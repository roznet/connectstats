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
    }
    return self;
}
-(NSString*)url{
    return nil;
}
// Need to override urlDescription to not deal work without signing in.
-(NSString*)urlDescription{
    return GCWebConnectStatsValidateUser([GCAppGlobal webConnectsStatsConfig]);
}
-(NSURLRequest*)preparedUrlRequest{
    if( [self isSignedIn] ){
        self.navigationController = nil;
    }
    
    if (self.navigationController) {
        return nil;
    }else{
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
    return nil;
}

-(void)process{
    [self process:[self.theString dataUsingEncoding:self.encoding] andDelegate:self.delegate];
}
-(void)process:(NSData *)theData andDelegate:(id<GCWebRequestDelegate>)delegate{
    self.delegate = delegate;
  
    // If we have navigation controller, check signin
    if( self.navigationController != nil) {
        if (![self isSignedIn]) {
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self processNewStage];
            });
            dispatch_async(dispatch_get_main_queue(),^(){
                RZLog(RZLogInfo,@"Starting signIn process");
                [self signIn];
            });
        }else{
            RZLog(RZLogInfo,@"Already signed in");
            [self processDone];
        }
    }else{
        // result of validate user
        NSData * jsonData = theData;
        if( jsonData ){
            NSDictionary * info = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
            if( [info isKindOfClass:[NSDictionary class]] && [info[@"cs_user_id"] respondsToSelector:@selector(integerValue)] && [info[@"cs_user_id"] integerValue] == self.userId){
                RZLog(RZLogInfo, @"Validated user %@", info[@"cs_user_id"]);
                [GCConnectStatsRequestRegisterNotifications register];
            }else{
                RZLog(RZLogWarning, @"Invalid user %@ != %@", info[@"cs_user_id"], @(self.userId));
            }
        }else{
            RZLog(RZLogWarning, @"No data for user validation");
        }
        [self processDone];
    }
}

-(BOOL)priorityRequest{
    return true;
}


-(id<GCWebRequest>)nextReq{
    if( self.navigationController ){
        return [GCConnectStatsRequestLogin requestNavigationController:nil];
    }else{
        return nil;
    }
}

@end
