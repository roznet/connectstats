//  MIT Licence
//
//  Created on 21/08/2014.
//
//  Copyright (c) 2014 Brice Rosenzweig.
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

#import "GCHealthKitExportActivity.h"
#ifdef GC_USE_HEALTHKIT
#import <HealthKit/HealthKit.h>
#import "RZUtilsHealthkit/RZUtilsHealthkit.h"
#endif
#import "GCAppGlobal.h"
#import "GCService.h"
#import "GCActivity+Fields.h"

@interface GCHealthKitExportActivity ()
@property (nonatomic,retain) GCActivity * activity;
@end


@implementation GCHealthKitExportActivity
-(void)dealloc{
    [_activity release];
    [super dealloc];
}
+(GCHealthKitExportActivity*)healthKitExportActivity:(GCActivity*)act{
    if (act.activityId && [[GCService service:gcServiceHealthKit] lastSync:act.activityId]) {
        return nil;
    }
    GCHealthKitExportActivity * rv = [[[GCHealthKitExportActivity alloc] init] autorelease];
    if (rv) {
        rv.activity = act;
    }
    return rv;
}

-(NSString*)description{
    return [NSString stringWithFormat:@"Saving %@ to Health App", self.activity.activityId];
}

-(NSSet*)dataTypesToWrite{
    return [NSSet setWithArray:@[
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned],
                                 [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate],
                                 [HKQuantityType workoutType]

              ]];
}

-(void)executeQuery{
    HKWorkoutActivityType type = HKWorkoutActivityTypeRunning;
    GCActivity * act = self.activity;
    if ([act.activityType isEqualToString:GC_TYPE_RUNNING]) {
        type =HKWorkoutActivityTypeRunning;
    }else if ([act.activityType isEqualToString:GC_TYPE_CYCLING]){
        type = HKWorkoutActivityTypeCycling;
    }else{
        RZLog(RZLogWarning, @"Unsupported activity type %@", act );
        [self processDone];
    }

    GCNumberWithUnit * dist = [act numberWithUnitForFieldKey:@"SumDistance"];
    GCNumberWithUnit * cal  = [act numberWithUnitForFieldKey:@"SumEnergy"];



    HKWorkout * workout = [HKWorkout workoutWithActivityType:type
                                                   startDate:act.date
                                                     endDate:act.endTime
                                                    duration:[act.endTime timeIntervalSinceDate:act.startTime]
                                           totalEnergyBurned:[cal hkQuantity]
                                               totalDistance:[dist hkQuantity]
                                                    metadata:@{@"activityId":act.activityId,@"activityName":act.activityName }];
    [self.healthStore saveObject:workout withCompletion:^(BOOL success, NSError * error){
        if (success) {
            HKQuantityType * disttype = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
            if (type == HKWorkoutActivityTypeCycling) {
                disttype = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling];
            }
            HKQuantityType * hrtype   = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
            NSMutableArray * samples = [NSMutableArray array];
            GCTrackPoint * point = nil;
            for (GCTrackPoint * next in act.trackpoints) {
                if (point) {
                    GCNumberWithUnit * hrnu = [point numberWithUnitForField:gcFieldFlagWeightedMeanHeartRate andActivityType:act.activityType];
                    CLLocationDistance meters = [point distanceMetersFrom:next];

                    HKQuantity * diq = [HKQuantity quantityWithUnit:[HKUnit meterUnit] doubleValue:meters];

                    HKQuantitySample * diqu = [HKQuantitySample quantitySampleWithType:disttype
                                                                              quantity:diq
                                                                             startDate:point.time
                                                                               endDate:next.time];
                    [samples addObject:diqu];
                    if (hrnu) {
                        HKQuantitySample * hrqu = [HKQuantitySample quantitySampleWithType:hrtype
                                                                                  quantity:[hrnu hkQuantity]
                                                                                 startDate:point.time
                                                                                   endDate:next.time];
                        [samples addObject:hrqu];
                    }

                }
                point = next;
            }
            [self.healthStore addSamples:samples toWorkout:workout completion:^(BOOL success2, NSError * error2){
                if (success2) {
                    RZLog(RZLogInfo, @"Saved %d samples for %@", (int)samples.count, act);
                    [[GCService service:gcServiceHealthKit] recordSync:act.activityId];
                }else{
                    RZLog(RZLogError, @"Error saving Workout %@ for %@", error2, act);
                }
                [self processDone];
            }];
        }else{
            RZLog(RZLogError, @"Error saving Workout %@", error);
            [self processDone];
        }
    }];

}
@end
