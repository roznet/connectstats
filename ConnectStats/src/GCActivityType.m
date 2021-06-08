//  MIT Licence
//
//  Created on 01/12/2013.
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

#import "GCActivityType.h"
#import "GCField.h"
#import "GCFieldCache.h"
#import "GCActivityTypes.h"

static GCFieldCache * _fieldCache = nil;
static GCActivityTypes * _activityTypesCache = nil;

@interface GCActivityType ()
@property (nonnull,retain,nonatomic) NSString * key;
@property (nonatomic,assign) NSUInteger typeId;
@property (nullable,retain,nonatomic) GCActivityType * parentType;


@end

@implementation GCActivityType

+(GCActivityTypes*)activityTypes{
    if( _activityTypesCache == nil){
        _activityTypesCache = [GCActivityTypes activityTypes];
        RZRetain(_activityTypesCache);
    }
    return _activityTypesCache;
}

+(void)setActivityTypes:(GCActivityTypes *)a{
    if( _activityTypesCache != nil){
        RZRelease(_activityTypesCache);
        _activityTypesCache = nil;
    }
    
    _activityTypesCache = a;
    RZRetain(_activityTypesCache);
}

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

+(nullable GCActivityType*)activityType:(nonnull NSString*)key typeId:(NSUInteger)typeId andParent:(nullable GCActivityType*)parent{
    GCActivityType * rv = RZReturnAutorelease([[GCActivityType alloc] init]);
    if (rv) {
        rv.key = key;
        rv.typeId = typeId;
        rv.parentType = parent;
        if( ![rv.key isKindOfClass:[NSString class]]){
            NSLog(@"What???");
        }

    }
    return rv;

}

#if !__has_feature(objc_arc)
-(void)dealloc{
    [_key release];
    [_parentType release];

    [super dealloc];
}
#endif

#pragma mark - NSCoding

#define kGCActivityTypeVersion @"activityTypeVersion"
#define kGCActivityTypeKey @"activityTypeKey"
#define kGCActivityTypeId @"activityTypeId"
#define kGCActivityTypeParentObject @"activityTypeParentObject"
#define kGCActivityTypeParentId @"activityTypeParentId"

+(BOOL)supportsSecureCoding{
    return YES;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.key = [aDecoder decodeObjectOfClass:[NSString class] forKey:kGCActivityTypeKey];
        self.typeId = [aDecoder decodeIntegerForKey:kGCActivityTypeId];
        NSUInteger parentId = [aDecoder decodeIntegerForKey:kGCActivityTypeParentId];
        if( parentId != 0){
            self.parentType = [aDecoder decodeObjectOfClass:[GCActivityType class] forKey:kGCActivityTypeParentObject];
        }else{
            self.parentType = nil;
        }
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeInt:1 forKey:kGCActivityTypeVersion];
    [aCoder encodeObject:self.key forKey:kGCActivityTypeKey];
    [aCoder encodeInteger:self.typeId forKey:kGCActivityTypeId];
    [aCoder encodeInteger:self.parentType ? self.parentType.typeId : 0 forKey:kGCActivityTypeParentId];
    if (self.parentType){
        [aCoder encodeObject:self.parentType forKey:kGCActivityTypeParentObject];
    }
}


#pragma mark - Dictionary Key protocols:

-(instancetype)copyWithZone:(NSZone *)zone{
    GCActivityType * rv = [[[self class] alloc] init];
    if (rv) {
        rv.key = RZReturnAutorelease([self.key copyWithZone:zone]);
        rv.parentType = self.parentType ? RZReturnAutorelease([self.parentType copyWithZone:zone]) : nil;
        rv.typeId = self.typeId;
    }
    return  rv;
}

-(NSUInteger)hash{
    return self.typeId;
}

-(BOOL)isEqualToActivityType:(GCActivityType*)other{
    return self.typeId == other.typeId;
}


-(BOOL)isEqual:(id)object{
    if ([object isKindOfClass:[GCActivityType class]]) {
        return [self isEqualToActivityType:object];
    }else{
        return false;
    }
}

-(BOOL)isEqualToString:(nonnull NSString*)activityTypeString{
    return [self.key isEqualToString:activityTypeString];
}



-(NSInteger)sortOrder{
    // for now, typeid happens to be not too bad
    return self.typeId;
}

-(NSComparisonResult)compare:(GCActivityType*)other{
    if( [other isKindOfClass:[self class]]){
        NSInteger thisPrimarySortOrder = self.primaryActivityType.sortOrder;
        NSInteger otherPrimarySortOrder = other.primaryActivityType.sortOrder;

        if( thisPrimarySortOrder == otherPrimarySortOrder ){
            NSInteger thisSortOrder = self.sortOrder;
            NSInteger otherSortOrder = other.sortOrder;
            if( thisSortOrder == otherSortOrder){
                return NSOrderedSame;
            }else if( thisSortOrder < otherSortOrder){
                return NSOrderedAscending;
            }else{
                return NSOrderedDescending;
            }
        }else if( thisPrimarySortOrder < otherPrimarySortOrder){
            return NSOrderedAscending;
        }else{
            return NSOrderedDescending;
        }
    }else{
        return NSOrderedAscending;
    }
}

-(GCActivityType*)rootType{
    if (self.isRootType) {
        return self;
    }
    GCActivityType * rv = self.parentType;
    while (rv.parentType != nil) {
        rv = rv.parentType;
    }
    return rv;
}

-(GCActivityType*)primaryActivityType{
    if (self.isRootType) {
        return self;
    }
    GCActivityType * rv = self;
    while (!rv.parentType.isRootType) {
        rv = rv.parentType;
    }
    return rv;
}


-(BOOL)isSameRootType:(GCActivityType*)other{
    return [self.rootType isEqualToActivityType:other.rootType];
}

-(BOOL)hasSamePrimaryType:(GCActivityType*)other{
    if (self.isRootType || other.isRootType) {
        return [self isSameRootType:other];
    }
    // trivial case of same type
    if (self.typeId == other.typeId) {
        return true;
    }
    // one is parent of the other
    if( self.typeId == other.parentType.typeId || self.parentType.typeId == other.typeId){
        return true;
    }

    // full logic check
    if( self.primaryActivityType.typeId == other.primaryActivityType.typeId){
        return true;
    }

    return false;
}

-(void)writeToDb:(FMDatabase*)db{
}

-(BOOL)isRootType{
    return self.parentType == nil;
}
-(NSString*)description{
    if (self.parentType == nil || self.parentType.isRootType) {
        return [NSString stringWithFormat:@"<%@:%@(%d)>", NSStringFromClass([self class]), self.key, (int)self.typeId];
    }else{
        return [NSString stringWithFormat:@"<%@:%@:%@(%d)>", NSStringFromClass([self class]), self.parentType.key, self.key, (int)self.typeId];
    }
}

-(NSString*)displayName{
    if(_fieldCache==nil){
        [GCActivityType fieldCache];
    }
    return [_fieldCache infoForActivityType:self.key].displayName?: [GCField displayNameImpliedByFieldKey:self.key];
}

#pragma mark - Properties

-(gcIgnoreMode)ignoreMode{
    return [self.key isEqualToString:GC_TYPE_DAY] ? gcIgnoreModeDayFocus : gcIgnoreModeActivityFocus;
}

-(BOOL)isPacePreferred{
    if( [GCFields pacePreferredForActivityType:self.key]){
        return true;
    }
    
    return self.parentType.isPacePreferred;
}

-(BOOL)isSki{
    return ([self.key isEqualToString:GC_TYPE_SKI_BACK] || [self.key isEqualToString:GC_TYPE_SKI_DOWN] || [self.key isEqualToString:GC_TYPE_SKI_XC]);
}

-(BOOL)isElevationLossPreferred{
    return [self.key isEqualToString:GC_TYPE_SKI_DOWN];
}

-(GCUnit*)preferredSpeedDisplayUnit{
    GCActivityType * top = [self primaryActivityType];
    
    if( [top.key isEqualToString:GC_TYPE_SWIMMING] ){
        return [[GCUnit min100m] unitForGlobalSystem];
    }else if( [GCFields pacePreferredForActivityType:top.key]){
        return [[GCUnit minperkm] unitForGlobalSystem];
    }
    return [[GCUnit kph] unitForGlobalSystem];

}
#pragma mark - Convenience access

+(BOOL)isExistingActivityType:(NSString*)aType{
    return [[GCActivityType activityTypes] isExistingActivityType:aType];
}

+(nonnull GCActivityType*)activityTypeForKey:(nonnull NSString*)key{
    return [[GCActivityType activityTypes] activityTypeForKey:key];
}

+(nullable GCActivityType*)activityTypeForGarminId:(NSUInteger)garminActivityId{
    return [[GCActivityType activityTypes] activityTypeForGarminId:garminActivityId];
}
+(nullable GCActivityType*)activityTypeForStravaType:(NSString*)stravaType{
    return [[GCActivityType activityTypes] activityTypeForStravaType:stravaType];
}
+(nullable GCActivityType*)activityTypeForConnectStatsType:(NSString*)input{
    return [[GCActivityType activityTypes] activityTypeForConnectStatsType:input];
}
+(nullable GCActivityType*)activityTypeForFitSport:(NSString*)fitSport andSubSport:(NSString *)fitSubSport{
    return [[GCActivityType activityTypes] activityTypeForFitSport:fitSport andSubSport:fitSubSport];
}

+(GCActivityType*)running{
    return [[GCActivityType activityTypes] activityTypeForKey:GC_TYPE_RUNNING];
}
+(GCActivityType*)cycling{
    return [[GCActivityType activityTypes] activityTypeForKey:GC_TYPE_CYCLING];
}
+(GCActivityType*)swimming{
    return [[GCActivityType activityTypes] activityTypeForKey:GC_TYPE_SWIMMING];
}
+(GCActivityType*)hiking{
    return [[GCActivityType activityTypes] activityTypeForKey:GC_TYPE_HIKING];
}
+(nonnull GCActivityType*)walking{
    return [[GCActivityType activityTypes] activityTypeForKey:GC_TYPE_WALKING];
}
+(nonnull GCActivityType*)elliptical{
    return [[GCActivityType activityTypes] activityTypeForKey:@"elliptical"];
}
+(nonnull GCActivityType*)strength_training{
    return [[GCActivityType activityTypes] activityTypeForKey:@"stength_training"];
}

+(GCActivityType*)other{
    return [[GCActivityType activityTypes] activityTypeForKey:GC_TYPE_OTHER];
}
+(GCActivityType*)all{
    return [[GCActivityType activityTypes] activityTypeForKey:GC_TYPE_ALL];
}
+(GCActivityType*)multisport{
    return [[GCActivityType activityTypes] activityTypeForKey:GC_TYPE_MULTISPORT];
}
+(nonnull GCActivityType*)day{
    return [[GCActivityType activityTypes] activityTypeForKey:GC_TYPE_DAY];
}
+(nonnull NSArray<GCActivityType*>*)allTypes{
    return [[GCActivityType activityTypes] allTypes];
}
+(nonnull NSArray<GCActivityType*>*)allPrimaryTypes{
    return [[GCActivityType activityTypes] allPrimaryTypes];
}
+(nonnull NSArray<GCActivityType*>*)allTypesWithSamePrimaryTypeAs:(nonnull GCActivityType*)parentType{
    return [[GCActivityType activityTypes] allTypesWithSamePrimaryTypeAs:parentType];
}

-(nonnull NSArray<GCField*>*)summaryFields{
    NSString * activityType = self.primaryActivityType.key;
    
    NSString * preferredElevationField = [self isElevationLossPreferred] ? @"LossElevation" : @"GainElevation";
    NSArray<GCField*> * fields = @[
        [GCField fieldForFlag:gcFieldFlagSumDuration andActivityType:activityType],
        [GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:activityType],
        
        [GCField fieldForFlag:gcFieldFlagWeightedMeanSpeed andActivityType:activityType],
        [GCField fieldForFlag:gcFieldFlagWeightedMeanHeartRate andActivityType:activityType],
        [GCField fieldForFlag:gcFieldFlagPower andActivityType:activityType],
        [GCField fieldForKey:preferredElevationField andActivityType:activityType],
    ];
    
    return fields;
}
@end

