//  MIT Licence
//
//  Created on 19/10/2012.
//
//  Copyright (c) 2012 Brice Rosenzweig.
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

#import "GCLap.h"
#import "GCFields.h"
#import "GCAppGlobal.h"
#import "GCActivity+Import.h"
#import "GCActivitySummaryValue.h"

@implementation GCLap
@synthesize extra;

-(void)dealloc{
    [extra release];
    [_label release];

    [super dealloc];
}

-(instancetype)init{
    return [super init];
}

//NEWTRACKFIELD
-(GCLap*)initWithLap:(GCLap*)other{
    self = [super init];
    if (self) {
        self.time = other.time;
        self.latitudeDegrees = other.latitudeDegrees;
        self.longitudeDegrees = other.longitudeDegrees;
        self.distanceMeters = other.distanceMeters;
        self.elapsed = other.elapsed;
        self.speed = other.speed;
        self.heartRateBpm = other.heartRateBpm;
        self.cadence = other.cadence;
        self.power = other.power;
        self.groundContactTime = other.groundContactTime;
        self.verticalOscillation = other.verticalOscillation;
        self.extra = [NSMutableDictionary dictionaryWithDictionary:other.extra];
    }
    return self;
}

//NEWTRACKFIELD
-(GCLap*)initWithTrackPoint:(GCTrackPoint*)other{
    self = [super init];
    if (self) {
        self.time = other.time;
        self.latitudeDegrees = other.latitudeDegrees;
        self.longitudeDegrees = other.longitudeDegrees;
        self.altitude = other.altitude;

        self.distanceMeters = 0.;
        self.elapsed = 0.;

        self.speed = other.speed;
        self.heartRateBpm = other.heartRateBpm;
        self.cadence = other.cadence;
        self.power = other.power;
        self.verticalOscillation = other.verticalOscillation;
        self.groundContactTime = other.groundContactTime;

        if (other.fieldValues) {
            self.fieldValues = calloc(sizeof(double), kMaxExtraIndex);
            for (size_t i=0; i<kMaxExtraIndex; i++) {
                self.fieldValues[i] = other.fieldValues[i];
            }
        }

        [self setExtra:nil];
    }
    return self;
}

-(GCLap*)initWithDictionary:(NSDictionary*)data forActivity:(GCActivity *)act{
    self = [super init];
    if (self) {
        if (data[@"startTimeGMT"]){
            [self parseModernDict:data inActivity:act];
        }else if (data[@"StartTime"]) {
            [self parseOldDict:data withActivityType:act.activityType];
        }else{
            [self parseDict:data inActivity:act];
        }
    }
    return self;
}
-(GCLap*)initWithResultSet:(FMResultSet*)res{
    return [super initWithResultSet:res];;
}

-(NSString*)displayLabel{
    return self.label ?: [NSString stringWithFormat:NSLocalizedString(@"Lap %d", @"Lap Annotation Callout"), self.lapIndex];
}

#pragma mark - Parsing


-(void)parseOldDict:(NSDictionary*)data withActivityType:(NSString*)atype{
    self.time = [NSDate dateForRFC3339DateTimeString:data[@"StartTime"]];
    NSString * tmp = nil;
    self.latitudeDegrees = 0.0;
    self.longitudeDegrees = 0.0;

    tmp = data[@"DistanceMeters"];
    self.distanceMeters = tmp ? tmp.doubleValue : 0.0;
    if (tmp) {
        self.trackFlags |= gcFieldFlagSumDistance;
    }
    tmp = data[@"AverageHeartRateBpm"];
    self.heartRateBpm = tmp ? [tmp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].doubleValue : 0.0;
    if (tmp) {
        self.trackFlags |= gcFieldFlagWeightedMeanHeartRate;
    }
    tmp = data[@"AvgSpeed"];
    self.speed = tmp ? tmp.doubleValue : 0.0;
    if (tmp) {
        self.trackFlags |= gcFieldFlagWeightedMeanSpeed;
    }
    tmp = data[@"Cadence"];
    if (!tmp) {
        tmp = data[@"RunCadence"];
        if (!tmp) {
            tmp = data[@"AvgRunCadence"];
        }
    }
    self.cadence = tmp ? tmp.doubleValue : 0.0;
    if (tmp) {
        self.trackFlags |= gcFieldFlagCadence;
    }
    tmp = data[@"AvgWatts"];
    self.power = tmp ? tmp.doubleValue : 0.0;
    if (tmp) {
        self.trackFlags |= gcFieldFlagPower;
    }

    self.extra = [NSMutableDictionary dictionaryWithCapacity:data.count];

    for (NSString * field in data) {
        if (![field isEqualToString:@"DistanceMeters"] &&
            ![field isEqualToString:@"AverageHeartRateBpm"] &&
            ![field isEqualToString:@"AvgSpeed"] &&
            ![field isEqualToString:@"Cadence"] &&
            ![field isEqualToString:@"RunCadence"] &&
            ![field isEqualToString:@"AvgRunCadence"] &&
            ![field isEqualToString:@"AvgWatts"] &&
            ![field isEqualToString:@"StartTime"]) {
            id obj = data[field];

            NSString *usefield = [GCFields fieldForLapField:field andActivityType:atype];
            GCUnit * unit = [GCFields unitForLapField:field activityType:atype];
            double value = 0.;

            if([obj isMemberOfClass:[NSNumber class]]){
                value = [obj doubleValue];
            }else{
                NSString * s = [obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                value = s.doubleValue;
            }
            extra[usefield] = [GCNumberWithUnit numberWithUnit:unit andValue:value];

        }
    }
    GCNumberWithUnit * dur = extra[@"TotalTimeSecond"];
    if (!dur) {
        dur = extra[@"SumDuration"];
    }
    if (dur) {
        self.elapsed = dur.value;
    }
}

-(void)parseModernDict:(NSDictionary*)data inActivity:(GCActivity*)act{

    NSMutableDictionary * summary = [act buildSummaryDataFromGarminModernData:data];
    self.extra = [NSMutableDictionary dictionary];
    for (NSString * fieldKey in summary) {
        GCActivitySummaryValue * value = summary[fieldKey];
        GCNumberWithUnit * num = value.numberWithUnit;
        GCField * field = [GCField fieldForKey:fieldKey andActivityType:act.activityId];
        if (field.fieldFlag != gcFieldFlagNone) {
            GCUnit * unit = [GCTrackPoint unitForField:field.fieldFlag andActivityType:act.activityType];
            if(unit){
                [self setValue:[num convertToUnit:unit].value forField:field.fieldFlag];
            }
        }
        self.extra[fieldKey] = num;
    }
    self.time  = [act buildStartDateFromGarminModernData:data];


}

-(void)parseDict:(NSDictionary*)data inActivity:(GCActivity*)act{
    NSString * atype = act.activityType;

    NSDictionary * dict = data[@"BeginTimestamp"];
    NSString * s_time = dict[@"value"];
    double time70 = s_time.doubleValue;
    self.time = [NSDate dateWithTimeIntervalSince1970:time70/1e3];
    self.extra = [NSMutableDictionary dictionaryWithCapacity:data.count];

    BOOL reported= false;
    for (NSString * field in data) {
        dict = data[field];
        if ([dict isKindOfClass:[NSDictionary class]]) {
            NSString * value   = dict[@"value"];
            NSString * uom     = dict[@"uom"];
            NSString * display = dict[@"fieldDisplayName"];
            if ([value rangeOfString:@"Infinity"].location==NSNotFound) {
                gcFieldFlag trackfield = [GCFields trackFieldFromActivityField:field];
                if ([uom isEqualToString:@"kph"] && [dict[@"unitAbbr"] isEqualToString:@"min/km"]) {
                    uom = @"minperkm";
                }else if( [uom isEqualToString:@"mph"] && [dict[@"unitAbbr"] isEqualToString:@"min/mi"]){
                    uom = @"minpermile";
                }
                [GCFields registerField:field activityType:atype displayName:display andUnitName:uom];
                double numval = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].doubleValue;
                if (trackfield != gcFieldFlagNone) {
                    GCUnit * unit = [GCTrackPoint unitForField:trackfield andActivityType:atype];
                    if (![unit.key isEqualToString:uom]) {
                        numval = [unit convertDouble:numval fromUnit:[GCUnit unitForKey:uom]];
                    }
                    [self setValue:numval forField:trackfield];
                }else{
                    if (![GCFields skipField:field]) {
                        extra[field] = [GCNumberWithUnit numberWithUnitName:uom andValue:numval];
                    }
                }
            }
        }else{
            if (!reported) {
                RZLog(RZLogError, @"Didn't get field %@ as dictionary, got %@", field, NSStringFromClass([dict class]));
            }
            reported = true;
        }
    }
    GCNumberWithUnit * n = extra[@"SumDuration"];
    if (n) {
        self.elapsed = n.value;
    }
}

#pragma mark -

-(void)addExtraFromResultSet:(FMResultSet*)res andActivityType:(NSString*)aType;{
    NSString * lapfield = [res stringForColumn:@"field"];
    NSNumber * value = @([res doubleForColumn:@"value"]);
    NSString * unit  = [res stringForColumn:@"uom"];

    if (!self.extra) {
        self.extra = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    if (unit && unit.length) {
        (self.extra)[lapfield] = [GCNumberWithUnit numberWithUnitName:unit andValue:value.doubleValue];
    }else{
        NSString * usefield = [GCFields fieldForLapField:lapfield andActivityType:aType];
        GCUnit * useunit = [GCFields unitForLapField:lapfield activityType:aType];
        if (useunit) {
            (self.extra)[usefield] = [GCNumberWithUnit numberWithUnit:useunit andValue:value.doubleValue];
        }else{
            (self.extra)[lapfield] = value;
        }
    }
    // Special case
    if ([lapfield isEqualToString:@"TotalTimeSeconds"]) {
        self.elapsed = value.doubleValue;
    }else if ( [lapfield isEqualToString:@"SumDuration"]){
        self.elapsed = value.doubleValue;
    }

    gcFieldFlag next = [GCFields nextTrackField:gcFieldFlagNone in:self.trackFlags];
    while (next != gcFieldFlagNone) {
        GCField * field = [GCField fieldForFlag:next andActivityType:aType];
        GCUnit * uom = [field unit];
        self.extra[field.key] = [[self numberWithUnitForField:next andActivityType:aType] convertToUnit:uom];
        next = [GCFields nextTrackField:next in:self.trackFlags];
    }
}

//NEWTRACKFIELD
-(void)saveToDb:(FMDatabase*)trackdb{
    if(![trackdb executeUpdate:@"INSERT INTO gc_laps (Time,LatitudeDegrees,LongitudeDegrees,DistanceMeters,HeartRateBpm,Speed,Cadence,Altitude,Power,VerticalOscillation,GroundContactTime,Lap,Elapsed,trackflags) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
         self.time,
         @(self.latitudeDegrees),
         @(self.longitudeDegrees),
         @(self.distanceMeters),
         @(self.heartRateBpm),
         @(self.speed),
         @(self.cadence),
         @(self.altitude),
         @(self.power),
         @(self.verticalOscillation),
         @(self.groundContactTime),

         @(self.lapIndex),
         @(self.elapsed),
         @(self.trackFlags)
         ]){

        RZLog( RZLogError, @"db error %@", [trackdb lastErrorMessage]);
    }

    for (NSString * field in extra) {
        id val = extra[field];
        if ([val isKindOfClass:[NSNumber class]]) {
            if(![trackdb executeUpdate:@"INSERT INTO gc_laps_info (lap,field,value) VALUES (?,?,?)", @(self.lapIndex),field,val]){
                RZLog(RZLogError, @"%@",[trackdb lastError]);
            }
        }else{
            GCNumberWithUnit * num = val;
            if(![trackdb executeUpdate:@"INSERT INTO gc_laps_info (lap,field,value,uom) VALUES (?,?,?,?)",
                 @(self.lapIndex),
                 field,
                 @(num.value),
                 (num.unit).key]){
                RZLog(RZLogError, @"%@",[trackdb lastError]);
            }
        }
    }
}
-(GCNumberWithUnit*)numberWithUnitForExtra:(NSString*)aF activityType:(NSString*)aType{
    id valobj = extra[aF];
    if ([valobj isKindOfClass:[GCNumberWithUnit class]]) {
        return valobj;
    }
    NSNumber * val = valobj;
    if (val) {
        if ([aF isEqualToString:@"MaximumSpeed"]) {
            GCUnit * unit = [GCFields unitForLapField:aF activityType:aType];
            double conv=[unit convertDouble:val.doubleValue fromUnit:[GCUnit unitForKey:STOREUNIT_SPEED]];
            return [GCNumberWithUnit numberWithUnit:[GCFields unitForLapField:aF activityType:aType] andValue:conv];
        }else{
            return [GCNumberWithUnit numberWithUnit:[GCFields unitForLapField:aF activityType:aType] andValue:val.doubleValue];
        }
    }
    return [self numberWithUnitForCalculated:aF];
}

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiandsToDegrees(x) (x * 180.0 / M_PI)

-(void)difference:(GCTrackPoint*)to minus:(GCTrackPoint*)from{
    self.elapsed = [to.time timeIntervalSinceDate:from.time];
    if ([to validCoordinate] && [from validCoordinate]) {
        self.distanceMeters = [to distanceMetersFrom:from];

        CLLocationCoordinate2D fromLoc = [from coordinate2D];
        CLLocationCoordinate2D toLoc   = [to   coordinate2D];
        float bearing = 0;
        float fLat = degreesToRadians(fromLoc.latitude);
        float fLng = degreesToRadians(fromLoc.longitude);
        float tLat = degreesToRadians(toLoc.latitude);
        float tLng = degreesToRadians(toLoc.longitude);

        float degree = radiandsToDegrees(atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)));
        if (degree >= 0) {
            bearing = degree;
        } else {
            bearing = 360+degree;
        }

        if (self.extra==nil) {
            self.extra = [NSMutableDictionary dictionaryWithCapacity:5];
        }
        (self.extra)[GC_BEARING_FIELD] = [GCNumberWithUnit numberWithUnitName:@"dd" andValue:bearing];

    }else{
        self.distanceMeters = to.distanceMeters-from.distanceMeters;
    }
    self.speed = to.speed - from.speed;
    self.altitude=to.altitude-from.altitude;
}

-(void)interpolate:(double)delta within:(GCLap*)diff{
    self.distanceMeters += delta*diff.distanceMeters;
    self.elapsed += delta*diff.elapsed;
    self.speed = self.distanceMeters/self.elapsed;
    if (self.useMovingElapsed) {
        NSTimeInterval movingElapsed = self.movingElapsed;
        self.speed = self.distanceMeters/movingElapsed;
    }
}

-(void)accumulateLap:(GCLap*)other{
    NSTimeInterval newelapsed = self.elapsed+other.elapsed;
    self.heartRateBpm = self.heartRateBpm * (self.elapsed/newelapsed) + other.heartRateBpm * (other.elapsed/newelapsed);
    self.cadence = self.cadence *(self.elapsed/newelapsed) + other.cadence * (other.elapsed/newelapsed);
    self.distanceMeters += other.distanceMeters;
    self.speed = self.distanceMeters / newelapsed;
    self.elapsed = newelapsed;

    if (self.extra==nil) {
        self.extra = [NSMutableDictionary dictionaryWithCapacity:5];
    }

}

-(void)accumulateFrom:(GCTrackPoint*)from to:(GCTrackPoint*)to{
    NSTimeInterval dt = [to timeIntervalSince:from];

    if (self.extra==nil) {
        self.extra = [NSMutableDictionary dictionaryWithCapacity:5];
    }

    NSTimeInterval movingElapsed = self.movingElapsed;
    NSTimeInterval newMovingElapsed = movingElapsed+dt;
    NSTimeInterval newelapsed = dt+self.elapsed;

    double dist = 0.;
    if ([to validCoordinate] && [from validCoordinate]) {
        dist = [to distanceMetersFrom:from];
    }else if( to.distanceMeters!=0. && from.distanceMeters!=0.){
        dist = to.distanceMeters-from.distanceMeters;
    }

    double deviceDist = to.distanceMeters-from.distanceMeters;

    if (fabs(newelapsed) > 1e-4 ) {
        if (self.useMovingElapsed) {
            //if (to.distanceMeters-from.distanceMeters>1.e-2) {
            if (dt<10. || deviceDist > 1.) {
                self.heartRateBpm = self.heartRateBpm * (movingElapsed/newMovingElapsed) + from.heartRateBpm * (dt/newMovingElapsed);
                self.power = self.power * (movingElapsed/newMovingElapsed) + from.power * (dt/newMovingElapsed);
                self.cadence = self.cadence *(movingElapsed/newMovingElapsed) + from.cadence * (dt/newMovingElapsed);
                self.distanceMeters += dist;
                self.speed = self.distanceMeters / newMovingElapsed;
                self.movingElapsed = newMovingElapsed;
            }else{
                RZLog(RZLogInfo,@"skip: dt=%.1f dist=%.1f", dt, dist);
            }
        }else{
            self.heartRateBpm = self.heartRateBpm * (self.elapsed/newelapsed) + from.heartRateBpm * (dt/newelapsed);
            self.power = self.power * (self.elapsed/newelapsed) + from.power * (dt/newelapsed);
            self.cadence = self.cadence *(self.elapsed/newelapsed) + from.cadence * (dt/newelapsed);
            self.distanceMeters += dist;
            self.speed = self.distanceMeters / newelapsed;
        }
    }

    self.elapsed = newelapsed;

}

-(void)decumulateFrom:(GCTrackPoint*)from to:(GCTrackPoint*)to{
    NSTimeInterval dt = [to timeIntervalSince:from];
    if (self.extra==nil) {
        self.extra = [NSMutableDictionary dictionaryWithCapacity:5];
    }

    NSTimeInterval newelapsed = self.elapsed-dt;
    if (fabs(newelapsed) > 1e-4 ) {
        self.heartRateBpm = (self.heartRateBpm - from.heartRateBpm * (dt/self.elapsed))*(self.elapsed/newelapsed);
        self.power = (self.power - from.power * (dt/self.elapsed))*(self.elapsed/newelapsed);
        self.cadence = (self.cadence - from.cadence*(dt/self.elapsed))*(self.elapsed/newelapsed);
        if ([to validCoordinate] && [from validCoordinate]) {
            self.distanceMeters -= [to distanceMetersFrom:from];
        }else{
            self.distanceMeters -= to.distanceMeters-from.distanceMeters;
        }

        self.speed = self.distanceMeters / newelapsed;
    }else{


    }
    self.time = to.time;
    self.latitudeDegrees = to.latitudeDegrees;
    self.longitudeDegrees = to.longitudeDegrees;
    self.elapsed = newelapsed;
}

-(void)augmentElapsed:(NSDate*)start{
    if (self.extra==nil) {
        self.extra = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    (self.extra)[@"TotalTimeSeconds"] = @(self.elapsed);
    if (start) {
        (self.extra)[@"TotalTimeSinceStart"] = @([self.time timeIntervalSinceDate:start]);
    }
}

@end
