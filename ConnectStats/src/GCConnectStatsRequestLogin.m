//  MIT License
//
//  Created on 28/05/2019 for ConnectStats
//
//  Copyright (c) 2019 Brice Rosenzweig
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



#import "GCConnectStatsRequestLogin.h"
#import "GCWebUrl.h"
#import "GCAppGlobal.h"
#import "ConnectStats-Swift.h"

typedef NS_ENUM(NSUInteger,GCConnectStatsRequestLoginStage) {
    GCConnectStatsRequestLoginStageAPICheck,
    GCConnectStatsRequestLoginStageValidateUser,
    GCConnectStatsRequestLoginStageEnd
};

@interface GCConnectStatsRequestLogin ()

@property (nonatomic,assign) GCConnectStatsRequestLoginStage loginStage;

@end


@implementation GCConnectStatsRequestLogin

+(GCConnectStatsRequestLogin*)requestNavigationController:(UINavigationController *)nav{
    GCConnectStatsRequestLogin * rv = RZReturnAutorelease([[GCConnectStatsRequestLogin alloc] init]);
    rv.navigationController = nav;
    return rv;
}

-(GCConnectStatsRequestLogin*)initNextWith:(GCConnectStatsRequestLogin*)current{
    self = [super initNextWith:current];
    if( self ){
        self.navigationController = nil;
        self.loginStage = current.loginStage + 1;
    }
    return self;
}
-(NSString*)url{
    return nil;
}

-(NSURLRequest*)preparedUrlRequest{
    if( [self isSignedIn] ){
        self.navigationController = nil;
    }
    
    if (self.navigationController) {
        return nil;
    }else{
        switch (self.loginStage) {
                
            case GCConnectStatsRequestLoginStageValidateUser:
            {
                NSString * path = GCWebConnectStatsValidateUser([GCAppGlobal webConnectsStatsConfig]);
                NSUInteger type = [GCAppGlobal profile].pushNotificationType;
                NSDictionary *parameters = @{
                                             @"token_id" : @(self.tokenId),
                                             @"notification_device_token": [[GCAppGlobal profile] configGetString:CONFIG_NOTIFICATION_DEVICE_TOKEN defaultValue:@""],
                                             @"notification_enabled" : @([GCAppGlobal profile].pushNotificationEnabled),
                                             @"notification_push_type" : @( type ),
                                             };
                
                return [self preparedUrlRequest:path params:parameters];
            }
            case GCConnectStatsRequestLoginStageAPICheck:
            {
                return [NSURLRequest requestWithURL:[NSURL URLWithString:GCWebConnectStatsApiCheck([GCAppGlobal webConnectsStatsConfig])]];
            }
            case GCConnectStatsRequestLoginStageEnd:
                return nil;
        }
    }
    return nil;
}


-(void)process:(NSData *)theData andDelegate:(id<GCWebRequestDelegate>)delegate{
    self.delegate = delegate;
    
    if (self.loginStage == GCConnectStatsRequestLoginStageAPICheck){
        if( theData != nil){
            NSData * jsonData = theData;
            NSDictionary * info = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
            if( [info isKindOfClass:[NSDictionary class]] && [info[@"status"] respondsToSelector:@selector(integerValue)] && [info[@"status"] integerValue] == 1){
                RZLog(RZLogInfo, @"Api Check Success");
                
                if( [info[@"redirect"] isKindOfClass:[NSString class]] ){
                    gcWebConnectStatsConfig redirect = GCWebConnectStatsConfigForRedirect(info[@"redirect"]);
                    gcWebConnectStatsConfig currentConfig = [GCAppGlobal webConnectsStatsConfig];
                    if( redirect != gcWebConnectStatsConfigEnd && redirect != currentConfig){
                        RZLog( RZLogInfo, @"API Check requesting redirect from %@ to %@",
                              GCWebConnectStatsApiCheck(currentConfig),
                              GCWebConnectStatsApiCheck(redirect));
                        
                        [[GCAppGlobal profile] configSet:CONFIG_CONNECTSTATS_CONFIG intVal:redirect];
                        [GCAppGlobal saveSettings];
                    }else{
                        RZLog(RZLogInfo, @"API Check success. Already redirected." );
                    }
                }
            }else{
                RZLog(RZLogError, @"API Check FAILED %@", info);
            }
        }else{
            RZLog(RZLogInfo, @"API Check not supported");
        }
        [self processDone];
    }else{
        if (![self isSignedIn]) {
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self processNewStage];
            });
            dispatch_async(dispatch_get_main_queue(),^(){
                [self signIn];
            });
            
        }else{
            if( self.loginStage == GCConnectStatsRequestLoginStageValidateUser){
                NSData * jsonData = theData;
                NSDictionary * info = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
                if( [info isKindOfClass:[NSDictionary class]] && [info[@"cs_user_id"] respondsToSelector:@selector(integerValue)] && [info[@"cs_user_id"] integerValue] == self.userId){
                    RZLog(RZLogInfo, @"Validated user %@", info[@"cs_user_id"]);
                    [GCConnectStatsRequestRegisterNotifications register];
                }else{
                    RZLog(RZLogWarning, @"Invalid user %@ != %@", info[@"cs_user_id"], @(self.userId));
                }
                [self processDone];
            }
        }
    }
}

-(BOOL)priorityRequest{
    return true;
}


-(id<GCWebRequest>)nextReq{
    // later check logic to see if reach existing.
    if( self.navigationController ){
        return [GCConnectStatsRequestLogin requestNavigationController:nil];
    }else{
        if( self.loginStage + 1 < GCConnectStatsRequestLoginStageEnd ){
            return [[[GCConnectStatsRequestLogin alloc] initNextWith:self] autorelease];
        }
    }
    return nil;
}

@end
