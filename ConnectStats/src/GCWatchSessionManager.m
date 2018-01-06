//  MIT Licence
//
//  Created on 09/08/2015.
//
//  Copyright (c) 2015 Brice Rosenzweig.
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

#import "GCApplicationContext.h"
#import "GCWatchSessionManager.h"
#import "GCActivityThumbnails.h"
#import "GCAppGlobal.h"
#import "GCActivitiesOrganizer.h"

@interface GCWatchSessionManager ()
@property (nonatomic,retain) WCSession * session;
@end

@implementation GCWatchSessionManager

-(GCWatchSessionManager*)init{
    self = [super init];
    if (self) {
        if ([WCSession isSupported]) {
            self.session = [WCSession defaultSession];
            self.session.delegate = self;
            [self.session activateSession];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadCompleted) name:kNotifyOrganizerLoadComplete object:nil];
        }
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_session release];
    [super dealloc];
}

-(void)loadCompleted{
    if (self.session.isReachable) {
        [self transferSummaryImage];
    }
}

-(void)transferSummaryImage{
    GCActivityThumbnails * thumb = [[GCActivityThumbnails alloc] init];
    GCField * distfield = [GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:GC_TYPE_DAY];

    UIImage * img = [thumb historyPlotFor:distfield andSize:CGSizeMake(270., 200.)];
    NSData * data = UIImagePNGRepresentation(img);
    NSString * imgname = [NSString stringWithFormat:@"thumb-summary.png"];
    [data writeToFile:[RZFileOrganizer writeableFilePath:imgname] atomically:YES];

    [self transferFile:[NSURL fileURLWithPath:[RZFileOrganizer writeableFilePath:imgname]] metadata:@{kAppContextFileType:kAppContextImageSummary,kAppContextFileName:@"summary.png"}];

    img = [thumb performancePlotFor:distfield andSize:CGSizeMake(270., 200.)];
    data = UIImagePNGRepresentation(img);
    imgname = [NSString stringWithFormat:@"thumb-performance.png"];
    [data writeToFile:[RZFileOrganizer writeableFilePath:imgname] atomically:YES];

    [self transferFile:[NSURL fileURLWithPath:[RZFileOrganizer writeableFilePath:imgname]] metadata:@{kAppContextFileType:kAppContextImagePerformance,kAppContextFileName:@"performance.png"}];

    [thumb release];
}



-(void)transferFile:(NSURL*)url metadata:(NSDictionary*)dict{
    for (WCSessionFileTransfer *transfer in self.session.outstandingFileTransfers) {
        if ([transfer.file.fileURL isEqual:url]) {
            [transfer cancel];
            break;
        }
    }
    [self.session transferFile:url metadata:dict];
}

-(void)session:(WCSession *)session didReceiveFile:(WCSessionFile *)file{
    if ([file.metadata[kAppContextFromWatchMessage] isEqualToString:kAppContextMessageLogFile]) {

    }
}


-(void)sessionReachabilityDidChange:(WCSession *)session{
    if (self.session.isReachable) {
        RZLog(RZLogInfo, @"Watch Reachable from iPhone");
        [self.session transferUserInfo:@{kAppContextFromPhoneMessage:@"thanks"}];
        if ([[GCAppGlobal organizer] loadCompleted]) {
            [self transferSummaryImage];
        }

    }else{
        RZLog(RZLogInfo, @"Watch NOT Reachable from iPhone");
    }

}
-(void)session:(WCSession *)session didReceiveUserInfo:(NSDictionary<NSString *,id> *)userInfo{
    RZLog(RZLogInfo, @"Phone Received: %@", userInfo);
}

-(void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message
  replyHandler:(void (^)(NSDictionary<NSString *,id> * _Nonnull))replyHandler{
    RZLog(RZLogInfo, @"Received Message %@", message);
    replyHandler(@{kAppContextFromPhoneMessage:@"received"});
}

-(void)session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(NSError *)error{

}
-(void)sessionDidBecomeInactive:(WCSession *)session{

}
-(void)sessionDidDeactivate:(WCSession *)session{

}

@end

