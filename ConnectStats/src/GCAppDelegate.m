//  MIT Licence
//
//  Created on 02/09/2012.
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

#import "GCAppGlobal.h"
#import "GCAppDelegate.h"
#import "GCWebConnect.h"
#import "Flurry.h"
#import "GCActivitiesCacheManagement.h"
#include <execinfo.h>
@import RZExternal;
#include "GCMapGoogleViewController.h"
#import "GCSettingsBugReportViewController.h"
#import "GCWebConnect+Requests.h"
#import "GCAppActions.h"
#import "GCActivityType.h"
@import Appirater;
#import "GCActivity+CSSearch.h"
#import "GCFieldCache.h"
#import "GCAppDelegate+Swift.h"
#import "GCWeather.h"
#import "GCActivity+CachedTracks.h"
#import "GCConnectStatsStatus.h"
#import "GCAppSceneDelegate.h"

#define GC_STARTING_FILE @"starting.log"

static BOOL connectStatsVersion = false;
static BOOL checkedVersion = false;
static BOOL healthStatsVersion = false;

NSString * kShortCutItemTypeSummaryStats = @"net.ro-z.connectstats.shortcut.summarystats";
NSString * kShortCutItemTypeLastActivity = @"net.ro-z.connectstats.shortcut.lastactivity";
NSString * kShortCutItemTypeRefreshList  = @"net.ro-z.connectstats.shortcut.refreshlist";
NSString * kShortCutItemTypeCalendarList  = @"net.ro-z.connectstats.shortcut.calendar";

void checkVersion(){

    NSString * path = [RZFileOrganizer bundleFilePath:@"version.plist"];
    NSDictionary * dict = [NSDictionary dictionaryWithContentsOfFile:path];
    if (dict) {
        NSString * version = dict[@"version"];
        if (version && [version isEqualToString:@"connectstats"]) {
            connectStatsVersion = true;
        }
        if (version && [version isEqualToString:@"healthstats"]) {
            healthStatsVersion = true;
        }
    }
    checkedVersion = true;
}

@interface GCAppDelegate ()
@property (nonatomic,assign) BOOL needsStartupRefresh;
@property (nonatomic,retain) GCAppActions * actions;
@property (nonatomic,retain) NSDictionary<NSString*,NSDictionary*> * credentials;
@property (nonatomic,assign) BOOL firstTimeEver;
@property (nonatomic,retain) CLLocationManager * locationManager;
@property (nonatomic,retain) CLLocation * lastReceivedLocation;


@end

@implementation GCAppDelegate

+(BOOL)healthStatsVersion{
    if (!checkedVersion) {
        checkVersion();
    }
    return healthStatsVersion;
}
+(BOOL)connectStatsVersion{
    if (!checkedVersion) {
        checkVersion();
    }
    return connectStatsVersion;
}

-(void)dealloc{
    [_web release];
    [_settings release];
    [_db release];
    [_profiles release];
    [_organizer release];
    [_derived release];
    [_urlToOpen release];
    [_actions release];
    [_health release];
    [_segments release];
    [_credentials release];
    [_remoteStatus release];
    [_locationManager release];
    [_lastReceivedLocation release];

    [_watch release];
    [_window release];
    [_worker release];
    

    [super dealloc];
}

#pragma mark - Application Delegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    RZLog(RZLogInfo, @"=========== %@ %@ ==== %@ ===============",
          [[NSBundle mainBundle] infoDictionary][@"CFBundleExecutable"],
          [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"],
          [RZSystemInfo systemDescription]);

    RZSimNeedle();
    
    [self credentialsForService:@"flurry" andKey:@"connectstats"];
#if !TARGET_IPHONE_SIMULATOR
	NSString *applicationCode = [GCAppDelegate connectStatsVersion] ? [self credentialsForService:@"flurry" andKey:@"connectstats"] : [self credentialsForService:@"flurry" andKey:@"healthstats"];
    if ([GCAppDelegate healthStatsVersion]) {
        applicationCode =  [self credentialsForService:@"flurry" andKey:@"healthstats"];
    }
    [Flurry startSession:applicationCode];
#endif
    if ([GCAppDelegate connectStatsVersion]) {
        [Appirater setAppId: [self credentialsForService:@"appstore" andKey:@"connectstats"]];
    }else if ([GCAppDelegate healthStatsVersion]){
        [Appirater setAppId:[self credentialsForService:@"appstore" andKey:@"healthstats"]];
    }

    [GCMapGoogleViewController provideAPIKey:[self credentialsForService:@"googlemaps" andKey:@"api_key"]];
    BOOL ok = [self startInit];
    if (!ok) {
        RZLog(RZLogError, @"Multiple failure to start");
        return [self multipleFailureStart];
    }

    [GCAppGlobal setApplicationDelegate:self];

    self.needsStartupRefresh = true;
	self.settings = [NSMutableDictionary dictionaryWithDictionary:[RZFileOrganizer loadDictionary:@"settings.plist"]];
    self.firstTimeEver = (self.settings.count == 0);
    
    self.profiles = [GCAppProfiles profilesFromSettings:_settings];
    [self setupWorkerThread];
	self.db = [FMDatabase databaseWithPath:[RZFileOrganizer writeableFilePath:[_profiles currentDatabasePath]]];
    [_db open];
    // do db op before now before the app send them all to worker thread
    // Wrap in autorelease pool to ensure no left over db object are released
    // later while db operation happening on worker
    @autoreleasepool {
        [GCActivitiesOrganizer ensureDbStructure:_db];
        [GCHealthOrganizer ensureDbStructure:_db];
    }

    [self setupFieldCache];
    [GCActivityType setActivityTypes:[GCActivityTypes activityTypes]];

    [GCUnit setGlobalSystem:[_settings[CONFIG_UNIT_SYSTEM] intValue]];
    [GCUnit setStrideStyle:[_settings[CONFIG_STRIDE_STYLE] intValue]];
    [GCUnit setCalendar:[GCAppGlobal calculationCalendar]];
    [NSDate cc_setCalculationCalendar:[GCAppGlobal calculationCalendar]];
    
    [self settingsUpdateCheck];

    // This will trigger load from db in background,
    // make sure all setup first
    self.organizer = [[[GCActivitiesOrganizer alloc] initWithDb:self.db andThread:self.worker] autorelease];
    self.health = [[[GCHealthOrganizer alloc] initWithDb:self.db andThread:self.worker] autorelease];
    self.web = [[[GCWebConnect alloc] init] autorelease] ;
    self.web.worker = self.worker;
    // Force initial login
    if ([self.profiles serviceEnabled:gcServiceGarmin]) {
        [self.web requireLogin:gcWebServiceGarmin];
    }
    
    self.derived = [[[GCDerivedOrganizer alloc] initWithDb:nil andThread:self.worker] autorelease];

    [RZViewConfig setFontStyle:[GCAppGlobal configGetInt:CONFIG_FONT_STYLE defaultValue:gcFontStyleDynamicType]];

    
    [Appirater appLaunched:YES];

    [self updateShortCutKeys];

    //iOS9 Check
    if (launchOptions[UIApplicationLaunchOptionsShortcutItemKey]) {
        RZLog(RZLogInfo, @"Launched for ShortCut Item");
        UIApplicationShortcutItem * item = launchOptions[UIApplicationLaunchOptionsShortcutItemKey];
        if ([item isKindOfClass:[UIApplicationShortcutItem class]]) {
            // Will be called anyway.
            RZLog(RZLogInfo, @"Launch for shortcutItem %@", item);
            //[self application:application performActionForShortcutItem:item completionHandler:^(BOOL res){}];
        }else{
            RZLog(RZLogError, @"Launch Invalid ShortCutItem %@", item);
        }
    }else if (launchOptions[UIApplicationLaunchOptionsUserActivityDictionaryKey]){
        NSDictionary * dict = launchOptions[UIApplicationLaunchOptionsUserActivityDictionaryKey];
        if ([dict isKindOfClass:[NSDictionary class]]) {
            RZLog(RZLogInfo, @"Launch for UserActivity %@", dict);
        }else{
            RZLog(RZLogInfo, @"Launch Invalid UserActivity %@", dict);
        }
    }
    
    [self remoteStatusCheck];
    return YES;
}

     
- (void)applicationWillResignActive:(UIApplication *)application
{
    [RZFileOrganizer saveDictionary:_settings withName:@"settings.plist"];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    RZLog(RZLogInfo,@"background");
    [RZFileOrganizer saveDictionary:_settings withName:@"settings.plist"];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    RZLog(RZLogInfo,@"foreground");
    [GCAppGlobal setApplicationDelegate:self];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    RZLog(RZLogInfo,@"app active");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [RZFileOrganizer saveDictionary:_settings withName:@"settings.plist"];
    RZLog(RZLogInfo, @"app normal exit");
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application{
    RZLog(RZLogWarning, @"memory warning %@", [RZMemory formatMemoryInUse]);
    [_organizer purgeCache];
}
#pragma mark - Scenes


-(UISceneConfiguration*)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options{
    return RZReturnAutorelease([[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role]);
}


#pragma mark - User Activities

-(BOOL)application:(nonnull UIApplication *)application continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(nonnull void (^)(NSArray<id<UIUserActivityRestoring>> * __nullable))restorationHandler{
    BOOL rv = false;

    if( [userActivity.activityType isEqualToString:kNSUserActivityTypeViewOne]){
        NSString * aId = userActivity.userInfo[kNSUserActivityUserInfoActivityIdKey];
        RZLog(RZLogInfo,@"Act: %@ %@", userActivity.activityType,aId);
        if (aId) {
            [GCAppGlobal focusOnActivityId:aId];
            rv = true;
        }
    }else if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]){
        RZLog(RZLogInfo,@"Act: %@ %@", userActivity.activityType, userActivity.webpageURL);
        if (![self handleUniveralLink:userActivity.webpageURL]) {
            [[UIApplication sharedApplication] openURL:userActivity.webpageURL options:@{} completionHandler:nil];
        }else{
            rv = true;
        }
    }else{
        RZLog(RZLogWarning, @"Unknown Activity: %@", userActivity.activityType);
    }
    return rv;
}

-(BOOL)handleUniveralLink:(NSURL *) url{
    BOOL rv = false;
    if (!self.actions) {
        self.actions = [GCAppActions appActions];
    }
    rv = [self.actions execute:url];
    return rv;
}

#pragma mark ShortCutKey

-(void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler{
    RZLog(RZLogInfo, @"%@",shortcutItem);

    if ([shortcutItem.type isEqualToString:kShortCutItemTypeSummaryStats]) {
        [self.actionDelegate focusOnStatsSummary];
    }else if([shortcutItem.type isEqualToString:kShortCutItemTypeRefreshList]){
        [self searchRecentActivities];
        [self.actionDelegate focusOnActivityList];
        [self.actionDelegate beginRefreshing];
    }else if ([shortcutItem.type isEqualToString:kShortCutItemTypeLastActivity]){
        [self.actionDelegate focusOnActivityAtIndex:0];
    }else if ([shortcutItem.type isEqualToString:kShortCutItemTypeCalendarList]){
    }

    completionHandler(TRUE);
}


-(void)updateShortCutKeys{
    UIApplication * app = [UIApplication sharedApplication];


    //iOS9 Check
    if ([app respondsToSelector:@selector(shortcutItems)]) {
        if ([GCAppGlobal connectStatsVersion]) {
            app.shortcutItems = @[
                                  [[[UIApplicationShortcutItem alloc] initWithType:kShortCutItemTypeRefreshList
                                                                    localizedTitle:NSLocalizedString(@"Refresh", @"ShortCut Key")
                                                                 localizedSubtitle:nil
                                                                              icon:[UIApplicationShortcutIcon iconWithTemplateImageName:@"731-cloud-download"]
                                                                          userInfo:@{}] autorelease],
                                  [[[UIApplicationShortcutItem alloc] initWithType:kShortCutItemTypeSummaryStats
                                                                    localizedTitle:NSLocalizedString(@"Summary Statistics", @"ShortCut Key")
                                                                 localizedSubtitle:nil
                                                                              icon:[UIApplicationShortcutIcon iconWithTemplateImageName:@"858-line-chart"]
                                                                          userInfo:@{}] autorelease],
                                  [[[UIApplicationShortcutItem alloc] initWithType:kShortCutItemTypeLastActivity
                                                                    localizedTitle:NSLocalizedString(@"Last Activity", @"ShortCut Key")
                                                                 localizedSubtitle:nil
                                                                              icon:[UIApplicationShortcutIcon iconWithTemplateImageName:@"852-map"]
                                                                          userInfo:@{}] autorelease]
                                  ];
        }else{
            app.shortcutItems = @[
                                  [[[UIApplicationShortcutItem alloc] initWithType:kShortCutItemTypeSummaryStats
                                                                    localizedTitle:NSLocalizedString(@"Summary Statistics", @"ShortCut Key")
                                                                 localizedSubtitle:nil
                                                                              icon:[UIApplicationShortcutIcon iconWithTemplateImageName:@"858-line-chart"]
                                                                          userInfo:@{}] autorelease],
                                  [[[UIApplicationShortcutItem alloc] initWithType:kShortCutItemTypeCalendarList
                                                                    localizedTitle:NSLocalizedString(@"Calendar", @"ShortCut Key")
                                                                 localizedSubtitle:nil
                                                                              icon:[UIApplicationShortcutIcon iconWithTemplateImageName:@"851-calendar"]
                                                                          userInfo:@{}] autorelease],
                                  [[[UIApplicationShortcutItem alloc] initWithType:kShortCutItemTypeLastActivity
                                                                    localizedTitle:NSLocalizedString(@"Last Day", @"ShortCut Key")
                                                                 localizedSubtitle:nil
                                                                              icon:[UIApplicationShortcutIcon iconWithTemplateImageName:@"852-map"]
                                                                          userInfo:@{}] autorelease]
                                  ];

        }
    }
}

#pragma mark Open Url

-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options{
    RZLog(RZLogInfo,@"url: %@", url.path);
    BOOL rv = false;
    self.urlToOpen = url;
    // check if fit file
    if ([url.path hasSuffix:@".fit"]) {
        dispatch_async(self.worker,^(){
            [self handleFitFile];
        });

        rv = true;
    }
    return rv;
}


#pragma mark Thread Mgmt

-(void)setupWorkerThread{
    dispatch_queue_t queue = dispatch_queue_create("net.ro-z.worker", DISPATCH_QUEUE_SERIAL);
    self.worker = queue;
    dispatch_release(queue);

}

+(void)publishEvent:(NSString*)name{
#ifdef GC_USE_FLURRY
	[Flurry logEvent:name];
#endif
}

#pragma mark - Location Manager

-(CLLocation*)currentLocation{
    if( self.lastReceivedLocation ){
        return self.lastReceivedLocation;
    }else{
        return nil;
    }
}

-(void)startLocationRequest{
    self.locationManager = RZReturnAutorelease([[CLLocationManager alloc] init]);
    self.locationManager.delegate = self;
    RZLog(RZLogInfo,@"Requested Location");
    [self.locationManager requestWhenInUseAuthorization];
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if( status == kCLAuthorizationStatusAuthorizedWhenInUse ){
        [self.locationManager requestLocation];
    }else{
        RZLog(RZLogInfo,@"Location Request denied %@", @(status));
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    if( locations.count > 0){
        self.lastReceivedLocation = locations.lastObject;
        RZLog(RZLogInfo, @"Received location %@", self.lastReceivedLocation );
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyLocationRequestComplete object:self.lastReceivedLocation];
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    // ignore
}
#pragma mark - State Management and Actions

-(NSArray<NSDictionary*>*)recentRemoteMessages{
    NSUInteger knownStatus = [GCAppGlobal configGetInt:CONFIG_LAST_REMOTE_STATUS_ID defaultValue:0];
    NSArray * recent = [self.remoteStatus  recentMessagesSinceId:knownStatus withinDays:21];
    return recent;
}

-(void)recentRemoteMessagesReceived{
    NSUInteger latest = [self.remoteStatus mostRecentStatusId];
    [GCAppGlobal configSet:CONFIG_LAST_REMOTE_STATUS_ID intVal:latest];
    [GCAppGlobal saveSettings];
    [self.actionDelegate updateBadge:0];
}
-(void)remoteStatusCheck{
    self.remoteStatus = [GCConnectStatsStatus status];
    [self.remoteStatus check:^(GCConnectStatsStatus * s){
        //
        NSUInteger count = [self recentRemoteMessages].count;
        RZLog(RZLogInfo, @"Remote Status[%@]: %@", @(count), s);
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.actionDelegate updateBadge:count];
        });
    }];
}

-(void)setupFieldCache{

    gcLanguageSetting setting = [GCAppGlobal configGetInt:CONFIG_LANGUAGE_SETTING defaultValue:gcLanguageSettingAsDownloaded];

    NSString * language = nil;

    if (setting == gcLanguageSettingAsDownloaded) {
        language = nil;
    }else if (setting == gcLanguageSettingSystemLanguage){
        language = nil;
    }else{
        NSArray * languages = [GCFieldCache availableLanguagesCodes];
        NSUInteger languageIndex = setting - gcLanguageSettingPredefinedStart;
        if (languageIndex < languages.count) {
            language = languages[languageIndex];
        }
    }

    GCFieldCache * cache = [GCFieldCache cacheWithDb:self.db andLanguage:language];
    [cache registerFields:[GCFieldsCalculated fieldInfoForCalculatedFields]];
    [cache registerFields:[GCHealthMeasure fieldInfoForMeasureFields]];
    [cache registerFields:[GCActivity fieldInfoForCalculatedTrackFields]];
    [GCField setFieldCache: cache];
    [GCFields setFieldCache:cache];
    [GCActivityType setFieldCache:cache];

}

-(GCAppSceneDelegate*)currentSceneDelegate{
    NSSet<UIScene*> * scenes = [[UIApplication sharedApplication] connectedScenes];
    GCAppSceneDelegate * delegate = nil;
    
    for (UIScene * scene in scenes) {
        if( [scene.delegate isKindOfClass:[GCAppSceneDelegate class]] ){
            delegate = (GCAppSceneDelegate*)scene.delegate;
            break;
        }
    }
    return delegate;
}

-(NSObject<GCAppActionDelegate>*)actionDelegate{
    return [[self currentSceneDelegate] actionDelegate];
}

-(BOOL)startInit{
    NSString * filename = [RZFileOrganizer writeableFilePathIfExists:GC_STARTING_FILE];
    NSUInteger attempts = 1;
    NSError * e = nil;

    if (filename) {

        NSString * sofar = [NSString stringWithContentsOfFile:filename
                                            encoding:NSUTF8StringEncoding error:&e];

        if (sofar) {
            attempts = MAX(1, [sofar integerValue]+1);
        }else{
            RZLog(RZLogError, @"Failed to read initfile %@", e.localizedDescription);
        }
    }

    NSString * already = [NSString stringWithFormat:@"%lu",(unsigned long)attempts];
    if(![already writeToFile:[RZFileOrganizer writeableFilePath:GC_STARTING_FILE] atomically:YES encoding:NSUTF8StringEncoding error:&e]){
        RZLog(RZLogError, @"Failed to save startInit %@", e.localizedDescription);
    }

    return attempts < 3;
}

-(void)settingsUpdateCheckPostStart{
    BOOL needToSaveSettings = false;

    if( [self isFirstTimeForFeature:@"ENABLE_CONNECTSTATS_SERVICE"] ){
        if( ! self.firstTimeEver && ([[GCAppGlobal profile] serviceEnabled:gcServiceGarmin] && ![[GCAppGlobal profile] serviceEnabled:gcServiceConnectStats])){
            //needToSaveSettings = true;
            RZLog(RZLogInfo,@"Suggesting enable ConnectStats Service");
            
            NSString * message = NSLocalizedString(@"Do you want to enable the new service for Garmin Data? You can get more information and enable it later in the config page", @"Enable New Service");
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Enable New Service" message:message preferredStyle:UIAlertControllerStyleAlert];
            [alert addCancelAction];
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Enable",@"Service status") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                RZLog(RZLogInfo, @"User enabling connectstats");
                [GCViewConfig setGarminDownloadSource:gcGarminDownloadSourceBoth];
                [self saveSettings];
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [self searchRecentActivities];
                });
            }]];
            [[self.actionDelegate currentNavigationController] presentViewController:alert animated:YES completion:nil];
        }
    }
    
    if( needToSaveSettings ){
        [self saveSettings];
    }

}

-(void)settingsUpdateCheck{
    BOOL needToSaveSettings = false;
    if( @available( iOS 13.0, *)){
        if( [[GCAppGlobal profile] configGetBool:@"CONFIG_FIRST_TIME_IOS13" defaultValue:true] ){
            [[GCAppGlobal profile] configSet:CONFIG_SKIN_NAME stringVal:kGCSkinNameiOS13];
            [[GCAppGlobal profile] configSet:@"CONFIG_FIRST_TIME_IOS13" boolVal:false];
            needToSaveSettings = true;
        }
    }
    
    NSString * currentVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
    BOOL firstTimeForCurrentVersion = false;
    
    NSDictionary * versions = self.settings[CONFIG_VERSIONS_SEEN];
    
    if( versions == nil){
        self.settings[CONFIG_VERSIONS_SEEN] = @{ currentVersion: [[NSDate date] formatAsRFC3339]};
        [self saveSettings];
        firstTimeForCurrentVersion = true;
    }else{
        NSString * already = versions[currentVersion];
        
        if( already == nil){
            NSMutableDictionary * newVersions = [NSMutableDictionary dictionaryWithDictionary:versions];
            newVersions[currentVersion] = [NSDate date];
            
            self.settings[CONFIG_VERSIONS_SEEN] = newVersions;
            needToSaveSettings = true;
            firstTimeForCurrentVersion = true;
        }
    }
    
    if( firstTimeForCurrentVersion ){
        RZLog(RZLogInfo,@"First time for version %@", currentVersion);
    }else{
        RZLog(RZLogInfo,@"Current Version %@ first seen %@ (%lu total versions)", currentVersion, versions[currentVersion], (unsigned long)versions.count);
    }
    
    if( [self isFirstTimeForFeature:@"UPGRADE_WEATHER_WINDSPEED_UNITS"]){
        // remove all weather for activities since september 2019
        needToSaveSettings = true;
        if( ! self.firstTimeEver ){
            [GCWeather fixWindSpeed:self.db];
        }
    }
    
    if( [self isFirstTimeForFeature:@"REMOVE_BAD_HEALTHKIT_DUPLICATES"]){
        needToSaveSettings = true;
        if( ! self.firstTimeEver ){
            if( [self.db tableExists:@"gc_duplicate_activities"]){
                int count = [self.db intForQuery:@"SELECT COUNT(*) FROM gc_duplicate_activities WHERE duplicateActivityId LIKE '__healthkit__%'"];
                if( count > 0){
                    RZLog(RZLogInfo, @"Fixing healthkit duplicate (%d)", count);
                    RZEXECUTEUPDATE(self.db, @"DELETE FROM gc_duplicate_activities WHERE duplicateActivityId LIKE '__healthkit__%'");
                }
            }
        }
    }
    
    if( [self isFirstTimeForFeature:@"NEW_DUPLICATE_CHECK_SETTINGS"]){
        needToSaveSettings = true;
        BOOL previous = [GCAppGlobal configGetBool:CONFIG_DUPLICATE_SKIP_ON_IMPORT_OBSOLETE defaultValue:true];
        [[GCAppGlobal profile] configSet:CONFIG_DUPLICATE_CHECK_ON_IMPORT boolVal:previous];
        [[GCAppGlobal profile] configSet:CONFIG_DUPLICATE_CHECK_ON_LOAD boolVal:true]; // was always true before
    }
    
    if( [self isFirstTimeForFeature:@"UPGRADE_PROFILE_DONE_AND_ANCHOR"]){
        needToSaveSettings = true;
        // Transfer old key to new key
        if( [[GCAppGlobal profile] serviceSuccess:gcServiceGarmin]){
            NSUInteger page = [[GCAppGlobal profile] configGetInt:PROFILE_LAST_PAGE_OBSOLETE defaultValue:0];
            [[GCAppGlobal profile] serviceAnchor:gcServiceGarmin set:page];
            [[GCAppGlobal profile] serviceCompletedFull:gcServiceGarmin set:YES];
        }
        
        if( [[GCAppGlobal profile] serviceSuccess:gcServiceStrava]){
            [[GCAppGlobal profile] serviceCompletedFull:gcServiceStrava set:YES];
        }
        if( [[GCAppGlobal profile] serviceSuccess:gcServiceConnectStats]){
            [[GCAppGlobal profile] serviceCompletedFull:gcServiceConnectStats set:YES];
        }
    }
    
    if( needToSaveSettings ){
        [self saveSettings];
    }
}

-(BOOL)isFirstTimeForFeature:(NSString*)feature{
    BOOL rv = false;
    NSDictionary * dict = self.settings[CONFIG_FEATURES_SEEN];
    if( dict == nil || dict[feature] == nil){
        rv = true;
        if( dict == nil){
            self.settings[CONFIG_FEATURES_SEEN] = @{ feature : [NSDate date]};
        }else{
            NSMutableDictionary * newFeatures = [NSMutableDictionary dictionaryWithDictionary:dict];
            newFeatures[feature] = [NSDate date];
            self.settings[CONFIG_FEATURES_SEEN] = newFeatures;
        }
    }
    return rv;
}

-(void)versionSummary{
    NSDictionary * versionsSeen = self.settings[CONFIG_VERSIONS_SEEN];
    NSArray<NSString*>*versions = [[versionsSeen allKeys] sortedArrayUsingSelector:@selector(compareVersion:)];
    NSUInteger idx = 0;
    NSUInteger total = versions.count;
    // only show first 3 and last 3
    for (NSString * version in versions) {
        if( idx > (total - 3) || idx < 3){
            RZLog(RZLogInfo,@"Version %@ seen %@", version, versionsSeen[version]);
        }
        idx ++;
    }
}
-(void)searchRecentActivities{
    [self.web servicesSearchRecentActivities];
}

-(void)addOrSelectProfile:(NSString*)pName{
    if (![pName isEqualToString:[self.profiles currentProfileName]]) {
        RZLog(RZLogInfo, @"Changing profile from %@ to %@", [self.profiles currentProfileName], pName);

        [self.db close];
        [self.profiles addOrSelectProfile:pName];
        self.db = [FMDatabase databaseWithPath:[RZFileOrganizer writeableFilePath:[self.profiles currentDatabasePath]]];
        [self.db open];
        [GCActivitiesOrganizer ensureDbStructure:_db];
        [GCHealthOrganizer ensureDbStructure:_db];
        [self setupFieldCache];
        [_organizer updateForNewProfile];
        [_health updateForNewProfile];
        [_derived updateForNewProfile];
        [self saveSettings];
        [[NSNotificationCenter defaultCenter] postNotificationName:KalDataSourceChangedNotification object:self];
        [_web servicesResetLogin];
    }
}

-(void)saveSettings{
    [_profiles saveToSettings:_settings];
    [RZFileOrganizer saveDictionary:_settings withName:@"settings.plist"];

}

-(void)startupRefreshIfNeeded{
    if (self.needsStartupRefresh && [self.profiles configGetBool:CONFIG_REFRESH_STARTUP defaultValue:[GCAppGlobal healthStatsVersion]]) {
        [self searchRecentActivities];
    }
    self.needsStartupRefresh = false;
}

-(void)startSuccessful{
    static BOOL once = false;
    if (!once) {
        RZLog(RZLogInfo, @"Started");
        [RZFileOrganizer removeEditableFile:GC_STARTING_FILE];
        once = true;
        
        [self settingsUpdateCheckPostStart];
    }
}

-(BOOL)multipleFailureStart{
    [Flurry logEvent:EVENT_MULTIPLE_FAILURE];
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    GCSettingsBugReportViewController * bug =[[[GCSettingsBugReportViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    bug.includeActivityFiles = true;
    bug.includeErrorFiles = true;
    _window.rootViewController = bug;

    self.settings = [NSMutableDictionary dictionaryWithDictionary:[RZFileOrganizer loadDictionary:@"settings.plist"]];
    self.profiles = [GCAppProfiles profilesFromSettings:_settings];
    [self setupWorkerThread];
    self.db = [FMDatabase databaseWithPath:[RZFileOrganizer writeableFilePath:[_profiles currentDatabasePath]]];
    [_db open];

    [self startSuccessful];
    [_window makeKeyAndVisible];

    //Tested by forcing multiple Failure
    [bug presentSimpleAlertWithTitle:NSLocalizedString(@"Repeated Failure to start", @"Error")
                             message:NSLocalizedString(@"The app seem to not have started multiple times. You can send a bug report, next attempt will try again", @"Error")];

    return YES;
}

-(NSDictionary<NSString*,NSString*>*)credentialsForService:(NSString*)service{
    if( self.credentials == nil){
        NSString * credentialsPath = [RZFileOrganizer bundleFilePath:@"credentials.json"];
        NSData * credentialsData = [NSData dataWithContentsOfFile:credentialsPath];
        if( credentialsData ){
            NSError * error = nil;
            NSDictionary * credentials = [NSJSONSerialization JSONObjectWithData:credentialsData options:NSJSONReadingAllowFragments error:&error];
            if( [credentials isKindOfClass:[NSDictionary class]]){
                self.credentials = credentials;
            }else{
                RZLog(RZLogError, @"Failed to read credentials.json %@", error.localizedDescription);
            }
        }
        // if still nil, we didn't succeed
        if( self.credentials == nil){
            RZLog(RZLogError, @"Failed to load credentials: %@", credentialsPath);
            self.credentials = @{};
        }
    }
    NSDictionary * rv = self.credentials[service];
    return rv ?: @{};
}

-(NSString*)credentialsForService:(NSString*)service andKey:(NSString*)key{
    NSDictionary * credentials = [self credentialsForService:service];
    NSString * found = credentials[key];
    if( [found isKindOfClass:[NSString class]]){
        return found;
    }else{
        // Default empty string, will fail connection as invalid credential...
        RZLog(RZLogError, @"Didn't find credential %@ for %@", key, service);;
        return @"";
    }
}

@end
