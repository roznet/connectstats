//  MIT Licence
//
//  Created on 13/09/2014.
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

#import "GCFitBitActivitiesParser.h"
#import "GCActivity.h"
#import "GCActivitySummaryValue.h"
#import "GCService.h"
#import "GCActivity+Database.h"
// Running Id: 90009
// Biking  Id: 90001


@implementation GCFitBitActivitiesParser

+(GCFitBitActivitiesParser*)activitiesParser:(NSData*)input forDate:(NSDate*)date{
    GCFitBitActivitiesParser * rv = [[[GCFitBitActivitiesParser alloc] init] autorelease];
    if (rv) {
        rv.date = date;
        [rv parse:input];
    }
    return rv;
}

-(void)dealloc{
    [_date release];
    [_activity release];
    [super dealloc];
}

-(void)parse:(NSData*)data{

    NSError * e = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    if (!json) {
        RZLog(RZLogError, @"Failed to process json from %@", e.localizedDescription);
    }
    NSDictionary * summary = json[@"summary"];
    NSArray * distances = summary[@"distances"];
    NSDictionary * goals = json[@"goals"];

    GCActivity * activity = [[[GCActivity alloc] init] autorelease];
    activity.date = self.date;
    activity.activityType = GC_TYPE_DAY;
    activity.activityTypeDetail = [GCActivityType activityTypeForKey:GC_TYPE_DAY];

    NSDictionary * goalMap = @{
                               @"activeMinutes": @[ @"GoalSumDuration", @"minute"],
                               @"caloriesOut" :  @[ @"GoalSumEnergy",   @"kilocalorie"],
                               @"distance":      @[ @"GoalSumDistance", @"kilometer"],
                               @"steps":         @[ @"GoalSumStep",     @"step"]
                               };

    NSDictionary * summMap = @{
                               @"sedentaryMinutes":         @"", // 1293
                               @"veryActiveMinutes":        @[ @"SumDurationVeryActive", @"minute"], // 44
                               @"lightlyActiveMinutes":     @[ @"SumDurationLightlyActive", @"minute"], // 53
                               @"fairlyActiveMinutes":      @[ @"SumDurationModeratelyActive", @"minute"], // 50

                               @"activeScore":              @"", // -1

                               @"steps":                    @[ @"SumStep",  @"step" ], // 8847

                               @"caloriesBMR":              @"", // 1725
                               @"caloriesOut":              @[ @"SumEnergy", @"kilocalorie"], // 2307
                               @"activityCalories":         @[ @"SumEnergyActive", @"kilocalorie"], // 784
                               @"marginalCalories":         @"", // 564
                               };

    NSDictionary * distMap = @{
                               @"total":                    @[ @"SumDistance", @"kilometer" ], // 6.79
                               @"tracker":                  @"", // 6.79
                               @"loggedActivities":         @"", // 0
                               @"veryActive":               @[ @"SumDistanceVeryActive", @"kilometer"], // 3.89
                               @"moderatelyActive":         @[ @"SumDistanceModeratelyActive", @"kilometer"], // 2.26
                               @"lightlyActive":            @[ @"SumDistanceLightlyActive", @"kilometer"], // 0.61
                               @"sedentaryActive":          @"", // 0.03
                               };

/*
    HK_EXTERN NSString * const HKQuantityTypeIdentifierStepCount NS_AVAILABLE_IOS(8_0);                 // Scalar(Count),               Cumulative
    HK_EXTERN NSString * const HKQuantityTypeIdentifierDistanceWalkingRunning NS_AVAILABLE_IOS(8_0);    // Length,                      Cumulative
    HK_EXTERN NSString * const HKQuantityTypeIdentifierDistanceCycling NS_AVAILABLE_IOS(8_0);           // Length,                      Cumulative
    HK_EXTERN NSString * const HKQuantityTypeIdentifierBasalEnergyBurned NS_AVAILABLE_IOS(8_0);         // Energy,                      Cumulative
    HK_EXTERN NSString * const HKQuantityTypeIdentifierActiveEnergyBurned NS_AVAILABLE_IOS(8_0);        // Energy,                      Cumulative
    HK_EXTERN NSString * const HKQuantityTypeIdentifierFlightsClimbed NS_AVAILABLE_IOS(8_0);            // Scalar(Count),               Cumulative
    HK_EXTERN NSString * const HKQuantityTypeIdentifierNikeFuel NS_AVAILABLE_IOS(8_0);                  // Scalar(Count),               Cumulative
*/

    NSMutableDictionary * summaryData = [NSMutableDictionary dictionaryWithCapacity:10];
    NSMutableDictionary * metaData = [NSMutableDictionary dictionaryWithCapacity:10];

    activity.sumDuration = 0.;

    for (NSString * one in goals) {
        id val = goals[one];
        if ([val isKindOfClass:[NSNumber class]]) {
            NSNumber * value = val;
            NSArray * defs = goalMap[one];
            if (defs && [defs isKindOfClass:[NSArray class]]) {
                GCNumberWithUnit * nu = [GCNumberWithUnit numberWithUnitName:defs[1] andValue:value.doubleValue];
                summaryData[defs[0]] = [GCActivitySummaryValue activitySummaryValueForField:defs[0] value:nu];
            }
        }
    }

    for (NSString * one in summary) {
        id val = summary[one];
        if ([val isKindOfClass:[NSNumber class]]) {
            NSNumber * value = val;
            NSArray * defs = summMap[one];
            if (defs && [defs isKindOfClass:[NSArray class]]) {
                GCNumberWithUnit * nu = [GCNumberWithUnit numberWithUnitName:defs[1] andValue:value.doubleValue];
                if ([defs[0] hasPrefix:@"SumDuration"]) {
                    activity.flags |= gcFieldFlagSumDuration;
                    activity.sumDuration += [nu convertToUnitName:STOREUNIT_ELAPSED].value;
                }
                summaryData[defs[0]] = [GCActivitySummaryValue activitySummaryValueForField:defs[0] value:nu];
            }
        }
    }
    for (NSDictionary * one in distances) {
        NSNumber * val = one[@"distance"];
        NSString * key = one[@"activity"];

        if ([val isKindOfClass:[NSNumber class]] && [key isKindOfClass:[NSString class]]) {
            NSArray * defs = distMap[key];
            if (defs && [defs isKindOfClass:[NSArray class]]) {
                GCNumberWithUnit * nu = [GCNumberWithUnit numberWithUnitName:defs[1] andValue:val.doubleValue];
                if ([defs[0] isEqualToString:@"SumDistance"]) {
                    activity.sumDistance = [nu convertToUnitName:STOREUNIT_DISTANCE].value;
                    activity.flags |= gcFieldFlagSumDistance;
                    activity.distanceDisplayUom = nu.unit.key;
                }
                if ([defs[0] isEqualToString:@"SumStep"]) {
                    activity.flags |= gcFieldFlagCadence;
                }
                summaryData[defs[0]] = [GCActivitySummaryValue activitySummaryValueForField:defs[0] value:nu];
            }
        }
    }
    activity.activityId = [[GCService service:gcServiceFitBit] activityIdFromServiceId:[self.date YYYYMMDD]];
    activity.activityName = @"";
    activity.location = @"";
    activity.speedDisplayUom = @"kph";
    [activity setSummaryDataFromKeyDict:summaryData];
    [activity updateMetaData:metaData];
    activity.downloadMethod = gcDownloadMethodFitFile;
    if (activity.sumDistance > 0. || activity.sumDuration > 0.) {
        self.activity = activity;
    }
}

@end
