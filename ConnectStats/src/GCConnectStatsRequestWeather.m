//  MIT License
//
//  Created on 26/10/2019 for ConnectStats
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



#import "GCConnectStatsRequestWeather.h"
#import "GCWebUrl.h"
#import "GCActivity.h"
#import "GCService.h"
#import "GCAppGlobal.h"

@interface GCConnectStatsRequestWeather ()
@property (nonatomic,retain) GCActivity * activity;
@end

@implementation GCConnectStatsRequestWeather

+(GCConnectStatsRequestWeather*)requestWithActivity:(GCActivity*)act andNavigationController:(UINavigationController*)nav{
    GCConnectStatsRequestWeather * rv = RZReturnAutorelease([[GCConnectStatsRequestWeather alloc] init]);
    if( rv ){
        rv.activity = act;
        rv.navigationController = nav;
    }
    return rv;
}


-(GCConnectStatsRequestWeather*)initWithNext:(GCConnectStatsRequestWeather*)current{
    self = [super initNextWith:current];
    if( self ){
        self.activity = current.activity;
    }
    return self;
}

#if !__has_feature(objc_arc)
-(void)dealloc{
    [_activity release];
    [super dealloc];
}
#endif

-(id<GCWebRequest>)nextReq{
    
    if( self.navigationController ){
        return RZReturnAutorelease([[GCConnectStatsRequestWeather alloc] initNextWith:self]);
    }
    else{
        return nil;
    }
}
-(NSString*)url{
    return nil;
}
-(NSString*)description{
    return [NSString stringWithFormat:NSLocalizedString(@"Downloading Weather... %@",@"Request Description"),[self.activity.date dateFormatFromToday]];
}
-(NSURLRequest*)preparedUrlRequest{
    if( [self isSignedIn] ){
        self.navigationController = nil;
    }
    
    if (self.navigationController) {
        return nil;
    }else{
        NSString * path = GCWebConnectStatsWeather([[GCAppGlobal profile] configGetInt:CONFIG_CONNECTSTATS_CONFIG defaultValue:gcWebConnectStatsConfigProduction]);
        GCService * service = self.activity.service;
        NSString * aid = [service serviceIdFromActivityId:self.activity.activityId ];
        
        NSDictionary *parameters = @{
                                     @"token_id" : @(self.tokenId),
                                     @"activity_id" : @(aid.integerValue),
                                     @"table":@"weather",
                                     };
        
        return [self preparedUrlRequest:path params:parameters];
    }
}

-(NSString*)weatherFileName{
    NSString * aid = [self.activity.service serviceIdFromActivityId:self.activity.activityId ];
    return [NSString stringWithFormat:@"weather_cs_%@.json", aid];
}

-(void)process{
    if (![self isSignedIn]) {
        [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
        dispatch_async(dispatch_get_main_queue(),^(){
            [self signIn];
        });
        
    }else{
#if TARGET_IPHONE_SIMULATOR
        NSError * e;
        NSString * fname = [self weatherFileName];
        if(![self.theString writeToFile:[RZFileOrganizer writeableFilePath:fname] atomically:true encoding:kRequestDebugFileEncoding error:&e]){
            RZLog(RZLogError, @"Failed to save %@. %@", fname, e.localizedDescription);
        }
#endif
        [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
        dispatch_async([GCAppGlobal worker],^(){
            [self processParse];
        });
    }
}

-(void)processParse{
    if( [self checkNoErrors]){
        
        NSData * data = [self.theString dataUsingEncoding:self.encoding];
        if( data ){
            NSError * err = nil;
            NSDictionary * json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments
                                                                           error:&err];
            if( json ){
                
                if( [json isKindOfClass:[NSDictionary class]]){
                    BOOL done = false;
                    NSArray<NSDictionary*>*found = json[@"weather"];
                    if( [found isKindOfClass:[NSArray class]]){
                        for (NSDictionary * one in found) {
                            NSString * aId = one[@"activity_id"];
                            
                            if( aId && [[self.activity.service activityIdFromServiceId:aId] isEqualToString:self.activity.activityId]){
                                GCWeather * weather = [GCWeather weatherWithData:one];
                                [self.activity recordWeather:weather];
                                dispatch_async(dispatch_get_main_queue(), ^(){
                                    [[GCAppGlobal organizer] notifyForString:self.activity.activityId];
                                });
                                done = true;
                            }
                        }
                        if( ! done ){
                            RZLog(RZLogInfo, @"No weather data found for %@", self.activity);
                        }
                    }
                }else{
                    RZLog(RZLogError, @"Weather is not a json dictionary");
                }
                
            }else{
                RZLog(RZLogError, @"Failed to parse json %@", err);
            }
        }
    }
    [self processDone];
}

+(GCActivity*)testForActivity:(GCActivity*)act withFilesIn:(NSString*)path{
    
    GCConnectStatsRequestWeather * req = [GCConnectStatsRequestWeather requestWithActivity:act andNavigationController:nil];
    
    BOOL isDirectory = false;
    if( [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory]){
        NSString * fn = isDirectory ? [path stringByAppendingPathComponent:[req weatherFileName]] : path;
        
        req.theString = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:fn] encoding:kRequestDebugFileEncoding error:nil];
        req.encoding = kRequestDebugFileEncoding;
        [req processParse];
    }
    return req.activity;
}

@end
