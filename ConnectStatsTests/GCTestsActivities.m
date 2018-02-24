//
//  GCTestsActivities.m
//  GarminConnect
//
//  Created by Brice Rosenzweig on 20/10/2013.
//  Copyright (c) 2013 Brice Rosenzweig. All rights reserved.
//

#import "GCTestCase.h"
#import "GCActivitiesOrganizer.h"
#import "GCActivitiesCacheManagement.h"
#import "GCActivity+Calculated.h"
#import "GCAppGlobal.h"
#import <HealthKit/HealthKit.h>
#import "GCHealthKitActivityParser.h"
#import "GCActivity+Database.h"
#import "GCTrackStats.h"
#import "GCActivityThumbnails.h"
#import "GCFieldsForCategory.h"
#import "GCTrackFieldChoiceHolder.h"
#import "GCGarminUserJsonParser.h"
#import "GCActivity+CachedTracks.h"
#import "GCTestsHelper.h"

@interface GCTestsActivities : GCTestCase
@end

@implementation GCTestsActivities

- (void)setUp
{
    
    [super setUp];
}

- (void)tearDown
{
    
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - duplicate activities

-(void)testSearchDuplicateActivities{
    
    NSString * fname = [RZFileOrganizer bundleFilePath:@"activities_duplicate.db" forClass:[self class]];
    FMDatabase * db = [FMDatabase databaseWithPath:fname];
    [db open];

    GCActivitiesOrganizer * organizer = [[GCActivitiesOrganizer alloc] initTestModeWithDb:db];
    XCTAssertEqual(organizer.activities.count, 126, @"filtered duplicate properly");
    [organizer release];
}

#pragma mark - simulator db and tracks

// Way to run some test on all activities
// Disabled
-(void)disabledTestAllActivities{
    BOOL verbose = false;
    GCActivitiesCacheManagement * cache = [[[GCActivitiesCacheManagement alloc] init] autorelease];
    
    [cache analyze];
    NSUInteger i = 0;
    
    NSUInteger countDb = 0;
    NSUInteger countTotalTracks = 0;
    
    for (GCActivitiesCacheFileInfo * info in [cache.cacheFiles objectAtIndex:gcCacheFileActivityDb]) {
        FMDatabase * db = [FMDatabase databaseWithPath:[RZFileOrganizer writeableFilePath:info.filename]];
        [db open];
        [GCActivity ensureDbStructure:db];
        [GCWeather ensureDbStructure:db];
        
        GCActivitiesOrganizer * organizer = [[GCActivitiesOrganizer alloc] initTestModeWithDb:db];
        
        countDb++;
        NSUInteger countTracks = 0;
        NSMutableArray * tracksAvailable = [NSMutableArray arrayWithCapacity:5];
        for (GCActivity * activity in organizer.activities) {
            i++;
            if (verbose && i%100==0) {
                NSLog(@"%@:%d", info.filename,(int)i);
            }
            if ([activity hasTrackDb] ) {
                FMDatabase * trackdb = activity.trackdb;
                if (![activity trackdbIsObsolete:trackdb]) {
                    [activity loadTrackPointsFromDb:trackdb];
                    [tracksAvailable addObject:activity];
                    countTracks++;
                    countTotalTracks++;
                    if (countTotalTracks == 10) {
                        //DEBUG_BREAK();
                    }
                }
            }
        }
        if (verbose) {
            NSLog(@"%@:%d tracks", info.filename,(int)countTracks);
        }
        for (GCActivity * activity in tracksAvailable) {
            [self runActivityTest:activity file:info.filename];
        }
        
        
        [organizer release];
        [db close];
    }
    if (verbose) {
        NSLog(@"total tracks: %d", (int)countTotalTracks);
    }
    
}

-(void)runLapRecoveryTest:(GCActivity*)act laps:(NSArray*)laps{
    double dist = 0.;
    BOOL constant = true;
    for (NSUInteger i = 0; i<[laps count]-1; i++) {
        GCLap * lap = [laps objectAtIndex:i];
        if (dist == 0.) {
            dist = lap.distanceMeters;
        }else{
            if (fabs(dist-lap.distanceMeters)>1.e-6) {
                constant = false;
            }
        }
    }
    if (constant) {
        //373208472,203107435
        if (dist == 0.) {
            NSLog(@"0 dist laps %d for %@",(int)[laps count], act.activityId);
        }else{
            NSArray * calcLaps = [act calculatedLapFor:dist match:[act matchDistanceBlockGreater] inLap:GC_ALL_LAPS];
            if ([calcLaps count]!=[laps count]) {
                DEBUG_BREAK();
                calcLaps = [act calculatedLapFor:dist match:[act matchDistanceBlockGreater] inLap:GC_ALL_LAPS];
            }
            double maxDiff = 0.;
            for (NSUInteger i = 0; i<[laps count]-1; i++) {
                GCLap * clap = [calcLaps objectAtIndex:i];
                GCLap * olap = [laps objectAtIndex:i];
                double diff = fabs((clap.speed-olap.speed)/olap.speed);
                //XCTAssertEqualWithAccuracy(diff, 0., 0.05, @"%@/%@: Speed within 5sec/km %f==%f", act.activityId,act.activityType,clap.speed,olap.speed);
                if (diff > maxDiff) {
                    maxDiff = diff;
                }
            }
        }
    }
    
}

// Run on every activity in the current organizer
// Currently somewhat silly test, hard to know what
// Can be generically tested
-(void)runActivityTest:(GCActivity*)act file:(NSString*)fn{
    if (act.trackpoints) {
        GCField * speedField = [GCField fieldForFlag:gcFieldFlagWeightedMeanSpeed andActivityType:act.activityType];

        if ([act hasField:speedField]){
            GCStatsDataSerie * speed = [act timeSerieForField:speedField].serie;
            
            if ([act.activityType isEqualToString:GC_TYPE_CYCLING]||[act.activityType isEqualToString:GC_TYPE_RUNNING]){
                
                GCStatsDataSerie * orig = [act timeSerieForField:speedField].serie;
                // Most checks that it loads
                XCTAssertLessThanOrEqual(orig.count, act.trackpoints.count, @"same number of points %@",act.activityId);
            }
            //  DISABLED
            if (false && [act.activityType isEqualToString:GC_TYPE_CYCLING]) {
                NSArray * laps = [act laps];
                [self runLapRecoveryTest:act laps:laps];
            }
            
            if (speed.count > 1) {
                gcStatsRange range = [speed range];
                if (range.x_max!= 0. && range.x_min!=0.) {
                    if (fabs(range.x_max-range.x_min)<1e-7) {
                        NSLog(@"OOPS");
                    }
                    
                    XCTAssertNotEqualWithAccuracy(range.x_max, range.x_min, 1e-7, @"Got x range %@", act.activityId);
                    XCTAssertNotEqualWithAccuracy(range.y_max, range.y_min, 1e-7, @"Got y range %@", act.activityId);
                }
            }
            
        }
    }
}

#pragma mark - Fields

-(void)testFieldsCategories{
    NSArray * tests = @[
                        @"BeginLatitude",
                        @"BeginLongitude",
                        @"BeginPowerTwentyMinutesDistance",
                        @"BeginPowerTwentyMinutesTime",
                        @"BeginPowerTwentyMinutesTimerTime",
                        @"EndPowerTwentyMinutesDistance",
                        @"EndPowerTwentyMinutesTime",
                        @"EndPowerTwentyMinutesTimerTime",
                        @"GainElevation",
                        @"LossElevation",
                        @"MaxAirTemperature",
                        @"MaxBikeCadence",
                        @"MaxDoubleCadence",
                        @"MaxElevation",
                        @"MaxFractionalCadence",
                        @"MaxHeartRate",
                        @"MaxPace",
                        @"MaxPowerTwentyMinutes",
                        @"MaxRunCadence",
                        @"MaxSpeed",
                        @"MaxSwimCadence",
                        @"MinAirTemperature",
                        @"MinEfficiency",
                        @"MinElevation",
                        @"MinSpeed",
                        @"MinStrokes",
                        @"MinSwolf",
                        @"SumDistance",
                        @"SumDuration",
                        @"SumElapsedDuration",
                        @"SumEnergy",
                        @"SumIntensityFactor",
                        @"SumMovingDuration",
                        @"SumNumActiveLengths",
                        @"SumNumLengths",
                        @"SumPoolLength",
                        @"SumStep",
                        @"SumStrokes",
                        @"SumTotalWork",
                        @"SumTrainingEffect",
                        @"SumTrainingStressScore",
                        @"ThresholdPower",
                        @"WeightedMeanAirTemperature",
                        @"WeightedMeanBikeCadence",
                        @"WeightedMeanDoubleCadence",
                        @"WeightedMeanEfficiency",
                        @"WeightedMeanFractionalCadence",
                        @"WeightedMeanGroundContactTime",
                        @"WeightedMeanHeartRate",
                        @"WeightedMeanMovingPace",
                        @"WeightedMeanMovingSpeed",
                        @"WeightedMeanNormalizedPower",
                        @"WeightedMeanPace",
                        @"WeightedMeanPower",
                        @"WeightedMeanRightBalance",
                        @"WeightedMeanRunCadence",
                        @"WeightedMeanSpeed",
                        @"WeightedMeanStrideLength",
                        @"WeightedMeanStrokes",
                        @"WeightedMeanSwimCadence",
                        @"WeightedMeanSwolf",
                        @"WeightedMeanVerticalOscillation",
                        
                        @"UnkownField1",
                        @"UnknownField2"
                        ];
    
    RZRegressionManager * manager = [RZRegressionManager managerForTestClass:[self class]];
    //manager.recordMode =true;
    
    NSArray<GCFieldsForCategory*> * rv = [GCFields categorizeAndOrderFields:tests forActivityType:nil];
    NSArray<GCFieldsForCategory*> * expected = [manager retrieveReferenceObject:rv selector:_cmd identifier:@"List1" error:nil];
    
    XCTAssertEqual(expected.count, rv.count);
    
    for (NSUInteger i=0; i<MIN(rv.count, expected.count); i++) {
        XCTAssertEqualObjects(expected[i], rv[i], @"%lu: %@/%@", i, [expected[i] category], [rv[i] category]);
    }
    
    tests = @[ @"WeightedMeanHeartRate",
               @"WeightedMeanMovingPace",
               @"MinHeartRate",
               @"MinAirTemperature",
               @"MinCorrectedElevation",
               @"LossCorrectedElevation",
               @"MinSpeed",
               @"WeightedMeanAirTemperature",
               @"MinElevation",
               @"SumMovingDuration",
               @"SumStrokes",
               @"__CalcMaxDescentSpeed",
               @"__healthnone",
               @"MaxHeartRate",
               @"MaxDoubleCadence",
               @"SumTrainingEffect",
               @"SumElapsedDuration",
               @"__CalcVerticalSpeed",
               @"WeightedMeanRunCadence",
               @"MaxCorrectedElevation",
               @"SumStep",
               @"MaxElevation",
               @"MaxAirTemperature",
               @"__CalcMaxAscentSpeed",
               @"BeginLatitude",
               @"EndLatitude",
               @"GainElevation",
               @"WeightedMeanPace",
               @"WeightedMeanSpeed",
               @"LossUncorrectedElevation",
               @"MinRunCadence",
               @"MaxRunCadence",
               @"__CalcAscentSpeed",
               @"WeightedMeanStrideLength",
               @"MaxBikeCadence",
               @"SumDistance",
               @"__healthweight",
               @"GainCorrectedElevation",
               @"MinBikeCadence",
               @"MaxSpeed",
               @"__healthfat_free_mass",
               @"SumDuration",
               @"__CalcRotationDevelopment",
               @"__CalcDescentSpeed",
               @"MaxPace",
               @"BeginLongitude",
               @"WeightedMeanBikeCadence",
               @"LossElevation",
               @"WeightedMeanMovingSpeed",
               @"__healthfat_ratio",
               @"__healthfat_mass_weight",
               @"MinUncorrectedElevation",
               @"EndLongitude",
               @"__healthheart_rate",
               @"WeightedMeanDoubleCadence",
               @"MaxUncorrectedElevation",
               @"GainUncorrectedElevation",
               @"SumEnergy"
               ];
    
    rv = [GCFields categorizeAndOrderFields:tests forActivityType:nil];
    expected = [manager retrieveReferenceObject:rv selector:_cmd identifier:@"List2" error:nil];
    
    XCTAssertEqualObjects(expected, rv);


}


-(void)testHealthKitParsing{
    [RZFileOrganizer removeEditableFile:@"track___healthkit__20141003.db"];
    [RZFileOrganizer removeEditableFile:@"testHealthKitParsing.db"];
    NSString * testfn = [RZFileOrganizer writeableFilePath:@"testHealthKitParsing.db"];
    FMDatabase * db = [FMDatabase databaseWithPath:testfn];
    [db open];
    [GCActivitiesOrganizer ensureDbStructure:db];
    
    NSString * expectedId = @"__healthkit__Default_20141003";
    GCActivitiesOrganizer * organizer = [[GCActivitiesOrganizer alloc] initTestModeWithDb:db];
    
    HKQuantitySample * (^sample)(gcFieldFlag flag, double from, double elapsed, double value) = ^(gcFieldFlag flag, double from, double elapsed, double value){
        NSDate * fromdate = [[NSDate dateForRFC3339DateTimeString:@"2014-10-03T18:00:00.000Z"] dateByAddingTimeInterval:from];
        NSDate * todate = [fromdate dateByAddingTimeInterval:elapsed];
        HKQuantityType * type = nil;
        HKQuantity * quantity = nil;

        switch (flag) {
            case gcFieldFlagSumDistance:
                type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
                quantity = [HKQuantity quantityWithUnit:[HKUnit meterUnit] doubleValue:value];
                break;
            case gcFieldFlagCadence:
                type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
                quantity = [HKQuantity quantityWithUnit:[HKUnit countUnit] doubleValue:value];
                break;
            default:
                break;
        }
        HKQuantitySample * one = quantity ? [HKQuantitySample quantitySampleWithType:type quantity:quantity startDate:fromdate endDate:todate] :nil;
        return one;
    };
    
    NSDictionary * dict = @{ HKQuantityTypeIdentifierDistanceWalkingRunning: @[ sample(gcFieldFlagSumDistance, 0., 5., 10.) ] };

    [GCHealthKitActivityParser healthKitActivityParserWith:dict andOrganizer:organizer];
    
    XCTAssertEqualWithAccuracy([[organizer activityForId:expectedId] sumDistance], 10., 1.e-7);
    
    [organizer release];
    organizer = [[GCActivitiesOrganizer alloc] initTestModeWithDb:db];
    
    dict = @{ HKQuantityTypeIdentifierDistanceWalkingRunning: @[ sample(gcFieldFlagSumDistance, 5., 8., 15.) ] };
    
    [GCHealthKitActivityParser healthKitActivityParserWith:dict andOrganizer:organizer];
    XCTAssertEqualWithAccuracy([[organizer activityForId:expectedId] sumDistance], 25., 1.e-7);
}

-(void)testActivityStatsRunning{
    FMDatabase * t1 = [FMDatabase databaseWithPath:[RZFileOrganizer bundleFilePath:@"test_activity_running_837769405.db"
                                                                        forClass:[self class]]];
    [t1 open];
    
    GCActivity * act = [GCActivity fullLoadFromDb:t1];
    XCTAssertGreaterThan(act.trackpoints.count, 1);
    
    GCTrackStats * trackStats = [[GCTrackStats alloc] init];
    trackStats.activity = act;
    
    GCField * speedField = [GCField fieldForFlag:gcFieldFlagWeightedMeanSpeed andActivityType:act.activityType];
    GCField * hrField = [GCField fieldForFlag:gcFieldFlagWeightedMeanHeartRate andActivityType:act.activityType];
    
    [trackStats setupForField:speedField xField:hrField andLField:nil];
    GCStatsDataSerieWithUnit * hr = [act timeSerieForField:hrField];
    GCStatsDataSerieWithUnit * speed = [act timeSerieForField:speedField];
    
    XCTAssertNotEqual(hr.count, speed.count);
    XCTAssertEqual([trackStats dataSerie:0].count, [trackStats dataSerie:1].count);// got reduced to same set

}

-(void)testCompareActivitiesRunning{
    FMDatabase * db1 = [FMDatabase databaseWithPath:[RZFileOrganizer bundleFilePath:@"test_activity_running_1266384539.db" forClass:[self class]]];
    FMDatabase * db2 = [FMDatabase databaseWithPath:[RZFileOrganizer bundleFilePath:@"test_activity_running_828298988.db"  forClass:[self class]]];
    [db1 open];
    [db2 open];
    
    GCActivity * act = [GCActivity fullLoadFromDb:db1];
    GCActivity * compare = [GCActivity fullLoadFromDb:db2];
    
    // basic test the progress serie finishes on the right point
    GCStatsDataSerieWithUnit * su = [act progressSerie:true];
    GCStatsDataPoint * last = su.serie.lastObject;
    
    XCTAssertEqual([(NSDate*)[act.trackpoints.lastObject time] timeIntervalSinceDate:(NSDate*)[act.trackpoints.firstObject time]], last.x_data);
    XCTAssertEqual([act.trackpoints.lastObject distanceMeters], last.y_data);
    
    su = [act progressSerie:false];
    last = su.serie.lastObject;
    XCTAssertEqual([(NSDate*)[act.trackpoints.lastObject time] timeIntervalSinceDate:(NSDate*)[act.trackpoints.firstObject time]], last.y_data);
    XCTAssertEqual([act.trackpoints.lastObject distanceMeters], last.x_data);

    GCStatsDataSerieWithUnit * su2 = [compare progressSerie:false];
    
    GCStatsDataSerie * diff = [su.serie cumulativeDifferenceWith:su2.serie];
    
    
    
    NSLog(@"%@", diff);
    
}

-(void)testProfilesFromScratch{
    // Could Fail first time if the clear at the end wasn't executed (failure or while debugging)
    NSString * testPassword = @"__password_scratch__";
    NSString * testUsername = @"__username_scratch__";
    
    NSString * testPassword2 = @"__password_scratch_2__";
    NSString * testUsername2 = @"__username_scratch_2__";

    NSMutableDictionary * settings = [NSMutableDictionary dictionary];
    GCAppProfiles * profile = [GCAppProfiles profilesFromSettings:settings];
    
    XCTAssertEqualObjects([profile currentLoginNameForService:gcServiceGarmin], @"");
    XCTAssertEqualObjects([profile currentPasswordForService:gcServiceGarmin], @"");
    
    [profile setLoginName:testUsername forService:gcServiceGarmin];
    [profile setPassword:testPassword forService:gcServiceGarmin];
    
    XCTAssertEqualObjects([profile currentLoginNameForService:gcServiceGarmin], testUsername);
    XCTAssertEqualObjects([profile currentPasswordForService:gcServiceGarmin], testPassword);

    // changing login should get back no password
    [profile setLoginName:testUsername2 forService:gcServiceGarmin];
    XCTAssertEqualObjects([profile currentLoginNameForService:gcServiceGarmin], testUsername2);
    XCTAssertEqualObjects([profile currentPasswordForService:gcServiceGarmin], @"");
    
    [profile setPassword:testPassword2 forService:gcServiceGarmin];
    XCTAssertEqualObjects([profile currentLoginNameForService:gcServiceGarmin], testUsername2);
    XCTAssertEqualObjects([profile currentPasswordForService:gcServiceGarmin], testPassword2);
    
    // Switch back to first username, should retrieve all password from keychain
    [profile setLoginName:testUsername forService:gcServiceGarmin];
    XCTAssertEqualObjects([profile currentLoginNameForService:gcServiceGarmin], testUsername);
    XCTAssertEqualObjects([profile currentPasswordForService:gcServiceGarmin], testPassword);
    
    //Clear both password
    [profile setPassword:nil forService:gcServiceGarmin];
    [profile setLoginName:testUsername2 forService:gcServiceGarmin];
    [profile setPassword:nil forService:gcServiceGarmin];
    
}

-(void)testProfileUpgrade{
    
}

-(void)testProfilesFromExisting{
    NSString * testPassword = @"__password_existing__";
    NSString * testUsername = @"__username_existing__";
    
    NSDictionary * pdict = @{
                             CONFIG_PROFILES: [NSMutableArray arrayWithArray:@[
                                     [NSMutableDictionary dictionaryWithDictionary:@{
                                         PROFILE_LOGIN_NAME:testUsername,
                                         PROFILE_LOGIN_PWD:[testPassword mangledDataWithKey:MANGLE_KEY],
                                         PROFILE_NAME:@"Default",
                                         PROFILE_DBPATH:@"activities.db",
                                         PROFILE_FULL_DOWNLOAD_DONE:@(false),
                                         CONFIG_GARMIN_ENABLE:@(true)
                                         }]
                                     ]],
                             CONFIG_CURRENT_PROFILE: @(0)
                             };
    
    NSMutableDictionary * settings = [NSMutableDictionary dictionaryWithDictionary:pdict];
    
    GCAppProfiles * profile = [GCAppProfiles profilesFromSettings:settings];
    
    [profile serviceEnabled:gcServiceGarmin set:true];
    
    XCTAssertEqualObjects([profile currentPasswordForService:gcServiceGarmin], testPassword);
    
    NSMutableDictionary * saveDict = [NSMutableDictionary dictionary];
    [profile saveToSettings:saveDict];
    
    XCTAssertNotNil(saveDict[CONFIG_PROFILES]);
    NSMutableArray * retrievedProfileArray = saveDict[CONFIG_PROFILES];
    XCTAssertEqual(retrievedProfileArray.count, 1);
    if( retrievedProfileArray.count == 1){
        NSMutableDictionary * one = retrievedProfileArray[0];
        XCTAssertNil(one[PROFILE_LOGIN_PWD]);
    }
    
    GCAppProfiles * retrieved = [GCAppProfiles profilesFromSettings:saveDict];
    XCTAssertEqualObjects([retrieved currentLoginNameForService:gcServiceGarmin], testUsername);
    XCTAssertEqualObjects([retrieved currentPasswordForService:gcServiceGarmin], testPassword);
    
    // Should Clear password
    [retrieved setPassword:nil forService:gcServiceGarmin];
    
    XCTAssertEqualObjects([retrieved currentPasswordForService:gcServiceGarmin], @"");
}

-(void)testBucketVersusLaps{
    NSError * error = nil;
    
    NSString * fp = [RZFileOrganizer writeableFilePath:@"test_health_organizer.db"];
    [RZFileOrganizer removeEditableFile:@"test_health_organizer.db"];
    
    FMDatabase * db = [FMDatabase databaseWithPath:fp];
    [db open];
    [GCHealthOrganizer ensureDbStructure:db];
    GCHealthOrganizer * health = [[[GCHealthOrganizer alloc] initWithDb:db andThread:nil] autorelease];
    
    NSString * theString = [NSString stringWithContentsOfFile:[RZFileOrganizer bundleFilePath:@"user.json" forClass:[self class]] encoding:NSUTF8StringEncoding error:&error];
    XCTAssertNotNil(theString, @"Could read file without error %@", error);
    
    GCGarminUserJsonParser * parser = [[[GCGarminUserJsonParser alloc] initWithString:theString andEncoding:NSUTF8StringEncoding] autorelease];
    XCTAssertTrue(parser.success);
    
    [health registerZoneCalculators:parser.data];
    XCTAssertTrue(parser.success, @"JsonParser Success");
    
    FMDatabase * t1 = [FMDatabase databaseWithPath:[RZFileOrganizer bundleFilePath:@"test_activity_running_837769405.db"
                                                                        forClass:[self class]]];
    [t1 open];
    
    GCActivity * act = [GCActivity fullLoadFromDb:t1];
    
    // Important to disable filters, or number in serie don't match exactly trackpoints
    [act.settings disableFiltersAndAdjustments];
    
    XCTAssertGreaterThan(act.trackpoints.count, 1);
    
    GCTrackStats * trackStats = [[GCTrackStats alloc] init];
    trackStats.activity = act;
    
    GCField * hrField = [GCField fieldForFlag:gcFieldFlagWeightedMeanHeartRate andActivityType:act.activityType];
    
    GCTrackFieldChoiceHolder * holder = [GCTrackFieldChoiceHolder trackFieldChoice:hrField zone:[health zoneCalculatorForField:hrField]];
    [holder setupTrackStats:trackStats];
    
    NSArray * laps = [act compoundLapForZoneCalculator:[health zoneCalculatorForField:hrField]];
    GCStatsDataSerie * serie = trackStats.data.serie;
    
    XCTAssertEqual(laps.count, serie.count, @"Serie and Lap count matched");
    
    for (NSUInteger i=0; i<MIN(laps.count,serie.count); i++) {
        GCLap * lap = laps[i];
        GCStatsDataPoint * point = [serie dataPointAtIndex:i];
        XCTAssertEqualWithAccuracy(point.y_data, lap.elapsed, 1.e-5);
    }
    
    //NSLog(@"%@", trackStats.data.serie);
    //NSLog(@"%@", laps);

}

-(void)testActivityThumbnails{
    FMDatabase * t1 = [FMDatabase databaseWithPath:[RZFileOrganizer bundleFilePath:@"test_activity_running_837769405.db"
                                                                        forClass:[self class]]];
    [t1 open];
    
    GCActivity * act = [GCActivity fullLoadFromDb:t1];
    XCTAssertGreaterThan(act.trackpoints.count, 1);

    GCActivityThumbnails * thumbs = [[GCActivityThumbnails alloc] init];
    
    UIImage * img = [thumbs trackGraphFor:act andSize:CGSizeMake(150., 150.)];
    
    // Only works if current image has running activities
    //img = [thumbs historyPlotFor:@"SumDistance" activityType:@"running" andSize:CGSizeMake(150., 150.)];
    NSData * data = UIImagePNGRepresentation(img);
    NSString * imgname = [NSString stringWithFormat:@"thumb-graph.png"];
    [data writeToFile:[RZFileOrganizer writeableFilePath:imgname] atomically:YES];
    XCTAssertEqual(img.size.width, 150.);
    XCTAssertEqual(img.size.height, 150.);
    
    [thumbs release];
}

-(void)testActivityStatsDayHeartRate{
    FMDatabase * t1 = [FMDatabase databaseWithPath:[RZFileOrganizer bundleFilePath:@"test_activity_day___healthkit__20150622.db"
                                                                        forClass:[self class]]];
    [t1 open];
    
    GCActivity * act = [GCActivity fullLoadFromDb:t1];
    XCTAssertGreaterThan(act.trackpoints.count, 1);
    
    GCTrackStats * trackStats = [[GCTrackStats alloc] init];
    trackStats.activity = act;
    
    GCField * distField = [GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:act.activityType];
    GCField * hrField = [GCField fieldForFlag:gcFieldFlagWeightedMeanHeartRate andActivityType:act.activityType];
    
    [trackStats setupForField:distField xField:hrField andLField:nil];
    GCStatsDataSerieWithUnit * hr = [act timeSerieForField:hrField];
    GCStatsDataSerieWithUnit * dist = [act timeSerieForField:distField];

    
    GCStatsDataSerie * avg = [hr.serie movingAverageOrSumOf:dist.serie forUnit:60.*10. offset:0. average:NO];
    NSLog(@"%lu %lu %lu", (unsigned long)trackStats.data.count, (unsigned long)hr.count, (unsigned long)avg.count);
    [GCStatsDataSerie reduceToCommonRange:avg and:hr.serie];
    NSLog(@"%lu %lu %lu", (unsigned long)trackStats.data.count, (unsigned long)hr.serie.count, (unsigned long)avg.count);
    
    
}

-(void)testActivityCalculated{
    // https://www.strava.com/activities/744059200/overview
    // https://connect.garmin.com/modern/activity/1404395287
    FMDatabase * db = [FMDatabase databaseWithPath:[RZFileOrganizer bundleFilePath:@"test_activity_cycling_1404395287.db" forClass:[self class]]];
    [db open];
    
    GCActivity * act = [GCActivity fullLoadFromDb:db];
    // Before loading tracks, not there
    XCTAssertFalse([act hasField:[GCField fieldForKey:CALC_NONZERO_POWER andActivityType:act.activityType]]);
    
    XCTAssertNotNil(act.trackpoints);
    
    XCTAssertTrue([act hasField:[GCField fieldForKey:CALC_NONZERO_POWER andActivityType:act.activityType]]);

    RZRegressionManager * manager = [RZRegressionManager managerForTestClass:[self class]];
    //manager.recordMode =true;
    
    
    NSDictionary<GCField*,GCActivityCalculatedValue*>*calculated = act.calculatedFields;
    NSDictionary<GCField*,GCActivityCalculatedValue*>*expected = [manager retrieveReferenceObject:calculated selector:_cmd identifier:@"ActivityCalculated" error:nil];
    
    XCTAssertEqualObjects(calculated, expected);
    

}


@end
