//  MIT License
//
//  Created on 02/04/2021 for ConnectStats
//
//  Copyright (c) 2021 Brice Rosenzweig
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
    gcAutoLapStyleIndexSerie,
    gcAutoLapStyleAccumulated
};
@class GCHealthZoneCalculator;

NS_ASSUME_NONNULL_BEGIN

@interface GCActivityAutoLapChoiceHolder : NSObject
@property (nonatomic,assign,nullable) GCActivityMatchLapBlock match;
@property (nonatomic,assign,nullable) GCActivityCompareLapBlock compare;
@property (nonatomic,assign) double value;
@property (nonatomic,retain) NSString * key;
@property (nonatomic,assign) gcAutoLapStyle style;
@property (nonatomic,retain) GCHealthZoneCalculator*zoneCalc;
@property (nonatomic,retain) GCStatsDataSerieWithUnit * indexSerie;
@property (nonatomic,retain) NSString * lapDescription;


+(GCActivityAutoLapChoiceHolder*)choiceHolderWithLabel:(NSString*)label;
+(GCActivityAutoLapChoiceHolder*)choiceHolder:(GCActivityMatchLapBlock)match
                                        value:(double)value
                                     andLabel:(NSString*)label;
+(GCActivityAutoLapChoiceHolder*)choiceHolder:(GCActivityMatchLapBlock)match
                                      compare:(GCActivityCompareLapBlock)comp
                                        value:(double)value andLabel:(NSString*)label;
+(GCActivityAutoLapChoiceHolder*)choiceHolderSki;
+(GCActivityAutoLapChoiceHolder*)choiceForZoneCalculator:(GCHealthZoneCalculator*)zoneCalc
                                                andLabel:(NSString*)label;
+(GCActivityAutoLapChoiceHolder*)choiceForIndexSerie:(GCStatsDataSerieWithUnit*)serie
                                            andLabel:(NSString*)label;
+(GCActivityAutoLapChoiceHolder*)choiceHolderAccumulatedWithLabel:(NSString*)label;

-(NSArray<GCLap*>*)laps:(GCActivity*)activity;

-(BOOL)shouldAlwaysRecalculate;
@end

NS_ASSUME_NONNULL_END
