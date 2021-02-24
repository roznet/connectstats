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
#import "GCHistoryFieldDataHolder.h"



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
        NSMutableDictionary<GCField*,GCHistoryFieldDataHolder*> * fieldKeyData = [NSMutableDictionary dictionary];

        GCStatsDateBuckets * weekBucket = nil;
        GCStatsDateBuckets * monthBucket= nil;
        GCStatsDateBuckets * yearBucket = nil;
        NSMutableDictionary * activityTypes = [NSMutableDictionary dictionary];
        for (GCActivity * act in activities) {
            if (![act ignoreForStats:ignoreMode] && ( match == nil || match(act) ) ) {
                activityTypes[act.activityType] = act.activityType;
                NSArray<GCField*> * fields = [act allFields];
                for (GCField * field in fields) {
                    //
                    GCHistoryFieldDataHolder * holder = fieldKeyData[field];
                    if (!holder) {
                        holder = [[[GCHistoryFieldDataHolder alloc] init] autorelease];
                        holder.field = field;
                        fieldKeyData[field] = holder;
                    }
                    GCField * fieldAll = [field correspondingFieldTypeAll];
                    GCHistoryFieldDataHolder * holderAll = fieldKeyData[fieldAll];
                    if(!holderAll){
                        holderAll = RZReturnAutorelease([[GCHistoryFieldDataHolder alloc] init]);
                        holderAll.field = fieldAll;
                        fieldKeyData[fieldAll] = holderAll;
                    }
                    GCNumberWithUnit * nu = [act numberWithUnitForField:field];
                    if (nu) {
                        if( nu.value == 0.0 && !field.isZeroValid){
                            continue;
                        }
                        
                        // weight is either duration (everything) or dist (for pace = invlinear)
                        double timeweight = [act summaryFieldValueInStoreUnit:gcFieldFlagSumDuration];
                        double distweight = [act summaryFieldValueInStoreUnit:gcFieldFlagSumDistance];
                        // When doing day -> weight = 1
                        if (field.fieldFlag == gcFieldFlagSumDistance || ignoreMode == gcIgnoreModeDayFocus) {
                            distweight=1.;
                            timeweight=1.;
                        }
                        
                        [holder addNumberWithUnit:nu withTimeWeight:timeweight distWeight:distweight for:gcHistoryStatsAll];
                        [holderAll addNumberWithUnit:nu withTimeWeight:timeweight distWeight:distweight for:gcHistoryStatsAll];

                        if (weekBucket==nil) {
                            
                            weekBucket = [GCStatsDateBuckets statsDateBucketFor:NSCalendarUnitWeekOfYear
                                                                  referenceDate:refOrNil
                                                                    andCalendar:[GCAppGlobal calculationCalendar]];
                            monthBucket= [GCStatsDateBuckets statsDateBucketFor:NSCalendarUnitMonth
                                                                  referenceDate:refOrNil
                                                                    andCalendar:[GCAppGlobal calculationCalendar]];
                            yearBucket= [GCStatsDateBuckets statsDateBucketFor:NSCalendarUnitYear
                                                                  referenceDate:refOrNil
                                                                    andCalendar:[GCAppGlobal calculationCalendar]];
                            [weekBucket bucket:act.date];
                            [monthBucket bucket:act.date];
                            [yearBucket bucket:act.date];
                        }
                        if ([weekBucket contains:act.date]) {
                            [holder addNumberWithUnit:nu withTimeWeight:timeweight distWeight:distweight for:gcHistoryStatsWeek];
                            [holderAll addNumberWithUnit:nu withTimeWeight:timeweight distWeight:distweight for:gcHistoryStatsWeek];
                        }
                        if ([monthBucket contains:act.date]) {
                            [holder addNumberWithUnit:nu withTimeWeight:timeweight distWeight:distweight for:gcHistoryStatsMonth];
                            [holderAll addNumberWithUnit:nu withTimeWeight:timeweight distWeight:distweight for:gcHistoryStatsMonth];
                        }
                        if ([yearBucket contains:act.date]) {
                            [holder addNumberWithUnit:nu withTimeWeight:timeweight distWeight:distweight for:gcHistoryStatsYear];
                            [holderAll addNumberWithUnit:nu withTimeWeight:timeweight distWeight:distweight for:gcHistoryStatsYear];
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
    GCStatsDateBuckets * yearBucket= nil;

    NSMutableDictionary * healthFieldData = [NSMutableDictionary dictionaryWithDictionary:self.fieldData];

    for (GCHealthMeasure * measure in measures) {
        // not an interesting measure
        if ([measure.field isEqualToField:[GCHealthMeasure height]]) {
            continue;
        }
        GCField * field = measure.field;

        GCHistoryFieldDataHolder * holder = healthFieldData[field];
        if (!holder) {
            holder = [[[GCHistoryFieldDataHolder alloc] init] autorelease];
            holder.field = field;

            healthFieldData[field] = holder;
        }
        [holder addNumberWithUnit:measure.value withTimeWeight:1.0 distWeight:1.0 for:gcHistoryStatsAll];
        if (weekBucket==nil) {
            weekBucket = [GCStatsDateBuckets statsDateBucketFor:NSCalendarUnitWeekOfYear referenceDate:refOrNil andCalendar:[GCAppGlobal calculationCalendar]];
            monthBucket= [GCStatsDateBuckets statsDateBucketFor:NSCalendarUnitMonth referenceDate:refOrNil andCalendar:[GCAppGlobal calculationCalendar]];
            yearBucket = [GCStatsDateBuckets statsDateBucketFor:NSCalendarUnitYear referenceDate:refOrNil andCalendar:[GCAppGlobal calculationCalendar]];
            [weekBucket bucket:measure.date];
            [monthBucket bucket:measure.date];
            [yearBucket bucket:measure.date];
        }
        if ([weekBucket contains:measure.date]) {
            [holder addNumberWithUnit:measure.value withTimeWeight:1. distWeight:1. for:gcHistoryStatsWeek];
        }
        if ([monthBucket contains:measure.date]) {
            [holder addNumberWithUnit:measure.value withTimeWeight:1. distWeight:1.  for:gcHistoryStatsMonth];
        }
        if ([yearBucket contains:measure.date]) {
            [holder addNumberWithUnit:measure.value withTimeWeight:1. distWeight:1.  for:gcHistoryStatsYear];
        }

    }
    self.fieldData = [NSDictionary dictionaryWithDictionary:healthFieldData];
}

-(GCHistoryFieldDataHolder*)dataForField:(GCField*)aField{
    return self.fieldData[aField];
}


@end
