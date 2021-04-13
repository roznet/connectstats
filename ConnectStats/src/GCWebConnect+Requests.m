//  MIT Licence
//
//  Created on 01/03/2014.
//
//  Copyright (c) 2014 Brice Rosenzweig.
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

#import "GCWebConnect+Requests.h"

#import "GCService.h"
#import "GCWebUrl.h"
#import "GCAppGlobal.h"

#import "GCGarminRequestActivityReload.h"
#import "GCGarminActivityTrack13Request.h"
#import "GCGarminRequestModernActivityTypes.h"
#import "GCGarminLoginSimulatorRequest.h"
#import "GCGarminLoginSSORequest.h"
#import "GCGarminRequestModernSearch.h"
#import "GCGarminRequestHeartRateZones.h"

#import "GCConnectStatsRequestSearch.h"
#import "GCConnectStatsRequestFitFile.h"
#import "GCConnectStatsRequestLogin.h"
#import "GCConnectStatsRequestWeather.h"

#import "GCHealthKitBodyRequest.h"
#import "GCHealthKitActivityRequest.h"
#import "GCHealthKitWorkoutsRequest.h"
#import "GCHealthKitDailySummaryRequest.h"
#import "GCHealthKitDayDetailRequest.h"
#import "GCHealthKitSourcesRequest.h"

#import "GCDerivedRequest.h"
#import "GCHealthOrganizer.h"
#import "ConnectStats-Swift.h"

@implementation GCWebConnect (Requests)

#pragma mark - search activity list

-(BOOL)downloadMissingActivityDetails:(NSUInteger)n{
    BOOL rv = true;
    NSArray * activities = [[GCAppGlobal organizer] activities];
    NSUInteger i = 0;
    NSDate * mostRecent = nil;
    NSDate * oldest = nil;
    for (GCActivity * activity in activities) {
        if ([activity trackPointsRequireDownload]) {
            NSTimeInterval since = [[activity date] timeIntervalSinceNow];
            // Only load the last year
            if (since > -3600. * 24.0 * 365.) {
                if( mostRecent == nil){
                    mostRecent = activity.date;
                    oldest = activity.date;
                }else{
                    if( [activity.date compare:oldest] == NSOrderedAscending){
                        oldest = activity.date;
                    }
                }
                [activity trackpoints];
            }
            i++;
        }
        if (i >= n) {
            break;
        }
    }
    if( oldest != nil && mostRecent != nil){
        RZLog(RZLogInfo, @"Download %lu Missing Details from %@ to %@", (unsigned long)i+1, oldest.YYYYdashMMdashDD, mostRecent.YYYYdashMMdashDD);
    }else{
        RZLog(RZLogInfo, @"Download Missing Details (none required out of %lu activities)", (unsigned long)activities.count);
        rv = false;
    }
    return rv;
}

-(BOOL)servicesBackgroundUpdate{
    BOOL rv = false;
    if( [[GCAppGlobal profile] configGetBool:CONFIG_CONNECTSTATS_ENABLE defaultValue:NO] &&
       [[GCAppGlobal profile] serviceCompletedFull:gcServiceConnectStats] &&
       [[GCAppGlobal profile] serviceSuccess:gcServiceConnectStats] ){
        // Run on main queue as it accesses a navigation Controller
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self addRequest:RZReturnAutorelease([[GCConnectStatsRequestBackgroundFetch alloc] init])];
        });
        rv = true;
    }

    return rv;
}
-(void)servicesSearch:(BOOL)reloadAll{
    if( ([[GCAppGlobal profile] configGetBool:CONFIG_CONNECTSTATS_ENABLE defaultValue:NO])){
        // Run on main queue as it accesses a navigation Controller
        dispatch_async(dispatch_get_main_queue(), ^(){
            BOOL connectStatsReload = reloadAll || ![[GCAppGlobal profile] serviceCompletedFull:gcServiceConnectStats];
            [self addRequest:[GCConnectStatsRequestLogin requestNavigationController:[GCAppGlobal currentNavigationController]]];
            [self addRequest:[GCConnectStatsRequestSearch requestWithStart:0 mode:connectStatsReload andNavigationController:[GCAppGlobal currentNavigationController]]];
        });
    }
    
    if ([[GCAppGlobal profile] configGetBool:CONFIG_GARMIN_ENABLE defaultValue:NO]) {
        if( [GCGarminReqBase killSwitchTriggered] ){
            RZLog(RZLogWarning, @"Garmin is turned off by killswitch");
        }else{
            dispatch_async(dispatch_get_main_queue(), ^(){
                BOOL garminStatsReload = reloadAll || ![[GCAppGlobal profile] serviceCompletedFull:gcServiceGarmin];
                NSInteger aStart = garminStatsReload ? [[GCAppGlobal profile] serviceAnchor:gcServiceGarmin] : 0;
                //[self addRequest:[[[GCGarminRequestModernActivityTypes alloc] init] autorelease]];
                [self addRequest:[[[GCGarminRequestModernSearch alloc] initWithStart:aStart andMode:garminStatsReload] autorelease]];
            });
        }
    }

    if ([[GCAppGlobal profile] configGetBool:CONFIG_STRAVA_ENABLE defaultValue:NO]) {
        dispatch_async(dispatch_get_main_queue(), ^(){
            BOOL stravaReload = (reloadAll || ![[GCAppGlobal profile] serviceCompletedFull:gcServiceStrava]);
            
            GCStravaRequestActivityList * req = RZReturnAutorelease([[GCStravaRequestActivityList alloc] initWithNavigationController:[GCAppGlobal currentNavigationController] page:0 reloadAll:stravaReload]);
            [self addRequest:req];
        });
    }

    if ([GCHealthKitRequest isSupported]) {
        if ([[GCAppGlobal profile] configGetBool:CONFIG_HEALTHKIT_ENABLE defaultValue:[GCAppGlobal healthStatsVersion]]) {
            if (![[GCAppGlobal profile] sourceIsSet]) {
                [self healthStoreCheckSource];
            }
            [self healthStoreUpdate];
        }
    }
    if ([[GCAppGlobal profile] configGetBool:CONFIG_ENABLE_DERIVED defaultValue:[GCAppGlobal connectStatsVersion]]) {
        [self derivedComputations:1];
    }
    // If on wifi, try to download extra missing details
    if ([[GCAppGlobal profile] configGetBool:CONFIG_WIFI_DOWNLOAD_DETAILS defaultValue:false] &&  [RZSystemInfo wifiAvailable]) {
        [self downloadMissingActivityDetails:15];
    }
}
-(void)servicesSearchRecentActivities{
    [self servicesLogin];
    [self servicesSearch:false];
}

-(void)servicesSearchAllActivities{
    [self servicesLogin];
    [self servicesSearch:true];
}

-(void)servicesResetLogin{
    [self resetSuccessfulLogin];
    [self servicesLogin];
}
-(void)servicesLogin{
    if (![self didLoginSuccessfully:gcWebServiceGarmin] && [[GCAppGlobal profile] configGetBool:CONFIG_GARMIN_ENABLE defaultValue:NO]) {
        if( [GCGarminReqBase killSwitchTriggered] ){
            RZLog(RZLogWarning, @"Garmin is turned off by killswitch");
        }else{
            [self garminLogin];
        }
    }
    
    // other services are automatic
}

#pragma mark - download track details

-(void)garminDownloadActivityTrackPoints13:(GCActivity*)act{
    // If the service for garmin was successfull, download anyway.
    // it's possible it's the detail of an old activities, downloaded before the service was turned off.
    if( [[GCAppGlobal profile] serviceSuccess:gcServiceGarmin] || [[GCAppGlobal profile] configGetBool:CONFIG_GARMIN_ENABLE defaultValue:NO] ){
        if( [GCGarminReqBase killSwitchTriggered] ){
            RZLog(RZLogWarning, @"Garmin is turned off by killswitch");
            return;
        }
        [self addRequest:[GCGarminActivityTrack13Request requestWithActivity:act]];
    }
}

-(void)garminDownloadActivitySummary:(NSString*)aId{
    if(  [[GCAppGlobal profile] configGetBool:CONFIG_GARMIN_ENABLE defaultValue:NO] ){
        if( [GCGarminReqBase killSwitchTriggered] ){
            RZLog(RZLogWarning, @"Garmin is turned off by killswitch");
            return;
        }
        [self addRequest:[[[GCGarminRequestActivityReload alloc] initWithId:aId] autorelease]];
    }
}


-(BOOL)isGarminSimulatorAccount:(NSString*)username andPassword:(NSString*)password{
    return ([username hasPrefix:@"simulator"] || [username hasPrefix:@"testaccount"]) && ([password isEqualToString:@"iamatesterfromapple"] || [password isEqualToString:@"iamafriendofbrice"]);
}

-(void)garminLogin{
    if (!self.isProcessing && [[GCAppGlobal profile] configGetBool:CONFIG_GARMIN_ENABLE defaultValue:NO]) {
        if( [GCGarminReqBase killSwitchTriggered] ){
            RZLog(RZLogWarning, @"Garmin is turned off by killswitch");
            return;
        }

        gcGarminLoginMethod method = (gcGarminLoginMethod)[[GCAppGlobal profile] configGetInt:CONFIG_GARMIN_LOGIN_METHOD defaultValue:GARMINLOGIN_DEFAULT];

        NSString * username = [[GCAppGlobal profile] currentLoginNameForService:gcServiceGarmin];
        NSString * password = [[GCAppGlobal profile] currentPasswordForService:gcServiceGarmin];

        bool simulatorAccount = [self isGarminSimulatorAccount:username andPassword:password];

        if( simulatorAccount ){
            method = gcGarminLoginMethodSimulator;
            RZLog(RZLogInfo, @"Test Username Detected <%@> entering simulator mode", username);
        }
        if (method == gcGarminLoginMethodSimulator) {
            [self clearCookies];
            GCGarminLoginSimulatorRequest * first  = [[[GCGarminLoginSimulatorRequest alloc] init] autorelease];
            GCGarminLoginSimulatorRequest * second = [[[GCGarminLoginSimulatorRequest alloc] initWithName:username andPwd:password] autorelease];
            if ( simulatorAccount ) {
                GCWebUseSimulator(true, [GCAppGlobal simulatorUrl]);
            }else{
                GCWebUseSimulator(false, nil);
            }
            //GCWebUseSimulator(true);
            [self clearRequests];
            [self resetStatus];
            [self addRequest:first];
            [self addRequest:second];
            self.status = GCWebStatusOK;
        }else if (method == gcGarminLoginMethodDirect){
            [self clearCookies];
            [self clearRequests];
            [self resetStatus];
            [self addRequest:[GCGarminLoginSSORequest requestWithUser:[[GCAppGlobal profile] currentLoginNameForService:gcServiceGarmin]
                                                                       andPwd:[[GCAppGlobal profile] currentPasswordForService:gcServiceGarmin]
                                                                   validation:^(){
                return [[GCAppGlobal profile] serviceEnabled:gcServiceGarmin];
            }]];
        }
    }
}

-(void)garminLogout{
    return;
    /*if (!self.processing) {
        [self clearCookies];
        [self.requests removeAllObjects];
        [self.requests addObject:[[[GCGarminLogout alloc] init] autorelease]];
        [self next];
    }*/
}

-(void)garminTestLogin{
    if (!self.isProcessing) {
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *each in cookieStorage.cookies) {
            [cookieStorage deleteCookie:each];
        }
        GCGarminLoginSimulatorRequest * first  = [[[GCGarminLoginSimulatorRequest alloc] init] autorelease];
        GCGarminLoginSimulatorRequest * second = [[[GCGarminLoginSimulatorRequest alloc] initWithName:[[GCAppGlobal profile] currentLoginNameForService:gcServiceGarmin]
                                                                                         andPwd:[[GCAppGlobal profile] currentPasswordForService:gcServiceGarmin]] autorelease];

        bool simulatorAccount = [self isGarminSimulatorAccount:second.uname andPassword:second.pwd];
        if (simulatorAccount) {
            GCWebUseSimulator(true,[GCAppGlobal simulatorUrl]);
        }else{
            GCWebUseSimulator(false,nil);
        }
        //GCWebUseSimulator(true);
        [self clearRequests];
        [self addRequest:first];
        [self addRequest:second];
        self.status = GCWebStatusOK;
    }
}
#pragma mark - connectstats

-(void)connectStatsDownloadActivityTrackpoints:(GCActivity*)act{
    if( [[GCAppGlobal profile] serviceSuccess:gcServiceConnectStats] || [[GCAppGlobal profile] configGetBool:CONFIG_CONNECTSTATS_ENABLE defaultValue:NO] ){
        dispatch_async(dispatch_get_main_queue(), ^(){
            if( [GCAppGlobal currentNavigationController] ){
                [self addRequest:[GCConnectStatsRequestFitFile requestWithActivity:act andNavigationController:[GCAppGlobal currentNavigationController]]];
            };
        });
    }
}
-(void)connectStatsDownloadWeather:(GCActivity *)act{
    if( [[GCAppGlobal profile] serviceSuccess:gcServiceConnectStats] || [[GCAppGlobal profile] configGetBool:CONFIG_CONNECTSTATS_ENABLE defaultValue:NO] ){
        dispatch_async(dispatch_get_main_queue(), ^(){
            if( [GCAppGlobal currentNavigationController] ){
                [self addRequest:[GCConnectStatsRequestWeather requestWithActivity:act andNavigationController:[GCAppGlobal currentNavigationController]]];
            };
        });
    }

}
#pragma mark - strava

-(void)stravaDownloadActivityTrackPoints:(GCActivity*)act{
    dispatch_async(dispatch_get_main_queue(), ^(){
        if ([GCAppGlobal currentNavigationController] && [[GCAppGlobal profile] configGetBool:CONFIG_STRAVA_ENABLE defaultValue:NO]) {
            GCStravaRequestStreams * req = RZReturnAutorelease([[GCStravaRequestStreams alloc] initWithNavigationController:[GCAppGlobal currentNavigationController] activity:act]);
            [self addRequest:req];
        }
    });
}

#pragma mark - healthstore

-(void)healthStoreUpdate{
    NSDate * startDate = [NSDate date];
    if( [[GCAppGlobal profile] configGetBool:CONFIG_HEALTHKIT_DAILY defaultValue:[GCAppGlobal healthStatsVersion]]){
        [self addRequest:[GCHealthKitDailySummaryRequest requestFor:startDate]];
        [self addRequest:[GCHealthKitDayDetailRequest requestForDate:startDate to:[[NSDate date] dateByAddingTimeInterval:-3600*24*7]]];
    }
    
    if ([[GCAppGlobal profile] configGetBool:CONFIG_HEALTHKIT_WORKOUT defaultValue:[GCAppGlobal healthStatsVersion]]) {
        if( [GCAppGlobal healthStatsVersion] ){
            GCHealthKitWorkoutsRequest * req = [GCHealthKitWorkoutsRequest request];
            //[req resetAnchor];
            [self addRequest:req];
        }else{
            RZLog(RZLogWarning, @"Disabled Workout from healthkit");
        }
    }
    [self addRequest:[GCHealthKitBodyRequest request]];
}

-(void)healthStoreDayDetails:(NSDate * )day{
    [self addRequest:[GCHealthKitDayDetailRequest requestForDate:day]];
}

-(void)healthStoreCheckSource{
    [self addRequest:[GCHealthKitSourcesRequest request]];
}

#pragma mark - derived
-(void)derivedComputations:(NSUInteger)n{
    [self addRequest:[GCDerivedRequest requestFor:n]];
}


@end
