//  MIT Licence
//
//  Created on 26/02/2013.
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

#import "GCHealthMeasure.h"
#import "GCField.h"
#import "GCFieldInfo.h"
#if TARGET_OS_IPHONE
@import RZUtilsTouch;
#endif

// 1	Weight (kg)
// 4	Height (meter)
// 5	Fat Free Mass (kg)
// 6	Fat Ratio (%)
// 8	Fat Mass Weight (kg)
// 9	Diastolic Blood Pressure (mmHg)
// 10	Systolic Blood Pressure (mmHg)
// 11 : Heart Pulse (bpm)
// 54 : SP02(%)
// 71 : Body Temperature
// 76 : Muscle Mass
// 77 : Hydration
// 88 : Bone Mass
// 91 : Pulse Wave Velocity

/*
1    Weight (kg)
4    Height (meter)
5    Fat Free Mass (kg)
6    Fat Ratio (%)
8    Fat Mass Weight (kg)
9    Diastolic Blood Pressure (mmHg)
10    Systolic Blood Pressure (mmHg)
11    Heart Pulse (bpm) - only for BPM and scale devices
12    Temperature (celsius)
54    SP02 (%)
71    Body Temperature (celsius)
73    Skin Temperature (celsius)
76    Muscle Mass (kg)
77    Hydration (kg)
88    Bone Mass (kg)
91    Pulse Wave Velocity (m/s)
 
 */

typedef NS_ENUM(NSUInteger,gcHealthDefsIndex) {
    gcHealthDefsIndexWithings=0,
    gcHealthDefsIndexFieldKey=1,
    gcHealthDefsIndexDisplay=2,
    gcHealthDefsIndexStoreUnit=3
};
NSArray * measureDefs(){
    static NSArray * _cacheMeasureDefs  = nil;
    if( _cacheMeasureDefs == nil){
        _cacheMeasureDefs = @[
            @[ @(1),GC_HEALTH_PREFIX @"weight",@"Weight",@"kilogram"],
            @[ @(4),GC_HEALTH_PREFIX @"height",@"Height",@"meter"],
            @[ @(5),GC_HEALTH_PREFIX @"fat_free_mass",@"Fat Free Mass",@"kilogram"],
            @[ @(6),GC_HEALTH_PREFIX @"fat_ratio",@"Fat Ratio",@"percent"],
            @[ @(8),GC_HEALTH_PREFIX @"fat_mass_weight",@"Fat Mass Weight",@"kilogram"],
            @[ @(9),GC_HEALTH_PREFIX @"diastolic_blood_pressure",@"Diastolic Blood Pressure",@"mmHg"],
            @[ @(10),GC_HEALTH_PREFIX @"systolic_blood_pressure",@"Systolic Blood Pressure",@"mmHg"],
            @[ @(11),GC_HEALTH_PREFIX @"heart_pulse",@"Heart Pulse",@"bpm"],
            @[ @(12),GC_HEALTH_PREFIX @"temperature",@"Temperature",@"celcius"],
            @[ @(54),GC_HEALTH_PREFIX @"sp02",@"SP02",@"percent"],
            @[ @(71),GC_HEALTH_PREFIX @"body_temperature",@"Body Temperature",@"celcius"],
            @[ @(73),GC_HEALTH_PREFIX @"skin_temperature",@"Skin Temperature",@"celcius"],
            @[ @(76),GC_HEALTH_PREFIX @"muscle_mass",@"Muscle Mass",@"kilogram"],
            @[ @(77),GC_HEALTH_PREFIX @"hydration",@"Hydration",@"kilogram"],
            @[ @(88),GC_HEALTH_PREFIX @"bone_mass",@"Bone Mass",@"kilogram"],
            @[ @(91),GC_HEALTH_PREFIX @"pulse_wave_velocity",@"Pulse Wave Velocity",@"mps"],
        ];
        
        RZRetain(_cacheMeasureDefs);
    }
    return _cacheMeasureDefs;
}

GCField * fieldForWithingsMeasureType(unsigned int i){
    static NSDictionary<NSNumber*,GCField*>*cache = nil;
    if( cache == nil){
        NSMutableDictionary * newCache = [NSMutableDictionary dictionary];
        NSArray * defs = measureDefs();
        for (NSArray * one in defs) {
            newCache[ one[gcHealthDefsIndexWithings] ] = [GCField fieldForKey:one[gcHealthDefsIndexFieldKey]
                                                              andActivityType:GC_TYPE_ALL];
        }
        RZRetain(newCache);
        cache = newCache;
    }
    
    return cache[ @(i) ];
}

GCUnit * storeUnitForField(GCField*field){
    static NSDictionary<GCField*,GCUnit*>*cache = nil;
    if( cache == nil){
        NSMutableDictionary * newCache = [NSMutableDictionary dictionary];
        NSArray * defs = measureDefs();
        for (NSArray * one in defs) {
            GCField * field = [GCField fieldForKey:one[gcHealthDefsIndexFieldKey] andActivityType:GC_TYPE_ALL];
            GCUnit * unit = [GCUnit unitForKey:one[gcHealthDefsIndexStoreUnit]];
            newCache[ field ] = unit;
        }
        RZRetain(newCache);
        cache = newCache;
    }
    return cache[field];
}

#ifdef GC_USE_HEALTHKIT
GCField * fieldForHKQuantityType(HKQuantityType*type){
    static NSDictionary * map = nil;
    if (map==nil) {
        map = @{ HKQuantityTypeIdentifierBodyMass:          [GCField fieldForKey:[GC_HEALTH_PREFIX stringByAppendingString:@"weight"] andActivityType:GC_TYPE_ALL],
                 HKQuantityTypeIdentifierBodyFatPercentage: [GCField fieldForKey:[GC_HEALTH_PREFIX stringByAppendingString:@"fat_ratio"] andActivityType:GC_TYPE_ALL],
                 HKQuantityTypeIdentifierLeanBodyMass:     [GCField fieldForKey:[GC_HEALTH_PREFIX stringByAppendingString:@"fat_free_mass"] andActivityType:GC_TYPE_ALL]
                 };
        [map retain];
    }

    return map[type.identifier];

}
#endif

@implementation GCHealthMeasure

#if !__has_feature(objc_arc)
-(void)dealloc{
    [_measureId release];
    [_date release];
    [_value release];
    [_field release];
    
    [super dealloc];
}
#endif

+(BOOL)isHealthField:(id)field{
    if ([field isKindOfClass:[GCField class]]) {
        return [field isHealthField];
    }else if([field isKindOfClass:[NSString class]]){
        return [field hasPrefix:GC_HEALTH_PREFIX];
    }
    return false;
}

+(GCField*)height{
    static GCField * cache = nil;
    if( cache == nil){
        cache = RZReturnRetain([GCField fieldForKey:[GC_HEALTH_PREFIX stringByAppendingString:@"height"] andActivityType:GC_TYPE_ALL]);
    }
    return cache;
}

+(GCField*)weight{
    static GCField * cache = nil;
    if( cache == nil){
        cache = RZReturnRetain([GCField fieldForKey:[GC_HEALTH_PREFIX stringByAppendingString:@"weight"] andActivityType:GC_TYPE_ALL]);
    }
    return cache;
}
/*
+(NSString*)healthFieldKeyFromMeasureType:(gcMeasureType)type{
    return [NSString stringWithFormat:@"%@%@", GC_HEALTH_PREFIX, [GCHealthMeasure measureKeyFromType:type]];
}

+(GCField*)healthFieldFromMeasureType:(gcMeasureType)type{
    NSString * key = [GC_HEALTH_PREFIX stringByAppendingString:[GCHealthMeasure measureKeyFromType:type]];
    return [GCField fieldForKey:key andActivityType:GC_TYPE_ALL];
}

+(GCField*)healthFieldFromMeasureType:(gcMeasureType)type forActivityType:(NSString*)aType{
    NSString * key = [GC_HEALTH_PREFIX stringByAppendingString:[GCHealthMeasure measureKeyFromType:type]];
    return [GCField fieldForKey:key andActivityType:aType];
}


+(NSString*)measureKeyFromType:(gcMeasureType)type{
    if (_cacheMeasureKeys==nil) {
        buildMeasureTypeKeys();
    }
    return _cacheMeasureKeys[type];
}

+(gcMeasureType)measureTypeFromKey:(NSString*)key{
    if (_cacheMeasureTypesFromKeys==nil) {
        buildMeasureTypeKeys();
    }
    return [_cacheMeasureTypesFromKeys[key] intValue];
}
*/

+(NSDictionary<GCField*,GCFieldInfo*>*)fieldInfoForMeasureFields{
    static NSDictionary<GCField*,GCFieldInfo*>*fieldCache = nil;
    if( fieldCache == nil){
        NSArray * defs = measureDefs();

        NSMutableDictionary * build = [NSMutableDictionary dictionary];
        
        for (NSArray * one in defs) {
            GCField * field = [GCField fieldForKey:one[gcHealthDefsIndexFieldKey] andActivityType:GC_TYPE_ALL];
            NSString * displayName = one[gcHealthDefsIndexDisplay];
            GCUnit * unit = storeUnitForField(field);
            NSDictionary * units = @{@(gcUnitSystemMetric):unit};
            
            GCFieldInfo * info = [GCFieldInfo fieldInfoFor:field displayName:displayName andUnits:units];
            build[field] = info;
        }
        
        fieldCache = build;
        RZRetain(fieldCache);
    }
    return fieldCache;
}
+(GCFieldInfo*)fieldInfoFromField:(GCField *)field{
    GCFieldInfo * rv = nil;
    if (field.isHealthField) {
        NSDictionary<GCField*,GCFieldInfo*>*fieldCache = [self fieldInfoForMeasureFields];
        rv = fieldCache[field];
    }
    return rv;
}

/*
+(GCFieldInfo*)fieldInfoFromMeasureType:(gcMeasureType)type{
    NSDictionary<NSNumber*,GCFieldInfo*>*fieldCache = [self fieldInfoForMeasureTypes];;
    GCFieldInfo * rv = fieldCache[@(type)];
    return rv;
}


+(GCUnit*)storeUnit:(gcMeasureType)type{
    return [[GCHealthMeasure fieldInfoFromMeasureType:type] unitForSystem:gcUnitSystemMetric];
}

+(GCUnit*)measureUnit:(gcMeasureType)type{
    return [GCHealthMeasure fieldInfoFromMeasureType:type].unit;
}
+(NSString*)measureName:(gcMeasureType)type{
    return [GCHealthMeasure fieldInfoFromMeasureType:type].displayName;
}
*/
#ifdef GC_USE_HEALTHKIT
+(GCHealthMeasure*)healthMeasureFromHKSample:(HKQuantitySample*)sample{
    GCHealthMeasure * rv = [[[GCHealthMeasure alloc] init] autorelease];
    if (rv) {
        rv.field = fieldForHKQuantityType(sample.quantityType);
        if (rv.field==nil) {
            return nil;
        }
        rv.date = sample.startDate;
        GCUnit * unit = storeUnitForField(rv.field);
        if ([sample.quantity isCompatibleWithUnit:[unit hkUnit]]) {
            rv.value = [GCNumberWithUnit numberWithUnit:unit andQuantity:sample.quantity];
            rv.measureId = [NSString stringWithFormat:@"HealthKit%@", [sample.startDate YYYYMMDDhhmm]];
        }
    }
    return rv;
}
#endif

+(GCHealthMeasure*)healthMeasureFromWithings:(NSDictionary*)dict forDate:(NSDate*)aDate andId:(NSUInteger)aId{
    GCHealthMeasure * rv = RZReturnAutorelease([[GCHealthMeasure alloc] init]);
    if (rv) {
        NSNumber * typeN  = dict[WS_KEY_TYPE];
        NSNumber * valueN = dict[WS_KEY_VALUE];
        NSNumber * unitN  = dict[WS_KEY_UNIT];

        if (typeN && valueN && unitN && [typeN isKindOfClass:[NSNumber class]] && [valueN isKindOfClass:[NSNumber class]]&&[unitN isKindOfClass:[NSNumber class]]) {
            rv.measureId = [NSString stringWithFormat:@"%d",(int)aId];
            rv.field  = fieldForWithingsMeasureType(typeN.intValue);
            if( rv.field == nil){
                return nil;
            }
            rv.date  = aDate;
            double val = valueN.doubleValue* pow(10., unitN.doubleValue);
            GCUnit * unit = storeUnitForField(rv.field);
            rv.value = [GCNumberWithUnit numberWithUnit:unit andValue:val];
        }
    }
    return rv;
}

-(NSString*)description{
    return [NSString stringWithFormat:@"<%@: %@ %@ %@ %@>", NSStringFromClass([self class]), self.measureId, [self.date dateShortFormat],
            self.field.key, self.value];
}

+(GCHealthMeasure*)healthMeasureFromResultSet:(FMResultSet*)res{
    GCHealthMeasure * rv = RZReturnAutorelease([[GCHealthMeasure alloc] init]);
    if (rv) {
        rv.measureId = [res stringForColumn:@"measureId"];
        NSString * fieldKey = [GC_HEALTH_PREFIX stringByAppendingString:[res stringForColumn:@"measureType"]];
        rv.field = [GCField fieldForKey:fieldKey andActivityType:GC_TYPE_ALL];
        rv.date = [res dateForColumn:@"measureDate"];
        GCUnit * unit = storeUnitForField(rv.field);
        rv.value = [GCNumberWithUnit numberWithUnit:unit andValue:[res doubleForColumn:@"measureValue"]];
    }
    return rv;
}

-(void)saveToDb:(FMDatabase*)db{
    NSString * key = [self.field.key substringFromIndex:[GC_HEALTH_PREFIX length]];
    [db beginTransaction];
    if( [db intForQuery:@"SELECT count(*) FROM gc_health_measures WHERE measureId = ? and measureType = ?", self.measureId,key] > 0 ){
        [db executeUpdate:@"DELETE FROM gc_health_measures WHERE measureId = ? and measureType = ?", self.measureId,key];
    }

    // always save in storeUnit
    GCNumberWithUnit * toSave = [self.value convertToUnit:storeUnitForField(self.field)];
    
    [db executeUpdate:@"INSERT INTO gc_health_measures (measureId,measureDate,measureType,measureValue) VALUES(?,?,?,?)",
     self.measureId,
     self.date,
     key,
     @(toSave.value)
     ];
    [db commit];
}

+(void)ensureDbStructure:(FMDatabase*)db{
    if (![db tableExists:@"gc_health_measures"]) {
        [db executeUpdate:@"CREATE TABLE gc_health_measures (measureId TEXT KEY, measureDate REAL, measureType TEXT, measureValue REAL)"];
    }
}


@end
