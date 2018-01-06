//  MIT Licence
//
//  Created on 30/05/2015.
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

#import "GCHealthKitDailySummaryRequest.h"
#import "GCActivity.h"
#import "GCActivity+Import.h"
#import "GCActivitiesOrganizer.h"

#ifdef GC_USE_HEALTHKIT
#import <HealthKit/HealthKit.h>
#endif

#import "GCService.h"
#import "GCAppGlobal.h"
#import "GCHealthKitDailySummaryParser.h"

@interface GCHealthKitDailySummaryRequest ()
@property (nonatomic,retain) NSMutableDictionary * collected;
@property (nonatomic,retain) NSMutableSet * foundSources;
@property (nonatomic,assign) NSUInteger newActivities;

@property (nonatomic,retain) NSDate * startDate;
@property (nonatomic,retain) NSDate * endDate;
@property (nonatomic,retain) NSDate * anchorDate;

@end

@implementation GCHealthKitDailySummaryRequest

+(instancetype)requestFor:(NSDate*)lastDate{
    GCHealthKitDailySummaryRequest * rv = [[[GCHealthKitDailySummaryRequest alloc] init] autorelease];
    if (rv) {
        [rv setupForEndDate:lastDate?:[NSDate date]];

    }
    return rv;
}

-(void)dealloc{
    [_collected release];
    [_startDate release];
    [_endDate release];
    [_anchorDate release];
    [_foundSources release];

    [super dealloc];
}

-(void)setupForEndDate:(NSDate*)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];


    // Set the anchor date to Monday at 3:00 a.m.
    NSDateComponents *anchorComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth |
                                          NSCalendarUnitYear | NSCalendarUnitWeekday fromDate:date];

    NSInteger offset = (7 + anchorComponents.weekday - 2) % 7;
    anchorComponents.day -= offset;
    anchorComponents.hour = 3;

    self.anchorDate = [calendar dateFromComponents:anchorComponents];

    self.endDate = date;
    self.startDate = [calendar dateByAddingUnit:NSCalendarUnitMonth
                                             value:-1
                                            toDate:self.endDate
                                           options:0];

}

-(NSString*)description{
    return [NSString stringWithFormat:@"Analysing %@", [self.endDate calendarUnitFormat:NSCalendarUnitMonth]];
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

#pragma mark - Query HealthKit

-(void)executeQuery{
    self.collected = [NSMutableDictionary dictionary];
    self.foundSources = [NSMutableSet set];
    self.newActivities = 0;
    [self executeNext];
}

-(void)executeNext{
    NSDateComponents *interval = [[[NSDateComponents alloc] init] autorelease];
    interval.day = 1;

    HKQuantityType *quantityType = self.currentQuantityType;

    NSString * descriptor = [quantityType.identifier hasPrefix:@"HKQuantityTypeIdentifier"] ?
    [quantityType.identifier substringFromIndex:(@"HKQuantityTypeIdentifier").length] : quantityType.identifier;

    //HKStatisticsOptionCumulativeSum//+HKStatisticsOptionDiscreteAverage//+HKStatisticsOptionDiscreteMin+HKStatisticsOptionDiscreteMax
    NSUInteger option = [GCHealthKitRequest optionForIdentifier:quantityType.identifier];
    HKStatisticsCollectionQuery *query = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:quantityType
                                                                           quantitySamplePredicate:nil
                                                                                           options:option|HKStatisticsOptionSeparateBySource
                                                                                        anchorDate:self.anchorDate
                                                                                intervalComponents:interval];

    query.initialResultsHandler = ^(HKStatisticsCollectionQuery *thequery, HKStatisticsCollection *results, NSError *error) {
        if (error) {
            RZLog(RZLogError, @"%@ Query Failed: %@", descriptor, error.localizedDescription);
        }else{


            // Plot the weekly step counts over the past 3 months
            [results enumerateStatisticsFromDate:self.startDate
                                          toDate:self.endDate
                                       withBlock:^(HKStatistics *result, BOOL *stop) {
                                           [self.foundSources addObjectsFromArray:result.sources];

                                           NSMutableArray * one = self.collected[result.startDate];
                                           if (one == nil) {
                                               one = [NSMutableArray arrayWithObject:result];
                                               self.collected[result.startDate] = one;
                                           }else{
                                               [one addObject:result];
                                           }

                                       }];
        }
        [self nextQuantityType];
        if ([self isLastRequest]) {
            [self saveCollectedData:self.collected withSuffix:@"daysummary" andId:[self.endDate YYYYMMDD]];
            dispatch_async([GCAppGlobal worker],^(){
                [self parseCollected];
            });
        }else{
            [self performSelectorOnMainThread:@selector(executeNext) withObject:nil waitUntilDone:NO];
        }
    };

    [self.healthStore executeQuery:query];
    [query release];

}

#pragma mark - Parse


-(void)parseCollected{
    GCHealthKitDailySummaryParser * parser = [GCHealthKitDailySummaryParser parserWithSamples:self.collected];
    for (HKSource * source in self.foundSources) {
        [[GCAppGlobal profile] registerSource:source.bundleIdentifier withName:source.name];
    }
    parser.sourceValidator = [[GCAppGlobal profile] currentSourceValidator];
    [parser parse:^(GCActivity*act,NSString*aId){
        BOOL changed = [[GCAppGlobal organizer] registerActivity:act forActivityId:aId];
        if (changed) {
            self.newActivities++;
        }

    }];

    [self.delegate performSelectorOnMainThread:@selector(processDone:) withObject:self waitUntilDone:NO];

}

-(id<GCWebRequest>)nextReq{
    if (self.newActivities > 0) {
        return [GCHealthKitDailySummaryRequest requestFor:self.startDate];
    }
    return nil;
}


#endif

@end
