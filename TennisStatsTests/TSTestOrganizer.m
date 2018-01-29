//  MIT Licence
//
//  Created on 31/12/2014.
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
#import "TSTennisOrganizer.h"
#import "TSTennisSession.h"
#import "TSTennisScoreRule.h"
#import "TSTestSamples.h"
#import "TSPlayerManager.h"
#import "TSTennisSession+Test.h"
#import "TSCloudTypes.h"

@interface TSTestOrganizer : XCTestCase

@end

@implementation TSTestOrganizer

- (void)setUp {
    [super setUp];
    [TSTennisSession setSessionFilePrefix:@"testsession"];

    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)recordGame:(TSTennisSession*)session backWon:(BOOL)back{

    // First Serve & Forehand return out
    for (NSUInteger i=0; i<4; i++) {
        [session addEvent:[TSTennisEvent event:tsEventShot withLocation:SAMPLE_BACK_LONG_LEFT andDelta:SAMPLE_DELTA_UP]];
        [session addEvent:[TSTennisEvent event:back ? tsEventBackPlayerWon : tsEventFrontPlayerWon]];
    }
}

-(void)cleanTestFiles{
    NSArray * toDelete = [RZFileOrganizer writeableFilesMatching:^(NSString*fn){
        return [fn hasPrefix:@"test"];
    }];
    for (NSString * fn in toDelete) {
        [RZFileOrganizer removeEditableFile:fn];
    }

}

- (void)testOrganizerWorkflow {
    [self cleanTestFiles];

    //---------- Setup 1st organizer
    NSString * fn = [RZFileOrganizer writeableFilePath:@"test_organizer.db"];
    int count = 0;

    FMDatabase * db = [FMDatabase databaseWithPath:fn];
    [db open];
    [TSTennisOrganizer ensureDbStructure:db];
    [TSPlayerManager ensureDbStructure:db];

    TSPlayerManager * players = [[TSPlayerManager alloc] initWithDatabase:db andThread:nil];
    TSTennisOrganizer * organizer = [TSTennisOrganizer organizerWith:db players:players andThread:nil];
    organizer.sessionIdPrefix = @"a";
    //---------- Setup 2nd organizer
    NSString * fn2 = [RZFileOrganizer writeableFilePath:@"test_organizer2.db"];

    FMDatabase * db2 = [FMDatabase databaseWithPath:fn2];
    [db2 open];
    [TSTennisOrganizer ensureDbStructure:db2];
    [TSPlayerManager ensureDbStructure:db2];

    TSPlayerManager * players2 = [[TSPlayerManager alloc] initWithDatabase:db2 andThread:nil];
    TSTennisOrganizer * organizer2 = [TSTennisOrganizer organizerWith:db2 players:players2 andThread:nil];
    organizer2.sessionIdPrefix = @"b";

    //---------- Add players and session to organizer 1;
    TSPlayer * p1 = [TSPlayer playerWithFirstName:@"F1" andLastName:@"L1"];
    TSPlayer * p2 = [TSPlayer playerWithFirstName:@"F2" andLastName:@"L2"];
    [players registerPlayer:p1];
    [players registerPlayer:p2];

    [organizer startNewSession:[TSTennisScoreRule defaultRule]];
    TSTennisSession * session = [organizer currentSession];

    [session registerPlayer:p1];
    [session registerOpponent:p2];

    for (NSUInteger i=0; i<6; i++) {
        [self recordGame:session backWon:true];
    }

    //---------- Add Players and session to organizer 2
    TSPlayer * p3 = [TSPlayer playerWithFirstName:@"F3" andLastName:@"L3"];
    TSPlayer * p1_2 = [TSPlayer playerWithFirstName:@"F1" andLastName:@"L1"];// same player as p1
    [players2 registerPlayer:p3];
    [players2 registerPlayer:p1_2];

    [organizer2 startNewSession:[TSTennisScoreRule defaultRule]];
    TSTennisSession * session2 = [organizer2 currentSession];
    [session2 registerPlayer:p1_2];
    [session2 registerOpponent:p3];

    for (NSUInteger i=0; i<3; i++) {
        [self recordGame:session2 backWon:YES];
        [self recordGame:session2 backWon:NO];
        [self recordGame:session2 backWon:YES];
    }

    //---------- Add players and session to organizer 1;
    TSPlayer * p4 = [TSPlayer playerWithFirstName:@"F4" andLastName:@"L4"];
    [players registerPlayer:p4];

    [organizer startNewSession:[TSTennisScoreRule defaultRule]];
    TSTennisSession * session3 = [organizer currentSession];

    [session3 registerPlayer:p1];
    [session3 registerOpponent:p4];

    for (NSUInteger i=0; i<6; i++) {
        [self recordGame:session3 backWon:NO];
        [self recordGame:session3 backWon:YES];
        [self recordGame:session3 backWon:NO];
    }

    [organizer startNewSession:[TSTennisScoreRule defaultRule]];
    TSTennisSession * session4 = [organizer currentSession];


    // Simulate save to cloud:
    CKRecord * record = [[CKRecord alloc] initWithRecordType:kTSRecordTypeSession recordID:[[CKRecordID alloc] initWithRecordName:@"RECORD1"]];
    record[kTSRecordFieldSessionId] = session2.sessionId;
    [session2 noticeCloudRecord:record];
    CKRecord * rp1 = [[CKRecord alloc] initWithRecordType:kTSRecordTypePlayer recordID:[[CKRecordID alloc] initWithRecordName:@"PLAYERA"]];
    CKRecord * rp2 = [[CKRecord alloc] initWithRecordType:kTSRecordTypePlayer recordID:[[CKRecordID alloc] initWithRecordName:@"PLAYERB"]];
    [players2 noticeCloudRecord:rp1 forPlayer:p3];
    [players2 noticeCloudRecord:rp2 forPlayer:p1_2];

    count = [db intForQuery:@"SELECT COUNT(*) FROM tennis_sessions WHERE session_id = ?", session2.sessionId];
    XCTAssertEqual(count, 0);
    count = [db intForQuery:@"SELECT COUNT(*) FROM tennis_sessions WHERE sessionRecordId=?", @"RECORD1"];
    XCTAssertEqual(count, 0);
    count = [db intForQuery:@"SELECT COUNT(*) FROM players WHERE playerRecordId=?", @"PLAYERA"];
    XCTAssertEqual(count, 0);
    count = [db intForQuery:@"SELECT COUNT(*) FROM players WHERE playerRecordId=?", @"PLAYERB"];
    XCTAssertEqual(count, 0);

    TSTennisSession *session2_1 = [organizer sessionFromEventDb:[session2 eventdb]];

    count = [db intForQuery:@"SELECT COUNT(*) FROM tennis_sessions WHERE session_id = ?", session2.sessionId];
    XCTAssertEqual(count, 1);
    count = [db intForQuery:@"SELECT COUNT(*) FROM tennis_sessions WHERE sessionRecordId=?", @"RECORD1"];
    XCTAssertEqual(count, 1);
    count = [db intForQuery:@"SELECT COUNT(*) FROM players WHERE playerRecordId=?", @"PLAYERA"];
    XCTAssertEqual(count, 1);
    count = [db intForQuery:@"SELECT COUNT(*) FROM players WHERE playerRecordId=? AND firstName=?", @"PLAYERB",@"F1"];
    XCTAssertEqual(count, 1);

    XCTAssertEqualObjects(session2.sessionId, session2_1.sessionId);
    count = [db intForQuery:@"SELECT COUNT(*) FROM tennis_sessions WHERE session_id = ?", session2_1.sessionId];
    XCTAssertEqual(organizer.sessions.count, 4);

    count = [db intForQuery:@"SELECT COUNT(*) FROM tennis_sessions WHERE session_id = ?", session4.sessionId];
    XCTAssertEqual( count, 1);
    [organizer deleteSession:session4];
    XCTAssertEqual(organizer.sessions.count, 3);
    count = [db intForQuery:@"SELECT COUNT(*) FROM tennis_sessions WHERE session_id = ?", session4.sessionId];
    XCTAssertEqual(count, 0);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
