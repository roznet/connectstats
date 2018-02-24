//
//  RZUtilsTouchTests.m
//  RZUtilsTouchTests
//
//  Created by Brice Rosenzweig on 16/07/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <RZUtilsTouch/RZUtilsTouch.h>

@interface RZUtilsTouchTests : XCTestCase

@end

@implementation RZUtilsTouchTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testTableRemap{
    RZTableIndexRemap * remap = [RZTableIndexRemap tableIndexRemap];
    [remap addSection:4 withRows:@[ @(9), @(0) ]];
    [remap addSection:2 withRows:@[ @(1), @(0), @(3) ]];
    
    XCTAssertEqual([remap numberOfSections], 2, @"Number of sections");
    XCTAssertEqual([remap numberOfRowsInSection:0], 2, @"Sect 0" );
    XCTAssertEqual([remap numberOfRowsInSection:1], 3, @"Sect 0" );
    XCTAssertEqual([remap row:[NSIndexPath indexPathForRow:1 inSection:0]], 0, @"s0r1");
    XCTAssertEqual([remap row:[NSIndexPath indexPathForRow:2 inSection:1]], 3, @"s1r2");
    XCTAssertEqual([remap row:[NSIndexPath indexPathForRow:0 inSection:0]], 9, @"s0r0");
    XCTAssertEqual([remap sectionForIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], 4, @"s0");
    XCTAssertEqual([remap sectionForIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]], 2, @"s0");
    
    
}

-(void)testAxis{
    // Width: iPhone6 375, iPhone5 320
    
    GCUnit * second = [GCUnit unitForKey:@"second"];
    GCUnit * meter = [GCUnit unitForKey:@"meter"];
    XCTAssertEqualWithAccuracy([meter axisKnobSizeFor:219. numberOfKnobs:10.], 20.,1e-6, @"Axis sample 219/10");
    XCTAssertEqualWithAccuracy([meter axisKnobSizeFor:3.5 numberOfKnobs:10.], 0.5, 1e-6, @"Axis sample 3.5/10");
    
    GCSimpleGraphGeometry * geometry = [self geometryForXUnit:second unit:meter values:@[ @0., @0., @3420., @12. ] size:CGSizeMake(375., 200.) ];
    
}


-(GCSimpleGraphGeometry*)geometryForXUnit:(GCUnit*)xUnit unit:(GCUnit*)unit values:(NSArray<NSNumber*>*)values size:(CGSize)size{
    if (values.count != 4) {
        return nil;
    }
    
    GCSimpleGraphGeometry * geometry = [[GCSimpleGraphGeometry alloc] init];
    
    NSString * title = [NSString stringWithFormat:@"%@[%@,%@] x %@[%@,%@] in [%.0f,%.0f]", xUnit.key, values[0], values[2], unit.key, values[1], values[3], size.width, size.height];
    
    GCSimpleGraphCachedDataSource * dataSource = [GCSimpleGraphCachedDataSource graphDataSourceWithTitle:title andXUnit:xUnit];
    GCStatsDataSerie * serie = [GCStatsDataSerie dataSerieWithArrayOfDouble:values];
    GCSimpleGraphDataHolder * holder = [GCSimpleGraphDataHolder dataHolder:serie type:gcGraphLine color:nil andUnit:unit];
    [dataSource addDataHolder:holder];
    
    geometry.dataSource = dataSource;
    geometry.drawRect = CGRectMake(0., 0., size.width, size.height);
    [geometry calculate];
    
    return geometry;
    
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
