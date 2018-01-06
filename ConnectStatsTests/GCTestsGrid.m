//
//  GCTestsGrid.m
//  GarminConnect
//
//  Created by Brice Rosenzweig on 29/11/2015.
//  Copyright © 2015 Brice Rosenzweig. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface GCTestsGrid : XCTestCase

@end

@implementation GCTestsGrid

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.

}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGeometry {
    UIView * dummyView = [[[UIView alloc] initWithFrame:CGRectMake(0., 0., 320., 200.)] autorelease];
    GCViewsGrid * grid = [GCViewsGrid viewsGrid:dummyView];
    
    NSDictionary * attrSmall = @{NSFontAttributeName:[UIFont systemFontOfSize:12]};
    NSDictionary * attrLarge = @{NSFontAttributeName: [UIFont systemFontOfSize:16]};
    
    NSAttributedString * smallAttStr =[NSAttributedString attributedString:attrSmall withString:@"BaseSmall"];
    NSAttributedString * mediumAttrStr = [NSAttributedString attributedString:attrLarge withString:@"MiddleLarge"];
    NSAttributedString * largeAttrStr = [NSAttributedString attributedString:attrLarge withString:@"VeryLongAndLarge"];
    
    [grid setupForRows:2 andColumns:3];
    [grid labelForRow:0 andColumn:0].attributedText = smallAttStr;
    [grid labelForRow:1 andColumn:1].attributedText = mediumAttrStr;

    [grid configForRow:0 andColumn:0].minimumSize = CGSizeMake(100., 10.);
    [grid configForRow:1 andColumn:2].minimumSize = CGSizeMake(20., 10.);
    
    NSArray * sizes = [grid sizes];

    CGSize zero = CGSizeMake(0., 0.);
    CGSize small = [smallAttStr size];
    CGSize medium   = [mediumAttrStr size];
    CGSize large   = [largeAttrStr size];
    
    CGSize expected[6] = { CGSizeMake(100., small.height), zero,zero,zero,medium, CGSizeMake(20., 10.) };
    for (NSUInteger i =0; i<6; i++) {
        CGSize got = [sizes[i] CGSizeValue];
        CGSize exp = expected[i];
        XCTAssertEqualWithAccuracy(got.height, exp.height, 1.e-3);
        XCTAssertEqualWithAccuracy(got.width, exp.width, 1.e-3);
    }
    NSArray * colWidths = [grid columnsWidths];
    XCTAssertEqualWithAccuracy([colWidths[0] doubleValue], 100., 1.e-3);
    XCTAssertEqualWithAccuracy([colWidths[1] doubleValue], medium.width, 1.e-3);
    XCTAssertEqualWithAccuracy([colWidths[2] doubleValue], 20., 1.e-3);

    //Changing middle string changes
    [grid labelForRow:1 andColumn:1].attributedText = largeAttrStr;
    colWidths = [grid columnsWidths];
    XCTAssertEqualWithAccuracy([colWidths[0] doubleValue], 100., 1.e-3);
    XCTAssertEqualWithAccuracy([colWidths[1] doubleValue], large.width, 1.e-3);
    XCTAssertEqualWithAccuracy([colWidths[2] doubleValue], 20., 1.e-3);

    CGRect rect = CGRectMake(0., 0., 300., 80.);
    NSArray * cellRects = [grid cellRectsEvenIn:rect];
    [grid setupFrames:cellRects inViewRect:rect];
    NSLog(@"%@", cellRects);
    UILabel * label = [grid labelForRow:1 andColumn:1];
    NSLog(@"%@", NSStringFromCGRect(label.frame));
}

@end
