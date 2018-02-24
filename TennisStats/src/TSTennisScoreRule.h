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
#import "TSTennis.h"


extern NSString * kScoreRule3SetsChampionShip;
extern NSString * kScoreRule3ShortSets;

@class FMDatabase;

typedef unsigned long TSScoreRulePacked;

@interface TSTennisScoreRule : NSObject

@property (nonatomic,assign) TSScore tieBreakNumberOfPoints;
@property (nonatomic,assign) TSScore gamesPerSet;
@property (nonatomic,assign) TSScore setsPerMatch;

@property (nonatomic,assign) BOOL decidingSetIsTieBreak;
@property (nonatomic,assign) TSScore decidingSetTieBreakNumberOfPoints;
@property (nonatomic,assign) BOOL decidingSetHasNoTieBreak;
@property (nonatomic,assign) BOOL gameEndWithSuddenDeath;


+(TSTennisScoreRule*)ruleForName:(NSString*)name;
+(NSArray<NSString*>*)availableRuleNames;

+(TSTennisScoreRule*)defaultRule;
+(TSTennisScoreRule*)shortSetRule;

+(TSTennisScoreRule*)ruleFromDb:(FMDatabase*)db;
+(void)ensureDbStructure:(FMDatabase*)db;
-(void)saveToDb:(FMDatabase*)db;
-(NSString*)asString;

-(BOOL)isEqualToRule:(TSTennisScoreRule*)other;
-(TSScoreRulePacked)pack;
-(TSTennisScoreRule*)unpack:(TSScoreRulePacked)val;

-(tsContestant)winnerFromResult:(TSTennisResult*)result;
-(BOOL)validateResult:(TSTennisResult*)result;

-(BOOL)checkGamesWonSet:(TSScore)games other:(TSScore)other set:(NSUInteger)setnumber;
-(BOOL)checkIsLastSet:(NSUInteger)setnumber;
-(BOOL)checkTieBreak:(TSScore)games other:(TSScore)other;
-(BOOL)checkSetsWonMatch:(TSScore)sets other:(TSScore)other;

@end
