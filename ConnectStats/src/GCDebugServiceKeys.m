//  MIT License
//
//  Created on 27/07/2019 for ConnectStats
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



#import "GCDebugServiceKeys.h"
#import "GCAppGlobal.h"

@interface GCDebugServiceKeys ()
@property (nonatomic,retain) NSArray<NSDictionary<NSString*,NSString*>*>*debugKeys;
@end
@implementation GCDebugServiceKeys

+(instancetype)serviceKeys{
    GCDebugServiceKeys * rv = RZReturnAutorelease([[GCDebugServiceKeys alloc] init]);
    if( rv ){
        NSString * fp = [RZFileOrganizer writeableFilePathIfExists:@"debugkey.json"];
        
        if( fp ){
            NSData * data = [NSData dataWithContentsOfFile:fp];
            if ( data ){
                NSArray * d = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                if( d ){
                    rv.debugKeys = d;
                }
            }
        }
    }
    return rv;
}

-(void)dealloc{
    [_debugKeys release];
    [super dealloc];
}

-(BOOL)hasDebugKeys{
    return  self.debugKeys.count > 0;
}
-(NSArray<NSString*>*)availableTokenIds{
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:self.debugKeys.count];
    for (NSDictionary<NSString*,NSString*> * one in self.debugKeys) {
        if( one[@"token_id"] ){
            [rv addObject:one[@"token_id"]];
        }
    }
    return rv;
}

-(NSArray<NSString*>*)displayAvailableKeys{
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:self.debugKeys.count];
    for (NSDictionary<NSString*,NSString*> * one in self.debugKeys) {
        if( one[@"token_id"] ){
            [rv addObject:[NSString stringWithFormat:@"token_id=%@ cs_user_id=%@", one[@"token_id"], one[@"cs_user_id"]]];
        }
    }
    return rv;

}
-(void)useKeyForTokenId:(NSString*)tokenId{
    for (NSDictionary<NSString*,NSString*> * one in self.debugKeys) {
        
        if( [one[@"token_id"] isEqualToString:tokenId]){
            NSUInteger token_id = [one[@"token_id"] integerValue];
            NSUInteger cs_user_id = [one[@"cs_user_id"] integerValue];
            NSString * userAccessToken = one[@"userAccessToken"];
            NSString * userAccessTokenSecret = one[@"userAccessTokenSecret"];
            
            if( cs_user_id > 0 && userAccessToken && userAccessTokenSecret ){
                [[GCAppGlobal profile] configSet:CONFIG_CONNECTSTATS_TOKEN_ID intVal:token_id];
                [[GCAppGlobal profile] configSet:CONFIG_CONNECTSTATS_USER_ID intVal:cs_user_id];
                [[GCAppGlobal profile] configSet:CONFIG_CONNECTSTATS_TOKEN stringVal:userAccessToken];
                [[GCAppGlobal profile] setPassword:userAccessTokenSecret forService:gcServiceConnectStats];
                [GCAppGlobal saveSettings];
                
                RZLog( RZLogInfo, @"Switch to debug keys for token_id=%lu and cs_user_id=%lu", token_id, cs_user_id);
            }
        }
    }
}

@end
