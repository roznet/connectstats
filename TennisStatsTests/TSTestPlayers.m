//  MIT Licence
//
//  Created on 22/12/2014.
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
#import "TSPlayerManager.h"
#import "TSPlayer.h"
#import "TSTennisSession.h"

@interface TSTestPlayers : XCTestCase

@end

@implementation TSTestPlayers

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    [RZFileOrganizer removeEditableFile:@"players_test.db"];
    FMDatabase * db = [FMDatabase databaseWithPath:[RZFileOrganizer writeableFilePath:@"players_test.db"]];
    [db open];
    [TSPlayerManager ensureDbStructure:db];
    TSPlayerManager * players = [[TSPlayerManager alloc] initWithDatabase:db andThread:nil];
    TSPlayer * p1 = [TSPlayer playerWithFirstName:@"F1" andLastName:@"L1"];
    [players registerPlayer:p1];
    TSPlayer * p2 = [TSPlayer playerWithFirstName:@"F2" andLastName:@"L2"];
    [players registerPlayer:p2];
    XCTAssertNotEqual(p2.playerId, kInvalidPlayerId);
    NSArray * foundBoth = [players playersMatching:@"F"];
    XCTAssertEqual(foundBoth.count, 2);
    NSArray * foundOne = [players playersMatching:@"L1"];
    XCTAssertEqual(foundOne.count, 1);
    NSArray * foundNone = [players playersMatching:@"L1.1"];
    XCTAssertEqual(foundNone.count, 0);

    [p1 updateFirstName:@"F1" andLastName:@"L1.1"];
    [players registerPlayer:p1];
    foundOne = [players playersMatching:@"L1.1"];
    XCTAssertEqual(foundOne.count, 1);


    TSPlayerManager * players2 = [[TSPlayerManager alloc] initWithDatabase:db andThread:nil];
    TSPlayer * reloadp1 = [players2 playerForId:p1.playerId];
    XCTAssertEqual(reloadp1.playerId, p1.playerId);
    XCTAssertEqualObjects(reloadp1.firstName, p1.firstName);
    XCTAssertEqualObjects(reloadp1.lastName, p1.lastName);
    foundOne = [players2 playersMatching:@"L1.1"];
    XCTAssertEqual(foundOne.count, 1);
    foundBoth = [players2 playersMatching:@"F"];
    XCTAssertEqual(foundBoth.count, 2);
    foundOne = [players2 playersMatching:@"L2"];
    XCTAssertEqual(foundOne.count, 1);

    TSTennisSession * session = [TSTennisSession sessionWithId:@"test" forRule:[TSTennisScoreRule defaultRule] andThread:nil];
    [session registerPlayer:p1];
    [session registerOpponent:p2];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
