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

#import "GCActivityTypes.h"
#import "GCActivityType.h"
#import "GCField.h"
#import "GCField+Convert.h"

static NSUInteger nonPredefinedTypeId = 10000;

static NSString * kTypeId = @"kTypeId";
static NSString * kTypeKey = @"kTypeKey";
static NSString * kTypeParent = @"kParentTypeId";
static NSString * kTypeDisplay = @"kTypeDisplay";

@interface GCActivityTypes ()

@property (nonatomic,retain) NSDictionary<NSString*,GCActivityType*> * typesByKey;
@property (nonatomic,retain) NSDictionary<NSNumber*,GCActivityType*> * typesById;

@end

@implementation GCActivityTypes

+(GCActivityTypes*)activityTypes{
    GCActivityTypes * rv = RZReturnAutorelease([[GCActivityTypes alloc] init]);
    if (rv) {
        [rv loadPredefined];
    }
    return rv;
}
#if !__has_feature(objc_arc)
-(void)dealloc{
    [_typesByKey release];
    [_typesById release];

    [super dealloc];
}
#endif

-(NSUInteger)addMissingFrom:(NSDictionary<NSNumber*,NSDictionary*>*)defsFromDb{
    // Populate parent Ids and by detail
    NSMutableDictionary * byActivityType = [NSMutableDictionary dictionaryWithDictionary:self.typesByKey?:@{}];
    NSMutableDictionary * byTypeId = [NSMutableDictionary dictionaryWithDictionary:self.typesById?:@{}];
    
    NSUInteger foundNew = 0;
    BOOL stillMissing = true;
    NSUInteger safeGuard = 5;
    while( safeGuard > 0 && stillMissing){
        stillMissing = true;
        for (NSNumber * typeId in defsFromDb) {
            if( byTypeId[typeId] != nil){
                continue;
            }
            NSDictionary * defs = defsFromDb[typeId];
            NSNumber * parentId = defs[kTypeParent];
            GCActivityType * parentType = byTypeId[ parentId];
            if (parentId.integerValue == 0 || parentType) {
                NSString * key = defs[kTypeKey];
                GCActivityType * type = [GCActivityType activityType:key typeId:typeId.integerValue andParent:parentType];
                byTypeId[typeId] = type;
                byActivityType[key] = type;
                foundNew++;
            }else{
                stillMissing = true;
            }
        }
        safeGuard--;
    }
    if( safeGuard == 0 && stillMissing){
        RZLog(RZLogError, @"Failed to process all types after 5 iterations: parsed %lu < %lu", (unsigned long)byTypeId.count, (unsigned long)defsFromDb.count);
    }
    if( byTypeId.count != byActivityType.count){
        RZLog(RZLogError, @"Inconsistency in types byKey %lu != byTypeId %lu", (unsigned long)byTypeId.count, (unsigned long)byActivityType.count);
    }
    
    self.typesByKey = byActivityType;
    self.typesById = byTypeId;
    
    return foundNew;
}

-(void)loadPredefined{
    FMDatabase * fdb = [FMDatabase databaseWithPath:[RZFileOrganizer bundleFilePath:@"fields.db"]];
    [fdb open];

    NSMutableDictionary * defsFromDb = [NSMutableDictionary dictionary];

    FMResultSet * res = [fdb executeQuery:@"SELECT * FROM gc_activityType_modern"];
    while( [res next]){
        NSUInteger typeId = [res intForColumn:@"activityTypeId"];
        defsFromDb[ @(typeId) ] = @{
                                  kTypeId : @(typeId),
                                  kTypeKey : [res stringForColumn:@"activityTypeDetail"],
                                  kTypeParent : @([res intForColumn:@"parentActivityTypeId"]),
                                  };
    }

    [fdb close];

    NSUInteger n = [self addMissingFrom:defsFromDb];
    if( n > 0){
        RZLog(RZLogInfo, @"Registered %lu ActivityTypes", (long unsigned)n);
    }
    [self addNonGarminTypes];
}

-(NSUInteger)loadMissingFromGarmin:(NSArray<NSDictionary*>*)modern withDisplayInfoFrom:(NSArray<NSDictionary*>*)legacy{
    NSDictionary * defs = [self buildFromGarmin:modern withDisplay:legacy];
    return [self addMissingFrom:defs];
}

-(void)addNonGarminTypes{
    NSMutableDictionary<NSNumber*,NSDictionary*>* missing = [NSMutableDictionary dictionary];
    
    NSUInteger nonActivityAllId = 0;
    if( self.typesByKey[@"non_activity_all"] == nil){
        nonActivityAllId = nonPredefinedTypeId++;
        NSUInteger typeId = nonActivityAllId;
        missing[ @(typeId)] = @{
                                kTypeId : @(typeId),
                                kTypeKey : @"non_activity_all",
                                kTypeParent : @(0),
                                };
    }else{
        nonActivityAllId = self.typesByKey[@"non_activity_all"].typeId;
    }
    if( self.typesByKey[@"GC_TYPE_DAY"] == nil ){
        NSUInteger typeId = nonPredefinedTypeId++;
        missing[ @(typeId)] = @{
                                kTypeId : @(typeId),
                                kTypeKey : GC_TYPE_DAY,
                                kTypeParent : @(nonActivityAllId),
                                };
    }

    if( missing.count > 0){
        [self addMissingFrom:missing];
    }
}

-(NSDictionary<NSNumber*,NSDictionary*>*)buildFromGarmin:(NSArray<NSDictionary*>*)modern
                                             withDisplay:(NSArray<NSDictionary*>*)legacy{
    NSMutableDictionary * displayDict = [NSMutableDictionary dictionary];
    if([legacy isKindOfClass:[NSArray class]]){
        for (NSDictionary * one in legacy) {
            NSString * key = one[@"key"];
            NSString * display = one[@"display"];
            
            if( key && display){
                displayDict[key] = display;
            }
        }
    }
    
    NSMutableDictionary<NSNumber*, NSDictionary*>*missing =[NSMutableDictionary dictionary];
    
    if([modern isKindOfClass:[NSArray class]]){
        for (NSDictionary * one in modern) {
            NSString * key = one[@"typeKey"];
            NSNumber * typeId = one[@"typeId"];
            NSNumber * parentTypeId = one[@"parentTypeId"];
            
            NSString * display = displayDict[key];
            if( display == nil){
                display = [GCField displayNameImpliedByFieldKey:key];
            };
            
            missing[typeId] = @{
                                kTypeId : typeId,
                                kTypeKey : key,
                                kTypeParent : parentTypeId,
                                kTypeDisplay : display,
                                };
        }
    }
    
    return missing;
}


#pragma mark - Access

-(BOOL)isExistingActivityType:(NSString*)aType{
    return self.typesByKey[aType] != nil;
}
-(GCActivityType*)activityTypeForKey:(NSString*)aType{
    GCActivityType * rv = self.typesByKey[aType];
    if( rv == nil){
        rv = [GCActivityType activityType:aType typeId:nonPredefinedTypeId++ andParent:GCActivityType.all];
        NSMutableDictionary * byKeys = [NSMutableDictionary dictionaryWithDictionary:self.typesByKey];
        byKeys[aType] = rv;
        self.typesByKey = byKeys;
    }
    return rv;
}
-(GCActivityType*)activityTypeForGarminId:(NSUInteger)garminActivityId{
    return self.typesById[ @(garminActivityId)];
}
-(GCActivityType*)activityTypeForStravaType:(NSString*)stravaType{
    NSDictionary<NSString*,GCActivityType*> * cache = nil;
    if( cache == nil){
        NSDictionary * types = @{
                                 @"AlpineSki":@"resort_skiing_snowboarding",
                                 @"BackcountrySki": @"backcountry_skiing_snowboarding",
                                 @"Canoeing" :@"boating",
                                 @"Crossfit":@"fitness_equipment",
                                 @"EBikeRide":GC_TYPE_CYCLING,
                                 @"Elliptical":@"elliptical",
                                 @"Hike":   GC_TYPE_HIKING,
                                 @"IceSkate": @"skating",
                                 @"InlineSkate":@"inline_skating",
                                 @"Kayaking":@"whitewater_rafting_kayaking",
                                 @"Kitesurf":@"wind_kite_surfing",
                                 @"NordicSki":@"cross_country_skiing",
                                 @"Ride":   GC_TYPE_CYCLING,
                                 @"RockClimbing":@"rock_climbing",
                                 @"RollerSki":@"skate_skiing",
                                 @"Rowing" :@"rowing",
                                 @"Run":    GC_TYPE_RUNNING,
                                 @"Snowboard":@"resort_skiing_snowboarding",
                                 @"Snowshoe":@"snow_shoe",
                                 @"StairStepper": @"stair_climbing",
                                 @"StandUpPaddling":@"stand_up_paddleboarding",
                                 @"Surfing":@"surfing",
                                 @"Swim":   GC_TYPE_SWIMMING,
                                 @"VirtualRide":GC_TYPE_CYCLING,
                                 @"Walk":   GC_TYPE_WALKING,
                                 @"WeightTraining":@"strength_training",
                                 @"Windsurf":@"wind_kite_surfing",
                                 @"Workout":GC_TYPE_FITNESS,
                                 @"Yoga":@"other",

                                 };
        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
        for (NSString * stravaType in types) {
            NSString * typeKey = types[stravaType];
            GCActivityType * type = self.typesByKey[typeKey];
            if (type) {
                dict[[stravaType lowercaseString]] = type;
            }
        }
        cache = dict;
    }
    return cache[[stravaType lowercaseString]];
}

-(NSArray<GCActivityType*>*)allTypes{
    NSArray * rv = [self.typesByKey.allValues sortedArrayUsingComparator:^(GCActivityType*a1, GCActivityType*a2){
        return a1.typeId < a2.typeId ? NSOrderedAscending : (a1.typeId > a2.typeId ? NSOrderedDescending : NSOrderedSame);
    }];
    return rv;
}
-(NSArray<NSString*>*)allTypesKeys{
    NSArray * allTypes = [self allTypes];
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:allTypes.count];
    for (GCActivityType * type in allTypes) {
        [rv addObject:type.key];
    }
    return rv;
}

-(NSUInteger)count{
    return self.typesByKey.count;
}

-(NSArray<GCActivityType*>*)allParentTypes{
    NSMutableDictionary * rv = [NSMutableDictionary dictionaryWithCapacity:self.typesByKey.count];
    for (NSString * key in self.typesByKey) {
        GCActivityType * type = self.typesByKey[key];
        if (type.parentType != nil && !type.parentType.isRootType) {
            rv[type.parentType] = rv[type.parentType] ? @([rv[type.parentType] integerValue]+1) : @(1);
        }
    }
    return rv.allKeys;
}

-(NSArray<GCActivityType*>*)allTypesForParent:(GCActivityType*)parentType{
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:self.typesByKey.count];
    for (NSString * key in self.typesByKey) {
        GCActivityType * type = self.typesByKey[key];
        if (type.parentType != nil && [type.parentType isEqualToActivityType:parentType]){
            [rv addObject:type];
        }
    }
    return rv;
}

@end
