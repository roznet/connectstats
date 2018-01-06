//  MIT Licence
//
//  Created on 03/03/2013.
//
//  Copyright (c) 2013 Brice Rosenzweig.
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

#import "GCActivity.h"
#import "GCTrackStats.h"
#import "GCTrackFieldChoices.h"
#import "GCHealthZoneCalculator.h"

typedef NS_ENUM(NSUInteger, gcSmoothingFlag) {
    gcSmoothingAuto         ,
    gcSmoothingNone         ,
    gcSmoothingWeak         ,
    gcSmoothingNormal       ,
    gcSmoothingStrong       ,
    gcSmoothingStrongest
};

@interface GCActivityTrackOptions : NSObject

@property (nonatomic,retain) GCField * field;
@property (nonatomic,retain) GCField * x_field;
@property (nonatomic,retain) GCField * l_field;
@property (nonatomic,retain) GCField * o_field;

@property (nonatomic,assign) gcSmoothingFlag smoothing;
@property (nonatomic,assign) gcSmoothingFlag x_smoothing;
@property (nonatomic,assign) gcSmoothingFlag l_smoothing;
@property (nonatomic,assign) gcSmoothingFlag o_smoothing;

@property (nonatomic,assign) NSUInteger movingAverage;

@property (nonatomic,assign) BOOL distanceAxis;
@property (nonatomic,assign) gcTrackStatsStyle statsStyle;
@property (nonatomic,retain) GCHealthZoneCalculator * zoneCalculator;

+(GCActivityTrackOptions*)optionFor:(GCField*)field x:(GCField*)aXf andMovingAverage:(NSUInteger)aMA;
+(GCActivityTrackOptions*)optionFor:(GCField*)field l:(GCField*)aLf andMovingAverage:(NSUInteger)aMA;
+(GCActivityTrackOptions*)optionForHolder:(GCTrackFieldChoiceHolder*)holder;

-(void)setupTrackStats:(GCTrackStats*)trackStats;
-(void)setupTrackStatsForOther:(GCTrackStats *)trackStats;

+(NSArray*)smoothingDescriptions;
+(NSUInteger)movingAverageForSmoothingFlag:(gcSmoothingFlag)flag;

@end
