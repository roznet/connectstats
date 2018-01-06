//  MIT Licence
//
//  Created on 11/08/2015.
//
//  Copyright (c) 2015 Brice Rosenzweig.
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

#import "GCActivityThumbnails.h"
#import "GCMapViewController.h"
#import "GCTrackFieldChoiceHolder.h"
#import "GCTrackStats.h"
#import "GCSimpleGraphCachedDataSource+Templates.h"
#import "GCHistoryFieldDataSerie.h"
#import "GCAppGlobal.h"
#import "GCHistoryPerformanceAnalysis.h"
#import "GCActivitiesOrganizer.h"

@implementation GCActivityThumbnails

-(UIImage*)mapFor:(GCActivity*)act andSize:(CGSize)size{
    GCMapViewController * controller = [[GCMapViewController alloc] initWithNibName:nil bundle:nil];

    controller.activity = act;
    (controller.view).frame = CGRectMake(0., 0., size.width, size.height);
    UIImage * rv = [UIImage imageWithUIView:controller.view];
    [controller release];

    return rv;
}

-(UIImage*)trackGraphFor:(GCActivity*)act andSize:(CGSize)size{
    GCTrackStats * trackStats = [[GCTrackStats alloc] init];
    trackStats.activity = act;
    GCTrackFieldChoiceHolder * holder = [GCTrackFieldChoiceHolder trackFieldChoice:[GCField fieldForFlag:gcFieldFlagWeightedMeanHeartRate
                                                                                         andActivityType:act.activityType]
                                                                             style:gcTrackStatsData];
    [holder setupTrackStats:trackStats];
    GCSimpleGraphCachedDataSource * ds = [GCSimpleGraphCachedDataSource trackFieldFrom:trackStats];

    GCSimpleGraphView * graphView = [[GCSimpleGraphView alloc] initWithFrame:CGRectMake(0., 0., size.width, size.height)];
    graphView.dataSource = ds;
    graphView.displayConfig = ds;
    UIImage * rv = [UIImage imageWithUIView:graphView];
    [graphView release];
    [trackStats release];

    return rv;

}

-(UIImage*)historyPlotFor:(GCField*)field andSize:(CGSize)size{
    UIImage * rv = nil;

    GCHistoryFieldDataSerieConfig * config = [GCHistoryFieldDataSerieConfig configWithFilter:false
                                                                                       field:field];

    GCHistoryFieldDataSerie * fieldDataSerie = [[GCHistoryFieldDataSerie alloc] initFromConfig:config] ;
    [fieldDataSerie loadFromOrganizer];

    NSCalendarUnit unit = [GCAppGlobal healthStatsVersion]?NSCalendarUnitMonth : NSCalendarUnitYear;


    if (![fieldDataSerie isEmpty]) {

        if (unit == NSCalendarUnitYear) {
            gcStatsRange range = [fieldDataSerie.history.serie range];
            double span = range.x_max-range.x_min;
            if (span < 3600.*24.*365.) {// less than 1 year of data
                unit = NSCalendarUnitMonth;
            }
        }
        const CGFloat legendHeight = 12.;

        GCSimpleGraphCachedDataSource * ds = [GCSimpleGraphCachedDataSource historyView:fieldDataSerie
                                                                              calendarUnit:unit
                                                                               graphChoice:gcGraphChoiceCumulative
                                                                                     after:nil];
        ds.emptyGraphLabel = NSLocalizedString(@"Pending...", @"Summary Graph");

        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0., 0., size.width, size.height)];

        GCSimpleGraphView * graphView = [[GCSimpleGraphView alloc] initWithFrame:CGRectMake(0., 0., size.width, size.height-legendHeight)];
        [view addSubview:graphView];
        graphView.darkMode = true;
        graphView.dataSource = ds;
        graphView.displayConfig = ds;

        GCSimpleGraphLegendView * legendView = [[GCSimpleGraphLegendView alloc] initWithFrame:CGRectMake(0., size.height-legendHeight, size.width, legendHeight)];
        legendView.darkMode = true;
        legendView.dataSource = ds;
        legendView.displayConfig = ds;
        [view addSubview:legendView];

        rv = [UIImage imageWithUIView:view];
        [graphView release];
        [legendView release];
        [view release];
    }

    [fieldDataSerie release];

    return rv;
}
-(UIImage*)performancePlotFor:(GCField *)field andSize:(CGSize)size{
    UIImage * rv = nil;

    NSDate *from=[[[GCAppGlobal organizer] lastActivity].date dateByAddingGregorianComponents:[NSDateComponents dateComponentsFromString:@"-6m"]];
    GCHistoryPerformanceAnalysis * performanceAnalysis = [GCHistoryPerformanceAnalysis performanceAnalysisFromDate:from
                                                                                                          forField:[GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:field.activityType] ];


    [performanceAnalysis calculate];
    if (![performanceAnalysis isEmpty]) {
        GCSimpleGraphCachedDataSource * ds = [GCSimpleGraphCachedDataSource performanceAnalysis:performanceAnalysis width:size.width];

        GCSimpleGraphView * graphView = [[GCSimpleGraphView alloc] initWithFrame:CGRectMake(0., 0., size.width, size.height)];
        graphView.darkMode = true;
        graphView.dataSource = ds;
        graphView.displayConfig = ds;
        rv = [UIImage imageWithUIView:graphView];
        [graphView release];

    }
    return rv;
}




@end
