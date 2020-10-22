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

#import <RZUtils/GCStatsDataSerie.h>
#import "GCStatsFunctions.h"
#import "NSDate+RZHelper.h"
#import "GCStatsDateBuckets.h"
#import "GCStatsDataPointMulti.h"
#import "RZFileOrganizer.h"
#import <RZUtils/RZMacros.h>
#import "RZLog.h"
#import "NSDateComponents+RZHelper.h"

// no more than ~8 hours = 3600*8 = 28800 double 225k/array
NSUInteger MAX_FILL_POINTS = 28800;

NSString * STATS_SUM = @"sum";
NSString * STATS_CNT = @"count";
NSString * STATS_AVG = @"average";
NSString * STATS_MAX = @"max";
NSString * STATS_MIN = @"min";
NSString * STATS_STD = @"std";

NSString * STATS_SUMPOS = @"sumpos";
NSString * STATS_SUMNEG = @"sumneg";
NSString * STATS_AVGPOS = @"avgpos";
NSString * STATS_AVGNEG = @"avgneg";

NSString * STATS_WSUM = @"wsum";
NSString * STATS_WAVG =   @"weightedaverage";
NSString * STATS_WAVGPOS = @"weightedaveragepos";
NSString * STATS_WAVGNEG = @"weightedaverageneg";


gcStatsRange minRange( gcStatsRange range1, gcStatsRange range2){
    gcStatsRange range = range1;
    range.x_max = MIN(range1.x_max, range2.x_max);
    range.x_min = MAX(range1.x_min, range2.x_min);
    range.y_max = MIN(range1.y_max, range2.y_max);
    range.y_min = MAX(range1.y_min, range2.y_min);
    return range;
}


gcStatsRange maxRange( gcStatsRange range1, gcStatsRange range2){
    gcStatsRange range = range1;
    range.x_max = MAX(range1.x_max, range2.x_max);
    range.x_min = MIN(range1.x_min, range2.x_min);
    range.y_max = MAX(range1.y_max, range2.y_max);
    range.y_min = MIN(range1.y_min, range2.y_min);
    return range;
}

gcStatsRange maxRangeXOnly( gcStatsRange range1, gcStatsRange range2){
    gcStatsRange range = range1;
    range.x_max = MAX(range1.x_max, range2.x_max);
    range.x_min = MIN(range1.x_min, range2.x_min);
    return range;
}

#define GC_CODER_DATA_POINTS @"dataPoints"
#define GC_CODER_VERSION @"version"

@interface GCStatsDataSerie ()
@property (nonatomic,retain) NSMutableArray<GCStatsDataPoint*> * dataPoints;

@end

@implementation GCStatsDataSerie
@synthesize dataPoints;

+(BOOL)supportsSecureCoding{
    return YES;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [self init];
    if (self) {
        self.dataPoints = [aDecoder decodeObjectOfClasses:[NSSet setWithObjects:[NSMutableArray class], [GCStatsDataPoint class], nil] forKey:GC_CODER_DATA_POINTS];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeInt:1 forKey:GC_CODER_VERSION];
    [aCoder encodeObject:self.dataPoints forKey:GC_CODER_DATA_POINTS];
}

-(GCStatsDataSerie*)init{
    self = [super init];
    if (self) {
        self.dataPoints = [NSMutableArray arrayWithCapacity:100];
    }
    return self;
}

#if ! __has_feature(objc_arc)
-(void)dealloc{
    [dataPoints release];
    [super dealloc];
}
#endif

+(GCStatsDataSerie*)dataSerieWithPointsIn:(GCStatsDataSerie*)other{
    GCStatsDataSerie * rv = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);
    if (rv) {
        NSMutableArray * tmp = [NSMutableArray arrayWithCapacity:other.count];
        for (GCStatsDataPoint * p in other) {
            [tmp addObject:[p duplicate]];
        }
        rv.dataPoints = tmp;
    }
    return rv;

}

+(GCStatsDataSerie*)dataSerieWithPoints:(NSArray<GCStatsDataPoint*>*)points{
    GCStatsDataSerie * rv = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);
    if (rv) {
        NSMutableArray * tmp = [NSMutableArray arrayWithCapacity:points.count];
        for (GCStatsDataPoint * p in points) {
            [tmp addObject:p];
        }
        rv.dataPoints = tmp;
    }
    return rv;
}

+(GCStatsDataSerie*)dataSerieWithArrayOfDouble:(NSArray<NSNumber*>*)doubles{
    GCStatsDataSerie * rv = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);
    if (rv) {
        for (NSUInteger i=0; i+1<doubles.count; i+=2) {
            [rv addDataPointWithX:[doubles[i] doubleValue] andY:[doubles[i+1] doubleValue] ];
        }
    }
    return rv;
}

#pragma mark - Add/Remove Points

-(void)addDataPointWithDate:(NSDate*)aDate andValue:(double)value{
    [dataPoints addObject:[GCStatsDataPoint dataPointWithDate:aDate andValue:value]];
}

-(void)addDataPointWithDate:(NSDate*)aDate since:(NSDate*)first andValue:(double)value{
    [dataPoints addObject:[GCStatsDataPoint dataPointWithDate:aDate sinceDate:first andValue:value]];
}
-(void)addDataPointWithX:(double)x andY:(double)y{
    [dataPoints addObject:[GCStatsDataPoint dataPointWithX:x andY:y]];
}

-(void)addDataPointWithX:(double)x y:(double)y andZ:(double)z{
    [dataPoints addObject:[GCStatsDataPointMulti dataPointWithX:x y:y andZ:z]];
}
-(void)addDataPointNoValueWithX:(double)x{
    [dataPoints addObject:[GCStatsDataPointNoValue dataPointWithX:x andY:0.]];
}

-(void)addDataPointNoValueWithDate:(NSDate*)x{
    [dataPoints addObject:[GCStatsDataPointNoValue dataPointWithDate:x andValue:0.]];
}
-(void)addDataPointNoValueWithDate:(NSDate*)aDate since:(NSDate*)first{
    [dataPoints addObject:[GCStatsDataPointNoValue dataPointWithDate:aDate sinceDate:first andValue:0.]];
}

-(void)addDataPointWithPoint:(GCStatsDataPoint*)point andValue:(double)value{
    [dataPoints addObject:[GCStatsDataPoint dataPointWithPoint:point andValue:value]];
}

-(void)removeAllPoints{
    [dataPoints removeAllObjects];
}
-(void)removePointAtIndex:(NSUInteger)idx{
    [dataPoints removeObjectAtIndex:idx];
}

#pragma mark - Sorting

-(void)sortByDate{
    [dataPoints sortUsingComparator:^NSComparisonResult(id o1, id o2){
        double d1 = [o1 x_data];
        double d2 = [o2 x_data];

        return d1 < d2 ? NSOrderedAscending : d1 > d2 ? NSOrderedDescending : NSOrderedSame;
    }];
}

-(void)sortByReverseDate{
    [dataPoints sortUsingComparator:^NSComparisonResult(id o1, id o2){
        double d1 = [o1 x_data];
        double d2 = [o2 x_data];

        return d1 > d2 ? NSOrderedAscending : d1 < d2 ? NSOrderedDescending : NSOrderedSame;
    }];
}

-(void)sortByValue{
    [dataPoints sortUsingComparator:^NSComparisonResult(id o1, id o2){
        double d1 = [o1 y_data];
        double d2 = [o2 y_data];

        return d1 < d2 ? NSOrderedAscending : d1 > d2 ? NSOrderedDescending : NSOrderedSame;
    }];

}
-(void)sortByX{
    [dataPoints sortUsingComparator:^NSComparisonResult(id o1, id o2){
        double d1 = [o1 x_data];
        double d2 = [o2 x_data];

        return d1 < d2 ? NSOrderedAscending : d1 > d2 ? NSOrderedDescending : NSOrderedSame;
    }];
}

-(BOOL)isStrictlyIncreasingByX{
    BOOL rv = true;
    GCStatsDataPoint * last = nil;
    for( GCStatsDataPoint * point in self.dataPoints){
        if( last != nil){
            rv = point.x_data > last.x_data;
            if( ! rv){
                break;
            }
        }
        last = point;
    }
    return rv;
}

#pragma mark - Descriptions

-(NSString*)descriptionFrom:(NSUInteger)from to:(NSUInteger)to{
    NSMutableString * s = [NSMutableString stringWithFormat:@"DataSerie(%d points)[%d..%d]\n", (int)dataPoints.count, (int)from, (int)to];
    for (NSUInteger i=from; i<to; i++) {
        if (i<dataPoints.count) {
            [s appendFormat:@"  [%d]%@\n", (int)i, [dataPoints[i] description]];
        }
    }
    return s;
}


-(NSString*)description{
    NSMutableString * s = [NSMutableString stringWithFormat:@"DataSerie(%d points)\n", (int)dataPoints.count];
    if( dataPoints.count < 6){
        for (NSUInteger i=0; i<dataPoints.count; i++) {
            if (i<dataPoints.count) {
                [s appendFormat:@"  [%d]%@\n", (int)i, [dataPoints[i] description]];
            }
        }
    }else{
        NSUInteger n = dataPoints.count;
        NSUInteger indexes[] = { 0, 1, 2, n/4, n/2, 3*n/4, n-1 };
        size_t nn = sizeof(indexes)/sizeof(NSUInteger);
        for( size_t i = 0; i < nn; i++){
            NSUInteger index = indexes[i];
            // if diff with previous is > 1: non contiguous, print ellipses
            if( i > 0 && (index - indexes[i-1]) > 1 ){
                [s appendString:@"  ...\n"];
            }
            // if diff with prev is 0, index arithmetic yield same index don't print twice
            if( i == 0 || (index-indexes[i-1]) != 0){
                [s appendFormat:@"  [%d]%@\n", (int)index, [dataPoints[index] description]];
            }
        }
    }
    return s;
}
-(NSString*)descriptionAllPoints{
    NSMutableString * s = [NSMutableString stringWithFormat:@"DataSerie(%d points)\n", (int)dataPoints.count];
    for (NSUInteger i=0; i<dataPoints.count; i++) {
        [s appendFormat:@"  [%d]%@\n", (int)i, [dataPoints[i] description]];
    }
    return s;
}

-(NSString*)descriptionWithDate{
    NSMutableString * s = [NSMutableString stringWithFormat:@"DataSerie(%d points)\n", (int)dataPoints.count];
    for (NSUInteger i=0; i<5; i++) {
        if (i<dataPoints.count) {
            [s appendFormat:@"  [%d]%@\n", (int)i, [dataPoints[i] descriptionWithDate]];
        }
    }
    if (dataPoints.count>5) {
        if (dataPoints.count >6) {
            [s appendString:@"  ...\n"];
        }
        [s appendFormat:@"  [%d]%@\n", (int)(dataPoints.count-1),[dataPoints.lastObject descriptionWithDate]];
    }
    return s;
}

-(NSString*)asCSVString:(BOOL)asDate{
    BOOL hasMulti = false;
    for (GCStatsDataPoint * point in self.dataPoints) {
        if( [point isKindOfClass:[GCStatsDataPointMulti class]]){
            hasMulti = true;
            break;
        }
    }
    
    NSMutableArray * lines = [NSMutableArray array];
    
    [lines addObject:hasMulti ? @"i,x,y,z" : @"i,x,y" ];

    NSUInteger i = 0;
    for (GCStatsDataPoint * point in self.dataPoints) {
        NSMutableString * line = nil;
        if (asDate) {
            line = [NSMutableString stringWithFormat:@"%d,%@,%f", (int)i, [point.date formatAsRFC3339], point.y_data];
        }else{
            line = [NSMutableString stringWithFormat:@"%d,%f,%f", (int)i, point.x_data, point.y_data];
        }
        if( hasMulti ){
            if( [point isKindOfClass:[GCStatsDataPointMulti class]] ){
                GCStatsDataPointMulti * multi = (GCStatsDataPointMulti*)point;
                [line appendFormat:@",%f", multi.z_data];
            }else{
                [line appendFormat:@","];
            }
        }
        [lines addObject:line];
    }
    
    return [lines componentsJoinedByString:@"\n"];
}

#pragma mark - Access

-(NSUInteger)count{
    return dataPoints.count;
}

-(NSUInteger)hash{
    return self.dataPoints.hash;
}

-(BOOL)isEqual:(id)object{
    if (self == object) {
        return true;
    }else if (object && [object isKindOfClass:[self class]]){
        return [self isEqualToSerie:object];
    }else{
        return false;
    }
}
-(BOOL)isEqualToSerie:(GCStatsDataSerie*)other{
    BOOL rv = true;
    if (self.count != other.count) {
        rv = false;
    }else{
        for (NSUInteger i=0; rv && i<self.count; i++) {
            rv = rv && [[self dataPointAtIndex:i] isEqualToPoint:[other dataPointAtIndex:i]];
            if( rv == false){
                NSLog(@"%@ %@ %@", @(i), [self dataPointAtIndex:i], [other dataPointAtIndex:i]);
            }
        }
    }
    return rv;
}
-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len{
    return [self.dataPoints countByEnumeratingWithState:state objects:buffer count:len];
}

-(GCStatsDataPoint*)dataPointAtIndex:(NSUInteger)idx{
    return (GCStatsDataPoint*)dataPoints[idx];
}
-(GCStatsDataPoint*)objectAtIndexedSubscript:(NSUInteger)idx{
    return (GCStatsDataPoint*)dataPoints[idx];
}
-(GCStatsDataPoint*)lastObject{
    return (GCStatsDataPoint*)dataPoints.lastObject;
}
-(GCStatsDataPoint*)firstObject{
    return (GCStatsDataPoint*)dataPoints.firstObject;
}

/**
 Will try to find the index in the serie such that ax is within x[left] and x[right]
 If ax is an x_data in the serie, then left==right
 The search will be optimized assuming the x_data are sorted by increasing order

 @param ax the value of x to find
 @param currentIndex where to start from
 @return left,right index and
 */
-(gcStatsIndexes)indexForXVal:(double)ax from:(NSUInteger)currentIndex{
    gcStatsIndexes indexes;
    indexes.left = currentIndex;
    indexes.right = currentIndex;
    indexes.cnt = 0;
    // if only 1 point, don't bother
    if( self.dataPoints.count < 2){
        indexes.left = 0;
        indexes.right = 0;
        return indexes;
    }
    
    double curr_x = [dataPoints[indexes.left] x_data];
    // easy edge case
    NSUInteger n = dataPoints.count;
    if (fabs(curr_x-ax)<1.e-10) {
        indexes.right = indexes.left;
        return indexes;
    }

    double last_x;
    int inc = 1;
    if (ax < curr_x) {
        inc = -1;
    }
    NSInteger lasti=currentIndex;
    NSInteger i = currentIndex + inc;
    if (i < 0) {
        i = 0;
        lasti = 1;
    }else if (i == n) {
        i = n-1;
        lasti =i-1;
    }else{
        while (i!=currentIndex) {
            indexes.cnt++;
            curr_x = [dataPoints[i] x_data];
            if(ax > curr_x && inc == -1){
                break;
            }
            if (ax < curr_x && inc == 1) {
                break;
            }
            lasti=i;
            i+=inc;
            if (i < 0) {
                i = 0;
                lasti = 1;
                break;
            }else if (i == n) {
                i = n-1;
                lasti = i-1;
                break;
            }
        }
    }
    last_x = [dataPoints[lasti] x_data];
    if (fabs(curr_x-ax)<1.e-10) {
        indexes.left = i;
        indexes.right = i;
        return indexes;
    }
    if(fabs(last_x-ax)<1.e-10){
        indexes.left = lasti;
        indexes.right = lasti;
        return  indexes;
    }
    if (lasti<i) {
        indexes.left = lasti;
        indexes.right = i;
        return indexes;
    }
    indexes.left = i;
    indexes.right = lasti;
    return indexes;
}

-(gcStatsRange)range{
    gcStatsRange rv = {0.,0.,0.,0.};
    BOOL started= false;
    if (dataPoints) {
        for (GCStatsDataPoint * each in dataPoints) {
            double x = each.x_data;
            double y = each.y_data;
            if (started == false ){
                rv.x_min = x;
                rv.x_max = x;
                rv.y_max = y;
                rv.y_min = y;
                started = true;
            }else{
                if (x > rv.x_max) {
                    rv.x_max = x;
                }
                if (x < rv.x_min) {
                    rv.x_min = x;
                }
                if (y > rv.y_max) {
                    rv.y_max = y;
                }
                if (y < rv.y_min) {
                    rv.y_min = y;
                }
            }
        }
    }
    return rv;

}
-(GCStatsDataPoint*)max{
    GCStatsDataPoint * running = nil;
    for (GCStatsDataPoint * each in dataPoints) {
        if (running == nil || each.y_data > running.y_data) {
            running = each;
        }
    }
    return running;
}

-(GCStatsDataPoint*)min{
    GCStatsDataPoint * running = nil;
    for (GCStatsDataPoint * each in dataPoints) {
        if (running == nil || each.y_data < running.y_data) {
            running = each;
        }
    }
    return running;
}

#pragma mark - Filters and Reduce

-(GCStatsDataSerie*)filterForNonZeroIn:(GCStatsDataSerie*)other{
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:(self.dataPoints).count];


    for (NSUInteger i=0;i<MIN([other.dataPoints count], [self.dataPoints count]);i++){
        GCStatsDataPoint * p = (self.dataPoints)[i];
        GCStatsDataPoint * op= (other.dataPoints)[i];

        if (fabs(op.y_data) > 1e-7 ) {
            [rv addObject:p];
        }
    }
    return [GCStatsDataSerie dataSerieWithPoints:rv];

}
-(GCStatsDataSerie*)serieReducedToRange:(gcStatsRange)range{
    NSMutableArray * rvdata = [NSMutableArray arrayWithCapacity:self.dataPoints.count];
    for (GCStatsDataPoint * point in self.dataPoints) {
        if (point.x_data >= range.x_min && point.x_data <= range.x_max && point.y_data <= range.y_max && point.y_data >= range.y_min) {
            [rvdata addObject:point];
        }
    }
    return [GCStatsDataSerie dataSerieWithPoints:rvdata];
}

+(void)reduceToCommonInterval:(GCStatsDataSerie *)serie1 and:(GCStatsDataSerie *)serie2{
    NSUInteger maxSize = MAX([[serie1 dataPoints] count],[[serie2 dataPoints] count]);

    gcStatsRange range1 = serie1.range;
    gcStatsRange range2 = serie2.range;

    gcStatsRange range = minRange(range1, range2);

    NSMutableArray * rvdata1 = [NSMutableArray arrayWithCapacity:maxSize];
    NSMutableArray * rvdata2 = [NSMutableArray arrayWithCapacity:maxSize];

    for (GCStatsDataPoint * point in serie1.dataPoints) {
        if (point.x_data >= range.x_min && point.x_data <= range.x_max) {
            [rvdata1 addObject:point];
        }
    }

    for (GCStatsDataPoint * point in serie2.dataPoints) {
        if (point.x_data >= range.x_min && point.x_data <= range.x_max) {
            [rvdata2 addObject:point];
        }
    }

    serie1.dataPoints = rvdata1;
    serie2.dataPoints = rvdata2;

}

+(void)reduceToCommonRange:(GCStatsDataSerie*)serie1 and:(GCStatsDataSerie*)serie2{
    NSUInteger maxSize = MIN([[serie1 dataPoints] count],[[serie2 dataPoints] count]);

    NSMutableArray * ordered1 = [NSMutableArray arrayWithArray:serie1.dataPoints];
    NSMutableArray * ordered2 = [NSMutableArray arrayWithArray:serie2.dataPoints];

    [ordered1 sortUsingComparator:^NSComparisonResult(id o1, id o2){
        double d1 = [o1 x_data];
        double d2 = [o2 x_data];

        return d1 < d2 ? NSOrderedAscending : d1 > d2 ? NSOrderedDescending : NSOrderedSame;
    }];
    [ordered2 sortUsingComparator:^NSComparisonResult(id o1, id o2){
        double d1 = [o1 x_data];
        double d2 = [o2 x_data];

        return d1 < d2 ? NSOrderedAscending : d1 > d2 ? NSOrderedDescending : NSOrderedSame;
    }];

    NSMutableArray * rvdata1 = [NSMutableArray arrayWithCapacity:maxSize];
    NSMutableArray * rvdata2 = [NSMutableArray arrayWithCapacity:maxSize];

    NSUInteger i1 = 0;
    NSUInteger i2 = 0;

    while (i1 < ordered1.count && i2 < ordered2.count) {
        GCStatsDataPoint * point1 = ordered1[i1];
        GCStatsDataPoint * point2 = ordered2[i2];

        double x1 = point1.x_data;
        double x2 = point2.x_data;
        if (fabs(x1-x2)<1.e-7) {
            [rvdata1 addObject:point1];
            [rvdata2 addObject:point2];
            i1++;
            i2++;
        }else if (x1 < x2){
            i1++;
        }else{
            i2++;
        }
    }
    serie1.dataPoints = rvdata1;
    serie2.dataPoints = rvdata2;
}

#pragma mark - Basic Statistics

-(GCStatsDataSerie*)standardDeviation{
    NSUInteger n = dataPoints.count;
    if (n > 1) {

        double current_sum   = 0.;
        double current_sumsq = 0.;
        double current_count = 0;

        for (GCStatsDataPoint * point in dataPoints) {
            current_sum   +=point.y_data;
            current_sumsq +=point.y_data*point.y_data;
            current_count += 1;
        }
        double d_avg = current_sum/current_count;
        double d_std = STDDEV(current_count, current_sum, current_sumsq);
        GCStatsDataPoint * avg = [GCStatsDataPoint dataPointWithPoint:dataPoints[0] andValue:d_avg];
        GCStatsDataPoint * std = [GCStatsDataPoint dataPointWithPoint:dataPoints[0] andValue:d_std];

        return [GCStatsDataSerie dataSerieWithPoints:[NSMutableArray arrayWithObjects:avg,std, nil]];
    }
    return nil;
}

-(GCStatsDataSerie*)quantiles:(NSUInteger)nquantiles{
    NSMutableArray * quantiles = [NSMutableArray arrayWithCapacity:nquantiles];

    GCStatsDataSerie * dup = [GCStatsDataSerie dataSerieWithPoints:dataPoints];
    [dup sortByValue];

    if (dup.count<nquantiles || dup.count == 0) {
        return dup;
    }

    double qstep = (double)dataPoints.count/nquantiles;

    NSUInteger qidx;
    // minimum
    [quantiles addObject:dup.dataPoints[0]];
    for (qidx=1; qidx<nquantiles; qidx++) {
        NSUInteger idx = MIN(((NSUInteger)qidx*qstep)-1, dup.dataPoints.count-1) ;
        [quantiles addObject:(dup.dataPoints)[idx]];
    }
    [quantiles addObject:(dup.dataPoints).lastObject];
    return [GCStatsDataSerie dataSerieWithPoints:quantiles];
}

-(GCStatsDataSerie*)xyCumulativeValue{

    NSMutableArray * cum = [NSMutableArray arrayWithCapacity:dataPoints.count];
    double sum_y = 0.;
    double sum_x = 0.;
    for (GCStatsDataPoint * point in self.dataPoints) {
        sum_y += point.y_data;
        sum_x += point.x_data;
        [cum addObject:[GCStatsDataPoint dataPointWithX:sum_x andY:sum_y]];
    }

    GCStatsDataSerie * rv = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);
    rv.dataPoints = cum;
    return rv;

}

-(GCStatsDataSerie*)cumulativeDifferenceWith:(GCStatsDataSerie*)otherSerie{
    NSMutableArray * points = [NSMutableArray arrayWithCapacity:dataPoints.count];

    NSArray * other = otherSerie.dataPoints;
    NSUInteger i_other = 0;
    NSUInteger n_other = otherSerie.dataPoints.count;

    double minus_other = 0.;

    for (GCStatsDataPoint * point in dataPoints) {
        while( i_other < n_other && [other[i_other] x_data] <point.x_data){
            minus_other = [other[i_other] y_data];
            i_other++;
        }

        [points addObject:[GCStatsDataPoint dataPointWithX:point.x_data andY:point.y_data - minus_other]];
    }

    GCStatsDataSerie * rv = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);
    rv.dataPoints = points;
    return rv;
}

-(GCStatsDataSerie*)cumulativeValue{
    GCStatsDataSerie * dup = [GCStatsDataSerie dataSerieWithPoints:dataPoints];
    [dup sortByX];

    NSMutableArray * cum = [NSMutableArray arrayWithCapacity:dataPoints.count];
    double sum = 0.;
    for (GCStatsDataPoint * point in dup.dataPoints) {
        sum += point.y_data;
        [cum addObject:[GCStatsDataPoint dataPointWithPoint:point andValue:sum]];
    }

    GCStatsDataSerie * rv = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);
    rv.dataPoints = cum;
    return rv;
}

-(GCStatsDataSerie*)sum{
    return [self sumAndDivideByCount:NO];
}

-(GCStatsDataSerie*)average{
    return [self sumAndDivideByCount:YES];
}


-(GCStatsDataSerie*)areaForMaxDx:(double)mdx{
    NSUInteger n = dataPoints.count;
    if (n > 2) {

        double current_area   = 0.;
        double total_x        = 0.;
        double max_y          = 0.;

        for (NSUInteger i=0;i<n-1;i++) {
            GCStatsDataPoint * cur = dataPoints[i];
            GCStatsDataPoint * next= dataPoints[i+1];
            double dx = next.x_data-cur.x_data;
            if (mdx>0.) {
                dx = MIN(mdx, dx);
            }
            total_x += dx;
            current_area +=cur.y_data * dx;
            max_y = MAX(cur.y_data, max_y);
        }
        GCStatsDataPoint * area = [GCStatsDataPoint dataPointWithPoint:dataPoints[0] andValue:current_area];
        GCStatsDataPoint * totx = [GCStatsDataPoint dataPointWithPoint:dataPoints[0] andValue:total_x];
        GCStatsDataPoint * maxy = [GCStatsDataPoint dataPointWithPoint:dataPoints[0] andValue:max_y];

        return [GCStatsDataSerie dataSerieWithPoints:[NSMutableArray arrayWithObjects:area, totx, maxy, nil]];
    }
    return nil;
}

-(NSDictionary<NSString*,NSNumber*>*)summaryStatistics{
    double sum  = 0.;
    double cnt  = 0.;
    double max  = 0.;
    double min  = 0.;

    double wsum = 0.;
    double wgt  = 0.;

    double sumpos = 0.;
    double sumneg = 0.;
    double wsumpos = 0.;
    double wsumneg = 0.;

    double cntpos = 0.;
    double cntneg = 0.;
    double wgtpos = 0.;
    double wgtneg = 0.;

    BOOL first = true;

    BOOL hasPos = false;
    BOOL hasNeg = false;

    NSUInteger count = dataPoints.count;
    for (NSUInteger idx = 0; idx < count; idx++) {
        GCStatsDataPoint * point = dataPoints[idx];

        if( !point.hasValue ){
            continue;
        }
        
        BOOL isPos = point.y_data > 0;
        BOOL isNeg = point.y_data < 0;

        sum += point.y_data;
        cnt += 1.;

        if (idx+1<count) {
            GCStatsDataPoint * next = dataPoints[idx+1];
            double dx = next.x_data-point.x_data;
            wsum += (point.y_data*dx);
            wgt  += dx;

            if (isPos) {
                wsumpos += point.y_data*dx;
                wgtpos += dx;
            }
            if (isNeg) {
                wsumneg += point.y_data*dx;
                wgtneg += dx;
            }
        }

        if (isPos) {
            hasPos = true;
            sumpos += point.y_data;
            cntpos += 1.;
        }
        if (isNeg) {
            hasNeg = true;
            sumneg += point.y_data;
            cntneg += 1.;
        }

        if (first) {
            max = point.y_data;
            min = point.y_data;
            first = false;
        }else{
            max = MAX(max, point.y_data);
            min = MIN(min, point.y_data);
        }
    }

    NSMutableDictionary<NSString*,NSNumber*> * rv = [NSMutableDictionary dictionaryWithDictionary:@{
             STATS_SUM: @(sum),
             STATS_CNT: @(cnt),
             STATS_AVG: @(sum/cnt),
             STATS_MAX: @(max),
             STATS_MIN: @(min),



             STATS_WSUM: @(wsum),
             STATS_WAVG:   @(wsum/wgt),

             }];
    if (hasPos) {
        NSDictionary<NSString*,NSNumber*> * pos = @{
                               STATS_SUMPOS: @(sumpos),
                               STATS_AVGPOS: @(sumpos/cntpos),
                               STATS_WAVGPOS: @(wsumpos/wgtpos)

                               };
        [rv addEntriesFromDictionary:pos];
    }
    if (hasNeg) {
        NSDictionary<NSString*,NSNumber*> * neg = @{
                               STATS_SUMNEG: @(sumneg),
                               STATS_AVGNEG: @(sumneg/cntneg),
                               STATS_WAVGNEG: @(wsumneg/wgtneg),

                               };
        [rv addEntriesFromDictionary:neg];
    }
    return rv;
}

-(GCStatsDataSerie*)sumAndDivideByCount:(BOOL)divide{

    NSMutableArray * averages = [NSMutableArray arrayWithCapacity:1];

    NSUInteger n = dataPoints.count;
    if (n > 0) {

        GCStatsDataPoint * current_sum = [GCStatsDataPoint dataPointWithPoint:dataPoints[0] andValue:0.];
        double current_count = 0;

        for (GCStatsDataPoint * point in self.dataPoints) {
            if( point.hasValue ){
                [current_sum addPoint:point];
                current_count += 1;
            }
        }
        if (divide) {
            [current_sum divideByDouble:current_count];
        }
        [averages addObject:current_sum];
    }
    return [GCStatsDataSerie dataSerieWithPoints:averages];
}

-(GCStatsLinearFunction*)regression{
    GCStatsLinearFunction * rv = nil;

    if (dataPoints.count > 0) {

        double
        s_x = 0.,
        s_y = 0.,
        s_xx = 0.,
        s_xy = 0.,
        s_yy = 0.,
        n    = 0.;

        for (GCStatsDataPoint * point in dataPoints) {
            if( ! point.hasValue ){
                continue;
            }
            
            double x = point.x_data;
            double y = point.y_data;
            if (isinf(x)||isinf(y)||isnan(x)||isnan(y)) {
                continue;
            }
            n += 1.;
            s_x += x;
            s_y += y;
            s_xx += x*x;
            s_yy += y*y;
            s_xy += x*y;
        }
        double beta = n==1. || n*s_xx-s_x*s_x == 0. ? 0. : (n*s_xy - (s_x*s_y))/(n*s_xx-s_x*s_x);
        double alpha = beta == 0. ? s_y/n : (s_y/n) - (beta/n*s_x);

        rv = [GCStatsLinearFunction linearFunctionWithAlpha:alpha andBeta:beta];
    }
    return rv;
}

#pragma mark - Processes Series

//  --x-x-x-x--x--x----xx------x
//   [--dx--|
//      [--dx--|
//         [--dx--|
//              [--dx--|
//               [--dx--|
//                      [--dx--|
//   idx_offset: [
//   idx_this:   |

-(GCStatsDataSerie*)deltaYSerieForDeltaX:(double)dx scalingFactor:(double)scaling simpleDifference:(BOOL)diffOnly{
    NSUInteger count = self.count;

    // Needs at least 2 points
    if (count < 2) {
        return nil;
    }

    GCStatsDataSerie * this = [GCStatsDataSerie dataSerieWithPoints:self.dataPoints];

    [this sortByX];

    NSMutableArray * rv_points = [NSMutableArray arrayWithCapacity:dataPoints.count];

    NSUInteger idx_x1 = 0;
    NSUInteger idx_x0 = 0;

    BOOL started = false;

    GCStatsDataPoint * p_x0 = this.dataPoints[idx_x0];

    for (idx_x1=1; idx_x1<count; idx_x1++) {
        GCStatsDataPoint * p_x1 = this.dataPoints[idx_x1];
                
        if( dx == 0. || p_x1.x_data - this.dataPoints[idx_x0+1].x_data <= dx){
            started = true;
        }
        
        while (idx_x0 < idx_x1 && (p_x1.x_data - this.dataPoints[idx_x0+1].x_data) > dx ) {
            idx_x0++;
            p_x0 = this.dataPoints[idx_x0];
        }

        if (started && idx_x0!=idx_x1) {
            double delta_y = p_x1.y_data-p_x0.y_data;
            double delta_x = p_x1.x_data-p_x0.x_data;

            double final = diffOnly ? delta_y : delta_y/delta_x * scaling;
            [rv_points addObject:[GCStatsDataPoint dataPointWithX:p_x1.x_data andY:final]];
        }
    }
    GCStatsDataSerie * rv = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);
    rv.dataPoints = rv_points;
    return rv;
}
-(GCStatsDataSerie*)deltaYSerieForDeltaX:(double)dx scalingFactor:(double)scaling{
    return [self deltaYSerieForDeltaX:dx scalingFactor:scaling simpleDifference:NO];
}
-(GCStatsDataSerie*)differenceSerieForLag:(double)dx{
    return [self deltaYSerieForDeltaX:dx scalingFactor:1.0 simpleDifference:YES];
}

//  --x-x-x-x--x--x----xx------x
//  --------y------------y-----y
//  [-------|
//               [-------|
//                     [-------|

-(GCStatsDataSerie*)movingAverageOrSumOf:(GCStatsDataSerie*)rawother forUnit:(double)unit offset:(double)offset average:(BOOL)avg{
    GCStatsDataSerie * this = [GCStatsDataSerie dataSerieWithPoints:self.dataPoints];
    GCStatsDataSerie * other = [GCStatsDataSerie dataSerieWithPoints:rawother.dataPoints];

    [this sortByX];
    [other sortByX];

    NSMutableArray * samples = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray * rv_points = [NSMutableArray arrayWithCapacity:dataPoints.count];

    NSArray * p_this = this.dataPoints;
    NSArray * p_other= other.dataPoints;

    double runningSum = 0.;

    NSUInteger idx_this = 0;
    NSUInteger idx_other= 0;
    NSUInteger idx_sample=0;

    while (idx_this < this.count) {
        GCStatsDataPoint * point = p_this[idx_this++];
        if( point.hasValue ){
            double x_to = point.x_data-offset;
            double x_from = x_to-unit;
            for (idx_sample=0; idx_sample<samples.count; idx_sample++) {
                GCStatsDataPoint * sample = samples[idx_sample];
                if (sample.x_data < x_from) {
                    runningSum -= sample.y_data;
                }else{
                    break;
                }
            }
            [samples removeObjectsInRange:NSMakeRange(0, idx_sample)];
            for (; idx_other<p_other.count; idx_other++) {
                GCStatsDataPoint * one = p_other[idx_other];
                if (one.x_data<x_from) {
                    continue;
                }else if (one.x_data <= x_to) {
                    [samples addObject:one];
                    runningSum += one.y_data;
                }else{
                    break;
                }
            }
            [rv_points addObject:[GCStatsDataPoint dataPointWithPoint:point
                                                             andValue:avg&&samples.count!=0.?runningSum/samples.count:runningSum]];
        }
    }
    GCStatsDataSerie * rv = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);
    rv.dataPoints = rv_points;
    return rv;

}

-(GCStatsDataSerie*)movingFunctionForUnit:(double)unit function:(double(^)(NSArray<GCStatsDataPoint*>*))fct{

    GCStatsDataSerie * dup = [GCStatsDataSerie dataSerieWithPoints:dataPoints];
    [dup sortByX];
    if (fabs(unit)<1.e-8) { // 1 or 0 = same serie
        return dup;
    }

    NSMutableArray * samples = [NSMutableArray arrayWithCapacity:dataPoints.count];
    NSMutableArray * smoothed = [NSMutableArray arrayWithCapacity:dataPoints.count];
    
    for (GCStatsDataPoint * point in dup.dataPoints) {
        // remove point if out of range
        double left_x = point.x_data - unit;
        NSUInteger i=0;
        for (i=0; i<samples.count; i++) {
            GCStatsDataPoint * sample = samples[i];
            if (sample.x_data >= left_x ) {
                break;
            }
        }
        [samples removeObjectsInRange:NSMakeRange(0, i)];
        [samples addObject:point];
        double value = fct(samples);

        [smoothed addObject:[GCStatsDataPoint dataPointWithPoint:point andValue:value]];
    }

    GCStatsDataSerie * rv = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);
    rv.dataPoints = smoothed;
    return rv;
}


-(GCStatsDataSerie*)movingAverageOrSumForUnit:(double)unit average:(BOOL)avg{

    GCStatsDataSerie * dup = [GCStatsDataSerie dataSerieWithPoints:dataPoints];
    [dup sortByX];
    if (fabs(unit)<1.e-8) { // 1 or 0 = same serie
        return dup;
    }

    NSMutableArray * samples = [NSMutableArray arrayWithCapacity:10];

    NSMutableArray * smoothed = [NSMutableArray arrayWithCapacity:dataPoints.count];
    double runningSum = 0.;

    for (GCStatsDataPoint * point in dup.dataPoints) {
        // remove point if out of range
        double left_x = point.x_data - unit;
        NSUInteger i=0;
        for (i=0; i<samples.count; i++) {
            GCStatsDataPoint * sample = samples[i];
            if (sample.x_data < left_x ) {
                runningSum -= sample.y_data;
            }else{
                break;
            }
        }
        [samples removeObjectsInRange:NSMakeRange(0, i)];
        [samples addObject:point];
        runningSum += point.y_data;

        [smoothed addObject:[GCStatsDataPoint dataPointWithPoint:point andValue:avg?runningSum/samples.count:runningSum]];
    }

    GCStatsDataSerie * rv = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);
    rv.dataPoints = smoothed;
    return rv;
}

-(GCStatsDataSerie*)movingAverageForUnit:(double)unit{
    return [self movingAverageOrSumForUnit:unit average:true];
}

-(GCStatsDataSerie*)movingSumForUnit:(double)unit{
    return [self movingAverageOrSumForUnit:unit average:false];
}

-(GCStatsDataSerie*)movingAverage:(NSUInteger)nSamples{

    GCStatsDataSerie * dup = [GCStatsDataSerie dataSerieWithPoints:dataPoints];
    [dup sortByX];
    if (nSamples<2) { // 1 or 0 = same serie
        return dup;
    }

    double * samples = calloc(nSamples,sizeof(double));

    size_t sample_idx = 0;
    size_t n = 0;

    NSMutableArray * smoothed = [NSMutableArray arrayWithCapacity:dataPoints.count];
    double runningSum = 0.;

    for (GCStatsDataPoint * point in dup.dataPoints) {
        double y = point.y_data;
        if (n < nSamples) {
            n++;
            samples[sample_idx++] = y;
            runningSum += y;
        }else{
            runningSum += y-samples[sample_idx];
            samples[sample_idx]=y;
            sample_idx++;
            [smoothed addObject:[GCStatsDataPoint dataPointWithPoint:point andValue:(runningSum/nSamples)]];
        }

        if (sample_idx == nSamples) {
            sample_idx = 0;
        }
    }

    free(samples);
    GCStatsDataSerie * rv = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);
    rv.dataPoints = smoothed;
    return rv;
}

#pragma mark - Buckets and Histograms
/**
 Will generate a series with x on multiples of xInt, with the number of point between x,x+xInt

 @param xInt size of the bucket
 @param xMax maximum x to look at
 @return the new serie
 */
-(GCStatsDataSerie*)countByXInterval:(double)xInt xMax:(double)xMax{
    GCStatsDataSerie *  rv = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);

    BOOL started = false;
    double next_x = 0.;

    NSUInteger count_int = 0;

    for (GCStatsDataPoint * point in self.dataPoints) {
        if (isnan(point.x_data)||isinf(point.x_data)) {
            RZLog(RZLogError, @"Inf X data");
        }
        if (!started) {
            started = true;
            next_x = point.x_data+xInt;
        }else{
            if (point.x_data > next_x) {
                [rv addDataPointWithX:next_x-xInt andY:count_int];
                int k = (point.x_data-next_x)/xInt;
                next_x+=xInt*(k+1);
                count_int = 0;
            }
        }
        if (next_x>xMax) {
            break;
        }
        count_int++;
    }
    if (count_int>0) {
        [rv addDataPointWithX:next_x-xInt andY:count_int];
    }
    return rv;
}

-(GCStatsDataSerie*)bucketWith:(GCStatsDataSerie*)buckets{
    GCStatsDataSerie * rv = nil;

    BOOL increasing = true;
    GCStatsDataPoint * last = nil;
    for (GCStatsDataPoint * point in buckets.dataPoints) {
        if (last) {
            if (last.x_data > point.x_data || last.y_data > point.y_data) {
                increasing = false;
            }
        }
        last = point;
    }
    if (increasing) {
        rv = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);
        // init
        for (GCStatsDataPoint * point in buckets.dataPoints) {
            [rv addDataPointWithX:point.x_data andY:0.];
        }
        last = nil;
        NSUInteger nbuckets = (buckets.dataPoints).count;
        NSUInteger i = 0;
        for (GCStatsDataPoint * point in self.dataPoints) {
            if (last) {
                for (i=0; i<nbuckets; i++) {
                    GCStatsDataPoint * bucket = (buckets.dataPoints)[i];
                    if (bucket.y_data > last.y_data) {
                        NSUInteger idx = i>0 ? i-1 : i;
                        GCStatsDataPoint * record = (rv.dataPoints)[idx];
                        record.y_data += point.x_data - last.x_data;
                        //NSLog(@"SER %f adds %f to [%d]=%f Bucket[%d]=%f", last.y_data, point.x_data-last.x_data, (int)idx, record.y_data, (int)i, bucket.y_data);
                        break;
                    }
                }
                if (i==nbuckets && i > 0) {
                    GCStatsDataPoint * record = (rv.dataPoints)[i-1];
                    record.y_data += point.x_data - last.x_data;
                }
            }
            last = point;
        }
    }else{
        RZLog(RZLogError, @"Non increasing bucket serie");
    }
    return rv;
}

/**
 This will rebucket a serie, but assumes the buckets are a subset of current series' buckets
 and that the y are summed for collapsed buckets

 @param buckets serie of buckets (Xs must be subset of serie's Xs)
 @return new serie or nil of sub buckets are incompatible
 */
-(GCStatsDataSerie*)rebucket:(GCStatsDataSerie*)buckets{

    GCStatsDataSerie * rv = nil;

    if (buckets.count < 2) {
        return rv;
    }

    rv = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);
    // init
    for (GCStatsDataPoint * point in buckets.dataPoints) {
        [rv addDataPointWithX:point.x_data andY:0.];
    }

    NSUInteger i_newBuckets = 0;
    GCStatsDataPoint * last = rv[i_newBuckets];
    double next_x = buckets[i_newBuckets+1].x_data; //buckets.count >= 2

    for (GCStatsDataPoint * point in self) {
        if( point.x_data < next_x){
            last.y_data += point.y_data;
        }else{
            if (i_newBuckets + 1 < rv.count) {
                i_newBuckets++;
                last = rv[i_newBuckets];
                last.y_data += point.y_data;
                if (i_newBuckets+1<buckets.count) {
                    next_x = buckets[i_newBuckets+1].x_data;
                }else{
                    next_x = self.lastObject.x_data + 1.0; // + 1 so always further than any point
                }

            }
        }
    }
    return rv;

}

/**
 Generate a serie for which x are bcukets spaning Ys with size spacing * k such that number of bucket is less than maxBucket

 @param spacing the width of the bucket,
 @param maxBuckets the maximum number of buckets.
 @return a new histogram serie
 */
-(GCStatsDataSerie*)histogramOfXSumWithYBucketSize:(double)spacing andMaxBuckets:(NSUInteger)maxBuckets{
    if( fabs(spacing) < 1.e-10){
        return nil; // need to divide by non null
    }
    [self sortByX];
    gcStatsRange range = [self range];

    double a = 0.0;
    double bucketSize = spacing;

    double firstBucket = floor((range.y_min-a)/bucketSize)*bucketSize+a;
    double lastBucket = ceil((range.y_max-a)/bucketSize)*bucketSize+a;

    double numberOfBuckets = (lastBucket  - firstBucket)/bucketSize;
    while( numberOfBuckets > maxBuckets){
        bucketSize+=spacing;
        firstBucket = floor((range.y_min-a)/bucketSize)*bucketSize+a;
        lastBucket = ceil((range.y_max-a)/bucketSize)*bucketSize+a;
        numberOfBuckets = (lastBucket  - firstBucket)/bucketSize;
    }

    double * values  = calloc(numberOfBuckets, sizeof(double));

    for (NSUInteger i=0; i<(self.dataPoints).count-1; i++) {
        GCStatsDataPoint * point = (self.dataPoints)[i];
        GCStatsDataPoint * next  = [self.dataPoints objectAtIndex:i+1];
        double sum = next.x_data - point.x_data;

        size_t idx = floor((point.y_data-firstBucket)/bucketSize);
        if (idx<numberOfBuckets) {
            values[idx] += sum;
        }
    }

    GCStatsDataSerie * rv = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);
    for (size_t n=0; n<numberOfBuckets; n++) {
        [rv addDataPointWithX:firstBucket+n*bucketSize andY:values[n]];
    }

    free(values);
    return rv;

}


-(GCStatsDataSerie*)histogramWith:(NSUInteger)buckets{
    if (self.dataPoints.count < 2 || buckets < 1) {
        return nil;
    }
    [self sortByDate];

    gcStatsRange range = [self range];
    double fullRange = range.y_max-range.y_min;
    double bucketSize = fullRange/buckets;

    double * values  = calloc(buckets, sizeof(double));

    for (NSUInteger i=0; i<(self.dataPoints).count-1; i++) {
        GCStatsDataPoint * point = (self.dataPoints)[i];
        //GCStatsDataPoint * next  = [self.dataPoints objectAtIndex:i+1];
        // other aggregation based on next.x - point.x??

        size_t idx = (point.y_data-range.y_min)/bucketSize;
        if (idx<buckets) {
            values[idx] += 1.;
        }
    }

    GCStatsDataSerie * rv = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);
    for (size_t n=0; n<buckets; n++) {
        [rv addDataPointWithX:range.y_min+n*bucketSize andY:values[n]];
    }

    free(values);
    return rv;
}

#pragma mark - Statistics Series


-(NSDictionary*)xyCumulativeRescaledByCalendarUnit:(NSCalendarUnit)aUnit inTimeSerie:(GCStatsDataSerie*)timeSerie withCalendar:(NSCalendar*)cal{
    NSMutableDictionary * rv = [NSMutableDictionary dictionaryWithCapacity:10];
    if ((self.dataPoints).count != (timeSerie.dataPoints).count) {
        // Need to be same size
        return nil;
    }

    NSUInteger n = (self.dataPoints).count;

    BOOL merged = NO;

    if (n > 0) {
        NSDate * start;
        NSTimeInterval extends;

        NSDate * first = [(timeSerie.dataPoints)[0] date];

        for (NSUInteger i = 0;i<n;i++) {
            GCStatsDataPoint * point     = (self.dataPoints)[i];
            GCStatsDataPoint * timePoint = (timeSerie.dataPoints)[i];

            NSDate * thisdate = [timePoint date];
            [cal rangeOfUnit:aUnit startDate:&start interval:&extends forDate:thisdate];
            NSDate * key = merged ? first : start;
            GCStatsDataSerie * serie = rv[key];
            if (!serie) {
                serie = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);
                rv[key] = serie;
            }
            [serie addDataPointWithX:point.x_data andY:point.y_data];
        }
        NSMutableDictionary * final = [NSMutableDictionary dictionaryWithCapacity:10];

        for (NSDate * key in rv) {
            GCStatsDataSerie * serie = rv[key];
            final[key] = [serie xyCumulativeValue];
        }
        rv = final;
    }
    return rv;
}

-(NSDictionary*)rescaleWithinCalendarUnit:(NSCalendarUnit)aUnit merged:(BOOL)merged referenceDate:(NSDate*)refOrNil andCalendar:(NSCalendar*)cal{
    NSMutableDictionary * rv = [NSMutableDictionary dictionaryWithCapacity:10];
    GCStatsDataSerie * serie = [GCStatsDataSerie dataSerieWithPoints:dataPoints];
    [serie sortByDate];

    NSMutableArray * sortedDataPoints = serie.dataPoints;

    GCStatsDateBuckets * bucketer = [GCStatsDateBuckets statsDateBucketFor:aUnit referenceDate:refOrNil andCalendar:cal];

    NSUInteger n = [serie count];

    if (n > 0) {
        NSDate * start = nil;
        NSDate * first = [sortedDataPoints[0] date];

        for (GCStatsDataPoint * point in sortedDataPoints) {
            NSDate * thisdate = [point date];
            [bucketer bucket:thisdate];
            start = bucketer.bucketStart;
            NSTimeInterval x = [thisdate timeIntervalSinceDate:start];
            NSDate * key = merged ? first : start;
            serie = rv[key];
            if (!serie) {
                serie = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);
                rv[key] = serie;
            }
            [serie addDataPointWithX:x andY:point.y_data];
        }
    }
    return rv;
}

-(GCStatsDataSerie*)closeIntervalsForCalendarUnit:(NSCalendarUnit)calunit
                                calendar:(NSCalendar*)cal
                               afterDate:(NSDate*)afterdate{
    NSMutableArray * adjusted = [NSMutableArray arrayWithCapacity:self.count];

    NSDateComponents * oneUnit = [NSDateComponents dateComponentsForCalendarUnit:calunit withValue:1];

    // bottom of the gcGraphStep is 0 or min
    double plot_y_min = 0.;
    if (true) {
        gcStatsRange range = [self range];
        plot_y_min = range.y_min;
    }

    NSDate * lastdate = nil;
    NSDate * next     = nil;
    for (GCStatsDataPoint * point in self) {
        if (afterdate && [point.date compare:afterdate] == NSOrderedAscending) {
            continue;
        }
        if (lastdate) {
            // if next < pointdate as in:
            // |----------|-----------|-------|---
            // lastdate   next        next    pointdate
            // fill with no value for next and move lastdate to next
            //
            // until
            // |----------|-------------|---
            // lastdate   pointdate     next
            // move lastdate to pointdate
            next = [cal dateByAddingComponents:oneUnit toDate:lastdate options:0];

            if ([next compareCalendarDay:[point date] include:NO calendar:cal] == NSOrderedAscending){
                do {
                    [adjusted addObject:[GCStatsDataPointNoValue dataPointWithDate:next andValue:plot_y_min]];
                    next = [cal dateByAddingComponents:oneUnit toDate:next options:0];
                } while ([next compareCalendarDay:[point date] include:NO calendar:cal] == NSOrderedAscending);
            }

            lastdate = [point date];

        }else{
            lastdate = [point date];
        }
        [adjusted addObject:point];
    }
    // add space for last point
    if (lastdate) {
        next = [cal dateByAddingComponents:oneUnit toDate:lastdate options:0];
        [adjusted addObject:[GCStatsDataPointNoValue dataPointWithDate:next andValue:plot_y_min]];
    }
    return [GCStatsDataSerie dataSerieWithPoints:adjusted];
}


-(NSDictionary*)aggregatedStatsByCalendarUnit:(NSCalendarUnit)aUnit referenceDate:(NSDate*)refOrNil andCalendar:(NSCalendar*)cal{

    NSMutableArray * r_avg = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray * r_max = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray * r_std = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray * r_min = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray * r_sum = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray * r_cnt = [NSMutableArray arrayWithCapacity:10];

    GCStatsDataSerie * serie = [GCStatsDataSerie dataSerieWithPoints:dataPoints];
    [serie sortByDate];
    NSMutableArray * sortedDataPoints = serie.dataPoints;

    NSUInteger idx = 0;
    NSUInteger n = [serie count];

    GCStatsDateBuckets * bucketer = [GCStatsDateBuckets statsDateBucketFor:aUnit referenceDate:refOrNil andCalendar:cal];

    if (n > 0) {
        NSDate * thisdate = [sortedDataPoints[0] date];

        [bucketer bucket:thisdate];
        NSDate * recordDate = bucketer.bucketStart;

        GCStatsDataPoint * current_sum = [GCStatsDataPoint dataPointWithDate:recordDate andValue:0.];
        GCStatsDataPoint * current_avg = [GCStatsDataPoint dataPointWithDate:recordDate andValue:0.];
        GCStatsDataPoint * current_cnt = [GCStatsDataPoint dataPointWithDate:recordDate andValue:0.];
        GCStatsDataPoint * current_std = [GCStatsDataPoint dataPointWithDate:recordDate andValue:0.];
        GCStatsDataPoint * current_ssq = [GCStatsDataPoint dataPointWithDate:recordDate andValue:0.];
        GCStatsDataPoint * current_max = [GCStatsDataPoint dataPointWithDate:recordDate andValue:[dataPoints[0] y_data]];
        GCStatsDataPoint * current_min = [GCStatsDataPoint dataPointWithDate:recordDate andValue:[dataPoints[0] y_data]];

        GCStatsDataPoint * point = nil;
        double y_data = 0.;

        for (idx=0; idx<n; idx++) {
            point    = sortedDataPoints[idx];
            thisdate = [point date];
            y_data   = point.y_data;

            BOOL changed = [bucketer bucket:thisdate];

            if (changed) {
                current_avg.y_data = current_sum.y_data/current_cnt.y_data;
                current_std.y_data = STDDEV(current_cnt.y_data, current_sum.y_data, current_ssq.y_data);
                [r_sum addObject:current_sum];
                [r_std addObject:current_std];
                [r_avg addObject:current_avg];
                [r_cnt addObject:current_cnt];
                [r_max addObject:current_max];
                [r_min addObject:current_min];

                recordDate = bucketer.bucketStart;
                current_sum = [GCStatsDataPoint dataPointWithDate:recordDate andValue:0.];
                current_ssq = [GCStatsDataPoint dataPointWithDate:recordDate andValue:0.];
                current_std = [GCStatsDataPoint dataPointWithDate:recordDate andValue:0.];
                current_avg = [GCStatsDataPoint dataPointWithDate:recordDate andValue:0.];
                current_cnt = [GCStatsDataPoint dataPointWithDate:recordDate andValue:0.];
                current_max = [GCStatsDataPoint dataPointWithDate:recordDate andValue:point.y_data];
                current_min = [GCStatsDataPoint dataPointWithDate:recordDate andValue:point.y_data];
            }

            current_sum.y_data += y_data;
            current_ssq.y_data += y_data*y_data;
            current_cnt.y_data += 1.;
            current_max.y_data = MAX(current_max.y_data, y_data);
            current_min.y_data = MIN(current_min.y_data, y_data);
        }

        if (current_cnt.y_data>0) { //last one to record
            current_avg.y_data = current_sum.y_data/current_cnt.y_data;
            current_std.y_data = STDDEV(current_cnt.y_data, current_sum.y_data, current_ssq.y_data);
            [r_sum addObject:current_sum];
            [r_std addObject:current_std];
            [r_avg addObject:current_avg];
            [r_cnt addObject:current_cnt];
            [r_max addObject:current_max];
            [r_min addObject:current_min];
        }
    }

    return @{STATS_SUM: [GCStatsDataSerie dataSerieWithPoints:r_sum],
                STATS_CNT: [GCStatsDataSerie dataSerieWithPoints:r_cnt],
                STATS_AVG: [GCStatsDataSerie dataSerieWithPoints:r_avg],
                STATS_MAX: [GCStatsDataSerie dataSerieWithPoints:r_max],
                STATS_MIN: [GCStatsDataSerie dataSerieWithPoints:r_min],
                STATS_STD: [GCStatsDataSerie dataSerieWithPoints:r_std]};
}


-(GCStatsDataSerie*)normalizedSerie:(double)avg std:(double)std{

    GCStatsDataSerie * rv = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);
    for (GCStatsDataPoint * p in self.dataPoints) {
        [rv addDataPointWithX:p.x_data andY:(p.y_data-avg)/std];
    }
    return rv;
}


-(void)fill:(size_t)range valuesForUnit:(double)unit into:(double*)values firstx:(double*)firstx{
    NSUInteger n = (self.dataPoints).count;
    if( n < 2){
        return;
    }
    
    GCStatsDataPoint * first_p = self.dataPoints.firstObject;
    double first_x  = unit * (int)(first_p.x_data/unit);
    if( firstx ){
        *firstx = first_x;
    }
    NSUInteger p_idx = 0;
    GCStatsDataPoint * from_p = self.dataPoints[p_idx];
    GCStatsDataPoint * to_p = p_idx + 1 < n ? self.dataPoints[p_idx+1] : nil;
    
    for(size_t v_idx = 0; v_idx < range; v_idx++){
        double v_x = first_x + unit*v_idx;
        // Find the two index of point with value surrounding v_x
        while( to_p != nil && to_p.x_data < v_x){
            do {
                p_idx ++;
                if( p_idx < n && self.dataPoints[p_idx].hasValue){
                    from_p =  self.dataPoints[p_idx] ;
                }
            } while (p_idx < n && !self.dataPoints[p_idx].hasValue );
            NSUInteger n_idx = p_idx;
            do {
                n_idx++;
                to_p = n_idx < n ? self.dataPoints[n_idx] : nil;
            } while (to_p && !to_p.hasValue);
        }
        // If we have next point and x_data are not equal (otherwise div by 0...)
        // If multiple points with the same x (x_data equal), then the
        // value from the last from_p will be used. Not bad choice, for example
        // if many point at 0 distance with different times, then use the last one
        if( to_p && fabs(to_p.x_data - from_p.x_data) > 1.e-10){
            values[v_idx] = from_p.y_data + (to_p.y_data-from_p.y_data)*(v_x-from_p.x_data)/(to_p.x_data-from_p.x_data);
        }else{
            values[v_idx] = from_p.y_data;
        }
    }
}

-(GCStatsDataSerie*)filledSerieForUnit:(double)unit{
    if (self.dataPoints.count < 2) {
        return nil;
    }
    [self sortByDate];

    GCStatsDataPoint * first_p = (self.dataPoints)[0];
    GCStatsDataPoint * last_p  = (self.dataPoints).lastObject;

    size_t range = ((last_p.x_data - first_p.x_data)/unit)+1;
    range  = MIN(range, MAX_FILL_POINTS); // no more than ~8 hours = 3600*8 = 28800 double 225k/array

    double * values  = calloc(range, sizeof(double));
    double first_x = 0.;
    [self fill:range valuesForUnit:unit into:values firstx:&first_x];
    GCStatsDataSerie * rv = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);
    for (size_t n=0; n<range; n++) {
        [rv addDataPointWithX:first_x+unit*n andY:values[n]];
    }

    free(values);

    return rv;
}

-(GCStatsDataSerie*)summedSerieByUnit:(double)unit fillMethod:(gcStatsFillMethod)fill{
    if (self.dataPoints.count < 2) {
        return nil;
    }
    [self sortByDate];

    GCStatsDataPoint * first_p = (self.dataPoints)[0];
    GCStatsDataPoint * last_p  = (self.dataPoints).lastObject;

    size_t range = ((last_p.x_data - first_p.x_data)/unit)+1;
    range  = MIN(range, MAX_FILL_POINTS); // no more than ~8 hours = 3600*8 = 28800 double 225k/array

    double * values  = calloc(range, sizeof(double));

    GCStatsDataSerie * rv = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);

    double first_x  = first_p.x_data;

    NSUInteger n = (self.dataPoints).count;

    for (NSUInteger idx_p = 0;idx_p < n;idx_p++) {
        GCStatsDataPoint * from_p = (self.dataPoints)[idx_p];

        double from_x  = from_p.x_data-first_x;

        size_t from_i = MIN(from_x/unit,MAX_FILL_POINTS-1);

        values[from_i] += from_p.y_data;

    }
    for (size_t i=0; i<range; i++) {
        if (values[i]!=0.) {
            [rv addDataPointWithX:first_p.x_data+unit*i andY:values[i]];
        }else{
            [rv addDataPointNoValueWithX:first_p.x_data+unit*i];
        }
    }

    free(values);

    return rv;
}


-(GCStatsDataSerie*)serieWithCutOff:(NSDate*)cutOff
                           withUnit:(NSCalendarUnit)aUnit
                      referenceDate:(NSDate*)refOrNil
                        andCalendar:(NSCalendar*)calendar{
    GCStatsDateBuckets * bucketer = [GCStatsDateBuckets statsDateBucketFor:aUnit
                                                             referenceDate:refOrNil
                                                               andCalendar:calendar];

    [bucketer bucket:cutOff];
    NSTimeInterval cutOffInterval = [cutOff timeIntervalSinceDate:bucketer.bucketStart];

    GCStatsDataSerie * rv = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);

    for (GCStatsDataPoint * point in self.dataPoints) {
        [bucketer bucket:point.date];
        if ([point.date timeIntervalSinceDate:bucketer.bucketStart] <= cutOffInterval) {
            [rv.dataPoints addObject:point];
        }
    }

    return rv;
}

-(GCStatsDataSerie*)movingBestByUnitOf:(double)unit fillMethod:(gcStatsFillMethod)fill select:(gcStatsSelection)select statistic:(gcStats)statistic{
    return [self movingBestByUnitOf:unit fillMethod:fill select:select statistic:statistic fillStatistics:statistic];
}

-(GCStatsDataSerie*)movingBestByUnitOf:(double)unit
                            fillMethod:(gcStatsFillMethod)fill
                                select:(gcStatsSelection)select
                             statistic:(gcStats)statistic
                        fillStatistics:(gcStats)fillStatistic{


    if (self.dataPoints.count < 2) {
        return nil;
    }
    [self sortByDate];

    GCStatsDataPoint * first_p = (self.dataPoints)[0];
    size_t first_x_i = first_p.x_data/unit;
    double first_x = unit*first_x_i;

    GCStatsDataPoint * last_p  = (self.dataPoints).lastObject;

    size_t range = ((last_p.x_data - first_p.x_data)/unit)+1;
    range  = MIN(range, MAX_FILL_POINTS); // no more than ~8 hours = 3600*8 = 28800 double 225k/array

    double * values  = calloc(range, sizeof(double));
    double * rolling = calloc(range, sizeof(double));
    double * best    = calloc(range, sizeof(double));
    double * nonzero = calloc(range, sizeof(double));
    size_t * bestidx = nil;
    
    [self fill:range valuesForUnit:unit into:values firstx:&first_x];
    //Update First_x with the one used by fill

    //for debugging,
    // bestidx will keep the locate of the reached min or max
    // debugidx if != -1 will dump all the number contributing to that specific
    // index max or min
    bestidx = calloc(range, sizeof(size_t));
    BOOL debug_trace = false;
    size_t debugidx = -1;
    
    // populate per unit data:
    //   rolling    n:0    1    2    3    4
    //   values i:0   +0   +0   +0   +0   +0
    //            1   +1-0 +1   +1   +1   +1
    //            2   +2-1 +2-0 +2   +2   +2
    //            3   +3-2 +3-1 +3-0 +3   +3
    //            4   +4-3 +4-2 +4-1 +4-0 +4

    //
    for (size_t i=0; i<range; i++) {
        for (size_t n=0; n<range; n++) {
            if (i<=n) {
                if( values[i] > 0){
                    nonzero[n] += 1;
                }
                switch (statistic) {
                    case gcStatsWeightedMean:
                        // We haven't reach n values yet, add i_th
                        if( debug_trace && n == debugidx ){
                            RZLog(RZLogInfo,@"add: rolling[%lu] += values[%lu] / (n+1) = %f / %lu = %f + %f / %lu = %f ", n, i,  values[i], n+1, rolling[n], values[i], n+1, rolling[n] + (values[i]/(n+1)));
                        }
                        rolling[n] += values[i]/(n+1);
                        break;
                    case gcStatsSum:
                        // We haven't reach n values yet, add i_th
                        if( debug_trace && n == debugidx ){
                            RZLog(RZLogInfo,@"add: rolling[%lu] += values[%lu] = %f + %f = %f ", n, i, rolling[n], values[i], rolling[n] + values[i]);
                        }

                        rolling[n] += values[i];
                        break;
                }
            }else{
                if( values[i] > 0){
                    nonzero[n] += 1;
                }
                if( values[i-n-1] && nonzero[n] > 0){
                    nonzero[n] -= 1;
                }
                switch (statistic) {
                    case gcStatsWeightedMean:
                    {
                        // We have reach n values, add i_th, but remove i_th - (n_th+1)
                        double add = values[i]/(n+1) - values[i-n-1]/(n+1);
                        // Don't add <0 numbers
                        rolling[n] = MAX(rolling[n] + add,0.0);
                        break;
                    }
                    case gcStatsSum:
                    {
                        // We have reach n values, add i_th, but remove i_th - (n_th+1)
                        if( debug_trace && n == debugidx ){
                            RZLog(RZLogInfo,@"add: rolling[%lu] += values[%lu] - values[%lu] = %f + %f - %f = %f ", n, i, i-n, rolling[n], values[i], values[i-n], rolling[n] + values[i] -values[i-n]);
                        }
                        double add = values[i] - values[i-n];
                        // Don't add <0 numbers
                        rolling[n] = MAX(rolling[n] + add,0.0);
                        break;
                    }
                        
                }
            }

            // We have reach n values, start recording best, initialize with current value
            if (i==n) {
                best[n]=rolling[n];
                if (bestidx) {
                    bestidx[n]=i;
                }
            }else if(i>n){
                // we now have n values, check if last n better than previous best according to
                // the appropriate select rule.
                if (select==gcStatsRatioMin || select==gcStatsRatioMax){
                    // for speed if n: distance, rolling[n]: time, speed is best if dist/time is higher
                    if( rolling[n] != 0.0 && best[n] != 0.0){
                        // for speed if n: distance, rolling[n]: time, speed is best if dist/time is higher
                        double rollingInvRatio = (unit * (1.0+n))/rolling[n];
                        double bestInvRatio = (unit * (1.0+n))/best[n];
                        
                        // Example: n: meters, rolling[n]: seconds, ratio: n+1*stride / rolling[n] = distance/time (mps) gcStatsRatioMax: highest mps
                        
                        if( ( select==gcStatsRatioMin && bestInvRatio > rollingInvRatio ) ||
                           ( select==gcStatsRatioMax && bestInvRatio < rollingInvRatio ) ){
                            best[n]=rolling[n];
                            if (bestidx) {
                                bestidx[n] = i-n;
                            }
                        }
                    }
                }else{
                    if ( (select==gcStatsMax && best[n]<rolling[n]) ||
                        (select==gcStatsMin && best[n]>rolling[n]) )
                    {
                        if( debug_trace && n == debugidx ){
                            RZLog(RZLogInfo,@"found: best[%lu]=%f rolling[%lu]=%f index=[%lu-%lu]", n,best[n],n,rolling[n], i-n, i);
                        }
                        best[n]=rolling[n];
                        if (bestidx) {
                            bestidx[n] = i-n;
                        }
                    }
                }
            }
        }
    }
#if TARGET_IPHONE_SIMULATOR
    size_t bad_count = 0;
    for(size_t n=1;n<range;n++){
        // For debugging should not happen
        if ( (select==gcStatsMax && best[n]<best[n-1]) || (select==gcStatsMin && best[n]>best[n-1])) {
            bad_count++;
        }
    }
#endif

    GCStatsDataSerie * rv = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);
    if (bestidx) {
        for (size_t n=0; n<range; n++) {
            [rv addDataPointWithX:first_x+unit*n y:best[n] andZ:first_x+bestidx[n]*unit];
        }
        free(bestidx);
    }else{
        for (size_t n=0; n<range; n++) {
            [rv addDataPointWithX:first_x+unit*n andY:best[n]];
        }
    }

    free(best);
    free(values);
    free(rolling);
    free(nonzero);

    return rv;
}


-(GCStatsDataSerie*)operate:(gcStatsOperand)operand with:(GCStatsDataSerie*)other{
    NSUInteger s_idx = 0;
    NSUInteger o_idx = 0;
    NSUInteger maxCount = self.count+other.count;//worst case is fully disjoint

    NSMutableArray * newPoints = [NSMutableArray arrayWithCapacity:maxCount];
    double last_x = 0;
    BOOL started = false;

    NSUInteger safeguard = 0;

    BOOL operandSupportsDisjoint = (operand != gcStatsOperandMultiply && operand != gcStatsOperandMinus);

    while ((s_idx<self.count||o_idx<other.count) && safeguard < maxCount) {
        safeguard++;
        GCStatsDataPoint * s_point = s_idx<self.count  ? self.dataPoints[s_idx] : nil;
        GCStatsDataPoint * o_point = o_idx<other.count ? other.dataPoints[o_idx]: nil;

        GCStatsDataPoint * newpoint = nil;
        BOOL disjoint = true;
        if (s_point&&o_point) {
            if (fabs(s_point.x_data-o_point.x_data)<1e-7) {
                disjoint = false;
                if (s_point.x_data > last_x || !started) {
                    newpoint = [GCStatsDataPoint dataPointWithPoint:s_point andValue:s_point.y_data];
                    switch (operand) {
                        case gcStatsOperandMax:
                            [newpoint setToMax:o_point];
                            break;
                        case gcStatsOperandMin:
                            [newpoint setToMin:o_point];
                            break;
                        case gcStatsOperandPlus:
                            [newpoint addPoint:o_point];
                            break;
                        case gcStatsOperandMinus:
                            [newpoint minusPoint:o_point];
                            break;
                        case gcStatsOperandMultiply:
                            [newpoint multiplyPoint:o_point];
                            break;
                    }
                }
                s_idx++;
                o_idx++;
            }else if (s_point.x_data>o_point.x_data){
                newpoint = [GCStatsDataPoint dataPointWithPoint:o_point andValue:o_point.y_data];
                o_idx++;

            }else{
                newpoint = [GCStatsDataPoint dataPointWithPoint:s_point andValue:s_point.y_data];
                s_idx++;
            }
        }else if (s_point){
            newpoint = [GCStatsDataPoint dataPointWithPoint:s_point andValue:s_point.y_data];
            s_idx++;
        }else if (o_point){
            newpoint = [GCStatsDataPoint dataPointWithPoint:o_point andValue:o_point.y_data];
            o_idx++;
        }
        if (newpoint) {
            if (operandSupportsDisjoint || disjoint == false) {
                [newPoints addObject:newpoint];
                last_x = newpoint.x_data;
            }
        }

        started=true;
    }//while
    if (safeguard>=maxCount && other.count>0) {
        RZLog(RZLogWarning, @"hit safeguard %d x %d -> %d points", (int)self.count, (int)other.count, (int)safeguard);
    }
    return [GCStatsDataSerie dataSerieWithPoints:newPoints];
}

@end
