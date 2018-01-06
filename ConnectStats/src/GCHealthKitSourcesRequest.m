//  MIT Licence
//
//  Created on 13/06/2015.
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

#import "GCHealthKitSourcesRequest.h"

#ifdef GC_USE_HEALTHKIT
#import <HealthKit/HealthKit.h>
#endif

#import "GCService.h"
#import "GCAppGlobal.h"

@interface GCHealthKitSourcesRequest ()
@property (nonatomic,retain) NSMutableDictionary * sources;
@property (nonatomic,assign) BOOL foundNewSource;

@end

@implementation GCHealthKitSourcesRequest

-(void)dealloc{
    [_sources release];
    [super dealloc];
}

-(NSString*)description{
    return NSLocalizedString( @"Analysing Sources", @"HealthRequest Descriptions");
}

#ifdef GC_USE_HEALTHKIT
-(NSArray*)readSampleTypes{
    return @[ [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
              [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate],
              [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning],
              [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling],
              [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed],
              [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned],
              [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass],
              [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyFatPercentage],
              [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierLeanBodyMass],
              [HKQuantityType workoutType],
              ];
}

#pragma mark - Query HealthKit

-(void)executeQuery{
    if (self.sources == nil) {
        self.sources = [NSMutableDictionary dictionary];
        self.foundNewSource = false;
    }

    HKQuantityType *quantityType = self.currentQuantityType;
    if ([quantityType isKindOfClass:[HKWorkoutType class]]) {
        if ([self isLastRequest]) {
            [self performSelectorOnMainThread:@selector(checkSources) withObject:nil waitUntilDone:NO];

        }else{
            [self nextQuantityType];
            [self performSelectorOnMainThread:@selector(executeQuery) withObject:nil waitUntilDone:NO];
        }
    }else{
        NSDateComponents *interval = [[[NSDateComponents alloc] init] autorelease];
        interval.year = -1;
        NSDate * date = [NSDate date];
        NSDate * start = [date dateByAddingGregorianComponents:interval];

        interval.year = 1;



        NSString * descriptor = [quantityType.identifier hasPrefix:@"HKQuantityTypeIdentifier"] ?
        [quantityType.identifier substringFromIndex:(@"HKQuantityTypeIdentifier").length] : quantityType.identifier;

        //HKStatisticsOptionCumulativeSum//+HKStatisticsOptionDiscreteAverage//+HKStatisticsOptionDiscreteMin+HKStatisticsOptionDiscreteMax
        NSUInteger option = [GCHealthKitRequest optionForIdentifier:quantityType.identifier];
        HKStatisticsCollectionQuery *query = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:quantityType
                                                                               quantitySamplePredicate:nil
                                                                                               options:option|HKStatisticsOptionSeparateBySource
                                                                                            anchorDate:date
                                                                                    intervalComponents:interval];

        query.initialResultsHandler = ^(HKStatisticsCollectionQuery *thequery, HKStatisticsCollection *results, NSError *error) {
            if (error) {
                RZLog(RZLogError, @"%@ Query Failed: %@", descriptor, error.localizedDescription);
            }else{
                // do 1 day query just to check the sources
                [results enumerateStatisticsFromDate:start
                                              toDate:date
                                           withBlock:^(HKStatistics *result, BOOL *stop) {

                                               NSArray * sources = result.sources;
                                               for (HKSource * source in sources) {
                                                   BOOL newOne = [[GCAppGlobal profile] registerSource:source.bundleIdentifier withName:source.name];
                                                   if (newOne) {
                                                       self.foundNewSource = true;
                                                   }
                                                   self.sources[source.bundleIdentifier] = source.name;
                                               }
                                           }];
            }
            if ([self isLastRequest]) {
                [self performSelectorOnMainThread:@selector(checkSources) withObject:nil waitUntilDone:NO];

            }else{
                [self nextQuantityType];
                [self performSelectorOnMainThread:@selector(executeQuery) withObject:nil waitUntilDone:NO];
            }
        };

        [self.healthStore executeQuery:query];
        [query release];
    }
}

-(void)checkSources{
    NSString * current = [[GCAppGlobal profile] currentSource];
    BOOL saveSettings = self.foundNewSource;
    if (current.length == 0) {
        // Setup reasonable default:
        NSString * watch = nil;
        NSString * iphone = nil;
        NSString * apple = nil;
        for (NSString * identifier in self.sources) {
            NSString * name = self.sources[identifier];
            if ([name rangeOfString:@"Watch"].location != NSNotFound) {
                watch = identifier;
            }else if ([name rangeOfString:@"iPhone"].location != NSNotFound) {
                iphone = identifier;
            }else if ([identifier hasPrefix:@"com.apple"]){
                apple = identifier;
            }
        }
        NSString * useSource = nil;
        if (watch) {
            useSource = watch;
        }else if (iphone){
            useSource = iphone;
        }else if (apple){
            useSource = apple;
        }else if(self.sources.count>0){
            useSource = self.sources.allKeys[0];
        }
        if (useSource) {
            RZLog(RZLogInfo, @"Setting Source to %@ (%@)", self.sources[useSource], useSource);
            [[GCAppGlobal profile] setCurrentSource:useSource];
            [[GCAppGlobal profile] configSet:CONFIG_HEALTHKIT_SOURCE_CHECKED boolVal:true];
            saveSettings = true;
        }
    }
    if (saveSettings) {
        [GCAppGlobal saveSettings];
    }
    [self.delegate performSelectorOnMainThread:@selector(processDone:) withObject:self waitUntilDone:NO];
}

-(id<GCWebRequest>)nextReq{
    return nil;
}

#endif
@end
