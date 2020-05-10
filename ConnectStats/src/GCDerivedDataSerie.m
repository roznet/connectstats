//  MIT Licence
//
//  Created on 26/01/2014.
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

#import "GCDerivedDataSerie.h"
#import "GCActivity.h"
#import "GCAppGlobal.h"
#import "GCActivity+CachedTracks.h"
sqlite3_int64 kInvalidSerieId = 0;

@interface GCDerivedDataSerie ()

@property (nonatomic,retain) NSDate * bucketStart;
@property (nonatomic,retain) NSDate * bucketEnd;
@property (nonatomic,assign) sqlite3_int64 serieId;
@property (nonatomic,retain) NSString * filePath;
@end

@implementation GCDerivedDataSerie

#define kGCVersion          @"version"
#define kGCDerivedType      @"derivedType"
#define kGCField            @"fieldFlag"
#define kGCDerivedPeriod    @"derivedPeriod"
#define kGCActivityType     @"activityType"
#define kGCBucketStart      @"bucketStart"
#define kGCBucketEnd        @"bucketEnd"
#define kGCSerie            @"serie"

-(void)registerFileName:(NSString*)fn{
    self.filePath = [RZFileOrganizer writeableFilePathIfExists:fn];
}

+(BOOL)supportsSecureCoding{
    return YES;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.derivedPeriod  = [aDecoder decodeIntForKey:kGCDerivedPeriod];
        self.derivedType    = [aDecoder decodeIntForKey:kGCDerivedType];
        self.fieldFlag          = [aDecoder decodeIntForKey:kGCField];
        
        self.activityType   = [aDecoder decodeObjectOfClass:[NSString class] forKey:kGCActivityType];
        self.serieWithUnit  = [aDecoder decodeObjectOfClass:[GCStatsDataSerieWithUnit class] forKey:kGCSerie];
        self.bucketEnd      = [aDecoder decodeObjectOfClass:[NSDate class] forKey:kGCBucketEnd];
        self.bucketStart    = [aDecoder decodeObjectOfClass:[NSDate class] forKey:kGCBucketStart];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeInt:1                 forKey:kGCVersion];
    [aCoder encodeInt:(int)_derivedType      forKey:kGCDerivedType];
    [aCoder encodeInt:(int)_fieldFlag            forKey:kGCField];
    [aCoder encodeInt:(int)_derivedPeriod    forKey:kGCDerivedPeriod];
    [aCoder encodeObject:_activityType  forKey:kGCActivityType];
    [aCoder encodeObject:_serieWithUnit forKey:kGCSerie];
    [aCoder encodeObject:_bucketEnd     forKey:kGCBucketEnd];
    [aCoder encodeObject:_bucketStart   forKey:kGCBucketStart];
}

+(GCDerivedDataSerie*)derivedDataSerie:(gcDerivedType)type
                                 field:(gcFieldFlag)field
                                period:(gcDerivedPeriod)period
                               forDate:(NSDate *)date
                       andActivityType:(NSString *)atype{

    GCDerivedDataSerie * rv = [[[GCDerivedDataSerie alloc] init] autorelease];
    if (rv) {
        rv.derivedType = type;
        rv.fieldFlag = field;
        rv.derivedPeriod = period;
        rv.activityType = atype;


        if (date && period != gcDerivedPeriodAll) {
            GCStatsDateBuckets * buckets = [GCStatsDateBuckets statsDateBucketFor:period == gcDerivedPeriodMonth ? NSCalendarUnitMonth: NSCalendarUnitYear referenceDate:nil andCalendar:[GCAppGlobal calculationCalendar]];
            [buckets bucket:date];
            rv.bucketEnd = buckets.bucketEnd;
            rv.bucketStart = buckets.bucketStart;
        }
    }
    return rv;
}

+(GCDerivedDataSerie*)derivedDataSerie:(gcDerivedType)type
                                 field:(gcFieldFlag)field
                                period:(gcDerivedPeriod)period
                           forActivity:(GCActivity *)act{
    return [GCDerivedDataSerie derivedDataSerie:type field:field period:period
                                        forDate:act.date andActivityType:act.activityType];
}

-(void)dealloc{
    [_serieWithUnit release];
    [_activityType release];
    [_bucketEnd release];
    [_bucketStart release];
    [_filePath release];

    [super dealloc];
}

-(BOOL)dependsOnSerie:(GCDerivedDataSerie*)other{
    BOOL typeValid = [self.activityType isEqualToString:other.activityType];
    if( typeValid && self.fieldFlag == other.fieldFlag){
        if( self.derivedPeriod == gcDerivedPeriodAll && other.derivedPeriod != gcDerivedPeriodAll){
            return true;
        }
        if( self.derivedPeriod == gcDerivedPeriodYear && other.derivedPeriod == gcDerivedPeriodMonth){
            if( self.bucketStart && self.bucketEnd){
                return [self.bucketStart compare:other.bucketStart] != NSOrderedDescending && [self.bucketEnd compare:other.bucketEnd] != NSOrderedAscending;
            }
        }
    }
    return false;
}

-(BOOL)containsActivity:(GCActivity*)act{
    BOOL typeValid = [self.activityType isEqualToString:act.activityType];
    BOOL dateValid = self.derivedPeriod == gcDerivedPeriodAll;
    if( typeValid && ! dateValid){
        if( self.bucketStart && self.bucketEnd){
            dateValid = [self.bucketStart compare:act.date] != NSOrderedDescending && [self.bucketEnd compare:act.date] != NSOrderedAscending;
        }
    }
    return dateValid && typeValid;
}

-(NSArray<GCActivity*>*)containedActivitiesIn:(NSArray<GCActivity*>*)activities{
    NSMutableArray<GCActivity*> * rv = [NSMutableArray arrayWithCapacity:activities.count];
    for (GCActivity * act in activities) {
        if( [self containsActivity:act] ){
            [rv addObject:act];
        }
    }
    return rv;
}

-(NSArray<GCActivity*>*)bestMatchingSerieIn:(NSArray<GCActivity*>*)activities maxCount:(NSUInteger)maxcount{
    // don't go further that current serie
    NSUInteger count = MIN(maxcount, self.serieWithUnit.count);
    
    NSMutableArray<GCActivity*>* rv = [NSMutableArray arrayWithCapacity:count];
    BOOL betterIsMin = self.serieWithUnit.unit.betterIsMin;
    
    for (GCActivity * act in activities) {
        if( [self containsActivity:act] ){
            if( rv.count == 0){
                // first round, just put activity everywhere
                for( NSUInteger idx = 0; idx < count; idx++){
                    // We may add act beyond the size of that act's best serie.
                    [rv addObject:act];
                }
            }else{
                GCStatsDataSerieWithUnit * actBest = [act calculatedDerivedTrack:gcCalculatedCachedTrackRollingBest
                                                                        forField:self.field
                                                                          thread:nil];
                if( actBest.count == 0){
                    RZLog(RZLogInfo, @"got no points %@", act);
                }
                for (NSUInteger idx = 0; idx < MIN(count,actBest.count); idx ++ ) {
                    GCActivity * currrentBestActivity = rv[idx];
                    GCStatsDataSerieWithUnit * currentBest = [currrentBestActivity calculatedDerivedTrack:gcCalculatedCachedTrackRollingBest
                                                                                                 forField:self.field
                                                                                                   thread:nil];
                    if( idx < currentBest.count){
                        double y_best = [currentBest dataPointAtIndex:idx].y_data;
                        double check_y_best = [actBest dataPointAtIndex:idx].y_data;
                        if( betterIsMin ){
                            if( check_y_best < y_best ){
                                rv[idx] = act;
                            }
                        }else{
                            if( check_y_best > y_best ){
                                rv[idx] = act;
                            }
                        }
                    }else{
                        // If idx is beyond the size of current best, fill with current act, which is going further
                        rv[idx] = act;
                    }
                }
            }
        }
    }
    return rv;
}

-(GCField*)field{
    return [GCField fieldForFlag:self.fieldFlag andActivityType:self.activityType];
}
-(NSString*)key{
    NSString * typekey = nil;
    switch (_derivedType) {
        case gcDerivedTypeBestRolling:
            typekey = @"bestrolling";
            break;
        case gcDerivedTypeTimeInZone:
            typekey = @"timeinzone";
    }
    NSString * fieldkey = @"missing";
    if (self.fieldFlag == gcFieldFlagWeightedMeanSpeed) {
        fieldkey = @"speed";
    }else if (self.fieldFlag == gcFieldFlagWeightedMeanHeartRate){
        fieldkey = @"hr";
    }else if (self.fieldFlag == gcFieldFlagPower){
        fieldkey = @"power";
    }
    return [NSString stringWithFormat:@"%@-%@-%@-%@", _activityType, fieldkey, typekey, [self bucketKey]];
}

-(NSString*)description{
    return [NSString stringWithFormat:@"<%@: %@%@>", NSStringFromClass([self class]), self.key, self.isEmpty ? @"" : @" hasData"];
}

-(NSString*)bucketKey{
    NSCalendarUnit calUnit;
    NSTimeInterval extends;
    NSDate * rv = nil;

    switch (_derivedPeriod) {
        case gcDerivedPeriodAll:
            return @"all";
        case gcDerivedPeriodYear:
            calUnit = NSCalendarUnitYear;
            break;
        case gcDerivedPeriodMonth:
            calUnit = NSCalendarUnitMonth;
    }
    if (self.bucketStart == nil) {
        return @"NoDate";

    }else{
        [[GCAppGlobal calculationCalendar] rangeOfUnit:calUnit startDate:&rv interval:&extends forDate:self.bucketStart];
        return [[rv calendarUnitFormat:calUnit] stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString;
    }
}

-(void)reset{
    self.serieWithUnit = nil;
}
-(void)operate:(gcStatsOperand)operand with:(GCStatsDataSerieWithUnit*)other from:(GCActivity*)activity{
    if (self.serieWithUnit) {
        if (self.serieWithUnit.serie) {
            GCStatsDataSerie * otherSerie = [other dataSerieConvertedToUnit:self.serieWithUnit.unit].serie;
            [self.serieWithUnit convertToCommonUnitWith:other.unit];
            GCStatsDataSerie * serie = [self.serieWithUnit.serie operate:operand with:otherSerie];
            self.serieWithUnit.serie = serie;
        }else{
            self.serieWithUnit.serie = other.serie;
            self.serieWithUnit.unit = other.unit;
        }
    }else{
        self.serieWithUnit = [GCStatsDataSerieWithUnit dataSerieWithUnit:other.unit xUnit:other.xUnit andSerie:other.serie];
    }
}

#define DBCHECK(x) if(!x){ RZLog( RZLogError, @"Error %@", [db lastErrorMessage]); };

+(void)ensureDbStructure:(FMDatabase*)db{
    if (![db tableExists:@"gc_derived_series"]) {
        DBCHECK([db executeUpdate:@"CREATE TABLE gc_derived_series (serieId INTEGER PRIMARY KEY, key TEXT UNIQUE, activityType TEXT, fieldFlag INTEGER, derivedType INTEGER, derivedPeriod INTEGER, bucketStart REAL, bucketEnd REAL)"]);
        DBCHECK([db executeUpdate:@"CREATE INDEX IF NOT EXISTS gc_idx_derived_series_key ON gc_derived_series (key)"]);
    }
    if (![db tableExists:@"gc_derived_series_data"]) {
        DBCHECK([db executeUpdate:@"CREATE TABLE gc_derived_series_data (serieId INTEGER, x REAL, y REAL)"]);
        DBCHECK([db executeUpdate:@"CREATE INDEX IF NOT EXISTS gc_idx_derived_series_data_id ON gc_derived_series_data (serieId)"]);
    }
    if (![db tableExists:@"gc_derived_series_unit"]) {
        DBCHECK([db executeUpdate:@"CREATE TABLE gc_derived_series_unit (serieId INTEGER PRIMARY KEY, uom TEXT)"]);
    }
}

-(void)loadFromDb:(FMDatabase*)db{
    FMResultSet * res = [db executeQuery:@"SELECT serieId FROM gc_derived_series WHERE key = ?", [self key]];
    if ([res next]) {
        sqlite_int64 serieId = [res intForColumn:@"serieId"];
        self.serieId = serieId;

        res = [db executeQuery:@"SELECT x,y FROM gc_derived_series_data WHERE serieId = ? ORDER BY x", serieId];
        NSMutableArray * points = [NSMutableArray array];
        while ([res next]) {
            [points addObject:[GCStatsDataPoint dataPointWithX:[res doubleForColumn:@"x"]
                                                          andY:[res doubleForColumn:@"y"]]];
        }
        if (points.count>0) {
            GCUnit * unit = nil;
            res = [db executeQuery:@"SELECT uom FROM gc_derived_series_unit WHERE serieId = ?", @(serieId)];
            if ([res next]) {
                unit = [GCUnit unitForKey:[res stringForColumn:@"uom"]];
            }
            self.serieWithUnit = [GCStatsDataSerieWithUnit dataSerieWithUnit:unit];
            self.serieWithUnit.serie = [GCStatsDataSerie dataSerieWithPoints:points];
        }
    }

}

-(void)loadFromFile:(NSString*)fn{
    NSData * data = [NSData dataWithContentsOfFile:fn];
    GCDerivedDataSerie * loaded = [NSKeyedUnarchiver unarchivedObjectOfClass:[GCDerivedDataSerie class] fromData:data error:nil];
    if ([loaded isKindOfClass:[GCDerivedDataSerie class]]) {
        if (self.derivedPeriod == loaded.derivedPeriod
            && self.derivedType==loaded.derivedType
            && self.fieldFlag==loaded.fieldFlag
            && [self.activityType isEqualToString:loaded.activityType]) {
            self.serieWithUnit = loaded.serieWithUnit;
            self.filePath = fn;
        }else{
            RZLog(RZLogWarning, @"Ignoring load %@ from incompatible %@", self.key, loaded.key);
        }
    }
}

-(BOOL)saveToFile:(NSString*)fn{
    NSError * err=nil;
    BOOL rv = [[NSKeyedArchiver archivedDataWithRootObject:self
                           requiringSecureCoding:YES error:&err] writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:YES];
    if(err){
        RZLog(RZLogError,@"failed to archive %@",err);
    }
    if (rv) {
        self.filePath = [RZFileOrganizer writeableFilePathIfExists:fn];
        #if TARGET_IPHONE_SIMULATOR
            [[self.serieWithUnit.serie asCSVString:false] writeToFile:[NSString stringWithFormat:@"%@.csv", self.filePath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        #endif
    }
    return rv;
}
+(GCDerivedDataSerie*)derivedDataSerieFromResultSet:(FMResultSet*)res{
    GCDerivedDataSerie * rv = [[[GCDerivedDataSerie alloc] init] autorelease];
    if (rv) {
        rv.activityType = [res stringForColumn:@"activityType"];
        rv.fieldFlag = [res intForColumn:@"fieldFlag"];
        rv.derivedPeriod = [res intForColumn:@"derivedPeriod"];
        rv.bucketEnd  =[res dateForColumn:@"bucketEnd"];
        rv.bucketStart = [res dateForColumn:@"bucketStart"];
        rv.derivedType =[res intForColumn:@"derivedType"];
        rv.serieId = [res intForColumn:@"serieId"];
    }

    return rv;
}


-(sqlite3_int64)saveToDb:(FMDatabase*)db withData:(BOOL)withdata{
    [GCDerivedDataSerie ensureDbStructure:db];

    FMResultSet * res = [db executeQuery:@"SELECT serieId FROM gc_derived_series WHERE key = ?", [self key]];
    sqlite_int64 serieId = 0;
    [db beginTransaction];
    if ([res next]) {
        self.serieId = [res intForColumn:@"serieId"];
    }else{
        if ([db executeUpdate:@"INSERT INTO gc_derived_series (key,activityType,fieldFlag,derivedType,derivedPeriod,bucketStart,bucketEnd) VALUES (?,?,?,?,?,?,?)", self.key, self.activityType, @(_fieldFlag), @(_derivedType), @(_derivedPeriod), self.bucketStart, self.bucketEnd]){
            self.serieId = [db lastInsertRowId];
        }else{
            RZLog(RZLogError, @"Error %@", [db lastErrorMessage]);
        }
    }
    if (withdata) {
        if(![db executeUpdate:@"INSERT OR REPLACE INTO gc_derived_series_unit (serieId,uom) VALUES (?,?)", @(self.serieId), self.serieWithUnit.unit.key]){
            RZLog(RZLogError, @"Error %@", [db lastErrorMessage]);
        }
        if (![db executeUpdate:@"DELETE FROM gc_derived_series_data WHERE serieId=?", @(self.serieId)]) {
            RZLog(RZLogError, @"Error %@", [db lastErrorMessage]);
        }
        [db setShouldCacheStatements:YES];
        for (GCStatsDataPoint * point in self.serieWithUnit) {
            if(![db executeUpdate:@"INSERT INTO gc_derived_series_data (serieId,x,y) VALUES (?,?,?)", @(serieId), @(point.x_data), @(point.y_data)]){
                RZLog(RZLogError, @"Error %@", [db lastErrorMessage]);
            }
        }
        //[db setShouldCacheStatements:NO];
    }
    [db commit];
    return self.serieId;
}

-(BOOL)isEmpty{
    return self.filePath == nil || (self.serieWithUnit != nil && self.serieWithUnit.serie.count == 0);
}

@end
