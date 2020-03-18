//
//  GarminConnectTests.m
//  GarminConnectTests
//
//  Created by Brice Rosenzweig on 02/09/2012.
//  Copyright (c) 2012 Brice Rosenzweig. All rights reserved.
//  $Id$

#import "GCTestCase.h"
#import "GCGarminSearchJsonParser.h"
#import "GCActivitiesOrganizer.h"
#import "GCActivitySearch.h"
#import "GCHistoryAggregatedActivityStats.h"
#import "GCAppProfiles.h"
#import "GCActivity+Calculated.h"
#import "GCFieldsCalculated.h"
#import "GCActivityCalculatedValue.h"
#import "GCActivitiesCacheManagement.h"
#import "GCAppGlobal.h"
#import "GCHistoryFieldDataSerie.h"
#import "GCViewIcons.h"
#import "GCTrackFieldChoices.h"
#import "GCSimpleGraphCachedDataSource+Templates.h"
#import "GCWebConnect.h"
#import "GCTestsSamples.h"
#import "GCHistoryFieldSummaryStats.h"
#import "GCActivity+CachedTracks.h"
#import "GCHistoryPerformanceAnalysis.h"
#import "GCActivity+Fields.h"
#import "GCTestsHelper.h"
#import "GCActivity+Database.h"
#import "GCActivity+Import.h"

#import "GCActivity+TestBackwardCompat.h"

@interface GCTestsGeneral : GCTestCase
@end

#define EPS 1e-10

#define FAST_MODE 1


@implementation GCTestsGeneral

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{

    [super tearDown];
}

#pragma mark - Helpers

-(GCActivity*)buildActivityWithTrackpoints:(NSArray*)defs{
    GCActivity * act= [[[GCActivity alloc] init] autorelease];
    NSMutableArray * tracks = [NSMutableArray arrayWithCapacity:100];

    double dist = 0.;
    NSDate * time = [NSDate date];
    NSUInteger lapIndex = 0;
    for (NSDictionary * def in defs) {
        double speed = [[def objectForKey:@"speed"] doubleValue];
        NSUInteger n = [[def objectForKey:@"n"] integerValue];
        double hr    = [[def objectForKey:@"hr"] doubleValue];
        double elapsed = [[def objectForKey:@"elapsed"] doubleValue];
        
        for (NSUInteger i = 0; i<n; i++) {
            time= [time dateByAddingTimeInterval:elapsed];
            GCTrackPoint * point = [[GCTrackPoint alloc] init];
            dist += speed*elapsed;
            point.distanceMeters = dist;
            point.time = time;
            point.speed = speed;
            point.heartRateBpm = hr;
            point.lapIndex = lapIndex;
            point.trackFlags = gcFieldFlagWeightedMeanHeartRate|gcFieldFlagWeightedMeanSpeed;
            
            [tracks addObject:point];
            [point release];
        }
        lapIndex++;
    }
    [act setTrackpoints:tracks];
    return act;
}

-(GCActivitySummaryValue*)sumVal:(NSString*)k val:(double)val uom:(NSString*)uom{
    GCActivitySummaryValue * rv = [[[GCActivitySummaryValue alloc] init] autorelease];
    rv.numberWithUnit = [GCNumberWithUnit numberWithUnitName:uom andValue:val];
    rv.field = k;
    return rv;
}

-(void)addDummyActivity:(double)val andDate:(NSDate*)date in:(GCActivitiesOrganizer*)organizer{
    NSMutableArray * tmp = [NSMutableArray arrayWithArray:[organizer activities]];
    GCActivity * act = [[GCActivity alloc] init];
    act.activityId = [NSString stringWithFormat:@"Test_%@_%@", GC_TYPE_RUNNING, date.YYYYMMDD];
    [act setDate:date];
    [act setSumDistanceCompat:val];
    [act setSumDurationCompat:val*2.];
    [act setWeightedMeanHeartRateCompat:val*3.];
    [act setWeightedMeanSpeedCompat:val*4.];
    [act setFlags:gcFieldFlagSumDistance+gcFieldFlagSumDuration+gcFieldFlagWeightedMeanHeartRate+gcFieldFlagWeightedMeanSpeed];
    [act setActivityType:GC_TYPE_RUNNING];
    
    [act setSummaryDataFromKeyDict:@{     @"SumDuration" :           [self sumVal:@"SumDuration"             val:act.sumDurationCompat             uom:@"second" ],
                             @"SumDistance" :           [self sumVal:@"SumDistance"             val:act.sumDistanceCompat            uom:@"meter" ],
                             @"WeightedMeanHeartRate":  [self sumVal:@"WeightedMeanHeartRate"   val:act.weightedMeanHeartRateCompat   uom:@"bpm"  ],
                             }];
    
    [tmp addObject:act];
    [act release];
    
    act = [[GCActivity alloc] init];
    act.activityId = [NSString stringWithFormat:@"Test_%@_%@", GC_TYPE_CYCLING, date.YYYYMMDD];
    [act setDate:date];
    [act setSumDistanceCompat:val*5.];
    [act setSumDurationCompat:val*6.];
    [act setWeightedMeanHeartRateCompat:val*7.];
    [act setWeightedMeanSpeedCompat:val*8.];
    [act setFlags:gcFieldFlagSumDistance+gcFieldFlagSumDuration+gcFieldFlagWeightedMeanHeartRate+gcFieldFlagWeightedMeanSpeed];
    [act setActivityType:GC_TYPE_CYCLING];
    
    [act setSummaryDataFromKeyDict:@{     @"SumDuration" :           [self sumVal:@"SumDuration"             val:act.sumDurationCompat             uom:@"second" ],
                             @"SumDistance" :           [self sumVal:@"SumDistance"             val:act.sumDistanceCompat             uom:@"meter" ],
                             @"WeightedMeanHeartRate":  [self sumVal:@"WeightedMeanHeartRate"   val:act.weightedMeanHeartRateCompat   uom:@"bpm"  ],
                             }];

    [tmp addObject:act];
    [act release];
    [organizer setActivities:[NSArray arrayWithArray:tmp]];
}




#pragma mark - GCActivity

-(GCField*)fldFor:(NSString*)key act:(GCActivity*)act{
    return [GCField fieldForKey:key andActivityType:act.activityType];
}

-(void)testCalculatedFields{
    GCActivity * act = [[GCActivity alloc] init];
    act.activityType = GC_TYPE_CYCLING;
    
    [act updateSummaryData:@{
                           [self fldFor:@"SumDuration" act:act] :              [self sumVal:@"SumDuration"             val:3       uom:@"second" ],
                           [self fldFor:@"WeightedMeanPower" act:act]:         [self sumVal:@"WeightedMeanPower"       val:3000    uom:@"watt" ],
                           [self fldFor:@"WeightedMeanSpeed" act:act]:         [self sumVal:@"WeightedMeanSpeed"       val:10.8    uom:@"kph" ],
                           [self fldFor:@"WeightedMeanRunCadence" act:act]:    [self sumVal:@"WeightedMeanRunCadence"  val:90      uom:@"stepsPerMinute" ]
                           }
     ];
    GCFieldCalcKiloJoules * kj = [[GCFieldCalcKiloJoules alloc] init];
    GCFieldCalcStrideLength * sl = [[GCFieldCalcStrideLength alloc] init];
    GCActivityCalculatedValue * rv = nil;

    rv = [kj evaluateForActivity:act];
    XCTAssertEqualObjects(rv.uom, @"kilojoule", @"Right unit");
    XCTAssertEqualWithAccuracy(rv.value, 9., 1.e-7, @"sample is 9");

    rv = [sl evaluateForActivity:act];
    XCTAssertNil(rv, @"Computing Run Calc Field on cycle activity");
    
    act.activityType = GC_TYPE_RUNNING; // Stride only valid for running
    [act updateSummaryData:@{
                          [self fldFor:@"SumDuration" act:act] :              [self sumVal:@"SumDuration"             val:3       uom:@"second" ],
                          [self fldFor:@"WeightedMeanSpeed" act:act]:         [self sumVal:@"WeightedMeanSpeed"       val:10.8    uom:@"kph" ],
                          [self fldFor:@"WeightedMeanRunCadence" act:act]:    [self sumVal:@"WeightedMeanRunCadence"  val:90      uom:@"stepsPerMinute" ]
                          }
     ];
    
    rv = [sl evaluateForActivity:act];
    XCTAssertEqualObjects(rv.uom, @"stride", @"Right unit for stride length");
    XCTAssertEqualWithAccuracy(rv.value, 2., 1.e-7, @"sample is 2 meters");

    [GCFieldsCalculated addCalculatedFields:act];
    //ToTest
    //XCTAssertTrue([act hasField:[sl field]], @"stride there");
    //XCTAssertTrue([act hasField:[kj field]], @"kj there");
    GCNumberWithUnit * v_sl = [act numberWithUnitForFieldKey:[sl fieldKey]];
    GCNumberWithUnit * v_kj = [act numberWithUnitForFieldKey:[kj fieldKey]];
    
    XCTAssertNil(v_kj);// SHould not be there (no power)
    XCTAssertEqualWithAccuracy(v_sl.value, 2., 1.e-7, @"sl sample");
    
    
    [kj release];
    [sl release];
    
    [act release];
    
}


-(void)testCalculatedFieldsTrackPoints{
    GCActivity * act = [[GCActivity alloc] init];
    [act setActivityType:GC_TYPE_RUNNING];
    NSDictionary * d = @{ @"averageRunCadence": @180.0,
                          @"duration": @"3.",
                          @"averageSpeed": @3.,
                          @"averagePower": @3000.0,
                          @"calories":@"9.",
                          @"startTimeGMT":@"2016-03-13T12:46:19.0"
                          
                          };
    
    GCLap * trackpoint = [[GCLap alloc] initWithDictionary:d forActivity:act];
    
    GCFieldCalcStrideLength * sl = [[GCFieldCalcStrideLength alloc] init];
    GCFieldCalcKiloJoules * kj = [[GCFieldCalcKiloJoules alloc] init];
    GCFieldCalcMetabolicEfficiency * me = [[GCFieldCalcMetabolicEfficiency alloc] init];
    
    GCActivityCalculatedValue * v_sl = [sl evaluateForTrackPoint:trackpoint inActivity:act];
    GCActivityCalculatedValue * v_kj = [kj evaluateForTrackPoint:trackpoint inActivity:act];
    GCActivityCalculatedValue * v_me = [me evaluateForTrackPoint:trackpoint inActivity:act];
    
    XCTAssertEqualObjects(v_sl.uom, @"stride", @"Right unit for stride length");
    XCTAssertEqualWithAccuracy(v_sl.value, 2., 1.e-7, @"sample is 2 meters");
    
    XCTAssertEqualObjects(v_kj.uom, @"kilojoule", @"Right unit");
    XCTAssertEqualWithAccuracy(v_kj.value, 9., 1.e-7, @"sample is 9");

    XCTAssertEqualObjects(v_me.uom, @"percent", @"Right unit");
    XCTAssertEqualWithAccuracy(v_me.value, 23.9005736, 1.e-3, @"sample is .239");

    
    [sl release];
    [kj release];
    [me release];
    [trackpoint release];
    
}


-(void)testAggregateActivities{
    GCActivitiesOrganizer * organizer = [[GCActivitiesOrganizer alloc] init];
    NSDictionary * sample  = [GCTestsSamples aggregateSample];
    NSDictionary * expected =[GCTestsSamples aggregateExpected];
    // Create one running/one cycling with distance = val, time = val *2, etc
    for (NSString * datestr in sample) {
        NSNumber * val = [sample objectForKey:datestr];
        [self addDummyActivity:[val doubleValue] andDate:[NSDate dateForRFC3339DateTimeString:datestr] in:organizer];
    }
    organizer.activities = [organizer.activities sortedArrayUsingComparator:^(GCActivity * o1,GCActivity* o2){ return [o2.date compare:o1.date]; }];
    GCStatsDataSerie * e_avg = [[[GCStatsDataSerie alloc] init] autorelease];
    GCStatsDataSerie * e_sum = [[[GCStatsDataSerie alloc] init] autorelease];
    GCStatsDataSerie * e_max = [[[GCStatsDataSerie alloc] init] autorelease];
    for (NSString * datestr in expected) {
        NSDate * d = [NSDate dateForRFC3339DateTimeString:datestr];
        NSArray * a = [expected objectForKey:datestr];
        [e_avg addDataPointWithDate:d andValue:[[a objectAtIndex:0] doubleValue]];
        [e_sum addDataPointWithDate:d andValue:[[a objectAtIndex:1] doubleValue]];
        [e_max addDataPointWithDate:d andValue:[[a objectAtIndex:2] doubleValue]];
    }
    [e_avg sortByReverseDate];
    [e_sum sortByReverseDate];
    [e_max sortByReverseDate];
    
    GCHistoryAggregatedActivityStats * stats = [[GCHistoryAggregatedActivityStats alloc] init];
    [stats setActivitiesFromOrganizer:organizer];
    [stats setActivityType:GC_TYPE_RUNNING];
    [stats aggregate:NSCalendarUnitWeekOfYear referenceDate:nil ignoreMode:gcIgnoreModeActivityFocus];
    XCTAssertEqual([e_avg count], [stats count], @"Count");
    
    NSDateFormatter * formatter = [[[NSDateFormatter alloc] init] autorelease];
    NSTimeZone * tz = [NSTimeZone timeZoneWithName:@"GMT"];
    [formatter setTimeZone:tz];
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    NSCalendar * cal = [NSCalendar currentCalendar];
    
    for(NSUInteger i = 0; i<[e_avg count];i++){
        
        GCHistoryAggregatedDataHolder * holder = [stats dataForIndex:i];
        if (![[holder date] isSameCalendarDay:[[e_avg dataPointAtIndex:i] date] calendar:cal]) {
            NSLog(@"%d: %@!=%@",(int)i,[holder date], [[e_avg dataPointAtIndex:i] date]);
        }
        XCTAssertTrue([[holder date] isSameCalendarDay:[[e_avg dataPointAtIndex:i] date] calendar:cal], @"same date avg %@ %@", [holder date], [[e_avg dataPointAtIndex:i] date] );
        gcAggregatedField f = gcAggregatedSumDistance;
        double x = 1.;
        XCTAssertEqualWithAccuracy([holder valFor:f and:gcAggregatedAvg], [[e_avg dataPointAtIndex:i] y_data]*x, 1e-6, @"Same Average");
        XCTAssertEqualWithAccuracy([holder valFor:f and:gcAggregatedSum], [[e_sum dataPointAtIndex:i] y_data]*x, 1e-6, @"Same sum");
        XCTAssertEqualWithAccuracy([holder valFor:f and:gcAggregatedMax], [[e_max dataPointAtIndex:i] y_data]*x, 1e-6, @"Same max");
        
        f = gcAggregatedSumDuration;
        x = 2.;
        XCTAssertEqualWithAccuracy([holder valFor:f and:gcAggregatedAvg], [[e_avg dataPointAtIndex:i] y_data]*x, 1e-6, @"Same Average");
        XCTAssertEqualWithAccuracy([holder valFor:f and:gcAggregatedSum], [[e_sum dataPointAtIndex:i] y_data]*x, 1e-6, @"Same sum");
        XCTAssertEqualWithAccuracy([holder valFor:f and:gcAggregatedMax], [[e_max dataPointAtIndex:i] y_data]*x, 1e-6, @"Same max");

        f = gcAggregatedWeightedHeartRate;
        x = 3.;
        XCTAssertEqualWithAccuracy([holder valFor:f and:gcAggregatedAvg], [[e_avg dataPointAtIndex:i] y_data]*x, 1e-6, @"Same Average");
        XCTAssertEqualWithAccuracy([holder valFor:f and:gcAggregatedSum], [[e_sum dataPointAtIndex:i] y_data]*x, 1e-6, @"Same sum");
        XCTAssertEqualWithAccuracy([holder valFor:f and:gcAggregatedMax], [[e_max dataPointAtIndex:i] y_data]*x, 1e-6, @"Same max");
        
        f = gcAggregatedWeightedSpeed;
        x = 4.;
        XCTAssertEqualWithAccuracy([holder valFor:f and:gcAggregatedAvg], [[e_avg dataPointAtIndex:i] y_data]*x, 1e-6, @"Same Average");
        XCTAssertEqualWithAccuracy([holder valFor:f and:gcAggregatedSum], [[e_sum dataPointAtIndex:i] y_data]*x, 1e-6, @"Same sum");
        XCTAssertEqualWithAccuracy([holder valFor:f and:gcAggregatedMax], [[e_max dataPointAtIndex:i] y_data]*x, 1e-6, @"Same max");
    }
    
    [stats setActivityType:GC_TYPE_ALL];
    [stats aggregate:NSCalendarUnitWeekOfYear referenceDate:nil ignoreMode:gcIgnoreModeActivityFocus];

    GCHistoryFieldSummaryStats * sumStats = [GCHistoryFieldSummaryStats fieldStatsWithActivities:organizer.activities matching:nil referenceDate:nil ignoreMode:gcIgnoreModeActivityFocus];
    GCHistoryAggregatedDataHolder * holder = [stats dataForIndex:0];
    
    GCField * hrfield =[GCField fieldForFlag:gcFieldFlagWeightedMeanHeartRate andActivityType:GC_TYPE_ALL];
    
    XCTAssertEqualWithAccuracy([holder valFor:gcAggregatedWeightedHeartRate and:gcAggregatedAvg],
                               [[sumStats dataForField:hrfield] averageWithUnit:gcHistoryStatsWeek].value,
                               1.e-7, @"Average equals");
    XCTAssertEqualWithAccuracy([holder valFor:gcAggregatedWeightedHeartRate and:gcAggregatedCnt],
                               [[sumStats dataForField:hrfield] count:gcHistoryStatsWeek],
                               1.e-7, @"Count equals");
    
    // Check Cutoff aggregate
    [stats setActivityType:GC_TYPE_RUNNING];
    NSDate * cutoff = [organizer.activities.lastObject date];
    [stats aggregate:NSCalendarUnitMonth referenceDate:nil cutOff:cutoff ignoreMode:gcIgnoreModeActivityFocus];
    
    // CutOff November 13 (last):
    //    Nov -> Cnt 1, Sum 0.2
    //    Oct -> Cnt 2, Sum 3.2+2.1=5.3
    //    Sep -> Cnt 1, Sum 1.2

    NSArray * cutOffExpected = @[ @[ @"2012-11-01", @(0.2)], @[ @"2012-10-01", @(5.3)], @[@"2012-09-01", @(1.2)]];
    NSUInteger i=0;
    for (NSArray * one in cutOffExpected) {
        NSDate * date = [NSDate dateForDashedDate:one[0]];
        NSNumber * value = one[1];
        GCHistoryAggregatedDataHolder * holder = [stats dataForIndex:i++];
        XCTAssertTrue([holder.date isSameCalendarDay:date calendar:[GCAppGlobal calculationCalendar]], @"same date %@ / %@", holder.date, date);
        XCTAssertEqualWithAccuracy([holder valFor:gcAggregatedSumDistance and:gcAggregatedSum], value.doubleValue, 1.e-7);
    }
    
    
    [stats release];
    [organizer release];
}

-(void)atestTrackFieldChoiceOrder{
    GCActivity * activity = [[[GCActivity alloc] init] autorelease];
    
    activity.activityType = GC_TYPE_RUNNING;
    activity.trackFlags = gcFieldFlagSumDistance|gcFieldFlagWeightedMeanSpeed|gcFieldFlagWeightedMeanHeartRate;
    
    GCTrackFieldChoices * choices = [GCTrackFieldChoices trackFieldChoicesWithActivity:activity];
    
    NSLog(@"choices %@", choices.choices );
}

-(void)testSearchString{
    GCActivitySearch * search = nil;
    GCActivity * one_true = [[[GCActivity alloc] init] autorelease];
    GCActivity * one_false =[[[GCActivity alloc] init] autorelease];
    [one_true setSumDistanceCompat:20000.];
    [one_false setSumDistanceCompat:2000.];
    
    for (NSString * st in [NSArray arrayWithObjects:@"distance > 10",@"distance >10",@"distance>10",@"distance> 10", nil]) {
        search = [GCActivitySearch activitySearchWithString:st];
        XCTAssertTrue([search match:one_true], @"%@(20)",st);
        XCTAssertFalse([search match:one_false], @"%@(20)",st);
    }
    for (NSString * st in [NSArray arrayWithObjects:@"distance < 10",@"distance <10",@"distance<10",@"distance< 10", nil]) {
        search = [GCActivitySearch activitySearchWithString:st];
        XCTAssertTrue([search match:one_false], @"%@(20)",st);
        XCTAssertFalse([search match:one_true], @"%@(20)",st);
    }
    
    [one_true setSumDistanceCompat:2000.];
    [one_false setSumDistanceCompat:1450.];
    search = [GCActivitySearch activitySearchWithString:@"distance > 1.5km"];
    NSString * st = @"2km";
    XCTAssertFalse([search match:one_false], @"%@(20)",st);
    XCTAssertTrue([search match:one_true], @"%@(20)",st);
    
    [one_true setSumDistanceCompat:1.];
    [one_false setSumDistanceCompat:1.];
    [one_true setWeightedMeanSpeedCompat:2.];
    [one_false setWeightedMeanSpeedCompat:1.];
    st = @"speed";
    search = [GCActivitySearch activitySearchWithString:@"speed > 7 kph"];
    XCTAssertFalse([search match:one_false], @"%@(20)",st);
    XCTAssertTrue([search match:one_true], @"%@(20)",st);
    
    
    search = [GCActivitySearch activitySearchWithString:@"touRRette"];
    [one_true setLocation:@"Tourrettes"];
    [one_false setLocation:@"london"];
    XCTAssertTrue([search match:one_true], @"Tourrettes (true)");
    XCTAssertFalse([search match:one_false], @"tourrettes (false)");
    
    [one_false setSumDurationCompat:72.];
    [one_true setSumDurationCompat:82.];
    search = [GCActivitySearch activitySearchWithString:@"duration > 1:20"];
    XCTAssertTrue([search match:one_true],@"82 > 1:20");
    XCTAssertFalse([search match:one_false],@"72s > 1:20");
    
    NSDateComponents * comp = [[[NSDateComponents alloc] init] autorelease];
    NSCalendar * cal = [NSCalendar currentCalendar];
    [comp setDay:17];
    [comp setMonth:11];
    [comp setYear:2012];
    
    NSDate * sampledate = [cal dateFromComponents:comp];
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    NSString * weeksample = [NSString stringWithFormat:@"Weekof %@", [dateFormatter stringFromDate:sampledate]];
    
    NSArray * dateSamples = [NSArray arrayWithObjects:
                             @"June 2012",          @"2012-06-13T18:48:16.000Z",@"2012-09-13T18:48:16.000Z",
                             @"Mar 2011",           @"2011-03-13T18:48:16.000Z",@"2012-03-13T18:48:16.000Z",
                             @"2013",               @"2013-03-13T18:48:16.000Z",@"2011-03-13T18:48:16.000Z",
                             @"Saturday",           @"2012-11-17T18:48:16.000Z",@"2012-11-18T18:48:16.000Z",
                             weeksample,            @"2012-11-13T18:48:16.000Z",@"2012-11-22T18:48:16.000Z",
                             nil];
    
    for (NSUInteger i = 0; i<[dateSamples count]; i+=3) {
        NSString * searchStr = [dateSamples objectAtIndex:i];
        NSString * trueStr   = [dateSamples objectAtIndex:i+1];
        NSString * falseStr  = [dateSamples objectAtIndex:i+2];
        
        search = [GCActivitySearch activitySearchWithString:searchStr];
        [one_false setDate:[NSDate dateForRFC3339DateTimeString:falseStr]];
        [one_true setDate:[NSDate dateForRFC3339DateTimeString:trueStr]];
        
        XCTAssertTrue([search match:one_true],   @"%@ %@->%@", searchStr, trueStr, one_true.date);
        XCTAssertFalse([search match:one_false], @"%@ %@->%@", searchStr, falseStr, one_false.date);
        
    }
    
    /*
     search = [GCActivitySearch activitySearchWithString:@"Mar 2012"];
     search = [GCActivitySearch activitySearchWithString:@"Fri"];
     search = [GCActivitySearch activitySearchWithString:@"Thursday"];
     search = [GCActivitySearch activitySearchWithString:@"2012"];
     search = [GCActivitySearch activitySearchWithString:@"Weekof 11/16/12"];
     */
}

-(void)testLapBreakdown{
    
    NSArray * samples = @[ @{@"speed" : @10.,  @"n" : @10, @"hr" : @110., @"elapsed" : @1. },
                           @{@"speed" : @12.,  @"n" : @5 , @"hr" : @115., @"elapsed" : @1. },
                           @{@"speed" : @12.,  @"n" : @5 , @"hr" : @125., @"elapsed" : @1. },
                           @{@"speed" : @10.,  @"n" : @10, @"hr" : @122., @"elapsed" : @1. },
                           @{@"speed" : @11.5, @"n" : @10, @"hr" : @120., @"elapsed" : @1. },
                           @{@"speed" : @11.5, @"n" : @10, @"hr" : @140., @"elapsed" : @1. },
                           @{@"speed" : @10.,  @"n" : @10, @"hr" : @120., @"elapsed" : @1. },
                           ];
    
    GCActivity * act= [self buildActivityWithTrackpoints:samples];
    NSArray * laps = [act calculatedLapFor:40. match:[act matchTimeBlock] inLap:GC_ALL_LAPS];
    XCTAssertEqual([laps count], (NSUInteger)2, @"matching time");
    laps = [act calculatedLapFor:20. match:[act matchTimeBlock] inLap:GC_ALL_LAPS];
    XCTAssertEqual([laps count], (NSUInteger)3, @"matching time");
    laps = [act calculatedLapFor:100. match:[act matchTimeBlock] inLap:GC_ALL_LAPS];
    XCTAssertEqual([laps count], (NSUInteger)1, @"matching time");
    laps = [act accumulatedLaps];
    GCLap * second = laps[1];
    XCTAssertEqualWithAccuracy(second.distanceMeters, 162.0, 1.e-5, @"dist of second lap");
    XCTAssertEqualWithAccuracy(second.speed, 10.8, 1.e-5, @"speed of second lap");
    
}
    
-(void)testRollingLap{
    
    NSArray * samples = @[ @{@"speed" : @0.,   @"n" : @1,  @"hr" : @110., @"elapsed" : @1. },
                           @{@"speed" : @10.,  @"n" : @10, @"hr" : @110., @"elapsed" : @1. },
                           @{@"speed" : @12.,  @"n" : @5 , @"hr" : @115., @"elapsed" : @1. },
                           @{@"speed" : @12.,  @"n" : @5 , @"hr" : @125., @"elapsed" : @1. },
                           @{@"speed" : @10.,  @"n" : @10, @"hr" : @122., @"elapsed" : @1. },
                           @{@"speed" : @11.5, @"n" : @10, @"hr" : @120., @"elapsed" : @1. },
                           @{@"speed" : @11.5, @"n" : @10, @"hr" : @140., @"elapsed" : @1. },
                           @{@"speed" : @10.,  @"n" : @10, @"hr" : @120., @"elapsed" : @1. },
                           ];
    
    GCActivity * act= [self buildActivityWithTrackpoints:samples];
    
    GCActivityMatchLapBlock m = [act matchDistanceBlockEqual];
    GCActivityCompareLapBlock c = [act compareSpeedBlock];
    
    void (^test)(double dist)  = ^(double dist){
        NSArray * rv = [act calculatedRollingLapFor:dist match:m compare:c];
        GCLap * first = rv[1];
        GCLap * second = rv[2];
        GCTrackPoint * firstP = nil;
        GCTrackPoint * secondP = nil;
        NSUInteger i =0;
        for (i=0; i<[[act trackpoints] count]; i++) {
            GCTrackPoint * p = [[act trackpoints] objectAtIndex:i];
            if ([[p time] isEqualToDate:[first time]]) {
                firstP = p;
            }
            if ([[p time] isEqualToDate:[second time]]) {
                secondP = p;
            }
            
        }
        XCTAssertEqualWithAccuracy(dist, first.distanceMeters, first.speed, @"match dist %.f", dist);
        XCTAssertEqualWithAccuracy(secondP.distanceMeters-firstP.distanceMeters, first.distanceMeters, second.speed*1.1, @"match dist %.f", dist);
        
    };
    
    test(100.);
    test(200.);
    
}

-(void)disableTestCompoundBestOf{
    NSArray * samples = @[ @{@"speed" : @0.,  @"n" : @1,  @"hr" : @110., @"elapsed" : @2. },
                           @{@"speed" : @2.8, @"n" : @30, @"hr" : @110., @"elapsed" : @2. },
                           @{@"speed" : @2.8, @"n" : @20, @"hr" : @115., @"elapsed" : @2. },
                           @{@"speed" : @3.0, @"n" : @20, @"hr" : @125., @"elapsed" : @2. },
                           @{@"speed" : @3.5, @"n" : @40, @"hr" : @122., @"elapsed" : @2. },
                           @{@"speed" : @3.4, @"n" : @30, @"hr" : @120., @"elapsed" : @2. },
                           @{@"speed" : @3.5, @"n" : @20, @"hr" : @140., @"elapsed" : @2. },
                           @{@"speed" : @3.1, @"n" : @20, @"hr" : @120., @"elapsed" : @2. },
                           @{@"speed" : @2.9, @"n" : @10, @"hr" : @120., @"elapsed" : @2. },
                           @{@"speed" : @2.7, @"n" : @20, @"hr" : @140., @"elapsed" : @2. },
                           ];
    
    GCActivity * act= [self buildActivityWithTrackpoints:samples];

    GCField * field = [GCField fieldForFlag:gcFieldFlagWeightedMeanSpeed andActivityType:GC_TYPE_RUNNING];
    GCStatsDataSerieWithUnit * v_bestroll = [act calculatedDerivedTrack:gcCalculatedCachedTrackRollingBest forField:field thread:nil];
    NSArray * laps = [act compoundLapForIndexSerie:v_bestroll desc:@""];
    
    
    for (NSUInteger i=0; i<laps.count; i++) {
        NSLog(@"i=%lu dist=%f elapsed=%f", (unsigned long)i, [laps[i] distanceMeters], [laps[i] elapsed]);
    }
    
    GCActivityMatchLapBlock m = [act matchDistanceBlockEqual];
    GCActivityCompareLapBlock c = [act compareSpeedBlock];
    
    NSArray * km2   = [act calculatedRollingLapFor:1000. match:m compare:c];
    
    NSArray * per10m = [act resample:act.trackpoints forUnit:10. useTimeAxis:NO];
    
    NSLog(@"rol %lu, resample %lu", (unsigned long)km2.count, (unsigned long)per10m.count);
}

-(void)testPerformanceAnalysis{
    NSArray * samples = @[ // week 1 - hard
                           @{@"day": @1,    @"dist": @10.0,    @"hr": @160,    @"speed": @12.5 },
                           @{@"day": @2,    @"dist": @15.0,    @"hr": @150,    @"speed": @12   },
                           @{@"day": @4,    @"dist": @08.0,    @"hr": @140,    @"speed": @11   },
                           @{@"day": @6,    @"dist": @10.0,    @"hr": @170,    @"speed": @13   },
                           // week 2 - less hard
                           @{@"day": @8,    @"dist": @10.0,    @"hr": @170,    @"speed": @13   },
                           @{@"day": @9,    @"dist": @08.0,    @"hr": @150,    @"speed": @11   },
                           @{@"day": @10,   @"dist": @09.0,    @"hr": @150,    @"speed": @11.5 },
                           // week 3 - very hard
                           @{@"day": @15,   @"dist": @12.0,    @"hr": @170,    @"speed": @12.5 },
                           @{@"day": @17,   @"dist": @15.0,    @"hr": @165,    @"speed": @12 },
                           @{@"day": @18,   @"dist": @10.0,    @"hr": @170,    @"speed": @13 },
                           @{@"day": @19,   @"dist": @10.0,    @"hr": @150,    @"speed": @12 },
                           // week 4 - easy
                           @{@"day": @21,   @"dist": @10.0,    @"hr": @150,    @"speed": @11   },
                           @{@"day": @22,   @"dist": @08.0,    @"hr": @130,    @"speed": @10.5 },
                           // week 5 - moderate
                           @{@"day": @29,   @"dist": @10.0,    @"hr": @165,    @"speed": @13 },
                           @{@"day": @30,   @"dist": @10.0,    @"hr": @160,    @"speed": @12 }
                           ];
    NSDate * startDate = [NSDate dateForRFC3339DateTimeString:@"2014-03-04T18:00:00.000Z"];
    NSMutableArray * activities = [NSMutableArray arrayWithCapacity:samples.count];
    for (NSDictionary * sample in samples) {
        NSTimeInterval shift = ([sample[@"day"] doubleValue] * 60.*60.*24.);
        NSDate * date = [startDate dateByAddingTimeInterval:shift];
        
        double distance = [sample[@"dist"] doubleValue] * 1000.;
        double hr       = [sample[@"hr"] doubleValue];
        double speed    = [sample[@"speed"] doubleValue] * 1000./3600.; // km into mps
        double elapsed  = distance/speed;
        
        
        GCActivity * act = [[GCActivity alloc] init];
        act.activityId = [NSString stringWithFormat:@"act_%d dist=%.0fkm hr=%.0fbpm speed=%.1fkph", [sample[@"day"] intValue],
                          distance/1000., hr,speed/1000.*3600.];
        [act setDate:date];
        [act setSumDistanceCompat:distance];
        [act setSumDurationCompat:elapsed];
        [act setWeightedMeanHeartRateCompat:hr];
        [act setWeightedMeanSpeedCompat:speed];
        [act setFlags:gcFieldFlagSumDistance+gcFieldFlagSumDuration+gcFieldFlagWeightedMeanHeartRate+gcFieldFlagWeightedMeanSpeed];
        [act setActivityType:GC_TYPE_RUNNING];
        
        [act setSummaryDataFromKeyDict: @{     @"SumDuration" :           [self sumVal:@"SumDuration"             val:act.sumDurationCompat             uom:@"second" ],
                                 @"SumDistance" :           [self sumVal:@"SumDistance"             val:act.sumDistanceCompat             uom:@"meter" ],
                                 @"WeightedMeanHeartRate":  [self sumVal:@"WeightedMeanHeartRate"   val:act.weightedMeanHeartRateCompat   uom:@"bpm"  ],
                                 }];
        
        [activities addObject:act];
        [act release];

    }
    
    GCActivitiesOrganizer * organizer = [[[GCActivitiesOrganizer alloc] init] autorelease];
    organizer.activities = activities;
    
    GCHistoryPerformanceAnalysis * perfAnalysis = [[[GCHistoryPerformanceAnalysis alloc] init] autorelease];
    [perfAnalysis useOrganizer:organizer];
    
    perfAnalysis.shortTermPeriod = gcPerformancePeriodWeek;
    perfAnalysis.longTermPeriod  = gcPerformancePeriodTwoWeeks;
    perfAnalysis.summableField = [GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:GC_TYPE_RUNNING];
    perfAnalysis.scalingField = [GCField fieldForFlag:gcFieldFlagWeightedMeanHeartRate andActivityType:GC_TYPE_RUNNING];

    [perfAnalysis calculate];
    
    //NSLog(@"Serie =\n%@", [perfAnalysis.serie.serie asCSVString:true]);
    //NSLog(@"ST Serie =\n%@", [perfAnalysis.shortTermSerie.serie asCSVString:true]);
    //NSLog(@"LT Serie =\n%@", [perfAnalysis.longTermSerie.serie asCSVString:true]);
    // Expected computed from above in XLS: perfAnalysisSample.xlsx

    NSArray * exp_st =@[ @967142.8571,  @817142.8571,   @1010000,       @850000,
                         @850000,       @607142.8571,   @607142.8571,   @655714.2857,
                         @484285.7143,  @645000,        @887857.1429,   @1102142.857,
                         @1102142.857,  @1316428.571,   @1173571.429,   @1173571.429,
                         @820000,       @577142.8571,   @362857.1429,   @362857.1429,
                         @148571.4286,  @235714.2857,   @464285.7143 ];

    NSArray * exp_lt =@[ @811428.5714, @650714.2857, @827500, @868928.5714,
                         @976071.4286, @854642.8571, @961785.7143, @914642.8571,
                         @828928.5714,
                        ];
    
    XCTAssertEqual(exp_st.count, perfAnalysis.shortTermSerie.serie.count, @"Short Term count as Expected");
    XCTAssertEqual(exp_lt.count, perfAnalysis.longTermSerie.serie.count, @"Long Term count as Expected");
    
    // Divide by 1000 as display unit is kilometer now, but above is calculated with meters.
    // it doesn't matter for final display as it's rescaled against the maximium on the serie.
    for (NSUInteger i=0; i<MIN(exp_st.count, perfAnalysis.shortTermSerie.serie.count); i++) {
        XCTAssertEqualWithAccuracy([exp_st[i] doubleValue]/1000.0, [perfAnalysis.shortTermSerie.serie dataPointAtIndex:i].y_data, 1.e-2, @"Short Term Value [%d]", (int)i );
    }
    
    for (NSUInteger i=0; i<MIN(exp_lt.count, perfAnalysis.longTermSerie.serie.count); i++) {
        XCTAssertEqualWithAccuracy([exp_lt[i] doubleValue]/1000.0, [perfAnalysis.longTermSerie.serie dataPointAtIndex:i].y_data, 1.e-2, @"Long Term Value [%d]", (int)i );
    }
    
}

-(void)testAccumulateTrack{
    
    GCActivity * dummy = [[[GCActivity alloc] init] autorelease];
    dummy.activityType = GC_TYPE_RUNNING;
    
    GCLap * lap = [[[GCLap alloc] init] autorelease];
    
    GCTrackPoint * from = [[[GCTrackPoint alloc] init] autorelease];
    GCTrackPoint * to   = [[[GCTrackPoint alloc] init] autorelease];
    
    NSDate * start = [NSDate date];
    
    GCField * hr = [GCField fieldForFlag:gcFieldFlagWeightedMeanHeartRate andActivityType:GC_TYPE_RUNNING];
    GCField * dist = [GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:GC_TYPE_RUNNING];
    
    from.time = start;
    to.time = [start dateByAddingTimeInterval:1.];
    [from setNumberWithUnit:[GCNumberWithUnit numberWithUnit:GCUnit.bpm andValue:120.] forField:hr inActivity:dummy];
    [from setNumberWithUnit:[GCNumberWithUnit numberWithUnit:GCUnit.meter andValue:1.0] forField:dist inActivity:dummy];
    [to setNumberWithUnit:[GCNumberWithUnit numberWithUnit:GCUnit.meter andValue:11.0] forField:dist inActivity:dummy];
    // from 1m to 11m in 1sec = 10 m/s
    
    // 60 seconds of this
    for (NSUInteger i=0; i<60; i++) {
        [lap accumulateFrom:from to:to inActivity:dummy];
    }
    XCTAssertEqualWithAccuracy(lap.distanceMeters, 600., 1e-7, @"distance after 1min");
    XCTAssertEqualWithAccuracy(lap.speed, 10., 1e-7, @"speed after 1min");
    XCTAssertEqualWithAccuracy(lap.heartRateBpm, 120., 1e-7, @"hr after 1min");
    // Switch to 20 m/s @ 140bpm
    [to setNumberWithUnit:[GCNumberWithUnit numberWithUnit:GCUnit.meter andValue:21.0] forField:dist inActivity:dummy];
    [from setNumberWithUnit:[GCNumberWithUnit numberWithUnit:GCUnit.bpm andValue:140.0] forField:hr inActivity:dummy];
    
    for (NSUInteger i=0; i<60; i++) {
        [lap accumulateFrom:from to:to  inActivity:dummy];
        XCTAssertTrue(lap.speed-10.> 0.001, @"Speed > 10");
    }
    XCTAssertEqualWithAccuracy(lap.distanceMeters, 1800., 1e-7, @"distance after 1min");
    XCTAssertEqualWithAccuracy(lap.speed, 15., 1e-7, @"speed after 1min");
    XCTAssertEqualWithAccuracy(lap.heartRateBpm, 130., 1e-7, @"hr after 1min");
    
}



#pragma mark - GCActivitiesOrganizer

-(void)testOrganizer{
    GCActivitiesOrganizer * organizer = [[GCActivitiesOrganizer alloc] init];
    NSArray * initial = [NSArray arrayWithObjects:@"a", @"b", @"c", @"d",@"e", nil];
    NSMutableArray * a1 = [NSMutableArray arrayWithCapacity:[initial count]];
    for (NSString * aId in initial) {
        GCActivity * act = [[GCActivity alloc] init];
        [act setActivityId:aId];
        [a1 addObject:act];
        [act release];
    }
    [organizer setActivities:[NSArray arrayWithArray:a1]];
    NSArray * t1 = [NSArray arrayWithObjects:@"a", @"c", @"d", nil];
    NSArray * t2 = [NSArray arrayWithObjects:@"aa",@"cc", @"dd", nil];
    NSArray * t3 = [NSArray arrayWithObjects:@"d", @"e", nil];
    NSArray * t4 = [NSArray arrayWithObjects:@"d", @"e", @"f", nil];
    
    NSArray * ri = [organizer findActivitiesNotIn:initial isFirst:YES];
    NSArray * r1 = [organizer findActivitiesNotIn:t1 isFirst:YES];
    NSArray * r2 = [organizer findActivitiesNotIn:t2 isFirst:YES];
    NSArray * r3 = [organizer findActivitiesNotIn:t3 isFirst:YES];
    NSArray * r4 = [organizer findActivitiesNotIn:t4 isFirst:YES];
    
    NSUInteger ric = [ri count];;
    NSArray * e1 = [NSArray arrayWithObject:@"b"];
    NSArray * e3 = [NSArray arrayWithObjects:@"a",@"b",@"c", nil];
    XCTAssertEqualWithAccuracy(ric, 0, 0,  @"Nothing deleted from initial");
    XCTAssertTrue(r2 == nil, @"Nothing in common is error");
    XCTAssertEqualObjects(r1, e1, @"found the one to delete");
    XCTAssertEqualObjects(r3, e3, @"Found all to delete");
    XCTAssertTrue(r4==nil, @"Should never happen");//list in has last element not in organizer.
}


-(void)testOrganizerSearchAndFilter{
    GCActivitiesOrganizer * organizer = [[GCActivitiesOrganizer alloc] init];
    NSArray * samples  = @[ @[ GC_TYPE_CYCLING, @"2012-09-13T18:48:16.000Z", @1, @"meter",     @5.2,  @"minperkm", @"aa"],
                            @[ GC_TYPE_CYCLING, @"2012-09-14T18:48:16.000Z", @1, @"kilometer", @1,    @"kph", @"bb"],
                            @[ GC_TYPE_RUNNING, @"2012-09-15T18:48:16.000Z", @1, @"kilometer", @1,    @"kph",  @"aa"],
                            @[ GC_TYPE_DAY,     @"2012-09-16T18:48:16.000Z", @1, @"kilometer", @1,    @"kph", @"cc"],
                            ];
    NSMutableArray * activities = [NSMutableArray arrayWithCapacity:[samples count]];
    for (NSArray * sample in samples) {
        GCActivity * act = [[GCActivity alloc] init];
        [act setActivityType:[sample objectAtIndex:0]];
        [act setDate:[NSDate dateForRFC3339DateTimeString:[sample objectAtIndex:1]]];
        [act setSumDistanceCompat:[[sample objectAtIndex:2] doubleValue]];
        [act setFlags:gcFieldFlagSumDistance];
        [act setLocation:sample[6]];
        [act updateSummaryData:@{[self fldFor:@"WeightedMeanSpeed" act:act]:[self sumVal:@"WeightedMeanSpeed" val:[[sample objectAtIndex:4] doubleValue] uom:[sample objectAtIndex:5]]}];
        [activities addObject:act];
    }
    [organizer setActivities:activities];
    XCTAssertEqual([organizer countOfFilteredActivities], samples.count);
    
    [organizer filterForQuickFilter];
    XCTAssertEqual([organizer countOfFilteredActivities], 3);
    for (NSUInteger i=0; i<[organizer countOfFilteredActivities]; i++) {
        GCActivity * act = [organizer filteredActivityForIndex:i];
        XCTAssertNotEqualObjects(act.activityType, GC_TYPE_DAY);
    }
    
    [organizer clearFilter];
    XCTAssertEqual([organizer countOfFilteredActivities], samples.count);
    
    [organizer filterForSearchString:GC_TYPE_RUNNING];
    XCTAssertEqual([organizer countOfFilteredActivities], 1);
    for (NSUInteger i=0; i<[organizer countOfFilteredActivities]; i++) {
        GCActivity * act = [organizer filteredActivityForIndex:i];
        XCTAssertEqualObjects(act.activityType, GC_TYPE_RUNNING);
    }
    
    [organizer clearFilter];
    XCTAssertEqual([organizer countOfFilteredActivities], samples.count);

    [organizer filterForSearchString:GC_TYPE_CYCLING];
    XCTAssertEqual([organizer countOfFilteredActivities], 2);
    for (NSUInteger i=0; i<[organizer countOfFilteredActivities]; i++) {
        GCActivity * act = [organizer filteredActivityForIndex:i];
        XCTAssertEqualObjects(act.activityType, GC_TYPE_CYCLING);
    }
    
    [organizer clearFilter];
    XCTAssertEqual([organizer countOfFilteredActivities], samples.count);

    [organizer filterForSearchString:@"aa"];
    XCTAssertEqual([organizer countOfFilteredActivities], 2);
    for (NSUInteger i=0; i<[organizer countOfFilteredActivities]; i++) {
        GCActivity * act = [organizer filteredActivityForIndex:i];
        XCTAssertEqualObjects(act.location,@"aa");
    }
    
}

-(void)testOrganizerTimeSeries{
    GCActivitiesOrganizer * organizer = [[GCActivitiesOrganizer alloc] init];
    NSArray * samples  = @[ @[ GC_TYPE_CYCLING, @"2012-09-13T18:48:16.000Z", @1, @"meter",     @5.2,  @"minperkm"],
                            @[ GC_TYPE_CYCLING, @"2012-09-14T18:48:16.000Z", @1, @"kilometer", @1,    @"kph"],
                            @[ GC_TYPE_RUNNING, @"2012-09-15T18:48:16.000Z", @1, @"kilometer", @1,    @"kph"]
                            ];
    NSMutableArray * activities = [NSMutableArray arrayWithCapacity:[samples count]];
    for (NSArray * sample in samples) {
        GCActivity * act = [[GCActivity alloc] init];
        [act setActivityType:[sample objectAtIndex:0]];
        [act setDate:[NSDate dateForRFC3339DateTimeString:[sample objectAtIndex:1]]];
        [act setSumDistanceCompat:[[sample objectAtIndex:2] doubleValue]];
        [act setFlags:gcFieldFlagSumDistance];
        [act updateSummaryData:@{[self fldFor:@"WeightedMeanSpeed" act:act]:[self sumVal:@"WeightedMeanSpeed" val:[[sample objectAtIndex:4] doubleValue] uom:[sample objectAtIndex:5]]}];
        [activities addObject:act];
    }
    [organizer setActivities:activities];
    
    NSDictionary * rv = [organizer fieldsSeries:@[@"WeightedMeanSpeed",@(gcFieldFlagSumDistance)] matching:nil useFiltered:false ignoreMode:gcIgnoreModeActivityFocus];
    GCStatsDataSerieWithUnit * speed = [rv objectForKey:@"WeightedMeanSpeed"];
    GCStatsDataSerieWithUnit * dist  = [rv objectForKey:@(gcFieldFlagSumDistance)];
    
    GCUnit * km = [GCUnit unitForKey:@"kilometer"];
    GCUnit * kph = [GCUnit unitForKey:@"kph"];
    
    XCTAssertTrue([[speed unit] isEqualToUnit:kph], @"Speed in kph");
    XCTAssertTrue([[dist unit] isEqualToUnit:km] , @"Dist in km");
    
    for (NSUInteger idx=0; idx<[[organizer activities] count]; idx++) {
        GCActivity * act = [organizer activityForIndex:idx];
        [act mergeSummaryData:@{
                              [self fldFor:@"SumDuration" act:act] :               [self sumVal:@"SumDuration"             val:(idx+1)       uom:@"second" ],
                              [self fldFor:@"WeightedMeanPower" act:act] :         [self sumVal:@"WeightedMeanPower"       val:(idx+1)*1000    uom:@"watt" ],
         }
         ];
        [GCFieldsCalculated addCalculatedFields:act];
    }
    
    
    
    rv = [organizer fieldsSeries:@[CALC_ENERGY] matching:nil useFiltered:false ignoreMode:gcIgnoreModeActivityFocus];
    GCStatsDataSerieWithUnit * engy = [rv objectForKey:CALC_ENERGY];
    
    XCTAssertTrue([[engy unit] isEqualToUnit:[GCUnit unitForKey:@"kilojoule"]], @"Calc Val worked");
    XCTAssertTrue([engy.serie count] == [[organizer activities] count], @"point for each");
    for (NSUInteger idx=0; idx<[engy.serie count]; idx++) {
        XCTAssertEqualWithAccuracy(1.*(idx+1)*(idx+1), [[engy.serie dataPointAtIndex:idx] y_data], 1e-8, @"should be square");
    }

    GCField * durfield = [GCField fieldForFlag:gcFieldFlagSumDuration andActivityType:GC_TYPE_ALL];
    
    GCHistoryFieldDataSerieConfig * config = [GCHistoryFieldDataSerieConfig configWithFilter:false field:durfield];
    GCHistoryFieldDataSerie * dataserie = [[GCHistoryFieldDataSerie alloc] initFromConfig:config];
    NSDate * limit = [NSDate dateForRFC3339DateTimeString:@"2012-09-14T00:10:16.000Z"];
    dataserie.organizer = organizer;
    void (^test)(NSString * type, NSDate * from, NSUInteger e_n) = ^(NSString * type, NSDate * from, NSUInteger e_n){
        dataserie.config.fromDate = from;
        dataserie.config.activityType = type;
        
        [dataserie loadFromOrganizer];
        XCTAssertEqual([[dataserie history] count], e_n, @"%@/%@ expected = %d", type,from,(int)e_n);
    };
    test( GC_TYPE_ALL,nil,3);
    test( GC_TYPE_CYCLING,nil,2);
    test( GC_TYPE_RUNNING,nil,1);
    test( GC_TYPE_ALL,limit,2);
    test( GC_TYPE_RUNNING,limit,1);
    test( GC_TYPE_HIKING,nil,0);
    test( GC_TYPE_HIKING,limit,0);
    
    [organizer release];
}


-(void)testIconsExits{
    for (NSUInteger i=0; i<gcIconNavEnd; i++) {
        gcIconNav idx = (gcIconNav)i;
        UIImage * img =[GCViewIcons navigationIconFor:idx];
        XCTAssertNotNil(img, @"Image for i=%d exists", (int)i);
    }
    for (NSUInteger i=0; i<gcIconCellEnd; i++) {
        gcIconCell idx = (gcIconCell)i;
        UIImage * img =[GCViewIcons cellIconFor:idx];
        XCTAssertNotNil(img, @"Image for i=%d exists", (int)i);
    }
    for (NSUInteger i=0; i<gcIconTabEnd; i++) {
        gcIconTab idx = (gcIconTab)i;
        UIImage * img =[GCViewIcons tabBarIconFor:idx];
        XCTAssertNotNil(img, @"Image for i=%d exists", (int)i);
    }
    
}

-(void)testTimeAxisGeometry{
    GCHistoryFieldDataSerie * dataserie = [[[GCHistoryFieldDataSerie alloc] init] autorelease];
    GCStatsDataSerie * serie = [[[GCStatsDataSerie alloc] init] autorelease];
    NSDictionary * sample  = [GCTestsSamples aggregateSample];

    for (NSString * datestr in sample) {
        NSNumber * val = [sample objectForKey:datestr];
        [serie addDataPointWithDate:[NSDate dateForRFC3339DateTimeString:datestr] andValue:[val doubleValue]];
    }
    [serie sortByDate];

    dataserie.history = [GCStatsDataSerieWithUnit dataSerieWithUnit:[GCUnit unitForKey:@"dimensionless"] andSerie:serie];
    NSDate * first = [serie[0] date];
    
    GCSimpleGraphCachedDataSource * dataSource = [GCSimpleGraphCachedDataSource historyView:dataserie
                                                                               calendarUnit:NSCalendarUnitMonth
                                                                                graphChoice:gcGraphChoiceBarGraph
                                                  after:nil];
    
    GCSimpleGraphGeometry * geometry = [[[GCSimpleGraphGeometry alloc] init] autorelease];
    [geometry setDrawRect:CGRectMake(0., 0., 320., 405.)];
    [geometry setZoomPercentage:CGPointMake(0., 0.)];
    [geometry setOffsetPercentage:CGPointMake(0., 0.)];
    [geometry setDataSource:dataSource];
    [geometry setAxisIndex:0];
    [geometry setSerieIndex:0];
    [geometry calculate];
    [geometry calculateAxisKnobRect:gcGraphStep andAttribute:@{NSFontAttributeName:[GCViewConfig systemFontOfSize:12.]}];
    NSCalendar * cal = [GCAppGlobal calculationCalendar];
    NSDate * start = nil;

    NSTimeInterval extends;
    NSDateComponents * comp = [[[NSDateComponents alloc] init] autorelease];
    comp.month = 1;
    
    for (GCAxisKnob*point in geometry.xAxisKnobs) {
        // Check all days are first of month
        [cal rangeOfUnit:NSCalendarUnitMonth startDate:&start interval:&extends forDate:first];
        NSDate * knobDate = [NSDate dateWithTimeIntervalSinceReferenceDate:point.value];
        //XCTAssertEqualObjects(start, knobDate, @"Axis match");
        if (knobDate) {//FIXME: to avoid unused

        }
        first = [cal dateByAddingComponents:comp toDate:first options:0];
    }
     

}

-(void)testFieldValidChoices{
    NSString * defaultField = @"backhands"; // params as can change
    NSDictionary * m1 = @{
                         @"SumDuration":                    defaultField,
                         @"__healthweight":                 defaultField,
                         @"backhands"            : @"heatmap_backhands_center",
                         @"backhands_flat"       : @"heatmap_backhands_center" ,
                         @"backhands_lifted"     : @"heatmap_backhands_center" ,
                         @"backhands_sliced"     : @"heatmap_backhands_center" ,
                         @"first_serves"         : @"heatmap_serves_center",
                         @"first_serves_effect"  : @"heatmap_serves_center",
                         @"first_serves_flat"    : @"heatmap_serves_center",
                         @"forehands"            : @"heatmap_forehands_center",
                         @"forehands_flat"       : @"heatmap_forehands_center",
                         @"forehands_lifted"     : @"heatmap_forehands_center",
                         @"heatmap_all_center"   : @"forehands",
                         @"heatmap_backhands_center":@"backhands",
                         @"heatmap_forehands_center":@"forehands",
                         @"heatmap_serves_center"  :defaultField, // defaults because @"serves" not there..
                         
                         
                         @"UnkownField"           : defaultField
                         };
    
    NSDictionary * m2 =    @{
                             @"WeightedMeanRunCadence":         @"WeightedMeanPace",
                             @"SumDistance":                    @"WeightedMeanPace",
                             @"SumDuration":                    @"WeightedMeanPace",
                             @"WeightedMeanPace":               @"WeightedMeanHeartRate",
                             @"WeightedMeanHeartRate":          @"WeightedMeanPace",
                             @"WeightedMeanPower":              @"WeightedMeanPace",
                             @"WeightedMeanVerticalOscillation":@"WeightedMeanPace",
                             @"WeightedMeanGroundContactTime":  @"WeightedMeanPace",
                             @"__healthweight":                 @"WeightedMeanPace",
                             };
    for (NSDictionary * m in @[ m1, m2]) {
        NSArray * inputs =  [[m allKeys] arrayByMappingBlock:^(NSString * key){
            return [GCField fieldForKey:key andActivityType:GC_TYPE_ALL];
        }];
        NSArray * valid = [GCViewConfig validChoicesForGraphIn:inputs];
        for (GCField * field in inputs) {
            GCField * exp = [GCField fieldForKey:m[field.key] andActivityType:GC_TYPE_ALL];
            GCField * rv = [GCViewConfig nextFieldForGraph:nil fieldOrder:valid differentFrom:field];
            XCTAssertEqualObjects(rv, exp, @"next[%@] = %@ (expect: %@)", field, rv, exp);
        }
    }
}

@end
