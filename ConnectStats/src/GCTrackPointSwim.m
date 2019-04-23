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

-(void)dealloc{
    [_values release];
    [super dealloc];
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
-(void)parseModernDict:(NSDictionary*)data forActivity:(GCActivity*)act{
    NSMutableDictionary * summary = [act buildSummaryDataFromGarminModernData:data dtoUnits:true];

    NSMutableDictionary * values = [NSMutableDictionary dictionary];
    for (GCField * field in summary) {
        NSDate * date = [act buildStartDateFromGarminModernData:data];
        self.time = date;
        GCActivitySummaryValue * value = summary[field];
        values[field] = value.numberWithUnit;

        [self setNumberWithUnit:value.numberWithUnit forField:field inActivity:act];
    }
    self.values = values;
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
        }
    }
    self.values = found;
    NSDictionary * tmp = data[@"DirectSwimStroke"];
    if (tmp) {
        self.directSwimStroke = [tmp[@"value"] intValue];
    }

}

-(void)updateValueFromResultSet:(FMResultSet*)res inActivity:(GCActivity*)act{
    NSString * key = [res stringForColumn:@"field"];
    NSString * uom = [res stringForColumn:@"uom"];
    double val = [res doubleForColumn:@"value"];

    GCNumberWithUnit * nb = [GCNumberWithUnit numberWithUnit:[GCUnit unitForKey:uom] andValue:val];
    if ([key isEqualToString:@"SumDistance"]) {
        self.distanceMeters = val;
    }else if ([key isEqualToString:@"WeightedMeanSpeed"] || [key isEqualToString:@"WeightedMeanPace"]){
        self.speed = [[GCNumberWithUnit numberWithUnitName:uom andValue:val] convertToUnitName:@"mps"].value;
    }
    self.values[ [GCField fieldForKey:key andActivityType:act.activityType] ] = nb;
}

-(void)fixupDrillData:(NSDate*)time inActivity:(GCActivity*)act{
    GCField * speedf = [GCField fieldForKey:@"WeightedMeanSpeed" andActivityType:act.activityType];
    GCField * pacef  = [GCField fieldForKey:@"WeightedMeanPace" andActivityType:act.activityType];
    GCNumberWithUnit * nb = (self.values)[ speedf ];
    if (self.directSwimStroke==gcSwimStrokeOther ){
        // 30sec / 25m. 100/25
        GCNumberWithUnit * pace = [GCNumberWithUnit numberWithUnitName:@"min100m" andValue:self.elapsed/60. / self.distanceMeters*100.];
        self.values[pacef] = pace;
        self.values[speedf] = [pace convertToUnit:nb.unit];
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
        self.values = [NSMutableDictionary dictionaryWithCapacity:10];
        self.lengthIdx = [res intForColumn:@"length"];
    }
    return self;
}

-(void)saveToDb:(FMDatabase *)trackdb{
    [self saveLengthToDb:trackdb index:self.lengthIdx];
}

-(void)saveLengthToDb:(FMDatabase *)trackdb index:(NSUInteger)idx{
    for (GCField * field in self.values) {
        GCNumberWithUnit * nb = self.values[field];
        if (![trackdb executeUpdate:@"INSERT INTO gc_length_info (lap,length,field,value,uom) VALUES (?,?,?,?,?)",
              @(self.lapIndex),
              @(idx),
              field.key,
              [nb number],
              (nb.unit).key]){
            RZLog( RZLogError, @"Failed sql %@",[trackdb lastErrorMessage]);
        }
    }
    if (![trackdb executeUpdate:@"INSERT INTO gc_length (length,Time,SumDuration,lap,DirectSwimStroke) VALUES (?,?,?,?,?)",
          @(idx),
          self.time,
          @(self.elapsed),
          @(self.lapIndex),
          @(self.directSwimStroke)
          ]){
        RZLog( RZLogError, @"Failed sql %@",[trackdb lastErrorMessage]);
    };
}
-(NSArray<GCField*>*)availableFieldsInActivity:(GCActivity*)act{
    NSMutableArray<GCField*>*rv = [NSMutableArray arrayWithArray:[super availableFieldsInActivity:act]];
    if( self.values ){
        [rv addObjectsFromArray:self.values.allKeys];
    }
    return rv;
}
-(BOOL)active{
    return self.distanceMeters > 0.;
}
-(GCNumberWithUnit*)numberWithUnitForField:(GCField*)aF inActivity:(GCActivity*)act{
    GCNumberWithUnit * rv = [super numberWithUnitForField:aF inActivity:act];
    if( rv == nil){
        rv = self.values[aF];
    }
    return rv;
}
/*
-(double)valueForField:(gcFieldFlag)aField{
    GCNumberWithUnit * nb = self.values[[GCFields swimLapFieldFromTrackField:aField]];
    return nb.value;
}
-(GCUnit*)unitForField:(gcFieldFlag)aField andActivityType:(NSString*)aType{
    GCNumberWithUnit * nb = self.values[[GCFields swimLapFieldFromTrackField:aField]];
    return nb.unit;

}
-(GCNumberWithUnit*)numberWithUnitForField:(gcFieldFlag)aField andActivityType:(NSString *)aType{
    GCNumberWithUnit * nb = self.values[[GCFields swimLapFieldFromTrackField:aField]];
    return nb;
}
-(GCNumberWithUnit*)numberWithUnitForExtra:(NSString*)aF activityType:(NSString*)aType{
    GCNumberWithUnit * nb = self.values[aF];
    return nb;
}
 
-(NSDictionary*)extra{
    return self.values;
}

-(GCNumberWithUnit*)numberWithUnitForField:(GCField*)aF inActivity:(GCActivity*)act{
    GCNumberWithUnit * rv = self.values[aF.key];
    if( !rv && aF.fieldFlag != gcFieldFlagNone){
        NSString * swimField = [GCFields swimLapFieldFromTrackField:aF.fieldFlag];
        rv = self.values[swimField];
        if(!rv){
            rv = [super numberWithUnitForField:aF inActivity:act];
        }
    }
    return rv;
}*/

@end
