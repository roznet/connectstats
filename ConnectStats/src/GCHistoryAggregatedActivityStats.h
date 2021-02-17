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

#import <Foundation/Foundation.h>
#import "GCActivity.h"
#import "GCActivitiesOrganizer.h"
#import "GCHistoryAggregatedDataHolder.h"

//
// aggregate by [ dynamic Date Buckets ] x [ fixed fields ]
// aggregate by [ fixed buckets All, 1w, 1m, 1y ] x [ dynamic all fields ]
// aggregate by [ dynamic activity type, fixed [ all, 1w, 1m ] ] x [ dynamic all fields ]
// aggregate by [ dynamic cluster ] x [ all fields ]
// aggregate by [ dynamic cluster, dynamic date buckets  ] x [ all fields ]
//
//   AggregatedDataHolder: fixed field or dynamic
//        collect info: Activity Type? array of activities?
//        diff over last: wow, mom, yoy
//   GroupBy: [fixed or dynamic element]
//        date bucket
//        number range
//        string(activity|other meta)/location/cluster
//   Queries:
//        indexed by date list of holders x [ fields ] (statistic list page)
//        indexed by date series of number(field) : graphs
//        indexed by field list of holder x [ bucket ] (field summary for 1w, 1m )
//        indexed by field list of holder x [ buckets ] (field summary for wow, mom )
//        indexed by cluster serie of date x field (graphs or total by location, cluster)

NS_ASSUME_NONNULL_BEGIN

@interface GCHistoryAggregatedActivityStats : NSObject<NSFastEnumeration>

+(GCHistoryAggregatedActivityStats*)aggregatedActivityStatsForActivityType:(NSString*)activityType;

@property (nonatomic,retain) NSArray<GCActivity*> * activities;
@property (nonatomic,retain) NSString * activityType;
@property (nonatomic,assign) BOOL useFilter;

-(void)aggregate:(NSCalendarUnit)aUnit referenceDate:(nullable NSDate*)refOrNil ignoreMode:(gcIgnoreMode)ignoreMode;
-(void)aggregate:(NSCalendarUnit)aUnit referenceDate:(nullable NSDate*)refOrNil cutOff:(nullable NSDate*)cutOff ignoreMode:(gcIgnoreMode)ignoreMode;
-(NSUInteger)count;
-(GCHistoryAggregatedDataHolder*)dataForIndex:(NSUInteger)idx;
-(GCHistoryAggregatedDataHolder*)dataForDate:(NSDate*)date;
-(void)setActivitiesFromOrganizer:(GCActivitiesOrganizer*)organizer;

+(NSArray<GCField*>*)defaultFieldsForActivityType:(NSString*)activityType;
@end

NS_ASSUME_NONNULL_END
