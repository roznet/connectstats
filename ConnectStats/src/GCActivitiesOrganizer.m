//  MIT Licence
//
//  Created on 08/09/2012.
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

#import "GCActivitiesOrganizer.h"
#import "GCAppGlobal.h"
#import "GCActivity.h"
#import "GCFields.h"
#import "Flurry.h"
#import "GCActivitySearch.h"
#import "GCHealthOrganizer.h"
#import "GCWeather.h"
#import "GCActivityTennis.h"
#import "GCActivity+Import.h"
#import "GCActivity+Database.h"
#import "GCService.h"
#import "GCActivityTennisShotValues.h"
#import "GCActivityTennisCuePoint.h"
#import "GCActivityTennisHeatmap.h"
#import "GCActivity+Database.h"


#define GC_SYNC_KEY(act,service) [[act activityId] stringByAppendingString:service]

NSString * INFO_ACTIVITY_TYPES = @"activity_types";
NSString * INFO_ACTIVITY_TYPE_COUNT = @"activity_type_count";
NSString * INFO_ACTIVITY_TYPE_LATEST = @"activity_type_latest";

NSString * kNotifyOrganizerLoadComplete = @"kNotifyOrganizerLoadComplete";
NSString * kNotifyOrganizerListChanged = @"kNotifyOrganizerListChanged";
NSString * kNotifyOrganizerReset = @"kNotifyOrganizerReset";

@interface GCActivitiesOrganizer ()
@property (nonatomic,retain) NSArray * allActivities;

@property (nonatomic,retain) FMDatabase * tennisdbCache;
@property (nonatomic,retain) NSDictionary<NSString*,NSMutableDictionary*> * info;
@property (nonatomic,retain) NSMutableDictionary * duplicateActivityIds;

@property (nonatomic,assign) NSUInteger nextForGeocoding;
@property (nonatomic,assign) BOOL geocoding;
@property (nonatomic,retain) NSString * focusedField;
@property (nonatomic,retain) GCWebReverseGeocode * reverseGeocoder;
@property (nonatomic,retain) NSMutableDictionary * synchronized;
@property (nonatomic,retain) NSArray * filteredIndices;
@property (nonatomic,assign) BOOL testMode;
@property (nonatomic,retain) dispatch_queue_t worker;

@property (nonatomic,assign) BOOL loadCompleted;

@property (nonatomic,retain) GCHealthOrganizer * storedHealth;


@end

@implementation GCActivitiesOrganizer
//@synthesize db,allActivities,currentActivityIndex,reverseGeocoder,focusedField;


-(GCActivitiesOrganizer*)init{
    return [self initWithDb:nil andThread:nil];
}

-(GCActivitiesOrganizer*)initWithDb:(FMDatabase*)aDb{
    return [self initWithDb:aDb andThread:nil];
}

-(GCActivitiesOrganizer*)initWithDb:(FMDatabase*)aDb andThread:(dispatch_queue_t)thread{
    self = [super init];
    if (self) {
        self.db = aDb;
        self.reverseGeocoder = RZReturnAutorelease([[GCWebReverseGeocode alloc]initWithOrganizer:self andDel:self]);
        self.worker = thread;
        if (aDb) {
            if (thread) {
                dispatch_async(thread,^(){
                    [self loadFromDb];
                });
            }else{
                [self loadFromDb];
            }
        }
    }
    return self;
}

-(GCActivitiesOrganizer*)initTestModeWithDb:(FMDatabase*)aDb{
    self = [super init];
    if (self) {
        self.testMode = true;
        self.db = aDb;
        [self setReverseGeocoder:nil];
        [self loadFromDb];
    }
    return self;

}

-(void)dealloc{
    _reverseGeocoder.organizer = nil;
    _reverseGeocoder.delegate=nil;
    _reverseGeocoder.geocoder=nil;
    [_reverseGeocoder release];

    [_allActivities release];
    [_focusedField release];
    [_activitiesTrash release];
    [_synchronized release];
    [_filteredIndices release];
    [_lastSearchString release];
    [_worker release];
    [_db release];
    [_tennisdbCache release];
    [_info release];
    [_filteredActivityType release];
    [_duplicateActivityIds release];
    [_storedHealth release];

    [super dealloc];
}

-(void)buildInfoDictionary{
    if (!self.info) {
        self.info = @{
                      INFO_ACTIVITY_TYPES: [NSMutableDictionary dictionary],
                      };
    }
}

/** @brief record activity type currently in the list of activities
 */
-(void)recordActivityType:(GCActivity*)act{
    NSString * type = act.activityType;
    if( [type isEqualToString:GC_TYPE_OTHER] ){
        type = act.activityTypeDetail.key;
    }
    
    if (!self.info) {
        [self buildInfoDictionary];
    }

    if(type==nil)
        return;
    NSDictionary * info = self.info[INFO_ACTIVITY_TYPES][type];
    if (!info) {
        info = @{ INFO_ACTIVITY_TYPE_COUNT : @1, INFO_ACTIVITY_TYPE_LATEST : act.date };
    }else{
        NSDate * latest = info[INFO_ACTIVITY_TYPE_LATEST];
        NSNumber * cur = info[INFO_ACTIVITY_TYPE_COUNT];
        
        if( [latest compare:act.date] == NSOrderedAscending ){
            latest = act.date;
        }
        info = @{ INFO_ACTIVITY_TYPE_COUNT: @(cur.integerValue+1), INFO_ACTIVITY_TYPE_LATEST : latest };
    }
    self.info[INFO_ACTIVITY_TYPES][type] = info;
}

/** @brief Record All Available Activities Types, not just the one the currently list contains
 */
-(void)registerActivityTypes:(NSDictionary*)aData{
}

/** @brief ActivityTypes currently in the list of activities
 */
-(NSArray*)listActivityTypes{
    NSMutableArray * rv = [NSMutableArray array];
    NSDictionary * infos = self.info[INFO_ACTIVITY_TYPES];
    if (infos) {
        for (NSString * type in infos) {
            NSDictionary * info = infos[type];
            NSNumber * count = info[INFO_ACTIVITY_TYPE_COUNT];
            NSDate * latest = info[INFO_ACTIVITY_TYPE_LATEST];
            NSTimeInterval elapsed = [latest timeIntervalSinceNow];
            // Either more than 20 and oldest less than a year old or more than 5 and less than 3m
            if( ( count.integerValue > 20 && fabs(elapsed) < 3600. * 24. * 360.) ||
               ( count.integerValue > 5 && fabs(elapsed) < 3600. * 24. * 90.) )
            {
                [rv addObject:type];
            }
        }
    }
    [rv sortUsingComparator:^(NSString * s1, NSString * s2){
        GCActivityType * t1 = [GCActivityType activityTypeForKey:s1];
        GCActivityType * t2 = [GCActivityType activityTypeForKey:s2];
        
        if( t1.sortOrder < t2.sortOrder ){
            return NSOrderedAscending;
        }else if (t1.sortOrder > t2.sortOrder){
            return NSOrderedDescending;
        }else{
            return NSOrderedSame;
        }
    }];
    // Add ALL at the end
    [rv addObject:GC_TYPE_ALL];
    return rv;
}

-(NSString*)lastGarminLoginUsername{
    NSString * rv = nil;
    if (self.allActivities && self.allActivities.count) {
        for (GCActivity * act in self.allActivities) {
            GCActivityMetaValue * val =(act.metaData)[@"username"];
            if (val) {
                rv =val.display;
                break;
            }
        }
    }
    return rv;
}

-(GCHealthOrganizer*)health{
    if (self.storedHealth) {
        return  self.storedHealth;
    }else{
        return [GCAppGlobal health];
    }
}
-(void)setHealth:(GCHealthOrganizer *)health{
    self.storedHealth = health;
}

-(FMDatabase*)tennisdb{
    if (!self.tennisdbCache) {
        self.tennisdbCache = [FMDatabase databaseWithPath:[RZFileOrganizer writeableFilePath:[[GCAppGlobal profile] currentTennisDatabasePath]]];
        [self.tennisdbCache open];
        [GCActivityTennis ensureDbStructure:self.tennisdbCache];
    }
    return self.tennisdbCache;
}

-(void)publishEvent{
#ifdef GC_USE_FLURRY
    NSUInteger report = _allActivities.count;
    if (report > 10 && report<100) {
        report /= 10;
        report *= 10;
    }else if (report>100){
        report /= 50;
        report *= 50;
    }
    if (report > 0) {
        NSDictionary * params = @{@"Count": @((int)report)};
        [Flurry logEvent:EVENT_LOAD_ACTIVITIES withParameters:params];
    }
#endif
}

-(void)notifyOnMainThread:(NSString*)stringOrNil{
    if (stringOrNil) {
        [self performSelectorOnMainThread:@selector(notifyForString:) withObject:stringOrNil waitUntilDone:NO];
    }else{
        [self performSelectorOnMainThread:@selector(notify) withObject:nil waitUntilDone:NO];
    }
}

#pragma mark - load and update

-(void)loadSegments{

}

-(void)loadFromDb{
    if (!_db) {
        if (!self.info) {
            [self buildInfoDictionary];
        }
        self.allActivities = @[];

        return;
    }
    self.loadCompleted = false;
     NSDate * timing_start = [NSDate date];
    unsigned mem_start = [RZMemory memoryInUse];

    NSMutableDictionary * duplicates = [NSMutableDictionary dictionary];
    FMResultSet * res = nil;
    if ([_db tableExists:@"gc_duplicate_activities"]) {
        res = [_db executeQuery:@"SELECT * FROM gc_duplicate_activities"];
        while ([res next]) {
            duplicates[[res stringForColumn:@"activityId"]] = [res stringForColumn:@"duplicateActivityId"];
        }

    }
    self.duplicateActivityIds = duplicates;

    NSMutableArray * m_activities = [NSMutableArray arrayWithCapacity:[_db intForQuery:@"SELECT count(*) from gc_activities"]];

    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:m_activities.count];
    res = [_db executeQuery:@"SELECT * FROM gc_activities_meta WHERE field='activityType'"];
    while ([res next]) {
        GCActivityMetaValue * val = [GCActivityMetaValue activityValueForResultSet:res];
        dict[[res stringForColumn:@"activityId"]] = val;
    }

    res = [_db executeQuery:@"SELECT * FROM gc_activities ORDER BY BeginTimestamp DESC"];
    if (res == nil) {
        RZLog(RZLogError, @"db error: %@", [_db lastErrorMessage]);
    }
    BOOL lastLocation = false;
    NSUInteger count = 0;

    //restart, clear info dictionary
    [self buildInfoDictionary];

    BOOL hasTennis = false;

    while ([res next]) {
        count++;
        // if in background notify to display quick preview when many activities
        if (self.worker&&count==50) {
            self.allActivities = [NSArray arrayWithArray:m_activities];
            [self notifyOnMainThread:nil];
        }
        gcDownloadMethod method = [res intForColumn:@"downloadMethod"];
        GCActivity * act = nil;

        if (method==gcDownloadMethodTennis) {
            act =[[GCActivityTennis alloc] initWithResultSet:res];
            hasTennis = true;
        }else{
            act =[[GCActivity alloc] initWithResultSet:res];
            [act setDb:self.db];
        }
        if (!lastLocation && [act validCoordinate]) {
            lastLocation = true;
        }
        GCActivityMetaValue * detailAType = dict[act.activityId];
        if (detailAType) {
            if (detailAType.key && ![detailAType.key isEqualToString:@""]) {
                act.activityTypeDetail = [GCActivityType activityTypeForKey:detailAType.key];
            }else{
                act.activityTypeDetail = [GCActivityType activityTypeForKey:detailAType.display];
            }
        }
        [self recordActivityType:act];
        [m_activities addObject:act];
        [act release];
    }
    [res close];
    self.allActivities = [NSArray arrayWithArray:m_activities];

    if (hasTennis) {
        [self addTennisFields];
    }
    [self addSummaryFields:nil];
    [self addWeather];
    [self clearFilter];

    self.worker = nil;
    self.loadCompleted = true;

    if (!self.testMode) {

        RZLog(RZLogInfo, @"Loaded %d activities [%.1f sec %@]",(int)[_allActivities count], [[NSDate date] timeIntervalSinceDate:timing_start],
              [RZMemory formatMemoryInUseChangeSince:mem_start]);
        NSDictionary * summary = [self serviceSummary];
        for (NSString * serviceName in summary) {
            NSDictionary *serviceSummary = summary[serviceName];
            RZLog( RZLogInfo, @"%@: %@ activities [From: %@ to %@]", serviceName, serviceSummary[@"count"], serviceSummary[@"earliest"], serviceSummary[@"latest"]);
        }
        [_reverseGeocoder start];
        [self performSelectorOnMainThread:@selector(publishEvent) withObject:nil waitUntilDone:NO];
        [self notifyOnMainThread:nil];
        dispatch_async(dispatch_get_main_queue(), ^(){
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyOrganizerLoadComplete object:nil];
        });
    }
    [self lookForAllDuplicate];
    
}


-(void)postNotificationListChanged{
    dispatch_async(dispatch_get_main_queue(), ^(){
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyOrganizerListChanged object:nil];
    });

}

-(void)postNotificationReset{
    dispatch_async(dispatch_get_main_queue(), ^(){
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyOrganizerReset object:nil];
    });

}

-(void)updateForNewProfile{
    self.db = [GCAppGlobal db];
    _currentActivityIndex = 0;
    dispatch_async([GCAppGlobal worker],^(){
        [self loadFromDb];
    });

    [self postNotificationReset];
}

-(void)reloadActivity:(NSString*)aId withGarminData:(NSDictionary*)aData{
    GCActivity * activity = [self activityForId:aId];
    if (activity) {
        [activity updateWithGarminData:aData];
        [activity saveToDb:self.db];
    }else{
        [self registerActivity:RZReturnAutorelease([[GCActivity alloc] initWithId:aId andGarminData:aData]) forActivityId:aId];
    }
}

-(void)registerTennisActivity:(NSString *)aId withBabolatData:(NSDictionary *)aData{
    if ([GCAppGlobal trialVersion] && _allActivities.count > 20) {
        return;
    }
    NSString *activityId = [[GCService service:gcServiceBabolat] activityIdFromServiceId:aId];

    GCActivity * existing = [self activityForId:activityId];
    if (!existing) {
        NSMutableArray * m_activities = [NSMutableArray arrayWithArray:_allActivities];
        GCActivityTennis * act = RZReturnAutorelease([[GCActivityTennis alloc] initWithId:activityId andBabolatData:[NSMutableDictionary dictionaryWithDictionary:aData]]);
        if (m_activities.count > 0 && [[m_activities[0] date] compare:act.date] == NSOrderedAscending) {
            [m_activities insertObject:act atIndex:0];
        }else{
            [m_activities addObject:act];
        }
        [m_activities sortUsingComparator:^(id obj1, id obj2){
            return [[obj2 date] compare:[obj1 date]];
        }];
        self.allActivities = [NSArray arrayWithArray:m_activities];
        [self notifyOnMainThread:aId];
    }
}
-(void)registerTennisActivity:(NSString *)aId withFullSession:(NSDictionary *)aData{
    if ([GCAppGlobal trialVersion] && _allActivities.count > 20) {
        return;
    }
    NSString *activityId = [[GCService service:gcServiceBabolat] activityIdFromServiceId:aId];

    GCActivity * existing = [self activityForId:activityId];
    if (existing && [existing isKindOfClass:[GCActivityTennis class]]) {
        GCActivityTennis * activity = (GCActivityTennis*)existing;
        [activity saveSession:aData];
    }
}

-(void)registerTemporaryActivity:(GCActivity*)act forActivityId:(NSString*)aId{
    [self registerActivity:act forActivityId:aId save:NO];
}
-(BOOL)registerActivity:(GCActivity*)act forActivityId:(NSString*)aId{
    return [self registerActivity:act forActivityId:aId save:YES];
}

-(BOOL)registerActivity:(GCActivity*)act forActivityId:(NSString*)aId save:(BOOL)save{
    if ([GCAppGlobal trialVersion] && _allActivities.count > 20) {
        return false;
    }
    BOOL rv = false;

    if( ![act isActivityValid] || aId == nil){
        RZLog(RZLogError, @"Trying to register invalid activity %@", act);
        return rv;
    }

    GCActivity * existing = [self activityForId:aId];

    if (existing) {
        if ([existing updateWithActivity:act]){
            rv = true;
            if (save) {
                [existing saveToDb:self.db];
                RZLog(RZLogInfo, @"%@ update found and saved", act);
            }
            [self notifyOnMainThread:aId];
        }
    }else{

        if ([GCAppGlobal configGetBool:CONFIG_MERGE_IMPORT_DUPLICATE defaultValue:true]) {
            GCActivity * other = [self findDuplicate:act];
            if (other) {
                gcDuplicate reason = [other testForDuplicate:act];
                BOOL duplicateServiceIsPreferred = (reason == gcDuplicateSynchronizedService) && [act.service preferredOver:other.service];
                
                // don't record if already
                if( self.duplicateActivityIds[act.activityId] == nil) {
                    self.duplicateActivityIds[act.activityId] = other.activityId;
                    [self.db executeUpdate:@"INSERT INTO gc_duplicate_activities (activityId,duplicateActivityId) VALUES (?,?)", act.activityId, other.activityId];
                
                    gcDuplicate reason = [other testForDuplicate:act];
                    // This is
                    if( reason == gcDuplicateNotMatching){
                        reason = [act testForDuplicate:other];
                        if( reason != gcDuplicateNotMatching ){
                            RZLog(RZLogWarning,@"Duplicate test for %@ and %@ appear not symetric", act.activityId, other.activityId);
                        }
                    }
                    
                    NSString * reasonDescription = [GCActivity duplicateDescription:reason];
                    
                    // If from same service, and preferred, take the extra info
                    if( duplicateServiceIsPreferred ){
                        RZLog(RZLogInfo, @"Duplicate (%@): updating %@ (preferred: %@)", reasonDescription, other.activityId, act.activityId );
                        // Avoid trivial case where exact same pointer/activity
                        if( act != other ){
                            [other updateMissingFromActivity:act];
                        }
                    }else{
                        RZLog(RZLogInfo, @"Duplicate (%@): skipping %@ (preferred: %@)", reasonDescription, act.activityId, other.activityId);
                    }
                }else{
                    // Update missing again as some edit can happen later
                    if( duplicateServiceIsPreferred && act != other ){
                        [other updateMissingFromActivity:act];
                    }

                }
                return rv;
            }
        }
        rv = true;
        if (save) {
            [act saveToDb:self.db];
        }
        NSMutableArray * m_activities = [NSMutableArray arrayWithArray:_allActivities];
        if (m_activities.count > 0 && [[m_activities[0] date] compare:act.date] != NSOrderedDescending) {
            [m_activities insertObject:act atIndex:0];
        }else{
            [m_activities addObject:act];
        }
        [m_activities sortUsingComparator:^(id obj1, id obj2){
            return [[obj2 date] compare:[obj1 date]];
        }];
        self.allActivities = [NSArray arrayWithArray:m_activities];
        [self recordActivityType:act];
        [self notifyOnMainThread:aId];
        [_reverseGeocoder start];
    }
    return rv;
}

-(void)registerActivity:(NSString*)aId withStravaData:(NSDictionary*)aData{
    GCActivity * act = RZReturnAutorelease([[GCActivity alloc] initWithId:aId andStravaData:aData]);
    [self registerActivity:act forActivityId:aId];
}

-(void)registerActivity:(NSString*)aId withGarminData:(NSDictionary*)aData{
    GCActivity * act = RZReturnAutorelease([[GCActivity alloc] initWithId:aId andGarminData:aData]);
    [self registerActivity:act forActivityId:aId];
}

-(void)registerActivity:(NSString *)aId withWeather:(GCWeather *)aData{
    [[self activityForId:aId] recordWeather:aData];
    //needed?
    //[self notifyOnMainThread];
}
-(void)registerActivity:(NSString*)aId withTrackpoints:(NSArray*)aTrack andLaps:(NSArray*)laps{
    if ([[self activityForId:aId] saveTrackpoints:aTrack andLaps:laps]) {
        [self notifyOnMainThread:aId];
    }
}

-(void)registerActivity:(NSString*)aId withTrackpointsSwim:(NSArray<GCTrackPointSwim*>*)aTrack andLaps:(NSArray<GCLapSwim*>*)laps{
    [[self activityForId:aId] saveTrackpointsSwim:aTrack andLaps:laps];
    [self notifyOnMainThread:aId];
}


#pragma mark - access

-(void)lookForAllDuplicate{
    // Ability to disable duplicate check for old tests.
    if (![GCAppGlobal configGetBool:CONFIG_FULL_DUPLICATE_CHECK defaultValue:true]) {
        return;
    }
    NSMutableDictionary * found = [NSMutableDictionary dictionary];
    GCActivity * last = nil;
    NSUInteger reportCount = 0;
    for (GCActivity * one in self.allActivities) {
        if( last ){
            if( [last.activityId hasPrefix:@"__bab"]){
                continue; // will deal with tennis later
            }
            
            gcDuplicate activitiesAreDuplicate = [one testForDuplicate:last];
            
            if( activitiesAreDuplicate != gcDuplicateNotMatching){
                BOOL preferLast = true;
                if( [last.activityType isEqualToString:GC_TYPE_UNCATEGORIZED]){
                    preferLast = false;
                }
                if( [one.service preferredOver:last.service]){
                    preferLast = false;
                }

                if( [one.activityId isEqualToString:last.activityId] ){
                    if( reportCount++ < 5){
                        RZLog(RZLogInfo, @"Exact Duplicate =%@ =%@", preferLast ? last : one, preferLast ? one : last);
                    }
                }else{
                    //RZLog(RZLogInfo, @"Duplicate +%@ -%@", preferLast ? last : one, preferLast ? one : last);
                    if (preferLast) {
                        found[one.activityId] = one;
                    }else{
                        found[last.activityId] = last;
                    }
                }
            }
        }
        last = one;
    }
    if (found.count > 0) {
        NSUInteger dupCount = found.count;
        NSUInteger preCount = self.allActivities.count;

        NSMutableArray * fixed = [NSMutableArray arrayWithCapacity:preCount];
        for (GCActivity * one in self.allActivities) {
            if( ! found[one.activityId]){
                [fixed addObject:one];
            }
        }
        self.allActivities = fixed;
        RZLog(RZLogInfo, @"Found %lu duplicates (%lu activities left)", (unsigned long)dupCount, (unsigned long)self.allActivities.count );

    }

}
-(NSUInteger)countOfKnownDuplicates{
    return self.duplicateActivityIds.count;
}
-(GCActivity*)findDuplicate:(GCActivity*)act{
    if (self.duplicateActivityIds[act.activityId]) {
        NSString * otherId = self.duplicateActivityIds[act.activityId];
        GCActivity * other = [self activityForId:otherId];
        return other;
    }

    for (GCActivity * other in _allActivities) {
        if (other==act) {
            // don't check for exact same activity, of course they would be duplicate...
            continue;
        }
        if ([act testForDuplicate:other] != gcDuplicateNotMatching) {
            return other;
        }
    }
    return nil;
}


-(BOOL)isKnownDuplicate:(GCActivity*)act{
    return self.duplicateActivityIds[act.activityId] != nil;
}
-(NSString*)hasKnownDuplicate:(GCActivity*)act{
    for (NSString * duplicateId in self.duplicateActivityIds) {
        if( [self.duplicateActivityIds[duplicateId] isEqualToString:act.activityId]){
            return duplicateId;
        }
    }
    
    return( nil );
}
-(GCActivity*)activityForId:(NSString*)aId{
    for (GCActivity * act in _allActivities) {
        if ([act.activityId isEqualToString:aId]) {
            return act;
        }
    }
    return nil;
}

-(void)setCurrentActivityId:(NSString*)aId{
    BOOL found = false;
    NSUInteger idx = 0;
    for (GCActivity * act in _allActivities) {
        if ([act.activityId isEqualToString:aId]) {
            found = true;
            break;
        }
        idx++;
    }
    if (found) {
        self.currentActivityIndex = idx;
        [self notifyOnMainThread:NOTIFY_CHANGE];
    }
}

-(GCActivity*)activityForIndex:(NSUInteger)idx{
    return idx < _allActivities.count ? (GCActivity*)_allActivities[idx] : nil;
}

-(GCActivity*)currentActivity{
    if (_currentActivityIndex <_allActivities.count) {
        return (GCActivity*)_allActivities[_currentActivityIndex];
    }
    return nil;
}

-(GCActivity*)lastActivity{
    if (_allActivities.count<1) {
        return nil;
    }
    return _allActivities[0];
}
-(GCActivity*)oldestActivity{
    if (_allActivities.count<1) {
        return nil;
    }
    return _allActivities.lastObject;
}

-(GCActivity*)compareActivity{
    if (self.hasCompareActivity && self.selectedCompareActivityIndex < _allActivities.count && self.selectedCompareActivityIndex!=self.currentActivityIndex) {
        return (GCActivity*)_allActivities[self.selectedCompareActivityIndex];
    }
    return nil;
}


-(GCActivity*)validCompareActivityFor:(GCActivity*)activity{
    GCActivity * compareActivity = [self compareActivity];
    if (compareActivity &&
        ![compareActivity.activityId isEqualToString:activity.activityId] /*&&
        [compareActivity.activityType isEqualToString:activity.activityType]*/
        ) {
        return compareActivity;
    }
    return nil;
}
-(NSUInteger)countOfActivities{
    return _allActivities.count;
}
-(NSArray*)activities{
    return _allActivities;
}
-(void)setActivities:(NSArray*)activities{
    self.allActivities = activities;
}

-(NSArray*)activitiesMatching:(gcActivityOrganizerMatchBlock)match withLimit:(NSUInteger)limit{
    NSMutableArray * rv = [NSMutableArray array];
    for (GCActivity * act in _allActivities) {
        if (match(act)) {
            [rv addObject:act];
        }
        if (rv.count >= limit) {
            break;
        }
    }

    return rv;
}

-(NSDictionary*)serviceSummary{
    NSMutableDictionary * rv = [NSMutableDictionary dictionary];
    for (GCActivity * act in self.allActivities) {
        GCService * service = act.service;
        if( service == nil || ![service respondsToSelector:@selector(displayName)] ||
           ![act.date isKindOfClass:[NSDate class]]){
            continue;
        }
        NSMutableDictionary * serviceDict = rv[service.displayName];
        if( serviceDict == nil){
            serviceDict = [NSMutableDictionary dictionary];
            rv[service.displayName] = serviceDict;
        }
        
        NSNumber * count = serviceDict[@"count"];
        NSDate   * earliest = serviceDict[@"earliest"];
        NSDate   * latest   = serviceDict[@"latest"];
        
        if( count == nil){
            count = @(1);
        }else{
            count = @(count.integerValue + 1);
        }
        
        if( !earliest || [earliest compare:act.date] == NSOrderedDescending ){
            earliest = act.date;
        }
        
        if( !latest || [latest compare:act.date] == NSOrderedAscending ){
            latest = act.date;
        }
        
        serviceDict[@"count"] = count;
        serviceDict[@"earliest"] = earliest;
        serviceDict[@"latest"] = latest;
    }
    return rv;
}

-(NSArray*)activitiesWithin:(NSTimeInterval)time of:(NSDate*)date{
    NSMutableArray * rv = [NSMutableArray array];
    for (GCActivity * act in _allActivities) {
        if (fabs([act.date timeIntervalSinceDate:date])<time) {
            [rv addObject:act];
        }
    }
    return rv;
}

+(void)ensureDbStructure:(FMDatabase*)db{
    [GCActivity ensureDbStructure:db];
    [GCFields ensureDbStructure:db];

    if (![db tableExists:@"gc_list_activity_types"]) {
        [db executeUpdate:@"CREATE TABLE gc_list_activity_types (activityTypeDetail TEXT, description TEXT, activityTypeParent TEXT, activityType TEXT )"];
    }
    if (![db tableExists:@"gc_duplicate_activities"]) {
        [db executeUpdate:@"CREATE TABLE gc_duplicate_activities (activityId TEXT, duplicateActivityId TEXT )"];
    }
}

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo*)theInfo{
    [self notifyOnMainThread:nil];
}

-(void)reverseGeocodeDone{
    //[self notifyOnMainThread];
}


-(NSArray<GCActivity*>*)activitiesFromDate:(NSDate*)aFrom to:(NSDate*)aTo{
    NSMutableArray * rv = [ NSMutableArray arrayWithCapacity:10];
    for (GCActivity * act in _allActivities) {
        BOOL inside  = [act.date compare:aTo]   == NSOrderedAscending;
        BOOL tooearly = [act.date compare:aFrom] == NSOrderedAscending;
        if (tooearly) {
            break;
        }
        if (inside) {
            [rv addObject:act];
        }
    }
    return rv;
}

-(void)purgeCache{
    RZLog(RZLogInfo, @"Purge Cache");

    GCActivity * current =[self currentActivity];
    for (GCActivity * act in _allActivities) {
        if (act != current) {
            [act purgeCache];
        }
    }
}

#pragma mark - filter

-(void)filterForQuickFilter{
    self.filteredIndices = [self activityIndexesForQuickFilter];
    self.lastSearchString = nil;
}

-(void)filterForSearchString:(NSString*)str{
    if (str) {
        self.filteredIndices =[self activityIndexesMatchingString:str];
        self.lastSearchString = str;
    }else{
        self.filteredIndices = nil;
        self.lastSearchString = nil;
    }
}
-(void)clearFilter{
    self.filteredIndices = nil;
    self.lastSearchString = nil;
}

-(NSArray*)filteredActivities{
    if (self.filteredIndices == nil) {
        return self.allActivities;
    }
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:(self.filteredIndices).count];
    for (NSNumber * index in self.filteredIndices) {
        NSUInteger idx = index.integerValue;
        [rv addObject:(self.allActivities)[idx]];
    }
    return rv;
}

-(NSUInteger)countOfFilteredActivities{
    return self.filteredIndices ? (self.filteredIndices).count : (self.allActivities).count;
}
-(GCActivity*)filteredActivityForIndex:(NSUInteger)idx{
    if (self.filteredIndices) {
        NSUInteger aIdx = idx < self.filteredIndices.count ? [self.filteredIndices[idx] integerValue] : 0;

        if ( aIdx < self.allActivities.count ){
            return self.allActivities[aIdx];
        }else{
            return nil;
        }
    }else{
        if (idx<self.allActivities.count) {
            return (self.allActivities)[idx];
        }else{
            return nil;
        }
    }
}
-(NSUInteger)activityIndexForFilteredIndex:(NSUInteger)idx{
    if (self.filteredIndices) {
        return [(self.filteredIndices)[idx] integerValue];
    }else{
        return idx;
    }
}
-(NSUInteger)filteredIndexForActivityIndex:(NSUInteger)idx{
    if (self.filteredIndices) {
        return [self.filteredIndices indexOfObject:@(idx)];
    }else{
        return idx;
    }
}
-(BOOL)hasFilter{
    return self.filteredIndices != nil;
}

-(BOOL)isQuickFilterApplicable{
    NSDictionary * dict = self.info[INFO_ACTIVITY_TYPES];
    return dict[GC_TYPE_DAY] && dict.count > 1;
}

-(NSArray*)activityIndexesForQuickFilter{
    NSUInteger n = [self countOfActivities];
    NSMutableArray * filteredIndexes=[NSMutableArray arrayWithCapacity:n];

    NSString * commonActivityType = nil;

    gcIgnoreMode mode = gcIgnoreModeActivityFocus;

    for (NSUInteger i=0; i<n; i++) {
        GCActivity * act = _allActivities[i];
        if (![act ignoreForStats:mode]) {
            if (commonActivityType == nil) {
                commonActivityType = act.activityType;
            }else{
                if (![commonActivityType isEqualToString:act.activityType]) {
                    commonActivityType = GC_TYPE_ALL;
                }
            }

            [filteredIndexes addObject:@(i)];
        }
    }
    self.filteredActivityType = commonActivityType;

    return filteredIndexes;

}

-(NSArray*)activityIndexesMatchingString:(NSString*)str{
    if (str == nil || [str isEqualToString:@""]) {
        return nil;
    }

    GCActivitySearch * asearch = [GCActivitySearch activitySearchWithString:str];
    NSUInteger n = [self countOfActivities];
    NSMutableArray * filteredIndexes=[NSMutableArray arrayWithCapacity:n];

    NSDictionary * dbg = [GCAppGlobal debugState];
    NSNumber * lastSum = dbg[DEBUGSTATE_LAST_SUM];
    NSNumber * lastCnt = dbg[DEBUGSTATE_LAST_CNT];

    double sum = 0;
    double cnt = 0;

    NSString * commonActivityType = nil;

    for (NSUInteger i=0; i<n; i++) {
        GCActivity * act = _allActivities[i];
        if ([asearch match:act]) {
            if (commonActivityType == nil) {
                commonActivityType = act.activityType;
            }else{
                if (![commonActivityType isEqualToString:act.activityType]) {
                    commonActivityType = GC_TYPE_ALL;
                }
            }

            [filteredIndexes addObject:@(i)];
            sum += [act summaryFieldValueInStoreUnit:gcFieldFlagSumDistance];
            cnt += 1.;
        }
    }
    self.filteredActivityType = commonActivityType;
    if ((lastCnt && fabs(lastCnt.doubleValue-cnt)>1e-6)||(lastSum && fabs(lastSum.doubleValue-sum)>1e-6)) {
        RZLog(RZLogError, @"Inconsistent sum/filter cnt exp=%.0f/got=%.0f, sum exp=%.2f/got=%.2f (%.2f)",
              [lastCnt doubleValue],cnt,[lastSum doubleValue],sum,[lastSum doubleValue]-sum);
        RZLog(RZLogInfo,  @"Filter: %@", str);
        int ii = 0;
        NSUInteger nn = filteredIndexes.count;
        for (NSNumber * idx in filteredIndexes) {
            if (ii < 30 || (nn-ii)<5) {
                GCActivity * act = _allActivities[idx.integerValue];
                RZLog(RZLogInfo, @" %d: %@ %@ %f", ii, [act date], [act activityType], [act summaryFieldValueInStoreUnit:gcFieldFlagSumDistance] );
            }
            ii++;
        }
    }
    [GCAppGlobal debugStateClear];

    return filteredIndexes;
}


/**
 This function will look for activities that are in the current organizer but have been removed
 from the service feed. This means the activity was removed from the service and should be
 removed from the organizer
 
 The logic will only apply from the first Id if found in the organizer list to the last one,
 because this is only potentially information about deleted activities BETWEEN the first and last
 currently being looked at.

 @param inIds List of activities Ids that were returned by the service
 @param isFirst If this is the first query from the service, we should
    assume that from the beginning the first activity is present (handle case where latest activity was deleted
 @return List of activities to delete
 */
-(NSArray*)findActivitiesNotIn:(NSArray<NSString*>*)inIds isFirst:(BOOL)isFirst{
    if (inIds.count < 1) {
        return nil;
    }
    NSUInteger idx = 0;
    NSMutableArray * deleteCandidate = [NSMutableArray array];

    NSMutableArray * altIds = [NSMutableArray array];
    for (NSString * one in inIds) {
        NSString * dup = self.duplicateActivityIds[one];
        if( dup ){
            [altIds addObject:dup];
        }
    }
    
    BOOL foundFirst = isFirst;
    BOOL foundLast = false;

    NSString * first = inIds[0];
    NSString * last = inIds.lastObject;

    for (idx=0; idx < _allActivities.count; idx++ ) {
        GCActivity * act = _allActivities[idx];
        // Don't look at day activities only fitness
        if( [act.activityType isEqualToString:GC_TYPE_DAY] ){
            continue;
        }
        if ([act.activityId isEqualToString:first]) {
            foundFirst = true;
        }
        if ([act.activityId isEqualToString:last]) {
            foundLast = true;
            break;
        }
        if (foundFirst) {
            if ([inIds indexOfObject:act.activityId] == NSNotFound &&
                [altIds indexOfObject:act.activityId] == NSNotFound) {
                if(act.parentId == nil || [inIds indexOfObject:act.parentId] == NSNotFound){
                    [deleteCandidate  addObject:act.activityId];
                }
            }
        }
    }
    return foundLast ? deleteCandidate : nil;

}

#pragma mark - delete

-(void)deleteAllActivities{
    RZLog(RZLogInfo, @"delete all");
    [_db beginTransaction];
    [_db executeUpdate:@"DELETE FROM gc_activities"];
    [_db executeUpdate:@"DELETE FROM gc_activities_values"];
    [_db executeUpdate:@"DELETE FROM gc_activities_meta"];
    [_db executeUpdate:@"DELETE FROM gc_duplicate_activities"];
    [_db commit];
    _currentActivityIndex = 0;
    [GCAppGlobal saveSettings];
    self.allActivities = [NSMutableArray arrayWithCapacity:_allActivities.count];
    self.duplicateActivityIds = [NSMutableDictionary dictionary];
    [self notify];

}

-(void)deleteActivitiesInTrash{
    if (self.activitiesTrash.count) {
        NSMutableArray * newActivities = [NSMutableArray arrayWithCapacity:_allActivities.count];

        NSMutableDictionary * toDelete = [NSMutableDictionary dictionaryWithObjects:_activitiesTrash forKeys:_activitiesTrash];

        for (GCActivity * act in _allActivities) {
            if (toDelete[act.activityId] == nil) {
                [newActivities addObject:act];
            }
        }
        self.allActivities = [NSArray arrayWithArray:newActivities];
        if (self.currentActivityIndex >= newActivities.count) {
            self.currentActivityIndex = 0;
        }

        [_db beginTransaction];
        for (NSString * activityId in _activitiesTrash) {
            RZLog(RZLogInfo, @"delete index %@", activityId);
            RZEXECUTEUPDATE(_db, @"DELETE FROM gc_activities WHERE activityId=?", activityId);
            RZEXECUTEUPDATE(_db, @"DELETE FROM gc_activities_values WHERE activityId=?", activityId);
            RZEXECUTEUPDATE(_db, @"DELETE FROM gc_activities_meta WHERE activityId=?", activityId);
            RZEXECUTEUPDATE(_db, @"DELETE FROM gc_duplicate_activities WHERE activityId=?",activityId);
            RZEXECUTEUPDATE(_db, @"DELETE FROM gc_duplicate_activities WHERE duplicateActivityId=?",activityId);
            [RZFileOrganizer removeEditableFile:[NSString stringWithFormat:@"track_%@.db",activityId]];
            [[GCAppGlobal derived] forceReprocessActivity:activityId];
        }
        [_db commit];
        [self deleteDuplicateForActivities:self.activitiesTrash];
        self.activitiesTrash = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self notify];
        });
    }
}

-(void)deleteActivityId:(NSString*)aId{
    for (NSUInteger idx = 0; idx<_allActivities.count; idx++) {
        GCActivity * act = _allActivities[idx];
        if ([act.activityId isEqualToString:aId ]) {
            [self deleteActivityAtIndex:idx];
            return;
        }
    }
}

-(void)deleteActivityAtIndex:(NSUInteger)idx{
    NSString * activityId = [_allActivities[idx] activityId];

    RZLog(RZLogInfo, @"delete index %d id %@", (int)idx, activityId);

    [_db beginTransaction];
    if (idx<_allActivities.count) {
        RZEXECUTEUPDATE(_db, @"DELETE FROM gc_activities WHERE activityId=?", activityId);
        RZEXECUTEUPDATE(_db, @"DELETE FROM gc_activities_values WHERE activityId=?", activityId);
        RZEXECUTEUPDATE(_db, @"DELETE FROM gc_activities_meta WHERE activityId=?", activityId);
        RZEXECUTEUPDATE(_db, @"DELETE FROM gc_duplicate_activities WHERE activityId=?",activityId);
        RZEXECUTEUPDATE(_db, @"DELETE FROM gc_duplicate_activities WHERE duplicateActivityId=?",activityId);
        [RZFileOrganizer removeEditableFile:[NSString stringWithFormat:@"track_%@.db",activityId]];
    }
    [_db commit];
    [self deleteDuplicateForActivities:@[ activityId ]];
    
    _currentActivityIndex = 0;
    NSMutableArray * array = [NSMutableArray arrayWithArray:_allActivities];
    [array removeObjectAtIndex:idx];
    self.allActivities = [NSArray arrayWithArray:array];
    [self notify];
}

-(void)deleteActivityUpToIndex:(NSUInteger)idx{
    [self deleteActivityFromIndex:0 toIndex:idx+1]; // +1 to delete up and include idx
}

-(void)deleteActivityFromIndex:(NSUInteger)idx{
    [self deleteActivityFromIndex:idx toIndex:self.allActivities.count];
}

-(void)deleteDuplicateForActivities:(NSArray<NSString*>*)activityIds{
    NSMutableDictionary * newDuplicates = [NSMutableDictionary dictionary];
    for (NSString * key in self.duplicateActivityIds) {
        NSString * val = self.duplicateActivityIds[key];
        if( ![activityIds containsObject:val] && ![activityIds containsObject:key] ){
            newDuplicates[key] = val;
        }
    }
    self.duplicateActivityIds = newDuplicates;
}

-(void)deleteActivityFromIndex:(NSUInteger)idxfrom toIndex:(NSUInteger)idxto{
    RZLog(RZLogInfo, @"delete from %d to %d", (unsigned)idxfrom, (unsigned)idxto);

    NSMutableArray * toDelete = [NSMutableArray arrayWithCapacity:(idxto-idxfrom)];
    [_db beginTransaction];
    for (NSUInteger i=idxfrom; i<idxto; i++) {
        if (i<_allActivities.count) {
            NSString * activityId = [_allActivities[i] activityId];
            [toDelete addObject:[_allActivities[i] activityId]];
            RZEXECUTEUPDATE(_db, @"DELETE FROM gc_activities WHERE activityId=?", activityId);
            RZEXECUTEUPDATE(_db, @"DELETE FROM gc_activities_values WHERE activityId=?", activityId);
            RZEXECUTEUPDATE(_db, @"DELETE FROM gc_activities_meta WHERE activityId=?", activityId);
            RZEXECUTEUPDATE(_db, @"DELETE FROM gc_duplicate_activities WHERE activityId=?",activityId);
            RZEXECUTEUPDATE(_db, @"DELETE FROM gc_duplicate_activities WHERE duplicateActivityId=?",activityId);
            [RZFileOrganizer removeEditableFile:[NSString stringWithFormat:@"track_%@.db",activityId]];
        }
    }
    [_db commit];
    [self deleteDuplicateForActivities:toDelete];
    
    _currentActivityIndex = 0;
    if( idxfrom == 0){
        self.allActivities = [self.allActivities subarrayWithRange:NSMakeRange(idxto, self.allActivities.count-idxto)];
    }else if (idxto == self.allActivities.count){
        self.allActivities = [self.allActivities subarrayWithRange:NSMakeRange(0, idxfrom)];
    }else{
        NSArray * start = [self.allActivities subarrayWithRange:NSMakeRange(0, idxfrom)];
        NSArray * end   = [self.allActivities subarrayWithRange:NSMakeRange(idxto, self.allActivities.count-idxto)];
        self.allActivities = [start arrayByAddingObjectsFromArray:end];
    }
    [self notify];
}

+(void)sanityCheckDb:(FMDatabase*)aDb{
    NSArray * queries = @[@"select * from gc_activities_values where value > 1000. and (uom = 'kph' or uom = 'mph') limit 5",
                     @"select * from gc_activities_values where value > 1000000. limit 5"];
    NSUInteger n = 0;
    for (NSString * query in queries) {
        FMResultSet * res = [aDb executeQuery:query];
        while ([res next]) {
            n++;
            if (n>5*queries.count) {
                break;
            }

            RZLog(RZLogWarning, @"bad val %@ %@ %f %@",
                  [res stringForColumn:@"activityId"],
                  [res stringForColumn:@"field"],
                  [res doubleForColumn:@"value"],
                  [res stringForColumn:@"uom"]);
        }
    }
    RZLog(RZLogInfo, @"Sanity Check done");
}

#pragma mark - series

-(void)addWeather{
    // First load new format
    NSString * query = @"SELECT * FROM gc_activities_weather_detail";
    NSMutableDictionary * newData = [NSMutableDictionary dictionaryWithCapacity:self.allActivities.count];
    FMResultSet * res = [self.db executeQuery:query];
    while ([res next]) {
        NSString * aId = [res stringForColumn:@"activityId"];
        GCWeather * weather = [GCWeather weatherWithResultSet:res];
        if (weather) {
            newData[aId] = weather;
        }
    }

    NSMutableDictionary * data =  [NSMutableDictionary dictionaryWithCapacity:self.allActivities.count];
    NSMutableDictionary * currentSummary = nil;
    NSString * currentId = nil;

    query = @"SELECT * FROM gc_activities_weather ORDER BY activityId DESC";

    res = [self.db executeQuery:query];
    while ([res next]) {
        if (currentId==nil || ![currentId isEqualToString:[res stringForColumn:@"activityId"]]) {
            currentId = [res stringForColumn:@"activityId"];
            currentSummary = [NSMutableDictionary dictionaryWithCapacity:5];
            data[currentId] = currentSummary;
        }
        NSString * key = [res stringForColumn:@"weatherField"];
        NSString * val = [res stringForColumn:@"weatherValue"];
        if (key&&val&&currentSummary) {
            currentSummary[key] = val;
        }
    }
    for (GCActivity * one in self.allActivities) {
        GCWeather * weather = newData[one.activityId];
        if (weather) {
            one.weather = weather;
        }else{
            NSDictionary * dict = data[one.activityId];
            if (dict) {
                one.weather = [GCWeather weatherWithData:dict];
            }
        }
    }
}

-(void)addTennisFields{
    FMDatabase * tennisdb = [self tennisdb];
    NSString * query = @"SELECT * FROM babolat_shots ORDER BY session_id DESC";

    NSString * currentId = nil;
    NSMutableDictionary * currentData = nil;
    NSMutableDictionary * shots = [NSMutableDictionary dictionary];
    NSMutableDictionary * cues =[NSMutableDictionary dictionary];
    NSMutableDictionary * heatmaps=[NSMutableDictionary dictionary];

    FMResultSet * res = [tennisdb executeQuery:query];
    while ([res next]) {
        if (![currentId isEqualToString:[res stringForColumn:@"session_id"]]) {
            currentId = [res stringForColumn:@"session_id"];
            currentData = [NSMutableDictionary dictionaryWithCapacity:20];
            shots[currentId] = currentData;
        }
        GCActivityTennisShotValues * currentShotValues = [GCActivityTennisShotValues tennisShotValuesForResultSet:res];
        currentData[currentShotValues.shotType] = currentShotValues;
    }

    query = @"SELECT * FROM babolat_cuepoints ORDER BY session_id DESC";

    currentId = nil;
    res = [tennisdb executeQuery:query];
    NSMutableArray * currentCues = nil;
    while ([res next]) {
        if (![currentId isEqualToString:[res stringForColumn:@"session_id"]]) {
            currentId = [res stringForColumn:@"session_id"];
            currentCues = [NSMutableArray arrayWithCapacity:15];
            cues[currentId] = currentCues;
        }
        GCActivityTennisCuePoint * currentCuePoint = [GCActivityTennisCuePoint cuePointFromResultSet:res];
        [currentCues addObject:currentCuePoint];
    }

    query = @"SELECT * FROM babolat_heatmaps ORDER BY session_id DESC";

    currentId = nil;
    res = [tennisdb executeQuery:query];
    NSMutableDictionary * currentHeatmaps = nil;
    while ([res next]) {
        if (![currentId isEqualToString:[res stringForColumn:@"session_id"]]) {
            currentId = [res stringForColumn:@"session_id"];
            currentHeatmaps = [NSMutableDictionary dictionaryWithCapacity:5];
            heatmaps[currentId] = currentHeatmaps;
        }
        GCActivityTennisHeatmap * currentHeatmap = [GCActivityTennisHeatmap heatmapForResultSet:res];
        currentHeatmaps[[res stringForColumn:@"heatmap_type"]] = currentHeatmap;
    }

    for (id obj in self.allActivities) {
        if ([obj isKindOfClass:[GCActivityTennis class]]) {
            GCActivityTennis * act = obj;
            [act addShots:shots[act.sessionId] cuePoints:cues[act.sessionId] andHeatmap:heatmaps[act.sessionId]];
        }
    }
}

-(void)addSummaryFields:(NSArray*)f{
    NSString * query = @"SELECT * FROM gc_activities_values ORDER BY activityId DESC";
    NSMutableDictionary * data = [NSMutableDictionary dictionaryWithCapacity:self.allActivities.count];
    NSMutableDictionary * meta = [NSMutableDictionary dictionaryWithCapacity:self.allActivities.count];
    NSString * currentId = nil;
    GCActivitySummaryValue * currentValue = nil;
    GCActivityMetaValue * metaValue = nil;

    NSMutableDictionary<NSString*,GCActivitySummaryValue*> * currentSummary = nil;
    NSMutableDictionary<NSString*,GCActivityMetaValue*> * currentMeta = nil;

    FMResultSet * res = [self.db executeQuery:query];
    while ([res next]) {
        if (![currentId isEqualToString:[res stringForColumn:@"activityId"]]) {
            currentId = [res stringForColumn:@"activityId"];
            currentSummary = [NSMutableDictionary dictionaryWithCapacity:20];
            data[currentId] = currentSummary;
        }
        currentValue = [GCActivitySummaryValue activitySummaryValueForResultSet:res];
        currentSummary[ [res stringForColumn:@"field"] ] = currentValue;
    }
    BOOL spuriousActivityCleanupRequired = false;
    query = @"SELECT * FROM gc_activities_meta ORDER BY activityId DESC";
    res = [self.db executeQuery:query];
    while ([res next]) {
        if (![currentId isEqualToString:[res stringForColumn:@"activityId"]]) {
            currentId = [res stringForColumn:@"activityId"];
            currentMeta = [NSMutableDictionary dictionaryWithCapacity:20];
            meta[currentId] = currentMeta;
        }
        metaValue = [GCActivityMetaValue activityValueForResultSet:res];
        currentMeta[[res stringForColumn:@"field"]] = metaValue;
        
        if( [metaValue.field isEqualToString:@"ownerDisplayName"] && [metaValue.display isEqualToString:@"garmin.connect"] ){
            spuriousActivityCleanupRequired = true;
        }
    }
    
    if( spuriousActivityCleanupRequired ){
        NSMutableArray * todelete = [NSMutableArray arrayWithCapacity:self.allActivities.count];
        for (GCActivity * act in self.allActivities) {
            GCActivityMetaValue * displayName = meta[act.activityId ][@"ownerDisplayName"];
            if( meta && [displayName.display isEqualToString:@"garmin.connect"]){
                [todelete addObject:act.activityId];
            }
        }
        RZLog(RZLogInfo, @"Cleanup spurious activity: delete %lu out of %lu", todelete.count, self.allActivities.count);
        self.activitiesTrash = todelete;
        [self deleteActivitiesInTrash];
    }
    

    for (GCActivity * one in self.allActivities) {
        currentSummary = data[one.activityId];
        if (currentSummary) {
            [one setSummaryDataFromKeyDict:currentSummary];
        }
        currentMeta = meta[one.activityId];
        if (currentMeta) {
            [one updateMetaData:currentMeta];
        }
        
        [GCFieldsCalculated addCalculatedFields:one];
    }
}

-(GCStatsDataSerieFilter*)standardFilterForField:(GCField*)field{
    GCStatsDataSerieFilter * filter = nil;
    gcFieldFlag aField = field.fieldFlag;
    NSString * type = field.activityType;

    if ([GCAppGlobal configGetBool:CONFIG_FILTER_BAD_VALUES defaultValue:YES]){
        if (aField == gcFieldFlagCadence){
            filter = RZReturnAutorelease([[GCStatsDataSerieFilter alloc] init]);
            filter.minValue = 1e-8;
            filter.filterMinValue = true;
        }else if (aField == gcFieldFlagWeightedMeanSpeed && ([type isEqualToString:GC_TYPE_RUNNING] ||[type isEqualToString:GC_TYPE_CYCLING])){
            filter = RZReturnAutorelease([[GCStatsDataSerieFilter alloc] init]);
            filter.minValue = [GCAppGlobal configGetDouble:CONFIG_FILTER_SPEED_BELOW defaultValue:1.0];
            filter.filterMinValue = true;
            filter.unit = [GCUnit unitForKey:STOREUNIT_SPEED];
        }else if ([field.key isEqualToString:@"DirectVO2Max"]){
            filter = RZReturnAutorelease([[GCStatsDataSerieFilter alloc] init]);
            filter.minValue = 1.;
            filter.filterMinValue = true;
        }else if ([field.key isEqualToString:@"MaxSpeed"]){
            filter = RZReturnAutorelease([[GCStatsDataSerieFilter alloc] init]);
            filter.maxValue = [type isEqualToString:GC_TYPE_RUNNING] ? 40. : 100.;
            filter.filterMaxValue = true;
            filter.unit = [GCUnit unitForKey:@"kph"];
        }else if( aField == gcFieldFlagWeightedMeanHeartRate){
            filter = RZReturnAutorelease([[GCStatsDataSerieFilter alloc] init]);
            filter.minValue = 10.;
            filter.filterMinValue = true;
            filter.unit = [GCUnit unitForKey:@"bpm"];

        }
    }
    return filter;
}

-(NSDictionary*)fieldsSeries:(NSArray*)fields
                    matching:(GCActivityMatchBlock)match
                 useFiltered:(BOOL)useFilter
                  ignoreMode:(gcIgnoreMode)ignoreMode{

    NSUInteger n = fields.count;
    NSMutableArray * actfields = [NSMutableArray arrayWithCapacity:n];
    NSMutableDictionary * rv = [NSMutableDictionary dictionaryWithCapacity:n];

    for (id field in fields) {
        if ([GCHealthMeasure isHealthField:field]) {
            rv[field] = [self.health dataSerieWithUnitForHealthField:field];
        }else{
            [actfields addObject:field];
        }
    }

    if (actfields.count) {
        NSArray * useActivities = useFilter ? [self filteredActivities] : self.allActivities;
        for (GCActivity * act in useActivities) {
            if (![act ignoreForStats:ignoreMode] && (match==nil || match(act))) {
                for (id one in actfields) {
                    GCNumberWithUnit * nu = nil;
                    GCField * field = nil;
                    if ([one isKindOfClass:[GCField class]]){
                        field = one;
                        if( [field.activityType isEqualToString:GC_TYPE_ALL]){
                            field = [field correspondingFieldForActivityType:act.activityType];
                        }
                    }else if ([one isKindOfClass:[NSString class]]) {
                        field = [GCField fieldForKey:one andActivityType:act.activityType];
                    }else if ([one isKindOfClass:[NSNumber class]]){
                        field = [GCField fieldForFlag:(gcFieldFlag)[one integerValue] andActivityType:act.activityType];
                    }
                    nu = [act numberWithUnitForField:field];
                    if (nu) {
                        nu = [nu convertToGlobalSystem];
                        GCStatsDataSerieWithUnit * serie = rv[one];
                        if (serie == nil) {
                            serie = [GCStatsDataSerieWithUnit dataSerieWithUnit:nu.unit];
                            rv[one] = serie;
                        }
                        [serie addNumberWithUnit:nu forDate:act.date];
                    }
                }
            }
        }
    }

    return rv;

}

#pragma mark - Calculated Fields

-(void)calculateField:(GCFieldsCalculated*)field for:(NSArray*)activities{

}
-(void)calculateAllFieldsForActivity:(GCActivity*)act{

}

#pragma mark - synchronization
-(void)loadSynchronized{

}

-(void)writeSynchronizedRecord:(GCActivity*)act forService:(NSString*)service{

}

-(void)recordSynchronized:(GCActivity*)act forService:(NSString*)service{
    if (self.synchronized == nil) {
        self.synchronized = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    (self.synchronized)[GC_SYNC_KEY(act,service)] = [NSDate date];
}
-(BOOL)isSynchronized:(GCActivity*)act forService:(NSString*)service{
    return false;
}

-(GCActivity*)mostRecentActivityFromService:(GCService*)service{
    for (GCActivity * act in self.allActivities) {
        if( [act.service isEqualToService:service] ){
            return act;
        }
    }
    return nil;
}

@end

