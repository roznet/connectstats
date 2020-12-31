//  MIT Licence
//
//  Created on 04/11/2015.
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

#import "GCTestUISamples.h"
#import "ConnectStats-Swift.h"
#import "GCSimpleGraphCachedDataSource+Templates.h"
#import "GCHistoryFieldDataSerie.h"
#import "GCHistoryFieldDataSerie+Test.h"
#import "GCViewSwimStrokeColors.h"
#import "GCActivity+Import.h"
#import "GCTrackStats.h"
#import "GCCellGrid+Test.h"
#import "GCCellGrid+Templates.h"
#import "GCHistoryAggregatedActivityStats.h"
#import "GCTestIconsCell.h"
#import "GCTestUISampleCellHolder.h"
#import "GCActivity+Database.h"
#import "GCStatsMultiFieldViewController.h"
#import "GCStatsMultiFieldViewControllerConsts.h"
#import "GCCellHealthDayActivity.h"
#import "GCTrackFieldChoices.h"
#import "GCTestsSamples.h"
#import "GCActivity+Series.h"
#import "GCConnectStatsRequestFitFile.h"
#import "GCGarminActivityTrack13Request.h"
#import "GCGarminRequestActivityReload.h"
#import "GCStatsDerivedHistory.h"
#import "GCTestAppGlobal.h"
#import "GCActivitiesOrganizer.h"
#import "ConnectStats-Swift.h"
#import "GCActivityDetailViewController.h"
#import "GCActivity+Fields.h"

@import RZUtilsSwift;

@implementation GCTestUISamples

#pragma mark - DataSource Samples

-(NSArray*)dataSourceSamples{
    //[self loadDataSourceSamples];

    // use the NSStringFromSelector(@Selector()) idiom so
    // xcode warns about undefined selectors
    NSArray<NSString*> * selectorNames = @[

                                           NSStringFromSelector(@selector(sample1_simpleLines)),
                                           NSStringFromSelector(@selector(sample2_SimpleSinusPlot)),
                                           NSStringFromSelector(@selector(sample3_WikipediaSampleRegression)),
                                           NSStringFromSelector(@selector(sample5_trackSerieScatterPlot)),
                                           NSStringFromSelector(@selector(sample6_simpleBarGraph)),
                                           NSStringFromSelector(@selector(sample7_historyCumulativeGraph)),
                                           NSStringFromSelector(@selector(sample8_historyBarGraphCoarse)),
                                           NSStringFromSelector(@selector(sample9_trackFieldMultipleLineGraphs)),
                                           NSStringFromSelector(@selector(sample10_swimBarGraphFine)),
                                           NSStringFromSelector(@selector(sample11_cumulativeHist)),
                                           NSStringFromSelector(@selector(sample12_trackStats)),
                                           NSStringFromSelector(@selector(sample13_compareStats)),
                                           NSStringFromSelector(@selector(sample14_SimpleGradientFillPlot)),
                                           NSStringFromSelector(@selector(sample15_HistDerivedGraphs)),


                                           ];


    NSMutableArray * rv = [NSMutableArray array];
    @autoreleasepool {
        [GCTestAppGlobal setupSampleState:@"sample_activities.db"];
        
        NSString * filter = nil;
        NSInteger which = -1;
        // DONT CHECKIN
        //filter = @"sample15_";
        //which = 2;
        if( filter ){
            for (NSString * one in selectorNames) {
                if( [one containsString:filter] ){
                    selectorNames = @[ one ];
                    break;
                }
            }
        }
        
        for (NSString * selectorName in selectorNames) {
            
            NSArray<GCTestUISampleDataSourceHolder*> * sources = [self dataSourceHolderFor:NSSelectorFromString(selectorName)];
            if( filter != nil && which >= 0 && which < sources.count ){
                sources = @[ sources[which] ];
            }
            for (GCTestUISampleDataSourceHolder * holder in sources) {
                [rv addObject:holder];
            }
        }
    }
    return  rv;
}

-(NSArray<GCTestUISampleDataSourceHolder*>*)dataSourceHolderFor:(SEL)selector{
    NSArray< GCTestUISampleDataSourceHolder* > * rv = nil;

    id val = [self performSelector:selector];
    if( [val isKindOfClass:[NSArray class] ] ){
        NSMutableArray< GCTestUISampleDataSourceHolder*> * holders = [NSMutableArray array];
        NSArray * dataSources = val;
        NSUInteger i = 0;
        for (GCSimpleGraphCachedDataSource * source in dataSources) {
            NSString * identifier = NSStringFromSelector(selector);
            if (i>0) {
                identifier = [NSString stringWithFormat:@"%@[%lu]", identifier, (unsigned long)i];
            }
            [holders addObject:[GCTestUISampleDataSourceHolder holderFor:source andIdentifier:identifier]];
            i++;
        }
        rv = holders;

    }else if( [val isKindOfClass:[GCSimpleGraphCachedDataSource class]]){
        rv = @[ [GCTestUISampleDataSourceHolder holderFor:val andIdentifier:NSStringFromSelector(selector)] ];
    }

    return rv;
}

-(NSArray<GCSimpleGraphCachedDataSource*>*)sample1_simpleLines{
    
    NSMutableArray<GCSimpleGraphCachedDataSource*>*rv = [NSMutableArray array];
    
    GCStatsDataSerie * data = [[GCStatsDataSerie alloc] init];
    GCStatsDataSerie * data2 = [[GCStatsDataSerie alloc] init];
    double x = 0.;
    [data addDataPointWithX:x andY:0.5]; x+=1.;
    [data addDataPointWithX:x andY:0.6]; x+=1.;

    for (size_t i = 0; i<5; i++) {
        [data addDataPointWithX:x andY:1.]; x+=1.;
    }
    double x0=x;
    for (size_t i = 0; i<5; i++) {
        [data2 addDataPointWithX:x andY:0.5+1.*(x-x0)/5.];
        [data addDataPointWithX:x andY:2.]; x+=1.;
    }
    
    GCSimpleGraphCachedDataSource * sample = [[[GCSimpleGraphCachedDataSource alloc] init] autorelease];
    GCSimpleGraphDataHolder * h = [GCSimpleGraphDataHolder dataHolder:data
                                                                 type:gcGraphLine
                                                                color:[UIColor blackColor]
                                                              andUnit:[GCUnit unitForKey:@"mps"]];
    GCSimpleGraphDataHolder * h2 = [GCSimpleGraphDataHolder dataHolder:data2
                                                                  type:gcGraphLine
                                                                 color:[UIColor blueColor]
                                                               andUnit:[GCUnit unitForKey:@"mps"]];
    
    [sample setSeries:[NSMutableArray arrayWithObjects:h, h2, nil]];
    [sample setXUnit:[GCUnit unitForKey:@"second"]];
    [sample setTitle:@"Sample 1 [0]"];
    [data release];
    [data2 release];

    [rv addObject:sample];
    
    sample = [[[GCSimpleGraphCachedDataSource alloc] init] autorelease];
    GCStatsDataSerie * adjusted = [[GCStatsDataSerie alloc] init];
    GCStatsDataSerie * negative = [[GCStatsDataSerie alloc] init];
    for (GCStatsDataPoint * point in data) {
        if( point.x_data == 4.0){
            [adjusted addDataPointNoValueWithX:point.x_data];
            [negative addDataPointNoValueWithX:point.x_data];
        }else{
            [adjusted addDataPointWithX:point.x_data andY:point.y_data];
            [negative addDataPointWithX:point.x_data andY:point.y_data*-1];
        }
    }
    
    
    h = [GCSimpleGraphDataHolder dataHolder:adjusted type:gcGraphLine color:[UIColor blackColor] andUnit:[GCUnit unitForKey:@"mps"]];
    h.fillColorForSerie = [[UIColor redColor] colorWithAlphaComponent:0.5];
    
    [sample setSeries:[NSMutableArray arrayWithObjects:h, nil]];
    [sample setXUnit:[GCUnit unitForKey:@"second"]];
    [sample setTitle:@"Sample 1 [1]"];

    [rv addObject:sample];
    

    sample = [[[GCSimpleGraphCachedDataSource alloc] init] autorelease];
    GCSimpleGraphDataHolder * h3 = [GCSimpleGraphDataHolder dataHolder:negative
                                                                  type:gcGraphLine
                                                                 color:[UIColor blueColor]
                                                               andUnit:[GCUnit unitForKey:@"mps"]];
    h3.fillColorForSerie = [[UIColor redColor] colorWithAlphaComponent:0.5];
    
    [sample setSeries:[NSMutableArray arrayWithObjects:h3, nil]];
    [sample setXUnit:[GCUnit unitForKey:@"second"]];
    [sample setTitle:@"Sample 1 [2]"];

    [rv addObject:sample];

    return rv;

}

-(GCSimpleGraphCachedDataSource*)sample2_SimpleSinusPlot{
    GCStatsDataSerie * serie = [[GCStatsDataSerie alloc] init];
    for (double x = 0.; x < 10.; x+= 0.1) {
        [serie addDataPointWithX:x andY:sin(x)];
    }


    GCSimpleGraphCachedDataSource * sample = [[[GCSimpleGraphCachedDataSource alloc] init] autorelease];
    [sample addDataHolder:[GCSimpleGraphDataHolder dataHolder:serie type:gcGraphLine
                                                        color:[UIColor blueColor]
                                                      andUnit:[GCUnit unitForKey:@"percent"]]];
    [sample setXUnit:[GCUnit unitForKey:@"percent"]];
    [sample setTitle:@"sample 2"];

    [serie release];

    return sample;
}

-(GCSimpleGraphCachedDataSource*)sample3_WikipediaSampleRegression{
    GCStatsDataSerie * serie = [[GCStatsDataSerie alloc] init];
    [serie addDataPointWithX:147 andY:52.21];
    [serie addDataPointWithX:150 andY:53.12];
    [serie addDataPointWithX:152 andY:54.48];
    [serie addDataPointWithX:155 andY:55.84];
    [serie addDataPointWithX:157 andY:57.2];
    [serie addDataPointWithX:160 andY:58.57];
    [serie addDataPointWithX:163 andY:59.93];
    [serie addDataPointWithX:165 andY:61.29];
    [serie addDataPointWithX:168 andY:63.11];
    [serie addDataPointWithX:170 andY:64.47];
    [serie addDataPointWithX:173 andY:66.28];
    [serie addDataPointWithX:175 andY:68.1];
    [serie addDataPointWithX:178 andY:69.92];
    [serie addDataPointWithX:180 andY:72.19];
    [serie addDataPointWithX:183 andY:74.46];

    GCStatsLinearFunction * reg = [serie regression];
    GCStatsDataSerie * line = [reg valueForXIn:serie];

    GCUnit * kg = [GCUnit unitForKey:@"kilogram"];
    GCSimpleGraphCachedDataSource * sample = [[[GCSimpleGraphCachedDataSource alloc] init] autorelease];
    GCSimpleGraphDataHolder * scatter = [GCSimpleGraphDataHolder dataHolder:serie type:gcScatterPlot color:[UIColor blueColor] andUnit:kg];
    [sample setSeries:[NSMutableArray arrayWithObjects:scatter,
                       [GCSimpleGraphDataHolder dataHolder:line type:gcGraphLine color:[UIColor redColor] andUnit:kg],
                       nil]];
    [sample setXUnit:[GCUnit unitForKey:@"dimensionless"]];
    [sample setTitle:@"Height/Mass"];

    [serie release];

    return sample;
}


-(GCSimpleGraphCachedDataSource*)sample5_trackSerieScatterPlot{
    GCViewGradientColors * gradient = [GCViewGradientColors gradientColorsRainbow16];

    GCField * hrfield = [GCField fieldForFlag:gcFieldFlagWeightedMeanHeartRate andActivityType:GC_TYPE_RUNNING];
    GCField * pacefield = [GCField fieldForFlag:gcFieldFlagWeightedMeanSpeed andActivityType:GC_TYPE_RUNNING];

    GCHistoryFieldDataSerieConfig * config = [GCHistoryFieldDataSerieConfig configWithField:hrfield
                                                                                     xField:pacefield ];
    GCHistoryFieldDataSerie * history = [[[GCHistoryFieldDataSerie alloc] initFromConfig:config] autorelease];

    [history setupAndLoadForConfig:config withThread:nil];

    GCStatsDataSerie * gradientSerie = [[history gradientSerie] serie];
    GCStatsScaledFunction * gradientFunction = [GCStatsScaledFunction scaledFunctionWithSerie:gradientSerie];
    [gradientFunction setScale_x:true];

    GCSimpleGraphCachedDataSource * sample = [[[GCSimpleGraphCachedDataSource alloc] init] autorelease];
    GCSimpleGraphDataHolder * info = [GCSimpleGraphDataHolder dataHolder:[history dataSerie:0] type:gcScatterPlot color:[UIColor redColor] andUnit:[history yUnit:0]];
    [info setGradientColors:gradient];
    [info setGradientDataSerie:gradientSerie];
    [info setGradientFunction:gradientFunction];
    GCStatsLinearFunction * reg = [[history dataSerie:0] regression];
    GCStatsDataSerie * line = [reg valueForXIn:[history dataSerie:0]];
    GCSimpleGraphDataHolder * lineinfo = [GCSimpleGraphDataHolder dataHolder:line type:gcGraphLine color:[UIColor blueColor] andUnit:[history yUnit:0]];

    [sample setSeries:[NSMutableArray arrayWithObjects:info,lineinfo, nil]];
    [sample setXUnit:[history xUnit]];

    return sample;
}

-(NSArray<GCSimpleGraphCachedDataSource*>*)sample6_simpleBarGraph{
    GCStatsDataSerie * serie = [[GCStatsDataSerie alloc] init];
    [serie addDataPointWithX:0.  andY:2.];
    [serie addDataPointWithX:10. andY:1.];
    [serie addDataPointWithX:15. andY:0.];
    [serie addDataPointWithX:25. andY:1.];
    [serie addDataPointWithX:30. andY:3.];
    [serie addDataPointWithX:35. andY:0.];

    GCStatsDataSerie * stroke = [[GCStatsDataSerie alloc]init];
    [stroke addDataPointWithX:0.  andY:0.];
    [stroke addDataPointWithX:10. andY:0.];
    [stroke addDataPointWithX:15. andY:1.];
    [stroke addDataPointWithX:25. andY:2.];
    [stroke addDataPointWithX:30. andY:0.];
    [stroke addDataPointWithX:35. andY:1.];

    GCSimpleGraphCachedDataSource * sample = [[[GCSimpleGraphCachedDataSource alloc] init] autorelease];
    GCSimpleGraphDataHolder * holder =[GCSimpleGraphDataHolder dataHolder:serie
                                                                     type:gcGraphStep
                                                                    color:[UIColor blackColor]
                                                                  andUnit:[GCUnit unitForKey:@"kilogram"]];
    [holder setGradientDataSerie:stroke];
    [holder setGradientColors:[GCViewSwimStrokeColors swimStrokeColors]];
    [sample setSeries:[NSMutableArray arrayWithObject:holder]];
    [sample setXUnit:[GCUnit unitForKey:@"second"]];
    [sample setTitle:@"sample 6"];

    GCSimpleGraphCachedDataSource * sample2 = [[[GCSimpleGraphCachedDataSource alloc] init] autorelease];
    GCSimpleGraphDataHolder * holder2 =[GCSimpleGraphDataHolder dataHolder:serie
                                                                     type:gcGraphStep
                                                                    color:[UIColor blackColor]
                                                                  andUnit:[GCUnit unitForKey:@"kilogram"]];
    [holder2 setGradientDataSerie:stroke];
    [holder2 setGradientColors:[GCViewSwimStrokeColors swimStrokeColors]];
    [sample2 setSeries:[NSMutableArray arrayWithObject:holder]];
    [sample2 setXUnit:[GCUnit unitForKey:@"second"]];
    [sample2 setTitle:@"sample 6"];

    sample2.xAxisIsVertical = true;

    [serie release];
    [stroke release];

    return @[sample, sample2];
}

-(GCSimpleGraphCachedDataSource*)sample7_historyCumulativeGraph{

    GCField * distfield = [GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:GC_TYPE_RUNNING];

    GCHistoryFieldDataSerieConfig * config = [GCHistoryFieldDataSerieConfig configWithField:distfield xField:nil];
    GCHistoryFieldDataSerie * history = [[[GCHistoryFieldDataSerie alloc] initFromConfig:config] autorelease];

    [history setDb:[GCAppGlobal db]];
    [history loadFromDb:nil];
    
    GCSimpleGraphCachedDataSource * sample = [GCSimpleGraphCachedDataSource historyView:history
                                                                           calendarConfig:[GCStatsCalendarAggregationConfig globalConfigFor:NSCalendarUnitYear]
                                                                            graphChoice:gcGraphChoiceCumulative after:nil];

    return sample;
}

-(NSArray<GCSimpleGraphCachedDataSource*>*)sample8_historyBarGraphCoarse{

    GCField * distfield = [GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:GC_TYPE_RUNNING];

    GCHistoryFieldDataSerieConfig * config = [GCHistoryFieldDataSerieConfig configWithField:distfield xField:nil];
    GCHistoryFieldDataSerie * history = [[[GCHistoryFieldDataSerie alloc] initFromConfig:config] autorelease];

    [history setDb:[GCAppGlobal db]];
    [history loadFromDb:nil];

    GCSimpleGraphCachedDataSource * sample = [GCSimpleGraphCachedDataSource historyView:history
                                                                           calendarConfig:[GCStatsCalendarAggregationConfig globalConfigFor:NSCalendarUnitMonth]
                                                                            graphChoice:gcGraphChoiceBarGraph after:nil];

    [history loadFromDb:^(NSDate * date){
        BOOL rv = [date compare:[NSDate dateForRFC3339DateTimeString:@"2011-12-01T00:00:00.000Z"]] == NSOrderedAscending ||
        [date compare:[NSDate dateForRFC3339DateTimeString:@"2012-02-01T00:00:00.000Z"]] == NSOrderedDescending;
        return rv;
        
    }] ;
    GCSimpleGraphCachedDataSource * sample2 = [GCSimpleGraphCachedDataSource historyView:history
                                                                           calendarConfig:[GCStatsCalendarAggregationConfig globalConfigFor:NSCalendarUnitMonth]
                                                                            graphChoice:gcGraphChoiceBarGraph after:nil];

    return @[ sample, sample2 ];
}

-(NSArray<GCSimpleGraphCachedDataSource*>*)sample9_trackFieldMultipleLineGraphs{
    GCActivity * act = [GCActivity fullLoadFromDbPath:[GCTestsSamples sampleActivityDatabasePath:@"test_activity_running_837769405.db"]];
    act.settings.treatGapAsNoValueInSeries = false;

    GCSimpleGraphCachedDataSource * sample = [[[GCSimpleGraphCachedDataSource alloc] init] autorelease];

    GCField * speedField = [GCField fieldForFlag:gcFieldFlagWeightedMeanSpeed andActivityType:act.activityType];
    GCField * hrField = [GCField fieldForFlag:gcFieldFlagWeightedMeanHeartRate andActivityType:act.activityType];
    
    GCStatsDataSerieWithUnit * speedSU = [act timeSerieForField:speedField];
    GCStatsDataSerieWithUnit * hrSU    = [act timeSerieForField:hrField];

    GCSimpleGraphDataHolder * speed = [GCSimpleGraphDataHolder dataHolder:speedSU.serie
                                                                     type:gcGraphLine
                                                                    color:[UIColor redColor]
                                                                  andUnit:[act displayUnitForField:speedField]];

    GCSimpleGraphDataHolder * hr = [GCSimpleGraphDataHolder dataHolder:hrSU.serie
                                                                  type:gcGraphLine
                                                                 color:[UIColor blueColor]
                                                               andUnit:[act displayUnitForField:hrField]];
    [hr setAxisForSerie:1];

    GCStatsDataSerie * ma = [[speed dataSerie] movingAverage:60];
    GCSimpleGraphDataHolder * speed_ma = [GCSimpleGraphDataHolder dataHolder:ma type:gcGraphLine color:[UIColor blackColor] andUnit:act.speedDisplayUnit];
    [speed_ma setLineWidth:2.];

    [sample setSeries:[NSMutableArray arrayWithObjects:speed, hr, speed_ma, nil]];
    [sample setXUnit:[GCUnit unitForKey:@"second"]];
    [sample setTitle:@"sample 9"];

    GCSimpleGraphCachedDataSource * sampleTransposed = [[[GCSimpleGraphCachedDataSource alloc] init] autorelease];
    [sampleTransposed setSeries:[NSMutableArray arrayWithObjects:speed, hr, speed_ma, nil]];
    [sampleTransposed setXUnit:[GCUnit unitForKey:@"second"]];
    [sampleTransposed setTitle:@"sample 9 transposed"];
    sampleTransposed.xAxisIsVertical = true;

    
    return @[ sample, sampleTransposed ];
}

-(NSArray<GCSimpleGraphCachedDataSource*>*)sample10_swimBarGraphFine{
    NSMutableArray<GCSimpleGraphCachedDataSource*>*rv =[NSMutableArray array];
    
    NSString * activityId = @"1027746730";
        
    NSString * fn = [NSString stringWithFormat:@"activity_%@.json", activityId];
    NSData * data = [NSData dataWithContentsOfFile:[RZFileOrganizer bundleFilePath:fn forClass:[self class]] options:0 error:nil];
    
    NSDictionary * json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    GCActivity * activity = [[[GCActivity alloc] initWithId:activityId andGarminData:json] autorelease];
    [GCGarminActivityTrack13Request testForActivity:activity withFilesIn:[RZFileOrganizer bundleFilePath:nil forClass:[self class]] mergeFit:false];

    GCSimpleGraphCachedDataSource * one = nil;

    GCTrackStats * trackStats = RZReturnAutorelease([[GCTrackStats alloc] init]);
    trackStats.activity = activity;
    GCField * speed = [GCField fieldForFlag:gcFieldFlagWeightedMeanSpeed andActivityType:GC_TYPE_SWIMMING];

    GCTrackFieldChoiceHolder * choice = [GCTrackFieldChoiceHolder trackFieldChoice:speed style:gcTrackStatsData];
    [choice setupTrackStats:trackStats];
    one = [GCSimpleGraphCachedDataSource trackFieldFrom:trackStats];
    one.xAxisIsVertical = false;
    [rv addObject:one];
    
    trackStats = RZReturnAutorelease([[GCTrackStats alloc] init]);
    //activityId = @"424479793";
    NSString * fp_fit = [RZFileOrganizer bundleFilePath:@"activity_424479793.fit"];
    //GCActivity * activity3 = [GCGarminRequestActivityReload testForActivity:activityId withFilesIn:[RZFileOrganizer bundleFilePath:nil]];;
    GCActivity * activity3 = [GCConnectStatsRequestFitFile testForActivity:nil withFilesIn:fp_fit];
    trackStats.activity = activity3;

    choice = [GCTrackFieldChoiceHolder trackFieldChoice:speed style:gcTrackStatsData];
    [choice setupTrackStats:trackStats];
    one = [GCSimpleGraphCachedDataSource trackFieldFrom:trackStats];
    one.xAxisIsVertical = false;
    [rv addObject:one];

    return rv;
}

-(GCSimpleGraphCachedDataSource*)sample11_cumulativeHist{
    GCField * distfield = [GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:GC_TYPE_RUNNING];
    GCField * durfield  = [GCField fieldForFlag:gcFieldFlagSumDuration andActivityType:GC_TYPE_RUNNING];

    GCHistoryFieldDataSerieConfig * config = [GCHistoryFieldDataSerieConfig configWithField:distfield  xField:durfield];
    GCHistoryFieldDataSerie * history = [[[GCHistoryFieldDataSerie alloc] initFromConfig:config] autorelease];

    [history setDb:[GCAppGlobal db]];
    [history loadFromDb:nil];

    GCSimpleGraphCachedDataSource * sample = [GCSimpleGraphCachedDataSource historyView:history
                                                                           calendarConfig:[GCStatsCalendarAggregationConfig globalConfigFor:NSCalendarUnitYear]
                                                                            graphChoice:gcGraphChoiceCumulative after:nil];

    return sample;
}

-(NSArray<GCSimpleGraphCachedDataSource*>*)sample12_trackStats{
    GCActivity * activity = [GCActivity fullLoadFromDbPath:[GCTestsSamples sampleActivityDatabasePath:@"test_activity_running_837769405.db" ]];
    GCTrackStats * trackStats = [[GCTrackStats alloc] init];
    trackStats.activity = activity;
    activity.settings.gapTimeInterval = 30.;

    GCField * hr = [GCField fieldForFlag:gcFieldFlagWeightedMeanHeartRate andActivityType:GC_TYPE_RUNNING];
    GCField * speed = [GCField fieldForFlag:gcFieldFlagWeightedMeanSpeed andActivityType:GC_TYPE_RUNNING];

    NSArray<NSNumber*>*zoneValues = @[ @(100.), @(140.), @(150.), @(160.), @(180.), @(200.)];
    NSArray<NSString*>*zoneNames  = @[ @"Rest", @"Easy", @"Threshold", @"Threshold2", @"Sprint"];
    GCHealthZoneCalculator * healthCalc = [GCHealthZoneCalculator zoneCalculatorForValues:zoneValues
                                                                                   inUnit:[GCUnit unitForKey:@"bpm"]
                                                                                withNames:zoneNames
                                                                                    field:hr
                                                                                forSource:gcHealthZoneSourceAuto];

    NSMutableArray<GCSimpleGraphCachedDataSource*> * rv = [NSMutableArray array];
    GCSimpleGraphCachedDataSource * one = nil;

    GCTrackFieldChoiceHolder * choice = [GCTrackFieldChoiceHolder trackFieldChoice:hr zone:healthCalc];
    [choice setupTrackStats:trackStats];
    one = [GCSimpleGraphCachedDataSource trackFieldFrom:trackStats];
    one.xAxisIsVertical = false;
    [rv addObject:one];

    one = [GCSimpleGraphCachedDataSource trackFieldFrom:trackStats];
    one.xAxisIsVertical = true;
    [rv addObject:one];


    activity.settings.treatGapAsNoValueInSeries = NO;
    choice = [GCTrackFieldChoiceHolder trackFieldChoice:hr xField:speed];
    [choice setupTrackStats:trackStats];
    one = [GCSimpleGraphCachedDataSource trackFieldFrom:trackStats];
    [rv addObject:one];

    choice = [GCTrackFieldChoiceHolder trackFieldChoice:hr xField:nil];
    choice.zoneCalculator = nil;
    [choice setupTrackStats:trackStats];
    one = [GCSimpleGraphCachedDataSource trackFieldFrom:trackStats];
    [rv addObject:one];

    activity.settings.treatGapAsNoValueInSeries = YES;
    [trackStats setNeedsForRecalculate];
    choice = [GCTrackFieldChoiceHolder trackFieldChoice:hr xField:nil];
    choice.zoneCalculator = nil;
    [choice setupTrackStats:trackStats];
    one = [GCSimpleGraphCachedDataSource trackFieldFrom:trackStats];
    [rv addObject:one];

    activity.settings.treatGapAsNoValueInSeries = NO;
    trackStats.highlightLap = true;
    trackStats.highlightLapIndex = 4;
    [trackStats setNeedsForRecalculate];
    choice = [GCTrackFieldChoiceHolder trackFieldChoice:hr xField:nil];
    [choice setupTrackStats:trackStats];
    one = [GCSimpleGraphCachedDataSource trackFieldFrom:trackStats];
    [rv addObject:one];
    
    choice = [GCTrackFieldChoiceHolder trackFieldChoice:hr xField:speed];
    [choice setupTrackStats:trackStats];
    one = [GCSimpleGraphCachedDataSource trackFieldFrom:trackStats];
    [rv addObject:one];


    [trackStats release];
    return rv;
}

-(NSArray<GCSimpleGraphCachedDataSource*>*)sample13_compareStats{
    GCActivity * activity = [GCActivity fullLoadFromDbPath:[GCTestsSamples sampleActivityDatabasePath:@"test_activity_running_828298988.db" ]];
    GCActivity * compare = [GCActivity fullLoadFromDbPath:[GCTestsSamples sampleActivityDatabasePath:@"test_activity_running_1266384539.db"]];

    GCTrackStats * trackStats = [[[GCTrackStats alloc] init] autorelease];
    trackStats.activity = activity;

    GCTrackFieldChoiceHolder * choice = [GCTrackFieldChoiceHolder trackFieldChoiceComparing:compare timeAxis:true];

    [choice setupTrackStats:trackStats];
    NSMutableArray<GCSimpleGraphCachedDataSource*> * rv = [NSMutableArray arrayWithObject:[GCSimpleGraphCachedDataSource trackFieldFrom:trackStats]];
    choice = [GCTrackFieldChoiceHolder trackFieldChoiceComparing:compare timeAxis:false];
    [trackStats setNeedsForRecalculate];
    [choice setupTrackStats:trackStats];
    [rv addObject:[GCSimpleGraphCachedDataSource trackFieldFrom:trackStats]];

    return rv;
}

-(GCSimpleGraphCachedDataSource*)sample14_SimpleGradientFillPlot{
    GCStatsDataSerie * serie = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);
    GCViewGradientColors * colors = [GCViewGradientColors gradientColorsWith:@[ [UIColor redColor], [UIColor greenColor], [UIColor blueColor]]];
    GCStatsDataSerie * gradientSerie = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);
    for (double x = 0.; x < 20.; x+= 0.1) {
        if( sin(x) > 0.5){
            [gradientSerie addDataPointWithX:x andY:0.];
        }else if( sin(x) < -0.5){
            [gradientSerie addDataPointWithX:x andY:1.];
        }else{
            [gradientSerie addDataPointWithX:x andY:2.];
        }
        [serie addDataPointWithX:x andY:sin(x)];
    }
    
    GCSimpleGraphCachedDataSource * sample = [[[GCSimpleGraphCachedDataSource alloc] init] autorelease];
    GCSimpleGraphDataHolder * holder = [GCSimpleGraphDataHolder dataHolder:serie type:gcGraphLine
                                                                     color:[UIColor blueColor]
                                                                   andUnit:[GCUnit unitForKey:@"percent"]];
    holder.gradientDataSerie = gradientSerie;
    holder.gradientColors = colors;
    holder.gradientColorsFill = [colors gradientAsBackgroundWithAlpha:0.5];
    
    holder.fillColorForSerie = [UIColor colorWithWhite:0.5 alpha:0.5];
    [sample addDataHolder:holder];
    [sample setXUnit:[GCUnit unitForKey:@"percent"]];
    [sample setTitle:@"sample 14"];

    return sample;
}

-(NSArray<GCSimpleGraphCachedDataSource*>*)sample15_HistDerivedGraphs{
    [RZFileOrganizer createEditableCopyOfFile:@"activities_testderived.db"];
    [RZFileOrganizer createEditableCopyOfFile:@"derived_testderived.db"];
    
    FMDatabase * db = [FMDatabase databaseWithPath:[RZFileOrganizer writeableFilePath:@"activities_testderived.db"]];
    [db open];
    GCActivitiesOrganizer * organizer = RZReturnAutorelease([[GCActivitiesOrganizer alloc] initTestModeWithDb:db]);
    FMDatabase * deriveddb = [FMDatabase databaseWithPath:[RZFileOrganizer writeableFilePath:@"derived_testderived.db"]];
    [deriveddb open];

    GCDerivedOrganizer * derived = RZReturnAutorelease([[GCDerivedOrganizer alloc] initForTestModeWithDb:deriveddb thread:nil andFilePrefix:@"testderived"]);
    GCField * field = [GCField fieldForFlag:gcFieldFlagWeightedMeanHeartRate andActivityType:GC_TYPE_RUNNING];
    GCStatsSerieOfSerieWithUnits * serieOfSeries = [derived timeserieOfSeriesFor:field inActivities:organizer.activities];
    
    NSMutableArray * rv = [NSMutableArray array];
    
    GCStatsMultiFieldConfig * fieldConfig = [GCStatsMultiFieldConfig fieldListConfigFrom:nil];
    GCStatsDerivedAnalysisConfig * derivedAnalysisConfig = [GCStatsDerivedAnalysisConfig configForActivityType:GC_TYPE_RUNNING];;
    
    GCStatsDerivedHistory * config = [GCStatsDerivedHistory analysisWith:fieldConfig and:derivedAnalysisConfig];
    config.mode = gcDerivedHistModeAbsolute;
    config.longTermSmoothing = gcDerivedHistSmoothingMovingAverage;
    config.shortTermSmoothing = gcDerivedHistSmoothingMovingAverage;
    config.longTermPeriod = [GCLagPeriod periodFor:gcLagPeriodTwoWeeks];
    config.shortTermPeriod = [GCLagPeriod periodFor:gcLagPeriodWeek];
    [rv addObject:[GCSimpleGraphCachedDataSource derivedHist:config field:field series:serieOfSeries width:320.]];
    config.mode = gcDerivedHistModeDrop;
    config.longTermSmoothing = gcDerivedHistSmoothingMovingAverage;
    config.shortTermSmoothing = gcDerivedHistSmoothingMovingAverage;
    config.longTermPeriod = [GCLagPeriod periodFor:gcLagPeriodTwoWeeks];
    config.shortTermPeriod = [GCLagPeriod periodFor:gcLagPeriodWeek];
    [rv addObject:[GCSimpleGraphCachedDataSource derivedHist:config field:field series:serieOfSeries width:320.]];
    config.mode = gcDerivedHistModeAbsolute;
    config.longTermSmoothing = gcDerivedHistSmoothingMax;
    config.shortTermSmoothing = gcDerivedHistSmoothingMovingAverage;
    config.longTermPeriod = [GCLagPeriod periodFor:gcLagPeriodTwoWeeks];
    config.shortTermPeriod = [GCLagPeriod periodFor:gcLagPeriodWeek];
    [rv addObject:[GCSimpleGraphCachedDataSource derivedHist:config field:field series:serieOfSeries width:320.]];
    config.mode = gcDerivedHistModeDrop;
    config.longTermSmoothing = gcDerivedHistSmoothingMax;
    config.shortTermSmoothing = gcDerivedHistSmoothingMovingAverage;
    config.longTermPeriod = [GCLagPeriod periodFor:gcLagPeriodTwoWeeks];
    config.shortTermPeriod = [GCLagPeriod periodFor:gcLagPeriodNone];
    [rv addObject:[GCSimpleGraphCachedDataSource derivedHist:config field:field series:serieOfSeries width:320.]];

    return rv;
}
#pragma mark - Cells Samples

-(NSArray*)sampleCells{

    static NSString *CellIdentifier = @"Cell";

    GCCellGrid*cell = [[[GCCellGrid alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    [cell setMarginx:5.];
    [cell setMarginy:5.];
    [cell setupForRows:2 andCols:4];
    [cell setCellLayout:gcCellLayoutEven];
    [cell labelForRow:0 andCol:0].text = NSLocalizedString(@"cell(0,0)", nil);
    [cell labelForRow:0 andCol:1].text = NSLocalizedString(@"cell(0,1)", nil);
    [cell labelForRow:0 andCol:2].text = NSLocalizedString(@"cell(0,2)", nil);
    [cell labelForRow:0 andCol:3].text = NSLocalizedString(@"cell(0,3)", nil);
    [cell labelForRow:1 andCol:0].text = NSLocalizedString(@"cell(1,0)", nil);
    [cell labelForRow:1 andCol:1].text = NSLocalizedString(@"cell(1,1)", nil);
    [cell labelForRow:1 andCol:2].text = NSLocalizedString(@"cell(1,2)", nil);
    [cell labelForRow:1 andCol:3].text = NSLocalizedString(@"cell(1,3)", nil);

    GCCellGrid*cell2 = [[[GCCellGrid alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    [cell2 setMarginx:5.];
    [cell2 setMarginy:5.];
    [cell2 setupForRows:2 andCols:4];
    [cell2 setCellLayout:gcCellLayoutEven];
    [cell2 labelForRow:0 andCol:0].text = NSLocalizedString(@"cell(0,0)",nil);
    [cell2 labelForRow:0 andCol:0].backgroundColor = [UIColor lightGrayColor];
    [cell2 labelForRow:0 andCol:1].text = NSLocalizedString(@"cell(0,1)",nil);
    [cell2 labelForRow:0 andCol:2].text = NSLocalizedString(@"cell(0,2)",nil);
    [cell2 labelForRow:0 andCol:3].text = NSLocalizedString(@"cell(0,3)",nil);
    [cell2 labelForRow:1 andCol:0].text = NSLocalizedString(@"cell(1,0) Very Long",nil);
    [cell2 configForRow:1 andCol:0].horizontalOverflow = YES;
    //[cell2 labelForRow:1 andCol:1].text = @"cell(1,1)";
    [cell2 labelForRow:1 andCol:2].text = NSLocalizedString(@"cell(1,2) Very Long No Over",nil);
    [cell2 configForRow:1 andCol:2].horizontalOverflow = NO;
    [cell2 configForRow:1 andCol:2].horizontalAlign = gcHorizontalAlignLeft;
    //[cell2 labelForRow:1 andCol:3].text = @"cell(1,3)";

    GCCellGrid*cell3 = [[[GCCellGrid alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    [cell3 setupForRows:3 andCols:4];
    [cell3 labelForRow:0 andCol:0].text = NSLocalizedString(@"cell(0,0)",nil);
    UIView * view = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    view.backgroundColor = [UIColor blueColor];
    [cell3 setupView:view forRow:1 andColumn:0];
    [cell3 configForRow:1 andCol:0].columnSpan = 2;
    UIView * view2 = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    view2.backgroundColor = [UIColor redColor];
    [cell3 setupView:view2 forRow:1 andColumn:2];
    [cell3 configForRow:1 andCol:2].columnSpan = 2;
    [cell3 configForRow:1 andCol:2].rowSpan = 2;

    UIView * view3 = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    view3.backgroundColor = [UIColor yellowColor];
    [cell3 setupView:view3 forRow:0 andColumn:3];
    [cell3 configForRow:0 andCol:3].columnSpan = 2;


    return @[
             [GCTestUISampleCellHolder holderFor:cell3 andIdentifier:@"Sample Cell with Views"],
             [GCTestUISampleCellHolder holderFor:cell2 andIdentifier:@"Sample Simple Cell Overflow"],
             [GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Sample Simple Cell"],
             ];
}

-(NSArray*)sampleDayActivities{
    GCActivity * act = nil;
    GCCellHealthDayActivity * cell =  nil;

    NSMutableArray * rv = [NSMutableArray array];

    cell = [GCCellHealthDayActivity activityCell:nil];
    act = [GCActivity fullLoadFromDb:[GCTestsSamples sampleActivityDatabase:@"test_activity_day___healthkit__Default_20151106.db"]];
    [cell setupForActivity:act];
    [rv addObject:[GCTestUISampleCellHolder holderFor:cell height:kGCCellActivityDefaultHeight andIdentifier:@"Day Activity hr"]];

    cell = [GCCellHealthDayActivity activityCell:nil];
    act = [GCActivity fullLoadFromDb:[GCTestsSamples sampleActivityDatabase:@"test_activity_day___healthkit__Default_20151109.db"]];
    [cell setupForActivity:act];
    [rv addObject:[GCTestUISampleCellHolder holderFor:cell height:kGCCellActivityDefaultHeight andIdentifier:@"Day Activity nohr"]];

    return rv;
}

-(NSArray*)sampleActivitySummary{
    [GCViewConfig setSkin:[GCViewConfigSkin skinForName:kGCSkinNameiOS13]];
    GCCellGrid * cell = nil;

    GCActivity *act=nil;

    NSMutableArray * activity = [NSMutableArray array];

    NSUInteger nrows = 3;
    CGFloat height = [GCViewConfig sizeForNumberOfRows:nrows];

    NSUInteger nrowsExtended = 4;
    CGFloat heightExtended = [GCViewConfig sizeForNumberOfRows:nrowsExtended];

    act =[GCActivity fullLoadFromDbPath:[GCTestsSamples sampleActivityDatabasePath:@"test_activity_running_837769405.db" ]];
    cell = [GCCellGrid cellGrid:nil];
    [cell setupSummaryFromActivity:act rows:nrows width:320. status:gcViewActivityStatusNone];
    [activity addObject:[GCTestUISampleCellHolder holderFor:cell height:height andIdentifier:@"Running Activity Base"]];
    
    cell = [GCCellGrid cellGrid:nil];
    [cell setupSummaryFromActivity:act rows:nrowsExtended width:320. status:gcViewActivityStatusNone];
    [activity addObject:[GCTestUISampleCellHolder holderFor:cell height:heightExtended andIdentifier:@"Running Activity Base Ext"]];
    
    cell = [GCCellGrid cellGrid:nil];
    [cell setupSummaryFromActivity:act rows:nrows width:320. status:gcViewActivityStatusCompare];
    [activity addObject:[GCTestUISampleCellHolder holderFor:cell height:height andIdentifier:@"Running Activity Compare"]];
    
    cell = [GCCellGrid cellGrid:nil];
    [cell setupSummaryFromActivity:act rows:nrowsExtended width:320. status:gcViewActivityStatusCompare];
    [activity addObject:[GCTestUISampleCellHolder holderFor:cell height:heightExtended andIdentifier:@"Running Activity Compare Ext"]];
    
    act =[GCActivity fullLoadFromDbPath:[GCTestsSamples sampleActivityDatabasePath:@"test_activity_swimming_439303647.db" ]];
    cell = [GCCellGrid cellGrid:nil];
    [cell setupSummaryFromActivity:act rows:nrows width:320. status:gcViewActivityStatusNone];
    [activity addObject:[GCTestUISampleCellHolder holderFor:cell height:height andIdentifier:@"Swim Activity Base"]];

    cell = [GCCellGrid cellGrid:nil];
    [cell setupSummaryFromActivity:act rows:nrowsExtended width:320. status:gcViewActivityStatusNone];
    [activity addObject:[GCTestUISampleCellHolder holderFor:cell height:heightExtended andIdentifier:@"Swim Activity Base Ext"]];

    act =[GCActivity fullLoadFromDbPath:[GCTestsSamples sampleActivityDatabasePath:@"test_activity_cycling_940863203.db" ]];

    cell = [GCCellGrid cellGrid:nil];
    [cell setupSummaryFromActivity:act rows:nrows width:320. status:gcViewActivityStatusNone];
    [activity addObject:[GCTestUISampleCellHolder holderFor:cell height:height andIdentifier:@"Cycle Activity Base"]];

    cell = [GCCellGrid cellGrid:nil];
    [cell setupSummaryFromActivity:act rows:nrowsExtended width:320. status:gcViewActivityStatusNone];
    [activity addObject:[GCTestUISampleCellHolder holderFor:cell height:heightExtended andIdentifier:@"Cycle Activity Base Ext"]];

    return activity;
}

-(NSArray*)sampleNewActivitySummary{
    [GCViewConfig setSkin:[GCViewConfigSkin skinForName:kGCSkinName2021]];
    NSString * name = @"activities_types_samples.db";
    FMDatabase * db = [FMDatabase databaseWithPath:[RZFileOrganizer bundleFilePath:name]];
    [db open];
    GCActivitiesOrganizer * organizer = RZReturnAutorelease([[GCActivitiesOrganizer alloc] initTestModeWithDb:db]);

    NSMutableArray * rv = [NSMutableArray array];
    
    NSUInteger nrowsExtended = 4;
    CGFloat heightExtended = [GCViewConfig sizeForNumberOfRows:nrowsExtended] * 1.1;

    UINib * nib = [UINib nibWithNibName:@"GCCellActivity" bundle:[NSBundle mainBundle]];
    
    for (GCActivity * act in organizer.activities) {
        GCCellActivity * cell = [nib instantiateWithOwner:self options:nil][0];
        [cell setupFor:act];
        [rv addObject:[GCTestUISampleCellHolder holderFor:cell height:heightExtended andIdentifier:@"new cell"]];
    }
    [db close];
    [GCViewConfig setSkin:[GCViewConfigSkin skinForName:kGCSkinNameiOS13]];
    return rv;
}


-(NSArray*)sampleActivityDetail{
    [GCViewConfig setSkin:[GCViewConfigSkin skinForName:kGCSkinNameiOS13]];

    GCCellGrid * cell = nil;

    GCActivity *act=nil;

    NSMutableArray * activity = [NSMutableArray array];

    act =[GCActivity fullLoadFromDbPath:[GCTestsSamples sampleActivityDatabasePath:@"test_activity_running_837769405.db" ]];
    
    cell = [GCCellGrid cellGrid:nil];
    [cell setupDetailHeader:act];
    [activity addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Running Activity Detail"]];
    cell = [GCCellGrid cellGrid:nil];
    [cell setupForField:@"WeightedMeanPace" andActivity:act width:320.];
    [activity addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Running Activity Pace Field"]];
    if ([act trackpointsReadyOrLoad] && [[act laps] count] > 0) {
        cell = [GCCellGrid cellGrid:nil];
        [cell setupForLap:0 andActivity:act width:320.];
        [activity addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Running Activity Lap"]];
    }

    act =[GCActivity fullLoadFromDbPath:[GCTestsSamples sampleActivityDatabasePath:@"test_activity_swimming_439303647.db" ]];

    cell = [GCCellGrid cellGrid:nil];
    [cell setupDetailHeader:act];
    [activity addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Swim Activity Detail"]];
    cell = [GCCellGrid cellGrid:nil];
    [cell setupForField:@"WeightedMeanPace" andActivity:act width:320.];
    [activity addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Swim Activity Pace Field"]];
    if ([act trackpointsReadyOrLoad] && [[act laps] count] > 0) {
        cell = [GCCellGrid cellGrid:nil];
        [cell setupForLap:0 andActivity:act width:320.];
        [activity addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Swim Activity Lap"]];
    }

    act =[GCActivity fullLoadFromDbPath:[GCTestsSamples sampleActivityDatabasePath:@"test_activity_cycling_940863203.db" ]];

    cell = [GCCellGrid cellGrid:nil];
    [cell setupDetailHeader:act];
    [activity addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Cycle Activity Detail"]];
    cell = [GCCellGrid cellGrid:nil];
    [cell setupForField:@"WeightedMeanSpeed" andActivity:act width:320.];
    [activity addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Cycle Activity Speed Field"]];
    if ([act trackpointsReadyOrLoad] && [[act laps] count] > 0) {
        cell = [GCCellGrid cellGrid:nil];
        [cell setupForLap:0 andActivity:act width:320.];
        [activity addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Cycle Activity Lap"]];
    }

    return activity;
}
-(NSArray*)sampleNewActivityDetail{
    [GCViewConfig setSkin:[GCViewConfigSkin skinForName:kGCSkinName2021]];

    GCCellGrid * cell = nil;
    GCActivity *act=nil;
    
    
    
    NSMutableArray * activity = [NSMutableArray array];

    act =[GCActivity fullLoadFromDbPath:[GCTestsSamples sampleActivityDatabasePath:@"test_activity_running_5881498219.db" ]];
    GCActivityOrganizedFields * organizedFields = [act groupedFields];
    
    cell = [GCCellGrid cellGrid:nil];
    [cell setupDetailHeader:act];
    [activity addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Running Activity Detail"]];
    NSUInteger indexes[] = {0, 1, 2, 4, 6, 8, 11};

    for( NSUInteger i=0;i<sizeof(indexes)/sizeof(NSUInteger);i++){
        cell = [GCCellGrid cellGrid:nil];
        NSArray<GCField*>*fields = organizedFields.groupedPrimaryFields[indexes[i]];
        CGFloat height = [GCViewConfig sizeForNumberOfRows:fields.count];
        NSString * tag = [NSString stringWithFormat:@"%@ %@ %@ Detail New Style", act.activityId, act.activityType, fields.firstObject.key];
        [cell setupActivityDetailWithFields:fields
                                   activity:act
                                   geometry:organizedFields.geometry];
        [activity addObject:[GCTestUISampleCellHolder holderFor:cell height:height andIdentifier:tag]];
    }
    /*
    if ([act trackpointsReadyOrLoad] && [[act laps] count] > 0) {
        cell = [GCCellGrid cellGrid:nil];
        [cell setupForLap:0 andActivity:act width:320.];
        [activity addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Running Activity Lap"]];
    }

    act =[GCActivity fullLoadFromDbPath:[GCTestsSamples sampleActivityDatabasePath:@"test_activity_swimming_439303647.db" ]];

    cell = [GCCellGrid cellGrid:nil];
    [cell setupDetailHeader:act];
    [activity addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Swim Activity Detail"]];
    cell = [GCCellGrid cellGrid:nil];
    [cell setupForField:@"WeightedMeanPace" andActivity:act width:320.];
    [activity addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Swim Activity Pace Field"]];
    if ([act trackpointsReadyOrLoad] && [[act laps] count] > 0) {
        cell = [GCCellGrid cellGrid:nil];
        [cell setupForLap:0 andActivity:act width:320.];
        [activity addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Swim Activity Lap"]];
    }

    act =[GCActivity fullLoadFromDbPath:[GCTestsSamples sampleActivityDatabasePath:@"test_activity_cycling_940863203.db" ]];

    cell = [GCCellGrid cellGrid:nil];
    [cell setupDetailHeader:act];
    [activity addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Cycle Activity Detail"]];
    cell = [GCCellGrid cellGrid:nil];
    [cell setupForField:@"WeightedMeanSpeed" andActivity:act width:320.];
    [activity addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Cycle Activity Speed Field"]];
    if ([act trackpointsReadyOrLoad] && [[act laps] count] > 0) {
        cell = [GCCellGrid cellGrid:nil];
        [cell setupForLap:0 andActivity:act width:320.];
        [activity addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Cycle Activity Lap"]];
    }
*/
    [GCViewConfig setSkin:[GCViewConfigSkin skinForName:kGCSkinNameiOS13]];

    return activity;

}


-(NSArray*)sampleAggregatedStats{
    [GCViewConfig setSkin:[GCViewConfigSkin skinForName:kGCSkinNameiOS13]];

    static NSString *CellIdentifier = @"Cell";
    GCCellGrid * cell = nil;

    NSMutableArray * stats = [NSMutableArray array];

    GCHistoryAggregatedActivityStats * aggregatedStats = [GCHistoryAggregatedActivityStats aggregatedActivitStatsForActivityType:GC_TYPE_RUNNING];
    [aggregatedStats setActivitiesFromOrganizer:[GCAppGlobal organizer]];
    [aggregatedStats aggregate:NSCalendarUnitWeekOfYear referenceDate:nil ignoreMode:gcIgnoreModeActivityFocus];

    cell = [[[GCCellGrid alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    GCStatsMultiFieldConfig * config = [GCStatsMultiFieldConfig fieldListConfigFrom:nil];
    config.calendarConfig.calendarUnit= NSCalendarUnitWeekOfYear;
    [cell setupFromHistoryAggregatedData:[aggregatedStats dataForIndex:0] index:0 multiFieldConfig:config andActivityType:GCActivityType.running width:320.];
    [stats addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Running Stats Weekly"]];

    [aggregatedStats aggregate:NSCalendarUnitMonth referenceDate:nil ignoreMode:gcIgnoreModeActivityFocus];
    cell = [[[GCCellGrid alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    config.calendarConfig.calendarUnit = NSCalendarUnitMonth;
    [cell setupFromHistoryAggregatedData:[aggregatedStats dataForIndex:0] index:0 multiFieldConfig:config andActivityType:GCActivityType.running width:320.];
    [stats addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Running Stats Monthly"]];
    
    return stats;
}

-(NSArray*)sampleNewAggregatedStats{
    [GCViewConfig setSkin:[GCViewConfigSkin skinForName:kGCSkinName2021]];

    static NSString *CellIdentifier = @"Cell";
    GCCellGrid * cell = nil;

    NSMutableArray * stats = [NSMutableArray array];

    GCHistoryAggregatedActivityStats * aggregatedStats = [GCHistoryAggregatedActivityStats aggregatedActivitStatsForActivityType:GC_TYPE_RUNNING];
    [aggregatedStats setActivitiesFromOrganizer:[GCAppGlobal organizer]];
    [aggregatedStats aggregate:NSCalendarUnitWeekOfYear referenceDate:nil ignoreMode:gcIgnoreModeActivityFocus];

    GCStatsMultiFieldConfig * config = [GCStatsMultiFieldConfig fieldListConfigFrom:nil];
    RZNumberWithUnitGeometry * geometry = RZReturnAutorelease([[RZNumberWithUnitGeometry alloc] init]);
    
    config.calendarConfig.calendarUnit= NSCalendarUnitWeekOfYear;
    [GCCellGrid adjustAggregatedWithDataHolder:[aggregatedStats dataForIndex:0] activityType:GCActivityType.running geometry:geometry];
    [GCCellGrid adjustAggregatedWithDataHolder:[aggregatedStats dataForIndex:1] activityType:GCActivityType.running geometry:geometry];
    
    cell = [[[GCCellGrid alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    [cell setupAggregatedWithDataHolder:[aggregatedStats dataForIndex:0] index:0 multiFieldConfig:config activityType:GCActivityType.running geometry:geometry wide:false];
    [stats addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Running Stats Weekly [0] NewStyle"]];

    cell = [[[GCCellGrid alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    [cell setupAggregatedWithDataHolder:[aggregatedStats dataForIndex:1] index:1 multiFieldConfig:config activityType:GCActivityType.running geometry:geometry wide:false];
    [stats addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Running Stats Weekly [1] NewStyle"]];

    cell = [[[GCCellGrid alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    config.calendarConfig.calendarUnit = NSCalendarUnitMonth;
    [cell setupAggregatedWithDataHolder:[aggregatedStats dataForIndex:0] index:0 multiFieldConfig:config activityType:GCActivityType.running geometry:geometry wide:false];
    [stats addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Running Stats Month [0] NewStyle"]];

    [GCViewConfig setSkin:[GCViewConfigSkin skinForName:kGCSkinNameiOS13]];

    return stats;
}

-(NSArray*)sampleMultiFieldsStats{
    NSMutableArray * rv = [NSMutableArray array];

    GCStatsMultiFieldViewController * vc = RZReturnAutorelease([[GCStatsMultiFieldViewController alloc] initWithStyle:UITableViewStyleGrouped]);
    GCStatsMultiFieldConfig * config = RZReturnAutorelease([[GCStatsMultiFieldConfig alloc] init]);
    config.activityType = GC_TYPE_RUNNING;
    config.viewChoice = gcViewChoiceFields;
    config.viewConfig = gcStatsViewConfigAll;
    config.calendarConfig.calendarUnit = kCalendarUnitNone;

    UITableView * tableView = vc.tableView;
    // Force width for consistency accross device run
    CGRect adjusted = tableView.frame;
    adjusted.size.width = 320.;
    tableView.frame = adjusted;
    [vc setupTestModeWithFieldListConfig:config];

    UITableViewCell * cell = [vc tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:GC_SECTION_DATA]];
    [rv addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Stats Multi Distance"]];
    cell = [vc tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:GC_SECTION_DATA+1]];
    [rv addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Stats Multi Time"]];
    cell = [vc tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:GC_SECTION_DATA+2]];
    [rv addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Stats Multi HR"]];
    
    config.viewChoice = gcViewChoiceCalendar;
    config.calendarConfig.calendarUnit = NSCalendarUnitMonth;
    [vc setupTestModeWithFieldListConfig:config];
    cell = [vc tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:GC_SECTION_DATA]];
    [rv addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Stats Multi Last Month"]];

    return rv;
}



-(NSArray*)sampleIcons{
    NSMutableArray * icons = [NSMutableArray arrayWithCapacity:10];
    for (NSString * type in @[
                              GC_TYPE_RUNNING,
                              GC_TYPE_SWIMMING,
                              GC_TYPE_OTHER,
                              GC_TYPE_CYCLING,
                              GC_TYPE_FITNESS,
                              GC_TYPE_HIKING,
                              GC_TYPE_TENNIS,
                              GC_TYPE_MULTISPORT,
                              GC_TYPE_SKI_BACK,
                              GC_TYPE_SKI_DOWN,
                              GC_TYPE_SKI_XC,
                              GC_TYPE_ROWING,
                              GC_TYPE_TRANSITION,

                              ]) {
        GCTestIconsCell * iconCell = [GCTestIconsCell iconsCellForActivityType:type];
        NSString * identifier = [NSString stringWithFormat:@"Icons %@", type];
        [icons addObject:[GCTestUISampleCellHolder holderFor:iconCell height:56 andIdentifier:identifier]];
    }
    return icons;
}

-(NSArray*)gridCellSamples{
    [GCTestAppGlobal setupSampleState:@"sample_activities.db"];

    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:10];

    [rv addObject:[self sampleNumberGeometry]];
    
    [rv addObject:[self sampleNewActivitySummary]];
    [rv addObject:[self sampleNewAggregatedStats]];
    [rv addObject:[self sampleNewActivityDetail]];

    [rv addObject:[self sampleActivitySummary]];
    [rv addObject:[self sampleActivityDetail]];
    
    [rv addObject:[self sampleMultiFieldsStats]];
    [rv addObject:[self sampleAggregatedStats]];

    [rv addObject:[self sampleDayActivities]];
    
    [rv addObject:[self sampleIcons]];
    [rv addObject:[self sampleCells]];
    
    return rv;
}
@end
