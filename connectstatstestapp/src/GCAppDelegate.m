//  MIT Licence
//
//  Created on 13/09/2012.
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

#import "GCAppDelegate.h"
#import "GCTestViewController.h"
#import "GCDerivedOrganizer.h"
#import "GCFieldCache.h"
#import "GCAppGlobal.h"
@import RZUtils;
#import <RZUtilsSwift/RZUtilsSwift-Swift.h>
//@import RZUtilsSwift;

@interface GCAppDelegate ()
@property (nonatomic,retain) RZSRemoteURLFindValid * findValid;
@property (nonatomic,retain) NSString * useSimulatorUrl;
@property (nonatomic,retain) UITabBarController * tabBarController;
@property (nonatomic,retain) NSDictionary<NSString*,NSDictionary*> * credentials;

@end

@implementation GCAppDelegate

- (void)dealloc
{
    [_findValid release];
    [_useSimulatorUrl release];
    [_testUIGraphViewController release];
    [_testUICellViewController release];
    [_testViewController release];
    [_window release];
    [_settings release];
    [_web release];
    [_worker release];
    [_profile release];
    [_organizer release];
    [_db release];
    [_derived release];
    [_health release];
    [_tabBarController release];
    [_testServicesViewController release];
    [_credentials release];
    
    [super dealloc];
}

#pragma mark - Application Delegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    // Override point for customization after application launch.
	self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    [self setSettings:[NSMutableDictionary dictionaryWithCapacity:10]];
    [self setProfile:[GCAppProfiles profilesFromSettings:_settings]];
    [_profile setLoginName:@"simulator" forService:gcServiceGarmin];
    [_profile setPassword:@"iamatesterfromapple" forService:gcServiceGarmin];


    [self checkSimulatorUrl];
    
    // =========== DONT CHECKIN ======
    //[self cleanWritableFiles];

    RZSimNeedle();
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithName:@"Europe/London"]];

    [GCAppGlobal setApplicationDelegate:self];

    [self setupWorkerThread];
    _testViewController = [[GCTestViewController alloc] init];
    _testViewController.runTestOnStartup = false;
    _testUIGraphViewController = [[GCTestUIGraphViewController alloc] initWithStyle:UITableViewStylePlain];
    _testUICellViewController = [[GCTestUICellsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    _testServicesViewController = [[GCTestServicesViewController alloc] init];
    _testServicesViewController.runTestOnStartup = false;

    UITabBarController * tabbar = [[[UITabBarController alloc] initWithNibName:nil bundle:nil] autorelease];
    self.tabBarController = tabbar;
    UITabBarItem * testItem	= [[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Test",nil)	image:[UIImage imageNamed:@"784-target"] tag:0] autorelease];
    UITabBarItem * graphItem	= [[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Graphs",nil)     image:[UIImage imageNamed:@"858-line-chart"] tag:0] autorelease];
    UITabBarItem * cellItem	= [[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Cells",nil)     image:[UIImage imageNamed:@"729-top-list"] tag:0] autorelease];
    UITabBarItem * servicesItem = [[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Services",nil) image:[UIImage imageNamed:@"715-globe"] tag:0] autorelease];

    UINavigationController *graphNav= [[[UINavigationController alloc] initWithRootViewController:_testUIGraphViewController] autorelease];
    UINavigationController *cellNav	= [[[UINavigationController alloc] initWithRootViewController:_testUICellViewController] autorelease];
    UINavigationController *testNav	= [[[UINavigationController alloc] initWithRootViewController:_testViewController] autorelease];
    UINavigationController *servicesNav = [[[UINavigationController alloc] initWithRootViewController:_testServicesViewController] autorelease];

    cellNav.tabBarItem = cellItem;
    graphNav.tabBarItem = graphItem;
    testNav.tabBarItem = testItem;
    servicesNav.tabBarItem = servicesItem;

    [tabbar setViewControllers:[NSArray arrayWithObjects:testNav,graphNav,cellNav,servicesNav, nil]];

    [self.window setRootViewController:tabbar];
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [GCAppGlobal setApplicationDelegate:self];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Setup States

-(void)setupFieldCache{

    gcLanguageSetting setting = gcLanguageSettingAsDownloaded;

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
    [GCField setFieldCache: cache];
    [GCFields setFieldCache:cache];
    [GCActivityType setFieldCache:cache];
    [GCActivityType setActivityTypes:[GCActivityTypes activityTypes]];
}


-(void)setupEmptyState:(NSString*)name withSettingsName:(NSString*)settingName{
    //@"activities.db"
    self.db = nil;
    
    @autoreleasepool {
        RZLog(RZLogInfo, @"<<< SETUP %@", name );
        // autorelease pool to make sure nothing hangs in the wrong thread.
        
        
        [RZFileOrganizer forceRebuildEditable:name];
        [RZFileOrganizer removeEditableFile:[RZFileOrganizer writeableFilePath:[self.profile currentDerivedDatabasePath]]];
        
        [self setDb:[FMDatabase databaseWithPath:[RZFileOrganizer writeableFilePath:name]]];
        [_db open];
        [GCActivitiesOrganizer ensureDbStructure:_db];
        [GCHealthOrganizer ensureDbStructure:_db];
        [self setupFieldCache];
        
        [self setSettings:[NSMutableDictionary dictionaryWithDictionary:[RZFileOrganizer loadDictionary:settingName]]];
        [self setOrganizer:[[[GCActivitiesOrganizer alloc] initWithDb:_db] autorelease]];
        [self setDerived:nil];// detach from web before we delete
        [self setWeb:[[[GCWebConnect alloc] init] autorelease]] ;
        self.web.worker = self.worker;
        [self setHealth:[[[GCHealthOrganizer alloc] initWithDb:_db andThread:nil] autorelease]];
        self.health.worker = self.worker; // Don't set thread in init to ensure all db ops done in current thread
        [self setProfile:[GCAppProfiles profilesFromSettings:self.settings]];
        [[self profile] serviceEnabled:gcServiceStrava set:false];
        [[self profile] configSet:PROFILE_DBPATH stringVal:name];
    }
}

-(void)setupEmptyState:(NSString *)name{
    [self setupEmptyState:name withSettingsName:@"settings.plist"];
}
-(void)setupEmptyStateWithDerived:(NSString*)name{
    [self setupEmptyState:name];
    [RZFileOrganizer removeEditableFile:[self.profile currentDerivedDatabasePath]];
    [self setDerived:[[[GCDerivedOrganizer alloc] initWithDb:nil andThread:self.worker] autorelease]];
}

-(void)setupSampleState:(NSString *)name{
    [self setupSampleState:name config:nil];
}
/**
 Setup state from scratch with the db in bundle copied over as writeable
 */
-(void)setupSampleState:(NSString*)name config:(NSDictionary *)config{
    // Stop everything.
    self.organizer = nil;
    RZLog(RZLogInfo, @"<<< SETUP %@", name );
    [RZFileOrganizer createEditableCopyOfFile:name];
	[self setDb:[FMDatabase databaseWithPath:[RZFileOrganizer writeableFilePath:name]]];
    [_db open];

    [GCActivitiesOrganizer ensureDbStructure:_db];
    [GCHealthOrganizer ensureDbStructure:_db];

    [self setupFieldCache];

	[self setSettings:[NSMutableDictionary dictionaryWithDictionary:[RZFileOrganizer loadDictionary:@"settings.plist"]]];
    if( config ){
        for (NSString * key in config) {
            self.settings[key] = config[key];
        }
    }
    [self setOrganizer:[[[GCActivitiesOrganizer alloc] initWithDb:_db] autorelease]];
    [self setWeb:[[[GCWebConnect alloc] init] autorelease]];
    self.web.worker = self.worker;
    [self setHealth:[[[GCHealthOrganizer alloc] initWithDb:_db andThread:self.worker] autorelease]];
    [self setProfile:[GCAppProfiles profilesFromSettings:self.settings]];
    [[self profile] serviceEnabled:gcServiceStrava set:false];
    [[self profile] configSet:PROFILE_DBPATH stringVal:name];
}

-(void)reinitFromSampleState:(NSString*)name{
    self.organizer = nil;
	[self setDb:[FMDatabase databaseWithPath:[RZFileOrganizer writeableFilePath:name]]];
    [_db open];

    [self setOrganizer:[[[GCActivitiesOrganizer alloc] initWithDb:_db] autorelease]];
    [self setHealth:[[[GCHealthOrganizer alloc] initWithDb:_db andThread:self.worker] autorelease]];

    [self setupFieldCache];
}

-(void)cleanWritableFiles{
    NSFileManager	*	fileManager			= [NSFileManager defaultManager];
    NSArray		*	paths				= NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
    NSString	*	documentsDirectory	= [paths objectAtIndex:0];
    NSError * e;
    NSArray * files = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:&e];
    for (NSString * file in files) {
        if (![file hasPrefix:@"."] && ![file hasSuffix:@"laps_regr.plist"] && ![file hasSuffix:kPreservedSettingsName]) {
            [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:file] error:&e];
        }
    }
}

#pragma mark - Simulator Url

-(void)checkSimulatorUrl{
    NSArray<NSString*> * tries = @[@"https://localhost/connectstats/check.php",
                                   @"https://roznet.ro-z.me/connectstats/check.php",
                                   @"https://ro-z.net/connectstats/check.php"];

    self.findValid = RZReturnAutorelease([[RZSRemoteURLFindValid alloc] initWithUrls:tries]);
    [self.findValid search:^(NSString*found){
        NSDictionary<NSString*,NSString*> * map = @{
                                                    @"https://localhost/connectstats/check.php" : @"https://localhost",
                                                    @"https://roznet.ro-z.me/connectstats/check.php" : @"https://roznet.ro-z.me",
                                                    @"https://ro-z.net/connectstats/check.php" : @"https://ro-z.net"

                                                    };

        if( found && map[found]){
            RZLog(RZLogInfo, @"Setup Simulator with url %@", map[found]);
            self.useSimulatorUrl = map[found];
        };

    }];

}

-(NSString*)simulatorUrl{
    return self.useSimulatorUrl;
}

#pragma mark - Thread

-(void)setupWorkerThread{
    dispatch_queue_t q = dispatch_queue_create("net.ro-z.worker", DISPATCH_QUEUE_SERIAL);
    self.worker = q;
    dispatch_release(q);

}

-(void)startWorkerThread{
    //NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];

    while (true) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantFuture]];
    }
    //[pool release];
}
-(UINavigationController*)currentNavigationController{
    return self.tabBarController.viewControllers[self.tabBarController.selectedIndex ];
}


-(NSDictionary<NSString*,NSString*>*)credentialsForService:(NSString*)service{
    if( self.credentials == nil){
        NSString * credentialsPath = [RZFileOrganizer bundleFilePath:@"credentials.json"];
        NSData * credentialsData = [NSData dataWithContentsOfFile:credentialsPath];
        if( credentialsPath ){
            NSError * error = nil;
            NSDictionary * credentials = [NSJSONSerialization JSONObjectWithData:credentialsData options:NSJSONReadingAllowFragments error:&error];
            if( [credentials isKindOfClass:[NSDictionary class]]){
                self.credentials = credentials;
            }else{
                RZLog(RZLogError, @"Failed to load %@", credentialsPath);
                self.credentials = @{};
            }
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
-(void)versionSummary{
    RZLog(RZLogInfo,@"Version %@", [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"]);
}

@end
