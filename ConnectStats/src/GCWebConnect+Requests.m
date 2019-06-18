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
#import "GCActivityTennis.h"

#import "GCGarminRequestSearch.h"
#import "GCGarminRequestActivityReload.h"
#import "GCGarminActivityTrack13Request.h"
#import "GCGarminRequestModernActivityTypes.h"
#import "GCGarminLoginSimulatorRequest.h"
#import "GCGarminLoginSSORequest.h"
#import "GCGarminRequestActivityWeather.h"
#import "GCGarminRequestModernSearch.h"
#import "GCGarminRequestHeartRateZones.h"

#import "GCConnectStatsRequestSearch.h"
#import "GCConnectStatsRequestFitFile.h"

#import "GCSportTracksActivityList.h"
#import "GCSportTracksActivityDetail.h"

#import "GCFitBitActivities.h"
#import "GCFitBitWeight.h"

#import "GCWithingsBodyMeasures.h"
#import "GCWithingsActivityMeasures.h"
#import "GCWithingsSleepMeasures.h"
#import "GCWithingsRequestOnce.h"

#import "GCHealthKitBodyRequest.h"
#import "GCHealthKitActivityRequest.h"
#import "GCHealthKitWorkoutsRequest.h"
#import "GCHealthKitDailySummaryRequest.h"
#import "GCHealthKitDayDetailRequest.h"
#import "GCHealthKitExportActivity.h"
#import "GCHealthKitSourcesRequest.h"

#import "GCStravaActivityList.h"
#import "GCStravaActivityStreams.h"
#import "GCStravaSegmentListStarred.h"
#import "GCStravaAthlete.h"
#import "GCStravaSegmentEfforts.h"
#import "GCStravaSegmentEffortStream.h"
#import "GCStravaTrainingZones.h"

#import "GCBabolatLoginRequest.h"

#import "GCDerivedRequest.h"
#import "GCHealthOrganizer.h"

@implementation GCWebConnect (Requests)

#pragma mark - search activity list

-(void)downloadMissingActivityDetails:(NSUInteger)n{
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
        RZLog(RZLogInfo, @"Download Missing Details (none required out of %lu activities", (unsigned long)activities.count);
    }
}

-(void)nonGarminSearch{
    if( ([[GCAppGlobal profile] configGetBool:CONFIG_CONNECTSTATS_ENABLE defaultValue:NO])){
#if TARGET_IPHONE_SIMULATOR
        // SWITCH TO PROD LATER
        GCWebUseConnectStatsDevServer(true,nil);
#endif
        [self addRequest:[GCConnectStatsRequestSearch requestWithStart:0 mode:true andNavigationController:[GCAppGlobal currentNavigationController]]];
    }
    
    if ([[GCAppGlobal profile] configGetBool:CONFIG_STRAVA_ENABLE defaultValue:NO]) {
        [self addRequest:[GCStravaActivityList stravaActivityList:[GCAppGlobal currentNavigationController] start:0 andMode:false]];
    }
    // For testing
    if([[GCAppGlobal profile] configGetBool:CONFIG_STRAVA_SEGMENTS defaultValue:NO]){

        [self addRequest:[GCStravaAthlete stravaAthlete:[GCAppGlobal currentNavigationController]]];
        [self addRequest:[GCStravaSegmentListStarred segmentListStarred:[GCAppGlobal currentNavigationController]]];
        //[self addRequest:[GCStravaSegmentEfforts segmentEfforts:[GCAppGlobal currentNavigationController] for:@"1943525" and:@"1656888"]];
        //[self addRequest:[GCStravaSegmentEffortStream stravaEffortStream:[GCAppGlobal currentNavigationController] for:@"15963924664" in:@"1943525"]];

        //[self addRequest:[GCStravaTrainingZones stravaTrainingZones:[GCAppGlobal currentNavigationController]]];

    }

    if ([[GCAppGlobal profile] configGetBool:CONFIG_SPORTTRACKS_ENABLE defaultValue:NO]) {
        [self addRequest:[GCSportTracksActivityList activityList:[GCAppGlobal currentNavigationController]]];
    }
    if ([[GCAppGlobal profile] configGetBool:CONFIG_BABOLAT_ENABLE defaultValue:false]) {
        [self addRequest:[GCBabolatLoginRequest babolatLoginRequest]];
    }
    if ([[GCAppGlobal profile] configGetBool:CONFIG_WITHINGS_AUTO defaultValue:false]) {
        [self withingsUpdate];
    }
    if ([GCHealthKitRequest isSupported]) {
        if ([[GCAppGlobal profile] configGetBool:CONFIG_HEALTHKIT_ENABLE defaultValue:[GCAppGlobal healthStatsVersion]]) {
            if (![[GCAppGlobal profile] sourceIsSet]) {
                [self healthStoreCheckSource];
            }
            [self healthStoreUpdate];
        }
    }
    if ([[GCAppGlobal profile] configGetBool:CONFIG_FITBIT_ENABLE defaultValue:NO])  {
        [self fitBitUpdate];
    }
    if ([[GCAppGlobal profile] configGetBool:CONFIG_ENABLE_DERIVED defaultValue:[GCAppGlobal connectStatsVersion]]) {
        [self derivedComputations:1];
    }
    // If on wifi, try to download extra missing details
    if ([GCAppGlobal configGetBool:CONFIG_WIFI_DOWNLOAD_DETAILS defaultValue:YES] &&  [RZSystemInfo wifiAvailable]) {
        //[self downloadMissingActivityDetails:15];
    }
}

-(void)servicesSearchActivitiesFrom:(NSUInteger)aStart reloadAll:(BOOL)rAll{
    [self servicesLogin];
    if ([[GCAppGlobal profile] configGetBool:CONFIG_GARMIN_ENABLE defaultValue:NO]) {
        if( [[GCAppGlobal profile] configGetBool:CONFIG_GARMIN_USE_MODERN defaultValue:true] ){
            [self addRequest:[[[GCGarminRequestModernSearch alloc] initWithStart:aStart andMode:rAll] autorelease]];
        }else{
            [self addRequest:[[[GCGarminSearch alloc] initWithStart:aStart percent:0.0 andMode:rAll] autorelease]];
        }
    }
    [self nonGarminSearch];
}

-(void)servicesSearchRecentActivities{
    [self servicesLogin];
    if ([[GCAppGlobal profile] configGetBool:CONFIG_GARMIN_ENABLE defaultValue:NO]) {
        [self addRequest:[[[GCGarminRequestModernActivityTypes alloc] init] autorelease]];
        [self addRequest:[[[GCGarminRequestModernSearch alloc] initWithStart:0 andMode:false] autorelease]];
        // get user/zones
        [self addRequest:[[[GCGarminRequestHeartRateZones alloc] init] autorelease]];
    }

    [self nonGarminSearch];
}
-(void)servicesSearchAllActivities{
    if ([[GCAppGlobal profile] configGetBool:CONFIG_STRAVA_ENABLE defaultValue:NO]) {
        [self addRequest:[GCStravaActivityList stravaActivityList:[GCAppGlobal currentNavigationController] start:0 andMode:true]];
    }

    if ([[GCAppGlobal profile] configGetBool:CONFIG_GARMIN_ENABLE defaultValue:NO]) {
        if( [[GCAppGlobal profile] configGetBool:CONFIG_GARMIN_USE_MODERN defaultValue:true] ){
            [self addRequest:[[[GCGarminRequestModernSearch alloc] initWithStart:0 andMode:true] autorelease]];
        }else{
            [self addRequest:[[[GCGarminSearch alloc] initWithStart:0 percent:0.0 andMode:true] autorelease]];
        }
    }
}

-(void)servicesResetLogin{
    [self resetSuccessfulLogin];
    [self clearCookies];
    [GCStravaReqBase signout];
    [GCSportTracksBase signout];
    [self servicesLogin];
}
-(void)servicesLogin{
    if (![self didLoginSuccessfully:gcWebServiceGarmin]&& [[GCAppGlobal profile] configGetBool:CONFIG_GARMIN_ENABLE defaultValue:NO]) {
        [self garminLogin];
    }
    // other services are automatic
}


#pragma mark - withings
-(void)withingsChangeUser:(NSString*)shortname{
    NSArray * users = [[GCAppGlobal profile] configGetArray:CONFIG_WITHINGS_USERSLIST defaultValue:@[]];
    NSString * current = [[GCAppGlobal profile] configGetString:CONFIG_WITHINGS_USER defaultValue:@""];
    if (users && ![shortname isEqualToString:current]) {
        NSDictionary * found = nil;
        for (NSDictionary * one in users) {
            if ([one[@"shortname"] isEqualToString:current]) {
                found = one;
                break;
            }
        }
        if (found) {
            [[GCAppGlobal profile] configSet:CONFIG_WITHINGS_USER stringVal:shortname];
            [GCAppGlobal saveSettings];
            [[GCAppGlobal health] clearAllMeasures];
            [[GCAppGlobal profile] serviceSuccess:gcServiceWithings set:NO];
            [self withingsUpdate];
        }
    }
}
-(void)withingsUpdate{
#ifdef WITHINGS_OAUTH
    [self addRequest:[GCWithingsBodyMeasures measuresSinceDate:nil with:[GCAppGlobal currentNavigationController]]];
    if ([GCAppGlobal healthStatsVersion]) {
        [self addRequest:[GCWithingsSleepMeasures measuresSinceDate:nil with:[GCAppGlobal currentNavigationController]]];
        [self addRequest:[GCWithingsActivityMeasures measuresFromDate:nil toDate:[NSDate date] with:[GCAppGlobal currentNavigationController]]];
    }
#else
    [self addRequest:[GCWithingsRequestOnce withingsRequestOnce]];
#endif
}
#pragma mark - download track details


-(void)garminDownloadActivityTrackPoints13:(GCActivity*)act{
    if(  [[GCAppGlobal profile] configGetBool:CONFIG_GARMIN_ENABLE defaultValue:NO] ){
        [self addRequest:[GCGarminActivityTrack13Request requestWithActivity:act]];
    }
}

-(void)garminDownloadWeather:(GCActivity*)activity{
    //[self addRequest:[GCGarminActivityWeatherHtml garminActivityWeatherHtml:aId]];
    [self addRequest:[GCGarminRequestActivityWeather requestWithActivity:activity]];
}

-(void)garminDownloadActivitySummary:(NSString*)aId{
    if(  [[GCAppGlobal profile] configGetBool:CONFIG_GARMIN_ENABLE defaultValue:NO] ){
        [self addRequest:[[[GCGarminRequestActivityReload alloc] initWithId:aId] autorelease]];
    }
}


-(BOOL)isGarminSimulatorAccount:(NSString*)username andPassword:(NSString*)password{
    return ([username hasPrefix:@"simulator"] || [username hasPrefix:@"testaccount"]) && ([password isEqualToString:@"iamatesterfromapple"] || [password isEqualToString:@"iamafriendofbrice"]);
}

-(void)garminLogin{
    if (!self.isProcessing && [[GCAppGlobal profile] configGetBool:CONFIG_GARMIN_ENABLE defaultValue:NO]) {
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
            [self.requests removeAllObjects];
            [self resetStatus];
            [self.requests addObject:first];
            [self.requests addObject:second];
            self.status = GCWebStatusOK;
        }else if (method == gcGarminLoginMethodDirect){
            [self clearCookies];
            [self.requests removeAllObjects];
            [self resetStatus];
            [self.requests addObject:[GCGarminLoginSSORequest requestWithUser:[[GCAppGlobal profile] currentLoginNameForService:gcServiceGarmin]
                                                                       andPwd:[[GCAppGlobal profile] currentPasswordForService:gcServiceGarmin]]];
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
        [self.requests removeAllObjects];
        [self.requests addObject:first];
        [self.requests addObject:second];
        self.status = GCWebStatusOK;
    }
}
#pragma mark - connectstats

-(void)connectStatsDownloadActivityTrackpoints:(GCActivity*)act{
    if( [GCAppGlobal currentNavigationController] && [[GCAppGlobal profile] configGetBool:CONFIG_CONNECTSTATS_ENABLE defaultValue:NO]){
        [self addRequest:[GCConnectStatsRequestFitFile requestWithActivity:act andNavigationController:[GCAppGlobal currentNavigationController]]];
    }
}
#pragma mark - strava

-(void)stravaDownloadActivityTrackPoints:(GCActivity*)act{
    if ([GCAppGlobal currentNavigationController] && [[GCAppGlobal profile] configGetBool:CONFIG_STRAVA_ENABLE defaultValue:NO]) {
        [self addRequest:[GCStravaActivityStreams stravaActivityStream:[GCAppGlobal currentNavigationController] for:act]];
    }
}

#pragma mark - sporttracks

-(void)sportTracksDownloadActivityTrackPoints:(NSString*)aId withUri:(NSString*)uri{
    if ([GCAppGlobal currentNavigationController]) {
        [self addRequest:[GCSportTracksActivityDetail activityDetail:[GCAppGlobal currentNavigationController] forActivityId:aId andUri:uri]];
    }

}

#pragma mark - healthstore

-(void)healthStoreUpdate{
    NSDate * startDate = [NSDate date];
    [self addRequest:[GCHealthKitDailySummaryRequest requestFor:startDate]];
    if ([GCAppGlobal healthStatsVersion] && [[GCAppGlobal profile] configGetBool:CONFIG_HEALTHKIT_WORKOUT defaultValue:[GCAppGlobal healthStatsVersion]]) {
        if( [GCAppGlobal healthStatsVersion] ){
            GCHealthKitWorkoutsRequest * req = [GCHealthKitWorkoutsRequest request];
            //[req resetAnchor];
            [self addRequest:req];
        }else{
            RZLog(RZLogWarning, @"Disabled Workout from healthkit");
        }
    }
    [self addRequest:[GCHealthKitDayDetailRequest requestForDate:startDate to:[[NSDate date] dateByAddingTimeInterval:-3600*24*7]]];
    [self addRequest:[GCHealthKitBodyRequest request]];
}

-(void)healthStoreExportActivity:(GCActivity*)act{
    [self addRequest:[GCHealthKitExportActivity healthKitExportActivity:act]];
}

-(void)healthStoreDayDetails:(NSDate * )day{
    [self addRequest:[GCHealthKitDayDetailRequest requestForDate:day]];
}

-(void)healthStoreCheckSource{
    [self addRequest:[GCHealthKitSourcesRequest request]];
}

#pragma mark - fitbit

-(void)fitBitUpdate{
    [self addRequest:[GCFitBitActivities activitiesForDate:[NSDate date] with:[GCAppGlobal currentNavigationController]]];
    NSDate * last = [[[GCAppGlobal organizer] activities].lastObject date];
    [self addRequest:[GCFitBitWeight activitiesFromDate:last to:[NSDate date] with:[GCAppGlobal currentNavigationController]]];
}

-(void)fitBitUpdateFromDate:(NSDate*)date{
    [self addRequest:[GCFitBitActivities activitiesForDate:date with:[GCAppGlobal currentNavigationController]]];
}

#pragma mark - Babolat

-(void)babolatDownloadTennisActivityDetails:(NSString*)aId{
    if ([GCActivityTennis isTennisActivityId:aId]) {
        GCBabolatLoginRequest * req = [GCBabolatLoginRequest babolatLoginRequest];
        req.sessionId = [[GCService service:gcServiceBabolat] serviceIdFromActivityId:aId];
        [self addRequest:req];
    }
}

#pragma mark - derived
-(void)derivedComputations:(NSUInteger)n{
    [self addRequest:[GCDerivedRequest requestFor:n]];
}


@end
