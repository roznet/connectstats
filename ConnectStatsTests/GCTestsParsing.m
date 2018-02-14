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

@interface GCTestsParsing : GCTestCase

@end

@implementation GCTestsParsing


- (void)setUp {
    [super setUp];
    
}

- (void)tearDown {
    [super tearDown];
}

- (void)testParsingModern {
    NSString * file = [RZFileOrganizer bundleFilePath:@"activitytrack_718039360.json" forClass:[self class]];
    NSError * err = nil;
    NSString * string = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&err];
    
    GCGarminActivityDetailJsonParser * parser = [[GCGarminActivityDetailJsonParser alloc] initWithString:string andEncoding:NSUTF8StringEncoding];
    XCTAssertEqual(parser.trackPoints.count, 575);
    gcFieldFlag trackFlags = gcFieldFlagNone;
    
    GCActivity * act = [[GCActivity alloc] init];
    [act setActivityType:GC_TYPE_RUNNING];

    for (NSDictionary * one in parser.trackPoints) {
        GCTrackPoint * point = [[GCTrackPoint alloc] initWithDictionary:one forActivity:act];
        trackFlags |= point.trackFlags;
        [point release];
    }
    XCTAssertTrue( (trackFlags & gcFieldFlagWeightedMeanSpeed) == gcFieldFlagWeightedMeanSpeed);
}

-(void)testActivityParsingModern{
    // Add test for
    NSArray * activityIds = @[ @"1108367966", @"1108368135", @"1089803211", @"924421177"];;
    
    RZRegressionManager * manager = [RZRegressionManager managerForTestClass:[self class]];
    //manager.recordMode = true;
    
    for (NSString * aId in activityIds) {
        GCActivity * act = [GCGarminRequestActivityReload testForActivity:aId withFilesIn:[RZFileOrganizer bundleFilePath:nil forClass:[self class]]];
        [GCGarminActivityTrack13Request testForActivity:act withFilesIn:[RZFileOrganizer bundleFilePath:nil forClass:[self class]]];
        
        NSArray<GCField*>*fields = [act availableTrackFields];
        for (GCField * field in fields) {
            NSString * ident = [NSString stringWithFormat:@"%@_%@", aId, field.key];
            GCStatsDataSerieWithUnit * expected = [act timeSerieForField:field];
            GCStatsDataSerieWithUnit * retrieved = [manager retrieveReferenceObject:expected selector:_cmd identifier:ident error:nil];
            XCTAssertNotEqual(expected.count, 0, @"%@[%@] has points",aId,field.key);
            XCTAssertEqualObjects(expected, retrieved, @"%@[%@]: %@<>%@", aId, field.key, expected, retrieved);
        }
    }
    
    //NSLog(@"act %@", act);
}

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
    
    GCActivityTypes * types = [ GCActivityTypes activityTypes];
    XCTAssertEqualObjects([types activityTypeForKey:GC_TYPE_CYCLING], [types activityTypeForStravaType:@"Ride"]);
    
    GCFieldCache * cache = [GCFieldCache cacheWithDb:nil andLanguage:@"en"];
    
    NSData * data = [NSData dataWithContentsOfFile:[RZFileOrganizer bundleFilePath:@"modern_activity_types.json" forClass:[self class]]];
    NSArray * json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];

    NSMutableDictionary * byName = [NSMutableDictionary dictionary];
    NSMutableDictionary * byTypeId = [NSMutableDictionary dictionary];
    
    if([json isKindOfClass:[NSArray class]]){
        
        for (NSDictionary * one in json) {
            byName[one[@"typeKey"]] = one;
            byTypeId[one[@"typeId"]] = one;
        }
    }
    
    for (NSString * typeName in byName) {
        NSString * parent = @"MISSING";
        NSDictionary * sub = byName[typeName];
        NSString * parentId = sub[@"parentTypeId"];
        if( parentId){
            parent = byTypeId[parentId][@"typeKey"];
        }
        NSString * display = @"missing";
        if(parent){
            display = [cache infoForActivityType:typeName].displayName;
        }
        
        NSLog(@"%@ parent: %@ info: %@", typeName, parent, display);
    }
    NSLog(@"DONE");
}

-(void)testParseSearch{
    NSString * dbfp = [RZFileOrganizer writeableFilePath:@"test_parsingsearch.db"];
    [RZFileOrganizer removeEditableFile:@"test_parsingsearch.db"];
    FMDatabase * db = [FMDatabase databaseWithPath:dbfp];
    [db open];
    [GCActivitiesOrganizer ensureDbStructure:db];
    [GCHealthOrganizer ensureDbStructure:db];
    GCActivitiesOrganizer * organizer = [[[GCActivitiesOrganizer alloc] initTestModeWithDb:db] autorelease];
    GCHealthOrganizer * health = [[[GCHealthOrganizer alloc] initWithDb:db andThread:nil] autorelease];
    organizer.health = health;
    [GCGarminSearch testForOrganizer:organizer withFilesInPath:[RZFileOrganizer bundleFilePath:nil forClass:[self class]]];
    
    [GCWithingsBodyMeasures testForHealth:health withFilesIn:[RZFileOrganizer bundleFilePath:nil forClass:[self class]] forId:@"188427"];
    GCField * hf = [GCHealthMeasure healthFieldFromMeasureType:gcMeasureWeight];
    
    NSDictionary * rv = [organizer fieldsSeries:@[ @"WeightedMeanHeartRate", @"WeightedMeanPace", hf] matching:nil useFiltered:NO ignoreMode:gcIgnoreModeActivityFocus];
    
    RZRegressionManager * manager = [RZRegressionManager managerForTestClass:[self class]];
    //manager.recordMode = true;

    NSDictionary * expected = [manager retrieveReferenceObject:rv selector:_cmd identifier:@"timeSeries" error:nil ];
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

-(void)testParseLaps{
    
    // Swimming activity
    NSString * activityId = @"1027746730";//@"1378220136";
    
    NSString * fn = [NSString stringWithFormat:@"activity_%@.json", activityId];
    NSData * data = [NSData dataWithContentsOfFile:[RZFileOrganizer bundleFilePath:fn forClass:[self class]] options:0 error:nil];
    
    NSDictionary * json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    GCActivity * modernAct = [[[GCActivity alloc] initWithId:activityId andGarminData:json] autorelease];
    
    fn = [NSString stringWithFormat:@"activitylaps_%@.json", activityId];
    data = [NSData dataWithContentsOfFile:[RZFileOrganizer bundleFilePath:fn forClass:[self class]]];
    GCGarminActivityLapsParser * lapsparser = [[[GCGarminActivityLapsParser alloc] initWithData:data forActivity:modernAct] autorelease];
    
    fn = [NSString stringWithFormat:@"activitytrack_%@.json", activityId];
    data = [NSData dataWithContentsOfFile:[RZFileOrganizer bundleFilePath:fn forClass:[self class]]];
    GCGarminActivityDetailJsonParser * trackparser = [[[GCGarminActivityDetailJsonParser alloc] initWithData:data] autorelease];
    
    XCTAssertGreaterThan(trackparser.trackPoints.count, 1);
    XCTAssertGreaterThan(lapsparser.lapsSwim.count, 1);
    XCTAssertGreaterThan(lapsparser.trackPointSwim.count, 1);
}

-(void)testParseAndCompare{
    
    
    NSData * searchLegacyInfo = [NSData  dataWithContentsOfFile:[RZFileOrganizer bundleFilePath:@"last_search_modern.json"
                                                                                       forClass:[self class]]];
    NSData * searchModernInfo = [NSData dataWithContentsOfFile:[RZFileOrganizer bundleFilePath:@"activities_list_modern.json"
                                                                                      forClass:[self class]]];
    NSData * searchStravaInfo =[NSData dataWithContentsOfFile:[RZFileOrganizer bundleFilePath:@"strava_list_0.json"
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

-(void)testOrganizerRegister{
    NSData * searchLegacyInfo = [NSData  dataWithContentsOfFile:[RZFileOrganizer bundleFilePath:@"last_search_modern.json"
                                                                                       forClass:[self class]]];
    
    GCGarminSearchJsonParser * parser=[[[GCGarminSearchJsonParser alloc] initWithData:searchLegacyInfo] autorelease];

    NSArray<GCActivity*>* activityFirstHalf = [parser.activities subarrayWithRange:NSMakeRange(0, 10)];
    NSArray<GCActivity*>* activitySubFirstHalf = [parser.activities subarrayWithRange:NSMakeRange(2, 8)];
    NSArray<GCActivity*>* activitySecondHalf = [parser.activities subarrayWithRange:NSMakeRange(10, 10)];
    
    NSString * dbn = [RZFileOrganizer writeableFilePath:@"test_organizer_register.db"];
    [RZFileOrganizer removeEditableFile:@"test_organizer_register.db"];
    FMDatabase * db = [FMDatabase databaseWithPath:dbn];
    [db open];
    [GCActivitiesOrganizer ensureDbStructure:db];
    
    GCActivitiesOrganizer * organizer = [[GCActivitiesOrganizer alloc] initTestModeWithDb:db];
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
    
    GCActivitiesOrganizer * reloaded = [[GCActivitiesOrganizer alloc] initTestModeWithDb:db];
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

-(void)testParseFitFile{
    NSDictionary * epsForField = @{
                                   @"SumEnergy": @(1.),
                                   @"SumElapsedDuration": @(0.02),
                                   @"SumDuration":@(0.02),
                                   @"MaxSpeed":@(0.0001),
                                   @"WeightedMeanAirTemperature": @(0.1),
                                   @"MinSpeed":@(0.5),
                                   // somehow some non sensical values:
                                   @"MinHeartRate":@(100),
                                   @"MinAirTemperature":@(50),
                                   };
    
    NSDictionary * expectedMissing = @{
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
                                       
                                       };
    
    // Ski Activity
    NSString * aId = @"1083407258";
    
    GCActivity * act = [GCGarminRequestActivityReload testForActivity:aId withFilesIn:[RZFileOrganizer bundleFilePath:nil forClass:[self class]]];
    [GCGarminActivityTrack13Request testForActivity:act withFilesIn:[RZFileOrganizer bundleFilePath:nil forClass:[self class]]];
    
    NSString * fn = [RZFileOrganizer bundleFilePath:[NSString stringWithFormat:@"activity_%@.fit", aId] forClass:[self class]];
    
    FITFitFileDecode * fitDecode = [FITFitFileDecode fitFileDecodeForFile:fn];
    [fitDecode parse];
    GCActivity * fitAct = [[GCActivity alloc] initWithId:aId fitFile:fitDecode.fitFile];
    
    NSDictionary * sum_gc = act.summaryData;
    NSDictionary * sum_fit= fitAct.summaryData;
    
    NSDictionary * expectedMissingFromGC = @{@"WeightedMeanCadence":@1, @"MaxCadence":@2, @"WeightedMeanElevation":@3,@"MinCadence":@4,
                                             @"MinElevation":@5,@"MaxElevation":@6,// elevation is all messed up (elevation correction)
                                             @"total_cycles":@7,@"enhanced_max_speed":@8,@"avg_step_length":@9
                                             };
    
    for (GCField * field in sum_fit) {
        if( expectedMissingFromGC[field.key] != nil){
            continue;// Somehow missing from gc
        }
        GCActivitySummaryValue * v_gc = sum_gc[field];
        GCActivitySummaryValue * v_fit= sum_fit[field];
        
        XCTAssertNotNil(v_gc, @"Found field %@", field);
        double eps =  1.e-7;
        NSNumber * specialEps = epsForField[field.key];
        if (specialEps) {
            eps = specialEps.doubleValue;
        }
        
        if( v_gc == nil || [v_gc.numberWithUnit compare:v_fit.numberWithUnit withTolerance:eps] != NSOrderedSame ){
            //SetBreakpoint
        }
        XCTAssertTrue([v_gc.numberWithUnit compare:v_fit.numberWithUnit withTolerance:eps] == NSOrderedSame,
                      @"Key %@: %@ == %@ within %@", field, v_gc.numberWithUnit, v_fit.numberWithUnit, @(eps));
    }
    
    for (GCField * field in sum_gc) {
        GCActivitySummaryValue * v_gc = sum_gc[field];
        GCActivitySummaryValue * v_fit= sum_fit[field];
        XCTAssertTrue(v_fit != nil || expectedMissing[field.key]!=nil, @"%@ %@ unexpectedly missing", field, v_gc);
    }
}

-(void)testHealthCollected{
    /*
    NSMutableDictionary * dict = [NSKeyedUnarchiver unarchiveObjectWithFile:[RZFileOrganizer bundleFilePath:@"collected.plist" forClass:[self class]]];
    NSLog(@"%@", dict);
    NSLog(@"%d", (int)dict.count);
     */
}


@end
