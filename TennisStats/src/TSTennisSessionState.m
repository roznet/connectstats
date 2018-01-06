//  MIT Licence
//
//  Created on 12/10/2014.
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

#import "TSTennisSessionState.h"
#import "TSTennisRally.h"
#import "TSTennisScore.h"
#import "TSTennisScoreRule.h"
#import "TSTennisSession.h"
#import "TSTennisFields.h"

@interface TSTennisSessionState ()
@property (nonatomic,retain) TSTennisShot * currentShot;
@property (nonatomic,retain) TSTennisRally * currentRally;
@property (nonatomic,retain) NSMutableArray * rallies;

@property (nonatomic,assign) tsCourtSide playerSide;
@property (nonatomic,assign) tsCourtSide opponentSide;
@property (nonatomic,retain) TSTennisScoreRule * rule;

@property (nonatomic,retain) TSDataTable * cachedRallyTable;
@property (nonatomic,retain) TSDataTable * cachedShotTable;

@property (nonatomic,weak) TSTennisSession * session;
@end

@implementation TSTennisSessionState



+(TSTennisSessionState*)startSessionState:(TSTennisScoreRule*)rule session:(TSTennisSession*)session andDb:(FMDatabase*)db{
    TSTennisSessionState * rv = [[TSTennisSessionState alloc] init];
    if (rv) {
        rv.playerSide = tsCourtBack;
        rv.opponentSide = tsCourtFront;
        rv.rallies = [NSMutableArray arrayWithCapacity:100];
        rv.rule = rule;
        rv.session = session;
        [rv saveToDb:db];
    }
    return rv;
}
+(TSTennisSessionState*)loadSessionStateFromDb:(FMDatabase*)db session:(TSTennisSession *)session{
    TSTennisSessionState * rv = [[TSTennisSessionState alloc] init];
    if (rv) {
        rv.playerSide = tsCourtBack;
        rv.opponentSide = tsCourtFront;
        rv.rallies = [NSMutableArray arrayWithCapacity:100];
        rv.session = session;
        [rv loadFromDb:db];
    }
    return rv;

}

-(void)resetState{
    self.playerSide = tsCourtBack;
    self.opponentSide = tsCourtFront;
    [self.rallies removeAllObjects];

}

-(void)changeScoreRule:(TSTennisScoreRule*)newRule{
    self.rule = newRule;
}

/**
 @discussion Will save the rule into the database.
             the structure will be created if needed
 @param db database
 */
-(void)saveToDb:(FMDatabase*)db{
    [TSTennisScoreRule ensureDbStructure:db];
    [self.rule saveToDb:db];
}

/**
 @discussion Will load from db, the rule
 @param db database
 */
-(void)loadFromDb:(FMDatabase*)db{
    TSTennisScoreRule * rule = [TSTennisScoreRule ruleFromDb:db];
    if (!rule) {
        rule = [TSTennisScoreRule defaultRule];
    }
    self.rule = rule;
}

#pragma mark - Rally and Shots

-(TSTennisRally*)lastRally{
    return [self.rallies lastObject];
}

-(TSTennisShot*)lastShot{
    return [[self.rallies lastObject] lastShot];
}
/**
 * @discussion Start new rally. Will end previous one if one already started
            The new rally with start with the next score.
 */
-(void)newRally{
    if (self.currentRally) {
        [self.currentRally endRally];
    }
    TSTennisScore * score = [[self lastRally] nextScore];

    self.currentRally = [[TSTennisRally alloc] initWithScore:score session:self.session andPlayerCourtSide:self.playerSide];
    [self.rallies addObject:self.currentRally];
}

#pragma mark - Event Processing

-(void)processShot:(TSTennisEvent*)event{
    if (event.type == tsEventShot) {
        self.currentShot = [TSTennisShot tennisShotWithEvent:event];
        if (self.currentRally == nil || ![self.currentRally isSameRally:self.currentShot] ) {
            [self newRally];
        }
        if (self.currentRally.score == nil && self.currentShot.shotType == tsShotServe) {
            self.currentRally.score = [TSTennisScore scorePlayerStartsServe:(self.playerSide==self.currentShot.shotCourtSide) withRule:self.rule];
        }
        [self.currentRally addShot:self.currentShot];
    }
}

-(void)processBall:(TSTennisEvent*)event{
    if (event.type == tsEventBall) {
        if ([self.currentShot isSameShot:event]) {
            [self.currentShot updateWithEvent:event];
            if ([self.currentRally lastShotIsEnd]) {
                /*if ([self.currentRally winningContestantFromLastShot] == tsContestantPlayer) {
                    [self.currentRally playerWon];
                }else{
                    [self.currentRally opponentWon];
                }*/
            }
        }
    }
}

-(void)processScoreUpdate:(TSTennisEvent*)event{
    TSTennisScore * score = self.currentScore;
    tsContestant contestant = tsContestantUnknown;
    if (event.type == tsEventOpponentUpdateScore) {
        contestant = tsContestantOpponent;
    }else if(event.type == tsEventPlayerUpdateScore){
        contestant = tsContestantPlayer;
    }
    if (contestant != tsContestantUnknown) {
        score = [score adjustScore:contestant sets:event.location.x games:event.location.y points:event.delta.x];

        if (self.currentRally == nil) {
            self.currentRally = [[TSTennisRally alloc] initWithScore:score session:self.session andPlayerCourtSide:self.playerSide];
            [self.rallies addObject:self.currentRally];
        }else{
            self.currentRally.score = score;
        }
    }
}

-(void)processEndRally:(TSTennisEvent*)event{
    if (self.currentRally) {
        [self.currentRally endRally];
        self.currentRally = nil;
    }

    TSTennisRally * last = [self lastRally];
    if (event.type == tsEventBackPlayerWon||event.type == tsEventFrontPlayerLost) {
        [last backCourtSideWon];
    }else if (event.type == tsEventBackPlayerLost||event.type == tsEventFrontPlayerWon){
        [last frontCourtSideWon];
    }else if (event.type == tsEventPlayerSwithSide) {
        [last switchSide];
    }

}

-(void)processRallyResult:(TSTennisEvent*)event{
    tsRallyResult res = (tsRallyResult)event.location.x;
    TSTennisRally * last = [self lastRally];
    [last recordResult:res];
}

-(void)processTagEvent:(TSTennisEvent *)event{

}
-(void)processEvent:(TSTennisEvent*)event{

    switch (event.type) {
        case tsEventPlayerSwithSide:
            [self processEndRally:event];
            if (self.playerSide == tsCourtBack) {
                self.playerSide = tsCourtFront;
                self.opponentSide = tsCourtBack;
            }else{
                self.playerSide = tsCourtBack;
                self.opponentSide = tsCourtFront;
            }
            break;
        case tsEventShot:
            [self processShot:event];
            break;
        case tsEventBall:
            [self processBall:event];
            break;
        case tsEventBackPlayerLost:
        case tsEventBackPlayerWon:
        case tsEventFrontPlayerLost:
        case tsEventFrontPlayerWon:
            [self processEndRally:event];
            break;
        case tsEventEnd:
        case tsEventNone:
        case tsEventRallyResult:
            [self processRallyResult:event];
            break;
        case tsEventOpponentUpdateScore:
        case tsEventPlayerUpdateScore:
            [self processScoreUpdate:event];
            break;
        case tsEventTag:
            [self processTagEvent:event];
            break;
    }
}

#pragma mark - Current Information

-(NSArray*)ralliesWithScores:(TSTennisScoreFlag)flag{

    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:self.rallies.count/4];
    for (TSTennisRally * rally in self.rallies) {
        if ([rally.score testFlag:flag]) {
            [rv addObject:rally];
        }
    }
    return rv;
}

-(TSTennisScore*)currentScore{
    TSTennisRally * last = [self lastRally];
    if (last==nil) {
        return [TSTennisScore zeroScore];
    }else if (last.winningContestant == tsContestantPlayer) {
        return [last.score playerWonPoint];
    }else if(last.winningContestant == tsContestantOpponent){
        return [last.score opponentWonPoint];
    }else{
        return last.score;
    }
}

-(TSTennisResult*)currentResult{
    TSTennisRally * last = [self lastRally];
    if (last == nil) {
        return [TSTennisResult emptyResult];
    }else{
        return [[last score] result];
    }
}

-(NSString*)playerCurrentAnalysis{
    if (self.currentRally == nil) {
        TSTennisRally * last = [self lastRally];
        if (last.winningContestant == tsContestantPlayer) {
            return [last playerRallyDescription];
        }
    }else{

        if (self.currentShot.shotCourtSide == self.playerSide) {
            if(self.currentShot.shotType == tsShotServe){
                NSUInteger servesOut = [self.currentRally numberOfServesOut];
                if (servesOut > 0) {
                    return NSLocalizedString(@"2nd Serve", @"Analysis");
                }else{
                    return NSLocalizedString(@"1st Serve", @"Analysis");
                }
            }else{
                return [TSTennisFields analysisDescription:self.currentShot.shotAnalysis];
            }
        }
    }
    return nil;
}

-(NSString*)opponentCurrentAnalysis{
    if (self.currentRally == nil) {
        TSTennisRally * last = [self lastRally];
        if (last.winningContestant == tsContestantOpponent) {
            return [last opponentRallyDescription];
        }
    }else{

        if (self.currentShot.shotCourtSide == self.opponentSide) {
            if(self.currentShot.shotType == tsShotServe){
                NSUInteger servesOut = [self.currentRally numberOfServesOut];
                if (servesOut > 0) {
                    return NSLocalizedString(@"2nd Serve", @"Analysis");
                }else{
                    return NSLocalizedString(@"1st Serve", @"Analysis");
                }
            }else{
                return [TSTennisFields analysisDescription:self.currentShot.shotAnalysis];
            }
        }
    }
    return nil;
}

-(NSString*)playerCurrentShotDescription{
    if (self.currentRally == nil) {
        TSTennisRally * last = [self lastRally];
        if (last.winningContestant == tsContestantPlayer) {
            return @"Won";
        }
    }else{

        if (self.currentShot.shotCourtSide == self.playerSide) {
            return [self.currentShot shotDescription];
        }
    }
    return nil;
}
-(NSString*)opponentCurrentShotDescription{
    if (self.currentRally == nil) {
        TSTennisRally * last = [self lastRally];
        if (last.winningContestant == tsContestantOpponent) {
            return @"Won";
        }
    }else{

        if (self.currentShot.shotCourtSide == self.opponentSide) {
            return [self.currentShot shotDescription];
        }
    }
    return nil;
}

#pragma mark - Table and Plots Extract

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len{
    return [_rallies countByEnumeratingWithState:state objects:buffer count:len];
}

-(void)clearTableCache{
    self.cachedRallyTable = nil;
    self.cachedShotTable = nil;
}

-(TSDataTable*)rallyTable{
    TSDataTable * table = [TSDataTable tableWithColumnNames:[TSTennisRally dataColumns]];
    NSUInteger idx = 0;
    for (TSTennisRally * rally in self) {
        TSDataRow * row = rally.dataRow;
        row[kfRallyNumber] = @(idx);
        idx++;
        [table addRow:row];
    }
    return table;
}

-(TSDataTable*)shotTable{
    TSDataTable * table = [TSDataTable tableWithColumnNames:[TSTennisShot dataColumns]];
    NSUInteger rallyIdx = 0;
    for (TSTennisRally * rally in self) {
        TSDataRow * rallyRow = [rally dataRow];
        rallyRow[kfRallyNumber] = @(rallyIdx);
        rallyIdx++;
        NSUInteger shotNumber = 0;
        for (TSTennisShot * shot in rally) {
            TSDataRow * shotRow = shot.dataRow;
            NSString * shotPlayerName =shot.shotCourtSide == self.playerSide ? self.session.displayPlayerName : self.session.displayOpponentName;

            NSDictionary * rowDict = @{
                                       kfShotPlayer:shotPlayerName,
                                       kfShotNumber:@(shotNumber),
                                       kfShotIsRallyEnd:@(shot == rally.lastShot)
                                       };
            shotRow = [shotRow mergedWithRow:[TSDataRow rowWithObj:rowDict andColumns:@[kfShotPlayer,kfShotNumber,kfShotIsRallyEnd]]];
            shotRow = [shotRow mergedWithRow:rallyRow];
            [table addRow:shotRow];
            shotNumber++;
        }
    }
    return table;
}

-(GCStatsDataSerie*)pointsDataSerie{
    NSMutableArray * points = [NSMutableArray array];

    double running = 0.;
    if (self.rallies.count > 0) {
        NSDate * start = [self.rallies[0] startTime];
        NSTimeInterval elapsed = 0.;
        for (TSTennisRally * rally in self) {

            if (rally.endTime != nil) {
                elapsed = [rally.endTime timeIntervalSinceDate:start];
            }
            if( rally.winningContestant == tsContestantPlayer){
                running += 1.;
                [points addObject:[GCStatsDataPoint dataPointWithX:elapsed andY:running]];
            }else if (rally.winningContestant == tsContestantOpponent){
                running -= 1.;
                [points addObject:[GCStatsDataPoint dataPointWithX:elapsed andY:running]];
            }else{
                // Should be the last.
                if (rally != self.currentRally) {
                    NSLog(@"hum");
                }
            }
        }
    }

    return [GCStatsDataSerie dataSerieWithPoints:points];
}

-(GCStatsDataSerie*)gamesDataSerie{
    NSMutableArray * points = [NSMutableArray array];

    double running = 0.;
    if (self.rallies.count > 0) {
        NSDate * start = [self.rallies[0] startTime];
        NSTimeInterval elapsed = 0.;
        for (TSTennisRally * rally in self) {

            if( rally.winningContestant == tsContestantPlayer){
                running += 1.;
                if ([rally.score testFlag:TSTennisScoreEndOfGame]) {
                    [points addObject:[GCStatsDataPoint dataPointWithX:elapsed andY:running]];
                    elapsed = [rally.endTime timeIntervalSinceDate:start];
                }
            }else if (rally.winningContestant == tsContestantOpponent){
                running -= 1.;
                if ([rally.score testFlag:TSTennisScoreEndOfGame]) {
                    [points addObject:[GCStatsDataPoint dataPointWithX:elapsed andY:running]];
                    elapsed = [rally.endTime timeIntervalSinceDate:start];
                }
            }else{
                // SHould be the last.
                if (rally != self.currentRally) {
                    NSLog(@"hum");
                }


            }
        }
    }

    return [GCStatsDataSerie dataSerieWithPoints:points];
}



@end
