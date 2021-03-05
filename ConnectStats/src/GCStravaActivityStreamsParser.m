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
#import "GCActivity.h"
#import "GCTrackPoint.h"

@interface GCStravaActivityStreamsParser ()
@property (nonatomic,retain) GCActivity * activity;

@end

@implementation GCStravaActivityStreamsParser

+(GCStravaActivityStreamsParser*)activityStreamsParser:(NSData *)input inActivity:(GCActivity*)act{
    GCStravaActivityStreamsParser * rv = [[[GCStravaActivityStreamsParser alloc] init] autorelease];
    if (rv) {
        rv.activity = act;
        [rv parse:input];
    }
    return rv;
}

-(void)dealloc{
    [_activity release];
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
        self.status = GCWebStatusOK;
        NSUInteger n = [json[0][@"data"] count];
        NSMutableArray * trackpoints = [NSMutableArray arrayWithCapacity:n];
        
        NSDictionary * defs = @{ @"heartrate" : @[ [GCField fieldForFlag:gcFieldFlagWeightedMeanHeartRate andActivityType:self.activity.activityType], GCUnit.bpm ],
                                 @"distance" : @[ [GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:self.activity.activityType], GCUnit.meter ],
                                 @"velocity_smooth" : @[ [GCField fieldForFlag:gcFieldFlagWeightedMeanSpeed andActivityType:self.activity.activityType], GCUnit.mps ],
                                 @"altitude" : @[ [GCField fieldForFlag:gcFieldFlagAltitudeMeters andActivityType:self.activity.activityType], GCUnit.meter ],
                                 @"cadence" : @[ [GCField fieldForFlag:gcFieldFlagCadence andActivityType:self.activity.activityType], GCUnit.stepsPerMinute ],
                                 @"watts" : @[ [GCField fieldForFlag:gcFieldFlagPower andActivityType:self.activity.activityType], GCUnit.watt ],
        };
        
        for (NSUInteger i=0; i<n; i++) {
            GCTrackPoint * trackpoint = [[GCTrackPoint alloc] init];
            for (NSUInteger k=0; k<json.count; k++) {
                NSString * type = json[k][@"type"];
                id o = json[k][@"data"][i];
                if ([o isKindOfClass:[NSNumber class]]) {
                    NSNumber * val = o;
                    if ([type isEqualToString:@"time"]) {
                        trackpoint.elapsed = val.doubleValue;
                    }else{
                        NSArray * def = defs[type];
                        if( def ){
                            GCField * field= def[0];
                            GCUnit * unit = def[1];
                            GCNumberWithUnit * nu = [[GCNumberWithUnit alloc] initWithUnit:unit andValue:val.doubleValue];
                            [trackpoint setNumberWithUnit:nu forField:field inActivity:self.activity];
                            RZRelease(nu);
                        }
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
                ([dict[@"message"] isEqualToString:@"Record Not Found"] ||
                 [dict[@"message"] isEqualToString:@"Resource Not Found"])) {
                self.points = @[];
            }else{
                RZLog(RZLogInfo, @"Got Dictionary %@", dict);
                self.status = GCWebStatusParsingFailed;
            }

        }else{
            self.status = GCWebStatusParsingFailed;
            RZLog(RZLogWarning, @"Failed to download stream got %@", e ?: NSStringFromClass([json class]));
        }
    }
}
@end
