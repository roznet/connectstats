//  MIT Licence
//
//  Created on 08/02/2013.
//
//  Copyright (c) 2013 Brice Rosenzweig.
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

#import "GCExportStrava.h"
#import "GCActivity+ExportText.h"

//https://stravasite-main.pbworks.com/w/page/51754311/v2%20upload%20create

@implementation GCExportStrava

+(NSDictionary*)exportActivity:(GCActivity*)activity forToken:(NSString*)token{

    NSMutableDictionary * dict = nil;
    if ([activity trackpointsReadyOrLoad]) {
        dict = [NSMutableDictionary dictionaryWithCapacity:10];
        NSArray * trackpoints = [activity trackpoints];
        NSMutableArray * fields = [NSMutableArray arrayWithObjects:@"time", @"latitude", @"longitude", nil];
        BOOL el  = [activity hasTrackField:gcFieldFlagAltitudeMeters];
        BOOL hr  = [activity hasTrackField:gcFieldFlagWeightedMeanHeartRate];
        BOOL cad = [activity hasTrackField:gcFieldFlagCadence];
        BOOL pow = [activity hasTrackField:gcFieldFlagPower];

        if (el) {
            [fields addObject:@"elevation"];
        }
        if (hr) {
            [fields addObject:@"heartrate"];
        }
        if (cad) {
            [fields addObject:@"cadence"];
        }
        if (pow) {
            [fields addObject:@"watts"];
        }
        NSMutableArray * points = [NSMutableArray arrayWithCapacity:trackpoints.count];
        for (GCTrackPoint * point in trackpoints) {
            if ([point validCoordinate]) {
                NSMutableArray * one = [NSMutableArray arrayWithObjects:[point.time formatAsRFC3339],
                                        @(point.latitudeDegrees),
                                        @(point.longitudeDegrees),
                                        nil];
                if (el) {
                    [one addObject:@(point.altitude)];
                }
                if (hr) {
                    [one addObject:@(point.heartRateBpm)];
                }
                if (cad) {
                    [one addObject:@(point.cadence)];
                }
                if (pow) {
                    [one addObject:@(point.power)];
                }
                [points addObject:one];
            }
        }
        dict[@"points"] = points;
        NSString * typestr = @"ride";
        if ([activity.activityType isEqualToString:GC_TYPE_RUNNING]) {
            typestr = @"run";
        }else if(![activity.activityType isEqualToString:GC_TYPE_CYCLING]){
            typestr = @"other";
        }
        dict[@"activity_type"] = typestr;
        dict[@"data_fields"] = fields;
        dict[@"type"] = @"json";
        dict[@"id"] = activity.activityId;
        dict[@"token"] = token;
        if ([activity.activityName isEqualToString:@"Untitled"]) {
            dict[@"activity_name"] = [activity exportTitle];
        }else{
            dict[@"activity_name"] = activity.activityName;
        }
    }
    return dict;
}

@end
