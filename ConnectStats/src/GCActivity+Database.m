//  MIT Licence
//
//  Created on 16/03/2014.
//
//  Copyright (c) 2014 Brice Rosenzweig.
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

#import "GCActivity+Database.h"
#import "GCAppGlobal.h"
#import "GCActivitySummaryValue.h"
#import "GCFieldsCalculated.h"
#import "GCActivitiesOrganizer.h"

@implementation GCActivity (Database)

+(GCActivity*)activityWithId:(NSString*)aId andDb:(FMDatabase*)db{
    GCActivity * rv = [[[GCActivity alloc] init] autorelease];
    if (rv) {
        rv.activityId = aId;
        [rv setDb:db];
        [rv setTrackdb:db];
        [rv loadFromDb:db];
        [rv loadSummaryDataFrom:db];
        rv.settings = [GCActivitySettings defaultsFor:rv];
    }
    return rv;
}

-(void)loadFromResultSet:(FMResultSet*)res{
    self.activityName = [res stringForColumn:@"activityName"];
    self.activityType = [res stringForColumn:@"activityType"];
    self.date = [res dateForColumn:@"BeginTimestamp"];

    for (GCField * summaryField in [self validStoredSummaryFields]) {
        NSString * fieldKey = summaryField.key;
        if( summaryField.fieldFlag == gcFieldFlagWeightedMeanSpeed){
            fieldKey = @"WeightedMeanSpeed"; // otherwise could be pace...
        }
        double value = [res doubleForColumn:fieldKey];
        GCNumberWithUnit * nu = [GCNumberWithUnit numberWithUnit:[self storeUnitForField:summaryField] andValue:value];
        [self setSummaryField:summaryField.fieldFlag with:nu];
    }
        
    self.speedDisplayUom = [res stringForColumn:@"speedDisplayUom"];
    self.distanceDisplayUom = [res stringForColumn:@"distanceDisplayUom"];
    self.garminSwimAlgorithm = [res boolForColumn:@"garminSwimAlgorithm"];

    self.location = [res stringForColumn:@"Location"];
    self.flags = [res intForColumn:@"Flags"];
    int tmp = [res intForColumn:@"trackFlags"];
    if (tmp==-1) {
        self.trackFlags = self.flags;
    }else{
        self.trackFlags = tmp;
    }
    self.downloadMethod = [res intForColumn:@"downloadMethod"];

    self.beginCoordinate = CLLocationCoordinate2DMake([res doubleForColumn:@"BeginLatitude"], [res doubleForColumn:@"BeginLongitude"]);
}

-(NSArray<NSString*>*)checkActivityInvalidFields{

    NSMutableArray * bad = [NSMutableArray arrayWithCapacity:5];

    if (self.activityId == nil) {
        [bad addObject:@"activityId"];
    }
    if (self.date == nil) {
        [bad addObject:@"date"];
    }
    if (self.activityName == nil) {
        [bad addObject:@"activityName"];
    }
    if (self.location == nil) {
        [bad addObject:@"location"];
    }
    if (self.speedDisplayUom == nil) {
        [bad addObject:@"speedDisplayUom"];
    }
    if (self.distanceDisplayUom == nil) {
        [bad addObject:@"distanceDisplayUom"];
    }

    return bad;
}

-(BOOL)isActivityValid{
    NSArray<NSString*> * bad = [self checkActivityInvalidFields];
    return bad.count == 0;
}
-(void)saveToDb:(FMDatabase*)db{
    if (![self isActivityValid]) {
        NSArray<NSString*> * bad = [self checkActivityInvalidFields];
        RZLog(RZLogError, @"Trying to save an invalid activity %@, missing %@", self, [bad componentsJoinedByString:@", "]);

        return;
    }
    [self setDb:db];
    [db beginTransaction];
    if( [db intForQuery:@"SELECT count(*) FROM gc_activities WHERE activityId = ?", self.activityId] > 0 ){
        [db executeUpdate:@"DELETE FROM gc_activities WHERE activityId = ?", self.activityId];
        [db executeUpdate:@"DELETE FROM gc_activities_values WHERE activityId = ?", self.activityId];
        [db executeUpdate:@"DELETE FROM gc_activities_meta WHERE activityId = ?", self.activityId];
        [db executeUpdate:@"DELETE FROM gc_activities_calculated WHERE activityId = ?", self.activityId];
    }
    
    NSArray * dbrow = @[self.activityId,
                        self.activityType,
                        self.date,
                        @([self summaryFieldValueInStoreUnit:gcFieldFlagSumDistance]),
                        @([self summaryFieldValueInStoreUnit:gcFieldFlagSumDuration]),
                        @([self summaryFieldValueInStoreUnit:gcFieldFlagWeightedMeanHeartRate]),
                        self.activityName,
                        @(self.beginCoordinate.longitude),
                        @(self.beginCoordinate.latitude),
                        @([self summaryFieldValueInStoreUnit:gcFieldFlagWeightedMeanSpeed]),
                        self.location,
                        @(self.flags),
                        self.speedDisplayUom,
                        self.distanceDisplayUom,
                        @(self.garminSwimAlgorithm),
                        @(self.downloadMethod),
                        @(self.trackFlags)
                        ];

    [db setShouldCacheStatements:YES];
    NSString * sql = @"INSERT INTO gc_activities (activityId,activityType,BeginTimestamp,SumDistance,SumDuration,WeightedMeanHeartRate,activityName, BeginLongitude,BeginLatitude,WeightedMeanSpeed,Location,Flags,SpeedDisplayUom,DistanceDisplayUom,garminSwimAlgorithm,downloadMethod,trackFlags) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    [db executeUpdate:sql withArgumentsInArray:dbrow];
    if ([db hadError]) {
        RZLog(RZLogError, @"db update %@", [db lastErrorMessage]);
    }

    for (GCField * field in self.summaryData) {
        GCActivitySummaryValue * data = self.summaryData[field];
        [data saveToDb:db forActivityId:self.activityId];
    }

    for (NSString * field in self.metaData) {
        GCActivityMetaValue * data = self.metaData[field];
        [data saveToDb:db forActivityId:self.activityId];
    }
    if(![db commit]){
        RZLog(RZLogError, @"db commit %@", [db lastErrorMessage]);
    }
    //[db setShouldCacheStatements:NO];
}


+(BOOL)activityExists:(NSString*)aId{
    return [[GCAppGlobal db] intForQuery:@"SELECT count(*) FROM gc_activities WHERE activityId = ?", aId] > 0;
}


-(void)loadFromDb:(FMDatabase*)db{

    FMResultSet * res = [db executeQuery:@"SELECT * FROM gc_activities WHERE activityId=?", self.activityId];
    if ([res next]) {
        [self loadFromResultSet:res];
    }
    [res close];
}

-(void)setSummaryDataFromKeyDict:(NSDictionary<NSString*,GCActivitySummaryValue*>*)v{
    NSMutableDictionary<GCField*,GCActivitySummaryValue*>*newSum = [NSMutableDictionary dictionaryWithCapacity:v.count];
    
    NSString * activityType = self.activityType;
    
    for (NSString * key in v) {
        newSum[ [GCField fieldForKey:key andActivityType:activityType]] = v[key];
    }
    self.summaryData = newSum;
}

-(void)loadSummaryDataFrom:(FMDatabase*)db{
    FMResultSet * res = [db executeQuery:@"SELECT * FROM gc_activities_values WHERE activityId = ?",self.activityId];
    NSMutableDictionary<NSString*,GCActivitySummaryValue*> * val =[NSMutableDictionary dictionaryWithCapacity:20];
    while ([res next]) {
        val[[res stringForColumn:@"field"]] = [GCActivitySummaryValue activitySummaryValueForResultSet:res];
    }

    [self setSummaryDataFromKeyDict:val];

    NSMutableDictionary<NSString*,GCActivityMetaValue*>* mval = [NSMutableDictionary dictionaryWithCapacity:5];
    res = [db executeQuery:@"SELECT * FROM gc_activities_meta WHERE activityId = ?", self.activityId];
    while ([res next]) {
        mval[[res stringForColumn:@"field"]] = [GCActivityMetaValue activityValueForResultSet:res];
    }
    [self updateMetaData:mval];

    [GCFieldsCalculated addCalculatedFields:self];

}

-(void)loadSummaryDataProcess{
    FMDatabase * db = self.db;

    [self loadSummaryDataFrom:db];

    _summaryDataLoading =false;

    [[GCAppGlobal organizer] notifyOnMainThread:self.activityId ];
}

-(void)loadSummaryData{

    if ( !self.summaryData && !_summaryDataLoading) {
        _summaryDataLoading = true;
        dispatch_async([GCAppGlobal worker],^(){
            [self loadSummaryDataProcess];
        });
    }
}

//select m.activityId,m.display,m2.display,m3.display FROM gc_activities_meta m, gc_activities_meta m2, gc_activities_meta m3 WHERE m.activityId = m2.activityId AND m.field = 'device' AND m2.field = 'activityType' AND m.activityId = m3.activityId AND m3.field='garminSwimAlgorithm';
+(void)ensureDbStructure:(FMDatabase*)db{
    if (/* DISABLES CODE */ (false)) {
        [db executeUpdate:@"DROP TABLE gc_activities"];
        [db executeUpdate:@"DROP TABLE gc_activities_values"];
        [db executeUpdate:@"DROP TABLE gc_activities_meta"];
        [db executeUpdate:@"DROP TABLE gc_activities_calculated"];
    }
    if (![db tableExists:@"gc_activities"]) {
        [db executeUpdate:@"CREATE TABLE gc_activities (activityId TEXT PRIMARY KEY, activityName TEXT, activityType TEXT,BeginTimestamp REAL,SumDistance REAL,SumDuration REAL,WeightedMeanHeartRate REAL,WeightedMeanSpeed REAL,SpeedDisplayUom TEXT,DistanceDisplayUom TEXT,BeginLatitude REAL,BeginLongitude REAL,Location TEXT,Flags REAL,trackFlags INT DEFAULT -1,garminSwimAlgorithm INT DEFAULT 0,downloadMethod INT DEFAULT 0)"];
    }
    if (![db tableExists:@"gc_activities_values"]) {
        [db executeUpdate:@"CREATE TABLE gc_activities_values (activityId TEXT, field TEXT, value REAL, uom TEXT )"];
    }
    if (![db tableExists:@"gc_activities_meta"]) {
        [db executeUpdate:@"CREATE TABLE gc_activities_meta (activityId TEXT, field TEXT, display TEXT, key TEXT)"];
    }
    if (![db tableExists:@"gc_activities_calculated"]) {
        [db executeUpdate:@"CREATE TABLE gc_activities_calculated (activityId TEXT, field TEXT, value REAL, uom TEXT)"];
    }
    if (![db tableExists:@"gc_version"]) {
        [db executeUpdate:@"CREATE TABLE gc_version (version INT)"];
        [db executeUpdate:@"INSERT INTO gc_version (version) VALUES(1)"];
        if (![db columnExists:@"garminSwimAlgorithm" inTableWithName:@"gc_activities"]) {
            [db executeUpdate:@"ALTER TABLE gc_activities ADD COLUMN garminSwimAlgorithm INT DEFAULT 0"];
            FMResultSet * res = [db executeQuery:@"SELECT * FROM gc_activities_meta WHERE field='garminSwimAlgorithm' and display=1"];
            NSMutableArray * ids = [NSMutableArray arrayWithCapacity:10];
            while ([res next]) {
                [ids addObject:[res stringForColumn:@"activityId"]];
            }
            [res close];
            for (NSString * aId in ids) {
                [db executeUpdate:@"UPDATE gc_activities SET garminSwimAlgorithm = 1 WHERE activityId = ?", aId];
            }
        }
    }
    int max_version = [db intForQuery:@"SELECT MAX(version) FROM gc_version"];
    if (max_version<2) {
        [db beginTransaction];
        if (![db columnExists:@"downloadMethod" inTableWithName:@"gc_activities"]) {
            [db executeUpdate:@"ALTER TABLE gc_activities ADD COLUMN downloadMethod INT DEFAULT 0"];
            [db executeUpdate:@"UPDATE gc_activities SET downloadMethod = 1 WHERE garminSwimAlgorithm = 1"];

            FMResultSet * res = [db executeQuery:@"SELECT * FROM gc_activities_meta WHERE field='device' and display='Garmin Fenix'"];
            NSMutableArray * ids = [NSMutableArray arrayWithCapacity:10];
            while ([res next]) {
                [ids addObject:[res stringForColumn:@"activityId"]];
            }
            [res close];
            for (NSString * aId in ids) {
                [db executeUpdate:@"UPDATE gc_activities SET downloadMethod = 2 WHERE activityId = ?", aId];
            }
        }
        [db executeUpdate:@"INSERT INTO gc_version (version) VALUES(2)"];
        [db commit];
        max_version = 2;
    }
    if (max_version < 3) {
        [db beginTransaction];
        if (![db columnExists:@"key" inTableWithName:@"gc_activities_meta"]) {
            [db executeUpdate:@"ALTER TABLE gc_activities_meta ADD COLUMN key"];
        }
        [db executeQuery:@"CREATE INDEX IF NOT EXISTS gc_idx_meta_activityId       ON gc_activities_meta       (activityId)"];
        [db executeQuery:@"CREATE INDEX IF NOT EXISTS gc_idx_values_activityId     ON gc_activities_values     (activityId,field)"];
        [db executeQuery:@"CREATE INDEX IF NOT EXISTS gc_idx_calculated_activityId ON gc_activities_calculated (activityId,field)"];
        [db executeUpdate:@"INSERT INTO gc_version (version) VALUES(3)"];
        [db commit];
        max_version = 3;
    }

    if (![db tableExists:@"gc_activities_weather"]) {
        [db beginTransaction];
        [db executeUpdate:@"CREATE TABLE gc_activities_weather (activityId TEXT, weatherField TEXT, weatherValue TEXT)"];
        [db executeUpdate:@"INSERT INTO gc_version (version) VALUES(4)"];
        [db commit];
        max_version = 4;
    }
    [GCWeather ensureDbStructure:db];

    if (![db tableExists:@"gc_activities_sync"]) {
        [db beginTransaction];
        [db executeUpdate:@"CREATE TABLE gc_activities_sync (activityId TEXT, service TEXT,date REAL)"];
        [db executeUpdate:@"INSERT INTO gc_version (version) VALUES(5)"];
        [db commit];
        max_version = 5;
    }
    if (max_version < 6) {
        [db beginTransaction];
        [db executeUpdate:@"CREATE INDEX ActivityValuesIndex ON gc_activities_values (activityId DESC)"];
        [db executeUpdate:@"INSERT INTO gc_version (version) VALUES(6)"];
        [db commit];
        max_version = 6;
    }
    if (max_version < 7) {
        [GCActivity fixDbMilesConversion:db];
        [db beginTransaction];
        [db executeUpdate:@"INSERT INTO gc_version (version) VALUES(7)"];
        [db commit];
        max_version = 7;
    }
    if (max_version < 8) {
        [db beginTransaction];
        [db executeUpdate:@"CREATE INDEX IF NOT EXISTS gc_idx_BeginTimeStamp ON gc_activities (BeginTimestamp DESC)"];
        [db executeUpdate:@"INSERT INTO gc_version (version) VALUES(8)"];
        [db commit];
        max_version = 8;
    }
    if (max_version < 9) {
        [db beginTransaction];
        RZEXECUTEUPDATE(db, @"CREATE TABLE gc_activities_data (activityId TEXT PRIMARY KEY, summaryData BLOB, metaData BLOB)");
        [db executeUpdate:@"INSERT INTO gc_version (version) VALUES(9)"];
        [db commit];
    }
    if(max_version < 10){
        [db beginTransaction];
        RZEXECUTEUPDATE(db, @"DROP TABLE IF EXISTS gc_health_zones");
        [db executeUpdate:@"INSERT INTO gc_version (version) VALUES(10)"];
        [db commit];
    }
    if(max_version < 11){
        [GCActivity upgradeDatababaseForRemappedTypes:db];
        RZEXECUTEUPDATE(db, @"INSERT INTO gc_version (version) VALUES(11)");
    }
}

+(void)upgradeDatababaseForRemappedTypes:(FMDatabase*)db{
    RZPerformance * perf = [RZPerformance start];
    
    FMResultSet * res = [db executeQuery:@"SELECT * FROM gc_activities_meta WHERE field='activityType'"];
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    NSMutableDictionary * types = [NSMutableDictionary dictionary];
    while( [res next] ){
        NSString * key = [res stringForColumn:@"key"];
        NSString * newType = [GCActivityTypes remappedLegacy:key];
        if( key != nil && newType != nil && ![key isEqualToString:newType] ){
            types[key] = newType;
            dict[ [res stringForColumn:@"activityId" ] ] = newType;
        }
    }
    [db beginTransaction];
    [db setShouldCacheStatements:YES];

    for (NSString * activityId in dict) {
        GCActivityType * newType = [GCActivityType activityTypeForKey:dict[activityId]];
        GCActivityType * parentType = newType.parentType;
        if( parentType.isRootType){
            parentType = newType;
        }
            
        RZEXECUTEUPDATE(db, @"UPDATE gc_activities SET activityType=? WHERE activityId=?", parentType.key, activityId);
        RZEXECUTEUPDATE(db, @"UPDATE gc_activities_meta SET key=? WHERE activityId=? AND field='activityType'", newType.key, activityId);
    }
    [db commit];
    
    RZLog(RZLogInfo, @"Updated %@ legacy types for %@ activities [%@]", @(types.count), @(dict.count), perf);
}


+(void)fixDbMilesConversion:(FMDatabase*)db{
    NSDate * start = [NSDate date];
    NSString * query = @"select * from gc_activities_values where (uom='mile' and field='SumDistance') or (uom='mph' and field='WeightedMeanSpeed')";
    NSMutableDictionary * save = [[NSMutableDictionary alloc] initWithCapacity:100];
    FMResultSet * res=[db executeQuery:query];
    while ([res next]) {
        NSString * aId = [res stringForColumn:@"activityId"];
        NSMutableDictionary * one = save[aId];
        if (!one) {
            one = [[NSMutableDictionary alloc] initWithCapacity:2];
            save[aId]=one;
            [one release];
        }
        GCNumberWithUnit * nu = [GCNumberWithUnit numberWithUnitName:[res stringForColumn:@"uom"] andValue:[res doubleForColumn:@"value"]];
        NSString * field = [res stringForColumn:@"field"];
        if ([field isEqualToString:@"SumDistance"]) {
            nu = [nu convertToUnitName:STOREUNIT_DISTANCE];
            one[field] = nu;
        }else if ([field isEqualToString:@"WeightedMeanSpeed"]) {
            nu = [nu convertToUnitName:STOREUNIT_SPEED];
            one[field] = nu;
        }
    }
    [db beginTransaction];
    [db setShouldCacheStatements:YES];
    NSUInteger updated = 0;
    for (NSString*aId in save) {
        GCNumberWithUnit * dist = save[aId][@"SumDistance"];
        if (dist) {
            updated++;
            [db executeUpdate:@"UPDATE gc_activities SET SumDistance=? WHERE activityId=?", [dist number], aId];
        }
        GCNumberWithUnit * speed = save[aId][@"WeightedMeanSpeed"];
        if (speed) {
            updated++;
            [db executeUpdate:@"UPDATE gc_activities SET WeightedMeanSpeed=? WHERE activityId=?", [speed number], aId];
        }
    }
    [db commit];
    //[db setShouldCacheStatements:NO];
    [save release];
    if (updated>10) {
        RZLog(RZLogInfo, @"Updated %d records in %.1fsecs", (int)updated, [[NSDate date] timeIntervalSinceDate:start]);
    }
}

-(void)fullSaveToDb:(FMDatabase*)db{
    [GCActivity ensureDbStructure:db];
    [self saveToDb:db];
    [self saveTrackpointsAndLapsToDb:db];
    [self.weather saveToDb:db forActivityId:self.activityId];
}
+(GCActivity*)fullLoadFromDbPath:(NSString*)dbname{
    FMDatabase * db = [FMDatabase databaseWithPath:dbname];
    [db open];
    return [GCActivity fullLoadFromDb:db];
}
+(GCActivity*)fullLoadFromDb:(FMDatabase*)db{
    GCActivity * rv = nil;
    if ([db intForQuery:@"SELECT COUNT(*) FROM gc_activities"] == 1) {
        FMResultSet * res = [db executeQuery:@"SELECT * FROM gc_activities LIMIT 1"];
        [res next];
        rv = [[[GCActivity alloc] initWithResultSet:res] autorelease];
        rv.db = db;
        rv.trackdb = db;
        [rv loadSummaryDataFrom:db];
        [rv trackpoints];//force load trackpoints
        GCActivityMetaValue * typeDetail = rv.metaData[@"activityType"];
        if( typeDetail && rv.activityTypeDetail == nil ){
            rv.activityTypeDetail = [GCActivityType activityTypeForKey:typeDetail.key];
        }
        
        if( rv.activityId ){
            FMResultSet * res = [db executeQuery:@"SELECT * FROM gc_activities_weather_detail WHERE activityId = ?", rv.activityId];
            if([res next]){
                rv.weather = [GCWeather weatherWithResultSet:res];
            }
        }
    }
    return rv;
}


@end
