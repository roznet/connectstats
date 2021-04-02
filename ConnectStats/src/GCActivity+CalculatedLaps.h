//  MIT Licence
//
//  Created on 20/02/2013.
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

#import "GCActivity.h"

@class GCHealthZoneCalculator;
@class GCStatsDataSerieWithUnit;

typedef NSComparisonResult (^GCActivityMatchLapBlock)(GCLap * candidate,GCLap * diff,double value,BOOL interp);
typedef BOOL (^GCActivityCompareLapBlock)(GCLap*current,GCLap*candidate);

@interface GCActivity (CalculatedLaps)

/// Look for the last lap that matches the MatchlapBlock and that return true to for the compare function
/// For example, if match is a fix distance and compare returns true if a specific value like speed is higher
/// it will find the lap of that distance that achieved the highest speed
/// @param val Value to pass to the match function
/// @param matchG match function to indicate the lap is valid
/// @param compare function to indicate if the latest lap is preferred to the last one
-(NSArray<GCLap*>*)calculatedRollingLapFor:(double)val match:(GCActivityMatchLapBlock)matchG compare:(GCActivityCompareLapBlock)compare;
-(NSArray<GCLap*>*)calculatedLapFor:(double)val match:(GCActivityMatchLapBlock)matchL inLap:(NSUInteger)idx;
-(NSArray<GCLap*>*)calculateSkiLaps;
-(NSArray<GCLap*>*)compoundLapForZoneCalculator:(GCHealthZoneCalculator*)zoneCalc;
-(NSArray<GCLap*>*)compoundLapForIndexSerie:(GCStatsDataSerieWithUnit*)serieu desc:(NSString*)desc;
-(NSArray<GCLap*>*)accumulatedLaps;

-(GCActivityCompareLapBlock)compareSpeedBlock;
-(GCActivityMatchLapBlock)matchDistanceBlockEqual;
-(GCActivityMatchLapBlock)matchDistanceBlockGreater;
-(GCActivityMatchLapBlock)matchTimeBlock;

@end
