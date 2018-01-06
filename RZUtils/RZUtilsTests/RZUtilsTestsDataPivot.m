//
//  RZUtilsTestsDataPivot.m
//  RZUtils
//
//  Created by Brice Rosenzweig on 07/05/2017.
//  Copyright © 2017 Brice Rosenzweig. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <RZUtils/RZUtils.h>

@interface RZUtilsTestsDataPivot : XCTestCase

@end

@implementation RZUtilsTestsDataPivot

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


-(NSString*)shot{
    return @"bh";
}
-(NSString*)player{
    return @"p";
}
-(NSString*)result{
    return @"w";
}
-(NSString*)score{
    return @"0-1";
}

-(void)testDataCube{
    NSArray * cols = @[ @"score", @"shot", @"player", @"result"];
    
    TSDataTable * table = [TSDataTable tableWithColumnNames:cols];
    [table addRow:@{ @"score": @"0-0", @"shot": @"bh", @"player":@"p", @"result":@"w"}];
    [table addRow:self];
    
    [table addRow:@[ @"1-1", @"bh", @"p", @"w"]];
    [table addRow:@[ @"0-1", @"fh", @"p", @"l"]];
    [table addRow:@[ @"1-1", @"bh", @"o", @"w"]];
    [table addRow:@[ @"0-1", @"bh", @"p", @"w"]];
    
    NSArray * testCases =@[
                           @{
                                @"r": @[ @"score", @"shot"],
                                @"c": @[ @"player"],
                                @"v": @[ @"result"],
                                @"e": @[ @1, @0, @2, @0, @1, @0, @1, @1 ]
                               },
                           @{
                               @"r":@[ @"shot"],
                               @"c":@[ @"player", @"score"],
                               @"v":@[@"result"],
                               @"e":@[@1,@2,@1,@1, @0,@1,@0,@0],
                               },
                           @{
                               @"r": @[ @"shot"],
                               @"c": @[ @"player"],
                               @"v": @[ @"result"],
                               @"e": @[ @4, @1, @1, @0 ]
                               },

                           ];
    
    for (NSDictionary*one in testCases) {
        TSDataPivot * pivot = [TSDataPivot pivot:table rows:one[@"r"] columns:one[@"c"] collect:one[@"v"]];
        NSArray * got = [pivot asGrid];
        NSUInteger startIndex = [one[@"c"] count]; // Skip headers for each column
        NSUInteger startCol   = [one[@"r"] count]; // Start from column after each row
        NSUInteger expectedIndex = 0;
        NSArray * expected = one[@"e"];
        for (NSUInteger r=startIndex; r<got.count; r++) {
            NSArray * gotRow = got[r];
            for (NSUInteger c=startCol; c<gotRow.count; c++) {
                id value = gotRow[c];
                if( expectedIndex < expected.count){
                    NSNumber * expectedValue = expected[expectedIndex++];
                    if( [value isKindOfClass:[NSNumber class]]){
                        XCTAssertEqualObjects(value, expectedValue, @"Row %lu[%lu]: expected %@ got %@", (unsigned long)r, (unsigned long)c, expectedValue, gotRow);
                    }else{
                        XCTAssertEqualObjects(expectedValue, @0, @"Row %lu[%lu]: expected %@ got %@", (unsigned long)r, (unsigned long)c, expectedValue, gotRow);
                    }
                }else{
                    XCTFail(@"More results than expected");
                }
                
            }
        }
    }
    
}

@end
