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
static NSDictionary * _cacheLapFieldToFieldMap = nil;
static NSDictionary * _cacheFieldToLapFieldMap = nil;
static NSArray * _cacheSwimLapField = nil;

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

+(void)registerMissingField:(GCField*)field displayName:(NSString*)aName andUnitName:(NSString*)uom{
    [_fieldCache registerMissingField:field displayName:aName andUnitName:uom];

}

#pragma mark -

+(NSArray*)knownFieldsMatching:(NSString*)str{
    return [_fieldCache knownFieldsMatching:str];
}

+(NSDictionary<GCField*,GCFieldInfo*>*)missingPredefinedField{
    return [_fieldCache missingPredefinedField];
}

+(NSString*)activityTypeDisplay:(NSString*)aType{
    if (!aType) {
        RZLog(RZLogWarning, @"nil type");
        return @"ERROR";
    }
    return [[_fieldCache infoForActivityType:aType] displayName];
}

#pragma mark - Field Properties


+(NSArray<GCFieldsForCategory*>*)categorizeAndOrderFields:(NSArray<GCField*>*)fields forActivityType:(NSString*)activityType{
    NSMutableDictionary * categories = [NSMutableDictionary dictionary];

    for (GCField * field in fields) {
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


#pragma mark - gcFieldFlag


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

//NEWTRACKFIELD  avoid gcFieldFlag if possible
#define FLAGS_COUNT 12

+(NSArray<GCField*>*)availableFieldsIn:(NSUInteger)flag forActivityType:(NSString*)atype{
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
            [rv addObject:[GCField fieldForFlag:valid[c] andActivityType:atype]];
        }
    }
    return [NSArray arrayWithArray:rv];
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


@end
