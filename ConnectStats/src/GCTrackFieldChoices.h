//  MIT Licence
//
//  Created on 21/08/2013.
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
#import "GCFields.h"
#import "GCTrackStats.h"
#import "GCTrackFieldChoiceHolder.h"

@class GCActivity;
@class GCHealthZoneCalculator;


@interface GCTrackFieldChoices : NSObject
/**
 nested NSArray. Each subarray is an NSArray<GCTrackFieldChoiceHolder> for the differenet
 relevant styles for a field. The 0th element of the subarray is typically
 the configuration for simple graph of the field, and then different styles (scatterplots, best of, histogram, etc)
 */
@property (nonatomic,retain) NSArray * choices;
@property (nonatomic,assign) NSUInteger currentChoice;
@property (nonatomic,assign) NSUInteger currentStyle;
@property (nonatomic,assign) gcFieldFlag trackFlag;
@property (nonatomic,retain) NSString * activityType;

+(GCTrackFieldChoices*)trackFieldChoicesWithActivity:(GCActivity*)activity;
+(GCTrackFieldChoices*)trackFieldChoicesWithDayActivity:(GCActivity*)activity;

-(void)setupTrackStats:(GCTrackStats*)trackStats;

/** @brief select the next field
 */
-(void)next;
-(void)previous;
/** @brief select the next graph style for the same field, if this is the last style, it moves to the next field
 */
-(void)nextStyle;

-(GCTrackFieldChoiceHolder*)current;
/**
 Returns the NSArray<GCTrackFieldChoiceHolder*> with the styles relevant for field
 */
-(NSArray<GCTrackFieldChoiceHolder*>*)holdersForField:(GCField*)field;
-(BOOL)validForActivity:(GCActivity*)activity;
-(BOOL)trackFlagSameAs:(GCActivity*)activity;


@end
