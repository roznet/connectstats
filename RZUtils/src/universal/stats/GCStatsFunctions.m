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

#import "GCStatsFunctions.h"
#import <RZUtils/GCStatsDataSerieWithUnit.h>
#import <RZUtils/RZMacros.h>

@implementation GCStatsLinearFunction
@synthesize alpha,beta;

+(GCStatsLinearFunction*)linearFunctionWithAlpha:(double)a andBeta:(double)b{
    GCStatsLinearFunction * rv = RZReturnAutorelease([[GCStatsLinearFunction alloc] init]);
    if (rv) {
        rv.alpha = a;
        rv.beta = b;
    }
    return rv;
}

-(GCStatsDataSerie*)valueForXIn:(GCStatsDataSerie*)serie{
    GCStatsDataSerie * rv = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);

    for (GCStatsDataPoint * point in serie) {
        double x = point.x_data;
        [rv addDataPointWithX:x andY:(x*beta+alpha)];
    }
    return rv;
}
-(double)valueForX:(double)x{
    return x*beta + alpha;
}

@end

#pragma mark -

@implementation GCStatsNonZeroIndicatorFunction
#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_serie release];
    [super dealloc];
}
#endif

+(GCStatsNonZeroIndicatorFunction*)nonZeroIndicatorFor:(GCStatsDataSerie*)aSerie{
    GCStatsNonZeroIndicatorFunction*rv = RZReturnAutorelease([[GCStatsNonZeroIndicatorFunction alloc] init]);
    if(rv){
        rv.serie = [GCStatsDataSerie dataSerieWithPointsIn:aSerie];
        [rv.serie sortByX];
        rv.currentIndex = 0;

    }
    return rv;
}

-(GCStatsDataSerie*)valueForXIn:(GCStatsDataSerie*)aserie{
    GCStatsDataSerie * rv = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);

    for (GCStatsDataPoint * point in aserie) {
        double x = point.x_data;
        [rv addDataPointWithX:x andY:[self valueForX:x]];
    }
    return rv;
}

-(double)valueForX:(double)ax{
    gcStatsIndexes indexes = [self.serie indexForXVal:ax from:self.currentIndex];
    self.currentIndex = indexes.left;
    double y = ax > [_serie dataPointAtIndex:indexes.right].x_data ? [_serie dataPointAtIndex:indexes.right].y_data : [_serie dataPointAtIndex:indexes.left].y_data;
    return fabs(y)>1.e-10;
}

@end

#pragma mark -

@implementation GCStatsScaledFunction
@synthesize serie,currentIndex,range,scale_x;

#if ! __has_feature(objc_arc)
-(void)dealloc{
    [serie release];
    [super dealloc];
}
#endif

+(GCStatsScaledFunction*)scaledFunctionWithSerie:(GCStatsDataSerie *)aSerie{
    GCStatsScaledFunction * rv = RZReturnAutorelease([[GCStatsScaledFunction alloc] init]);
    if (rv) {
        rv.serie = [GCStatsDataSerie dataSerieWithPointsIn:aSerie];
        [rv.serie sortByX];
        rv.range = [rv.serie range];
        rv.currentIndex = 0;
        rv.scale_x = false;
    }
    return rv;
}

+(GCStatsScaledFunction*)scaledFunctionForXWithSerie:(GCStatsDataSerie*)aSerie{
    GCStatsScaledFunction * rv = [GCStatsScaledFunction scaledFunctionWithSerie:aSerie];
    if (rv) {
        rv.scale_x = true;
    }
    return rv;
}

-(GCStatsDataSerie*)valueForXIn:(GCStatsDataSerie*)aserie{
    GCStatsDataSerie * rv = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);

    for (GCStatsDataPoint * point in aserie) {
        double x = point.x_data;
        [rv addDataPointWithX:x andY:[self valueForX:x]];
    }
    return rv;
}

-(double)valueForX:(double)ax{
    if (scale_x) {
        return (ax-range.x_min)/(range.x_max-range.x_min);
    }
    gcStatsIndexes indexes = [serie indexForXVal:ax from:currentIndex];
    currentIndex = indexes.left;
    double y = ax > [serie dataPointAtIndex:indexes.right].x_data ? [serie dataPointAtIndex:indexes.right].y_data : [serie dataPointAtIndex:indexes.left].y_data;
    return (y-range.y_min)/(range.y_max-range.y_min);
}

@end


#pragma mark -

@implementation GCStatsInterpFunction
@synthesize serie,currentIndex;
#if ! __has_feature(objc_arc)
-(void)dealloc{
    [serie release];
    [super dealloc];
}
#endif

+(GCStatsInterpFunction*)interpFunctionWithSerie:(GCStatsDataSerie*)aSerie{
    GCStatsInterpFunction *rv= RZReturnAutorelease([[GCStatsInterpFunction alloc] init]);
    if (rv) {
        rv.serie = [GCStatsDataSerie dataSerieWithPointsIn:aSerie];
        [rv.serie sortByX];
        rv.currentIndex = 0;
    }
    return rv;
}

-(GCStatsDataSerie*)valueForXIn:(GCStatsDataSerie*)aserie{
    GCStatsDataSerie * rv = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);

    for (GCStatsDataPoint * point in aserie) {
        double x = point.x_data;
        [rv addDataPointWithX:x andY:[self valueForX:x]];
    }
    return rv;
}
-(double)valueForX:(double)ax{
    if ([self.serie count] == 0) {
        return 0.;
    }
    gcStatsIndexes indexes = [serie indexForXVal:ax from:currentIndex];
    currentIndex = indexes.left;
    if (indexes.left == indexes.right) {
        return [serie dataPointAtIndex:indexes.left].y_data;
    }
    double
        left_x = [serie dataPointAtIndex:indexes.left].x_data,
        left_y = [serie dataPointAtIndex:indexes.left].y_data,
        right_x =[serie dataPointAtIndex:indexes.right].x_data,
        right_y =[serie dataPointAtIndex:indexes.right].y_data;

    return left_y + (ax-left_x)/(right_x-left_x)*(right_y-left_y);
}

-(GCStatsDataSerie*)xySerieWith:(GCStatsDataSerie*)other{
    GCStatsDataSerie * rv = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);
    for (GCStatsDataPoint * otherPoint in other) {
        double x = otherPoint.x_data;
        double y = otherPoint.y_data;
        double this_y = [self valueForX:x];
        [rv addDataPointWithX:this_y andY:y];
    }
    return rv;
}

+(GCStatsDataSerieWithUnit*)xySerieWithUnitForX:(GCStatsDataSerieWithUnit*)xSerie andY:(GCStatsDataSerieWithUnit*)ySerie{
    GCStatsInterpFunction * interp = [GCStatsInterpFunction interpFunctionWithSerie:xSerie.serie];
    GCStatsDataSerie * xy = [interp xySerieWith:ySerie.serie];
    GCStatsDataSerieWithUnit * rv = [GCStatsDataSerieWithUnit dataSerieWithUnit:ySerie.unit andSerie:xy];
    rv.xUnit = xSerie.unit;
    return rv;

}

@end

#pragma mark -

@implementation GCStatsQuantileFunction

#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_serie release];
    [super dealloc];
}
#endif

+(GCStatsQuantileFunction*)quantileFunctionWith:(GCStatsDataSerie*)aSerie andQuantiles:(NSUInteger)nQuantiles{
    GCStatsQuantileFunction *rv= RZReturnAutorelease([[GCStatsQuantileFunction alloc] init]);
    if (rv) {
        GCStatsDataSerie * quantiles = [aSerie quantiles:nQuantiles];
        rv.serie = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);

        size_t n = [quantiles count];
        double * thresholds = malloc(sizeof(double)*n);
        size_t idx=0;

        for (idx=0; idx<n; idx++) {
            double val =[quantiles dataPointAtIndex:idx].y_data;
            thresholds[idx]=val;
        }

        for (GCStatsDataPoint * point in aSerie) {
            double x = point.x_data;
            double y = point.y_data;

            for (idx=0; idx<n; idx++) {
                double th = thresholds[idx];
                if (y<th) {
                    break;
                }
            }
            double val = (double)idx/n;

            [rv.serie addDataPointWithX:x andY:val];
        }
        free(thresholds);
    }
    return rv;
}

-(double)valueForX:(double)ax{
    gcStatsIndexes indexes = [self.serie indexForXVal:ax from:self.currentIndex];
    self.currentIndex = indexes.left;
    double y = ax > [self.serie dataPointAtIndex:indexes.right].x_data ? [self.serie dataPointAtIndex:indexes.right].y_data : [self.serie dataPointAtIndex:indexes.left].y_data;
    return y;
}

-(GCStatsDataSerie*)valueForXIn:(GCStatsDataSerie*)aserie{
    GCStatsDataSerie * rv = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);

    for (GCStatsDataPoint * point in aserie) {
        double x = point.x_data;
        [rv addDataPointWithX:x andY:[self valueForX:x]];
    }
    return rv;
}

@end

#pragma mark -

@implementation GCStatsScaledXIndexFunction

#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_serie release];
    [super dealloc];
}
#endif

+(GCStatsScaledXIndexFunction*)scaledXIndexFunctionFor:(GCStatsDataSerie*)serie{
    GCStatsScaledXIndexFunction *rv= RZReturnAutorelease([[GCStatsScaledXIndexFunction alloc] init]);
    if (rv){
        rv.serie = serie;
    }
    return rv;
}

-(double)valueForX:(double)ax{
    gcStatsIndexes indexes = [self.serie indexForXVal:ax from:self.currentIndex];
    return (double)indexes.left/_serie.count;
}

-(GCStatsDataSerie*)valueForXIn:(GCStatsDataSerie*)aserie{
    GCStatsDataSerie * rv = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);

    for (GCStatsDataPoint * point in aserie) {
        double x = point.x_data;
        [rv addDataPointWithX:x andY:[self valueForX:x]];
    }
    return rv;
}
@end
