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
#import "GCStatsHistGraphViewController.h"
#import "GCDerivedGroupedSeries.h"
#import "GCDerivedOrganizer.h"
#import "GCHealthOrganizer.h"
#import "GCStatsDerivedAnalysisViewController.h"

@interface GCStatsMultiFieldViewController ()
@property (nonatomic,retain) GCHistoryPerformanceAnalysis * performanceAnalysis;
@property (nonatomic,assign) BOOL started;
@property (nonatomic,retain) GCStatsDerivedAnalysisViewController * configViewController;

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
    [_activityTypeButton release];
    [self clearFieldDataSeries];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[GCAppGlobal organizer] detach:self];
    [_performanceAnalysis release];
    [_aggregatedStats release];
    [_fieldOrder release];
    [_fieldStats release];
    [_fieldDataSeries release];
    [_allFields release];
    [_config release];
    [_configViewController release];
    [super dealloc];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    RZLogTrace(@"");
    [super viewDidLoad];

    self.navigationItem.hidesBackButton = YES;
    self.activityTypeButton = [GCViewActivityTypeButton activityTypeButtonForDelegate:self];
    
    [self setupBarButtonItem];

}

// If summary stat is the first view to appear
-(void)viewDidAppear:(BOOL)animated{
    RZLogTrace(@"");

    [super viewDidAppear:animated];

    [GCAppGlobal startupRefreshIfNeeded];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if( ! self.started){
        [self setupForCurrentActivityAndViewChoice:self.viewChoice];
        self.config.viewChoice = (gcViewChoice)[GCAppGlobal configGetInt:CONFIG_STATS_START_PAGE defaultValue:gcViewChoiceSummary];
        RZLog(RZLogInfo, @"Initial start page %@", [GCViewConfig viewChoiceDesc:self.config.viewChoice]);
        [GCViewConfig setupViewController:self];
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
    if (self.viewChoice==gcViewChoiceAll) {
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
    if (self.viewChoice == gcViewChoiceAll) {
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
    if (self.viewChoice == gcViewChoiceAll) {
        rv = [self tableView:tableView fieldSummaryCell:indexPath];
    }else if (self.viewChoice == gcViewChoiceSummary){
        rv = [self tableView:tableView summaryCellForRowAtIndexPath:indexPath];
    }else{
        if (indexPath.section == 0) {
            rv = [self tableView:tableView graphCell:indexPath];
        }else{
            rv = [self tableView:tableView aggregatedCell:indexPath];
        }
    }

    return rv;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(self.viewChoice == gcViewChoiceAll ){
        NSString * category = [self categoryNameForSection:section];
        return [GCTableHeaderFieldsCategory tableView:tableView viewForHeaderCategory:category];
    }else{
        return RZReturnAutorelease([[UIView alloc] initWithFrame:CGRectZero]);
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(self.viewChoice == gcViewChoiceAll ){
        NSString * category = [self categoryNameForSection:section];
        return [GCTableHeaderFieldsCategory tableView:tableView heightForHeaderCategory:category];
    }else{
        return 0.;
    }
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(self.viewChoice == gcViewChoiceAll ){
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
            [self.config nextDerivedSerie];            
            [tableView reloadData];
        }else if (indexPath.row == GC_SUMMARY_CUMULATIVE_DISTANCE){
            [self.config nextSummaryCumulativeField];
            [tableView reloadData];
        }
    }else if (self.viewChoice == gcViewChoiceAll) {
        GCField * field = [self fieldsForSection:indexPath.section][indexPath.row];
        //[[self fieldOrder] objectAtIndex:[indexPath row]];
        GCStatsOneFieldViewController *statsViewController = [[GCStatsOneFieldViewController alloc] initWithStyle:UITableViewStylePlain];
        (statsViewController.config).useFilter = self.useFilter;
        (statsViewController.config).fieldOrder = self.fieldOrder;
        
        GCField * xfield = [GCViewConfig nextFieldForGraph:nil fieldOrder:[GCViewConfig validChoicesForGraphIn:self.allFields] differentFrom:field];
        
        [statsViewController setupForType:self.activityType field:field
                                   xField:xfield
                               viewChoice:gcViewChoiceAll];
        
        [UIViewController setupEdgeExtendedLayout:statsViewController];
        
        [self.navigationController pushViewController:statsViewController animated:YES];
        [statsViewController release];
    }else{
        if (indexPath.section >= GC_SECTION_DATA) {
            GCHistoryAggregatedDataHolder * data = [self.aggregatedStats dataForIndex:indexPath.row];
            NSString * filter = [GCViewConfig filterFor:self.viewChoice date:data.date andActivityType:self.activityType];
            [GCAppGlobal debugStateRecord:@{
                DEBUGSTATE_LAST_CNT : @([data valFor:gcAggregatedSumDistance and:gcAggregatedCnt]),
                DEBUGSTATE_LAST_SUM : @([data valFor:gcAggregatedSumDistance and:gcAggregatedSum])
                
            }];
            [GCAppGlobal focusOnListWithFilter:filter];
            self.config.historyStats =gcHistoryStatsAll;
            [self setupForCurrentActivityType:GC_TYPE_ALL filter:true andViewChoice:gcViewChoiceAll];
        }else if (indexPath.section == GC_SECTION_GRAPH){
                GCStatsOneFieldGraphViewController * graph = [[GCStatsOneFieldGraphViewController alloc] initWithNibName:nil bundle:nil];
                gcGraphChoice choice = self.viewChoice == gcViewChoiceYearly ? gcGraphChoiceCumulative : gcGraphChoiceBarGraph;
                
                GCHistoryFieldDataSerie * fieldDataSerie = [self fieldDataSerieFor:[GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:self.activityType]];
                
                [graph setupForHistoryField:fieldDataSerie graphChoice:choice andViewChoice:self.viewChoice];
                [graph setCanSum:true];
                if ([UIViewController useIOS7Layout]) {
                    [UIViewController setupEdgeExtendedLayout:graph];
                }
                
                [self.navigationController pushViewController:graph animated:YES];
                [graph release];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.viewChoice == gcViewChoiceSummary) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            return 230.;
        }else{
            return 200.;
        }
    }else if( self.viewChoice == gcViewChoiceAll){
        return 58.;
    }else{
        if (indexPath.section == GC_SECTION_GRAPH ) {
            return 200.;
        }else{
            return 58.;
        }
    }
}

#pragma mark - Historical Statistics Cells

-(GCSimpleGraphCachedDataSource*)dataSourceForField:(GCField*)field{
    GCHistoryFieldDataSerie * fieldDataSerie = [self fieldDataSerieFor:field];
    return [self.config dataSourceForFieldDataSerie:fieldDataSerie];
}

- (UITableViewCell *)tableView:(UITableView *)tableView graphCell:(NSIndexPath*)indexPath{

    GCCellSimpleGraph * cell = [GCCellSimpleGraph graphCell:tableView];
    cell.cellDelegate = self;
    GCSimpleGraphCachedDataSource * cache = [self dataSourceForField:self.config.currentCumulativeSummaryField];
    [cell setDataSource:cache andConfig:cache];
    if (self.config.viewChoice == gcViewChoiceYearly) {// This is Cumulative graph, needs legend
        cell.legend = true;
    }else{
        cell.legend = false;
    }
    return cell;

}

-(UITableViewCell*)tableView:(UITableView *)tableView aggregatedCell:(NSIndexPath *)indexPath{
    GCCellGrid *cell = [GCCellGrid gridCell:tableView];

    GCHistoryAggregatedDataHolder * data = [self.aggregatedStats dataForIndex:indexPath.row];
    if( data ){
        [cell setupFromHistoryAggregatedData:data index:indexPath.row viewChoice:self.viewChoice andActivityType:self.displayActivityType width:tableView.frame.size.width];
    }
    return cell;
}


#pragma mark - Field Summary Cells

-(UITableViewCell*)tableView:(UITableView *)tableView fieldSummaryCell:(NSIndexPath *)indexPath{
    GCCellGrid * cell = [GCCellGrid gridCell:tableView];
    GCField * field =[self fieldsForSection:indexPath.section][indexPath.row];

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

    GCFieldDataHolder * data = [self.fieldStats dataForField:field];
    [cell setupForFieldDataHolder:data histStats:self.config.historyStats andActivityType:self.activityType];
    if ([GCAppGlobal configGetBool:CONFIG_STATS_INLINE_GRAPHS defaultValue:true] && doGraph[field.key]) {
        GCSimpleGraphCachedDataSource * cache = [self dataSourceForField:field];
        cache.maximizeGraph = true;

        GCSimpleGraphView * view = [[GCSimpleGraphView alloc] initWithFrame:CGRectZero];
        view.displayConfig = cache;
        view.dataSource = cache;
        [cell setIconView:view withSize:CGSizeMake( tableView.frame.size.width > 400. ? 128. : 64., 60.)];
        [view release];
    }else{
        cell.iconView = nil;
        cell.iconSize = CGSizeZero;
    }

    return cell;
}


#pragma mark - Analysis Summary Cells

-(UITableViewCell*)tableView:(UITableView *)tableView performanceCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GCCellSimpleGraph * graphCell = [GCCellSimpleGraph graphCell:tableView];

    NSDate *from=[[[GCAppGlobal organizer] lastActivity].date dateByAddingGregorianComponents:[NSDateComponents dateComponentsFromString:@"-6m"]];
    self.performanceAnalysis = [GCHistoryPerformanceAnalysis performanceAnalysisFromDate:from
                                                                                forField:[GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:self.config.activityType]];

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
    GCCellSimpleGraph * graphCell = [GCCellSimpleGraph graphCell:tableView];
    graphCell.cellDelegate = self;

    GCDerivedDataSerie * current = [self currentDerivedDataSerie];
    GCStatsSerieOfSerieWithUnits * serieOfSerie = nil;
    GCField * field = nil;
    
    if( current ){
        field = [GCField fieldForFlag:current.fieldFlag andActivityType:self.activityType];
        serieOfSerie = [[GCAppGlobal derived] timeserieOfSeriesFor:field inActivities:[[GCAppGlobal organizer] activitiesMatching:^(GCActivity * act){
            return [act.activityType isEqualToString:self.activityType];
        } withLimit:90]];
    }
    //GCStatsSerieOfSerieWithUnits * historical = [[GCAppGlobal derived] timeSeriesOfSeriesFor:field];
    //[serieOfSerie addSerieOfSerie:historical];
    GCSimpleGraphCachedDataSource * cache = nil;
    if (serieOfSerie) {
        cache = [GCSimpleGraphCachedDataSource derivedHist:false field:field series:serieOfSerie width:tableView.frame.size.width];
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

-(GCDerivedDataSerie*)currentDerivedDataSerie{
    return [self.config currentDerivedDataSerie];
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
    
    GCHistoryFieldDataSerie * fieldDataSerie = [self fieldDataSerieFor:self.config.currentCumulativeSummaryField];
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
                                                                              calendarUnit:unit
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

-(UITableViewCell*)tableView:(UITableView *)tableView weeklyBarsCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GCCellSimpleGraph * graphCell = [GCCellSimpleGraph graphCell:tableView];

    GCHistoryFieldDataSerie * fieldDataSerie = [self fieldDataSerieFor:[GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:self.activityType]];
    if (![fieldDataSerie isEmpty]) {
        NSDate * afterdate = [[fieldDataSerie lastDate] dateByAddingGregorianComponents:[NSDateComponents dateComponentsFromString:@"-1Y"]];
        GCSimpleGraphCachedDataSource * cache = [GCSimpleGraphCachedDataSource historyView:fieldDataSerie
                                                                              calendarUnit:NSCalendarUnitWeekOfYear
                                                                               graphChoice:gcGraphChoiceBarGraph
                                                                                     after:afterdate];
        graphCell.legend = TRUE;
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
    RZLogTrace(@"");
    if( [notification.name isEqualToString:kNotifyOrganizerLoadComplete]){
        [self clearFieldDataSeries];
    }
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
        RZLogTrace(@"");

        if (!skipSetup) {
            [self setupForCurrentActivityAndViewChoice:self.viewChoice];
        }
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
}

-(void)updateDone{
    [self setupBarButtonItem];
    [self.tableView reloadData];
    [self.navigationController.navigationBar setNeedsDisplay];

}

-(void)publishEvent{
    NSString * choice = [GCViewConfig viewChoiceDesc:self.viewChoice];
    NSDictionary * params = @{@"ActivityType": self.activityType ?: @"None",
                             @"Choice": choice ?: @"None"};
    [Flurry logEvent:EVENT_REPORT withParameters:params];
}


#pragma mark - Config

-(BOOL)useFilter{
    return self.config.useFilter;
}
-(gcViewChoice)viewChoice{
    return self.config.viewChoice;
}

-(NSString*)activityType{
    return self.config.activityType;
}

-(NSString*)displayActivityType{
    if (self.config.useFilter) {
        return [GCAppGlobal organizer].filteredActivityType;
    }
    return self.config.activityType;
}

-(void)toggleViewChoice{
    [self setupForCurrentActivityType:self.activityType andViewChoice:[GCViewConfig nextViewChoiceWithSummary:self.viewChoice]];
}

-(void)switchCalFilter{
    [self setupForFieldListConfig:[self.config configForNextFilter]];
    [self setupBarButtonItem];
    [self.tableView reloadData];
}

-(void)setupBarButtonItem{
    UIBarButtonItem * rightMost =[[[UIBarButtonItem alloc] initWithTitle:[GCViewConfig viewChoiceDesc:self.viewChoice]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self action:@selector(toggleViewChoice)] autorelease];

    UIBarButtonItem * cal = [self.config buttonForTarget:self action:@selector(switchCalFilter)];

    self.navigationItem.rightBarButtonItems = cal ? @[rightMost,cal] : @[ rightMost];

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
    if( self.config.viewChoice == gcViewChoiceSummary){
        if( cell.identifier == GC_SUMMARY_DERIVED){
            [self.config nextDerivedSerieField];
        }else if( cell.identifier == GC_SUMMARY_CUMULATIVE_DISTANCE ){
            [self.config nextSummaryCumulativeField];
        }
    }else{
        [self.config nextSummaryCumulativeField];
    }

    [self.tableView reloadData];
}

-(void)longPress:(GCCellSimpleGraph*)cell{
    RZLog(RZLogInfo,@"Starting Derived Analysis");
    
    self.configViewController = [GCStatsDerivedAnalysisViewController controllerWithDelegate:self];
    
    [self.navigationController pushViewController:self.configViewController animated:YES];
}

-(void)configChanged{
    [self.tableView reloadData];
}
-(void)configViewController:(GCStatsDerivedAnalysisViewController*)vc didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if( indexPath.row == 0 && indexPath.section == 0){
        NSArray<GCActivity*>*activities = [[GCAppGlobal organizer] activities];
        GCActivity * current = [[GCAppGlobal organizer] currentActivity];
        if( ![current.activityType isEqualToString:self.config.activityType] ){
            for (GCActivity * one in activities) {
                if( [one.activityType isEqualToString:self.config.activityType] ){
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
                                                                               referenceDate:[GCAppGlobal referenceDate]
                                                                                  ignoreMode:ignoreMode
                                         ];
    //RZLog(RZLogInfo, @"Stats found [%@]", [vals.foundActivityTypes componentsJoinedByString:@", "]);
    if ([[GCAppGlobal health] hasHealthData]) {
        [vals addHealthMeasures:[GCAppGlobal health].measures referenceDate:[GCAppGlobal referenceDate]];
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

    [self performSelectorOnMainThread:@selector(updateDone) withObject:nil waitUntilDone:NO];
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

    GCHistoryAggregatedActivityStats * vals = [[[GCHistoryAggregatedActivityStats alloc] init] autorelease];
    vals.useFilter = self.useFilter;
    [vals setActivitiesFromOrganizer:[GCAppGlobal organizer]];
    vals.activityType = self.activityType;
    gcIgnoreMode ignoreMode = [self.activityType isEqualToString:GC_TYPE_DAY] ? gcIgnoreModeDayFocus : gcIgnoreModeActivityFocus;
    NSDate * cutOff = nil;
    if (self.config.calChoice == gcStatsCalToDate) {
        cutOff = [[GCAppGlobal organizer] lastActivity].date;
    }
    [vals aggregate:[GCViewConfig calendarUnitForViewChoice:self.viewChoice]
      referenceDate:[GCAppGlobal referenceDate]
             cutOff:cutOff
         ignoreMode:ignoreMode];
    self.aggregatedStats = vals;
    [self performSelectorOnMainThread:@selector(updateDone) withObject:nil waitUntilDone:NO];
}

-(void)setupForCurrentActivityAndViewChoice:(gcViewChoice)choice{
    GCStatsMultiFieldConfig * nconfig = [GCStatsMultiFieldConfig fieldListConfigFrom:self.config];
    nconfig.activityType = [[GCAppGlobal organizer] currentActivity].activityType;
    nconfig.viewChoice = choice;
    [self setupForFieldListConfig:nconfig];
}
-(void)setupForCurrentActivityType:(NSString*)aType andViewChoice:(gcViewChoice)choice{
    GCStatsMultiFieldConfig * nconfig = [GCStatsMultiFieldConfig fieldListConfigFrom:self.config];
    nconfig.activityType = aType;
    nconfig.viewChoice = choice;
    [self setupForFieldListConfig:nconfig];
}

-(void)setupForCurrentActivityType:(NSString*)aType andFilter:(BOOL)aFilter{
    GCStatsMultiFieldConfig * nconfig = [GCStatsMultiFieldConfig fieldListConfigFrom:self.config];
    nconfig.activityType = aType;
    nconfig.useFilter = aFilter;
    [self setupForFieldListConfig:nconfig];
}

-(void)setupForCurrentActivityType:(NSString*)aType filter:(BOOL)aFilter andViewChoice:(gcViewChoice)choice{
    GCStatsMultiFieldConfig * nconfig = [GCStatsMultiFieldConfig fieldListConfigFrom:self.config];
    nconfig.activityType = aType;
    nconfig.useFilter = aFilter;
    nconfig.viewChoice = choice;
    [self setupForFieldListConfig:nconfig];

}

-(void)setupTestModeWithFieldListConfig:(GCStatsMultiFieldConfig*)nConfig{
    self.config = nConfig;
    [self clearFieldDataSeries];
    if (self.viewChoice == gcViewChoiceAll || self.viewChoice == gcViewChoiceSummary) {
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
    //FIXME: check if does not require full setup
    if (![self.config isEqualToConfig:nConfig]) {
        self.config = nConfig;
        [self clearFieldDataSeries];
        if (self.viewChoice == gcViewChoiceAll || self.viewChoice == gcViewChoiceSummary) {
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
#ifdef GC_USE_FLURRY
        [self publishEvent];
#endif
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
