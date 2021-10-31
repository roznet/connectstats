//
//  GCTestsParsing.m
//  GarminConnect
//
//  Created by Brice Rosenzweig on 14/03/2015.
//  Copyright (c) 2015 Brice Rosenzweig. All rights reserved.
//

#import "GCTestCase.h"
#import "GCActivity+Database.h"
#import "GCActivity+Import.h"
#import "GCWeather.h"
#import "GCAppGlobal.h"
#import "GCGarminActivityDetailJsonParser.h"
#import "GCGarminRequestActivityReload.h"
#import "GCGarminActivityTrack13Request.h"
#import "GCGarminSearchModernJsonParser.h"
#import "GCGarminActivityLapsParser.h"
#import "GCGarminUserJsonParser.h"
#import "GCStravaActivityListParser.h"
#import "GCActivitiesOrganizer.h"
#import "GCHealthOrganizer.h"
#import "GCHealthZoneCalculator.h"
#import "GCActivitiesOrganizer.h"
#import "GCActivitiesOrganizerListRegister.h"
#import "GCService.h"
#import "GCFieldCache.h"
#import "GCActivityTypes.h"
#import "ConnectStats-Swift.h"
#import "GCTrackFieldChoices.h"
#import "GCTrackStats.h"
#import "GCGarminRequestModernActivityTypes.h"
#import "GCGarminRequestModernSearch.h"
#import "GCConnectStatsRequestSearch.h"
#import "GCConnectStatsRequestFitFile.h"
#import "GCLap.h"
#import "GCConnectStatsRequestSearch.h"
#import "GCHistoryFieldSummaryStats.h"
#import "GCActivity+TestBackwardCompat.h"
#import "GCActivity+TrackTransform.h"
#import "GCactivity+Series.h"
#import "GCHistoryFieldSummaryDataHolder.h"
#import "GCConnectStatsSearchJsonParser.h"

@interface GCTestsParsing : GCTestCase

@end

@implementation GCTestsParsing


- (void)setUp {
    [super setUp];
    
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark - Parse Single Activities


-(void)testActivityParsingModern{
    // Add test for
    NSArray * activityIds = @[
        @"217470507", // in samples/tcx: swimming, fit, json modern, tcx
        @"234721416", // in samples/tcx: cycling london commute 10k 2012, fit, json modern, tcx
        @"234979239", // in samples/tcx: running london commute 10k 2012, fit, json modern, tcx
        
        @"2477200414", // in activity_merge_fit: running, battersea, 2018, running power, fit, json modern, activitydb
        
        @"3988198230", // in flying: flying, modern json, contained in last_modern_search_flying.json
        
        @"1083407258", // in fit_files: cross country skiing 2016, modern json, fit
        @"2545022458", // in fit_files: running, 2018, running pwer from garmin, fit
    ];
    
    RZRegressionManager * manager = [RZRegressionManager managerForTestClass:[self class]];
    manager.recordMode = [GCTestCase recordModeGlobal];
    //manager.recordMode = true;
    
    NSSet<Class>*classes =[NSSet setWithObjects:[GCStatsDataSerieWithUnit class], nil];
    
    
    for (NSString * aId in activityIds) {
        dispatch_sync([GCAppGlobal worker], ^(){
            GCActivity * act = [GCGarminRequestActivityReload testForActivity:aId withFilesIn:[RZFileOrganizer bundleFilePath:nil forClass:[self class]]];
            // Disable thread so calculated fields are populated at once
            act.settings.worker = nil;
            [GCGarminActivityTrack13Request testForActivity:act withFilesIn:[RZFileOrganizer bundleFilePath:nil forClass:[self class]]];
            
            NSArray<GCField*>*fields = [act availableTrackFields];
            NSMutableArray<GCField*>*newFieds = [NSMutableArray array];
            for (GCField * field in fields) {
                NSError * error = nil;
                
                NSString * ident = [NSString stringWithFormat:@"%@_%@", aId, field.key];
                GCStatsDataSerieWithUnit * expected = [act timeSerieForField:field];
                GCStatsDataSerieWithUnit * retrieved = [manager retrieveReferenceObject:expected forClasses:classes selector:_cmd identifier:ident error:&error];
                if( retrieved == nil){
                    [newFieds addObject:field];
                }
                XCTAssertNotNil( retrieved, @"In activity %@, field %@ does not have saved reference point, maybe a new field?", act, field);
                XCTAssertNotEqual(expected.count, 0, @"%@[%@] has points",aId,field.key);
                XCTAssertEqualObjects(expected, retrieved, @"%@[%@]: %@<>%@", aId, field.key, expected, retrieved);
            }
            if( newFieds.count > 0){
                RZLog(RZLogInfo, @"%@ potential new fields %@", act, newFieds);
            }
        });
        
    }
}

-(void)testParseLapsSwimming{
    
    [[GCAppGlobal health] clearAllZones];
    
    // Swimming activity
    NSString * activityId = @"1027746730";//@"1378220136";
    
    NSString * dbfn = [NSString stringWithFormat:@"test_swimming_%@.db", activityId];
    [RZFileOrganizer removeEditableFile:dbfn];
    FMDatabase * db = [FMDatabase databaseWithPath:[RZFileOrganizer writeableFilePath:dbfn]];
    [db open];
    [GCActivitiesOrganizer ensureDbStructure:db];
    
    NSString * fn = [NSString stringWithFormat:@"activity_%@.json", activityId];
    NSData * data = [NSData dataWithContentsOfFile:[RZFileOrganizer bundleFilePath:fn forClass:[self class]] options:0 error:nil];
    
    NSDictionary * json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    GCActivity * modernAct = [[[GCActivity alloc] initWithId:activityId andGarminData:json] autorelease];
    modernAct.db = db;
    modernAct.trackdb = db;
    modernAct.settings.worker = nil;
    
    [GCGarminActivityTrack13Request testForActivity:modernAct withFilesIn:[RZFileOrganizer bundleFilePath:nil forClass:[self class]] mergeFit:false];
    [modernAct saveToDb:db];
    
    XCTAssertGreaterThan(modernAct.trackpoints.count, 1);
    BOOL recordMode = [GCTestCase recordModeGlobal];
    //recordMode = true;
    //[[modernAct exportCsv] writeToFile:[RZFileOrganizer writeableFilePath:@"t.csv"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [self compareStatsCheckSavedFor:modernAct identifier:@"modernAct" cmd:_cmd recordMode:recordMode];
}

-(void)testParseSaveAndReload{
    
    [[GCAppGlobal health] clearAllZones];
    
    BOOL saveDerived = [[GCAppGlobal profile] configGetBool:CONFIG_ENABLE_DERIVED defaultValue:[GCAppGlobal connectStatsVersion]];
    
    [[GCAppGlobal profile] configSet:CONFIG_ENABLE_DERIVED boolVal:false];
    NSArray<NSString*>*testActivityIds = @[
                                           @"1027746730", // Swim activity
                                           @"1378220136", // Running
                                           @"1382772474"  // Cycling
                                           ];
    
    for (NSString * activityId in testActivityIds) {
        
        NSString * dbfn = [NSString stringWithFormat:@"test_parse_reload_%@.db", activityId];
        [RZFileOrganizer removeEditableFile:dbfn];
        FMDatabase * db = [FMDatabase databaseWithPath:[RZFileOrganizer writeableFilePath:dbfn]];
        [db open];
        [GCActivitiesOrganizer ensureDbStructure:db];
        
        NSString * fn = [NSString stringWithFormat:@"activity_%@.json", activityId];
        NSData * data = [NSData dataWithContentsOfFile:[RZFileOrganizer bundleFilePath:fn forClass:[self class]] options:0 error:nil];
        
        NSDictionary * json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        GCActivity * parsedAct = [[[GCActivity alloc] initWithId:activityId andGarminData:json] autorelease];
        parsedAct.db = db;
        parsedAct.trackdb = db;
        parsedAct.settings.worker = nil;
        //[parsedAct.settings disableFiltersAndAdjustments];
        [GCGarminActivityTrack13Request testForActivity:parsedAct withFilesIn:[RZFileOrganizer bundleFilePath:nil forClass:[self class]] mergeFit:false];
        [parsedAct saveToDb:db];
        
        XCTAssertGreaterThan(parsedAct.trackpoints.count, 1);
        bool recordMode = [GCTestCase recordModeGlobal];
        //recordMode = true;
        
        NSString * identifier = [NSString stringWithFormat:@"parse_reload_%@", activityId];
        [self compareStatsCheckSavedFor:parsedAct identifier:identifier cmd:_cmd recordMode:recordMode];
        
        GCActivity * reloadedAct = [GCActivity activityWithId:activityId andDb:db];
        // disable threading so calculated value recalculated synchronously.
        reloadedAct.settings.worker = nil;
        //[reloadedAct.settings disableFiltersAndAdjustments];
        [reloadedAct trackpoints];
        
        NSDictionary * parsedDict = [self compareStatsDictFor:parsedAct];
        NSDictionary * reloadedDict = [self compareStatsDictFor:reloadedAct];
        
        // Check basics first
        XCTAssertEqual(parsedAct.trackpoints.count, reloadedAct.trackpoints.count);
        
        // Check basics first
        XCTAssertEqual(parsedAct.laps.count, reloadedAct.laps.count);
        
        [self compareStatsAssertEqual:reloadedDict andExpected:parsedDict withMessage:[NSString stringWithFormat:@"Check Reloaded activity %@", activityId]];
        
        XCTAssertEqual(reloadedAct.laps.count, parsedAct.laps.count, @"Lap count %@", activityId);
        
        for (NSUInteger idx=0; idx<MIN(parsedAct.laps.count,reloadedAct.laps.count); idx++) {
            
            if (parsedAct.garminSwimAlgorithm ) {
                GCLap * parsedLap = (GCLap*)parsedAct.laps[idx];
                GCLap * reloadedLap = (GCLap*)reloadedAct.laps[idx];
                
                XCTAssertEqualObjects(parsedLap.label, reloadedLap.label, @"Label %@/%@", parsedAct.activityId, @(parsedLap.lapIndex));
            }else{ // GCLap
                
            }
            
            if( [parsedAct.laps[idx] isKindOfClass:[GCTrackPoint class]]){
                GCTrackPoint * parsedPoint = (GCTrackPoint*)parsedAct.laps[idx];
                GCTrackPoint * reloadedPoint = (GCTrackPoint*)reloadedAct.laps[idx];
                
                // Check first or it will crash anyway...
                XCTAssertTrue([reloadedPoint isKindOfClass:[GCTrackPoint class]]);
                
                NSDictionary * diff = [parsedPoint.extra smartCompareDict:reloadedPoint.extra];
                XCTAssertNil(diff);
                
                NSArray<GCField*>*parsedFields = [parsedPoint availableFieldsInActivity:parsedAct];
                NSArray<GCField*>*reloadedFields = [reloadedPoint availableFieldsInActivity:reloadedAct];
                
                XCTAssertEqual(parsedFields.count, reloadedFields.count);
                
                XCTAssertEqualWithAccuracy(parsedPoint.distanceMeters, reloadedPoint.distanceMeters, 1.E-7);
            }
        }
    }
    [[GCAppGlobal profile] configSet:CONFIG_ENABLE_DERIVED boolVal:saveDerived];
}
-(void)testParseReloadAndCompare{
    NSData * searchModernInfo = [NSData dataWithContentsOfFile:[RZFileOrganizer bundleFilePath:@"activities_list_modern.json"
                                                                                      forClass:[self class]]];
    NSData * searchStravaInfo =[NSData dataWithContentsOfFile:[RZFileOrganizer bundleFilePath:@"last_strava_search_0.json"
                                                                                     forClass:[self class]]];
    
    GCGarminSearchModernJsonParser * modernParser = [[[GCGarminSearchModernJsonParser alloc] initWithData:searchModernInfo] autorelease];
    GCStravaActivityListParser * stravaListParser = [GCStravaActivityListParser activityListParser:searchStravaInfo];
    
    GCActivitiesOrganizer * organizer = [self createEmptyOrganizer:@"test_organizer_parse_reload.db"];
    GCService * serviceGarmin = [GCService service:gcServiceGarmin];
    
    GCActivitiesOrganizerListRegister * listregisterGarmin =[GCActivitiesOrganizerListRegister activitiesOrganizerListRegister:modernParser.activities from:serviceGarmin isFirst:YES];
    [listregisterGarmin addToOrganizer:organizer];
    
    GCService * serviceStrava = [GCService service:gcServiceStrava];
    GCActivitiesOrganizerListRegister * listregisterStrava =[GCActivitiesOrganizerListRegister activitiesOrganizerListRegister:stravaListParser.activities from:serviceStrava isFirst:YES];
    [listregisterStrava addToOrganizer:organizer];
    
    GCActivitiesOrganizer * reload = [[GCActivitiesOrganizer alloc] initTestModeWithDb:organizer.db];
    
    XCTAssertEqual(organizer.activities.count, reload.activities.count, @"reloaded same number of activities");
    
    for (GCActivity * original in organizer.activities) {
        GCActivity * reloaded = [reload activityForId:original.activityId];
        XCTAssertNotNil(reloaded);
        XCTAssertTrue([reloaded isEqualToActivity:original], @"reloaded activity match %@", reloaded.activityId);
    }
}

-(void)testParseAndCompare{
    NSData * searchConnectStatsInfo = [NSData dataWithContentsOfFile:[RZFileOrganizer bundleFilePath:@"last_connectstats_search_0.json"
                                                                                       forClass:[self class]]];
    NSData * searchModernInfo = [NSData dataWithContentsOfFile:[RZFileOrganizer bundleFilePath:@"last_modern_search_0.json"
                                                                                      forClass:[self class]]];
    NSData * searchStravaInfo =[NSData dataWithContentsOfFile:[RZFileOrganizer bundleFilePath:@"last_strava_search_0.json"
                                                                                     forClass:[self class]]];
    
    GCConnectStatsSearchJsonParser * connectStatsParser= [[[GCConnectStatsSearchJsonParser alloc] initWithData:searchConnectStatsInfo] autorelease];
    GCGarminSearchModernJsonParser * modernParser = [[[GCGarminSearchModernJsonParser alloc] initWithData:searchModernInfo] autorelease];
    GCStravaActivityListParser * stravaListParser = [GCStravaActivityListParser activityListParser:searchStravaInfo];
    
    NSUInteger commonConnectStats = 0;
    NSUInteger commonStrava = 0;
    for (GCActivity * garminAct in modernParser.activities) {
        NSString * activityId = garminAct.activityId;
        
        GCActivity * stravaAct = [self findActivityId:activityId in:stravaListParser.activities];
        GCActivity * connectStatsAct = [self findActivityId:activityId in:connectStatsParser.activities];
        
        NSDictionary * connectStatsTolerance = @{};
        
        
        NSDictionary * stravaModernTolerance = @{
            // Reported by Strava but not garmin
            @"WeightedMeanAirTemperature": @"SKIP",
            @"SumTotalWork": @"SKIP",
            @"WeightedMeanPower": @"SKIP"
        };
        
        if( connectStatsAct ){
            [self compareActivitySummaryIn:connectStatsAct and:garminAct tolerance:connectStatsTolerance message:@"connectstats==garmin"];
            commonConnectStats += 1;
        }
        if( stravaAct ){
            [self compareActivitySummaryIn:stravaAct and:garminAct tolerance:stravaModernTolerance message:@"strava==connectstats"];
            commonStrava += 1;
        }
    }
    XCTAssertGreaterThan(commonStrava, 0);
    XCTAssertGreaterThan(commonConnectStats, 0);
}

-(void)testParseTCX{
    NSArray<NSString*>*samples = @[
        @"234979239", // running
        @"234721416", // cycling
        //@"217470507", // swimming
    ];
   
    for (NSString * activityId in samples) {
        NSString * activityId_tcx = [activityId stringByAppendingString:@"tcx"];
        NSString * activityId_fit = [activityId stringByAppendingString:@"fit"];
        
        GCActivity * act_tcx = [GCGarminRequestActivityReload testForActivity:activityId withFilesIn:[RZFileOrganizer bundleFilePath:nil forClass:[self class]]];
        act_tcx.activityId = activityId_tcx;
        act_tcx.db = act_tcx.trackdb;
        act_tcx.settings.worker = nil;
        [GCActivity ensureDbStructure:act_tcx.db];
        GCActivity * act_fit = [GCGarminRequestActivityReload testForActivity:activityId withFilesIn:[RZFileOrganizer bundleFilePath:nil forClass:[self class]]];
        act_fit.activityId = activityId_fit;
        act_fit.db = act_fit.trackdb;
        act_fit.settings.worker = nil;
        [GCActivity ensureDbStructure:act_fit.db];
        NSString * tcx = [NSString stringWithFormat:@"activity_%@.tcx", activityId];
        NSString * fit = [NSString stringWithFormat:@"activity_%@.fit", activityId];
        NSString * fp_tcx = [RZFileOrganizer bundleFilePath:tcx forClass:[self class]];
        NSString * fp_fit = [RZFileOrganizer bundleFilePath:fit forClass:[self class]];
        
        act_fit = [GCConnectStatsRequestFitFile testForActivity:act_fit withFilesIn:fp_fit];
        act_tcx = [GCConnectStatsRequestFitFile testForActivity:act_tcx withFilesIn:fp_tcx];

        XCTAssertEqualObjects(act_fit.date, act_tcx.date);
        XCTAssertEqual(act_fit.trackpoints.count, act_tcx.trackpoints.count);
        XCTAssertTrue(RZTestOption(act_tcx.flags, gcFieldFlagSumDistance));
        XCTAssertTrue(RZTestOption(act_tcx.flags, gcFieldFlagSumDuration));
        XCTAssertTrue(RZTestOption(act_tcx.flags, gcFieldFlagWeightedMeanSpeed));
    }
    
}

-(void)testParseFitFile{
    NSDictionary * epsForField = @{
                                   // somehow some non sensical values:
                                   @"MaxRunCadence": @(1.5),
                                   @"MaxSpeed":@(0.0001),
                                   @"MaxPace":@(0.0001),
                                   @"MinAirTemperature":@(50),
                                   @"MinHeartRate":@(100),
                                   @"MinSpeed":@(0.5),
                                   @"MinPace":@(0.5),
                                   @"SumDuration": @(125),
                                   //@"SumDuration":@(0.02),
                                   @"SumElapsedDuration": @(125),
                                   //@"SumElapsedDuration": @(124.8420000000001),
                                   @"SumEnergy": @(1.),
                                   @"WeightedMeanAirTemperature": @(0.1),
                                   @"WeightedMeanGroundContactTime": @(5.0),
                                   @"WeightedMeanPace": @(0.3260718057400382),
                                   @"WeightedMeanRunCadence": @(0.7834375),
                                   @"WeightedMeanVerticalOscillation": @(3.051757833105739e-06),
                                   @"WeightedMeanVerticalRatio": @(0.1),
                                   
                                   };
    
    NSDictionary * expectedMissingFromFit = @{
                                              @"WeightedMeanVerticalRatio": @"8.84 %",
                                              @"DirectVO2Max": @"40.0 ml/kg/min",
                                              @"GainCorrectedElevation": @"844 m",
                                              @"GainUncorrectedElevation": @"861 m",
                                              @"LossUncorrectedElevation": @"0.0 cm",
                                              @"MaxAirTemperature": @"30 °C",
                                              @"MaxCorrectedElevation": @"2.37 km",
                                              @"MaxElevation": @"2.38 km",
                                              @"MaxPace": @"07:31 min/km",
                                              @"MaxUncorrectedElevation": @"2.38 km",
                                              @"MinAirTemperature": @"21 °C",
                                              @"MinCorrectedElevation": @"1.53 km",
                                              @"MinElevation": @"1.52 km",
                                              @"MinHeartRate": @"92 bpm",
                                              @"MinSpeed": @"0.3 km/h",
                                              @"MinUncorrectedElevation": @"1.52 km",
                                              @"SumMovingDuration": @"01:28:07",
                                              @"SumStep": @"3,834 s",
                                              @"WeightedMeanAirTemperature": @"26 °C",
                                              @"WeightedMeanFractionalCadence": @"1 rpm",
                                              @"WeightedMeanMovingPace": @"18:56 min/km",
                                              @"WeightedMeanMovingSpeed": @"3.2 km/h",
                                              @"WeightedMeanPace": @"20:14 min/km",
                                              
                                              @"WeightedMeanStrideLength": @"1 m",
                                              @"DirectLactateThresholdHeartRate": @"180 bpm",
                                              @"WeightedMeanGroundContactBalanceLeft": @"49.2 %",
                                              @"DirectLactateThresholdSpeed": @"3.5 mps",
                                              @"MinVerticalRatio": @"2",
                                              @"MaxVerticalRatio": @"41",
                                              @"MaxGroundContactBalanceLeft": @"54",
                                              @"MinGroundContactBalanceLeft": @"24",
                                              
                                              
                                              };
    
    NSDictionary * expectedMissingFromGC = @{
                                             @"MaxCadence":@2,
                                             @"MaxElevation":@6,// elevation is all messed up (elevation correction)
                                             @"MaxFormPower": @1,
                                             @"MaxFractionalCadence": @1,
                                             @"MaxGroundContactTime": @1,
                                             @"MaxLegSpringStiffness": @1,
                                             @"MaxPower": @1,
                                             @"MaxVerticalOscillation": @1,
                                             @"MinCadence":@4,
                                             @"MinElevation":@5,
                                             @"MinFormPower": @1,
                                             @"MinGroundContactTime": @1,
                                             @"MinHeartRate": @1,
                                             @"MinLegSpringStiffness": @1,
                                             @"MinPower": @1,
                                             @"MinRunCadence": @1,
                                             @"MinSpeed": @1,
                                             @"MinPace" : @1,
                                             @"MinVerticalOscillation": @1,
                                             @"StanceTimePercent": @1,
                                             @"WeightedMeanCadence":@1,
                                             @"WeightedMeanElevation":@3,
                                             @"WeightedMeanFormPower": @1,
                                             @"WeightedMeanFractionalCadence": @1,
                                             @"WeightedMeanLegSpringStiffness": @1,
                                             @"WeightedMeanPower": @1,
                                             @"WeightedMeanStanceTime": @1,
                                             @"WeightedMeanStanceTimeBalance": @1,
                                             @"WeightedMeanStanceTimePercent": @1,
                                             @"avg_step_length":@9,
                                             @"enhanced_max_speed":@8,
                                             @"total_cycles":@7,
                                             @"message_index":@9,
                                             @"NumLaps":@9,
                                             @"FirstLapIndex": @1,
                                             
                                             };
    
    /* Re-base:
     *   
     */
    NSArray<NSString*>*aIds = @[ @"1083407258", // Ski Activity
                                 @"2477200414", // Run with Power
                                 ];
    
    NSString * dbn_fit = @"test_activity_fit_merge.db";
    NSString * dbn_nofit = @"test_activity_nofit_merge.db";
    
    [RZFileOrganizer removeEditableFile:dbn_fit];
    [RZFileOrganizer removeEditableFile:dbn_nofit];
    
    FMDatabase * db_fit = [FMDatabase databaseWithPath:[RZFileOrganizer writeableFilePath:dbn_fit]];
    [db_fit open];
    [GCActivitiesOrganizer ensureDbStructure:db_fit];
    
    FMDatabase * db_nofit = [FMDatabase databaseWithPath:[RZFileOrganizer writeableFilePath:dbn_nofit]];
    [db_nofit open];
    [GCActivitiesOrganizer ensureDbStructure:db_nofit];
    
    [GCAppGlobal configSet:CONFIG_GARMIN_FIT_MERGE boolVal:FALSE];
    for (NSString * aId in aIds) {
        GCActivity * act = [GCGarminRequestActivityReload testForActivity:aId withFilesIn:[RZFileOrganizer bundleFilePath:nil forClass:[self class]]];
        act.db = db_nofit;
        act.trackdb = db_nofit;
        act.settings.worker = nil;// sync calculated fields
        [act saveToDb:db_nofit];
        [GCGarminActivityTrack13Request testForActivity:act withFilesIn:[RZFileOrganizer bundleFilePath:nil forClass:[self class]]];
        
        GCActivity * actMerge = [GCGarminRequestActivityReload testForActivity:aId withFilesIn:[RZFileOrganizer bundleFilePath:nil forClass:[self class]]];
        actMerge.db = db_fit;
        actMerge.trackdb = db_fit;
        actMerge.settings.worker = nil;
        [actMerge saveToDb:db_fit];
        [GCGarminActivityTrack13Request testForActivity:actMerge withFilesIn:[RZFileOrganizer bundleFilePath:nil forClass:[self class]] mergeFit:TRUE];
        [actMerge saveToDb:db_fit];
        
        GCActivity * actMergeReload = [GCActivity activityWithId:aId andDb:db_fit];
        actMergeReload.settings.worker = nil;
        [actMergeReload trackpoints]; // force load trackpoints
        
        NSString * fn = [RZFileOrganizer bundleFilePath:[NSString stringWithFormat:@"activity_%@.fit", aId] forClass:[self class]];
        
        GCActivity * fitAct = [[GCActivity alloc] initWithId:aId fitFilePath:fn startTime:[NSDate date]];
        
        // All trackfield fields merged
        for (GCField * one in act.availableTrackFields) {
            XCTAssertTrue([actMergeReload.availableTrackFields containsObject:one], @"%@ in merge reload %@", one, aId);
            XCTAssertTrue([actMerge.availableTrackFields containsObject:one], @"%@ in merge %@", one, aId);
        }
        for (GCField * one in fitAct.availableTrackFields) {
            BOOL found = [actMergeReload.availableTrackFields containsObject:one];
            if( ! found && one.correspondingPaceOrSpeedField){
                found = [actMergeReload.availableTrackFields containsObject:one.correspondingPaceOrSpeedField];
            }
            XCTAssertTrue(found, @"%@ in merge reload %@", one, aId);
            
            found = [actMerge.availableTrackFields containsObject:one];
            if( ! found && one.correspondingPaceOrSpeedField){
                found = [actMerge.availableTrackFields containsObject:one.correspondingPaceOrSpeedField];
            }
            XCTAssertTrue(found, @"%@ in merge %@", one, aId);
        }
        
        NSDictionary * sum_gc = act.summaryData;
        NSDictionary * sum_fit= fitAct.summaryData;
        NSDictionary * sum_merge= actMerge.summaryData;
        NSDictionary * sum_reload= actMergeReload.summaryData;
        
        NSMutableArray * recordMissing = [NSMutableArray array];
        NSMutableArray * recordEpsilon = [NSMutableArray array];
        
        for (GCField * field in sum_fit) {
            GCActivitySummaryValue * v_fit= sum_fit[field];
            GCActivitySummaryValue * v_merge=sum_merge[field];
            GCActivitySummaryValue * v_reload=sum_reload[field];
            
            // Everything in fit should be in merge and reload
            XCTAssertNotNil(v_merge);
            XCTAssertNotNil(v_reload);
            
            // SOme won't be in gc, then skip
            if( expectedMissingFromGC[field.key] != nil){
                continue;// Somehow missing from gc
            }
            GCActivitySummaryValue * v_gc = sum_gc[field];
            if( v_gc == nil && field.correspondingPaceOrSpeedField ){
                v_gc = sum_gc[field.correspondingPaceOrSpeedField];
            }
            double eps =  1.e-7;
            NSNumber * specialEps = epsForField[field.key];
            if (specialEps) {
                eps = specialEps.doubleValue;
            }
            
            if( v_gc == nil ){
                [recordMissing addObject:[NSString stringWithFormat:@" @\"%@\": @1", field.key]];
            }
            if( [v_gc.numberWithUnit compare:v_fit.numberWithUnit withTolerance:eps] != NSOrderedSame ){
                GCNumberWithUnit * diff = [v_gc.numberWithUnit addNumberWithUnit:v_fit.numberWithUnit weight:-1.0];
                
                [recordEpsilon addObject:[NSString stringWithFormat:@" @\"%@\": @(%@)", field.key, @(diff.value)]];
            }
            XCTAssertNotNil(v_gc, @"Found field %@", field);
            if( [aId isEqualToString:@"2477200414"] && [field.key hasSuffix:@"Cadence"]){
                NSLog(@"%@ %@ %@", aId, v_gc, v_fit);
            }
            if( v_gc ){
                XCTAssertTrue([v_gc.numberWithUnit compare:v_fit.numberWithUnit withTolerance:eps] == NSOrderedSame,
                              @"Key %@: %@ == %@ within %@", field, v_gc.numberWithUnit, v_fit.numberWithUnit, @(eps));
            }
        }
        if( recordEpsilon.count > 0){
            for (NSString * one in recordEpsilon) {
                NSLog(@"%@,", one);
            }
        }
        if( recordMissing.count > 0){
            for (NSString * one in recordMissing) {
                NSLog(@"%@,", one);
            }
        }
        [recordMissing removeAllObjects];
        for (GCField * field in sum_gc) {
            // everything should be in reload and merge
            XCTAssertNotNil(sum_reload[field]);
            XCTAssertNotNil(sum_merge[field]);
            
            GCActivitySummaryValue * v_gc = sum_gc[field];
            GCActivitySummaryValue * v_fit= sum_fit[field];
            if( v_fit == nil && field.correspondingPaceOrSpeedField){
                v_fit = sum_fit[field.correspondingPaceOrSpeedField];
            }
            
            if( v_fit == nil && expectedMissingFromFit[field.key] == nil){
                [recordMissing addObject:[NSString stringWithFormat:@"@\"%@\": @\"%@\"", field.key, v_gc.numberWithUnit]];
            }
            XCTAssertTrue(v_fit != nil || expectedMissingFromFit[field.key]!=nil, @"%@ %@ unexpectedly missing", field, v_gc);
        }
        if(recordMissing.count > 0){
            for (NSString * one in recordMissing) {
                NSLog(@"%@,", one);
            }
        }
    }
}
-(void)testParseConnectIQFields{
    
    NSDictionary * defs = @{
                            @"2477200414": @[ @"WeightedMeanPower"],  // Stryd Fields
                            @"2545022458": @[ @"WeightedMeanPower"],  // Garmin power fields;
                            };
    
    for (NSString * aId in defs) {
        GCActivity * act = [GCGarminRequestActivityReload testForActivity:aId withFilesIn:[RZFileOrganizer bundleFilePath:nil forClass:[self class]]];
        [GCGarminActivityTrack13Request testForActivity:act withFilesIn:[RZFileOrganizer bundleFilePath:nil forClass:[self class]]];
        
        NSArray * expectedKeys = defs[aId];
        for (NSString * fieldKey in expectedKeys) {
            XCTAssertTrue([act.availableTrackFields containsObject:[GCField fieldForKey:fieldKey andActivityType:act.activityType]], @"got field %@ for %@", fieldKey, aId);
            
            if ([fieldKey isEqualToString:@"WeightedMeanPower"]){
                // special case, check power was added to lap
                for (GCLap * lap in act.laps) {
                    XCTAssertTrue((lap.trackFlags & gcFieldFlagPower) == gcFieldFlagPower, @"power was added back");
                }
            }
        }
    }
}

-(void)testMultiSportAndSwimfitFile{
    //GCActivity * act = [GCActivity activityWithId]
}

#pragma mark - Test non activities

-(void)testParsingWeather{
    [RZFileOrganizer removeEditableFile:@"test_newweather.db"];
    FMDatabase * newdb = [FMDatabase databaseWithPath:[RZFileOrganizer writeableFilePath:@"test_newweather.db"]];
    [newdb open];
    [GCActivity ensureDbStructure:newdb];
    [GCWeather ensureDbStructure:newdb];
    
    NSArray * files = @[ @"weather_cs_2288.json", // multi sources/new format
                         @"weather_cs_4646.json"  // darkSky only/old format
    ];
    NSError * err = nil;
    NSMutableDictionary * rv = [NSMutableDictionary dictionary];
    for (NSString * fn in files) {
        NSData * jsonData = [NSData dataWithContentsOfFile:[RZFileOrganizer bundleFilePath:fn forClass:[self class]]];
        NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
        NSArray * dataArray = json[@"weather"];
        // change later
        for (NSDictionary * weatherData in dataArray) {
            for (NSString * provider in @[ kGCWeatherProviderDarkSky, kGCWeatherProviderVisualCrossing, kGCWeatherProviderOpenWeatherMap] ) {
                NSString * aId = weatherData[@"file_id"];
                if (![aId isKindOfClass:[NSNull class]]) {
                    aId = [aId.description stringByAppendingString:provider];
                    GCWeather * weatherNew = [GCWeather weatherWithData:weatherData preferredProvider:@[ provider, kGCWeatherProviderDarkSky ] ];
                    rv[aId] = weatherNew.description;
                    [weatherNew saveToDb:newdb forActivityId:aId];

                }
            }
        }
    }
    RZRegressionManager * manager = [RZRegressionManager managerForTestClass:[self class]];
    manager.recordMode = [GCTestCase recordModeGlobal];
    //manager.recordMode = true;
    
    NSError * error = nil;
    NSSet<Class>*classes = [NSSet setWithObjects:[NSDictionary class], nil];

    NSDictionary * expected = [manager retrieveReferenceObject:rv forClasses:classes selector:_cmd identifier:@"parsed weather" error:&error];
    XCTAssertEqualObjects(expected, rv);
    
    
    /*
    FMResultSet * res = [newdb executeQuery:@"SELECT * FROM gc_activities_weather_detail"];
    NSUInteger count = 0;
    while ([res next]) {
        count++;
        GCWeather * weatherNew = [GCWeather weatherWithResultSet:res];
        NSString * aId = [res stringForColumn:@"activityId"];
        GCWeather * weatherOld = [GCWeather weatherWithData:data[aId]];
        if (weatherOld) {
            NSString * tempnew = [NSString stringWithFormat:@"%.0f℃", [weatherNew.temperature value] ];
            NSString * tempold = [weatherOld weatherDisplayField:GC_WEATHER_TEMPERATURE];
            if (tempold) {
                XCTAssertEqualObjects(tempnew, tempold );
            }
        }
    }
    XCTAssertEqual(count, found.count);
     */
}

-(void)testParseActivityTypes{
    
    GCActivityTypes * types = [GCActivityTypes activityTypes];
    XCTAssertEqualObjects([types activityTypeForKey:GC_TYPE_CYCLING], [types activityTypeForStravaType:@"Ride"]);
    
    // Build incomplete activity types, from old download file
    
    types = [[[GCActivityTypes alloc] init] autorelease];
    NSString * path = [RZFileOrganizer bundleFilePath:nil forClass:[self class]];
    NSError * err = nil;
    
    NSData * jsonData = [NSData dataWithContentsOfFile:[path stringByAppendingPathComponent:@"modern_activity_types.json"]];
    NSArray * modern = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    
    // legacy is more recent, but it's fine, just use for display info
    jsonData = [NSData dataWithContentsOfFile:[path stringByAppendingPathComponent:@"activity_types.json"]];
    NSArray * legacy = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err][@"dictionary"];
    
    [types loadMissingFromGarmin:modern withDisplayInfoFrom:legacy];
    NSUInteger n = types.allTypes.count;
    
    [GCGarminRequestModernActivityTypes testWithFilesIn:path forTypes:types];
    
    XCTAssertGreaterThan(types.allTypes.count, n, @"Got more types");
    XCTAssertGreaterThanOrEqual(types.allTypes.count, modern.count); // registered all new types
}

#pragma mark - Parse List and Search results

-(void)testParseSearch{
    GCActivitiesOrganizer * organizer = [self createEmptyOrganizer:@"test_parsingsearch.db"];
    
    [GCGarminRequestModernSearch testForOrganizer:organizer withFilesInPath:[RZFileOrganizer bundleFilePath:nil forClass:[self class]]];
    
    GCField * hf = [GCHealthMeasure weight];
    
    GCField * hrField = [GCField fieldForFlag:gcFieldFlagWeightedMeanHeartRate andActivityType:GC_TYPE_ALL];
    GCField * paceField = [GCField fieldForKey:@"WeightedMeanPace" andActivityType:GC_TYPE_ALL];
    
    NSDictionary * rv = [organizer fieldsSeries:@[ hrField, paceField, hf] matching:nil useFiltered:NO ignoreMode:gcIgnoreModeActivityFocus];
    
    RZRegressionManager * manager = [RZRegressionManager managerForTestClass:[self class]];
    manager.recordMode = [GCTestCase recordModeGlobal];
    //manager.recordMode = true;
    
    NSError * error = nil;
    NSSet<Class>*classes = [NSSet setWithObjects:[NSDictionary class], [GCField class], [GCStatsDataSerieWithUnit class], nil];
    
    NSDictionary * expected = [manager retrieveReferenceObject:rv forClasses:classes selector:_cmd identifier:@"timeSeries" error:&error];
    XCTAssertEqual(expected.count, rv.count);
    for (GCField * key in expected) {
        GCStatsDataSerieWithUnit * exp_serie = expected[key];
        GCStatsDataSerieWithUnit * got_serie = rv[key];
        XCTAssertNotNil(got_serie, @"key %@", key);
        if (got_serie) {
            XCTAssertEqualObjects(exp_serie, got_serie, @"Key %@", key);
        }
    }
}

-(void)testParseSearchFlying{
    GCActivitiesOrganizer * organizer = [self createEmptyOrganizer:@"test_parsing_flying.db"];
    NSString * flying = [RZFileOrganizer bundleFilePath:@"last_modern_search_flying.json" forClass:[self class]];
    [GCGarminRequestModernSearch testForOrganizer:organizer withFilesInPath:flying];
    
    XCTAssertNotNil([organizer activityForId:@"3988198230"]);
    XCTAssertFalse([organizer activityForId:@"3988198230"].garminSwimAlgorithm);

}

-(void)testOrganizerSkipAlways{
    GCActivitiesOrganizer * organizer = [self createEmptyOrganizer:@"test_skipalways.db"];
    
    [GCGarminRequestModernSearch testForOrganizer:organizer withFilesInPath:[RZFileOrganizer bundleFilePath:nil forClass:[self class]]];
    
    GCField * distField = [GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:GC_TYPE_ALL];
    
    [organizer fieldsSeries:@[distField] matching:nil useFiltered:false ignoreMode:gcIgnoreModeActivityFocus];
    
    GCActivity * first = [organizer activityForIndex:0];
    NSString * activityType = first.activityType;
    GCNumberWithUnit * dist = [first numberWithUnitForField:[GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:activityType]];
    
    GCHistoryFieldSummaryStats * start_stats = [GCHistoryFieldSummaryStats fieldStatsWithActivities:organizer.activities activityTypeSelection:nil referenceDate:nil ignoreMode:gcIgnoreModeActivityFocus];
    GCNumberWithUnit * start_nu = [[start_stats dataForField:[GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:activityType]] weightedSumWithUnit:gcHistoryStatsAll];
    
    first.skipAlways = true;
    [first saveToDb:organizer.db];
    
    GCHistoryFieldSummaryStats * skip_stats = [GCHistoryFieldSummaryStats fieldStatsWithActivities:organizer.activities activityTypeSelection:nil referenceDate:nil ignoreMode:gcIgnoreModeActivityFocus];
    GCNumberWithUnit * skip_nu = [[skip_stats dataForField:[GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:activityType]] weightedSumWithUnit:gcHistoryStatsAll];

    GCActivitiesOrganizer * reload = [[[GCActivitiesOrganizer alloc] initTestModeWithDb:organizer.db] autorelease];

    GCHistoryFieldSummaryStats * reload_stats = [GCHistoryFieldSummaryStats fieldStatsWithActivities:reload.activities activityTypeSelection:nil referenceDate:nil ignoreMode:gcIgnoreModeActivityFocus];
    GCNumberWithUnit * reload_nu = [[reload_stats dataForField:[GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:activityType]] weightedSumWithUnit:gcHistoryStatsAll];

    first.skipAlways = false;
    
    GCHistoryFieldSummaryStats * unskip_stats = [GCHistoryFieldSummaryStats fieldStatsWithActivities:organizer.activities activityTypeSelection:nil referenceDate:nil ignoreMode:gcIgnoreModeActivityFocus];
    GCNumberWithUnit * unskip_nu = [[unskip_stats dataForField:[GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:activityType]] weightedSumWithUnit:gcHistoryStatsAll];

    
    XCTAssertEqualWithAccuracy(start_nu.value, [skip_nu addNumberWithUnit:dist weight:1.0].value, 1.e-7);
    XCTAssertEqualWithAccuracy(reload_nu.value, skip_nu.value, 1.e-7);
    XCTAssertEqualWithAccuracy(start_nu.value, unskip_nu.value, 1.e-7);

}

-(void)testOrganizerGarminAllSourcesMergeAndReload{
    NSString * bundlePath = [RZFileOrganizer bundleFilePath:nil forClass:[self class]];
    NSUInteger idx = 0;
    NSUInteger metaCount = 0;
    
    GCActivity * act_cs = nil;
    GCActivity * act_garmin = nil;
    GCActivity * act_reload = nil;
    
    GCActivitiesOrganizer * organizer_garmin = [self createEmptyOrganizer:@"test_parsing_cs_merge_garmin_dup_save.db"];
    GCActivitiesOrganizer * organizer_cs_garmin = [self createEmptyOrganizer:@"test_parsing_cs_merge_garmin.db"];

    // Real Life Garmin All setup:
    // first cs
    [GCConnectStatsRequestSearch testForOrganizer:organizer_cs_garmin withFilesInPath:bundlePath];
    idx = 0;
    act_cs = [organizer_cs_garmin activityForIndex:idx];
    XCTAssertEqualObjects(act_cs.activityName, @"", @"Starts without name");
    metaCount = act_cs.metaData.count;
    XCTAssertEqual(metaCount, 3);
    
    // then garmin to get extra fields
    [GCGarminRequestModernSearch testForOrganizer:organizer_cs_garmin withFilesInPath:bundlePath];
    [GCGarminRequestModernSearch testForOrganizer:organizer_garmin withFilesInPath:bundlePath];
    
    GCActivitiesOrganizer * organizer_reload = RZReturnAutorelease([[GCActivitiesOrganizer alloc] initTestModeWithDb:organizer_cs_garmin.db]);

    
    idx = 0;
    act_cs = [organizer_cs_garmin activityForIndex:idx];
    act_garmin = [organizer_garmin activityForIndex:idx];
    act_reload = [organizer_reload activityForIndex:idx];
    
    XCTAssertNotEqualObjects(act_cs.activityName, @"");
    XCTAssertEqualObjects(act_cs.activityName, act_garmin.activityName);
    XCTAssertEqualObjects(act_reload.activityName, act_garmin.activityName);
    
    XCTAssertGreaterThanOrEqual(act_cs.metaData.count, act_garmin.metaData.count);
    XCTAssertEqual(act_cs.metaData.count, act_reload.metaData.count);
    
    XCTAssertFalse([act_cs updateMissingFromActivity:act_garmin], @"Update missing does not find anything new");
    
    // Now load with deleted and edited
    NSUInteger garminStartCount = organizer_garmin.countOfActivities;
    NSUInteger mergeStartCount  = organizer_cs_garmin.countOfActivities;
    XCTAssertEqual(mergeStartCount, garminStartCount);
    
    XCTestExpectation * expectation = RZReturnAutorelease([[XCTestExpectation alloc] initWithDescription:@"Run on worker"]);
    
    dispatch_async([GCAppGlobal worker], ^(){
        [GCGarminRequestModernSearch testForOrganizer:organizer_cs_garmin withFilesInPath:[RZFileOrganizer bundleFilePath:@"last_modern_search_0_changes.json" forClass:[self class]]];
        [GCGarminRequestModernSearch testForOrganizer:organizer_garmin withFilesInPath:[RZFileOrganizer bundleFilePath:@"last_modern_search_0_changes.json" forClass:[self class]]];
        
        XCTAssertEqual(mergeStartCount, organizer_cs_garmin.countOfActivities+1);
        XCTAssertEqual(garminStartCount, organizer_garmin.countOfActivities+1);
        [expectation fulfill];
    });

    [self waitForExpectations:@[ expectation] timeout:10.0];
}

-(void)testOrganizerMergeServices{
    // To re-create setup for this test:
    //   copy
    //
    
    NSString * bundlePath = [RZFileOrganizer bundleFilePath:nil forClass:[self class]];
    
    // Don't pro
    [[GCAppGlobal profile] configSet:CONFIG_SYNC_WITH_PREFERRED boolVal:false];
    
    GCActivitiesOrganizer * organizer = [self createEmptyOrganizer:@"test_parsing_modern_merge.db"];
    GCActivitiesOrganizer * organizer_strava = [self createEmptyOrganizer:@"test_parsing_modern_merge_strava.db"];
    GCActivitiesOrganizer * organizer_garmin = [self createEmptyOrganizer:@"test_parsing_modern_merge_garmin.db"];
    GCActivitiesOrganizer * organizer_cs = [self createEmptyOrganizer:@"test_parsing_modern_merge_cs.db"];

    // Garmin Cycling: 3726595228  -> __strava__2432750438
    // Garmin Running: 3743031453  -> __strava__2446347224
    // In Garmin not in strava
    //     @"3560921097",
    //     @"3560919931",
    //     @"3560919337",
    //     @"3560918864",

    NSData * data = [NSData dataWithContentsOfFile:[RZFileOrganizer bundleFilePath:@"services_activities.json" forClass:[self class]]
                                           options:0 error:nil];
    NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    NSArray * running_ids = [[dict[@"types"][@"running"] allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSArray * cycling_ids = [[dict[@"types"][@"cycling"] allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    NSString * runGarminId = running_ids[0];
    NSString * bikeGarminId = cycling_ids[0];
    
    NSArray * running_dup = [[dict[@"duplicates"][runGarminId] allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSArray * cycling_dup = [[dict[@"duplicates"][bikeGarminId] allKeys] sortedArrayUsingSelector:@selector(compare:)];

    //NSString * runConnectId = running_dup[0];
    NSString * runStravaId = running_dup[1];
    
    //NSString * bikeConnectId = cycling_dup[0];
    NSString * bikeStravaId = cycling_dup[1];
    
    NSUInteger addedActivities = 0;
    
    // First add garmin
    [GCGarminRequestModernSearch testForOrganizer:organizer withFilesInPath:bundlePath];
    [GCGarminRequestModernSearch testForOrganizer:organizer_garmin withFilesInPath:bundlePath];

    // Count activities from garmin as it will only remove duplicate/overlapping
    addedActivities += organizer_garmin.countOfActivities;
    // Make sure all added in garmin is total minues overlapping
    XCTAssertEqual(organizer_garmin.countOfActivities, 20-organizer_garmin.countOfKnownDuplicates);
    XCTAssertEqual(organizer.countOfActivities, organizer_garmin.countOfActivities);

    XCTAssertNotNil([organizer activityForId:runGarminId]);
    XCTAssertNotNil([organizer activityForId:bikeGarminId]);

    // then add strava
    [GCStravaRequestActivityList testWithOrganizer:organizer path:bundlePath];
    [GCStravaRequestActivityList testWithOrganizer:organizer_strava path:bundlePath];
    
    // added extra 10 from strava
    // Note that strava already eliminate time overlapping, so should
    // get 30
    XCTAssertEqual(organizer.countOfActivities, 30);
    XCTAssertEqual(organizer_strava.countOfActivities, 30); // all should be added
    XCTAssertNotNil([organizer activityForId:runGarminId]);
    XCTAssertNotNil([organizer activityForId:bikeGarminId]);
    XCTAssertNil([organizer activityForId:runStravaId]);
    XCTAssertNil([organizer activityForId:bikeStravaId]);
    XCTAssertNotNil([organizer_strava activityForId:runStravaId]);
    XCTAssertNotNil([organizer_strava activityForId:bikeStravaId]);
    XCTAssertTrue([organizer isKnownDuplicate:[organizer_strava activityForId:runStravaId]]);
    XCTAssertTrue([organizer isKnownDuplicate:[organizer_strava activityForId:bikeStravaId]]);
    
    // Add Connectstats
    [GCConnectStatsRequestSearch testForOrganizer:organizer_cs withFilesInPath:bundlePath];
    XCTAssertEqual(organizer_cs.countOfActivities, 20-organizer_cs.countOfKnownDuplicates);
    [GCConnectStatsRequestSearch testForOrganizer:organizer_cs withFilesInPath:bundlePath start:20];
    XCTAssertEqual(organizer_cs.countOfActivities, 40-organizer_cs.countOfKnownDuplicates);
    
    
    [GCGarminRequestModernSearch testForOrganizer:organizer withFilesInPath:bundlePath start:20];
    [GCGarminRequestModernSearch testForOrganizer:organizer_garmin withFilesInPath:bundlePath start:20];
    // should have 40 - duplicates - 1 overlappng (existing)
    XCTAssertEqual(organizer_garmin.countOfActivities, 40 - organizer_garmin.countOfKnownDuplicates - 1);
    XCTAssertEqual(organizer.countOfActivities, organizer_garmin.countOfActivities);
    // connectstats does not send overlapping activities, so should have 1 more
    XCTAssertEqual(organizer_cs.countOfActivities, organizer_garmin.countOfActivities+1);

    [GCStravaRequestActivityList testWithOrganizer:organizer path:bundlePath start:1];
    [GCStravaRequestActivityList testWithOrganizer:organizer_strava path:bundlePath start:1];
    XCTAssertEqual(organizer_strava.countOfActivities, 60);

    NSUInteger beforeLastGarmin = organizer.countOfActivities;
    
    // Add empty stub should change nothing
    [GCGarminRequestModernSearch testForOrganizer:organizer withFilesInPath:bundlePath start:40];
    [GCGarminRequestModernSearch testForOrganizer:organizer_garmin withFilesInPath:bundlePath start:40];

    // We added all the extra from strava, so no new one should come from garmin (all sync'd duplicates)
    XCTAssertEqual(organizer.countOfActivities, beforeLastGarmin);
    
    NSUInteger beforeLastStrava = organizer_strava.countOfActivities;
    [GCStravaRequestActivityList testWithOrganizer:organizer_strava path:bundlePath start:2];
    XCTAssertEqual(organizer_strava.countOfActivities, beforeLastStrava);

    // All the activities in garmin shuold be in final merged
    // or a known duplicate (strava should have more activities)
    for (GCActivity * one in organizer_garmin.activities) {
        GCActivity * found = [organizer activityForId:one.activityId];
        BOOL knownDuplicate = [organizer isKnownDuplicate:one];
        XCTAssertTrue(knownDuplicate || found != nil, @"activity %@", one);
    }

    for (GCActivity * one in organizer.activities) {
        GCActivity * found = [organizer_strava activityForId:one.activityId];
        if( found == nil){
            NSString * knownDuplicate = [organizer hasKnownDuplicate:one];
            found = [organizer_strava activityForId:knownDuplicate];
        }
        if( found == nil){
            // Strava will skip activities of less than 30 seconds
            XCTAssertLessThan(one.sumDurationCompat, 30.0);
        }else{
            XCTAssertTrue(found != nil, @"activity %@ in both", one);
        }
    }

    GCActivitiesOrganizer * reload = RZReturnAutorelease([[GCActivitiesOrganizer alloc] initTestModeWithDb:organizer.db]);
    XCTAssertEqual(organizer.countOfActivities,reload.countOfActivities);
    
    // Check that import again on reloaded organizer does not add duplicate
    [GCGarminRequestModernSearch testForOrganizer:reload withFilesInPath:bundlePath];
    
    [GCStravaRequestActivityList testWithOrganizer:reload path:bundlePath];
    XCTAssertEqual(organizer.countOfActivities,reload.countOfActivities);
    [GCGarminRequestModernSearch testForOrganizer:reload withFilesInPath:bundlePath start:20];
    [GCStravaRequestActivityList testWithOrganizer:reload path:bundlePath start:1];
    XCTAssertEqual(organizer.countOfActivities,reload.countOfActivities);
    
}

-(void)testOrganizerBackgroundRegister{    
    NSString * bundlePath = [RZFileOrganizer bundleFilePath:nil forClass:[self class]];

    NSMutableDictionary * save_cs = [NSMutableDictionary dictionary];
    NSMutableDictionary * save_fit = [NSMutableDictionary dictionary];
    NSMutableDictionary * save_gar = [NSMutableDictionary dictionary];

    GCNumberWithUnit * exampleFieldValue = nil;
    GCField * exampleDetailField = [GCField fieldForKey:@"GainElevation" andActivityType:GC_TYPE_RUNNING];
    NSString * exampleActivityId = @"__connectstats__5567";

    FMDatabase * db = nil;

    @autoreleasepool {
        GCActivitiesOrganizer * organizer = [self createEmptyOrganizer:@"test_register_background.db"];
        db = organizer.db;
        
        [GCConnectStatsRequestSearch testForOrganizer:organizer withFilesInPath:bundlePath];
        
        // First do the motion of the workflow of update:
        //   1. connectstats search activity
        //   2. update from fit file
        //   3. update garmin connect summaries

        for (GCActivity * one in organizer.activities) {
            save_cs[one.activityId] = one.summaryData;
        }
        
        XCTAssertNil([[organizer activityForId:exampleActivityId] numberWithUnitForField:exampleDetailField], @"From the initial download, detail field is missing" );

        for (GCActivity * one in organizer.activities) {
            one.settings.worker = nil;
            NSDictionary * before = save_cs[one.activityId];
            GCActivity * fit = [GCConnectStatsRequestFitFile testForActivity:one  withFilesIn:bundlePath];
            if( fit ) {
                XCTAssertGreaterThan(one.summaryData.count, before.count,@"%@ after fit load has more information", one);
                save_fit[one.activityId] = one.summaryData;
            }
            NSMutableSet<GCField*>*updated = [NSMutableSet set];
            
            for (GCField *key in one.summaryData) {
                if( before[key] == nil){
                    [updated addObject:key];
                }
            }
            if( updated.count > 0){
                RZLog(RZLogInfo, @"%@: updated fit with %@ fields", one, @(updated.count));
            }
        }
        exampleFieldValue = [[[organizer activityForId:exampleActivityId] numberWithUnitForField:exampleDetailField] retain];
        XCTAssertNotNil(exampleFieldValue, @"After detail download, detail field is n ot missing" );
        [GCGarminRequestModernSearch testForOrganizer:organizer withFilesInPath:bundlePath];
        
        for (NSString * activityId in save_fit) {
            NSDictionary * before = save_fit[activityId];
            GCActivity * after  = [organizer activityForId:activityId];
            XCTAssertNotNil(after);
            XCTAssertGreaterThan(after.summaryData.count,before.count,@"%@ after garmin has more information", after);
            save_gar[activityId] = after.summaryData;
            for (GCField *key in before) {
                // we didn't loose anything
                XCTAssertNotNil(after.summaryData[key], @"%@ has %@", activityId, key);
            }

            NSMutableSet<GCField*>*updated = [NSMutableSet set];
            for (GCField *key in after.summaryData) {
                if( before[key] == nil){
                    [updated addObject:key];
                }
            }
            if( updated.count > 0){
                RZLog(RZLogInfo, @"%@: updated gar with %@ fields", activityId, @(updated.count));
            }
        }
        
        // Remove all details and close db for activities
        [organizer purgeCache];
    } // End autoreleast pool
    
    // Now do a workflow of background update:
    //   1. load without details
    //   2. update new only from connectstats + fit file
    //   3. load details for the rest when UI starts

    GCActivitiesOrganizer * organizer_light = RZReturnAutorelease([[GCActivitiesOrganizer alloc] initTestModeWithDb:db loadDetails:false]);
    for (NSString * activityId in save_fit) {
        GCActivity * after  = [organizer_light activityForId:activityId];
        XCTAssertNotNil(after);
        XCTAssertEqual(after.summaryData.count,0,@"%@ summary loaded no details", after);
    }

    [organizer_light ensureDetailsLoaded];
    XCTAssertEqualObjects(exampleFieldValue, [[organizer_light activityForId:exampleActivityId] numberWithUnitForField:exampleDetailField], @"After detail download example field still correct");
    
    for (NSString * activityId in save_fit) {
        NSDictionary * before = save_gar[activityId];
        GCActivity * after  = [organizer_light activityForId:activityId];
        XCTAssertEqual(after.summaryData.count,before.count, @"%@ after split reload has all information", after);
        for (GCField *key in before) {
            if( after.summaryData[key] == nil){
                NSLog(@"missing %@ = %@", key, before[key]);
            }
        }
    }

    // ==== Test background download and process
    // now delete one fit activity, to make sure background reload will bring it back
    NSString * deletedActivityId = save_fit.allKeys.firstObject;
    [organizer_light deleteActivityId:deletedActivityId];
    // reload it
    organizer_light = RZReturnAutorelease([[GCActivitiesOrganizer alloc] initTestModeWithDb:db loadDetails:false]);
    for (NSString * activityId in save_fit) {
        if( [activityId isEqualToString:deletedActivityId]){
            XCTAssertNil([organizer_light activityForId:activityId]);
        }else{
            GCActivity * after  = [organizer_light activityForId:activityId];
            XCTAssertEqual(after.summaryData.count,0,@"%@ summary loaded no details", after);
        }
    }
    // Do the background refresh, without details loaded, to simulate background refresh
    [GCConnectStatsRequestBackgroundSearch testWithOrganizer:organizer_light path:bundlePath mode:gcRequestModeDownloadAndProcess];
    
    // Right now activity was reconstructed from fit
    GCActivity * current = [organizer_light activityForId:deletedActivityId];
    NSDictionary * before = nil;
    
    XCTAssertNotNil(current);
    before = save_fit[deletedActivityId];
    XCTAssertEqual(current.summaryData.count,before.count, @"In memory reconstruction match original");
    
    // then load details, simulate when the UI starts, this will
    // trigger an update from the database of what was saved from the background update, need
    // to make sure still consistent
    [organizer_light ensureDetailsLoaded];
    for (NSString * activityId in save_fit) {
        GCActivity * after  = [organizer_light activityForId:activityId];
        XCTAssertNotNil(after);
        
        if( [activityId isEqualToString:deletedActivityId]){
            before = save_fit[activityId];
        }else{
            before = save_gar[activityId];
        }
        XCTAssertEqual(after.summaryData.count,before.count, @"%@ after split reload has all information", after);
    }

    // Now reload fit for deleted activity in background
    GCActivity * newAct = [organizer_light activityForId:deletedActivityId];
    GCActivity * fit = [GCConnectStatsRequestBackgroundFitFile testForActivity:newAct  withFilesIn:bundlePath];
    XCTAssertNotNil(fit);
    
    // do full reload of activity and make sure we get back same as we started
    GCActivitiesOrganizer * organizer_final = RZReturnAutorelease([[GCActivitiesOrganizer alloc] initTestModeWithDb:db loadDetails:true]);
    for (NSString * activityId in save_fit) {
        NSDictionary * before = nil;
        GCActivity * after  = [organizer_final activityForId:activityId];
        if( [activityId isEqualToString:deletedActivityId]){
            before = save_fit[activityId];
        }else{
            before = save_gar[activityId];
        }
        XCTAssertEqual(after.summaryData.count,before.count, @"%@ after full reload has all information", after);
    }
    
    // ==== Test cache
    // Now try to do the same exercise fully in backgorund without anything loaded and in two step
    // delete one fit activity, reload minimum, save cache, reload details, process cache
    
    [organizer_light deleteActivityId:deletedActivityId];
    // reload it
    organizer_light = RZReturnAutorelease([[GCActivitiesOrganizer alloc] initTestModeMinimumWithDb:db]);
    XCTAssertEqual(organizer_light.countOfActivities, 0, "Started with no activities loaded");
    XCTAssertFalse( organizer_light.fullyLoaded );
    // Do the background refresh, without details loaded, to simulate background refresh
    [GCConnectStatsRequestBackgroundSearch testWithOrganizer:organizer_light path:bundlePath mode:gcRequestModeDownloadAndCache];

    // Nothing got updated
    XCTAssertEqual(organizer_light.countOfActivities, 0, "Started with no activities loaded");
    XCTAssertFalse( organizer_light.fullyLoaded );

    // Now load
    [organizer_light ensureSummaryLoaded];
    [organizer_light ensureDetailsLoaded];

    for (NSString * activityId in save_fit) {
        if( [activityId isEqualToString:deletedActivityId]){
            XCTAssertNil([organizer_light activityForId:activityId]);
        }else{
            GCActivity * after  = [organizer_light activityForId:activityId];
            before = save_gar[activityId];
            XCTAssertEqual(after.summaryData.count,before.count,@"%@ summary loaded same details", after);
        }
    }

    // Now process cache
    [GCConnectStatsRequestBackgroundSearch testWithOrganizer:organizer_light path:bundlePath mode:gcRequestModeProcessCache];
    
    // Right now activity was reconstructed properly
    current = [organizer_light activityForId:deletedActivityId];
    before = nil;
    
    XCTAssertNotNil(current);
    before = save_cs[deletedActivityId];
    XCTAssertEqual(current.summaryData.count,before.count, @"In memory reconstruction match original");

    
    [exampleFieldValue release];
}

-(void)testOrganizerRegister{
    NSData * searchLegacyInfo = [NSData  dataWithContentsOfFile:[RZFileOrganizer bundleFilePath:@"last_modern_search_0.json"
                                                                                       forClass:[self class]]];
    
    GCGarminSearchModernJsonParser * parser=[[[GCGarminSearchModernJsonParser alloc] initWithData:searchLegacyInfo] autorelease];
    
    NSArray<GCActivity*>* activityFirstHalf = [parser.activities subarrayWithRange:NSMakeRange(0, 10)];
    NSArray<GCActivity*>* activitySubFirstHalf = [parser.activities subarrayWithRange:NSMakeRange(2, 8)];
    NSArray<GCActivity*>* activitySecondHalf = [parser.activities subarrayWithRange:NSMakeRange(10, 10)];
    
    GCActivitiesOrganizer * organizer = [self createEmptyOrganizer:@"test_organizer_register.db"];
    GCService * service = [GCService service:gcServiceGarmin];
    
    GCActivitiesOrganizerListRegister * listregister =[GCActivitiesOrganizerListRegister activitiesOrganizerListRegister:activitySubFirstHalf from:service isFirst:YES];
    [listregister addToOrganizer:organizer];
    XCTAssertEqual(organizer.countOfActivities+organizer.countOfKnownDuplicates, 8);
    XCTAssertFalse(listregister.reachedExisting);
    
    listregister =[GCActivitiesOrganizerListRegister activitiesOrganizerListRegister:activitySecondHalf from:service isFirst:NO];
    [listregister addToOrganizer:organizer];
    XCTAssertEqual(organizer.countOfActivities+organizer.countOfKnownDuplicates, 18);
    XCTAssertFalse(listregister.reachedExisting);
    
    listregister =[GCActivitiesOrganizerListRegister activitiesOrganizerListRegister:activityFirstHalf from:service isFirst:NO];
    [listregister addToOrganizer:organizer];
    XCTAssertEqual(organizer.countOfActivities+organizer.countOfKnownDuplicates, 20);
    XCTAssertTrue(listregister.reachedExisting);
    
    NSArray * oneDeleted = [@[parser.activities[0]] arrayByAddingObjectsFromArray:activitySubFirstHalf];
    listregister =[GCActivitiesOrganizerListRegister activitiesOrganizerListRegister:oneDeleted from:service isFirst:NO];
    [listregister addToOrganizer:organizer];
    XCTAssertEqual(organizer.countOfActivities+organizer.countOfKnownDuplicates, 19);
    XCTAssertTrue(listregister.reachedExisting);
    
    GCActivitiesOrganizer * reloaded = [[GCActivitiesOrganizer alloc] initTestModeWithDb:organizer.db];
    XCTAssertEqual(reloaded.countOfActivities, organizer.countOfActivities);
    
    for (NSString * activityType in @[ GC_TYPE_RUNNING, GC_TYPE_CYCLING]) {
        NSArray<GCActivity*>*activities = [organizer activitiesMatching:^(GCActivity * act){
            return [act.activityType isEqualToString:activityType];
        } withLimit:1];
        XCTAssertTrue(activities.count > 0, @"Found for type %@", activityType);
        if( activities.count > 0){
            NSArray<GCField*>*allFields = [activities[0] allFields];
            NSDictionary * origSeries = [organizer fieldsSeries:allFields matching:nil useFiltered:false ignoreMode:gcIgnoreModeActivityFocus];
            NSDictionary * reloadedSeries = [reloaded fieldsSeries:allFields matching:nil useFiltered:false ignoreMode:gcIgnoreModeActivityFocus];
            
            XCTAssertEqual(origSeries.count, reloadedSeries.count);
            for (GCField * field in allFields) {
                GCStatsDataSerieWithUnit * origSerie = origSeries[field];
                GCStatsDataSerieWithUnit * reloadSerie = reloadedSeries[field];
                XCTAssertEqualObjects( origSerie, reloadSerie, @"Reloaded %@ match %@ %@", field, origSerie, reloadSerie);
            }
        }
    }
    
}

#pragma mark - Utilities

-(GCActivity*)findActivityId:(NSString*)activityId in:(NSArray<GCActivity*>*)activities{
    GCActivity * rv = nil;
    for (GCActivity * one in activities) {
        if( [one.activityId isEqualToString:activityId] ||[one.externalServiceActivityId isEqualToString:activityId]){
            rv = one;
            break;
        }
    }
    return rv;
}

-(void)compareActivitySummaryIn:(GCActivity*)one and:(GCActivity*)two tolerance:(NSDictionary<NSString*,id>*)tolerances message:(NSString*)msg{
    NSDictionary<GCField*,GCActivitySummaryValue*> * oneDict = one.summaryData;
    NSDictionary<GCField*,GCActivitySummaryValue*> * twoDict = two.summaryData;
    [self compareActivitySummaryDictIn:oneDict and:twoDict tolerance:tolerances message:msg];
}

-(void)compareActivitySummaryDictIn:(NSDictionary<GCField*,GCActivitySummaryValue*>*)oneDict and:(NSDictionary<GCField*,GCActivitySummaryValue*>*)twoDict tolerance:(NSDictionary<NSString*,id>*)tolerances message:(NSString*)msg{
    
    NSMutableDictionary * missingFromTwo = [NSMutableDictionary dictionary];

    NSMutableDictionary * equals = [NSMutableDictionary dictionary];
    NSMutableDictionary * diffs = [NSMutableDictionary dictionary];
    
    for (GCField * field in oneDict) {
        // Skip corrected/uncorrected elevation
        if( [field hasSuffix:@"orrectedElevation"]){
            continue;
        }
        
        GCActivitySummaryValue * oneValue = oneDict[field];
        GCActivitySummaryValue * twoValue = twoDict[field];
        
        if (twoValue) {
            NSString * displayOne = oneValue.numberWithUnit.description;
            NSString * displayTwo = oneValue.numberWithUnit.description;
            
            if( [displayTwo isEqualToString:displayOne]){
                equals[field] = displayOne;
            }else{
                diffs[field] = displayOne;
            }
            
            XCTAssertEqualObjects(displayOne, displayTwo, @"%@: %@ %@<>%@", msg, field, displayOne, displayTwo);
        }else{
            if( ![tolerances[field.key] isKindOfClass:[NSString class]]){
                missingFromTwo[field] = oneValue;
            }
        }
    }
    
    // We do not assert what is missing from one, as we should call in one
    // for the service with the least fields.
    XCTAssertEqual(missingFromTwo.count, 0);
    XCTAssertGreaterThan(equals.count, 0);
}

-(NSDictionary*)compareStatsDictFor:(GCActivity*)act{
    GCTrackFieldChoices * choices = [GCTrackFieldChoices trackFieldChoicesWithActivity:act];
    NSArray<GCField*>*fields = [act availableTrackFields];
    
    GCTrackStats * trackStats = [[GCTrackStats alloc] init];
    trackStats.activity = act;
    if( act.garminSwimAlgorithm ){
        act.settings.treatGapAsNoValueInSeries = NO;
        act.settings.gapTimeInterval = 0.;
    }else{
        act.settings.treatGapAsNoValueInSeries = NO;
    }

    // Make sure allKeys are the same and generated holders are the same
    // then summary statistics for each field is the same.
    NSMutableDictionary * rv = [NSMutableDictionary dictionaryWithObject:fields forKey:@"allkeys"];
    rv[@"holders"] = choices.choices;
    for (NSArray<GCTrackFieldChoiceHolder *> * holders in choices.choices) {
        XCTAssertGreaterThan(holders.count, 0);
        if( holders.count > 0){
            GCTrackFieldChoiceHolder*holder = holders[0];
            [holder setupTrackStats:trackStats];
            if( trackStats.nDataSeries > 0 && ! rv[trackStats.field]){
                GCStatsDataSerie * serie = [trackStats dataSerie:0];
                rv[trackStats.field] = serie.summaryStatistics;
            }
        }
    }
    return rv;
}

-(void)compareStatsAssertEqual:(NSDictionary*)rv andExpected:(NSDictionary*)expected withMessage:(NSString*)msg{
    XCTAssertEqual(expected.allKeys.count, rv.allKeys.count,  @"Same Keys %@", msg);
    
    for (NSObject<NSCopying>*key in expected) {
        NSObject * expectedVal = expected[key];
        NSObject * rvVal = rv[key];
        XCTAssertNotNil(rvVal, @"got same key %@", key);
        
        if( [expectedVal isKindOfClass:[NSDictionary class]] && [rvVal isKindOfClass:[NSDictionary class]]){
            NSDictionary * expectedValDict = (NSDictionary*)expectedVal;
            NSDictionary * rvValDict = (NSDictionary*)rvVal;
            
            NSDictionary * smartDiff = [expectedValDict smartCompareDict:rvValDict];
            XCTAssertNil(smartDiff, @"[%@] %@", key, msg);
            if( smartDiff == nil &&  ![expectedVal isEqual:rvVal]){
                RZLog(RZLogInfo, @"attention");
            }
        }else{
            XCTAssertTrue([expectedVal respondsToSelector:@selector(isEqual:)]);
            
            if( [expectedVal respondsToSelector:@selector(isEqual:)]){
                XCTAssertTrue([expectedVal isEqual:rvVal]);
                if( ! [expectedVal isEqual:rvVal] && [expectedVal isKindOfClass:[NSArray class]] && [rvVal isKindOfClass:[NSArray class]]){
                    NSArray * e = (NSArray*)expectedVal;
                    NSArray * r = (NSArray*)rvVal;
                    for( NSUInteger i=0;i<MIN(e.count, r.count);i++){
                        if( [e[i] isKindOfClass:[GCField class]] ){
                            GCField * eA = e[i];
                            GCField * rA = r[i];
                            if( ! [eA isEqualToField:rA] ){
                                RZLog(RZLogInfo, @"%@[%lu]  %@ != %@", key, (unsigned long)i, eA, rA);
                            }
                        }else{
                            NSArray<GCTrackFieldChoiceHolder*> * eA = e[i];
                            NSArray<GCTrackFieldChoiceHolder*> * rA = r[i];
                            if( eA.count != rA.count ){
                                RZLog(RZLogInfo, @"%@[%lu] count %@ != %@", key, (unsigned long)i, @(eA.count), @(rA.count));
                            }else{
                                for (NSUInteger j=0; j<eA.count; j++) {
                                    GCTrackFieldChoiceHolder * eH = eA[j];
                                    GCTrackFieldChoiceHolder * rH = rA[j];
                                    
                                    if( ![eH.field isEqualToField:rH.field] ){
                                        RZLog(RZLogInfo, @"%@[%@] %@ != %@", key, @(i), eH.field, rH.field);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

-(void)compareStatsCheckSavedFor:(GCActivity*)act identifier:(NSString*)label cmd:(SEL)sel recordMode:(BOOL)record{
    RZRegressionManager * manager = [RZRegressionManager managerForTestClass:[self class]];
    manager.recordMode = record;

    NSSet<Class>*classes = [NSSet setWithObjects:[NSDictionary class], [GCField class], [GCTrackFieldChoiceHolder class], [NSArray class], nil];
    NSError * error = nil;
    NSDictionary * rv = [self compareStatsDictFor:act];
    NSDictionary * expected = [manager retrieveReferenceObject:rv forClasses:classes selector:sel identifier:label error:&error];
    [self compareStatsAssertEqual:rv andExpected:expected withMessage:[NSString stringWithFormat:@"%@ %@", NSStringFromSelector(sel), label]];

}


@end
