//  MIT Licence
//
//  Created on 18/10/2014.
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

#import "TSTennisRally.h"
#import "TSTennisFields.h"
#import "TSAppGlobal.h"
#import "TSTennisOrganizer.h"

@interface TSTennisRally ()
@property (nonatomic,retain) NSMutableArray * shots;
@property (nonatomic,assign) BOOL beyondServe;
@property (nonatomic,assign) NSUInteger nShots; // not count because of first serve out or net serve
@property (nonatomic,assign) tsContestant winningContestant;
@property (nonatomic,assign) tsRallyResult result;

@property (nonatomic,weak) TSTennisSession * session;

@end

@implementation TSTennisRally
-(TSTennisRally*)initWithScore:(TSTennisScore*)score session:(TSTennisSession*)session andPlayerCourtSide:(tsCourtSide)playerCourtSide;{
    self = [super init];
    if (self) {
        self.shots = [NSMutableArray arrayWithCapacity:4];
        self.score = score;
        self.playerCourtSide = playerCourtSide;
        self.result = tsResultNone;
        self.session = session;
    }
    return self;

}
-(TSTennisRally*)init{
    self = [super init];
    if (self) {
        self.shots = [NSMutableArray arrayWithCapacity:4];
    }
    return self;
}

-(NSString*)playerRallyDescription{
    NSMutableArray * rv = [NSMutableArray array];
    if (self.winningContestant == tsContestantPlayer) {
        [rv addObject:NSLocalizedString( @"Won", @"Rally Description" )];
        if (self.result != tsResultNone) {
            [rv addObject:[TSTennisFields resultDescription:self.result]];
        }
    }
    return [rv componentsJoinedByString:@" "];
}

-(NSString*)opponentRallyDescription{
    NSMutableArray * rv = [NSMutableArray array];
    if (self.winningContestant == tsContestantPlayer) {
        [rv addObject:NSLocalizedString( @"Won", @"Rally Description" )];
        if (self.result != tsResultNone) {
            [rv addObject:[TSTennisFields resultDescription:self.result]];
        }
    }
    return [rv componentsJoinedByString:@" "];
}


-(NSString*)description{
    NSString * rv = [NSString stringWithFormat:@"<TSTennisRally %d shots, %@ won %@>\n%@",
                     (int)self.nShots,
                     self.score,
                     [TSTennisFields contestantDescription:self.winningContestant],
                     self.shots];
    return rv;
}

-(void)recordResult:(tsRallyResult)result{
    self.result = result;
}
-(TSTennisShot*)lastShot{
    return [self.shots lastObject];
}

-(TSTennisShot*)lastPlayerShot{
    TSTennisShot * rv = nil;
    NSUInteger n = self.shots.count;
    for (NSUInteger i=1;i<n;i++){
        rv = self.shots[n-i];
        if (rv.shotCourtSide == self.playerCourtSide) {
            break;
        }
    }
    if (rv.shotCourtSide != self.playerCourtSide) {
        rv = nil;
    }
    return rv;
}

-(NSDate*)startTime{
    NSDate * rv = nil;
    if (self.shots.count>0) {
        return [self.shots[0] time];
    }
    return rv;
}
-(NSDate*)endTime{
    NSDate * rv = nil;
    if (self.shots.count>0) {
        return [[self.shots lastObject] time];
    }
    return rv;
}

/**
 * @discussion Currently always returns true. For extension if we find way to detect properly.
 * @return YES if in the same rally
 */
-(BOOL)isSameRally:(TSTennisShot*)shot{
    // only reason to be in new rally is to have started new one
    return true;
/*
    BOOL rv = true;
    if (shot.shotType == tsShotServe) {
        // Try to see if serve is on same side?
        if (self.beyondServe ||  (self.lastShot &&  ![[self lastShot] isServeSameSide:shot])) {
            rv = false;
        }
    }
    return rv;
 */
}

#pragma mark - Record

-(void)addShot:(TSTennisShot*)shot{
    [self.shots addObject:shot];
    if (shot.shotType != tsShotServe) {
        self.beyondServe = true;
        self.nShots++;
    }
    self.winningContestant = tsContestantUnknown;
}
-(void)playerWon{
    self.winningContestant = tsContestantPlayer;
}

-(void)opponentWon{
    self.winningContestant = tsContestantOpponent;
}

-(void)frontCourtSideWon{
    self.winningContestant = self.playerCourtSide == tsCourtFront ? tsContestantPlayer : tsContestantOpponent;
}
-(void)backCourtSideWon{
    self.winningContestant = self.playerCourtSide == tsCourtBack ? tsContestantPlayer : tsContestantOpponent;
}
-(void)switchSide{
    self.playerCourtSide = self.playerCourtSide == tsCourtBack ? tsCourtFront : tsCourtBack;
    //self.winningCourtSide = self.winningCourtSide == tsCourtBack ? tsCourtFront : tsCourtBack;
}
-(tsCourtSide)serverCourtSide{
    tsCourtSide rv = tsCourtUnknownSide;
    for (TSTennisShot * shot in self.shots) {
        if (shot.shotType == tsShotServe) {
            rv = shot.shotCourtSide;
            break;
        }
    }
    return rv;
}

-(tsContestant)serverContestant{
    return self.serverCourtSide == self.playerCourtSide ? tsContestantPlayer : tsContestantOpponent;
}

-(void)endRally{
    if (self.winningContestant == tsContestantUnknown) {
        self.winningContestant = [self winningContestantFromLastShot];
    }
}

-(TSTennisScore*)nextScore{
    if (self.winningContestant == tsContestantPlayer) {
        return [self.score playerWonPoint];
    }else{
        return [self.score opponentWonPoint];
    }
}

-(TSTennisScore*)nextScoreServerWon{
    return [self.score serverWonPoint];
}

-(TSTennisScore*)nextScoreReceiverWon{
    return [self.score receiverWonPoint];
}

#pragma mark - Analyse

-(tsCourtSide)winningCourtSideFromLastShot{
    tsCourtSide rv = tsCourtUnknownSide;
    TSTennisShot * last = [self lastShot];
    if (last.ballIsIn) {
        rv = last.shotCourtSide == tsCourtFront ? tsCourtFront : tsCourtBack;
    }else{
        rv = last.shotCourtSide == tsCourtFront ? tsCourtBack : tsCourtFront;
    }
    return rv;
}

-(tsContestant)winningContestantFromLastShot{
    return self.winningCourtSideFromLastShot == self.playerCourtSide ? tsContestantPlayer : tsContestantOpponent;
}

-(NSUInteger)numberOfServesIn{
    NSUInteger rv = 0;

    for (TSTennisShot * shot in self.shots) {
        if (shot.shotType == tsShotServe){
            if (shot.ballLocationKnown && shot.ballIsIn) {
                rv++;
            }
        }
    }
    return rv;
}

-(NSUInteger)numberOfServesOut{
    NSUInteger rv = 0;

    for (TSTennisShot * shot in self.shots) {
        if (shot.shotType == tsShotServe){
            if (shot.ballLocationKnown && !shot.ballIsIn) {
                rv++;
            }
        }
    }
    return rv;
}

-(tsCourtSide)opponentCourtSide{
    return self.playerCourtSide == tsCourtBack ? tsCourtFront : tsCourtBack;
}

-(tsRallyResult)guessResultFromShots{
    tsRallyResult rv = tsResultNone;

    TSTennisShot * lastShot = [self lastShot];

    NSUInteger nServesOut = self.numberOfServesOut;
    //NSUInteger nServesIn  = self.numberOfServesIn;

    tsCourtSide winningSide = self.winningContestant == tsContestantPlayer ? self.playerCourtSide : self.opponentCourtSide;

    if (winningSide == tsCourtUnknownSide) {
        winningSide = self.winningCourtSideFromLastShot;
    }

    if (lastShot.shotType == tsShotServe) {
        if (lastShot.shotCourtSide == winningSide) {
            rv = tsResultAce;
        }else if( nServesOut > 1){
            rv = tsResultDoubleFault;
        }
    }else{
        if (lastShot.shotCourtSide == winningSide) {
            rv = tsResultWinner;
        }else{
            rv = tsResultUnforcedError;
        }
    }

    return rv;
}
-(BOOL)lastShotIsEnd{
    BOOL rv = false;
    TSTennisShot * last = [self lastShot];
    if ( last.ballArea != tsBallNoLocation && !last.ballIsIn) {
        if (last.shotType == tsShotServe) {
            if ([self numberOfServesOut]>1) {
                rv = true;
            }
        }else{
            rv = true;
        }
    }
    return rv;
}

-(tsRallyLength)rallyLength{

    if (self.nShots < 2) {
        return tsRallyShort;
    }else if (self.nShots > 5){
        return tsRallyLong;
    }else{
        return tsRallyMedium;
    }
}

-(NSUInteger)count{
    return self.shots.count;
}
-(TSTennisShot*)objectAtIndexedSubscript:(NSUInteger)idx{
    return self.shots[idx];
}

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len{
    return [_shots countByEnumeratingWithState:state objects:buffer count:len];
}
+(NSArray*)dataColumns{
    return @[ kfWinner, kfNumberOfShots, kfScoreDifferential, kfLastShotType, kfLastShotArea, kfRallyLength, kfRallyResult,kfSetNumber];
}
-(TSDataRow*)dataRow{
    TSTennisShot * lastPlayerShot = [self lastPlayerShot];
    NSString * missing = NSLocalizedString(@"None", @"Missing Last Shot");
    NSString * vkfWinner = self.winningContestant == tsContestantPlayer ? self.session.displayPlayerName : self.session.displayOpponentName;
    NSNumber * vkfNumberOfShots = @( [self nShots] );
    NSString * vkfScoreDifferential = [TSTennisFields scoreDifferentialDescription:[self.score playerPointDifferential]];
    NSString * vkfLastShotType= lastPlayerShot ? [TSTennisFields shotTypeDescription:[lastPlayerShot shotType]] : missing;
    NSString * vkfLastShotArea= lastPlayerShot ? [TSTennisFields ballCourtAreaDescription:[lastPlayerShot ballArea]] : missing;

    NSString * vkfRallyResult= [TSTennisFields resultDescription:[self result]];
    NSString * vkfRallyLength = [TSTennisFields rallyLengthDescription:[self rallyLength]];
    NSString * vkfScoreCriticality= [TSTennisFields scoreCriticalityDescription:[self.score criticality]];

    NSString * vkfSetNumber = [NSString stringWithFormat:@"Set %d", (int)[self.score setNumber]];

    NSDictionary * dict = @{
                            kfWinner :              vkfWinner,
                            kfNumberOfShots :       vkfNumberOfShots,
                            kfScoreDifferential :   vkfScoreDifferential,
                            kfLastShotType:         vkfLastShotType,
                            kfLastShotArea:         vkfLastShotArea,

                            kfRallyResult :         vkfRallyResult,
                            kfRallyLength :         vkfRallyLength,
                            kfScoreCriticality:     vkfScoreCriticality,
                            kfSetNumber:            vkfSetNumber,
                            kfRallyTime:            self.startTime ? self.startTime : [NSNull null]

                            };
    return [TSDataRow rowWithObj:dict andColumns:dict.allKeys];
}



@end
