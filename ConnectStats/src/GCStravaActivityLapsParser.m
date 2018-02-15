//  MIT Licence
//
//  Created on 13/05/2014.
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

#import "GCStravaActivityLapsParser.h"
#import "GCFields.h"
#import "GCLap.h"
#import "GCActivity.h"

@implementation GCStravaActivityLapsParser
+(GCStravaActivityLapsParser*)activityLapsParser:(NSData*)input withPoints:(NSArray*)points inActivity:(GCActivity*)act{
    GCStravaActivityLapsParser * rv = [[[GCStravaActivityLapsParser alloc] init] autorelease];
    if (rv) {
        [rv parse:input withPoints:(NSArray*)points inActivity:act];
    }
    return rv;

}
-(void)dealloc{
    [_laps release];
    [super dealloc];
}
/*
 {
 "id" : 532975015,
 "resource_state" : 2,
 "name" : "Lap 1",
 "activity" : {
 "id" : 140735593
 },
 "athlete" : {
 "id" : 1656888
 },
 "elapsed_time" : 816,
 "moving_time" : 816,
 "start_date" : "2014-05-13T18:11:17Z",
 "start_date_local" : "2014-05-13T19:11:17Z",
 "distance" : 3000,
 "start_index" : 0,
 "end_index" : 282,
 "total_elevation_gain" : 12.4,
 "average_speed" : 3.7,
 "max_speed" : 7.8,
 "average_cadence" : 62.4,
 "average_watts" : 73.4,
 "average_heartrate" : 104.6,
 "max_heartrate" : 136,
 "lap_index" : 1
 }
 */
-(void)parse:(NSData*)inputs withPoints:(NSArray*)points inActivity:(GCActivity*)act{
    BOOL saveBadJson = false;
    NSError * e = nil;
    NSArray *json = [NSJSONSerialization JSONObjectWithData:inputs options:NSJSONReadingMutableContainers error:&e];
    static NSDictionary * defs = nil;
    if (defs == nil) {
        defs =@{ @"elapsed_time" :          @[ @"SumDuration",          @"second",  @(gcFieldFlagSumDuration)],
                 @"moving_time" :           @[ @"SumMovingDuration",    @"second",  @(gcFieldFlagNone)],
                 @"distance" :              @[ @"SumDistance",          @"meter",   @(gcFieldFlagSumDistance) ],
                 @"total_elevation_gain" :  @[ @"GainElevation",        @"meter",   @(gcFieldFlagNone)],
                 @"average_speed" :         @[ @"WeightedMeanSpeed",    @"mps",     @(gcFieldFlagWeightedMeanSpeed)],
                 @"max_speed" :             @[ @"MaxSpeed",             @"mps",     @(gcFieldFlagNone)],
                 @"average_cadence" :       @[ @"",                     @"",        @(gcFieldFlagCadence)],
                 @"average_watts" :         @[ @"WeightedMeanPower",    @"watt",    @(gcFieldFlagPower)],
                 @"average_heartrate" :     @[ @"WeightedMeanHeartRate",@"bpm",     @(gcFieldFlagWeightedMeanHeartRate)],
                 @"max_heartrate" :         @[ @"MaxHeartRate",         @"bpm",     @(gcFieldFlagNone)]
                 };
        [defs retain];
    }
    if ([json isKindOfClass:[NSArray class]] && json.count>0) {
        //@"start_date" : "2014-05-13T18:11:17Z",
        //@"start_date_local" : "2014-05-13T19:11:17Z",
        //@"start_index" : 0,
        //@"end_index" : 282,
        NSMutableArray * ar = [NSMutableArray arrayWithCapacity:json.count];
        for (id one in json) {
            if ([one isKindOfClass:[NSDictionary class]]) {
                NSDictionary * lapinfo = one;

                GCLap * lap = [[GCLap alloc] init];
                
                for (NSString * key in defs) {
                    id value = lapinfo[key];
                    NSArray * subdefs = defs[key];
                    if (value && [value respondsToSelector:@selector(doubleValue)]) {
                        double dval = [value doubleValue];
                        gcFieldFlag flag = [subdefs[2] intValue];
                        NSString * uom = subdefs[1];
                        GCField * field = (flag == gcFieldFlagNone) ? [GCField fieldForKey:subdefs[0] andActivityType:act.activityType] :
                            [GCField fieldForFlag:flag andActivityType:act.activityType];

                        GCNumberWithUnit * num = [GCNumberWithUnit numberWithUnitName:uom andValue:dval];
                        [lap setExtraValue:num forFieldKey:field in:act];
                    }
                }

                if (lapinfo[@"start_date"] && [lapinfo[@"start_date"] isKindOfClass:[NSString class]]) {
                    NSDate * start_date = [NSDate dateForStravaTimeString:lapinfo[@"start_date"]];
                    lap.time = start_date;
                }
                if (!lap.time) {
                    RZLog( RZLogError, @"Failed to parse strava date %@", lapinfo[@"start_date"]);
                    saveBadJson=true;
                }

                if (lapinfo[@"start_index"]) {
                    NSUInteger index = [lapinfo[@"start_index"] integerValue];
                    if (index < points.count) {
                        GCTrackPoint * point = points[index];
                        lap.longitudeDegrees = point.longitudeDegrees;
                        lap.latitudeDegrees = point.latitudeDegrees;
                    }
                }
                
                [ar addObject:lap];
                [lap release];
            }else{
                RZLog(RZLogError, @"Failed to parse strava lap");
                saveBadJson= true;
            }
        }
        self.laps = ar;
    }
    if (![json isKindOfClass:[NSArray class]]) {
        RZLog( RZLogError, @"Failed to parse strava laps %@", e?:NSStringFromClass([json class]));
        saveBadJson=true;
    }
    if (saveBadJson) {
        NSString * fn = @"error_strava_laps.json";
        [inputs writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true];
    }

}
@end
