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
@class GCSimpleGraphCachedDataSource;
@class GCHistoryFieldDataSerie;

@interface GCStatsMultiFieldConfig : NSObject

@property (nonatomic,retain) NSString * activityType;
/**
 *  ViewChoice, decide what you display: all, monthly, weekly, yearly, summary
 */
@property (nonatomic,assign) gcViewChoice viewChoice;
/**
 *  History Stats is monthly, weekly or all -> quick filter on thumbnail graphs
 */
@property (nonatomic,assign) gcHistoryStats historyStats;
/**
 *  Stats calChoice, is how far back to look in summary pages, can also be toDate/All
 */
@property (nonatomic,assign) gcStatsCalChoice calChoice;
@property (nonatomic,assign) BOOL useFilter;


+(GCStatsMultiFieldConfig*)fieldListConfigFrom:(GCStatsMultiFieldConfig*)other;
-(GCStatsMultiFieldConfig*)sameFieldListConfig;
-(GCStatsMultiFieldConfig*)nextViewChoiceConfig;
-(BOOL)isEqualToConfig:(GCStatsMultiFieldConfig*)other;

-(GCStatsMultiFieldConfig*)configForNextFilter;

-(GCSimpleGraphCachedDataSource*)dataSourceForFieldDataSerie:(GCHistoryFieldDataSerie*)fieldDataSerie;

-(UIBarButtonItem*)buttonForTarget:(id)target action:(SEL)sel;

@end
