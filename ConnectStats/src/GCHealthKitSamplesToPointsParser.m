//  MIT Licence
//
//  Created on 06/06/2015.
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

#import "GCHealthKitSamplesToPointsParser.h"

#ifdef GC_USE_HEALTHKIT
#import <HealthKit/HealthKit.h>
#endif
#include "GCTrackPoint.h"
@import RZUtilsTouch;

double kGCTrackPointsMinimumSpeedMps = 0.3;

@interface GCHealthKitSamplesToPointsParser ()
@property (nonatomic,retain) NSArray * samples;
@property (nonatomic,retain) NSString * activityType;
@property (nonatomic,retain) HKSourceRevision * sourceRevision;
@end

@implementation GCHealthKitSamplesToPointsParser

+(instancetype)parserForSamples:(NSArray*)samples forActivityType:(NSString *)activityType andSource:(HKSourceRevision*)sourceRevision{
    GCHealthKitSamplesToPointsParser * rv = [[[GCHealthKitSamplesToPointsParser alloc] init] autorelease];
    if (rv) {
        rv.sourceRevision = sourceRevision;
        [rv parseSamples:samples forActivityType:activityType];
    }
    return rv;
}

-(void)dealloc{
    [_samples release];
    [_activityType release];
    [_points release];
    [_sourceRevision release];
    [super dealloc];
}

-(void)parseSamples:(NSArray*)samples forActivityType:(NSString*)activityType{
    self.samples  =samples;
    self.activityType = activityType;

#ifdef GC_USE_HEALTHKIT

    static NSDictionary * defs =nil;
    if (defs == nil) {
        defs =     @{
                     HKQuantityTypeIdentifierStepCount : @(gcFieldFlagSumStep),
                     HKQuantityTypeIdentifierDistanceWalkingRunning:@(gcFieldFlagSumDistance),
                     HKQuantityTypeIdentifierDistanceCycling:@(gcFieldFlagSumDistance),
                     HKQuantityTypeIdentifierHeartRate:@(gcFieldFlagWeightedMeanHeartRate)

                     };
        [defs retain];
    }

    NSMutableDictionary * trackpoints = [NSMutableDictionary dictionary];
    NSMutableArray * allpoints = [NSMutableArray array];

    NSMutableDictionary * quantityTypes = [NSMutableDictionary dictionary];

    for (HKQuantitySample * sample in self.samples) {
        NSMutableDictionary * forQuantity = quantityTypes[sample.quantityType];
        if( forQuantity == nil){
            quantityTypes[sample.quantityType] = [NSMutableDictionary dictionaryWithObject:@1 forKey:sample.sourceRevision];
        }else{
            NSNumber * count = forQuantity[sample.sourceRevision];
            if( count == nil){
                forQuantity[sample.sourceRevision] = @1;
            }else{
                forQuantity[sample.sourceRevision] = @(count.integerValue + 1);
            }
        }
    }

    NSMutableDictionary * useQuantityTypes = [NSMutableDictionary dictionary];
    for (HKQuantityType * type in quantityTypes) {
        NSDictionary * candidates = quantityTypes[type];

        if (candidates[self.sourceRevision]) {
            // if workout source exists -> use that
            useQuantityTypes[type] = self.sourceRevision;
        }else{
            //look for the one with most samples
            NSUInteger max = 0;

            for (HKSourceRevision * source in candidates) {
                NSNumber * count = candidates[source];
                if( count.integerValue > max){
                    max = count.integerValue;
                    useQuantityTypes[type] = source;
                }
            }
        }
    }
    for (HKQuantitySample * sample in self.samples) {
        BOOL useSample = [useQuantityTypes[sample.quantityType] isEqual:sample.sourceRevision];
        if (useSample) {
            NSMutableArray * pointsfordate = trackpoints[ sample.startDate ];
            GCTrackPoint * point = nil;
            if (pointsfordate == nil) {
                pointsfordate = [NSMutableArray array];
                trackpoints[ sample.startDate ] = pointsfordate;
            }
            double interval = [sample.endDate timeIntervalSinceDate:sample.startDate];

            for (GCTrackPoint * one in pointsfordate) {
                if (fabs(interval-one.elapsed)<1.e-4) {
                    point = one;
                    break;
                }
            }

            if (point == nil) {
                point = [[GCTrackPoint alloc] init];
                point.time = sample.startDate;
                interval = [sample.endDate timeIntervalSinceDate:sample.startDate];
                point.elapsed = interval;
                [allpoints addObject:point];
                [pointsfordate addObject:point];
                [point release];
            }
            NSNumber * fieldNum = defs[ sample.quantityType.identifier];
            if (fieldNum) {
                gcFieldFlag fieldFlag = fieldNum.intValue;
                GCField * field = [GCField fieldForFlag:fieldFlag andActivityType:self.activityType];
                GCUnit * unit = [GCTrackPoint unitForField:fieldFlag andActivityType:self.activityType ];
                GCNumberWithUnit * num = [GCNumberWithUnit numberWithUnit:unit andQuantity:sample.quantity];
                [point setNumberWithUnit:num forField:field inActivity:nil];
                point.trackFlags |= fieldFlag;
                self.trackFlags |= fieldFlag;
            }
        }
    }

    self.points = [allpoints sortedArrayUsingSelector:@selector(compareTime:)];
    [self postProcessPoints:self.points];
    self.points = [self mergeUnrealisticPoints:self.points forActivityType:activityType];

#endif
}

-(NSArray*)mergeUnrealisticPoints:(NSArray*)points forActivityType:(NSString*)activityType{
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:points.count];

    GCTrackPoint * last = nil;
    for (GCTrackPoint * point in points) {
        if (last) {
            // if not too much later
            if (fabs([point timeIntervalSince:last]-last.elapsed) < 10. ) {
                [last mergeWith:point];
            }else{
                [rv addObject:last];
                last = point;
            }
        }else{
            last = point;
        }

        if ([last realisticForActivityType:activityType]) {
            [rv addObject:last];
            last = nil;
        }
    }
    if (last) {
        [rv addObject:last];
    }

    return rv;
}

-(void)postProcessPoints:(NSArray*)points{
    self.points = points;

    double lastDistance = 0.;
    BOOL ascendingDistance = YES;
    for (GCTrackPoint * next in self.points) {
        if (next.distanceMeters < lastDistance) {
            ascendingDistance = NO;
            break;
        }
        lastDistance = next.distanceMeters;
    }

    GCTrackPoint * point = nil;
    GCUnit * mpsUnit = GCUnit.mps;
    GCField * speedField = [GCField fieldForFlag:gcFieldFlagWeightedMeanSpeed andActivityType:self.activityType];
    
    GCUnit * cadenceUnit = GCUnit.stepsPerMinute;
    GCField * cadenceField = [GCField fieldForFlag:gcFieldFlagCadence andActivityType:self.activityType];
    
    for (GCTrackPoint * next in self.points) {
        if (point) {
            BOOL hasDistance =(point.trackFlags & gcFieldFlagSumDistance) == gcFieldFlagSumDistance;
            BOOL hasSpeed    = (point.trackFlags & gcFieldFlagWeightedMeanSpeed) == gcFieldFlagWeightedMeanSpeed;
            BOOL hasSteps    =(point.trackFlags & gcFieldFlagCadence) == gcFieldFlagCadence;

            if (hasDistance) {
                if (ascendingDistance) {
                    point.distanceMeters = next.distanceMeters - point.distanceMeters;
                }
                if (! hasSpeed) {
                    double mps = point.distanceMeters/point.elapsed; // in m/s
                    if (mps > kGCTrackPointsMinimumSpeedMps) {
                        GCNumberWithUnit * speed = [GCNumberWithUnit numberWithUnit:mpsUnit andValue:mps];
                        [point setNumberWithUnit:speed forField:speedField inActivity:nil];
                        self.trackFlags |= gcFieldFlagWeightedMeanSpeed;
                        RZRelease(speed);
                    }
                }
            }
            if (hasSteps) {
                GCNumberWithUnit * cadence = [GCNumberWithUnit numberWithUnit:cadenceUnit andValue:point.cadence/point.elapsed * 60.];
                [point setNumberWithUnit:cadence forField:cadenceField inActivity:nil];
                self.trackFlags |= gcFieldFlagCadence;
                RZRelease(cadence);
            }
        }
        point = next;
    }

}
@end
