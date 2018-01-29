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

#import "TSTennisScore.h"
#import "TSTennisScoreRule.h"

// Status:
// Which Set
// EndOfGame Score
// EndOfSet Score
// Game Number overall
//
// Current:
// Point Number in current Game
// How Many Sets Each
// Game in current Set
// current Set
// Regular Game or Tie Break
//



#define TEST_FLAG(val,flag) ( (val&flag) == flag)
#define CLEAR_FLAG(val,flag) ( val & ( ~(flag) ) )
#define SET_FLAG(val,flag) (val | (flag) )

@interface TSTennisScore ()
@property (nonatomic,assign) NSUInteger flag;
@property (nonatomic,retain) TSTennisScoreRule * rule;
@property (nonatomic,assign) TSScore countOfGames;
@property (nonatomic,assign) TSScore countOfPoints;


@end

@implementation TSTennisScore
+(TSTennisScore*)scorePlayerStartsServe:(BOOL)playerStart withRule:(TSTennisScoreRule*)rule{
    TSTennisScore * rv = [[TSTennisScore alloc] init];
    if (rv) {
        rv.rule = rule;
        rv.flag |= playerStart ? TSTennisScorePlayerServe : TSTennisScoreOpponentServe;
        rv.flag |= TSTennisScoreRegularGame;
        rv.result = [TSTennisResult emptyResult];
    }
    return  rv;
}

+(TSTennisScore*)scoreWithScore:(TSTennisScore*)other{
    TSTennisScore * rv = [[TSTennisScore alloc] init];
    if (rv) {
        rv.playerGames = other.playerGames;
        rv.opponentGames = other.opponentGames;
        rv.playerSets = other.playerSets;
        rv.opponentSets = other.opponentSets;
        rv.playerPoints = other.playerPoints;
        rv.opponentPoints = other.opponentPoints;
        rv.flag = other.flag;
        rv.rule = other.rule;
        rv.result = other.result;
        rv.countOfPoints = other.countOfPoints;
        rv.countOfGames = other.countOfGames;
    }
    return  rv;

}

+(TSTennisScore*)zeroScore{
    TSTennisScore * rv = [[TSTennisScore alloc] init];
    if (rv) {
        rv.playerGames = 0;
        rv.opponentGames = 0;
        rv.playerSets = 0;
        rv.opponentSets = 0;
        rv.playerPoints = 0;
        rv.opponentPoints = 0;
        rv.result = [TSTennisResult emptyResult];
    }
    return rv;
}
-(BOOL)isGamePointForContestant:(tsContestant)contestant{
    if (contestant==tsContestantUnknown) {
        return false;
    }
    return [self checkPointsWonGame:contestant == tsContestantPlayer ? self.playerPoints+1 : self.opponentPoints+1
                              other:contestant == tsContestantPlayer ? self.opponentPoints : self.playerPoints];
}

-(BOOL)isDeucePoint:(TSScore)points other:(TSScore)other{
    if ( TEST_FLAG(self.flag, TSTennisScoreRegularGame) ) {
        return points >= 4 && points == other;
    }else if(TEST_FLAG(self.flag, TSTennisScoreTieBreak)) {
        return points >= self.rule.tieBreakNumberOfPoints && points == other;
    }else if(TEST_FLAG(self.flag, TSTennisScoreMatchTieBreak)){
        return points >= self.rule.decidingSetTieBreakNumberOfPoints && points== other;
    }

    return false;

}
-(BOOL)checkPointsWonGame:(TSScore)points other:(TSScore)other{
    if ( TEST_FLAG(self.flag, TSTennisScoreRegularGame) ) {
        if( self.rule.gameEndWithSuddenDeath){
            return points >= 4;
        }else{
            return points >= 4 && points > other+1;
        }
    }else if(TEST_FLAG(self.flag, TSTennisScoreTieBreak)) {
        return points >= self.rule.tieBreakNumberOfPoints && points > other+1;
    }else if(TEST_FLAG(self.flag, TSTennisScoreMatchTieBreak)){
        return points >= self.rule.decidingSetTieBreakNumberOfPoints && points > other+1;
    }

    return false;
}

-(BOOL)isLastSet{
    return [self.rule checkIsLastSet:self.playerSets+self.opponentSets];
}

-(BOOL)checkGamesWonSet:(TSScore)games other:(TSScore)other{
    return [self.rule checkGamesWonSet:games other:other set:self.playerSets+self.opponentSets];
}

-(BOOL)checkTieBreak:(TSScore)games other:(TSScore)other{
    return [self.rule checkTieBreak:games other:other];
}

-(BOOL)checkSetsWonMatch:(TSScore)sets other:(TSScore)other{
    return [self.rule checkSetsWonMatch:sets other:other];
}

-(void)updateResults{
    if (self.result) {
        TSTennisResultSet * current = [self.result lastSet];

        if(TEST_FLAG(self.flag, TSTennisScoreMatchTieBreak)){
            current.lastGameWasTieBreak = false;
            current.tieBreakSet = true;
        }else{
            current.playerGames = self.playerGames;
            current.opponentGames = self.opponentGames;

            if(TEST_FLAG(self.flag, TSTennisScoreTieBreak)) {
                current.lastGameWasTieBreak =true;
                current.playerTieBreakPoints = self.playerPoints;
                current.opponentTieBreakPoints = self.opponentPoints;
            }
        }
    }
}

-(void)nextGame:(TSTennisScore*)previous{
    if ([self checkPointsWonGame:self.playerPoints other:self.opponentPoints]) {
        self.playerGames++;
        self.countOfGames++;
        self.flag = SET_FLAG(self.flag, TSTennisScoreStartOfGame);
    }else if([self checkPointsWonGame:self.opponentPoints other:self.playerPoints]){
        self.opponentGames++;
        self.countOfGames++;
        self.flag = SET_FLAG(self.flag, TSTennisScoreStartOfGame);
    }else{
        // no one won
        return;
    }

    if ([self checkGamesWonSet:self.playerGames other:self.opponentGames]) {
        self.playerSets++;
        [self updateResults];
        if ([self checkSetsWonMatch:self.playerSets other:self.opponentSets]) {
            self.flag = SET_FLAG(self.flag, TSTennisScoreEndOfMatch);
            self.result.winner = tsContestantPlayer;
        }else{
            [self.result nextSet];
        }
        self.playerGames = 0;
        self.opponentGames = 0;
        self.flag =  SET_FLAG(self.flag, TSTennisScoreStartOfSet);
        previous.flag = SET_FLAG(previous.flag, TSTennisScoreEndOfSet);

    }else if ([self checkGamesWonSet:self.opponentGames other:self.playerGames]){
        self.opponentSets++;
        [self updateResults];
        if ([self checkSetsWonMatch:self.opponentSets other:self.playerSets]) {
            self.flag = SET_FLAG(self.flag, TSTennisScoreEndOfMatch);
            self.result.winner = tsContestantOpponent;
        }else{
            [self.result nextSet];
        }

        self.playerGames = 0;
        self.opponentGames = 0;
        self.flag = SET_FLAG(self.flag, TSTennisScoreStartOfSet);
        previous.flag = SET_FLAG(previous.flag, TSTennisScoreEndOfSet);
    }else{
        [self updateResults];
    }

    // Reset for next game
    self.playerPoints=0;
    self.opponentPoints=0;
    if (TEST_FLAG(self.flag, TSTennisScorePlayerServe)) {
        self.flag = CLEAR_FLAG(self.flag, TSTennisScorePlayerServe);
        self.flag = SET_FLAG(self.flag, TSTennisScoreOpponentServe);
    }else{
        self.flag = SET_FLAG(self.flag, TSTennisScorePlayerServe);
        self.flag = CLEAR_FLAG(self.flag, TSTennisScoreOpponentServe);
    }
    if ([self checkTieBreak:self.playerGames other:self.opponentGames]) {
        self.flag = SET_FLAG(self.flag, TSTennisScoreTieBreak);
        self.flag = CLEAR_FLAG(self.flag, TSTennisScoreRegularGame);
    }else{
        self.flag = CLEAR_FLAG(self.flag, TSTennisScoreTieBreak);
        self.flag = SET_FLAG(self.flag, TSTennisScoreRegularGame);
    }

}

-(NSString*)setsAsString{
    return [NSString stringWithFormat:@"%d-%d", (int)self.playerSets, (int)self.opponentSets];
}

-(NSString*)gamesAsString{
    return [NSString stringWithFormat:@"%d-%d", (int)self.playerGames, (int)self.opponentGames];
}

-(NSString*)endGamesAsString{
    if (TEST_FLAG(self.flag, TSTennisScoreEndOfGame)) {
        return [NSString stringWithFormat:@"%d-%d",
                (int) self.playerGames + ( TEST_FLAG(self.flag, TSTennisScorePlayerWon) ? 1 : 0),
                (int) self.opponentGames + ( TEST_FLAG(self.flag, TSTennisScoreOpponentWon) ? 1 : 0)];
    }else{
        return [self gamesAsString];
    }

}
-(NSArray*)playerOpponentFullScoreStringArray{
    NSArray * points = [self playerOpponentPointsStringArray];
    return @[
             @[ [@(self.playerSets) stringValue], [@(self.playerGames) stringValue], points[0],
                TEST_FLAG(self.flag, TSTennisScorePlayerServe)?@"*":@"" ],
             @[ [@(self.opponentSets) stringValue], [@(self.opponentGames) stringValue], points[1],
                TEST_FLAG(self.flag, TSTennisScorePlayerServe)?@"":@"*" ],
             ];
}

-(NSString*)playerScore{
    return [NSString stringWithFormat:@"%d %d %@%@", (int)self.playerSets, (int)self.playerGames,
            [self playerOpponentPointsStringArray][0],
            TEST_FLAG(self.flag, TSTennisScorePlayerServe) ? @"*" : @""];
}
-(NSString*)opponentScore{
    return [NSString stringWithFormat:@"%d %d %@%@", (int)self.opponentSets, (int)self.opponentGames,
            [self playerOpponentPointsStringArray][1],
            TEST_FLAG(self.flag, TSTennisScoreOpponentServe) ? @"*" : @""];
}

-(NSArray*)playerOpponentPointsStringArray{
    NSArray * rv = nil;
    NSArray * ps = @[ @"0", @"15", @"30", @"40"];
    NSString * playerStr = nil;
    NSString * opponentStr = nil;

    if (TEST_FLAG(self.flag, TSTennisScoreRegularGame)) {
        if (self.playerPoints < 4) {
            playerStr = ps[self.playerPoints];
        }
        if (self.opponentPoints < 4) {
            opponentStr = ps[self.opponentPoints];
        }
        if (self.playerPoints>3 || self.opponentPoints>3) {
            if (self.playerPoints > self.opponentPoints) {
                rv = @[ @"Ad", @"40" ];
            }else if (self.playerPoints < self.opponentPoints) {
                rv = @[ @"40", @"Ad" ];
            }else{
                rv = @[ @"40", @"40" ];
            }
        }else {
            rv = @[ playerStr, opponentStr];
        }
    }else{
        rv = @[ [NSString stringWithFormat:@"%d", (int)self.playerPoints],
                [NSString stringWithFormat:@"%d", (int)self.opponentPoints] ];
    }
    return rv;
}

-(NSString*)pointsAsString{
    NSArray * points = [self playerOpponentPointsStringArray];
    NSString * rv = nil;
    NSString * playerStr = points[0];
    NSString * opponentStr = points[1];

    if (TEST_FLAG(self.flag, TSTennisScorePlayerServe)) {
        rv = [NSString stringWithFormat:@"*%@-%@ ", playerStr, opponentStr];
    }else{
        rv = [NSString stringWithFormat:@" %@-%@*", playerStr, opponentStr];
    }
    return rv;
}

-(NSString*)description{
    return [NSString stringWithFormat:@"<TSTennisScore S:%@ G:%@ P:%@>", [self setsAsString], [self gamesAsString], [self pointsAsString]];
}

-(void)sameGame{
    self.flag = CLEAR_FLAG(self.flag, TSTennisScoreStartOfGame|TSTennisScoreStartOfSet);
}

-(TSTennisScore*)removePointPlayer{
    TSTennisScore * rv = [TSTennisScore scoreWithScore:self];
    if (rv) {
        if (rv.playerPoints > 0) {
            rv.playerPoints -= 1;
            self.flag = CLEAR_FLAG(self.flag, TSTennisScoreEndOfGame|TSTennisScoreEndOfMatch|TSTennisScoreEndOfSet);
        }
    }
    return rv;
}
-(TSTennisScore*)removePointOpponent{
    TSTennisScore * rv = [TSTennisScore scoreWithScore:self];
    if (rv) {
        if (rv.opponentPoints > 0) {
            rv.opponentPoints -= 1;
            self.flag = CLEAR_FLAG(self.flag, TSTennisScoreEndOfGame|TSTennisScoreEndOfMatch|TSTennisScoreEndOfSet);
        }
    }
    return rv;
}

-(TSTennisScore*)addGamePlayer:(TSScore)n{
    TSTennisScore * rv = [TSTennisScore scoreWithScore:self];
    if (rv) {
        rv.playerGames += n;
    }
    return rv;
}
-(TSTennisScore*)addGameOpponent:(TSScore)n{
    TSTennisScore * rv = [TSTennisScore scoreWithScore:self];
    if (rv) {
            rv.opponentGames += n;
    }
    return rv;
}



-(TSTennisScore*)adjustScore:(tsContestant)contestant sets:(TSScore)sets games:(TSScore)games points:(TSScore)points{
    TSTennisScore * rv = self;

    if (points > 0) {
        rv = (contestant == tsContestantOpponent) ? [rv opponentWonPoint] : [rv playerWonPoint];
    }else if( points < 0){
        rv = (contestant == tsContestantOpponent) ? [rv removePointOpponent] : [rv removePointPlayer];
    }

    rv = (contestant == tsContestantOpponent) ? [rv addGameOpponent:games] : [rv addGamePlayer:games];

    return rv;


}

-(TSScore)setNumber{
    return self.opponentSets+self.playerSets+1;
}
-(TSScore)gameNumber{
    return self.countOfGames;
}
-(TSScore)pointNumber{
    return self.countOfPoints;
}


-(TSTennisScore*)playerWonPoint{

    TSTennisScore * rv = [TSTennisScore scoreWithScore:self];
    if (rv) {
        rv.playerPoints += 1;
        rv.countOfPoints = self.countOfPoints+1;

        if ([rv checkPointsWonGame:rv.playerPoints other:rv.opponentPoints]) {
            self.flag = SET_FLAG(self.flag, TSTennisScorePlayerWon|TSTennisScoreEndOfGame);
            [rv nextGame:self];
        }else{
            [rv sameGame];
        }
    }
    return rv;
}
-(TSTennisScore*)opponentWonPoint{
    TSTennisScore * rv = [TSTennisScore scoreWithScore:self];
    if (rv) {
        rv.opponentPoints += 1;
        rv.countOfPoints = self.countOfPoints+1;

        if ([rv checkPointsWonGame:rv.opponentPoints other:rv.playerPoints]) {
            self.flag = SET_FLAG(self.flag, TSTennisScoreOpponentWon|TSTennisScoreEndOfGame);
            [rv nextGame:self];
        }else{
            [rv sameGame];
        }
    }
    return rv;
}

-(TSTennisScore*)serverWonPoint{
    if (TEST_FLAG(self.flag, TSTennisScorePlayerServe)) {
        return [self playerWonPoint];
    }else{
        return [self opponentWonPoint];
    }
}
-(TSTennisScore*)receiverWonPoint{
    if (TEST_FLAG(self.flag, TSTennisScorePlayerServe)) {
        return [self opponentWonPoint];
    }else{
        return [self playerWonPoint];
    }
}

-(BOOL)testFlag:(TSTennisScoreFlag)flag{
    return TEST_FLAG(self.flag, flag);
}

-(tsDifferential)playerPointDifferential{
    if (self.playerPoints == self.opponentPoints) {
        return tsDifferentialEven;
    }else if (self.playerPoints > self.opponentPoints){
        return tsDifferentialAhead;
    }else{
        return tsDifferentialBehind;
    }
}
-(tsScoreCriticality)criticality{
    tsScoreCriticality rv = tsScoreEarlyPoint;
    if ([self isGamePointForContestant:tsContestantOpponent]) {
        rv = tsScoreOpponentGamePoint;
    }else if ([self isGamePointForContestant:tsContestantPlayer]){
        rv = tsScorePlayerGamePoint;
    }else if ([self isDeucePoint:self.playerPoints other:self.opponentPoints]){
        rv = tsScoreDeucePoint;
    }
    return rv;
}
@end
