//  MIT Licence
//
//  Created on 22/09/2012.
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
#import "GCStatsDataPoint.h"


@class GCStatsDataSerie;
@class GCStatsLinearFunction;

extern NSString * STATS_SUM;
extern NSString * STATS_CNT;
extern NSString * STATS_AVG;
extern NSString * STATS_MAX;
extern NSString * STATS_MIN;
extern NSString * STATS_STD;

extern NSString * STATS_SUMPOS;
extern NSString * STATS_SUMNEG;
extern NSString * STATS_AVGPOS;
extern NSString * STATS_AVGNEG;

extern NSString * STATS_WSUM;
extern NSString * STATS_WAVG;
extern NSString * STATS_WAVGPOS;
extern NSString * STATS_WAVGNEG;

NS_INLINE double STDDEV(double cnt, double sum, double ssq ){
    return sqrt((cnt*ssq-sum*sum)/(cnt*(cnt-1)));
}

typedef NS_ENUM(NSUInteger, gcStatsFillMethod) {
    gcStatsZero,
    gcStatsLast

};

typedef NS_ENUM(NSUInteger, gcStatsSelection) {
    gcStatsMax,
    gcStatsMin
};

typedef struct {
    double x_min;
    double x_max;
    double y_min;
    double y_max;
} gcStatsRange;

typedef struct {
    NSInteger left;
    NSInteger right;
    NSInteger cnt;
} gcStatsIndexes;

typedef NS_ENUM(NSUInteger, gcStatsOperand) {
    gcStatsOperandPlus,
    gcStatsOperandMax,
    gcStatsOperandMin,
    gcStatsOperandMultiply
};

gcStatsRange minRange( gcStatsRange range1, gcStatsRange range2);
gcStatsRange maxRange( gcStatsRange range1, gcStatsRange range2);
gcStatsRange maxRangeXOnly( gcStatsRange range1, gcStatsRange range2);

@protocol GCStatsFunction <NSObject>

-(GCStatsDataSerie*)valueForXIn:(GCStatsDataSerie*)serie;
-(double)valueForX:(double)x;

@end

@interface GCStatsDataSerie : NSObject<NSCoding,NSFastEnumeration>


// --- Constructions
-(instancetype)init NS_DESIGNATED_INITIALIZER;

/**
 Will make a deep copy of the points array (but not the datapoints themselves)
 */
+(GCStatsDataSerie*)dataSerieWithPointsIn:(GCStatsDataSerie*)other;
+(GCStatsDataSerie*)dataSerieWithPoints:(NSArray<GCStatsDataPoint*>*)points;
/**
 return data serie from an array of double, [ x0,y0, x1,y1, ... ]
 */
+(GCStatsDataSerie*)dataSerieWithArrayOfDouble:(NSArray<NSNumber*>*)doubles;


+(void)reduceToCommonRange:(GCStatsDataSerie*)serie1 and:(GCStatsDataSerie*)serie2;
/**
 Will reduce the two series to the set of points that they have in common.
 This will be done in place
 @param serie1 This serie will be modified in place
 @param serie2 This serie will be modified in place
 */
+(void)reduceToCommonInterval:(GCStatsDataSerie *)serie1 and:(GCStatsDataSerie *)serie2;

-(GCStatsDataSerie*)serieReducedToRange:(gcStatsRange)range;
-(void)addDataPointWithDate:(NSDate*)aDate andValue:(double)value;
-(void)addDataPointWithDate:(NSDate*)aDate since:(NSDate*)first andValue:(double)value;
-(void)addDataPointWithX:(double)x andY:(double)value;
-(void)addDataPointWithX:(double)x y:(double)y andZ:(double)z;
-(void)addDataPointNoValueWithX:(double)x;
/**
 Add new point copy with same class and x_data as point and value
 */
-(void)addDataPointWithPoint:(GCStatsDataPoint*)point andValue:(double)value;

-(void)sortByReverseDate;
-(void)sortByDate;
-(void)sortByValue;
-(void)sortByX;

-(BOOL)isStrictlyIncreasingByX;

// --- Access
-(NSString*)description;
-(NSString*)descriptionAllPoints;
-(NSString*)asCSVString:(BOOL)asDate;

-(NSUInteger)count;
-(GCStatsDataPoint*)dataPointAtIndex:(NSUInteger)idx;
-(GCStatsDataPoint*)objectAtIndexedSubscript:(NSUInteger)idx;
-(GCStatsDataPoint*)lastObject;
-(GCStatsDataPoint*)firstObject;

-(gcStatsIndexes)indexForXVal:(double)aX from:(NSUInteger)idx;

// --- Stats
-(GCStatsDataSerie*)quantiles:(NSUInteger)n;
-(GCStatsDataSerie*)sum;
-(GCStatsDataSerie*)average;
-(GCStatsDataSerie*)standardDeviation;
/**
 Return the cumulative difference with another serie, useful for comparing.
 it returns Sum( this so far ) - Sum( other so far)
 It assumes each serie is already a cumulative
 */
-(GCStatsDataSerie*)cumulativeDifferenceWith:(GCStatsDataSerie*)other;
-(GCStatsDataSerie*)cumulativeValue;
-(GCStatsDataSerie*)xyCumulativeValue;
-(GCStatsDataSerie*)filterForNonZeroIn:(GCStatsDataSerie*)other;
-(gcStatsRange)range;
-(GCStatsDataPoint*)max;
-(GCStatsDataPoint*)min;
-(GCStatsLinearFunction*)regression;
-(GCStatsDataSerie*)movingAverage:(NSUInteger)nSamples;
-(GCStatsDataSerie*)bucketWith:(GCStatsDataSerie*)buckets;
-(GCStatsDataSerie*)countByXInterval:(double)xInt xMax:(double)xMax;
-(GCStatsDataSerie*)normalizedSerie:(double)avg std:(double)std;
-(GCStatsDataSerie*)movingAverageForUnit:(double)unit;
-(GCStatsDataSerie*)movingSumForUnit:(double)unit;
-(GCStatsDataSerie*)movingAverageOrSumOf:(GCStatsDataSerie*)rawother forUnit:(double)unit offset:(double)offset average:(BOOL)avg;
/**
 Generate a serie for which x are bcukets spaning Ys with size spacing * k such that number of bucket is less than maxBucket

 @param spacing the width of the bucket,
 @param maxBuckets the maximum number of buckets.
 @return a new histogram serie
 */
-(GCStatsDataSerie*)histogramOfXSumWithYBucketSize:(double)spacing andMaxBuckets:(NSUInteger)maxBuckets;
/**
 This will rebucket a serie, but assumes the buckets are a subset of current series' buckets
 and that the y are summed for collapsed buckets

 @param buckets serie of buckets (Xs must be subset of serie's Xs)
 @return new serie or nil of sub buckets are incompatible
 */
-(GCStatsDataSerie*)rebucket:(GCStatsDataSerie*)buckets;

/**
 compute basics statistics with keys STATS_XXX constants (avg,cnt,wsum,...)
 */
-(NSDictionary<NSString*,NSNumber*>*)summaryStatistics;
/**
 Compute dy/dx serie
 @param dx in the minimum delta x required to compute derivative. dx=0 compute between consecutive points
 @param scaling multiplier do change unit dy/dx * scaling
 */
-(GCStatsDataSerie*)deltaYSerieForDeltaX:(double)dx scalingFactor:(double)scaling;

/**
 Return a dictionary with aggregated series for different statistics.
 Each serie will have the statistic for the first day of the bucket
 @param aUnit NSCalendarUnit calendar unit to do the bucketing
 @param refOrNil NSCalendar* the calendar for the bucketing
 @return NSDictionary* a dictionary with keys STATS_SUM, STATS_CNT, STATS_AVG, STATS_MAX, STATS_MIN, STATS_STD
 */
-(NSDictionary*)aggregatedStatsByCalendarUnit:(NSCalendarUnit)aUnit
                                referenceDate:(NSDate*)refOrNil
                                  andCalendar:(NSCalendar*)cal;

/**
 Return a dictionary with series with points within given buckets
 @param merged BOOL merged if NO each key will be the start of the interval, if YES, only one serie will be returned
 @param aUnit NSCalendarunit calendar unit to do the bucketing
 @param cal NSCalendar* the calendar for the bucketing
 @return NSDictionary* a dictionary with keys NSDate with start of the bucket, and series with x as interval since beginning of the bucket
 */
-(NSDictionary*)rescaleWithinCalendarUnit:(NSCalendarUnit)aUnit
                                   merged:(BOOL)merged
                            referenceDate:(NSDate*)refOrNil
                              andCalendar:(NSCalendar*)cal;

/**
 Return a dictionary with series where x & y are cumulative, and sorted by timeserie time.
 The dictionary key are the first date of the bucket
 @param aUnit NSCalendarUnit calendar unit to bucket by
 @param timeSerie GCStatsDataSerie* timeSerie serie for time axis. Needs to have exact same count of points
 @param cal NSCalendar* calendar to do the bucketing
 @return NSDictionary or nil with the relevant series.
 */
-(NSDictionary*)xyCumulativeRescaledByCalendarUnit:(NSCalendarUnit)aUnit
                                       inTimeSerie:(GCStatsDataSerie*)timeSerie
                                      withCalendar:(NSCalendar*)cal;

/**
 Will add a GCStatsDataPointNoValue if necessary to close intervals of a given calunit
 Useful for bar graph so the bar only extends the length of the interval
 @param calunit NSCalendarunit calendar unit to close
 @param cal NSCalendar* the calendar for the interval
 @param afterdate NSDate* if not nil, will limit the serie to point after that date
 @return a new serie with interval closed
 */
-(GCStatsDataSerie*)closeIntervalsForCalendarUnit:(NSCalendarUnit)calunit
                                         calendar:(NSCalendar*)cal
                                        afterDate:(NSDate*)afterdate;

/**
 Will truncate the serie for cutOff within calendar buckets (Year, Month, etc). This is used to do Month to date
 Or year to date type calculations
 @param cutOff NSDate* which will be used to compute the cutOff within bucket
 @param aUnit NSCalendarUnit to bucket dates for the cutOff
 @param refOrNil NSDate* reference date to compute buckets
 @param calendar NSCalendar* to compute buckets
 */
-(GCStatsDataSerie*)serieWithCutOff:(NSDate*)cutOff
                           withUnit:(NSCalendarUnit)aUnit
                      referenceDate:(NSDate*)refOrNil
                        andCalendar:(NSCalendar*)calendar;

-(GCStatsDataSerie*)movingBestByUnitOf:(double)unit fillMethod:(gcStatsFillMethod)fill select:(gcStatsSelection)select;
-(GCStatsDataSerie*)histogramWith:(NSUInteger)buckets;
-(GCStatsDataSerie*)filledSerieForUnit:(double)unit fillMethod:(gcStatsFillMethod)fill;
-(GCStatsDataSerie*)summedSerieByUnit:(double)unit fillMethod:(gcStatsFillMethod)fill;

-(GCStatsDataSerie*)operate:(gcStatsOperand)operand with:(GCStatsDataSerie*)other;

-(BOOL)isEqualToSerie:(GCStatsDataSerie*)other;

-(void)removeAllPoints;
@end
