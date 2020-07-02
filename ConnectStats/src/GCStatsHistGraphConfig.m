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

#import "GCStatsHistGraphConfig.h"
#import "GCAppGlobal.h"
#import "GCSimpleGraphCachedDataSource+Templates.h"
#import "GCViewConfig.h"
#import "GCActivitiesOrganizer.h"

@interface GCStatsHistGraphConfig ()

@property (nonatomic,retain) GCHistoryFieldDataSerie * dataSerie;
@property (nonatomic,retain) GCHistoryPerformanceAnalysis * performanceAnalysis;
@property (nonatomic,retain) GCSimpleGraphCachedDataSource * dataSource;
@property (nonatomic,retain) dispatch_queue_t worker;

@end

@implementation GCStatsHistGraphConfig

+(NSArray<NSString*>*)graphTypeDisplayNames{
    return @[
             @"Simple Graph",
             @"Cumulative Graph",
             @"Performance Graph",
             @"Histogram",
             @"Best Rolling",
             ];
}

+(instancetype)histGraphConfigWithWorker:(dispatch_queue_t)worker{
    GCStatsHistGraphConfig * rv = [[[GCStatsHistGraphConfig alloc] init] autorelease];
    if (rv) {
        rv.worker = worker;
    }
    return rv;
}

+(instancetype)histGraphConfigFrom:(GCStatsHistGraphConfig *)other{
    GCStatsHistGraphConfig * rv = [[[GCStatsHistGraphConfig alloc] init] autorelease];
    if (rv) {
        rv.worker = other.worker;
        rv.fieldConfig = [GCHistoryFieldDataSerieConfig configWithConfig:other.fieldConfig];
        rv.timeWindowConfig = [GCStatsMultiFieldConfig fieldListConfigFrom:other.timeWindowConfig];
        rv.graphType = other.graphType;
        rv.width = other.width;
    }
    return rv;
}

-(BOOL)isEqualToConfig:(GCStatsHistGraphConfig*)other{
    return ([self.timeWindowConfig isEqualToConfig:other.timeWindowConfig] &&
            [self.fieldConfig isEqualToConfig:other.fieldConfig] &&
            self.graphType == other.graphType

            );
}

-(void)dealloc{
    [_dataSerie detach:self];
    [_dataSerie release];
    [_performanceAnalysis release];
    [_dataSource release];

    [_timeWindowConfig release];
    [_fieldConfig release];
    [_worker release];

    [super dealloc];
}

#pragma mark - Main Build Process

-(BOOL)buildWithDataSerie:(GCHistoryFieldDataSerie*)dataSerie{
    BOOL rv = false;

    self.dataSource = nil;
    self.performanceAnalysis = nil;

    [self.dataSerie detach:self];
    self.dataSerie = nil;

    self.fieldConfig = dataSerie.config;

    self.dataSerie = dataSerie;

    rv = [self buildDataSource];

    return rv;

}

-(BOOL)build{
    BOOL rv = false;

    self.dataSource = nil;
    self.performanceAnalysis = nil;

    rv = [self buildDataSerie];
    if (rv) {
        rv = [self buildDataSource];
    }

    return rv;
}

-(BOOL)buildDataSource{
    BOOL rv = false;
    switch (self.graphType) {
        case gcHistGraphTypeHistogram:
            rv = [self buildForSimpleBarGraph];
            break;
        case gcHistGraphTypeBarSum:
            rv = [self buildForFieldGraph];
            break;
        case gcHistGraphTypePerformance:
            rv = [self buildForPerformanceAnalysis];
            break;
        case  gcHistGraphTypeCumulative:
            rv = [self buildForCumulativeGraph];
            break;
        case gcHistGraphTypeBestRolling:
        case gcHistGraphTypeEnd:
            break;

    }
    return rv;
}

-(BOOL)buildDataSerie{
    [self.dataSerie detach:self];
    self.dataSerie = nil;

    self.dataSerie = [[[GCHistoryFieldDataSerie alloc] initAndLoadFromConfig:self.fieldConfig withThread:self.worker] autorelease];
    [self.dataSerie attach:self];

    return self.worker == nil;
}

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    if (theParent == self.dataSerie) {
        [self buildDataSource];
        [self notify];
    }
}

#pragma mark - DataSource Build

// Used in onefieldviewcontroller
-(BOOL)buildForPerformanceAnalysis{
    // Params:  Date Delay
    //          field/activityType

    NSDate *from=[[[GCAppGlobal organizer] lastActivity].date dateByAddingGregorianComponents:[NSDateComponents dateComponentsFromString:@"-6m"]];
    self.performanceAnalysis = [GCHistoryPerformanceAnalysis performanceAnalysisFromDate:from
                                                                                forField:self.fieldConfig.activityField];

    [self.performanceAnalysis calculate];

    self.dataSource = [GCSimpleGraphCachedDataSource performanceAnalysis:self.performanceAnalysis width:self.width];
    return true;
}

// Used in OneFieldViewController
-(BOOL)buildForScatterGraph{
    BOOL rv = false;
    // requires history has x_field
    if (self.fieldConfig.x_activityField != nil) {
        GCSimpleGraphCachedDataSource * cache = [GCSimpleGraphCachedDataSource scatterPlotCacheFrom:self.dataSerie];
        self.dataSource = cache;
        rv = true;
    }

    return rv;
}

// Used in OneFieldViewController
-(BOOL)buildForCumulativeGraph{
    GCSimpleGraphCachedDataSource * cache = [GCSimpleGraphCachedDataSource historyView:self.dataSerie
                                                                          calendarConfig:self.timeWindowConfig.calendarConfig
                                                                           graphChoice:gcGraphChoiceCumulative
                                                                                 after:nil];
    self.dataSource = cache;
    return true;
}

// Used in OneFieldViewController
-(BOOL)buildForSimpleBarGraph{
    //FIXME: use field instead of key
    gcGraphChoice choice = [GCViewConfig graphChoiceForField:self.fieldConfig.activityField andUnit:self.timeWindowConfig.calendarConfig.calendarUnit];
    self.dataSource = [GCSimpleGraphCachedDataSource historyView:self.dataSerie
                                                  calendarConfig:self.timeWindowConfig.calendarConfig
                                                     graphChoice:choice
                                                           after:nil];
    return  true;
}

-(BOOL)buildForFieldGraph{
    self.dataSource = [self.timeWindowConfig dataSourceForFieldDataSerie:self.dataSerie];
    return true;
}


@end
