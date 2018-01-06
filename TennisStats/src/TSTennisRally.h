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

#import <Foundation/Foundation.h>
#import "TSTennisShot.h"
#import "TSTennisScore.h"

@class TSTennisSession;

@interface TSTennisRally : NSObject<NSFastEnumeration>

@property (nonatomic,retain) TSTennisScore * score;
@property (nonatomic,assign) tsCourtSide playerCourtSide;

-(TSTennisRally*)initWithScore:(TSTennisScore*)score session:(TSTennisSession*)session andPlayerCourtSide:(tsCourtSide)playerCourtSide;

-(BOOL)isSameRally:(TSTennisShot*)shot;
-(void)addShot:(TSTennisShot*)shot;

-(void)playerWon;
-(void)opponentWon;
-(void)frontCourtSideWon;
-(void)backCourtSideWon;
-(void)switchSide;
-(void)recordResult:(tsRallyResult)result;
-(tsContestant)winningContestantFromLastShot;
-(tsContestant)serverContestant;
-(tsContestant)winningContestant;

-(NSString*)playerRallyDescription;
-(NSString*)opponentRallyDescription;

-(void)endRally;

-(TSTennisScore*)nextScore;
-(TSTennisShot*)lastShot;
-(BOOL)lastShotIsEnd;
-(TSTennisShot*)lastPlayerShot;

-(NSDate*)startTime;
-(NSDate*)endTime;

-(NSUInteger)count;
-(TSTennisShot*)objectAtIndexedSubscript:(NSUInteger)idx;

-(NSUInteger)numberOfServesIn;
-(NSUInteger)numberOfServesOut;

-(TSDataRow*)dataRow;
+(NSArray*)dataColumns;

@end
