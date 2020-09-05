//  MIT License
//
//  Created on 01/07/2020 for ConnectStats
//
//  Copyright (c) 2020 Brice Test User
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
#import "GCAppConstants.h"

NS_ASSUME_NONNULL_BEGIN

extern const NSCalendarUnit kCalendarUnitNone;

@interface GCStatsCalendarAggregationConfig : NSObject

@property (nonatomic,assign) NSCalendarUnit calendarUnit;
@property (nonatomic,retain,nullable) NSDate * referenceDate;
@property (nonatomic,retain) NSCalendar * calendar;

@property (nonatomic,readonly) NSDateFormatter * dateFormatter;
@property (nonatomic,readonly) NSString * calendarUnitDescription;
@property (nonatomic,retain) NSString * calendarUnitKey;
@property (nonatomic,assign) gcPeriodType periodType;
@property (nonatomic,retain) NSString * periodTypeKey;

@property (nonatomic,readonly) gcHistoryStats historyStats;
/// Cut off date to use in to date calculation.
/// usually last date of last activity (could be change to current time later)
@property (nonatomic,readonly,nullable) NSDate * cutOff;

+(GCStatsCalendarAggregationConfig*)configFor:(NSCalendarUnit)aUnit calendar:(NSCalendar*)calendar;
+(GCStatsCalendarAggregationConfig*)globalConfigFor:(NSCalendarUnit)aUnit;
+(GCStatsCalendarAggregationConfig*)configFrom:(GCStatsCalendarAggregationConfig*)other;

-(GCStatsCalendarAggregationConfig*)equivalentConfigFor:(NSCalendarUnit)aUnit;

/// Go to next  calendar unit between week, month, year
/// @return true if finished the loop and starting again
-(BOOL)nextCalendarUnit;

-(BOOL)isEqualToConfig:(GCStatsCalendarAggregationConfig*)other;

@end

NS_ASSUME_NONNULL_END
