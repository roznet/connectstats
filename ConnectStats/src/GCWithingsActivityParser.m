//  MIT Licence
//
//  Created on 10/10/2014.
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

#import "GCWithingsActivityParser.h"
#import "GCActivity.h"
#import "GCActivitySummaryValue.h"
#import "GCService.h"
#import "GCActivity+Database.h"

@implementation GCWithingsActivityParser

+(GCWithingsActivityParser*)activitiesParser:(NSData*)input{
    GCWithingsActivityParser * rv = [[[GCWithingsActivityParser alloc] init] autorelease];
    if (rv) {
        [rv parse:input];
    }
    return rv;
}

-(void)dealloc{
    [_activities release];
    [super dealloc];
}

-(void)parse:(NSData*)data{

    NSError * e = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    if (!json) {
        RZLog(RZLogError, @"Failed to process json %@", e.localizedDescription);
    }
    NSDictionary * body = json[@"body"];
    NSArray * inputs = body[@"activities"];



    NSDictionary * summMap = @{
                               @"distance":         @[ @"SumDistance", @"meter" ], // 6.79
                               @"steps":            @[ @"SumStep",  @"step" ], // 8847
                               @"calories":         @[ @"SumEnergy", @"kilocalorie"], // 2307
                               @"intense":          @[ @"SumDurationVeryActive", @"second"], // 44
                               @"soft":             @[ @"SumDurationLightlyActive", @"second"], // 53
                               @"moderate":         @[ @"SumDurationModeratelyActive", @"second"], // 50
                               };

    /*
     {
     "date" : "2014-09-25",
     "steps" : 15080,
     "distance" : 15715.03,
     "calories" : 1448,
     "elevation" : 0,
     "soft" : 6600,
     "moderate" : 1380,
     "intense" : 3240,
     "timezone" : "Europe/London"
     }
     HK_EXTERN NSString * const HKQuantityTypeIdentifierStepCount NS_AVAILABLE_IOS(8_0);                 // Scalar(Count),               Cumulative
     HK_EXTERN NSString * const HKQuantityTypeIdentifierDistanceWalkingRunning NS_AVAILABLE_IOS(8_0);    // Length,                      Cumulative
     HK_EXTERN NSString * const HKQuantityTypeIdentifierDistanceCycling NS_AVAILABLE_IOS(8_0);           // Length,                      Cumulative
     HK_EXTERN NSString * const HKQuantityTypeIdentifierBasalEnergyBurned NS_AVAILABLE_IOS(8_0);         // Energy,                      Cumulative
     HK_EXTERN NSString * const HKQuantityTypeIdentifierActiveEnergyBurned NS_AVAILABLE_IOS(8_0);        // Energy,                      Cumulative
     HK_EXTERN NSString * const HKQuantityTypeIdentifierFlightsClimbed NS_AVAILABLE_IOS(8_0);            // Scalar(Count),               Cumulative
     HK_EXTERN NSString * const HKQuantityTypeIdentifierNikeFuel NS_AVAILABLE_IOS(8_0);                  // Scalar(Count),               Cumulative
     */

    NSMutableArray * parsed = [NSMutableArray arrayWithCapacity:inputs.count];
    for (NSDictionary * input in inputs) {
        GCActivity * activity = [[GCActivity alloc] init];
        activity.date = [NSDate dateForDashedDate:input[@"date"]];
        activity.activityType = GC_TYPE_DAY;
        activity.activityTypeDetail = [GCActivityType activityTypeForKey:GC_TYPE_DAY];

        NSMutableDictionary * summaryData = [NSMutableDictionary dictionaryWithCapacity:10];
        NSMutableDictionary * metaData = [NSMutableDictionary dictionaryWithCapacity:10];

        activity.sumDuration = 0.;


        for (NSString * key in input) {
            id val = input[key];
            if ([val isKindOfClass:[NSNumber class]]) {
                NSNumber * value = val;
                NSArray * defs = summMap[key];
                if (defs && [defs isKindOfClass:[NSArray class]]) {
                    GCNumberWithUnit * nu = [GCNumberWithUnit numberWithUnitName:defs[1] andValue:value.doubleValue];
                    if ([defs[0] hasPrefix:@"SumDuration"]) {
                        activity.flags |= gcFieldFlagSumDuration;
                        activity.sumDuration += [nu convertToUnitName:STOREUNIT_ELAPSED].value;
                    }
                    if ([defs[0] hasPrefix:@"SumDistance"]) {
                        activity.flags |= gcFieldFlagSumDistance    ;
                        activity.sumDistance += [nu convertToUnitName:STOREUNIT_DISTANCE].value;
                    }
                    summaryData[defs[0]] = [GCActivitySummaryValue activitySummaryValueForField:defs[0] value:nu];
                }
            }
        }
        activity.activityId = [[GCService service:gcServiceWithings] activityIdFromServiceId:[activity.date YYYYMMDD]];
        activity.activityName = @"";
        activity.location = @"";
        activity.distanceDisplayUom = @"kilometer";
        activity.speedDisplayUom = @"kph";
        [activity setSummaryDataFromKeyDict:summaryData];
        [activity updateMetaData:metaData];
        activity.downloadMethod = gcDownloadMethodFitFile;
        if (activity.sumDistance > 0. || activity.sumDuration > 0.) {
            [parsed addObject:activity];
        }
        [activity release];

    }
    self.activities = parsed;
}

@end
