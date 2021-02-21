//  MIT License
//
//  Created on 09/10/2020 for ConnectStats
//
//  Copyright (c) 2020 Brice Rosenzweig
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



#import "GCHistoryFieldDataHolder.h"

@interface GCHistoryFieldDataHolder ()

@property (nonatomic,retain) GCUnit * unit;
@property (nonatomic,assign) double * sum;
@property (nonatomic,assign) double * count;
@property (nonatomic,assign) double * max;
@property (nonatomic,assign) double * min;
@property (nonatomic,assign) double * timewsum;
@property (nonatomic,assign) double * timeweight;
@property (nonatomic,assign) double * distwsum;
@property (nonatomic,assign) double * distweight;

@end

@implementation GCHistoryFieldDataHolder
-(GCHistoryFieldDataHolder*)init{
    self = [super init];
    if (self) {
        _sum    = calloc(sizeof(double), gcHistoryStatsEnd);
        _count  = calloc(sizeof(double), gcHistoryStatsEnd);
        _max    = calloc(sizeof(double), gcHistoryStatsEnd);
        _min    = calloc(sizeof(double), gcHistoryStatsEnd);
        _timewsum   = calloc(sizeof(double), gcHistoryStatsEnd);
        _timeweight = calloc(sizeof(double), gcHistoryStatsEnd);
        _distwsum   = calloc(sizeof(double), gcHistoryStatsEnd);
        _distweight = calloc(sizeof(double), gcHistoryStatsEnd);
    }
    return self;
}

-(void)dealloc{
    free(_sum);
    free(_count);
    free(_max);
    free(_min);
    free(_timewsum);
    free(_timeweight);
    free(_distwsum);
    free(_distweight);
    [_field release];
    [_unit release];


    [super dealloc];
}

-(NSString*)displayField{
    return [self.field displayName];
}

-(GCNumberWithUnit*)averageWithUnit{
    return [self averageWithUnit:gcHistoryStatsAll];
}
-(GCNumberWithUnit*)sumWithUnit{
    return [self sumWithUnit:gcHistoryStatsAll];
}
-(double)count:(gcHistoryStats)which{
    return _count[which];
}
-(GCNumberWithUnit*)countWithUnit:(gcHistoryStats)which{
    return [GCNumberWithUnit numberWithUnitName:@"dimensionless" andValue:_count[which]];
}

-(GCNumberWithUnit*)weightedSumWithUnit:(gcHistoryStats)which{
    switch (self.unit.sumWeightBy) {
        case GCUnitSumWeightByTime:
            return [self numberWithUnitForValue:self.timewsum[which]];
        case GCUnitSumWeightByCount:
            return [self numberWithUnitForValue:self.sum[which]];
        case GCUnitSumWeightByDistance:
            return [self numberWithUnitForValue:self.distwsum[which]];
    }
}
-(GCNumberWithUnit*)weightedAverageWithUnit:(gcHistoryStats)which{
    switch (self.unit.sumWeightBy) {
        case GCUnitSumWeightByTime:
            if (self.timeweight[which]!= 0.) {
                return [self numberWithUnitForValue:self.timewsum[which]/self.timeweight[which]];
            }
            break;
        case GCUnitSumWeightByCount:
            if( self.count[which] != 0.){
                return [self numberWithUnitForValue:self.sum[which]/self.count[which]];
            }
            break;
        case GCUnitSumWeightByDistance:
            if (self.distweight[which]!= 0.) {
                return [self numberWithUnitForValue:self.distwsum[which]/self.distweight[which]];
            }
            break;
    }
    return nil;

}

-(GCNumberWithUnit*)averageWithUnit:(gcHistoryStats)which{
    if (self.count[which] > 0.) {
        return [self numberWithUnitForValue:self.sum[which]/self.count[which]];
    }else{
        return nil;
    }
}
-(GCNumberWithUnit*)numberWithUnitForValue:(double)val{
    GCNumberWithUnit * rv = [GCNumberWithUnit numberWithUnit:self.unit andValue:val];
    rv = [rv convertToGlobalSystem];
    return rv;
}

-(GCNumberWithUnit*)sumWithUnit:(gcHistoryStats)which{
    return [self numberWithUnitForValue:self.sum[which]];
}
-(GCNumberWithUnit*)maxWithUnit:(gcHistoryStats)which{
    return [self numberWithUnitForValue:self.max[which]];
}
-(GCNumberWithUnit*)minWithUnit:(gcHistoryStats)which{
    return [self numberWithUnitForValue:self.min[which]];
}

-(NSString*)description{
    NSMutableString * rv = [NSMutableString stringWithFormat:@"<GCFieldDataHolder: %@ %@:\n",self.field,self.unit];
    NSArray * desc = @[ @"All", @"W", @"M", @"Y" ];
    for (gcHistoryStats i = 0; i<gcHistoryStatsEnd; i++) {
        [rv appendFormat:@"  %@: Cnt %@, Avg %@, Sum %@, Max %@, Min %@\n", desc[i], [self countWithUnit:i], [self averageWithUnit:i],
         [self sumWithUnit:i], [self maxWithUnit:i], [self minWithUnit:i]];
    }
    [rv appendString:@">"];
    return rv;
}

-(void)convertToUnit:(GCUnit*)unit{
    if ([unit isEqualToUnit:self.unit]) {
        return;
    }else{
        GCUnit * common = [unit commonUnit:self.unit];
        if (![common isEqualToUnit:self.unit]) {
            for (gcHistoryStats i=0; i<gcHistoryStatsEnd; i++) {
                self.sum[i] = [common convertDouble:self.sum[i] fromUnit:self.unit];
                self.max[i] = [common convertDouble:self.max[i] fromUnit:self.unit];
                self.min[i] = [common convertDouble:self.min[i] fromUnit:self.unit];
                self.timewsum[i]= [common convertDouble:self.timewsum[i] fromUnit:self.unit];
            }
            self.unit = common;
        }
    }
}

-(void)addNumberWithUnit:(GCNumberWithUnit*)num{
    [self addNumberWithUnit:num withTimeWeight:1.0 distWeight:1.0 for:gcHistoryStatsAll];
}
-(void)addNumberWithUnit:(GCNumberWithUnit*)num withTimeWeight:(double)tw distWeight:(double)dw for:(gcHistoryStats)which{
    if( self.unit == nil ){
        self.unit = num.unit.referenceUnit ?: num.unit;
    }
    GCNumberWithUnit * cnum = [num convertToUnit:self.unit];
    
    if (!isinf(cnum.value)) {
        self.sum[which] += cnum.value;
        self.max[which] = MAX(self.max[which], cnum.value);
        self.min[which] = MIN(self.min[which], cnum.value);
        self.timewsum[which] += cnum.value * tw;
        self.distwsum[which] += cnum.value * dw;
    }
    
    self.count[which] +=1.;
    self.timeweight[which]+=tw;
    self.distweight[which]+=dw;
}
-(void)addSumWithUnit:(GCNumberWithUnit*)num andCount:(NSUInteger)count for:(gcHistoryStats)which{
    if( self.unit == nil ){
        self.unit = num.unit.referenceUnit ?: num.unit;
    }
    GCNumberWithUnit * cnum = [num convertToUnit:self.unit];
    
    self.sum[which] += cnum.value;
    self.max[which] = MAX(self.max[which], cnum.value);
    self.min[which] = MIN(self.min[which], cnum.value);
    self.count[which] += count;
}

@end
