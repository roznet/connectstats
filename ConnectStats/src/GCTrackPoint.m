//  MIT Licence
//
//  Created on 18/09/2012.
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

#import "GCTrackPoint.h"
#import "GCFields.h"
#import "GCActivity.h"
#import "GCTrackPointExtraIndex.h"
#import "GCActivitySummaryValue.h"

//static NSArray * _dbColumnNames = nil;
//static NSArray * _directKeys = nil;

@interface GCTrackPoint ()
@property (nonatomic,retain) NSMutableDictionary<GCField*,GCNumberWithUnit*> * calculatedStorage;
@property (nonatomic,retain) NSMutableDictionary<GCField*,GCNumberWithUnit*> * extraStorage;

-(BOOL)hasField:(GCField*)afield;
-(double)valueForField:(gcFieldFlag)aField;

@end

void buildStatic(){
    //_dbColumnNames = @[<#objects, ...#>]
}

@implementation GCTrackPoint

-(instancetype)init{
    self = [super init];
    return self;
}
-(GCTrackPoint*)initWithDictionary:(NSDictionary*)data forActivity:(GCActivity*)act{
    self = [super init];
    if (self) {
        if (data[@"directTimestamp"]) {
            [self parseDictionary:data inActivity:act];
        }else{
            [self parseDictionaryOld:data];
        }
    }
    return self;
}
-(GCTrackPoint*)initWithTrackPoint:(GCTrackPoint*)other{
    self = [super init];
    if (self) {
        self.trackFlags = other.trackFlags;
        self.lapIndex = other.lapIndex;
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
        if( other.extraStorage ){
            self.extraStorage = [NSMutableDictionary dictionaryWithDictionary:other.extraStorage];
        }
        if( other.calculatedStorage ) {
            self.calculatedStorage = [NSMutableDictionary dictionaryWithDictionary:other.calculatedStorage];
        }
    }

    return self;
}
-(void)dealloc{
    [_extraStorage release];
    [_time release];
    [_calculatedStorage release];

    [super dealloc];
}

+(GCTrackPoint*)trackPointWithCoordinate2D:(CLLocationCoordinate2D)coord{
    GCTrackPoint * rv = [[[GCTrackPoint alloc] init] autorelease];
    if (rv) {
        rv.latitudeDegrees = coord.latitude;
        rv.longitudeDegrees = coord.longitude;
    }
    return rv;
}
+(GCTrackPoint*)trackPointWithCoordinate2D:(CLLocationCoordinate2D)coord
                                        at:(NSDate*)timestamp
                                       for:(NSDictionary<GCField*,GCActivitySummaryValue*>*)sumValues
                                inActivity:(GCActivity*)act{
    GCTrackPoint * rv = [[[GCTrackPoint alloc] init] autorelease];
    if (rv) {
        rv.time = timestamp;
        rv.longitudeDegrees = coord.longitude;
        rv.latitudeDegrees = coord.latitude;
        [rv updateWithSummaryData:sumValues inActivity:act];
    }
    return rv;
}

#pragma mark - Database

//NEWTRACKFIELD
-(GCTrackPoint*)initWithResultSet:(FMResultSet*)res{
    self = [super init];
    if (self) {
        self.time = [res dateForColumn:@"Time"];
        _latitudeDegrees = [res doubleForColumn:@"LatitudeDegrees"];
        _longitudeDegrees = [res doubleForColumn:@"LongitudeDegrees"];
        _distanceMeters = [res doubleForColumn:@"DistanceMeters"];
        _heartRateBpm = [res doubleForColumn:@"HeartRateBpm"];
        _speed = [res doubleForColumn:@"Speed"];
        _cadence = [res doubleForColumn:@"Cadence"];
        _lapIndex = [res intForColumn:@"Lap"];
        _altitude = [res doubleForColumn:@"Altitude"];
        _power = [res doubleForColumn:@"Power"];
        _elapsed = [res doubleForColumn:@"Elapsed"];
        self.verticalOscillation = [res doubleForColumn:@"VerticalOscillation"];
        self.groundContactTime = [res doubleForColumn:@"GroundContactTime"];
        self.trackFlags = [res intForColumn:@"trackflags"];
    }
    return self;
}

-(NSDictionary<GCField*,GCNumberWithUnit*>*)calculated{
    return self.calculatedStorage;
}
-(NSDictionary<GCField*,GCNumberWithUnit*>*)extra{
    return self.extraStorage;
}

//NEWTRACKFIELD
-(void)saveToDb:(FMDatabase*)trackdb{
    if (!self.time) {
        RZLog(RZLogError, @"No time in track, can't save");
        return;
    }
    if(![trackdb executeUpdate:@"INSERT INTO gc_track (Time,LatitudeDegrees,LongitudeDegrees,DistanceMeters,HeartRateBpm,Speed,Cadence,Altitude,Power,VerticalOscillation,GroundContactTime,Lap,Elapsed,trackflags) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
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
}

-(void)addExtraFromResultSet:(FMResultSet*)res andActivityType:(NSString*)aType{
    GCField * lapfield = [GCField fieldForKey:[res stringForColumn:@"field"] andActivityType:aType] ;
    NSNumber * value = @([res doubleForColumn:@"value"]);
    NSString * unit  = [res stringForColumn:@"uom"];
    
    if (!self.extraStorage) {
        self.extraStorage = [NSMutableDictionary dictionary];
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
}

#pragma mark - Parsing

-(BOOL)updateInActivity:(GCActivity*)act fromTrackpoint:(GCTrackPoint*)other fromActivity:(GCActivity*)otheract forFields:(NSArray<GCField*>*)fields{
    BOOL rv = false;
    
    for (GCField * field in fields) {
        GCNumberWithUnit * nu = [other numberWithUnitForField:field inActivity:otheract];
        [self setNumberWithUnit:nu forField:field inActivity:act];
    }
    
    return rv;
}

-(void)updateWithSummaryData:(NSDictionary<GCField*,GCActivitySummaryValue*>*)summaryData inActivity:(GCActivity*)act{
    
    for (GCField * field in summaryData) {
        GCNumberWithUnit * nu = summaryData[field].numberWithUnit;
        [self setNumberWithUnit:nu forField:field inActivity:act];
    }
}

//NEWTRACKFIELD
-(void)parseDictionary:(NSDictionary*)data inActivity:(GCActivity*)act{
    NSString * tmp = nil;
    NSDictionary * d = data[@"directTimestamp"];
    if (d) {
        self.time = [NSDate dateWithTimeIntervalSince1970:[d[@"value"] doubleValue]/1000.];
    }
    tmp = data[@"directLatitude"][@"value"];
    _latitudeDegrees = tmp ? tmp.doubleValue : 0.0;

    tmp = data[@"directLongitude"][@"value"];
    _longitudeDegrees = tmp ? tmp.doubleValue : 0.0;



    static NSDictionary * defs = nil;
    static NSMutableDictionary * missing = nil;

    if (defs == nil) {

        defs = @{@"sumDistance": @[              STOREUNIT_DISTANCE, @(gcFieldFlagSumDistance)],
                 @"directHeartRate": @[          @"bpm",             @(gcFieldFlagWeightedMeanHeartRate)],
                 @"directSpeed": @[              STOREUNIT_SPEED,    @(gcFieldFlagWeightedMeanSpeed)],
                 @"directElevation": @[          STOREUNIT_ALTITUDE, @(gcFieldFlagAltitudeMeters)],
                 @"directBikeCadence": @[        @"rpm",             @(gcFieldFlagCadence)],
                 //@"directFractionalCadence": @[  @"spm",             @(gcFieldFlagCadence)],
                 @"directRunCadence": @[         @"spm",             @(gcFieldFlagCadence)],
                 @"directPower": @[              @"watt",            @(gcFieldFlagPower)],
                 @"directGroundContactTime": @[  @"ms",              @(gcFieldFlagGroundContactTime)],
                 @"directVerticalOscillation": @[@"centimeter",      @(gcFieldFlagVerticalOscillation)],

                 @"directAirTemperature": @[@"celcius", @"WeightedMeanAirTemperature"],
                 @"directGroundContactBalanceLeft": @[@"percent", @"WeightedMeanGroundContactBalanceLeft"],
                 @"directVerticalRatio":@[@"percent",@"WeightedMeanVerticalRatio"],
                 };

        missing = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                  @"sumMovingDuration":@1,
                                                                  @"sumDuration":@1,
                                                                  @"directLatitude":@1,
                                                                  @"directLongitude":@1,
                                                                  @"directTimestamp":@1,
                                                                  @"sumElapsedDuration":@1,
                                                                  @"directDoubleCadence":@1,
                                                                  @"directStrideLength":@1,
                                                                  }];

        [missing retain];
        [defs retain];
    }

    /*sumDuration,
    directPower,
    sumDistance,
    sumMovingDuration,
    directPowerZone,
    directTimestamp,
    directElevation,
    directRightBalance,
    directAirTemperature,
    directHeartRatePercentMax,
    directBikeCadence,
    directHeartRate,
    sumElapsedDuration,
    directHeartRateZone,
    directLatitude,
    directPace,
    directSpeed,
    directLongitude*/

    for (NSString * field in data) {
        d = data[field];
        NSArray * def = defs[field];
        if (def) {
            NSString * uom = def[0];
            id target = def[1];
            GCNumberWithUnit * nu = [GCNumberWithUnit numberWithUnitName:d[@"unit"] andValue:[d[@"value"] doubleValue]];
            double val = [nu convertToUnit:[GCUnit unitForKey:uom]].value;

            if ([target isKindOfClass:[NSNumber class]]) {
                gcFieldFlag flag = (gcFieldFlag)[target integerValue];
                [self setValue:val forField:flag];
            }else if([target isKindOfClass:[NSString class]]){
                GCField * targetField = [GCField fieldForKey:target andActivityType:act.activityType];
                GCNumberWithUnit * nu = [GCNumberWithUnit numberWithUnitName:uom andValue:val];
                [self setExtraValue:nu forFieldKey:targetField in:act];
            }
        }else{
            if (missing[field] == nil) {
                RZLog(RZLogInfo, @"Ignored Track Field: %@ in %@", field, d[@"unit"]);
                missing[field] = @1;
            }
        }
    }
}

-(double)extraValueForIndex:(GCTrackPointExtraIndex*)idx{
    GCNumberWithUnit * num = self.extraStorage[idx.field];
    if( num ){
        return num.value;
    }
    return 0.;
}
-(void)setExtraValue:(GCNumberWithUnit*)nu forFieldKey:(GCField*)field in:(GCActivity*)act{
    if( act == nil){
        return;// don't bother
    }
    GCTrackPointExtraIndex * index = act.cachedExtraTracksIndexes[field];

    if (index == nil) {
        if (act.cachedExtraTracksIndexes ==nil) {
            act.cachedExtraTracksIndexes = @{};
        }
        index = [GCTrackPointExtraIndex extraIndexForField:field withUnit:nu.unit in:act.cachedExtraTracksIndexes];
        NSMutableDictionary * nextDict = [NSMutableDictionary dictionaryWithObject:index forKey:field];
        [nextDict addEntriesFromDictionary:act.cachedExtraTracksIndexes];
        act.cachedExtraTracksIndexes = nextDict;
    }

    if (!self.extraStorage) {
        self.extraStorage = [NSMutableDictionary dictionary];
    }
    self.extraStorage[field] = nu;
}

-(void)parseDictionaryOld:(NSDictionary*)data{
    NSString * tmp = nil;

    tmp = data[@"Time"];
    if (tmp) {
        self.time = [NSDate dateForRFC3339DateTimeString:data[@"Time"]];
    }
    tmp = data[@"LatitudeDegrees"];
    if (!tmp) {
        tmp = data[@"directLatitude"][@"value"];
    }
    _latitudeDegrees = tmp ? tmp.doubleValue : 0.0;
    tmp = data[@"LongitudeDegrees"];
    if (!tmp) {
        tmp = data[@"directLongitude"][@"value"];
    }
    _longitudeDegrees = tmp ? tmp.doubleValue : 0.0;

    _distanceMeters = 0.;
    _heartRateBpm = 0.;
    _speed = 0.;
    _cadence = 0.;
    _altitude = 0.;
    _power = 0.;
    _trackFlags = gcFieldFlagNone;

    tmp = data[@"DistanceMeters"];
    if (tmp) {
        _distanceMeters = tmp.doubleValue;
        if (_distanceMeters > 0.) {
            _trackFlags |= gcFieldFlagSumDistance;
        }
    }

    tmp = data[@"HeartRateBpm"];
    if (tmp) {
        _heartRateBpm = [tmp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].doubleValue;
        _trackFlags |= gcFieldFlagWeightedMeanHeartRate;
    }
    tmp = data[@"Speed"];
    if (tmp) {
        _speed = tmp.doubleValue;
        if (_speed>0.) {
            _trackFlags |= gcFieldFlagWeightedMeanSpeed;
        }
    }
    tmp = data[@"Watts"];
    if (tmp) {
        _power = tmp.doubleValue;
        _trackFlags |= gcFieldFlagPower;
    }
    tmp = data[@"Cadence"];
    if (!tmp) {
        tmp = data[@"RunCadence"];
    }
    if (tmp) {
        _cadence = tmp ? tmp.doubleValue : 0.0;
        _trackFlags |= gcFieldFlagCadence;
    }
    tmp = data[@"AltitudeMeters"];
    if (tmp) {
        _altitude = tmp ? tmp.doubleValue : 0.0;
        _trackFlags |= gcFieldFlagAltitudeMeters;
    }
}

-(void)updateWithNextPoint:(GCTrackPoint*)next{
    if (next) {
        if ( ( _trackFlags & gcFieldFlagWeightedMeanSpeed ) != gcFieldFlagWeightedMeanSpeed) {
            if ( (_trackFlags & gcFieldFlagSumDistance) == gcFieldFlagSumDistance) {
                double dt = [next.time timeIntervalSinceDate:self.time];
                double dx = next.distanceMeters - self.distanceMeters;
                if (dt != 0.0) {
                    [self setValue:dx/dt forField:gcFieldFlagWeightedMeanSpeed];
                    _trackFlags |= gcFieldFlagWeightedMeanSpeed;
                }
            }
        }
    }

}
-(NSComparisonResult)compareTime:(GCTrackPoint*)other{
    return [self.time compare:other.time];
}

-(NSString*)description{
    NSMutableString * rv = [NSMutableString stringWithFormat:@"<%@: %@,%.1f sec", NSStringFromClass([self class]), _time,_elapsed];

    NSArray<NSNumber*> * available =[GCFields availableTrackFieldsIn:self.trackFlags];
    GCNumberWithUnit * nu = [self numberWithUnitForField:gcFieldFlagSumDistance andActivityType:GC_TYPE_ALL];
    if( nu ){
        [rv appendFormat:@", %@", nu];
    }
    for (NSNumber * one in available) {
        gcFieldFlag flag = one.intValue;
        GCNumberWithUnit * nu = [self numberWithUnitForField:flag andActivityType:GC_TYPE_ALL];
        [rv appendFormat:@", %@", nu];
    }
    [rv appendString:@">"];
    return rv;
}

-(NSString*)fullDescriptionInActivity:(GCActivity*)act{
    NSMutableString * rv = [NSMutableString stringWithFormat:@"<%@: %@,%.1f sec>", NSStringFromClass([self class]), _time,_elapsed];
    if ([self validCoordinate]) {
        [rv appendString: @"\n  Valid Coordinates"];
    }
    NSArray<GCField*> * available = [self availableFieldsInActivity:act];
    for (GCField * one in available) {
        GCNumberWithUnit * nu = [self numberWithUnitForField:one inActivity:act];
        [rv appendFormat:@"\n  %@: %@", one, nu ];
    }

    return rv;
}
-(NSString*)displayLabel{
    return nil;
}

#pragma mark - Extra Values


-(GCNumberWithUnit*)numberWithUnitForExtraByIndex:(GCTrackPointExtraIndex *)idx{
    return self.extraStorage[idx.field];
}
-(GCNumberWithUnit*)numberWithUnitForExtraByField:(GCField *)aF{
    return self.extraStorage[aF];
}
-(void)updateWithExtra:(NSDictionary<GCField*,GCNumberWithUnit*>*)other{
    if( ! self.extraStorage ){
        self.extraStorage = [NSMutableDictionary dictionaryWithDictionary:other];
    }else{
        for (GCField * one in other) {
            self.extraStorage[one] = other[one];
        }
    }
}

#pragma mark - Access/Set Values

-(double)steps{
    return self.cadence * self.elapsed / 60.;
}
-(void)setSteps:(double)steps{
    if (steps != 0. && self.elapsed!=0.) {
        self.cadence = steps /self.elapsed * 60.;
    }
}

-(BOOL)hasField:(GCField*)field{
    if(field.fieldFlag != gcFieldFlagNone){
        return (self.trackFlags & field.fieldFlag) == field.fieldFlag;
    }else{
        return self.extraStorage[field] != nil || self.calculatedStorage[field] != nil;
    }
}

-(NSArray<GCField*>*)availableFieldsInActivity:(GCActivity*)act{
    NSMutableArray * rv = [NSMutableArray arrayWithArray:[GCFields availableFieldsIn:self.trackFlags forActivityType:act.activityType]];
    if( self.extraStorage ){
        [rv addObjectsFromArray:self.extraStorage.allKeys];
    }
    if( self.calculatedStorage ){
        [rv addObjectsFromArray:self.calculatedStorage.allKeys];
    }
    return rv;
}

//NEWTRACKFIELD
-(double)valueForField:(gcFieldFlag)aField{
    switch (aField) {
        case gcFieldFlagSumDuration:
            return _elapsed;
        case gcFieldFlagSumDistance:
            return _distanceMeters;
        case gcFieldFlagWeightedMeanHeartRate:
            return _heartRateBpm;
        case gcFieldFlagWeightedMeanSpeed:
            return self.speed;
        case gcFieldFlagCadence:
            return self.cadence;
        case gcFieldFlagAltitudeMeters:
            return self.altitude;
        case gcFieldFlagPower:
            return self.power;
        case gcFieldFlagVerticalOscillation:
            return self.verticalOscillation;
        case gcFieldFlagGroundContactTime:
            return self.groundContactTime;
        case gcFieldFlagSumStep:
            return self.steps;
        default:
            return 0.0;
    }
    return 0.;
}

//NEWTRACKFIELD
-(void)setValue:(double)val forField:(gcFieldFlag)aField{
    switch (aField) {
        case gcFieldFlagSumDuration:
            _trackFlags |= aField;
            _elapsed=val;
            break;
        case gcFieldFlagSumDistance:
            _trackFlags |= aField;
            _distanceMeters = val;
            break;
        case gcFieldFlagWeightedMeanHeartRate:
            _trackFlags |= aField;
            _heartRateBpm = val;
            break;
        case gcFieldFlagWeightedMeanSpeed:
            _trackFlags |= aField;
            _speed = val;
            break;
        case gcFieldFlagCadence:
            _trackFlags |= aField;
            _cadence = val;
            break;
        case gcFieldFlagAltitudeMeters:
            _trackFlags |= aField;
            _altitude = val;
            break;
        case gcFieldFlagPower:
            _trackFlags |= aField;
            _power = val;
            break;
        case gcFieldFlagGroundContactTime:
            _trackFlags |= aField;
            self.groundContactTime = val;
            break;
        case gcFieldFlagVerticalOscillation:
            _trackFlags |= aField;
            self.verticalOscillation = val;
            break;
        case gcFieldFlagSumStep:
            _trackFlags |= aField;
            self.steps = val;
            break;
        default:
            break;
    }

}

//NEWTRACKFIELD
+(GCUnit*)unitForField:(gcFieldFlag)aField andActivityType:(NSString*)aType{
    switch (aField) {
        case gcFieldFlagWeightedMeanSpeed:
            return [GCUnit unitForKey:@"mps"];
        case gcFieldFlagWeightedMeanHeartRate:
            return [GCUnit unitForKey:@"bpm"];
        case gcFieldFlagSumDistance:
            return [GCUnit unitForKey:@"meter"];
        case gcFieldFlagSumDuration:
            return [GCUnit unitForKey:@"second"];
        case gcFieldFlagAltitudeMeters:
            return [GCUnit unitForKey:@"meter"];
        case gcFieldFlagCadence:
            if ([aType isEqualToString:GC_TYPE_CYCLING]) {
                return [GCUnit unitForKey:@"rpm"];
            }else if ([aType isEqualToString:GC_TYPE_SWIMMING]){
                return [GCUnit unitForKey:@"strokesPerMinute"];
            }
            return [GCUnit unitForKey:@"stepsPerMinute"];
        case gcFieldFlagPower:
            return [GCUnit unitForKey:@"watt"];
        case gcFieldFlagVerticalOscillation:
            return [GCUnit unitForKey:@"centimeter"];
        case gcFieldFlagGroundContactTime:
            return [GCUnit unitForKey:@"ms"];
        case gcFieldFlagSumStep:
            return [GCUnit unitForKey:@"step"];
        default:
            break;
    }
    return nil;
}

-(GCNumberWithUnit*)numberWithUnitForField:(GCField*)aF inActivity:(GCActivity*)act{
    GCNumberWithUnit * rv = nil;
    if (aF.fieldFlag != gcFieldFlagNone) {
        if( (aF.fieldFlag & self.trackFlags) == aF.fieldFlag ){
            rv = [GCNumberWithUnit numberWithUnit:[GCTrackPoint unitForField:aF.fieldFlag andActivityType:aF.activityType?:GC_TYPE_ALL]
                                         andValue:[self valueForField:aF.fieldFlag]];
        }
    }else{
        GCTrackPointExtraIndex * idx = act.cachedExtraTracksIndexes[aF];
        if (idx) {
            rv = [GCNumberWithUnit numberWithUnit:idx.unit andValue:[self extraValueForIndex:idx]];
        }

        if (!rv && self.calculatedStorage) {
            rv = self.calculatedStorage[aF];
            rv = [rv convertToGlobalSystem];
            if ([aF.key hasSuffix:@"Elevation"] && [rv.unit.key isEqualToString:@"yard"]) {
                rv = [rv convertToUnitName:@"foot"];
            }
        }
        if (!rv) {
            rv = [self numberWithUnitForExtraByField:aF];
        }
    }
    return rv;
}
-(void)setNumberWithUnit:(GCNumberWithUnit*)nu forField:(GCField*)field inActivity:(GCActivity*)act{
    static NSDictionary*_defs = nil;
    if( _defs == nil){
        _defs = @{
                  @(gcFieldFlagSumDistance) : [GCUnit unitForKey:STOREUNIT_DISTANCE],
                  @(gcFieldFlagWeightedMeanSpeed) : [GCUnit unitForKey:STOREUNIT_SPEED],
                  @(gcFieldFlagWeightedMeanHeartRate) : [GCUnit bpm],
                  @(gcFieldFlagAltitudeMeters): [GCUnit unitForKey:STOREUNIT_ALTITUDE],
                  @(gcFieldFlagCadence):[GCUnit rpm],
                  @(gcFieldFlagPower):[GCUnit watt],
                  @(gcFieldFlagGroundContactTime):[GCUnit ms],
                  @(gcFieldFlagVerticalOscillation):[GCUnit centimeter],
                  };
        [_defs retain];
    }
    GCUnit * unit = field.fieldFlag != gcFieldFlagNone?_defs[ @(field.fieldFlag) ] : nil;
    if( unit ){
        [self setValue:[nu convertToUnit:unit].value forField:field.fieldFlag];
    }else{
        if( ![nu.unit.key isEqualToString:@"datetime"]){
            [self setExtraValue:nu forFieldKey:field in:act];
        }
    }
}
-(GCNumberWithUnit*)numberWithUnitForField:(gcFieldFlag)aField andActivityType:(NSString*)aType;{
    return [GCNumberWithUnit numberWithUnit:[GCTrackPoint unitForField:aField andActivityType:aType] andValue:[self valueForField:aField]];
}

#pragma mark - Locations

-(BOOL)validCoordinate{
    return _longitudeDegrees != 0.;
}

-(CLLocationCoordinate2D)coordinate2D{
		return CLLocationCoordinate2DMake(_latitudeDegrees, _longitudeDegrees);
}

-(CLLocation*)location{
    if ([self validCoordinate]) {
        return [[[CLLocation alloc] initWithCoordinate:[self coordinate2D] altitude:_altitude horizontalAccuracy:1. verticalAccuracy:1. timestamp:_time] autorelease];
    }
    return nil;
}
-(CLLocationDistance)distanceMetersFrom:(GCTrackPoint*)other{
    CLLocationDistance rv = 0.;

    CLLocation * loc1=nil;
    CLLocation * loc2=nil;
    if (self.validCoordinate) {
        loc1 = [[CLLocation alloc] initWithCoordinate:[self coordinate2D] altitude:_altitude horizontalAccuracy:1. verticalAccuracy:1. timestamp:_time];
    }
    if (other.validCoordinate) {
        loc2 = [[CLLocation alloc] initWithCoordinate:[other coordinate2D] altitude:other.altitude horizontalAccuracy:1. verticalAccuracy:1. timestamp:other.time];
    }

    if (loc1&&loc2) {
        rv = [loc1 distanceFromLocation:loc2];
    }
    [loc1 release];
    [loc2 release];
    return rv;

}

#pragma mark - Calculations

-(NSTimeInterval)timeIntervalSince:(GCTrackPoint*)other{
    return [self.time timeIntervalSinceDate:other.time];
}

-(void)clearCalculatedForFields:(NSArray<GCField *> *)fields{
    for (GCField * field in fields) {
        [self.calculatedStorage removeObjectForKey:field];
    }
}

-(GCNumberWithUnit*)numberWithUnitForCalculated:(GCField*)aF{
    if (self.calculatedStorage) {
        GCNumberWithUnit * rv = (self.calculatedStorage)[aF];
        rv = [rv convertToGlobalSystem];
        if ([aF.key hasSuffix:@"Elevation"] && [rv.unit.key isEqualToString:@"yard"]) {
            rv = [rv convertToUnitName:@"foot"];
        }
        return rv;
    }
    return nil;
}
-(void)addNumberWithUnitForCalculated:(GCNumberWithUnit*)aN forField:(GCField*)aF{
    if (self.calculatedStorage == nil) {
        self.calculatedStorage = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    self.calculatedStorage[aF] = aN;
}

-(void)add:(GCTrackPoint*)other withAccrued:(double)accrued timeAxis:(BOOL)timeAxis{
    // first? setup basics
    if (self.time==nil) {
        self.time = other.time;
        self.latitudeDegrees = other.latitudeDegrees;
        self.longitudeDegrees = other.longitudeDegrees;
        self.altitude = other.altitude;
    }
    self.trackFlags |= other.trackFlags;

    self.heartRateBpm   += accrued * other.heartRateBpm;
    self.speed          += accrued * other.speed;
    self.power          += accrued * other.power;
    self.verticalOscillation += accrued * other.verticalOscillation;
    self.groundContactTime   += accrued * other.groundContactTime;

    // FIXME: accrued based on timeaxis
    self.distanceMeters += accrued * other.distanceMeters;
    self.elapsed        += accrued * other.elapsed;

}

-(void)mergeWith:(GCTrackPoint*)other{

    self.trackFlags |= other.trackFlags;

    double totalElapsed = self.elapsed + other.elapsed;

    self.heartRateBpm   = (self.elapsed * self.heartRateBpm +other.heartRateBpm * other.elapsed)/totalElapsed;
    self.power          = (self.elapsed * self.power +other.power * other.elapsed)/totalElapsed;
    self.distanceMeters = self.distanceMeters + other.distanceMeters;

    BOOL hasStep = (self.trackFlags & gcFieldFlagSumStep) == gcFieldFlagSumStep;
    if (hasStep) {
        // step needs to get accessed before elapsed and set after, as as self.step is a function of self.elapsed
        double steps = self.steps + other.steps;
        self.elapsed = totalElapsed;
        self.steps = steps;
    }else{
        self.elapsed = totalElapsed;
    }
    if (totalElapsed!= 0.) {
        self.speed = self.distanceMeters/totalElapsed;
    }else{
        self.speed = 0.;
    }
}
-(BOOL)realisticForActivityType:(NSString*)aType{
    if ([aType isEqualToString:GC_TYPE_DAY]) {
        return self.cadence < 200;
    }
    return true;
}

@end
