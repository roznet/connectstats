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

#import "TSTennisSession.h"
#import "TSTennisScore.h"
#import "TSTennisOrganizer.h"
#import "TSTennisSessionState.h"
#import "TSTennisRally.h"
#import "TSTennisFields.h"
#import "TSTennisResultSet.h"
#import "TSTennisScoreRule.h"
#import "TSTestSamples.h"
#import "TSAnalysis.h"

#define TEST_FLAG(val,flag) ( (val&flag) == flag)
#define CLEAR_FLAG(val,flag) ( val & ( ~(flag) ) )
#define SET_FLAG(val,flag) (val | (flag) )

/*
 #define FULL_WIDTH   10.97
 #define SINGLE_WIDTH  8.23
 #define HALF_LENGTH  11.89
 #define FULL_LENGTH  23.78
 #define SERVICE_DIST  6.40
 #define SIDE_WIDTH    1.37
 #define AREA_LENGTH  30.00
 #define AREA_WIDTH   15.00
 #define NET_HEIGHT    1.50
 */

NSString * byte_to_binary(unsigned int x){
    NSMutableString * rv = [NSMutableString stringWithCapacity:66];
    [rv appendString:@"0b"];
    int y;
    long long z;
    BOOL started = false;
    for( z=1LL<<(sizeof(int)*8-1),y=0;z>0;z>>=1,y++){
        bool isOne = (x&z)==z;
        if( isOne)
            started = true;
        
        if( started){
            if(isOne){
                [rv appendString:@"1"];
            }else{
                [rv appendString:@"0"];
            }
        }
    }
    return rv;
}


typedef NS_OPTIONS(NSUInteger, testflags) {
    tf_a = 0x1 << 1,
    tf_b = 0x1 << 2,
    tf_c = 0x1 << 3,
    tf_d = 0x1 << 4,
};

@interface TSTestTennisSession : XCTestCase

@end

@implementation TSTestTennisSession

- (void)setUp {
    [super setUp];
    [TSTennisSession setSessionFilePrefix:@"testsession"];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


-(void)testPack{
    TSTennisResultSet * set64 = [[TSTennisResultSet alloc] init];
    set64.playerGames = 6;
    set64.opponentGames = 4;
    
    TSTennisResultSet * setWTb = [[TSTennisResultSet alloc] init];
    setWTb.playerGames = 7;
    setWTb.opponentGames = 6;
    setWTb.tieBreakSet = false;
    setWTb.lastGameWasTieBreak = true;
    setWTb.playerTieBreakPoints = 8;
    setWTb.opponentTieBreakPoints = 6;

    TSTennisResultSet * setTb = [[TSTennisResultSet alloc] init];
    setTb.playerGames = 1;
    setTb.opponentGames = 0;
    setTb.tieBreakSet = true;
    setTb.lastGameWasTieBreak = false;
    setTb.playerTieBreakPoints = 22;
    setTb.opponentTieBreakPoints = 20;


    TSResultPacked pack64 = set64.pack;
    TSResultPacked packWTb = setWTb.pack;
    TSResultPacked packTb = setTb.pack;
    
    TSTennisResultSet * setU64 = [[TSTennisResultSet alloc] init];
    TSTennisResultSet * setUWTb = [[TSTennisResultSet alloc] init];
    TSTennisResultSet * setUTb = [[TSTennisResultSet alloc] init];

    [setUTb unpack:packTb];
    [setUWTb unpack:packWTb];
    [setU64 unpack:pack64];

    XCTAssertTrue([setU64 isEqualToResult:set64]);
    XCTAssertTrue([setUTb isEqualToResult:setTb]);
    XCTAssertTrue([setUWTb isEqualToResult:setWTb]);

    TSTennisScoreRule * rul1 = [TSTennisScoreRule defaultRule];
    TSTennisScoreRule * rul2 = [TSTennisScoreRule shortSetRule];

    TSScoreRulePacked packr1 = [rul1 pack];
    TSScoreRulePacked packr2 = [rul2 pack];

    TSTennisScoreRule * rulu1 = [[TSTennisScoreRule alloc] init];
    TSTennisScoreRule * rulu2 = [[TSTennisScoreRule alloc] init];

    [rulu1 unpack:packr1];
    [rulu2 unpack:packr2];

    XCTAssertTrue([rulu1 isEqualToRule:rul1]);
    XCTAssertTrue([rulu2 isEqualToRule:rul2]);
}

-(void)testScoreResult{
    TSTennisResultSet * set64 = [[TSTennisResultSet alloc] init];
    set64.playerGames = 6;
    set64.opponentGames = 4;

    TSTennisResultSet * setWTb = [[TSTennisResultSet alloc] init];
    setWTb.playerGames = 6;
    setWTb.opponentGames = 7;
    setWTb.tieBreakSet = false;
    setWTb.lastGameWasTieBreak = true;
    setWTb.playerTieBreakPoints = 8;
    setWTb.opponentTieBreakPoints = 6;

    TSTennisResultSet * setTb = [[TSTennisResultSet alloc] init];
    setTb.playerGames = 1;
    setTb.opponentGames = 0;
    setTb.tieBreakSet = true;
    setTb.lastGameWasTieBreak = false;
    setTb.playerTieBreakPoints = 22;
    setTb.opponentTieBreakPoints = 20;

    TSTennisResult * res = [[TSTennisResult alloc] init];
    res.sets = @[ set64, setWTb, setTb ];

    TSTennisScoreRule * rul1 = [TSTennisScoreRule defaultRule];

    tsContestant winner = [rul1 winnerFromResult:res];
    XCTAssertEqual(winner, tsContestantPlayer);

}

-(void)testFlags{
    testflags flag = 0;
    flag = SET_FLAG(flag, tf_a);
    XCTAssertTrue(TEST_FLAG(flag, tf_a));
    XCTAssertFalse(TEST_FLAG(flag, tf_b));
    XCTAssertFalse(TEST_FLAG(flag, tf_c));
    XCTAssertFalse(TEST_FLAG(flag, tf_d));

    flag = SET_FLAG(flag, tf_b);
    XCTAssertTrue(TEST_FLAG(flag, tf_a));
    XCTAssertTrue(TEST_FLAG(flag, tf_b));
    XCTAssertFalse(TEST_FLAG(flag, tf_c));
    XCTAssertFalse(TEST_FLAG(flag, tf_d));

    flag = CLEAR_FLAG(flag, tf_a);
    XCTAssertFalse(TEST_FLAG(flag, tf_a));
    XCTAssertTrue(TEST_FLAG(flag, tf_b));
    XCTAssertFalse(TEST_FLAG(flag, tf_c));
    XCTAssertFalse(TEST_FLAG(flag, tf_d));

    flag = SET_FLAG(flag, tf_b);
    flag = SET_FLAG(flag, tf_c|tf_d);
    XCTAssertFalse(TEST_FLAG(flag, tf_a));
    XCTAssertTrue(TEST_FLAG(flag, tf_b));
    XCTAssertTrue(TEST_FLAG(flag, tf_c));
    XCTAssertTrue(TEST_FLAG(flag, tf_d));

    flag = CLEAR_FLAG(flag, tf_b|tf_d);
    XCTAssertFalse(TEST_FLAG(flag, tf_a));
    XCTAssertFalse(TEST_FLAG(flag, tf_b));
    XCTAssertTrue(TEST_FLAG(flag, tf_c));
    XCTAssertFalse(TEST_FLAG(flag, tf_d));
}

- (void)testReplaySession
{

    NSString * sid = @"201410180916";
    sid = @"201411011705";
    FMDatabase * db = [FMDatabase databaseWithPath:[RZFileOrganizer bundleFilePath:[TSTennisOrganizer eventDbNameFromSessionId:sid] forClass:[self class]]];

    [db open];

    TSTennisSession * session = [TSTennisSession sessionFromEventDb:db players:nil andThread:nil];
    TSTennisSessionState * state = session.state;

    NSArray * scores = [state ralliesWithScores:TSTennisScoreEndOfSet];
    [scores enumerateObjectsUsingBlock:^(TSTennisRally*r, NSUInteger i, BOOL * stop){
        NSLog(@" %@", [r.score endGamesAsString]);
    }];

    scores = [state ralliesWithScores:TSTennisScoreEndOfGame];
    [scores enumerateObjectsUsingBlock:^(TSTennisRally*r, NSUInteger i, BOOL * stop){
        NSLog(@" %@", r.score);
    }];

    TSDataTable * table =[session.state rallyTable];

    TSDataPivot * pivot = [TSDataPivot pivot:table rows:@[ kfLastShotArea,  kfRallyResult ] columns:@[kfWinner] collect:@[kfWinner]];
    NSLog(@"\n%@", [pivot formatAsString]);

    table = [session.state shotTable];
    pivot = [TSDataPivot pivot:table rows:@[kfShotPlayer] columns:@[kfWinner] collect:@[kfWinner]];

    NSLog(@"\n%@", [pivot formatAsString]);
}

-(void)testSessionEvents{
    NSString * sid = @"test";
    TSTennisSession * session = [TSTennisSession sessionWithId:sid forRule:[TSTennisScoreRule defaultRule] andThread:nil];
    TSTennisSessionState * state = session.state;

    // First Serve & Forehand return out
    [session addEvent:[TSTennisEvent event:tsEventShot withLocation:SAMPLE_BACK_LONG_LEFT andDelta:SAMPLE_DELTA_UP]];
    XCTAssertFalse([[state lastRally] lastShotIsEnd]);
    XCTAssertEqual([state lastShot].shotType, tsShotServe);
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 0 0*");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 0");
    [session addEvent:[TSTennisEvent event:tsEventBall withLocation:SAMPLE_FRONT_SERVE_RIGHT_IN]];
    XCTAssertFalse([[state lastRally] lastShotIsEnd]);
    XCTAssertEqual([state lastShot].shotType, tsShotServe);
    XCTAssertTrue([state lastShot].ballIsIn);
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 0 0*");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 0");
    [session addEvent:[TSTennisEvent event:tsEventShot withLocation:SAMPLE_FRONT_LONG_RIGHT andDelta:SAMPLE_DELTA_RIGHT]];
    XCTAssertFalse([[state lastRally] lastShotIsEnd]);
    XCTAssertEqual([state lastShot].shotType, tsShotForehand);
    XCTAssertTrue([state lastShot].ballIsIn);
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 0 0*");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 0");
    [session addEvent:[TSTennisEvent event:tsEventBall withLocation:SAMPLE_BACK_LONG_RIGHT]];
    XCTAssertTrue([[state lastRally] lastShotIsEnd]);
    XCTAssertEqual([state lastShot].shotType, tsShotForehand);
    XCTAssertFalse([state lastShot].ballIsIn);
    [session addEvent:[TSTennisEvent event:tsEventBackPlayerWon]];
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 0 15*");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 0");

    // Double Fault
    [session addEvent:[TSTennisEvent event:tsEventShot withLocation:SAMPLE_BACK_LONG_RIGHT andDelta:SAMPLE_DELTA_UP]];
    XCTAssertFalse([[state lastRally] lastShotIsEnd]);
    XCTAssertEqual([state lastShot].shotType, tsShotServe);
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 0 15*");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 0");
    [session addEvent:[TSTennisEvent event:tsEventBall withLocation:SAMPLE_FRONT_SERVE_RIGHT_IN]];
    XCTAssertFalse([[state lastRally] lastShotIsEnd]);
    XCTAssertEqual([state lastShot].shotType, tsShotServe);
    XCTAssertFalse([state lastShot].ballIsIn);
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 0 15*");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 0");
    [session addEvent:[TSTennisEvent event:tsEventShot withLocation:SAMPLE_BACK_LONG_RIGHT andDelta:SAMPLE_DELTA_UP]];
    XCTAssertFalse([[state lastRally] lastShotIsEnd]);
    XCTAssertEqual([state lastShot].shotType, tsShotServe);
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 0 15*");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 0");
    [session addEvent:[TSTennisEvent event:tsEventBall withLocation:SAMPLE_FRONT_SERVE_RIGHT_IN]];
    XCTAssertTrue([[state lastRally] lastShotIsEnd]);
    XCTAssertEqual([state lastShot].shotType, tsShotServe);
    XCTAssertFalse([state lastShot].ballIsIn);
    [session addEvent:[TSTennisEvent event:tsEventBackPlayerLost]];
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 0 15*");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 15");

    // Test Switch Side twice in the middle
    [session addEvent:[TSTennisEvent event:tsEventPlayerSwithSide]];
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 0 15*");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 15");
    [session addEvent:[TSTennisEvent event:tsEventPlayerSwithSide]];
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 0 15*");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 15");

    // Second Serve In (recorded as out, but extra shot should correct)
    [session addEvent:[TSTennisEvent event:tsEventShot withLocation:SAMPLE_BACK_LONG_RIGHT andDelta:SAMPLE_DELTA_UP]];
    XCTAssertFalse([[state lastRally] lastShotIsEnd]);
    XCTAssertEqual([state lastShot].shotType, tsShotServe);
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 0 15*");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 15");
    [session addEvent:[TSTennisEvent event:tsEventBall withLocation:SAMPLE_FRONT_SERVE_RIGHT_IN]];
    XCTAssertFalse([[state lastRally] lastShotIsEnd]);
    XCTAssertEqual([state lastShot].shotType, tsShotServe);
    XCTAssertFalse([state lastShot].ballIsIn);
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 0 15*");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 15");
    [session addEvent:[TSTennisEvent event:tsEventShot withLocation:SAMPLE_BACK_LONG_RIGHT andDelta:SAMPLE_DELTA_UP]];
    XCTAssertFalse([[state lastRally] lastShotIsEnd]);
    XCTAssertEqual([state lastShot].shotType, tsShotServe);
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 0 15*");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 15");
    [session addEvent:[TSTennisEvent event:tsEventBall withLocation:SAMPLE_FRONT_SERVE_RIGHT_IN]];
    XCTAssertTrue([[state lastRally] lastShotIsEnd]);
    XCTAssertEqual([state lastShot].shotType, tsShotServe);
    XCTAssertFalse([state lastShot].ballIsIn);
    [session addEvent:[TSTennisEvent event:tsEventBackPlayerLost]];

    XCTAssertEqualObjects([state.currentScore playerScore], @"0 0 15*");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 30");
    [session addEvent:[TSTennisEvent event:tsEventBackPlayerWon]];
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 0 30*");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 15");
    // Hitting won again does not change score
    [session addEvent:[TSTennisEvent event:tsEventBackPlayerWon]];
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 0 30*");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 15");
    // Hitting other won changes score (correction)
    [session addEvent:[TSTennisEvent event:tsEventBackPlayerLost]];
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 0 15*");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 30");
    [session addEvent:[TSTennisEvent event:tsEventBackPlayerWon]];
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 0 30*");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 15");
    // Serve + win is enough to record a point
    [session addEvent:[TSTennisEvent event:tsEventShot withLocation:SAMPLE_BACK_LONG_RIGHT andDelta:SAMPLE_DELTA_UP]];
    [session addEvent:[TSTennisEvent event:tsEventBackPlayerWon]];
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 0 40*");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 15");
    [session addEvent:[TSTennisEvent event:tsEventShot withLocation:SAMPLE_BACK_LONG_RIGHT andDelta:SAMPLE_DELTA_UP]];
    [session addEvent:[TSTennisEvent event:tsEventBackPlayerWon]];
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 1 0");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 0*");
    // First Game, switch side

    [session addEvent:[TSTennisEvent event:tsEventPlayerSwithSide]];
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 1 0");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 0*");
    [session addEvent:[TSTennisEvent event:tsEventShot withLocation:SAMPLE_BACK_LONG_RIGHT andDelta:SAMPLE_DELTA_UP]];
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 1 0");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 0*");
    [session addEvent:[TSTennisEvent event:tsEventBackPlayerWon]];
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 1 0");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 15*");

}

-(void)testScore{
    TSTennisScore * score = [TSTennisScore scorePlayerStartsServe:true withRule:[TSTennisScoreRule defaultRule]];
    score.result = [TSTennisResult emptyResult];
    NSMutableArray * scores = [NSMutableArray array];
    [scores addObject:score];
    [scores addObject:[[scores lastObject] playerWonPoint]];
    [scores addObject:[[scores lastObject] opponentWonPoint]];
    [scores addObject:[[scores lastObject] playerWonPoint]];
    [scores addObject:[[scores lastObject] playerWonPoint]];
    [scores addObject:[[scores lastObject] playerWonPoint]];
    // game
    XCTAssertEqual([[scores lastObject] playerGames], 1);
    XCTAssertEqual([[scores lastObject] opponentGames], 0);
    [scores addObject:[[scores lastObject] playerWonPoint]];
    [scores addObject:[[scores lastObject] opponentWonPoint]];
    [scores addObject:[[scores lastObject] playerWonPoint]];
    [scores addObject:[[scores lastObject] playerWonPoint]];
    [scores addObject:[[scores lastObject] opponentWonPoint]];
    [scores addObject:[[scores lastObject] opponentWonPoint]];
    [scores addObject:[[scores lastObject] playerWonPoint]];
    [scores addObject:[[scores lastObject] opponentWonPoint]];
    [scores addObject:[[scores lastObject] playerWonPoint]];
    [scores addObject:[[scores lastObject] opponentWonPoint]];
    [scores addObject:[[scores lastObject] opponentWonPoint]];
    [scores addObject:[[scores lastObject] playerWonPoint]];
    [scores addObject:[[scores lastObject] playerWonPoint]];
    [scores addObject:[[scores lastObject] playerWonPoint]];

    XCTAssertEqual([[scores lastObject] playerGames], 2);
    XCTAssertEqual([[scores lastObject] opponentGames], 0);

    [scores addObject:[[scores lastObject] playerWonPoint]];
    [scores addObject:[[scores lastObject] opponentWonPoint]];
    [scores addObject:[[scores lastObject] opponentWonPoint]];
    [scores addObject:[[scores lastObject] opponentWonPoint]];
    [scores addObject:[[scores lastObject] opponentWonPoint]];
    XCTAssertEqual([[scores lastObject] playerGames], 2);
    XCTAssertEqual([[scores lastObject] opponentGames], 1);

    for (NSUInteger i=0; i<4; i++) {
        [scores addObject:[[scores lastObject] playerWonPoint]];
        [scores addObject:[[scores lastObject] opponentWonPoint]];
        [scores addObject:[[scores lastObject] playerWonPoint]];
        [scores addObject:[[scores lastObject] playerWonPoint]];
        [scores addObject:[[scores lastObject] playerWonPoint]];
    }

    XCTAssertEqual([[scores lastObject] playerSets], 1);
    XCTAssertEqual([[scores lastObject] opponentSets], 0);
    XCTAssertEqual([[scores lastObject] playerGames], 0);
    XCTAssertEqual([[scores lastObject] opponentGames], 0);

    for (NSUInteger i=0; i<6; i++) {
        [scores addObject:[[scores lastObject] playerWonPoint]];
        [scores addObject:[[scores lastObject] opponentWonPoint]];
        [scores addObject:[[scores lastObject] playerWonPoint]];
        [scores addObject:[[scores lastObject] playerWonPoint]];
        [scores addObject:[[scores lastObject] playerWonPoint]];

        [scores addObject:[[scores lastObject] playerWonPoint]];
        [scores addObject:[[scores lastObject] opponentWonPoint]];
        [scores addObject:[[scores lastObject] opponentWonPoint]];
        [scores addObject:[[scores lastObject] playerWonPoint]];
        [scores addObject:[[scores lastObject] opponentWonPoint]];
        [scores addObject:[[scores lastObject] opponentWonPoint]];
    }
    XCTAssertEqual([[scores lastObject] playerSets], 1);
    XCTAssertEqual([[scores lastObject] opponentSets], 0);
    XCTAssertEqual([[scores lastObject] playerGames], 6);
    XCTAssertEqual([[scores lastObject] opponentGames], 6);

    // Tie Break
    [scores addObject:[[scores lastObject] playerWonPoint]];
    [scores addObject:[[scores lastObject] opponentWonPoint]];
    [scores addObject:[[scores lastObject] playerWonPoint]];
    [scores addObject:[[scores lastObject] playerWonPoint]];
    [scores addObject:[[scores lastObject] playerWonPoint]];

    [scores addObject:[[scores lastObject] playerWonPoint]];
    [scores addObject:[[scores lastObject] opponentWonPoint]];
    [scores addObject:[[scores lastObject] opponentWonPoint]];
    [scores addObject:[[scores lastObject] playerWonPoint]];
    [scores addObject:[[scores lastObject] playerWonPoint]];

    XCTAssertEqual([[scores lastObject] playerSets], 2);
    XCTAssertEqual([[scores lastObject] opponentSets], 0);
    XCTAssertEqual([[scores lastObject] playerGames], 0);
    XCTAssertEqual([[scores lastObject] opponentGames], 0);

}

-(void)testUpdateScore{
    NSString * sid = @"test_score";
    TSTennisSession * session = [TSTennisSession sessionWithId:sid forRule:[TSTennisScoreRule defaultRule] andThread:nil];
    TSTennisSessionState * state = session.state;

    // First Serve & Forehand return out
    [session addEvent:[TSTennisEvent event:tsEventShot withLocation:SAMPLE_BACK_LONG_LEFT andDelta:SAMPLE_DELTA_UP]];
    XCTAssertFalse([[state lastRally] lastShotIsEnd]);
    XCTAssertEqual([state lastShot].shotType, tsShotServe);
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 0 0*");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 0");
    [session addEvent:[TSTennisEvent event:tsEventBall withLocation:SAMPLE_FRONT_SERVE_RIGHT_IN]];
    XCTAssertFalse([[state lastRally] lastShotIsEnd]);
    XCTAssertEqual([state lastShot].shotType, tsShotServe);
    XCTAssertTrue([state lastShot].ballIsIn);
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 0 0*");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 0");
    [session addEvent:[TSTennisEvent event:tsEventShot withLocation:SAMPLE_FRONT_LONG_RIGHT andDelta:SAMPLE_DELTA_RIGHT]];
    XCTAssertFalse([[state lastRally] lastShotIsEnd]);
    XCTAssertEqual([state lastShot].shotType, tsShotForehand);
    XCTAssertTrue([state lastShot].ballIsIn);
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 0 0*");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 0");
    [session addEvent:[TSTennisEvent event:tsEventBall withLocation:SAMPLE_BACK_LONG_RIGHT]];
    XCTAssertTrue([[state lastRally] lastShotIsEnd]);
    XCTAssertEqual([state lastShot].shotType, tsShotForehand);
    XCTAssertFalse([state lastShot].ballIsIn);
    [session addEvent:[TSTennisEvent event:tsEventBackPlayerWon]];
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 0 15*");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 0");

    [session addEvent:[TSTennisEvent event:tsEventOpponentUpdateScore withValue:0 second:0 third:1]];
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 0 15*");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 15");

    // Double Fault
    [session addEvent:[TSTennisEvent event:tsEventShot withLocation:SAMPLE_BACK_LONG_RIGHT andDelta:SAMPLE_DELTA_UP]];
    XCTAssertFalse([[state lastRally] lastShotIsEnd]);
    XCTAssertEqual([state lastShot].shotType, tsShotServe);
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 0 15*");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 15");
    [session addEvent:[TSTennisEvent event:tsEventBall withLocation:SAMPLE_FRONT_SERVE_RIGHT_IN]];
    XCTAssertFalse([[state lastRally] lastShotIsEnd]);
    XCTAssertEqual([state lastShot].shotType, tsShotServe);
    XCTAssertFalse([state lastShot].ballIsIn);
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 0 15*");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 15");
    [session addEvent:[TSTennisEvent event:tsEventShot withLocation:SAMPLE_BACK_LONG_RIGHT andDelta:SAMPLE_DELTA_UP]];
    XCTAssertFalse([[state lastRally] lastShotIsEnd]);
    XCTAssertEqual([state lastShot].shotType, tsShotServe);
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 0 15*");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 15");
    [session addEvent:[TSTennisEvent event:tsEventBall withLocation:SAMPLE_FRONT_SERVE_RIGHT_IN]];
    XCTAssertTrue([[state lastRally] lastShotIsEnd]);
    XCTAssertEqual([state lastShot].shotType, tsShotServe);
    XCTAssertFalse([state lastShot].ballIsIn);
    [session addEvent:[TSTennisEvent event:tsEventBackPlayerLost]];
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 0 15*");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 30");

    // Player Wins
    [session addEvent:[TSTennisEvent event:tsEventShot withLocation:SAMPLE_BACK_LONG_LEFT andDelta:SAMPLE_DELTA_UP]];
    XCTAssertFalse([[state lastRally] lastShotIsEnd]);
    XCTAssertEqual([state lastShot].shotType, tsShotServe);
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 0 15*");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 30");
    [session addEvent:[TSTennisEvent event:tsEventBall withLocation:SAMPLE_FRONT_SERVE_RIGHT_IN]];
    XCTAssertFalse([[state lastRally] lastShotIsEnd]);
    XCTAssertEqual([state lastShot].shotType, tsShotServe);
    XCTAssertTrue([state lastShot].ballIsIn);
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 0 15*");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 30");
    [session addEvent:[TSTennisEvent event:tsEventShot withLocation:SAMPLE_FRONT_LONG_RIGHT andDelta:SAMPLE_DELTA_RIGHT]];
    XCTAssertFalse([[state lastRally] lastShotIsEnd]);
    XCTAssertEqual([state lastShot].shotType, tsShotForehand);
    XCTAssertTrue([state lastShot].ballIsIn);
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 0 15*");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 30");
    [session addEvent:[TSTennisEvent event:tsEventBall withLocation:SAMPLE_BACK_LONG_RIGHT]];
    XCTAssertTrue([[state lastRally] lastShotIsEnd]);
    XCTAssertEqual([state lastShot].shotType, tsShotForehand);
    XCTAssertFalse([state lastShot].ballIsIn);
    [session addEvent:[TSTennisEvent event:tsEventBackPlayerWon]];
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 0 30*");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 30");

    [session addEvent:[TSTennisEvent event:tsEventOpponentUpdateScore withValue:0 second:0 third:-1]];
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 0 30*");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 15");

    // Double Fault
    [session addEvent:[TSTennisEvent event:tsEventShot withLocation:SAMPLE_BACK_LONG_RIGHT andDelta:SAMPLE_DELTA_UP]];
    XCTAssertFalse([[state lastRally] lastShotIsEnd]);
    XCTAssertEqual([state lastShot].shotType, tsShotServe);
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 0 30*");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 15");
    [session addEvent:[TSTennisEvent event:tsEventBall withLocation:SAMPLE_FRONT_SERVE_RIGHT_IN]];
    XCTAssertFalse([[state lastRally] lastShotIsEnd]);
    XCTAssertEqual([state lastShot].shotType, tsShotServe);
    XCTAssertFalse([state lastShot].ballIsIn);
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 0 30*");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 15");
    [session addEvent:[TSTennisEvent event:tsEventShot withLocation:SAMPLE_BACK_LONG_RIGHT andDelta:SAMPLE_DELTA_UP]];
    XCTAssertFalse([[state lastRally] lastShotIsEnd]);
    XCTAssertEqual([state lastShot].shotType, tsShotServe);
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 0 30*");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 15");
    [session addEvent:[TSTennisEvent event:tsEventBall withLocation:SAMPLE_FRONT_SERVE_RIGHT_IN]];
    XCTAssertTrue([[state lastRally] lastShotIsEnd]);
    XCTAssertEqual([state lastShot].shotType, tsShotServe);
    XCTAssertFalse([state lastShot].ballIsIn);
    [session addEvent:[TSTennisEvent event:tsEventBackPlayerLost]];
    XCTAssertEqualObjects([state.currentScore playerScore], @"0 0 30*");
    XCTAssertEqualObjects([state.currentScore opponentScore], @"0 0 30");

}

-(void)testForcedSession{
    NSString * sid = @"20150117170928";
    FMDatabase * db = [FMDatabase databaseWithPath:[RZFileOrganizer bundleFilePath:[TSTennisOrganizer eventDbNameFromSessionId:sid] forClass:[self class]]];

    [db open];

    TSTennisSession * session = [TSTennisSession sessionFromEventDb:db players:nil andThread:nil];
    TSTennisSessionState * state = session.state;
    session.isReadOnly = true;

    [session replayToEventIndex:1];
    NSLog(@"%@", state.currentScore);
    [session replayToEventIndex:10];
    NSLog(@"%@", state.currentScore);
    [session replayToEventIndex:22];
    NSLog(@"%@", state.currentScore);
    TSScore currGames = state.currentScore.gameNumber+1;
    [session replayToEventMatching:^(TSTennisSessionState*cur){
        return (BOOL)(cur.currentScore.gameNumber == currGames );
    }
                              hint:false];
    NSLog(@"%@", state.currentScore);
    currGames = 4;
    [session replayToEventMatching:^(TSTennisSessionState*cur){
        return (BOOL)(cur.currentScore.gameNumber == currGames );
    }
                              hint:false];
    NSLog(@"%@", state.currentScore);
    currGames = 2;
    [session replayToEventMatching:^(TSTennisSessionState*cur){
        return (BOOL)(cur.currentScore.gameNumber == currGames );
    }
                              hint:false];
    NSLog(@"%@", state.currentScore);


}

-(void)testSessionShotAnalysis{
    FMDatabase * db = [FMDatabase databaseWithPath:[RZFileOrganizer bundleFilePath:@"cloud_session_20150708164712.db" forClass:[self class]]];
    [db open];

    TSTennisSession * session = [TSTennisSession sessionFromEventDb:db players:nil andThread:nil];

    TSDataTable * shots = [session.state shotTable];
    XCTAssertEqual(shots.rows.count, 85);
    TSAnalysis * analyser=[TSAnalysis analysisForSession:session];
    TSDataTable * analysis = [analyser analyse];
    TSDataPivot *pivot = [TSDataPivot pivot:analysis rows:@[ kfPlayerName] columns:@[kfAnalysisName,kfAnalysisSituation] collect:@[kfAnalysisCount]];
    TSDataTable * pivoted = [pivot asTable:tsPivotSumOrCount];

    NSLog(@"%@", [pivot formatAsString]);
}

-(void)addEventsIn:(FMDatabase*)db to:(TSTennisSession*)session{
    FMResultSet * res = [db executeQuery:@"SELECT * FROM events ORDER BY time" ];
    NSDate * sessionEndTime = session.currentEvent.time;
    NSDate * eventStartTime = nil;
    while ([res next]) {
        TSTennisEvent * event = [TSTennisEvent eventWithResultSet:res];
        if (eventStartTime == nil) {
            eventStartTime = event.time;
        }
        if(sessionEndTime == nil){
            sessionEndTime = event.time;
        }
        NSDate * adjustedEventTime = [sessionEndTime dateByAddingTimeInterval:[event.time timeIntervalSinceDate:eventStartTime]];
        event.time = adjustedEventTime;
        [session addEvent:event];
    }
}

-(void)testPerformanceScale{
    FMDatabase * db = [FMDatabase databaseWithPath:[RZFileOrganizer bundleFilePath:@"session_test_large.db" forClass:[self class]]];
    [db open];

    TSTennisSession * session = [TSTennisSession sessionFromEventDb:db players:nil andThread:nil];

    [self measureBlock:^{
        TSDataTable * shots = [session.state shotTable];
        NSLog(@"%lu", shots.rows.count);
    }];



}
@end
