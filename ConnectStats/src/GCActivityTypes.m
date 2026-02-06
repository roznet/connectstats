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
    NSUInteger safeGuard = 8;
    while( safeGuard > 0 && stillMissing){
        stillMissing = false;
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
        for (NSNumber * typeId in defsFromDb) {
            if( byTypeId[typeId] != nil){
                continue;
            }
            NSDictionary * defs = defsFromDb[typeId];
            NSNumber * parentId = defs[kTypeParent];
            GCActivityType * parentType = byTypeId[ parentId];
            if (parentId.integerValue != 0 && parentType == nil) {
                RZLog(RZLogInfo, @"Type %@ missing parent %@", defs[kTypeKey], parentId);
            }
        }

    }
    if( byTypeId.count != byActivityType.count){
        RZLog(RZLogError, @"Inconsistency in types byKey %lu != byTypeId %lu", (unsigned long)byTypeId.count, (unsigned long)byActivityType.count);
        NSMutableDictionary * found = [NSMutableDictionary dictionary];
        for (NSNumber * typeId in byTypeId) {
            GCActivityType * type = byTypeId[typeId];
            if( found[type.key] != nil){
                RZLog(RZLogInfo, @"inconsitent %@ %@", type, found[type.key]);
            }
            found[type.key] = type;
        }
        [found removeAllObjects];
        for (NSString * typeName in byActivityType) {
            GCActivityType * type = byActivityType[typeName];
            NSNumber * typeId = @(type.typeId);
            if( byTypeId[typeId] == nil){
                GCActivityType * candidate = nil;
                for (GCActivityType * otherType in byTypeId.allValues) {
                    if( [otherType.key containsString:type.key] || [type.key containsString:otherType.key]){
                        candidate = otherType;
                        break;
                    }
                }
                if( candidate ){
                RZLog(RZLogInfo, @"Missing %@ Candidate: %@", type, candidate);
                }else{
                RZLog(RZLogInfo, @"Missing %@", type);
                }
            }
            if( found[typeId] ){
                RZLog(RZLogInfo, @"inconsitent %@ %@", type, found[type.key]);
            }
            found[typeId] = type;
        }
    }
    
    self.typesByKey = byActivityType;
    self.typesById = byTypeId;
    
    return foundNew;
}

-(void)loadPredefined{
    FMDatabase * fdb = [FMDatabase databaseWithPath:[RZFileOrganizer bundleFilePath:@"fields.db"]];
    [fdb open];

    NSMutableDictionary * defsFromDb = [NSMutableDictionary dictionary];

    FMResultSet * res = [fdb executeQuery:@"SELECT * FROM gc_activity_types"];
    while( [res next]){
        NSUInteger typeId = [res intForColumn:@"activity_type_id"];
        defsFromDb[ @(typeId) ] = @{
                                  kTypeId : @(typeId),
                                  kTypeKey : [res stringForColumn:@"activity_type"],
                                  kTypeParent : @([res intForColumn:@"parent_activity_type_id"]),
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
            
            if( ! self.typesById[typeId]){
                missing[typeId] = @{
                                    kTypeId : typeId,
                                    kTypeKey : key,
                                    kTypeParent : parentTypeId,
                                    kTypeDisplay : display,
                                    };
            }else if (![self.typesById[typeId].key isEqualToString:key]){
                RZLog(RZLogWarning, @"Inconsistent type: garmin=%@[%@] pre=%@[%@]", self.typesById[typeId], typeId, key, typeId);
            }
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

-(NSArray<GCActivityType*>*)allPrimaryTypes{
    NSMutableDictionary * rv = [NSMutableDictionary dictionaryWithCapacity:self.typesByKey.count];
    for (NSString * key in self.typesByKey) {
        GCActivityType * type = self.typesByKey[key];
        if (type.parentType != nil && !type.parentType.isRootType) {
            rv[type.parentType] = rv[type.parentType] ? @([rv[type.parentType] integerValue]+1) : @(1);
        }
    }
    return rv.allKeys;
}

-(NSArray<GCActivityType*>*)allTypesWithSamePrimaryTypeAs:(GCActivityType*)parentType{
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:self.typesByKey.count];
    for (NSString * key in self.typesByKey) {
        GCActivityType * type = self.typesByKey[key];
        if (type.parentType != nil && [type.parentType isEqualToActivityType:parentType]){
            [rv addObject:type];
        }
    }
    return rv;
}

+(NSString*)remappedLegacy:(NSString*)activityType{
    static NSDictionary<NSString*,NSString*>*map_ = nil;
    if(map_==nil){
        map_ = @{
            @"cross_country_skiing":            GC_TYPE_SKI_XC,
            @"resort_skiing_snowboarding":      GC_TYPE_SKI_DOWN,
            @"backcountry_skiing_snowboarding": GC_TYPE_SKI_BACK,
            
            @"snowmobiling":                     @"snowmobiling_ws",
            @"snow_shoe":                        @"snow_shoe_ws",
            @"skating":                          @"skating_ws",
            @"skate_skiing":                     @"skate_skiing_ws",
        };
        RZRetain(map_);
    }
    
    NSString * rv = map_[activityType];
    if( rv == nil){
        rv = activityType;
    }
        
    return rv;
}
#pragma mark - Import

-(GCActivityType*)activityTypeForFitSport:(NSString*)fitSport andSubSport:(NSString*)fitSubSport{
    static NSDictionary<NSString*,GCActivityType*> * cache = nil;
    static NSDictionary<NSString*,GCActivityType*> * cache_sub = nil;
    if( cache == nil){
        NSDictionary * sports = @{
            @"ALPINE_SKIING": @"resort_skiing_snowboarding_ws",
            @"AMERICAN_FOOTBALL": @"other",
            @"BASKETBALL": @"other",
            @"BOATING": @"boating",
            @"BOXING": @"other",
            @"CROSS_COUNTRY_SKIING": @"cross_country_skiing_ws",
            @"CYCLING": @"cycling",
            @"DRIVING": @"diving",
            @"E_BIKING": @"road_biking",
            @"FISHING": @"hunting_fishing",
            @"FITNESS_EQUIPMENT": @"fitness_equipment",
            @"FLOOR_CLIMBING": @"floor_climbing",
            @"FLYING": @"flying",
            @"GENERIC": @"other",
            @"GOLF": @"golf",
            @"HANG_GLIDING": @"hang_gliding",
            @"HIKING": @"hiking",
            @"HORSEBACK_RIDING": @"horseback_riding",
            @"HUNTING": @"hunting_fishing",
            @"ICE_SKATING": @"inline_skating",
            @"INLINE_SKATING": @"inline_skating",
            @"JUMPMASTER": @"fitness_equiment",
            @"KAYAKING": @"whitewater_rafting_kayaking",
            @"KITESURFING": @"wind_kite_surfing",
            @"MOTORCYCLING": @"motorcycling",
            @"MOUNTAINEERING": @"mountaineering",
            @"MULTISPORT": @"multi_sport",
            @"PADDLING": @"paddling",
            @"RAFTING": @"boating",
            @"ROCK_CLIMBING": @"rock_climbing",
            @"ROWING": @"rowing",
            @"RUNNING": @"running",
            @"SAILING": @"sailing",
            @"SKY_DIVING": @"sky_diving",
            @"SNOWBOARDING": @"resort_skiing_snowboarding_ws",
            @"SNOWMOBILING": @"snowmobiling_ws",
            @"SNOWSHOEING": @"snow_shoe_ws",
            @"SOCCER": @"other",
            @"STAND_UP_PADDLEBOARDING": @"stand_up_paddleboarding",
            @"SURFING": @"surfing",
            @"SWIMMING": @"swimming",
            @"TACTICAL": @"other",
            @"TENNIS": @"tennis",
            @"TRAINING": @"other",
            @"TRANSITION": @"transition",
            @"WAKEBOARDING": @"wakeboarding",
            @"WALKING": @"walking",
            @"WATER_SKIING": @"wakeboarding",
            @"WINDSURFING": @"wind_kite_surfing",
        };
    
        NSDictionary * subsports = @{
            //@"GENERIC": @"tennis",
            @"TREADMILL": @"treadmill_running",
            @"STREET": @"street_running",
            @"TRAIL": @"trail_running",
            @"TRACK": @"track_running",
            //@"SPIN": @"sailing",
            @"INDOOR_CYCLING": @"indoor_cycling",
            @"ROAD": @"road_biking",
            @"MOUNTAIN": @"mountain_biking",
            @"DOWNHILL": @"downhill_biking",
            @"RECUMBENT": @"recumbent_cycling",
            @"CYCLOCROSS": @"cyclocross",
            //@"HAND_CYCLING": @"indoor_cycling",
            @"TRACK_CYCLING": @"track_cycling",
            @"INDOOR_ROWING": @"indoor_rowing",
            @"ELLIPTICAL": @"elliptical",
            @"STAIR_CLIMBING": @"stair_climbing",
            @"LAP_SWIMMING": @"lap_swimming",
            @"OPEN_WATER": @"open_water_swimming",
            //@"FLEXIBILITY_TRAINING": @"strength_training",
            @"STRENGTH_TRAINING": @"strength_training",
            //@"WARM_UP": @"winter_sports",
            //@"MATCH": @"stop_watch",
            //@"EXERCISE": @"tennis",
            //@"CHALLENGE": @"casual_walking",
            //@"INDOOR_SKIING": @"indoor_rowing",
            //@"CARDIO_TRAINING": @"strength_training",
            //@"INDOOR_WALKING": @"indoor_rowing",
            //@"E_BIKE_FITNESS": @"road_biking",
            @"BMX": @"bmx",
            @"CASUAL_WALKING": @"casual_walking",
            @"SPEED_WALKING": @"speed_walking",
            @"BIKE_TO_RUN_TRANSITION": @"bikeToRunTransition",
            @"RUN_TO_BIKE_TRANSITION": @"runToBikeTransition",
            @"SWIM_TO_BIKE_TRANSITION": @"swimToBikeTransition",
            @"ATV": @"atv",
            @"MOTOCROSS": @"motocross",
            @"BACKCOUNTRY": @"backcountry_skiing_snowboarding_ws",
            //@"RESORT": @"winter_sports",
            @"RC_DRONE": @"rc_drone",
            @"WINGSUIT": @"wingsuit_flying",
            @"WHITEWATER": @"whitewater_rafting_kayaking",
            @"SKATE_SKIING": @"skate_skiing_ws",
            @"YOGA": @"yoga",
            @"PILATES": @"pilates",
            @"INDOOR_RUNNING": @"indoor_running",
            @"GRAVEL_CYCLING": @"gravel_cycling",
            //@"E_BIKE_MOUNTAIN": @"bikeToRunTransition",
            //@"COMMUTING": @"boating",
            //@"MIXED_SURFACE": @"wind_kite_surfing",
            //@"NAVIGATE": @"pilates",
            //@"TRACK_ME": @"track_running",
            //@"MAP": @"all",
            @"SINGLE_GAS_DIVING": @"single_gas_diving",
            @"MULTI_GAS_DIVING": @"multi_gas_diving",
            @"GAUGE_DIVING": @"gauge_diving",
            @"APNEA_DIVING": @"apnea_diving",
            @"APNEA_HUNTING": @"apnea_hunting",
            //@"VIRTUAL_ACTIVITY": @"virtual_ride",
            @"OBSTACLE": @"obstacle_run",

        };
        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
        for (NSString * sport in sports) {
            NSString * typeKey = sports[sport];
            GCActivityType * type = self.typesByKey[typeKey];
            if (type) {
                dict[ sport.lowercaseString ] = type;
            }
        }
        NSMutableDictionary * dict_sub = [NSMutableDictionary dictionary];
        for (NSString*subsport in subsports) {
            NSString * subtypeKey = subsports[subsport];
            GCActivityType * type = self.typesByKey[subtypeKey];
            if( type ){
                dict_sub[ subsport.lowercaseString ] = type;
            }
        }
        cache = RZReturnRetain(dict);
        cache_sub = RZReturnRetain( dict_sub );
    }
    GCActivityType * rv = cache[ fitSport.lowercaseString ];
    if( fitSubSport != nil){
        GCActivityType * sub = cache_sub[ fitSubSport.lowercaseString ];
        if( sub ){
            rv = sub;
        }
    }
    if( rv == nil && fitSubSport != nil && [GCActivityType isExistingActivityType:fitSubSport.lowercaseString]){
        rv = [GCActivityType activityTypeForKey:fitSubSport.lowercaseString];
    }
    if( rv == nil && fitSport != nil && [GCActivityType isExistingActivityType:fitSport.lowercaseString] ){
        rv = [GCActivityType activityTypeForKey:fitSport.lowercaseString];
    }
    return rv;
}

-(GCActivityType*)activityTypeForStravaType:(NSString*)stravaType{
    static NSMutableDictionary<NSString*,GCActivityType*> * cache = nil;
    if( cache == nil){
        NSDictionary * types = @{
                                 @"AlpineSki":@"resort_skiing_snowboarding_ws",
                                 @"BackcountrySki": @"backcountry_skiing_snowboarding_ws",
                                 @"Canoeing" :@"boating",
                                 @"Crossfit":@"fitness_equipment",
                                 @"EBikeRide":GC_TYPE_CYCLING,
                                 @"Elliptical":@"elliptical",
                                 @"Hike":   GC_TYPE_HIKING,
                                 @"IceSkate": @"skating",
                                 @"InlineSkate":@"inline_skating_ws",
                                 @"Kayaking":@"whitewater_rafting_kayaking",
                                 @"Kitesurf":@"wind_kite_surfing",
                                 @"NordicSki":@"cross_country_skiing_ws",
                                 @"Ride":   GC_TYPE_CYCLING,
                                 @"RockClimbing":@"rock_climbing",
                                 @"RollerSki":@"skate_skiing",
                                 @"Rowing" :@"rowing",
                                 @"Run":    GC_TYPE_RUNNING,
                                 @"Snowboard":@"resort_skiing_snowboarding_ws",
                                 @"Snowshoe":@"snow_shoe_ws",
                                 @"StairStepper": @"stair_climbing",
                                 @"StandUpPaddling":@"stand_up_paddleboarding",
                                 @"Surfing":@"surfing",
                                 @"Swim":   GC_TYPE_SWIMMING,
                                 @"VirtualRide":GC_TYPE_CYCLING,
                                 @"VirtualRun":GC_TYPE_RUNNING,
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
        RZRetain(cache);
    }
    GCActivityType * rv = cache[[stravaType lowercaseString]];
    if( rv == nil){
        RZLog(RZLogInfo, @"Registering missing Strava Type %@ as Other", stravaType);
        rv = GCActivityType.other;
        cache[[stravaType lowercaseString]] = rv;
    }
    return rv;
}

-(GCActivityType*)activityTypeForConnectStatsType:(NSString*)input{
    NSDictionary<NSString*,GCActivityType*> * cache = nil;
    if( cache == nil){
        NSDictionary * types = @{
                       @"ALL":@"all",
                       @"UNCATEGORIZED":@"uncategorized",
                       @"SEDENTARY":@"sedentary",
                       @"SLEEP":@"sleep",
                       @"RUNNING":@"running",
                       @"STREET_RUNNING":@"street_running",
                       @"TRACK_RUNNING":@"track_running",
                       @"TRAIL_RUNNING":@"trail_running",
                       @"TREADMILL_RUNNING":@"treadmill_running",
                       @"CYCLING":@"cycling",
                       @"CYCLOCROSS":@"cyclocross",
                       @"DOWNHILL_BIKING":@"downhill_biking",
                       @"INDOOR_CYCLING":@"indoor_cycling",
                       @"MOUNTAIN_BIKING":@"mountain_biking",
                       @"RECUMBENT_CYCLING":@"recumbent_cycling",
                       @"ROAD_BIKING":@"road_biking",
                       @"TRACK_CYCLING":@"track_cycling",
                       @"FITNESS_EQUIPMENT":@"fitness_equipment",
                       @"ELLIPTICAL":@"elliptical",
                       @"INDOOR_CARDIO":@"indoor_cardio",
                       @"INDOOR_ROWING":@"indoor_rowing",
                       @"STAIR_CLIMBING":@"stair_climbing",
                       @"STRENGTH_TRAINING":@"strength_training",
                       @"HIKING":@"hiking",
                       @"SWIMMING":@"swimming",
                       @"LAP_SWIMMING":@"lap_swimming",
                       @"OPEN_WATER_SWIMMING":@"open_water_swimming",
                       @"WALKING":@"walking",
                       @"CASUAL_WALKING":@"casual_walking",
                       @"SPEED_WALKING":@"speed_walking",
                       @"TRANSITION":@"transition",
                       @"SWIMTOBIKETRANSITION":@"swimToBikeTransition",
                       @"BIKETORUNTRANSITION":@"bikeToRunTransition",
                       @"RUNTOBIKETRANSITION":@"runToBikeTransition",
                       @"MOTORCYCLING":@"motorcycling",
                       @"OTHER":@"other",
                       @"BACKCOUNTRY_SKIING_SNOWBOARDING_WS":@"backcountry_skiing_snowboarding_ws",
                       @"BACKCOUNTRY_SKIING":@"backcountry_skiing_snowboarding_ws",
                       @"BACKCOUNTRY_SNOWBOARDING":@"backcountry_skiing_snowboarding_ws",
                       @"BOATING":@"boating",
                       @"CROSS_COUNTRY_SKIING_WS":@"cross_country_skiing_ws",
                       @"CROSS_COUNTRY_SKIING":@"cross_country_skiing_ws",
                       @"DRIVING_GENERAL":@"driving_general",
                       @"FLYING":@"flying",
                       @"GOLF":@"golf",
                       @"HORSEBACK_RIDING":@"horseback_riding",
                       @"INLINE_SKATING":@"inline_skating",
                       @"MOUNTAINEERING":@"mountaineering",
                       @"PADDLING":@"paddling",
                       @"RESORT_SKIING_SNOWBOARDING_WS":@"resort_skiing_snowboarding_ws",
                       @"RESORT_SKIING":@"resort_skiing_snowboarding_ws",
                       @"ROWING":@"rowing",
                       @"SAILING":@"sailing",
                       @"SKATE_SKIING_WS":@"skate_skiing_ws",
                       @"SKATE_SKIING":@"skate_skiing_ws",
                       @"SNOWBOARDING_WS":@"resort_skiing_snowboarding_ws",
                       @"SKATING_WS":@"skating_ws",
                       @"SNOWMOBILING_WS":@"snowmobiling_ws",
                       @"SNOWMOBILING":@"snowmobiling_ws",
                       @"SNOW_SHOE_WS":@"snow_shoe_ws",
                       @"SNOW_SHOE":@"snow_shoe_ws",
                       @"STAND_UP_PADDLEBOARDING":@"stand_up_paddleboarding",
                       @"WHITEWATER_RAFTING_KAYAKING":@"whitewater_rafting_kayaking",
                       @"WIND_KITE_SURFING":@"wind_kite_surfing",
                       @"MULTI_SPORT":@"multi_sport",
                       @"VIRTUAL_RIDE":@"virtual_ride",
                       @"VIRTUAL_RUN":@"virtual_run",
                       };
        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
        for (NSString * cstype in types) {
            NSString * typeKey = types[cstype];
            GCActivityType * type = self.typesByKey[typeKey];
            if (type) {
                dict[cstype] = type;
            }
        }
        cache = dict;
    }
    GCActivityType * rv = cache[ input ];
    if( rv == nil && [GCActivityType isExistingActivityType:[input lowercaseString]]){
        rv = [GCActivityType activityTypeForKey:[input lowercaseString]];
    }
    return rv;
}

@end
