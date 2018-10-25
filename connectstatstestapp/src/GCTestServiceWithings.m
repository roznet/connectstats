//  MIT License
//
//  Created on 21/10/2018 for ConnectStatsTestApp
//
//  Copyright (c) 2018 Brice Rosenzweig
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



#import "GCTestServiceWithings.h"
#import "GCWebConnect+Requests.h"
#import "GCWebUrl.h"
#import "GCAppGlobal.h"

@implementation GCTestServiceWithings

-(NSArray*)testDefinitions{
    return @[ @{TK_SEL:NSStringFromSelector(@selector(testWithings)),
                TK_DESC:@"Try to login and download Weights from withings",
                TK_SESS:@"GC Withings"},
              
              ];
}

-(void)testWithings{
    [self startSession:@"GC Withings"];
    GCWebUseSimulator(FALSE, nil);
    
    [GCAppGlobal setupEmptyState:@"activities_withings.db" withSettingsName:kPreservedSettingsName];
    [[GCAppGlobal profile] configSet:CONFIG_WITHINGS_AUTO boolVal:YES];
    
    GCField * weight = [GCHealthMeasure healthFieldFromMeasureType:gcMeasureWeight];
    GCStatsDataSerieWithUnit * values = [[GCAppGlobal health] dataSerieWithUnitForHealthField:weight];
    
    [self assessTestResult:@"Start with 0" result:values.count == 0 ];
    [[GCAppGlobal web] attach:self];
    [[GCAppGlobal web] servicesSearchRecentActivities];
}

-(void)testWithingsEnd{
    [[GCAppGlobal web] detach:self];
    
    GCField * weight = [GCHealthMeasure healthFieldFromMeasureType:gcMeasureWeight];
    GCStatsDataSerieWithUnit * values = [[GCAppGlobal health] dataSerieWithUnitForHealthField:weight];
    
    [self assessTestResult:@"Ends with more than 0" result:values.count > 0 ];

    [self endSession:@"GC Withings"];
}

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    if( [theParent respondsToSelector:@selector(currentDescription)]){
        [self log:@"%@: %@", theInfo.stringInfo, [theParent currentDescription]];
    }
    RZ_ASSERT(![[theInfo stringInfo] isEqualToString:@"error"], @"Web request had no error");
    if ([[theInfo stringInfo] isEqualToString:@"end"] || [[theInfo stringInfo] isEqualToString:@"error"]) {
        [self testWithingsEnd];
    }
}

@end
