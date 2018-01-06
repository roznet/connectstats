//
//  ExtensionDelegate.m
//  healthwatch Extension
//
//  Created by Brice Rosenzweig on 09/08/2015.
//  Copyright © 2015 Brice Rosenzweig. All rights reserved.
//

#import "GCWExtensionDelegate.h"
#import "GCWSummaryInterfaceController.h"
#import "GCApplicationContext.h"

@interface GCWExtensionDelegate ()
@property (nonatomic,retain) WCSession * session;
@end



@implementation GCWExtensionDelegate

#pragma mark - ExtensionDelegate
- (void)applicationDidFinishLaunching {
    //RZSimNeedle();
    
    // Perform any final initialization of your application.
    if ([WCSession isSupported]) {
        self.session = [WCSession defaultSession];
        self.session.delegate = self;
        [self.session activateSession];
        [self initiateDeviceUpdate];
    }
}

- (void)applicationDidBecomeActive {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //RZLog(RZLogInfo,@"Active");
}

- (void)applicationWillResignActive {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, etc.
}

#pragma mark - Messages

-(void)initiateDeviceUpdate{
    if (self.session.isReachable) {
        CGRect screen = [[WKInterfaceDevice currentDevice] screenBounds];
        [self.session sendMessage:@{kAppContextFromWatchMessage:kAppContextMessageRequestUpdate,
                                    kAppContextScreenWidth:@(screen.size.width)}
                     replyHandler:^(NSDictionary*reply){
                         //RZLog(RZLogInfo,@"Reply: %@", reply);
                     }
                     errorHandler:^(NSError * error){
                         //RZLog(RZLogInfo,@"Error: %@", error);
                     }];
    }
    
}

#pragma mark - SessionDelegate
-(NSString*)writeableFilePath:(nullable NSString*)aName{
    NSArray		*	paths				= NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
    NSString	*	documentsDirectory	= paths[0];
    
    return( aName ? [documentsDirectory stringByAppendingPathComponent:aName] : documentsDirectory);
}

-(void)sessionReachabilityDidChange:(WCSession *)session{
    if (session.isReachable) {
        //RZLog(RZLogInfo,@"iPhone Reachable from Watch");
    }else{
        //RZLog(RZLogInfo,@"iPhone NOT Reachable from Watch");
    }
}
-(void)session:(WCSession *)session didReceiveUserInfo:(NSDictionary<NSString *,id> *)userInfo{
    //RZLog(RZLogInfo,@"Watch Received : %@", userInfo);
}

-(void)session:(WCSession *)session didReceiveFile:(WCSessionFile *)file{
    NSData * data = [NSData dataWithContentsOfURL:file.fileURL];
    //RZLog(RZLogInfo,@"Received %@", file.metadata[kAppContextFileName]);
    [data writeToFile:[self writeableFilePath:file.metadata[kAppContextFileName]] atomically:YES];
    [self.mainInterface updateForContext];
}

@end
