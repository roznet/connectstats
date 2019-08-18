#!/usr/bin/env python3
#
# Simple utility to generate a credentials config file as we update the main credentials.json
#
# 


import json

with open( 'credentials.json', 'r') as jsonfile:
    full = json.load( jsonfile );
    sample = dict()
    for service,one in full.items():
        servicedict = dict()
        for key,val in one.items():
            if key.endswith('_url' ) or key.endswith('_callback') or key.endswith('_param'):
                servicedict[key] = val
            else:
                servicedict[key] = "***"
        sample[service] = servicedict

with open( 'credentials.sample.json', 'w' ) as outfile:
    json.dump( sample, outfile, indent = 2, sort_keys=True );
