//  MIT Licence
//
//  Created on 24/12/2013.
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

#import "GCDerivedOrganizer.h"
#import "GCAppGlobal.h"
#import "GCActivity+CachedTracks.h"
#import "GCActivitiesOrganizer.h"
#import "GCDerivedGroupedSeries.h"
#import "GCAppProfiles.h"

//Process Loop
//   Entry: Array Of Activities
//   X If allready a process queue, don't do anything
//   X set the queue for all activities not already processed
//   X Next: Take last object in queue and process
//   X  if no more in queue -> set queue to nil

//Process One activity
//    do all calculated tracks
//    loops (field,calctype) in calculated tracks
//     loop bucket in (year,month,all)
//        get current serieId & Serie for (bucket,atype,calctype,field)
//        check it wasn't processed
//        process
//        record it was processed: (SerieId -> ActivityId) in main db
//        save new serie

//Database Main
//   SerieId -> Serie Identifiers
//   Cache all SerieId Available.
//   Cache all SerieId -> ActivityId used

//Serie Identified
//      serieType: bestRollingProfile|timeInZone
//      activityType,
//      fieldName: WeightedMeanHeartRate|WeightedMeanPower|WeightedMeanSpeed
//      bucketKey:  all|MMMYY|YYYY

//Full Save:
//      serieType: bestRollingProfile|timeInZone
//      activityType,
//      fieldName: WeightedMeanHeartRate|WeightedMeanPower|WeightedMeanSpeed
//      timePeriod: month|year|overall
//      bucketStart
//      bucketEnd
//      uom
//

NSString * kNOTIFY_DERIVED_END = @"derived_end";
NSString * kNOTIFY_DERIVED_NEXT = @"derived_next";


#define DBCHECK(x) if(!x){ RZLog( RZLogError, @"Error %@", [db lastErrorMessage]); };

static NSInteger kDerivedCurrentVersion = 2;
static BOOL kDerivedEnabled = true;

@interface GCDerivedQueueElement : NSObject
@property (nonatomic,retain) GCActivity * activity;
@property (nonatomic,assign) gcFieldFlag field;
@property (nonatomic,assign) gcDerivedType derivedType;
@property (nonatomic,assign) BOOL activityLast;

+(GCDerivedQueueElement*)element:(GCActivity*)act field:(gcFieldFlag)field andType:(gcDerivedType)type activityLast:(BOOL)al;


@end

@implementation GCDerivedQueueElement

+(GCDerivedQueueElement*)element:(GCActivity*)act field:(gcFieldFlag)field andType:(gcDerivedType)type activityLast:(BOOL)al{
    GCDerivedQueueElement * rv = [[[GCDerivedQueueElement alloc] init] autorelease];
    if (rv) {
        rv.activity = act;
        rv.field = field;
        rv.derivedType = type;
        rv.activityLast = al;
    }
    return rv;
}

-(void)dealloc{
    [_activity release];
    [super dealloc];
}

@end

@interface GCDerivedOrganizer ()
@property (nonatomic,retain) FMDatabase * db;
@property (nonatomic,retain) NSMutableDictionary * derivedSeries;
@property (nonatomic,retain) NSMutableDictionary * modifiedSeries;
@property (nonatomic,retain) NSMutableDictionary * processedActivities;
@property (nonatomic,retain) dispatch_queue_t worker;
@property (nonatomic,retain) NSMutableArray * queue;
@property (nonatomic,assign) GCWebConnect * web;
@property (nonatomic,retain) RZPerformance * performance;
@end

@implementation GCDerivedOrganizer

-(instancetype)init{
    return [self initWithDb:nil andThread:nil];
}

-(NSString*)description{
    return [NSString stringWithFormat:@"<%@:%lu series>", NSStringFromClass([self class]), (long unsigned)self.derivedSeries.count];
}

-(GCDerivedOrganizer*)initWithDb:(FMDatabase*)aDb andThread:(dispatch_queue_t)thread{
    self = [super init];
    if (self) {
        self.db = aDb;
        self.worker = thread;
        self.queue = nil;
        self.web = [GCAppGlobal web];
        [self.web attach:self];
        if (thread==nil) {
            self.derivedSeries= [NSMutableDictionary dictionaryWithCapacity:10];
        }else{
            dispatch_async(self.worker,^(){
                [self loadFromDb];
            });
        }
    }
    return self;
}

-(void)dealloc{
    [self.web detach:self];
    [_modifiedSeries release];
    [_processedActivities release];
    [_db release];
    [_performance release];
    [_derivedSeries release];
    [_queue release];

    [super dealloc];
}

#pragma mark - Accessed Derived Series

-(void)loadFromDb{
    self.derivedSeries= [NSMutableDictionary dictionaryWithCapacity:10];

    if (![GCAppGlobal healthStatsVersion] && kDerivedEnabled) {
        FMDatabase * db = [self deriveddb];
        NSMutableDictionary * filenameMap = [NSMutableDictionary dictionary];

        FMResultSet * res = [self.deriveddb executeQuery:@"SELECT * FROM gc_derived_series_files"];
        while ([res next]) {
            NSInteger serieId = [res intForColumn:@"serieId"];
            NSString * fn = [res stringForColumn:@"filename"];
            filenameMap[ @(serieId)] = fn;
        }

        res= [db executeQuery:@"SELECT * FROM gc_derived_series"];
        while ([res next]) {
            GCDerivedDataSerie * serie = [GCDerivedDataSerie derivedDataSerieFromResultSet:res];
            if (filenameMap[@(serie.serieId)]) {
                [serie registerFileName:filenameMap[@(serie.serieId)]];
            }
            self.derivedSeries[serie.key] = serie;
        }
        RZLog(RZLogInfo, @"Loaded %d derived series", (int)self.derivedSeries.count);
        [self loadProcesseActivities];
    }
}

-(GCDerivedDataSerie*)derivedDataSerieForKey:(NSString*)key{
    return (self.derivedSeries)[key];
}

-(NSArray<GCDerivedGroupedSeries*>*)groupedSeriesMatching:(GCDerivedDataSerieMatchBlock)match{
    NSMutableArray * rv = [NSMutableArray array];

    NSMutableDictionary * byField = [NSMutableDictionary dictionary];

    for (NSString * key in self.derivedSeries) {
        GCDerivedDataSerie * serie = self.derivedSeries[key];
        if (!serie.isEmpty && match(serie)) {
            GCDerivedGroupedSeries * grouped = byField[serie.field];
            if (grouped == nil) {
                grouped = [GCDerivedGroupedSeries groupedSeriesStartingWith:serie];
                byField[serie.field] = grouped;
            }else{
                [grouped addSerie:serie];
            }
        }
    }
    NSArray * keys = [[byField allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (NSString * key in keys) {
        [rv addObject:byField[key]];
    }
    return rv;
}

-(GCDerivedDataSerie*)derivedDataSerie:(gcDerivedType)type field:(gcFieldFlag)field period:(gcDerivedPeriod)period
                               forDate:(NSDate*)date andActivityType:(NSString*)activityType{

    GCDerivedDataSerie * serie = [GCDerivedDataSerie derivedDataSerie:type field:field period:period forDate:date andActivityType:activityType];
    NSString * key = serie.key;

    GCDerivedDataSerie * existing = (self.derivedSeries)[key];
    if (existing) {
        if (existing.serieWithUnit == nil) {
            [self loadSerieFromFile:existing];
        }
    }else{
        (self.derivedSeries)[key] = serie;
        existing = serie;
        [self loadSerieFromFile:serie];
    }
    return existing;
}

-(NSArray<NSNumber*>*)availableFieldsForType:(NSString*)aType{

    NSMutableDictionary * all =  [NSMutableDictionary dictionary];
    for (NSString * key in self.derivedSeries) {
        GCDerivedDataSerie * serie = self.derivedSeries[key];

        if ([serie.activityType isEqualToString:aType]) {
            all[@( serie.fieldFlag )] = @1;
        }
    }

    return all.allKeys;
}

-(void)loadSerieFromFile:(GCDerivedDataSerie*)serie{
    FMResultSet * res = [self.deriveddb executeQuery:@"SELECT filename FROM gc_derived_series_files WHERE serieId = ?", @([self serieId:serie])];
    if ([res next]) {
        NSString * fn = [res stringForColumn:@"filename"];
        [serie loadFromFile:[RZFileOrganizer writeableFilePath:fn]];
    }
}

-(void)recordModifiedSerie:(GCDerivedDataSerie*)serie withActivity:(GCActivity*)activity intoFile:(NSString*)fn{
    NSString * key = [serie key];
    if (!self.modifiedSeries) {
        self.modifiedSeries = [NSMutableDictionary dictionary];
    }
    NSMutableDictionary * acts = self.modifiedSeries[key];
    if (!acts) {
        self.modifiedSeries[key] = [NSMutableDictionary dictionaryWithObject:fn forKey:activity.activityId];
    }else{
        (self.modifiedSeries[key])[activity.activityId] = fn;
    }
}

#pragma mark - Processed Activities

-(void)loadProcesseActivities{
    FMDatabase * db = [self deriveddb];
    FMResultSet * res = [db executeQuery:@"SELECT * FROM gc_derived_activity_processed"];
    self.processedActivities = [NSMutableDictionary dictionary];
    while ([res next]) {
        self.processedActivities[ [res stringForColumn:@"activityId"] ] = @([res intForColumn:@"version"]);
    }
}

-(BOOL)recordProcessedActivity:(NSString*)aId{
    BOOL rv = true;
    if (!self.processedActivities) {
        [self loadProcesseActivities];
    }
    self.processedActivities[ aId] = @(kDerivedCurrentVersion);
    if(! [self.deriveddb executeUpdate:@"INSERT OR REPLACE INTO gc_derived_activity_processed (activityId,version) VALUES (?,?)", aId, @(kDerivedCurrentVersion)]){
        rv = false;
        RZLog(RZLogError, @"db error %@", [self.deriveddb lastErrorMessage]);
    };
    return rv;
}


-(BOOL)activityAlreadyProcessed:(GCActivity*)activity{

    if (!self.processedActivities) {
        [self loadProcesseActivities];
    }
    return [self.processedActivities[ activity.activityId ] integerValue] >= kDerivedCurrentVersion;
}

-(BOOL)activityRequireProcessing:(GCActivity*)activity{
    // check if already in database
    if (![activity.activityType isEqualToString:GC_TYPE_RUNNING] && ![activity.activityType isEqualToString:GC_TYPE_CYCLING]) {
        return false;
    }
    return (![activity ignoreForStats:gcIgnoreModeActivityFocus]) && [activity trackPointsRequireDownload] == false && ![self activityAlreadyProcessed:activity] ;
}

-(NSArray*)activitiesRequiringProcessingIn:(NSArray*)activities limit:(NSUInteger)limit{
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:limit < activities.count ? limit : activities.count];
    for (GCActivity * act in activities) {
        if ([self activityRequireProcessing:act]) {
            [rv addObject:act];
        }
        if (rv.count>=limit) {
            break;
        }
    }
    return rv;
}

#pragma mark - Processing

-(void)processQueueElement:(GCDerivedQueueElement*)element{
    RZPerformance * performance = [RZPerformance start];
    GCActivity * activity = element.activity;

    if (![activity trackdbIsObsolete:activity.trackdb]) {
        // no worker here, this function should already be on worker
        GCStatsDataSerieWithUnit * serie =  [activity calculatedDerivedTrack:gcCalculatedCachedTrackRollingBest
                                                                    forField:[GCField fieldForFlag:element.field andActivityType:activity.activityType]
                                                                      thread:nil];

        for (NSNumber * num in @[ @(gcDerivedPeriodAll),@(gcDerivedPeriodMonth),@(gcDerivedPeriodYear)]) {
            gcDerivedPeriod period = num.intValue;
            GCDerivedDataSerie * derivedserie = [self derivedDataSerie:element.derivedType
                                                                 field:element.field
                                                                period:period
                                                               forDate:activity.date
                                                       andActivityType:activity.activityType];
            gcStatsOperand operand = [derivedserie.serieWithUnit.unit betterIsMin] ? gcStatsOperandMin : gcStatsOperandMax;
            [derivedserie operate:operand with:serie from:activity];
            NSString * fn = [NSString stringWithFormat:@"%@-%@.data", [[GCAppGlobal profile] currentDerivedFilePrefix],  derivedserie.key];
            if([derivedserie saveToFile:fn]){
                [self recordModifiedSerie:derivedserie withActivity:activity intoFile:fn];
            }else{
                RZLog( RZLogError, @"Failed to write %@", fn);
            }
        }
    }

    if (element.activityLast && activity != [[GCAppGlobal organizer] currentActivity]) {
        [activity purgeCache];
    }
    if ([performance significant]) {
        RZLog(RZLogInfo, @"%@ heavy: %@ %@", activity, [GCFields fieldForFlag:element.field andActivityType:activity.activityType], performance);
    }
}



-(void)processActivities:(NSArray*)activities{
    if (self.queue) {
        return;
    }
    NSMutableArray * toProcess = [NSMutableArray arrayWithCapacity:activities.count];
    for (GCActivity * activity in activities) {
        if ([self activityRequireProcessing:(GCActivity*)activity]) {
            if ([activity.activityType isEqualToString:GC_TYPE_RUNNING]){
                [toProcess addObject:[GCDerivedQueueElement element:activity
                                                              field:gcFieldFlagWeightedMeanHeartRate
                                                            andType:gcDerivedTypeBestRolling
                                                       activityLast:NO]];
                [toProcess addObject:[GCDerivedQueueElement element:activity
                                                              field:gcFieldFlagWeightedMeanSpeed
                                                            andType:gcDerivedTypeBestRolling
                                                       activityLast:YES]];
            }else if ([activity.activityType isEqualToString:GC_TYPE_CYCLING]) {
                [toProcess addObject:[GCDerivedQueueElement element:activity
                                                              field:gcFieldFlagWeightedMeanHeartRate
                                                            andType:gcDerivedTypeBestRolling
                                                       activityLast:NO]];
                [toProcess addObject:[GCDerivedQueueElement element:activity
                                                              field:gcFieldFlagWeightedMeanSpeed andType:gcDerivedTypeBestRolling
                                                       activityLast:NO]];
                [toProcess addObject:[GCDerivedQueueElement element:activity
                                                              field:gcFieldFlagPower andType:gcDerivedTypeBestRolling
                                                       activityLast:YES]];
            }
        }
    }
    self.queue = toProcess;

    if (self.queue.count) {
        RZLog( RZLogInfo, @"queue start %d elements", (int)self.queue.count);
        self.performance= [RZPerformance start];
    }else{
        [self notifyForString:kNOTIFY_DERIVED_END];
        self.queue = nil;
    }
    dispatch_async(self.worker,^(){
        [self processNext];
    });

}

-(void)processNext{
    if (self.queue) {
        [self notifyForString:kNOTIFY_DERIVED_NEXT];

        GCDerivedQueueElement * element = (self.queue).lastObject;

        [self processQueueElement:element];
        [self.queue removeLastObject];
        if (self.queue.count == 0) {
            self.queue = nil;
            dispatch_async(self.worker,^(){
                [self processDone];
            });
        }else{
            if (self.performance.significant) {
                RZLog(RZLogInfo, @"queue next %d elements %@", (int)self.queue.count, self.performance);
                [self.performance reset];
            }
            dispatch_async(self.worker,^(){
                [self processNext];
            });
        }
    }
}

-(sqlite3_int64)serieId:(GCDerivedDataSerie*)serie{
    sqlite3_int64 rv = serie.serieId;
    if (rv == kInvalidSerieId) {
        rv = [serie saveToDb:self.deriveddb withData:NO];
    }
    return rv;
}

-(void)processDone{
    RZLog(RZLogInfo, @"queue end %@", self.performance);
    NSMutableDictionary * activities = [NSMutableDictionary dictionary];
    NSMutableDictionary * files = [NSMutableDictionary dictionary];

    for (NSString * key in self.modifiedSeries) {
        // Force all seriesId before below transaction
        GCDerivedDataSerie * serie = [self derivedDataSerieForKey:key];
        [self serieId:serie];
        NSDictionary * series = self.modifiedSeries[key];
        for (NSString * activityId in series) {
            NSString * fn = series[activityId];
            files[key] = fn;
            activities[activityId] = activityId;
        }
    }
    FMDatabase * db = [self deriveddb];
    BOOL haserror = false;
    [db beginTransaction];
    NSUInteger updateCount = 0;
    for (NSString * key in files) {
        GCDerivedDataSerie * serie = [self derivedDataSerieForKey:key];
        if (!serie) {
            RZLog(RZLogError, @"Inconsistent Workflow missing %@", key);
        }else{
            sqlite3_int64 serieId = [self serieId:serie];
            if (![db executeUpdate:@"INSERT OR REPLACE INTO gc_derived_series_files (serieId,filename) VALUES (?,?)", @(serieId),files[key]]){
                RZLog(RZLogError, @"db error %@", [db lastErrorMessage]);
                haserror = true;
            }
            updateCount++;
        }
    }
    if (updateCount > 0) {
        RZLog(RZLogInfo, @"Derived updated %lu series", (unsigned long)updateCount);
    }
    if (!haserror) {
        for (NSString * aId in activities) {
            if (![self recordProcessedActivity:aId]){
                haserror = true;
            }
        }
    }
    if (!haserror) {
        [db commit];
    }
    [self notifyForString:kNOTIFY_DERIVED_END];
}

#pragma mark - Database and notify

-(FMDatabase*)deriveddb{
    if (!self.db) {
        self.db = [FMDatabase databaseWithPath:[RZFileOrganizer writeableFilePath:[[GCAppGlobal profile] currentDerivedDatabasePath]]];
        [self.db open];
        [GCDerivedOrganizer ensureDbStructure:self.db];
    }
    return self.db;
}

-(void)processSome{
    if ([GCAppGlobal healthStatsVersion] || !kDerivedEnabled) {
        [self notifyForString:kNOTIFY_DERIVED_END];
        return;
    }

    /*
     NSDate * current = [[[GCAppGlobal organizer] currentActivity] date];
     NSArray * twoMonths = [[GCAppGlobal organizer] activitiesWithin:3600.*60.*24. of:current];
     [self processActivities:twoMonths];
     */
    NSArray * toProcess = [self activitiesRequiringProcessingIn:[[GCAppGlobal organizer] activities] limit:8];
    [self processActivities:toProcess];

}
-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
}

+(void)ensureDbStructure:(FMDatabase*)db{

    if (![db tableExists:@"gc_derived_version"]) {
        /*
        for (NSString * table in @[ @"gc_derived_series_files", @"gc_derived_activity_processed",@"gc_derived_series", @"gc_derived_series_data", @"gc_derived_series_unit"]) {
            RZEXECUTEUPDATE(db, [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", table]);
        }*/
        RZEXECUTEUPDATE(db, @"CREATE TABLE gc_derived_version (version INTEGER)");
        RZEXECUTEUPDATE(db, @"INSERT INTO gc_derived_version (version) VALUES (1)");
    }

    [GCDerivedDataSerie ensureDbStructure:db];
    if (![db tableExists:@"gc_derived_series_files"]) {
        DBCHECK([db executeUpdate:@"CREATE TABLE gc_derived_series_files (serieId INTEGER PRIMARY KEY, filename TEXT, modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP)"]);
    }
    if (![db tableExists:@"gc_derived_activity_processed"]) {
        DBCHECK([db executeUpdate:@"CREATE TABLE gc_derived_activity_processed (activityId TEXT UNIQUE, version INTEGER, modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP)"]);
    }
}


@end
