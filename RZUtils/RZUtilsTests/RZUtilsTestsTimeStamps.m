//
//  RZUtilsTestsTimeStamps.m
//  RZUtils
//
//  Created by Brice Rosenzweig on 14/05/2017.
//  Copyright © 2017 Brice Rosenzweig. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <RZUtils/RZUtils.h>
@interface RZUtilsTestsTimeStamps : XCTestCase

@end

@implementation RZUtilsTestsTimeStamps

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTimeStampManager {
    NSString * fn = @"test_ts.db";
    NSString * dbpath = [NSTemporaryDirectory() stringByAppendingPathComponent:fn];
    
    if( [[NSFileManager defaultManager] fileExistsAtPath:dbpath] ){
        [[NSFileManager defaultManager] removeItemAtPath:dbpath error:nil];
    }
    
    FMDatabase * db = [FMDatabase databaseWithPath:dbpath];
    [db open];
    
    RZTimeStampManager * mgr = [RZTimeStampManager timeStampManagerWithDb:db andTable:@"ts_test"];
    __block NSDate * ts = [NSDate date];
    // Collector adds one timestamp per day
    mgr.collector = ^(){
        ts = [ts dateByAddingTimeInterval:24. * 3600.];
        return ts;
    };
    
    NSString * key1 = @"key1";
    NSString * key2 = @"key2";
    NSString * key3 = @"key3";
    
    NSArray * key1key2 = @[key1, key2];
    NSArray * key2key1 = @[key2, key1];
    NSDate * date1 = nil;
    NSDate * date2 = nil;
    
    NSDictionary * dict = [mgr lastKeysAndTimeStamps];
    XCTAssertTrue(dict.count == 0, @"Start with empty timestamps %@", dict);
    NSMutableArray * key1Dates = [NSMutableArray array];
    
    //Record 1
    [mgr recordTimeStampForKey:key1];
    [mgr recordTimeStampForKey:key2];
    
    dict = [mgr lastKeysAndTimeStamps];
    date1 = dict[key1];
    date2 = dict[key2];
    
    [key1Dates addObject:date1];
    
    XCTAssertTrue([date1 compare:date2] == NSOrderedAscending, @"key1 before key2 (%@<%@)", date1, date2);
    XCTAssertEqualObjects([mgr lastKeysSorted], key2key1);
    //Record 2
    [mgr recordTimeStampForKey:key1];
    
    dict = [mgr lastKeysAndTimeStamps];
    
    date1 = dict[key1];
    date2 = dict[key2];
    
    [key1Dates addObject:date1];
    
    XCTAssertTrue([date1 compare:date2] == NSOrderedDescending, @"key1 after key2 (%@>%@)", date1, date2);
    XCTAssertEqualObjects([mgr lastKeysSorted], key1key2);
    //Record 3
    [mgr recordTimeStampForKey:key1];
    XCTAssertTrue([date1 compare:dict[key1]] == NSOrderedSame, @"Second key1 does not change date (%@==%@)", date1, dict[key1]);
    
    [key1Dates sortUsingComparator:^(NSDate * d1, NSDate * d2){
        return [d2 compare:d1];
    }];
    NSArray * key1Stamps = [mgr lastTimeStampsForKey:key1];
    XCTAssertEqualObjects(key1Stamps, key1Dates);
    
    mgr.queryLimit = 3;
    // alternate key2/key3 so key1 is further away
    for( int i=0;i<4;i++){
        [mgr recordTimeStampForKey:key2];
        [mgr recordTimeStampForKey:key3];
    }
    dict = [mgr lastKeysAndTimeStamps];
    NSArray * key2Stamps = [mgr lastTimeStampsForKey:key2];
    XCTAssertNotNil(dict[key1], @"Make sure we found key1");
    XCTAssertEqualObjects(key2Stamps[0], dict[key2], @"Max date is top of array");
    XCTAssertEqual(key2Stamps.count, 3, @"Found querylimit=3 dates");
    XCTAssertEqual(dict.count, 3, @"Found all 3 Keys");
    
    // We've added 11 days of time stamps
    // First purge older: should get same results
    
    [mgr purgeTimeStampsOlderThan:20];
    XCTAssertEqualObjects([mgr lastKeysAndTimeStamps], dict);
    
    mgr.queryLimit = 20; // get all dates
    
    key1Stamps = [mgr lastTimeStampsForKey:key1];
    key2Stamps = [mgr lastTimeStampsForKey:key2];
    
    NSUInteger pre1 = key1Stamps.count;
    NSUInteger pre2 = key2Stamps.count;
    XCTAssertEqual(pre1, 2);
    XCTAssertEqual(pre2, 5);
    
    [mgr purgeTimeStampsOlderThan:10]; // should get rid of 1 key1
    key1Stamps = [mgr lastTimeStampsForKey:key1];
    key2Stamps = [mgr lastTimeStampsForKey:key2];
    XCTAssertEqual(key1Stamps.count, pre1-1);
    XCTAssertEqual(key2Stamps.count, pre2);
    
    // Now purge middle of key2/3, should preserve older last key1
    [mgr purgeTimeStampsOlderThan:5]; // should get rid of 1 key1
    key1Stamps = [mgr lastTimeStampsForKey:key1];
    key2Stamps = [mgr lastTimeStampsForKey:key2];
    XCTAssertEqual(key1Stamps.count, pre1-1);
    XCTAssertEqual(key2Stamps.count, pre2-3);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
