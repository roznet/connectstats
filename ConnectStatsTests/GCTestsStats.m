//  MIT License
//
//  Created on 26/04/2021 for ConnectStatsXCTests
//
//  Copyright (c) 2021 Brice Rosenzweig
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//



#import "GCTestCase.h"
#import "GCActivity.h"
#import "GCActivitiesOrganizer.h"
#import "GCAppGlobal.h"
#import "GCHistoryAggregatedActivityStats.h"
#import "GCHistoryFieldSummaryStats.h"
#import "GCViewConfig.h"
#import "GCActivity+TestBackwardCompat.h"
#import "GCStatsCalendarAggregationConfig.h"
#import "GCHistoryFieldDataHolder.h"
@import CHCSVParser;

@interface GCTestsStats : GCTestCase

@end

@implementation GCTestsStats

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{

    [super tearDown];
}

-(void)testSelfConsistency{
    [[GCAppGlobal profile] configSet:CONFIG_DUPLICATE_CHECK_ON_LOAD boolVal:false];
    
    GCActivitiesOrganizer * organizer = [self setupSampleState:@"test_activities_stats.db"];
    
    NSArray * atype= @[ GC_TYPE_RUNNING, GC_TYPE_SWIMMING,GC_TYPE_CYCLING,GC_TYPE_ALL ];
    NSArray * ctype=  @[ @(NSCalendarUnitWeekOfYear), @(NSCalendarUnitMonth), @(NSCalendarUnitYear) ];

    // Try to match aggregator with manual sum on activities
    // returned by manual filter
    for (NSString * activityType in atype) {
        for (NSNumber * vc in ctype) {
            NSCalendarUnit calendarUnit = [vc intValue];
            GCStatsCalendarAggregationConfig * calendarConfig = [GCStatsCalendarAggregationConfig globalConfigFor:calendarUnit];
            GCHistoryAggregatedActivityStats * vals = [GCHistoryAggregatedActivityStats aggregatedActivityStatsForActivityType:activityType];
            [vals setActivitiesFromOrganizer:organizer];
            
            [vals aggregate:calendarUnit referenceDate:nil ignoreMode:gcIgnoreModeActivityFocus];

            for (NSUInteger k = 0; k<[vals count]; k++) {
                GCHistoryAggregatedDataHolder * data = [vals dataForIndex:k];
                NSString * filter = [GCViewConfig filterFor:calendarConfig date:[data date] andActivityType:activityType];
                NSArray * actIdx = [organizer activityIndexesMatchingString:filter];
                GCNumberWithUnit * sum = nil;
                double cnt = 0.;
                XCTAssertGreaterThan(actIdx.count, 0, @"We got some activities");
                if( actIdx.count > 0){
                    for (NSUInteger i = 0; i < [actIdx count]; i++) {
                        GCActivity * act = [organizer activityForIndex:[[actIdx objectAtIndex:i] integerValue]];
                        GCNumberWithUnit * dist = [act numberWithUnitForField:[GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:act.activityType]];
                        if( sum == nil){
                            sum = dist;
                        }else{
                            sum = [sum addNumberWithUnit:dist weight:1.0];
                        }
                        cnt += 1.;
                    }
                    GCField * distfield = [GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:activityType];
                    GCNumberWithUnit * aggSum = [data numberWithUnit:distfield statType:gcAggregatedSum];
                    double aggCnt = [data numberWithUnit:distfield statType:gcAggregatedCnt].value;
                    
                    if ( sum != nil && ( fabs(cnt-aggCnt) > 1e-7 || ![aggSum isEqualToNumberWithUnit:sum]) ) {
                        actIdx = [organizer activityIndexesMatchingString:filter];
                        //NSLog( @"%@", data);
                        //NSLog(@"type=%@ config=%@ filter=%@",activityType,calendarConfig,filter);
                        for (NSUInteger i = 0; i < [actIdx count]; i++) {
                            GCActivity * act = [organizer activityForIndex:[[actIdx objectAtIndex:i] integerValue]];
                            NSLog(@"%@ %@ %f",act,[[act date] dateShortFormat],act.sumDistanceCompat);
                        }
                    }
                    XCTAssertEqualWithAccuracy(cnt, aggCnt, 1e-6,@"%f match cnt %f", aggCnt,cnt);
                    if( sum != nil){
                        XCTAssertEqualObjects(aggSum, sum,@"%@ match sum %@", aggSum,sum);
                    }
                }
            }
            [self checkGarminConsistency:vals activityType:activityType calendarConfig:calendarConfig];

        }
    }
}

-(GCHistoryFieldSummaryStats*)fieldStatsWithDb:(FMDatabase*)aDb andActivityType:(NSString*)activityType{
    GCHistoryFieldSummaryStats * rv = [[[GCHistoryFieldSummaryStats alloc] init] autorelease];
    NSString * query = @"select distinct field,uom,count(value) as count,sum(value) as sum from gc_activities_values v, gc_activities a where a.activityId=v.activityId and a.activityType = ? group by field,uom";
    if ( [activityType isEqualToString:GC_TYPE_ALL] ) {
        query = @"select distinct field,uom,count(value) as count,sum(value) as sum from gc_activities_values v, gc_activities a where a.activityId=v.activityId group by field,uom";
    }
    FMResultSet * res = [aDb executeQuery:query, activityType];
    NSMutableDictionary<GCField*,GCHistoryFieldDataHolder*> * fieldData = [NSMutableDictionary dictionary];
    while ([res next]) {
        GCField * field = [GCField fieldForKey:[res stringForColumn:@"field"] andActivityType:activityType];
        GCHistoryFieldDataHolder * pre = [fieldData objectForKey:field];
        if (!pre) {
            GCHistoryFieldDataHolder * v =[[GCHistoryFieldDataHolder alloc] init];
            [v setField:field];
            fieldData[field] = v;
            pre = v;
            [v release];
        }
        GCNumberWithUnit * nu = [GCNumberWithUnit numberWithUnitName:[res stringForColumn:@"uom"] andValue:[res doubleForColumn:@"sum"]];
        [pre addSumWithUnit:nu andCount:[res intForColumn:@"count"] for:gcHistoryStatsAll];
    }
    rv.fieldData = fieldData;
    return rv;
}

-(void)checkGarminConsistency:(GCHistoryAggregatedActivityStats*)vals activityType:(NSString*)activityType calendarConfig:(GCStatsCalendarAggregationConfig*)calendarConfig{
    if ([activityType isEqualToString:GC_TYPE_CYCLING] || [activityType isEqualToString:GC_TYPE_RUNNING]) {
        NSString * file = [NSString stringWithFormat:@"stats_%@_%@.csv",activityType,[calendarConfig.calendarUnitDescription lowercaseString]];
        NSArray * gc=[NSArray arrayWithContentsOfCSVURL:[NSURL fileURLWithPath:[RZFileOrganizer bundleFilePath:file forClass:[self class]]] options:CHCSVParserOptionsTrimsWhitespace];
        NSDateFormatter * formatter = [[[NSDateFormatter alloc] init] autorelease];
        if (calendarConfig.calendarUnit == NSCalendarUnitMonth) {
            [formatter setDateFormat:@"MMM yyyy"];
        }else if (calendarConfig.calendarUnit == NSCalendarUnitWeekOfYear){
            [formatter setDateFormat:@"MM/dd/yyyy"];
        }else{
            [formatter setDateFormat:@"yyyy"];
        }
        for (NSUInteger i =3; i<[gc count]; i++) {
            NSArray * line = [gc objectAtIndex:i];
            NSString * dateStr = [line objectAtIndex:0];

            if (![dateStr isEqualToString:@"Summary"]) {
                GCHistoryAggregatedDataHolder * data = [vals dataForIndex:i-3];

                double gc_count = [[line objectAtIndex:1] integerValue];
                NSString * cleanNumber = [[line[2] stringByReplacingOccurrencesOfString:@"," withString:@""] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                double gc_dist = [cleanNumber doubleValue];
                //double gc_hr   = [[line objectAtIndex:6] integerValue];

                GCField * distfield = [GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:activityType];
                double cs_count = [data numberWithUnit:distfield statType:gcAggregatedCnt].value;
                double cs_dist  = [data numberWithUnit:distfield statType:gcAggregatedSum].value;
                //double cs_hr    = [data valFor:gcAggregatedWeightedHeartRate and:gcAggregatedAvg];

                NSString * hdr = [NSString stringWithFormat:@"%@ %@ %@", activityType, calendarConfig, dateStr];

                NSString * res = [formatter stringFromDate:[data date]];
                XCTAssertEqualObjects(res, dateStr, @"%@: %@ == %@", hdr, dateStr, res);

                XCTAssertEqualWithAccuracy(gc_count, cs_count, 0.1, @"%@: cnt %.0f == %.0f", hdr, gc_count,cs_count);
                XCTAssertEqualWithAccuracy(gc_dist, cs_dist, 0.01,@"%@: dist %.2f == %.2f", hdr, gc_dist,cs_dist );

            }

        }
    }
}

-(void)testsHistoryStats{
    GCActivitiesOrganizer * organizer = [self setupSampleState:@"test_activities_large.db"];

    NSString * activityType = GC_TYPE_CYCLING;

    GCActivityMatchBlock filter = nil;
    if (![activityType isEqualToString:GC_TYPE_ALL]) {
        filter = ^(GCActivity*act){
            return [[act activityType] isEqualToString:activityType];
        };
    }

    GCHistoryFieldSummaryStats * vals_sum = [GCHistoryFieldSummaryStats fieldStatsWithActivities:organizer.activities
                                                                                        matching:filter
                                                                                   referenceDate:nil
                                                                                      ignoreMode:gcIgnoreModeActivityFocus];

    GCHistoryAggregatedActivityStats * vals_agg = [GCHistoryAggregatedActivityStats aggregatedActivityStatsForActivityType:activityType];
    [vals_agg setActivitiesFromOrganizer:organizer];
    [vals_agg aggregate:NSCalendarUnitWeekOfYear referenceDate:nil ignoreMode:gcIgnoreModeActivityFocus];

    void (^testOne)(NSString*field) = ^(NSString*fieldkey){
        GCField * field = [GCField fieldForKey:fieldkey andActivityType:activityType];

        GCHistoryAggregatedDataHolder * data_agg = [vals_agg dataForIndex:0];
        GCHistoryFieldDataHolder * data_sum = [vals_sum dataForField:field];
        //nu_agg is always same
        GCNumberWithUnit* nu_agg = [data_agg numberWithUnit:field statType:gcAggregatedSum];
        GCNumberWithUnit* nu_sum = [data_sum sumWithUnit:gcHistoryStatsWeek];
        XCTAssertNotNil(nu_sum);
        XCTAssertTrue([nu_agg compare:nu_sum withTolerance:1.e-7]==NSOrderedSame,@"%@ sum match %@ == %@", field, nu_sum,nu_agg);

        nu_agg = [data_agg numberWithUnit:field statType:gcAggregatedAvg];
        nu_sum = [data_sum averageWithUnit:gcHistoryStatsWeek];

        XCTAssertTrue([nu_agg compare:nu_sum withTolerance:1.e-7]==NSOrderedSame,@"%@ avg match %@ == %@", field, nu_sum,nu_agg);
    };

    testOne(@"SumDistance");
    testOne(@"WeightedMeanSpeed");

    GCHistoryAggregatedDataHolder * data_agg = [vals_agg dataForIndex:0];
    GCHistoryFieldDataHolder * dist_sum = [vals_sum dataForField:[GCField fieldForKey:@"SumDistance" andActivityType:activityType]];
    GCHistoryFieldDataHolder * dur_sum  = [vals_sum dataForField:[GCField fieldForKey:@"SumDuration" andActivityType:activityType]];
    GCHistoryFieldDataHolder * speed_sum= [vals_sum dataForField:[GCField fieldForKey:@"WeightedMeanSpeed" andActivityType:activityType]];

    GCNumberWithUnit* dist_nu   = [dist_sum sumWithUnit:gcHistoryStatsAll];
    GCNumberWithUnit* dur_nu    = [dur_sum sumWithUnit:gcHistoryStatsAll];
    //GCNumberWithUnit* speed_nu  = nil;//[speed_sum averageWithUnit:gcHistoryStatsAll];
    GCNumberWithUnit* wspeed_nu = [speed_sum weightedAverageWithUnit:gcHistoryStatsAll];

    double meters = [dist_nu convertToUnitName:@"meter"].value;
    double seconds = [dur_nu convertToUnitName:@"second"].value;
    GCNumberWithUnit* implied_speed = [GCNumberWithUnit numberWithUnitName:@"mps" andValue:meters/seconds];

    XCTAssertEqualObjects(wspeed_nu.formatDouble, [implied_speed convertToUnit:wspeed_nu.unit].formatDouble,@"Implied==wspeed %@ %@", implied_speed, wspeed_nu);

    dist_nu   = [dist_sum sumWithUnit:gcHistoryStatsWeek];
    dur_nu    = [dur_sum sumWithUnit:gcHistoryStatsWeek];
    //speed_nu  = [speed_sum averageWithUnit:gcHistoryStatsWeek];
    //wspeed_nu = [speed_sum weightedAverageWithUnit:gcHistoryStatsWeek];

    meters = [dist_nu convertToUnitName:@"meter"].value;
    seconds = [dur_nu convertToUnitName:@"second"].value;
    implied_speed = [GCNumberWithUnit numberWithUnitName:@"mps" andValue:meters/seconds];

    GCField * speed = [GCField fieldForFlag:gcFieldFlagWeightedMeanSpeed andActivityType:activityType];
    GCNumberWithUnit * wspeed_agg_nu = [data_agg numberWithUnit:speed statType:gcAggregatedWvg];

    XCTAssertEqualObjects(wspeed_agg_nu.formatDouble,[implied_speed convertToUnit:wspeed_agg_nu.unit].formatDouble,@"Implied==wspeed %@ %@", implied_speed, wspeed_agg_nu);

}

@end
