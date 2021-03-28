#!/usr/bin/env python3
#
# This replicates the logic ConnectStats is using to logging to Garmin Connect so it's easier to debug/fix/trace
#
# to use charles proxy: 
# export REQUESTS_CA_BUNDLE=${HOME}/Downloads/charles-ssl-proxying-certificate.pem
# export GC_PASSWORD

import pytz
from datetime import datetime, timedelta
import requests
import os
import logging
from pprint import pprint
import sys
import getpass

class GarminConnectService:
   _obligatory_headers = {
       "Referer": "https://sync.tapiriik.com",
       "nk": "NT",
   }
   _garmin_signin_headers = {
       "nk": "NT",
       "origin": "https://sso.garmin.com"
   }

   def __init__(self,username,password):
       self.username = username
       self.password = password
       self.session = None
       
   def auth(self):
       session = requests.Session()
       
       data = {
           "username": self.username,
           "password": self.password,
           "_eventId": "submit",
           "embed": "true",
           # "displayNameRequired": "false"
       }
       params = {
           "service": "https://connect.garmin.com/modern",
           # "redirectAfterAccountLoginUrl": "http://connect.garmin.com/modern",
           # "redirectAfterAccountCreationUrl": "http://connect.garmin.com/modern",
           # "webhost": "olaxpw-connect00.garmin.com",
           "clientId": "GarminConnect",
           "gauthHost": "https://sso.garmin.com/sso",
           # "rememberMeShown": "true",
           # "rememberMeChecked": "false",
           "consumeServiceTicket": "false",
           # "id": "gauth-widget",
           # "embedWidget": "false",
           # "cssUrl": "https://static.garmincdn.com/com.garmin.connect/ui/src-css/gauth-custom.css",
           # "source": "http://connect.garmin.com/en-US/signin",
           # "createAccountShown": "true",
           # "openCreateAccount": "false",
           # "usernameShown": "true",
           # "displayNameShown": "false",
           # "initialFocus": "true",
           # "locale": "en"
       }

       known_errors = {
           ">sendEvent('FAIL')" : "Invalid Login",
           ">sendEvent('ACCOUNT_LOCKED')" : "Account Locked",
           "renewPassword" : "Renew Password",
           "temporarily unavailable": "Temporary Unavailable"
       }

       logging.info( 'pre Step' )
       preResp = session.get("https://sso.garmin.com/sso/signin", params=params)
       if preResp.status_code != 200:
           logging.error("pre Step Failed")
           return False
       
       logging.info( 'sso Step' )
       ssoResp = session.post("https://sso.garmin.com/sso/signin", headers=self._garmin_signin_headers, params=params, data=data, allow_redirects=False)
       if ssoResp.status_code != 200:
           logging.error( f'sso step failed {ssoResp.status_code}' )
           return False

       for (known_one,msg) in known_errors.items():
           if known_one in ssoResp.text:
               logging.error( f'sso step failed {msg}' )
               return False

       logging.info( 'gc Step' )
       gcResp = session.get("https://connect.garmin.com/modern" )
       if gcResp.status_code != 200:
           logging.error( f'GC redeem-start error {gcResp.status_code}' )
           return False
       
       session.headers.update(self._obligatory_headers)

       self.session = session

       return True

   def downloadActivityList(self, page = 0, pageSize = 20):
      if not self.session:
         self.auth()
      

      logging.info( 'api step' )    
      res = self.session.get("https://connect.garmin.com/modern/proxy/activitylist-service/activities/search/activities",
                             params={"start": page * pageSize, "limit": pageSize} ) 
      if res.status_code != 200:
         logging.error( f'api step failed {res.status_code}' )

      
      return res.text

# Setup debug logging of all headers/query executed
logging.basicConfig(format='%(levelname)s: %(message)s', level=logging.DEBUG)
logging.info( "starting" )
import http.client as http_client
http_client.HTTPConnection.debuglevel = 1
requests_log = logging.getLogger("requests.packages.urllib3")
requests_log.setLevel(logging.DEBUG)
requests_log.propagate = True

username = sys.argv[1]
password = os.environ.get( 'GC_PASSWORD' )
if not password:
    password = getpass.getpass('GC_PASSWORD not set, enter password for {}: '.format( username ) )
gc = GarminConnectService(username,password)
with open( 't.json', 'w' ) as of:
    data = gc.downloadActivityList()
    of.write( data )
    
