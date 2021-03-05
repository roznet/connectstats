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
        }else{
            [self parseDict:data inActivity:act];
        }
    }
    return self;
}

-(GCLap*)initWithSummaryValues:(NSDictionary*)summary
                      starting:(NSDate*)start
                            at:(CLLocationCoordinate2D)coord
                   forActivity:(GCActivity*)act {
    self = [super init];
    if (self) {
        for (GCField * field in summary) {
            GCActivitySummaryValue * value = summary[field];
            GCNumberWithUnit * num = value.numberWithUnit;
            [self setNumberWithUnit:num forField:field inActivity:act];
        }
        self.time  = start;
        self.latitudeDegrees = coord.latitude;
        self.longitudeDegrees = coord.longitude;
    }
    return self;
    
}

-(GCLap*)initWithResultSet:(FMResultSet*)res{
    return [super initWithResultSet:res];;
}

-(NSString*)displayLabel{
    return self.label ?: [NSString stringWithFormat:NSLocalizedString(@"Lap %lu", @"Lap Annotation Callout"), self.lapIndex];
}

#pragma mark - Parsing


-(void)recordField:(GCField*)field withUnit:(GCUnit*)unit inActivity:(GCActivity*)act{
    // Override track point record, as for lap we will have more fields
    // and we don't want them to be recorded as trackfields
}

-(void)parseModernDict:(NSDictionary*)data inActivity:(GCActivity*)act{

    NSMutableDictionary * summary = [act buildSummaryDataFromGarminModernData:data dtoUnits:true];
    
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
                [GCFields registerMissingField:field displayName:display andUnitName:uom];
                
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

@end
