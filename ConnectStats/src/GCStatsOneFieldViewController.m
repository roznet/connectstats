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

@interface GCStatsOneFieldViewController ()

@property (nonatomic,assign) BOOL activityStatsLock;
@property (nonatomic,assign) BOOL scatterStatsLock;
@property (nonatomic,retain) RZNumberWithUnitGeometry * geometry;
@property (nonatomic,readonly) GCStatsMultiFieldConfig * multiFieldConfig;
@property (nonatomic,retain) UIViewController * popoverViewController;
@property (nonatomic,retain) UIBarButtonItem * rightMostButtonItem;

/**
 * main field serie for oneFieldConfig.field
 */
@property (nonatomic,retain) GCHistoryFieldDataSerie * fieldDataSerie;
/**
 * field serie xy for scatter plots with y = oneFieldConfig.field and x = oneFieldConfig.x_field
 */
@property (nonatomic,retain) GCHistoryFieldDataSerie * fieldDataSerieXY;
@property (nonatomic,retain) GCHistoryAggregatedStats * aggregatedStats;
@property (nonatomic,retain) GCHistoryPerformanceAnalysis * performanceAnalysis;

@property (nonatomic,readonly) BOOL isNewStyle;

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
    [_fieldDataSerieXY release];
    [_aggregatedStats release];
    
    [_oneFieldConfig release];
    [_performanceAnalysis release];
    [_fieldOrder release];
    [_geometry release];
    [_popoverViewController release];
    [_rightMostButtonItem release];
    [_updateCallback release];
    
    [super dealloc];
}
-(GCStatsMultiFieldConfig*)multiFieldConfig{
    return self.oneFieldConfig.multiFieldConfig;
}

-(void)setupForFieldListConfig:(GCStatsOneFieldConfig*)oneFieldConfig{

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
    self.aggregatedStats = nil;
}

-(void)calculate{
    GCHistoryFieldDataSerie * stats = [GCHistoryFieldDataSerie historyFieldDataSerieLoadedFromConfig:self.oneFieldConfig.historyConfig andOrganizer:[GCAppGlobal organizer]];
    self.fieldDataSerie = stats;
    
    [self calculateXY];
    
    GCStatsCalendarAggregationConfig * calendarConfig = self.oneFieldConfig.calendarConfig;
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
}

-(void)calculateXY{
    if (self.oneFieldConfig.x_field) {
        GCHistoryFieldDataSerieConfig * configXY = self.oneFieldConfig.historyConfigXY;
        // will be nil if all selected
        configXY.fromDate = [self.multiFieldConfig selectAfterDateFrom:self.fieldDataSerie.lastDate];
        
        GCHistoryFieldDataSerie * xystats = [GCHistoryFieldDataSerie historyFieldDataSerieLoadedFromConfig:configXY andOrganizer:[GCAppGlobal organizer]];
        self.fieldDataSerieXY = xystats;
    }else{
        self.fieldDataSerieXY = nil;
    }
}

#pragma mark - Notification and changes

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo*)theInfo{

    dispatch_async(dispatch_get_main_queue(), ^(){
        [self.tableView reloadData];
        if( self.updateCallback ){
            self.updateCallback();
        }
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
        return 0;
    }else if(section == GC_S_QUARTILES){
        return 0;
    }else if(section == GC_S_GRAPH){
        if ( _activityStatsLock == false && _scatterStatsLock == false && self.fieldDataSerie.ready && self.fieldDataSerieXY.ready) {
            return 2;
        }
        return 1;
    }else if( section == GC_S_AGGREGATE){
        return self.aggregatedStats.count;
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
            
            NSDate * afterdate = [self.multiFieldConfig selectAfterDateFrom:self.fieldDataSerie.lastDate];
            
            if( !RZNilOrEqualToDate(afterdate, self.fieldDataSerieXY.config.fromDate) ){
                // After Date for scatter point field serie have to be recalculated because
                // the serie x is not the date
                RZLog(RZLogInfo, @"Recalculate XY serie because %@ != %@", afterdate, self.fieldDataSerieXY.config.fromDate);
                [self calculateXY];
            }
            GCSimpleGraphCachedDataSource * cache = [GCSimpleGraphCachedDataSource scatterPlotCacheFrom:self.fieldDataSerieXY];
            [cell setDataSource:cache andConfig:cache];

            return cell;
        }
    }else if(indexPath.section == GC_S_QUARTILES){
        GCCellGrid * cell = [GCCellGrid cellGrid:tableView];
        return cell;
    }else if( indexPath.section == GC_S_AGGREGATE ){
        return [self tableView:tableView aggregatedCellForRowAtIndexPath:indexPath];
    }else{
        GCCellGrid * cell = [GCCellGrid cellGrid:tableView];
        if (indexPath.section == GC_S_NAME) {
            [cell setupStatsHeaders:self.fieldDataSerie];
        }else if (indexPath.section == GC_S_AVERAGE){
        }else if (indexPath.section == GC_S_QUARTILES){
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
        if (indexPath.row == 0) {
            GCStatsMultiFieldGraphViewController * viewController = [[GCStatsMultiFieldGraphViewController alloc] initWithNibName:nil bundle:nil];
            viewController.scatterStats = self.fieldDataSerieXY;
            viewController.fieldOrder = self.fieldOrder;
            viewController.x_field = self.fieldDataSerieXY.config.x_activityField;
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
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == GC_S_GRAPH ) {
        return 200.;
    }else if(indexPath.section == GC_S_QUARTILES){
        return 64.;
    }else if(indexPath.section == GC_S_AGGREGATE){
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



