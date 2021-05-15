//  MIT Licence
//
//  Created on 19/09/2016.
//
//  Copyright (c) 2016 Brice Rosenzweig.
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

#import "GCAppDelegate+Swift.h"
#import "ConnectStats-Swift.h"
#import "GCWebConnect+Requests.h"

@import UserNotifications;

#define GC_STARTING_FILE @"starting.log"

BOOL kOpenTemporary = false;

@implementation GCAppDelegate (Swift)

-(void)handleAppRating{
    
    [self initiateAppRating];
}

-(void)registerForPushNotifications{
    [GCConnectStatsRequestRegisterNotifications register];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    if( userInfo[@"activity_id"] != nil){
        RZLog(RZLogInfo,@"remote notification for activity %@",userInfo[@"activity_id"]);
    }else{
        RZLog(RZLogInfo,@"remote notification %@", userInfo);
    }
    application.applicationIconBadgeNumber = 1;
    RZPerformance * notificationPerf = [RZPerformance start];
    
    self.web.notificationHandler = ^(gcWebNotification notification){
        switch( notification ){
            case gcWebNotificationEnd:
            {
                RZLog(RZLogInfo,@"didReceivedRemoteNotification web updated completed successfully %@", notificationPerf);
                self.web.notificationHandler = nil;
                completionHandler(UIBackgroundFetchResultNewData);
                break;
            }
            case gcWebNotificationError:
            {
                RZLog(RZLogInfo,@"didReceivedRemoteNotification web updated completed with error %@", notificationPerf);
                self.web.notificationHandler = nil;
                completionHandler(UIBackgroundFetchResultFailed);
                break;
            }
            default:
                RZLog(RZLogInfo,@"didReceivedRemoteNotification web still going");
                break;
        }
    };
    
    if( ! [self.web servicesBackgroundUpdate]){
        self.web.notificationHandler = nil;
        completionHandler(UIBackgroundFetchResultNoData);
    }
}


-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    const uint8_t * data = deviceToken.bytes;
    
    NSMutableString * token = [NSMutableString string];
    for (NSUInteger i=0; i<deviceToken.length; i++) {
        [token appendFormat:@"%02hhX", data[i]];
    }
    NSString * existingToken = [[GCAppGlobal profile] configGetString:CONFIG_NOTIFICATION_DEVICE_TOKEN defaultValue:@""];
    if( ![token isEqualToString:existingToken] ){
        RZLog(RZLogInfo,@"remote notification registered with new token: %@", token);
        [[GCAppGlobal profile] configSet:CONFIG_NOTIFICATION_DEVICE_TOKEN stringVal:token];
        dispatch_async(dispatch_get_main_queue(), ^(){
            [GCAppGlobal saveSettings];
        });
        
    }else{
        RZLog(RZLogInfo,@"remote notification registered with same token: %@", token);
    }
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    RZLog(RZLogError,@"Failed to register %@", error);
}

-(void)handleFitFile:(NSData*)fitData{
    if( fitData.length  > 12){// minimum size for fit file include headers
        GCActivity * fitAct = RZReturnAutorelease([[GCActivity alloc] initWithId:[self.urlToOpen.path lastPathComponent] fitFileData:fitData fitFilePath:self.urlToOpen.path startTime:[NSDate date]]);
        RZLog(RZLogInfo, @"Opened temp fit %@", [RZMemory formatMemoryInUse]);
        if( kOpenTemporary ){
            [self.organizer registerTemporaryActivity:fitAct forActivityId:fitAct.activityId];
        }else{
            
            [self.organizer registerActivity:fitAct forActivityId:fitAct.activityId];
            [self.organizer registerActivity:fitAct withTrackpoints:fitAct.trackpoints andLaps:fitAct.laps];
        }
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self handleFitFileDone:fitAct.activityId];
        });
    }else{
        RZLog(RZLogWarning, @"Handling fit file with no data")
    }
}

-(void)handleFitFileDone:(NSString*)aId{
    [self.actionDelegate focusOnActivityId:aId];
}
-(void)stravaSignout{
    [GCStravaRequestBase signout];
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

-(void)startSuccessful{
    static BOOL once = false;
    if (!once) {
        RZLog(RZLogInfo, @"Started");
        [RZFileOrganizer removeEditableFile:GC_STARTING_FILE];
        once = true;
        
        [self settingsUpdateCheckPostStart];
        [self startSuccessfulSwift];
        //[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
}

@end
