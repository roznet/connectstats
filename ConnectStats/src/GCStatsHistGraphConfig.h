//  MIT Licence
//
//  Created on 26/08/2014.
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
#import "GCHistoryFieldDataSerie.h"
#import "GCHistoryPerformanceAnalysis.h"
#import "GCViewConfig.h"
#import "GCHistoryFieldSummaryStats.h"

#import "GCStatsMultiFieldConfig.h"
#import "GCHistoryFieldDataSerieConfig.h"

// Inputs:
//   - history: configuration for historydataserie
//   - performance analysis
//   - fromDate/fromDateString: limit to point since that date
//   - view.width

// outputs = SimpleGraphDataSource
//  - xy plot
//  - y plot (bar, cum, etc)==gcGraphChoice
//  - performance analysis if performance analysis
//  -


typedef NS_ENUM(NSUInteger, gcHistGraphType) {
    gcHistGraphTypeBarSum,
    gcHistGraphTypeCumulative,
    gcHistGraphTypePerformance,
    gcHistGraphTypeHistogram,
    gcHistGraphTypeBestRolling,
    gcHistGraphTypeEnd
};


@interface GCStatsHistGraphConfig : RZParentObject<RZChildObject>

@property (nonatomic,retain) GCStatsMultiFieldConfig * timeWindowConfig;
@property (nonatomic,retain) GCHistoryFieldDataSerieConfig * fieldConfig;

@property (nonatomic,assign) CGFloat width;

@property (nonatomic,assign) gcHistGraphType graphType;

#pragma mark - Outputs

/**
 requires call to build to be valid
 */
@property (nonatomic,readonly) GCHistoryFieldDataSerie * dataSerie;
/**
 requires call to build to be valid
 */
@property (nonatomic,readonly) GCHistoryPerformanceAnalysis * performanceAnalysis;
/**
 requires call to build to be valid
 */
@property (nonatomic,readonly) GCSimpleGraphCachedDataSource * dataSource;

+(instancetype)histGraphConfigWithWorker:(NSThread*)worker;

/**
 Create new config as copy of another
 */
+(instancetype)histGraphConfigFrom:(GCStatsHistGraphConfig *)other;

-(BOOL)isEqualToConfig:(GCStatsHistGraphConfig*)other;
/**
 Do full build from scratch
 */
-(BOOL)build;
/**
 Do build assuming dataSerie is the data to use
 */
-(BOOL)buildWithDataSerie:(GCHistoryFieldDataSerie*)dataSerie;

+(NSArray<NSString*>*)graphTypeDisplayNames;

@end
