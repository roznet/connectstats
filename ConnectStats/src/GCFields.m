//  MIT Licence
//
//  Created on 04/10/2012.
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

#import "GCFields.h"
#import "GCFieldsForCategory.h"
#import "GCFieldInfo.h"
#import "GCFieldCache.h"
#import "GCHealthMeasure.h"

static GCFieldCache * _fieldCache = nil;
static NSDictionary * _activityFromTrack = nil;
static NSDictionary * _cacheLapFieldToFieldMap = nil;
static NSDictionary * _cacheFieldToLapFieldMap = nil;
static NSArray * _cacheSwimLapField = nil;
static NSDictionary * _calcToField = nil;
static NSDictionary * _fieldToCalc = nil;

gcFieldFlag gcAggregatedFieldToFieldFlag[gcAggregatedFieldEnd] = {
    gcFieldFlagSumDistance,
    gcFieldFlagSumDuration,
    gcFieldFlagWeightedMeanHeartRate,
    gcFieldFlagWeightedMeanSpeed,
    gcFieldFlagCadence,
    gcFieldFlagAltitudeMeters,
    gcFieldFlagTennisShots,
    gcFieldFlagTennisPower,
    gcFieldFlagSumStep
};

@implementation GCFields

+(GCFieldCache*)fieldCache{
    return _fieldCache;
}
+(void)setFieldCache:(GCFieldCache*)cache{
    if (cache != _fieldCache) {
        RZRelease(_fieldCache);
        _fieldCache = cache;
        RZRetain(cache);
    }
}

+(void)ensureDbStructure:(FMDatabase*)db{
    if (![db tableExists:@"gc_fields"]) {
        [db executeUpdate:@"CREATE TABLE gc_fields (field TEXT, activityType TEXT, fieldDisplayName TEXT, uom TEXT)"];
    }
}

+(void)registerField:(NSString*)field activityType:(NSString*)aType displayName:(NSString*)aName  andUnitName:(NSString*)uom{
    [_fieldCache registerField:field activityType:aType displayName:aName andUnitName:uom];
}

#pragma mark -

+(NSArray*)knownFieldsMatching:(NSString*)str{
    return [_fieldCache knownFieldsMatching:str];
}

+(BOOL)knownField:(NSString*)field activityType:(NSString*)activityType{
    if( [_fieldCache knownField:field activityType:activityType]){
        return true;
    }
    if ([GCHealthMeasure isHealthField:field]) {
        return true;
    }
    return false;
}
+(NSString*)fieldUnitName:(NSString*)field activityType:(NSString*)activityType{
    if ([GCHealthMeasure isHealthField:field]) {
        return [GCHealthMeasure measureUnit:[GCHealthMeasure measureTypeFromHealthFieldKey:field]].key;
    }

    return [[_fieldCache infoForField:field andActivityType:activityType] uom];
}
+(NSString*)fieldDisplayName:(NSString*)field activityType:(NSString*)aType{
    return [[_fieldCache infoForField:field andActivityType:aType] displayName];
}

+(NSArray*)missingPredefinedField{
    return [_fieldCache missingPredefinedField];
}

+(GCUnit*)fieldUnit:(NSString*)field  activityType:(NSString*)activityType{
    if ([GCHealthMeasure isHealthField:field]) {
        return [GCHealthMeasure measureUnit:[GCHealthMeasure measureTypeFromHealthFieldKey:field]];
    }

    GCUnit * rv = [[[_fieldCache infoForField:field andActivityType:activityType] unit] unitForGlobalSystem];

    if ([field hasSuffix:@"Elevation"] && [rv.key isEqualToString:@"yard"]){
        rv = [GCUnit unitForKey:@"foot"];
    }

    return rv;
}

+(NSString*)fieldDisplayNameAndUnits:(NSString *)fieldStr activityType:(NSString*)aType unit:(GCUnit*)unit{
    return [[GCField fieldForKey:fieldStr andActivityType:aType] displayNameWithUnits:unit];
}

+(NSString*)fieldDisplayNameAndUnits:(NSString *)fieldStr activityType:(NSString*)aType{
    GCUnit * unit = [GCFields fieldUnit:fieldStr activityType:aType];
    return [GCFields fieldDisplayNameAndUnits:fieldStr activityType:aType unit:unit];
}


+(NSString*)activityTypeDisplay:(NSString*)aType{
    if (!aType) {
        RZLog(RZLogWarning, @"nil type");
        return @"ERROR";
    }
    return [[_fieldCache infoForActivityType:aType] displayName];
}

#pragma mark - Field Properties


//NEWTRACKFIELD  avoid gcFieldFlag if possible
+(BOOL)trackFieldCanSum:(gcFieldFlag)field{
    switch (field) {
        case gcFieldFlagAltitudeMeters:
        case gcFieldFlagSumDistance:
        case gcFieldFlagSumDuration:
        case gcFieldFlagSumStrokes:
        case gcFieldFlagSumEfficiency:
        case gcFieldFlagTennisShots:
        case gcFieldFlagSumStep:
            return true;

        case gcFieldFlagCadence:
        case gcFieldFlagGroundContactTime:
        case gcFieldFlagNone:
        case gcFieldFlagPower:
        case gcFieldFlagTennisEnergy:
        case gcFieldFlagSumSwolf:
        case gcFieldFlagTennisPower:
        case gcFieldFlagTennisRegularity:
        case gcFieldFlagVerticalOscillation:
        case gcFieldFlagWeightedMeanHeartRate:
        case gcFieldFlagWeightedMeanSpeed:
            return false;

    }
    return false;
}

+(NSString*)calcOrFieldFor:(NSString*)field{
    if (_calcToField==nil) {
        _calcToField =     @{CALC_NORMALIZED_POWER:@"WeightedMeanNormalizedPower",
                              CALC_ALTITUDE_GAIN:@"GainElevation",
                              CALC_ALTITUDE_LOSS:@"LossElevation",
                              CALC_STRIDE_LENGTH:@"WeightedMeanStrideLength"
                             };
        RZRetain(_calcToField);
        _fieldToCalc = RZReturnRetain([_calcToField dictionarySwappingKeysForObjects]);
    }

    return _calcToField[field] ?: _fieldToCalc[field];
}

+(NSArray<GCFieldsForCategory*>*)categorizeAndOrderFields:(NSArray*)fields forActivityType:(NSString*)activityType{
    NSMutableDictionary * categories = [NSMutableDictionary dictionary];

    for (id one in fields) {
        GCField * field = nil;
        if ([one isKindOfClass:[GCField class]]){
            field = one;
        }else{
            field = [GCField field:one forActivityType:activityType];
        }
        NSString * category = field.category;

        if (category) {
            GCFieldsForCategory * categoryFields = categories[category];
            if (!categoryFields) {
                categoryFields = [[GCFieldsForCategory alloc] init];
                categoryFields.category = category;
                categories[category] = categoryFields;
                RZRelease(categoryFields);
            }
            [categoryFields addField:field];
        }
    }

    NSDictionary * category2Order = [GCFieldsCategory categoryOrder];

    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray * categoriesSorted = [NSMutableArray arrayWithArray:categories.allKeys];
    [categoriesSorted sortUsingComparator:^(NSString*c1,NSString*c2){
        //FIXME: missing category
        return [category2Order[c1] compare:category2Order[c2]];
    }];

    for (NSString * category in categoriesSorted) {
        GCFieldsForCategory * orderedFields = categories[category];
        if ([category isEqualToString:GC_CATEGORY_IGNORE]) {
            continue;
        }
        if([category isEqualToString:GC_CATEGORY_OTHER]) {
            [GCFields reportOtherFields:orderedFields.fields activityType:activityType];
        }
        [rv addObject:orderedFields];
    }
    return rv;
}

+(void)reportOtherFields:(NSArray*)fields activityType:(NSString*)aType{
    static NSMutableDictionary * reported = nil;
    if (reported==nil) {
        reported = [NSMutableDictionary dictionary];
        RZRetain(reported);
    }
    for (GCField * field in fields) {
        if (!reported[field]) {
            // To Fix add to fields_order.db and rerun build.py
            // INSERT INTO fields_order (field,displayOrder,category) VALUES( 'fieldkey',-1,'ignore' );
            if( [field isKindOfClass:[GCField class]] ){
                RZLog(RZLogInfo, @"Non Categorized field[%@] VALUES('%@',-1,'ignore')", field.activityType,  field.key );
            }else{
                RZLog(RZLogInfo, @"Non Categorized field[%@]", field );
            }
            reported[field] = field;
        }
    }
}

+(BOOL)skipField:(NSString*)field{
    return [field isEqualToString:@"BeginTimestamp"]
        || [field isEqualToString:@"EndTimestamp"]
        || [field hasSuffix:@"Latitude"]
        || [field hasSuffix:@"Longitude"]
        || [field hasPrefix:@"Difference"]
        || [field hasPrefix:@"SumSample"]
        || [field isEqualToString:@"MinPace"];
}

+(NSString*)field:(NSString*)field withIntensity:(gcIntensityLevel)level{
    NSString * rv = nil;
    switch (level) {
        case gcIntensityInactive:
            return nil;
        case gcIntensityLightlyActive:
            rv = [NSString stringWithFormat:@"%@LightlyActive", field];
            break;
        case gcIntensityModeratelyActive:
            rv = [NSString stringWithFormat:@"%@ModeratelyActive", field];
            break;
        case gcIntensityVeryActive:
            rv = [NSString stringWithFormat:@"%@VeryActive", field];
            break;
    }
    return rv;
}

#pragma mark - gcFieldFlag


//NEWTRACKFIELD  avoid gcFieldFlag if possible. this should not be required now as trackfield should be deduced from GCField
+(gcFieldFlag)trackFieldFromActivityField:(NSString*)aActivityField{
    if (!_activityFromTrack) {
        _activityFromTrack = @{@"SumDistance":                     @(gcFieldFlagSumDistance),
                                @"SumDuration":                     @(gcFieldFlagSumDuration),
                                @"WeightedMeanHeartRate":           @(gcFieldFlagWeightedMeanHeartRate),
                                @"WeightedMeanPace":                @(gcFieldFlagWeightedMeanSpeed),
                                @"WeightedMeanSpeed":               @(gcFieldFlagWeightedMeanSpeed),
                                @"WeightedMeanRunCadence":          @(gcFieldFlagCadence),
                                @"WeightedMeanBikeCadence":         @(gcFieldFlagCadence),
                                @"Cadence":                         @(gcFieldFlagCadence),
                                @"Altitude":                        @(gcFieldFlagAltitudeMeters),
                                @"GainElevation":                   @(gcFieldFlagAltitudeMeters),
                                @"MinElevation":                    @(gcFieldFlagAltitudeMeters),
                                @"MaxElevation":                    @(gcFieldFlagAltitudeMeters),
                                @"WeightedMeanPower":               @(gcFieldFlagPower),
                                @"SumStep":                         @(gcFieldFlagSumStep),
                                @"WeightedMeanGroundContactTime":   @(gcFieldFlagGroundContactTime),
                                @"WeightedMeanVerticalOscillation": @(gcFieldFlagVerticalOscillation)};
        RZRetain(_activityFromTrack);

    }
    NSNumber * rv = _activityFromTrack[aActivityField];
    return (gcFieldFlag)rv.integerValue;
}

+(NSString*)trackFieldDisplayName:(gcFieldFlag)which forActivityType:(NSString*)aAct{
    return [GCFields fieldDisplayName:[GCFields fieldForFlag:which andActivityType:aAct] activityType:aAct];
}

//NEWTRACKFIELD  avoid gcFieldFlag if possible. GCField should be used to deduce the field key
+(NSString*)activityFieldFromTrackField:(gcFieldFlag)aTrackField andActivityType:(NSString*)aAct{
    switch (aTrackField) {
        case gcFieldFlagSumDistance:
            return @"SumDistance";
        case gcFieldFlagSumDuration:
            return @"SumDuration";
        case gcFieldFlagSumEfficiency:
            return @"WeightedMeanEfficiency";
        case gcFieldFlagSumStrokes:
            return @"SumStrokes";
        case gcFieldFlagSumSwolf:
            return @"WeightedMeanSwolf";
        case gcFieldFlagWeightedMeanHeartRate:
            return @"WeightedMeanHeartRate";
        case gcFieldFlagPower:
            return @"WeightedMeanPower";
        case gcFieldFlagSumStep:
            return @"SumStep";
        case gcFieldFlagWeightedMeanSpeed:{
            if ([aAct isEqualToString:GC_TYPE_RUNNING] || [aAct isEqualToString:GC_TYPE_SWIMMING]) {
                return @"WeightedMeanPace";
            }else{
                return @"WeightedMeanSpeed";
            }
        }
        case gcFieldFlagCadence:{
            if ([aAct isEqualToString:GC_TYPE_RUNNING]) {
                return @"WeightedMeanRunCadence";
            }else if ([aAct isEqualToString:GC_TYPE_SWIMMING]){
                return @"WeightedMeanSwimCadence";
            /* Used to try to mix cadence and sumstep which was confusing
             
             }else if ([aAct isEqualToString:GC_TYPE_DAY]){
                return @"SumStep";*/
            }else{
                return @"WeightedMeanBikeCadence";
            }
        }
        case gcFieldFlagAltitudeMeters:
            return @"GainElevation";
        case gcFieldFlagVerticalOscillation:
            return @"WeightedMeanVerticalOscillation";
        case gcFieldFlagGroundContactTime:
            return @"WeightedMeanGroundContactTime";
        case gcFieldFlagTennisShots:
            return @"shots";
        case gcFieldFlagTennisPower:
            return @"averagePower";
        case gcFieldFlagTennisEnergy:
            return @"energy";
        case gcFieldFlagTennisRegularity:
            return @"regularity";
        default:
            break;
    }
    return nil;
}

+(NSString*)fieldForFlag:(gcFieldFlag)which andActivityType:(NSString*)activityType{
    return [GCFields activityFieldFromTrackField:which andActivityType:activityType];
}

//NEWTRACKFIELD  avoid gcFieldFlag if possible
#define FLAGS_COUNT 12
+(gcFieldFlag)nextTrackField:(gcFieldFlag)which in:(NSUInteger)flag{
    gcFieldFlag valid[FLAGS_COUNT] = {
        gcFieldFlagNone,gcFieldFlagWeightedMeanSpeed,gcFieldFlagWeightedMeanHeartRate,
        gcFieldFlagCadence,gcFieldFlagPower,gcFieldFlagSumStrokes,
        gcFieldFlagSumSwolf,gcFieldFlagSumEfficiency,gcFieldFlagAltitudeMeters,
        gcFieldFlagGroundContactTime,gcFieldFlagVerticalOscillation,gcFieldFlagSumStep
    };
    size_t c = 0;
    for (c=0; c<FLAGS_COUNT; c++) {
        if (valid[c] == which) {
            break;
        }
    }
    for (c++; c<FLAGS_COUNT; c++) {
        if (flag & valid[c]) {
            break;
        }
    }
    if (c==FLAGS_COUNT) {
        c=0;
    }
    return valid[c];
}

+(NSArray<GCField*>*)availableFieldsIn:(NSUInteger)flag forActivityType:(NSString*)atype{
    NSArray * found = [GCFields availableTrackFieldsIn:flag];
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:found.count];
    for (NSNumber * one in found) {
        gcFieldFlag asflag = (gcFieldFlag)one.integerValue;
        [rv addObject:[GCField fieldForFlag:asflag andActivityType:atype]];
    }
    return rv;
}

//NEWTRACKFIELD avoid gcFieldFlag if possible
+(NSArray*)availableTrackFieldsIn:(NSUInteger)flag{
    gcFieldFlag valid[FLAGS_COUNT] = {
        gcFieldFlagNone,gcFieldFlagCadence,gcFieldFlagWeightedMeanHeartRate,
        gcFieldFlagWeightedMeanSpeed,gcFieldFlagPower,gcFieldFlagAltitudeMeters,
        gcFieldFlagSumStrokes,gcFieldFlagSumSwolf,gcFieldFlagSumEfficiency,
        gcFieldFlagGroundContactTime,gcFieldFlagVerticalOscillation,gcFieldFlagSumStep
    };
    size_t c = 0;
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:FLAGS_COUNT];
    for(c =1;c<FLAGS_COUNT;c++){
        if (flag & valid[c]) {
            [rv addObject:@(valid[c])];
        }
    }
    return [NSArray arrayWithArray:rv];
}
+(NSArray*)describeTrackFields:(gcFieldFlag)flag forActivityType:(NSString*)aType{
    NSArray * fields = [GCFields availableTrackFieldsIn:flag];
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:fields.count];
    for (NSNumber * n in fields) {
        gcFieldFlag f = n.intValue;
        [rv addObject:[GCFields activityFieldFromTrackField:f andActivityType:aType]];
    }
    return rv;
}

#pragma mark - swimLapFields

+(NSArray*)swimLapFields{
    if (!_cacheSwimLapField) {
        _cacheSwimLapField = @[
                              //@"totalLengths",
                              //@"active",

                              //@"BeginTimestamp",
                              //@"EndTimestamp",

                              //@"DirectSwimStroke",

                              @"MaxPace",
                              @"MaxSpeed",
                              @"MaxSwimCadence",
                              @"MinEfficiency",
                              @"MinSwolf",
                              @"SumDistance",
                              @"SumDuration",
                              @"SumEfficiency",
                              @"SumEnergy",
                              @"SumMovingDuration",
                              @"SumNumActiveLengths",
                              @"SumNumLengths",
                              @"SumStrokes",
                              @"WeightedMeanEfficiency",
                              @"WeightedMeanPace",
                              @"WeightedMeanSpeed",
                              @"WeightedMeanStrokes",
                              @"WeightedMeanSwimCadence",
                              @"WeightedMeanSwolf",
                              @"WeightedMeanHeartRate"
                              ];
        RZRetain(_cacheSwimLapField);


    }
    return _cacheSwimLapField;
}

//NEWTRACKFIELD avoid gcFieldFlag if possible
+(gcFieldFlag)trackFieldFromSwimLapField:(NSString*)f{
    static NSDictionary * dict = nil;
    if (dict==nil) {
        dict = @{@"SumDistance":                        @(gcFieldFlagSumDistance),
                  @"SumDuration":                        @(gcFieldFlagSumDuration),
                  @"SumEfficiency":                      @(gcFieldFlagSumEfficiency),
                  @"SumStrokes":                         @(gcFieldFlagSumStrokes),
                  @"WeightedMeanVerticalOscillation":    @(gcFieldFlagVerticalOscillation),
                  @"WeightedMeanGroundContactTime":      @(gcFieldFlagGroundContactTime),
                  @"WeightedMeanEfficiency":             @(gcFieldFlagSumEfficiency),
                  @"WeightedMeanPace":                   @(gcFieldFlagWeightedMeanSpeed),
                  @"WeightedMeanSpeed":                  @(gcFieldFlagWeightedMeanSpeed),
                  @"WeightedMeanStrokes":                @(gcFieldFlagSumStrokes),
                  @"WeightedMeanSwimCadence":            @(gcFieldFlagCadence),
                  @"WeightedMeanSwolf":                  @(gcFieldFlagSumSwolf),
                  @"WeightedMeanHeartRate":              @(gcFieldFlagWeightedMeanHeartRate),

                  @"SumStep":                            @(gcFieldFlagSumStep),
                  } ;
        RZRetain(dict);
    }


    return (gcFieldFlag)[dict[f] integerValue];
}

+(NSString*)swimLapFieldFromTrackField:(gcFieldFlag)tfield{
    switch (tfield) {
        case gcFieldFlagSumEfficiency:
            return @"SumEfficiency";
        case gcFieldFlagSumStrokes:
            return @"SumStrokes";
        case gcFieldFlagSumSwolf:
            return @"WeightedMeanSwolf";
        case gcFieldFlagWeightedMeanSpeed:
            return @"WeightedMeanSpeed";
        case gcFieldFlagCadence:
            return @"WeightedMeanSwimCadence";
        case gcFieldFlagSumDistance:
            return @"SumDistance";
        case gcFieldFlagSumDuration:
            return @"SumDuration";
        case gcFieldFlagWeightedMeanHeartRate:
            return @"WeightedMeanHeartRate";
        default:
            break;
    }
    return nil;
}

+(NSString*)swimStrokeName:(gcSwimStrokeType)tp{
    switch (tp) {
        case gcSwimStrokeFree:
            return NSLocalizedString(@"Freestyle",      @"Swim Stroke");
        case gcSwimStrokeBreast:
            return NSLocalizedString(@"Breaststroke",   @"Swim Stroke");
        case gcSwimStrokeButterfly:
            return NSLocalizedString(@"Butterfly",      @"Swim Stroke");
        case gcSwimStrokeBack:
            return NSLocalizedString(@"Backstroke",     @"Swim Stroke");
        case gcSwimStrokeOther:
            return NSLocalizedString(@"Drill",          @"Swim Stroke");
        default:
            return NSLocalizedString(@"Mixed",          @"Swim Stroke");
    }
    return NSLocalizedString(@"Mixed", @"Swim Stroke");
}

#pragma mark - lapFields

+(void)buildLapCache{
    _cacheLapFieldToFieldMap = @{@"WeightedMeanRunCadence": @"AvgRunCadence",
                                 @"SumEnergy": @"Calories",
                                 @"MaxRunCadence": @"MaxRunCadence",
                                 @"MaxHeartRate": @"MaximumHeartRateBpm",
                                 @"MaxSpeed": @"MaximumSpeed",
                                 @"SumSteps": @"Steps",
                                 @"SumDuration": @"TotalTimeSeconds"};
    RZRetain(_cacheLapFieldToFieldMap);
    NSMutableDictionary * reverse = [NSMutableDictionary dictionaryWithCapacity:10];
    for (NSString*f in _cacheLapFieldToFieldMap) {
        reverse[_cacheLapFieldToFieldMap[f]] = f;
    }
    _cacheFieldToLapFieldMap = [NSDictionary dictionaryWithDictionary:reverse];
    RZRetain(_cacheFieldToLapFieldMap);

}

+(NSString*)lapFieldForField:(NSString*)field{
    if (!_cacheLapFieldToFieldMap) {
        [GCFields buildLapCache];
    }
    return _cacheLapFieldToFieldMap[field];
}

+(NSString*)fieldForLapField:(NSString*)field andActivityType:(NSString*)aType{
    if (!_cacheLapFieldToFieldMap) {
        [GCFields buildLapCache];
    }
    return _cacheFieldToLapFieldMap[field] ?: field;
}
+(GCUnit*)unitForLapField:(NSString*)field activityType:(NSString*)aType{
    if (!_cacheLapFieldToFieldMap) {
        [GCFields buildLapCache];
    }

    GCUnit * found = [GCField fieldForKey:[GCFields fieldForLapField:field andActivityType:aType] andActivityType:aType].unit;
    return found ?: [GCUnit unitForKey:@"dimensionless"];
}

#pragma mark - gcAggregatedField

+(NSString*)fieldForAggregatedField:(gcAggregatedField)which andActivityType:(NSString*)actType{
    switch (which) {
        case gcAggregatedWeightedSpeed:
            if ([actType isEqualToString:GC_TYPE_RUNNING] || [actType isEqualToString:GC_TYPE_SWIMMING]) {
                return @"WeightedMeanPace";
            }else{
                return @"WeightedMeanSpeed";
            }
            break;
        case gcAggregatedWeightedHeartRate:
            return @"WeightedMeanHeartRate";
        case gcAggregatedSumDistance:
            return @"SumDistance";
        case gcAggregatedSumDuration:
            return @"SumDuration";
        case gcAggregatedTennisPower:
            return @"averagePower";
        case gcAggregatedTennisShots:
            return @"shots";
        case gcAggregatedCadence:
            return [GCFields fieldForFlag:gcFieldFlagCadence andActivityType:actType];
        case gcAggregatedAltitudeMeters:
            return @"GainElevation";
        case gcAggregatedFieldEnd:
            return nil;
        case gcAggregatedSumStep:
            return @"SumStep";
    }
    return nil;
}

+(NSString*)metaFieldDisplayName:(NSString*)metaField{
    if ([metaField isEqualToString:@"device"]) {
        return @"Device";
    }else if ([metaField isEqualToString:@"activityType"]){
        return @"Activity Type";
    }else if ([metaField isEqualToString:@"eventType"]){
        return @"Event Type";
    }else if ([metaField isEqualToString:@"activityDescription"]){
        return @"Activity Description";
    }else if ([metaField isEqualToString:@"username"]){
        return @"User name";
    }
    return metaField;
}

+(NSString*)predefinedDisplayNameForField:(NSString*)afield andActivityType:(NSString*)atype{
    static NSDictionary * cache = nil;
    if (cache==nil) {
        FMDatabase * db = [FMDatabase databaseWithPath:[RZFileOrganizer bundleFilePath:@"fields.db"]];
        [db open];
        NSString * language = [[NSLocale preferredLanguages][0] substringToIndex:2];
        NSString * table = [NSString stringWithFormat:@"gc_fields_%@", language];
        if (![db tableExists:table]) {
            table = @"gc_fields_en";
        }
        FMResultSet * res = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@", table]];
        NSMutableDictionary * rv  = [NSMutableDictionary dictionaryWithCapacity:100];
        while ([res next]) {
            NSString * field = [res stringForColumn:@"field"];
            NSString * type  = [res stringForColumn:@"activityType"];
            GCFieldInfo * info = [GCFieldInfo fieldInfoFor:field
                                                      type:type
                                               displayName:[res stringForColumn:@"fieldDisplayName"]
                                               andUnitName:nil];
            rv[[field stringByAppendingString:type]] = info;
        }
        cache = RZReturnRetain(rv);
        [db close];
    }
    GCFieldInfo * info = cache[[afield stringByAppendingString:atype]];
    if (info) {
        return info.displayName;
    }
    info = cache[[afield stringByAppendingString:GC_TYPE_ALL]];
    if (info) {
        return info.displayName;
    }
    if( [afield rangeOfString:@"_"].location == NSNotFound){
        NSString * rv = [afield fromCamelCaseToSeparatedByString:@" "];
        if( [rv hasPrefix:@"WeightedMean"]){
            rv = [rv stringByReplacingOccurrencesOfString:@"WeightedMean" withString:@"Avg"];
        }
                  return rv;
    }else{
        return [afield dashSeparatedToSpaceCapitalized];
    }
    return nil;
}
+(NSString*)predefinedUomForField:(NSString*)afield andActivityType:(NSString*)atype{
    static NSDictionary * cache = nil;
    if (cache==nil) {
        FMDatabase * db = [FMDatabase databaseWithPath:[RZFileOrganizer bundleFilePath:@"fields.db"]];
        [db open];

        NSDictionary*(^load)(NSString*table) = ^(NSString*table){
            NSMutableDictionary * rv  = [NSMutableDictionary dictionaryWithCapacity:100];
            FMResultSet * res = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@", table]];
            while ([res next]) {
                NSString * field = [res stringForColumn:@"field"];
                NSString * type  = [res stringForColumn:@"activityType"];
                GCFieldInfo * info = [GCFieldInfo fieldInfoFor:field
                                                          type:type
                                                   displayName:nil
                                                   andUnitName:[res stringForColumn:@"uom"]];
                rv[[field stringByAppendingString:type]] = info;
            }

            return rv;
        };

        cache = @{@"statute":load(@"gc_fields_uom_statute"),@"metric":load(@"gc_fields_uom_metric")};
        RZRetain(cache);
    }
    NSString * key = [GCUnit getGlobalSystem]==GCUnitSystemImperial ? @"statute" : @"metric";

    GCFieldInfo * info = (cache[key])[[afield stringByAppendingString:atype]];
    if (info) {
        return info.uom;
    }
    info = (cache[key])[[afield stringByAppendingString:GC_TYPE_ALL]];
    if (info) {
        return info.uom;
    }
    return nil;
}

@end
