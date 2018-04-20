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
@end

@implementation GCLap

-(void)dealloc{
    
    [_label release];

    [super dealloc];
}

-(instancetype)init{
    return [super init];
}


-(GCLap*)initWithLap:(GCLap*)other{
    self = [super initWithTrackPoint:other];
    return self;
}


-(GCLap*)initWithTrackPoint:(GCTrackPoint*)other{
    self = [super initWithTrackPoint:other];
    if (self) {
        self.distanceMeters = 0.;
        self.elapsed = 0.;
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
    NSMutableDictionary<GCField*,GCNumberWithUnit*>*extraStorage = [NSMutableDictionary dictionary];
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
            
            extraStorage[ [GCField fieldForKey:usefield andActivityType:atype]  ] = [GCNumberWithUnit numberWithUnit:unit andValue:value];

        }
    }
    GCNumberWithUnit * dur = extraStorage[ [GCField fieldForKey:@"TotalTimeSecond" andActivityType:atype] ];
    if (!dur) {
        dur = extraStorage[ [GCField fieldForKey:@"SumDuration" andActivityType:atype] ];
    }
    if (dur) {
        self.elapsed = dur.value;
    }
    [self updateWithExtra:extraStorage];
}

-(void)recordField:(GCField*)field withUnit:(GCUnit*)unit inActivity:(GCActivity*)act{
    // Override track point record, as for lap we will have more fields
    // and we don't want them to be recorded as trackfields
}

-(void)parseModernDict:(NSDictionary*)data inActivity:(GCActivity*)act{

    NSMutableDictionary * summary = [act buildSummaryDataFromGarminModernData:data];
    
    for (GCField * field in summary) {
        GCActivitySummaryValue * value = summary[field];
        GCNumberWithUnit * num = value.numberWithUnit;
        [self setNumberWithUnit:num forField:field inActivity:act];
    }
    self.time  = [act buildStartDateFromGarminModernData:data];
}

-(void)parseDict:(NSDictionary*)data inActivity:(GCActivity*)act{
    NSString * atype = act.activityType;

    NSDictionary * dict = data[@"BeginTimestamp"];
    NSString * s_time = dict[@"value"];
    double time70 = s_time.doubleValue;
    self.time = [NSDate dateWithTimeIntervalSince1970:time70/1e3];
    NSMutableDictionary<GCField*,GCNumberWithUnit*>*extraStorage = [NSMutableDictionary dictionaryWithCapacity:data.count];

    BOOL reported= false;
    for (NSString * fieldKey in data) {
        GCField * field = [GCField fieldForKey:fieldKey andActivityType:act.activityType];
        dict = data[fieldKey];
        if ([dict isKindOfClass:[NSDictionary class]]) {
            NSString * value   = dict[@"value"];
            NSString * uom     = dict[@"uom"];
            NSString * display = dict[@"fieldDisplayName"];
            if ([value rangeOfString:@"Infinity"].location==NSNotFound) {
                gcFieldFlag trackfield = field.fieldFlag;
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
                    [self setNumberWithUnit:[GCNumberWithUnit numberWithUnit:unit andValue:numval]
                                   forField:[GCField fieldForFlag:trackfield andActivityType:act.activityType] inActivity:nil];
                }else{
                    if (![GCFields skipField:fieldKey]) {
                        extraStorage[field] = [GCNumberWithUnit numberWithUnitName:uom andValue:numval];
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
    GCNumberWithUnit * n = extraStorage[ [GCField fieldForKey:@"SumDuration" andActivityType:act.activityType] ];
    if (n) {
        self.elapsed = n.value;
    }
    [self updateWithExtra:extraStorage];
}

#pragma mark -


//NEWTRACKFIELD avoid gcFieldFlag if possible
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

    for (GCField * field in self.extra) {
        GCNumberWithUnit * num = self.extra[field];
        if(![trackdb executeUpdate:@"INSERT INTO gc_laps_info (lap,field,value,uom) VALUES (?,?,?,?)",
             @(self.lapIndex),
             field.key,
             @(num.value),
             num.unit.key]){
            RZLog(RZLogError, @"%@",[trackdb lastError]);
        }
    }
}

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiandsToDegrees(x) (x * 180.0 / M_PI)

-(void)difference:(GCTrackPoint*)to minus:(GCTrackPoint*)from inActivity:(GCActivity*)act{
    self.elapsed = [to.time timeIntervalSinceDate:from.time];
    if ([to validCoordinate] && [from validCoordinate]) {
        self.distanceMeters = [to distanceMetersFrom:from];
        
        //FIXME: not sure where BEARING Is used?
        /*
         CLLocationCoordinate2D fromLoc = [from coordinate2D];
         CLLocationCoordinate2D toLoc   = [to   coordinate2D];
         float fLat = degreesToRadians(fromLoc.latitude);
         float fLng = degreesToRadians(fromLoc.longitude);
         float tLat = degreesToRadians(toLoc.latitude);
         float tLng = degreesToRadians(toLoc.longitude);

        float degree = radiandsToDegrees(atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)));
        float bearing = 0;
        if (degree >= 0) {
            bearing = degree;
        } else {
            bearing = 360+degree;
        }

        self.extraStorage[ [GCField fieldForKey:GC_BEARING_FIELD andActivityType:nil] = [GCNumberWithUnit numberWithUnitName:@"dd" andValue:bearing];
         */
    }else{
        self.distanceMeters = to.distanceMeters-from.distanceMeters;
    }
    self.speed = to.speed - from.speed;
    self.altitude=to.altitude-from.altitude;
}

-(void)interpolate:(double)delta within:(GCLap*)diff inActivity:(GCActivity*)act{
    self.distanceMeters += delta*diff.distanceMeters;
    self.elapsed += delta*diff.elapsed;
    self.speed = self.distanceMeters/self.elapsed;
    if (self.useMovingElapsed) {
        NSTimeInterval movingElapsed = self.movingElapsed;
        self.speed = self.distanceMeters/movingElapsed;
    }
}

-(void)accumulateLap:(GCLap*)other inActivity:(GCActivity*)act{
    NSTimeInterval newelapsed = self.elapsed+other.elapsed;
    [self accumulateFieldsFrom:other thisWeight:(self.elapsed/newelapsed) otherWeight:(other.elapsed/newelapsed) inActivity:act];
    self.distanceMeters += other.distanceMeters;
    self.speed = self.distanceMeters / newelapsed;
    self.elapsed = newelapsed;

}

-(void)accumulateFieldsFrom:(GCTrackPoint*)other thisWeight:(double)w0 otherWeight:(double)w1 inActivity:(GCActivity*)act{
    // Get fields available in other and add them
    NSArray<GCField*>*fields = [other availableFieldsInActivity:act];
    
    for (GCField * field in fields) {
        GCNumberWithUnit * num = [self numberWithUnitForField:field inActivity:act];
        GCNumberWithUnit * onum = [other numberWithUnitForField:field inActivity:act];
        
        if( num == nil){
            // we don't have the field, start with existing
            [self setNumberWithUnit:onum forField:field inActivity:act];
        }else{
            
            if( field.canSum ){
                [self setNumberWithUnit:[num addNumberWithUnit:onum thisWeight:1.0 otherWeight:1.0] forField:field inActivity:act];
            }else if( field.isWeightedAverage ){
                [self setNumberWithUnit:[num addNumberWithUnit:onum thisWeight:w0 otherWeight:w1] forField:field inActivity:act];
            }else if (field.isMax){
                [self setNumberWithUnit:[num maxNumberWithUnit:onum] forField:field inActivity:act];
            }else if (field.isMin){
                [self setNumberWithUnit:[num nonZeroMinNumberWithUnit:onum] forField:field inActivity:act];
            }// don't touch rest
        }
    }
}

-(void)accumulateFrom:(GCTrackPoint*)from to:(GCTrackPoint*)to inActivity:(GCActivity*)act{
    NSTimeInterval dt = [to timeIntervalSince:from];

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
                [self accumulateFieldsFrom:from thisWeight:(movingElapsed/newMovingElapsed) otherWeight:(dt/newMovingElapsed) inActivity:act];
                self.distanceMeters += dist;
                self.speed = self.distanceMeters / newMovingElapsed;
                self.movingElapsed = newMovingElapsed;
            }else{
                RZLog(RZLogInfo,@"skip: dt=%.1f dist=%.1f", dt, dist);
            }
        }else{
            [self accumulateFieldsFrom:from thisWeight:(self.elapsed/newelapsed) otherWeight:(dt/newelapsed) inActivity:act];
            self.distanceMeters += dist;
            self.speed = self.distanceMeters / newelapsed;
        }
    }

    self.elapsed = newelapsed;

}

-(void)decumulateFrom:(GCTrackPoint*)from to:(GCTrackPoint*)to inActivity:(GCActivity*)act{
    NSTimeInterval dt = [to timeIntervalSince:from];

    NSTimeInterval newelapsed = self.elapsed-dt;
    if (fabs(newelapsed) > 1e-4 ) {
        [self accumulateFieldsFrom:from thisWeight:1.0 otherWeight:-1.0*(dt/self.elapsed)*(self.elapsed/newelapsed) inActivity:act];
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
    GCField * totalElapsed = [GCField fieldForKey:@"TotalTimeSeconds" andActivityType:act.activityType];
    [self setNumberWithUnit:[GCNumberWithUnit numberWithUnit:GCUnit.second andValue:self.elapsed] forField:totalElapsed inActivity:act];
    if (start) {
        GCField * timeStart = [GCField fieldForKey:@"TotalTimeSinceStart" andActivityType:act.activityType];
        [self setNumberWithUnit:[GCNumberWithUnit numberWithUnit:GCUnit.second andValue:[self.time timeIntervalSinceDate:start]] forField:timeStart inActivity:act];
    }
}
@end
