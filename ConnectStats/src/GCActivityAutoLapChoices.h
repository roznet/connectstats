//  MIT Licence
//
//  Created on 06/04/2013.
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
#import "GCActivity+Calculated.h"

typedef NS_ENUM(NSUInteger, gcAutoLapStyle) {
    gcAutoLapStyleMatching,
    gcAutoLapStyleRolling,
    gcAutoLapStyleSki,
    gcAutoLapStyleZone,
    gcAutoLapStyleIndexSerie
};
@class GCHealthZoneCalculator;

@interface GCActivityAutoLapChoiceHolder : NSObject
@property (nonatomic,assign) GCActivityMatchLapBlock match;
@property (nonatomic,assign) GCActivityCompareLapBlock compare;
@property (nonatomic,assign) double value;
@property (nonatomic,retain) NSString * key;
@property (nonatomic,assign) gcAutoLapStyle style;
@property (nonatomic,retain) GCHealthZoneCalculator*zoneCalc;
@property (nonatomic,retain) GCStatsDataSerieWithUnit * indexSerie;

+(GCActivityAutoLapChoiceHolder*)choiceHolder:(GCActivityMatchLapBlock)match value:(double)value andLabel:(NSString*)label;
+(GCActivityAutoLapChoiceHolder*)choiceHolder:(GCActivityMatchLapBlock)match compare:(GCActivityCompareLapBlock)comp value:(double)value andLabel:(NSString*)label;
+(GCActivityAutoLapChoiceHolder*)choiceHolderSki;
+(GCActivityAutoLapChoiceHolder*)choiceForZoneCalculator:(GCHealthZoneCalculator*)zoneCalc andLabel:(NSString*)label;
+(GCActivityAutoLapChoiceHolder*)choiceForIndexSerie:(GCStatsDataSerieWithUnit*)serie andLabel:(NSString*)label;

-(NSArray*)laps:(GCActivity*)activity;
@end

@interface GCActivityAutoLapChoices : NSObject
@property (nonatomic,retain) NSArray * choices;
@property (nonatomic,retain) GCActivity * activity;
@property (nonatomic,assign) NSUInteger selected;

-(instancetype)init NS_DESIGNATED_INITIALIZER;
-(GCActivityAutoLapChoices*)initWithActivity:(GCActivity*)act NS_DESIGNATED_INITIALIZER;
-(void)changeSelectedTo:(NSUInteger)idx;
-(void)changeActivity:(GCActivity*)act;

-(NSAttributedString*)currentDetailledDescription;
-(GCActivityAutoLapChoiceHolder*)currentHolder;
+(NSAttributedString*)defaultDescription;
+(NSAttributedString*)currentDescription:(GCActivity*)activity;

-(NSArray*)choicesDescriptions;
@end
