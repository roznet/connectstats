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

#define kGCVersion          @"version"
#define kGCDerivedType      @"derivedType"
#define kGCField            @"fieldFlag"
#define kGCDerivedPeriod    @"derivedPeriod"
#define kGCActivityType     @"activityType"
#define kGCBucketStart      @"bucketStart"
#define kGCBucketEnd        @"bucketEnd"
#define kGCSerie            @"serie"

@interface GCDerivedDataSerie ()
@property (nonatomic,retain) GCStatsDataSerieWithUnit * cacheSerieWithUnit;
@property (nonatomic,retain) NSDate * bucketStart;
@property (nonatomic,retain) NSDate * bucketEnd;
@end

@implementation GCDerivedDataSerie

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
        self.cacheSerieWithUnit  = [aDecoder decodeObjectOfClass:[GCStatsDataSerieWithUnit class] forKey:kGCSerie];
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
    [aCoder encodeObject:_cacheSerieWithUnit forKey:kGCSerie];
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

-(void)dealloc{
    [_cacheSerieWithUnit release];
    [_activityType release];
    [_bucketEnd release];
    [_bucketStart release];
    [_fileNamePrefix release];

    [super dealloc];
}

-(GCStatsDataSerieWithUnit*)serieWithUnit{
    if( self.cacheSerieWithUnit == nil && self.fileNamePrefix){
        [self loadFromFileIfNeeded];
    }
    return self.cacheSerieWithUnit;
}

#pragma mark - Reconstruct with activities or other

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
                GCStatsDataSerieWithUnit * actBest = [act calculatedSerieForField:self.field.correspondingBestRollingField
                                                                          thread:nil];
                if( actBest.count == 0){
                    RZLog(RZLogInfo, @"got no points %@", act);
                }
                for (NSUInteger idx = 0; idx < MIN(count,actBest.count); idx ++ ) {
                    GCActivity * currrentBestActivity = rv[idx];
                    GCStatsDataSerieWithUnit * currentBest = [currrentBestActivity calculatedSerieForField:self.field.correspondingBestRollingField
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

#pragma mark - access

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
    NSString * points = self.cacheSerieWithUnit.count > 0 ? [NSString stringWithFormat:@" %@ points", @(self.cacheSerieWithUnit.count)] : @"";
    return [NSString stringWithFormat:@"<%@: %@%@>", NSStringFromClass([self class]), self.key, points];
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

-(BOOL)isEmpty{
    return self.filePath == nil || (self.serieWithUnit != nil && self.serieWithUnit.serie.count == 0);
}

#pragma mark - operate

-(void)reset{
    self.cacheSerieWithUnit = nil;
}
-(void)operate:(gcStatsOperand)operand with:(GCStatsDataSerieWithUnit*)other from:(GCActivity*)activity{
    if (self.cacheSerieWithUnit) {
        if (self.cacheSerieWithUnit.serie) {
            GCStatsDataSerie * otherSerie = [other dataSerieConvertedToUnit:self.serieWithUnit.unit].serie;
            [self.cacheSerieWithUnit convertToCommonUnitWith:other.unit];
            GCStatsDataSerie * serie = [self.serieWithUnit.serie operate:operand with:otherSerie];
            self.cacheSerieWithUnit.serie = serie;
        }else{
            self.cacheSerieWithUnit.serie = other.serie;
            self.cacheSerieWithUnit.unit = other.unit;
        }
    }else{
        self.cacheSerieWithUnit = [GCStatsDataSerieWithUnit dataSerieWithUnit:other.unit xUnit:other.xUnit andSerie:other.serie];
    }
}

#pragma mark - database and file save

+(void)ensureDbStructure:(FMDatabase*)db{
    if (![db tableExists:@"gc_derived_series"]) {
        RZEXECUTEUPDATE(db, @"CREATE TABLE gc_derived_series (serieId INTEGER PRIMARY KEY, key TEXT UNIQUE, activityType TEXT, fieldFlag INTEGER, derivedType INTEGER, derivedPeriod INTEGER, bucketStart REAL, bucketEnd REAL)");
        RZEXECUTEUPDATE(db, @"CREATE INDEX IF NOT EXISTS gc_idx_derived_series_key ON gc_derived_series (key)");
    }else{
        if( [db columnExists:@"serieId" inTableWithName:@"gc_derived_series"]){
            RZLog(RZLogInfo, @"Upgrading ");
            RZEXECUTEUPDATE(db, @"ALTER TABLE gc_derived_series RENAME TO gc_derived_series_old");
            RZEXECUTEUPDATE(db, @"CREATE TABLE gc_derived_series (key TEXT PRIMARY KEY, activityType TEXT, fieldFlag INTEGER, derivedType INTEGER, derivedPeriod INTEGER, bucketStart REAL, bucketEnd REAL)")
            RZEXECUTEUPDATE(db, @"INSERT INTO gc_derived_series SELECT key,activityType,fieldFlag,derivedType,derivedPeriod,bucketStart,bucketEnd FROM gc_derived_series_old");
        }
    }
    
    
    if ([db tableExists:@"gc_derived_series_data"]) {
        RZEXECUTEUPDATE(db, @"DROP TABLE gc_derived_series_data");
    }
    if ([db tableExists:@"gc_derived_series_unit"]) {
        RZEXECUTEUPDATE(db, @"DROP TABLE gc_derived_series_unit");
    }
}

-(NSString*)filename{
    NSString * filename = [NSString stringWithFormat:@"%@-%@.data", self.fileNamePrefix, self.key];
    return filename;
}

-(NSString*)filePath{
    NSString * filepath = [RZFileOrganizer writeableFilePath:self.filename];
    return filepath;
}

-(void)loadFromFileIfNeeded{
    if( self.cacheSerieWithUnit == nil){
        [self loadFromFile:self.filePath];
    }
}

-(void)clearDataAndFile{
    [self reset];
    [RZFileOrganizer removeEditableFile:self.filename];
}

-(BOOL)saveToFile{
    return([self saveToFile:self.filePath]);
}

-(void)loadFromFile:(NSString*)fn{
    NSData * data = [NSData dataWithContentsOfFile:fn];
    GCDerivedDataSerie * loaded = [NSKeyedUnarchiver unarchivedObjectOfClass:[GCDerivedDataSerie class] fromData:data error:nil];
    if ([loaded isKindOfClass:[GCDerivedDataSerie class]]) {
        if (self.derivedPeriod == loaded.derivedPeriod
            && self.derivedType==loaded.derivedType
            && self.fieldFlag==loaded.fieldFlag
            && [self.activityType isEqualToString:loaded.activityType]) {
            self.cacheSerieWithUnit = loaded.serieWithUnit;
        }else{
            RZLog(RZLogWarning, @"Ignoring load %@ from incompatible %@", self.key, loaded.key);
        }
    }
}

-(BOOL)saveToFile:(NSString*)fn{
    NSError * err=nil;
    BOOL rv = [[NSKeyedArchiver archivedDataWithRootObject:self
                                     requiringSecureCoding:YES error:&err] writeToFile:fn atomically:YES];
    if(err){
        RZLog(RZLogError,@"failed to archive %@",err);
    }
    if (rv) {
        #if TARGET_IPHONE_SIMULATOR
            [[self.serieWithUnit.serie asCSVString:false] writeToFile:[NSString stringWithFormat:@"%@.csv", fn] atomically:YES encoding:NSUTF8StringEncoding error:nil];
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
    }

    return rv;
}

-(BOOL)saveToDb:(FMDatabase*)db{
    BOOL rv = false;
    
    [GCDerivedDataSerie ensureDbStructure:db];

    FMResultSet * res = [db executeQuery:@"SELECT * FROM gc_derived_series WHERE key = ?", self.key];
    if ([res next]) {
        rv = false;
    }else{
        if ([db executeUpdate:@"INSERT INTO gc_derived_series (key,activityType,fieldFlag,derivedType,derivedPeriod,bucketStart,bucketEnd) VALUES (?,?,?,?,?,?,?)", self.key, self.activityType, @(_fieldFlag), @(_derivedType), @(_derivedPeriod), self.bucketStart, self.bucketEnd]){
            rv = true;
        }else{
            RZLog(RZLogError, @"Error %@", [db lastErrorMessage]);
        }
    }
    
    return rv;
}

@end
