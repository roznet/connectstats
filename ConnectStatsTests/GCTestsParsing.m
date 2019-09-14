//
//  GCTestsParsing.m
//  GarminConnect
//
//  Created by Brice Rosenzweig on 14/03/2015.
//  Copyright (c) 2015 Brice Rosenzweig. All rights reserved.
//

#import "GCTestCase.h"
#import "GCTrackPoint.h"
#import "GCActivity+Database.h"
#import "GCActivity+Import.h"
#import "GCWeather.h"
#import "GCAppGlobal.h"
#import "GCGarminActivityDetailJsonParser.h"
#import "GCGarminRequestActivityReload.h"
#import "GCGarminSearchJsonParser.h"
#import "GCGarminActivityTrack13Request.h"
#import "GCGarminSearchModernJsonParser.h"
#import "GCGarminActivityLapsParser.h"
#import "GCGarminRequestSearch.h"
#import "GCGarminUserJsonParser.h"
#import "GCStravaSegmentListStarred.h"
#import "GCStravaActivityListParser.h"
#import "GCActivitiesOrganizer.h"
#import "GCHealthOrganizer.h"
#import "GCWithingsBodyMeasures.h"
#import "GCHealthZoneCalculator.h"
#import "FITFitFileDecode.h"
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
#import "GCStravaActivityList.h"
#import "GCLap.h"
#import "GCLapSwim.h"
#import "GCConnectStatsRequestSearch.h"
#import "GCHistoryFieldSummaryStats.h"

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

- (void)testParsingModern {
    NSString * file = [RZFileOrganizer bundleFilePath:@"activitytrack_718039360.json" forClass:[self class]];
    
    NSData * data = [NSData dataWithContentsOfFile:file];
    GCActivity * act = [[GCActivity alloc] init];
    [act setActivityType:GC_TYPE_RUNNING];

    GCGarminActivityDetailJsonParser * parser = [[GCGarminActivityDetailJsonParser alloc] initWithData:data forActivity:act];
    XCTAssertEqual(parser.trackPoints.count, 575);
    gcFieldFlag trackFlags = gcFieldFlagNone;
    

    for (GCTrackPoint * point in parser.trackPoints) {
        trackFlags |= point.trackFlags;
    }
    XCTAssertTrue( (trackFlags & gcFieldFlagWeightedMeanSpeed) == gcFieldFlagWeightedMeanSpeed);
}


-(void)testActivityParsingModern{
    // Add test for
    NSArray * activityIds = @[ @"1108367966", @"1108368135", @"1089803211", @"924421177"];;
    
    RZRegressionManager * manager = [RZRegressionManager managerForTestClass:[self class]];
    manager.recordMode = [GCTestCase recordModeGlobal];
    //manager.recordMode = true;
    
    NSSet<Class>*classes =[NSSet setWithObjects:[GCStatsDataSerieWithUnit class], nil];
    
    
    for (NSString * aId in activityIds) {
        dispatch_sync([GCAppGlobal worker], ^(){
            GCActivity * act = [GCGarminRequestActivityReload testForActivity:aId withFilesIn:[RZFileOrganizer bundleFilePath:nil forClass:[self class]]];
            [GCGarminActivityTrack13Request testForActivity:act withFilesIn:[RZFileOrganizer bundleFilePath:nil forClass:[self class]]];
            
            NSArray<GCField*>*fields = [act availableTrackFields];
            
            for (GCField * field in fields) {
                NSError * error = nil;
                
                NSString * ident = [NSString stringWithFormat:@"%@_%@", aId, field.key];
                GCStatsDataSerieWithUnit * expected = [act timeSerieForField:field];
                GCStatsDataSerieWithUnit * retrieved = [manager retrieveReferenceObject:expected forClasses:classes selector:_cmd identifier:ident error:&error];
                XCTAssertNotNil( retrieved, @"In activity %@, field %@ does not have saved reference point, maybe a new field?", act, field);
                XCTAssertNotEqual(expected.count, 0, @"%@[%@] has points",aId,field.key);
                XCTAssertEqualObjects(expected, retrieved, @"%@[%@]: %@<>%@", aId, field.key, expected, retrieved);
            }
        });
    }
    
    //NSLog(@"act %@", act);
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
    
    [GCGarminActivityTrack13Request testForActivity:modernAct withFilesIn:[RZFileOrganizer bundleFilePath:nil forClass:[self class]] mergeFit:false];
    [modernAct saveToDb:db];
    
    XCTAssertGreaterThan(modernAct.trackpoints.count, 1);
    [self compareStatsCheckSavedFor:modernAct identifier:@"modernAct" cmd:_cmd recordMode:[GCTestCase recordModeGlobal]];
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
        
        [GCGarminActivityTrack13Request testForActivity:parsedAct withFilesIn:[RZFileOrganizer bundleFilePath:nil forClass:[self class]] mergeFit:false];
        [parsedAct saveToDb:db];
        
        XCTAssertGreaterThan(parsedAct.trackpoints.count, 1);
        bool recordMode = [GCTestCase recordModeGlobal];
        
        NSString * identifier = [NSString stringWithFormat:@"parse_reload_%@", activityId];
        [self compareStatsCheckSavedFor:parsedAct identifier:identifier cmd:_cmd recordMode:recordMode];
        
        GCActivity * reloadedAct = [GCActivity activityWithId:activityId andDb:db];
        [reloadedAct trackpoints];
        NSDictionary * parsedDict = [self compareStatsDictFor:parsedAct];
        NSDictionary * reloadedDict = [self compareStatsDictFor:reloadedAct];
        
        // Check basics first
        XCTAssertEqual(parsedAct.trackpoints.count, reloadedAct.trackpoints.count);
        
        // Check basics first
        XCTAssertEqual(parsedAct.laps.count, reloadedAct.laps.count);
        
        [self compareStatsAssertEqual:parsedDict and:reloadedDict withMessage:[NSString stringWithFormat:@"Check Reloaded activity %@", activityId]];
        
        XCTAssertEqual(reloadedAct.laps.count, parsedAct.laps.count, @"Lap count %@", activityId);
        
        for (NSUInteger idx=0; idx<MIN(parsedAct.laps.count,reloadedAct.laps.count); idx++) {
            
            if ([parsedAct.laps[idx] isKindOfClass:[GCLapSwim class]]) {
                GCLapSwim * parsedLap = (GCLapSwim*)parsedAct.laps[idx];
                GCLapSwim * reloadedLap = (GCLapSwim*)reloadedAct.laps[idx];
                
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
    
    GCActivitiesOrganizerListRegister * listregisterGarmin =[GCActivitiesOrganizerListRegister listRegisterFor:modernParser.activities from:serviceGarmin isFirst:YES];
    [listregisterGarmin addToOrganizer:organizer];
    
    GCService * serviceStrava = [GCService service:gcServiceStrava];
    GCActivitiesOrganizerListRegister * listregisterStrava =[GCActivitiesOrganizerListRegister listRegisterFor:stravaListParser.activities from:serviceStrava isFirst:YES];
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
    
    
    NSData * searchLegacyInfo = [NSData  dataWithContentsOfFile:[RZFileOrganizer bundleFilePath:@"last_search_modern.json"
                                                                                       forClass:[self class]]];
    NSData * searchModernInfo = [NSData dataWithContentsOfFile:[RZFileOrganizer bundleFilePath:@"activities_list_modern.json"
                                                                                      forClass:[self class]]];
    NSData * searchStravaInfo =[NSData dataWithContentsOfFile:[RZFileOrganizer bundleFilePath:@"strava_list.json"
                                                                                     forClass:[self class]]];
    
    GCGarminSearchJsonParser * parser=[[[GCGarminSearchJsonParser alloc] initWithData:searchLegacyInfo] autorelease];
    GCGarminSearchModernJsonParser * modernParser = [[[GCGarminSearchModernJsonParser alloc] initWithData:searchModernInfo] autorelease];
    GCStravaActivityListParser * stravaListParser = [GCStravaActivityListParser activityListParser:searchStravaInfo];
    
    for (NSString * activityId in @[@"1378220136",@"1382772474"]) {
        
        GCActivity * legacyAct = [self findActivityId:activityId in:parser.activities];
        GCActivity * searchModernAct = [self findActivityId:activityId in:modernParser.activities];
        GCActivity * stravaAct = [self findActivityId:activityId in:stravaListParser.activities];
        
        NSData * fitData = [NSData dataWithContentsOfFile:[RZFileOrganizer bundleFilePath:[NSString stringWithFormat:@"activity_%@.fit", activityId] forClass:[self class]]];
        
        FITFitFileDecode * fitDecode = [FITFitFileDecode fitFileDecode:fitData];
        [fitDecode parse];
        
        //[[GCActivity alloc] initWithId:activityId fitFile:fitDecode.fitFile];
        
        NSString * fn = [NSString stringWithFormat:@"activity_%@.json", activityId];
        NSData * data = [NSData dataWithContentsOfFile:[RZFileOrganizer bundleFilePath:fn forClass:[self class]] options:0 error:nil];
        
        NSDictionary * json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        GCActivity * modernAct = [[[GCActivity alloc] initWithId:activityId andGarminData:json] autorelease];
        
        NSDictionary * legacyModernTolerance = @{@"MaxRunCadence":@(0.015),
                                                 @"WeightedMeanRunCadence":@(0.015),
                                                 @"SumTotalWork":@(0.01),
                                                 @"MinPower": @"SKIP",
                                                 
                                                 // In legacy not in modern/cycling
                                                 @"EndPowerTwentyMinutesTimerTime" : @"SKIP",
                                                 @"BeginPowerTwentyMinutesTime" : @"SKIP",
                                                 @"MinBikeCadence" : @"SKIP",
                                                 @"MaxFractionalCadence" : @"SKIP",
                                                 @"MinSpeed" : @"SKIP",
                                                 @"MinHeartRate" : @"SKIP",
                                                 @"EndPowerTwentyMinutesTime" : @"SKIP",
                                                 @"BeginPowerTwentyMinutesTimerTime" : @"SKIP",
                                                 @"WeightedMeanMovingPace" : @"SKIP",
                                                 @"WeightedMeanPace" : @"SKIP",
                                                 @"DirectVO2MaxCycling" : @"SKIP",
                                                 @"WeightedMeanFractionalCadence" : @"SKIP",
                                                 @"BeginPowerTwentyMinutesDistance" : @"SKIP",
                                                 @"MaxPace" : @"SKIP",
                                                 
                                                 // In legacy not in modern/running
                                                 @"DirectVO2Max" : @"SKIP",
                                                 @"SumStep" : @"SKIP",
                                                 @"WeightedMeanDoubleCadence" : @"SKIP",
                                                 @"MinRunCadence" : @"SKIP",
                                                 @"MaxDoubleCadence" : @"SKIP",
                                                 
                                                 
                                                 };
        
        NSDictionary * modernSearchSkip = @{
                                            // Running
                                            @"DirectLactateThresholdHeartRate":@"SKIP",
                                            @"DirectLactateThresholdSpeed":@"SKIP",
                                            @"MaxAirTemperature":@"SKIP",
                                            @"MaxElevation":@"SKIP",
                                            @"MaxRunCadence":@"SKIP",
                                            @"MinAirTemperature":@"SKIP",
                                            @"MinElevation":@"SKIP",
                                            @"SumElapsedDuration":@"SKIP",
                                            @"SumMovingDuration":@"SKIP",
                                            @"SumTrainingEffect":@"SKIP",
                                            @"WeightedMeanAirTemperature":@"SKIP",
                                            @"WeightedMeanGroundContactBalanceLeft":@"SKIP",
                                            @"WeightedMeanGroundContactTime":@"SKIP",
                                            @"WeightedMeanMovingSpeed":@"SKIP",
                                            @"WeightedMeanRunCadence":@"SKIP",
                                            @"WeightedMeanStrideLength":@"SKIP",
                                            @"WeightedMeanVerticalOscillation":@"SKIP",
                                            @"WeightedMeanVerticalRatio":@"SKIP",
                                            @"WeightedMeanMovingPace":@"SKIP",
                                            // Cycle
                                            @"MaxBikeCadence":@"SKIP",
                                            @"MaxPower":@"SKIP",
                                            @"MaxPowerTwentyMinutes":@"SKIP",
                                            @"MinPower":@"SKIP",
                                            @"SumIntensityFactor":@"SKIP",
                                            @"SumStrokes":@"SKIP",
                                            @"SumTotalWork":@"SKIP",
                                            @"SumTrainingStressScore":@"SKIP",
                                            @"ThresholdPower":@"SKIP",
                                            @"WeightedMeanBikeCadence":@"SKIP",
                                            @"WeightedMeanLeftPedalSmoothness":@"SKIP",
                                            @"WeightedMeanLeftTorqueEffectiveness":@"SKIP",
                                            @"WeightedMeanNormalizedPower":@"SKIP",
                                            @"WeightedMeanPower":@"SKIP",
                                            
                                            };
        
        NSDictionary * stravaModernTolerance = @{
                                                 @"WeightedMeanRunCadence":@(0.015),
                                                 @"SumDistance":@(0.005),
                                                 @"WeightedMeanHeartRate":@(0.05),
                                                 @"WeightedMeanPace":@(0.005),
                                                 @"WeightedMeanSpeed":@(0.20),
                                                 @"WeightedMeanAirTemperature":@(0.05),
                                                 @"SumTotalWork":@(0.05),
                                                 @"WeightedMeanPower":@(0.15),
                                                 @"WeightedMeanBikeCadence":@(0.01),
                                                 
                                                 // Skip
                                                 @"SumMovingDuration":@"SKIP",
                                                 @"SumDuration":@"SKIP",
                                                 @"MaxSpeed":@"SKIP",
                                                 
                                                 // Not available in Strava Cycling
                                                 @"SumTrainingStressScore" : @"SKIP",
                                                 @"SumIntensityFactor" : @"SKIP",
                                                 @"SumElapsedDuration" : @"SKIP",
                                                 @"MaxPower" : @"SKIP",
                                                 @"SumEnergy" : @"SKIP",
                                                 @"MaxElevation" : @"SKIP",
                                                 @"WeightedMeanLeftPedalSmoothness" : @"SKIP",
                                                 @"MaxPowerTwentyMinutes" : @"SKIP",
                                                 @"LossElevation" : @"SKIP",
                                                 @"WeightedMeanMovingSpeed" : @"SKIP",
                                                 @"ThresholdPower" : @"SKIP",
                                                 @"MaxAirTemperature" : @"SKIP",
                                                 @"MinPower" : @"SKIP",
                                                 @"MinAirTemperature" : @"SKIP",
                                                 @"MinElevation" : @"SKIP",
                                                 @"WeightedMeanNormalizedPower" : @"SKIP",
                                                 @"WeightedMeanLeftTorqueEffectiveness" : @"SKIP",
                                                 @"MaxBikeCadence" : @"SKIP",
                                                 @"SumStrokes" : @"SKIP",
                                                 
                                                 // Not available in Strava Running
                                                 @"MaxRunCadence":@"SKIP",
                                                 @"WeightedMeanStrideLength" : @"SKIP",
                                                 @"WeightedMeanMovingPace" : @"SKIP",
                                                 @"WeightedMeanVerticalRatio" : @"SKIP",
                                                 @"WeightedMeanVerticalOscillation" : @"SKIP",
                                                 @"DirectLactateThresholdHeartRate" : @"SKIP",
                                                 @"MaxRunCadence" : @"SKIP",
                                                 @"DirectLactateThresholdSpeed" : @"SKIP",
                                                 @"SumTrainingEffect" : @"SKIP",
                                                 @"WeightedMeanGroundContactTime" : @"SKIP",
                                                 @"WeightedMeanGroundContactBalanceLeft" : @"SKIP",
                                                 
                                                 };
        
        [self compareActivitySummaryIn:legacyAct and:modernAct tolerance:legacyModernTolerance message:@"legacy==modern"];
        [self compareActivitySummaryIn:modernAct and:searchModernAct tolerance:modernSearchSkip message:@"searchModern==modern"];
        [self compareActivitySummaryIn:stravaAct and:modernAct tolerance:stravaModernTolerance message:@"strava==modern"];
        
        NSString * lapsFn = [NSString stringWithFormat:@"activitylaps_%@.json", activityId];
        NSData * lapsData = [NSData dataWithContentsOfFile:[RZFileOrganizer bundleFilePath:lapsFn forClass:[self class]]];
        
        json = [NSJSONSerialization JSONObjectWithData:lapsData options:NSJSONReadingAllowFragments error:nil];
        NSArray * lapsJson = json[@"lapDTOs"];
        NSMutableArray * laps = [NSMutableArray array];
        GCNumberWithUnit * dist = [GCNumberWithUnit numberWithUnitName:@"kilometer" andValue:0.];
        for (NSDictionary * one in lapsJson) {
            GCLap * lap = [[GCLap alloc] initWithDictionary:one forActivity:modernAct];
            [laps addObject:lap];
            dist = [dist addNumberWithUnit:[lap numberWithUnitForField:gcFieldFlagSumDistance andActivityType:modernAct.activityType] weight:1.];
            [lap release];
        }
        XCTAssertEqualObjects([modernAct numberWithUnitForField:[GCField fieldForKey:@"SumDistance" andActivityType:modernAct.activityType]], dist);
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
        [act saveToDb:db_nofit];
        [GCGarminActivityTrack13Request testForActivity:act withFilesIn:[RZFileOrganizer bundleFilePath:nil forClass:[self class]]];
        
        GCActivity * actMerge = [GCGarminRequestActivityReload testForActivity:aId withFilesIn:[RZFileOrganizer bundleFilePath:nil forClass:[self class]]];
        actMerge.db = db_fit;
        actMerge.trackdb = db_fit;
        [actMerge saveToDb:db_fit];
        [GCGarminActivityTrack13Request testForActivity:actMerge withFilesIn:[RZFileOrganizer bundleFilePath:nil forClass:[self class]] mergeFit:TRUE];
        [actMerge saveToDb:db_fit];
        
        GCActivity * actMergeReload = [GCActivity activityWithId:aId andDb:db_fit];
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
    NSArray * files = [RZFileOrganizer bundleFilesMatching:^(NSString*fn) {
        return [fn hasPrefix:@"activityweather"];
    }
                                                forClass:[self class]];
    NSError * err = nil;
    
    FMDatabase * weatherdb = [FMDatabase databaseWithPath:[RZFileOrganizer bundleFilePath:@"weather.db" forClass:[self class]]];
    [weatherdb open];
    
    // Parse Weather Old Db
    NSString * query = @"SELECT * FROM gc_activities_weather ORDER BY activityId DESC";
    NSMutableDictionary * data = [NSMutableDictionary dictionary];
    NSString * currentId = nil;
    NSMutableDictionary * currentSummary = nil;
    
    [RZFileOrganizer removeEditableFile:@"test_newweather.db"];
    FMDatabase * newdb = [FMDatabase databaseWithPath:[RZFileOrganizer writeableFilePath:@"test_newweather.db"]];
    [newdb open];
    [GCActivity ensureDbStructure:newdb];
    [GCWeather ensureDbStructure:newdb];
    
    FMResultSet * res = [weatherdb executeQuery:query];
    while ([res next]) {
        if (currentId==nil || ![currentId isEqualToString:[res stringForColumn:@"activityId"]]) {
            currentId = [res stringForColumn:@"activityId"];
            currentSummary = [NSMutableDictionary dictionaryWithCapacity:5];
            [data setObject:currentSummary forKey:currentId];
        }
        NSString * key = [res stringForColumn:@"weatherField"];
        NSString * val = [res stringForColumn:@"weatherValue"];
        if (key&&val&&currentSummary) {
            [currentSummary setObject:val forKey:key];
        }
    }

    NSMutableArray * found = [NSMutableArray array];
    
    for (NSString * fn in files) {
        NSData * jsonData = [NSData dataWithContentsOfFile:[RZFileOrganizer bundleFilePath:fn forClass:[self class]]];
        NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
        NSNumber * aId = json[@"activityId"];
        if (![aId isKindOfClass:[NSNull class]]) {
            GCWeather * weatherNew = [GCWeather weatherWithData:json];
            [weatherNew saveToDb:newdb forActivityId:[aId stringValue]];
            [found addObject:aId.stringValue];
        }
    }
    res = [newdb executeQuery:@"SELECT * FROM gc_activities_weather_detail"];
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
    
    [GCGarminSearch testForOrganizer:organizer withFilesInPath:[RZFileOrganizer bundleFilePath:nil forClass:[self class]]];
    
    [GCWithingsBodyMeasures testForHealth:organizer.health withFilesIn:[RZFileOrganizer bundleFilePath:nil forClass:[self class]] forId:@"188427"];
    GCField * hf = [GCHealthMeasure healthFieldFromMeasureType:gcMeasureWeight];
    
    NSDictionary * rv = [organizer fieldsSeries:@[ @"WeightedMeanHeartRate", @"WeightedMeanPace", hf] matching:nil useFiltered:NO ignoreMode:gcIgnoreModeActivityFocus];
    
    RZRegressionManager * manager = [RZRegressionManager managerForTestClass:[self class]];
    manager.recordMode = [GCTestCase recordModeGlobal];
    //manager.recordMode = true;
    
    NSError * error = nil;
    NSSet<Class>*classes = [NSSet setWithObjects:[NSDictionary class], [GCField class], [GCStatsDataSerieWithUnit class], nil];
    
    NSDictionary * expected = [manager retrieveReferenceObject:rv forClasses:classes selector:_cmd identifier:@"timeSeries" error:&error];
    XCTAssertEqual(expected.count, rv.count);
    for (id key in expected) {
        GCStatsDataSerieWithUnit * exp_serie = expected[key];
        GCStatsDataSerieWithUnit * got_serie = rv[key];
        XCTAssertNotNil(got_serie, @"key %@", key);
        if (got_serie) {
            XCTAssertEqualObjects(exp_serie, got_serie, @"Key %@", key);
        }
    }
}

-(void)testOrganizerSkipAlways{
    GCActivitiesOrganizer * organizer = [self createEmptyOrganizer:@"test_skipalways.db"];
    
    [GCGarminRequestModernSearch testForOrganizer:organizer withFilesInPath:[RZFileOrganizer bundleFilePath:nil forClass:[self class]]];
    
    [organizer fieldsSeries:@[@"SumDistance"] matching:nil useFiltered:false ignoreMode:gcIgnoreModeActivityFocus];
    
    GCActivity * first = [organizer activityForIndex:0];
    NSString * activityType = first.activityType;
    GCNumberWithUnit * dist = [first numberWithUnitForField:[GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:activityType]];
    
    GCHistoryFieldSummaryStats * start_stats = [GCHistoryFieldSummaryStats fieldStatsWithActivities:organizer.activities matching:nil referenceDate:nil ignoreMode:gcIgnoreModeActivityFocus];
    GCNumberWithUnit * start_nu = [[start_stats dataForField:[GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:activityType]] sumWithUnit];
    
    first.skipAlways = true;
    [first saveToDb:organizer.db];
    
    GCHistoryFieldSummaryStats * skip_stats = [GCHistoryFieldSummaryStats fieldStatsWithActivities:organizer.activities matching:nil referenceDate:nil ignoreMode:gcIgnoreModeActivityFocus];
    GCNumberWithUnit * skip_nu = [[skip_stats dataForField:[GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:activityType]] sumWithUnit];

    GCActivitiesOrganizer * reload = [[[GCActivitiesOrganizer alloc] initTestModeWithDb:organizer.db] autorelease];

    GCHistoryFieldSummaryStats * reload_stats = [GCHistoryFieldSummaryStats fieldStatsWithActivities:reload.activities matching:nil referenceDate:nil ignoreMode:gcIgnoreModeActivityFocus];
    GCNumberWithUnit * reload_nu = [[reload_stats dataForField:[GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:activityType]] sumWithUnit];

    first.skipAlways = false;
    
    GCHistoryFieldSummaryStats * unskip_stats = [GCHistoryFieldSummaryStats fieldStatsWithActivities:organizer.activities matching:nil referenceDate:nil ignoreMode:gcIgnoreModeActivityFocus];
    GCNumberWithUnit * unskip_nu = [[unskip_stats dataForField:[GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:activityType]] sumWithUnit];

    
    XCTAssertEqualWithAccuracy(start_nu.value, skip_nu.value+dist.value, 1.e-7);
    XCTAssertEqualWithAccuracy(reload_nu.value, skip_nu.value, 1.e-7);
    XCTAssertEqualWithAccuracy(start_nu.value, unskip_nu.value, 1.e-7);

}

-(GCActivitiesOrganizer*)createEmptyOrganizer:(NSString*)dbname{
    NSString * dbfp = [RZFileOrganizer writeableFilePath:dbname];
    [RZFileOrganizer removeEditableFile:dbname];
    FMDatabase * db = [FMDatabase databaseWithPath:dbfp];
    [db open];
    [GCActivitiesOrganizer ensureDbStructure:db];
    [GCHealthOrganizer ensureDbStructure:db];
    GCActivitiesOrganizer * organizer = [[[GCActivitiesOrganizer alloc] initTestModeWithDb:db] autorelease];
    GCHealthOrganizer * health = [[[GCHealthOrganizer alloc] initWithDb:db andThread:nil] autorelease];
    organizer.health = health;

    return organizer;
}

-(void)testOrganizerMergeServices{
    // To re-create setup for this test:
    //   copy
    //
    
    NSString * bundlePath = [RZFileOrganizer bundleFilePath:nil forClass:[self class]];
    
    
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
    [GCStravaActivityList testForOrganizer:organizer withFilesInPath:bundlePath];
    [GCStravaActivityList testForOrganizer:organizer_strava withFilesInPath:bundlePath];
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

    [GCStravaActivityList testForOrganizer:organizer withFilesInPath:bundlePath start:1];
    [GCStravaActivityList testForOrganizer:organizer_strava withFilesInPath:bundlePath start:1];
    XCTAssertEqual(organizer_strava.countOfActivities, 60);

    NSUInteger beforeLastGarmin = organizer.countOfActivities;
    
    // Add empty stub should change nothing
    [GCGarminRequestModernSearch testForOrganizer:organizer withFilesInPath:bundlePath start:40];
    [GCGarminRequestModernSearch testForOrganizer:organizer_garmin withFilesInPath:bundlePath start:40];

    // We added all the extra from strava, so no new one should come from garmin (all sync'd duplicates)
    XCTAssertEqual(organizer.countOfActivities, beforeLastGarmin);
    
    NSUInteger beforeLastStrava = organizer_strava.countOfActivities;
    [GCStravaActivityList testForOrganizer:organizer_strava withFilesInPath:bundlePath start:2];
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
            XCTAssertLessThan(one.sumDuration, 30.0);
        }else{
            XCTAssertTrue(found != nil, @"activity %@ in both", one);
        }
    }

    GCActivitiesOrganizer * reload = RZReturnAutorelease([[GCActivitiesOrganizer alloc] initTestModeWithDb:organizer.db]);
    XCTAssertEqual(organizer.countOfActivities,reload.countOfActivities);
    
    // Check that import again on reloaded organizer does not add duplicate
    [GCGarminRequestModernSearch testForOrganizer:reload withFilesInPath:bundlePath];
    [GCStravaActivityList testForOrganizer:reload withFilesInPath:bundlePath];
    XCTAssertEqual(organizer.countOfActivities,reload.countOfActivities);
    [GCGarminRequestModernSearch testForOrganizer:reload withFilesInPath:bundlePath start:20];
    [GCStravaActivityList testForOrganizer:reload withFilesInPath:bundlePath start:1];
    XCTAssertEqual(organizer.countOfActivities,reload.countOfActivities);
    
}

-(void)testOrganizerRegister{
    NSData * searchLegacyInfo = [NSData  dataWithContentsOfFile:[RZFileOrganizer bundleFilePath:@"last_search_modern.json"
                                                                                       forClass:[self class]]];
    
    GCGarminSearchJsonParser * parser=[[[GCGarminSearchJsonParser alloc] initWithData:searchLegacyInfo] autorelease];
    
    NSArray<GCActivity*>* activityFirstHalf = [parser.activities subarrayWithRange:NSMakeRange(0, 10)];
    NSArray<GCActivity*>* activitySubFirstHalf = [parser.activities subarrayWithRange:NSMakeRange(2, 8)];
    NSArray<GCActivity*>* activitySecondHalf = [parser.activities subarrayWithRange:NSMakeRange(10, 10)];
    
    GCActivitiesOrganizer * organizer = [self createEmptyOrganizer:@"test_organizer_register.db"];
    GCService * service = [GCService service:gcServiceGarmin];
    
    GCActivitiesOrganizerListRegister * listregister =[GCActivitiesOrganizerListRegister listRegisterFor:activitySubFirstHalf from:service isFirst:YES];
    [listregister addToOrganizer:organizer];
    XCTAssertEqual(organizer.countOfActivities, 8);
    XCTAssertFalse(listregister.reachedExisting);
    
    listregister =[GCActivitiesOrganizerListRegister listRegisterFor:activitySecondHalf from:service isFirst:NO];
    [listregister addToOrganizer:organizer];
    XCTAssertEqual(organizer.countOfActivities, 18);
    XCTAssertFalse(listregister.reachedExisting);
    
    listregister =[GCActivitiesOrganizerListRegister listRegisterFor:activityFirstHalf from:service isFirst:NO];
    [listregister addToOrganizer:organizer];
    XCTAssertEqual(organizer.countOfActivities, 20);
    XCTAssertTrue(listregister.reachedExisting);
    
    NSArray * oneDeleted = [@[parser.activities[0]] arrayByAddingObjectsFromArray:activitySubFirstHalf];
    listregister =[GCActivitiesOrganizerListRegister listRegisterFor:oneDeleted from:service isFirst:NO];
    [listregister addToOrganizer:organizer];
    XCTAssertEqual(organizer.countOfActivities, 19);
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
    
    NSMutableDictionary * missingFromTwo = [NSMutableDictionary dictionary];
    NSMutableDictionary * missingFromOne = [NSMutableDictionary dictionary];
    
    for (GCField * field in oneDict) {
        // Skip corrected/uncorrected elevation
        if( [field hasSuffix:@"orrectedElevation"]){
            continue;
        }
        
        GCActivitySummaryValue * oneValue = oneDict[field];
        GCActivitySummaryValue * twoValue = twoDict[field];
        
        if (twoValue) {
            NSNumber * tolerance = tolerances[field.key];
            if ([tolerance isKindOfClass:[NSNumber class]]) {
                // tolerance is % (0.01 -> 1%)
                double useTolerance = oneValue.numberWithUnit.value * tolerance.doubleValue;
                XCTAssertTrue([oneValue.numberWithUnit compare:twoValue.numberWithUnit withTolerance:useTolerance] == NSOrderedSame, @"%@: %@ %@<>%@ (within %@)", msg, field, oneValue.numberWithUnit, twoValue.numberWithUnit, tolerance);
            }else if([tolerance isKindOfClass:[NSString class]]){
                //SKIP
            }else{
                XCTAssertEqualObjects(oneValue, twoValue, @"%@: %@", field, msg );
            }
        }else{
            if( ![tolerances[field.key] isKindOfClass:[NSString class]]){
                missingFromTwo[field] = oneValue;
            }
        }
    }
    
    for (GCField * field in twoDict) {
        if( !oneDict[field] && ![tolerances[field.key] isKindOfClass:[NSString class]]){
            missingFromOne[field] = twoDict[field];
        }
    }
    if(missingFromOne.count > 0 || missingFromTwo.count > 0){
        NSLog(@"OOPS");
    }
    XCTAssertEqual(missingFromOne.count, 0);
    XCTAssertEqual(missingFromTwo.count, 0);
}



-(NSDictionary*)compareStatsDictFor:(GCActivity*)act{
    GCTrackFieldChoices * choices = [GCTrackFieldChoices trackFieldChoicesWithActivity:act];
    NSArray<GCField*>*fields = [act availableTrackFields];
    
    GCTrackStats * trackStats = [[GCTrackStats alloc] init];
    trackStats.activity = act;
    
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

-(void)compareStatsAssertEqual:(NSDictionary*)rv and:(NSDictionary*)expected withMessage:(NSString*)msg{
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
    [self compareStatsAssertEqual:rv and:expected withMessage:[NSString stringWithFormat:@"%@ %@", NSStringFromSelector(sel), label]];

}



@end
