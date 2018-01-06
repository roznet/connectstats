//  MIT Licence
//
//  Created on 26/09/2014.
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

#import "GCHealthKitActivityParser.h"
#import <HealthKit/HealthKit.h>
#import "GCFields.h"
#import "GCAppGlobal.h"
#import "GCActivity.h"
#import "GCService.h"
#import "GCHealthKitRequest.h"
#import "GCActivity+Fields.h"
#import "RZUtilsHealthkit/RZUtilsHealthkit.h"

@interface GCHealthKitActivityParser ()
@property (nonatomic,retain) NSDictionary * data;
@property (nonatomic,retain) GCActivitiesOrganizer * organizer;
@end

@implementation GCHealthKitActivityParser

-(void)dealloc{
    [_data release];
    [_organizer release];
    [_activities release];
    [super dealloc];
}

+(GCHealthKitActivityParser*)healthKitActivityParserWith:(NSDictionary*)data andOrganizer:(GCActivitiesOrganizer*)organizer{
    GCHealthKitActivityParser * rv = [[[GCHealthKitActivityParser alloc] init] autorelease];
    if (rv) {
        rv.organizer = organizer;
        rv.data = data;
        [rv parse];
    }
    return rv;
}

-(void)parse{
    NSArray * types = (self.data).allKeys;
    NSMutableDictionary * organized = [NSMutableDictionary dictionaryWithCapacity:10];
    for (NSString * identifier in types) {
        gcFieldFlag flag = gcFieldFlagNone;
        if ([identifier isEqualToString:HKQuantityTypeIdentifierDistanceWalkingRunning]) {
            flag = gcFieldFlagSumDistance;
        }else if ([identifier isEqualToString:HKQuantityTypeIdentifierStepCount]){
            flag = gcFieldFlagCadence;
        }else if ([identifier isEqualToString:HKQuantityTypeIdentifierFlightsClimbed]){
            flag = gcFieldFlagAltitudeMeters;
        }
        NSArray * results = self.data[identifier];
        BOOL incompatibleElapsed = false;
        if (results) {
            for (HKQuantitySample * qs in results) {
                NSDate * start = qs.startDate;
                NSTimeInterval elapsed = [qs.endDate timeIntervalSinceDate:start];
                NSString * key = [[GCService service:gcServiceHealthKit] activityIdFromServiceId:[GCHealthKitRequest dayActivityId:start]];
                NSMutableDictionary * points = organized[key];
                if (points == nil) {
                    points = [NSMutableDictionary dictionaryWithCapacity:10];
                    if (self.organizer) {
                        GCActivity * existing = [self.organizer activityForId:key];
                        if (existing) {
                            NSArray * trackpoints = [existing trackpoints];
                            for (GCTrackPoint * point in trackpoints) {
                                points[point.time]=point;
                            }
                        }
                    }

                    organized[key] = points;
                }
                GCTrackPoint * point = points[start];
                if (point == nil) {
                    point = [[[GCTrackPoint alloc] init] autorelease];
                    point.elapsed = elapsed;
                    point.time = start;
                    points[start] = point;
                }
                if (fabs(point.elapsed-elapsed)>1.e-5) {
                    incompatibleElapsed = true;
                }
                point.trackFlags |= flag;
                GCUnit * convert = [GCUnit unitForKey:flag==gcFieldFlagSumDistance?STOREUNIT_DISTANCE:@"dimensionless"];
                GCNumberWithUnit * nu = [GCNumberWithUnit numberWithUnit:convert andQuantity:qs.quantity];
                [point setValue:nu.value forField:flag];
            }
        }
        if (incompatibleElapsed) {
            RZLog(RZLogWarning, @"inconsistent elapsed");
        }
    }
    for (NSString * key in organized) {
        NSArray * points = [[organized[key] allValues] sortedArrayUsingSelector:@selector(compareTime:)];
        if (points.count>0) {
            GCActivity * activity = [[[GCActivity alloc] init] autorelease];
            activity.date = [points[0] time];
            double sumSteps = 0.;
            double sumFloors =0.;
            for (GCTrackPoint * point in points) {
                if (point.elapsed>0) {
                    point.speed = point.distanceMeters/point.elapsed;
                }
                activity.sumDistance +=point.distanceMeters;
                activity.sumDuration +=point.elapsed;
                activity.flags |= point.trackFlags;
                activity.trackFlags |= point.trackFlags;
                sumFloors += point.altitude;
                sumSteps  += point.cadence;
            }

            activity.activityId = key;
            activity.activityType = GC_TYPE_DAY;
            activity.activityTypeDetail = GC_TYPE_DAY;
            activity.activityName = @"";
            activity.downloadMethod = gcDownloadMethodHealthKit;
            activity.location = @"";
            activity.speedDisplayUom = @"kph";
            activity.distanceDisplayUom = @"kilometer";
            activity.summaryData = @{
                                     @"SumDistance":[GCActivitySummaryValue activitySummaryValueForField:@"SumDistance" value:[activity numberWithUnitForFieldFlag:gcFieldFlagSumDistance]],
                                     @"SumDuration":[GCActivitySummaryValue activitySummaryValueForField:@"SumDuration" value:[activity numberWithUnitForFieldFlag:gcFieldFlagSumDuration]],
                                     @"SumStep":[GCActivitySummaryValue activitySummaryValueForField:@"SumStep" value:[GCNumberWithUnit numberWithUnitName:@"step" andValue:sumSteps]],
                                     @"SumFloorClimbed":[GCActivitySummaryValue activitySummaryValueForField:@"SumFloorClimbed" value:[GCNumberWithUnit numberWithUnitName:@"step" andValue:sumFloors]],

                                     };
            activity.metaData = [NSMutableDictionary dictionary];
            if (self.organizer) {
                [self.organizer registerActivity:activity forActivityId:activity.activityId];
                [activity saveTrackpoints:points andLaps:@[]];
            }else{

            }
        }
    }

}

@end
