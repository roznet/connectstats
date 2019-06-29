//  MIT Licence
//
//  Created on 06/09/2012.
//
//  Copyright (c) 2012 Brice Rosenzweig.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//  

#import <Foundation/Foundation.h>

void GCWebUseSimulator( BOOL abool, NSString * url);
void GCWebSetSimulatorError( BOOL abool);
void GCWebSetSimulatorState( NSString * state);
void GCWebUseConnectStatsDevServer(BOOL abool, NSString * url);
/**
 This will only take effect after the next signin to the simulator
 */
void GCWebSetSimulatorDir( NSString * dir);
BOOL GCWebSimulatorIsInUse(void);

NSString * GCWebSimulatorSigninURL( NSString * uname, NSString * pwd);
NSString * GCWebLogoutURL(void);

NSString * GCWebConnectStatsValidateUser(void);
NSString * GCWebConnectStatsSearch(void);
NSString * GCWebConnectStatsFitFile(void);
NSString * GCWebConnectStatsRegisterUser( NSString * accessToken, NSString * accessTokenSecret);

NSString * GCWebSearchURL( NSUInteger start );
NSString * GCWebModernSearchURL( NSUInteger start, NSUInteger requestCount );

NSString * GCWebActivityURLSummary( NSString * activityID);
NSString * GCWebActivityURLSplits( NSString * activityID);
NSString * GCWebActivityURLFitFile( NSString * activityID);

NSString * GCWebActivityTypes(void);
NSString * GCWebUserData(void);
NSString * GCWebGarminHeartRate(void);

NSString * GCWebGoogleEarthURL( NSString*aId);
NSString * GCWebUploadURL( NSString*dir);

NSString * GCWebStravaAuthentication(void);
NSString * GCWebStravaUpload(void);

NSString * GCWebWithingsOnce(void);
NSString * GCWebWithingsUserList(NSString*email,NSString*hash);
NSString * GCWebWithingsMeasure(NSString*uid,NSString*key);

NSString * GCWebWeatherHtml(NSString*aId);

NSString * GCWebActivityURLDetail( NSString * activityID);

