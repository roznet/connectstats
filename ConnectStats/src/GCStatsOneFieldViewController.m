//  MIT Licence
//
//  Created on 29/09/2012.
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

#import "GCStatsOneFieldViewController.h"
#import "GCViewConfig.h"
#import "GCAppGlobal.h"
#import "GCSimpleGraphCachedDataSource+Templates.h"
#import "GCCellGrid+Templates.h"
#import "GCStatsMultiFieldGraphViewController.h"
#import "Flurry.h"
#import "GCStatsOneFieldGraphViewController.h"
#import "GCFields.h"
#import "GCViewConfig.h"
@import RZExternal;
#import "GCStatsGraphOptionViewController.h"
#import "GCHistoryPerformanceAnalysis.h"
#import "GCActivitiesOrganizer.h"
#import "GCStatsCalendarAggregationConfig.h"
#import "GCHistoryAggregatedStats.h"
#import "GCStatsMultiFieldConfig.h"
#import "ConnectStats-Swift.h"
@import RZUtilsSwift;
@import RZUtilsTouch;
@import RZUtilsTouchSwift;

#define GC_S_NAME 0
#define GC_S_GRAPH 1
#define GC_S_AVERAGE 2
#define GC_S_QUARTILES 3
#define GC_S_AGGREGATE 4
#define GC_S_END 5

@interface GCStatsOneFieldViewController (){
    NSUInteger movingAverageSample;
}
@property (nonatomic,assign) BOOL activityStatsLock;
@property (nonatomic,assign) BOOL scatterStatsLock;
@property (nonatomic,retain) RZNumberWithUnitGeometry * geometry;
@property (nonatomic,readonly) GCStatsMultiFieldConfig * multiFieldConfig;
@property (nonatomic,retain) UIViewController * popoverViewController;
@property (nonatomic,retain) UIBarButtonItem * rightMostButtonItem;

@end

@implementation GCStatsOneFieldViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.oneFieldConfig = [[[GCStatsOneFieldConfig alloc] init] autorelease];
    }
    return self;
}

-(void)dealloc{
    [_fieldDataSerie release];
    [_summarizedHistory release];
    [_average release];
    [_quartiles release];
    [_fieldDataSerieXY release];
    [_aggregatedStats release];
    
    [_oneFieldConfig release];
    [_performanceAnalysis release];
    [_fieldOrder release];
    [_geometry release];
    [_popoverViewController release];
    [_rightMostButtonItem release];
    
    [super dealloc];
}
-(GCStatsMultiFieldConfig*)multiFieldConfig{
    return self.oneFieldConfig.multiFieldConfig;
}
-(void)setupForConfig:(GCStatsOneFieldConfig*)oneFieldConfig{

    self.oneFieldConfig = oneFieldConfig;
    self.oneFieldConfig.multiFieldConfig.comparisonMetric = gcComparisonMetricPercent;

    [self clearAll];
    
    dispatch_async([GCAppGlobal worker], ^(){
        [self calculate];
        [self notifyCallBack:self info:nil];
    });
}

-(BOOL)isNewStyle{
    return [GCViewConfig is2021Style];
}

-(void)clearAll{
    self.fieldDataSerie = nil;
    self.fieldDataSerieXY = nil;
    //self.summarizedHistory = nil;
    self.aggregatedStats = nil;
    self.quartiles = nil;
    self.average = nil;
}

-(void)calculate{
    GCHistoryFieldDataSerie * stats = [GCHistoryFieldDataSerie historyFieldDataSerieLoadedFromConfig:self.oneFieldConfig.historyConfig andOrganizer:[GCAppGlobal organizer]];
    self.fieldDataSerie = stats;
    if (self.oneFieldConfig.x_field) {
            GCHistoryFieldDataSerie * xystats = [GCHistoryFieldDataSerie historyFieldDataSerieLoadedFromConfig:self.oneFieldConfig.historyConfigXY andOrganizer:[GCAppGlobal organizer]];
            self.fieldDataSerieXY = xystats;
    }
    GCStatsCalendarAggregationConfig * calendarConfig = self.oneFieldConfig.calendarConfig;
    /*self.summarizedHistory = [_activityStats.history.serie aggregatedStatsByCalendarUnit:calendarConfig.calendarUnit
                                                                           referenceDate:calendarConfig.referenceDate
                                                                             andCalendar:calendarConfig.calendar];
    */
    self.aggregatedStats = [GCHistoryAggregatedStats aggregatedStatsForActivityTypeSelection:self.multiFieldConfig.activityTypeSelection];
    
    [self.aggregatedStats setActivities:[GCAppGlobal organizer].activities andFields:self.oneFieldConfig.fieldsForAggregation];
    [self.aggregatedStats aggregate:calendarConfig.calendarUnit
                      referenceDate:calendarConfig.referenceDate
                             cutOff:calendarConfig.cutOff
                         ignoreMode:self.multiFieldConfig.activityTypeDetail.ignoreMode];
    
    self.geometry = [RZNumberWithUnitGeometry geometry];
    GCActivityType * type = self.multiFieldConfig.activityTypeDetail;
    for (GCHistoryAggregatedDataHolder * holder in self.aggregatedStats) {
        [GCCellGrid adjustAggregatedWithDataHolder:holder activityType:type geometry:self.geometry];
    }

    self.quartiles = [_fieldDataSerie.history.serie quantiles:4];
    self.average = [_fieldDataSerie.history.serie standardDeviation];
}
-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo*)theInfo{

    dispatch_async(dispatch_get_main_queue(), ^(){
        [self.tableView reloadData];
    });
}

-(void)changeXField:(GCField*)xField{
    if (![xField isEqualToField:_oneFieldConfig.x_field]) {
        dispatch_async([GCAppGlobal worker], ^(){
            if (self.oneFieldConfig.x_field) {
                    GCHistoryFieldDataSerie * xystats = [GCHistoryFieldDataSerie historyFieldDataSerieLoadedFromConfig:self.oneFieldConfig.historyConfigXY andOrganizer:[GCAppGlobal organizer]];
                    self.fieldDataSerieXY = xystats;
            }
            [self notifyCallBack:self info:nil];
        });
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupBarButtonItem];
    movingAverageSample = 0;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [GCViewConfig setupViewController:self];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Configuration Update from UI

-(void)setupBarButtonItem{
//    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:[GCViewConfig viewChoiceDesc:self.oneFieldConfig.viewChoice
//                                                                                          calendarConfig:self.oneFieldConfig.calendarConfig] style:UIBarButtonItemStylePlain
//                                                                     target:self action:@selector(toggleViewChoice)];
//    self.navigationItem.rightBarButtonItem = anotherButton;
//    [anotherButton release];
    
    self.rightMostButtonItem = [self.oneFieldConfig viewChoiceButtonForTarget:self action:@selector(nextView) longPress:@selector(configLongPress:)];
    UIBarButtonItem * cal = [self.oneFieldConfig viewConfigButtonForTarget:self action:@selector(nextViewConfig) longPress:@selector(configLongPress:)];
    if( self.rightMostButtonItem ){
        self.navigationItem.rightBarButtonItems = cal ? @[self.rightMostButtonItem,cal] : @[ self.rightMostButtonItem ];
    }

    if (self.useFilter) {
        (self.navigationController.navigationBar.topItem).title = [GCAppGlobal organizer].lastSearchString;
    }
}

-(void)nextView{
    [self.oneFieldConfig nextView];
    
    [self clearAll];
    dispatch_async([GCAppGlobal worker], ^(){
        [self calculate];
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.tableView reloadData];
        });
    });
    
    [self setupBarButtonItem];

    [self.tableView reloadData];
}
-(void)nextViewConfig{
    [self.oneFieldConfig nextViewConfig];
    
    [self clearAll];
    dispatch_async([GCAppGlobal worker], ^(){
        [self calculate];
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.tableView reloadData];
        });
    });
    
    [self setupBarButtonItem];
}

-(void)configLongPress:(UIGestureRecognizer*)gesture{
    if( gesture.state == UIGestureRecognizerStateBegan){
        GCStatsOneFieldConfigViewController * controller=[[[GCStatsOneFieldConfigViewController alloc] initWithNibName:@"GCStatsOneFieldConfigViewController" bundle:nil] autorelease];
        controller.oneFieldViewController = self;
        controller.modalPresentationStyle = UIModalPresentationPopover;
        self.popoverViewController = controller;
        RZAutorelease([[UIPopoverPresentationController alloc] initWithPresentedViewController:controller
                                                                      presentingViewController:self.presentingViewController]);
        controller.popoverPresentationController.barButtonItem = self.rightMostButtonItem;
        [self presentViewController:controller animated:YES completion:nil];
    }

}

-(BOOL)useFilter{
    return self.multiFieldConfig.useFilter;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return GC_S_END;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == GC_S_NAME) {
        return 1;
    }else if( section == GC_S_AVERAGE){
        if( self.isNewStyle ){
            return 0;
        }
        return 1;
    }else if(section == GC_S_QUARTILES){
        if( self.isNewStyle ){
            return 0;
        }
        if (_oneFieldConfig.viewChoice == gcViewChoiceFields) {
            return 2;
        }else{
            return [_summarizedHistory[STATS_AVG] count];
        }
    }else if(section == GC_S_GRAPH){
        if (_oneFieldConfig.viewChoice == gcViewChoiceFields) {
            if ( _activityStatsLock == false && _scatterStatsLock==false && [_fieldDataSerie ready] && [_fieldDataSerieXY ready]) {
                return 2;
            }
        }else{
            return 1;
        }
    }else if( section == GC_S_AGGREGATE){
        if( self.isNewStyle ){
            return self.aggregatedStats.count;
        }else{
            return 0;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView aggregatedCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GCCellGrid *cell = [GCCellGrid cellGrid:tableView];

    GCHistoryAggregatedDataHolder * data = [self.aggregatedStats dataForIndex:indexPath.row];
    if( data ){
        if( self.isNewStyle ){
            GCHistoryAggregatedDataHolder * comp = [self.aggregatedStats dataForIndex:indexPath.row+1];
            
            [cell setupAggregatedComparisonWithField:self.oneFieldConfig.field
                                          dataHolder:data
                                    comparisonHolder:comp
                                               index:indexPath.row
                                    multiFieldConfig:self.multiFieldConfig
                                        activityType:self.multiFieldConfig.activityTypeDetail
                                            geometry:self.geometry
                                                wide:false];
        }
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == GC_S_GRAPH) {
        if (indexPath.row == 1) {
            GCCellSimpleGraph * cell = [GCCellSimpleGraph graphCell:tableView];

            GCSimpleGraphCachedDataSource * cache = nil;
            if (self.oneFieldConfig.secondGraphChoice == gcOneFieldSecondGraphHistory) {
                cache = [self.multiFieldConfig dataSourceForFieldDataSerie:self.fieldDataSerie];
                if (self.multiFieldConfig.graphChoice == gcGraphChoiceCumulative) {// This is Cumulative graph, needs legend
                    cell.legend = true;
                }else{
                    cell.legend = false;
                }
            }else if(self.oneFieldConfig.secondGraphChoice == gcOneFieldSecondGraphHistogram){
                cache = [GCSimpleGraphCachedDataSource fieldHistoryHistogramFrom:_fieldDataSerie width:tableView.frame.size.width];
            }else if(self.oneFieldConfig.secondGraphChoice == gcOneFieldSecondGraphPerformance){
                NSDate *from=[[[GCAppGlobal organizer] lastActivity].date dateByAddingGregorianComponents:[NSDateComponents dateComponentsFromString:@"-6m"]];
                self.performanceAnalysis = [GCHistoryPerformanceAnalysis performanceAnalysisFromDate:from forField:self.oneFieldConfig.field];
                
                [self.performanceAnalysis calculate];
                
                cache = [GCSimpleGraphCachedDataSource performanceAnalysis:self.performanceAnalysis width:tableView.frame.size.width];
            }
            [cell setDataSource:cache andConfig:cache];
            return cell;
        }else{
            GCCellSimpleGraph * cell = [GCCellSimpleGraph graphCell:tableView];
            
            if (_oneFieldConfig.viewChoice==gcViewChoiceFields) {
                GCSimpleGraphCachedDataSource * cache = [GCSimpleGraphCachedDataSource scatterPlotCacheFrom:_fieldDataSerieXY];
                [cell setDataSource:cache andConfig:cache];
            }else{
                if ([_fieldDataSerie ready]) {
                    GCSimpleGraphCachedDataSource * cache = [self.multiFieldConfig dataSourceForFieldDataSerie:self.fieldDataSerie];
                    NSCalendarUnit unit = _oneFieldConfig.calendarConfig.calendarUnit;
                    //FIXME: check to use Field
                    gcGraphChoice choice = [GCViewConfig graphChoiceForField:_oneFieldConfig.field andUnit:unit];
                    cache = [GCSimpleGraphCachedDataSource historyView:_fieldDataSerie
                                                          calendarConfig:self.oneFieldConfig.calendarConfig
                                                           graphChoice:choice after:nil];
                    [cell setDataSource:cache andConfig:cache];
                }else{
                    GCCellActivityIndicator *icell = [GCCellActivityIndicator activityIndicatorCell:tableView parent:[GCAppGlobal web]];
                    icell.label.text = NSLocalizedString( @"Preparing Graph", @"StatsOneView");
                    return icell;
                }
            }

            return cell;
        }
    }else if(indexPath.section == GC_S_QUARTILES && _oneFieldConfig.viewChoice != gcViewChoiceFields){
        NSUInteger idx = [_summarizedHistory[STATS_AVG] count]-indexPath.row-1;
        GCCellGrid * cell = [GCCellGrid cellGrid:tableView];
        [cell setUpForSummarizedHistory:_summarizedHistory atIndex:idx forField:_oneFieldConfig.field calendarConfig:self.oneFieldConfig.calendarConfig];
        return cell;
    }else if( indexPath.section == GC_S_AGGREGATE ){
        return [self tableView:tableView aggregatedCellForRowAtIndexPath:indexPath];
    }else{
        GCCellGrid * cell = [GCCellGrid cellGrid:tableView];
        if (indexPath.section == GC_S_NAME) {
            [cell setupStatsHeaders:self.fieldDataSerie];
        }else if (indexPath.section == GC_S_AVERAGE){
            [cell setupStatsAverageStdDev:self.average for:self.fieldDataSerie];

        }else if (indexPath.section == GC_S_QUARTILES){
            [cell setupStatsQuartile:indexPath.row in:self.quartiles for:self.fieldDataSerie];
        }
        // Configure the cell...
        return cell;
    }
    return nil;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    if (indexPath.section == GC_S_GRAPH) {
        if (_oneFieldConfig.viewChoice==gcViewChoiceFields) {
            if (indexPath.row == 0) {
                GCStatsMultiFieldGraphViewController * viewController = [[GCStatsMultiFieldGraphViewController alloc] initWithNibName:nil bundle:nil];
                viewController.scatterStats = _fieldDataSerieXY;
                viewController.fieldOrder = self.fieldOrder;
                viewController.x_field = _fieldDataSerieXY.config.x_activityField;
                /*GCStatsGraphOptionViewController * optionsController = [[GCStatsGraphOptionViewController alloc] initWithStyle:UITableViewStyleGrouped];
                optionsController.graphViewController = viewController;
                 */
                if ([UIViewController useIOS7Layout]) {
                    [UIViewController setupEdgeExtendedLayout:viewController];
                }

                [self.navigationController pushViewController:viewController animated:YES];
                [viewController release];
            }else if(indexPath.row==1){
                self.oneFieldConfig.secondGraphChoice++;
                if (self.oneFieldConfig.secondGraphChoice>=gcOneFieldSecondGraphEnd) {
                    self.oneFieldConfig.secondGraphChoice = gcOneFieldSecondGraphHistory;
                }
                [self.tableView reloadData];
            }
        }else{
            GCStatsOneFieldGraphViewController * graph = [[GCStatsOneFieldGraphViewController alloc] initWithNibName:nil bundle:nil];
            //FIXME: use gcfield instead of key
            gcGraphChoice choice = [GCViewConfig graphChoiceForField:_oneFieldConfig.field andUnit:self.oneFieldConfig.calendarConfig.calendarUnit];

            [graph setupForHistoryField:self.fieldDataSerie graphChoice:choice andConfig:_oneFieldConfig];
            
            graph.canSum = [_oneFieldConfig.field canSum];

            if ([UIViewController useIOS7Layout]) {
                [UIViewController setupEdgeExtendedLayout:graph];
            }

            [self.navigationController pushViewController:graph animated:YES];
            [graph release];

        }
    }else if(indexPath.section==GC_S_QUARTILES && _oneFieldConfig.viewChoice != gcViewChoiceFields){
        NSUInteger n = [_summarizedHistory[STATS_CNT] count];
        if (indexPath.row < n) {
            NSUInteger idx = n-indexPath.row-1;
            GCStatsDataPoint * point = [_summarizedHistory[STATS_CNT] dataPointAtIndex:idx];
            NSDate * date = [point date];
            NSNumber * cnt = @(point.y_data);
            [GCAppGlobal debugStateRecord:@{DEBUGSTATE_LAST_CNT:cnt}];

            NSString * filter = [GCViewConfig filterFor:_oneFieldConfig.calendarConfig date:date andActivityType:_oneFieldConfig.activityType];
            [GCAppGlobal focusOnListWithFilter:filter];

        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == GC_S_GRAPH ) {
        return 200.;
    }else if(indexPath.section == GC_S_QUARTILES && _oneFieldConfig.viewChoice != gcViewChoiceFields){
        return 64.;
    }else if(indexPath.section == GC_S_AGGREGATE && self.isNewStyle){
        if( self.multiFieldConfig.comparisonMetric == gcComparisonMetricNone){
            //GCHistoryAggregatedDataHolder * data = [self.aggregatedStats dataForIndex:indexPath.row];
            CGFloat height = [GCViewConfig sizeForNumberOfRows:6];
            return height;
        }else{
            CGFloat height = [GCViewConfig sizeForNumberOfRows:6];
            return height;
        }

    }else{
        return 58.;
    }
}


@end



