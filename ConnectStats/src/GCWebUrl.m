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

#import "GCWebUrl.h"

// Withings:
// Your OAuth key is :e555eef15ef1526431f5bd6c721e8023c7d0d84dcb8461cc67d83f45870
// Your OAuth secret is :1cd7f11c1e6d48e040ec58cf58fee1f1d30492ddc70c46f60c7575978dd
// https://oauth.withings.com/account/request_token
// https://oauth.withings.com/account/authorize

// Garmin
//
// Fit Files:
//  https://connect.garmin.com/modern/proxy/download-service/files/activity/988460411
//
// http://connect.garmin.com/proxy/goal-service-1.1/index.html
// http://connect.garmin.com/proxy/activity-service-1.3/
// http://connect.garmin.com/proxy/activity-search-service-1.2/
// http://connect.garmin.com/proxy/upload-service-1.1/
// http://connect.garmin.com/proxy/goal-service-1.1/
// http://connect.garmin.com/proxy/user-service-1.0/
// http://connect.garmin.com/proxy/calendar-service-1.0/
// http://connect.garmin.com/proxy/device-service-1.1/
// http://connect.garmin.com/proxy/course-service-1.0/
// http://connect.garmin.com/proxy/workout-service-1.0/
//
// Ex http://connect.garmin.com/proxy/goal-service-1.1/json/goals?status=ACTIVE
//    http://connect.garmin.com/proxy/goal-service-1.1/json/goalType
//
//    http://connect.garmin.com/proxy/activity-service-1.3/json/activity_types
//    http://connect.garmin.com/proxy/activity-service-1.3/json/event_types
//
// Friends:
//    http://connect.garmin.com/proxy/activitylist-service/activities/comments/JERICHO?start=1&limit=20
//    http://connect.garmin.com/proxy/userprofile-service/socialProfile/connections
//    http://connect.garmin.com/proxy/activitylist-service/activities/comments/subscriptionFeed?start=1&limit=10
//    https://sso.garmin.com/sso/login?service=http%3A%2F%2Fconnect.garmin.com%2Fpost-auth%2Flogin&webhost=olaxpw-connect03.garmin.com&source=http%3A%2F%2Fconnect.garmin.com%2Fen-US%2Fsignin&redirectAfterAccountLoginUrl=http%3A%2F%2Fconnect.garmin.com%2Fpost-auth%2Flogin&redirectAfterAccountCreationUrl=http%3A%2F%2Fconnect.garmin.com%2Fpost-auth%2Flogin&gauthHost=https%3A%2F%2Fsso.garmin.com%2Fsso&locale=en&id=gauth-widget&cssUrl=https%3A%2F%2Fstatic.garmincdn.com%2Fcom.garmin.connect%2Fui%2Fsrc-css%2Fgauth-custom.css&clientId=GarminConnect&rememberMeShown=true&rememberMeChecked=false&createAccountShown=true&openCreateAccount=false&usernameShown=true&displayNameShown=false&consumeServiceTicket=false&initialFocus=true&embedWidget=false
//
// TrainingPeaks
// List of Workouts:
// GET /tpwebservices/service.asmx/GetWorkoutsForAthlete?username=string&password=string&startDate=string&endDate=string HTTP/1.1
// Host: www.trainingpeaks.com
//
// Getperson ID:
// https://www.trainingpeaks.com/tpwebservices/service.asmx/AuthenticateAccount?username=bricerosenzweig&password=
// https://www.trainingpeaks.com/m/Shared/PersonInfo.js  -> get personId
//
// Single Workout
// GET /tpwebservices/service.asmx/GetExtendedWorkoutsForAccessibleAthlete?username=string&password=string&personId=string&workoutIds=string&workoutIds=string HTTP/1.1
// Host: www.trainingpeaks.com
//
// http://www.trainingpeaks.com/tpwebservices/service.asmx/GetExtendedWorkoutsForAccessibleAthlete?username=bricerosenzweig&password=&personId=1230459&workoutIds=183404610&workoutIds=183404610

// GARMIN MODERN:
// https://connect.garmin.com/modern/proxy/activity-service/activity/718039360/splits
// https://connect.garmin.com/modern/proxy/weather-service/weather/718039360
// https://connect.garmin.com/modern/proxy/biometric-service/heartRateZones/
// https://connect.garmin.com/modern/proxy/device-service/deviceservice/device-info/active/bricerosenzweig
// https://connect.garmin.com/modern/proxy/device-service/deviceservice/device-info/3891352043

// HTTP_USER_AGENT Mac @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/601.4.4 (KHTML, like Gecko) Version/9.0.3 Safari/601.4.4"

static BOOL useSimulator = false;
static BOOL simulatorError = false;
static NSString * simulatorURL = nil;
static NSString * simulatorState = nil;
static NSString * simulatorDir = nil;

void GCWebUseSimulator( BOOL abool, NSString * url){
    useSimulator = abool;
    if( url == nil){
#if TARGET_IPHONE_SIMULATOR
        simulatorURL = @"https://localhost";
        //simulatorURL = @"https://www.ro-z.net";
#else
        simulatorURL = @"https://www.ro-z.net";
#endif
    }else{
        simulatorURL = url;
    }
}

void GCWebSetSimulatorState( NSString * state){
    RZRelease(simulatorState);
    simulatorState = state;
    RZRetain(simulatorState);
}

void GCWebSetSimulatorDir( NSString * dir){
    RZRelease(simulatorDir);
    simulatorDir = dir;
    RZRetain(simulatorDir);
}


void GCWebSetSimulatorError( BOOL abool){
    simulatorError = abool;
}
BOOL GCWebSimulatorIsInUse(){
    return useSimulator;
}

#pragma mark - ConnectStats

NSString * GCWebConnectStatsPrefixForConfig(gcWebConnectStatsConfig config){
    switch (config) {
        case gcWebConnectStatsConfigProductionRozNet:
        case gcWebConnectStatsConfigEnd:
            return @"https://ro-z.net/prod";
        case gcWebConnectStatsConfigProductionConnectStatsApp:
            return @"https://connectstats.app/prod";
        case gcWebConnectStatsConfigLocalProdTesting:
            return @"https://localhost.ro-z.me/prod";
        case gcWebConnectStatsConfigLocalDevTesting:
            return @"https://localhost.ro-z.me/dev";
        case gcWebConnectStatsConfigRemoteDevTesting:
            return @"https://connectstats.app/dev";
    }
}
gcWebConnectStatsConfig GCWebConnectStatsConfigForRedirect(NSString * redirect){
    if( [redirect isEqualToString:@"https://ro-z.net/prod"] ){
        return gcWebConnectStatsConfigProductionRozNet;
    }else if ([redirect isEqualToString:@"https://localhost.ro-z.me/prod"]){
        return gcWebConnectStatsConfigLocalProdTesting;
    }else if ([redirect isEqualToString:@"https://localhost.ro-z.me/dev"]){
        return gcWebConnectStatsConfigLocalDevTesting;
    }else if ([redirect isEqualToString:@"https://connectstats.app/dev"] ){
        return gcWebConnectStatsConfigRemoteDevTesting;
    }else if ([redirect isEqualToString:@"https://connectstats.app/prod"] ){
        return gcWebConnectStatsConfigProductionConnectStatsApp;
    }else{
        return gcWebConnectStatsConfigEnd;
    }
}

NSString * GCWebConnectStatsApiCheck(gcWebConnectStatsConfig config){
    NSString * url = GCWebConnectStatsPrefixForConfig(useSimulator ? gcWebConnectStatsConfigLocalProdTesting : config);
    
    if (simulatorError) {
        return [NSString stringWithFormat:@"%@/garminsimul/samples/last_search_error.html", simulatorURL];
    }else{
        return [NSString stringWithFormat:@"%@/api/connectstats/apicheck",url];
    }
}
NSString * GCWebConnectStatsSearch(gcWebConnectStatsConfig config){
    NSString * url = GCWebConnectStatsPrefixForConfig(useSimulator ? gcWebConnectStatsConfigLocalProdTesting : config);
    
    if (simulatorError) {
        return [NSString stringWithFormat:@"%@/garminsimul/samples/last_search_error.html", simulatorURL];
    }else{
        return [NSString stringWithFormat:@"%@/api/connectstats/search",url];
    }
}

NSString * GCWebConnectStatsFitFile(gcWebConnectStatsConfig config){
    NSString * url = GCWebConnectStatsPrefixForConfig(useSimulator ? gcWebConnectStatsConfigLocalProdTesting : config);

    if (simulatorError) {
        return [NSString stringWithFormat:@"%@/garminsimul/samples/last_search_error.html", simulatorURL];
    }else{
        return [NSString stringWithFormat:@"%@/api/connectstats/file",url];
    }

}

NSString * GCWebConnectStatsWeather(gcWebConnectStatsConfig config){
    NSString * url = GCWebConnectStatsPrefixForConfig(useSimulator ? gcWebConnectStatsConfigLocalProdTesting : config);

    if (simulatorError) {
        return [NSString stringWithFormat:@"%@/garminsimul/samples/last_search_error.html", simulatorURL];
    }else{
        return [NSString stringWithFormat:@"%@/api/connectstats/json",url];
    }

}


NSString * GCWebConnectStatsRequestBackfill(gcWebConnectStatsConfig config){
    NSString * url = GCWebConnectStatsPrefixForConfig(useSimulator ? gcWebConnectStatsConfigLocalProdTesting : config);
    
    if (simulatorError) {
        return [NSString stringWithFormat:@"%@/garminsimul/samples/last_search_error.html", simulatorURL];
    }else{
        return [NSString stringWithFormat:@"%@/api/garmin/backfill",url];
    }
}

NSString * GCWebConnectStatsValidateUser(gcWebConnectStatsConfig config){
    NSString * url = GCWebConnectStatsPrefixForConfig(useSimulator ? gcWebConnectStatsConfigLocalProdTesting : config);

    if (simulatorError) {
        return [NSString stringWithFormat:@"%@/garminsimul/samples/last_search_error.html", simulatorURL];
    }else{
        return [NSString stringWithFormat:@"%@/api/connectstats/validateuser",url];
    }
}



NSString * GCWebConnectStatsRegisterUser( gcWebConnectStatsConfig config, NSString * accessToken, NSString * accessTokenSecret){
    NSString * url = GCWebConnectStatsPrefixForConfig(useSimulator ? gcWebConnectStatsConfigLocalProdTesting : config);

    if (simulatorError) {
        return [NSString stringWithFormat:@"%@/garminsimul/samples/last_search_error.html", simulatorURL];
    }else{
        return [NSString stringWithFormat:@"%@/api/connectstats/user_register?userAccessToken=%@&userAccessTokenSecret=%@",url, accessToken, accessTokenSecret];
    }
}

#pragma mark - Garmin

NSString * GCWebSimulatorSigninURL( NSString * uname, NSString * pwd){
    if (uname) {
        NSString * diroption = simulatorDir ? [NSString stringWithFormat:@"&dir=%@", simulatorDir] : @"";
        NSString * url = [NSString stringWithFormat:@"%@/garminsimul/signin.php?username=%@&password=%@%@",
                          simulatorURL,
                          RZWebEncodeURL(uname),
                          RZWebEncodeURL(pwd),
                          diroption
                          ];
        return url;
    }else{
        return [NSString stringWithFormat:@"%@/garminsimul/signin.php", simulatorURL];
    }
}

NSString * GCWebSearchURL( NSUInteger start ){
    if (useSimulator) {
        if (simulatorError) {
            return [NSString stringWithFormat:@"%@/garminsimul/samples/last_search_error.html", simulatorURL];
        }else{
            return [NSString stringWithFormat:@"%@/garminsimul/json.php?filename=last_search_%d%@", simulatorURL, (int)start,simulatorState?: @""];
        }
    }else{
        //https://connect.garmin.com/modern/proxy/activitylist-service/activities?start=1&limit=20
        return [NSString stringWithFormat:@"https://connect.garmin.com/proxy/activity-search-service-1.2/json/activities?start=%d&limit=20", (int)start];
    }
}

NSString * GCWebModernSearchURL( NSUInteger start, NSUInteger requestCount ){
    if (useSimulator) {
        if (simulatorError) {
            return [NSString stringWithFormat:@"%@/garminsimul/samples/last_search_error.html", simulatorURL];
        }else{
            return [NSString stringWithFormat:@"%@/garminsimul/json.php?filename=last_modern_search_%d%@", simulatorURL, (int)start,simulatorState?: @""];
        }
    }else{
        //
        return [NSString stringWithFormat:@"https://connect.garmin.com/modern/proxy/activitylist-service/activities?start=%d&limit=%d", (int)start,(int)requestCount];
    }

}

NSString * GCWebActivityURLDetail( NSString * activityID){

    if(useSimulator){
        return [NSString stringWithFormat:@"%@/garminsimul/json.php?filename=activitytrack_%@&state=%@", simulatorURL, activityID,simulatorState?:@""];
    }else{

        //return [NSString stringWithFormat:@"http://connect.garmin.com/proxy/activity-service-1.3/json/activityDetails/%@?maxSize=100000",activityID];
        return [NSString stringWithFormat:@"https://connect.garmin.com/modern/proxy/activity-service/activity/%@/details?maxChartSize=1000&maxPolylineSize=1000",activityID];
    }
}
NSString * GCWebActivityURLSummary( NSString * activityID){
    if (useSimulator) {
        return [NSString stringWithFormat:@"%@/garminsimul/detailjson.php?id=%@&state=%@", simulatorURL, activityID,simulatorState?:@""];
    }else{
        return [NSString stringWithFormat:@"https://connect.garmin.com/modern/proxy/activity-service/activity/%@",activityID];
    }
}


NSString * GCWebActivityURLSplits( NSString * activityID){
    if (useSimulator) {
        return [NSString stringWithFormat:@"%@/garminsimul/detailjson.php?id=%@&state=%@", simulatorURL, activityID,simulatorState?:@""];
    }else{
        return [NSString stringWithFormat:@"https://connect.garmin.com/modern/proxy/activity-service/activity/%@/splits",activityID];
    }
}

NSString * GCWebActivityURLFitFile( NSString * activityID){
    if (useSimulator) {
        return [NSString stringWithFormat:@"%@/garminsimul/detailfit.php?id=%@&state=%@", simulatorURL, activityID,simulatorState?:@""];
    }else{
        return [NSString stringWithFormat:@"https://connect.garmin.com/modern/proxy/download-service/files/activity/%@",activityID];
    }
}

#pragma mark - Garmin Info

NSString * GCWebWeatherHtml(NSString*aId){
    if (useSimulator) {
        return [NSString stringWithFormat:@"%@/garminsimul/weather.php?activityId=%@",simulatorURL,aId];
    }else{
        return [NSString stringWithFormat:@"https://connect.garmin.com/modern/proxy/weather-service/weather/%@", aId];
        //return [NSString stringWithFormat:@"http://connect.garmin.com/activity/%@", aId];
    }
}

NSString * GCWebActivityTypes(){
    if (useSimulator) {
        return [NSString stringWithFormat:@"%@/garminsimul/samples2/activity_types.json", simulatorURL];
    }else{
        //URL	https://connect.garmin.com/modern/proxy/activity-service/activity/activityTypes

        return @"https://connect.garmin.com/proxy/activity-service-1.3/json/activity_types";
    }
}

NSString * GCWebActivityTypesModern(){
    if (useSimulator) {
        return [NSString stringWithFormat:@"%@/garminsimul/samples_fullmodern/activity_types_modern.json", simulatorURL];
    }else{
        return @"https://connect.garmin.com/modern/proxy/activity-service/activity/activityTypes";
    }
}


NSString * GCWebUserData(){
    if (useSimulator) {
        return [NSString stringWithFormat:@"%@/garminsimul/samples/user.json", simulatorURL];
    }else{
        return @"https://connect.garmin.com/modern/proxy/user-service-1.0/json/user";
    }
}

NSString * GCWebGarminHeartRate(){
    if (useSimulator) {
        return [NSString stringWithFormat:@"%@/garminsimul/json.php?filename=user_hr_zones", simulatorURL];
    }else{
        return @"https://connect.garmin.com/modern/proxy/biometric-service/heartRateZones/";
    }
}

#pragma mark - Obsolete

NSString * GCWebGoalsSearch(NSString*type){
    return [NSString stringWithFormat:@"https://connect.garmin.com/proxy/goal-service-1.1/json/goals?status=%@",type];
}


NSString * GCWebActivityURLSwim( NSString * activityID){
    if (useSimulator) {
        return [NSString stringWithFormat:@"%@/garminsimul/json.php?dir=activities&filename=activity_%@%@", simulatorURL, activityID,simulatorState?:@""];
    }else{
        return [NSString stringWithFormat:@"https://connect.garmin.com/proxy/activity-service-1.3/json/activity/%@?maxSize=100000",activityID];
    }
}


NSString * GCWebLogoutURL(){
    return @"https://connect.garmin.com/reports?actionMethod=page%2Fhome%2Freports.xhtml%3Aidentity.logout";
}

NSString * GCWebUploadURL( NSString*dir){
    NSString * server = @"www.ro-z.net";
#if TARGET_IPHONE_SIMULATOR
    //server = @"localhost";
#endif
    return [NSString stringWithFormat:@"https://%@/connectstats/upload.php?dir=%@",server,dir];
}


NSString * GCWebRenameActivity(NSString*aId){
    return [NSString stringWithFormat:@"https://connect.garmin.com/modern/proxy/activity-service/activity/%@",aId];
}
NSString * GCWebChangeActivityType(NSString*aId){
    return [NSString stringWithFormat:@"https://connect.garmin.com/proxy/activity-service-1.3/json/type/%@",aId];
}
NSString * GCWebDeleteActivity(NSString*aId){
    return [NSString stringWithFormat:@"https://connect.garmin.com/proxy/activity-service-1.3/xml/activity/%@",aId];
}

#pragma mark - Strava


NSString * GCWebStravaAuthentication(){
    return @"https://www.strava.com/oauth/token";
}
NSString * GCWebStravaUpload(){
    return @"https://www.strava.com/api/v3/uploads";
}

NSString * GCWebGoogleEarthURL( NSString*aId){
    NSString * server = @"connectstats.ro-z.net";
#if TARGET_IPHONE_SIMULATOR
    //server = @"localhost/connectstats";
#endif
    return [NSString stringWithFormat:@"%@/kml/%@.kmz",server,aId];
}

#pragma mark - Withings

NSString * GCWebWithingsOnce(){
    if (useSimulator) {
        return [NSString stringWithFormat:@"%@/garminsimul/withings.php?which=once",simulatorURL];
    }else{
        return @"https://wbsapi.withings.net/once?action=get";
    }
}
NSString * GCWebWithingsUserList(NSString*email,NSString*hash){
    if (useSimulator) {
        return [NSString stringWithFormat:@"%@/garminsimul/withings.php?which=userlist",simulatorURL];
    }else{
        return [NSString stringWithFormat:@"https://wbsapi.withings.net/account?action=getuserslist&email=%@&hash=%@",email,hash];
    }
}
NSString * GCWebWithingsMeasure(NSString*uid,NSString*key){
    if (useSimulator) {
        return [NSString stringWithFormat:@"%@/garminsimul/withings.php?which=measure&uid=%@",simulatorURL,uid];
    }else{
        return [NSString stringWithFormat:@"https://wbsapi.withings.net/measure?action=getmeas&userid=%@&publickey=%@&category=1",uid,key];
    }
}

