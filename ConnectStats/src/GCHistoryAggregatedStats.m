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

#import "GCHistoryAggregatedStats.h"
#import "GCAppGlobal.h"
#import "GCActivity+Fields.h"

// NSDate sqlite format select
// select strftime( '%Y-%W', BeginTimeStamp/60/60/24+2440587.5 ) as Week, sum(SumDistance) from gc_activities  WHERE activityType = 'running' GROUP BY Week order by BeginTimeStamp desc limit 10;
// tracks
// select strftime( '%c', Time/60/60/24+2440587.5 ) as Timestamp, distanceMeter from gc_activities  WHERE activityType = 'Running' GROUP BY Week order by BeginTimeStamp desc limit 10


@interface GCHistoryAggregatedStats ()

@property (nonatomic,retain) NSArray<GCHistoryAggregatedDataHolder*> * aggregatedStats;
@property (nonatomic,retain) NSDate * refOrNil;
@property (nonatomic,assign) NSCalendarUnit calendarUnit;

@property (nonatomic,assign) NSDate * cutOff;

@property (nonatomic, retain) NSArray<GCField*>*fields;
@property (nonatomic, retain) NSSet<GCField*>*foundFields;

@end


@implementation GCHistoryAggregatedStats

+(GCHistoryAggregatedStats*)aggregatedStatsForActivityType:(NSString*)activityType{
    return [GCHistoryAggregatedStats aggregatedStatsForActivityTypeDetail:[GCActivityType activityTypeForKey:activityType]];
}
+(GCHistoryAggregatedStats*)aggregatedStatsForActivityTypeDetail:(GCActivityType*)activityType{
    return [GCHistoryAggregatedStats aggregatedStatsForActivityTypeSelection:RZReturnAutorelease([[GCActivityTypeSelection alloc] initWithActivityTypeDetail:activityType matchPrimaryType:true])];
}

+(GCHistoryAggregatedStats*)aggregatedStatsForActivityTypeSelection:(GCActivityTypeSelection*)selection{
    GCHistoryAggregatedStats * rv = [[[GCHistoryAggregatedStats alloc] init] autorelease];
    if( rv ){
        rv.fields = [GCHistoryAggregatedStats defaultFieldsForActivityTypeDetail:selection.activityTypeDetail];
        rv.activityTypeSelection = selection;
    }
    return rv;
}

+(NSArray<GCField*>*)defaultFieldsForActivityTypeDetail:(GCActivityType*)activityTypeDetail{
    NSString * activityType = activityTypeDetail.primaryActivityType.key;
    return @[
        [GCField fieldForFlag:gcFieldFlagWeightedMeanSpeed andActivityType:activityType],
        [GCField fieldForFlag:gcFieldFlagWeightedMeanHeartRate andActivityType:activityType],
        [GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:activityType],
        [GCField fieldForFlag:gcFieldFlagSumDuration andActivityType:activityType],
        [GCField fieldForFlag:gcFieldFlagPower andActivityType:activityType],
        [GCField fieldForFlag:gcFieldFlagCadence andActivityType:activityType],
        [GCField fieldForKey:@"GainElevation" andActivityType:activityType],
        [GCField fieldForKey:@"SumStep" andActivityType:activityType]
    ];
}

-(void)dealloc{
    [_activities release];
    [_aggregatedStats release];
    [_activityTypeDetail release];
    [_refOrNil release];
    [_fields release];
    [_foundFields release];
    [_activityTypeSelection release];
    
    [super dealloc];
}

-(NSString*)activityType{
    return self.activityTypeDetail.primaryActivityType.key;
}
-(NSUInteger)count{
    return _aggregatedStats.count;
}
-(GCHistoryAggregatedDataHolder*)dataForIndex:(NSUInteger)idx{
    return idx < _aggregatedStats.count ? _aggregatedStats[idx] : nil;
}

-(NSDate*)lastDate{
    return self.aggregatedStats.lastObject.date;
}

-(void)setActivitiesFromOrganizer:(GCActivitiesOrganizer*)organizer{
    self.activities = self.useFilter ? [organizer filteredActivities] : [organizer activities];
}

-(void)setActivities:(NSArray<GCActivity*>*)activities andFields:(NSArray<GCField*>*)fields{
    self.activities = activities;
    
    BOOL missingDuration = true;
    BOOL missingDistance = true;
    
    for (GCField * field in fields) {
        if( field.fieldFlag == gcFieldFlagSumDuration){
            missingDuration = false;
        }
        if( field.fieldFlag == gcFieldFlagSumDistance){
            missingDistance = false;
        }
    }
    
    if( missingDistance || missingDuration ){
        NSMutableArray * required = [NSMutableArray arrayWithArray:fields];
        if( missingDistance ){
            [required addObject:[GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:self.activityType]];
        }
        if( missingDuration ){
            [required addObject:[GCField fieldForFlag:gcFieldFlagSumDuration andActivityType:self.activityType]];
        }
        self.fields = required;
    }else{
        self.fields = fields;
    }
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
    
    NSMutableSet<GCField*> * found = [NSMutableSet set];

    NSArray<GCActivity*> * serie = [self.activityTypeSelection selectedWithActivities:self.activities];
    
    serie = [serie sortedArrayUsingComparator:^(id obj1, id obj2){
        return [[obj1 date] compare:[obj2 date]];
    }];

    NSMutableArray<GCHistoryAggregatedDataHolder*> * aggregatedStats = [NSMutableArray arrayWithCapacity:serie.count];
    if (serie.count > 0) {
        GCStatsDateBuckets * bucketer = [GCStatsDateBuckets statsDateBucketFor:aUnit referenceDate:refOrNil andCalendar:[GCAppGlobal calculationCalendar]];

        NSTimeInterval cutOffInterval = 0.;
        if (self.cutOff) {
            [bucketer bucket:self.cutOff];
            cutOffInterval = [self.cutOff timeIntervalSinceDate:bucketer.bucketStart];
        }

        NSDate * thisdate = serie.firstObject.date;
        [bucketer bucket:thisdate];
        GCHistoryAggregatedDataHolder * dataHolder = [[GCHistoryAggregatedDataHolder alloc] initForDate:bucketer.bucketStart andFields:self.fields];

        for (GCActivity * activity in serie) {
            thisdate = activity.date;
            BOOL changedBucket = [bucketer bucket:thisdate];
            if (changedBucket) {
                [dataHolder aggregateEnd:nil];
                [found addObjectsFromArray:dataHolder.availableFields];
                [aggregatedStats addObject:dataHolder];
                [dataHolder release];
                dataHolder = [[GCHistoryAggregatedDataHolder alloc] initForDate:bucketer.bucketStart andFields:self.fields];
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
        [found addObjectsFromArray:dataHolder.availableFields];
        [aggregatedStats addObject:dataHolder];
        [dataHolder release];
        [aggregatedStats sortUsingComparator:^(id obj1, id obj2){
            return [[obj2 date] compare:[obj1 date]];
        }];
    }
    self.foundFields = found;
    self.aggregatedStats = aggregatedStats;
}

- (NSUInteger)countByEnumeratingWithState:(nonnull NSFastEnumerationState *)state objects:(id  _Nullable * _Nonnull)buffer count:(NSUInteger)len {
    return [self.aggregatedStats countByEnumeratingWithState:state objects:buffer count:len];
}

@end
