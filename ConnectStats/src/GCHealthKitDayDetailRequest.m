//  MIT Licence
//
//  Created on 01/06/2015.
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

#import "GCHealthKitDayDetailRequest.h"

#ifdef GC_USE_HEALTHKIT
#import <HealthKit/HealthKit.h>
#endif

#import "GCTrackPoint.h"
#import "GCAppGlobal.h"
#import "GCHealthKitSamplesToPointsParser.h"
#import "GCService.h"
#import "GCHealthKitDayDetailParser.h"
#import "GCActivitiesOrganizer.h"

@interface GCHealthKitDayDetailRequest ()
@property (nonatomic,retain) NSMutableDictionary * samples;
@property (nonatomic,retain) NSDate * date;
@property (nonatomic,retain) NSDate * toDate;

@end

@implementation GCHealthKitDayDetailRequest

+(instancetype)requestForDate:(NSDate*)date{
    GCHealthKitDayDetailRequest * rv = [[[GCHealthKitDayDetailRequest alloc] init] autorelease];
    if (rv) {
        rv.date = date;
    }
    return rv;
}
+(instancetype)requestForDate:(NSDate*)date to:(NSDate*)toDate{
    GCHealthKitDayDetailRequest * rv = [GCHealthKitDayDetailRequest requestForDate:date];
    if (rv) {
        rv.toDate =toDate;
    }
    return rv;
}

-(void)dealloc{
    [_samples release];
    [_date release];
    [_toDate release];

    [super dealloc];
}

#ifdef GC_USE_HEALTHKIT
-(NSArray*)readSampleTypes{
    return @[ [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
              [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate],
              [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning],
              [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling],
              [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed]
              ];
}

-(NSString*)description{

    return [NSString stringWithFormat:@"Analysing %@", [self.date dateFormatFromToday]];
}

#pragma  mark - Query Healthkit

-(void)executeNext{
    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self.date];

    NSDate *startDate = [calendar dateFromComponents:components];
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];

    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];

    HKQuantityType *quantityType = self.currentQuantityType;

    NSString * descriptor = [quantityType.identifier hasPrefix:@"HKQuantityTypeIdentifier"] ?
    [quantityType.identifier substringFromIndex:(@"HKQuantityTypeIdentifier").length] : quantityType.identifier;

    NSSortDescriptor *startDateSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate
                                                                    ascending:YES];


    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:quantityType
                                                           predicate:predicate
                                                               limit:0
                                                     sortDescriptors:@[startDateSort]
                                                      resultsHandler:^(HKSampleQuery *thequery, NSArray *results, NSError *error) {

        if (error) {
            RZLog(RZLogError, @"%@ Query Failed: %@", descriptor, error.localizedDescription);
        }else{

            for (HKQuantitySample *sample in results) {
                NSMutableArray * one = self.samples[sample.startDate];
                if (!one) {
                    one = [NSMutableArray arrayWithObject:sample];
                    self.samples[sample.startDate] = one;
                }else{
                    [one addObject:sample];
                }
            }
        }
        [self nextQuantityType];
        if ([self isLastRequest]) {
            [self saveCollectedData:self.samples withSuffix:@"daydetail" andId:[self.date YYYYMMDD]];
            dispatch_async([GCAppGlobal worker],^(){
                [self parseSamples];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self executeNext];
            });
        }
    }];

    [self.healthStore executeQuery:query];
    [query release];

}

-(void)executeQuery{
    self.samples = [NSMutableDictionary dictionary];
    [self executeNext];
}

#pragma mark - Parsing

-(void)parseSamples{

    NSString * aId = [[GCService service:gcServiceHealthKit] activityIdFromServiceId:[GCHealthKitRequest dayActivityId:self.date]];
    GCHealthKitDayDetailParser * parser = [GCHealthKitDayDetailParser parserWithSamples:self.samples];
    parser.sourceValidator = [[GCAppGlobal profile] currentSourceValidator];
    [parser parse:^(NSArray*points){
        if (points) {
            [[GCAppGlobal organizer] registerActivity:aId withTrackpoints:points andLaps:nil];
        }
    }];
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self.delegate processDone:self];
    });
}

-(id<GCWebRequest>)nextReq{
    GCHealthKitDayDetailRequest * rv = nil;
    if (self.toDate) {
        NSDate * nextDate = [[GCAppGlobal calculationCalendar] dateByAddingUnit:NSCalendarUnitDay
                                                                          value:-1
                                                                         toDate:self.date
                                                                        options:0];
        if ([nextDate compare:self.toDate] != NSOrderedAscending) {
            rv = [GCHealthKitDayDetailRequest requestForDate:nextDate to:self.toDate];
        }
    }
    return rv;
}


#endif


@end
