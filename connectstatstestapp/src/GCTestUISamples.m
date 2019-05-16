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
#import "GCAppGlobal.h"
#import "GCGarminActivityXMLParser.h"
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
#import "GCCellActivity.h"
#import "GCTrackFieldChoices.h"

@implementation GCTestUISamples

#pragma mark - DataSource Samples

-(NSArray*)dataSourceSamples{
    //[self loadDataSourceSamples];

    // use the NSStringFromSelector(@Selector()) idiom so
    // xcode warns about undefined selectors
    NSArray<NSString*> * selectorNames = @[
                                           NSStringFromSelector(@selector(sample13_compareStats)),

                                           NSStringFromSelector(@selector(sample1_simpleLines)),
                                           NSStringFromSelector(@selector(sample2_SimpleSinusPlot)),
                                           NSStringFromSelector(@selector(sample3_WikipediaSampleRegression)),
                                           NSStringFromSelector(@selector(sample5_trackSerieScatterPlot)),
                                           NSStringFromSelector(@selector(sample6_simpleBarGraph)),
                                           NSStringFromSelector(@selector(sample7_historyCumulativeGraph)),
                                           NSStringFromSelector(@selector(sample8_historyBarGraphCoarse)),
                                           NSStringFromSelector(@selector(sample9_trackFieldMultipleLineGraphs)),
                                           //NSStringFromSelector(@selector(sample10_swimBarGraphFine)),
                                           NSStringFromSelector(@selector(sample11)),
                                           NSStringFromSelector(@selector(sample_12_trackStats)),


                                           ];


    NSMutableArray * rv = [NSMutableArray array];
    @autoreleasepool {
        [GCAppGlobal setupSampleState:@"sample_activities.db"];

        for (NSString * selectorName in selectorNames) {
            
            NSArray<GCTestUISampleDataSourceHolder*> * sources = [self dataSourceHolderFor:NSSelectorFromString(selectorName)];
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

-(GCSimpleGraphCachedDataSource*)sample1_simpleLines{
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
    GCSimpleGraphDataHolder * h = [GCSimpleGraphDataHolder dataHolder:data type:gcGraphLine color:[UIColor blackColor] andUnit:[GCUnit unitForKey:@"mps"]];
    GCSimpleGraphDataHolder * h2 = [GCSimpleGraphDataHolder dataHolder:data2 type:gcGraphLine color:[UIColor blueColor] andUnit:[GCUnit unitForKey:@"mps"]];

    [sample setSeries:[NSMutableArray arrayWithObjects:h, h2, nil]];
    [sample setXUnit:[GCUnit unitForKey:@"second"]];
    [sample setTitle:@"Sample 1"];
    [data release];
    [data2 release];

    return sample;

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
    [history loadFromDb];

    GCSimpleGraphCachedDataSource * sample = [GCSimpleGraphCachedDataSource historyView:history
                                                                           calendarUnit:NSCalendarUnitYear
                                                                            graphChoice:gcGraphChoiceCumulative after:nil];

    return sample;
}

-(GCSimpleGraphCachedDataSource*)sample8_historyBarGraphCoarse{

    GCField * distfield = [GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:GC_TYPE_RUNNING];

    GCHistoryFieldDataSerieConfig * config = [GCHistoryFieldDataSerieConfig configWithField:distfield xField:nil];
    GCHistoryFieldDataSerie * history = [[[GCHistoryFieldDataSerie alloc] initFromConfig:config] autorelease];

    [history setDb:[GCAppGlobal db]];
    [history loadFromDb];

    GCSimpleGraphCachedDataSource * sample = [GCSimpleGraphCachedDataSource historyView:history
                                                                           calendarUnit:NSCalendarUnitMonth
                                                                            graphChoice:gcGraphChoiceBarGraph after:nil];


    return sample;
}

-(GCSimpleGraphCachedDataSource*)sample9_trackFieldMultipleLineGraphs{
    //GCActivity * act = [[GCAppGlobal organizer] activityForId:@"234979239"];
    GCActivity * act = [GCActivity fullLoadFromDbPath:[RZFileOrganizer bundleFilePath:@"test_activity_running_837769405.db" ]];
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
    GCSimpleGraphDataHolder * speed_ma = [GCSimpleGraphDataHolder dataHolder:ma type:gcGraphLine color:[UIColor blackColor] andUnit:[GCUnit unitForKey:act.speedDisplayUom]];
    [speed_ma setLineWidth:2.];

    [sample setSeries:[NSMutableArray arrayWithObjects:speed, hr, speed_ma, nil]];
    [sample setXUnit:[GCUnit unitForKey:@"second"]];
    [sample setTitle:@"sample 9"];

    return sample;
}

-(GCSimpleGraphCachedDataSource*)sample11{
    GCField * distfield = [GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:GC_TYPE_RUNNING];
    GCField * durfield  = [GCField fieldForFlag:gcFieldFlagSumDuration andActivityType:GC_TYPE_RUNNING];

    GCHistoryFieldDataSerieConfig * config = [GCHistoryFieldDataSerieConfig configWithField:distfield  xField:durfield];
    GCHistoryFieldDataSerie * history = [[[GCHistoryFieldDataSerie alloc] initFromConfig:config] autorelease];

    [history setDb:[GCAppGlobal db]];
    [history loadFromDb];

    GCSimpleGraphCachedDataSource * sample = [GCSimpleGraphCachedDataSource historyView:history
                                                                           calendarUnit:NSCalendarUnitYear
                                                                            graphChoice:gcGraphChoiceCumulative after:nil];

    return sample;
}

-(NSArray<GCSimpleGraphCachedDataSource*>*)sample_12_trackStats{
    GCActivity * activity = [GCActivity fullLoadFromDbPath:[RZFileOrganizer bundleFilePath:@"test_activity_running_837769405.db" ]];
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


    [trackStats release];
    return rv;
}

-(NSArray<GCSimpleGraphCachedDataSource*>*)sample13_compareStats{
    GCActivity * activity = [GCActivity fullLoadFromDbPath:[RZFileOrganizer bundleFilePath:@"test_activity_running_828298988.db" ]];
    GCActivity * compare = [GCActivity fullLoadFromDbPath:[RZFileOrganizer bundleFilePath:@"test_activity_running_1266384539.db"]];

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
    GCCellActivity * cell =  nil;

    NSMutableArray * rv = [NSMutableArray array];

    cell = [GCCellActivity activityCell:nil];
    act = [GCActivity fullLoadFromDbPath:[RZFileOrganizer bundleFilePath:@"test_activity_day___healthkit__Default_20151106.db"]];
    [cell setupForActivity:act];
    [rv addObject:[GCTestUISampleCellHolder holderFor:cell height:kGCCellActivityDefaultHeight andIdentifier:@"Day Activity hr"]];

    cell = [GCCellActivity activityCell:nil];
    act = [GCActivity fullLoadFromDbPath:[RZFileOrganizer bundleFilePath:@"test_activity_day___healthkit__Default_20151109.db"]];
    [cell setupForActivity:act];
    [rv addObject:[GCTestUISampleCellHolder holderFor:cell height:kGCCellActivityDefaultHeight andIdentifier:@"Day Activity nohr"]];

    return rv;
}

-(NSArray*)sampleActivities{
    GCCellGrid * cell = nil;

    GCActivity *act=nil;

    NSMutableArray * activity = [NSMutableArray array];


    act =[GCActivity fullLoadFromDbPath:[RZFileOrganizer bundleFilePath:@"test_activity_running_837769405.db" ]];
    cell = [GCCellGrid gridCell:nil];
    [cell setupSummaryFromActivity:act width:320. status:gcViewActivityStatusNone];
    [activity addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Running Activity Base"]];
    cell = [GCCellGrid gridCell:nil];
    [cell setupSummaryFromActivity:act width:320. status:gcViewActivityStatusCompare];
    [activity addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Running Activity Compare"]];
    cell = [GCCellGrid gridCell:nil];
    [cell setupDetailHeader:act];
    [activity addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Running Activity Detail"]];
    cell = [GCCellGrid gridCell:nil];
    [cell setupForField:@"WeightedMeanPace" andActivity:act width:320.];
    [activity addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Running Activity Pace Field"]];
    if ([act trackpointsReadyOrLoad] && [[act laps] count] > 0) {
        cell = [GCCellGrid gridCell:nil];
        [cell setupForLap:0 andActivity:act width:320.];
        [activity addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Running Activity Lap"]];
    }

    act =[GCActivity fullLoadFromDbPath:[RZFileOrganizer bundleFilePath:@"test_activity_swimming_439303647.db" ]];
    cell = [GCCellGrid gridCell:nil];
    [cell setupSummaryFromActivity:act width:320. status:gcViewActivityStatusNone];
    [activity addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Swim Activity Base"]];
    cell = [GCCellGrid gridCell:nil];
    [cell setupDetailHeader:act];
    [activity addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Swim Activity Detail"]];
    cell = [GCCellGrid gridCell:nil];
    [cell setupForField:@"WeightedMeanPace" andActivity:act width:320.];
    [activity addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Swim Activity Pace Field"]];
    if ([act trackpointsReadyOrLoad] && [[act laps] count] > 0) {
        cell = [GCCellGrid gridCell:nil];
        [cell setupForLap:0 andActivity:act width:320.];
        [activity addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Swim Activity Lap"]];
    }

    act =[GCActivity fullLoadFromDbPath:[RZFileOrganizer bundleFilePath:@"test_activity_cycling_940863203.db" ]];

    cell = [GCCellGrid gridCell:nil];
    [cell setupSummaryFromActivity:act width:320. status:gcViewActivityStatusNone];
    [activity addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Cycle Activity Base"]];
    cell = [GCCellGrid gridCell:nil];
    [cell setupDetailHeader:act];
    [activity addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Cycle Activity Detail"]];
    cell = [GCCellGrid gridCell:nil];
    [cell setupForField:@"WeightedMeanSpeed" andActivity:act width:320.];
    [activity addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Cycle Activity Speed Field"]];
    if ([act trackpointsReadyOrLoad] && [[act laps] count] > 0) {
        cell = [GCCellGrid gridCell:nil];
        [cell setupForLap:0 andActivity:act width:320.];
        [activity addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Cycle Activity Lap"]];
    }

    return activity;
}

-(NSArray*)sampleMultiFieldsStats{
    NSMutableArray * rv = [NSMutableArray array];

    GCStatsMultiFieldViewController * vc = RZReturnAutorelease([[GCStatsMultiFieldViewController alloc] initWithStyle:UITableViewStyleGrouped]);
    GCStatsMultiFieldConfig * config = RZReturnAutorelease([[GCStatsMultiFieldConfig alloc] init]);
    config.activityType = GC_TYPE_RUNNING;
    config.viewChoice = gcViewChoiceAll;
    config.historyStats = gcHistoryStatsAll;
    config.calChoice = gcStatsCalAll;

    UITableView * tableView = vc.tableView;

    [vc setupTestModeWithFieldListConfig:config];

    UITableViewCell * cell = [vc tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:GC_SECTION_DATA]];

    [rv addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Stats Multi Distance"]];
    cell = [vc tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:GC_SECTION_DATA+1]];
    [rv addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Stats Multi Time"]];
    cell = [vc tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:GC_SECTION_DATA+2]];
    [rv addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Stats Multi HR"]];

    config.viewChoice = gcViewChoiceMonthly;
    [vc setupTestModeWithFieldListConfig:config];
    cell = [vc tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:GC_SECTION_DATA]];
    [rv addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Stats Multi Last Month"]];

    return rv;
}

-(NSArray*)sampleStats{
    static NSString *CellIdentifier = @"Cell";
    GCCellGrid * cell = nil;

    NSMutableArray * stats = [NSMutableArray array];

    GCHistoryAggregatedActivityStats * aggregatedStats = [[[GCHistoryAggregatedActivityStats alloc] init] autorelease];
    [aggregatedStats setActivityType:GC_TYPE_RUNNING];
    [aggregatedStats setActivitiesFromOrganizer:[GCAppGlobal organizer]];
    [aggregatedStats aggregate:NSCalendarUnitWeekOfYear referenceDate:nil ignoreMode:gcIgnoreModeActivityFocus];

    cell = [[[GCCellGrid alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    [cell setupFromHistoryAggregatedData:[aggregatedStats dataForIndex:0] index:0 viewChoice:gcViewChoiceWeekly andActivityType:GC_TYPE_RUNNING width:320.];
    [stats addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Running Stats Weekly"]];

    [aggregatedStats aggregate:NSCalendarUnitMonth referenceDate:nil ignoreMode:gcIgnoreModeActivityFocus];
    cell = [[[GCCellGrid alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    [cell setupFromHistoryAggregatedData:[aggregatedStats dataForIndex:0] index:0 viewChoice:gcViewChoiceMonthly andActivityType:GC_TYPE_RUNNING width:320.];
    [stats addObject:[GCTestUISampleCellHolder holderFor:cell andIdentifier:@"Running Stats Monthly"]];

    return stats;
}

-(NSArray*)sampleIcons{
    NSMutableArray * icons = [NSMutableArray arrayWithCapacity:10];
    for (NSString * type in @[GC_TYPE_RUNNING,GC_TYPE_SWIMMING,GC_TYPE_OTHER,GC_TYPE_CYCLING,GC_TYPE_FITNESS,GC_TYPE_HIKING]) {
        GCTestIconsCell * iconCell = [GCTestIconsCell iconsCellForActivityType:type];
        NSString * identifier = [NSString stringWithFormat:@"Icons %@", type];
        [icons addObject:[GCTestUISampleCellHolder holderFor:iconCell andIdentifier:identifier]];
    }
    return icons;
}


-(NSArray*)gridCellSamples{
    [GCAppGlobal setupSampleState:@"sample_activities.db"];

    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:10];

    [rv addObject:[self sampleCells]];
    [rv addObject:[self sampleDayActivities]];
    [rv addObject:[self sampleMultiFieldsStats]];
    [rv addObject:[self sampleActivities]];
    [rv addObject:[self sampleStats]];
    [rv addObject:[self sampleIcons]];

    return rv;
}
@end
