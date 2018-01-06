//
//  HealthStatsTests.m
//  HealthStatsTests
//
//  Created by Brice Rosenzweig on 07/06/2015.
//  Copyright (c) 2015 Brice Rosenzweig. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <HealthKit/HealthKit.h>
#import "RZUtils/RZUtils.h"
#import "GCHealthKitWorkoutParser.h"
#import "GCHealthKitDailySummaryParser.h"
#import "GCHealthKitDayDetailParser.h"
#import "GCActivity.h"
#import "GCAppGlobal.h"
#import "GCActivitiesOrganizer.h"

@interface HealthStatsTests : XCTestCase

@end

@implementation HealthStatsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testWorkoutParser{
    NSString * fn = [RZFileOrganizer writeableFilePathIfExists:@"last_workout_parser.data"];
    if (fn) {
        NSObject * read = [NSKeyedUnarchiver unarchiveObjectWithFile:fn];
        if( [read isKindOfClass:[GCHealthKitWorkoutParser class]] ){
            GCHealthKitWorkoutParser * parser = (GCHealthKitWorkoutParser*)read;
            [parser parse:^(GCActivity * act, NSString * aId){
                NSLog(@"%@", act);
            }];
        }
    }
}

- (void)testExample {
    // This is an example of a functional test case.

    NSString * fn = [RZFileOrganizer bundleFilePath:@"health_workout_0.data" forClass:[self class]];
    NSDictionary * workout = [NSKeyedUnarchiver unarchiveObjectWithFile:fn];
    fn = [RZFileOrganizer bundleFilePath:@"health_daysummary_20150620.data" forClass:[self class]];
    NSDictionary * daysummary = [NSKeyedUnarchiver unarchiveObjectWithFile:fn];
    fn = [RZFileOrganizer bundleFilePath:@"health_daydetail_20150618.data" forClass:[self class]];
    NSDictionary * daydetail = [NSKeyedUnarchiver unarchiveObjectWithFile:fn];
    
    NSMutableArray * workouts = [NSMutableArray array];
    FMDatabase * db = [FMDatabase databaseWithPath:[RZFileOrganizer writeableFilePath:@"test_healthstat.db"]];
    [db open];
    [GCActivitiesOrganizer ensureDbStructure:db];
    GCActivitiesOrganizer * organizer = [[GCActivitiesOrganizer alloc] initTestModeWithDb:db];
    //F752F959-3B3C-4A32-BBE4-96C2592153F5
    GCHealthKitWorkoutParser * wparser = [GCHealthKitWorkoutParser parserWithWorkouts:workout[@"r"] andSamples:workout[@"s"]];
    [wparser parse:^(GCActivity*act,NSString*aId){
        [organizer registerTemporaryActivity:act forActivityId:aId];

        [workouts addObject:act];
    }];
    NSMutableArray * days = [NSMutableArray array];
    __block GCActivity * dact = nil;
    
    // In samples:
    //<HKSource:0x7f8d486fbc10 "Health" (com.apple.Health)>,
    //<HKSource:0x7f8d4d126c70 "Yi's Apple Watch" (com.apple.health.9152B44B-A249-48BC-BAF2-C345F1508C17)>,
    //<HKSource:0x7f8d48663a20 "iPhone" (com.apple.health.D9628BC6-5F94-4CB0-BA6E-F8F0868B7A52)>,
    //<HKSource:0x7f8d4d126bb0 "HealthStats" (net.ro-z.healthstats)>

    gcServiceSourceValidator validator = ^(NSString*s){
        return [s hasPrefix:@"com.apple.health.9"];
    };
    GCHealthKitDailySummaryParser * sparser = [GCHealthKitDailySummaryParser parserWithSamples:daysummary];
    sparser.sourceValidator = validator;
    [sparser parse:^(GCActivity*act,NSString*aId){
        if ([aId hasSuffix:@"20150618"]) {
            dact = act;
        }
        [days addObject:act];
        [organizer registerTemporaryActivity:act forActivityId:aId];
    }];

    GCHealthKitDayDetailParser * dparser = [GCHealthKitDayDetailParser parserWithSamples:daydetail];
    dparser.sourceValidator = validator;
    [dparser parse:^(NSArray*points){
        [dact saveTrackpoints:points andLaps:nil];
    }];
    /*
    GCStatsDataSerieWithUnit * dayhr = [dact timeSerieForTrackField:gcFieldFlagWeightedMeanHeartRate];
    GCStatsDataSerieWithUnit * daysp = [dact timeSerieForTrackField:gcFieldFlagWeightedMeanSpeed];
    GCStatsDataSerieWithUnit * dayst = [dact timeSerieForTrackField:gcFieldFlagSumStep];
    GCStatsDataSerieWithUnit * dayca = [dact timeSerieForTrackField:gcFieldFlagCadence];
    */
    NSLog(@"do");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

-(void)testProfileSource{
    NSString * s_apple1 = @"com.apple.1";
    NSString * s_apple2 = @"com.apple.2";
    NSString * s_connect = @"net.ro-z.connectstats";
    NSString * s_health  = @"net.ro-z.healthstats";
    
    NSString * n_apple = @"iPhone";
    NSString * n_connect = @"ConnectStats";
    NSString * n_health = @"HealthStats";
    
    GCAppProfiles * profile = [GCAppProfiles profilesFromSettings:[NSMutableDictionary dictionary]];
    [profile registerSource:s_apple1 withName:n_apple];
    [profile registerSource:s_connect withName:n_connect];
    [profile setCurrentSource:s_apple1];
    XCTAssertEqualObjects( [profile sourceName:s_apple1], n_apple );
    XCTAssertEqual([[profile availableSources] count], 2);
    XCTAssertEqualObjects([profile sourceName:[profile currentSource]], n_apple);

    // Register same again: no changes
    [profile registerSource:s_apple1 withName:n_apple];
    XCTAssertEqualObjects( [profile sourceName:s_apple1], n_apple );
    XCTAssertEqual([[profile availableSources] count], 2);
    XCTAssertNil([profile sourceName:s_health]);
    
    // Register new one: added
    [profile registerSource:s_health withName:n_health];
    XCTAssertEqual([[profile availableSources] count], 3);
    XCTAssertEqualObjects([profile sourceName:s_health], n_health);
    XCTAssertEqualObjects([profile sourceName:[profile currentSource]], n_apple);
    
    // Register same name, different identifier (currentSource): changes identifier and currentSource
    [profile registerSource:s_apple2 withName:n_apple];
    XCTAssertEqual([[profile availableSources] count], 3);
    XCTAssertEqualObjects([profile sourceName:s_apple2], n_apple);
    XCTAssertNil([profile sourceName:s_apple1]);//apple 1 is gone
    XCTAssertEqualObjects([profile sourceName:[profile currentSource]], n_apple);// current source still apple
    
}

@end
