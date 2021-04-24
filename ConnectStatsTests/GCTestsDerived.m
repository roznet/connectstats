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
#import "GCActivity+CalculatedTracks.h"

@interface GCTestsDerived : GCTestCase

@end

@implementation GCTestsDerived

/*
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
*/

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


-(void)setupDerived:(GCActivitiesOrganizer*)organizer derived:(GCDerivedOrganizer*)derived field:(GCField*)field activities:(NSArray<NSString*>*)activityIds{
    
    NSString * path = [RZFileOrganizer bundleFilePath:@"last_connectstats_search_derived.json" forClass:[self class]];
    [GCConnectStatsRequestSearch testForOrganizer:organizer withFilesInPath:path];
    GCService * service = [GCService service:gcServiceConnectStats];
    for (NSString * serviceId  in activityIds) {
        NSString * activityId = [service activityIdFromServiceId:serviceId];
        GCActivity * act = [organizer activityForId:activityId];
        act.settings.worker = nil;
        XCTAssertNotNil(act);
        NSString * fp_fit = [RZFileOrganizer bundleFilePath:[NSString stringWithFormat:@"track_cs_%@.fit", serviceId] forClass:[self class]];
        GCActivity * fit = [GCConnectStatsRequestFitFile testForActivity:act withFilesIn:fp_fit];
        fit.settings.worker = nil;
        XCTAssertNotNil(fit);
        [derived processActivities:@[ fit ] ];
    }

}

-(void)testDerivedRebuild{
    /*
     2 activities in april, 2 in may
     <GCActivity running:__connectstats__857090 2020-05-04 38:13 7.07 km>
     <GCActivity running:__connectstats__834323 2020-05-01 28:10 5.86 km>
     <GCActivity running:__connectstats__777501 2020-04-24 26:25 5.53 km>
     <GCActivity running:__connectstats__728599 2020-04-18 21:42 4.25 km>
     */
    
    NSArray<NSString*>*activityIds = @[   @"857090", @"834323", @"777501", @"728599" ];
    GCField * field = [GCField fieldForFlag:gcFieldFlagWeightedMeanHeartRate andActivityType:GC_TYPE_RUNNING];

    NSString * db_name = @"test_activities_derived_rebuild.db";
    NSString * derived_name = @"test_derived_rebuild";
    GCActivitiesOrganizer * organizer = [self createEmptyOrganizer:db_name];
    GCDerivedOrganizer * derived = [self createEmptyDerived:derived_name];
    
    [self setupDerived:organizer derived:derived field:field activities:activityIds];
    
    // Skip first
    NSArray<GCActivity*>*activities = [organizer activities];
    GCActivity * testForAct = activities.firstObject;
    NSUInteger bestIdx = 0;

    // Look at serie containing testForAct
    GCDerivedDataSerie * serie = [derived derivedDataSerie:gcDerivedTypeBestRolling
                                                      field:field
                                                     period:gcDerivedPeriodMonth
                                                    forDate:testForAct.date];

    GCDerivedDataSerie * serieYear= [derived derivedDataSerie:gcDerivedTypeBestRolling
                                                      field:field
                                                     period:gcDerivedPeriodYear
                                                    forDate:testForAct.date];

    double original_y_max = [serie.serieWithUnit dataPointAtIndex:bestIdx].y_data;
    double original_year_y_max = [serieYear.serieWithUnit dataPointAtIndex:bestIdx].y_data;


    // NOW try to rebuild
    
    NSArray<GCActivity*>*bestActivities = [derived bestMatchingActivitySerieFor:serie within:activities completion:nil];
    NSArray<GCActivity*>*bestYearActivities = [derived bestMatchingActivitySerieFor:serieYear within:activities completion:nil];

    GCActivity * exclude = bestActivities[bestIdx];
    XCTAssertEqualObjects(bestYearActivities[bestIdx].activityId, exclude.activityId, @"Check that testAct was selected in the month with best overall");

    NSMutableArray * sameSerieAsExcluded = [NSMutableArray array];
    NSMutableArray * allButExcluded = [NSMutableArray array];

    for (GCActivity * one in activities) {
        if( [one.activityId isEqualToString:exclude.activityId] ){
            continue; // skip
        }
        if( [serie containsActivity:one] ){
            [sameSerieAsExcluded addObject:one];
        }
        [allButExcluded addObject:one];
    }
    
    
    GCStatsDataSerieWithUnit * excludeBest = [exclude calculatedSerieForField:serie.field.correspondingBestRollingField
                                                                      thread:nil];
    // First check best is correct
    double excluded_y_max = [excludeBest dataPointAtIndex:bestIdx].y_data;
    XCTAssertEqualWithAccuracy(excluded_y_max, original_y_max, 1.0e-8);
    // Note this is because testAct is in the month with the best overall... setup dependent
    XCTAssertEqualWithAccuracy(excluded_y_max, original_year_y_max, 1.0e-8);

    // Check all the other are lower
    for (GCActivity * act in sameSerieAsExcluded) {
        GCStatsDataSerieWithUnit * checkBest = [act calculatedSerieForField:serie.field.correspondingBestRollingField
                                                                          thread:nil];
        XCTAssertLessThan([checkBest dataPointAtIndex:bestIdx].y_data, excluded_y_max);
    }
    
    // rebuild now with the first act that wasn't the max. Now new best should be less that excluded serie
    [derived forceReprocessActivity:exclude.activityId];
    [derived rebuildDerivedDataSerie:gcDerivedTypeBestRolling
                         forActivity:testForAct
                        inActivities:sameSerieAsExcluded];
    
    GCDerivedDataSerie * serieWithoutExcluded = [derived derivedDataSerie:gcDerivedTypeBestRolling
                                                     field:field
                                                    period:gcDerivedPeriodMonth
                                                   forDate:testForAct.date];
    
    GCDerivedDataSerie * serieYearWithoutExcluded = [derived derivedDataSerie:gcDerivedTypeBestRolling
                                                     field:field
                                                    period:gcDerivedPeriodYear
                                                   forDate:testForAct.date];

    double rebuild_y_max = [serieWithoutExcluded.serieWithUnit dataPointAtIndex:bestIdx].y_data;
    double rebuild_year_y_max = [serieYearWithoutExcluded.serieWithUnit dataPointAtIndex:bestIdx].y_data;

    XCTAssertLessThan(rebuild_y_max, excluded_y_max);
    XCTAssertLessThan(rebuild_year_y_max, excluded_y_max);

    [derived processActivities:@[ exclude ] ];
    
    GCDerivedDataSerie * serieWithExcluded = [derived derivedDataSerie:gcDerivedTypeBestRolling
                                                     field:field
                                                    period:gcDerivedPeriodMonth
                                                   forDate:testForAct.date];
    GCDerivedDataSerie * serieYearWithExcluded = [derived derivedDataSerie:gcDerivedTypeBestRolling
                                                     field:field
                                                    period:gcDerivedPeriodYear
                                                   forDate:testForAct.date];

    double final_y_max = [serieWithExcluded.serieWithUnit dataPointAtIndex:bestIdx].y_data;
    double final_year_y_max = [serieYearWithExcluded.serieWithUnit dataPointAtIndex:bestIdx].y_data;
    XCTAssertEqualWithAccuracy(final_y_max, excluded_y_max, 1.0e-8);
    XCTAssertEqualWithAccuracy(final_year_y_max, excluded_y_max, 1.0e-8);
    
    GCDerivedDataSerie * serieAll = [derived derivedDataSerie:gcDerivedTypeBestRolling
                                                     field:field
                                                    period:gcDerivedPeriodAll
                                                   forDate:testForAct.date];
    NSArray<GCDerivedDataSerie*>*bestSeries = [derived bestMatchingDerivedSerieFor:serieAll completion:nil];
    double allFromSeries_y_max = [bestSeries[bestIdx].serieWithUnit dataPointAtIndex:bestIdx].y_data;
    // we recover the best when we do best by serie, because setup such that month of focus is best one
    XCTAssertEqualWithAccuracy(allFromSeries_y_max, excluded_y_max, 1.0e-8);
    XCTAssertEqual(bestSeries.count, serieAll.serieWithUnit.count);

    // Tet Reload
    
    GCDerivedOrganizer * reload = [[GCDerivedOrganizer alloc] initTestModeWithDb:derived.deriveddb thread:nil andFilePrefix:derived_name];

    GCDerivedDataSerie * reload_serie = [reload derivedDataSerie:gcDerivedTypeBestRolling
                                                      field:field
                                                     period:gcDerivedPeriodMonth
                                                    forDate:testForAct.date];

    GCDerivedDataSerie * reload_serieYear= [reload derivedDataSerie:gcDerivedTypeBestRolling
                                                      field:field
                                                     period:gcDerivedPeriodYear
                                                    forDate:testForAct.date];

    double reload_y_max = [reload_serie.serieWithUnit dataPointAtIndex:bestIdx].y_data;
    double reload_year_y_max = [reload_serieYear.serieWithUnit dataPointAtIndex:bestIdx].y_data;

    XCTAssertEqualWithAccuracy(reload_y_max, original_y_max, 1.0e-8);
    XCTAssertEqualWithAccuracy(reload_year_y_max, original_year_y_max, 1.0e-8);


}

-(void)testDerivedHistorical{
    /*
     2 activities in april, 2 in may
     <GCActivity running:__connectstats__857090 2020-05-04 38:13 7.07 km>
     <GCActivity running:__connectstats__834323 2020-05-01 28:10 5.86 km>
     <GCActivity running:__connectstats__777501 2020-04-24 26:25 5.53 km>
     <GCActivity running:__connectstats__728599 2020-04-18 21:42 4.25 km>
     */
    
    NSArray<NSString*>*activityIds = @[   @"857090", @"834323", @"777501", @"728599" ];
    GCField * field = [GCField fieldForFlag:gcFieldFlagWeightedMeanHeartRate andActivityType:GC_TYPE_RUNNING];

    NSString * db_name = @"test_activities_derived_rebuild.db";
    GCActivitiesOrganizer * organizer = [self createEmptyOrganizer:db_name];
    GCDerivedOrganizer * derived = [self createEmptyDerived:@"test_derived_rebuild"];
    
    [self setupDerived:organizer derived:derived field:field activities:activityIds];
    // Now test against historical Series
    GCStatsSerieOfSerieWithUnits * serieOfSeries = [derived timeserieOfSeriesFor:field inActivities:[organizer activities]];
    XCTAssertNotNil(serieOfSeries);

    // Get the curve from the serie of serie that is f( date ) = y = best rolling( x )
    
    GCNumberWithUnit * x = [GCNumberWithUnit numberWithUnit:[GCUnit second] andValue:30.0];
    GCStatsDataSerieWithUnit * serieForX = [serieOfSeries serieForX:x];
    GCActivity * one = organizer.activities.firstObject;
    GCStatsDataSerieWithUnit * oneStandard = [one standardizedBestRollingTrack:field thread:nil];
    GCStatsDataSerieWithUnit * oneFull = [one calculatedSerieForField:field.correspondingBestRollingField thread:nil];

    // Get value from the series for date, from the standard curve of activity or from full curve of activity
    // on an anchor like 30.0, all should be equal
    GCStatsInterpFunction * serieInterp = [GCStatsInterpFunction interpFunctionWithSerie:serieForX.serie];
    GCStatsInterpFunction * oneStandardInterp = [GCStatsInterpFunction interpFunctionWithSerie:oneStandard.serie];
    GCStatsInterpFunction * oneFullInterp = [GCStatsInterpFunction interpFunctionWithSerie:oneFull.serie];
    double eps = 1.0e-8;
    XCTAssertEqualWithAccuracy([oneStandardInterp valueForX:x.value], [oneFullInterp valueForX:x.value], eps);
    XCTAssertEqualWithAccuracy([oneStandardInterp valueForX:x.value], [serieInterp valueForX:[one.date timeIntervalSinceReferenceDate]], eps);
                                                                       
                                                                       
}


-(void)testDerivedHist{
    [RZFileOrganizer createEditableCopyOfFile:@"activities_testderived.db" forClass:[self class]];
    [RZFileOrganizer createEditableCopyOfFile:@"derived_testderived.db" forClass:[self class]];
    
    FMDatabase * db = [FMDatabase databaseWithPath:[RZFileOrganizer writeableFilePath:@"activities_testderived.db"]];
    [db open];
    GCActivitiesOrganizer * organizer = [[GCActivitiesOrganizer alloc] initTestModeWithDb:db];
    FMDatabase * deriveddb = [FMDatabase databaseWithPath:[RZFileOrganizer writeableFilePath:@"derived_testderived.db"]];
    [deriveddb open];

    GCDerivedOrganizer * derived = [[GCDerivedOrganizer alloc] initTestModeWithDb:deriveddb thread:nil andFilePrefix:@"testderived"];
    GCField * field = [GCField fieldForFlag:gcFieldFlagWeightedMeanHeartRate andActivityType:GC_TYPE_RUNNING];
    GCStatsSerieOfSerieWithUnits * serieOfSeries = [derived timeserieOfSeriesFor:field inActivities:organizer.activities];
        
    NSArray<GCNumberWithUnit*>*xs = [serieOfSeries allXs];
    for (GCNumberWithUnit * nu in xs) {
        GCStatsDataSerieWithUnit * one = [serieOfSeries serieForX:nu];
        XCTAssertGreaterThan(one.count, 0);
        // should save series into reference object
    }
}

@end
