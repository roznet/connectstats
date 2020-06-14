    //  MIT License
//
//  Created on 19/04/2020 for ConnectStats
//
//  Copyright (c) 2020 Brice Rosenzweig
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



#import "GCStatsDerivedAnalysisViewController.h"
#import "GCStatsMultiFieldConfig.h"
#import "GCDerivedGroupedSeries.h"
#import "GCDerivedOrganizer.h"
#import "GCSimpleGraphCachedDataSource+Templates.h"
#import "GCStatsDerivedAnalysisViewControllerConsts.h"
#import "GCAppGlobal.h"
#import "GCStatsDerivedAnalysisConfig.h"

typedef NS_ENUM(NSUInteger) {
    gcRebuildFree,
    gcRebuildDownload,
    gcRebuildCalculate
} gcRebuildStatus;

@interface GCStatsDerivedAnalysisViewController ()
@property (nonatomic,retain) NSObject<GCStatsMultiFieldConfigViewDelegate> * delegate;
@property (nonatomic,retain) NSArray<GCField*>*fields;
@property (nonatomic,retain) NSArray<GCDerivedDataSerie*>*choices;
@property (nonatomic,readonly) GCStatsMultiFieldConfig * config;
@property (nonatomic,readonly) GCStatsDerivedAnalysisConfig * derivedAnalysisConfig;
@property (nonatomic,assign) gcRebuildStatus rebuildStatus;
@end

@implementation GCStatsDerivedAnalysisViewController

-(void)dealloc{
    [[GCAppGlobal derived] detach:self];
    
    [_choices release];
    [_delegate release];
    [super dealloc];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[GCAppGlobal derived] attach:self];
    [[GCAppGlobal web] attach:self];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[GCAppGlobal derived] detach:self];
    [[GCAppGlobal web] detach:self];
}

+(GCStatsDerivedAnalysisViewController*)controllerWithDelegate:(NSObject<GCStatsMultiFieldConfigViewDelegate>*)delegate{
    GCStatsDerivedAnalysisViewController * rv = RZReturnAutorelease([[GCStatsDerivedAnalysisViewController alloc] initWithStyle:UITableViewStyleGrouped]);
    rv.delegate = delegate;
    rv.modalPresentationStyle = UIModalPresentationPopover;

    return rv;
}

#pragma mark - TableView Delegate and DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return GC_SECTION_END;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if( section == GC_SECTION_GRAPHS){
        return GC_GRAPH_END;
    }else if (section == GC_SECTION_STATUS){
        return GC_STATUS_END;
    }else if (section == GC_SECTION_ACTIONS){
        return GC_ACTION_END;
    }
    return 0;
}

-(nonnull UITableViewCell *)tableView:(UITableView *)tableView derivedCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GCCellSimpleGraph * graphCell = [GCCellSimpleGraph graphCell:tableView];
    GCDerivedDataSerie * current = [self currentDerivedDataSerie];

    if (current) {
        CGFloat width = tableView.frame.size.width;
        // Do calculation on worker spread
        dispatch_async([GCAppGlobal worker], ^(){
            gcDerivedPeriod period = indexPath.row == 0 ? gcDerivedPeriodYear : gcDerivedPeriodMonth;
            NSMutableArray<GCSimpleGraphLegendInfo*>*legends = [NSMutableArray array];
            GCSimpleGraphCachedDataSource * cache = [GCSimpleGraphCachedDataSource derivedDataSingleHighlighted:current.field period:period forDate:current.bucketStart addLegendTo:legends width:width];
            
            dispatch_async(dispatch_get_main_queue(), ^(){
                [graphCell setDataSource:cache andConfig:cache];
                // Setup legengview AFter otherwise setDataSource override the legend data source
                graphCell.legendView.displayConfig = cache;
                [graphCell.legendView setupWithLegends:legends];
                [graphCell setNeedsLayout];
                [graphCell setNeedsDisplay];
            });
        });
    }
    GCSimpleGraphCachedDataSource * cache = [GCSimpleGraphCachedDataSource dataSourceWithStandardColors];
    cache.emptyGraphLabel = NSLocalizedString(@"Calculating...", @"Derived Calculate");
    graphCell.legendView = [[[GCSimpleGraphLegendView alloc] initWithFrame:CGRectZero] autorelease];
    [graphCell setDataSource:cache andConfig:cache];

    return graphCell;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell * cell = nil;
    
    if( indexPath.section == GC_SECTION_STATUS){
        GCCellGrid * grcell = [GCCellGrid gridCell:tableView];
        [grcell setupForRows:1 andCols:1];
        
        if( indexPath.row == GC_STATUS_FIELD){
            [grcell labelForRow:0 andCol:0].text = self.derivedAnalysisConfig.currentDerivedDataSerie.field.displayName;
        }else if( indexPath.row == GC_STATUS_PERIOD){
            [grcell labelForRow:0 andCol:0].text = [self.derivedAnalysisConfig.currentDerivedDataSerie.bucketStart calendarUnitFormat:NSCalendarUnitMonth];
        }
        cell = grcell;
    }else if( indexPath.section == GC_SECTION_GRAPHS){
        cell = [self tableView:tableView derivedCellForRowAtIndexPath:indexPath];
    }else if( indexPath.section == GC_SECTION_ACTIONS){
        GCCellGrid * grcell = [GCCellGrid gridCell:tableView];
        [grcell setupForRows:2 andCols:1];
        
        if( indexPath.row == GC_ACTION_REBUILD){
            NSString * message = [NSString stringWithFormat:NSLocalizedString(@"Rebuild Analysis for %@", "Derived Analysis"),
                                  [self.derivedAnalysisConfig.currentDerivedDataSerie.bucketStart calendarUnitFormat:NSCalendarUnitMonth]];
            [grcell labelForRow:0 andCol:0].text = message;
            [grcell labelForRow:1 andCol:0].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute14Gray]
                                                                                       withString:NSLocalizedString(@"This action may take some time", "Derived Analysis")];
        }
        cell = grcell;
    }else{
        cell = [GCCellGrid gridCell:tableView];
        //don't crash return empty cell
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if( indexPath.section == GC_SECTION_ACTIONS && indexPath.row == GC_ACTION_REBUILD){
        if( self.rebuildStatus == gcRebuildFree){
            [self rebuildProcessStart];
        }
    }else if( indexPath.section == GC_SECTION_STATUS){
        NSArray<GCDerivedGroupedSeries*>*series = self.derivedAnalysisConfig.availableDataSeries;
        NSMutableArray<GCDerivedDataSerie*> * choices = [NSMutableArray array];
        NSMutableArray<NSString*>* labels = [NSMutableArray array];
        NSUInteger selected = 0;

        GCDerivedDataSerie * current = self.derivedAnalysisConfig.currentDerivedDataSerie;
        NSDate * date = current.bucketStart;
        GCField * field = current.field;
        
        if( indexPath.row == GC_STATUS_FIELD){
            NSUInteger idx = 0;
            for (GCDerivedGroupedSeries * group in series) {
                [labels addObject:group.field.displayName];
                if( [group.field isEqualToField:field]){
                    selected = idx;
                }
                idx++;
                GCDerivedDataSerie * found = nil;
                for (GCDerivedDataSerie * one in group.series) {
                    if( [one.bucketStart compare:date] != NSOrderedDescending){
                        found = one;
                        break;
                    }
                }
                
                [choices addObject:found ?: group.series.firstObject];
            }
        }else if( indexPath.row == GC_STATUS_PERIOD){
            GCField * field = self.derivedAnalysisConfig.currentDerivedDataSerie.field;
            for (GCDerivedGroupedSeries * group in series) {
                if( [group.field isEqualToField:field] ){
                    NSUInteger idx = 0;
                    for (GCDerivedDataSerie * one in group.series) {
                        if( [one.bucketStart isEqualToDate:date] ){
                            selected = idx;
                        }
                        idx ++;
                        [labels addObject:[one.bucketStart calendarUnitFormat:NSCalendarUnitMonth]];
                        [choices addObject:one];
                    }
                    break;
                }
            }
        }
        self.choices = choices;
        GCCellEntryListViewController * list = [GCViewConfig standardEntryListViewController:labels
                                                                                    selected:selected];
        list.entryFieldDelegate = self;
        list.identifierInt = GC_IDENTIFIER(GC_SECTION_STATUS, indexPath.row);
        [self.navigationController pushViewController:list animated:YES];

    }
    
}


#pragma mark - access

-(GCDerivedDataSerie*)currentDerivedDataSerie{
    return [self.derivedAnalysisConfig currentDerivedDataSerie];
}
-(GCStatsMultiFieldConfig*)multiFieldConfig{
    return self.delegate.multiFieldConfig;
}
-(GCStatsDerivedAnalysisConfig*)derivedAnalysisConfig{
    return self.delegate.derivedAnalysisConfig;
}
#pragma mark - Rebuild process

-(void)rebuildProcessNextStage{
    switch( self.rebuildStatus)
        case gcRebuildFree:{
            self.rebuildStatus = gcRebuildDownload;
            break;
        case gcRebuildDownload:
            self.rebuildStatus = gcRebuildCalculate;
            break;
        case gcRebuildCalculate:
            self.rebuildStatus = gcRebuildFree;
            break;
    }
    [self rebuildProcess];
}

-(void)rebuildProcessStart{
    if( self.rebuildStatus == gcRebuildFree ){
        [self rebuildProcessNextStage];
    }
}

-(void)rebuildUpdateStatusMessage{
    static NSUInteger counter = 0;
    NSMutableString * dots = [NSMutableString stringWithString:@"."];
    
    counter += 1;
    
    for(NSUInteger i=0;i<counter%6;i++){
        [dots appendString:@"."];
    }
    
    NSString * message = [NSString stringWithFormat:NSLocalizedString(@"Rebuilding %@%@", "Derived Analysis"),
                          [self.derivedAnalysisConfig.currentDerivedDataSerie.bucketStart calendarUnitFormat:NSCalendarUnitMonth],
                          dots];
    
    NSString * subtext = nil;
    
    switch( self.rebuildStatus) {
        case gcRebuildDownload:
        {
            subtext = NSLocalizedString(@"Downloading Missing Activities", "Derived Analysis");
            break;
        }
        case gcRebuildCalculate:
        {
            subtext = NSLocalizedString(@"Recalculating Best Rolling", "Derived Analysis");
            break;
        }
        case gcRebuildFree:
        {
            subtext = NSLocalizedString(@"Done", "Derived Analysis");
            break;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        GCCellGrid * grcell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:GC_ACTION_REBUILD inSection:GC_SECTION_ACTIONS]];
        [grcell labelForRow:0 andCol:0].text = message;
        [grcell labelForRow:1 andCol:0].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute14Gray] withString:subtext];
    });

}

-(void)rebuildProcess{
    switch( self.rebuildStatus) {
        case gcRebuildFree:
            // do nothing
            break;
        case gcRebuildDownload:
        {
            [self rebuildUpdateStatusMessage];
            [GCAppGlobal derived].pauseCalculation = true;
            RZLog(RZLogInfo, @"Starting rebuild download stage");
            NSArray<GCActivity*>*activities = [[GCAppGlobal organizer] activities];
            GCDerivedDataSerie * current = self.derivedAnalysisConfig.currentDerivedDataSerie;
            NSArray<GCActivity*>*contained = [current containedActivitiesIn:activities];
            BOOL some = false;
            for (GCActivity * act in contained) {
                if( [act trackPointsRequireDownload] ){
                    // force download
                    [act trackpoints];
                    some = true;
                }
            }
            if( ! some ){
                [self rebuildProcessNextStage];
            }
            break;
        }
        case gcRebuildCalculate:
        {
            [self rebuildUpdateStatusMessage];
            [GCAppGlobal derived].pauseCalculation = false;

            RZLog(RZLogInfo, @"Starting rebuild calculate stage");
            NSArray<GCActivity*>*activities = [[GCAppGlobal organizer] activities];
            GCDerivedDataSerie * current = self.derivedAnalysisConfig.currentDerivedDataSerie;
            NSArray<GCActivity*>*contained = [current containedActivitiesIn:activities];
            if( contained.count > 0){
                [[GCAppGlobal derived] rebuildDerivedDataSerie:gcDerivedTypeBestRolling
                                                   forActivity:contained.firstObject
                                                  inActivities:contained];
                
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [self.delegate configChanged];
                    [self.tableView reloadData];
                });
            }
        }
    }

}

#pragma mark - Cell and RZChild Delegate

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    BOOL reload = false;
    if( [theParent isKindOfClass:[GCDerivedOrganizer class]]){
        if( [theInfo.stringInfo isEqualToString:kNOTIFY_DERIVED_END] ){
            RZLog(RZLogInfo,@"Derived Finished");
            reload = true;
            [GCAppGlobal derived].pauseCalculation = false;
            [self rebuildProcessNextStage];
        }
    }else if ([theParent isKindOfClass:[GCWebConnect class]]){
        if( [theInfo.stringInfo isEqualToString:NOTIFY_END] ){
            RZLog(RZLogInfo,@"Web Finished");
            reload = true;
            [GCAppGlobal derived].pauseCalculation = false;
            [self rebuildProcessNextStage];
        }
    }
    
    
    if( reload ){
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.delegate configChanged];
            [self.tableView reloadData];
        });
    }else{
        [self rebuildUpdateStatusMessage];
    }
}

-(void)cellWasChanged:(id<GCEntryFieldProtocol>)cell{
    if( cell.identifierInt == GC_IDENTIFIER(GC_SECTION_STATUS, GC_STATUS_PERIOD) || cell.identifierInt == GC_IDENTIFIER(GC_SECTION_STATUS, GC_STATUS_FIELD)){
        self.derivedAnalysisConfig.currentDerivedDataSerie = self.choices[cell.selected];
        [self.delegate configChanged];
    }
    [self.tableView reloadData];
}

- (UINavigationController *)baseNavigationController {
    return self.navigationController;
}


- (UINavigationItem *)baseNavigationItem {
    return self.navigationItem;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if( indexPath.section == GC_SECTION_GRAPHS){
        return 200.;
    }else{
        return 58.;
    }
}
@end
