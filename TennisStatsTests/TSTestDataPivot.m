//  MIT Licence
//
//  Created on 23/10/2014.
//
//  Copyright (c) 2014 Brice Rosenzweig.
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

@import Foundation;
@import UIKit;
@import RZUtils;

#import <XCTest/XCTest.h>

@interface TSTestDataPivot : XCTestCase

@end

@implementation TSTestDataPivot

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

/*
- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}
*/

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

    TSDataPivot * pivot = [TSDataPivot pivot:table rows:@[@"score", @"shot"] columns:@[@"player"] collect:@[@"result"]];
    NSLog(@"\n%@", [pivot formatAsString]);
    pivot = [TSDataPivot pivot:table rows:@[ @"shot"] columns:@[ @"player", @"score"] collect:@[@"result"]];
    //NSArray * grid = [pivot asGridForRows:[pivot rowsValues] cols:[pivot columnsValues] andData:pivot.collect];
    NSLog(@"\n%@", [pivot formatAsHtml]);
    pivot = [TSDataPivot pivot:table rows:@[@"score", @"shot"] columns:@[@"player"] collect:@[@"result"]];
    NSLog(@"\n%@", [pivot formatAsString]);
}

@end
