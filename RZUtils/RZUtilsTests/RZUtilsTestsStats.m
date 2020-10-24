//
//  RZUtilsTestsStats.m
//  RZUtils
//
//  Created by Brice Rosenzweig on 16/07/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <RZUtils/RZUtils.h>
#import "RZUtilsTestsSamples.h"

#define EPS 1e-10

@interface RZUtilsTestsStats : XCTestCase

@end

@implementation RZUtilsTestsStats


- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - GCStatsDataSerie

-(void)testCumulativeRescaled{
    GCStatsDataSerie * serie_x  = [[GCStatsDataSerie alloc] init] ;
    GCStatsDataSerie * serie_y  = [[GCStatsDataSerie alloc] init] ;
    
    NSDictionary * sample = [RZUtilsTestsSamples aggregateSample];
    for (NSString * key in sample) {
        NSDate * date = [NSDate dateForRFC3339DateTimeString:key];
        NSNumber *val = [sample objectForKey:key];
        [serie_x  addDataPointWithDate:date andValue:[val doubleValue]];
        [serie_y  addDataPointWithDate:date andValue:[val doubleValue]*2.];
    }
    [GCStatsDataSerie reduceToCommonRange:serie_x and:serie_y];
    GCStatsInterpFunction * interp = [GCStatsInterpFunction interpFunctionWithSerie:serie_x];
    GCStatsDataSerie * serie_xy = [interp xySerieWith:serie_y];
    
    NSDictionary * serie_cum = [serie_xy xyCumulativeRescaledByCalendarUnit:NSCalendarUnitMonth inTimeSerie:serie_x withCalendar:[RZUtilsTestsSamples calculationCalendar]];
    
    NSDateComponents * components = [[NSDateComponents alloc] init];
    [components setDay:1];
    [components setYear:2012];
    
    [components setMonth:9];
    GCStatsDataSerie * sep = [serie_cum objectForKey:[[RZUtilsTestsSamples calculationCalendar] dateFromComponents:components]];
    [components setMonth:10];
    GCStatsDataSerie * oct = [serie_cum objectForKey:[[RZUtilsTestsSamples calculationCalendar] dateFromComponents:components]];
    [components setMonth:11];
    GCStatsDataSerie * nov = [serie_cum objectForKey:[[RZUtilsTestsSamples calculationCalendar] dateFromComponents:components]];
    
    XCTAssertEqual([sep count], (NSUInteger)3,  @"CumRescaled sep has 3 points");
    XCTAssertEqual([oct count], (NSUInteger)11, @"CumRescaled oct has 11 points");
    XCTAssertEqual([nov count], (NSUInteger)1,  @"CumRescaled nov has 1 point");
    
    void (^test)(GCStatsDataSerie*s,NSUInteger n,double e[],NSString*m)  = ^(GCStatsDataSerie*s,NSUInteger n,double e[],NSString*m){
        XCTAssertEqual([s count], n,  @"Serie %@ has %d elements", m, (int)n);
        double sum = 0.;
        for (size_t i=0; i<n; i++) {
            if (i<[s count]) {
                GCStatsDataPoint * point = [s dataPointAtIndex:i];
                sum += e[i];
                XCTAssertEqual([point x_data], sum, @"%@[%lu] x=%.1f", m,i,sum);
                XCTAssertEqual([point y_data], sum*2., @"%@[%lu] x=%.1f", m,i,sum*2.);
            }
        }
    };
    
    double sep_e[] = {1.2,1.3,2.1};
    double oct_e[] = {3.2,2.1,3.2,2.3,2.9,3.0,2.1,1.5,5.2,4.2,3.7};
    double nov_e[] = {0.2};
    
    test(sep, 3,sep_e,@"sep");
    test(oct,11,oct_e,@"oct");
    test(nov, 1,nov_e,@"nov");
    
}


-(void)testRescaleStats{
    GCStatsDataSerie * serie = [[GCStatsDataSerie alloc] init];
    GCStatsDataSerie * serie2 = [[GCStatsDataSerie alloc] init];
    
    NSDateComponents * comp = [[NSDateComponents alloc] init];
    NSCalendar * cal = [NSCalendar currentCalendar];
    [comp setDay:1];
    [comp setMonth:1];
    [comp setYear:2012];
    
    NSDate * date = [cal dateFromComponents:comp];
    
    for (int i=0; i<10; i++) {
        [comp setDay:i+1];
        [serie addDataPointWithDate:date andValue:1 ];
        [serie2 addDataPointWithDate:date andValue:i%7 ];
        date = [date dateByAddingTimeInterval:60*60*24];
    }
    
    NSDictionary * r = [serie rescaleWithinCalendarUnit:NSCalendarUnitYear merged:NO referenceDate:nil andCalendar:[RZUtilsTestsSamples calculationCalendar]];
    XCTAssertTrue([r count] == 1, @"Yearly = 1 observation");
    for (NSDate * d in r) {
        GCStatsDataSerie * serie = [r objectForKey:d];
        GCStatsDataSerie * cum = [serie cumulativeValue];
        for (NSUInteger i = 0; i<[serie count]; i++) {
            XCTAssertEqualWithAccuracy([[serie dataPointAtIndex:i] y_data], 1., 1.e-7, @"%i val = 1", (int)i);
            XCTAssertEqualWithAccuracy([[cum dataPointAtIndex:i] y_data], 1.+i, 1.e-7, @"%i cum", (int)i);
        }
    }
    r = [serie rescaleWithinCalendarUnit:NSCalendarUnitWeekOfYear merged:NO referenceDate:nil andCalendar:[RZUtilsTestsSamples calculationCalendar]];
    XCTAssertTrue([r count] == 2, @"Weekly = 2 observation");
    for (NSDate * d in r) {
        GCStatsDataSerie * serie = [r objectForKey:d];
        GCStatsDataSerie * cum = [serie cumulativeValue];
        for (NSUInteger i = 0; i<[serie count]; i++) {
            XCTAssertEqualWithAccuracy([[serie dataPointAtIndex:i] y_data], 1., 1.e-7, @"%i val = 1", (int)i);
            XCTAssertEqualWithAccuracy([[cum dataPointAtIndex:i] y_data], 1.+i, 1.e-7, @"%i cum", (int)i);
        }
    }
    r = [serie2 rescaleWithinCalendarUnit:NSCalendarUnitWeekOfYear merged:YES referenceDate:nil andCalendar:[RZUtilsTestsSamples calculationCalendar]];
    XCTAssertTrue([r count] == 1, @"Weekly = 2 observation");
    for (NSDate * d in r) {
        GCStatsDataSerie * serie = [r objectForKey:d];
        for (NSUInteger i = 0; i<[serie count]; i++) {
            double e_i = [[serie dataPointAtIndex:i] x_data]/(24.*60.*60.);
            
            XCTAssertEqualWithAccuracy([[serie2 dataPointAtIndex:i] y_data], e_i, 1.e-7, @"%i val = 1", (int)i);
        }
    }
}


-(void)testStats{
    GCStatsDataSerie * serie = [[GCStatsDataSerie alloc] init];
    
    NSDateComponents * comp = [[NSDateComponents alloc] init];
    NSCalendar * cal = [RZUtilsTestsSamples calculationCalendar];
    [cal setFirstWeekday:1];
    
    [comp setDay:1];
    [comp setMonth:1];
    [comp setYear:2012];
    
    NSDate * date = [cal dateFromComponents:comp];
    
    for (int i=0; i<10; i++) {
        [comp setDay:i+1];
        [serie addDataPointWithDate:date andValue:2.0*(i+1) ];
        date = [date dateByAddingTimeInterval:60*60*24];
    }
    
    GCStatsDataSerie * qu = [serie quantiles:4];
    GCStatsDataSerie * av = [serie average];
    
    XCTAssertTrue([qu count]==5,@"quartile");
    XCTAssertTrue([av count]==1,@"average");
    
    XCTAssertEqualWithAccuracy([[av dataPointAtIndex:0] y_data],    11.,    EPS,    @"Average 10 points");
    XCTAssertEqualWithAccuracy([[qu dataPointAtIndex:1] y_data],    4.,     EPS,    @"Quartile 1 / 10");
    XCTAssertEqualWithAccuracy([[qu dataPointAtIndex:2] y_data],    10.,    EPS,    @"Quartile 2 / 10");
    XCTAssertEqualWithAccuracy([[qu dataPointAtIndex:3] y_data],    14.,    EPS,    @"Quartile 3 / 10");
    
    qu = [serie quantiles:2];
    XCTAssertTrue([qu count]==3,@"median");
    XCTAssertEqualWithAccuracy([[qu dataPointAtIndex:1] y_data],   10.,    EPS,    @"Quartile 2 / 10");
    
    for (int i=10; i<20; i++) {
        [serie addDataPointWithDate:date andValue:-2.0*(i+1)+20+21 ];
        date = [date dateByAddingTimeInterval:60*60*24];
        
    }
    
    qu = [serie quantiles:4];
    av = [serie average];
    
    XCTAssertTrue([av count]==1,@"average");
    XCTAssertTrue([qu count]==5,@"quartile");
    
    XCTAssertEqualWithAccuracy([[av dataPointAtIndex:0] y_data],    10.5,   EPS,    @"Average 20 points");
    XCTAssertEqualWithAccuracy([[qu dataPointAtIndex:1] y_data],    5.,     EPS,    @"Quartile 1 / 10");
    XCTAssertEqualWithAccuracy([[qu dataPointAtIndex:2] y_data],    10.,    EPS,    @"Quartile 2 / 10");
    XCTAssertEqualWithAccuracy([[qu dataPointAtIndex:3] y_data],    15.,    EPS,    @"Quartile 3 / 10");
    
    
    [serie removeAllPoints];
    date = [cal dateFromComponents:comp];
    for (int i=0; i<20000; i++) {
        [serie addDataPointWithDate:[cal dateFromComponents:comp] andValue:(double)(i%10) ];
        date = [date dateByAddingTimeInterval:60*60*24];
    }
    qu = [serie quantiles:4];
    av = [serie average];
    
    XCTAssertTrue([av count]==1,@"average");
    XCTAssertTrue([qu count]==5,@"quartile");
    
    XCTAssertEqualWithAccuracy([[av dataPointAtIndex:0] y_data],    4.5,    EPS,    @"Average large");
    XCTAssertEqualWithAccuracy([[qu dataPointAtIndex:1] y_data],    2.,     EPS,    @"Quartile 1 large");
    XCTAssertEqualWithAccuracy([[qu dataPointAtIndex:2] y_data],    4.,    EPS,     @"Quartile 2 large");
    XCTAssertEqualWithAccuracy([[qu dataPointAtIndex:3] y_data],    7.,    EPS,     @"Quartile 3 large");
    
    
    NSArray * starts= @[ @[ @3,@1,@2012 ],
                         @[ @8,@1,@2012 ] ];
    
    for (NSArray * def in starts) {
        [serie removeAllPoints];
        
        [comp setDay:[def[0] integerValue]];
        [comp setMonth:[def[1] integerValue]];
        [comp setYear:[def[2] integerValue]];
        
        date = [cal dateFromComponents:comp];
        
        NSMutableArray * expectedSums = [NSMutableArray arrayWithCapacity:32];
        NSInteger lastWeek = -1;
        NSInteger expectedSum=0;
        for (int i=0; i<16; i++) {
            NSInteger thisWeek = [[cal components:NSCalendarUnitWeekOfYear fromDate:date] weekOfYear];
            if (lastWeek==-1) {
                lastWeek = thisWeek;
            }else{
                if (thisWeek!=lastWeek) {
                    [expectedSums addObject:[NSNumber numberWithInteger:expectedSum]];
                    lastWeek=thisWeek;
                    expectedSum=0;
                }
            }
            [serie addDataPointWithDate:date andValue:1.0 ];
            expectedSum+=1;
            date = [date dateByAddingTimeInterval:60*60*24];
        }
        if (expectedSum>0) {
            [expectedSums addObject:[NSNumber numberWithInteger:expectedSum]];
        }
        NSDictionary * stats = [serie aggregatedStatsByCalendarUnit:NSCalendarUnitWeekOfYear referenceDate:nil andCalendar:[RZUtilsTestsSamples calculationCalendar]];
        qu = [stats objectForKey:STATS_SUM];
        av = [stats objectForKey:STATS_AVG];
        
        XCTAssertTrue([qu count]==[expectedSums count],@"sum by week");
        for (NSUInteger i=0; i<MIN([qu count], [expectedSums count]); i++) {
            XCTAssertEqualWithAccuracy([[qu dataPointAtIndex:i] y_data],    [[expectedSums objectAtIndex:i] doubleValue],    EPS,    @"sum by week");
        }
        
    }
    
    [serie removeAllPoints];
    
    [comp setDay:24];
    [comp setMonth:1];
    [comp setYear:2012];
    [comp setHour:5];// 5am otherwise daylight saving messes up as default = midnight
    date = [cal dateFromComponents:comp];
    NSDateComponents * oneUnit = [[NSDateComponents alloc] init];
    [oneUnit setWeekOfYear:1];
    
    for (int i=0; i<16; i++) {
        [serie addDataPointWithDate:date andValue:[[cal components:NSCalendarUnitMonth fromDate:date] month]];
        date = [cal dateByAddingComponents:oneUnit toDate:date options:0];
    }
    av = [[serie aggregatedStatsByCalendarUnit:NSCalendarUnitMonth referenceDate:nil andCalendar:[RZUtilsTestsSamples calculationCalendar]]
          objectForKey:STATS_AVG];
    XCTAssertTrue([av count]==5,@"average by week");
    
    XCTAssertEqualWithAccuracy([[av dataPointAtIndex:0] y_data],    1.,    EPS,    @"avg jan");
    XCTAssertEqualWithAccuracy([[av dataPointAtIndex:1] y_data],    2.,    EPS,    @"avg feb");
    XCTAssertEqualWithAccuracy([[av dataPointAtIndex:2] y_data],    3.,    EPS,     @"avg mar");
    XCTAssertEqualWithAccuracy([[av dataPointAtIndex:3] y_data],    4.,    EPS,     @"avg apr");
    XCTAssertEqualWithAccuracy([[av dataPointAtIndex:4] y_data],    5.,    EPS,     @"avg may");
    
    [serie removeAllPoints];
    
    [comp setDay:24];
    [comp setMonth:1];
    [comp setYear:2012];
    [comp setHour:5];// 5am otherwise daylight saving messes up as default = midnight
    date = [cal dateFromComponents:comp];
    [oneUnit setWeekOfYear:0];
    [oneUnit setMonth:1];
    
    for (int i=0; i<3; i++) {
        [serie addDataPointWithDate:date andValue:[[cal components:NSCalendarUnitMonth fromDate:date] month]];
        date = [cal dateByAddingComponents:oneUnit toDate:date options:0];
    }
    av = [[serie aggregatedStatsByCalendarUnit:NSCalendarUnitWeekOfYear referenceDate:nil andCalendar:[RZUtilsTestsSamples calculationCalendar]] objectForKey:STATS_AVG];
    
    NSDateComponents * output = [cal components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitYear fromDate:[[av dataPointAtIndex:0] date]];
    XCTAssertEqual([output month], (NSInteger)1, @"first date week");
    XCTAssertEqual([output day], (NSInteger)22, @"first date week");
    XCTAssertEqual([output year], (NSInteger)2012, @"first date week");
    
    output = [cal components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitYear fromDate:[[av dataPointAtIndex:1] date]];
    XCTAssertEqual([output month], (NSInteger)2, @"second date week");
    XCTAssertEqual([output day], (NSInteger)19, @"second date week");
    XCTAssertEqual([output year], (NSInteger)2012, @"second date week");
    
    output = [cal components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitYear fromDate:[[av dataPointAtIndex:2] date]];
    XCTAssertEqual([output month], (NSInteger)3, @"third date week");
    XCTAssertEqual([output day], (NSInteger)18, @"third date week");
    XCTAssertEqual([output year], (NSInteger)2012, @"third date week");
    
    
    NSDictionary * sample = [RZUtilsTestsSamples aggregateSample];
    NSDictionary * expected = [RZUtilsTestsSamples aggregateExpected];
    [serie removeAllPoints];
    for (NSString * datestr in sample) {
        NSNumber * val = [sample objectForKey:datestr];
        [serie addDataPointWithDate:[NSDate dateForRFC3339DateTimeString:datestr] andValue:[val doubleValue]];
    }
    [serie sortByDate];
    GCStatsDataSerie * e_avg = [[GCStatsDataSerie alloc] init] ;
    GCStatsDataSerie * e_sum = [[GCStatsDataSerie alloc] init] ;
    GCStatsDataSerie * e_max = [[GCStatsDataSerie alloc] init] ;
    for (NSString * datestr in expected) {
        NSDate * d = [NSDate dateForRFC3339DateTimeString:datestr];
        NSArray * a = [expected objectForKey:datestr];
        [e_avg addDataPointWithDate:d andValue:[[a objectAtIndex:0] doubleValue]];
        [e_sum addDataPointWithDate:d andValue:[[a objectAtIndex:1] doubleValue]];
        [e_max addDataPointWithDate:d andValue:[[a objectAtIndex:2] doubleValue]];
    }
    [e_avg sortByDate];
    [e_sum sortByDate];
    [e_max sortByDate];
    NSDictionary * results = [serie aggregatedStatsByCalendarUnit:NSCalendarUnitWeekOfYear referenceDate:nil andCalendar:[RZUtilsTestsSamples calculationCalendar]];
    GCStatsDataSerie * r_avg = [results objectForKey:STATS_AVG];
    GCStatsDataSerie * r_sum = [results objectForKey:STATS_SUM];
    GCStatsDataSerie * r_max = [results objectForKey:STATS_MAX];
    
    XCTAssertEqual([r_avg count], [e_avg count], @"Avg count");
    XCTAssertEqual([r_sum count], [e_sum count], @"Sum count");
    XCTAssertEqual([r_max count], [e_max count], @"Max count");
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    NSTimeZone * tz = [NSTimeZone timeZoneWithName:@"GMT"];
    [formatter setTimeZone:tz];
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    for(NSUInteger i = 0; i<[r_avg count];i++){
        GCStatsDataPoint * r_point = [r_avg dataPointAtIndex:i];
        GCStatsDataPoint * e_point = [e_avg dataPointAtIndex:i];
        XCTAssertTrue([[r_point date] isSameCalendarDay:[e_point date] calendar:cal], @"same date avg");
        XCTAssertEqualWithAccuracy([r_point y_data], [e_point y_data], 1e-6, @"Same Average");
        r_point = [r_sum dataPointAtIndex:i];
        e_point = [e_sum dataPointAtIndex:i];
        XCTAssertTrue([[r_point date] isSameCalendarDay:[e_point date] calendar:cal], @"same date sum");
        XCTAssertEqualWithAccuracy([r_point y_data], [e_point y_data], 1e-6, @"Same sum");
        r_point = [r_max dataPointAtIndex:i];
        e_point = [e_max dataPointAtIndex:i];
        XCTAssertTrue([[r_point date] isSameCalendarDay:[e_point date] calendar:cal], @"same date max");
        XCTAssertEqualWithAccuracy([r_point y_data], [e_point y_data], 1e-6, @"Same max");
        
    }
    
}

-(void)testSimpleStats{
    GCStatsDataSerie * serie = [GCStatsDataSerie dataSerieWithArrayOfDouble:@[ @0.,@160.,
                                                                               @2.,@170.,
                                                                               @5.,@165.,
                                                                               @6.,@175.,
                                                                               @8.,@180.,
                                                                               @10.,@185.]];
    
    double wsum   = 160.*2+170.*3+165*1.+175*2.+180.*2;
    
    NSDictionary * stats = [serie summaryStatistics];
    gcStatsRange range = serie.range;
    
    
    XCTAssertEqual([stats[STATS_AVG] doubleValue], [(GCStatsDataSerie*)[serie average] dataPointAtIndex:0].y_data);
    XCTAssertEqual([stats[STATS_SUM] doubleValue], [(GCStatsDataSerie*)[serie sum] dataPointAtIndex:0].y_data);
    XCTAssertEqual([stats[STATS_AVGPOS] doubleValue], [(GCStatsDataSerie*)[serie average] dataPointAtIndex:0].y_data);
    XCTAssertEqual([stats[STATS_SUMPOS] doubleValue], [(GCStatsDataSerie*)[serie sum] dataPointAtIndex:0].y_data);
    XCTAssertEqual([stats[STATS_WSUM] doubleValue], wsum);
    XCTAssertEqual([stats[STATS_WAVG] doubleValue], wsum/10.);
    
    XCTAssertEqual([stats[STATS_MAX] doubleValue], range.y_max);
    XCTAssertEqual([stats[STATS_MIN] doubleValue], range.y_min);
    
    XCTAssertNil(stats[STATS_SUMNEG]);
    
    serie = [GCStatsDataSerie dataSerieWithArrayOfDouble:@[ @0.,@160.,
                                                            @2.,@170.,
                                                            @5.,@(-165.),
                                                            @6.,@175.,
                                                            @8.,@(-180.),
                                                            @10.,@185.]];
    
    wsum   = 160.*2+170.*3-165*1.+175*2.-180.*2;
    double sumpos = (160.+170.+175.+185.);
    double sumneg = (-165.+-180.);
    
    stats = [serie summaryStatistics];
    range = serie.range;
    
    
    XCTAssertEqual([stats[STATS_AVG] doubleValue], [(GCStatsDataSerie*)[serie average] dataPointAtIndex:0].y_data);
    XCTAssertEqual([stats[STATS_SUM] doubleValue], [(GCStatsDataSerie*)[serie sum] dataPointAtIndex:0].y_data);
    XCTAssertEqual([stats[STATS_WSUM] doubleValue], wsum);
    XCTAssertEqual([stats[STATS_WAVG] doubleValue], wsum/10.);
    
    XCTAssertEqual([stats[STATS_MAX] doubleValue], range.y_max);
    XCTAssertEqual([stats[STATS_MIN] doubleValue], range.y_min);
    
    XCTAssertEqual([stats[STATS_AVGPOS] doubleValue], sumpos/4.);
    XCTAssertEqual([stats[STATS_SUMPOS] doubleValue], sumpos);
    
    XCTAssertEqual([stats[STATS_AVGNEG] doubleValue], sumneg/2.);
    XCTAssertEqual([stats[STATS_SUMNEG] doubleValue], sumneg);
    
    
}

-(void)testDataSerieWithXUnit{
    GCStatsDataSerieWithUnit * su = [GCStatsDataSerieWithUnit dataSerieWithUnit:[GCUnit unitForKey:@"bpm"]];
    GCStatsDataSerie * serie = [GCStatsDataSerie dataSerieWithArrayOfDouble:@[ @500.,@160., @900.,@170., @2000.,@165., @2500.,@175., @3500.,@180., @5000.,@185.]];
    
    su.serie = serie;
    su.xUnit = [GCUnit unitForKey:@"meter"];
    
    [su convertToGlobalSystem];
    
    
    
    //NSLog(@"%@", su);
}

-(void)testDataSerieWithUnit{
    
    GCUnit * km = [GCUnit unitForKey:@"kilometer"];
    GCUnit * m  = [GCUnit unitForKey:@"meter"];
    GCUnit * mile = [GCUnit unitForKey:@"mile"];
    
    GCStatsDataSerieWithUnit * serieWithUnit = [GCStatsDataSerieWithUnit dataSerieWithUnit:m];
    [serieWithUnit addNumberWithUnit:[GCNumberWithUnit numberWithUnit:m andValue:1.] forX:1.];
    
    XCTAssertTrue([[serieWithUnit unit] isEqualToUnit:m], @"serie starts meter");
    [serieWithUnit addNumberWithUnit:[GCNumberWithUnit numberWithUnit:km andValue:0.01] forX:2.0];
    XCTAssertTrue([[serieWithUnit unit] isEqualToUnit:km], @"serie became km");
    XCTAssertTrue([serieWithUnit.serie count] == 2, @"got 2 points");
    XCTAssertEqualWithAccuracy([[serieWithUnit.serie dataPointAtIndex:0] y_data], 0.001, 1e-8, @"1m in km");
    XCTAssertEqualWithAccuracy([[serieWithUnit.serie dataPointAtIndex:1] y_data], 0.010, 1e-8, @"1m in km");
    
    double miles2km = 1.609344;
    
    [serieWithUnit convertToUnit:mile];
    XCTAssertTrue([[serieWithUnit unit] isEqualToUnit:mile], @"serie became mile");
    XCTAssertEqualWithAccuracy([[serieWithUnit.serie dataPointAtIndex:0] y_data], 0.001/miles2km, 1e-8, @"1m in mile");
    XCTAssertEqualWithAccuracy([[serieWithUnit.serie dataPointAtIndex:1] y_data], 0.010/miles2km, 1e-8, @"10m in mile");
    
    [serieWithUnit addNumberWithUnit:[GCNumberWithUnit numberWithUnit:km andValue:1.] forX:3.];
    XCTAssertTrue([[serieWithUnit unit] isEqualToUnit:mile], @"serie stayed mile");
    XCTAssertEqualWithAccuracy([[serieWithUnit.serie dataPointAtIndex:0] y_data], 0.001/miles2km, 1e-8, @"1m in mile");
    XCTAssertEqualWithAccuracy([[serieWithUnit.serie dataPointAtIndex:1] y_data], 0.010/miles2km, 1e-8, @"10m in mile");
    XCTAssertEqualWithAccuracy([[serieWithUnit.serie dataPointAtIndex:2] y_data], 1.000/miles2km, 1e-8, @"1km in mile");
    
    [serieWithUnit convertToUnit:m];
    XCTAssertTrue([[serieWithUnit unit] isEqualToUnit:m], @"serie converted to meter");
    XCTAssertEqualWithAccuracy([[serieWithUnit.serie dataPointAtIndex:0] y_data], 0.001*1000., 1e-8, @"1m in m");
    XCTAssertEqualWithAccuracy([[serieWithUnit.serie dataPointAtIndex:1] y_data], 0.010*1000., 1e-8, @"10m in m");
    XCTAssertEqualWithAccuracy([[serieWithUnit.serie dataPointAtIndex:2] y_data], 1.000*1000., 1e-8, @"1km in m");
    
    [serieWithUnit addNumberWithUnit:[GCNumberWithUnit numberWithUnit:km andValue:0.0001] forX:4.0];
    XCTAssertTrue([[serieWithUnit unit] isEqualToUnit:km], @"serie converted to km");
    XCTAssertEqualWithAccuracy([[serieWithUnit.serie dataPointAtIndex:0] y_data], 0.0010, 1e-8, @"1m in m");
    XCTAssertEqualWithAccuracy([[serieWithUnit.serie dataPointAtIndex:1] y_data], 0.0100, 1e-8, @"10m in m");
    XCTAssertEqualWithAccuracy([[serieWithUnit.serie dataPointAtIndex:2] y_data], 1.0000, 1e-8, @"1km in m");
    XCTAssertEqualWithAccuracy([[serieWithUnit.serie dataPointAtIndex:3] y_data], 0.0001, 1e-8, @"1km in m");
    
    
}

-(void)testStatsCommonX{
    GCStatsDataSerie * serie1 = [[GCStatsDataSerie alloc] init];
    [serie1 addDataPointWithX:1.0 andY:1.0];
    [serie1 addDataPointWithX:1.1 andY:1.0];
    [serie1 addDataPointWithX:1.2 andY:2.0];
    [serie1 addDataPointWithX:2.2 andY:2.0];
    [serie1 addDataPointWithX:3.2 andY:3.0];
    
    
    GCStatsDataSerie * serie2 = [[GCStatsDataSerie alloc] init];
    [serie2 addDataPointWithX:0.9  andY:-1.1];
    [serie2 addDataPointWithX:1.0  andY:-1.0];
    [serie2 addDataPointWithX:1.1  andY:-1.0];
    [serie2 addDataPointWithX:1.22 andY:-2.0];
    [serie2 addDataPointWithX:2.2  andY:-2.0];
    [serie2 addDataPointWithX:3.23 andY:-3.0];
    
    
    [GCStatsDataSerie reduceToCommonRange:serie1 and:serie2];
    
    XCTAssertEqual([serie1 count], [serie2 count], @"Reduced has same size");
    double expected_x[3]={1.0,1.1,2.2};
    for (NSUInteger i=0; i<[serie1 count]; i++) {
        XCTAssertEqualWithAccuracy([[serie1 dataPointAtIndex:i] x_data], [[serie2 dataPointAtIndex:i] x_data],EPS, @"Xs are equal");
        XCTAssertEqualWithAccuracy([[serie1 dataPointAtIndex:i] x_data], expected_x[i],EPS, @"Xs are expected");
    }
}

-(void)testStatsIndexFunction{
    GCStatsDataSerie * serie = [[GCStatsDataSerie alloc] init];
    [serie addDataPointWithX:1.0 andY:1.0];
    [serie addDataPointWithX:1.2 andY:2.0];
    [serie addDataPointWithX:2.2 andY:2.0];
    [serie addDataPointWithX:3.2 andY:3.0];
    
    gcStatsIndexes indexes;
    double xs[] = { 4.0,0.5,2.2,1.5,2.5,1.0,-1.};
    
    size_t i = 0;
    for (i=0; xs[i]!= -1.; i++) {
        NSUInteger start[] = {0,[serie count]-1,([serie count]-1)/2,-1};
        for (int k = 0; start[k]!=-1; k++) {
            indexes = [serie indexForXVal:xs[i] from:start[k]];
            if (indexes.left == indexes.right) {
                XCTAssertEqualWithAccuracy(xs[i], [[serie dataPointAtIndex:indexes.left] x_data], EPS, @"equal");
            }else{
                if (([[serie dataPointAtIndex:indexes.left] x_data] > xs[i] && indexes.left == 0) ||
                    ([[serie dataPointAtIndex:indexes.right] x_data] < xs[i] && indexes.right == [serie count]-1)
                    ) {
                    // outside of bound
                }else{
                    XCTAssertTrue([[serie dataPointAtIndex:indexes.left] x_data] < xs[i], @"surrounded left");
                    XCTAssertTrue([[serie dataPointAtIndex:indexes.right] x_data] > xs[i], @"surrounded right");
                }
            }
            NSUInteger diffleft = start[k]>indexes.left ? (start[k]-indexes.left) : indexes.left-start[k];
            NSUInteger diffright =start[k]>indexes.right ? (start[k]-indexes.right) : indexes.right-start[k];
            NSUInteger diff = diffleft > diffright ? diffleft  : diffright;
            diff+=1;
            XCTAssertTrue(indexes.cnt <=  diff, @"did not look too far");
        }
    }
}

-(void)testSaveSerie{
    GCStatsDataSerie * serie = [[GCStatsDataSerie alloc] init];
    double samples[8] = {2.,4.,4.,4.,5.,5.,7.,9.};
    for (size_t i=0; i<8; i++) {
        [serie addDataPointWithX:i andY:samples[i]];
    }
    NSError * error = nil;
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:serie requiringSecureCoding:YES error:&error];
    XCTAssertTrue(data != nil);
    
    GCStatsDataSerie * load = [NSKeyedUnarchiver unarchivedObjectOfClass:[GCStatsDataSerie class] fromData:data error:nil];
    XCTAssertTrue(load && [serie isEqualToSerie:load]);
}

-(void)testStd{
    // wikipedia sample
    GCStatsDataSerie * serie = [[GCStatsDataSerie alloc] init];
    double samples[8] = {2.,4.,4.,4.,5.,5.,7.,9.};
    for (size_t i=0; i<8; i++) {
        [serie addDataPointWithX:i andY:samples[i]];
    }
    GCStatsDataSerie * std = [serie standardDeviation];
    double d_avg = [[std dataPointAtIndex:0] y_data];
    double d_std = [[std dataPointAtIndex:1] y_data];
    XCTAssertEqual(d_avg, 5., @"Average");
    // std dev= 2, sample std = sqrt(n/n-1)
    XCTAssertEqual(d_std, 2.*sqrt(8./7.), @"sample standard dev");
}

-(void)testRegression{
    // wikipedia sample
    GCStatsDataSerie * serie = [[GCStatsDataSerie alloc] init];
    [serie addDataPointWithX:1.47 andY:52.21];
    [serie addDataPointWithX:1.5 andY:53.12];
    [serie addDataPointWithX:1.52 andY:54.48];
    [serie addDataPointWithX:1.55 andY:55.84];
    [serie addDataPointWithX:1.57 andY:57.2];
    [serie addDataPointWithX:1.6 andY:58.57];
    [serie addDataPointWithX:1.63 andY:59.93];
    [serie addDataPointWithX:1.65 andY:61.29];
    [serie addDataPointWithX:1.68 andY:63.11];
    [serie addDataPointWithX:1.7 andY:64.47];
    [serie addDataPointWithX:1.73 andY:66.28];
    [serie addDataPointWithX:1.75 andY:68.1];
    [serie addDataPointWithX:1.78 andY:69.92];
    [serie addDataPointWithX:1.8 andY:72.19];
    [serie addDataPointWithX:1.83 andY:74.46];
    
    XCTAssertTrue([serie count]== 15, @"Count");
    GCStatsLinearFunction * reg = [serie regression];
    
    XCTAssertEqualWithAccuracy([reg alpha], -39.061956, 0.00001, @"Alpha");
    XCTAssertEqualWithAccuracy([reg beta], 61.272187, 0.00001, @"Alpha");
    
    GCStatsDataSerie * line = [reg valueForXIn:serie];
    double expected[15*2] ={
        1.470000,51.008158,
        1.500000,52.846324,
        1.520000,54.071768,
        1.550000,55.909933,
        1.570000,57.135377,
        1.600000,58.973543,
        1.630000,60.811708,
        1.650000,62.037152,
        1.680000,63.875317,
        1.700000,65.100761,
        1.730000,66.938927,
        1.750000,68.164371,
        1.780000,70.002536,
        1.800000,71.227980,
        1.830000,73.066145
    };
    XCTAssertTrue(line.count == 15, @"Applied function has right size");
    for (NSUInteger i=0; i<15; i++) {
        double x = expected[2*i];
        double y = expected[2*i+1];
        GCStatsDataPoint * point = line[i];
        XCTAssertEqualWithAccuracy(x, [point x_data], 0.00001, @"reg X expected");
        XCTAssertEqualWithAccuracy(y, [point y_data], 0.00001, @"reg Y expected");
        XCTAssertEqualWithAccuracy([point y_data], [reg valueForX:x], EPS, @"reg Y individual");
    }
}

-(void)testInterp{
    GCStatsDataSerie * serie = [[GCStatsDataSerie alloc] init];
    double x;
    for( x = 1.;x<10.;x+=0.5){
        [serie addDataPointWithX:x andY:2.*x+1.];
    }
    GCStatsInterpFunction * interp = [GCStatsInterpFunction interpFunctionWithSerie:serie];
    
    x=2.0;XCTAssertEqualWithAccuracy([interp valueForX:x], 2.*x+1., EPS, @"f(%f)=%f (exp=%f)", x,[interp valueForX:x], 2.*x+1.);
    x=1.0;XCTAssertEqualWithAccuracy([interp valueForX:x], 2.*x+1., EPS, @"f(%f)=%f (exp=%f)", x,[interp valueForX:x], 2.*x+1.);
    x=7.0;XCTAssertEqualWithAccuracy([interp valueForX:x], 2.*x+1., EPS, @"f(%f)=%f (exp=%f)", x,[interp valueForX:x], 2.*x+1.);
    x=3.0;XCTAssertEqualWithAccuracy([interp valueForX:x], 2.*x+1., EPS, @"f(%f)=%f (exp=%f)", x,[interp valueForX:x], 2.*x+1.);
    x=1.2;XCTAssertEqualWithAccuracy([interp valueForX:x], 2.*x+1., EPS, @"f(%f)=%f (exp=%f)", x,[interp valueForX:x], 2.*x+1.);
    x=1.7;XCTAssertEqualWithAccuracy([interp valueForX:x], 2.*x+1., EPS, @"f(%f)=%f (exp=%f)", x,[interp valueForX:x], 2.*x+1.);
    x=0.0;XCTAssertEqualWithAccuracy([interp valueForX:x], 2.*x+1., EPS, @"f(%f)=%f (exp=%f)", x,[interp valueForX:x], 2.*x+1.);
    x=11.;XCTAssertEqualWithAccuracy([interp valueForX:x], 2.*x+1., EPS, @"f(%f)=%f (exp=%f)", x,[interp valueForX:x], 2.*x+1.);
    
}

-(void)testMovingAverage{
    GCStatsDataSerie * serie = [[GCStatsDataSerie alloc] init];
    double x = 0.;
    for (size_t i = 0; i<3; i++) {
        for (size_t k=0; k<5; k++) {
            [serie addDataPointWithX:x+k andY:1.+k];
        }
        x+=5.;
    }
    
    GCStatsDataSerie * smooth = [serie movingAverage:5];
    x=5.;
    for (GCStatsDataPoint * point in smooth) {
        XCTAssertEqualWithAccuracy([point x_data], x, EPS, @"MovingAverage 5samples");
        XCTAssertEqualWithAccuracy([point y_data], 3., EPS, @"MovingAverage 5samples");
        x+=1.;
    }
}

-(void)testHistograms{
    
    NSArray * trials = @[
                         @[ @[ @0.,@160.,
                               @2.,@161.,
                               @5.,@160.,
                               @6.,@175.,
                               @8.,@180.,
                               @18.,@185.],
                            @{
                                @160. : @3.,
                                @161. : @3.,
                                @175. : @2.,
                                @180. : @10.,
                                }
                            ],
                         ];
    
    for (NSArray * trial in trials) {
        GCStatsDataSerie * serie = [GCStatsDataSerie dataSerieWithArrayOfDouble:trial[0]];
        
        NSDictionary * expected = trial[1];
        
        GCStatsDataSerie * hist = [serie histogramOfXSumWithYBucketSize:1.0 andMaxBuckets:300];
        // Now same but without enough buckets
        NSUInteger target = hist.count*0.9;
        GCStatsDataSerie * histless = [serie histogramOfXSumWithYBucketSize:1.0 andMaxBuckets:target];
        XCTAssertLessThan(histless.count, target);

        for (NSNumber * y in expected) {
            NSNumber * sum = expected[y];
            
            gcStatsIndexes indexes = [hist indexForXVal:y.doubleValue from:0];
            XCTAssertEqual(indexes.left, indexes.right); // Exact match
            XCTAssertEqual(hist[indexes.left].y_data, sum.doubleValue, @"Value for %@ is equal to %@", y, sum);
        }
        for (GCStatsDataPoint * point in hist) {
            NSNumber * x = @(point.x_data);
            NSNumber * found = expected[x];
            
            if( fabs(point.y_data)> 1.e-10 ){
                XCTAssertNotNil(found, "x=%@ has a value %@",x,found);
            }else{
                XCTAssertNil(found, "x=%@ has no value", x);
            }
        }
        GCStatsDataSerie * rebucketed = [hist rebucket:histless];
        XCTAssertTrue([rebucketed isEqualToSerie:histless]);
    }
}

-(void)testBucketSerie{
    GCStatsDataSerie * serie   = [[GCStatsDataSerie alloc] init] ;
    GCStatsDataSerie * buckets = [[GCStatsDataSerie alloc] init] ;
    double hr[] = { 120., 121., 122. , 140. , 170., 60., 100., 145., 143., 0., 0.};// last one is ignored
    // 0-50
    // 50-100                                        1                     1
    // 100-130       1     1      1                        1
    // 130-150                           1                      1     1
    // 150-                                    1
    for (size_t i=0; i < sizeof(hr)/sizeof(double); i++) {
        [serie addDataPointWithX:i andY:hr[i]];
    }
    
    double zones[] = { 50., 100., 130., 150. };
    for (size_t i = 0; i < 4; i++) {
        [buckets addDataPointWithX:i andY:zones[i]];
    }
    
    
    GCStatsDataSerie * bucketed = [serie bucketWith:buckets];
    // bucket floor value included (100 goes to 100-130)
    // values below first buckets goes in first buckets: 0 -> 50-100
    double expected[] = {
        2., // 50-100
        4., // 100-130
        3., // 130-150
        1.  // 150 +
    };
    for (size_t i=0; i<4; i++) {
        XCTAssertEqualWithAccuracy([bucketed dataPointAtIndex:i].y_data, expected[i], 1e-7, @"Bucket[%lu] %0.f==%0.f", i,[bucketed dataPointAtIndex:i].y_data, expected[i] );
    }
}

-(void)testIndicatorFunction{
    GCStatsDataSerie * serie = [[GCStatsDataSerie alloc] init];
    [serie addDataPointWithX:1.0 andY:0.0];
    [serie addDataPointWithX:1.2 andY:0.2];
    [serie addDataPointWithX:2.2 andY:0.0];
    [serie addDataPointWithX:3.2 andY:10.0];
    GCStatsNonZeroIndicatorFunction * func = [GCStatsNonZeroIndicatorFunction nonZeroIndicatorFor:serie];
    double xs[] = {
        3.2,1.,
        4.0,1.0,
        0.5,0.,
        2.2,0.0,
        1.5,1.0,
        2.5,0.0,
        1.0,0.,
        
        -1.,-1.};
    
    for (int i = 0; xs[i]!= -1.; i+=2) {
        double x = xs[i];
        double expected = xs[i+1];
        double y = [func valueForX:x];
        XCTAssertEqualWithAccuracy(y, expected, EPS, @"f(%f)=%f",x,y);
    }
    
    
}

-(void)testScaleFunction{
    GCStatsDataSerie * serie = [[GCStatsDataSerie alloc] init];
    [serie addDataPointWithX:1.0 andY:0.0];
    [serie addDataPointWithX:1.2 andY:50.0];
    [serie addDataPointWithX:2.2 andY:20.0];
    [serie addDataPointWithX:3.2 andY:100.0];
    GCStatsScaledFunction * func = [GCStatsScaledFunction scaledFunctionWithSerie:serie];
    double xs[] = {
        3.2,1.,
        4.0,1.0,
        0.5,0.,
        2.2,0.2,
        1.5,0.5,
        2.5,0.2,
        1.0,0.,
        
        -1.,-1.};
    
    for (int i = 0; xs[i]!= -1.; i+=2) {
        double x = xs[i];
        double expected = xs[i+1];
        double y = [func valueForX:x];
        XCTAssertEqualWithAccuracy(y, expected, EPS, @"f(%f)=%f",x,y);
    }
    
}

-(void)testRescaleRefDate{
    NSArray * dateStr = @[ @"2012-09-13T18:48:16.000Z",//thu  wed12 tue11 mon10 sun09
                           @"2012-09-14T19:10:16.000Z",//fri  sat15 sun16
                           @"2012-09-21T18:10:01.000Z",//fri
                           @"2012-10-10T15:00:01.000Z",//wed
                           @"2012-10-11T15:00:01.000Z",//thu
                           @"2012-10-21T15:00:01.000Z",//sun
                           @"2012-10-22T15:00:01.000Z",//mon
                           @"2012-10-23T15:00:01.000Z",//tue
                           @"2012-10-24T15:00:01.000Z",//wed
                           @"2012-10-25T15:00:01.000Z",//thu
                           @"2012-10-26T15:00:01.000Z",//fri
                           @"2012-10-27T15:00:01.000Z",//sat
                           @"2012-10-28T15:00:01.000Z",//sun
                           @"2012-10-29T15:00:01.000Z",//mon
                           @"2012-11-13T16:01:02.000Z"//tue
                           ];
    NSDateComponents * comp = [[NSDateComponents alloc] init];
    comp.month = 9;
    comp.day = 15;
    comp.year = 2013;
    NSDate * refdate = [[RZUtilsTestsSamples calculationCalendar] dateFromComponents:comp];
    
    GCStatsDataSerie * serie = [[GCStatsDataSerie alloc] init];
    GCStatsDateBuckets * bucketer = [GCStatsDateBuckets statsDateBucketFor:NSCalendarUnitMonth referenceDate:refdate andCalendar:[RZUtilsTestsSamples calculationCalendar]];
    bucketer.calendar = [RZUtilsTestsSamples calculationCalendar];
    NSMutableDictionary * expected = [NSMutableDictionary dictionaryWithCapacity:5];
    
    for (NSString * str in dateStr) {
        NSDate * date = [NSDate dateForRFC3339DateTimeString:str];
        [serie addDataPointWithDate:date andValue:1.];
        [bucketer bucket:date];
        NSNumber * curr = [expected objectForKey:bucketer.bucketStart];
        curr = [NSNumber numberWithInt:[curr intValue]+1];
        [expected setObject:curr forKey:bucketer.bucketStart];
    }
    NSDictionary * dict = [serie rescaleWithinCalendarUnit:NSCalendarUnitMonth merged:NO referenceDate:refdate andCalendar:[RZUtilsTestsSamples calculationCalendar]];
    XCTAssertEqual(dict.count, expected.count, @"Expected buckets");
    for (NSDate * key in dict) {
        NSNumber * e_num = [expected objectForKey:key];
        GCStatsDataSerie * serie = [dict objectForKey:key];
        NSUInteger e_count = [e_num integerValue];
        XCTAssertEqual(e_count, serie.count, @"Right allocation");
    }
    
    dict = [serie rescaleWithinCalendarUnit:NSCalendarUnitYear merged:NO referenceDate:nil andCalendar:[RZUtilsTestsSamples calculationCalendar]];
    //NSLog(@"%@", dict);
}

-(void)testBucketDate{
    //   Reference Date = fixed or nil
    //   move 60 days back, check date when bucket changes:
    //          Either 7/30 days away
    //          or date before change had different unit
    
    NSCalendar * cal = [RZUtilsTestsSamples calculationCalendar];


    for( size_t j=0;j<2;j++){
        NSTimeInterval delta = (j == 0) ? -24.0*3600.0 : 24.0*3600.0;
        
        NSDate * testdate = [NSDate dateForRFC3339DateTimeString:@"2020-10-07T09:22:00.000Z"];
        NSDate * refdate = [testdate endOfDayForCalendar:cal];

        if( delta > 0){
            // if > 0 move just past the refdate
            // as all the count assume starting at the beginning/first day of the bucket
            testdate = [testdate dateByAddingTimeInterval:delta];
        }
        
        GCStatsDateBuckets * bucket_week_calendar  = [GCStatsDateBuckets statsDateBucketFor:NSCalendarUnitWeekOfYear referenceDate:nil andCalendar:cal];
        GCStatsDateBuckets * bucket_week_rolling   = [GCStatsDateBuckets statsDateBucketFor:NSCalendarUnitWeekOfYear referenceDate:refdate andCalendar:cal];
        GCStatsDateBuckets * bucket_month_calendar = [GCStatsDateBuckets statsDateBucketFor:NSCalendarUnitMonth referenceDate:nil andCalendar:cal];
        GCStatsDateBuckets * bucket_month_rolling  = [GCStatsDateBuckets statsDateBucketFor:NSCalendarUnitMonth referenceDate:refdate andCalendar:cal];

        [bucket_week_calendar bucket:testdate];
        [bucket_week_rolling bucket:testdate];
        [bucket_month_calendar bucket:testdate];
        [bucket_month_rolling bucket:testdate];
        
        // start at -1. because already one inside the bucket when we start
        NSInteger count_unchanged_week = 0;
        NSInteger count_unchanged_month = 0;

        // Will move forward and then backward by over one year in each direction
        //
        // then check at each bucket change:
        //      - rolling bucket: number of days before change
        //      - calendar bucket: calendar unit changed just for date before and after change.
        
        for( size_t i=0;i<370;i++){
            NSDate * previous_date = [testdate dateByAddingTimeInterval:delta];
            
            BOOL changed_week_calendar = [bucket_week_calendar bucket:previous_date];
            BOOL changed_week_rolling = [bucket_week_rolling bucket:previous_date];
            BOOL changed_month_calendar = [bucket_month_calendar bucket:previous_date];
            BOOL changed_month_rolling = [bucket_month_rolling bucket:previous_date];
            
            NSInteger week_previous = [cal component:NSCalendarUnitWeekOfYear fromDate:previous_date];
            NSInteger week_testdate = [cal component:NSCalendarUnitWeekOfYear fromDate:testdate];
            
            NSInteger month_previous = [cal component:NSCalendarUnitMonth fromDate:previous_date];
            NSInteger month_testdate = [cal component:NSCalendarUnitMonth fromDate:testdate];
            
            if( changed_week_calendar){
                XCTAssertNotEqual(week_previous, week_testdate, @"Calendar Week changed");
            }
            if( changed_month_calendar){
                XCTAssertNotEqual(month_previous, month_testdate, @"Calendar Month Changed");
            }
            
            if( changed_week_rolling ){
                XCTAssertEqual(count_unchanged_week, 6, @"7 days since last change");
            }
            if( changed_month_rolling ){
                NSDate * month_date = previous_date;
                if( delta > 0){
                    // when moving forward is the number of days of the previous month that matters
                    NSDateComponents * comp = [NSDateComponents dateComponentsFromString:@"-1m"];
                    month_date = [cal dateByAddingComponents:comp toDate:previous_date options:0];
                }
                NSRange total_days = [cal rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:month_date];
                XCTAssertEqual(total_days.length, count_unchanged_month+1);
            }
            
            if( changed_week_rolling ){
                count_unchanged_week = 0;
            }else{
                count_unchanged_week += 1;
            }
            if( changed_month_rolling ){
                count_unchanged_month = 0;
            }else{
                count_unchanged_month += 1;
            }
            testdate = previous_date;
        }
    }
}

-(void)testSerieFilter{
    //GCUnit * kph = [GCUnit unitForKey:@"kph"];
    GCUnit * mps = [GCUnit unitForKey:@"mps"];
    GCUnit * minperkm = [GCUnit unitForKey:@"minperkm"];
    
    
    
    void (^runOneTest)(NSArray * expected_min, NSArray * expected_max,NSArray * speeds) = ^(NSArray * expected_min, NSArray * expected_max,NSArray * speeds){
        GCStatsDataSerieWithUnit * serieWithUnit = [GCStatsDataSerieWithUnit dataSerieWithUnit:mps];
        GCStatsDataSerie * serie = serieWithUnit.serie;
        
        NSUInteger n_speeds = [speeds count];
        for (NSUInteger idx = 0; idx < n_speeds; idx++) {
            [serie addDataPointWithX:(double)idx andY:[speeds[idx] doubleValue]];
        }
        gcStatsRange range;
        GCStatsDataSerieFilter * filter = [[GCStatsDataSerieFilter alloc] init];
        filter.filterMaxValue = true;
        filter.filterMinValue = true;
        filter.maxValue = 8.;
        filter.minValue = 1.;
        
        GCStatsDataSerie * filtered = [filter filteredSerieFrom:serie];
        range = [filtered range];
        XCTAssertTrue(range.y_max<filter.maxValue, @"Max respected");
        XCTAssertTrue(range.y_min>filter.minValue, @"Min respected");
        XCTAssertEqualWithAccuracy(range.y_min, [expected_min[0] doubleValue], EPS, @"noacc, min is expected");
        XCTAssertEqualWithAccuracy(range.y_max, [expected_max[0] doubleValue], EPS, @"noacc, max is expected");
        
        filter.filterHighAcceleration = true;
        filter.maxAcceleration = 1.2;
        filter.maxAccelerationSpeedThreshold = 2.;
        
        filtered = [filter filteredSerieFrom:serie];
        range = [filtered range];
        XCTAssertTrue(range.y_max<filter.maxValue, @"Max respected");
        XCTAssertTrue(range.y_min>filter.minValue, @"Min respected");
        // make sure the 0.1 is filtered out because accel to high
        XCTAssertEqualWithAccuracy(range.y_min, [expected_min[1] doubleValue], EPS, @"withacc, min is expected");
        XCTAssertEqualWithAccuracy(range.y_max, [expected_max[1] doubleValue], EPS, @"withacc, max is expected");
        
        serieWithUnit.serie = filtered;
        [serieWithUnit convertToUnit:minperkm];
        gcStatsRange rangeinvert = [[serieWithUnit serie] range];
        XCTAssertEqualWithAccuracy(rangeinvert.y_max, [mps convertDouble:range.y_min toUnit:minperkm], EPS, @"range converted");
        XCTAssertEqualWithAccuracy(rangeinvert.y_min, [mps convertDouble:range.y_max toUnit:minperkm], EPS, @"range converted");
    };
    
    //10mps = 36kph = 1:40 min/km
    // 8mps = 29kph = 2:05 min/km  -- max speed
    // 6mps = 21kph = 2:46 min/km
    // 5mps = 18kph = 3:20 min/km
    // 4mps = 14kph = 4:10 min/km
    // 3mps = 10kph = 5:30 min/km
    // 2mps = 7kph  = 8:30 min/km  -- Acceleration threshold
    // 1mps = 4kph  =16:40 min/km  -- min speed
    
    // min max in the middle
    runOneTest( @[@5.0,@5.0],@[@5.3,@5.3], @[ @5.1,@5.2,@5.3,@5.0,@5.1,@5.2 ] );
    // min max at the extremes
    runOneTest( @[@5.0,@5.0],@[@5.3,@5.3], @[ @5.0,@5.1,@5.2,@5.1,@5.1,@5.3 ] );
    // one bad acceleration in the middle
    runOneTest( @[@5.0,@5.0],@[@7.0,@5.2], @[ @5.0,@5.1,@5.2,@7.0,@5.0,@5.1 ] );
    
    
}

-(void)testFillSerie{
    void (^checkSame)(GCStatsDataSerie*s1,GCStatsDataSerie*s2) = ^(GCStatsDataSerie*s1,GCStatsDataSerie*s2){
        XCTAssertEqual(s1.count, s2.count, @"Same number of points");
        if (s1.count==s2.count) {
            for (NSUInteger i=0; i<s1.count; i++) {
                GCStatsDataPoint * p1 = s1[i];
                GCStatsDataPoint * p2 = s2[i];
                XCTAssertEqualWithAccuracy(p1.x_data, p2.x_data, 1.e-7, @"x matches");
                XCTAssertEqualWithAccuracy(p1.y_data, p2.y_data, 1.e-7, @"y matches");
            }
        }
    };
    
    ////////////////
    GCStatsDataSerie * serie = [GCStatsDataSerie dataSerieWithArrayOfDouble:@[ @1.,@10., @2.,@50., @3.,@20., @4.,@30., @5.,@20., @6.,@30. ]];
    GCStatsDataSerie * rv = [serie filledSerieForUnit:1. ];
    checkSame(rv,serie);
    
    GCStatsDataSerie * expected = [GCStatsDataSerie dataSerieWithArrayOfDouble:@[ @0.,@(10 + (10-50)*(1-0)/(2-1) ), @2.,@50., @4.,@30.]];
    rv = [serie filledSerieForUnit:2.];
    checkSame(rv, expected);
    
    ////////////////
    serie = [GCStatsDataSerie dataSerieWithArrayOfDouble:@[ @1.,@10., @2.,@50., @2.5,@50., @3.,@20., @4.,@10., @7.,@40., @8.,@30. ]];
    
    rv = [serie filledSerieForUnit:1.];
    expected = [GCStatsDataSerie dataSerieWithArrayOfDouble:@[@1.,@10., @2.,@50., @3.,@20., @4.,@10., @5.,@20., @6.,@30., @7.,@40., @8.,@30. ]];
    checkSame(rv, expected);
    
    //rv = [serie filledSerieForUnit:2. fillMethod:gcStatsZero];
    //expected = [GCStatsDataSerie dataSerieWithArrayOfDouble:@[@1.,@30., @3.,@25., @5.,@0., @7.,@25.]];
    
    ////////////////
    serie = [GCStatsDataSerie dataSerieWithArrayOfDouble:@[ @0.,@10., @2.,@50., @3.,@20., @4.,@30., @5.,@20. ]];
    rv = [serie filledSerieForUnit:5.];
    XCTAssertEqualObjects(rv.firstObject,serie.firstObject);
    XCTAssertEqualObjects(rv.lastObject,serie.lastObject);
    XCTAssertEqual(rv.count, 2);
    
    serie = [GCStatsDataSerie dataSerieWithArrayOfDouble:@[ @1.,@10., @2.,@10., @5.,@10., @10.,@35., @11.,@5.]];
    rv = [serie summedSerieByUnit:3. fillMethod:gcStatsZero];
    expected = [GCStatsDataSerie dataSerieWithArrayOfDouble:@[ @1.,@20.,  @4.,@10.,  @7.,@0., @10.,@40.]];
    checkSame(rv, expected);
    
    serie = [GCStatsDataSerie dataSerieWithPoints:@[ [GCStatsDataPoint dataPointWithX:0 andY:1],
                                             [GCStatsDataPointNoValue dataPointWithX:2 andY:0],
                                             [GCStatsDataPointNoValue dataPointWithX:5 andY:0],
                                             [GCStatsDataPointNoValue dataPointWithX:10 andY:0],
                                             [GCStatsDataPointNoValue dataPointWithX:11 andY:0]
    ]];
    rv = [serie filledSerieForUnit:5.];
    expected = [GCStatsDataSerie dataSerieWithArrayOfDouble:@[ @0.,@1.,  @5.,@1.,  @10.,@1.]];
    checkSame(rv, expected);

}

-(void)testBestRolling{
    
    GCStatsDataSerie * serie = [GCStatsDataSerie dataSerieWithArrayOfDouble:@[ @1.,@10., @2.,@50., @3.,@20., @4.,@30., @5.,@20., @6.,@30. ]];
    
    GCStatsDataSerie * filled2 = [serie filledSerieForUnit:1.];
    NSLog(@"%@", filled2);
    GCStatsDataSerie * rv = [serie movingBestByUnitOf:1. fillMethod:gcStatsLast select:gcStatsMax statistic:gcStatsWeightedMean];
    gcStatsRange range = [serie range];
    GCStatsDataSerie * avg = [serie average];
    XCTAssertEqualWithAccuracy([avg[0] y_data], [[rv lastObject] y_data], 1e-6, @"Last is average");
    XCTAssertEqualWithAccuracy(range.y_max, [[rv dataPointAtIndex:0] y_data], 1e-6, @"First is max");
    
    serie = [GCStatsDataSerie dataSerieWithArrayOfDouble:@[ @1.,@10., @2.,@50., @2.5,@50., @3.,@20., @4.,@30., @7.,@20., @8.,@30. ]];
    rv = [serie movingBestByUnitOf:1. fillMethod:gcStatsLast select:gcStatsMax statistic:gcStatsWeightedMean];
    XCTAssertEqualWithAccuracy(range.y_max, [[rv dataPointAtIndex:0] y_data], 1e-6, @"First is max");
    
    GCStatsDataSerie * filled = [serie filledSerieForUnit:2.];
    rv = [serie movingBestByUnitOf:2. fillMethod:gcStatsLast select:gcStatsMax  statistic:gcStatsWeightedMean];
    range = [filled range];
    avg = [filled average];
    XCTAssertEqualWithAccuracy([avg[0] y_data], [[rv lastObject] y_data], 1e-6, @"Last is average");
    XCTAssertEqualWithAccuracy(range.y_max, [[rv dataPointAtIndex:0] y_data], 1e-6, @"First is max");
    
}

-(void)testMovingAverageByUnit{
    GCStatsDataSerie * serie1 = [GCStatsDataSerie dataSerieWithArrayOfDouble:@[ @1.,@10., @2.,@20., @3.,@20., @4.,@30., @5.,@25., @6.,@15. ]];
    GCStatsDataSerie * serie2 = [GCStatsDataSerie dataSerieWithArrayOfDouble:@[ @1.,@10., @2.,@20., @3.,@20., @4.,@30., @5.,@25., @6.,@15. ]];
    GCStatsDataSerie * expected = [GCStatsDataSerie dataSerieWithArrayOfDouble:@[ @1.,@10., @2.,@30., @3.,@50., @4.,@70., @5.,@75., @6.,@70. ]];
    
    XCTAssertTrue([[serie1 movingSumForUnit:2.] isEqualToSerie:expected]);
    
    GCStatsDataSerie * rv = [serie2 movingAverageOrSumOf:serie1 forUnit:2. offset:0. average:false];
    XCTAssertTrue([rv isEqualToSerie:expected]);
    
    serie1 = [GCStatsDataSerie dataSerieWithArrayOfDouble:  @[ @1.,@10., @5.,@10., @6.,@10., @6.5,@10., @7.,@10., @8.,@10. ]];
    expected = [GCStatsDataSerie dataSerieWithArrayOfDouble:@[ @1.,@10., @5.,@10., @6.,@20., @6.5,@30., @7.,@40., @8.,@40. ]];
    XCTAssertTrue([[serie1 movingSumForUnit:2.] isEqualToSerie:expected]);
    rv = [serie1 movingAverageOrSumOf:serie1 forUnit:2. offset:0. average:false];
    XCTAssertTrue([rv isEqualToSerie:expected]);
    
    serie2 = [GCStatsDataSerie dataSerieWithArrayOfDouble:@[ @1.,@10., @2.,@20., @3.,@20., @4.,@30., @7.,@1, @8.,@2 ]];
    rv = [serie2 movingAverageOrSumOf:serie1 forUnit:2. offset:0. average:false];
    expected = [GCStatsDataSerie dataSerieWithArrayOfDouble:@[ @1.,@10., @2.,@10., @3.,@10., @4.,@0., @7.,@40., @8.,@40. ]];
    XCTAssertTrue([rv isEqualToSerie:expected]);
    
    serie2 = [GCStatsDataSerie dataSerieWithArrayOfDouble:@[ @1.,@10., @2.,@20., @3.,@20., @4.,@30., @5.,@12., @7.,@1, @8.,@2 ]];
    rv = [serie2 movingAverageOrSumOf:serie1 forUnit:2. offset:1. average:false];
    expected = [GCStatsDataSerie dataSerieWithArrayOfDouble:@[ @1.,@0., @2.,@10., @3.,@10., @4.,@10., @5.,@0., @7.,@20., @8.,@40. ]];
    XCTAssertTrue([rv isEqualToSerie:expected]);
    
    //  --x-x-x-x--x--x----xx------x
    //  --------y------------y-----y
    //  [-------|
    //               [-------|
    //                     [-------|
    
    serie2 = [GCStatsDataSerie dataSerieWithArrayOfDouble:@[ @1.,@10., @2.,@20., @3.,@20., @4.,@30., @5.,@12., @7.,@1, @8.,@2 ]];
    rv = [serie2 movingFunctionForUnit:2. function:^(NSArray<GCStatsDataPoint*>*pts){
        double max = 0;
        if( pts.count > 0){
            max = pts.firstObject.y_data;
            for (GCStatsDataPoint * pt in pts) {
                if( pt.y_data > max){
                    max = pt.y_data;
                }
            }
        }
        return max;
    }];
    expected = [GCStatsDataSerie dataSerieWithArrayOfDouble:@[ @1.,@10., @2.,@20., @3.,@20., @4.,@30., @5.,@30., @7.,@12., @8.,@2. ]];
    XCTAssertTrue([rv isEqualToSerie:expected]);

}

-(void)testOperand{
    GCStatsDataSerie * serie1 = [GCStatsDataSerie dataSerieWithArrayOfDouble:@[ @1.,@10., @2.,@20., @3.,@20., @4.,@30., @5.,@25., @6.,@15. ]];
    GCStatsDataSerie * serie2 = [GCStatsDataSerie dataSerieWithArrayOfDouble:@[ @1.,@50., @2.,@40., @3.,@40., @4.,@30., @5.,@35., @6.,@45. ]];
    
    GCStatsDataSerie * result = [serie1 operate:gcStatsOperandPlus with:serie2];
    for (GCStatsDataPoint*point in result) {
        XCTAssertEqualWithAccuracy(point.y_data, 60., 1e-8, @"equal 60");
    }
    
    result = [serie1 operate:gcStatsOperandMax with:result];
    for (GCStatsDataPoint*point in result) {
        XCTAssertEqualWithAccuracy(point.y_data, 60., 1e-8, @"equal 60");
    }
    
    result = [serie1 operate:gcStatsOperandMin with:result];
    for (GCStatsDataPoint*point in result) {
        XCTAssertTrue(point.y_data<60., @"Min less than 60");
    }
    
    serie2 = [GCStatsDataSerie dataSerieWithArrayOfDouble:@[ @1.,@50., @2.,@40., @3.5, @20., @4.,@30., @5.,@35., @6.,@45. ]];
    result = [serie1 operate:gcStatsOperandPlus with:serie2];
    //NSLog(@"%@",result);
}

-(void)testCountByX{
    GCStatsDataSerie * (^buildForXs)(NSArray*x) = ^(NSArray*xs){
        GCStatsDataSerie * rv = [[GCStatsDataSerie alloc] init];
        for (NSNumber *xn in xs) {
            [rv addDataPointWithX:xn.doubleValue andY:xn.doubleValue];
        }
        return rv;
    };
    
    GCStatsDataSerie * serie1 = buildForXs(@[@1., @2., @5., @10, @14, @15]);
    GCStatsDataSerie * expected = [GCStatsDataSerie dataSerieWithArrayOfDouble:@[@1,@2,  @4,@1,  @10,@1, @13,@2 ]];
    
    GCStatsDataSerie * count = [serie1 countByXInterval:3. xMax:20.];
    double sum_count = [[count sum] dataPointAtIndex:0].y_data;
    double sum_orig  = [serie1 count];
    XCTAssertEqualWithAccuracy(sum_count, sum_orig, 1.e-7, @"CountByX");
    XCTAssertTrue([count isEqualToSerie:expected], @"Expected countByX");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
