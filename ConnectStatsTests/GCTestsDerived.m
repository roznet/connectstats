//
//  GCTestsDerived.m
//  GarminConnect
//
//  Created by Brice Rosenzweig on 01/02/2014.
//  Copyright (c) 2014 Brice Rosenzweig. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GCDerivedDataSerie.h"
#import "GCTestsSamples.h"
#import "GCDerivedOrganizer.h"
#import "GCAppGlobal.h"
#import "GCService.h"
#import "GCTestCase.h"
#import "GCConnectStatsRequestSearch.h"
#import "GCActivity+CachedTracks.h"

@interface GCTestsDerived : GCTestCase

@end

@implementation GCTestsDerived


- (void)testDerivedSerie
{
    
    NSArray * sample1 = @[ @1.,@10.,  @2.,@20.,  @3.,@20.,              @4.,@30.,  @5.,@25.,  @6.,@15., @7.,@20.    ];
    NSArray * sample2 = @[ @1.,@50.,  @2.,@40.,             @3.5,@40.,  @4.,@30.,  @5.,@15.,  @6.,@45.              ];
    NSArray * expect  = @[ @1.,@50.,  @2.,@40.,  @3.,@20.,  @3.5,@40.,  @4.,@30.,  @5.,@25.,  @6.,@45., @7.,@20.    ];
    
    GCDerivedDataSerie * derived = [GCDerivedDataSerie derivedDataSerie:gcDerivedTypeBestRolling field:gcFieldFlagWeightedMeanSpeed period:gcDerivedPeriodAll forDate:nil andActivityType:GC_TYPE_CYCLING];
    
    derived.serieWithUnit = [GCStatsDataSerieWithUnit dataSerieWithUnit:[GCUnit unitForKey:@"kph"]];
    derived.serieWithUnit.serie = [GCStatsDataSerie dataSerieWithArrayOfDouble:sample1];

    GCStatsDataSerieWithUnit * serieUnit = [GCStatsDataSerieWithUnit dataSerieWithUnit:[GCUnit unitForKey:@"kph"]];
    serieUnit.serie = [GCStatsDataSerie dataSerieWithArrayOfDouble:sample2];
    
    GCActivity * sample = [GCTestsSamples sampleCycling];
    
    [derived operate:gcStatsOperandMax with:serieUnit from:sample];
    for (NSUInteger i=0; i<expect.count; i+=2) {
        GCStatsDataPoint * point = [[derived serieWithUnit].serie dataPointAtIndex:i/2];
        XCTAssertEqualWithAccuracy(point.y_data, [expect[i+1] doubleValue], 1.e-7, @"expected max serie");
    }
}

-(void)testDerivedOrganizer{
    // build organizer
    // add activity with sample1 for trackpoint & date & activityType
    // process activity 1
    // add activity with sample2 for trackpoint & date & activityType
    // process activity 2
    //

    NSData * data = [NSData dataWithContentsOfFile:[RZFileOrganizer bundleFilePath:@"services_activities.json" forClass:[self class]]
                                           options:0 error:nil];
    NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    NSString * activityId = nil;
    for (NSString * aId in dict[@"types"][@"running"]) {
        if( [GCService serviceForActivityId:aId].service == gcServiceConnectStats){
            activityId = aId;
            break;
        }
    }
    NSString * bundlePath = [RZFileOrganizer bundleFilePath:nil forClass:[self class]];
    
    GCActivitiesOrganizer * organizer_cs = [self createEmptyOrganizer:@"test_parsing_derived_cs.db"];

    [GCConnectStatsRequestSearch testForOrganizer:organizer_cs withFilesInPath:bundlePath];
    GCActivity * act = [organizer_cs activityForId:activityId];
    // Disable backgorund calculation of derived tracks
    act.settings.worker = nil;
    
    // If false, it means the samples did not include the fit file for that run activity
    XCTAssertFalse(act.trackPointsRequireDownload);
    if( ! act.trackPointsRequireDownload){
        GCStatsDataSerieWithUnit * serieu = [act standardizedBestRollingTrack:[GCField fieldForFlag:gcFieldFlagWeightedMeanHeartRate andActivityType:act.activityType] thread:nil];
        
        FMDatabase * db = [[GCAppGlobal derived] deriveddb];
        NSLog(@"db: %@", db.databasePath);
        [db executeUpdate:@"DROP TABLE IF EXISTS gc_derived_time_serie"];
        if (![db tableExists:@"gc_derived_time_serie"]) {
            RZEXECUTEUPDATE(db, @"CREATE TABLE gc_derived_time_serie (activityId TEXT UNIQUE, fieldKey TEXT, date TIMESTAMP)");
        }
        FMResultSet * res = [db getTableSchema:@"gc_derived_time_serie"];
        NSMutableDictionary * cols = [NSMutableDictionary dictionary];
        NSMutableDictionary * missing = [NSMutableDictionary dictionary];
        while( [res next]){
            cols[ res[@"name"] ] = res[@"type"];
        }
        for (GCStatsDataPoint * point in [GCActivity standardSerieSampleForXUnit:GCUnit.second]) {
            NSString * colname = [NSString stringWithFormat:@"x_%.0f", point.x_data];
            if( cols[colname] == nil){
                missing[colname] = @(1);
                NSString * alterQuery = [NSString stringWithFormat:@"ALTER TABLE gc_derived_time_serie ADD COLUMN %@ REAL", colname];
                RZEXECUTEUPDATE(db, alterQuery);
            }
        }
        
        
        NSMutableDictionary * data = [NSMutableDictionary dictionaryWithDictionary:@{
            @"activityId" : act.activityId,
            @"date" : @(act.date.timeIntervalSince1970),
        }];
        NSMutableArray * insertFields = [NSMutableArray arrayWithArray:@[ @"activityId",  @"date" ]];
        NSMutableArray * insertValues = [NSMutableArray arrayWithArray:@[ @":activityId", @":date" ]];
        
        for (GCStatsDataPoint * point in serieu.serie) {
            NSString * colname = [NSString stringWithFormat:@"x_%.0f", point.x_data];
            data[colname] = @(point.y_data);
            [insertFields addObject:colname];
            [insertValues addObject:[@":" stringByAppendingString:colname]];
        }
        NSString * insertQuery = [NSString stringWithFormat:@"INSERT INTO gc_derived_time_serie (%@) VALUES (%@)",
                             [insertFields componentsJoinedByString:@","],
                            [ insertValues componentsJoinedByString:@","]];
        if( ![db executeUpdate:insertQuery withParameterDictionary:data]){
            RZLog(RZLogError, @"db error %@", db.lastErrorMessage);
        }

    }
}



@end
