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

@interface GCTestsDerived : XCTestCase

@end

@implementation GCTestsDerived

- (void)setUp
{
    [super setUp];
    [GCAppGlobal startSuccessful];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

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
}


@end
