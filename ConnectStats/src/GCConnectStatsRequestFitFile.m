//  MIT License
//
//  Created on 17/06/2019 for ConnectStats
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



#import "GCConnectStatsRequestFitFile.h"
#import "GCWebUrl.h"
#import "GCActivity.h"
#import "GCService.h"
#import "ConnectStats-Swift.h"

@interface GCConnectStatsRequestFitFile ()
@property (nonatomic,retain) GCActivity * activity;
@end

@implementation GCConnectStatsRequestFitFile

+(GCConnectStatsRequestFitFile*)requestWithActivity:(GCActivity*)act andNavigationController:(UINavigationController*)nav{
    GCConnectStatsRequestFitFile * rv = RZReturnAutorelease([[GCConnectStatsRequestFitFile alloc] init]);
    if( rv ){
        rv.activity = act;
        rv.navigationController = nav;
    }
    return rv;
}

-(GCConnectStatsRequestFitFile*)initWithNext:(GCConnectStatsRequestFitFile*)current{
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
        return RZReturnAutorelease([[GCConnectStatsRequestFitFile alloc] initNextWith:self]);
    }
    else{
        return nil;
    }
}
-(NSString*)url{
    return nil;
}
-(NSString*)description{
    return [NSString stringWithFormat:NSLocalizedString(@"Downloading Activity... %@",@"Request Description"),[self.activity.date dateFormatFromToday]];
}
-(NSURLRequest*)preparedUrlRequest{
    if( [self isSignedIn] ){
        self.navigationController = nil;
    }
    
    if (self.navigationController) {
        return nil;
    }else{
        NSString * path = GCWebConnectStatsFitFile();
        GCService * service = self.activity.service;
        NSString * aid = [service serviceIdFromActivityId:self.activity.activityId ];
        
        NSDictionary *parameters = @{
                                     @"token_id" : @(self.tokenId),
                                     @"activity_id" : @(aid.integerValue)
                                     };
        
        return [self preparedUrlRequest:path params:parameters];
    }
}

-(NSString*)fitFileName{
    NSString * aid = [self.activity.service serviceIdFromActivityId:self.activity.activityId ];
    return [NSString stringWithFormat:@"track_cs_%@.fit", aid];
}

-(void)process:(NSData *)theData andDelegate:(id<GCWebRequestDelegate>)delegate{
    self.delegate = delegate;
    
    if (![self isSignedIn]) {
        [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
        dispatch_async(dispatch_get_main_queue(),^(){
            [self signIn];
        });
        
    }else{
        NSString * fname = [self fitFileName];
        
        if(![theData writeToFile:[RZFileOrganizer writeableFilePath:fname] atomically:true]){
            RZLog(RZLogError, @"Failed to save %@.", fname);
        }
        
        
        self.stage = gcRequestStageParsing;
        [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
        dispatch_async([GCAppGlobal worker],^(){
            [self processParse:fname];
        });
    }
}

-(void)processParse:(NSString*)fileName{
    if( [self checkNoErrors]){
        NSString * fp = [[NSFileManager defaultManager] fileExistsAtPath:fileName] ? fileName : [RZFileOrganizer writeableFilePath:fileName];
        
        GCActivity * fitAct = RZReturnAutorelease([[GCActivity alloc] initWithId:self.activity.activityId fitFilePath:fp]);
        
        [self.activity updateSummaryDataFromActivity:fitAct];
        [self.activity updateTrackpointsFromActivity:fitAct];
        [self.activity saveTrackpoints:self.activity.trackpoints andLaps:self.activity.laps];
    }
    [self processDone];
}

+(GCActivity*)testForActivity:(GCActivity*)act withFilesIn:(NSString*)path{
    
    GCConnectStatsRequestFitFile * req = [GCConnectStatsRequestFitFile requestWithActivity:act andNavigationController:nil];
    
    NSString * fp = [path stringByAppendingPathComponent:[req fitFileName]];
    [req processParse:fp];
    
    return nil;
}

@end
