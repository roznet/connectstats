//  MIT Licence
//
//  Created on 27/10/2014.
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
#import "TSTennis.h"

// Rally Fields
extern NSString * kfWinner;
extern NSString * kfWinners;
extern NSString * kfNumberOfShots;
extern NSString * kfScoreDifferential;
extern NSString * kfScoreCriticality;
extern NSString * kfLastShotType;
extern NSString * kfLastShotArea;
extern NSString * kfRallyResult;
extern NSString * kfRallyLength;
extern NSString * kfRallyTime;
extern NSString * kfRallyNumber;
extern NSString * kfSetNumber;
// Shots Fields
extern NSString * kfShotType;
extern NSString * kfShotCourtArea;
extern NSString * kfBallCourtArea;
extern NSString * kfShotStyle;
extern NSString * kfShotAnalysis;
extern NSString * kfShotDirection;
extern NSString * kfShotPlayer;
extern NSString * kfShotNumber;
extern NSString * kfShotTime;
extern NSString * kfShotIsRallyEnd;

// Analysis
extern NSString * kfPlayerName;
extern NSString * kfAnalysisName;
extern NSString * kfAnalysisSituation;
extern NSString * kfAnalysisCount;

extern NSString * kaAnalysisDefence;
extern NSString * kaAnalysisProactive;
extern NSString * kaAnalysisReactive;

extern NSString * kaEffective;
extern NSString * kaIneffective;

@interface TSTennisFields : NSObject

+(NSString*)shotTypeDescription:(tsShotType)type;
+(NSString*)courtSideDescription:(tsCourtSide)sides;
+(NSString*)shotCourtAreaDescription:(tsShotCourtArea)area;
+(NSString*)ballCourtAreaDescription:(tsBallCourtArea)area;
+(NSString*)scoreDifferentialDescription:(tsDifferential)diff;
+(NSString*)resultDescription:(tsRallyResult)result;
+(NSString*)contestantDescription:(tsContestant)contestant;
+(NSString*)rallyLengthDescription:(tsRallyLength)length;
+(NSString*)scoreCriticalityDescription:(tsScoreCriticality)criticality;
+(NSString*)tagDescription:(tsTag)tag;
+(NSString*)shotStyleDescription:(tsShotStyle)style;
+(NSString*)shotDirectionDescription:(tsShotDirection)direction;
+(NSString*)shotCategoryDescription:(tsShotCategory)category;
+(NSString*)analysisDescription:(tsAnalysis)analysis;

@end
