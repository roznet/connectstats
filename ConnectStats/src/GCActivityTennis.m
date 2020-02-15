//  MIT Licence
//
//  Created on 09/02/2014.
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

#import "GCActivityTennis.h"
#import "GCActivitySummaryValue.h"
#import "GCAppGlobal.h"
#import "GCActivity+Import.h"
#import "GCActivityTennisShotValues.h"
#import "GCActivityTennisCuePoint.h"
#import "GCWebConnect+Requests.h"
#import "GCActivity+Database.h"
#import "GCService.h"
#import "GCActivityTennisHeatmap.h"
#import "GCActivity+Fields.h"
#import "GCActivity+Database.h"

@interface GCActivityTennis ()
@property (nonatomic,retain) NSDictionary * shotsData;
@property (nonatomic,retain) NSArray * cuePoints;
@property (nonatomic,retain) NSDictionary * heatmaps;

@end

@implementation GCActivityTennis

-(instancetype)init{
    return [super init];
}

-(GCActivityTennis*)initWithId:(NSString *)aId{
    return [super initWithId:aId];
}

-(GCActivityTennis*)initWithId:(NSString*)aId andBabolatData:(NSMutableDictionary*)aData{
    self = [super init];
    if (self) {
        self.activityId = aId;
        [self parseJson:aData];
    }
    return self;
}

-(GCActivityTennis*)initWithResultSet:(FMResultSet*)res{
    return [super initWithResultSet:res];
}

-(void)dealloc{
    [_shotsData release];
    [_cuePoints release];
    [_heatmaps release];

    [super dealloc];
}


+(BOOL)isTennisActivityId:(NSString*)activityId{
    return [GCService serviceForActivityId:activityId].service == gcServiceBabolat;
}

-(double)shots{
    GCActivitySummaryValue * sum = self.summaryData[[GCField fieldForKey:@"shots" andActivityType:self.activityType]];
    return sum.numberWithUnit.value;
}
-(void)parseJson:(NSMutableDictionary*)aData{

    NSNumber * timeMinutes = aData[@"play_time"];
    NSNumber * shots = aData[@"shots"];
    NSString * start_date = aData[@"start_date"];

    self.activityType = GC_TYPE_TENNIS;


    self.activityTypeDetail = [GCActivityType activityTypeForKey:aData[@"type"]];
    self.activityName = aData[@"type"];

    self.date = [NSDate dateForBabolatTimeString:start_date];
    self.location = @"";

    [self registerTennisFields];

    [self setNumberWithUnit:[GCNumberWithUnit numberWithUnit:GCUnit.minute andValue:timeMinutes.doubleValue]
                   forField:[GCField fieldForFlag:gcFieldFlagSumDuration andActivityType:self.activityType] ];

    [self setSummaryDataFromKeyDict:@{@"shots":[GCActivitySummaryValue activitySummaryValueForDict:@{@"value":shots,@"uom":@"shots"} andField:@"shots"]}];

    self.flags  = gcFieldFlagSumDuration+gcFieldFlagTennisShots;
    self.downloadMethod = gcDownloadMethodTennis;

    [self saveToDb:self.db];
}
-(BOOL)loadTrackPoints{
    return true;
}

-(GCNumberWithUnit*)numberWithUnitForField:(GCField*)field{
    GCNumberWithUnit * rv = nil;
    if (field.fieldFlag == gcFieldFlagTennisShots) {
        rv = [GCNumberWithUnit numberWithUnitName:@"shots" andValue:self.shots];
    }else if ([GCActivityTennisHeatmap isHeatmapField:field.key]) {
        NSString * type = [GCActivityTennisHeatmap heatmapFieldType:field.key];
        gcHeatmapLocation loc = [GCActivityTennisHeatmap heatmapFieldLocation:field.key];

        GCActivityTennisHeatmap * heatmap  = (self.heatmaps)[type];
        rv = [heatmap valueForLocation:loc];
    }else{
        GCActivityTennisShotValues * val = (self.shotsData)[field.key];
        if (!val) {
            rv =  [super numberWithUnitForField:field];
        }else{
            //FIX not always power
            rv = [GCNumberWithUnit numberWithUnitName:@"percent" andValue:(val.average_power).doubleValue];
        }
    }
    return rv;
}

/*
-(double)summaryFieldValue:(gcFieldFlag)which{
    if (which==gcFieldFlagTennisShots) {
        return self.shots;
    }else{
        return [super summaryFieldValue:which];
    }
}
-(GCUnit*)displayUnitForSummaryField:(gcFieldFlag)which{
    switch (which) {
        case gcFieldFlagTennisPower:
            return [GCUnit unitForKey:@"percent"];
        case gcFieldFlagTennisShots:
            return [GCUnit unitForKey:@"shots"];
        case gcFieldFlagTennisRegularity:
        case gcFieldFlagTennisEnergy:
            return [GCUnit unitForKey:@"dimensionless"];
        default:
            return [super displayUnitForSummaryField:which];
    }
}
*/
-(void)saveSession:(NSDictionary*)json{

    NSDictionary * predefined = @{
                                  @"energy":                @[@"dimensionless", @(gcFieldFlagNone)],
                                  @"strokes_per_minutes":   @[@"dimensionless", @(gcFieldFlagNone)],
                                  @"max_rally":             @[@"shots",         @(gcFieldFlagNone)],
                                  @"technical" :            @[@"dimensionless", @(gcFieldFlagNone)],
                                  @"regularity" :           @[@"dimensionless", @(gcFieldFlagTennisRegularity)],
                                  @"average_power":         @[@"percent",       @(gcFieldFlagTennisPower)],
                                  @"total_strokes":         @[@"shots",         @(gcFieldFlagTennisShots)],
                                  @"total_play_time":       @[@"second",        @(gcFieldFlagNone)],
                                  @"effective_play_time":   @[@"second",        @(gcFieldFlagNone)]
                                  };
    NSDictionary * metaFields = @{
                                  @"tennis_surface":        @[], // hard, etc
                                  @"venue":                 @[],  // indoor, outdoor
                                  @"type" :                 @[], // training, match_won, match_lost
                                  @"feeling":               @[] // nice, etc
                                  };

    _downloadRequested = false;
    NSMutableDictionary * fields = [NSMutableDictionary dictionary];
    NSMutableDictionary * heatmaps =[NSMutableDictionary dictionaryWithCapacity:5];

    NSMutableDictionary * sumdata = [NSMutableDictionary dictionaryWithDictionary:self.summaryData?: @{}];
    NSMutableDictionary * metdata = [NSMutableDictionary dictionaryWithDictionary:self.metaData ?: @{}];

    for (NSString * key in json) {
        if (predefined[key]) {
            id val = json[key];
            double dval = 0.;
            if ([val isKindOfClass:[NSString class]]) {
                NSString * strval = val;
                dval = strval.doubleValue;
            }else if ([val isKindOfClass:[NSNumber class]]){
                NSNumber * numval = val;
                dval = numval.doubleValue;
            }
            NSString * uom = predefined[key][0];
            GCNumberWithUnit * numu = [GCNumberWithUnit numberWithUnitName:uom andValue:dval];
            GCActivitySummaryValue * sumval = [GCActivitySummaryValue activitySummaryValueForField:key value:numu];
            GCField * field = [GCField fieldForKey:key andActivityType:self.activityType];
            sumdata[field] = sumval;

        }else if( metaFields[key]){
            id val = json[key];
            if ([val isKindOfClass:[NSString class]]) {
                NSString * strval = val;
                NSDictionary * dictval = @{@"key":key, @"display":strval};
                metdata[key] = [GCActivityMetaValue activityValueForDict:dictval andField:key];
            }
        }else if ([key isEqualToString:@"cuePoints"]) {
            NSArray * cuedata = json[key];
            NSMutableArray * cuepoints = [NSMutableArray arrayWithCapacity:cuedata.count];
            for (NSDictionary * one in cuedata) {
                [cuepoints addObject:[GCActivityTennisCuePoint cuePointFromData:one]];
            }
            self.cuePoints = cuepoints;
        }else if ([key hasPrefix:@"heatmap"]) {
            NSString * type = GC_HEATMAP_ALL;
            if ([key hasPrefix:@"heatmap_"]){
                type = [key substringFromIndex:(@"heatmap_").length];
            }
            GCActivityTennisHeatmap * heatmap = [GCActivityTennisHeatmap heatmapForJson:json[key]];
            heatmaps[type] = heatmap;
        }else{
            for (NSString * prefix in @[@"average_effect_level_",@"average_power_", @"max_power_",@"total_"]) {
                if ([key hasPrefix:prefix] ) {
                    NSString* field = [key substringFromIndex:prefix.length];
                    if ([field isEqualToString:@"play_time"]||[field isEqualToString:@"strokes"]) {
                        continue;
                    }
                    GCActivityTennisShotValues * fielddata = fields[field];
                    if (!fielddata) {
                        fielddata =[GCActivityTennisShotValues tennisShotValuesForType:field];
                        fields[field] = fielddata;
                    }
                    if( [json[key] respondsToSelector:@selector(doubleValue)]){
                        [fielddata updateField:[prefix substringToIndex:prefix.length-1] with:[json[key] doubleValue]];
                    }
                    break;
                }
            }
        }
    }
    self.shotsData   = fields;
    self.heatmaps    = heatmaps;
    [self updateSummaryData:sumdata];
    [self updateMetaData:metdata];

    [self registerTennisFields];
    [self saveToTennisDb];
}

-(void)registerTennisFields{
    /*
    [GCFields registerField:@"averagePower" activityType:GC_TYPE_TENNIS displayName:@"Power" andUnitName:@"percent"];
    [GCFields registerField:@"SumDuration" activityType:GC_TYPE_TENNIS displayName:NSLocalizedString(@"Play Time",@"Tennis") andUnitName:@"second"];
    [GCFields registerField:@"shots" activityType:GC_TYPE_TENNIS displayName:NSLocalizedString(@"Shots",@"Tennis") andUnitName:@"shots"];
    [GCFields registerField:@"regularity" activityType:GC_TYPE_TENNIS displayName:NSLocalizedString(@"Consistency",@"Tennis") andUnitName:@"dimensionless"];
    [GCFields registerField:@"energy" activityType:GC_TYPE_TENNIS displayName:NSLocalizedString(@"Energy",@"Tennis") andUnitName:@"dimensionless"];
*/
}

-(NSString*)sessionId{
    return [[GCService service:gcServiceBabolat] serviceIdFromActivityId:self.activityId];
}

-(FMDatabase*)tennisdb{
    return [[GCAppGlobal organizer] tennisdb];
}
-(void)saveToTennisDb{
    NSString * session_id = self.sessionId;
    FMDatabase * tennisdb = [self tennisdb];
    if ([tennisdb intForQuery:@"SELECT COUNT(*) FROM babolat_sessions WHERE session_id = ?", session_id]) {
        if (![tennisdb executeUpdate:@"DELETE FROM babolat_shots WHERE session_id = ?", session_id]||
            ![tennisdb executeUpdate:@"DELETE FROM babolat_sessions WHERE session_id = ?", session_id]) {
            RZLog(RZLogError, @"failed to delete %@", [tennisdb lastErrorMessage]);
        };
    }

    [self.tennisdb executeUpdate:@"INSERT INTO babolat_sessions (session_id,start_date,shots,play_time) VALUES(?,?,?,?)",
     session_id,self.date,@(self.shots),@([self summaryFieldValueInStoreUnit:gcFieldFlagSumDuration])];
    for (NSString*field in self.shotsData) {
        GCActivityTennisShotValues *val = self.shotsData[field];
        [val saveToDb:tennisdb forSessionId:session_id];
    }
    for (NSUInteger i=0; i<self.cuePoints.count; i++) {
        GCActivityTennisCuePoint * point = (self.cuePoints)[i];
        [point saveToDb:tennisdb forSessionId:session_id index:i];
    }
    for (NSString * type in self.heatmaps) {
        GCActivityTennisHeatmap * heatmap = self.heatmaps[type];
        [heatmap saveToDb:tennisdb forId:session_id andType:type];
    }
}

-(void)loadFromTennisDb{
    // FIX not always needed
    [self registerTennisFields];

    NSString * session_id = self.sessionId;
    FMDatabase * tennisdb = [self tennisdb];
    if ([tennisdb intForQuery:@"SELECT COUNT(*) FROM babolat_sessions WHERE session_id = ?", session_id]) {
        FMResultSet * res = [tennisdb executeQuery:@"SELECT * FROM babolat_shots WHERE session_id = ?", session_id];
        self.shotsData = [NSMutableDictionary dictionary];
        while ([res next]) {
            GCActivityTennisShotValues * val = [GCActivityTennisShotValues tennisShotValuesForResultSet:res];
            [self.shotsData setValue:val forKey:val.shotType];
        }
        res = [tennisdb executeQuery:@"SELECT * FROM babolat_cuepoints WHERE session_id = ? ORDER BY cuepoint_id", session_id];
        NSMutableArray * cues = [NSMutableArray array];
        while ([res next]) {
            GCActivityTennisCuePoint* val = [GCActivityTennisCuePoint cuePointFromResultSet:res];
            [cues addObject:val];
        }
        self.cuePoints = cues;
        NSMutableDictionary * heatmaps = [NSMutableDictionary dictionaryWithCapacity:5];
        res = [tennisdb executeQuery:@"SELECT * FROM babolat_heatmaps WHERE session_id = ?", session_id];
        while ([res next]) {
            NSString * type = [res stringForColumn:@"heatmap_type"];
            GCActivityTennisHeatmap * heatmap = [GCActivityTennisHeatmap heatmapForResultSet:res];
            heatmaps[type] = heatmap;
        }
        self.heatmaps = heatmaps;
    };
}

-(BOOL)sessionDataReady{
    if (self.shotsData) {
        return true;
    }
    FMDatabase * tennisdb = [self tennisdb];
    if ([tennisdb intForQuery:@"SELECT COUNT(*) FROM babolat_sessions WHERE session_id = ?", self.sessionId]) {
        [self loadFromTennisDb];
        return true;
    }else{
        if (!_downloadRequested) {
            [self forceReloadTrackPoints];
            _downloadRequested = true;
        }
        //FIX load from internet
    }
    return false;
}
-(void)forceReloadTrackPoints{
    [[GCAppGlobal web] babolatDownloadTennisActivityDetails:self.activityId];

}

+(void)ensureDbStructure:(FMDatabase*)db{
    if (/* DISABLES CODE */ (false)) {
        [db executeUpdate:@"DROP TABLE babolat_sessions"];
        [db executeUpdate:@"DROP TABLE babolat_shots"];
        [db executeUpdate:@"DROP TABLE babolat_cuepoints"];
    }
    if (![db tableExists:@"babolat_sessions"]) {
        [db executeUpdate:@"CREATE TABLE babolat_sessions (session_id INTEGER, start_date REAL, shots REAL, play_time REAL, type TEXT, venue TEXT, tennis_surface TEXT, feeling TEXT )"];
    }
    if (![db tableExists:@"babolat_shots"]) {
        [db executeUpdate:@"CREATE TABLE babolat_shots (session_id INTEGER, shotType TEXT, total REAL, average_power REAL,  max_power REAL, average_effect_level REAL)"];
    }
    if (![db tableExists:@"babolat_cuepoints"]) {
        [db executeUpdate:@"CREATE TABLE babolat_cuepoints (session_id INTEGER, cuepoint_id INTEGER, time REAL,totalStrokes REAL,averagePower REAL,energy REAL,regularity REAL)"];
    }
    if (![db tableExists:@"babolat_heatmaps"]) {
        [db executeUpdate:@"CREATE TABLE babolat_heatmaps (session_id INTEGER, heatmap_type TEXT, center REAL, up REAL, down REAL, left REAL, right REAL)"];
    }
}
-(void)addShots:(NSDictionary*)shots cuePoints:(NSArray*)points andHeatmap:(NSDictionary*)heatmaps{
    self.shotsData = shots;
    self.cuePoints = points;
    self.heatmaps  = heatmaps;
}

-(NSArray*)availableShotTypes{
    return (self.shotsData).allKeys;
}
-(GCActivityTennisShotValues*)valuesForShotType:(NSString*)shotType{
    return (self.shotsData)[shotType];
}

-(GCActivityTennisHeatmap*)heatmapForType:(NSString*)type{
    return (self.heatmaps)[type];
}

-(GCStatsDataSerieWithUnit*)cuePointDataSerie:(NSString*)field{
    GCStatsDataSerie * rv = nil;
    if ([self sessionDataReady]) {
        NSMutableArray * pt = [NSMutableArray arrayWithCapacity:self.cuePoints.count];
        for (NSUInteger i=0; i<self.cuePoints.count; i++) {
            GCActivityTennisCuePoint * one = (self.cuePoints)[i];
            GCStatsDataPoint * point = [GCStatsDataPoint dataPointWithX:one.time andY:[one valueForField:field]];
            [pt addObject:point];
        }
        rv = [GCStatsDataSerie dataSerieWithPoints:pt];
    }
    return [GCStatsDataSerieWithUnit dataSerieWithUnit:[GCUnit unitForKey:@"dimensionless"] andSerie:rv];

}
-(GCStatsDataSerieWithUnit * )timeSerieForField:(GCField*)field{
    GCStatsDataSerieWithUnit * rv = nil;
    gcFieldFlag afield = field.fieldFlag;

    if (afield == gcFieldFlagTennisShots || afield == gcFieldFlagTennisPower || afield == gcFieldFlagTennisEnergy || afield == gcFieldFlagTennisRegularity) {
        switch (afield) {
            case gcFieldFlagTennisShots:
                rv = [self cuePointDataSerie:@"totalStrokes"];
                break;
            case gcFieldFlagTennisEnergy:
                rv = [self cuePointDataSerie:@"energy"];
                break;
            case gcFieldFlagTennisRegularity:
                rv = [self cuePointDataSerie:@"regularity"];
                break;
            case gcFieldFlagTennisPower:
                rv = [self cuePointDataSerie:@"averagePower"];
                break;

            default:
                break;
        }
    }else{
        rv= [super timeSerieForField:field];
    }
    return rv;
}

#pragma mark -

-(NSArray<GCField*>*)allFields{
    NSMutableArray<GCField*> * rv = [NSMutableArray arrayWithArray:[super allFields]];
    for (NSString * key in self.shotsData) {
        [rv addObject:[GCField fieldForKey:key andActivityType:self.activityType]];
    }

    NSMutableArray * hf = [NSMutableArray arrayWithCapacity:self.heatmaps.count];
    for (NSString * type in self.heatmaps) {
        GCField * field = [GCField fieldForKey:[GCActivityTennisHeatmap heatmapField:type location:gcHeatmapLocationCenter] andActivityType:self.activityType];
        [hf  addObject:field];
    }
    [rv addObjectsFromArray:hf];

    return rv;
}
-(BOOL)hasField:(GCField*)field{
    return (self.shotsData)[field.key] || [super hasField:field];
}



@end
