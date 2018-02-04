//  MIT Licence
//
//  Created on 09/09/2012.
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

#import "GCActivity.h"
#import "GCAppGlobal.h"
#import "GCTrackPoint.h"
#import "GCFields.h"
#import "GCLap.h"
#import "GCTrackPointSwim.h"
#import "GCLapSwim.h"
#import "GCActivitySummaryValue.h"
#import "GCActivityMetaValue.h"
#import "GCActivityCalculatedValue.h"
#import "GCExportGoogleEarth.h"
#import "GCFieldsCalculated.h"
#import "GCWeather.h"
#import "GCLapCompound.h"
#import "GCActivity+Import.h"
#import "GCActivity+Database.h"
#import "GCWebConnect+Requests.h"
#import "GCService.h"
#import "GCActivity+CachedTracks.h"
#import "GCTrackPointExtraIndex.h"
#import "GCActivity+Fields.h"
#import "GCActivitiesOrganizer.h"
#import "GCDerivedOrganizer.h"

#define GC_PARENT_ID            @"__ParentId__"
#define GC_CHILD_IDS            @"__ChildIds__"
#define GC_EXTERNAL_ID          @"__ExternalId__"

NSString * kGCActivityNotifyDownloadDone = @"kGCActivityNotifyDownloadDone";
NSString * kGCActivityNotifyTrackpointReady = @"kGCActivityNotifyTrackpointReady";

@interface GCActivity ()

@property (nonatomic,retain) FMDatabase * useDb;
@property (nonatomic,retain) FMDatabase * useTrackDb;

@property (nonatomic,retain) NSArray * trackpointsCache;
@property (nonatomic,retain) NSArray * lapsCache;



@end

@implementation GCActivity

-(instancetype)init{
    return [super init];
}

-(GCActivity*)initWithId:(NSString *)aId{
    self = [super init];
    if (self) {
        self.activityId = aId;
    }
    return self;
}

-(GCActivity*)initWithResultSet:(FMResultSet*)res{
    self = [super init];
    if (self) {
        self.activityId = [res stringForColumn:@"activityId"];
        [self loadFromResultSet:res];
        self.settings = [GCActivitySettings defaultsFor:self];
    }
    return self;
}


-(void)dealloc{

    [[GCAppGlobal web] detach:self];
    [_useDb release];
    [_useTrackDb release];
    [_activityId release];
    [_summaryData release];
    [_trackpointsCache release];
    [_lapsCache release];
    [_metaData release];

    [_date release];

    [_activityType release];
    [_activityName release];

    [_location release];

    [_speedDisplayUom release];
    [_distanceDisplayUom release];

    [_activityTypeDetail release];
    [_calculatedFields release];
    [_calculatedLaps release];
    [_calculatedLapName release];

    [_weather release];

    [_cachedCalculatedTracks release];
    [_cachedExtraTracksIndexes release];

    [_settings release];

    [super dealloc];
}

-(NSString*)externalActivityId{
    return [self.service serviceIdFromActivityId:self.activityId];
}

-(GCService*)service{
    return [GCService serviceForActivityId:self.activityId];
}

-(NSString*)description{
    return [NSString stringWithFormat:@"<%@ %@:%@>", NSStringFromClass([self class]),_activityType,  _activityId];
}

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    if ([theInfo.stringInfo isEqualToString:NOTIFY_END] || [theInfo.stringInfo isEqualToString:NOTIFY_ERROR]) {
        _downloadRequested=false;
    }
}

-(void)addEntriesToMetaData:(NSDictionary<NSString*,GCActivityMetaValue*> *)dict{
    if (!self.metaData) {
        self.metaData = dict;
    }else{
        self.metaData = [self.metaData dictionaryByAddingEntriesFromDictionary:dict];
    }
}
-(void)addEntriesToCalculatedFields:(NSDictionary<NSString*,GCActivityCalculatedValue*> *)dict{
    if (!self.calculatedFields) {
        self.calculatedFields = dict;
    }else{
        self.calculatedFields = [self.calculatedFields dictionaryByAddingEntriesFromDictionary:dict];
    }
}

#pragma mark - Primary Field Access

/**
 Return summary value for field. Mostly for internal use
 @return summary value or nil
 */
/*
-(GCActivitySummaryValue*)summaryValueForField:(GCField*)field{
    [self loadSummaryData];
    GCActivitySummaryValue * val = summaryData[field.key];
    if (!val) {
        val = self.calculatedFields[field.key];
    }
    return val;
}
 */

/**
 This method should be the primary access method to get value for any field
 Note that the activityType in field will be ignored, if it does not match
 activityType of the activity but the field exist it will return the value
 @param GCField*field the field
 @return GCNumberWithUnit for the field or nil if not available.
 */
-(GCNumberWithUnit*)numberWithUnitForField:(GCField*)field{
    GCNumberWithUnit * rv = nil;
    gcFieldFlag flag = field.fieldFlag;
    switch (flag) {
        case gcFieldFlagSumDuration:
            rv = [GCNumberWithUnit numberWithUnitName:STOREUNIT_ELAPSED andValue:self.sumDuration];
            break;
        case gcFieldFlagSumDistance:
            rv = [[GCNumberWithUnit numberWithUnitName:STOREUNIT_DISTANCE andValue:self.sumDistance] convertToUnitName:self.distanceDisplayUom];
            break;
        case gcFieldFlagWeightedMeanSpeed:
            rv = [[GCNumberWithUnit numberWithUnitName:STOREUNIT_SPEED andValue:self.weightedMeanSpeed] convertToUnitName:self.speedDisplayUom];
            // Guard against inf speed or pace
            if( isinf(rv.value)){
                rv = nil;
            }
            break;
        case gcFieldFlagWeightedMeanHeartRate:
            rv = [GCNumberWithUnit numberWithUnitName:STOREUNIT_HEARTRATE andValue:self.weightedMeanHeartRate];
            break;

        default:
        {
            [self loadSummaryData];
            GCActivitySummaryValue * val = _summaryData[field.key];
            if (!val) {
                val = self.calculatedFields[field.key];
            }
            rv = val.numberWithUnit;
        }
    }
    return rv;
}

#pragma mark - Test on Fields

-(NSArray<GCField*>*)allFields{
    [self loadSummaryData];

    NSMutableArray<GCField*> * rv = [NSMutableArray array];
    for (NSString * key in _summaryData.allKeys) {
        [rv addObject:[GCField fieldForKey:key andActivityType:self.activityType]];
    }
    if (self.calculatedFields) {
        for (NSString * key in self.calculatedFields.allKeys) {
            [rv addObject:[GCField fieldForKey:key andActivityType:self.activityType]];
        }
    }
    return [NSArray arrayWithArray:rv];
}

-(NSArray<NSString*>*)allFieldsKeys{
    [self loadSummaryData];
    NSArray * rv = _summaryData.allKeys;
    if (self.calculatedFields) {
        rv = [rv arrayByAddingObjectsFromArray:self.calculatedFields.allKeys];
    }
    return rv;
}

-(NSString*)displayName{
    if ([_activityName isEqualToString:@"Untitled"] && ![_location isEqualToString:@""]){
        return _location;
    }
    return _activityName ?:@"";
}
-(GCActivityMetaValue*)metaValueForField:(NSString*)field{
    return _metaData[field];
}


#pragma mark - GCField Access methods


/**
 Test is a field is available
 */
-(BOOL)hasField:(GCField*)field{
    BOOL rv = false;
    switch (field.fieldFlag) {
        case gcFieldFlagSumDistance:
            rv = RZTestOption(self.flags, gcFieldFlagSumDistance);
            break;
        case gcFieldFlagWeightedMeanSpeed:
            rv = RZTestOption(self.flags, gcFieldFlagWeightedMeanSpeed);
            break;
        case gcFieldFlagWeightedMeanHeartRate:
            rv = RZTestOption(self.flags, gcFieldFlagWeightedMeanHeartRate);
            break;
        default:
        {
            [self loadSummaryData];
            rv = _summaryData[field.key] != nil || self.calculatedFields[field.key] != nil;
        }
    }
    return rv;
}


/**
 Return the display unit for field as stored for that specific activity
 */
-(GCUnit*)displayUnitForField:(GCField*)field{
    GCUnit * rv = nil;
    switch (field.fieldFlag) {
        case gcFieldFlagSumDistance:
            rv = [GCUnit unitForKey:_distanceDisplayUom];
            break;
        case gcFieldFlagWeightedMeanSpeed:
            rv = [GCUnit unitForKey:_speedDisplayUom];
            break;
        default:
        {
            rv = [self numberWithUnitForFieldKey:field.key].unit;
            if (!rv) {
                GCTrackPointExtraIndex * extra = self.cachedExtraTracksIndexes[field.key];
                if (extra) {
                    rv = extra.unit;
                }
            }
            if (!rv) {
                rv = [field unit];
            }
        }
    }
    return [rv unitForGlobalSystem];
}

-(GCUnit*)storeUnitForField:(GCField*)field{
    GCUnit * rv = nil;
    gcFieldFlag which = field.fieldFlag;

    switch (which) {
        case gcFieldFlagWeightedMeanSpeed:
            rv = [GCUnit unitForKey:STOREUNIT_SPEED];
            break;
        case gcFieldFlagAltitudeMeters:
            rv = [GCUnit unitForKey:STOREUNIT_ALTITUDE];
            break;
        case gcFieldFlagSumDistance:
            rv = [GCUnit unitForKey:STOREUNIT_DISTANCE];
            break;
        default:
        {
            rv = [self numberWithUnitForField:field].unit;
            if( ! rv ){
                rv = [field unit];
            }
        }
    }
    return  rv;
}

-(NSString*)formatValue:(double)val forField:(GCField*)field{
    GCUnit * unit = [self displayUnitForField:field];
    return [unit formatDouble:val];
}

-(NSString*)formatValueNoUnits:(double)val forField:(GCField*)field{
    GCUnit * unit = [self displayUnitForField:field];
    return [unit formatDoubleNoUnits:val];
}

-(NSString*)formattedValue:(GCField*)field{
    return [[self numberWithUnitForField:field] formatDouble] ?: @"";
}

-(NSString*)formatNumberWithUnit:(GCNumberWithUnit*)nu forField:(GCField*)which{
    GCUnit * unit = [self displayUnitForField:which];
    return [[nu convertToUnit:unit] formatDouble];
}


#pragma mark -

// tracks
// select strftime( '%c', Time/60/60/24+2440587.5 ) as Timestamp, distanceMeter,Speed from gc_track limit 10

//NEWTRACKFIELD
-(void)createTrackDb:(FMDatabase*)trackdb{
    [trackdb executeUpdate:@"DROP TABLE IF EXISTS gc_version_track"];
    [trackdb executeUpdate:@"DROP TABLE IF EXISTS gc_track"];
    [trackdb executeUpdate:@"DROP TABLE IF EXISTS gc_laps"];
    [trackdb executeUpdate:@"DROP TABLE IF EXISTS gc_laps_info"];
    [trackdb executeUpdate:@"DROP TABLE IF EXISTS gc_length"];
    [trackdb executeUpdate:@"DROP TABLE IF EXISTS gc_length_info"];
    [trackdb executeUpdate:@"DROP TABLE IF EXISTS gc_pool_lap"];
    [trackdb executeUpdate:@"DROP TABLE IF EXISTS gc_pool_lap_info"];

    [trackdb executeUpdate:@"DROP TABLE IF EXISTS gc_track_extra_idx"];
    [trackdb executeUpdate:@"DROP TABLE IF EXISTS gc_track_extra"];

    // Run/cycle gps activities

    [trackdb executeUpdate:@"CREATE TABLE gc_track (Time REAL,LatitudeDegrees REAL,LongitudeDegrees REAL,DistanceMeters REAL,HeartRateBpm REAL,Speed REAL,Cadence REAL,Altitude REAL,Power REAL,VerticalOscillation REAL,GroundContactTime REAL,lap INTEGER,elapsed REAL, trackflags INTEGER)"];
    [trackdb executeUpdate:@"CREATE TABLE gc_laps (lap INTEGER, Time REAL,LatitudeDegrees REAL,LongitudeDegrees REAL,DistanceMeters REAL,HeartRateBpm REAL,Speed REAL,Altitude REAL,Cadence REAL,Power REAL,VerticalOscillation REAL,GroundContactTime REAL,elapsed REAL, trackflags INTEGER)"];
    [trackdb executeUpdate:@"CREATE TABLE gc_laps_info (lap INTEGER,field TEXT,value REAL,uom TEXT)"];

    // Pools activity
    [trackdb executeUpdate:@"CREATE TABLE gc_pool_lap (lap INTEGER, Time REAL, SumDuration REAL,DirectSwimStroke INTEGER,Active INTEGER)"];
    [trackdb executeUpdate:@"CREATE TABLE gc_pool_lap_info (lap INTEGER,field TEXT,value REAL,uom TEXT)"];
    [trackdb executeUpdate:@"CREATE TABLE gc_length (Time REAL,SumDuration REAL,length INTEGER,lap INTEGER,DirectSwimStroke INTEGER)"];
    [trackdb executeUpdate:@"CREATE TABLE gc_length_info (lap INTEGER,length INTEGER,field TEXT,value REAL,uom TEXT)"];

    [trackdb executeUpdate:@"CREATE TABLE gc_track_extra_idx (field TEXT, idx INTEGER PRIMARY KEY, uom TEXT)"];

    [trackdb executeUpdate:@"CREATE TABLE gc_version_track (version INTEGER)"];
    // Version 1
    // Version 2: Add track_extra
    [trackdb executeUpdate:@"INSERT INTO gc_version_track (version) VALUES (2)"];
}

-(FMDatabase*)db{
    if (self.useDb != nil) {
        return self.useDb;
    }
    return [GCAppGlobal db];
}
-(void)setDb:(FMDatabase*)adb{
    self.useDb = adb;
}

-(FMDatabase*)trackdb{
    if (self.useTrackDb == nil) {
        self.useTrackDb = [FMDatabase databaseWithPath:[self trackDbFileName]];
        [self.useTrackDb open];
    }
    return self.useTrackDb;
}

-(void)setTrackdb:(FMDatabase*)db{
    self.useTrackDb = db;
}

-(NSString*)trackDbFileName{
    if (self.useTrackDb) {
        return self.useTrackDb.databasePath;
    }else{
        return [RZFileOrganizer writeableFilePath:[NSString stringWithFormat:@"track_%@.db", _activityId]];
    }
}

-(BOOL)hasTrackDb{
    return self.useTrackDb || [[NSFileManager defaultManager] fileExistsAtPath:[self trackDbFileName]];
}


-(void)saveTrackpointsSwim:(NSArray<GCTrackPointSwim*> *)aSwim andLaps:(NSArray<GCLapSwim*>*)laps{
    FMDatabase * db = self.db;
    FMDatabase * trackdb = self.trackdb;

    self.garminSwimAlgorithm = true;

    [self createTrackDb:trackdb];
    self.trackFlags = gcFieldFlagNone;

    [trackdb beginTransaction];
    [trackdb setShouldCacheStatements:YES];

    for (GCLapSwim * lap in laps) {
        [lap saveToDb:trackdb];
    }
    for (GCTrackPointSwim * point in aSwim) {
        self.trackFlags |= point.trackFlags;
        [point saveToDb:trackdb];
    }

    self.trackpointsCache = aSwim;
    self.lapsCache = laps;
    [self registerLaps:self.lapsCache forName:GC_LAPS_RECORDED];

    [trackdb commit];
    if (![db executeUpdate:@"UPDATE gc_activities SET trackFlags = ? WHERE activityId=?",@(_trackFlags), _activityId]){
        RZLog(RZLogError, @"db error %@", [db lastErrorMessage]);
    }
    if (![db executeUpdate:@"UPDATE gc_activities SET garminSwimAlgorithm = ? WHERE activityId=?",@(_garminSwimAlgorithm), _activityId]){
        RZLog(RZLogError, @"db error %@", [db lastErrorMessage]);
    }
}
-(void)loadTrackPointsSwim:(FMDatabase*)trackdb{
    NSMutableArray * trackpointsCache = [NSMutableArray arrayWithCapacity:100];
    FMResultSet * res = [trackdb executeQuery:@"SELECT * FROM gc_length ORDER BY length"];
    while ([res next]) {
        GCTrackPointSwim * point =[[[GCTrackPointSwim alloc] initWithResultSet:res] autorelease];
        point.trackFlags = _trackFlags;
        [trackpointsCache addObject:point];
    }
    self.trackpointsCache = trackpointsCache;

    [res close];
    self.lapsCache = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray * newLapsCache = [NSMutableArray array];

    res = [trackdb executeQuery:@"SELECT * FROM gc_pool_lap ORDER BY lap"];
    while ([res next]) {
        [newLapsCache addObject:[[[GCLapSwim alloc] initWithResultSet:res] autorelease]];
    }
    [res close];
    self.lapsCache = newLapsCache;
    [self registerLaps:newLapsCache forName:GC_LAPS_RECORDED];

    bool reported = false;
    res = [trackdb executeQuery:@"SELECT * FROM gc_pool_lap_info ORDER BY lap"];
    while ([res next]) {
        NSUInteger lapIdx = [res intForColumn:@"lap"];
        if( lapIdx < _lapsCache.count){
            GCTrackPointSwim * point = _lapsCache[lapIdx];
            [point updateValueFromResultSet:res];
        }else{
            if( !reported){
                RZLog(RZLogError, @"Inconsistent lap info with number of laps");
                reported = true;
            }
        }
    }
    reported = false;
    res = [trackdb executeQuery:@"SELECT * FROM gc_length_info ORDER BY length"];
    while ([res next]) {
        NSUInteger lengthIdx = [res intForColumn:@"length"];
        if( lengthIdx < trackpointsCache.count){
            GCTrackPointSwim * point = trackpointsCache[lengthIdx];
            [point updateValueFromResultSet:res];
        }else{
            if( !reported){
                RZLog(RZLogError, @"Inconsistent length info with number of laps");
                reported = true;
            }
        }
    }
    NSDate * time = nil;
    for (GCTrackPointSwim * point in self.trackpointsCache) {
        if (time==nil || point.directSwimStroke!=gcSwimStrokeOther) {
            time = point.time;
        }
        [point fixupDrillData:time];
        time = [time dateByAddingTimeInterval:point.elapsed];
    }
    [GCFieldsCalculated addCalculatedFieldsToTrackPoints:self.lapsCache forActivity:self];
}

-(void)loadTrackPointsExtraFromDb:(FMDatabase*)db{
    if ([db tableExists:@"gc_track_extra_idx"] && [db tableExists:@"gc_track_extra"]) {
        NSMutableDictionary * extra = [NSMutableDictionary dictionary];
        FMResultSet * res = [db executeQuery:@"SELECT * FROM gc_track_extra_idx" ];
        while( [res next]){
            NSString * field = [res stringForColumn:@"field"];
            size_t idx =  [res intForColumn:@"idx"];
            GCUnit * unit = [GCUnit unitForKey:[res stringForColumn:@"uom"]];
            extra[field] = [GCTrackPointExtraIndex extraIndex:idx key:field andUnit:unit];
        };
        self.cachedExtraTracksIndexes = extra;
        if (extra.count && self.trackpointsCache.count > 0) {
            NSUInteger i=0;
            GCTrackPoint * point = self.trackpointsCache[i];
            NSUInteger count = self.trackpointsCache.count;
            res = [db executeQuery:@"SELECT * FROM gc_track_extra"];

            while ([res next]) {
                NSDate * time = [res dateForColumn:@"Time"];
                while (point != nil && [point.time compare:time] == NSOrderedAscending) {
                    i++;
                    point = i<count ? self.trackpointsCache[i] : nil;
                };
                if ([point.time isEqualToDate:time]) {
                    for (GCTrackPointExtraIndex * e in extra.allValues) {
                        [point setExtraValue:[res doubleForColumn:e.key] forIndex:e];
                    }
                }
            }
        }
    }
}

-(void)saveTrackpointsExtraToDb:(FMDatabase*)db{
    if (self.cachedExtraTracksIndexes.count > 0) {
        NSArray * extra = [[self.cachedExtraTracksIndexes allValues] sortedArrayUsingComparator:^(GCTrackPointExtraIndex*i1,GCTrackPointExtraIndex*i2){
            NSComparisonResult rv = (i1.idx < i2.idx) ? NSOrderedAscending : (i1.idx == i2.idx ? NSOrderedSame : NSOrderedDescending);
            return rv;
        }];
        NSMutableArray * createFields = [NSMutableArray arrayWithObject:@"Time Real"];
        NSMutableArray * insertFields = [NSMutableArray arrayWithObject:@"Time"];
        NSMutableArray * insertValues = [NSMutableArray arrayWithObject:@":Time"];

        for (GCTrackPointExtraIndex * one in extra  ) {
            [createFields addObject:[NSString stringWithFormat:@"%@ Real", one.key]];
            [insertFields addObject:one.key];
            [insertValues addObject:[NSString stringWithFormat:@":%@", one.key]];
            [db executeUpdate:@"INSERT INTO gc_track_extra_idx (field,idx,uom) VALUES (?,?,?)", one.key, @(one.idx), one.unit.key];
        }

        [db executeUpdate:@"DROP TABLE IF EXISTS gc_track_extra"];
        NSString * createQuery = [NSString stringWithFormat:@"CREATE TABLE gc_track_extra (%@)", [createFields componentsJoinedByString:@","]];
        [db executeUpdate:createQuery];

        NSString * insertQuery = [NSString stringWithFormat:@"INSERT INTO gc_track_extra (%@) VALUES (%@)", [insertFields componentsJoinedByString:@","], [ insertValues componentsJoinedByString:@","]];

        NSMutableDictionary * data = [NSMutableDictionary dictionary];
        for (GCTrackPoint * one in self.trackpointsCache) {
            [data removeAllObjects];
            data[@"Time"] = one.time;
            if (one.fieldValues) {
                for (GCTrackPointExtraIndex * e in extra) {
                    data[e.key] = @(one.fieldValues[e.idx]);
                }
                [db executeUpdate:insertQuery withParameterDictionary:data];
            }
        }
    }
}

-(void)saveTrackpointsAndLapsToDb:(FMDatabase*)aDb{

    [self createTrackDb:aDb];


    [aDb beginTransaction];
    [aDb setShouldCacheStatements:YES];

    if (self.trackpointsCache) {
        for (GCTrackPoint * point in self.trackpointsCache) {
            [point saveToDb:aDb];
            _trackFlags |= point.trackFlags;
        }
        [self saveTrackpointsExtraToDb:aDb];
    }
    if (self.lapsCache) {
        for (GCLap * lap in self.lapsCache) {
            [lap saveToDb:aDb];
        }
    }
    if(![aDb commit]){
        RZLog(RZLogError, @"trackdb commit %@",[aDb lastErrorMessage]);
    }
    [self notifyForString:kGCActivityNotifyTrackpointReady];

}

-(BOOL)saveTrackpoints:(NSArray*)aTrack andLaps:(NSArray *)laps{
    BOOL rv = true;
    FMDatabase * db = self.db;
    FMDatabase * trackdb = self.trackdb;

    if ([trackdb tableExists:@"gc_track"] && [trackdb intForQuery:@"SELECT COUNT(*) FROM gc_track"] == aTrack.count) {
        rv = false;
    }

    NSMutableArray * trackData = [NSMutableArray arrayWithCapacity:aTrack.count];

    NSUInteger lapIdx = 0;
    NSUInteger nLaps = laps.count;

    NSMutableArray * newlapsCache = [NSMutableArray arrayWithCapacity:nLaps];

    for (id lone in laps) {
        GCLap * nlap = nil;//for release
        GCLap * alap = nil;
        if ([lone isKindOfClass:[GCLap class]] || [lone isKindOfClass:[GCLapSwim class]]) {
            alap = lone;
        }else if([lone isKindOfClass:[NSDictionary class]]){
            nlap = [[GCLap alloc] initWithDictionary:lone forActivity:self];
            alap = nlap;
        }
        alap.lapIndex = lapIdx++;
        if (alap) {
            [newlapsCache addObject:alap];
        }
        [nlap release];
    }
    self.lapsCache = newlapsCache;

    lapIdx = 0;
    GCLap * nextLap = lapIdx + 1 < nLaps ? _lapsCache[lapIdx+1] : nil;
    BOOL first = true;
    _trackFlags = gcFieldFlagNone;

    NSUInteger countBadLaps = 0;
    GCTrackPoint * lastTrack = nil;
    self.cachedExtraTracksIndexes = nil;
    for (id data in aTrack) {
        GCTrackPoint * npoint = nil;
        GCTrackPoint * point = nil;
        if ([data isKindOfClass:[GCTrackPoint class]]) {
            point = data;
            if (point.time==nil) {
                point.time = [self.date dateByAddingTimeInterval:point.elapsed];
                if (point.time==nil) {
                    countBadLaps++;
                    continue;
                }
            }
        }else if ([data isKindOfClass:[NSDictionary class]]){
            npoint = [[GCTrackPoint alloc] initWithDictionary:data forActivity:self];
            point = npoint;
        }
        if (lastTrack) {
            //[lastTrack updateWithNextPoint:point];
        }
        lastTrack = point;

        if (first && nLaps > 0) {
            GCLap * this = _lapsCache[0];
            this.longitudeDegrees = point.longitudeDegrees;
            this.latitudeDegrees = point.latitudeDegrees;
        }
        if (nextLap && [point.time compare:nextLap.time] == NSOrderedDescending) {
            nextLap.longitudeDegrees = point.longitudeDegrees;
            nextLap.latitudeDegrees = point.latitudeDegrees;

            lapIdx++;
            nextLap = lapIdx + 1 < nLaps ? _lapsCache[lapIdx+1] : nil;
        }
        point.lapIndex = lapIdx;
        if (point) {
            [trackData addObject:point];
            self.trackFlags |= point.trackFlags;
        }
        [npoint release];
    }

    self.trackpointsCache = trackData;
    [self registerLaps:self.lapsCache forName:GC_LAPS_RECORDED];

    [self saveTrackpointsAndLapsToDb:trackdb];

    if (![db executeUpdate:@"UPDATE gc_activities SET trackFlags = ? WHERE activityId=?",@(_trackFlags), _activityId]){
        RZLog(RZLogError, @"db update %@",[db lastErrorMessage]);
    }
    if ([trackdb tableExists:@"gc_activities"]) {
        if (![trackdb executeUpdate:@"UPDATE gc_activities SET trackFlags = ? WHERE activityId=?",@(_trackFlags), _activityId]){
            RZLog(RZLogError, @"db update %@",[db lastErrorMessage]);
        }
    }
    if (![self validCoordinate] && trackData.count>0) {
        self.beginCoordinate = [trackData[0] coordinate2D];
        if (![db executeUpdate:@"UPDATE gc_activities SET BeginLatitude = ?, BeginLongitude = ? WHERE activityId=?",
              @(self.beginCoordinate.latitude), @(self.beginCoordinate.longitude), _activityId]){
            RZLog(RZLogError, @"db update %@",[db lastErrorMessage]);
        }

    }

    [GCFieldsCalculated addCalculatedFieldsToTrackPoints:self.lapsCache forActivity:self];

    if ([[GCAppGlobal profile] configGetBool:CONFIG_ENABLE_DERIVED defaultValue:[GCAppGlobal connectStatsVersion]]) {
        dispatch_async([GCAppGlobal worker],^(){
            [[GCAppGlobal derived] processActivities:@[self]];
        });
    }
    [self notifyForString:kGCActivityNotifyTrackpointReady];

    return rv;
}

-(void)loadTrackPointsGPS:(FMDatabase*)trackdb{

    if (![trackdb columnExists:@"elapsed" inTableWithName:@"gc_track"]) {
        [trackdb executeUpdate:@"ALTER TABLE gc_track ADD COLUMN elapsed REAL DEFAULT 0."];
    }
    if (![trackdb columnExists:@"trackflags" inTableWithName:@"gc_track"]) {
        RZEXECUTEUPDATE(trackdb, [ NSString stringWithFormat:@"ALTER TABLE gc_track ADD COLUMN trackflags INTEGER DEFAULT %lu", (unsigned long)self.trackFlags]);
    }

    FMResultSet * res = [trackdb executeQuery:@"SELECT * FROM gc_track ORDER BY Time"];

    // Add to tmp array, in case there is a request from another thread, don't
    // want to have it muted while in use.
    self.trackpointsCache = [NSMutableArray array];
    self.lapsCache = [NSMutableArray array];

    NSMutableArray * tmptracks = [NSMutableArray array];

    gcFieldFlag loadedTrackFlags = gcFieldFlagNone;

    while ([res next]) {
        GCTrackPoint * point =[[[GCTrackPoint alloc] initWithResultSet:res] autorelease];
        loadedTrackFlags |= point.trackFlags;
        [tmptracks addObject:point];
    }
    if (loadedTrackFlags != self.trackFlags) {
        self.trackFlags = loadedTrackFlags;
    }
    [res close];

    self.trackpointsCache = tmptracks;

    [self loadTrackPointsExtraFromDb:trackdb];

    if(![trackdb columnExists:@"uom" inTableWithName:@"gc_laps_info"]) {
        [trackdb executeUpdate:@"ALTER TABLE gc_laps_info ADD COLUMN uom TEXT DEFAULT NULL"];
    }
    if (![trackdb columnExists:@"elapsed" inTableWithName:@"gc_laps"]) {
        [trackdb executeUpdate:@"ALTER TABLE gc_laps ADD COLUMN elapsed REAL DEFAULT 0."];
    }
    if (![trackdb columnExists:@"trackflags" inTableWithName:@"gc_laps"]) {
        RZEXECUTEUPDATE(trackdb, [ NSString stringWithFormat:@"ALTER TABLE gc_laps ADD COLUMN trackflags INTEGER DEFAULT %lu", (unsigned long)self.trackFlags]);
    }

    NSMutableArray * tmplaps = [NSMutableArray array];

    res = [trackdb executeQuery:@"SELECT * FROM gc_laps ORDER BY lap"];
    if (!res) {
        RZLog(RZLogError, @"track db %@", [trackdb lastErrorMessage]);
    }
    while ([res next]) {
        [tmplaps addObject:[[[GCLap alloc] initWithResultSet:res] autorelease]];
    }

    [res close];
    res = [trackdb executeQuery:@"SELECT * FROM gc_laps_info ORDER BY lap"];
    if (!res) {
        RZLog(RZLogError, @"track db %@", [trackdb lastErrorMessage]);
    }
    if (tmplaps.count> 0) {
        NSUInteger lap_idx = 0;
        GCLap * lap = tmplaps[lap_idx];
        while ([res next]) {
            NSUInteger this_idx = [res intForColumn:@"lap"];
            if (this_idx != lap_idx) {
                lap_idx = this_idx;
                lap = tmplaps[lap_idx];
            }
            [lap addExtraFromResultSet:res andActivityType:self.activityType];
        }
    }
    self.lapsCache = tmplaps;
    [self registerLaps:self.lapsCache forName:GC_LAPS_RECORDED];
}


-(void)clearTrackdb{
    [RZFileOrganizer removeEditableFile:[NSString stringWithFormat:@"track_%@.db",_activityId]];
    [self setTrackpointsCache:nil];
    [self setLapsCache:nil];
    [self setCalculatedLaps:nil];
    [self setCachedCalculatedTracks:nil];
    self.useTrackDb = nil;

    _downloadRequested = false;

}

-(void)loadTrackPointsFromDb:(FMDatabase*)trackdb{
    if ([trackdb tableExists:@"gc_version_track"]) {
        //int version = [trackdb intForQuery:@"SELECT version from gc_version_track"];
        if (_garminSwimAlgorithm) {
            [self loadTrackPointsSwim:trackdb];
        }else{
            [self loadTrackPointsGPS:trackdb];
        }
    }else if ([trackdb tableExists:@"gc_version"] ){
        // OLDER FILES
        int version = [trackdb intForQuery:@"SELECT version from gc_version"];
        if (_garminSwimAlgorithm && version >= 2) {
            [self loadTrackPointsSwim:trackdb];
        }else if(!_garminSwimAlgorithm && version >= 4){
            [self loadTrackPointsGPS:trackdb];
        }
    }

    [GCFieldsCalculated addCalculatedFieldsToTrackPoints:self.lapsCache forActivity:self];

}
-(void)forceReloadTrackPoints{
    [self clearTrackdb];
    self.weather = nil;
    switch (_downloadMethod) {
        case gcDownloadMethod13:
        case gcDownloadMethodModern:
            [[GCAppGlobal web] garminDownloadActivitySummary:_activityId];
            break;
        case gcDownloadMethodSportTracks:
            [[GCAppGlobal web] sportTracksDownloadActivityTrackPoints:self.activityId withUri:[self metaValueForField:@"uri"].display];
            break;
        default:
            break;
    }
}

-(BOOL)trackdbIsObsolete:(FMDatabase*)trackdb{
    BOOL rv = false;

    // Rename gc_version to gc_version_track so we can merge track /activity db
    if ([trackdb tableExists:@"gc_version"] && ![trackdb tableExists:@"gc_version_track"]) {
        int version = [trackdb intForQuery:@"SELECT MAX(version) from gc_version"];
        RZEXECUTEUPDATE(trackdb, @"CREATE TABLE gc_version_track (version INTEGER)");

        if (version >= 4) {
            RZEXECUTEUPDATE(trackdb, @"INSERT INTO gc_version_track (version) VALUES (1)");
        }else{
            rv = true;
        }

        RZEXECUTEUPDATE(trackdb, @"DROP TABLE gc_version");
    }

    if([trackdb intForQuery:@"SELECT MAX(version) from gc_version_track"] < 1){
        rv = true;
    }
    return rv;

}

-(BOOL)trackPointsRequireDownload{
    BOOL rv = true;
    if (self.trackpointsCache) {
        rv = false;
    }else{
        if (self.hasTrackDb) {
            rv = false;
        }else{
            switch (self.downloadMethod) {
                case gcDownloadMethodTennis:
                case gcDownloadMethodFitFile:
                case gcDownloadMethodHealthKit:
                case gcDownloadMethodWithings:
                    rv = false;
                    break;

                default:
                    break;
            }
        }
    }
    return  rv;
}

-(BOOL)loadTrackPoints{
    BOOL rv = false;
    if (self.hasTrackDb) {
        NSDate * timing_start = [NSDate date];
        unsigned mem_start =[RZMemory memoryInUse];
        FMDatabase * trackdb = self.trackdb;

        if (![self trackdbIsObsolete:trackdb]) {
            [self loadTrackPointsFromDb:trackdb];
            RZLog(RZLogInfo, @"%@ Loaded trackpoints count = %lu [%.1f sec %@]", self, (unsigned long)self.trackpointsCache.count,
                  [[NSDate date] timeIntervalSinceDate:timing_start], [RZMemory formatMemoryInUseChangeSince:mem_start]);
            [self notifyForString:kGCActivityNotifyTrackpointReady];
            rv = true;
        }
    }

    if (!rv) {
        // don't do it repeatedly
        if (!_downloadRequested) {
            _downloadRequested = true;
            [[GCAppGlobal web] attach:self];
            switch (_downloadMethod) {
                case gcDownloadMethodDetails:
                    [[GCAppGlobal web] garminDownloadActivityDetailTrackPoints:_activityId];
                    break;
                // Modern download summary and trackpoints
                case gcDownloadMethodSwim:
                case gcDownloadMethodModern:
                    [[GCAppGlobal web] garminDownloadActivitySummary:_activityId];
                case gcDownloadMethod13:
                    [[GCAppGlobal web] garminDownloadActivityTrackPoints13:self];
                    break;
                case gcDownloadMethodDefault:
                    [[GCAppGlobal web] garminDownloadActivityTrackPoints13:self];
                    break;
                case gcDownloadMethodStrava:
                    [[GCAppGlobal web] stravaDownloadActivityTrackPoints:self.activityId];
                    break;
                case gcDownloadMethodSportTracks:
                    [[GCAppGlobal web] sportTracksDownloadActivityTrackPoints:self.activityId withUri:[self metaValueForField:@"uri"].display];
                    break;
                case gcDownloadMethodHealthKit:
                {
                    if ([self.activityType isEqualToString:GC_TYPE_DAY]) {
                        [[GCAppGlobal web] healthStoreDayDetails:self.date];
                    }
                    break;
                }

                case gcDownloadMethodTennis:
                case gcDownloadMethodFitFile:
                case gcDownloadMethodWithings:

                    break;

            }
            // attempt to download weather at same time
            if (_downloadMethod == gcDownloadMethod13|| _downloadMethod == gcDownloadMethodModern) {
                if (![self hasWeather]) {
                    [[GCAppGlobal web] garminDownloadWeather:self];
                }
                // DISABLE STRAVA UPLOAD
                if ([[GCAppGlobal profile] configGetBool:CONFIG_SHARING_STRAVA_AUTO defaultValue:false]) {
                    [[GCAppGlobal profile] configSet:CONFIG_SHARING_STRAVA_AUTO boolVal:false];
                    [GCAppGlobal saveSettings];
                }
            }
        }
    }
    return rv;
}

-(void)uploadToStrava{
}

#pragma mark - Trackpoints

-(BOOL)hasTrackField:(gcFieldFlag)which{
    return (which & _trackFlags) == which;
}

-(void)addTrackPoint:(GCTrackPoint *)point{
    if (!self.trackpointsCache) {
        self.trackpointsCache = @[ point ];
    }else{
        self.trackpointsCache = [self.trackpointsCache arrayByAddingObject:point];
    }
}

-(GCField*)nextAvailableTrackField:(GCField*)which{
    GCField * rv = nil;
    NSArray * available = [self availableTrackFields];
    if (available.count > 0) {
        if (which == nil) {
            rv = available[0];
        }else{
            NSUInteger idx = 0;
            for (idx=0; idx<available.count; idx++) {
                GCField * field = available[idx];
                if ([field isEqualToField:which]) {
                    break;
                }
            }
            if (idx + 1 < available.count) {
                rv = available[idx+1];
            }else{
                rv = available[0];
            }
        }
    }
    return rv;
}

/**
 Return list of available fields with Track Points. Will include calculated tracks
 @return NSArray<GCField*>
 */
-(NSArray*)availableTrackFields{
    NSMutableDictionary * unique = [NSMutableDictionary dictionary];
    NSArray * track = [GCFields availableFieldsIn:_trackFlags forActivityType:self.activityType];
    for (GCField * one in track) {
        unique[one] = @1;
    }
    for (NSString * field in self.cachedExtraTracksIndexes) {
        GCField * one = [GCField field:field forActivityType:self.activityType];
        unique[one] = @1;
    }
    return [unique.allKeys sortedArrayUsingSelector:@selector(compare:)];
}

-(BOOL)trackpointsReadyOrLoad{
    if (_trackpointsCache) {
        return true;
    }

    return [self loadTrackPoints];
}
-(BOOL)trackpointsReadyNoLoad{
    return _trackpointsCache != nil;
}
-(NSArray*)trackpoints{
    if (!_trackpointsCache) {
        [self loadTrackPoints];
    }
    return _trackpointsCache;
}
-(void)setTrackpoints:(NSArray<GCTrackPoint *> *)trackpoints{
    self.trackpointsCache = trackpoints;
}
#pragma mark - Laps

-(NSArray*)laps{
    if (!_lapsCache) {
        [self loadTrackPoints];
    }
    return self.lapsCache;

}

-(void)registerLaps:(NSArray*)laps forName:(NSString*)name{
    if (self.calculatedLaps == nil) {
        self.calculatedLaps = [NSMutableDictionary dictionaryWithCapacity:2];
    }
    [self.calculatedLaps setValue:laps forKey:name];
}

-(void)focusOnLapIndex:(NSUInteger)lapIndex{
    // cheat for compound path that have multi point in the same lap
    NSUInteger nLaps = (self.lapsCache).count;
    if (lapIndex < nLaps) {
        if ([self.lapsCache[lapIndex] isKindOfClass:[GCLapCompound class]]) {
            GCLapCompound * lap = self.lapsCache[lapIndex];
            for (GCTrackPoint * point in self.trackpointsCache) {
                if ([lap pointInLap:point]) {
                    point.lapIndex = lapIndex;
                }
            }
        }
    }
}

-(void)remapLapIndex:(NSArray*)laps{
    NSUInteger lapIdx = 0;
    NSUInteger nLaps = laps.count;
    if (nLaps>0) {
        for (NSUInteger idx=0; idx<nLaps; idx++) {
            GCLap * lap = laps[idx];
            lap.lapIndex = idx;
        }
        if ([laps[0] isKindOfClass:[GCLapCompound class]]) {
            for (GCTrackPoint * point in self.trackpointsCache) {
                point.lapIndex = -1;
                for (NSUInteger idx = 0; idx<laps.count; idx++) {
                    GCLapCompound * lap = laps[idx];
                    if ([lap pointInLap:point]) {
                        point.lapIndex = idx;
                        break;
                    }
                }
            }
        }else{
            GCLap * nextLap = lapIdx + 1 < nLaps ? laps[lapIdx+1] : nil;
            for (GCTrackPoint * point in self.trackpointsCache) {
                if (nextLap && [point.time compare:nextLap.time] == NSOrderedDescending) {
                    lapIdx++;
                    nextLap = lapIdx + 1 < nLaps ? _lapsCache[lapIdx+1] : nil;
                }
                point.lapIndex = lapIdx;
            }
        }
    }
}

-(BOOL)useLaps:(NSString*)name{
    NSArray * laps = self.calculatedLaps[name];
    if (laps) {
        self.lapsCache = laps;
        [self remapLapIndex:laps];
        [GCFieldsCalculated addCalculatedFieldsToTrackPoints:self.lapsCache forActivity:self];
        self.calculatedLapName = name;
        return true;
    }
    return false;
}

-(NSUInteger)lapCount{
    if (!_lapsCache) {
        [self loadTrackPoints];
    }
    return _lapsCache.count;
}
-(GCLap*)lapNumber:(NSUInteger)idx{
    if (!_lapsCache) {
        [self loadTrackPoints];
    }
    return _lapsCache[idx];
}

-(GCTrackPointSwim*)swimLapNumber:(NSUInteger)idx{
    if (!_lapsCache) {
        [self loadTrackPoints];
    }
    return _lapsCache[idx];
}

-(GCStatsDataSerieWithUnit*)lapSerieForTrackField:(GCField*)field timeAxis:(BOOL)timeAxis{
    GCUnit * displayUnit = [self displayUnitForField:field];
    GCUnit * storeUnit   = [self storeUnitForField:field];

    GCStatsDataSerieWithUnit * serieWithUnit = [GCStatsDataSerieWithUnit dataSerieWithUnit:storeUnit];
    if (!timeAxis) {
        serieWithUnit.xUnit = [GCUnit unitForKey:STOREUNIT_DISTANCE];
    }
    NSDate * firstDate = nil;

    for (GCLap * lap in [self laps]) {
        if (timeAxis) {
            if (firstDate == nil) {
                firstDate = lap.time;
            }

            [serieWithUnit.serie addDataPointWithDate:lap.time since:firstDate andValue:[lap valueForField:field.fieldFlag]];
        }else{
            [serieWithUnit.serie addDataPointWithX:lap.distanceMeters andY:[lap valueForField:field.fieldFlag]];
        }
    }

    if (![displayUnit isEqualToUnit:storeUnit]) {
        [serieWithUnit convertToUnit:displayUnit];
    }
    [serieWithUnit convertToGlobalSystem];
    return serieWithUnit;
}

#pragma mark - Track Point Series


/**
 Check if activities has trackfield available. Note it may not be available
 immediately and require a load from the database or web
 */
-(BOOL)hasTrackForField:(GCField*)field{
    BOOL rv = false;
    if (field.fieldFlag != gcFieldFlagNone) {
        rv = RZTestOption(self.trackFlags, field.fieldFlag);
    }else{
        if ([self hasCalculatedDerivedTrack:gcCalculatedCachedTrackDataSerie forField:field]) {
            rv = true;
        }else{
            rv = (self.cachedExtraTracksIndexes[field.key] != nil);
        }
    }
    return rv;
}
-(GCStatsDataSerieWithUnit*)distanceSerieForField:(GCField*)field{
    if (field.fieldFlag != gcFieldFlagNone) {
        if (_garminSwimAlgorithm) {
            return [self timeSerieForTrackFieldSwim:field andLap:GC_ALL_LAPS];
        }else{
            return [self trackSerieForField:field timeAxis:false];
        }
    }
    return nil;
}


-(GCStatsDataSerieWithUnit*)timeSerieForField:(GCField*)field{
    GCStatsDataSerieWithUnit * rv = nil;

    if (field.fieldFlag != gcFieldFlagNone) {
        if (_garminSwimAlgorithm) {
            rv = [self timeSerieForTrackFieldSwim:field andLap:GC_ALL_LAPS];
        }else{
            rv = [self trackSerieForField:field timeAxis:true];
        }
    }else{
        if ([self hasCalculatedDerivedTrack:gcCalculatedCachedTrackDataSerie forField:field]) {
            rv = [self calculatedDerivedTrack:gcCalculatedCachedTrackDataSerie forField:field thread:nil];
        }else{
            rv = [self trackSerieForField:field timeAxis:true];
        }
    }
    return rv;
}

-(GCStatsDataSerie * )timeSerieForSwimStroke{
    if (_garminSwimAlgorithm) {
        GCTrackPointSwim * firstpoint = _trackpointsCache[0];
        NSDate * firstDate = firstpoint.time;
        NSDate * nextDate = [firstDate dateByAddingTimeInterval:firstpoint.elapsed];

        NSMutableArray * points = [NSMutableArray arrayWithCapacity:_trackpointsCache.count];
        for (GCTrackPointSwim * point in _trackpointsCache) {
            if ([point.time compare:nextDate] == NSOrderedDescending) {
                [points addObject:[GCStatsDataPoint dataPointWithDate:nextDate andValue:0.]];
            }
            [points addObject:[GCStatsDataPoint dataPointWithDate:point.time andValue:point.directSwimStroke]];
            nextDate = [point.time dateByAddingTimeInterval:point.elapsed];

        }
        return [GCStatsDataSerie dataSerieWithPoints:points];
    }else{
        return nil;
    }
}

-(GCStatsDataSerieWithUnit * )timeSerieForTrackFieldSwim:(GCField*)field andLap:(int)lapIdx{
    if (_trackpointsCache.count == 0) {
        return nil;
    }
    NSString * swimLapField = [GCFields swimLapFieldFromTrackField:field.fieldFlag];
    GCUnit * unit = nil;
    GCStatsDataSerie * rv = [[[GCStatsDataSerie alloc] init] autorelease];
    GCTrackPointSwim * firstpoint = _trackpointsCache[0];
    NSDate * firstDate = firstpoint.time;
    NSDate * nextDate = [firstDate dateByAddingTimeInterval:firstpoint.elapsed];
    if (swimLapField) {
        for (GCTrackPointSwim * point in _trackpointsCache) {
            if (lapIdx == GC_ALL_LAPS || lapIdx == point.lapIndex) {
                GCNumberWithUnit * nb = [point numberWithUnitForField:field inActivity:self];

                if (field.fieldFlag == gcFieldFlagWeightedMeanSpeed && nb.value != 0.) {
                    nb = [nb convertToUnitName:_speedDisplayUom];
                }
                if (!unit || ![unit isEqualToUnit:nb.unit]) {
                    //TODO should Convert?
                    unit = nb.unit;
                }
                if ([point.time compare:nextDate] == NSOrderedDescending) {
                    [rv addDataPointWithDate:nextDate since:firstDate andValue:0.];
                }
                if (nb && !isinf(nb.value)) {// Rest = speed at 0 -> Inf pace
                    [rv addDataPointWithDate:point.time since:firstDate andValue:nb.value];
                }else{
                    [rv addDataPointWithDate:point.time since:firstDate andValue:0.];
                }
                nextDate = [point.time dateByAddingTimeInterval:point.elapsed];
            }
        }
    }
    GCStatsDataSerieWithUnit * nu = [GCStatsDataSerieWithUnit dataSerieWithUnit:unit];
    nu.serie =rv;
    return nu;
}

-(GCStatsDataSerieWithUnit*)progressSerie:(BOOL)timeAxis{
    GCUnit * unit = timeAxis ? [GCUnit unitForKey:STOREUNIT_DISTANCE] : [GCUnit unitForKey:STOREUNIT_ELAPSED];
    GCUnit * xUnit= timeAxis ? [GCUnit unitForKey:STOREUNIT_ELAPSED] : [GCUnit unitForKey:STOREUNIT_DISTANCE];

    GCStatsDataSerieWithUnit * serieWithUnit = [GCStatsDataSerieWithUnit dataSerieWithUnit:unit];
    serieWithUnit.xUnit = xUnit;

    NSDate * firstDate = nil;

    GCTrackPoint * lastPoint = nil;

    for (GCTrackPoint * point in [self trackpoints]) {
        if (!lastPoint) {
            firstDate = point.time;
        }
        lastPoint = point;

        if (timeAxis) {
            [serieWithUnit.serie addDataPointWithX:[point.time timeIntervalSinceDate:firstDate] andY:point.distanceMeters];
        }else{
            [serieWithUnit.serie addDataPointWithX:point.distanceMeters andY:[point.time timeIntervalSinceDate:firstDate]];
        }
    }
    return serieWithUnit;

}

-(GCStatsDataSerieWithUnit*)cumulativeDifferenceSerieWith:(GCActivity*)other timeAxis:(BOOL)timeAxis{
    GCStatsDataSerieWithUnit * progress = [self progressSerie:timeAxis];
    GCStatsDataSerieWithUnit * otherProgress = [other progressSerie:timeAxis];

    return timeAxis ? [progress cumulativeDifferenceWith:otherProgress] : [otherProgress cumulativeDifferenceWith:progress];
}
-(GCStatsDataSerie*)highlightSerieForLap:(NSUInteger)lap timeAxis:(BOOL)timeAxis{
    GCStatsDataSerieWithUnit * serieWithUnit = [GCStatsDataSerieWithUnit dataSerieWithUnit:[GCUnit unitForKey:@"dimensionless"]];
    NSDate * lastDate = nil;
    NSDate * firstDate = nil;
    double lastDist = 0.;

    BOOL started = false;

    NSUInteger currLap = 0;

    for (GCTrackPoint * point in [self trackpoints]) {

        if (!started) {
            firstDate = point.time;
        }
        if (currLap != point.lapIndex || !started) {
            lastDist = point.distanceMeters;
            lastDate = point.time;
            currLap = point.lapIndex;
        }

        started = true;

        double y = 0.;
        if (point.lapIndex == lap) {
            // +1 so it's not equal to 0
            y = timeAxis ? [point.time timeIntervalSinceDate:lastDate]+1. : point.distanceMeters - lastDist;
        }

        if (timeAxis) {
            [serieWithUnit.serie addDataPointWithDate:point.time since:firstDate andValue:y];
        }else{
            [serieWithUnit.serie addDataPointWithX:point.distanceMeters andY:y];
        }
    }
    return serieWithUnit.serie;
}

-(NSArray*)trackSerieLapAdjustment:(GCField*)field{
    gcFieldFlag fieldFlag = field.fieldFlag;
    GCTrackPointExtraIndex * idx = nil;

    if (fieldFlag == gcFieldFlagNone) {
        //idx = self.cachedExtraTracksIndexes[field.key];
        // Need to check if GCLap works with extra indexes
        return nil;
    }

    NSMutableArray * rv = nil;

    NSUInteger lapCount = self.lapsCache.count;
    NSUInteger lapIdx = 0;
    double currentLapSum = 0.;
    double currentLapCount = 0.;

    BOOL error = false;

    if ([self.settings shouldAdjustToMatchLapAverageForField:field] && lapCount > 0) {
        rv = [NSMutableArray arrayWithCapacity:lapCount];
        // Init with zeros
        for (NSUInteger i=0;i<lapCount;i++) {
            [rv addObject:@( 0.0 )]; // 0 -> no adjustment (additive adjustment)
        }

        for (GCTrackPoint * point in self.trackpoints) {
            BOOL hasValue = false;
            double y_value = 0.;

            if (idx) {
                y_value = [point extraValueForIndex:idx];
                hasValue = true;
            }else if( [point hasField:fieldFlag]){
                y_value = [point valueForField:fieldFlag];
                hasValue = true;
            }

            if (hasValue) {
                if (point.lapIndex == lapIdx) {
                    currentLapCount += 1.;
                    currentLapSum   += y_value;
                }else{
                    GCLap * lap = self.laps[lapIdx];
                    rv[lapIdx] = @( [lap valueForField:fieldFlag] - (currentLapSum/currentLapCount) );

                    if (point.lapIndex == lapIdx + 1 && lapIdx + 1 < self.laps.count) {
                        lapIdx ++;
                        currentLapSum = 0.;
                        currentLapCount = 0.;
                    }else{
                        RZLog(RZLogError, @"Inconsistent laps.count=%lu, point.lapIndex=%lu, lapIdx=%lu",
                              (unsigned long) self.laps.count,
                              (unsigned long)point.lapIndex,
                              (unsigned long)lapIdx);
                        error = true;
                        break;
                    }
                }

            }
        }
    }
    if (error) {
        rv = nil;
    }
    return rv;

}

-(GCStatsDataSerieWithUnit*)trackSerieForField:(GCField*)field timeAxis:(BOOL)timeAxis{
    gcFieldFlag afield = field.fieldFlag;
    GCTrackPointExtraIndex * idx = nil;

    BOOL treatGapAsNoValue = self.settings.treatGapAsNoValueInSeries;
    NSTimeInterval gapTimeInterval = self.settings.gapTimeInterval;

    if (afield == gcFieldFlagNone) {
        idx = self.cachedExtraTracksIndexes[field.key];
    }
    GCUnit * displayUnit = [self displayUnitForField:field];
    GCUnit * storeUnit   = [self storeUnitForField:field];

    GCStatsDataSerieWithUnit * serieWithUnit = [GCStatsDataSerieWithUnit dataSerieWithUnit:storeUnit];
    if (timeAxis) {
        serieWithUnit.xUnit = [GCUnit unitForKey:STOREUNIT_ELAPSED];
    }else{
        serieWithUnit.xUnit = [GCUnit unitForKey:STOREUNIT_DISTANCE];
    }
    NSDate * firstDate = nil;
    BOOL useElapsed = ![self.activityType isEqualToString:GC_TYPE_DAY];
    if (!useElapsed&&timeAxis) {
        serieWithUnit.xUnit = [GCUnit unitForKey:@"timeofday"];
    }

    NSArray * lapAdjustments = nil;
    if (self.settings.adjustSeriesToMatchLapAverage) {
        lapAdjustments = [self trackSerieLapAdjustment:field];
    }

    GCTrackPoint * lastPoint = nil;
    for (GCTrackPoint * point in self.trackpoints) {
        BOOL hasValue = false;
        double y_value = 0.;

        if (idx) {
            y_value = [point extraValueForIndex:idx];
            hasValue = true;
        }else if( [point hasField:field.fieldFlag]){
            y_value = [point valueForField:field.fieldFlag];
            hasValue = true;
        }

        if (hasValue) {

            if (lapAdjustments && point.lapIndex < lapAdjustments.count) {
                double adjustment = [lapAdjustments[ point.lapIndex] doubleValue];
                y_value += adjustment;
            }

            if (timeAxis) {
                if (firstDate == nil) {
                    firstDate = point.time;
                }

                if (useElapsed) {
                    if(lastPoint){
                        NSTimeInterval elapsed = [point.time timeIntervalSinceDate:lastPoint.time];
                        if(treatGapAsNoValue &&  elapsed > gapTimeInterval){
                            [serieWithUnit.serie addDataPointNoValueWithX:[lastPoint.time timeIntervalSinceDate:firstDate]+10];
                        }
                    }
                    lastPoint = point;

                    [serieWithUnit.serie addDataPointWithDate:point.time since:firstDate andValue:y_value];
                }else{
                    [serieWithUnit.serie addDataPointWithDate:point.time andValue:y_value];
                }
            }else{
                [serieWithUnit.serie addDataPointWithX:point.distanceMeters andY:y_value];
            }
        }
    }

    [self applyStandardFilterTo:serieWithUnit ForField:field];

    if (![displayUnit isEqualToUnit:storeUnit]) {
        [serieWithUnit convertToUnit:displayUnit];
    }
    [serieWithUnit convertToGlobalSystem];
    return serieWithUnit;
}

-(GCStatsDataSerieWithUnit*)applyStandardFilterTo:(GCStatsDataSerieWithUnit*)serieWithUnit ForField:(GCField*)field{
    GCStatsDataSerieFilter * filter = self.settings.serieFilters[field];

    if (filter) {
        NSUInteger count_total = serieWithUnit.count;

        serieWithUnit.serie = [filter filteredSerieFrom:serieWithUnit.serie];

        NSUInteger count_serie = serieWithUnit.serie.count;
        NSUInteger count_filtered = count_total-count_serie;

        if ((double)count_filtered/count_total > 0.10) {
            RZLog(RZLogInfo, @"%@ filtered %d out of %d", field,
                  (int)count_filtered,(int)count_total);
        }

    }
    return serieWithUnit;
}

#pragma mark - weather


-(void)recordWeather:(GCWeather*)we{
    self.weather = we;
    [self.weather saveToDb:self.db forActivityId:self.activityId];

}

-(BOOL)hasWeather{
    return [self.weather valid];
}



#pragma mark -


-(BOOL)validCoordinate{
    bool rv = _beginCoordinate.latitude != 0 && _beginCoordinate.longitude != 0;
    if( !rv){
        if (self.trackpointsCache && self.trackpointsCache.count) {
            for (GCTrackPoint * p in self.trackpointsCache) {
                if( p.validCoordinate){
                    rv = true;
                    break;
                }
            }
        }
    }
    return rv;
}

-(void)saveLocation:(NSString*)aLoc{
    self.location = aLoc;
    [self.db executeUpdate:@"UPDATE gc_activities SET location=? WHERE activityId=?", _location, self.activityId];
}

-(void)purgeCache{
    [self setTrackpointsCache:nil];
    [self setLapsCache:nil];
    [self setCachedCalculatedTracks:nil];
    [self setUseTrackDb:nil];
}

#pragma mark - Parent/Child Ids

-(NSString*)externalServiceActivityId{
    GCActivityMetaValue * val = self.metaData[GC_EXTERNAL_ID];
    if (val) {
        return val.display;
    }
    return nil;
}

-(void)setExternalServiceActivityId:(NSString*)externalId{
    if (externalId) {
        GCActivityMetaValue * val = [GCActivityMetaValue activityMetaValueForDisplay:externalId andField:GC_EXTERNAL_ID];

        [self addEntriesToMetaData:@{ GC_EXTERNAL_ID : val }];

    }else{
        if (self.metaData[GC_EXTERNAL_ID]) {
            self.metaData = [self.metaData dictionaryByRemovingObjectsForKeys:@[ GC_EXTERNAL_ID] ];
        }
    }
}

-(NSString*)parentId{
    GCActivityMetaValue * val = self.metaData[GC_PARENT_ID];
    if (val) {
        return val.display;
    }
    return nil;
}
-(void)setParentId:(NSString*)parentId{
    if (parentId) {
        GCActivityMetaValue * val = [GCActivityMetaValue activityMetaValueForDisplay:parentId andField:GC_PARENT_ID];

        [self addEntriesToMetaData:@{ GC_PARENT_ID : val }];

    }else{
        if (self.metaData[GC_PARENT_ID]) {
            self.metaData = [self.metaData dictionaryByRemovingObjectsForKeys:@[ GC_PARENT_ID] ];
        }
    }
}

-(NSArray*)childIds{
    GCActivityMetaValue * val = self.metaData[GC_CHILD_IDS];
    if (val) {
        return [val.display componentsSeparatedByString:@","];
    }
    return nil;
}
-(void)setChildIds:(NSArray*)childIds{
    if (childIds && childIds.count>0) {
        GCActivityMetaValue * val = [GCActivityMetaValue activityMetaValueForDisplay:[childIds componentsJoinedByString:@","] andField:GC_CHILD_IDS];
        [self addEntriesToMetaData:@{ GC_CHILD_IDS: val }];

    }else{
        if (self.metaData[GC_CHILD_IDS]) {
            self.metaData = [self.metaData dictionaryByRemovingObjectsForKeys:@[ GC_CHILD_IDS] ];

        }
    }
}


-(BOOL)ignoreForStats:(gcIgnoreMode)mode{
    switch (mode) {
        case gcIgnoreModeActivityFocus:
            return [self.activityType isEqualToString:GC_TYPE_MULTISPORT] || [self.activityType isEqualToString:GC_TYPE_DAY];
        case gcIgnoreModeDayFocus:
            return ![self.activityType isEqualToString:GC_TYPE_DAY];
    }
    return false;
}

-(BOOL)isSkiActivity{
    return GCActivityTypeIsSki(self.activityType,self.activityTypeDetail);
}
@end
