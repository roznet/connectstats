//  MIT License
//
//  Created on 27/06/2020 for ConnectStats
//
//  Copyright (c) 2020 Brice Test User
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



#import "GCAppSceneDelegate.h"
#import "GCHealthViewController.h"
#import "GCAppGlobal.h"
#import "GCAppDelegate.h"
#import "ConnectStats-Swift.h"

#ifdef GC_TEST_APP
@class GCTabBarController;
@class GCSplitViewController;
#else
#import "GCTabBarController.h"
#import "GCSplitViewController.h"
#endif


@interface GCAppSceneDelegate ()

@property (nonatomic, retain) GCTabBarController * tabBarController;
@property (nonatomic, retain) GCSplitViewController * splitViewController;

@end

@implementation GCAppSceneDelegate

-(void)dealloc{
#ifndef GC_TEST_APP
    [_splitViewController release];
    [_tabBarController release];
#endif
    [_window release];
    
    [super dealloc];
}

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    RZLog(RZLogInfo,@"scene connect");
    
    if( [scene isKindOfClass:[UIWindowScene class]]){
        UIWindowScene * windowScene = (UIWindowScene*)scene;

        _window = [[UIWindow alloc] initWithFrame:windowScene.coordinateSpace.bounds];
        //DONT CHECK IN:
        //self.window = [[[SmudgyWindow alloc] initWithFrame:windowScene.coordinateSpace.bounds] autorelease];
        _window.windowScene = windowScene;
#ifndef GC_TEST_APP
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        {
            // The device is an iPad
            _splitViewController = [[GCSplitViewController alloc]init];
            _window.rootViewController = _splitViewController;
        }
        else
        {
            // The device is an iPhone
            _tabBarController = [[GCTabBarController alloc] init];
            _window.rootViewController = _tabBarController;
        }
#endif
        // first use, update, etc workflow
        [_window makeKeyAndVisible];
    }else{
        RZLog(RZLogInfo, @"connect to non window scene %@", scene);
    }
}


- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    RZLog(RZLogInfo,@"scene disconnect");
    [GCAppGlobal saveSettings];
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    RZLog(RZLogInfo,@"scene active");
    
}


- (void)sceneWillResignActive:(UIScene *)scene {
    RZLog(RZLogInfo,@"scene resign active");
    [GCAppGlobal saveSettings];
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
    [GCAppGlobal saveSettings];
}

-(NSObject<GCAppActionDelegate>*)actionDelegate{    
    return self.tabBarController ?:self.splitViewController;
}

-(void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts{
    NSLog(@"Called %@", URLContexts);
    GCAppDelegate * delegate = (GCAppDelegate*)[UIApplication sharedApplication].delegate;
    for (UIOpenURLContext * context in URLContexts) {
        if( [context.URL.path hasSuffix:@".fit"] ){
            [delegate application:[UIApplication sharedApplication] openURL:context.URL options:@{}];
            break;
        }
        if( [context.URL.path isEqualToString:@"/oauth/strava"]){
            [self handleOAuth:context.URL];
        }
    }
}
@end
