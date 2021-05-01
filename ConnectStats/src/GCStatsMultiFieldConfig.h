//  MIT Licence
//
//  Created on 13/07/2014.
//
//  Copyright (c) 2014 Brice Rosenzweig.
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
#import "GCHistoryFieldSummaryStats.h"
#import "GCViewConfig.h"
#import "GCStatsCalendarAggregationConfig.h"

@class GCSimpleGraphCachedDataSource;
@class GCHistoryFieldDataSerie;
@class GCDerivedDataSerie;
@class GCDerivedGroupedSeries;
@class GCActivityTypeSelection;

typedef NS_ENUM(NSUInteger, gcComparisonMetric) {
    gcComparisonMetricNone,
    gcComparisonMetricPercent,
    gcComparisonMetricValueDifference,
    gcComparisonMetricValue
};

@interface GCStatsMultiFieldConfig : NSObject

@property (nonatomic,readonly) NSString * activityType;// DEPRECATED_MSG_ATTRIBUTE("Use Type Detail");
@property (nonatomic,readonly) GCActivityType * activityTypeDetail;// DEPRECATED_MSG_ATTRIBUTE("Use Type Selection");
@property (nonatomic,retain) GCActivityTypeSelection * activityTypeSelection;
/**
 *  ViewChoice, decide what you display: all, monthly, weekly, yearly, summary
 */
@property (nonatomic,assign) gcViewChoice viewChoice;
@property (nonatomic,assign) NSString * viewChoiceKey;
/**
 *  ViewConfig, is how far back to look in summary pages, 3m, 6m, 1y, can also be toDate/All
 */
@property (nonatomic,assign) gcStatsViewConfig viewConfig;
@property (nonatomic,assign) NSString * viewConfigKey;

@property (nonatomic,assign) BOOL useFilter;

@property (nonatomic,assign) gcGraphChoice graphChoice;
@property (nonatomic,retain) NSString * graphChoiceKey;

@property (nonatomic,assign) gcComparisonMetric comparisonMetric;
@property (nonatomic,retain) NSString * comparisonMetricKey;

/**
 *  HistoryStats displayed can be current month, week, year or all -> quick filter on thumbnail graphs
 */
@property (nonatomic,readonly) gcHistoryStats historyStats;
@property (nonatomic,readonly) GCField * currentCumulativeSummaryField;
@property (nonatomic,readonly) GCStatsCalendarAggregationConfig * calendarConfig;

@property (nonatomic,readonly) NSString * viewDescription;


+(GCStatsMultiFieldConfig*)fieldListConfigFrom:(GCStatsMultiFieldConfig*)other;
-(GCStatsMultiFieldConfig*)sameFieldListConfig;

-(BOOL)isEqualToConfig:(GCStatsMultiFieldConfig*)other;
-(BOOL)requiresAggregateRebuild:(GCStatsMultiFieldConfig*)other;

-(NSString*)diffDescription:(GCStatsMultiFieldConfig*)other;

-(GCSimpleGraphCachedDataSource*)dataSourceForFieldDataSerie:(GCHistoryFieldDataSerie*)fieldDataSerie;

-(UIBarButtonItem*)viewChoiceButtonForTarget:(id)target action:(SEL)sel longPress:(SEL)longPressSel;
-(UIBarButtonItem*)viewConfigButtonForTarget:(id)target action:(SEL)sel longPress:(SEL)longPressSel;

/// Iterate through the different configuration for the current view
/// depending on the view will iterate though historyStats filter or calChoice.
-(BOOL)nextViewConfig;

/// Iterate through the different view, summary, all, calendar(weekly,monthly,annual)
/// return true if cycle complete and back to first view
-(BOOL)nextView;

-(void)nextSummaryCumulativeField;
-(NSDate*)selectAfterDateFrom:(NSDate*)lastDate;
@end
