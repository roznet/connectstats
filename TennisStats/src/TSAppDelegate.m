//  MIT Licence
//
//  Created on 10/02/2014.
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

#import "TSAppDelegate.h"
#import "TSTennisCourtViewController.h"
#import "TSTabBarViewController.h"
#import "TSTennisOrganizer.h"
#import "TSReportOrganizer.h"
#import "TSSplitViewController.h"
#import "TSCloudOrganizer.h"
#import "TSPlayerManager.h"
#import "Flurry.h"
#import "TSAppConstants.h"
#import "TSTennisScoreRule.h"


@interface TSAppDelegate ()
@property (nonatomic,retain) TSTabBarViewController * tabBarController;
@property (nonatomic,retain) TSSplitViewController * splitViewController;
@end

@implementation TSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    RZLog(RZLogInfo, @"============= %@ %@ =================",
          [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"],
          [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]);
    RZSimNeedle();
#if !TARGET_IPHONE_SIMULATOR
    [Flurry startSession:@"NSH4XJ295B9MXGC68D3V"];
#endif
    /*
    NSURL * group = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.net.ro-z.tennisstats"];
     */
    [self setupWorkerThread];

    [TSTennisSession setSessionFilePrefix:@"session"];

    [self registerDefaults];

    self.db = [FMDatabase databaseWithPath:[RZFileOrganizer writeableFilePath:@"sessions.db"]];
    [self.db open];
    [TSTennisOrganizer ensureDbStructure:self.db];
    [TSPlayerManager ensureDbStructure:self.db];


    // Player needs to load first as session loaded from organizer will require it
    self.players    = [[TSPlayerManager alloc] initWithDatabase:self.db andThread:self.worker];
    self.organizer  = [TSTennisOrganizer organizerWith:self.db players:self.players andThread:self.worker];
    self.cloud      = [[TSCloudOrganizer alloc] initWithDatabase:self.db andThread:self.worker];
    self.reports    = [TSReportOrganizer defaultOrganizer];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //self.window = [[SmudgyWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        self.splitViewController = [[TSSplitViewController alloc] initWithNibName:nil bundle:nil];
        [self.window setRootViewController:self.splitViewController];
    }else{
        self.tabBarController = [[TSTabBarViewController alloc] initWithNibName:nil bundle:nil];
        [self.window setRootViewController:self.tabBarController];
    }

    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
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
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark thread mgmt

-(void)setupWorkerThread{
    self.worker = [[NSThread alloc] initWithTarget:self selector:@selector(startWorkerThread) object:nil];
    [_worker setName:@"Worker"];
    [_worker start];
}

-(void)startWorkerThread{
    while (true) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantFuture]];
    }
}

-(void)tabBarToStats{
    if(self.tabBarController){
        [self.tabBarController setSelectedIndex:3];
        self.tabBarController.tabBar.hidden = NO;
    }else if( self.splitViewController){
        [self.splitViewController showStats];
    }
}

-(void)registerDefaults{
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{
                                                              CONFIG_DEFAULT_SCORE_RULE: @([[TSTennisScoreRule defaultRule] pack])
                                                              }];
}

@end
