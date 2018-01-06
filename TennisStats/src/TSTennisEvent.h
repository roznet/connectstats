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

#import <Foundation/Foundation.h>
#import "TSTennis.h"


typedef NS_ENUM(NSUInteger, tsEvent) {
    tsEventNone,
    tsEventShot,    // 1
    tsEventBall,
    tsEventBackPlayerWon,
    tsEventBackPlayerLost,
    tsEventFrontPlayerWon, // 5
    tsEventFrontPlayerLost,
    tsEventPlayerSwithSide,
    tsEventRallyResult,
    tsEventPlayerUpdateScore,
    tsEventOpponentUpdateScore, //10
    tsEventTag,
    tsEventEnd
};

@interface TSTennisEvent : NSObject
@property (nonatomic,retain) NSDate * time;
@property (nonatomic,assign) tsEvent type;
@property (nonatomic,assign) CGPoint location;
/// Main Difference
@property (nonatomic,assign) CGPoint delta;
/// Secondary Difference
@property (nonatomic,assign) CGPoint gamma;


+(TSTennisEvent*)event:(tsEvent)type;
+(TSTennisEvent*)event:(tsEvent)type withValue:(CGFloat)value;
+(TSTennisEvent*)event:(tsEvent)type withValue:(CGFloat)value second:(CGFloat)second;
+(TSTennisEvent*)event:(tsEvent)type withValue:(CGFloat)value second:(CGFloat)second third:(CGFloat)third;
+(TSTennisEvent*)event:(tsEvent)type withLocation:(CGPoint)point;
+(TSTennisEvent*)event:(tsEvent)type withLocation:(CGPoint)point andDelta:(CGPoint)delta;
+(TSTennisEvent*)event:(tsEvent)type withLocation:(CGPoint)point andDelta:(CGPoint)delta andGamma:(CGPoint)gamma;
+(TSTennisEvent*)eventWithResultSet:(FMResultSet*)res;

-(void)saveToDb:(FMDatabase*)db;
+(void)ensureDbStructure:(FMDatabase*)db;

-(tsShotType)shotType;
-(tsCourtSide)playerCourtSide;
-(tsCourtSide)shotCourtSide;
-(tsBallCourtArea)ballCourtArea;
-(tsShotCourtArea)shotCourtArea;
-(BOOL)isLeftSide;
-(BOOL)ballIsIn:(CGPoint)shotLocation;
-(BOOL)ballIsInServe:(CGPoint)shotLocation;
-(tsShotCategory)shotCategory;
-(tsShotStyle)shotStyle;



@end
