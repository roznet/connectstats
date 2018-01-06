//  MIT Licence
//
//  Created on 21/10/2012.
//
//  Copyright (c) 2012 Brice Rosenzweig.
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
#import "GCStatsDataSerie.h"

@class GCStatsDataSerieWithUnit;


@interface GCStatsLinearFunction : NSObject<GCStatsFunction>{
    double alpha;
    double beta;
}

@property (nonatomic,assign) double alpha;
@property (nonatomic,assign) double beta;

+(GCStatsLinearFunction*)linearFunctionWithAlpha:(double)a andBeta:(double)b;

@end

/**
 Return a function between [0,1] scaled within range of the original serie
 Can be either x value or y value scaled within its respective range
 */
@interface GCStatsScaledFunction : NSObject<GCStatsFunction>{
    GCStatsDataSerie * serie;
    NSUInteger currentIndex;
    gcStatsRange range;
    BOOL scale_x;
}
@property (nonatomic,retain) GCStatsDataSerie * serie;
@property (nonatomic,assign) NSUInteger currentIndex;
@property (nonatomic,assign) gcStatsRange range;
@property (nonatomic,assign) BOOL scale_x;


+(GCStatsScaledFunction*)scaledFunctionWithSerie:(GCStatsDataSerie*)aSerie;
+(GCStatsScaledFunction*)scaledFunctionForXWithSerie:(GCStatsDataSerie*)aSerie;

@end

/**
 Return function with values linearly interpreted between points
 */
@interface GCStatsInterpFunction : NSObject<GCStatsFunction>{
    GCStatsDataSerie * serie;
    NSUInteger currentIndex;
}
@property (nonatomic,retain) GCStatsDataSerie * serie;
@property (nonatomic,assign) NSUInteger currentIndex;

+(GCStatsInterpFunction*)interpFunctionWithSerie:(GCStatsDataSerie*)aSerie;

-(GCStatsDataSerie*)xySerieWith:(GCStatsDataSerie*)other;
+(GCStatsDataSerieWithUnit*)xySerieWithUnitForX:(GCStatsDataSerieWithUnit*)xSerie andY:(GCStatsDataSerieWithUnit*)ySerie;
@end

/**
 return a function between [0,1] of value quantile number/total number of quantile for each y in original value
 */
@interface GCStatsQuantileFunction : NSObject<GCStatsFunction>
@property (nonatomic,retain) GCStatsDataSerie * serie;
@property (nonatomic,assign) NSUInteger currentIndex;
+(GCStatsQuantileFunction*)quantileFunctionWith:(GCStatsDataSerie*)aSerie andQuantiles:(NSUInteger)nQuantiles;

@end

/**
 return 0 or 1 if non zero
 */
@interface GCStatsNonZeroIndicatorFunction : NSObject<GCStatsFunction>
@property (nonatomic,retain) GCStatsDataSerie * serie;
@property (nonatomic,assign) NSUInteger currentIndex;

+(GCStatsNonZeroIndicatorFunction*)nonZeroIndicatorFor:(GCStatsDataSerie*)serie;

@end

/**
 returns a function [0,1] with value index of x / total number of points
 Convenient for bar graph gradients
 */
@interface GCStatsScaledXIndexFunction : NSObject<GCStatsFunction>

@property (nonatomic,retain) GCStatsDataSerie * serie;
@property (nonatomic,assign) NSUInteger currentIndex;

+(GCStatsScaledXIndexFunction*)scaledXIndexFunctionFor:(GCStatsDataSerie*)serie;

@end
