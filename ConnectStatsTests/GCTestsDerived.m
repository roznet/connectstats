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
#import "GCConnectStatsRequestFitFile.h"
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

    // Disable derived calculation automatically triggered, everything
    // should be trigger by the test directly
    BOOL saveDerived = [[GCAppGlobal profile] configGetBool:CONFIG_ENABLE_DERIVED defaultValue:[GCAppGlobal connectStatsVersion]];
    
    [[GCAppGlobal profile] configSet:CONFIG_ENABLE_DERIVED boolVal:false];

    NSData * data = [NSData dataWithContentsOfFile:[RZFileOrganizer bundleFilePath:@"services_activities.json" forClass:[self class]]
                                           options:0 error:nil];
    NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    NSString * activityIdRun = nil;
    NSString * activityIdCycling = nil;
    
    NSMutableArray<NSString*>*activityIds = [NSMutableArray array];
    
    for (NSString * aId in dict[@"types"][@"running"]) {
        GCService * service = [GCService serviceForActivityId:aId];
        if( service.service == gcServiceConnectStats){
            NSString * fileName = [NSString stringWithFormat:@"track_cs_%@.fit", [service serviceIdFromActivityId:aId ]];
            if( [RZFileOrganizer bundleFilePathIfExists:fileName forClass:[self class]] ){
                activityIdRun = aId;
                [activityIds addObject:aId];
            }
        }
    }
    for (NSString * aId in dict[@"types"][@"cycling"]) {
        GCService * service = [GCService serviceForActivityId:aId];
        if( service.service == gcServiceConnectStats){
            NSString * fileName = [NSString stringWithFormat:@"track_cs_%@.fit", [service serviceIdFromActivityId:aId ]];
            if( [RZFileOrganizer bundleFilePathIfExists:fileName forClass:[self class]] ){
                activityIdCycling = aId;
                [activityIds addObject:aId];
            }
        }
    }
    NSString * bundlePath = [RZFileOrganizer bundleFilePath:nil forClass:[self class]];
    // add doubles to make sure it gets merged back properly
    [activityIds addObjectsFromArray:@[activityIdRun,activityIdCycling]];
    
    GCActivitiesOrganizer * organizer_cs = [self createEmptyOrganizer:@"test_parsing_bestrolling_cs.db"];
    [RZFileOrganizer removeEditableFile:@"test_derived_parsing_bestrolling_cs.db"];
    FMDatabase * deriveddb = [FMDatabase databaseWithPath:[RZFileOrganizer writeableFilePath:@"test_derived_parsing_bestrolling_cs.db"]];
    [deriveddb open];
    [GCDerivedOrganizer ensureDbStructure:deriveddb];
    
    GCDerivedOrganizer * derived = [[GCDerivedOrganizer alloc] initWithDb:deriveddb andThread:nil];
                                    
    [GCConnectStatsRequestSearch testForOrganizer:organizer_cs withFilesInPath:bundlePath];

    [RZFileOrganizer removeEditableFile:@"derived_test_time_series.db"];
    FMDatabase * db = [FMDatabase databaseWithPath:[RZFileOrganizer writeableFilePath:@"derived_test_time_series.db"]];
    [db open];
    RZLog(RZLogInfo, @"db: %@", db.databasePath);
    
    GCStatsDatabase * statsDb = [GCStatsDatabase database:db table:@"gc_derived_time_serie_second"];
    NSMutableDictionary * done = [NSMutableDictionary dictionary];
    
    double x_for_test = 10.0;
    GCStatsDataSerie * hrReconstructed = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);

    for (NSString * activityId in activityIds) {
        
        GCActivity * act = [organizer_cs activityForId:activityId];
        // Disable backgorund calculation of derived tracks
        act.settings.worker = nil;
        
        [GCConnectStatsRequestFitFile testForActivity:act withFilesIn:bundlePath];
        
        // If false, it means the samples did not include the fit file for that run activity
        XCTAssertFalse(act.trackPointsRequireDownload);
        if( ! act.trackPointsRequireDownload && act.trackpoints){
            // Run on worker as could collide with main app init load
            dispatch_sync([GCAppGlobal worker], ^(){
                [derived processActivities:@[ act] ];
            });
            
            for (GCField * field in @[ [GCField fieldForFlag:gcFieldFlagWeightedMeanHeartRate andActivityType:act.activityType],
                                       [GCField fieldForFlag:gcFieldFlagPower andActivityType:act.activityType] ] ) {
                if( [act hasTrackForField:field] ){
                    RZLog(RZLogInfo, @"%@ %@", act, field);
                    GCStatsDataSerieWithUnit * serieu = [act standardizedBestRollingTrack:field thread:nil];
                    
                    NSDictionary * keys = @{
                        @"activityId" : act.activityId,
                        @"fieldKey" : field.key,
                    };
                    if( done[keys] == nil && field.fieldFlag == gcFieldFlagWeightedMeanHeartRate && [act.activityType isEqualToString:GC_TYPE_RUNNING] ){
                        GCStatsInterpFunction * func = [GCStatsInterpFunction interpFunctionWithSerie:serieu.serie];
                        [hrReconstructed addDataPointWithDate:act.date andValue:[func valueForX:x_for_test]];
                    }

                    done[keys] = serieu;
                    [statsDb save:serieu.serie keys:keys];
                }
            }
        }
    }
    NSDictionary * all = [statsDb loadByKeys];
    
    NSMutableDictionary * serieOfSeries = [NSMutableDictionary dictionary];
    
    
    for (NSDictionary * keys in done) {
        GCStatsDataSerie * keyreload = all[keys];
        
        GCActivity * act = [organizer_cs activityForId:keys[@"activityId"]];
        XCTAssertNotNil(act, @"Found activity for key %@", keys);
        
        NSDictionary * sOfSKey = @{ @"activityType": act.activityType, @"fieldKey":keys[@"fieldKey"]};
        GCStatsDataSerieWithUnit * serieu = done[keys];
        
        GCStatsSerieOfSerieWithUnits * serieOfSerie = serieOfSeries[sOfSKey];
        if( serieOfSerie == nil){
            serieOfSerie = [GCStatsSerieOfSerieWithUnits serieOfSerieWithUnits:[GCUnit date]];
            serieOfSeries[sOfSKey] = serieOfSerie;
        }
        
        [serieOfSerie addSerie:serieu forDate:act.date];
        
        GCStatsDataSerie * reload = [statsDb loadForKeys:keys];
        XCTAssertEqual(reload.count, serieu.count);
        XCTAssertEqual(reload.count, keyreload.count);
        
        XCTAssertEqualObjects(reload, serieu.serie);
    }
    GCStatsSerieOfSerieWithUnits * res = serieOfSeries[@{@"activityType":GC_TYPE_RUNNING,@"fieldKey":@"WeightedMeanHeartRate"}];
    GCStatsDataSerieWithUnit * xserieu = [res serieForX:[GCNumberWithUnit numberWithUnitName:@"bpm" andValue:x_for_test]];
    
    [hrReconstructed sortByX];
    XCTAssertEqualObjects(hrReconstructed, xserieu.serie);
    
    [[GCAppGlobal profile] configSet:CONFIG_ENABLE_DERIVED boolVal:saveDerived];

}



@end
