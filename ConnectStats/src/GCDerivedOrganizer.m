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

static NSInteger kDerivedCurrentVersion = 3;
static BOOL kDerivedEnabled = true;

@interface GCDerivedQueueElement : NSObject
@property (nonatomic,retain) GCActivity * activity;
@property (nonatomic,assign) gcFieldFlag field;
@property (nonatomic,assign) gcDerivedType derivedType;
@property (nonatomic,assign) BOOL activityLast;
@property (nonatomic,assign) BOOL rebuild;

+(GCDerivedQueueElement*)element:(GCActivity*)act field:(gcFieldFlag)field andType:(gcDerivedType)type activityLast:(BOOL)al;
+(GCDerivedQueueElement*)rebuildElement:(GCActivity*)act type:(gcDerivedType)type;

@end

@implementation GCDerivedQueueElement
+(GCDerivedQueueElement*)rebuildElement:(GCActivity*)act type:(gcDerivedType)type{
    GCDerivedQueueElement * rv = [[[GCDerivedQueueElement alloc] init] autorelease];
    if (rv) {
        rv.activity = act;
        rv.field = gcFieldFlagNone;
        rv.derivedType = type;
        rv.activityLast = false;
        rv.rebuild = true;
    }
    return rv;

}

+(GCDerivedQueueElement*)element:(GCActivity*)act field:(gcFieldFlag)field andType:(gcDerivedType)type activityLast:(BOOL)al{
    GCDerivedQueueElement * rv = [[[GCDerivedQueueElement alloc] init] autorelease];
    if (rv) {
        rv.activity = act;
        rv.field = field;
        rv.derivedType = type;
        rv.activityLast = al;
        rv.rebuild = false;
    }
    return rv;
}

-(void)dealloc{
    [_activity release];
    [super dealloc];
}

-(NSString*)description{
    return [NSString stringWithFormat:@"<%@: %@%@ %@ %@>", NSStringFromClass([self class]), self.activity, self.activityLast ? @" last" : @"",  [GCField fieldForFlag:self.field andActivityType:self.activity.activityType], @(self.derivedType)];
}
@end

@interface GCDerivedOrganizer ()
@property (nonatomic,retain) FMDatabase * db;
@property (nonatomic,retain) dispatch_queue_t worker;
@property (nonatomic,retain) NSMutableArray * queue;
@property (nonatomic,assign) GCWebConnect * web;
@property (nonatomic,retain) RZPerformance * performance;

@property (nonatomic,retain) NSMutableDictionary * processedActivities;

// Old style storage by hard coded series
@property (nonatomic,retain) NSMutableDictionary<NSString*,GCDerivedDataSerie*> * derivedSeries;
@property (nonatomic,retain) NSMutableDictionary * modifiedSeries;

// New style storage by time series database
@property (nonatomic,retain) NSMutableDictionary<NSDictionary*,GCStatsDataSerie*> * seriesByKeys;
@property (nonatomic,retain) NSMutableDictionary<NSDictionary*,GCStatsDataSerie*> * historicalSeriesByKeys;

@property (nonatomic, retain) NSString * useDerivedFilePrefix;
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
            self.derivedSeries= [NSMutableDictionary dictionary];
        }else{
            dispatch_async(self.worker,^(){
                [self loadFromDb];
            });
        }
    }
    return self;
}

-(GCDerivedOrganizer*)initForTestModeWithDb:(FMDatabase*)aDb andFilePrefix:(NSString *)filePrefix{
    self = [self initWithDb:aDb andThread:nil];
    if( self ){
        self.useDerivedFilePrefix = filePrefix;
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
    [_useDerivedFilePrefix release];

    [super dealloc];
}

#pragma mark - Load Derived Series

-(NSString*)derivedFilePrefix{
    return self.useDerivedFilePrefix ? self.useDerivedFilePrefix : [[GCAppGlobal profile] currentDerivedFilePrefix];
}

-(void)loadFromDb{
    self.derivedSeries = [NSMutableDictionary dictionaryWithCapacity:10];

    if ( kDerivedEnabled) {
        FMDatabase * db = [self deriveddb];

        FMResultSet * res= [db executeQuery:@"SELECT * FROM gc_derived_series"];
        while ([res next]) {
            GCDerivedDataSerie * serie = [GCDerivedDataSerie derivedDataSerieFromResultSet:res];
            serie.fileNamePrefix = self.derivedFilePrefix;
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

#pragma mark - access Standardized Series

-(GCStatsSerieOfSerieWithUnits*)historicalTimeSeriesOfSeriesFor:(GCField*)field{
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

-(GCStatsDataSerie*)serieFor:(GCDerivedDataSerie*)derivedSerie{
    return nil;
}

#pragma mark - access Aggregated Series

-(GCDerivedDataSerie*)derivedDataSerie:(gcDerivedType)type
                                 field:(gcFieldFlag)field
                                period:(gcDerivedPeriod)period
                               forDate:(NSDate*)date
                       andActivityType:(NSString*)activityType{

    GCDerivedDataSerie * serie = [GCDerivedDataSerie derivedDataSerie:type
                                                                field:field
                                                               period:period
                                                              forDate:date
                                                      andActivityType:activityType];
    NSString * key = serie.key;

    GCDerivedDataSerie * existing = self.derivedSeries[key];
    if (!existing) {
        self.derivedSeries[key] = serie;
        existing = serie;
    }
    return existing;
}

-(GCDerivedDataSerie*)derivedDataSerieForKey:(NSString*)key{
    GCDerivedDataSerie * rv = self.derivedSeries[key];
    return rv;
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

-(void)recordModifiedSerie:(GCDerivedDataSerie*)serie withActivity:(GCActivity*)activity{
    NSString * key = serie.key;
    if (!self.modifiedSeries) {
        self.modifiedSeries = [NSMutableDictionary dictionary];
    }
    NSMutableDictionary * acts = self.modifiedSeries[key];
    if (!acts) {
        self.modifiedSeries[key] = [NSMutableDictionary dictionaryWithDictionary:@{ activity.activityId : @1 }];
    }else{
        self.modifiedSeries[key][activity.activityId] = @1;
    }
}

-(void)saveModifiedSeries{
    NSMutableDictionary * activities = [NSMutableDictionary dictionary];

    NSUInteger updateCount = 0;
    for (NSString * key in self.modifiedSeries) {
        GCDerivedDataSerie * serie = self.derivedSeries[key];
        if( [serie saveToFile] ){
            updateCount++;
            NSDictionary * activityIds = self.modifiedSeries[key];
            for (NSString * activityId in activityIds) {
                activities[activityId] = activityId;
            }
        }
    }
    if (updateCount > 0) {
        RZLog(RZLogInfo, @"Derived updated %lu series", (unsigned long)updateCount);
    }
    BOOL haserror = false;
    [self.deriveddb beginTransaction];
    for (NSString * aId in activities) {
        if (![self recordProcessedActivity:aId]){
            haserror = true;
        }
    }
    if( !haserror ){
        [self.deriveddb commit];
    }
}

#pragma mark - rebuild

-(void)clearDataForSerie:(GCDerivedDataSerie*)serie{
    [serie clearDataAndFile];
}

-(void)rebuildDependentDerivedDataSerie:(gcDerivedType)type
                   forActivity:(GCActivity*)act{
    gcDerivedPeriod period = gcDerivedPeriodMonth;

    NSArray<GCDerivedDataSerie*> * series =
    @[
        [self derivedDataSerie:type field:gcFieldFlagWeightedMeanSpeed period:period forDate:act.date andActivityType:act.activityType],
        [self derivedDataSerie:type field:gcFieldFlagPower period:period forDate:act.date andActivityType:act.activityType],
        [self derivedDataSerie:type field:gcFieldFlagWeightedMeanHeartRate period:period forDate:act.date andActivityType:act.activityType]
    ];

    // Redo Years with the months
    NSMutableArray * years = [NSMutableArray array];
    for (GCDerivedDataSerie * child in series) {
        for (GCDerivedDataSerie * serie in self.derivedSeries.allValues) {
            if( serie.derivedPeriod == gcDerivedPeriodYear && [serie dependsOnSerie:child] ){
                [years addObject:serie];
            }
        }
    }
    for (GCDerivedDataSerie * serie in years) {
        gcStatsOperand operand = serie.serieWithUnit.unit.betterIsMin ? gcStatsOperandMin : gcStatsOperandMax;
        [serie reset];
        for (GCDerivedDataSerie * one in self.derivedSeries.allValues) {
            if( one.derivedPeriod == gcDerivedPeriodMonth && [serie dependsOnSerie:one] ){
                RZLog( RZLogInfo, @"rebuild %@ using(%@) %@", serie.key, operand == gcStatsOperandMin ? @"min" : @"max", one.key);
                [serie operate:operand with:one.serieWithUnit from:act];
            }
        }
    }
    // Then Redo All with the years
    NSMutableArray * all = [NSMutableArray array];
    for (GCDerivedDataSerie * child in series) {
        for (GCDerivedDataSerie * serie in self.derivedSeries.allValues) {
            if( serie.derivedPeriod == gcDerivedPeriodAll && [serie dependsOnSerie:child] ){
                [all addObject:serie];
            }
        }
    }
    for (GCDerivedDataSerie * serie in all) {
        gcStatsOperand operand = serie.serieWithUnit.unit.betterIsMin ? gcStatsOperandMin : gcStatsOperandMax;
        [serie reset];
        for (GCDerivedDataSerie * one in self.derivedSeries.allValues) {
            if( one.derivedPeriod == gcDerivedPeriodYear && [serie dependsOnSerie:one] ){
                RZLog( RZLogInfo, @"rebuild %@ using(%@) %@", serie.key, operand == gcStatsOperandMin ? @"min" : @"max", one.key);
                [serie operate:operand with:one.serieWithUnit from:act];
            }
        }
    }
}

-(void)rebuildDerivedDataSerie:(gcDerivedType)type
                   forActivity:(GCActivity*)act
                  inActivities:(NSArray<GCActivity*>*)activities{
    
    // rebuild month, then we'll rebuild the other
    
    gcDerivedPeriod period = gcDerivedPeriodMonth;
    NSArray<GCDerivedDataSerie*> * series =
    @[
        [self derivedDataSerie:type field:gcFieldFlagWeightedMeanSpeed period:period forDate:act.date andActivityType:act.activityType],
        [self derivedDataSerie:type field:gcFieldFlagPower period:period forDate:act.date andActivityType:act.activityType],
        [self derivedDataSerie:type field:gcFieldFlagWeightedMeanHeartRate period:period forDate:act.date andActivityType:act.activityType]
    ];

    NSMutableArray * toProcess = [NSMutableArray array];
    for (GCActivity * act in activities) {
        for (GCDerivedDataSerie * serie in series) {
            if( [serie containsActivity:act] ){
                [toProcess addObject:act];
                break;
            }
        }
    }
    
    for (GCActivity * activity in toProcess) {
        [self forceReprocessActivity:activity.activityId];
    }
    for (GCDerivedDataSerie * serie in series) {
        RZLog(RZLogInfo,@"rebuild %@ using %@/%@ activities (for %@)", serie.key,  @(toProcess.count), @(activities.count), act);
        [self clearDataForSerie:serie];
    }
    [self processActivities:toProcess rebuild:act];
    
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

-(NSArray<GCDerivedDataSerie*>*)bestMatchinSerieIn:(GCDerivedDataSerie*)serie maxCount:(NSUInteger)maxcount{
    // don't go further that current serie
    NSUInteger count = MIN(maxcount, serie.serieWithUnit.count);
    
    NSMutableArray<GCDerivedDataSerie*>* rv = [NSMutableArray arrayWithCapacity:count];
    BOOL betterIsMin = serie.serieWithUnit.unit.betterIsMin;
    
    for (GCDerivedDataSerie * one in self.derivedSeries.allValues) {
        if( one.derivedPeriod == gcDerivedPeriodMonth && [serie dependsOnSerie:one] ){
            if( rv.count == 0){
                // first round, just put activity everywhere
                for( NSUInteger idx = 0; idx < count; idx++){
                    // fill all with first, even is size of one is too small, we'll be careful later
                    [rv addObject:one];
                }
            }else{
                GCStatsDataSerieWithUnit * oneBest = one.serieWithUnit;

                for (NSUInteger idx = 0; idx < MIN(count,oneBest.count); idx ++ ) {
                    GCDerivedDataSerie * currentBestSerie = rv[idx];
                    GCStatsDataSerieWithUnit * currentBest = currentBestSerie.serieWithUnit;
                    
                    if( idx < currentBest.count ){
                        double y_best = [currentBest dataPointAtIndex:idx].y_data;
                        double check_y_best = [oneBest dataPointAtIndex:idx].y_data;
                        if( betterIsMin ){
                            if( check_y_best < y_best ){
                                rv[idx] = one;
                            }
                        }else{
                            if( check_y_best > y_best ){
                                rv[idx] = one;
                            }
                        }
                    }else{
                        // current is going further that last best ,fill with this one.
                        rv[idx] = one;
                    }
                }
            }
        }
    }
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


-(void)processStandardizedSerieForActivity:(GCActivity*)activity andField:(GCField*)field{
    GCStatsDataSerieWithUnit * standard = [activity standardizedBestRollingTrack:field thread:nil];
    if( standard && standard.count > 0){
        GCStatsDatabase * statsDb = [GCStatsDatabase database:self.db table:[self standardSerieDatabaseNameFor:standard.xUnit]];
        NSDictionary * keys = @{
            @"activityId" : activity.activityId,
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
        
        RZLog(RZLogInfo, @"derived standard[%@]: %@ %@ %@", standard.xUnit.key, activity.activityId, field.key, standard );
        [statsDb save:standard.serie keys:keys];
        if( ! self.seriesByKeys){
            self.seriesByKeys = [NSMutableDictionary dictionary];
        }
        self.seriesByKeys[keys] = standard.serie;
    }
}

-(void)processAggregatedSerieForActivity:(GCActivity*)activity derivedType:(gcDerivedType)derivedType andField:(GCField*)field{
    // no worker here, this function should already be on worker
    GCStatsDataSerieWithUnit * serie =  [activity calculatedSerieForField:field.correspondingBestRollingField thread:nil];
    
    if( [self debugCheckSerie:serie.serie] ){
        RZLog(RZLogError,@"Bad input serie");
    }

    for (NSNumber * num in @[ @(gcDerivedPeriodAll),@(gcDerivedPeriodMonth),@(gcDerivedPeriodYear)]) {
        gcDerivedPeriod period = num.intValue;
        GCDerivedDataSerie * derivedserie = [self derivedDataSerie:derivedType
                                                             field:field.fieldFlag
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
        [self recordModifiedSerie:derivedserie withActivity:activity];
    }
}

-(void)processQueueElement:(GCDerivedQueueElement*)element{
    RZPerformance * performance = [RZPerformance start];
    GCActivity * activity = element.activity;
    
    if( element.rebuild ){
        [self rebuildDependentDerivedDataSerie:element.derivedType forActivity:activity];
        if ([performance significant]) {
            RZLog(RZLogInfo, @"rebuild %@ heavy: %@", activity, performance);
        }

    }else{
        GCField * field = [GCField fieldForFlag:element.field
                                andActivityType:activity.activityType];
        
        if (![activity trackdbIsObsolete:activity.trackdb]) {
            [self processAggregatedSerieForActivity:activity derivedType:element.derivedType andField:field];
            [self processStandardizedSerieForActivity:activity andField:field];
        }
        
        if (element.activityLast && activity != [[GCAppGlobal organizer] currentActivity]) {
            [activity purgeCache];
        }
        if ([performance significant]) {
            RZLog(RZLogInfo, @"%@ heavy: %@ %@", activity, field, performance);
        }
    }
}


-(void)processActivities:(NSArray<GCActivity*>*)activities{
    [self processActivities:activities rebuild:nil];
}

-(void)processActivities:(NSArray<GCActivity*>*)activities rebuild:(GCActivity*)rebuildAct{
    if (self.queue) {
        return;
    }
    NSMutableArray * toProcess = [NSMutableArray arrayWithCapacity:activities.count];
    
    if( rebuildAct != nil){
        // Add at the beginning as queue process from last to first
        [toProcess addObject:[GCDerivedQueueElement rebuildElement:rebuildAct type:gcDerivedTypeBestRolling]];
    }
    
    for (GCActivity * activity in activities) {
        if ([self activityRequireProcessing:activity]) {
            if ([activity.activityType isEqualToString:GC_TYPE_RUNNING]){
                // Flag Last on the "First" activity because queue is processed from end of the array
                [toProcess addObject:[GCDerivedQueueElement element:activity
                                                              field:gcFieldFlagWeightedMeanHeartRate
                                                            andType:gcDerivedTypeBestRolling
                                                       activityLast:YES]];
                [toProcess addObject:[GCDerivedQueueElement element:activity
                                                              field:gcFieldFlagWeightedMeanSpeed
                                                            andType:gcDerivedTypeBestRolling
                                                       activityLast:NO]];
                [toProcess addObject:[GCDerivedQueueElement element:activity
                                                              field:gcFieldFlagPower
                                                            andType:gcDerivedTypeBestRolling
                                                       activityLast:NO]];

            }else if ([activity.activityType isEqualToString:GC_TYPE_CYCLING]) {
                [toProcess addObject:[GCDerivedQueueElement element:activity
                                                              field:gcFieldFlagWeightedMeanHeartRate
                                                            andType:gcDerivedTypeBestRolling
                                                       activityLast:YES]];
                [toProcess addObject:[GCDerivedQueueElement element:activity
                                                              field:gcFieldFlagWeightedMeanSpeed
                                                            andType:gcDerivedTypeBestRolling
                                                       activityLast:NO]];
                [toProcess addObject:[GCDerivedQueueElement element:activity
                                                              field:gcFieldFlagPower
                                                            andType:gcDerivedTypeBestRolling
                                                       activityLast:NO]];
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
        // Process from last to first, same order as process Next
        while( self.queue.count > 0){
            GCDerivedQueueElement * element = self.queue.lastObject;
            [self notifyForString:kNOTIFY_DERIVED_NEXT];
            [self processQueueElement:element];
            [self.queue removeLastObject];
        }
        [self notifyForString:kNOTIFY_DERIVED_END];
        self.queue = nil;
    }
}

-(void)processNext{
    if (self.queue) {
        [self notifyForString:kNOTIFY_DERIVED_NEXT];

        // Process from last to first element in the array
        // so "last" flag for an activity should be tagged accordingly
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

-(void)processDone{
    RZLog(RZLogInfo, @"queue end %@", self.performance);
    [self saveModifiedSeries];
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
        RZEXECUTEUPDATE(db, @"CREATE TABLE gc_derived_series_files (serieId INTEGER PRIMARY KEY, filename TEXT, modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");
    }
    if (![db tableExists:@"gc_derived_activity_processed"]) {
        RZEXECUTEUPDATE(db, @"CREATE TABLE gc_derived_activity_processed (activityId TEXT UNIQUE, version INTEGER, modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");
    }
}
//
-(void)updateForNewProfile{
    
}

@end
