//  MIT Licence
//
//  Created on 17/11/2012.
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

#import "GCViewConfig.h"

@class GCHistoryPerformanceAnalysis;
@class GCTrackStats;
@class GCHistoryFieldDataSerie;

@interface GCSimpleGraphCachedDataSource (Templates)

+(GCSimpleGraphCachedDataSource*)scatterPlotCacheFrom:(GCHistoryFieldDataSerie *) scatterStats;
+(GCSimpleGraphCachedDataSource*)fieldHistoryCacheFrom:(GCHistoryFieldDataSerie*)history andMovingAverage:(NSUInteger)samples;
+(GCSimpleGraphCachedDataSource*)historyView:(GCHistoryFieldDataSerie*)fieldserie calendarUnit:(NSCalendarUnit)aUnit graphChoice:(gcGraphChoice)graphChoice after:(NSDate*)date;
+(GCSimpleGraphCachedDataSource*)fieldHistoryHistogramFrom:(GCHistoryFieldDataSerie*)history width:(CGFloat)width;
+(GCSimpleGraphCachedDataSource*)performanceAnalysis:(GCHistoryPerformanceAnalysis*)perfAnalysis width:(CGFloat)width;
+(GCSimpleGraphCachedDataSource*)derivedData:(NSString*)activityType field:(gcFieldFlag)field for:(NSDate*)date width:(CGFloat)width;

+(GCSimpleGraphCachedDataSource*)trackFieldFrom:(GCTrackStats*)trackStats;

@end
