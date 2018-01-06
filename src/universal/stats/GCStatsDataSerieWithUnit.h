//  MIT Licence
//
//  Created on 30/03/2013.
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
#import "GCUnit.h"
#import "GCStatsDataSerie.h"
#import "GCNumberWithUnit.h"

@interface GCStatsDataSerieWithUnit : NSObject<NSCoding,NSFastEnumeration>

@property (nonatomic,retain) GCStatsDataSerie * serie;
@property (nonatomic,retain) GCUnit * unit;
@property (nonatomic,retain) GCUnit * xUnit;

+(GCStatsDataSerieWithUnit*)dataSerieWithUnit:(GCUnit*)unit;
+(GCStatsDataSerieWithUnit*)dataSerieWithUnit:(GCUnit*)unit andSerie:(GCStatsDataSerie*)serie;
+(GCStatsDataSerieWithUnit*)dataSerieWithUnit:(GCUnit*)unit xUnit:(GCUnit*)xUnit andSerie:(GCStatsDataSerie*)serie;

+(GCStatsDataSerieWithUnit*)statsDataSerieWithUnit:(GCUnit*)unit xUnit:(GCUnit*)xUnit andSerie:(GCStatsDataSerie*)serie;

-(GCStatsDataSerieWithUnit*)dataSerieConvertedToUnit:(GCUnit*)unit;
-(GCStatsDataSerieWithUnit*)dataSerieConvertedToXUnit:(GCUnit*)xUnit;
+(GCStatsDataSerieWithUnit*)dataSerieWithOther:(GCStatsDataSerieWithUnit*)other;

-(NSUInteger)count;
-(GCStatsDataPoint*)dataPointAtIndex:(NSUInteger)idx;
-(void)convertToUnit:(GCUnit*)unit;
-(void)convertToXUnit:(GCUnit*)xUnit;
-(void)convertToCommonUnitWith:(GCUnit*)unit;
-(void)convertToGlobalSystem;

-(BOOL)isEqualToSerieWithUnit:(GCStatsDataSerieWithUnit*)other;

-(void)addNumberWithUnit:(GCNumberWithUnit*)number forDate:(NSDate*)date;
-(void)addNumberWithUnit:(GCNumberWithUnit*)number forX:(double)x;

-(GCStatsDataSerieWithUnit*)movingAverage:(NSUInteger)nSamples;
-(GCStatsDataSerieWithUnit*)histogramWith:(NSUInteger)buckets;
-(GCStatsDataSerieWithUnit*)bucketWith:(GCStatsDataSerieWithUnit*)buckets;
-(GCStatsDataSerieWithUnit*)filterForNonZeroIn:(GCStatsDataSerie*)other;
-(GCStatsDataSerieWithUnit*)summedBy:(double)unit;
-(GCStatsDataSerieWithUnit*)filledForUnit:(double)unit;
-(GCStatsDataSerieWithUnit*)cumulative;
-(GCStatsDataSerieWithUnit*)cumulativeDifferenceWith:(GCStatsDataSerieWithUnit*)other;

+(void)reduceToCommonRange:(GCStatsDataSerieWithUnit*)serie1 and:(GCStatsDataSerieWithUnit*)serie2;
-(GCStatsDataSerieWithUnit*)movingAverageOrSumOf:(GCStatsDataSerieWithUnit*)rawother forUnit:(double)unit offset:(double)offset average:(BOOL)avg;

-(GCStatsDataSerieWithUnit*)serieWithCutOff:(NSDate*)cutOff
                                   withUnit:(NSCalendarUnit)aUnit
                              referenceDate:(NSDate*)refOrNil
                                andCalendar:(NSCalendar*)calendar;

-(BOOL)isStrictlyIncreasingByX;

@end
