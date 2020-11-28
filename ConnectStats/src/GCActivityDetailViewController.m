//  MIT Licence
//
//  Created on 14/09/2012.
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

#import "GCActivityDetailViewController.h"
#import "GCAppGlobal.h"
#import "GCMapViewController.h"
#import "GCCellMap.h"
#import "GCViewConfig.h"
#import "GCFields.h"
#import "GCCellGrid+Templates.h"
#import "GCActivityLapViewController.h"
#import "GCActivityTrackGraphViewController.h"
#import "GCSimpleGraphCachedDataSource+Templates.h"
#import "Flurry.h"
#import "GCActivitySwimLapViewController.h"
#import "GCSharingViewController.h"
#import <RZExternal/RZExternal.h>
#import "GCActivityTrackGraphOptionsViewController.h"
#import "GCActivity+ExportText.h"
#import "GCWebConnect+Requests.h"
#import "GCActivity+CSSearch.h"
#import "GCActivityOrganizedFields.h"
#import "GCActivity+Fields.h"
#import "GCFormattedField.h"
#import "GCHealthOrganizer.h"
#import "ConnectStats-Swift.h"
#import "GCActivity+Assets.h"

#define GCVIEW_DETAIL_TITLE_SECTION     0
#define GCVIEW_DETAIL_LOAD_SECTION      1
#define GCVIEW_DETAIL_MAP_SECTION       2
#define GCVIEW_DETAIL_GRAPH_SECTION     3
#define GCVIEW_DETAIL_AVGMINMAX_SECTION 4
#define GCVIEW_DETAIL_EXTRA_SECTION     5
#define GCVIEW_DETAIL_WEATHER_SECTION   6
#define GCVIEW_DETAIL_HEALTH_SECTION    7
#define GCVIEW_DETAIL_LAPS_HEADER       8
#define GCVIEW_DETAIL_LAPS_SECTION      9
#define GCVIEW_DETAIL_SECTIONS          10

@interface GCActivityDetailViewController ()

@property (nonatomic,retain) GCActivitiesOrganizer * organizer;
@property (nonatomic,retain) GCTrackStats * trackStats;
@property (nonatomic,readonly) BOOL waitingForTrackpoints;
@property (nonatomic,assign) BOOL waitingForUpdate;
@property (nonatomic,retain) GCActivityAutoLapChoices * autolapChoice;
@property (nonatomic,retain) GCTrackFieldChoices * choices;
@property (nonatomic,retain) GCActivity * activity;
@property (nonatomic,retain) GCTrackStats * compareTrackStats;
@property (nonatomic,assign) BOOL initialized;

@property (nonatomic,retain) GCActivityOrganizedFields * cachedOrganizedFields;
@property (nonatomic,retain) NSArray<NSArray*>*organizedAttributedStrings;

/**
 NSArray of either graph GCField or something else if no graph field @(0)
 */
@property (nonatomic,retain) NSArray*organizedMatchingField;
@end

@implementation GCActivityDetailViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.organizer = [GCAppGlobal organizer];
        [self.organizer attach:self];
        [[GCAppGlobal web] attach:self];
        self.initialized = false;
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyCallBack:) name:kNotifySettingsChange object:nil];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_organizer detach:self];
    [[GCAppGlobal web] detach:self];
    [_autolapChoice release];
    [_choices release];

    [_cachedOrganizedFields release];
    [_organizedAttributedStrings release];
    [_organizedMatchingField release];
    [_organizer release];
    [_trackStats release];
    [_activity release];

    [super dealloc];
}

-(BOOL)isNewStyle{
    return [GCViewConfig cellBandedFormat];
}

-(BOOL)isWide{
    return self.tableView.frame.size.width > 600.0;
}

-(GCActivityOrganizedFields*)organizedFields{
    if( ! self.cachedOrganizedFields ){
        self.cachedOrganizedFields = [self.activity groupedFields];
    }
    return self.cachedOrganizedFields;
}

-(void)setOrganizedFields:(GCActivityOrganizedFields*)organizedFields{
    self.organizedFields  = organizedFields;
}
#pragma mark - UIView

- (void)viewDidLoad
{
    RZLogTrace(@"");
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    //self.tableView.backgroundColor = [GCViewConfig defaultBackgroundColor];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.refreshControl = [[[UIRefreshControl alloc] init] autorelease];
    self.refreshControl.attributedTitle = nil;
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];

    // Get ready with current activity
    [self selectNewActivity:[[GCAppGlobal organizer] currentActivity]];

    CGFloat height = 20.;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        height = 64.;
    }
    self.tableView.tableHeaderView = [[[UIView alloc] initWithFrame:CGRectMake(0., 0., 320., height)] autorelease];

    self.tableView.tableHeaderView.backgroundColor = [GCViewConfig cellBackgroundLighterForActivity:self.activity];
    self.initialized = true;
    self.view.backgroundColor = [GCViewConfig defaultColor:gcSkinDefaultColorBackground];
    self.tableView.backgroundColor = [GCViewConfig defaultColor:gcSkinDefaultColorBackground];
}

- (void)viewWillAppear:(BOOL)animated
{
    RZLogTrace(@"");

    [super viewWillAppear:animated];

    if (self.slidingViewController) {
        [self.view addGestureRecognizer:self.slidingViewController.panGesture];
        (self.slidingViewController).anchorRightRevealAmount = self.view.frame.size.width*0.875;
        //FIXME:
        self.slidingViewController.topViewAnchoredGesture = ECSlidingViewControllerAnchoredGesturePanning;
        self.slidingViewController.panGesture.delegate = self;
        //[self.slidingViewController setShouldAddPanGestureRecognizerToTopViewSnapshot:YES];
    }
    self.tableView.tableHeaderView.backgroundColor = [GCViewConfig cellBackgroundLighterForActivity:self.activity];


}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.slidingViewController.panGesture.delegate = nil;
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    // With the menu open, let any gesture pass.
    if (self.slidingViewController.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredRight) return YES;
    // With a closed Menu, only let the bordermost gestures pass.
    return ([gestureRecognizer locationInView:gestureRecognizer.view].x < 40.);

}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

-(void)refreshData{
    if( [NSThread isMainThread]){
        [self selectNewActivity:[[GCAppGlobal organizer] currentActivity]];
        [self.activity forceReloadTrackPoints];
        dispatch_async(dispatch_get_main_queue(), ^(){
            self.waitingForUpdate = true;
            [self.activity trackpoints];
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self.tableView reloadData];
            });
        });
        [self.refreshControl beginRefreshing];
        self.refreshControl.attributedTitle = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Refreshing",@"RefreshControl")] autorelease];
        
    }else{
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self refreshData];
        });
    }
}

-(void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    [self notifyCallBack:nil info:nil];
    if( @available( iOS 13.0, * )){
        if( self.traitCollection.userInterfaceStyle != previousTraitCollection.userInterfaceStyle ){
            [self.tableView reloadData];
        }
    }

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    //return [[self fieldsToDisplay] count];
    return GCVIEW_DETAIL_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //return [[[self fieldsToDisplay] objectAtIndex:section] count];
    if (section == GCVIEW_DETAIL_MAP_SECTION ) {
        return (self.waitingForTrackpoints || !self.activity.validCoordinate) ? 0 : 1;
    }else if (section == GCVIEW_DETAIL_LOAD_SECTION){
        return self.waitingForTrackpoints && self.waitingForUpdate ? 1 : 0;
    }else if (section == GCVIEW_DETAIL_GRAPH_SECTION){
        return (self.waitingForTrackpoints || self.activity.trackpoints.count == 0) ? 0 : 1;
    }else if (section == GCVIEW_DETAIL_TITLE_SECTION){
        return 1;
    }else if (section == GCVIEW_DETAIL_LAPS_SECTION){
        return self.waitingForTrackpoints ? 0 : self.activity.laps.count;
    }else if ( section == GCVIEW_DETAIL_WEATHER_SECTION ){
        return [self.activity hasWeather] ? 1 : 0;
    }else if (section == GCVIEW_DETAIL_LAPS_HEADER){
        return ( self.waitingForTrackpoints || self.activity.laps.count == 0 ) ? 0 : 1;
    }else if (section == GCVIEW_DETAIL_EXTRA_SECTION){
        return self.activity.metaData.count > 0 ? 1 : 0;
    }else if (section == GCVIEW_DETAIL_HEALTH_SECTION){
        return [[GCAppGlobal health] hasHealthData] ? 1 : 0;
    }
    if( self.isNewStyle ){
        if (!self.organizedFields) {
            self.organizedFields = [self.activity groupedFields];
        }
        
        return self.organizedFields.groupedPrimaryFields.count;

    }else{
        return [self displayPrimaryAttributedStrings].count;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView dayGraphCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GCCellSimpleGraph * cell = [GCCellSimpleGraph graphCell:tableView];
    cell.cellDelegate = self;
    GCActivity * activity = self.activity;
    GCTrackStats * s = [[GCTrackStats alloc] init];
    s.activity = activity;
    if (!self.choices || (self.choices).choices.count==0) {
        self.choices = [GCTrackFieldChoices trackFieldChoicesWithDayActivity:activity];
    }
    //s.x_movingAverage = 60.*10.;
    s.movingSumForUnit = 60.*5.;
    s.bucketUnit = 60.*5.;
    [self.choices setupTrackStats:s];
    self.trackStats = s;
    GCSimpleGraphCachedDataSource * ds = [GCSimpleGraphCachedDataSource trackFieldFrom:s];
    GCActivity * compare = [self compareActivity];
    if (compare) {
        if ([self.choices validForActivity:compare]) {
            self.compareTrackStats = [[[GCTrackStats alloc] init] autorelease];
            self.compareTrackStats.activity = compare;
            [self.choices setupTrackStats:self.compareTrackStats];
            GCSimpleGraphCachedDataSource * dsc = [GCSimpleGraphCachedDataSource trackFieldFrom:self.compareTrackStats];
            [dsc setupAsBackgroundGraph];
            [ds addDataSource:dsc];
        }

    }
    [cell setDataSource:ds andConfig:ds];

    [s release];

    return cell;
}

-(UITableViewCell*)tableView:(UITableView *)tableView activityGraphCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GCCellSimpleGraph * cell = [GCCellSimpleGraph graphCell:tableView];
    cell.cellDelegate = self;
    
    GCActivity * activity = self.activity;
    
     dispatch_block_t build = ^(){
        GCTrackStats * s = [[GCTrackStats alloc] init];
        s.activity = activity;
        if (!self.choices || (self.choices).choices.count==0) {
            self.choices = [GCTrackFieldChoices trackFieldChoicesWithActivity:activity];
        }
        [self.choices setupTrackStats:s];
        self.trackStats = s;
        GCSimpleGraphCachedDataSource * ds = [GCSimpleGraphCachedDataSource trackFieldFrom:s];
        GCActivity * compare = [self compareActivity];
        if (compare) {
            if ([self.choices validForActivity:compare]) {
                self.compareTrackStats = [[[GCTrackStats alloc] init] autorelease];
                self.compareTrackStats.activity = compare;
                [self.choices setupTrackStats:self.compareTrackStats];
                GCSimpleGraphCachedDataSource * dsc = [GCSimpleGraphCachedDataSource trackFieldFrom:self.compareTrackStats];
                [dsc setupAsBackgroundGraph];
                [ds addDataSource:dsc];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^(){
            [cell setDataSource:ds andConfig:ds];
            [cell setNeedsDisplay];
        });
        [s release];
    };
    if( activity.settings.worker ){
        dispatch_async(activity.settings.worker,build);
    }else{
        build();
    }
    return cell;
}


-(UITableViewCell *)tableView:(UITableView *)tableView mapCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GCCellMap *cell = (GCCellMap*)[tableView dequeueReusableCellWithIdentifier:@"GCMap"];
    if (cell == nil) {
        cell = [[[GCCellMap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GCMap"] autorelease];
    }
    GCActivity * act = self.activity;
    if( ![cell.mapController.activity.activityId isEqualToString:act.activityId] ){
        RZLog(RZLogInfo, @"Changing map activity");
        //[cell.mapController clearAllOverlayAndAnnotations];
    }
    cell.mapController.activity = act;
    dispatch_block_t build = ^(){
        // make sure we have trackpoints
        [act trackpoints];
        if ([GCAppGlobal configGetBool:CONFIG_MAPS_INLINE_GRADIENT defaultValue:true]) {
            if (!self.choices || (self.choices).choices.count==0) {
                self.choices = [GCTrackFieldChoices trackFieldChoicesWithActivity:self.activity];
            }
            cell.mapController.gradientField = self.choices.current.field;
            if(self.choices.current.statsStyle == gcTrackStatsCompare && self.compareActivity){
                cell.mapController.compareActivity = self.compareActivity;
            }else{
                cell.mapController.compareActivity = nil;
            }
        }else{
            cell.mapController.gradientField = nil;
        }

        [cell.mapController notifyCallBack:nil info:nil];
    };
    if( self.activity.settings.worker ){
        dispatch_async(self.activity.settings.worker,build);
    }else{
        build();
    }

    return cell;
}

-(UITableViewCell*)tableView:(UITableView *)tableView OldFieldCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GCCellGrid * cell = [GCCellGrid gridCell:tableView];
    
    if (!self.organizedFields) {
        self.organizedFields = [self.activity groupedFields];
    }
    
    if( indexPath.row < self.organizedFields.groupedPrimaryFields.count){
        
        NSArray<GCField*>*fields = self.organizedFields.groupedPrimaryFields[indexPath.row];
        [cell setupForRows:fields.count andCols:2];
        
        [cell labelForRow:0 andCol:0].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute:rzAttributeField]
                                                                                 withString:fields.firstObject.displayName];
        NSString * value = [[self.activity numberWithUnitForField:fields.firstObject] formatDouble];
        [cell labelForRow:0 andCol:1].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute:rzAttributeValue]
                                                                                 withString:value];
        NSUInteger row = 1;
        for (GCField * field in fields) {
            if( field != fields.firstObject){
                [cell labelForRow:row andCol:0].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute:rzAttributeSecondaryField]
                                                                                         withString:[field displayNameWithPrimary:fields.firstObject]];
                NSString * value = [[self.activity numberWithUnitForField:field] formatDouble];
                [cell labelForRow:row andCol:1].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute:rzAttributeSecondaryValue]
                                                                                         withString:value];
                [cell configForRow:row andCol:0].horizontalAlign = gcHorizontalAlignRight;
                row++;
            }
        }
        //[cell setupForField:field andActivity:act width:tableView.frame.size.width];
        BOOL graphIcon = false;
        if (indexPath.row < self.organizedMatchingField.count && [self.organizedMatchingField[indexPath.row] isKindOfClass:[GCField class]]) {
            graphIcon = true;
        }
        
        [GCViewConfig setupGradientForDetails:cell];
        
        if(graphIcon){
            [cell setIconImage:[GCViewIcons cellIconFor:gcIconCellLineChart]];
        }else{
            [cell setIconImage:nil];
            UIImage * icon = [GCViewIcons cellIconFor:gcIconCellLineChart];
            CGSize size = icon.size;
            UIView * view = [[[UIView alloc] initWithFrame:CGRectMake(0., 0., size.width, size.height)] autorelease];
            view.backgroundColor = [UIColor clearColor];
            [cell setIconView:view  withSize:size];
        }
    }
    return cell;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * rv = nil;

    if (indexPath.section == GCVIEW_DETAIL_TITLE_SECTION) {
        GCCellGrid * cell = [GCCellGrid gridCell:tableView];
        [cell setupDetailHeader:self.activity];

        rv = cell;
    }else if (indexPath.section == GCVIEW_DETAIL_AVGMINMAX_SECTION) {
        if( self.isNewStyle ){
            rv = [self tableView:tableView fieldCellForRowAtIndexPath:indexPath];
        }else{
            GCCellGrid * cell = [GCCellGrid gridCell:tableView];
            
            //GCActivity * act=self.activity;
            NSArray<NSArray*>*primary = [self displayPrimaryAttributedStrings];
            if( indexPath.row < primary.count){
                NSArray<NSAttributedString*>* attrStrings = primary[indexPath.row];
                
                //[cell setupForField:field andActivity:act width:tableView.frame.size.width];
                BOOL graphIcon = false;
                if (indexPath.row < self.organizedMatchingField.count && [self.organizedMatchingField[indexPath.row] isKindOfClass:[GCField class]]) {
                    graphIcon = true;
                }
                [cell setupForAttributedStrings:attrStrings graphIcon:graphIcon width:tableView.frame.size.width];
            }
            rv = cell;
        }
    }else if(indexPath.section == GCVIEW_DETAIL_LOAD_SECTION){
        GCCellActivityIndicator *cell = [GCCellActivityIndicator activityIndicatorCell:tableView parent:[GCAppGlobal web]];
        if ([[GCAppGlobal web] isProcessing]) {
            cell.label.text = [[GCAppGlobal web] currentDescription];
        }else{
            cell.label.text = nil;
        }
        rv = cell;
    }else if(indexPath.section == GCVIEW_DETAIL_MAP_SECTION){
        rv = [self tableView:tableView mapCellForRowAtIndexPath:indexPath];
    }else if(indexPath.section == GCVIEW_DETAIL_GRAPH_SECTION){
        if ([self.activity.activityType isEqualToString:GC_TYPE_DAY]) {
            rv = [self tableView:tableView dayGraphCellForRowAtIndexPath:indexPath];
        }else{
            rv = [self tableView:tableView activityGraphCellForRowAtIndexPath:indexPath];
        }
    }else if(indexPath.section == GCVIEW_DETAIL_LAPS_HEADER){
        GCCellGrid * cell = (GCCellGrid*)[tableView dequeueReusableCellWithIdentifier:@"GCGrid"];
        if (cell == nil) {
            cell = [[[GCCellGrid alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GCGrid"] autorelease];
        }
        [cell setupForRows:2 andCols:1];

        if (self.autolapChoice==nil) {
            self.autolapChoice = [[[GCActivityAutoLapChoices alloc] initWithActivity:self.activity] autorelease];
        }else{
            [self.autolapChoice changeActivity:self.activity];
        }
        [cell labelForRow:0 andCol:0].attributedText = [GCActivityAutoLapChoices currentDescription:self.activity];
        if (self.autolapChoice) {
            [cell labelForRow:1 andCol:0].attributedText = [self.autolapChoice currentDetailledDescription];
        }else{
            [cell labelForRow:1 andCol:0].attributedText = [GCActivityAutoLapChoices defaultDescription];
        }
        [GCViewConfig setupGradientForDetails:cell];
        rv = cell;
    }else if(indexPath.section == GCVIEW_DETAIL_LAPS_SECTION){
        GCCellGrid * cell = (GCCellGrid*)[tableView dequeueReusableCellWithIdentifier:@"GCGrid"];
        if (cell == nil) {
            cell = [[[GCCellGrid alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GCGrid"] autorelease];
        }

        GCActivity * act=self.activity;

        [cell setupForLap:indexPath.row andActivity:act width:tableView.frame.size.width];
        rv = cell;

    }else if (indexPath.section == GCVIEW_DETAIL_EXTRA_SECTION){
        GCCellGrid * cell = [GCCellGrid gridCell:tableView];
        GCActivity * act=self.activity;
        [cell setupForExtraSummary:act width:tableView.frame.size.width];
        rv = cell;
    }else if (indexPath.section == GCVIEW_DETAIL_WEATHER_SECTION){
        GCCellGrid * cell = [GCCellGrid gridCell:tableView];

        GCActivity * act=self.activity;
        [cell setupForWeather:act width:tableView.frame.size.width];
        rv = cell;
    }else if (indexPath.section == GCVIEW_DETAIL_HEALTH_SECTION){
        GCCellGrid * cell = [GCCellGrid gridCell:tableView];

        GCActivity * act=self.activity;
        GCHealthMeasure * meas=[[GCAppGlobal health] measureForDate:act.date andField:[GCHealthMeasure weight]];
        [cell setupForHealthMeasureSummary:meas];
        rv = cell;
    }else{
        rv = [GCCellGrid gridCell:tableView];
    }
	return rv;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    BOOL high = self.tableView.frame.size.height > 600.;

    if (indexPath.section == GCVIEW_DETAIL_AVGMINMAX_SECTION) {
        if (!self.organizedFields) {
            self.organizedFields = [self.activity groupedFields];
        }
        return [GCViewConfig sizeForNumberOfRows:[self.organizedFields.groupedPrimaryFields[indexPath.row] count]+1];
    }else if(indexPath.section==GCVIEW_DETAIL_MAP_SECTION){
        return high ? 200. : 150.;
    }else if(indexPath.section==GCVIEW_DETAIL_LOAD_SECTION){
        return 100.;
    }else if(indexPath.section==GCVIEW_DETAIL_GRAPH_SECTION){
        return high ? 200. : 150.;
    }else if(indexPath.section == GCVIEW_DETAIL_TITLE_SECTION){
        return [GCViewConfig sizeForNumberOfRows:3];
    }
    return [GCViewConfig sizeForNumberOfRows:3];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // go into stat page
    // stats page:
    // history/activity either accross  time or for this activity points
    // graph
    // table aggregated by week/month/all, sum or avg
    if (indexPath.section == GCVIEW_DETAIL_MAP_SECTION) {

        [self showMap:self.choices.current.field];
    }else if( indexPath.section == GCVIEW_DETAIL_TITLE_SECTION){
        
    }else if( indexPath.section == GCVIEW_DETAIL_AVGMINMAX_SECTION){
        if (indexPath.row < self.organizedMatchingField.count) {
            GCField * field = self.organizedMatchingField[indexPath.row];
            if ([field isKindOfClass:[GCField class]]) {
                [self showTrackGraph:field];
            }
        }
    }else if(indexPath.section == GCVIEW_DETAIL_GRAPH_SECTION){
        [self.choices nextStyle];
        [self notifyCallBack:nil info:nil];
    }else if( indexPath.section == GCVIEW_DETAIL_LAPS_SECTION){
        UIViewController * ctl = nil;
        if (self.activity.garminSwimAlgorithm) {
            GCActivitySwimLapViewController * lapView = [[GCActivitySwimLapViewController alloc] initWithStyle:UITableViewStylePlain];
            lapView.activity = self.activity;
            lapView.lapIndex = indexPath.row;
            ctl = lapView;
        }else{
            GCActivityLapViewController * lapView = [[GCActivityLapViewController alloc] initWithStyle:UITableViewStylePlain];
            lapView.activity = self.activity;
            lapView.lapIndex = indexPath.row;
            ctl = lapView;
        }
        if ([UIViewController useIOS7Layout]) {
            [UIViewController setupEdgeExtendedLayout:ctl];
        }

        [self.navigationController pushViewController:ctl animated:YES];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [ctl release];
    }else if( indexPath.section == GCVIEW_DETAIL_HEALTH_SECTION){

    }else if( indexPath.section == GCVIEW_DETAIL_LAPS_HEADER){

        GCActivity * act  = self.activity;
        if (act.garminSwimAlgorithm==false) {
            if (self.autolapChoice==nil) {
                self.autolapChoice = [[[GCActivityAutoLapChoices alloc] initWithActivity:act] autorelease];
            }

            GCCellEntryListViewController * list = [GCViewConfig standardEntryListViewController:[self.autolapChoice choicesDescriptions]
                                                                                                 selected:self.autolapChoice.selected];
            list.entryFieldDelegate = self;
            [self.navigationController pushViewController:list animated:YES];
            [self.navigationController setNavigationBarHidden:NO animated:YES];
        }
    }else if( indexPath.section == GCVIEW_DETAIL_EXTRA_SECTION){
        GCActivityMetaValue * desc = (self.activity).metaData[@"activityDescription"];
        CGFloat width = self.tableView.frame.size.width;
        NSUInteger maxSize = width>321.? 50 : 30;

        if (desc && (desc.display).length>maxSize) {
            [self presentSimpleAlertWithTitle:NSLocalizedString(@"Activity Description", @"Activity Description")
                                      message:desc.display];
        }
    }
}

#pragma mark - Table Header

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return nil;
}


#pragma mark - Setup and call back

-(NSArray<NSAttributedString*>*)attributedStringsForFieldInput:(NSArray<GCField*>*)input{
    NSMutableArray * rv = [NSMutableArray array];
    GCActivity * activity = self.activity;
    GCFormattedField * mainF = nil;
    GCField * field = nil;

    if([input isKindOfClass:[NSArray class]]){
        NSArray<GCField*> * inputs = input;
        if (inputs.count>0) {
            field = inputs[0];
            GCNumberWithUnit * mainN = [activity numberWithUnitForField:field];
            mainF = [GCFormattedField formattedField:field forNumber:mainN forSize:16.];
            [rv addObject:mainF.attributedString];
            
            for (NSUInteger i=1; i<inputs.count; i++) {
                GCField * addField = inputs[i];
                GCNumberWithUnit * addNumber = [activity numberWithUnitForField:addField];
                if( [[addField correspondingWeightedMeanField] isEqualToField:field] && [addNumber.unit canConvertTo:mainN.unit]){
                    addNumber = [addNumber convertToUnit:mainN.unit];
                }
                if (addNumber) {
                    GCFormattedField* theOne = [GCFormattedField formattedField:addField forNumber:addNumber forSize:14.];
                    theOne.shareFieldLabel = field;
                    theOne.valueColor = [GCViewConfig defaultColor:gcSkinDefaultColorSecondaryText];
                    theOne.labelColor = [GCViewConfig defaultColor:gcSkinDefaultColorSecondaryText];
                    if ([addNumber sameUnit:mainN]) {
                        theOne.noUnits = true;
                    }
                    [rv addObject:[theOne attributedString]];
                }
            }
        }
    }
    return rv;
}


-(NSArray<NSArray*>*)fitOrBreakupWide:(NSArray<NSAttributedString*>*)attrStrings{
    return @[ attrStrings];
}

-(NSArray<NSArray*>*)fitOrBreakupNarrow:(NSArray<NSAttributedString*>*)attrStrings{
    if (attrStrings.count == 0) {
        return nil;
    }
    NSMutableArray * rv =[NSMutableArray array];
    CGFloat tablewidth = self.tableView.frame.size.width - 35. -10.5;//35 for icon space, 10. for margins

    NSAttributedString * topLeft = attrStrings[0];
    NSAttributedString * bottomLeft = nil;
    NSAttributedString * bottomRight = nil;
    NSAttributedString * topRight = nil;

    NSMutableArray * firstCell = [NSMutableArray arrayWithObject:topLeft];

    if (attrStrings.count > 1) {
        bottomLeft = attrStrings[1];
        [firstCell addObject:bottomLeft];
    }
    BOOL breakup = false;

    if (attrStrings.count > 2) {
        bottomRight = attrStrings[2];
        if (bottomLeft.size.width + bottomRight.size.width > tablewidth) {
            breakup = true;
        }
    }
    if (attrStrings.count > 3) {
        topRight = attrStrings[3];
        if (topRight.size.width + topLeft.size.width > tablewidth*0.95) {
            breakup = true;
        }
    }

    if (breakup) {
        [rv addObject:firstCell];
        if (bottomRight) {
            NSMutableArray * secondCell = [NSMutableArray arrayWithObject:bottomRight];
            if (topRight) {
                [secondCell addObject:topRight];
            }
            [rv addObject:secondCell];
        }
    }else{
        // Keep it together.
        [rv addObject:attrStrings];
    }

    return rv;
}

-(GCActivityOrganizedFields*)displayOrganizedFields{
    if (!self.organizedFields) {
        self.organizedFields = [self.activity groupedFields];

        CGFloat tablewidth = self.tableView.frame.size.width;
        NSMutableArray * packed = [NSMutableArray array];
        NSMutableArray * fields = [NSMutableArray array];
        // Start Packing
        for (NSArray<GCField*> * input in self.organizedFields.groupedPrimaryFields) {
            GCField * field = input.firstObject;
            if(field.fieldFlag == gcFieldFlagSumDistance){
                field = [GCField fieldForFlag:gcFieldFlagAltitudeMeters andActivityType:_activity.activityType];
            }
            BOOL validForGraph =( [_activity hasTrackForField:field] && [field validForGraph] );
            NSArray<NSAttributedString*> * attrStrings = [self attributedStringsForFieldInput:input];
            NSArray<NSArray*>* splitUp = tablewidth > 600. ? [self fitOrBreakupWide:attrStrings] : [self fitOrBreakupNarrow:attrStrings];
            [packed addObjectsFromArray:splitUp];
            for (NSUInteger i=0; i<splitUp.count; i++) {
                if(validForGraph && i==0){
                    [fields addObject:field];
                }else{
                    [fields addObject:@(0)];
                }
            }
        }
        self.organizedAttributedStrings = packed;
        self.organizedMatchingField = fields;
        if (self.organizedMatchingField.count != self.organizedAttributedStrings.count) {
            RZLog(RZLogWarning, @"Organized Arrays be equals size");
        }
    }
    return _organizedFields;
}

-(NSArray<NSArray*>*)displayPrimaryAttributedStrings{
    [self displayOrganizedFields];
    return self.organizedAttributedStrings;
}


-(GCActivity*)compareActivity{
    return [self.organizer validCompareActivityFor:self.activity];
}

#pragma mark - Activity Change and Prep

-(void)selectNewActivity:(GCActivity*)act{

    BOOL activityIsChanging = (![act.activityId isEqualToString:self.activity.activityId]);
    
    // This only needed if brand new activity
    if( activityIsChanging )  {
        if (act) {
            RZLog(RZLogInfo, @"Display Detail %@",[act debugDescription]);
        }
        self.activity = act;

        self.userActivity = [self.activity spotLightUserActivity];
        [self.userActivity becomeCurrent];
    }

    // Below always do in case the activity change.
    self.organizedFields = nil; // Force regeneration of list of fields to display

    if (self.trackStats && ![_trackStats.activity.activityId isEqualToString:(self.activity).activityId]) {
        self.choices = nil; // Force build of graphs to rotate through in graph cell
        self.trackStats = nil; // Force build of trackstats
    }
    if (![self.choices trackFlagSameAs:self.activity]) {
        self.choices = nil;
        self.trackStats = nil;
    }
    self.autolapChoice = nil;
    
    if( activityIsChanging ){
        // If no trackpoint load on worker thread
        if( ! act.trackpointsReadyNoLoad ){
            dispatch_async([GCAppGlobal worker], ^(){
                self.waitingForUpdate = true;
                [act trackpoints];
                dispatch_async(dispatch_get_main_queue(), ^(){
                    if( !self.waitingForTrackpoints ){
                        self.waitingForUpdate = false;
                    }
                    [self.tableView reloadData];
                });
            });
        }else{
            [self tableReloadData];
        }
    }else{
        [self tableReloadData];
    }
}

-(BOOL)waitingForTrackpoints{
    return !self.activity.trackpointsReadyNoLoad;
}

-(void)tableReloadData{
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self.tableView reloadData];
    });
}

-(void)notifyCallBack:(NSNotification*)notification{
    self.trackStats = nil;

    [self.activity.settings setupWithGlobalConfig:self.activity];
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self.tableView reloadData];
    });
}

-(void)updateUserActivityState:(NSUserActivity *)activity{
    [self.activity updateUserActivity:activity];
}

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo*)theInfo{
    NSString * stringInfo = theInfo.stringInfo;
    NSString * compareId  = [self compareActivity].activityId;

    BOOL sameActivityId = [stringInfo isEqualToString:(self.activity).activityId] || (compareId && [stringInfo isEqualToString:compareId]);

    if( !self.waitingForTrackpoints ){
        self.waitingForUpdate = false;
    }
    // If notification for a different activityId, don't do anything
    if ((theParent == self.organizer &&
         (sameActivityId || stringInfo == nil)) || // organizer either nil -> all or specific activity Id
        theParent == nil ) {// Use for focusOnactivity -> parent = nil
        // Don't bother if not initialized(view didn't load yet)
        if (self.initialized) {
            [self selectNewActivity:[self.organizer currentActivity]];
        }else{
            self.choices = nil;
        }
    }else{ // Web Update
        if ([theInfo.stringInfo isEqualToString:NOTIFY_ERROR] ||
            [theInfo.stringInfo isEqualToString:NOTIFY_END]) {
            self.waitingForUpdate = false;
            [self performRefreshControl];
        }
    }
}


-(void)performRefreshControl{
    if ([NSThread isMainThread]) {
        [self.refreshControl endRefreshing];
        [self.tableView setContentOffset:CGPointZero animated:YES];
        [self.tableView reloadData];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self performRefreshControl];
        });
    }
}

#pragma mark - Actions

-(UIImage*)exportImage{
    return [GCViewConfig imageWithView:self.view];
}

-(void)showMap:(GCField*)field{
    GCMapViewController *detailViewController = [[GCMapViewController alloc] initWithNibName:nil bundle:nil];
    
    detailViewController.gradientField = field;
    detailViewController.activity = self.activity;
    detailViewController.mapType = (gcMapType)[GCAppGlobal configGetInt:CONFIG_USE_MAP defaultValue:gcMapBoth];
    detailViewController.enableTap = true;

    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController pushViewController:detailViewController animated:YES];

    [detailViewController release];
}

-(void)showTrackGraph:(GCField*)afield{
    GCField * field = afield;

    if (field.fieldFlag == gcFieldFlagSumDistance) {
        field = [GCField fieldForFlag:gcFieldFlagAltitudeMeters andActivityType:self.activity.activityType];
    }

    if (self.trackStats && [self.activity hasTrackForField:field]) {

        ECSlidingViewController * sliding = [[ECSlidingViewController alloc] initWithNibName:nil bundle:nil];
        GCActivityTrackGraphViewController * graphViewController = [[GCActivityTrackGraphViewController alloc] initWithNibName:nil bundle:nil];
        GCActivityTrackGraphOptionsViewController * optionController = [[GCActivityTrackGraphOptionsViewController alloc] initWithStyle:UITableViewStyleGrouped];
        optionController.viewController = graphViewController;
        GCTrackStats * ts = [[[GCTrackStats alloc] init] autorelease];
        [ts updateConfigFrom:self.trackStats];
        [ts setupForField:field xField:nil andLField:nil];

        graphViewController.trackStats = ts;
        graphViewController.activity = self.activity;
        graphViewController.field = field;
        sliding.topViewController = graphViewController;
        sliding.underLeftViewController = [[[UINavigationController alloc] initWithRootViewController:optionController] autorelease];
        [optionController.navigationController setNavigationBarHidden:YES];

        [UIViewController setupEdgeExtendedLayout:sliding];
        [UIViewController setupEdgeExtendedLayout:graphViewController];
        [UIViewController setupEdgeExtendedLayout:sliding.underLeftViewController];

        [self.navigationController pushViewController:sliding animated:YES];
        [self.navigationController setNavigationBarHidden:NO animated:YES];

        [graphViewController release];
        [sliding release];
        [optionController release];
    }
}

#pragma mark - Configure

-(void)swipeRight:(GCCellSimpleGraph *)cell{
    [self.choices previous];
    [self notifyCallBack:nil info:nil];
}
-(void)swipeLeft:(GCCellSimpleGraph*)cell{
    [self.choices next];
    [self notifyCallBack:nil info:nil];
}
-(void)nextGraphField{
    [self.choices next];
}


-(void)cellWasChanged:(id<GCEntryFieldProtocol>)cell{
    [self.autolapChoice changeSelectedTo:[cell selected]];
    [self.tableView reloadData];
}

-(UINavigationController*)baseNavigationController{
    return self.navigationController;
}
-(UINavigationItem*)baseNavigationItem{
    return (self.navigationController).navigationItem;
}

@end
