//  MIT License
//
//  Created on 07/06/2020 for ConnectStats
//
//  Copyright (c) 2020 Brice Rosenzweig
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



#import "GCStatsDerivedHistConfig.h"
#import "GCAppGlobal.h"

@implementation GCStatsDerivedHistConfig
+(GCStatsDerivedHistConfig*)config{
    GCStatsDerivedHistConfig * rv = [[[GCStatsDerivedHistConfig alloc] init] autorelease];
    if( rv){
        [rv setDateForLookbackBucket:@"-6m"];;
        rv.mode = gcDerivedHistModeAbsolute;
        rv.smoothing = gcDerivedHistSmoothingMax;
        rv.pointsForGraphs = @[ @(0), @(60), @(1800) ];
        ;
        rv.numberOfDaysForSmoothing = 5;

    }
    return rv;
}
-(void)dealloc{
    [_fromDate release];
    [super dealloc];
}
-(NSTimeInterval)timeIntervalForSmoothing{
    return self.numberOfDaysForSmoothing * 24*60*60;
}

-(void)setDateForLookbackBucket:(NSString*)bucket{
    NSString * useBucket = bucket;
    if( ! [useBucket hasPrefix:@"-"] ){
        useBucket = [NSString stringWithFormat:@"-%@", useBucket];
    }
    NSDate *from = [[[GCAppGlobal organizer] lastActivity].date dateByAddingGregorianComponents:[NSDateComponents dateComponentsFromString:useBucket]];
    
    self.fromDate = from;
}

@end
