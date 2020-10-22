//
//  GCStatsDatabase.m
//  RZUtils
//
//  Created by Brice Rosenzweig on 06/10/2019.
//  Copyright © 2019 Brice Rosenzweig. All rights reserved.
//

#import "GCStatsDatabase.h"
#import <RZUtils/RZMacros.h>
#import <RZUtils/FMDatabase.h>
#import "FMDatabaseAdditions.h"
#import <RZUtils/GCStatsDataSerieWithUnit.h>
#import "RZUtils/RZUtils.h"

@interface GCStatsDatabase ()
@property (nonatomic,retain) FMDatabase * db;
@property (nonatomic,retain) NSString * tableName;
@property (nonatomic,retain) NSString * definitionTableName;
@property (nonatomic,retain) NSString * dataPointColumnNamePrefix;

@end
@implementation GCStatsDatabase


+(GCStatsDatabase*)database:(FMDatabase*)db table:(NSString*)tableName{
    GCStatsDatabase * rv = RZReturnAutorelease([[GCStatsDatabase alloc] init]);
    if( rv ){
        rv.db = db;
        rv.tableName = tableName;
        rv.definitionTableName = [NSString stringWithFormat:@"%@_defs", tableName];
        rv.dataPointColumnNamePrefix = @"x_";
    }
    return rv;
}

#if !__has_feature(objc_arc)
-(void)dealloc{
    [_db release];
    [_tableName release];
    [_definitionTableName release];
    [_dataPointColumnNamePrefix release];
    
    [super dealloc];
}
#endif
-(NSDictionary*)convertKeysToType:(NSDictionary*)keys{
    NSMutableDictionary * rv = [NSMutableDictionary dictionary];
    for (NSString * key in keys) {
        NSObject * val = keys[key];
        
        if( [val isKindOfClass:[NSString class]] ){
            rv[key] = @"TEXT";
        }else if ([ val isKindOfClass:[NSDate class]] ){
            rv[key] = @"TIMESTAMP";
        }else if ([val isKindOfClass:[NSNumber class]]){
            rv[key] = @"REAL";
        }
    }
    return rv;
}

-(BOOL)ensureDbStructure:(NSDictionary*)keys serie:(GCStatsDataSerie*)serie{
    BOOL rv = true;
    
    FMDatabase * db = self.db;
    
    NSDictionary * types = nil;
    
    if (![db tableExists:self.tableName]) {
        types = [self convertKeysToType:keys];
        NSMutableArray * fields = [NSMutableArray array];
        for (NSString * key in types) {
            NSString * type = types[key];
            [fields addObject:[NSString stringWithFormat:@"%@ %@", key, type]];
        }
        RZEXECUTEUPDATE(db, [NSString stringWithFormat:@"CREATE TABLE %@ (%@)", self.tableName, [fields componentsJoinedByString:@", "]]);
    }
    
    FMResultSet * res = [db getTableSchema:self.tableName];
    
    NSMutableDictionary * cols = [NSMutableDictionary dictionary];
    NSMutableDictionary * missing = [NSMutableDictionary dictionary];
    while( [res next]){
        cols[ res[@"name"] ] = res[@"type"];
    }
    
    for (GCStatsDataPoint * point in serie) {
        NSString * colname = [NSString stringWithFormat:@"%@%.0f", self.dataPointColumnNamePrefix, point.x_data];
        if( cols[colname] == nil){
            missing[colname] = @(1);
            NSString * alterQuery = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ REAL", self.tableName, colname];
            RZEXECUTEUPDATE(db, alterQuery);
        }
    }
    
    
    for (NSString * keyColName in keys) {
        if( cols[ keyColName ] == nil){
            if( types == nil){
                types = [self convertKeysToType:keys];
            }
            NSString * type = types[keyColName];
            NSString * alterQuery = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ %@", self.tableName, keyColName, type];
            RZEXECUTEUPDATE(db, alterQuery);
        }
    }
    return rv;
}
-(NSDictionary*)keysForResultSet:(FMResultSet*)res{
    NSMutableDictionary * rv = [NSMutableDictionary dictionary];
    NSDictionary * dict = res.resultDictionary;
    
    for (NSString * colname in dict) {
        if( ! [colname hasPrefix:self.dataPointColumnNamePrefix] ){
            rv[colname] = dict[colname];
        }
    }
    return rv;
}
-(GCStatsDataSerie*)serieForResultSet:(FMResultSet*)res{
    GCStatsDataSerie * rv = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);
    NSDictionary * dict = res.resultDictionary;
    for (NSString * colname in dict) {
        NSNumber * y_value = dict[colname];
        if( [y_value isKindOfClass:[NSNumber class]] && [colname hasPrefix:self.dataPointColumnNamePrefix]){
            double x_value = [[colname substringFromIndex:self.dataPointColumnNamePrefix.length] doubleValue];
            [rv addDataPointWithX:x_value andY:y_value.doubleValue];
        }
    }
    [rv sortByX];
    return rv;
}
-(GCStatsDataSerie*)loadForKeys:(NSDictionary*)keys{
    GCStatsDataSerie * rv = nil;
    
    NSString * where = [self whereStatementForKeys:keys];
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@", self.tableName, where];
    
    FMResultSet * res = [self.db executeQuery:query];
    if( [res next]){
        rv = [self serieForResultSet:res];
    }
    return rv;
}
-(NSDictionary<NSDictionary*,GCStatsDataSerie*>*)loadByKeys{
    NSMutableDictionary * rv = [NSMutableDictionary dictionary];
    
    // It's possible nothing there and table wasn't even created
    if( [self.db tableExists:self.tableName] ){
        NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@", self.tableName];
        
        FMResultSet * res = [self.db executeQuery:query];
        while( [res next]){
            GCStatsDataSerie * serie = [self serieForResultSet:res];
            NSDictionary * keys = [self keysForResultSet:res];
            BOOL keep = true;
            if( [keys[@"fieldKey"] isEqualToString:@"WeightedMeanSpeed"] || [keys[@"fieldKey"] isEqualToString:@"WeightedMeanPace"] ) {
                gcStatsRange range = serie.range;
                if( range.y_min < 0 || range.y_max > 30.0 ) {
                    keep = false;
                    static NSUInteger _badSerie = 0;
                    if( _badSerie < 5){
                        RZLog(RZLogInfo, @"Skipping bad serie in %@ for %@ %@ in [%@,%@]", self.tableName, keys[@"activityId"], keys[@"fieldKey"], @(range.y_min), @(range.y_max));
                    }else if( _badSerie % 25 == 0){
                        RZLog(RZLogInfo, @"Skipped %@ bad series", @(_badSerie));
                    }
                    _badSerie++;
                }
            }
            if( keep ){
                rv[ keys ] = serie;
            }
        }
    }
    return rv;

}

-(NSString*)whereStatementForKeys:(NSDictionary*)keys{
    NSMutableArray * where = [NSMutableArray array];
    for (NSString * key in keys) {
        NSObject * val = keys[key];
        if( [val isKindOfClass:[NSString class]] ){
            [where addObject:[NSString stringWithFormat:@"%@ = '%@'", key, val]];
        }else if( [val isKindOfClass:[NSDate class]] ){
            NSDate * date = (NSDate*) val;
            [where addObject:[NSString stringWithFormat:@"%@ = '%@'", key, [date sqliteDateFormat]]];
        }else{
            [where addObject:[NSString stringWithFormat:@"%@ = %@", key, val]];
        }
    }
    return [where componentsJoinedByString:@" AND "];
}
-(void)save:(GCStatsDataSerie*)serie keys:(NSDictionary*)keys{
    [self ensureDbStructure:keys serie:serie];
    
    NSMutableArray * insertFields = [NSMutableArray arrayWithArray:keys.allKeys];
    NSMutableArray * insertValues = [NSMutableArray array];
    for (NSString * key in insertFields) {
        [insertValues addObject:[@":" stringByAppendingString:key]];
    }
    
    NSString * where = [self whereStatementForKeys:keys];
    // Protection for where empty
    if( where.length > 0){
        NSString * deleteQuery = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@", self.tableName, where];
        RZEXECUTEUPDATE(self.db, deleteQuery);
    };
    NSMutableDictionary * data = [NSMutableDictionary dictionaryWithDictionary:keys];
    
    for (GCStatsDataPoint * point in serie) {
        NSString * colname = [NSString stringWithFormat:@"x_%.0f", point.x_data];
        data[colname] = @(point.y_data);
        [insertFields addObject:colname];
        [insertValues addObject:[@":" stringByAppendingString:colname]];
    }
    NSString * insertQuery = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)",
                              self.tableName,
                         [insertFields componentsJoinedByString:@","],
                        [ insertValues componentsJoinedByString:@","]];
    
    if( ![self.db executeUpdate:insertQuery withParameterDictionary:data]){
        RZLog(RZLogError, @"db error %@", self.db.lastErrorMessage);
    }

}

@end
