//  MIT Licence
//
//  Created on 16/12/2012.
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

#import "GCTrackPointSwim.h"
#import "GCActivity+Import.h"
#import "GCActivitySummaryValue.h"

@implementation GCTrackPointSwim

-(instancetype)init{
    return [super init];
}

-(GCTrackPoint*)initWithDictionary:(NSDictionary*)data forActivity:(GCActivity *)act{
    self = [super init];
    if (self) {
        if( data[@"BeginTimestamp"]){
            [self parseOldDict:data forActivity:act];
        }else{
            [self parseModernDict:data forActivity:act];
        }
    }
    return self;
}

-(GCTrackPointSwim*)initWithTrackPoint:(GCTrackPoint*)other{
    self = [super initWithTrackPoint:other];
    return self;
}


-(GCTrackPointSwim*)initAt:(NSDate*)timestamp
                    stroke:(gcSwimStrokeType)type
                    active:(BOOL)active
                       for:(NSDictionary<GCField*,GCActivitySummaryValue*>*)sumValues
                inActivity:(GCActivity*)act{
    self = [super init];
    if (self) {
        self.time = timestamp;
        self.directSwimStroke = type;
        for (GCField * field in sumValues) {
            GCActivitySummaryValue * value = sumValues[field];
            [self setNumberWithUnit:value.numberWithUnit forField:field inActivity:act];
        }
        if( ! active ){
            [self setNumberWithUnit:[GCNumberWithUnit numberWithUnit:GCUnit.meter andValue:0.0] forField:[GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:act.activityType] inActivity:act];
        }
        
    }
    return self;
}


#pragma mark - Parsing

-(void)parseModernDict:(NSDictionary*)data forActivity:(GCActivity*)act{
    NSMutableDictionary * summary = [act buildSummaryDataFromGarminModernData:data dtoUnits:true];

    NSDate * date = [act buildStartDateFromGarminModernData:data];
    self.time = date;

    for (GCField * field in summary) {
        GCActivitySummaryValue * value = summary[field];
        [self setNumberWithUnit:value.numberWithUnit forField:field inActivity:act];
    }
    
    NSString * style = data[@"swimStroke"];
    if ([style isKindOfClass:[NSString class]]) {
        static NSDictionary * strokeMap = nil;
        if (strokeMap == nil) {
            strokeMap = @{
                          @"FREESTYLE":@(gcSwimStrokeFree),
                          @"BUTTERFLY":@(gcSwimStrokeButterfly),
                          @"BREASTSTROKE":   @(gcSwimStrokeBreast),
                          @"BACKSTROKE":@(gcSwimStrokeBack),
                          @"MIXED": @(gcSwimStrokeMixed),
                          @"DRILL": @(gcSwimStrokeMixed),
                          };
            [strokeMap retain];
        }
        NSNumber * found = strokeMap[style];
        if (found) {
            self.directSwimStroke = [found intValue];
        }else{
            RZLog(RZLogWarning, @"Unknown stroke %@ in %@", style, act);
            self.directSwimStroke = gcSwimStrokeOther;
        }
    }
}

-(void)parseOldDict:(NSDictionary*)data forActivity:(GCActivity*)act{
    NSString * s_time = data[@"BeginTimestamp"][@"value"];
    double time70 = s_time.doubleValue;
    self.time = [NSDate dateWithTimeIntervalSince1970:time70/1e3];
    self.latitudeDegrees = 0.;
    self.longitudeDegrees = 0.;

    self.cadence = 0.;
    self.heartRateBpm = 0.;
    self.altitude = 0.;
    self.power = 0.;

    self.distanceMeters = 0.;
    self.speed = 0.;
    self.cadence = 0.;

    self.trackFlags = gcFieldFlagNone;

    NSArray * fields = [GCFields swimLapFields];

    NSMutableDictionary * found = [NSMutableDictionary dictionaryWithCapacity:fields.count];
    for (NSString * key in fields) {
        NSDictionary * tmp = data[key];
        if (tmp) {
            NSString * s_val = tmp[@"value"];
            NSString * s_uom = tmp[@"uom"];
            GCNumberWithUnit * nb = [GCNumberWithUnit numberWithUnitName:s_uom andValue:s_val.doubleValue];
            found[key] = nb;
            
            gcFieldFlag trackField = [GCFields trackFieldFromSwimLapField:key];
            if ([key isEqualToString:@"SumDuration"]) {
                self.elapsed = nb.value;
            }else if([key isEqualToString:@"SumDistance"]){
                self.distanceMeters =[nb convertToUnit:[GCUnit unitForKey:STOREUNIT_DISTANCE]].value;
            }else if (trackField == gcFieldFlagWeightedMeanHeartRate){
                self.heartRateBpm = nb.value;
            }

            if (trackField != gcFieldFlagNone){
                self.trackFlags |= trackField;
            }
            [self setNumberWithUnit:nb forField:[GCField fieldForKey:key andActivityType:act.activityType] inActivity:act];
        }
    }
    
    NSDictionary * tmp = data[@"DirectSwimStroke"];
    if (tmp) {
        self.directSwimStroke = [tmp[@"value"] intValue];
    }

}

#pragma mark - Database

-(void)updateValueFromResultSet:(FMResultSet*)res inActivity:(GCActivity*)act{
    NSString * key = [res stringForColumn:@"field"];
    NSString * uom = [res stringForColumn:@"uom"];
    double val = [res doubleForColumn:@"value"];

    GCField * field = [GCField fieldForKey:key andActivityType:act.activityType];
    GCNumberWithUnit * nb = [GCNumberWithUnit numberWithUnit:[GCUnit unitForKey:uom] andValue:val];
    
    if ([key isEqualToString:@"SumDistance"]) {
        self.distanceMeters = val;
    }else if ([key isEqualToString:@"WeightedMeanSpeed"] || [key isEqualToString:@"WeightedMeanPace"]){
        self.speed = [[GCNumberWithUnit numberWithUnitName:uom andValue:val] convertToUnitName:@"mps"].value;
    }
    [self setNumberWithUnit:nb forField:field inActivity:act];
}

-(void)fixupDrillData:(NSDate*)time inActivity:(GCActivity*)act{
    GCField * speedf = [GCField fieldForKey:@"WeightedMeanSpeed" andActivityType:act.activityType];
    GCField * pacef  = [GCField fieldForKey:@"WeightedMeanPace" andActivityType:act.activityType];
    GCNumberWithUnit * nb =  [self numberWithUnitForField:speedf inActivity:act];
    if (self.directSwimStroke==gcSwimStrokeOther ){
        // 30sec / 25m. 100/25
        GCNumberWithUnit * pace = [GCNumberWithUnit numberWithUnitName:@"min100m" andValue:self.elapsed/60. / self.distanceMeters*100.];
        [self setNumberWithUnit:pace forField:pacef inActivity:act];
        [self setNumberWithUnit:[pace convertToUnit:nb.unit] forField:speedf inActivity:act];
        self.time = time;
    }
}

-(GCTrackPointSwim*)initWithResultSet:(FMResultSet*)res{
    self = [super init];
    if (self) {
        // If updating this, also update GCLapSwim
        self.lapIndex = [res intForColumn:@"lap"];
        self.time = [res dateForColumn:@"Time"];
        self.elapsed = [res doubleForColumn:@"SumDuration"];
        self.directSwimStroke = [res intForColumn:@"DirectSwimStroke"];
        self.lengthIdx = [res intForColumn:@"length"];
    }
    return self;
}

-(void)saveToDb:(FMDatabase *)trackdb{
    [self saveLengthToDb:trackdb index:self.lengthIdx];
}

-(BOOL)useLengthTable{
    return true;
}

-(void)saveLengthToDb:(FMDatabase *)trackdb index:(NSUInteger)idx{
    // Prepare to share the code with lap
    NSString * tableMidFix = @"length";
    
    NSString * sqlInfo = [NSString stringWithFormat:@"INSERT INTO gc_%@_info (lap,length,field,value,uom) VALUES (?,?,?,?,?)",
                          tableMidFix
                          ];
    
    NSString * sql = [NSString stringWithFormat:@"INSERT INTO gc_%@ (length,Time,SumDuration,lap,DirectSwimStroke) VALUES (?,?,?,?,?)",
                      tableMidFix];
    
    for (GCField * field in self.extra) {
        GCNumberWithUnit * nb = self.extra[field];
        if (![trackdb executeUpdate:sqlInfo,
              @(self.lapIndex),
              @(idx),
              field.key,
              [nb number],
              (nb.unit).key]){
            RZLog( RZLogError, @"Failed sql %@",[trackdb lastErrorMessage]);
        }
    }
    
    NSArray<GCField*>*native = [GCFields availableFieldsIn:self.trackFlags forActivityType:GC_TYPE_SWIMMING];
    for (GCField * field in native) {
        if( field.fieldFlag != gcFieldFlagNone && self.extra[field] == nil){
            GCNumberWithUnit * nb = [self numberWithUnitForField:field.fieldFlag andActivityType:GC_TYPE_SWIMMING];
            if( nb ){
                // VERY SCARY... need to reorg, here nil activity works because gcFieldFlag != None
                // This is to account for cases like HR where on import it get saved into the class member double values
                // as opposed to extra.
                // We need to revamp the whole saving mecanism to be more consistent whether field
                // come from member double or extra dictionary. This is bad design and difference between swim points
                // and regular gps points.
                if (![trackdb executeUpdate:sqlInfo,
                      @(self.lapIndex),
                      @(idx),
                      field.key,
                      [nb number],
                      (nb.unit).key]){
                    RZLog( RZLogError, @"Failed sql %@",[trackdb lastErrorMessage]);
                }
            }
        }
    }
    
    if( self.distanceMeters > 0){
        // special case as distance otherwise not covered for swim
        if (![trackdb executeUpdate:sqlInfo,
              @(self.lapIndex),
              @(idx),
              @"SumDistance",
              @(self.distanceMeters),
              @"meter"]){
            RZLog( RZLogError, @"Failed sql %@",[trackdb lastErrorMessage]);
        }
    }
    if (![trackdb executeUpdate:sql,
          @(idx),
          self.time,
          @(self.elapsed),
          @(self.lapIndex),
          @(self.directSwimStroke)
          ]){
        RZLog( RZLogError, @"Failed sql %@",[trackdb lastErrorMessage]);
    };
}

#pragma mark - Access Set Value

-(BOOL)active{
    return self.distanceMeters > 0.;
}

@end
