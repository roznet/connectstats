//  MIT Licence
//
//  Created on 01/11/2012.
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

#import "GCHistoryAggregatedActivityStats.h"
#import "GCAppGlobal.h"
#import "GCActivity+Fields.h"

// NSDate sqlite format select
// select strftime( '%Y-%W', BeginTimeStamp/60/60/24+2440587.5 ) as Week, sum(SumDistance) from gc_activities  WHERE activityType = 'running' GROUP BY Week order by BeginTimeStamp desc limit 10;
// tracks
// select strftime( '%c', Time/60/60/24+2440587.5 ) as Timestamp, distanceMeter from gc_activities  WHERE activityType = 'Running' GROUP BY Week order by BeginTimeStamp desc limit 10

@implementation GCHistoryAggregatedDataHolder
@synthesize stats,date,flags;

-(GCHistoryAggregatedDataHolder*)init{
    self = [super init];
    if (self) {
        size_t n = gcAggregatedTypeEnd*gcAggregatedFieldEnd;
        stats= malloc(sizeof(double)*n);
        for (size_t i=0; i<n; i++) {
            stats[i] = 0.;
        }
        flags = malloc(sizeof(BOOL)*gcAggregatedFieldEnd);
        for (size_t i=0; i<gcAggregatedFieldEnd; i++) {
            flags[i]=false;
        }
        self.date = nil;
        started = false;
    }
    return self;
}

-(GCHistoryAggregatedDataHolder*)initForDate:(NSDate*)adate{
    self = [super init];
    if (self) {
        size_t n = gcAggregatedTypeEnd*gcAggregatedFieldEnd;
        stats= malloc(sizeof(double)*n);
        for (size_t i=0; i<n; i++) {
            stats[i] = 0.;
        }
        flags = malloc(sizeof(BOOL)*gcAggregatedFieldEnd);
        for (size_t i=0; i<gcAggregatedFieldEnd; i++) {
            flags[i]=false;
        }
        self.date = adate;
        started = false;
    }
    return self;

}

-(void)dealloc{
    [_activityType release];
    free(stats);
    free(flags);
    [date release];
    [super dealloc];
}

-(NSString*)description{
    NSMutableString * rv = [NSMutableString stringWithFormat:@"<GCHistoryAggregatedDataHolder:%@>",
            [date dateShortFormat]];

    for (size_t i=0; i<gcAggregatedFieldEnd; i++) {
        NSString * field = [GCFields fieldForFlag:gcAggregatedFieldToFieldFlag[i] andActivityType:self.activityType];
        if (flags[i]) {
            [rv appendFormat:@"\n  %@: cnt=%.0f sum=%.1f avg=%.0f",
             field,
             stats[i*gcAggregatedTypeEnd+gcAggregatedCnt],
             stats[i*gcAggregatedTypeEnd+gcAggregatedSum],
             stats[i*gcAggregatedTypeEnd+gcAggregatedAvg]
             ];
        }else{
            [rv appendFormat:@"\n  %@: N/A", field];
        }
    }
    return rv;
}

-(void)aggregateActivity:(GCActivity*)act{

    NSUInteger flag = act.flags;
    double data[gcAggregatedFieldEnd];
    data[gcAggregatedSumDistance] = [act summaryFieldValueInStoreUnit:gcFieldFlagSumDistance];
    data[gcAggregatedSumDuration] = [act summaryFieldValueInStoreUnit:gcFieldFlagSumDuration];
    data[gcAggregatedWeightedHeartRate]=[act summaryFieldValueInStoreUnit:gcFieldFlagWeightedMeanHeartRate];
    data[gcAggregatedWeightedSpeed]=isinf([act summaryFieldValueInStoreUnit:gcFieldFlagWeightedMeanSpeed]) ? 0. : [act summaryFieldValueInStoreUnit:gcFieldFlagWeightedMeanSpeed];

    data[gcAggregatedAltitudeMeters] = [act numberWithUnitForFieldFlag:gcFieldFlagAltitudeMeters].value;
    data[gcAggregatedCadence] = [act numberWithUnitForFieldFlag:gcFieldFlagCadence].value;
    if ([act.activityType isEqualToString:GC_TYPE_TENNIS]) {
        data[gcAggregatedTennisShots] = [act numberWithUnitForFieldFlag:gcFieldFlagTennisShots].value;
        data[gcAggregatedTennisPower] = [act numberWithUnitForFieldFlag:gcFieldFlagTennisPower].value;
    }else{
        data[gcAggregatedTennisShots] = 0;
        data[gcAggregatedTennisPower] = 0;
    }
    if ([act.activityType isEqualToString:GC_TYPE_DAY]) {
        data[gcAggregatedSumStep] = [act numberWithUnitForFieldKey:@"SumStep"].value;
    }else{
        data[gcAggregatedSumStep] = 0;
    }

    if (_activityType==nil) {
        self.activityType = act.activityType;
    }else if (![_activityType isEqualToString:act.activityType]){
        // mixed activity become all
        self.activityType = GC_TYPE_ALL;
    }

    if (!started) {
        // first round set everything to current data
        started = true;
        for (size_t f =0; f<gcAggregatedFieldEnd; f++) {
            for (size_t s =0; s<gcAggregatedTypeEnd; s++) {
                if (flag & gcAggregatedFieldToFieldFlag[f]) {
                    flags[f] = true;
                    if (s == gcAggregatedCnt) {
                        stats[f*gcAggregatedTypeEnd+s] = 1.;
                    }else if (s == gcAggregatedSsq){
                        stats[f*gcAggregatedTypeEnd+s] = data[f]*data[f];
                    }else{
                        stats[f*gcAggregatedTypeEnd+s] = data[f];
                    }
                }else{
                    if (s == gcAggregatedCnt) {
                        stats[f*gcAggregatedTypeEnd+s] = 0.;
                    }else{
                        stats[f*gcAggregatedTypeEnd+s] = 0.;
                    }
                }
            }
        }
    }else{
        double dur_w0  = stats[gcAggregatedSumDuration*gcAggregatedTypeEnd+gcAggregatedSum];
        double dur_w1  = data[gcAggregatedSumDuration];
        double dur_tot = dur_w0+dur_w1;

        for (size_t f =0; f<gcAggregatedFieldEnd; f++) {
            if (flag & gcAggregatedFieldToFieldFlag[f]) {
                flags[f]=true;
                stats[f*gcAggregatedTypeEnd+gcAggregatedSsq] += data[f]*data[f];
                stats[f*gcAggregatedTypeEnd+gcAggregatedSum] += data[f];
                stats[f*gcAggregatedTypeEnd+gcAggregatedAvg] += data[f];
                stats[f*gcAggregatedTypeEnd+gcAggregatedCnt] += 1.;
                stats[f*gcAggregatedTypeEnd+gcAggregatedMax] = MAX(data[f], stats[f*gcAggregatedTypeEnd+gcAggregatedMax]);
                stats[f*gcAggregatedTypeEnd+gcAggregatedMin] = MIN(data[f], stats[f*gcAggregatedTypeEnd+gcAggregatedMin]);
                stats[f*gcAggregatedTypeEnd+gcAggregatedWvg] = (stats[f*gcAggregatedTypeEnd+gcAggregatedWvg]*dur_w0+data[f]*dur_w1)/dur_tot;
            }
        }
    }
}

-(void)aggregateEnd:(NSDate*)adate{
    for (size_t f =0; f<gcAggregatedFieldEnd; f++) {
        double cnt = stats[f*gcAggregatedTypeEnd+gcAggregatedCnt];
        double sum = stats[f*gcAggregatedTypeEnd+gcAggregatedSum];
        double ssq = stats[f*gcAggregatedTypeEnd+gcAggregatedSsq];

        if (cnt>0) {
            stats[f*gcAggregatedTypeEnd+gcAggregatedAvg] /= cnt;
            stats[f*gcAggregatedTypeEnd+gcAggregatedStd] = STDDEV(cnt, sum, ssq);
        }
    }
    if (adate) {
        self.date = adate;
    }
}

-(BOOL)hasField:(gcAggregatedField)f{
    return flags[f];
}
-(double)valFor:(gcAggregatedField)f and:(gcAggregatedType)s{
    if(f*gcAggregatedTypeEnd+s<gcAggregatedTypeEnd*gcAggregatedFieldEnd){
        return stats[f*gcAggregatedTypeEnd+s];
    }else{
        RZLog(RZLogWarning, @"Invalid index for stats lookup");
        return 0.;
    }
}

-(NSString*)formatValue:(gcAggregatedField)f statType:(gcAggregatedType)s andActivityType:(NSString*)aType{
    if (flags[f] == false) {
        return @"";
    }
    GCUnit * unit = [GCField fieldForAggregated:f  andActivityType:aType].unit;
    
    double val = stats[f*gcAggregatedTypeEnd+s];
    if (f == gcAggregatedSumDistance) {
        val = [unit convertDouble:val fromUnit:[GCUnit unitForKey:STOREUNIT_DISTANCE]];
    }else if(f == gcAggregatedWeightedSpeed){
        val = [unit convertDouble:val fromUnit:[GCUnit unitForKey:STOREUNIT_SPEED]];
    }
    GCUnit * global = [unit unitForGlobalSystem];
    if (global != unit) {
        val = [global convertDouble:val fromUnit:unit];
        unit = global;
    }
    return [unit formatDouble:val];
}
-(GCNumberWithUnit*)numberWithUnit:(gcAggregatedField)f statType:(gcAggregatedType)s andActivityType:(NSString*)aType{

    double val = 0.;
    GCUnit * unit = nil;

    if(f*gcAggregatedTypeEnd+s<gcAggregatedTypeEnd*gcAggregatedFieldEnd){
        val = stats[f*gcAggregatedTypeEnd+s];
        
        unit = [GCField fieldForAggregated:f  andActivityType:aType].unit;
        if (f == gcAggregatedSumDistance) {
            val = [unit convertDouble:val fromUnit:[GCUnit unitForKey:STOREUNIT_DISTANCE]];
        }else if(f == gcAggregatedWeightedSpeed){
            val = [unit convertDouble:val fromUnit:[GCUnit unitForKey:STOREUNIT_SPEED]];
        }
    }
    GCUnit * global = [unit unitForGlobalSystem];
    if (global != unit) {
        val = [global convertDouble:val fromUnit:unit];
        unit = global;
    }

    return unit ? [GCNumberWithUnit numberWithUnit:unit andValue:val] : nil;
}
@end

@interface GCHistoryAggregatedActivityStats ()

@property (nonatomic,retain) NSMutableArray * aggregatedStats;
@property (nonatomic,retain) NSDate * refOrNil;
@property (nonatomic,assign) NSCalendarUnit calendarUnit;

@property (nonatomic,assign) NSDate * cutOff;


@end


@implementation GCHistoryAggregatedActivityStats

-(void)dealloc{
    [_activities release];
    [_aggregatedStats release];
    [_activityType release];
    [_refOrNil release];
    [super dealloc];
}

-(NSUInteger)count{
    return _aggregatedStats.count;
}
-(GCHistoryAggregatedDataHolder*)dataForIndex:(NSUInteger)idx{
    return idx < _aggregatedStats.count ? _aggregatedStats[idx] : nil;
}

-(void)setActivitiesFromOrganizer:(GCActivitiesOrganizer*)organizer{
    self.activities = self.useFilter ? [organizer filteredActivities] : [organizer activities];
}

-(GCHistoryAggregatedDataHolder*)dataForDate:(NSDate *)date{
    if (_aggregatedStats) {
        GCStatsDateBuckets * bucketer = [GCStatsDateBuckets statsDateBucketFor:_calendarUnit referenceDate:_refOrNil andCalendar:[GCAppGlobal calculationCalendar]];
        [bucketer bucket:date];

        for (GCHistoryAggregatedDataHolder * holder in self.aggregatedStats) {
            if ([holder.date isEqualToDate:bucketer.bucketStart]) {
                return holder;
            }
        }
    }
    return nil;
}

-(void)aggregate:(NSCalendarUnit)aUnit referenceDate:(NSDate*)refOrNil ignoreMode:(gcIgnoreMode)ignoreMode{
    return [self aggregate:aUnit referenceDate:refOrNil cutOff:nil ignoreMode:ignoreMode];
}

-(void)aggregate:(NSCalendarUnit)aUnit referenceDate:(NSDate *)refOrNil cutOff:(NSDate *)cutOff ignoreMode:(gcIgnoreMode)ignoreMode{
    self.calendarUnit = aUnit;
    self.refOrNil = refOrNil;
    self.cutOff = cutOff;

    NSArray * useActivities = self.activities;

    NSMutableArray * serie = [NSMutableArray arrayWithCapacity:useActivities.count];
    if ([_activityType isEqualToString:GC_TYPE_ALL]) {
        [serie addObjectsFromArray:useActivities];
    }else{
        for (GCActivity * act in useActivities) {
            if ([act.activityType isEqualToString:_activityType]) {
                [serie insertObject:act atIndex:0];
            }
        }
    }
    self.aggregatedStats = [NSMutableArray arrayWithCapacity:serie.count];
    [serie sortUsingComparator:^(id obj1, id obj2){
        return [[obj1 date] compare:[obj2 date]];
    }];


    NSUInteger idx = 0;
    NSUInteger n = serie.count;

    if (n > 0) {
        GCStatsDateBuckets * bucketer = [GCStatsDateBuckets statsDateBucketFor:aUnit referenceDate:refOrNil andCalendar:[GCAppGlobal calculationCalendar]];

        NSTimeInterval cutOffInterval = 0.;
        if (self.cutOff) {
            [bucketer bucket:self.cutOff];
            cutOffInterval = [self.cutOff timeIntervalSinceDate:bucketer.bucketStart];
        }

        NSDate * thisdate = [serie[0] date];
        [bucketer bucket:thisdate];
        GCHistoryAggregatedDataHolder * dataHolder = [[GCHistoryAggregatedDataHolder alloc] initForDate:bucketer.bucketStart];

        GCActivity * activity = nil;

        for (idx=0; idx<n; idx++) {
            activity   = serie[idx];
            thisdate = activity.date;

            BOOL changedBucket = [bucketer bucket:thisdate];
            if (changedBucket) {
                [dataHolder aggregateEnd:nil];
                [_aggregatedStats addObject:dataHolder];
                [dataHolder release];
                dataHolder = [[GCHistoryAggregatedDataHolder alloc] initForDate:bucketer.bucketStart];
            }
            // In To CutOff mode, skip if later.
            if (self.cutOff && [activity.date timeIntervalSinceDate:bucketer.bucketStart] > cutOffInterval) {
                continue;
            }
            if (![activity ignoreForStats:ignoreMode]) {
                [dataHolder aggregateActivity:activity];
            }
        }
        [dataHolder aggregateEnd:nil];
        [_aggregatedStats addObject:dataHolder];
        [dataHolder release];
        [_aggregatedStats sortUsingComparator:^(id obj1, id obj2){
            return [[obj2 date] compare:[obj1 date]];
        }];
    }
}



@end
