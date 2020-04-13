//  MIT Licence
//
//  Created on 01/01/2016.
//
//  Copyright (c) 2016 Brice Rosenzweig.
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

#import "GCField.h"
#import "GCFieldsCategory.h"
#import "GCHealthMeasure.h"
#import "GCFieldCache.h"

#define GC_TYPE_NULL @"<NULL>"

static NSMutableDictionary<id<NSCopying>,NSMutableDictionary*> * _cache = nil;
static GCFieldCache * _fieldCache = nil;

static void registerInCache(GCField*field){
    if (_cache == nil) {
        _cache = [NSMutableDictionary dictionary];
        RZRetain(_cache);
    }
    NSMutableDictionary * dict = _cache[field.key];
    NSString * aType = field.activityType ?: GC_TYPE_NULL;
    if (!dict) {
        dict = [NSMutableDictionary dictionaryWithDictionary:@{aType:field}];
        _cache[field.key] = dict;
    }else{
        if(field){
            dict[aType] = field;
        }

    }
    if (field.fieldFlag!=gcFieldFlagNone) {
        if( field.fieldFlag == gcFieldFlagCadence && [field.key isEqualToString:@"WeightedMeanCadence"]){
            RZLog(RZLogWarning, @"Registering %@ for cadence", field);
        }
        dict = _cache[@(field.fieldFlag)];
        if (!dict) {
            dict = [NSMutableDictionary dictionaryWithDictionary:@{aType:field}];
            _cache[@(field.fieldFlag)]=dict;
        }else{
            if (dict[aType]) {
                RZLog(RZLogWarning, @"Duplicate now:%@, before:%@", field, dict[aType]);
            }
            dict[aType] = field;
        }
    }
}
@interface GCField ()

@property (nonatomic,retain) NSString * key;
@property (nonatomic,retain) NSString * activityType;
@property (nonatomic,assign) gcFieldFlag fieldFlag;

@end

#define kGCFieldKey @"fieldKey"
#define kGCActivityType @"activityType"
#define kGCFieldFlag @"fieldFlag"
#define kGCVersion @"version"

@implementation GCField

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
+(BOOL)supportsSecureCoding{
    return YES;
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.key = [aDecoder decodeObjectOfClass:[NSString class] forKey:kGCFieldKey];
        self.activityType = [aDecoder decodeObjectOfClass:[NSString class] forKey:kGCActivityType];
        self.fieldFlag = (gcFieldFlag)[aDecoder decodeInt64ForKey:kGCFieldFlag];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeInt:1 forKey:kGCVersion];
    [aCoder encodeObject:self.key forKey:kGCFieldKey];
    [aCoder encodeObject:self.activityType forKey:kGCActivityType];
    [aCoder encodeInt64:self.fieldFlag forKey:kGCFieldFlag];
}

#pragma mark - NSDictionary key

-(instancetype)copyWithZone:(NSZone *)zone{
    GCField * rv = [[[self class] alloc] init];
    if (rv) {
        rv.key = RZReturnAutorelease([self.key copyWithZone:zone]);
        rv.activityType = RZReturnAutorelease([self.activityType copyWithZone:zone]);
        rv.fieldFlag = self.fieldFlag;
    }
    return  rv;
}

-(NSUInteger)hash{
    return [[self.key stringByAppendingString:self.activityType ?: GC_TYPE_NULL] hash];
}

-(BOOL)isEqualToField:(GCField*)other{

    return self.fieldFlag == other.fieldFlag && RZNilOrEqualToString(self.key, other.key) && RZNilOrEqualToString(self.activityType, other.activityType);

}


-(BOOL)isEqual:(id)object{
    if ([object isKindOfClass:[GCField class]]) {
        return [self isEqualToField:object];
    }else{
        return false;
    }
}



+(id)field:(id)field forActivityType:(NSString*)activityType{
    if ([field isKindOfClass:[GCField class]]) {
        return field;
    }else if ([field isKindOfClass:[NSString class]]){
        return [GCField fieldForKey:field andActivityType:activityType];
    }else if ([field isKindOfClass:[NSNumber class]]){
        return [GCField fieldForFlag:[field integerValue] andActivityType:activityType];
    }else if ([field isKindOfClass:[NSArray class]]){
        NSArray * inputArray = field;
        if (inputArray.count>0) {
            NSMutableArray * rv = [NSMutableArray arrayWithCapacity:inputArray.count];
            for (id one in inputArray) {
                id oneOut = [GCField field:one forActivityType:activityType];
                if (oneOut) {
                    [rv addObject:oneOut];
                }
            }
            if (rv.count) {
                return [NSArray arrayWithArray:rv];
            }
        }
    }
    return nil;
}

+(GCField*)fieldForKey:(NSString*)field andActivityType:(NSString*)activityType{
    if (field == nil) {
        return nil;
    }

    GCField * rv =  _cache[field][activityType?:GC_TYPE_NULL];
    if (!rv) {
        rv = RZReturnAutorelease([[GCField alloc] init]);
        if (rv) {
            rv.key = field;
            rv.activityType = activityType;
            rv.fieldFlag = [rv derivedFieldFlag];

            registerInCache(rv);
        }

    }

    return rv;
}

//NEWTRACKFIELD EDIT HERE
-(gcFieldFlag)derivedFieldFlag{
    gcFieldFlag rv = gcFieldFlagNone;
    static NSDictionary * dict = nil;
    if (!dict) {
        dict = @{GC_TYPE_RUNNING:@{ @"WeightedMeanPace":@(gcFieldFlagWeightedMeanSpeed),
                                    @"WeightedMeanSpeed":@(gcFieldFlagNone),// not preferred
                                    @"WeightedMeanRunCadence":          @(gcFieldFlagCadence),
                                    @"WeightedMeanCadence":          @(gcFieldFlagCadence),
                                    },
                 GC_TYPE_CYCLING:@{ @"WeightedMeanBikeCadence":         @(gcFieldFlagCadence),
                                    @"WeightedMeanCadence":          @(gcFieldFlagCadence),
                                    @"WeightedMeanPace":                @(gcFieldFlagNone), // not preferred
                                    },
                 GC_TYPE_SWIMMING:@{ @"WeightedMeanSpeed":          @(gcFieldFlagNone),
                                     @"WeightedMeanPace":@(gcFieldFlagWeightedMeanSpeed),
                                     @"WeightedMeanSwimCadence": @(gcFieldFlagCadence),
                                     @"WeightedMeanCadence": @(gcFieldFlagCadence),
                                     },
                 GC_TYPE_ALL:@{@"SumDistance":                     @(gcFieldFlagSumDistance),
                               @"SumDuration":                     @(gcFieldFlagSumDuration),
                               @"WeightedMeanHeartRate":           @(gcFieldFlagWeightedMeanHeartRate),
                               @"WeightedMeanSpeed":               @(gcFieldFlagWeightedMeanSpeed),
                               @"GainElevation":                   @(gcFieldFlagAltitudeMeters),
                               @"WeightedMeanPower":               @(gcFieldFlagPower),
                               @"SumStep":                         @(gcFieldFlagSumStep),
                               @"WeightedMeanGroundContactTime":   @(gcFieldFlagGroundContactTime),
                               @"WeightedMeanVerticalOscillation": @(gcFieldFlagVerticalOscillation),
                               },
                 GC_TYPE_SKI_XC: @{@"WeightedMeanCadence": @(gcFieldFlagCadence)},
                 };
        RZRetain(dict);
    }
    if (self.activityType && self.key) {
        NSNumber * found = dict[self.activityType][self.key];
        if (!found) {
            found = dict[GC_TYPE_ALL][self.key];
        }
        if (found) {
            rv = [found integerValue];
        }
    }
    return rv;
}

+(GCField*)fieldForFlag:(gcFieldFlag)fieldFlag andActivityType:(NSString *)activityType{
    if (fieldFlag == gcFieldFlagNone) {
        return nil;
    }
    GCField * rv = _cache[@(fieldFlag)][activityType?:GC_TYPE_NULL];

    if (!rv) {
        rv = RZReturnAutorelease([[GCField alloc] init]);
        if (rv) {
            rv.fieldFlag = fieldFlag;
            rv.activityType = activityType;
            rv.key = [GCFields activityFieldFromTrackField:fieldFlag andActivityType:activityType];
            registerInCache(rv);
        }
    }
    return rv;
}

+(GCField*)fieldForAggregated:(gcAggregatedField)aggregatedField andActivityType:(NSString*)activityType{
    switch (aggregatedField) {
        case gcAggregatedWeightedSpeed:
            if ([activityType isEqualToString:GC_TYPE_RUNNING] || [activityType isEqualToString:GC_TYPE_SWIMMING]) {
                return [GCField fieldForKey:@"WeightedMeanPace" andActivityType:activityType];
            }else{
                return [GCField fieldForKey:@"WeightedMeanSpeed" andActivityType:activityType];
            }
            break;
        case gcAggregatedWeightedHeartRate:
            return [GCField fieldForKey:@"WeightedMeanHeartRate" andActivityType:activityType];
        case gcAggregatedSumDistance:
            return [GCField fieldForKey:@"SumDistance" andActivityType:activityType];
        case gcAggregatedSumDuration:
            return [GCField fieldForKey:@"SumDuration" andActivityType:activityType];
        case gcAggregatedTennisPower:
            return [GCField fieldForKey:@"averagePower" andActivityType:activityType];
        case gcAggregatedTennisShots:
            return [GCField fieldForKey:@"shots" andActivityType:activityType];
        case gcAggregatedCadence:
            return [GCField fieldForFlag:gcFieldFlagCadence andActivityType:activityType];
        case gcAggregatedAltitudeMeters:
            return [GCField fieldForKey:@"GainElevation" andActivityType:activityType];
        case gcAggregatedFieldEnd:
            return nil;
        case gcAggregatedSumStep:
            return [GCField fieldForKey:@"SumStep" andActivityType:activityType];
    }
    return nil;

}
#if !__has_feature(objc_arc)
-(void)dealloc{
    [_key release];
    [_activityType release];

    [super dealloc];
}
#endif
-(NSString*)description{
    NSString * key = self.fieldFlag != gcFieldFlagNone ? [NSString stringWithFormat:@"%@(%lu)", self.key, (unsigned long)self.fieldFlag] : self.key;

    return [NSString stringWithFormat:@"<%@:%@:%@>", NSStringFromClass([self class]), key, self.activityType?:GC_TYPE_NULL];
}

#pragma mark

-(BOOL)isHealthField{
    return [self.key hasPrefix:GC_HEALTH_PREFIX];
}
-(BOOL)isCalculatedField{
    return [self.key hasPrefix:CALC_PREFIX];
}
-(BOOL)isInternal{
    return [self.key hasPrefix:INTERNAL_PREFIX];
}

-(BOOL)isNoisy{
    if ([self.activityType isEqualToString:GC_TYPE_SWIMMING]) {
        return false;
    }
    gcFieldFlag aTrackField = self.fieldFlag;
    
    return aTrackField == gcFieldFlagCadence ||
        aTrackField == gcFieldFlagWeightedMeanSpeed ||
        aTrackField == gcFieldFlagPower ||
        aTrackField == gcFieldFlagVerticalOscillation ||
        aTrackField == gcFieldFlagGroundContactTime;

}

-(BOOL)canSum{
    NSString * field = self.key;
    
    if ([field isEqualToString:@"SumTrainingEffect"] || [field isEqualToString:@"SumIntensityFactor"]) {
        return NO;
    }
    return [field hasPrefix:@"Sum"] || [field isEqualToString:@"GainElevation"] || [field isEqualToString:@"LossElevation"] || [field isEqualToString:@"shots"];
}

-(BOOL)validForGraph{
    if( self.isInternal ){
        return false;
    }
    
    if (self.fieldFlag == gcFieldFlagSumDistance || self.fieldFlag == gcFieldFlagSumDuration) {
        return false;
    }
    // special case
    if( self.fieldFlag == gcFieldFlagAltitudeMeters){
        return true;
    }
    if( self.fieldFlag != gcFieldFlagNone){
        return self.isWeightedAverage;
    }
    return !self.isMax && !self.isMin;
}

-(BOOL)isWeightedAverage{
    return [self.key hasPrefix:@"WeightedMean"];
}
-(BOOL)isSpeedOrPace{
    return self.fieldFlag == gcFieldFlagWeightedMeanSpeed || [self.key isEqualToString:@"WeightedMeanSpeed"] || [self.key isEqualToString:@"WeightedMeanPace"];
}

-(BOOL)isMax{
    return [self.key hasPrefix:@"Max"];
}
-(BOOL)isMin{
    return [self.key hasPrefix:@"Min"];
}

-(BOOL)isZeroValid{
    if( [self.key hasSuffix:@"Elevation"] || self.fieldFlag == gcFieldFlagSumDistance || self.fieldFlag == gcFieldFlagSumDuration ){
        return true;
    }
    return false;
}
-(GCField*)fieldBySwappingPrefix:(NSString*)oldPrefix for:(NSString*)newPrefix{
    if( [self.key hasPrefix:oldPrefix]){
        NSString * guess = [NSString stringWithFormat:@"%@%@", newPrefix, [self.key substringFromIndex:[oldPrefix length]]];
        return [GCField fieldForKey:guess andActivityType:self.activityType];
    }
    return nil;
}
-(GCField*)fieldBySwappingSuffix:(NSString*)oldSuffix for:(NSString*)newSuffix{
    if( [self.key hasSuffix:oldSuffix]){
        NSString * guess = [NSString stringWithFormat:@"%@%@", [self.key substringToIndex:(self.key.length-oldSuffix.length)], newSuffix];
        return [GCField fieldForKey:guess andActivityType:self.activityType];
    }
    return nil;
}

-(GCField*)correspondingPaceOrSpeedField{
    GCField * rv = nil;
    if( [self.key hasSuffix:@"Speed"] ){
        rv = [self fieldBySwappingSuffix:@"Speed" for:@"Pace"];
    }else if([self.key hasSuffix:@"Pace"]){
        rv = [self fieldBySwappingSuffix:@"Pace" for:@"Speed"];
    }
    return rv;
}
-(GCField*)correspondingMaxField{
    GCField * rv = [self fieldBySwappingPrefix:@"WeightedMean" for:@"Max"];
    return rv;
}
-(GCField*)correspondingMinField{
    GCField * rv = [self fieldBySwappingPrefix:@"WeightedMean" for:@"Min"];
    return rv;
}

-(GCField*)correspondingWeightedMeanField{
    GCField * rv = nil;
    if( [self hasPrefix:@"Max"] ){
        rv = [self fieldBySwappingPrefix:@"Max" for:@"WeightedMean"];
    }else if ([self hasPrefix:@"Min"]){
        rv = [self fieldBySwappingPrefix:@"Min" for:@"WeightedMean"];
    }else if ([self hasPrefix:@"WeightedMean"]){
        rv = self;
    }
    return rv;
}
-(GCField*)correspondingFieldTypeAll{
    return [GCField fieldForKey:self.key andActivityType:GC_TYPE_ALL];
}
-(GCField*)correspondingFieldForActivityType:(NSString*)activityType{
    if( [self.activityType isEqualToString:activityType]){
        return self;
    }else{
          return [GCField fieldForKey:self.key andActivityType:activityType];
    }
}
-(BOOL)hasSuffix:(NSString*)suf{
    return [self.key hasSuffix:suf];
}
-(BOOL)hasPrefix:(NSString*)pref{
    return [self.key hasPrefix:pref];
}

#pragma mark

+(NSString*)displayNameImpliedByFieldKey:(NSString *)afield{
    if( [afield rangeOfString:@"_"].location == NSNotFound){
        NSString * rv = [afield fromCamelCaseToCapitalizedSeparatedByString:@" "];
        if( [rv hasPrefix:@"Weighted Mean "]){
            rv = [rv stringByReplacingOccurrencesOfString:@"Weighted Mean " withString:@""];
        }
        if( [rv hasPrefix:@"Direct "]){
            rv = [rv stringByReplacingOccurrencesOfString:@"Direct " withString:@""];
        }
        if( [rv hasPrefix:@"Sum "]){
            rv = [rv stringByReplacingOccurrencesOfString:@"Sum " withString:@""];
        }

        return rv;
    }else{
        return [afield dashSeparatedToSpaceCapitalized];
    }
}

-(NSString*)displayName{
    return [[_fieldCache infoForField:self] displayName] ?: [GCField displayNameImpliedByFieldKey:self.key];
}
-(GCUnit*)unit{
    return [[_fieldCache infoForField:self] unit];
}

-(NSString*)displayNameAndUnits{
    return [self displayNameWithUnits:[self unit]];
}
-(NSString*)displayNameWithUnits:(GCUnit*)unit{
    if (!unit) {
        return [self displayName];
    }
    NSString * unitAbbr = unit.abbr;
    if (unitAbbr && unitAbbr.length) {
        unitAbbr = [NSString stringWithFormat:@" (%@)", unitAbbr];
    }

    NSString * title = [NSString stringWithFormat:@"%@%@",
                        [self displayName],
                        unitAbbr];
    return title;
}

-(NSArray*)fieldCategoryAndOrder{
    static NSMutableDictionary * cache = nil;
    if (!cache) {
        cache = [NSMutableDictionary dictionary];
        RZRetain(cache);
    }

    NSString * activityType = self.activityType ?: GC_TYPE_ALL;
    NSMutableDictionary * rv = cache[ activityType ];

    if (!rv) {
        FMDatabase * fdb = [FMDatabase databaseWithPath:[RZFileOrganizer bundleFilePath:@"fields.db"]];
        [fdb open];

        rv = [NSMutableDictionary dictionary];
        FMResultSet * res = [fdb executeQuery:@"SELECT * FROM gc_fields_order WHERE activityType is NULL"];
        while ([res next]) {
            NSString * field = [res stringForColumn:@"field"];
            NSString * category = [res stringForColumn:@"category"];
            int order = [res intForColumn:@"display_order"];

            if (order <= 0) {
                category = GC_CATEGORY_IGNORE;
            }
            rv[field] = @[category,@(order)];
        }
        if (activityType != nil) {
            res = [fdb executeQuery:@"SELECT * FROM gc_fields_order WHERE activityType = ?", activityType];
            while ([res next]) {
                NSString * field = [res stringForColumn:@"field"];
                NSString * category = [res stringForColumn:@"category"];
                int order = [res intForColumn:@"display_order"];

                if (order <= 0) {
                    category = GC_CATEGORY_IGNORE;
                }
                rv[field] = @[category,@(order)];
            }

        }

        [fdb close];
        if (rv && activityType) {
            cache[activityType] = rv;
        }
    }
    return rv[self.key];
}


-(NSString*)category{
    NSString * rv = nil;
    NSArray * categoryAndOrder = [self fieldCategoryAndOrder];

    if (categoryAndOrder.count > 0) {
        rv = categoryAndOrder[0];
    }
    return  rv ?: GC_CATEGORY_OTHER;
}

-(NSInteger)sortOrder{
    NSInteger rv = 0;
    NSArray * categoryAndOrder = [self fieldCategoryAndOrder];

    if (categoryAndOrder.count > 1) {
        rv = [categoryAndOrder[1] integerValue];
    }
    return rv;
}

-(NSComparisonResult)compare:(id)other{
    NSComparisonResult rv = NSOrderedSame;

    if ([other isKindOfClass:[GCField class]]) {
        GCField * fother = other;
        NSString * cat1 = self.category;
        NSString * cat2 = fother.category;

        if ([cat1 isEqualToString:cat2]) {
            NSInteger order1 = self.sortOrder;
            NSInteger order2 = fother.sortOrder;

            rv = order1 == order2 ? NSOrderedSame : (order1 < order2 ? NSOrderedAscending : NSOrderedDescending);
        }else{
            NSDictionary * categoryOrder = [GCFieldsCategory categoryOrder];

            NSNumber * order1 = categoryOrder[cat1];
            NSNumber * order2 = categoryOrder[cat2];

            return [order1 compare:order2];
        }
    }
    return rv;
}

-(NSArray<GCField*>*)relatedFields{
    NSArray<NSString*> * prefixes = @[@"WeightedMean", @"WeightedMeanMoving", @"Max", @"Min"];
    static NSArray<NSArray<NSString*>*> * _groups = nil;
    static NSArray<NSString*> * _exceptions = nil;
    
    if (_groups==nil) {
        _groups = @[
                    @[@"SumDuration", @"SumElapsedDuration", @"SumMovingDuration" ],
                    @[@"SumDistance", @"GainElevation",      @"LossElevation", @"MaxElevation"],
                    @[@"SumEnergy",   @"SumTrainingEffect",  CALC_ENERGY,      CALC_METABOLIC_EFFICIENCY],
                    
                    @[@"SumIntensityFactor",          @"SumTrainingStressScore"],
                    @[@"WeightedMeanNormalizedPower", CALC_NONZERO_POWER, @"WeightedMeanLeftBalance", @"WeightedMeanRightBalance"],
                    @[@"WeightedMeanRunCadence",      @"MaxRunCadence",           CALC_STRIDE_LENGTH],
                    @[@"WeightedMeanBikeCadence",     @"MaxBikeCadence",          CALC_DEVELOPMENT],
                    @[CALC_NORMALIZED_POWER,          CALC_NONZERO_POWER],
                    @[CALC_ALTITUDE_GAIN,             CALC_ALTITUDE_LOSS],
                    //@[@"WeightedMeanVerticalOscillation", @"WeightedMeanGroundContactTime"],
                    @[@"DirectVO2Max", @"DirectLactateThresholdHeartRate"],
                    @[@"WeightedMeanVerticalRatio",@"WeightedMeanGroundContactBalanceLeft"],
                    @[CALC_ASCENT_SPEED, CALC_MAX_ASCENT_SPEED],
                    @[CALC_DESCENT_SPEED, CALC_MAX_DESCENT_SPEED],
                    @[CALC_VERTICAL_SPEED, CALC_ASCENT_SPEED, CALC_DESCENT_SPEED],
                    
                    ];
        RZRetain(_groups);
        NSMutableArray * found = [NSMutableArray arrayWithCapacity:5];
        for (NSArray * one in _groups) {
            for (NSString * str in one) {
                for (NSString * prefix in prefixes) {
                    if ([str hasPrefix:prefix]) {
                        [found addObject:str];
                    }
                }
            }
        }
        _exceptions = RZReturnRetain(found);
    }
    
    NSMutableArray<GCField*> * rv = nil;
    
    NSString * suffix = nil;
    // Exception without min/max
    if (![_exceptions containsObject:self.key]) {
        for (NSString * prefix in prefixes) {
            if ([self.key hasPrefix:prefix]) {
                suffix = [self.key substringFromIndex:prefix.length];
                break;
            }
        }
    }
    if (suffix) {
        rv = [NSMutableArray arrayWithCapacity:prefixes.count];
        // special case
        if ([suffix isEqualToString:@"Power"]) {
            [rv addObject:[GCField fieldForKey:@"MaxPowerTwentyMinutes" andActivityType:self.activityType ]];
        }
        for (NSString * prefix in prefixes) {
            NSString * newF=[prefix stringByAppendingString:suffix];
            if (![newF isEqualToString:self.key]) {
                [rv addObject:[GCField fieldForKey:newF andActivityType:self.activityType]];
            }
        }
    }else{
        NSArray * groups = _groups;
        
        for (NSArray * group in groups) {
            if ([group containsObject:self.key]) {
                rv = [NSMutableArray arrayWithCapacity:group.count];
                for (NSString * f in group) {
                    if (![f isEqualToString:self.key]) {
                        [rv addObject:[GCField fieldForKey:f andActivityType:self.activityType]];
                    }
                }
                break;
            }
        }
    }
    return rv;
}
@end
