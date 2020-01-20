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

static NSInteger kDerivedCurrentVersion = 3;
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
@property (nonatomic,retain) NSMutableDictionary<NSDictionary*,GCStatsDataSerie*> * seriesByKeys;
@property (nonatomic,retain) NSMutableDictionary<NSDictionary*,GCStatsDataSerie*> * historicalSeriesByKeys;
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
    [_seriesByKeys release];
    [_historicalSeriesByKeys release];

    [super dealloc];
}

#pragma mark - Accessed Derived Series

-(void)loadFromDb{
    self.derivedSeries= [NSMutableDictionary dictionaryWithCapacity:10];

    if ( kDerivedEnabled) {
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
        [self loadProcesseActivities];
        
        if( /* DISABLES CODE */ (true) ){
            [self loadHistoricalFileSeries];
        }

        for (GCUnit * xUnit in @[ GCUnit.second, GCUnit.meter ]) {
            NSString * tableName = [self standardSerieDatabaseNameFor:xUnit];
            if( [db tableExists:tableName]){
                GCStatsDatabase * statsDb = [GCStatsDatabase database:db table:tableName];
                if( self.seriesByKeys == nil ){
                    self.seriesByKeys = [NSMutableDictionary dictionaryWithDictionary:[statsDb loadByKeys]];
                }else{
                    NSDictionary * next = [statsDb loadByKeys];
                    [self.seriesByKeys addEntriesFromDictionary:next];
                }
            }
        }
        
        if( self.seriesByKeys.count > 0){
            RZLog(RZLogInfo, @"Loaded %d derived series and %@ series by key", (int)self.derivedSeries.count, @(self.seriesByKeys.count));
        }else{
            RZLog(RZLogInfo, @"Loaded %d derived series", (int)self.derivedSeries.count);
        }
    }
}

-(void)loadHistoricalFileSeries{
    BOOL convert = ! [[self deriveddb] tableExists:@"gc_converted_historical_second"];
    
    GCStatsDatabase * statsDb = [GCStatsDatabase database:[self deriveddb] table:@"gc_converted_historical_second"];
    RZPerformance * perf = [RZPerformance start];
    if( convert ){
        for (NSString * key in self.derivedSeries) {
            GCDerivedDataSerie * serie = self.derivedSeries[key];
            if( serie.derivedPeriod == gcDerivedPeriodMonth){
                [serie loadFromFile:serie.filePath];
                GCStatsDataSerieWithUnit * base = serie.serieWithUnit;
                if( [base.xUnit canConvertTo:[GCUnit second]] ){
                    GCStatsDataSerieWithUnit * standardSerie = [GCActivity standardSerieSampleForXUnit:base.xUnit];
                    // Make sure we reduce from a copy so we don't destroy the main serie
                    base = [GCStatsDataSerieWithUnit dataSerieWithOther:base];
                    [GCStatsDataSerie reduceToCommonRange:standardSerie.serie and:base.serie];
                    NSDictionary * keys = @{
                        @"date":serie.bucketStart,
                        @"field":serie.field.key,
                        @"activityType":serie.activityType
                    };
                    [statsDb save:base.serie keys:keys];
                }
            }
        }
        RZLog(RZLogInfo, @"Converted all in %@", perf);
        [perf reset];
    }
    self.historicalSeriesByKeys = [NSMutableDictionary dictionaryWithDictionary:[statsDb loadByKeys]];
    RZLog(RZLogInfo, @"Loaded all db in %@", perf);
}

-(GCStatsSerieOfSerieWithUnits*)timeSeriesOfSeriesFor:(GCField*)field{
    GCStatsSerieOfSerieWithUnits * serieOfSerie = [GCStatsSerieOfSerieWithUnits serieOfSerieWithUnits:[GCUnit date]];
    for (NSDictionary * keys in self.historicalSeriesByKeys) {
        if( [keys[@"activityType"] isEqualToString:field.activityType] && [keys[@"field"] isEqualToString:field.key] ){
            NSNumber * dateNum = keys[@"date"];
            NSDate * date = [NSDate dateWithTimeIntervalSince1970:dateNum.doubleValue];
            
            GCStatsDataSerie * serie = self.historicalSeriesByKeys[keys];
            GCStatsDataSerieWithUnit * serieu=[GCStatsDataSerieWithUnit dataSerieWithUnit:[field unit] xUnit:[GCUnit second] andSerie:serie];
            [serieOfSerie addSerie:serieu forDate:date];
        }
    }
    return serieOfSerie;
}

-(GCStatsSerieOfSerieWithUnits*)timeserieOfSeriesFor:(GCField*)field inActivities:(NSArray<GCActivity*>*)activities{
    
    GCStatsSerieOfSerieWithUnits * serieOfSerie = [GCStatsSerieOfSerieWithUnits serieOfSerieWithUnits:[GCUnit date]];
    for (GCActivity * act in activities) {
        GCStatsDataSerie * serie = self.seriesByKeys[ @{ @"activityId": act.activityId, @"fieldKey":field.key}];
        if( serie ){
            GCStatsDataSerieWithUnit * serieu=[GCStatsDataSerieWithUnit dataSerieWithUnit:[act displayUnitForField:field] xUnit:[GCUnit second] andSerie:serie];
            [serieOfSerie addSerie:serieu forDate:act.date];
        }
    }
    return serieOfSerie;
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

-(BOOL)debugCheckSerie:(GCStatsDataSerie*)serie{
    for( NSUInteger i=0;i<MIN(serie.count,10);i++){
        double x = [serie dataPointAtIndex:i].x_data;
        if( lround(x) % 5 != 0  ){
            return true;
            break;
        }
    }
    return false;
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

-(void)clearDataForActivityType:(NSString*)aType andFieldFlag:(gcFieldFlag)flag{
    FMResultSet * res = [self.deriveddb executeQuery:@"SELECT * FROM gc_derived_series s, gc_derived_series_files f WHERE activityType = 'running' AND fieldFlag = 64 AND f.serieId = s.serieId"];
    NSMutableArray * fileToDelete = [NSMutableArray array];
    NSMutableArray * seriesToDelete = [NSMutableArray array];
    while( [res next]){
        [seriesToDelete addObject:@([res intForColumn:@"serieId"])];
        [fileToDelete addObject:[res stringForColumn:@"filename"]];
    }
    for (NSString * filename in fileToDelete) {
        [RZFileOrganizer removeEditableFile:filename];
    }
    for (NSNumber * serieId in seriesToDelete) {
        if(![self.deriveddb executeUpdate:@"DELETE FROM gc_derived_series WHERE serieId = ?", serieId]){
            RZLog(RZLogError, @"Failed to update %@", self.deriveddb.lastErrorMessage);
        }
        if(![self.deriveddb executeUpdate:@"DELETE FROM gc_derived_series_files WHERE serieId = ?", serieId]){
            RZLog(RZLogError, @"Failed to update %@", self.deriveddb.lastErrorMessage);
        }
    }
}

-(void)loadSerieFromFile:(GCDerivedDataSerie*)serie{
    FMResultSet * res = [self.deriveddb executeQuery:@"SELECT filename FROM gc_derived_series_files WHERE serieId = ?", @([self serieId:serie])];
    if ([res next]) {
        NSString * fn = [res stringForColumn:@"filename"];
        [serie loadFromFile:[RZFileOrganizer writeableFilePath:fn]];
        if([self debugCheckSerie:serie.serieWithUnit.serie]){
            RZLog(RZLogError, @"bad serie load");
        }
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

-(void)forceReprocessActivity:(NSString*)aId{
    if (!self.processedActivities) {
        [self loadProcesseActivities];
    }
    if( self.processedActivities[aId]){
        [self.processedActivities removeObjectForKey:aId];
        if(! [self.deriveddb executeUpdate:@"DELETE FROM gc_derived_activity_processed WHERE activityId = ?", aId]){
            RZLog(RZLogError, @"db error %@", [self.deriveddb lastErrorMessage]);
        };

    }

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
    return (![activity ignoreForStats:gcIgnoreModeActivityFocus]) &&
        [activity trackPointsRequireDownload] == false &&
        ![self activityAlreadyProcessed:activity] ;
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

-(NSString*)standardSerieDatabaseNameFor:(GCUnit*)unit{
    return [NSString stringWithFormat:@"gc_derived_standard_serie_%@", unit.key];
}

-(void)processQueueElement:(GCDerivedQueueElement*)element{
    RZPerformance * performance = [RZPerformance start];
    GCActivity * activity = element.activity;

    if (![activity trackdbIsObsolete:activity.trackdb]) {
        
        GCField * field = [GCField fieldForFlag:element.field
                                andActivityType:activity.activityType];
        
        // no worker here, this function should already be on worker
        GCStatsDataSerieWithUnit * serie =  [activity calculatedDerivedTrack:gcCalculatedCachedTrackRollingBest
                                                                    forField:field
                                                                      thread:nil];
        if( [self debugCheckSerie:serie.serie] ){
            RZLog(RZLogError,@"Bad input serie");
        }
        
        GCStatsDataSerieWithUnit * standard = [activity standardizedBestRollingTrack:field thread:nil];
        if( standard && standard.count > 0){
            GCStatsDatabase * statsDb = [GCStatsDatabase database:self.db table:[self standardSerieDatabaseNameFor:standard.xUnit]];
            NSDictionary * keys = @{
                @"activityId" : element.activity.activityId,
                @"fieldKey" : field.key,
            };
            
            // Before we save if applicable, convert to store unit
            NSArray * storeUnits = @[
                [GCUnit unitForKey:STOREUNIT_DISTANCE],
                [GCUnit unitForKey:STOREUNIT_SPEED],
                [GCUnit unitForKey:STOREUNIT_ELAPSED]
            ];
            for (GCUnit * unit in storeUnits) {
                if( [standard.xUnit canConvertTo:unit] ){
                    [standard convertToXUnit:unit];
                }
                if( [standard.unit canConvertTo:unit] ){
                    [standard convertToUnit:unit];
                }
            }
            
            RZLog(RZLogInfo, @"derived standard[%@]: %@ %@ %@", standard.xUnit.key, element.activity.activityId, field.key, standard );
            [statsDb save:standard.serie keys:keys];
            if( ! self.seriesByKeys){
                self.seriesByKeys = [NSMutableDictionary dictionary];
            }
            self.seriesByKeys[keys] = standard.serie;
        }
        for (NSNumber * num in @[ @(gcDerivedPeriodAll),@(gcDerivedPeriodMonth),@(gcDerivedPeriodYear)]) {
            gcDerivedPeriod period = num.intValue;
            GCDerivedDataSerie * derivedserie = [self derivedDataSerie:element.derivedType
                                                                 field:element.field
                                                                period:period
                                                               forDate:activity.date
                                                       andActivityType:activity.activityType];
            if([self debugCheckSerie:derivedserie.serieWithUnit.serie]){
                RZLog(RZLogError,@"bad derived start");
            }
            gcStatsOperand operand = [derivedserie.serieWithUnit.unit betterIsMin] ? gcStatsOperandMin : gcStatsOperandMax;
            [derivedserie operate:operand with:serie from:activity];
            if( [self debugCheckSerie:derivedserie.serieWithUnit.serie]){
                RZLog(RZLogError,@"bad out serie");
            }
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
                                                       activityLast:NO]];
                [toProcess addObject:[GCDerivedQueueElement element:activity
                                                              field:gcFieldFlagPower
                                                            andType:gcDerivedTypeBestRolling
                                                       activityLast:YES]];

            }else if ([activity.activityType isEqualToString:GC_TYPE_CYCLING]) {
                [toProcess addObject:[GCDerivedQueueElement element:activity
                                                              field:gcFieldFlagWeightedMeanHeartRate
                                                            andType:gcDerivedTypeBestRolling
                                                       activityLast:NO]];
                [toProcess addObject:[GCDerivedQueueElement element:activity
                                                              field:gcFieldFlagWeightedMeanSpeed
                                                            andType:gcDerivedTypeBestRolling
                                                       activityLast:NO]];
                [toProcess addObject:[GCDerivedQueueElement element:activity
                                                              field:gcFieldFlagPower
                                                            andType:gcDerivedTypeBestRolling
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
    
    if( self.worker ){
        dispatch_async(self.worker,^(){
            [self processNext];
        });
    }else{
        for (GCDerivedQueueElement * element in self.queue) {
            [self notifyForString:kNOTIFY_DERIVED_NEXT];
            [self processQueueElement:element];
        }
        [self notifyForString:kNOTIFY_DERIVED_END];
        self.queue = nil;
    }
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
    if (!kDerivedEnabled) {
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
