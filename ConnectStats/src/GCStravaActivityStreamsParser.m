//  MIT Licence
//
//  Created on 18/03/2014.
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

#import "GCStravaActivityStreamsParser.h"
#import "GCTrackPoint.h"

@implementation GCStravaActivityStreamsParser
+(GCStravaActivityStreamsParser*)activityStreamsParser:(NSData *)input{
    GCStravaActivityStreamsParser * rv = [[[GCStravaActivityStreamsParser alloc] init] autorelease];
    if (rv) {
        [rv parse:input];
    }
    return rv;
}

-(void)dealloc{
    [_points release];
    [super dealloc];
}

/*
 time:	integer seconds
 latlng:	floats [latitude, longitude]
 distance:	float meters
 altitude:	float meters
 velocity_smooth:	float meters per second
 heartrate:	integer BPM
 cadence:	integer RPM
 watts:	integer watts
 temp:	integer degrees Celsius
 moving:	boolean
 grade_smooth:	float percent
*/
-(void)parse:(NSData*)inputs{
    NSError * e = nil;
    NSArray *json = [NSJSONSerialization JSONObjectWithData:inputs options:NSJSONReadingMutableContainers error:&e];
    if ([json isKindOfClass:[NSArray class]] && json.count>0) {
        self.inError =false;
        NSUInteger n = [json[0][@"data"] count];
        NSMutableArray * trackpoints = [NSMutableArray arrayWithCapacity:n];
        for (NSUInteger i=0; i<n; i++) {
            GCTrackPoint * trackpoint = [[GCTrackPoint alloc] init];
            for (NSUInteger k=0; k<json.count; k++) {
                NSString * type = json[k][@"type"];
                id o = json[k][@"data"][i];
                if ([o isKindOfClass:[NSNumber class]]) {
                    NSNumber * val = o;
                    if ([type isEqualToString:@"time"]) {
                        trackpoint.elapsed = val.doubleValue;
                    }else if ([type isEqualToString:@"heartrate"]){
                        trackpoint.heartRateBpm=val.doubleValue;
                        trackpoint.trackFlags |= gcFieldFlagWeightedMeanHeartRate;
                    }else if ([type isEqualToString:@"distance"]){
                        trackpoint.distanceMeters=val.doubleValue;
                        trackpoint.trackFlags |= gcFieldFlagSumDistance;
                    }else if ([type isEqualToString:@"velocity_smooth"]){
                        trackpoint.speed = val.doubleValue;
                        trackpoint.trackFlags |= gcFieldFlagWeightedMeanSpeed;
                    }else if ([type isEqualToString:@"altitude"]){
                        trackpoint.altitude = val.doubleValue;
                        trackpoint.trackFlags |= gcFieldFlagAltitudeMeters;
                    }else if ([type isEqualToString:@"cadence"]){
                        trackpoint.cadence = val.doubleValue;
                        trackpoint.trackFlags |= gcFieldFlagCadence;
                    }else if ([type isEqualToString:@"watts"]){
                        trackpoint.power = val.doubleValue;
                        trackpoint.trackFlags |= gcFieldFlagPower;
                    }
                }else if ([o isKindOfClass:[NSArray class]]){
                    NSArray * ar = o;
                    if ([type isEqualToString:@"latlng"] && ar.count==2) {
                        trackpoint.latitudeDegrees = [ar[0] doubleValue];
                        trackpoint.longitudeDegrees= [ar[1] doubleValue];
                    }
                }
            }
            [trackpoints addObject:trackpoint];
            [trackpoint release];

        }
        self.points = trackpoints;
    }else{
        if ([json isKindOfClass:[NSDictionary class]]) {
            NSDictionary * dict = (NSDictionary*)json;
            if ([dict[@"message"] respondsToSelector:@selector(isEqualToString:)] &&
                [dict[@"message"] isEqualToString:@"Record Not Found"]) {
                self.points = @[];
            }else{
                RZLog(RZLogInfo, @"Got Dictionary %@", dict);
                self.inError =true;
            }

        }else{
            self.inError =true;
            RZLog(RZLogWarning, @"Failed to download stream got %@", e ?: NSStringFromClass([json class]));
        }
    }
}
@end
