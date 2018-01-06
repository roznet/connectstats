//  MIT Licence
//
//  Created on 19/10/2014.
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

#import <Foundation/Foundation.h>
#import "TSTennisResult.h"

typedef NS_OPTIONS(NSUInteger, TSTennisScoreFlag) {
    TSTennisScoreAny                = 0,
    TSTennisScoreStartOfGame        = 0x1 << 0,
    TSTennisScoreEndOfGame          = 0x1 << 1,
    TSTennisScoreStartOfSet         = 0x1 << 2,
    TSTennisScoreEndOfSet           = 0x1 << 3,
    TSTennisScoreEndOfMatch         = 0x1 << 4,

    TSTennisScoreRegularGame        = 0x1 << 5,
    TSTennisScoreTieBreak           = 0x1 << 6,
    TSTennisScoreMatchTieBreak      = 0x1 << 7,

    TSTennisScorePlayerServe        = 0x1 << 8,
    TSTennisScoreOpponentServe      = 0x1 << 9,

    TSTennisScorePlayerWon          = 0x1 << 10,
    TSTennisScoreOpponentWon        = 0x1 << 11
};


// 40-15
// 1-0 0-0
#import "TSTennisScoreRule.h"
#import "TSTennis.h"
#import "TSTennisResult.h"

@interface TSTennisScore : NSObject
@property (nonatomic,assign) TSScore playerGames;
@property (nonatomic,assign) TSScore opponentGames;
@property (nonatomic,assign) TSScore playerSets;
@property (nonatomic,assign) TSScore opponentSets;
@property (nonatomic,assign) TSScore playerPoints;
@property (nonatomic,assign) TSScore opponentPoints;

@property (nonatomic,retain) TSTennisResult * result;


+(TSTennisScore*)scorePlayerStartsServe:(BOOL)playerStart withRule:(TSTennisScoreRule*)rule;
+(TSTennisScore*)scoreWithScore:(TSTennisScore*)other;
+(TSTennisScore*)zeroScore;
-(TSTennisScore*)removePointPlayer;
-(TSTennisScore*)removePointOpponent;

-(TSTennisScore*)playerWonPoint;
-(TSTennisScore*)opponentWonPoint;

-(TSTennisScore*)serverWonPoint;
-(TSTennisScore*)receiverWonPoint;

-(TSTennisScore*)adjustScore:(tsContestant)contestant sets:(TSScore)sets games:(TSScore)games points:(TSScore)points;

-(NSString*)pointsAsString;
-(NSString*)gamesAsString;
-(NSString*)setsAsString;
-(NSArray*)playerOpponentFullScoreStringArray;

-(TSScore)setNumber;
-(TSScore)gameNumber;
-(TSScore)pointNumber;

-(NSString*)playerScore;
-(NSString*)opponentScore;

-(NSString*)endGamesAsString;

-(BOOL)testFlag:(TSTennisScoreFlag)flag;

-(tsDifferential)playerPointDifferential;
-(tsScoreCriticality)criticality;
@end
