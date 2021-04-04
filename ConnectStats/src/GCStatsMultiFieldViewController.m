//  MIT Licence
//
//  Created on 04/10/2012.
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

#import "GCStatsMultiFieldViewController.h"
#import "GCAppGlobal.h"
#import "GCFields.h"
#import "GCViewConfig.h"
#import "GCStatsOneFieldViewController.h"
#import "GCCellGrid+Templates.h"
#import "Flurry.h"
#import "GCSimpleGraphCachedDataSource+Templates.h"
#import "GCStatsOneFieldGraphViewController.h"
#import "GCViewIcons.h"
#import "GCTableHeaderFieldsCategory.h"
#import "GCHistoryPerformanceAnalysis.h"
#import "GCStatsMultiFieldViewControllerConsts.h"
#import "GCFieldsForCategory.h"
#import "GCDerivedGroupedSeries.h"
#import "GCDerivedOrganizer.h"
#import "GCHealthOrganizer.h"
#import "GCStatsDerivedAnalysisViewController.h"
#import "GCStatsDerivedHistory.h"
#import "GCStatsDerivedHistoryViewController.h"
#import "ConnectStats-Swift.h"
@import RZUtilsSwift;

@interface GCStatsMultiFieldViewController ()
@property (nonatomic,retain) GCHistoryPerformanceAnalysis * performanceAnalysis;
@property (nonatomic,retain) GCStatsDerivedHistory * derivedHistAnalysis;

@property (nonatomic,assign) BOOL started;
@property (nonatomic,retain) GCStatsDerivedAnalysisViewController * configViewController;
@property (nonatomic,retain) GCStatsDerivedHistoryViewController * histAnalysisViewController;
@property (nonatomic,retain) UIViewController * popoverViewController;
@property (nonatomic,retain) RZNumberWithUnitGeometry * geometry;
@property (nonatomic,retain) UIBarButtonItem * rightMostButtonItem;
@end

@implementation GCStatsMultiFieldViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
        [[GCAppGlobal organizer] attach:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyCallBack:) name:kNotifySettingsChange object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyCallBack:) name:kNotifyOrganizerLoadComplete object:nil];

    }
    return self;
}

-(void)dealloc{
    [_popoverViewController release];
    [_activityTypeButton release];
    [self clearFieldDataSeries];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[GCAppGlobal organizer] detach:self];
    [_performanceAnalysis release];
    [_aggregatedStats release];
    [_fieldOrder release];
    [_fieldStats release];
    [_fieldDataSeries release];
    [_rightMostButtonItem release];
    [_allFields release];
    [_multiFieldConfig release];
    [_configViewController release];
    [_updateCallback release];
    [_geometry release];
    
    [super dealloc];
}

-(BOOL)isNewStyle{
    return [GCViewConfig is2021Style];
}

-(NSString*)activityType{
    return self.activityTypeDetail.primaryActivityType.key;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.hidesBackButton = YES;
    self.activityTypeButton = [GCViewActivityTypeButton activityTypeButtonForDelegate:self];
    
    [self setupBarButtonItem];

}

// If summary stat is the first view to appear
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    [GCAppGlobal startupRefreshIfNeeded];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if( ! self.started){
        [self setupForCurrentActivityAndViewChoice:gcViewChoiceSummary];
        [GCViewConfig setupViewController:self];
        RZLog(RZLogInfo, @"Initial start page %@", self.multiFieldConfig);
    }
    self.started = true;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.viewChoice==gcViewChoiceFields) {
        return GC_SECTION_DATA+_fieldOrder.count;
    }else if (self.viewChoice==gcViewChoiceSummary){
        return 1;
    }else{
        return GC_SECTION_END;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (self.viewChoice == gcViewChoiceFields) {
        if (section == GC_SECTION_GRAPH) {
            return 0;
        }else{
            NSArray * fields = [self fieldsForSection:section];
            return fields.count;
        }
    }else if(self.viewChoice == gcViewChoiceSummary){
        return GC_SUMMARY_END;
    }else{
        if (section==GC_SECTION_GRAPH) {
            GCHistoryFieldDataSerie * fieldDataSerie = [self fieldDataSerieFor:[GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:self.activityType]];

            return [fieldDataSerie ready] ? 1 : 0;
        }
        return [self.aggregatedStats count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * rv =nil;
    if (self.viewChoice == gcViewChoiceSummary){
        rv = [self tableView:tableView summaryCellForRowAtIndexPath:indexPath];
    }else if (self.viewChoice == gcViewChoiceFields) {
        rv = [self tableView:tableView fieldSummaryCell:indexPath];
    }else{
        if (indexPath.section == 0) {
            rv = [self tableView:tableView graphCell:indexPath];
        }else{
            rv = [self tableView:tableView aggregatedCell:indexPath];
        }
    }

    return rv;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.viewChoice == gcViewChoiceSummary) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            return 230.;
        }else{
            return 200.;
        }
    }else if( self.viewChoice == gcViewChoiceFields){
        return [GCViewConfig sizeForNumberOfRows:3];
    }else if( self.viewChoice == gcViewChoiceCalendar){
        if (indexPath.section == GC_SECTION_GRAPH ) {
            return 200.;
        }else{
            if( self.multiFieldConfig.comparisonMetric == gcComparisonMetricNone){
                //GCHistoryAggregatedDataHolder * data = [self.aggregatedStats dataForIndex:indexPath.row];
                CGFloat height = [GCViewConfig sizeForNumberOfRows:3];
                return height;
            }else{
                CGFloat height = [GCViewConfig sizeForNumberOfRows:6];
                return height;
            }
        }
    }
    return 58.;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(self.viewChoice == gcViewChoiceFields ){
        NSString * category = [self categoryNameForSection:section];
        return [GCTableHeaderFieldsCategory tableView:tableView viewForHeaderCategory:category];
    }else{
        return RZReturnAutorelease([[UIView alloc] initWithFrame:CGRectZero]);
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(self.viewChoice == gcViewChoiceFields ){
        NSString * category = [self categoryNameForSection:section];
        return [GCTableHeaderFieldsCategory tableView:tableView heightForHeaderCategory:category];
    }else{
        return 0.;
    }
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(self.viewChoice == gcViewChoiceFields ){
        return [self categoryNameForSection:section];
    }else{
        return nil;
    }
}


#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.viewChoice==gcViewChoiceSummary){
        if (indexPath.row == GC_SUMMARY_DERIVED) {
            [self.derivedAnalysisConfig nextDerivedSerie];
            [tableView reloadData];
        }else if (indexPath.row == GC_SUMMARY_CUMULATIVE_DISTANCE){
            [self.multiFieldConfig nextSummaryCumulativeField];
            [tableView reloadData];
        }
    }else if (self.viewChoice == gcViewChoiceFields) {
        GCField * field = [self fieldsForSection:indexPath.section][indexPath.row];
        GCField * xfield = [GCViewConfig nextFieldForGraph:nil fieldOrder:[GCViewConfig validChoicesForGraphIn:self.allFields] differentFrom:field];
        
        GCStatsOneFieldViewController *statsViewController = [[GCStatsOneFieldViewController alloc] initWithStyle:UITableViewStylePlain];
        statsViewController.fieldOrder = self.fieldOrder;
        
        [statsViewController setupForConfig:[GCStatsOneFieldConfig configFromMultiFieldConfig:self.multiFieldConfig forY:field andX:xfield]];
        
        [UIViewController setupEdgeExtendedLayout:statsViewController];
        
        [self.navigationController pushViewController:statsViewController animated:YES];
        [statsViewController release];
    }else{
        if (indexPath.section >= GC_SECTION_DATA) {
            GCHistoryAggregatedDataHolder * data = [self.aggregatedStats dataForIndex:indexPath.row];
            NSString * filter = [GCViewConfig filterFor:self.multiFieldConfig.calendarConfig date:data.date andActivityType:self.activityType];
            GCNumberWithUnit * sum = [data numberWithUnit:[GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:self.activityType] statType:gcAggregatedSum];
            GCNumberWithUnit * cnt = [data numberWithUnit:[GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:self.activityType] statType:gcAggregatedCnt];
            
            [GCAppGlobal debugStateRecord:@{
                DEBUGSTATE_LAST_CNT : cnt.number,
                DEBUGSTATE_LAST_SUM : sum.number
            }];
            [GCAppGlobal focusOnListWithFilter:filter];
            self.multiFieldConfig.viewConfig = gcStatsViewConfigAll;
            [self setupForCurrentActivityType:GC_TYPE_ALL filter:true andViewChoice:gcViewChoiceFields];
        }else if (indexPath.section == GC_SECTION_GRAPH){
            GCStatsOneFieldGraphViewController * graph = [[GCStatsOneFieldGraphViewController alloc] initWithNibName:nil bundle:nil];
            gcGraphChoice choice = self.multiFieldConfig.graphChoice;
            
            GCHistoryFieldDataSerie * fieldDataSerie = [self fieldDataSerieFor:[GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:self.activityType]];
            
            [graph setupForHistoryField:fieldDataSerie graphChoice:choice andConfig:[GCStatsOneFieldConfig configFromMultiFieldConfig:self.multiFieldConfig forY:fieldDataSerie.activityField andX:nil]];
            [graph setCanSum:true];
            if ([UIViewController useIOS7Layout]) {
                [UIViewController setupEdgeExtendedLayout:graph];
            }
            
            [self.navigationController pushViewController:graph animated:YES];
            [graph release];
        }
    }
}


#pragma mark - Historical Statistics Cells

-(GCSimpleGraphCachedDataSource*)dataSourceForField:(GCField*)field{
    GCHistoryFieldDataSerie * fieldDataSerie = [self fieldDataSerieFor:field];
    return [self.multiFieldConfig dataSourceForFieldDataSerie:fieldDataSerie];
}

- (UITableViewCell *)tableView:(UITableView *)tableView graphCell:(NSIndexPath*)indexPath{

    GCCellSimpleGraph * cell = [GCCellSimpleGraph graphCell:tableView];
    cell.cellDelegate = self;
    GCSimpleGraphCachedDataSource * cache = [self dataSourceForField:self.multiFieldConfig.currentCumulativeSummaryField];
    [cell setDataSource:cache andConfig:cache];
    if (self.multiFieldConfig.graphChoice == gcGraphChoiceCumulative) {// This is Cumulative graph, needs legend
        cell.legend = true;
    }else{
        cell.legend = false;
    }
    return cell;

}

-(UITableViewCell*)tableView:(UITableView *)tableView aggregatedCell:(NSIndexPath *)indexPath{
    GCCellGrid *cell = [GCCellGrid cellGrid:tableView];

    GCHistoryAggregatedDataHolder * data = [self.aggregatedStats dataForIndex:indexPath.row];
    if( data ){
        if( self.isNewStyle ){
            if( self.multiFieldConfig.comparisonMetric == gcComparisonMetricNone){
                [cell setupAggregatedWithDataHolder:data
                                              index:indexPath.row
                                   multiFieldConfig:self.multiFieldConfig
                                       activityType:[GCActivityType activityTypeForKey:self.displayActivityType]
                                           geometry:self.geometry
                                               wide:false
                                   comparisonHolder:nil];
            }else{
                GCHistoryAggregatedDataHolder * comp = [self.aggregatedStats dataForIndex:indexPath.row+1];
                [cell setupAggregatedComparisonWithDataHolder:data
                                             comparisonHolder:comp
                                                        index:indexPath.row
                                             multiFieldConfig:self.multiFieldConfig
                                                 activityType:[GCActivityType activityTypeForKey:self.displayActivityType]
                                                     geometry:self.geometry
                                                         wide:false];
            }
        }else{
            [cell setupFromHistoryAggregatedData:data
                                           index:indexPath.row
                                multiFieldConfig:self.multiFieldConfig
                                 andActivityType:[GCActivityType activityTypeForKey:self.displayActivityType]
                                           width:tableView.frame.size.width];
        }
    }
    return cell;
}


#pragma mark - Field Summary Cells

-(UITableViewCell*)tableView:(UITableView *)tableView fieldSummaryCell:(NSIndexPath *)indexPath{
    GCCellGrid * cell = [GCCellGrid cellGrid:tableView];
    GCField * field =[self fieldsForSection:indexPath.section][indexPath.row];

    if( field == nil ){
        [cell setupForRows:1 andCols:1];
        [cell labelForRow:0 andCol:0].text = NSLocalizedString(@"Empty",@"fieldSummaryCell");
        return cell;
    }
    static NSDictionary * doGraph = nil;
    if (doGraph==nil) {
        doGraph = @{@"SumDistance":             @1,
                    @"SumEnergy":               @1,
                    @"WeightedMeanHeartRate":   @2,
                    @"WeightedMeanPace":        @2,
                    @"WeightedMeanSpeed":       @2,
                    @"GainElevation":           @1
                    };
        [doGraph retain];
    }

    GCHistoryFieldDataHolder * data = [self.fieldStats dataForField:field];
    
    if( self.isNewStyle ){
        [cell setupFieldStatisticsWithDataHolder:data histStats:self.multiFieldConfig.historyStats geometry:self.geometry];
    }else{
        [cell setupForFieldDataHolder:data histStats:self.multiFieldConfig.historyStats andActivityType:self.activityType];
    }
    CGSize iconSize = CGSizeMake( tableView.frame.size.width > 400. ? 128. : 64., 60.);
    if ([GCAppGlobal configGetBool:CONFIG_STATS_INLINE_GRAPHS defaultValue:true] && doGraph[field.key]) {
        GCSimpleGraphCachedDataSource * cache = [self dataSourceForField:field];
        cache.maximizeGraph = true;

        GCSimpleGraphView * view = [[GCSimpleGraphView alloc] initWithFrame:CGRectZero];
        view.displayConfig = cache;
        view.dataSource = cache;
        [cell setIconView:view withSize:iconSize];
        [view release];
    }else{
        UIView * empty = RZReturnAutorelease([[UIView alloc] initWithFrame:CGRectZero]);
        empty.backgroundColor = [UIColor clearColor];
        cell.iconView = empty;
        cell.iconSize = iconSize;
    }

    return cell;
}


#pragma mark - Analysis Summary Cells

-(UITableViewCell*)tableView:(UITableView *)tableView performanceCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GCCellSimpleGraph * graphCell = [GCCellSimpleGraph graphCell:tableView];

    NSDate *from=[[[GCAppGlobal organizer] lastActivity].date dateByAddingGregorianComponents:[NSDateComponents dateComponentsFromString:@"-6m"]];
    self.performanceAnalysis = [GCHistoryPerformanceAnalysis performanceAnalysisFromDate:from
                                                                                forField:[GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:self.multiFieldConfig.activityType]];

    [self.performanceAnalysis calculate];
    if (![self.performanceAnalysis isEmpty]) {
        GCSimpleGraphCachedDataSource * cache = [GCSimpleGraphCachedDataSource performanceAnalysis:self.performanceAnalysis width:tableView.frame.size.width];
        graphCell.legend = TRUE;
        [graphCell setDataSource:cache andConfig:cache];
    }else{
        GCSimpleGraphCachedDataSource * cache = [GCSimpleGraphCachedDataSource dataSourceWithStandardColors];
        cache.emptyGraphLabel = NSLocalizedString(@"Not enough points", @"Performance Analysis Empty");
        [graphCell setDataSource:cache andConfig:cache];
    }
    return graphCell;
}

-(UITableViewCell*)tableView:(UITableView *)tableView derivedHistCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if( self.derivedHistAnalysis == nil){
        self.derivedHistAnalysis = [GCStatsDerivedHistory analysisWith:self.multiFieldConfig and:self.derivedAnalysisConfig];
    }
    
    GCCellSimpleGraph * graphCell = [self.derivedHistAnalysis tableView:tableView derivedHistCellForRowAtIndexPath:indexPath with:[GCAppGlobal derived]];
    graphCell.cellDelegate = self;
    graphCell.identifier = GC_SUMMARY_DERIVED_HIST;

    return graphCell;

}

-(GCDerivedDataSerie*)currentDerivedDataSerie{
    return [self.derivedAnalysisConfig currentDerivedDataSerie];
}

-(UITableViewCell*)tableView:(UITableView *)tableView derivedCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GCCellSimpleGraph * graphCell = [GCCellSimpleGraph graphCell:tableView];
    graphCell.cellDelegate = self;
    graphCell.identifier = GC_SUMMARY_DERIVED;
    GCDerivedDataSerie * current = [self currentDerivedDataSerie];

    GCSimpleGraphCachedDataSource * cache = nil;
    if (current) {
        cache = [GCSimpleGraphCachedDataSource derivedData:current.field forDate:current.bucketStart width:tableView.frame.size.width];
        cache.emptyGraphLabel = @"";
        graphCell.legend = true;
        [graphCell setDataSource:cache andConfig:cache];
    }else{
        cache = [GCSimpleGraphCachedDataSource dataSourceWithStandardColors];
        cache.emptyGraphLabel = @"";
        [graphCell setDataSource:cache andConfig:cache];
    }

    return graphCell;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cumulativeDistanceCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GCCellSimpleGraph * graphCell = [GCCellSimpleGraph graphCell:tableView];
    graphCell.cellDelegate = self;
    graphCell.legend = TRUE;
    graphCell.identifier = GC_SUMMARY_CUMULATIVE_DISTANCE;
    
    GCHistoryFieldDataSerie * fieldDataSerie = [self fieldDataSerieFor:self.multiFieldConfig.currentCumulativeSummaryField];
    NSCalendarUnit unit = NSCalendarUnitYear;

    if (![fieldDataSerie isEmpty]) {

        if (unit == NSCalendarUnitYear) {
            gcStatsRange range = [fieldDataSerie.history.serie range];
            double span = range.x_max-range.x_min;
            if (span < 3600.*24.*365.) {// less than 1 year of data
                unit = NSCalendarUnitMonth;
            }
        }

        GCSimpleGraphCachedDataSource * cache = [GCSimpleGraphCachedDataSource historyView:fieldDataSerie
                                                                              calendarConfig:[self.multiFieldConfig.calendarConfig equivalentConfigFor:unit]
                                                                               graphChoice:gcGraphChoiceCumulative
                                                                                     after:nil];
        cache.emptyGraphLabel = NSLocalizedString(@"Pending...", @"Summary Graph");
        [graphCell setDataSource:cache andConfig:cache];

    }else{
        GCSimpleGraphCachedDataSource * cache = [GCSimpleGraphCachedDataSource dataSourceWithStandardColors];
        [graphCell setDataSource:cache andConfig:cache];
    }
    return graphCell;
}

-(UITableViewCell*)tableView:(UITableView *)tableView summaryCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * rv = nil;
    if (indexPath.row == GC_SUMMARY_CUMULATIVE_DISTANCE) {
        rv = [self tableView:tableView cumulativeDistanceCellForRowAtIndexPath:indexPath];
    }else if (indexPath.row==GC_SUMMARY_PERFORMANCE){
        rv = [self tableView:tableView performanceCellForRowAtIndexPath:indexPath];

    }else if (indexPath.row == GC_SUMMARY_DERIVED){
        rv = [self tableView:tableView derivedCellForRowAtIndexPath:indexPath];
    }else if(indexPath.row == GC_SUMMARY_DERIVED_HIST){
        rv = [self tableView:tableView derivedHistCellForRowAtIndexPath:indexPath];
    }
    rv.backgroundColor = [GCViewConfig defaultColor:gcSkinDefaultColorBackground];
    return rv;
}




#pragma mark - Events

-(void)notifyCallBack:(NSNotification*)notification{
    [self clearFieldDataSeries];
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self.tableView reloadData];
    });
}

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo*)theInfo{
    if( ! self.started){
        return; // don't bother yet
    }
    // Ignore if organizer notify change to specific activity
    BOOL ignoreNotify = ([theParent isKindOfClass:[GCActivitiesOrganizer class]] && theInfo.stringInfo != nil);
    BOOL skipSetup = [theParent isKindOfClass:[GCHistoryFieldDataSerie class]];

    if (!ignoreNotify) {
        if (!skipSetup) {
            [self setupForCurrentActivityAndViewChoice:self.viewChoice];
        }
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.tableView reloadData];
            if( self.updateCallback ){
                self.updateCallback();
            }
        });
    }
}

-(void)updateDone{
    [self setupBarButtonItem];
    [self.tableView reloadData];
    [self.navigationController.navigationBar setNeedsDisplay];
    if( self.updateCallback ){
        self.updateCallback();
    }
}

-(void)publishEvent{
    NSString * choice = self.multiFieldConfig.viewDescription;
    NSDictionary * params = @{@"ActivityType": self.activityType ?: @"None",
                             @"Choice": choice ?: @"None"};
    [Flurry logEvent:EVENT_REPORT withParameters:params];
}

#pragma mark - Config

-(BOOL)useFilter{
    return self.multiFieldConfig.useFilter;
}
-(gcViewChoice)viewChoice{
    return self.multiFieldConfig.viewChoice;
}

-(GCActivityType*)activityTypeDetail{
    return self.multiFieldConfig.activityTypeDetail;
}

-(NSString*)displayActivityType{
    if (self.multiFieldConfig.useFilter) {
        return [GCAppGlobal organizer].filteredActivityType;
    }
    return self.multiFieldConfig.activityType;
}

-(void)toggleViewChoice{
    GCStatsMultiFieldConfig * nconfig = [GCStatsMultiFieldConfig fieldListConfigFrom:self.multiFieldConfig];
    [nconfig nextView];
    
    [self setupForFieldListConfig:nconfig];
}

-(void)switchCalFilter{
    GCStatsMultiFieldConfig * nconfig = [GCStatsMultiFieldConfig fieldListConfigFrom:self.multiFieldConfig];
    [nconfig nextViewConfig];
    [self setupForFieldListConfig:nconfig];
    [self setupBarButtonItem];
    [self.tableView reloadData];
}

-(void)setupBarButtonItem{
    self.rightMostButtonItem = [self.multiFieldConfig viewChoiceButtonForTarget:self action:@selector(toggleViewChoice) longPress:@selector(configLongPress:)];
    UIBarButtonItem * cal = [self.multiFieldConfig viewConfigButtonForTarget:self action:@selector(switchCalFilter) longPress:@selector(configLongPress:)];
    if( self.rightMostButtonItem ){
        self.navigationItem.rightBarButtonItems = cal ? @[self.rightMostButtonItem,cal] : @[ self.rightMostButtonItem ];
    }

    if (self.useFilter) {
        (self.navigationController.navigationBar.topItem).title = [GCAppGlobal organizer].lastSearchString;
    }else{
        if (self.activityType) {
            (self.navigationController.navigationBar.topItem).title = [GCActivityType activityTypeForKey:self.activityType].displayName;
        }
    }
    [self.activityTypeButton setupBarButtonItem:self];
    self.navigationItem.leftBarButtonItem = self.activityTypeButton.activityTypeButtonItem;
}

-(void)swipeLeft:(GCCellSimpleGraph *)cell{
    if( self.multiFieldConfig.viewChoice == gcViewChoiceSummary){
        if( cell.identifier == GC_SUMMARY_DERIVED){
            [self.derivedAnalysisConfig nextDerivedSerieField];
        }else if( cell.identifier == GC_SUMMARY_CUMULATIVE_DISTANCE ){
            [self.multiFieldConfig nextSummaryCumulativeField];
        }
    }else{
        [self.multiFieldConfig nextSummaryCumulativeField];
    }

    [self.tableView reloadData];
}

-(void)longPress:(GCCellSimpleGraph*)cell{
    if( cell.identifier == GC_SUMMARY_DERIVED){
        RZLog(RZLogInfo,@"Starting Derived Analysis");
        
        self.configViewController = [GCStatsDerivedAnalysisViewController controllerWithDelegate:self];
        
        [self.navigationController pushViewController:self.configViewController animated:YES];
    }else if (cell.identifier == GC_SUMMARY_DERIVED_HIST ){
        RZLog(RZLogInfo,@"Starting Derived Hist Analysis");
        
        self.histAnalysisViewController = [GCStatsDerivedHistoryViewController controllerWithDelegate:self];
        
        [self.navigationController pushViewController:self.histAnalysisViewController animated:YES];
    }
}

-(void)configLongPress:(UIGestureRecognizer*)gesture{
    NSLog(@"Config Long Press");
    
    if( gesture.state == UIGestureRecognizerStateBegan){
        GCStatsMultiFieldConfigViewController * controller=[[[GCStatsMultiFieldConfigViewController alloc] initWithNibName:@"GCStatsMultiFieldConfigViewController" bundle:nil] autorelease];
        controller.multiFieldViewController = self;
        controller.modalPresentationStyle = UIModalPresentationPopover;
        self.popoverViewController = controller;
        RZAutorelease([[UIPopoverPresentationController alloc] initWithPresentedViewController:controller
                                                                      presentingViewController:self.presentingViewController]);
        controller.popoverPresentationController.barButtonItem = self.rightMostButtonItem;
        [self presentViewController:controller animated:YES completion:nil];
    }

}

-(void)configChanged{
    [self.tableView reloadData];
}
-(void)configViewController:(GCStatsDerivedAnalysisViewController*)vc didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if( indexPath.row == 0 && indexPath.section == 0){
        NSArray<GCActivity*>*activities = [[GCAppGlobal organizer] activities];
        GCActivity * current = [[GCAppGlobal organizer] currentActivity];
        if( ![current.activityType isEqualToString:self.multiFieldConfig.activityType] ){
            for (GCActivity * one in activities) {
                if( [one.activityType isEqualToString:self.multiFieldConfig.activityType] ){
                    current = one;
                    break;
                }
            }
        }
        [[GCAppGlobal derived] rebuildDerivedDataSerie:gcDerivedTypeBestRolling forActivity:current inActivities:activities];
    }
}

#pragma mark - Setup data

-(void)setupFieldStats{
    GCActivityMatchBlock filter = nil;
    if (![self.activityType isEqualToString:GC_TYPE_ALL]) {
        filter = ^(GCActivity*act){
            return [act.activityType isEqualToString:self.activityType];
        };
    }
    gcIgnoreMode ignoreMode = [self.activityType isEqualToString:GC_TYPE_DAY] ? gcIgnoreModeDayFocus : gcIgnoreModeActivityFocus;
    NSArray * useActivities = self.useFilter ? [[GCAppGlobal organizer] filteredActivities] : [[GCAppGlobal organizer] activities];
    GCHistoryFieldSummaryStats * vals = [GCHistoryFieldSummaryStats fieldStatsWithActivities:useActivities
                                                                                    matching:filter
                                                                               referenceDate:self.multiFieldConfig.calendarConfig.referenceDate
                                                                                  ignoreMode:ignoreMode
                                         ];
    //RZLog(RZLogInfo, @"Stats found [%@]", [vals.foundActivityTypes componentsJoinedByString:@", "]);
    if ([[GCAppGlobal health] hasHealthData]) {
        [vals addHealthMeasures:[GCAppGlobal health].measures referenceDate:self.multiFieldConfig.calendarConfig.referenceDate];
    }

    self.allFields = vals.fieldData.allKeys;
    NSString * activityType = nil;
    // If one type of activity, limit to those fields
    // Else pick the ALL version
    if (vals.foundActivityTypes.count == 1) {
        activityType = vals.foundActivityTypes[0];
    }else{
        activityType = GC_TYPE_ALL;
    }

    NSMutableArray * limitFields = [NSMutableArray arrayWithCapacity:self.allFields.count];
    for (GCField * field in self.allFields) {
        if ([field.activityType isEqualToString:activityType] || field.isHealthField) {
            [limitFields addObject:field];
        }
    }
    self.allFields = [NSArray arrayWithArray:limitFields];

    self.fieldOrder = [GCFields categorizeAndOrderFields:self.allFields];
    self.fieldStats = vals;

    self.geometry = [RZNumberWithUnitGeometry geometry];
    
    [GCCellGrid adjustFieldStatisticsWithSummaryStats:self.fieldStats histStats:gcHistoryStatsAll geometry:self.geometry];
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self updateDone];
    });
}

-(void)setupTestModeFieldDataSeries{
    NSMutableDictionary * newSeries = [NSMutableDictionary dictionary];

    for (GCField * field in self.allFields) {
        GCHistoryFieldDataSerieConfig * config = [GCHistoryFieldDataSerieConfig configWithFilter:self.useFilter field:field];
        GCHistoryFieldDataSerie * stats = [[GCHistoryFieldDataSerie alloc] initFromConfig:config];
        [stats loadFromOrganizer];
        newSeries[field] = stats;
        [stats release];
    }

    self.fieldDataSeries = newSeries;
}

-(GCHistoryFieldDataSerie*)fieldDataSerieFor:(GCField*)field{
    GCHistoryFieldDataSerie * stats = self.fieldDataSeries[field];
    if (!stats) {
        if (field) {
            NSMutableDictionary * newSeries = self.fieldDataSeries?[NSMutableDictionary dictionaryWithDictionary:self.fieldDataSeries]:[NSMutableDictionary dictionary];

            GCHistoryFieldDataSerieConfig * config = [GCHistoryFieldDataSerieConfig configWithFilter:self.useFilter field:field];
            stats = [[[GCHistoryFieldDataSerie alloc] initAndLoadFromConfig:config withThread:[GCAppGlobal worker]] autorelease];
            [stats attach:self];
            newSeries[field] = stats;
            self.fieldDataSeries = [NSDictionary dictionaryWithDictionary:newSeries];
        }
    }

    return stats;
}

-(void)clearFieldDataSeries{
    for (GCField * field in self.fieldDataSeries) {
        GCHistoryFieldDataSerie * one = self.fieldDataSeries[field];
        [one detach:self];
    }
    self.fieldDataSeries = nil;
}

-(void)setupAggregatedStats{

    [self fieldDataSerieFor:[GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:self.activityType]];

    GCHistoryAggregatedActivityStats * vals = [GCHistoryAggregatedActivityStats aggregatedActivityStatsForActivityTypeDetail:self.activityTypeDetail];
    vals.useFilter = self.useFilter;
    [vals setActivitiesFromOrganizer:[GCAppGlobal organizer]];
    //vals.activityType = self.activityType;
    gcIgnoreMode ignoreMode = [self.activityType isEqualToString:GC_TYPE_DAY] ? gcIgnoreModeDayFocus : gcIgnoreModeActivityFocus;
    [vals aggregate:self.multiFieldConfig.calendarConfig.calendarUnit
      referenceDate:self.multiFieldConfig.calendarConfig.referenceDate
             cutOff:self.multiFieldConfig.calendarConfig.cutOff
         ignoreMode:ignoreMode];
    self.aggregatedStats = vals;
    
    self.geometry = [RZNumberWithUnitGeometry geometry];
    GCActivityType * type = self.activityTypeDetail;
    for (GCHistoryAggregatedDataHolder * holder in vals) {
        [GCCellGrid adjustAggregatedWithDataHolder:holder activityType:type geometry:self.geometry];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self updateDone];
    });
}

-(void)setupForCurrentActivityAndViewChoice:(gcViewChoice)choice{
    GCStatsMultiFieldConfig * nconfig = [GCStatsMultiFieldConfig fieldListConfigFrom:self.multiFieldConfig];
    nconfig.activityType = [[GCAppGlobal organizer] currentActivity].activityType;
    nconfig.viewChoice = choice;
    [self setupForFieldListConfig:nconfig];
}
-(void)setupForCurrentActivityType:(NSString*)aType andViewChoice:(gcViewChoice)choice{
    GCStatsMultiFieldConfig * nconfig = [GCStatsMultiFieldConfig fieldListConfigFrom:self.multiFieldConfig];
    nconfig.activityType = aType;
    nconfig.viewChoice = choice;
    [self setupForFieldListConfig:nconfig];
}

-(void)setupForCurrentActivityTypeDetail:(GCActivityType*)aType andFilter:(BOOL)aFilter{
    GCStatsMultiFieldConfig * nconfig = [GCStatsMultiFieldConfig fieldListConfigFrom:self.multiFieldConfig];
    nconfig.activityTypeDetail = aType;
    nconfig.useFilter = aFilter;
    [self setupForFieldListConfig:nconfig];
}

-(void)setupForCurrentActivityType:(NSString*)aType filter:(BOOL)aFilter andViewChoice:(gcViewChoice)choice{
    GCStatsMultiFieldConfig * nconfig = [GCStatsMultiFieldConfig fieldListConfigFrom:self.multiFieldConfig];
    nconfig.activityType = aType;
    nconfig.useFilter = aFilter;
    nconfig.viewChoice = choice;
    [self setupForFieldListConfig:nconfig];

}

-(void)setupTestModeWithFieldListConfig:(GCStatsMultiFieldConfig*)nConfig{
    self.multiFieldConfig = nConfig;
    [self clearFieldDataSeries];
    if (self.viewChoice == gcViewChoiceFields || self.viewChoice == gcViewChoiceSummary) {
        [self setFieldStats:nil];
        [self setFieldOrder:nil];
        [self setupFieldStats];
        [self setupTestModeFieldDataSeries];
    }else{
        [self setAggregatedStats:nil];
        [self setFieldOrder:nil];
        [self setupAggregatedStats];
    }

}

-(void)setupForFieldListConfig:(GCStatsMultiFieldConfig*)nConfig{
    if (self.multiFieldConfig == nil || [self.multiFieldConfig requiresAggregateRebuild:nConfig]) {
        if( self.multiFieldConfig != nil && nConfig != nil){
            RZLog(RZLogInfo, @"change %@", [self.multiFieldConfig diffDescription:nConfig]);
        }
        self.multiFieldConfig = nConfig;
        [self clearFieldDataSeries];
        if( self.derivedAnalysisConfig== nil){
            self.derivedAnalysisConfig = [GCStatsDerivedAnalysisConfig configForActivityType:self.multiFieldConfig.activityType];
        }else{
            self.derivedAnalysisConfig.activityType = self.multiFieldConfig.activityType;
        }

        if (self.viewChoice == gcViewChoiceFields || self.viewChoice == gcViewChoiceSummary) {
            [self setFieldStats:nil];
            [self setFieldOrder:nil];
            dispatch_async([GCAppGlobal worker],^(){
                [self setupFieldStats];
            });
        }else{
            [self setAggregatedStats:nil];
            [self setFieldOrder:nil];
            dispatch_async([GCAppGlobal worker],^(){
                [self setupAggregatedStats];
            });
        }
        RZLog(RZLogInfo, @"config %@", self.multiFieldConfig)
#ifdef GC_USE_FLURRY
        [self publishEvent];
#endif
    }else if( ! [self.multiFieldConfig isEqualToConfig:nConfig] ){
        self.multiFieldConfig = nConfig;
        [self.tableView reloadData];
        
    }
}



-(NSArray<GCField*>*)fieldsForSection:(NSInteger)section{
    if (section-GC_SECTION_DATA<_fieldOrder.count && section-GC_SECTION_DATA>=0) {
        GCFieldsForCategory * sub = _fieldOrder[section-GC_SECTION_DATA];
        return sub.fields;
    }
    return nil;
}
-(NSString*)categoryNameForSection:(NSInteger)section{
    if (section-GC_SECTION_DATA<_fieldOrder.count && section-GC_SECTION_DATA>=0) {
        GCFieldsForCategory * sub = _fieldOrder[section-GC_SECTION_DATA];
        return sub.category;
    }
    return nil;
}
@end
