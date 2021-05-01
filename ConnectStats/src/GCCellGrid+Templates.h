//  MIT Licence
//
//  Created on 09/11/2012.
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

#import "GCActivity.h"
#import "GCViewConfig.h"

#import "GCHistoryFieldSummaryStats.h"

@class GCHistoryAggregatedDataHolder;
@class GCActivity;
@class GCHealthMeasure;
@class GCHistoryFieldDataSerie;
@class GCStatsMultiFieldConfig;

@interface GCCellGrid (Templates)
-(void)setupDetailHeader:(GCActivity*)activity;

-(void)setupSummaryFromActivity:(GCActivity*)activity rows:(NSUInteger)nrows width:(CGFloat)width  status:(gcViewActivityStatus)status;
-(void)setupFromHistoryAggregatedData:(GCHistoryAggregatedDataHolder*)data
                                index:(NSUInteger)idx
                           multiFieldConfig:(GCStatsMultiFieldConfig*)multiFieldConfig
                      andActivityType:(GCActivityType*)activityType
                                width:(CGFloat)width;

-(void)setupForField:(NSString*)fieldKey
         andActivity:(GCActivity *)activity
               width:(CGFloat)width;

-(void)setupForFieldDataHolder:(GCHistoryFieldSummaryDataHolder*)data
                     histStats:(gcHistoryStats)which
               andActivityType:(NSString*)aType;

-(void)setUpForSummarizedHistory:(NSDictionary*)summarizedHistory
                         atIndex:(NSUInteger)idx
                        forField:(GCField*)field
                  calendarConfig:(GCStatsCalendarAggregationConfig*)calendarConfig;
-(void)setupForAttributedStrings:(NSArray<NSAttributedString*>*)attrStrings
                        graphIcon:(BOOL)graphIcon
                           width:(CGFloat)width;
-(void)setupForLap:(NSUInteger)idx andActivity:(GCActivity*)activity width:(CGFloat)width;

-(void)setupForText:(NSString*)aText;

-(void)setupForLap:(GCLap*)aLap key:(id)key andActivity:(GCActivity*)activity width:(CGFloat)width;
-(void)setupForExtraSummary:(GCActivity*)activity width:(CGFloat)width;
-(void)setupForHealthMeasureSummary:(GCHealthMeasure*)measure;

-(void)setupStatsAverageStdDev:(GCStatsDataSerie*)average for:(GCHistoryFieldDataSerie*)activityStats;
-(void)setupStatsHeaders:(GCHistoryFieldDataSerie *)activityStats;
-(void)setupStatsQuartile:(NSUInteger)row in:(GCStatsDataSerie*)quartiles for:(GCHistoryFieldDataSerie*)activityStats;
-(void)setupForWeather:(GCActivity*)activity width:(CGFloat)width;

-(void)setupForSwimTrackpoint:(GCTrackPoint*)lap index:(NSUInteger)idx andActivity:(GCActivity*)activity width:(CGFloat)width;

@end
