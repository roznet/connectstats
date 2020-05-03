//  MIT Licence
//
//  Created on 04/10/2012.
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

#import "GCHistoryFieldSummaryStats.h"
#import "GCFields.h"
#import "GCHealthMeasure.h"
#import "GCAppGlobal.h"
#import "GCActivity+Fields.h"

@interface GCFieldDataHolder ()

@property (nonatomic,retain) GCUnit * unit;
@property (nonatomic,assign) double * sum;
@property (nonatomic,assign) double * count;
@property (nonatomic,assign) double * max;
@property (nonatomic,assign) double * min;
@property (nonatomic,assign) double * wsum;
@property (nonatomic,assign) double * weight;

@end

@implementation GCFieldDataHolder
-(GCFieldDataHolder*)init{
    self = [super init];
    if (self) {
        _sum    = calloc(sizeof(double), gcHistoryStatsEnd);
        _count  = calloc(sizeof(double), gcHistoryStatsEnd);
        _max    = calloc(sizeof(double), gcHistoryStatsEnd);
        _min    = calloc(sizeof(double), gcHistoryStatsEnd);
        _wsum   = calloc(sizeof(double), gcHistoryStatsEnd);
        _weight = calloc(sizeof(double), gcHistoryStatsEnd);
    }
    return self;
}

-(void)dealloc{
    free(_sum);
    free(_count);
    free(_max);
    free(_min);
    free(_wsum);
    free(_weight);
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

-(GCNumberWithUnit*)weightWithUnit:(gcHistoryStats)which{
    return [GCNumberWithUnit numberWithUnitName:@"dimensionless" andValue:_weight[which]];

}
-(GCNumberWithUnit*)weightedSumWithUnit:(gcHistoryStats)which{
    return [self numberWithUnitForValue:self.wsum[which]];
}
-(GCNumberWithUnit*)weightedAverageWithUnit:(gcHistoryStats)which{
    if (self.weight[which]!= 0.) {
        return [self numberWithUnitForValue:self.wsum[which]/self.weight[which]];
    }else{
        return nil;
    }

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
    NSArray * desc = @[ @"All", @"W", @"M" ];
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
                self.wsum[i]= [common convertDouble:self.wsum[i] fromUnit:self.unit];
            }
            self.unit = common;
        }
    }
}

-(void)addNumberWithUnit:(GCNumberWithUnit*)num{
    [self addNumberWithUnit:num withWeight:1. for:gcHistoryStatsAll];
}
-(void)addNumberWithUnit:(GCNumberWithUnit*)num withWeight:(double)weight for:(gcHistoryStats)which{
    if ([num.unit isEqualToUnit:self.unit]) {
        if (!isinf(num.value)) {
            self.sum[which] += num.value;
            self.max[which] = MAX(self.max[which], num.value);
            self.min[which] = MIN(self.min[which], num.value);
            self.wsum[which] += num.value * weight;
        }
    }else{
        [self convertToUnit:num.unit];
        double val = [num convertToUnit:self.unit].value;
        if (!isinf(val)) {
            self.sum[which] += val;
            self.max[which] = MAX(self.max[which], val);
            self.min[which] = MIN(self.min[which], val);
            self.wsum[which] =  val * weight;
        }
    }
    self.count[which] +=1.;
    self.weight[which]+=weight;
}
-(void)addSumWithUnit:(GCNumberWithUnit*)num andCount:(NSUInteger)count for:(gcHistoryStats)which{
    if ([num.unit isEqualToUnit:self.unit]) {
        self.sum[which] += num.value;
        self.max[which] = MAX(self.max[which], num.value);
        self.min[which] = MIN(self.min[which], num.value);
    }else{
        [self convertToUnit:num.unit];
        double val = [num convertToUnit:self.unit].value;
        self.sum[which] += val;
        self.max[which] = MAX(self.max[which], val);
        self.min[which] = MIN(self.min[which], val);

    }
    self.count[which] +=count;
}

@end


@implementation GCHistoryFieldSummaryStats

-(void)dealloc{
    [_fieldData release];
    [_foundActivityTypes release];

    [super dealloc];
}

+(GCHistoryFieldSummaryStats*)fieldStatsWithActivities:(NSArray<GCActivity*>*)activities
                                              matching:(GCActivityMatchBlock)match
                                         referenceDate:(NSDate*)refOrNil
                                            ignoreMode:(gcIgnoreMode)ignoreMode{
    GCHistoryFieldSummaryStats * rv = [[[GCHistoryFieldSummaryStats alloc] init] autorelease];
    if (rv) {
        // First collect by indexing on Keys/NSStirng for speed
        // Then after cleanup by adding the type
        NSMutableDictionary<GCField*,GCFieldDataHolder*> * fieldKeyData = [NSMutableDictionary dictionary];

        GCStatsDateBuckets * weekBucket = nil;
        GCStatsDateBuckets * monthBucket= nil;
        NSMutableDictionary * activityTypes = [NSMutableDictionary dictionary];
        for (GCActivity * act in activities) {
            if (![act ignoreForStats:ignoreMode] && ( match == nil || match(act) ) ) {
                activityTypes[act.activityType] = act.activityType;
                NSArray<GCField*> * fields = [act allFields];
                for (GCField * field in fields) {
                    //
                    GCFieldDataHolder * holder = fieldKeyData[field];
                    if (!holder) {
                        holder = [[[GCFieldDataHolder alloc] init] autorelease];
                        holder.field = field;
                        fieldKeyData[field] = holder;
                    }
                    GCField * fieldAll = [field correspondingFieldTypeAll];
                    GCFieldDataHolder * holderAll = fieldKeyData[fieldAll];
                    if(!holderAll){
                        holderAll = RZReturnAutorelease([[GCFieldDataHolder alloc] init]);
                        holderAll.field = fieldAll;
                        fieldKeyData[fieldAll] = holderAll;
                    }
                    GCNumberWithUnit * nu = [act numberWithUnitForField:field];
                    if (nu) {
                        // weight is either duration (everything) or dist (for pace = invlinear)
                        double weight =  [nu.unit isKindOfClass:[GCUnitInverseLinear class]] ? [act summaryFieldValueInStoreUnit:gcFieldFlagSumDistance] : [act summaryFieldValueInStoreUnit:gcFieldFlagSumDuration];
                        // When doing day -> weight = 1
                        if (field.fieldFlag == gcFieldFlagSumDistance || ignoreMode == gcIgnoreModeDayFocus) {
                            weight=1.;
                        }
                        [holder addNumberWithUnit:nu withWeight:weight for:gcHistoryStatsAll];
                        [holderAll addNumberWithUnit:nu withWeight:weight for:gcHistoryStatsAll];
                        if (weekBucket==nil) {
                            weekBucket = [GCStatsDateBuckets statsDateBucketFor:NSCalendarUnitWeekOfYear
                                                                  referenceDate:refOrNil
                                                                    andCalendar:[GCAppGlobal calculationCalendar]];
                            monthBucket= [GCStatsDateBuckets statsDateBucketFor:NSCalendarUnitMonth
                                                                  referenceDate:refOrNil
                                                                    andCalendar:[GCAppGlobal calculationCalendar]];
                            [weekBucket bucket:act.date];
                            [monthBucket bucket:act.date];
                        }
                        if ([weekBucket contains:act.date]) {
                            [holder addNumberWithUnit:nu withWeight:weight for:gcHistoryStatsWeek];
                            [holderAll addNumberWithUnit:nu withWeight:weight for:gcHistoryStatsWeek];
                        }
                        if ([monthBucket contains:act.date]) {
                            [holder addNumberWithUnit:nu withWeight:weight for:gcHistoryStatsMonth];
                            [holderAll addNumberWithUnit:nu withWeight:weight for:gcHistoryStatsMonth];
                        }
                    }
                }
            }
        }

        rv.fieldData = [NSDictionary dictionaryWithDictionary:fieldKeyData];
        rv.foundActivityTypes = activityTypes.allKeys;
    }
    return rv;
}

+(GCHistoryFieldSummaryStats*)fieldStatsWithHealthMeasures:(NSArray*)measures{
    GCHistoryFieldSummaryStats * rv = [[[GCHistoryFieldSummaryStats alloc] init] autorelease];
    if (rv) {
        rv.fieldData = [NSMutableDictionary dictionaryWithCapacity:30];
        [rv addHealthMeasures:measures referenceDate:nil];
    }
    return rv;
}

-(void)addHealthMeasures:(NSArray<GCHealthMeasure*>*)measures referenceDate:(NSDate*)refOrNil{
    GCStatsDateBuckets * weekBucket = nil;
    GCStatsDateBuckets * monthBucket= nil;

    NSMutableDictionary * healthFieldData = [NSMutableDictionary dictionaryWithDictionary:self.fieldData];

    for (GCHealthMeasure * measure in measures) {
        // not an interesting measure
        if ([measure.field isEqualToField:[GCHealthMeasure height]]) {
            continue;
        }
        GCField * field = measure.field;

        GCFieldDataHolder * holder = healthFieldData[field];
        if (!holder) {
            holder = [[[GCFieldDataHolder alloc] init] autorelease];
            holder.field = field;

            healthFieldData[field] = holder;
        }
        [holder addNumberWithUnit:measure.value];
        if (weekBucket==nil) {
            weekBucket = [GCStatsDateBuckets statsDateBucketFor:NSCalendarUnitWeekOfYear referenceDate:refOrNil andCalendar:[GCAppGlobal calculationCalendar]];
            monthBucket= [GCStatsDateBuckets statsDateBucketFor:NSCalendarUnitMonth referenceDate:refOrNil andCalendar:[GCAppGlobal calculationCalendar]];
            [weekBucket bucket:measure.date];
            [monthBucket bucket:measure.date];
        }
        if ([weekBucket contains:measure.date]) {
            [holder addNumberWithUnit:measure.value withWeight:1. for:gcHistoryStatsWeek];
        }
        if ([monthBucket contains:measure.date]) {
            [holder addNumberWithUnit:measure.value withWeight:1. for:gcHistoryStatsMonth];
        }

    }
    self.fieldData = [NSDictionary dictionaryWithDictionary:healthFieldData];
}

-(GCFieldDataHolder*)dataForIndex:(NSUInteger)aIdx{
    GCFieldDataHolder * rv = nil;
    if (aIdx < self.fieldData.count) {
        GCField * field = [self.fieldData keysSortedByValueUsingSelector:@selector(compare:)][aIdx];
        rv = self.fieldData[field];
    }
    return rv;
}
-(NSUInteger)countOfFieldData{
    return self.fieldData.count;
}

-(GCFieldDataHolder*)dataForField:(GCField*)aField{
    return self.fieldData[aField];
}


@end
