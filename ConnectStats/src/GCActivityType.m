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

@interface GCActivityType ()
@property (nonnull,retain,nonatomic) NSString * key;
@property (nonatomic,assign) NSUInteger typeId;
@property (nullable,retain,nonatomic) GCActivityType * parentType;

+(GCActivityTypes*)activityTypes;

@end

@implementation GCActivityType

+(GCActivityTypes*)activityTypes{
    static GCActivityTypes * types = nil;
    if( types == nil){
        types = [GCActivityTypes activityTypes];
        RZRetain(types);
    }
    return types;
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

+(nonnull GCActivityType*)activityType:(nonnull NSString*)key typeId:(NSUInteger)typeId andParent:(nullable GCActivityType*)parent{
    GCActivityType * rv = RZReturnAutorelease([[GCActivityType alloc] init]);
    if (rv) {
        rv.key = key;
        rv.typeId = typeId;
        rv.parentType = parent;

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

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.key = [aDecoder decodeObjectForKey:kGCActivityTypeKey];
        self.typeId = [aDecoder decodeIntegerForKey:kGCActivityTypeId];
        NSUInteger parentId = [aDecoder decodeIntegerForKey:kGCActivityTypeParentId];
        if( parentId != 0){
            self.parentType = [aDecoder decodeObjectForKey:kGCActivityTypeParentObject];
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

-(GCActivityType*)topSubRootType{
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

-(BOOL)isSameParentType:(GCActivityType*)other{
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

    // same parent. Already know won't be root type as covered by first if
    if( self.parentType.typeId == other.parentType.typeId){
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
    return [_fieldCache infoForActivityType:self.key].displayName?:self.key;
}

#pragma mark - Properties

-(BOOL)isPaceValid{
    if( [self.key isEqualToString:GC_TYPE_RUNNING] || [self.key isEqualToString:GC_TYPE_SWIMMING])
        return true;
    
    return self.parentType.isPaceValid;
}

-(BOOL)isSki{
    return ([self.key isEqualToString:GC_TYPE_SKI_BACK] || [self.key isEqualToString:GC_TYPE_SKI_DOWN] || [self.key isEqualToString:GC_TYPE_SKI_XC]);
}


#pragma mark - Convenience access
+(nonnull GCActivityType*)activityTypeForKey:(nonnull NSString*)key{
    return [[GCActivityType activityTypes] activityTypeForKey:key];
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
+(GCActivityType*)other{
    return [[GCActivityType activityTypes] activityTypeForKey:GC_TYPE_OTHER];
}
+(GCActivityType*)all{
    return [[GCActivityType activityTypes] activityTypeForKey:GC_TYPE_ALL];
}
+(nonnull GCActivityType*)day{
    return [[GCActivityType activityTypes] activityTypeForKey:GC_TYPE_DAY];
}
+(nonnull NSArray<GCActivityType*>*)allTypes{
    return [[GCActivityType activityTypes] allTypes];
}
+(nonnull NSArray<GCActivityType*>*)allParentTypes{
    return [[GCActivityType activityTypes] allParentTypes];
}
+(nonnull NSArray<GCActivityType*>*)allTypesForParent:(nonnull GCActivityType*)parentType{
    return [[GCActivityType activityTypes] allTypesForParent:parentType];
}

@end
