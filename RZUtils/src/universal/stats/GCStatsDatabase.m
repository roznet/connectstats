//
//  GCStatsDatabase.m
//  RZUtils
//
//  Created by Brice Rosenzweig on 06/10/2019.
//  Copyright © 2019 Brice Rosenzweig. All rights reserved.
//

#import "GCStatsDatabase.h"
#import "RZMacros.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "GCStatsDataSerieWithUnit.h"
#import "RZUtils/RZUtils.h"

@interface GCStatsDatabase ()
@property (nonatomic,retain) FMDatabase * db;
@property (nonatomic,retain) NSString * tableName;
@property (nonatomic,retain) NSString * definitionTableName;

@end
@implementation GCStatsDatabase


+(GCStatsDatabase*)database:(FMDatabase*)db table:(NSString*)tableName{
    GCStatsDatabase * rv = RZReturnAutorelease([[GCStatsDatabase alloc] init]);
    if( rv ){
        rv.db = db;
        rv.tableName = tableName;
        rv.definitionTableName = [NSString stringWithFormat:@"%@_defs", tableName];
    }
    return rv;
}

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
        NSString * colname = [NSString stringWithFormat:@"x_%.0f", point.x_data];
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

-(void)save:(GCStatsDataSerieWithUnit*)serie keys:(NSDictionary*)keys{
    [self ensureDbStructure:keys serie:serie.serie];
    
    NSMutableArray * insertFields = [NSMutableArray arrayWithArray:keys.allKeys];
    NSMutableArray * insertValues = [NSMutableArray array];
    for (NSString * key in insertFields) {
        [insertValues addObject:[@":" stringByAppendingString:key]];
    }
    
    NSMutableArray * where = [NSMutableArray array];
    for (NSString * key in keys) {
        NSObject * val = keys[key];
        if( [val isKindOfClass:[NSString class]] ){
            [where addObject:[NSString stringWithFormat:@"%@ = '%@'", key, val]];
        }else{
            [where addObject:[NSString stringWithFormat:@"%@ = %@", key, val]];
        }
    }
    
    NSString * deleteQuery = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@", self.tableName, [where componentsJoinedByString:@" AND "]];
    RZEXECUTEUPDATE(self.db, deleteQuery);
    
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
