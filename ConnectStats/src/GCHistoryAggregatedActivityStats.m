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
