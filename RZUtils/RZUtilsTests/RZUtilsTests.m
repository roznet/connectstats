//
//  RZUtilsTests.m
//  RZUtilsTests
//
//  Created by Brice Rosenzweig on 08/09/2014.
//  Copyright (c) 2014 Brice Rosenzweig. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <RZUtils/RZUtils.h>

@interface NSNumber (GCTestsCategory)
-(NSNumber*)divideTwo;
@end

@implementation NSNumber (GCTestsCategory)

-(NSNumber*)divideTwo{
    if (self.integerValue % 2 ==0) {
        return @( self.integerValue / 2.);
    }else{
        return nil;
    }
}

@end



@interface RZUtilsTests : XCTestCase

@end

@implementation RZUtilsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testDateComponents{
    NSDate * testDate = [NSDate dateForRFC3339DateTimeString:@"2012-09-13T18:48:16.000Z"];
    NSArray * tests = @[@"1m", @"2012-10-13T18:48:16.000Z",
                        @"-1m",@"2012-08-13T18:48:16.000Z",
                        @"2m", @"2012-11-13T19:48:16.000Z",
                        @"12m",@"2013-09-13T18:48:16.000Z",
                        @"1y", @"2013-09-13T18:48:16.000Z",
                        @"-1y",@"2011-09-13T18:48:16.000Z",
                        @"3y", @"2015-09-13T18:48:16.000Z",
                        @"1w", @"2012-09-20T18:48:16.000Z",
                        @"-1w",@"2012-09-06T18:48:16.000Z",
                        @"4w", @"2012-10-11T18:48:16.000Z",
                        @"-4w",@"2012-08-16T18:48:16.000Z",
                        ];
    for (NSUInteger i=0; i<[tests count]; i+=2) {
        NSString * mat = [tests objectAtIndex:i];
        NSString * datstr = [tests objectAtIndex:i+1];
        
        NSDateComponents * comp = [NSDateComponents dateComponentsFromString:mat];
        NSDate * expected = [NSDate dateForRFC3339DateTimeString:datstr];
        NSDate * got = [testDate dateByAddingGregorianComponents:comp];
        XCTAssertEqualObjects(got, expected, @"date expected for %@", mat);
    }
    
    
}

-(void)testRegressionManager{
    RZRegressionManager * manager = [RZRegressionManager managerForTestClass:[self class]];
    NSDictionary * sample = @{@"a":@1, @"b":@2};
    manager.recordMode = true;
    [manager retrieveReferenceObject:sample selector:_cmd identifier:@"sampleDict" error:nil];
    
    manager.recordMode =false;
    NSDictionary * retrieve = [manager retrieveReferenceObject:sample selector:_cmd identifier:@"sampleDict" error:nil];
    
    XCTAssert([retrieve isEqualToDictionary:sample]);
    
}

-(void)testNilOrEqual{
    XCTAssertTrue(RZNilOrEqualToString(nil, nil));
    XCTAssertTrue(RZNilOrEqualToString(@"a", @"a"));
    XCTAssertFalse(RZNilOrEqualToString(@"a", nil));
    XCTAssertFalse(RZNilOrEqualToString(nil, @"a"));
    XCTAssertFalse(RZNilOrEqualToString(@"b", @"a"));
}

-(void)testSpecialCharacters{
    NSDictionary * tests = @{
                             @"Hello@World%&": @[@"%", @"&", @"@"],
                             @"HelloWorld123": @[],
                             @"HelloWorld@@@": @[@"@"],
                             @"&": @[@"&"],
                             @"&password@": @[ @"&", @"@"],
                             
                             };
    for (NSString * str in tests) {
        NSArray * expect = tests[str];
        NSArray* found = [str specialCharacters];
        XCTAssertEqualObjects(found, expect, @"Special in %@", str);
    }
    
    NSDictionary * testsReplace = @{
                                    @"second[0;5210] x": @"second_0_5210_x",
                                    @"second[0;5210] ": @"second_0_5210",
                                    @"_second[0;5210] ": @"second_0_5210",
                                    @"second__0_5210_ ": @"second_0_5210",
                                    @"secondABC923.232": @"secondABC923_232",
                                    };
    
    for (NSString * test in testsReplace) {
        NSString * rv = [test specialCharacterReplacedBySeparator:@"_"];
        XCTAssertEqualObjects(rv, testsReplace[test]);
    }
}


-(void)testXMLElement{
    GCXMLElement * elem = [GCXMLElement element:@"folder"];
    [elem addParameter:@"a" withValue:@"true"];
    [elem addParameter:@"b" withValue:@"1"];
    [elem addChild:[GCXMLElement element:@"key" withValue:@"value"]];
    GCXMLElement * sub = [GCXMLElement element:@"points"];
    [sub addChild:[GCXMLElement element:@"point" withValue:@"1"]];
    [sub addChild:[GCXMLElement element:@"point" withValue:@"2"]];
    [elem addChild:sub];
    GCXMLElement * extra = [GCXMLElement element:@"extra"];
    [extra addChild:[GCXMLElement element:@"e" withValue:@"1,a"]];
    [extra addChild:[GCXMLElement element:@"e" withValue:@"2,b"]];
    [elem addChild:extra];
    
    NSArray * expectedlines = [NSArray arrayWithObjects:
                               @"<folder a=\"true\" b=\"1\">",
                               @"  <key>value</key>",
                               @"  <points>",
                               @"    <point>1</point>",
                               @"    <point>2</point>",
                               @"  </points>",
                               @"  <extra>",
                               @"    <e>1,a</e>",
                               @"    <e>2,b</e>",
                               @"  </extra>",
                               @"</folder>",
                               @"",
                               nil];
    NSString * expected = [expectedlines componentsJoinedByString:@"\n"];
    XCTAssertEqualObjects(expected, [elem toXML:nil], @"XML output");
    
    GCXMLElement * back = [GCXMLReader elementForData:[expected dataUsingEncoding:NSUTF8StringEncoding]];
    XCTAssertEqualObjects(expected, [back toXML:nil], @"XML output");
    
    NSArray * points = [back findElements:@"point"];
    GCXMLElement * p0 = points[0];
    GCXMLElement * p1 = points[1];
    
    XCTAssertEqualObjects(p0.tag, @"point", @"key right");
    XCTAssertEqualObjects(p1.tag, @"point", @"key right");
    XCTAssertEqualObjects(p0.value, @"1", @"value right");
    XCTAssertEqualObjects(p1.value, @"2", @"value right");
}

-(void)testCamelCase{
    XCTAssertEqualObjects([@"testOneString" fromCamelCaseToSeparatedByString:@" "], @"test One String");
    XCTAssertEqualObjects([@"TestOneString" fromCamelCaseToSeparatedByString:@" "], @"Test One String");
    XCTAssertEqualObjects([@"T" fromCamelCaseToSeparatedByString:@" "], @"T");
    XCTAssertEqualObjects([@"" fromCamelCaseToSeparatedByString:@" "], @"");
    XCTAssertEqualObjects([@"alllowercase" fromCamelCaseToSeparatedByString:@" "], @"alllowercase");
    XCTAssertEqualObjects([@"ALLUP" fromCamelCaseToSeparatedByString:@" "], @"ALLUP");
    XCTAssertEqualObjects([@" () " fromCamelCaseToSeparatedByString:@" "], @"() ");
    XCTAssertEqualObjects([@" (A) " fromCamelCaseToSeparatedByString:@" "], @"( A) ");
}

-(void)testStringEllipsis{
    XCTAssertEqualObjects([@"short"     truncateIfLongerThan:10 ellipsis:@"..."], @"short");
    XCTAssertEqualObjects([@"not so short, quite long" truncateIfLongerThan:10 ellipsis:@".."], @"not ..long");
    XCTAssertEqualObjects([@"longerword"     truncateIfLongerThan:5 ellipsis:@".."], @"l..d");
    XCTAssertEqualObjects([@"longer word"     truncateIfLongerThan:6 ellipsis:@".."], @"lo..rd");
}
#pragma mark - NSArray+Map

-(void)testArrayMap{
    NSArray * testCases = @[
                            
                            @[ @1, @[ @2, @3], @4, @[ @[ @5, @6], @7], @8],
                            @[ @1, @2, @3, @4],
                            @[ @1, @[ @2, @3], @4, @[ @5]]
                            
                            ];
    
    for (NSArray * toFlatten in testCases) {
        NSArray * flattend = [toFlatten arrayFlattened];
        NSArray * div2_block = [flattend arrayByMappingBlock:^(NSNumber*obj){
            if (obj.integerValue % 2 ==0) {
                return @(obj.integerValue/2);
            }else{
                return (NSNumber*)nil;
            }
        }];
        NSArray * div2_sel = [flattend arrayByMappingSelector:@selector(divideTwo)];
        for (NSInteger i=0; i<flattend.count; i++) {
            XCTAssertTrue([flattend[i] isKindOfClass:[NSNumber class]]);
            XCTAssertEqual([flattend[i] integerValue], i+1);
            if ((i+1)%2==0) {
                XCTAssertEqual([div2_block[i] integerValue], (i+1)/2);
                XCTAssertEqual([div2_sel[i] integerValue], (i+1)/2);
            }else{
                XCTAssertEqualObjects(div2_block[i], [NSNull null]);
                XCTAssertEqualObjects(div2_sel[i], [NSNull null]);
            }
        }
    }
}

-(void)testMangling{
    NSArray * testcases = [NSArray arrayWithObjects:
                           @"mypassword", @"yesyes",
                           @"m", @"hello",
                           @"mypassword", @"mypassword",
                           @"", @"key",
                           @"mypassword", @"",
                           nil];
    
    for (NSUInteger i = 0; i<[testcases count]; i+=2) {
        NSString * pwd = [testcases objectAtIndex:i];
        NSString * key = [testcases objectAtIndex:i+1];
        NSData * d = [pwd mangledDataWithKey:key];
        XCTAssertEqualObjects(pwd, [NSString stringFromMangedData:d withKey:key], @"Recover pwd");
    }
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
