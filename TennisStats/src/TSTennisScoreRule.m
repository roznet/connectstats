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

#import "TSTennisScoreRule.h"
#include "RZUtils/RZUtils.h"

static NSString * kTieBreakNumberOfPoints = @"tieBreakNumberOfPoints";
static NSString * kGamesPerSet = @"gamesPerSet";
static NSString * ksetsPerMatch =  @"setsPerMatch";

static NSUInteger _pack_mask = 0xF;
static NSUInteger _pack_maskbits = 4;

NSDictionary*ruleMap(){
    static NSDictionary * map = nil;
    if (map == nil) {
        NSMutableDictionary * mmap = [NSMutableDictionary dictionary];
        NSArray * defs = @[ @[ @(3), @(6), @(7), @(10), @(true)],
                            @[ @(3), @(4), @(7), @(10), @(true)],
                            @[ @(3), @(6), @(7), @(10), @(false)],
                            @[ @(5), @(6), @(7), @(10), @(false)],
                            ];

        for (NSArray * def in defs) {
            TSTennisScoreRule * one = [[TSTennisScoreRule alloc] init];
            one.setsPerMatch = [def[0] integerValue];
            one.gamesPerSet = [def[1] integerValue];
            one.tieBreakNumberOfPoints = [def[2] integerValue];
            one.decidingSetTieBreakNumberOfPoints = [def[3] integerValue];
            one.decidingSetIsTieBreak = [def[4] boolValue];
            one.decidingSetHasNoTieBreak = one.setsPerMatch == 5 ? true : false;
            if (mmap[one.asString]) {
                RZLog( RZLogWarning, @"Duplicate Rule Name: %@", one.asString);
            }
            mmap[one.asString] = one;
        }

        map = [NSDictionary dictionaryWithDictionary:mmap];
    }
    return map;
}

@implementation TSTennisScoreRule

+(TSTennisScoreRule*)ruleForName:(NSString *)name{
    return ruleMap()[name];

}

+(NSArray*)availableRuleNames{
    return [ruleMap() allKeys];
}

-(BOOL)isEqualToRule:(TSTennisScoreRule*)other{
    return (self.decidingSetHasNoTieBreak == other.decidingSetHasNoTieBreak &&
            self.decidingSetIsTieBreak == other.decidingSetIsTieBreak &&
            self.gamesPerSet == other.gamesPerSet &&
            self.setsPerMatch == other.setsPerMatch &&
            self.gameEndWithSuddenDeath == other.gameEndWithSuddenDeath &&
            self.decidingSetTieBreakNumberOfPoints == other.decidingSetTieBreakNumberOfPoints
            );
}

-(TSScoreRulePacked)pack{
    TSScoreRulePacked rv = 0;
    rv = (self.decidingSetHasNoTieBreak ) | (self.decidingSetIsTieBreak << 1) | ( self.gameEndWithSuddenDeath << 2);
    rv <<= _pack_maskbits;
    rv |= self.tieBreakNumberOfPoints & _pack_mask;
    rv <<= _pack_maskbits;
    rv |= self.gamesPerSet & _pack_mask;
    rv <<= _pack_maskbits;
    rv |= self.setsPerMatch & _pack_mask;
    rv <<= _pack_maskbits;
    rv |= self.decidingSetTieBreakNumberOfPoints & _pack_mask;

    return rv;
}
-(TSTennisScoreRule*)unpack:(TSScoreRulePacked)val{
    TSScoreRulePacked unpack = val;
    self.decidingSetTieBreakNumberOfPoints = unpack & _pack_mask;
    unpack = unpack >> _pack_maskbits;
    self.setsPerMatch = unpack & _pack_mask;
    unpack = unpack >> _pack_maskbits;
    self.gamesPerSet = unpack & _pack_mask;
    unpack = unpack >> _pack_maskbits;
    self.tieBreakNumberOfPoints = unpack & _pack_mask;
    unpack = unpack >> _pack_maskbits;
    self.decidingSetHasNoTieBreak = (unpack & 1) == 1;
    self.decidingSetIsTieBreak = (unpack & 0b10) == 0b10;
    self.gameEndWithSuddenDeath = (unpack & 0b100) == 0b100;
    return self;
}


+(TSTennisScoreRule*)defaultRule{
    TSTennisScoreRule * rv = [[TSTennisScoreRule alloc] init];
    if (rv) {
        rv.tieBreakNumberOfPoints = 7;
        rv.gamesPerSet = 6;
        rv.setsPerMatch = 3;
        rv.decidingSetIsTieBreak = true;
        rv.decidingSetTieBreakNumberOfPoints = 10;
    }
    return rv;
}
+(TSTennisScoreRule*)shortSetRule{
    TSTennisScoreRule * rv = [[TSTennisScoreRule alloc] init];
    if (rv) {
        rv.tieBreakNumberOfPoints = 7;
        rv.gamesPerSet = 4;
        rv.setsPerMatch = 3;
        rv.decidingSetIsTieBreak = true;
    }
    return rv;

}

-(NSString*)asString{
    NSMutableString * rv = [NSMutableString stringWithFormat:@"Best of %d", (int)self.setsPerMatch];
    if (self.gamesPerSet<6) {
        [rv appendFormat:@" Short Sets"];
    }else{
        [rv appendFormat:@" Sets"];
    }
    if (self.decidingSetIsTieBreak) {
        [rv appendFormat:@" Super TieBreak"];
    }
    return rv;

}

+(TSTennisScoreRule*)ruleFromDb:(FMDatabase*)db{
    TSTennisScoreRule * rule = [TSTennisScoreRule defaultRule];
    if (rule && [db tableExists:@"tennis_score_rule"]) {
        FMResultSet * res = [db executeQuery:@"SELECT * FROM tennis_score_rule"];
        while ([res next]) {
            NSString * key = [res stringForColumn:@"field"];
            if ([key isEqualToString:ksetsPerMatch]) {
                rule.setsPerMatch = [res intForColumn:@"value"];
                if (rule.setsPerMatch == 2) {// old style
                    rule.setsPerMatch = 3;
                }
            }else if ([key isEqualToString:kTieBreakNumberOfPoints]){
                rule.tieBreakNumberOfPoints = [res intForColumn:@"value"];
            }else if ([key isEqualToString:kGamesPerSet]){
                rule.gamesPerSet = [res intForColumn:@"value"];
            }
        }
    }
    return rule;
}

+(void)ensureDbStructure:(FMDatabase*)db{
    if (![db tableExists:@"tennis_score_rule"]) {
        [db executeUpdate:@"CREATE TABLE tennis_score_rule (field TEXT UNIQUE, value REAL, desc TEXT)"];
    }
}

-(void)saveToDb:(FMDatabase*)db{
    [TSTennisScoreRule ensureDbStructure:db];
    [db executeUpdate:@"INSERT OR REPLACE INTO tennis_score_rule (field,value) VALUES (?,?)", kTieBreakNumberOfPoints, @(self.tieBreakNumberOfPoints)];
    [db executeUpdate:@"INSERT OR REPLACE INTO tennis_score_rule (field,value) VALUES (?,?)", kGamesPerSet, @(self.gamesPerSet)];
    [db executeUpdate:@"INSERT OR REPLACE INTO tennis_score_rule (field,value) VALUES (?,?)", ksetsPerMatch, @(self.setsPerMatch)];
}

#pragma mark - Result

-(tsContestant)setWinnerFromResult:(TSTennisResultSet*)set set:(NSUInteger)setnumber{
    tsContestant rv = tsContestantUnknown;

    if ([self checkGamesWonSet:set.playerGames other:set.opponentGames set:setnumber]) {
        rv = tsContestantPlayer;
    }else if ([self checkGamesWonSet:set.opponentGames other:set.playerGames set:setnumber]){
        rv = tsContestantOpponent;
    }

    return rv;
}

-(tsContestant)winnerFromResult:(TSTennisResult*)result{
    tsContestant rv = tsContestantUnknown;

    NSUInteger sets[ 3 ] = { 0, 0, 0 };
    NSUInteger setnumber = 0;
    for (TSTennisResultSet * set in result.sets) {
        sets[ [self setWinnerFromResult:set set:setnumber++]] ++;
    }
    if ([self checkSetsWonMatch:sets[tsContestantPlayer] other:sets[tsContestantOpponent]]) {
        rv = tsContestantPlayer;
    }else if ([self checkSetsWonMatch:sets[tsContestantPlayer] other:sets[tsContestantOpponent]]){
        rv = tsContestantOpponent;
    }

    return rv;
}

-(BOOL)validateResult:(TSTennisResult*)result{
    BOOL rv = true;

    return rv;
}

#pragma mark - Score Logic


-(BOOL)checkIsLastSet:(NSUInteger)setnumber{
    return setnumber == (self.setsPerMatch-1);
}

-(BOOL)checkGamesWonSet:(TSScore)games other:(TSScore)other set:(NSUInteger)setnumber{
    BOOL rv = false;
    if ([self checkIsLastSet:setnumber]) {
        if (self.decidingSetIsTieBreak) {
            return games>other;
        }else{
            if (self.decidingSetHasNoTieBreak) {
                rv = games >= self.gamesPerSet && games > other+1;
            }else{
                rv = (games >= self.gamesPerSet && games > other+1) || (games > self.gamesPerSet && other == self.gamesPerSet);
            }
        }
    }else{
        rv = (games >= self.gamesPerSet && games > other+1) || (games > self.gamesPerSet && other == self.gamesPerSet);
    }
    return rv;
}

-(BOOL)checkTieBreak:(TSScore)games other:(TSScore)other{
    return games == other && games >= self.gamesPerSet;
}

-(BOOL)checkSetsWonMatch:(TSScore)sets other:(TSScore)other{
    // (3) 1-1  r=1
    // (3) 2-0  r=1
    // (3) 1-0  r=2
    // (5) 3-1  r=1   2-0 r=3

    TSScore remaining = self.setsPerMatch - (sets+other);
    return sets > (other + remaining);
}


@end
