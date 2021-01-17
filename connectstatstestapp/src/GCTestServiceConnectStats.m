//  MIT License
//
//  Created on 28/05/2019 for ConnectStatsTestApp
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



#import "GCTestServiceConnectStats.h"
#import "GCAppGlobal.h"
#import "GCWebConnect+Requests.h"
#import "GCWebUrl.h"
#import "GCTestServiceCompare.h"
#import "GCTestAppGlobal.h"
#import "GCViewConfig.h"

@interface GCTestServiceConnectStats ()

@property (assign) gcTestStageServiceCompare stage;
@property (readonly) BOOL strava;
@property (readonly) BOOL garmin;
@property (readonly) NSString*serviceDescription;
@property (readonly) NSString*testServiceSessionName;
@end

@implementation GCTestServiceConnectStats

-(BOOL)strava{
    return self.garminSource == gcGarminDownloadSourceEnd;
}

-(BOOL)garmin{
    return self.garminSource != gcGarminDownloadSourceEnd;
}

-(gcGarminDownloadSource)garminSource{
    return gcGarminDownloadSourceConnectStats;
}

-(NSString*)serviceDescription{
    switch (self.garminSource) {
        case gcGarminDownloadSourceEnd:
            return @"Stava";
            break;
        case gcGarminDownloadSourceConnectStats:
            return @"ConnectStats";
        case gcGarminDownloadSourceBoth:
            return @"Garmin+ConnectStats";
        case gcGarminDownloadSourceGarminWeb:
            return @"GarminWeb";
    }
}

-(NSString*)testServiceSessionName{
    return [NSString stringWithFormat:@"GC Test Service %@", self.serviceDescription];
}

-(NSArray*)testDefinitions{
    NSString * testDesc = [NSString stringWithFormat:@"Test for %@", self.serviceDescription];
    return @[ @{ TK_SEL:NSStringFromSelector(@selector(testServiceStart)),
                 TK_DESC:testDesc,
                 TK_SESS:self.testServiceSessionName
    } ];
}

-(void)testServiceStart{
    [self startSession:self.testServiceSessionName];
    GCWebUseSimulator(FALSE, nil);
    
    self.stage = gcTestServiceServiceCompareSearch;
    
    dispatch_async( dispatch_get_main_queue(),^(){
        [GCTestAppGlobal setupEmptyState:serviceTestDbPath(self.garminSource) withSettingsName:kPreservedSettingsName];
        [GCViewConfig setGarminDownloadSource:self.garminSource];
        if( self.strava){
            [[GCAppGlobal profile] configSet:CONFIG_STRAVA_ENABLE boolVal:YES];
        }else{
            [[GCAppGlobal profile] configSet:CONFIG_STRAVA_ENABLE boolVal:NO];
        }
        
        [[GCAppGlobal profile] serviceAnchor:gcServiceGarmin set:kServiceNoAnchor];
        [[GCAppGlobal profile] serviceAnchor:gcServiceConnectStats set:kServiceNoAnchor];
        [[GCAppGlobal profile] serviceAnchor:gcServiceStrava set:kServiceNoAnchor];
        
        [self assessTestResult:@"Start with 0" result:[[GCAppGlobal organizer] countOfActivities] == 0 ];
        [[GCAppGlobal web] attach:self];
        [GCAppGlobal web].validateNextSearch = ^(NSDate* lastFound,NSUInteger count){
            BOOL rv = count < 70;
            RZLog(RZLogInfo, @"VALIDATE: %@ %@ activities downloaded %@", self.testServiceSessionName, @(count), rv ? @"Continue" : @"Stop");
            return rv;
        };

        [[GCAppGlobal web] servicesSearchRecentActivities];
    });
}

-(void)testServiceEnd{
    RZ_ASSERT([[GCAppGlobal organizer] countOfActivities] > 0, @"End with more than 0");
    
    // Need to detach from worker thread as there
    // maybe quite a few async processes from worker left taht are cleaning up
    // and may call notify. Need to avoid notify while detach on different thread
    dispatch_async([GCAppGlobal worker], ^(){
        [[GCAppGlobal web] detach:self];
        [GCAppGlobal web].validateNextSearch = nil;
    });
    
    [self endSession:self.testServiceSessionName];
}

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    if( [theParent respondsToSelector:@selector(currentDescription)]){
        [self log:@"%@: %@", theInfo.stringInfo, [theParent currentDescription]];
    }
    RZ_ASSERT(![[theInfo stringInfo] isEqualToString:NOTIFY_ERROR], @"Web request had no error %@", self.serviceDescription);
    if ([[theInfo stringInfo] isEqualToString:NOTIFY_END] || [[theInfo stringInfo] isEqualToString:NOTIFY_ERROR]) {
        self.stage += 1;
        
        if( self.stage == gcTestServiceServiceCompareDetails){
            RZ_ASSERT(kCompareDetailCount < [[GCAppGlobal organizer] countOfActivities], @"Stage within activities count");
            if( kCompareDetailCount < [[GCAppGlobal organizer] countOfActivities] ){
                dispatch_async([GCAppGlobal worker], ^(){
                    if( ! [[GCAppGlobal web] downloadMissingActivityDetails:kCompareDetailCount] ){
                        [self testServiceEnd];
                    }
                });
            }
        }else{
            [self testServiceEnd];
        }
    }
}

@end
