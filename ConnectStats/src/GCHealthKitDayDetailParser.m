//  MIT Licence
//
//  Created on 09/06/2015.
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

#import "GCHealthKitDayDetailParser.h"

#ifdef GC_USE_HEALTHKIT
#import <HealthKit/HealthKit.h>
#endif

#import "GCTrackPoint.h"
#import "GCAppGlobal.h"
#import "GCHealthKitSamplesToPointsParser.h"
#import "GCService.h"

@interface GCHealthKitDayDetailParser ()
@property (nonatomic,retain) NSDictionary * samples;
@end

@implementation GCHealthKitDayDetailParser

+(instancetype)parserWithSamples:(NSDictionary*)samples{
    GCHealthKitDayDetailParser * rv = [[[GCHealthKitDayDetailParser alloc] init] autorelease];
    if (rv) {
        rv.samples = samples;
    }
    return rv;
}

-(void)dealloc{
    [_sourceValidator release];
    [_samples release];

    [super dealloc];
}
-(void)parse:(GCHealthKitDaiDetailPoints)cb{
#if GC_USE_HEALTHKIT
    NSMutableArray * points = [NSMutableArray array];
    GCHealthKitSamplesToPointsParser * parser =[[[GCHealthKitSamplesToPointsParser alloc] init] autorelease];

    NSArray * dates = [(self.samples).allKeys sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray * sorted = [NSMutableArray array];
    for (NSDate * date in dates) {
        for (HKQuantitySample*sample in self.samples[date]) {
            if (self.sourceValidator( sample.sourceRevision.source.bundleIdentifier)) {
                [sorted addObject:sample];
                //NSLog(@"%@ -> %@ (%.1f) %@", sample.startDate, sample.endDate, [sample.endDate timeIntervalSinceDate:sample.startDate], sample.quantity);
            }
        }
    }

    if (sorted.count) {
        [parser parseSamples:sorted forActivityType:GC_TYPE_DAY];
        [points addObjectsFromArray:parser.points];
    }

    cb([points sortedArrayUsingSelector:@selector(compareTime:)]);
#endif
}

@end
