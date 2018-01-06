//  MIT Licence
//
//  Created on 24/05/2015.
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

#import "GCHealthKitWorkoutsRequest.h"
#import "GCAppGlobal.h"
#import "GCService.h"
#import "GCActivity+Import.h"
#import "GCHealthKitWorkoutParser.h"
#import "GCActivitiesOrganizer.h"

#ifdef GC_USE_HEALTHKIT
#import <HealthKit/HealthKit.h>
#endif


@interface GCHealthKitWorkoutsRequest ()

@property (nonatomic,retain) NSMutableDictionary * workoutSamples;
@property (nonatomic,retain) NSMutableArray * queryArgs;

@end

@implementation GCHealthKitWorkoutsRequest


-(void)dealloc{
    [_workoutSamples release];
    [_queryArgs release];

    [super dealloc];
}

#ifdef GC_USE_HEALTHKIT
-(NSArray*)readSampleTypes{
    return @[ [HKQuantityType workoutType]
              ];
}

-(NSString*)description{
    return [NSString stringWithFormat:@"Analysing Workouts"];
}

#pragma mark - Query HealthKit

-(void)nextWorkoutSamples{

    if (self.workoutSamples == nil) {
        self.workoutSamples = [NSMutableDictionary dictionary];
    }
    if (self.queryArgs.count == 0) {
        [self saveCollectedData:@{@"r":self.results,@"s":self.workoutSamples} withSuffix:@"workout" andId:@"0"];
        dispatch_async([GCAppGlobal worker],^(){
            [self parseWorkouts];
        });
        return;
    }
    NSDictionary * next = (self.queryArgs).lastObject;


    HKWorkout * theOne = next[@"w"];
    HKQuantityType * type = next[@"t"];

    //NSPredicate * workoutPredicate = [HKQuery predicateForObjectsFromWorkout:theOne];
    NSPredicate * workoutPredicate = [HKQuery predicateForSamplesWithStartDate:theOne.startDate
                                                         endDate:theOne.endDate
                                                         options:HKQueryOptionNone];

    NSSortDescriptor *startDateSort =
    [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate
                                  ascending:YES];

    HKSampleQuery *query = [[HKSampleQuery alloc]
                            initWithSampleType:type
                            predicate:workoutPredicate
                            limit:0
                            sortDescriptors:@[startDateSort]
                            resultsHandler:^(HKSampleQuery *thequery, NSArray *results, NSError *error) {
                                if (results == nil) {
                                    RZLog(RZLogError, @"Query Error for %@: %@", type, error.localizedDescription);
                                }else{
                                    NSArray * current= self.workoutSamples[theOne.UUID.UUIDString];
                                    if (current) {
                                        self.workoutSamples[theOne.UUID.UUIDString] = [current arrayByAddingObjectsFromArray:results];
                                    }else{
                                        self.workoutSamples[theOne.UUID.UUIDString] = results;
                                    }
                                }
                                [self.queryArgs removeLastObject];
                                [self performSelectorOnMainThread:@selector(nextWorkoutSamples) withObject:nil waitUntilDone:NO];
                            }];


    [self.healthStore executeQuery:query];
    [query release];

}

/*
-(NSUInteger)anchor{
    return HKAnchoredObjectQueryNoAnchor;
}
*/

-(void)processResults{
    HKQuantityType * qt = [self currentQuantityType];
    if (!self.data) {
        self.data = [NSMutableDictionary dictionary];
    }
    self.data[qt.identifier] = self.results;
    if ([self isLastRequest]) {
        [self.delegate loginSuccess:gcWebServiceHealthStore];
        NSArray * types =   @[
                              [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
                              [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning],
                              [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling],
                              [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned],
                              [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate]
                              ];
        NSMutableArray * todo = [NSMutableArray array];
        for (HKWorkout * one in self.results) {
            for (HKQuantityType * type in types) {
                [todo addObject:@{ @"w": one, @"t" : type }];
            }
        }
        self.queryArgs = todo;

        [self nextWorkoutSamples];
    }else{
        [self.delegate processDone:self];
    }

}

#pragma mark - Parse

-(void)parseWorkouts{

    GCHealthKitWorkoutParser * parser = [GCHealthKitWorkoutParser parserWithWorkouts:self.results andSamples:self.workoutSamples];
    if (self.results.count > 0) {
        NSString * fn = [RZFileOrganizer writeableFilePath:@"last_workout_parser.data"];
        [NSKeyedArchiver archiveRootObject:parser toFile:fn];
    }

    [parser parse:^(GCActivity *act, NSString*aId){
        [[GCAppGlobal organizer] registerActivity:act forActivityId:aId];
    }];

    [self.delegate performSelectorOnMainThread:@selector(processDone:) withObject:self waitUntilDone:NO];
}



#endif

@end
