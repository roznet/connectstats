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

#import "GCSimpleGraphCachedDataSource+Templates.h"
#import "GCViewSwimStrokeColors.h"
#import "GCViewConfig.h"
#import "GCAppGlobal.h"
#import "GCHealthZoneCalculator.h"
#import "GCHistoryFieldDataSerie.h"
#import "GCTrackStats.h"
#import "GCHistoryPerformanceAnalysis.h"
#import "GCUnitTrainingZone.h"
#import "GCDerivedOrganizer.h"
#import "GCActivity+Series.h"
#import "GCStatsDerivedHistory.h"
#import "GCStatsCalendarAggregationConfig.h"

@implementation GCSimpleGraphCachedDataSource (Templates)

+(GCSimpleGraphCachedDataSource*)dataSourceWithStandardColors{
    GCSimpleGraphCachedDataSource * cache = [[[GCSimpleGraphCachedDataSource alloc] init] autorelease];
    if( cache ){
        cache.useBackgroundColor = [GCViewConfig colorForGraphElement:gcSkinGraphColorBackground];
        cache.useForegroundColor = [GCViewConfig colorForGraphElement:gcSkinGraphColorForeground];
        cache.axisColor = [GCViewConfig colorForGraphElement:gcSkinGraphColorAxis];
    }
    return cache;
}

+(GCSimpleGraphCachedDataSource*)scatterPlotCacheFrom:(GCHistoryFieldDataSerie *)scatterStats {
    GCSimpleGraphCachedDataSource * cache = [GCSimpleGraphCachedDataSource dataSourceWithStandardColors];
    cache.xUnit = [scatterStats xUnit];
    cache.title = [scatterStats title];

    GCSimpleGraphDataHolder * xy = [GCSimpleGraphDataHolder dataHolder:[scatterStats dataSerie:0]
                                                                  type:gcScatterPlot
                                                                 color:[GCViewConfig colorForGraphElement:gcSkinGraphColorForeground]
                                                               andUnit:[scatterStats yUnit:0]];
    xy.gradientFunction = scatterStats.gradientFunction;
    xy.gradientDataSerie = scatterStats.gradientSerie.serie;
    xy.gradientColors = [GCViewGradientColors gradientColorsRainbow16];
    xy.gradientSerieXUnit = [GCUnit unitForKey:@"dateshort"];

    GCStatsLinearFunction * reg = [[scatterStats dataSerie:0] regression];
    GCStatsDataSerie * line = [reg valueForXIn:[scatterStats dataSerie:0]];
    [line sortByX];
    GCSimpleGraphDataHolder * lineinfo = [GCSimpleGraphDataHolder dataHolder:line type:gcGraphLine color:[GCViewConfig colorForGraphElement:gcSkinGraphColorRegressionLine]
                                                                     andUnit:[scatterStats yUnit:0]];

    cache.series = [NSMutableArray arrayWithObjects:xy, lineinfo, nil];
    return cache;
}

+(GCSimpleGraphCachedDataSource*)historyView:(GCHistoryFieldDataSerie*)fieldserie
                                calendarConfig:(GCStatsCalendarAggregationConfig*)aUnit
                                 graphChoice:(gcGraphChoice)graphChoice after:(NSDate*)date{
    if (graphChoice == gcGraphChoiceBarGraph) {
        return [GCSimpleGraphCachedDataSource barGraphView:fieldserie calendarConfig:aUnit after:(NSDate*)date];
    }else{
        return [GCSimpleGraphCachedDataSource calendarView:fieldserie calendarConfig:aUnit graphChoice:graphChoice];
    }
}

+(GCSimpleGraphCachedDataSource*)calendarView:(GCHistoryFieldDataSerie*)fieldserie
                                 calendarConfig:(GCStatsCalendarAggregationConfig*)calendarConfig
                                  graphChoice:(gcGraphChoice)graphChoice{
    GCSimpleGraphCachedDataSource * cache = [GCSimpleGraphCachedDataSource dataSourceWithStandardColors];
    NSCalendarUnit aUnit = calendarConfig.calendarUnit;
    cache.xUnit = [fieldserie xUnit];
    if ([fieldserie.config isYOnly]) {
        switch (calendarConfig.calendarUnit) {
            case NSCalendarUnitWeekOfYear:
                cache.xUnit = [GCUnit unitForKey:@"weekly"];
                break;
            case NSCalendarUnitMonth:
                cache.xUnit = [GCUnit unitForKey:@"monthly"];
                break;
            case NSCalendarUnitYear:
            default:
                if( calendarConfig.referenceDate != nil){
                           cache.xUnit = [GCUnitCalendarUnit calendarUnit:NSCalendarUnitYear
                                                                 calendar:calendarConfig.calendar
                                                            referenceDate:calendarConfig.referenceDate];
                }else{
                    cache.xUnit = [GCUnit unitForKey:@"yearly"];
                }
                break;
        }
    }

    cache.title = [fieldserie title];

    NSDate * refdate = calendarConfig.referenceDate;

    NSDictionary * dict = [fieldserie.config isXY] ?
        [fieldserie.history.serie xyCumulativeRescaledByCalendarUnit:calendarConfig.calendarUnit
                                                         inTimeSerie:fieldserie.gradientSerie.serie
                                                        withCalendar:calendarConfig.calendar]
    :
        [fieldserie.history.serie rescaleWithinCalendarUnit:calendarConfig.calendarUnit
                                                     merged:NO
                                              referenceDate:refdate
                                                andCalendar:calendarConfig.calendar];

    NSArray * keys = [dict.allKeys sortedArrayUsingComparator:^(id obj1, id obj2){
        return [obj2 compare:obj1];
    }];

    NSArray * colors = [GCViewConfig arrayOfColorsForMultiplots];

    NSUInteger nSeries = MIN(6, [keys count]);

    gcGraphType type = gcGraphLine;
    if (graphChoice == gcGraphChoiceDistribution) {
        type = gcScatterPlot;
        nSeries = keys.count;
    }
    BOOL cumulative = (graphChoice == gcGraphChoiceCumulative) && [fieldserie.config isYOnly];

    NSMutableArray * series = [NSMutableArray arrayWithCapacity:nSeries];

    GCStatsDataSerie * bestSerie = nil;
    double bestLast = 0.;
    NSString * bestLegend = nil;
    GCUnit * legendUnit = nil;
    switch (aUnit) {
        case NSCalendarUnitYear:
            legendUnit = [GCUnit unitForKey:@"dateyear"];
            break;
        case NSCalendarUnitMonth:
            legendUnit = [GCUnit unitForKey:@"datemonth"];
            break;
        case NSCalendarUnitWeekOfYear:
        default:
            legendUnit = [GCUnit unitForKey:@"dateshort"];
            break;
    }

    for (NSUInteger i =0 ; i<keys.count; i++) {
        NSDate * dateKey = keys[i];

        GCStatsDataSerie * serie = dict[dateKey];
        GCStatsDataSerie * cumul = cumulative ? [serie cumulativeValue] : serie;
        if (cumulative) {
            double last = [cumul lastObject].y_data;
            if (bestSerie == nil) {
                bestLast = last;
                bestSerie = cumul;
            }else{
                if (last > bestLast) {
                    bestLast = last;
                    if (i >= nSeries) {
                        // if less than nSerie already displayed...
                        bestSerie= cumul;
                        bestLegend = [NSString stringWithFormat:@"%@ (best)",[legendUnit formatDouble:dateKey.timeIntervalSinceReferenceDate]];
                    }
                }
            }
        }
        if (i<nSeries) {
            UIColor * color = nil;
            if (type == gcGraphLine) {
                color = colors[i];
            }else{
                color = [[GCViewConfig colorForGraphElement:gcSkinGraphColorForeground] colorWithAlphaComponent:1.-(1.*i/nSeries)];
            }
            GCSimpleGraphDataHolder * plot = [GCSimpleGraphDataHolder dataHolder:cumul
                                                                            type:type
                                                                           color:color
                                                                         andUnit:[fieldserie yUnit:0]];
            if (plot) {
                [plot setDisableHighlight:true];
                plot.legend = [legendUnit formatDouble:dateKey.timeIntervalSinceReferenceDate];
                if (i==0) {
                    plot.lineWidth = 2.;
                    plot.legend = [NSString stringWithFormat:@"%@ (last)",[legendUnit formatDouble:dateKey.timeIntervalSinceReferenceDate]];
                }
                [series insertObject:plot atIndex:0];
            }
        }
    }
    if (bestSerie) {
        UIColor * bestColor = [GCViewConfig colorForGraphElement:gcSkinGraphColorForeground];
        GCSimpleGraphDataHolder * plot = [GCSimpleGraphDataHolder dataHolder:bestSerie
                                                                        type:gcGraphLine
                                                                       color:bestColor
                                                                     andUnit:[fieldserie yUnit:0]];
        plot.legend = bestLegend;
        [plot setDisableHighlight:true];
        plot.lineWidth = 1.;
        plot.fillColorForSerie = [bestColor colorWithAlphaComponent:0.1];
        if (series.count) {
            [series insertObject:plot atIndex:series.count-1];
        }else{
            [series addObject:plot];
        }
    }

    cache.series = series;
    return cache;

}

+(GCSimpleGraphCachedDataSource*)barGraphView:(GCHistoryFieldDataSerie*)fieldserie                                      calendarConfig:(GCStatsCalendarAggregationConfig*)calendarConfig
                                        after:(NSDate*)afterdate{
    GCSimpleGraphCachedDataSource * cache = [GCSimpleGraphCachedDataSource dataSourceWithStandardColors];
    cache.xUnit = [fieldserie xUnit];
    NSCalendarUnit aUnit = calendarConfig.calendarUnit;
    switch (aUnit) {
        case NSCalendarUnitWeekOfYear:
            cache.xUnit = [GCUnit unitForKey:@"dateshort"];
            break;
        case NSCalendarUnitYear:
            cache.xUnit = [GCUnit unitForKey:@"dateyear"];
            break;
        case NSCalendarUnitMonth:
        default:
            cache.xUnit = [GCUnit unitForKey:@"datemonth"];
            break;
    }

    NSMutableArray * series = [NSMutableArray arrayWithCapacity:1];

    cache.title = [fieldserie title];

    NSDictionary * dict = [fieldserie.history.serie aggregatedStatsByCalendarUnit:aUnit
                                                                    referenceDate:calendarConfig.referenceDate
                                                                      andCalendar:calendarConfig.calendar];

    gcGraphType type = gcGraphStep;

    GCStatsDataSerie * serie = nil;
    if ([fieldserie.config.activityField canSum]) {
        serie = dict[STATS_SUM];
    }else{
        cache.title =[NSString stringWithFormat:@"%@ %@", [GCViewConfig calendarUnitDescription:aUnit], cache.title];
        serie = dict[STATS_AVG];
    }
    UIColor * color = [GCViewConfig colorForGraphElement:gcSkinGraphColorBarGraph];
    NSMutableArray * adjusted = [NSMutableArray arrayWithCapacity:serie.count];

    NSCalendar * cal = calendarConfig.calendar;

    NSDateComponents * oneUnit = [[[NSDateComponents alloc] init] autorelease];
    if (aUnit == NSCalendarUnitWeekOfYear) {
        oneUnit.weekOfYear = 1;
    }else if(aUnit == NSCalendarUnitMonth){
        oneUnit.month = 1;
    }else if(aUnit == NSCalendarUnitYear){
        oneUnit.year = 1;
    }

    // bottom of the gcGraphStep is 0 or min
    double plot_y_min = 0.;
    if (true) {
        gcStatsRange range = [serie range];
        plot_y_min = range.y_min;
    }

    NSDate * lastdate = nil;
    NSDate * next     = nil;
    for (GCStatsDataPoint * point in serie) {
        if (afterdate && [point.date compare:afterdate] == NSOrderedAscending) {
            continue;
        }
        if (lastdate) {
            // if next < pointdate as in:
            // |----------|-----------|-------|---
            // lastdate   next        next    pointdate
            // fill with no value for next and move lastdate to next
            //
            // until
            // |----------|-------------|---
            // lastdate   pointdate     next
            // move lastdate to pointdate
            next = [cal dateByAddingComponents:oneUnit toDate:lastdate options:0];

            if ([next compareCalendarDay:[point date] include:NO calendar:cal] == NSOrderedAscending){
                do {
                    [adjusted addObject:[GCStatsDataPointNoValue dataPointWithDate:next andValue:plot_y_min]];
                    next = [cal dateByAddingComponents:oneUnit toDate:next options:0];
                } while ([next compareCalendarDay:[point date] include:NO calendar:cal] == NSOrderedAscending);
            }

            lastdate = [point date];

        }else{
            lastdate = [point date];
        }
        [adjusted addObject:point];
    }
    // add space for last point
    if (lastdate) {
        next = [cal dateByAddingComponents:oneUnit toDate:lastdate options:0];
        [adjusted addObject:[GCStatsDataPointNoValue dataPointWithDate:next andValue:plot_y_min]];
    }

    GCSimpleGraphDataHolder * plot = [GCSimpleGraphDataHolder dataHolder:[GCStatsDataSerie dataSerieWithPoints:adjusted]
                                                                    type:type
                                                                   color:color
                                                                 andUnit:[fieldserie yUnit:0]];
    if (plot) {
        gcStatsRange range = plot.range;
        range.y_min = plot_y_min    ;
        plot.range = range;
        [plot setDisableHighlight:true];
        [series insertObject:plot atIndex:0];
    }

    cache.series = series;
    return cache;

}

+(GCSimpleGraphCachedDataSource*)fieldHistoryHistogramFrom:(GCHistoryFieldDataSerie*)history width:(CGFloat)width{
    GCSimpleGraphCachedDataSource * cache = [GCSimpleGraphCachedDataSource dataSourceWithStandardColors];
    cache.xUnit = [history yUnit:0];
    cache.title = [history title];

    NSUInteger n = width > 320. ? 24 : 16;

    GCSimpleGraphDataHolder * plot = [GCSimpleGraphDataHolder dataHolder:[[history dataSerie:0] histogramWith:n]
                                                                    type:gcGraphStep color:[GCViewConfig colorForGraphElement:gcSkinGraphColorBarGraph]
                                                                 andUnit:[GCUnit unitForKey:@"dimensionless"]];

    cache.series = [NSMutableArray arrayWithObject:plot];
    return cache;

}


+(GCSimpleGraphCachedDataSource*)fieldHistoryCacheFrom:(GCHistoryFieldDataSerie*)history andMovingAverage:(NSUInteger)samples{
    GCSimpleGraphCachedDataSource * cache = [GCSimpleGraphCachedDataSource dataSourceWithStandardColors];
    cache.xUnit = [history xUnit];
    cache.title = [history title];

    GCSimpleGraphDataHolder * plot = [GCSimpleGraphDataHolder dataHolder:[history dataSerie:0]
                                                                    type:gcGraphLine color:[GCViewConfig colorForGraphElement:gcSkinGraphColorForeground]
                                                                 andUnit:[history yUnit:0]];

    if (samples > 0) {
        GCSimpleGraphDataHolder * ma = [GCSimpleGraphDataHolder dataHolder:[[history dataSerie:0] movingAverage:samples]
                                                                            type:gcGraphLine
                                                                           color:[GCViewConfig colorForGraphElement:gcSkinGraphColorRegressionLine]
                                                                         andUnit:[history yUnit:0]];
        ma.lineWidth = 2.;

        cache.series = [NSMutableArray arrayWithObjects:plot, ma, nil];
    }else{
        cache.series = [NSMutableArray arrayWithObject:plot];
    }
    return cache;

}

+(GCSimpleGraphCachedDataSource*)dayActivityFieldFrom:(GCTrackStats*)trackStats{
    GCSimpleGraphCachedDataSource * cache = [GCSimpleGraphCachedDataSource dataSourceWithStandardColors];
    cache.xUnit = [trackStats xUnit];
    cache.title = [trackStats title];

    return cache;
}

+(GCSimpleGraphCachedDataSource*)trackFieldFrom:(GCTrackStats*)trackStats{
    // Needed or should be trackStats.movingAverage?
    NSUInteger samples = [trackStats.field isNoisy] ? 60 : 0;

    GCSimpleGraphCachedDataSource * cache = [GCSimpleGraphCachedDataSource dataSourceWithStandardColors];
    cache.xUnit = [trackStats xUnit];
    cache.title = [trackStats title];
    if (trackStats.x_field) {
        cache.title = [NSString stringWithFormat:@"%@ x %@",
                       [trackStats title],
                       [trackStats.x_field displayNameWithUnits:trackStats.xUnit]
                       ];

        GCSimpleGraphDataHolder * xy = [GCSimpleGraphDataHolder dataHolder:[trackStats dataSerie:0]
                                                                      type:gcScatterPlot
                                                                     color:[GCViewConfig colorForGraphElement:gcSkinGraphColorForeground]
                                                                   andUnit:[trackStats yUnit:0]];
        if (trackStats.x_field.fieldFlag == gcFieldFlagSumDistance) {
            xy.graphType = gcGraphLine;
            xy.lineWidth = 1.;
            xy.color = [GCViewConfig colorForGraphElement:gcSkinGraphColorForeground];
        }else{
            xy.gradientFunction = trackStats.gradientFunction;
            xy.gradientDataSerie = trackStats.gradientSerie;
            xy.gradientSerieXUnit = [GCUnit unitForKey:@"second"];
            if (trackStats.highlightLap) {
                xy.gradientColors = [GCViewGradientColors gradientColorsRainbowHighlight16];
            }else{
                xy.gradientColors = [GCViewGradientColors gradientColorsRainbow16];
            }
        }
        GCStatsLinearFunction * reg = [[trackStats dataSerie:0] regression];
        GCStatsDataSerie * line = [reg valueForXIn:[trackStats dataSerie:0]];
        [line sortByX];
        GCSimpleGraphDataHolder * lineinfo = [GCSimpleGraphDataHolder dataHolder:line
                                                                            type:gcGraphLine
                                                                           color:[GCViewConfig colorForGraphElement:gcSkinGraphColorLineGraph]
                                                                         andUnit:[trackStats yUnit:0]];
        cache.series = [NSMutableArray arrayWithObjects:xy, lineinfo, nil];

    }else{

        GCSimpleGraphDataHolder * plot = [GCSimpleGraphDataHolder dataHolder:[trackStats dataSerie:0]
                                                                        type:gcGraphLine
                                                                       color:[GCViewConfig colorForGraphElement:gcSkinGraphColorLineGraph]
                                                                     andUnit:[trackStats yUnit:0]];
        // If line field, setup gradient Function with value of the line field
        // otherwise, use fill color
        if (trackStats.l_field!=nil || trackStats.highlightLap) {
            plot.gradientFunction = trackStats.gradientFunction;
            plot.gradientDataSerie = trackStats.gradientSerie;
            if (trackStats.l_field!=gcFieldFlagNone) {
                plot.gradientColors = [GCViewGradientColors gradientColorsRainbow16];
                plot.lineWidth = 3.;
            }else{
                plot.gradientColorsFill = [GCViewGradientColors gradientColorsTrackHighlight:[GCViewConfig fillColorForField:trackStats.field] alpha:0.1];
                plot.gradientColors = [GCViewGradientColors gradientColorsTrackHighlight:[GCViewConfig colorForGraphElement:gcSkinGraphColorLineGraph] alpha:0.3];
                plot.lineWidth = 1.;
            }
        }else{
            plot.fillColorForSerie = [GCViewConfig fillColorForField:trackStats.field];
        }

        if ((trackStats.activity).garminSwimAlgorithm) {
            plot.graphType = gcGraphStep;
            plot.gradientColors = [GCViewSwimStrokeColors swimStrokeColors];
            plot.gradientDataSerie = trackStats.gradientSerie;
            cache.series = [NSMutableArray arrayWithObject:plot];
        }else if (trackStats.zoneCalculator){
            plot.graphType = gcGraphStep;
            plot.color = [GCViewConfig colorForGraphElement:gcSkinGraphColorBarGraph];
            plot.yUnit = [GCUnit unitForKey:@"second"];
            cache.xUnit = [GCUnitTrainingZone unitTrainingZoneFor:trackStats.zoneCalculator];
            cache.xAxisIsVertical = [GCAppGlobal configGetBool:CONFIG_ZONE_GRAPH_HORIZONTAL defaultValue:true];
            gcStatsRange range = [plot.dataSerie range];
            // FIX find better way to encapsulate
            [plot.dataSerie addDataPointWithX:range.x_max+1 andY:0.];
            plot.range = [plot.dataSerie range];

            NSArray * colors = [GCViewConfig colorsForField:trackStats.field];
            if (colors && colors.count > 1) {

                BOOL betterIsMin = [trackStats.zoneCalculator betterIsMin];

                plot.gradientColors = [GCViewGradientColors gradientColors:trackStats.zoneCalculator.zones.count
                                                                      from:betterIsMin ? [colors lastObject] : [colors firstObject]
                                                                        to:betterIsMin ? [colors firstObject] : [colors lastObject]];
                plot.gradientFunction = [GCStatsScaledXIndexFunction scaledXIndexFunctionFor:plot.dataSerie];
                plot.gradientDataSerie = plot.dataSerie;
            }

            if (trackStats.highlightLap) {
                GCSimpleGraphDataHolder * full = [GCSimpleGraphDataHolder dataHolder:trackStats.extra_data[0].serie type:gcGraphStep color:plot.color andUnit:plot.yUnit];
                [full.dataSerie addDataPointNoValueWithX:range.x_max];
                full.range = [plot.dataSerie range];
                plot.color = [GCViewConfig colorForGraphElement:gcSkinGraphColorLapOverlay];
                cache.series = [NSMutableArray arrayWithObjects:plot,full, nil];
            }else{
                cache.series = [NSMutableArray arrayWithObject:plot];
            }
        }else{
            NSMutableArray * seriesArray = [NSMutableArray arrayWithObject:plot];

            if (trackStats.statsStyle==gcTrackStatsHistogram) {
                plot.graphType = gcGraphStep;
                plot.color = [GCViewConfig colorForGraphElement:gcSkinGraphColorBarGraph];

                NSArray * colors = [GCViewConfig colorsForField:trackStats.field];
                if (colors && colors.count > 1) {
                    BOOL betterIsMin = [trackStats.xUnit betterIsMin];

                    plot.gradientColors = [GCViewGradientColors gradientColors:MIN(16, plot.dataSerie.count)
                                                                          from:betterIsMin ? [colors lastObject] : [colors firstObject]
                                                                            to:betterIsMin ? [colors firstObject] : [colors lastObject]];
                    plot.gradientFunction = [GCStatsScaledXIndexFunction scaledXIndexFunctionFor:plot.dataSerie];
                    plot.gradientDataSerie = plot.dataSerie;
                }

                cache.title = [NSString stringWithFormat:NSLocalizedString(@"Histogram %@", @"Graph Title"), cache.title];
            }
            else if (trackStats.statsStyle==gcTrackStatsRollingBest) {
                cache.emptyGraphLabel = NSLocalizedString(@"Calculating...", @"Calculating Graph Label");
            } else if (trackStats.statsStyle == gcTrackStatsBucket){
                plot.graphType = gcGraphStep;
                plot.color = [GCViewConfig fillColorForField:trackStats.field];
            }
            if (trackStats.statsStyle==gcTrackStatsData && trackStats.activity.lapCount>1) {
                // Add Laps overlay
                if ([GCAppGlobal configGetBool:CONFIG_GRAPH_LAP_OVERLAY defaultValue:true]) {
                    // Not very useful for elevation graphs...
                    if (trackStats.field.fieldFlag != gcFieldFlagAltitudeMeters) {
                        UIColor * lapColor = [GCViewConfig colorForGraphElement:gcSkinGraphColorLapOverlay];
                        GCStatsDataSerieWithUnit * lapSerie = [trackStats.activity lapSerieForTrackField:trackStats.field timeAxis:YES];
                        GCSimpleGraphDataHolder * lap = [GCSimpleGraphDataHolder dataHolder:lapSerie.serie type:gcGraphStep color:lapColor andUnit:[trackStats yUnit:0]];
                        
                        if( trackStats.highlightLap){
                            GCStatsDataSerieWithUnit * gradientSerie = [trackStats.activity highlightLapSerieForLap:trackStats.highlightLapIndex timeAxis:YES];
                            lap.gradientDataSerie = gradientSerie.serie;
                            lap.gradientColorsFill = [GCViewGradientColors gradientColorsTrackHighlight:lapColor alpha:0.1];
                            lap.gradientColors = [GCViewGradientColors gradientColorsTrackHighlight:lapColor alpha:0.1];
                        }
                        [seriesArray insertObject:lap atIndex:0];
                    }
                }
            }
            
            if( [trackStats nDataSeries]>1){
                for( NSUInteger i = 1; i < [trackStats nDataSeries]; i++){
                    GCSimpleGraphDataHolder * extra = [GCSimpleGraphDataHolder dataHolder:[trackStats dataSerie:i]
                                                                                     type:gcGraphLine
                                                                                    color:[GCViewConfig colorForGraphElement:gcSkinGraphColorRegressionLine]
                                                                                  andUnit:[trackStats yUnit:i]];
                    extra.lineWidth = 2.;
                    [seriesArray addObject:extra];
                }
            }
            if (samples > 0 && trackStats.statsStyle == gcTrackStatsData) {
                GCSimpleGraphDataHolder * ma = [GCSimpleGraphDataHolder dataHolder:[[trackStats dataSerie:0] movingAverage:samples]
                                                                              type:gcGraphLine
                                                                             color:[GCViewConfig colorForGraphElement:gcSkinGraphColorRegressionLine]
                                                                           andUnit:[trackStats yUnit:0]];


                ma.lineWidth = 2.;
                if (ma.dataSerie.count>0) {
                    [seriesArray addObject:ma];
                }
            }
            cache.series = seriesArray;
        }
    }
    return cache;
}

+(GCStatsDataSerie*)adjustedSerie:(GCStatsDataSerieWithUnit*)serie field:(gcFieldFlag)flag logScale:(GCUnitLogScale*)logScale{
    GCStatsDataSerie * rv = serie.serie;

    GCStatsDataSerieWithUnit * nu = serie;

    if(logScale){
        nu = [nu dataSerieConvertedToXUnit:logScale];
        rv = nu.serie;
    }
    if (flag == gcFieldFlagWeightedMeanSpeed) {
        gcStatsRange range = serie.serie.range;
        GCNumberWithUnit * min = [[GCNumberWithUnit numberWithUnitName:@"meter" andValue:400.] convertToUnit:nu.xUnit];
        range.x_min = MAX(range.x_min, min.value);
        rv = [nu.serie serieReducedToRange:range];
    }
    return rv;
}


+(GCSimpleGraphCachedDataSource*)derivedHist:(GCStatsDerivedHistory*)config
                                       field:(GCField*)field
                                      series:(GCStatsSerieOfSerieWithUnits*)serieOfSeries
                                       width:(CGFloat)width{
    
    NSArray<GCNumberWithUnit*>*points = config.pointsForGraphs;
    NSTimeInterval unitForLongTerm = config.longTermPeriod.timeInterval;
    NSTimeInterval unitForShortTerm = config.shortTermPeriod.timeInterval;
    
    BOOL adjustShortTerm = (config.shortTermPeriod.numberOfDays != 0);
    
    NSArray<UIColor*>*colors = [GCViewConfig arrayOfColorsForMultiplots];
    GCSimpleGraphCachedDataSource * rv = [GCSimpleGraphCachedDataSource dataSourceWithStandardColors];

    GCStatsDataSerie * firstLongTerm = nil;
    GCStatsDataSerie * firstShortTerm = nil;
    
    double (^sampleMax)(NSArray<GCStatsDataPoint*>*) = ^(NSArray<GCStatsDataPoint*>*samples){
        double max = samples.firstObject.y_data;
        for (GCStatsDataPoint * point in samples) {
            if( point.y_data > max){
                max = point.y_data;
            }
        }
        return max;
    };
    
    NSUInteger i=0;
    for (GCNumberWithUnit * point in points) {
        if( i < colors.count){
            UIColor * color = colors[i];
            
            GCStatsDataSerieWithUnit * one = [serieOfSeries serieForX:point];
            GCStatsDataSerie * longTerm = one.serie;
            GCStatsDataSerie * shortTerm = one.serie;
                        
            if( firstLongTerm == nil){
                firstLongTerm = longTerm;
                firstShortTerm = shortTerm;
            }else{
                GCStatsDataSerie * longTermFinalSerie = longTerm;
                GCStatsDataSerie * shortTermFinalSerie = shortTerm;
                if( config.mode == gcDerivedHistModeDrop ){
                    shortTermFinalSerie = [shortTerm operate:gcStatsOperandMinus with:firstShortTerm];
                    longTermFinalSerie = [longTerm operate:gcStatsOperandMinus with:firstLongTerm];
                }
                
                if (config.longTermSmoothing == gcDerivedHistSmoothingMax){
                    longTermFinalSerie = [longTermFinalSerie movingFunctionForUnit:unitForLongTerm function:sampleMax];
                }else{
                    longTermFinalSerie = [longTermFinalSerie movingAverageForUnit:unitForLongTerm];
                }
                if( adjustShortTerm ){
                    if( config.shortTermSmoothing == gcDerivedHistSmoothingMax){
                        shortTermFinalSerie = [shortTermFinalSerie movingFunctionForUnit:unitForShortTerm function:sampleMax];
                    }else{
                        shortTermFinalSerie = [shortTermFinalSerie movingAverageForUnit:unitForShortTerm];
                    }
                }

                GCSimpleGraphDataHolder * holderLongTerm = [GCSimpleGraphDataHolder dataHolder:longTermFinalSerie
                                                                                          type:gcGraphBezier
                                                                                         color:color
                                                                                       andUnit:one.unit];
                GCSimpleGraphDataHolder * holderShortTerm = [GCSimpleGraphDataHolder dataHolder:shortTermFinalSerie
                                                                                           type:gcGraphBezier
                                                                                          color:[color colorWithAlphaComponent:0.5]
                                                                                        andUnit:one.unit];
                holderLongTerm.lineWidth = 2.0;
                
                if( config.mode == gcDerivedHistModeDrop){
                    holderLongTerm.legend = [NSString stringWithFormat:@"%@ dCP", point];
                }
                else{
                    holderLongTerm.legend = [NSString stringWithFormat:@"CP %@", point];
                }
                [rv addDataHolder:holderLongTerm];
                [rv addDataHolder:holderShortTerm];
            }
            i++;
        }
    }
    
    if( config.longTermSmoothing == gcDerivedHistSmoothingMax ){
        rv.title = [NSString stringWithFormat:@"%@ Max %@", config.longTermPeriod.displayName, field.correspondingBestRollingField.displayName];
    }else{
        rv.title = [NSString stringWithFormat:@"%@ %@ Trend ", field.correspondingBestRollingField.displayName, config.longTermPeriod.displayName];
    }
    rv.xUnit = [GCUnit unitForKey:@"datemonth"];
    
    return rv;
}


+(GCSimpleGraphCachedDataSource*)derivedDataSingleHighlighted:(GCField*)field
                                                       period:(gcDerivedPeriod)period
                                                      forDate:(NSDate*)date
                                                  addLegendTo:(NSMutableArray<GCSimpleGraphLegendInfo*>*)legends
                                                        width:(CGFloat)width{
    gcFieldFlag fieldflag = field.fieldFlag;
    GCSimpleGraphCachedDataSource * rv = [GCSimpleGraphCachedDataSource dataSourceWithStandardColors];
    
    GCDerivedDataSerie * serie = [[GCAppGlobal derived] derivedDataSerie:gcDerivedTypeBestRolling
                                                                   field:field
                                                                  period:period
                                                                 forDate:date];
    
    GCDerivedDataSerie * serieCompare = [[GCAppGlobal derived] derivedDataSerie:gcDerivedTypeBestRolling
                                                                          field:field
                                                                         period:period == gcDerivedPeriodMonth ? gcDerivedPeriodYear : gcDerivedPeriodMonth
                                                                        forDate:date];
    
    NSMutableArray<NSString*>*labels = [NSMutableArray array];
    
    NSMutableDictionary<NSString*,NSNumber*>*labelsIndexes = [NSMutableDictionary dictionary];
    
    NSUInteger labelIndex = 0;
    
    NSArray<UIColor*>*colors = [GCViewConfig arrayOfColorsForMultiplots];
    GCViewGradientColors * gradientColors = [GCViewGradientColors gradientColorsWith:colors];
    GCViewGradientColors * gradientColorsFill = [gradientColors gradientAsBackgroundWithAlpha:0.4];
    
    if( period == gcDerivedPeriodMonth ){
        NSArray<GCActivity*>*bestActivities = [[GCAppGlobal derived] bestMatchingActivitySerieFor:serie within:[[GCAppGlobal organizer] activities] completion:nil];
        for (GCActivity * act in bestActivities) {
            NSString * label = [act.date calendarUnitFormat:NSCalendarUnitDay];
            [labels addObject:label];
            if( labelsIndexes[label] == nil){
                labelsIndexes[label] = @(labelIndex);
                
                if( labelIndex < colors.count){
                    GCSimpleGraphLegendInfo * info = [[GCSimpleGraphLegendInfo alloc] init];
                    info.text = label;
                    
                    info.color = gradientColorsFill.colors[labelIndex];
                    info.lineWidth = 5;
                    [legends addObject:info];
                    RZRelease(info);
                }
                labelIndex++;
            }
        }
    }else{
        NSArray<GCDerivedDataSerie*>*bestSeries = [[GCAppGlobal derived] bestMatchingDerivedSerieFor:serie completion:nil];
        for (GCDerivedDataSerie * one in bestSeries) {
            NSString * label = [one.bucketStart calendarUnitFormat:NSCalendarUnitMonth];
            [labels addObject:label];
            if( labelsIndexes[label] == nil){
                labelsIndexes[label] = @(labelIndex);
                if( labelIndex < colors.count){
                    GCSimpleGraphLegendInfo * info = [[GCSimpleGraphLegendInfo alloc] init];
                    info.text = label;
                    info.color = gradientColorsFill.colors[labelIndex];
                    info.lineWidth = 5;
                    [legends addObject:info];
                    RZRelease(info);
                }
                labelIndex++;
            }
        }
    }
    
    GCUnit * xUnit = serie.serieWithUnit.xUnit;
    if (xUnit == nil) {
        if (fieldflag == gcFieldFlagWeightedMeanSpeed) {
            xUnit = [[GCUnit unitForKey:@"kilometer"] unitForGlobalSystem];
        }else{
            xUnit = [GCUnit unitForKey:@"second"];
        }
    }
    
    GCUnitLogScale * logScale = nil;
    if( fieldflag == gcFieldFlagPower && [GCAppGlobal configGetBool:CONFIG_POWER_CURVE_LOG_SCALE defaultValue:true]){
        logScale = [GCUnitLogScale logScaleUnitFor:xUnit base:10. scaling:0.05 shift:1.];
        xUnit = logScale;
    }
    
    GCStatsDataSerie * graphSerie = nil;
    GCStatsDataSerie * graphSerieCompare = nil;
    
    if( logScale ){
        graphSerie = [[GCStatsDataSerieWithUnit dataSerieWithOther:serie.serieWithUnit] convertToXUnit:logScale].serie;
        graphSerieCompare = [[GCStatsDataSerieWithUnit dataSerieWithOther:serieCompare.serieWithUnit] convertToXUnit:logScale].serie;
    }else{
        graphSerie = serie.serieWithUnit.serie;
        graphSerieCompare = serieCompare.serieWithUnit.serie;
    }
    GCStatsDataSerie * gradientSerie = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);
    
    for (NSUInteger idx = 0; idx < MIN(labels.count,graphSerie.count); idx++) {
        NSString * label = labels[idx];
        NSUInteger labelIndex = labelsIndexes[label].integerValue;
        GCStatsDataPoint * point = [graphSerie dataPointAtIndex:idx];
        if( labelIndex < colors.count){
            [gradientSerie addDataPointWithX:point.x_data andY:labelIndex];
        }else{
            // Last color for all the other ones
            [gradientSerie addDataPointWithX:point.x_data andY:colors.count-1];
        }
    }
    
    UIColor * defaultColor = [GCViewConfig defaultColor:gcSkinDefaultColorPrimaryText];
    
    GCSimpleGraphDataHolder * holder = [GCSimpleGraphDataHolder dataHolder:graphSerie
                                                                      type:gcGraphLine
                                                                     color:defaultColor
                                                                   andUnit:serie.serieWithUnit.unit];
    holder.fillColorForSerie = [UIColor colorWithWhite:0.5 alpha:0.6]; // fill for gradient will only use alpha.
    GCSimpleGraphDataHolder * holderCompare = [GCSimpleGraphDataHolder dataHolder:graphSerieCompare
                                                                             type:gcGraphLine
                                                                            color:[GCViewConfig colorForGraphElement:gcSkinGraphColorLapOverlay]
                                                                          andUnit:serie.serieWithUnit.unit];
    
    holder.gradientColors = gradientColors;
    holder.gradientColorsFill = gradientColorsFill;
    holder.gradientDataSerie = gradientSerie;
    
    holder.lineWidth = 1.;
    [rv addDataHolder:holder];
    [rv addDataHolder:holderCompare];
    
    rv.title =[NSString stringWithFormat:NSLocalizedString(@"Best %@ for %@", @"Best Rolling Curve"),[field displayName],period == gcDerivedPeriodMonth ? [date calendarUnitFormat:NSCalendarUnitMonth] : [date calendarUnitFormat:NSCalendarUnitYear]];
    rv.xUnit = xUnit;
    
    return rv;
    
}

+(GCSimpleGraphCachedDataSource*)derivedData:(GCField*)field
                                          forDate:(NSDate*)date
                                       width:(CGFloat)width{
    

    gcFieldFlag fieldflag = field.fieldFlag;
    GCSimpleGraphCachedDataSource * rv = [GCSimpleGraphCachedDataSource dataSourceWithStandardColors];

    GCDerivedDataSerie * serie = [[GCAppGlobal derived] derivedDataSerie:gcDerivedTypeBestRolling
                                                                   field:field
                                                                  period:gcDerivedPeriodMonth
                                                                 forDate:date];
    if ([serie isEmpty]) {
        fieldflag = gcFieldFlagWeightedMeanSpeed;
        serie =[[GCAppGlobal derived] derivedDataSerie:gcDerivedTypeBestRolling
                                                 field:field
                                                period:gcDerivedPeriodMonth
                                               forDate:date];
    }

    GCUnit * xUnit = serie.serieWithUnit.xUnit;
    if (xUnit == nil) {
        if (fieldflag == gcFieldFlagWeightedMeanSpeed) {
            xUnit = [[GCUnit unitForKey:@"kilometer"] unitForGlobalSystem];
        }else{
            xUnit = [GCUnit unitForKey:@"second"];
        }
    }

    GCUnitLogScale * logScale = nil;
    if( fieldflag == gcFieldFlagPower && [GCAppGlobal configGetBool:CONFIG_POWER_CURVE_LOG_SCALE defaultValue:true]){
        logScale = [GCUnitLogScale logScaleUnitFor:xUnit base:10. scaling:0.05 shift:1.];
        xUnit = logScale;
    }

    NSArray<UIColor*>* colors = [GCViewConfig arrayOfColorsForMultiplots];
    UIColor * defaultColor = [GCViewConfig defaultColor:gcSkinDefaultColorPrimaryText];

    GCSimpleGraphDataHolder * mth = [GCSimpleGraphDataHolder dataHolder:[self adjustedSerie:serie.serieWithUnit field:fieldflag logScale:logScale]
                                                                  type:gcGraphLine
                                                                  color:colors.count > 0 ? colors[0] : defaultColor
                                                               andUnit:serie.serieWithUnit.unit];


    mth.lineWidth = 2.;
    mth.fillColorForSerie = [GCViewConfig fillColorForField:field];
    mth.legend = [date calendarUnitFormat:NSCalendarUnitMonth];

    NSDateComponents * comp = [[NSDateComponents alloc] init];
    comp.month = -1;
    NSDate * prevMonth = [date dateByAddingGregorianComponents:comp];
    comp.month = 0;
    comp.year = -1;
    NSDate * prevYear = [date dateByAddingGregorianComponents:comp];
    [comp release];

    serie = [[GCAppGlobal derived] derivedDataSerie:gcDerivedTypeBestRolling
                                              field:field
                                             period:gcDerivedPeriodMonth
                                            forDate:prevMonth];

    GCSimpleGraphDataHolder * pmth = [GCSimpleGraphDataHolder dataHolder:[self adjustedSerie:serie.serieWithUnit field:fieldflag logScale:logScale]
                                                                   type:gcGraphLine
                                                                  color:colors.count > 1 ? colors[1] : defaultColor
                                                                andUnit:serie.serieWithUnit.unit];

    pmth.legend = [prevMonth calendarUnitFormat:NSCalendarUnitMonth];

    serie = [[GCAppGlobal derived] derivedDataSerie:gcDerivedTypeBestRolling
                                              field:field
                                             period:gcDerivedPeriodYear
                                            forDate:date];

    GCSimpleGraphDataHolder * year = [GCSimpleGraphDataHolder dataHolder:[self adjustedSerie:serie.serieWithUnit field:fieldflag logScale:logScale]
                                                                   type:gcGraphLine
                                                                  color:[[GCViewConfig fillColorForField:field] colorWithAlphaComponent:0.5]
                                                                andUnit:serie.serieWithUnit.unit];
    year.legend = [date calendarUnitFormat:NSCalendarUnitYear];
    year.fillColorForSerie = [[GCViewConfig fillColorForField:field] colorWithAlphaComponent:0.5];

    serie = [[GCAppGlobal derived] derivedDataSerie:gcDerivedTypeBestRolling
                                              field:field
                                             period:gcDerivedPeriodYear
                                            forDate:prevYear];

    GCSimpleGraphDataHolder * pyear = [GCSimpleGraphDataHolder dataHolder:[self adjustedSerie:serie.serieWithUnit field:fieldflag logScale:logScale]
                                                                    type:gcGraphLine
                                                                       color:colors.count > 2 ? colors[2] : defaultColor
                                                                 andUnit:serie.serieWithUnit.unit];
    pyear.legend = [prevYear calendarUnitFormat:NSCalendarUnitYear];
    //pyear.lineWidth = 5;


    rv.xUnit = xUnit;

    rv.series = [NSMutableArray array];
    BOOL hasOne = false;
    for (GCSimpleGraphDataHolder * holder in @[year,mth,pmth,pyear]) {
        if (!holder.isEmpty) {
            [rv addDataHolder:holder];
            hasOne = true;
        }
    }
    if (hasOne) {
        rv.title =[NSString stringWithFormat:NSLocalizedString(@"Best %@", @"Best Rolling Curve"),field.correspondingBestRollingField.displayName];
    }

    return rv;
}

+(GCSimpleGraphCachedDataSource*)performanceAnalysis:(GCHistoryPerformanceAnalysis*)perfAnalysis width:(CGFloat)width{
    GCSimpleGraphCachedDataSource * rv = [GCSimpleGraphCachedDataSource dataSourceWithStandardColors];

    rv.xUnit = [GCUnit unitForKey:@"datemonth"];

    GCSimpleGraphDataHolder * lt = [GCSimpleGraphDataHolder dataHolder:perfAnalysis.longTermSerie.serie
                                                                  type:gcGraphBezier
                                                                 color:[GCViewConfig colorForGraphElement:gcSkinGraphColorRegressionLine]
                                                               andUnit:perfAnalysis.longTermSerie.unit];
    lt.lineWidth =2;
    lt.legend = NSLocalizedString(@"Fitness", @"Performance");
    GCSimpleGraphDataHolder * st = [GCSimpleGraphDataHolder dataHolder:perfAnalysis.shortTermSerie.serie
                                                                  type:gcGraphBezier
                                                                 color:[GCViewConfig colorForGraphElement:gcSkinGraphColorRegressionLineSecondary]
                                                               andUnit:perfAnalysis.shortTermSerie.unit];
    st.legend = NSLocalizedString(@"Fatigue", @"Performance");
    GCUnitPerformanceRange * unit = [GCUnitPerformanceRange performanceUnitFrom:st.range.y_min to:st.range.y_max];
    st.yUnit = unit;
    lt.yUnit = unit;
    //NSString * scaleDesc = [GCFields fieldDisplayName:perfAnalysis.scalingField activityType:perfAnalysis.activityType];
    //NSString * sumdesc   = [GCFields fieldDisplayName:perfAnalysis.summableField activityType:perfAnalysis.activityType];
    rv.title = [NSString stringWithFormat:NSLocalizedString(@"Performance %@", @"Graph Title"), perfAnalysis.seriesDescription];
    rv.series = [NSMutableArray arrayWithObjects: st, lt, nil];
    return rv;
}
@end
