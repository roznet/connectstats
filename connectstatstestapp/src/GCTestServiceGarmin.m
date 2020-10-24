//  MIT Licence
//
//  Created on 13/05/2017.
//
//  Copyright (c) 2017 Brice Rosenzweig.
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

#import "GCTestServiceGarmin.h"
#import "GCWebConnect+Requests.h"
#import "GCWebUrl.h"
#import "GCAppGlobal.h"
#import "GCTestServiceCompare.h"
#import "GCTestAppGlobal.h"

@interface GCTestServiceGarmin ()
@property (assign) gcTestStageServiceCompare stage;
@end

@implementation GCTestServiceGarmin

-(NSArray*)testDefinitions{
    return @[ @{TK_SEL:NSStringFromSelector(@selector(testGarminConnectModern)),
                TK_DESC:@"Try to login and download one list of activity modern",
                TK_SESS:@"GC Garmin Connect Alt"},

              ];
}

-(void)testGarminConnectModern{
    [self startSession:@"GC Garmin Connect Alt"];
    GCWebUseSimulator(FALSE, nil);

    [GCTestAppGlobal setupEmptyState:kDbPathServiceGarmin withSettingsName:kPreservedSettingsName];
    [[GCAppGlobal profile] configSet:CONFIG_GARMIN_ENABLE boolVal:YES];
    [[GCAppGlobal profile] configSet:CONFIG_GARMIN_USE_MODERN boolVal:YES];

    self.stage = gcTestServiceServiceCompareSearch;

    [self assessTestResult:@"Start with 0" result:[[GCAppGlobal organizer] countOfActivities] == 0 ];
    /*dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
     [self timeOutCheck];
     });*/
    [[GCAppGlobal web] attach:self];
    [[GCAppGlobal web] servicesSearchRecentActivities];
}

-(void)testGarminConnectModernEnd{
    // Need to detach from worker thread as there
    // maybe quite a few async processes from worker left taht are cleaning up
    // and may call notify. Need to avoid notify while detach on different thread
    dispatch_async([GCAppGlobal worker], ^(){
        [[GCAppGlobal web] detach:self];
    });


    [self endSession:@"GC Garmin Connect Alt"];
}

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    if( [theParent respondsToSelector:@selector(currentDescription)]){
        [self log:@"%@: %@", theInfo.stringInfo, [theParent currentDescription]];
    }
    RZ_ASSERT(![[theInfo stringInfo] isEqualToString:@"error"], @"Web request had no error");
    if ([[theInfo stringInfo] isEqualToString:@"end"] || [[theInfo stringInfo] isEqualToString:@"error"]) {
        self.stage += 1;
        
        if( self.stage == gcTestServiceServiceCompareDetails){
            
            RZ_ASSERT(kCompareDetailCount < [[GCAppGlobal organizer] countOfActivities], @"Stage within activities count");
            if( kCompareDetailCount < [[GCAppGlobal organizer] countOfActivities] ){
                [[GCAppGlobal web] downloadMissingActivityDetails:kCompareDetailCount];
            }
        }else{
            [self testGarminConnectModernEnd];
        }        
    }
}
@end
