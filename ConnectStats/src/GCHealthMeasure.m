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
#import "RZUtilsHealthkit/RZUtilsHealthkit.h"
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
 gcMeasureNone,
 gcMeasureWeight,
 gcMeasureHeight,
 gcMeasureFatFreeMass,
 gcMeasureFatRatio,
 gcMeasureFatMassWeight
 */

#define WS_TYPE_WEIGHT          1
#define WS_TYPE_HEIGHT          4
#define WS_TYPE_FATFREE_MASS    5
#define WS_TYPE_FAT_PCT         6
#define WS_TYPE_FAT_MASS        8
#define WS_TYPE_HEART_RATE      11

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

static NSArray * _cacheMeasureKeys  = nil;
static NSDictionary * _cacheMeasureTypesFromKeys=nil;

void buildMeasureTypeKeys(){
    _cacheMeasureKeys = @[@"none",@"weight",@"height", @"fat_free_mass",@"fat_ratio",@"fat_mass_weight",@"heart_rate"];
    RZRetain(_cacheMeasureKeys);
    NSMutableDictionary * d = [NSMutableDictionary dictionaryWithCapacity:_cacheMeasureKeys.count];
    for (NSUInteger i=0; i<_cacheMeasureKeys.count; i++) {
        d[_cacheMeasureKeys[i]] = @(i);
    }
    _cacheMeasureTypesFromKeys = RZReturnRetain(d);
}

gcMeasureType measureTypeForWS(unsigned int i){
    switch (i) {
        case WS_TYPE_WEIGHT:
            return gcMeasureWeight;
        case WS_TYPE_HEIGHT:
            return gcMeasureHeight;
        case WS_TYPE_FATFREE_MASS:
            return gcMeasureFatFreeMass;
        case WS_TYPE_FAT_PCT:
            return gcMeasureFatRatio;
        case WS_TYPE_FAT_MASS:
            return gcMeasureFatMassWeight;
        case WS_TYPE_HEART_RATE:
            return gcMeasureHeartRate;
        default:
            break;
    }
    return gcMeasureNone;
}

#ifdef GC_USE_HEALTHKIT
gcMeasureType measureTypeForHK(HKQuantityType*type){
    static NSDictionary * map = nil;
    if (map==nil) {
        map = @{ HKQuantityTypeIdentifierBodyMass:          @(gcMeasureWeight),
                 HKQuantityTypeIdentifierBodyFatPercentage: @(gcMeasureFatRatio),
                 HKQuantityTypeIdentifierLeanBodyMass:      @(gcMeasureFatFreeMass)
                 };
        [map retain];
    }

    NSNumber * found = map[type.identifier];

    return found ? found.intValue : gcMeasureNone;
}
#endif

@implementation GCHealthMeasure

#if !__has_feature(objc_arc)
-(void)dealloc{
    [_measureId release];
    [_date release];
    [_value release];

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
+(gcMeasureType)measureTypeFromHealthFieldKey:(NSString*)field{
    return [GCHealthMeasure measureTypeFromKey:[field substringFromIndex:(GC_HEALTH_PREFIX).length]];
}
+(gcMeasureType)measureTypeFromHealthField:(GCField*)field{
    return [GCHealthMeasure measureTypeFromKey:[field.key substringFromIndex:(GC_HEALTH_PREFIX).length]];
}

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

+(GCFieldInfo*)fieldInfoFromMeasureType:(gcMeasureType)type{
    static NSDictionary<NSNumber*,GCFieldInfo*>*fieldCache = nil;
    if( fieldCache == nil){
        NSArray<NSString*>*fieldKeys = @[@"none",@"weight",@"height", @"fat_free_mass",@"fat_ratio",@"fat_mass_weight",@"heart_rate"];
        NSArray<NSString*>*units = @[@"dimensionless",@"kilogram",@"meter",@"kilogram",@"percent",@"kilogram",@"bpm"];
        NSArray<NSString*>*displayNames = @[@"None",@"Weight",@"Height", @"Fat Free Mass",@"Fat Ratio",@"Fat Mass Weight",@"Heart Rate"];
        
        NSUInteger size = fieldKeys.count;
        
        NSMutableDictionary * build = [NSMutableDictionary dictionary];
        
        for (NSUInteger i=0;i<size;i++) {
            GCField * field = [GCField fieldForKey:[GC_HEALTH_PREFIX stringByAppendingString:fieldKeys[i]] andActivityType:GC_TYPE_ALL];
            GCUnit * unit = [GCUnit unitForKey:units[i]];
            NSString * displayName = displayNames[i];
            
            GCFieldInfo * info = [GCFieldInfo fieldInfoFor:field displayName:displayName andUnits:@{@(GCUnitSystemMetric):unit}];
            build[@(i)] = info;
        }
        
        fieldCache = build;
        RZRetain(fieldCache);
    }
    
    GCFieldInfo * rv = fieldCache[@(type)];
    return rv;
}

+(GCFieldInfo*)fieldInfoFromField:(GCField *)field{
    GCFieldInfo * rv = nil;
    if (field.isHealthField) {
        gcMeasureType type = [GCHealthMeasure measureTypeFromHealthField:field];

        rv = [GCHealthMeasure fieldInfoFromMeasureType:type];
    }
    return rv;
}

+(GCUnit*)measureUnit:(gcMeasureType)type{
    return [GCHealthMeasure fieldInfoFromMeasureType:type].unit;
}
+(NSString*)measureName:(gcMeasureType)type{
    return [GCHealthMeasure fieldInfoFromMeasureType:type].displayName;
}

#ifdef GC_USE_HEALTHKIT
+(GCHealthMeasure*)healthMeasureFromHKSample:(HKQuantitySample*)sample{
    GCHealthMeasure * rv = [[[GCHealthMeasure alloc] init] autorelease];
    if (rv) {
        rv.type = measureTypeForHK(sample.quantityType);
        if (rv.type==gcMeasureNone) {
            return nil;
        }
        rv.date = sample.startDate;
        GCUnit * unit = [GCHealthMeasure measureUnit:rv.type];
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
            rv.type  = measureTypeForWS(typeN.intValue);
            rv.date  = aDate;
            double val = valueN.doubleValue* pow(10., unitN.doubleValue);
            rv.value = [GCNumberWithUnit numberWithUnit:[GCHealthMeasure measureUnit:rv.type] andValue:val];
        }
    }
    return rv;
}

-(NSString*)description{
    return [NSString stringWithFormat:@"<%@: %@ %@ %@ %@>", NSStringFromClass([self class]), self.measureId, [self.date dateShortFormat],
            [GCHealthMeasure measureKeyFromType:self.type], self.value];
}

+(GCHealthMeasure*)healthMeasureFromResultSet:(FMResultSet*)res{
    GCHealthMeasure * rv = RZReturnAutorelease([[GCHealthMeasure alloc] init]);
    if (rv) {
        rv.measureId = [res stringForColumn:@"measureId"];
        rv.type = [GCHealthMeasure measureTypeFromKey:[res stringForColumn:@"measureType"]];
        rv.date = [res dateForColumn:@"measureDate"];
        rv.value = [GCNumberWithUnit numberWithUnit:[GCHealthMeasure measureUnit:rv.type] andValue:[res doubleForColumn:@"measureValue"]];
    }
    return rv;
}
-(void)saveToDb:(FMDatabase*)db{
    NSString * key = [GCHealthMeasure measureKeyFromType:self.type];
    [db beginTransaction];
    if( [db intForQuery:@"SELECT count(*) FROM gc_health_measures WHERE measureId = ? and measureType = ?", self.measureId,key] > 0 ){
        [db executeUpdate:@"DELETE FROM gc_health_measures WHERE measureId = ? and measureType = ?", self.measureId,key];
    }

    [db executeUpdate:@"INSERT INTO gc_health_measures (measureId,measureDate,measureType,measureValue) VALUES(?,?,?,?)",
     self.measureId,
     self.date,
     key,
     @(self.value.value)
     ];
    [db commit];
}

+(void)ensureDbStructure:(FMDatabase*)db{
    if (![db tableExists:@"gc_health_measures"]) {
        [db executeUpdate:@"CREATE TABLE gc_health_measures (measureId TEXT KEY, measureDate REAL, measureType TEXT, measureValue REAL)"];
    }
}


@end
