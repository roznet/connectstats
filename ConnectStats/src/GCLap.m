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

@interface GCLap ()
@property (nonatomic,retain) NSMutableDictionary<GCField*,GCNumberWithUnit*>*extraStorage;
@end

@implementation GCLap

-(void)dealloc{
    [_extraStorage release];
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
        self.extraStorage = [NSMutableDictionary dictionaryWithDictionary:other.extra];
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
        self.extraStorage = nil;
    }
    return self;
}

-(NSDictionary<GCField*,GCNumberWithUnit*>*)extra{
    return self.extraStorage;
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

    self.extraStorage = [NSMutableDictionary dictionaryWithCapacity:data.count];

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
            self.extraStorage[ [GCField fieldForKey:usefield andActivityType:atype]  ] = [GCNumberWithUnit numberWithUnit:unit andValue:value];

        }
    }
    GCNumberWithUnit * dur = self.extraStorage[ [GCField fieldForKey:@"TotalTimeSecond" andActivityType:atype] ];
    if (!dur) {
        dur = self.extraStorage[ [GCField fieldForKey:@"SumDuration" andActivityType:atype] ];
    }
    if (dur) {
        self.elapsed = dur.value;
    }
}

-(void)parseModernDict:(NSDictionary*)data inActivity:(GCActivity*)act{

    NSMutableDictionary * summary = [act buildSummaryDataFromGarminModernData:data];
    self.extraStorage = [NSMutableDictionary dictionary];
    for (GCField * field in summary) {
        GCActivitySummaryValue * value = summary[field];
        GCNumberWithUnit * num = value.numberWithUnit;
        if (field.fieldFlag != gcFieldFlagNone) {
            GCUnit * unit = [GCTrackPoint unitForField:field.fieldFlag andActivityType:act.activityType];
            if(unit){
                [self setValue:[num convertToUnit:unit].value forField:field.fieldFlag];
            }
        }
        self.extraStorage[field] = num;
    }
    self.time  = [act buildStartDateFromGarminModernData:data];
}

-(void)parseDict:(NSDictionary*)data inActivity:(GCActivity*)act{
    NSString * atype = act.activityType;

    NSDictionary * dict = data[@"BeginTimestamp"];
    NSString * s_time = dict[@"value"];
    double time70 = s_time.doubleValue;
    self.time = [NSDate dateWithTimeIntervalSince1970:time70/1e3];
    self.extraStorage = [NSMutableDictionary dictionaryWithCapacity:data.count];

    BOOL reported= false;
    for (NSString * fieldKey in data) {
        GCField * field = [GCField fieldForKey:fieldKey andActivityType:act.activityType];
        dict = data[fieldKey];
        if ([dict isKindOfClass:[NSDictionary class]]) {
            NSString * value   = dict[@"value"];
            NSString * uom     = dict[@"uom"];
            NSString * display = dict[@"fieldDisplayName"];
            if ([value rangeOfString:@"Infinity"].location==NSNotFound) {
                gcFieldFlag trackfield = [GCFields trackFieldFromActivityField:fieldKey];
                if ([uom isEqualToString:@"kph"] && [dict[@"unitAbbr"] isEqualToString:@"min/km"]) {
                    uom = @"minperkm";
                }else if( [uom isEqualToString:@"mph"] && [dict[@"unitAbbr"] isEqualToString:@"min/mi"]){
                    uom = @"minpermile";
                }
                [GCFields registerField:fieldKey activityType:atype displayName:display andUnitName:uom];
                double numval = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].doubleValue;
                if (trackfield != gcFieldFlagNone) {
                    GCUnit * unit = [GCTrackPoint unitForField:trackfield andActivityType:atype];
                    if (![unit.key isEqualToString:uom]) {
                        numval = [unit convertDouble:numval fromUnit:[GCUnit unitForKey:uom]];
                    }
                    [self setValue:numval forField:trackfield];
                }else{
                    if (![GCFields skipField:fieldKey]) {
                        self.extraStorage[field] = [GCNumberWithUnit numberWithUnitName:uom andValue:numval];
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
    GCNumberWithUnit * n = self.extraStorage[ [GCField fieldForKey:@"SumDuration" andActivityType:act.activityType] ];
    if (n) {
        self.elapsed = n.value;
    }
}

#pragma mark -

-(void)addExtraFromResultSet:(FMResultSet*)res andActivityType:(NSString*)aType;{
    GCField * lapfield = [GCField fieldForKey:[res stringForColumn:@"field"] andActivityType:aType] ;
    NSNumber * value = @([res doubleForColumn:@"value"]);
    NSString * unit  = [res stringForColumn:@"uom"];

    if (!self.extraStorage) {
        self.extraStorage = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    if (unit && unit.length) {
        self.extraStorage[lapfield] = [GCNumberWithUnit numberWithUnitName:unit andValue:value.doubleValue];
    }else{
        GCField * usefield = [GCField fieldForKey:[GCFields fieldForLapField:lapfield.key andActivityType:aType] andActivityType:aType];
        GCUnit * useunit = [GCFields unitForLapField:lapfield.key activityType:aType];
        if( ! useunit){
            useunit = GCUnit.dimensionless;
        }
        self.extraStorage[usefield] = [GCNumberWithUnit numberWithUnit:useunit andValue:value.doubleValue];
    }
    // Special case
    if ([lapfield.key isEqualToString:@"TotalTimeSeconds"]) {
        self.elapsed = value.doubleValue;
    }else if ( [lapfield.key isEqualToString:@"SumDuration"]){
        self.elapsed = value.doubleValue;
    }

    gcFieldFlag next = [GCFields nextTrackField:gcFieldFlagNone in:self.trackFlags];
    while (next != gcFieldFlagNone) {
        GCField * field = [GCField fieldForFlag:next andActivityType:aType];
        GCUnit * uom = [field unit];
        self.extraStorage[field] = [[self numberWithUnitForField:next andActivityType:aType] convertToUnit:uom];
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

    for (GCField * field in self.extraStorage) {
        GCNumberWithUnit * val = self.extraStorage[field];
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
-(GCNumberWithUnit*)numberWithUnitForExtraByField:(GCField *)aF{
    return self.extraStorage[aF];
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
            self.extraStorage = [NSMutableDictionary dictionaryWithCapacity:5];
        }
        //FIXME: not sure where BEARING Is used?
        //self.extraStorage[ [GCField fieldForKey:GC_BEARING_FIELD andActivityType:nil] = [GCNumberWithUnit numberWithUnitName:@"dd" andValue:bearing];

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
        self.extraStorage = [NSMutableDictionary dictionaryWithCapacity:5];
    }

}

-(void)accumulateFrom:(GCTrackPoint*)from to:(GCTrackPoint*)to{
    NSTimeInterval dt = [to timeIntervalSince:from];

    if (self.extra==nil) {
        self.extraStorage = [NSMutableDictionary dictionaryWithCapacity:5];
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
    if (self.extraStorage==nil) {
        self.extraStorage = [NSMutableDictionary dictionaryWithCapacity:5];
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

-(void)augmentElapsed:(NSDate*)start inActivity:(GCActivity*)act{
    if (self.extraStorage==nil) {
        self.extraStorage = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    GCField * totalElapsed = [GCField fieldForKey:@"TotalTimeSeconds" andActivityType:act.activityType];
    self.extraStorage[totalElapsed] = [GCNumberWithUnit numberWithUnit:GCUnit.second andValue:self.elapsed];
    if (start) {
        GCField * timeStart = [GCField fieldForKey:@"TotalTimeSinceStart" andActivityType:act.activityType];
        self.extraStorage[timeStart] = [GCNumberWithUnit numberWithUnit:GCUnit.second andValue:[self.time timeIntervalSinceDate:start]];
    }
}
-(void)updateExtra:(NSDictionary<GCField*,GCNumberWithUnit*>*)extra inActivity:(GCActivity*)act{
    self.extraStorage = [NSMutableDictionary dictionaryWithDictionary:extra];
}
@end
