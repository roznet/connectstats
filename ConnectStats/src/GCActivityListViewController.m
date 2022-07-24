//  MIT Licence
//
//  Created on 02/09/2012.
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
@import Flurry_iOS_SDK;
#import "GCActivityListViewController.h"
#import "GCActivitiesOrganizer.h"
#import "GCAppGlobal.h"
#import "GCViewConfig.h"
#import "GCActivitySearch.h"
#import "GCCellGrid+Templates.h"
#import "GCSplitViewController.h"
#import "GCViewIcons.h"
#import "GCActivityTypeListViewController.h"
#import "GCWebConnect+Requests.h"
#import "GCCellHealthDayActivity.h"
#import "GCActivityPreviewingViewController.h"
@import RZExternal;
#import "GCActivity+Database.h"
#import "ConnectStats-Swift.h"

#define GC_ALERT_CONFIRM_DELETED    1
#define GC_ALERT_TRIAL              2
#define GC_ALERT_RENAME_ACTIVITY    3
#define GC_ALERT_DELETE_ACTIVITY    4

const CGFloat kCellDaySpacing = 2.f;

@interface GCActivityListViewController ()
@property (nonatomic,assign) NSUInteger loginTries;
@property (nonatomic,retain) GCActivitiesOrganizer * organizer;
@property (nonatomic,retain) UILabel * titleLabel;
@property (nonatomic,retain) UISearchBar * search;
@property (nonatomic,retain) GCActivity * activityForAction;
@property (nonatomic,assign) BOOL quickFilter;
@property (nonatomic,assign) BOOL showImages;

@end

@implementation GCActivityListViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.organizer = [GCAppGlobal organizer];
        [self.organizer attach:self];
        self.detailController = nil;
        self.titleLabel = RZReturnAutorelease([[UILabel alloc] initWithFrame:CGRectZero]);
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [GCViewConfig boldSystemFontOfSize:10.0];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColor = [UIColor whiteColor];

        self.quickFilter = [GCAppGlobal configGetBool:CONFIG_QUICK_FILTER defaultValue:false];

        self.showImages = [GCAppGlobal configGetBool:CONFIG_SHOW_PHOTOS defaultValue:false];
        
        self.refreshControl = RZReturnAutorelease([[UIRefreshControl alloc] init]);
        self.refreshControl.attributedTitle = nil;
        [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyCallBack:) name:kNotifySettingsChange object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyCallBack:) name:kNotifyLocationRequestComplete object:nil];

    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    RZRelease(_organizer);
    RZRelease(_search);
    RZRelease(_activityForAction);
    RZRelease(_detailController);
    RZRelease(_titleLabel);

    RZSuperDealloc;
}

-(BOOL)extendedDisplay{
    return [GCAppGlobal configGetBool:CONFIG_CELL_EXTENDED_DISPLAY defaultValue:true];
}

-(void)deletedActivity{
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self delayedEndRefreshing:self];
    });

    UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Deleted Activity", @"DeletedActivity")
                                                                    message:NSLocalizedString(@"This activity was deleted from garmin connect, do you want to delete in the app too?",@"DeletedActivity")
                                                             preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Alert")
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction*action){

                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", @"Alert")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction*action){
                                                [[GCAppGlobal organizer] deleteActivityAtIndex:[GCAppGlobal organizer].currentActivityIndex];
                                            }]];
    [self presentViewController:alert animated:YES completion:nil];
}

-(NSArray<NSString*>*)reportServiceError{
    NSMutableArray * errorsString = [NSMutableArray arrayWithCapacity:gcWebServiceEnd];
    gcWebService others[] = {gcWebServiceGarmin,gcWebServiceConnectStats,gcWebServiceStrava};
    
    BOOL messageOnly = true;
    
    size_t nServices = sizeof(others)/sizeof(gcWebService);
    for (size_t i=0; i<nServices; i++) {
        gcWebService service = others[i];
        GCWebStatus status= [[GCAppGlobal web] statusForService:service];
        if ( status!= GCWebStatusOK) {
            // if only message, don't display Error in the string
            if( status != GCWebStatusCustomMessage){
                messageOnly = false;
            }
            [errorsString addObject:[NSString stringWithFormat:@"%@: %@",
                                     [[GCAppGlobal web] webServiceDescription:service],
                                     [[GCAppGlobal web] statusDescriptionForService:service]]];
            if (service == gcWebServiceGarmin) {
                NSString * lastName = [[GCAppGlobal organizer] lastGarminLoginUsername];
                NSString *username = [[GCAppGlobal profile] currentLoginNameForService:gcServiceGarmin];
                if (lastName && ![username isEqualToString:lastName] ) {
                    RZLog(RZLogError, @"Inconsistent username before=%@ now=%@", lastName, [[GCAppGlobal profile] currentLoginNameForService:gcServiceGarmin]);
                }
                if (![username isEqualToString:username.lowercaseString]) {
                    RZLog(RZLogError, @"Inconsistent case in username %@ try=%@?", username, [username lowercaseString]);
                }
            }
        }
    }
    if( errorsString.count == 0){
        if ([[GCAppGlobal web] lastError]) {
            [errorsString addObject:[[[GCAppGlobal web] lastError] localizedDescription]];
        }
    }
    
    // Tested by turning off internet
    NSString * leaderString = messageOnly ?  NSLocalizedString(@"Message", @"Error") : NSLocalizedString(@"Error updating", @"Error");
    [self presentSimpleAlertWithTitle:leaderString message:[errorsString componentsJoinedByString:@"\n"]];
    
    return errorsString;
}

-(void)updateRefreshControlTitle{
    if ((self.refreshControl).refreshing) {
        self.refreshControl.attributedTitle = RZReturnAutorelease([[NSAttributedString alloc] initWithString:[[GCAppGlobal web] currentDescription] ?: @""]);
    }
}

-(void)notifyCallBack:(NSNotification*)notification{
    if ([[NSThread currentThread] isMainThread]) {
        if( [notification.name isEqualToString:kNotifyLocationRequestComplete] ){
            [self.organizer filterForLastSearchString];
        }
        [self.tableView reloadData];
        [self setupQuickFilterIcon];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self notifyCallBack:notification];
        });
    }
}

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo*)theInfo{
    if (theParent == self.organizer) {
        [self filterActivityForString:self.search.text];
        if (self.quickFilter) {
            [self.organizer filterForQuickFilter];
        }
        [self notifyCallBack:nil];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self updateRefreshControlTitle];
        });

        if ([theInfo.stringInfo isEqualToString:NOTIFY_END]) {
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self delayedEndRefreshing:self];
            });
            self.loginTries = 0;
        }else if ([theInfo.stringInfo isEqualToString:NOTIFY_ERROR]) {

            if ([GCAppGlobal web].status == GCWebStatusResourceNotFound) {
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [self deletedActivity];
                });

            }else{
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [self reportServiceError];
                    [self delayedEndRefreshing:self];
                });
            }
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.tableView.backgroundColor = [GCViewConfig defaultBackgroundColor];

    [self.tableView registerNib:[UINib nibWithNibName:@"GCCellActivity" bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:@"GCCellActivity"];
    
    self.navigationItem.titleView = self.titleLabel;

	self.search = RZReturnAutorelease([[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 280.0f, 44.0f)]);
	_search.barStyle					= UIBarStyleDefault;
	_search.delegate					= self;
	_search.autocorrectionType		= UITextAutocorrectionTypeNo;
	_search.autocapitalizationType	= UITextAutocapitalizationTypeNone;
    _search.placeholder              = NSLocalizedString(@"Search",@"SearchBar");

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.tableView.tableHeaderView = self.search;
        UIImage * imagel = [GCViewIcons tabBarIconFor:gcIconTabCalendar];
        UIImage * imager = [GCViewIcons tabBarIconFor:gcIconTabStatsIPad];
        UIImage * imagec = [GCViewIcons tabBarIconFor:gcIconTabSettings];

        
        UIBarButtonItem * settingsButton = RZReturnAutorelease([[UIBarButtonItem alloc] initWithImage:imagec style:UIBarButtonItemStylePlain target:self action:@selector(ipadSelectSettings)]);
        
        self.navigationItem.rightBarButtonItem = RZReturnAutorelease([[UIBarButtonItem alloc] initWithImage:imager style:UIBarButtonItemStylePlain target:self action:@selector(ipadSelectStats)]);
         self.navigationItem.leftBarButtonItems = @[
                                                    RZReturnAutorelease([[UIBarButtonItem alloc] initWithImage:imagel style:UIBarButtonItemStylePlain target:self action:@selector(ipadSelectCalendar)]),
                                                    settingsButton,
                                                   
                                                    ];
    }else{
        self.navigationItem.titleView = self.search;
        [self setupQuickFilterIcon];
    }

    [_search findTextFieldsInSubviewHierarchyOfView:_search andExecuteBlock:^(UITextField * searchField){
        searchField.returnKeyType = UIReturnKeyDone;
        [searchField setEnablesReturnKeyAutomatically:NO];
    }];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    [[GCAppGlobal web] attach:self];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [GCViewConfig setupViewController:self];

}
-(void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    [super traitCollectionDidChange:previousTraitCollection];
    if( @available( iOS 13.0, * )){
        if( self.traitCollection.userInterfaceStyle != previousTraitCollection.userInterfaceStyle ){
            [self.tableView reloadData];
        }
    }
}
-(void)setupQuickFilterIcon{
    // iPhone only will have day activities
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ) {
        if ([[GCAppGlobal organizer] isQuickFilterApplicable]) {
            UIImage * filterIcon = [self imageForQuickFilter];
            if (self.navigationItem.rightBarButtonItem == nil) {
                self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:filterIcon
                                                                                           style:UIBarButtonItemStylePlain
                                                                                          target:self
                                                                                          action:@selector(toggleQuickFilter:)] autorelease];
            }
        }else{
            self.navigationItem.rightBarButtonItem = nil;
        }
    }

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    RZLog(RZLogInfo, @"display list");
    
    dispatch_async([GCAppGlobal worker], ^(){
        [[GCAppGlobal organizer] ensureDetailsLoaded];
    });

    [GCAppGlobal startupRefreshIfNeeded];

    if ([[GCAppGlobal web] isProcessing]) {
        [self beginRefreshing];
    }else{
        [self delayedEndRefreshing:nil];
    }
}

#pragma mark - iPad Setup

-(void)ipadSetupStatButton{
    UIImage * imager = [GCViewIcons tabBarIconFor:gcIconTabStatsIPad];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:imager style:UIBarButtonItemStylePlain target:self action:@selector(ipadSelectStats)] autorelease];

}

-(void)ipadSetupDetailButton{
    UIImage * imager = [GCViewIcons tabBarIconFor:gcIconTabMap];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:imager style:UIBarButtonItemStylePlain target:self action:@selector(ipadSelectCurrentActivity)] autorelease];

}

-(void)ipadSelectCalendar{
    GCSplitViewController*sp = (GCSplitViewController*)self.splitViewController;
    [sp.calendarViewController showAndSelectDate:[[[GCAppGlobal organizer] currentActivity] date] ?: [NSDate date]];
    [self.navigationController pushViewController:sp.calendarViewController animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];

}
-(void)ipadSelectSettings{
    GCSplitViewController*sp = (GCSplitViewController*)self.splitViewController;
    [self.navigationController pushViewController:sp.settingsViewController animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)ipadSelectStats{
    GCSplitViewController*sp = (GCSplitViewController*)self.splitViewController;
    [sp.activityDetailViewController.navigationController pushViewController:sp.fieldListViewController animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self ipadSetupDetailButton];
}

-(void)ipadSelectCurrentActivity{
    GCSplitViewController*sp = (GCSplitViewController*)self.splitViewController;
    [sp.activityDetailViewController.navigationController popToRootViewControllerAnimated:YES];
    [self ipadSetupStatButton];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - Quick Filter

-(void)toggleQuickFilter:(id)sender{
    self.quickFilter = [GCAppGlobal configToggleBool:CONFIG_QUICK_FILTER];
    [GCAppGlobal saveSettings];
    self.navigationItem.rightBarButtonItem.image = [self imageForQuickFilter];

    if (self.quickFilter) {
        [[GCAppGlobal organizer] filterForQuickFilter];
    }else{
        [[GCAppGlobal organizer] clearFilter];
    }
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self refreshAfterFilterSetup:nil];
    });
}

-(UIImage*)imageForQuickFilter{
    return  self.quickFilter ? [GCViewIcons navigationIconFor:gcIconNavFilterSelected] : [GCViewIcons navigationIconFor:gcIconNavFilter];

}
#pragma mark - Refreshing

-(void)searchActivities{
    dispatch_async([GCAppGlobal worker], ^(){
        [GCAppGlobal searchRecentActivities];
    });
}

-(void)beginRefreshing{
    if ([NSThread isMainThread]) {
        self.refreshControl.attributedTitle = [[[NSAttributedString alloc] initWithString:@""] autorelease];
        [self.tableView setContentOffset:CGPointMake(0, -self.tableView.contentInset.top-self.refreshControl.frame.size.height) animated:YES];
        [self.refreshControl beginRefreshing];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self beginRefreshing];
        });
    }
}

-(void)endRefreshing{
    [self.refreshControl endRefreshing];
    self.refreshControl.attributedTitle = RZReturnAutorelease([[NSAttributedString alloc] initWithString:@""]);
    //pre iOS7 [self.tableView setContentOffset:CGPointZero animated:YES];
    [self.tableView reloadData];
}

-(void)delayedEndRefreshing:(id)aObj{
    if ([NSThread isMainThread]) {
        [self performSelector:@selector(endRefreshing) withObject:nil afterDelay:1.0];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self delayedEndRefreshing:aObj];
        });
    }
}


-(void)refreshData{
    self.refreshControl.attributedTitle = RZReturnAutorelease([[NSAttributedString alloc] initWithString:@""]);

    [self searchActivities];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self countOfActivities];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GCActivity * act = [self activityForIndex:indexPath.row];
    
    if (![act.activityType isEqualToString:GC_TYPE_DAY]) {
        return [self tableView:tableView activityCellForRowAtIndexPath:indexPath];
    }else{
        return [self tableView:tableView dayCellForRowAtIndexPath:indexPath];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView dayCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GCCellHealthDayActivity * cell = [GCCellHealthDayActivity activityCell:tableView];
    [cell setupForActivity:[self activityForIndex:indexPath.row]];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView activityCellWithImagesForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GCCellGrid * cell = [GCCellGrid cellGrid:tableView];
    cell.delegate = self;
    gcViewActivityStatus status = gcViewActivityStatusNone;
    if (self.organizer.hasCompareActivity && [self.organizer activityIndexForFilteredIndex:indexPath.row]==self.organizer.selectedCompareActivityIndex) {
        status = gcViewActivityStatusCompare;
    }
    [cell setupSummaryFromActivity:[self activityForIndex:indexPath.row] rows:3 width:tableView.frame.size.width status:status];
    cell.cellInset = [self insetForRowAtIndexPath:indexPath];
    cell.cellInsetSize = kCellDaySpacing;
    
    
    return cell;
}



- (UITableViewCell *)tableView:(UITableView *)tableView activityCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL newStyle = [GCViewConfig is2021Style];
    if( newStyle ){
        GCCellActivity * cell = [self.tableView dequeueReusableCellWithIdentifier:@"GCCellActivity" forIndexPath:indexPath];
        [cell setupFor:[self activityForIndex:indexPath.row]];
        return cell;
    }else{
        GCCellGrid * cell = [GCCellGrid cellGrid:tableView];
        cell.delegate = self;
        gcViewActivityStatus status = gcViewActivityStatusNone;
        if (self.organizer.hasCompareActivity && [self.organizer activityIndexForFilteredIndex:indexPath.row]==self.organizer.selectedCompareActivityIndex) {
            status = gcViewActivityStatusCompare;
        }
        
        [cell setupSummaryFromActivity:[self activityForIndex:indexPath.row] rows:self.extendedDisplay ? 4 : 3 width:tableView.frame.size.width status:status];
        cell.cellInset = [self insetForRowAtIndexPath:indexPath];
        cell.cellInsetSize = kCellDaySpacing;
        
        return cell;
    }
}

-(gcCellInset)insetForRowAtIndexPath:(NSIndexPath*)indexPath{
    return gcCellInsetAll;
    /*
    gcCellInset rv = gcCellInsetNone;
    NSUInteger row = indexPath.row;
    GCActivitiesOrganizer * organizer = [GCAppGlobal organizer];
    GCActivity * act = [self activityForIndex:row];

    if (row + 1 < [organizer countOfFilteredActivities]) {
        GCActivity * next = [self activityForIndex:row+1];
        if (![act.date isSameCalendarDay:next.date calendar:[GCAppGlobal calculationCalendar]]) {
            rv = RZSetOption(rv, gcCellInsetBottom);
            //NSLog(@"Bottom for %@ -> %@", act.date, next.date);
        }
    }
    if (row > 1) {
        GCActivity * previous = [self activityForIndex:row-1];
        if (![act.date isSameCalendarDay:previous.date calendar:[GCAppGlobal calculationCalendar]]) {
            //rv = RZSetOption(rv, gcCellInsetTop);
            //NSLog(@"Top for %@ -> %@", previous.date, act.date);
        }

    }
    return rv;
     */
}
#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat rv = [GCViewConfig sizeForNumberOfRows:self.extendedDisplay ? 4 : 3];
    BOOL newStyle = [GCViewConfig is2021Style];
    if( newStyle ){
        rv = [GCViewConfig sizeForNumberOfRows:4] * 1.1;
    }else{
        
        GCActivity * act = [self activityForIndex:indexPath.row];
        if ([act.activityType isEqualToString:GC_TYPE_DAY]) {
            rv = kGCCellActivityDefaultHeight;
        }else{
            if( self.showImages ){
                rv = 150.;
            }
        }
        
        if ([self insetForRowAtIndexPath:indexPath]) {
            rv += kCellDaySpacing;
        }
    }
    return  rv;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [GCAppGlobal focusOnActivityAtIndex:[self.organizer activityIndexForFilteredIndex:indexPath.row]];
}

// When the search button (i.e. "Done") is clicked, hide the keyboard
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
    [self setupFilterForString:searchBar.text];
}

-(void)setupFilterForString:(NSString*)aFilter{
    [self filterActivityForString:aFilter];
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self refreshAfterFilterSetup:aFilter];
    });
}

-(void)refreshAfterFilterSetup:(NSString*)aFilter{
    if( [NSThread isMainThread]){
        [self.tableView reloadData];
        self.search.text = aFilter;
        [self.search setNeedsDisplay];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self setupFilterForString:aFilter];
        });
    }
}

-(void)filterActivityForString:(NSString*)str{
    [self.organizer filterForSearchString:str];
}

-(NSUInteger)countOfActivities{
    return [self.organizer countOfFilteredActivities];
}

-(GCActivity*)activityForIndex:(NSUInteger)idx{
    return [self.organizer filteredActivityForIndex:idx];
}

#pragma mark - UISearchBar Delegate

// When the search text changes, update the array
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	if (searchText.length == 0) {
        [searchBar resignFirstResponder];
        [self filterActivityForString:nil];
        [self.tableView reloadData];
    }
    if (searchText.length > 2) {
        [self filterActivityForString:searchBar.text];
        [self.tableView reloadData];
        [GCAppGlobal publishEvent:EVENT_LIST_SEARCH];
    }
    if (searchText.length > 5 && [searchText isEqualToString:CONFIG_ENABLE_DEBUG_ON]) {
        NSString * current = [GCAppGlobal configGetString:CONFIG_ENABLE_DEBUG defaultValue:CONFIG_ENABLE_DEBUG_OFF];
        if( [current isEqualToString:CONFIG_ENABLE_DEBUG_ON]){
            RZLog(RZLogInfo, @"Turning OFF debug");
            [GCAppGlobal configSet:CONFIG_ENABLE_DEBUG stringVal:CONFIG_ENABLE_DEBUG_OFF];
        }else{
            RZLog(RZLogInfo, @"Turning ON debug");
            [GCAppGlobal configSet:CONFIG_ENABLE_DEBUG stringVal:CONFIG_ENABLE_DEBUG_ON];
        }
        [GCAppGlobal saveSettings];
    }
}


#pragma mark - GCCellGridDelegate

-(void)cellGrid:(GCCellGrid*)cell didSelectRightButtonAt:(NSIndexPath*)indexPath{
    self.activityForAction = [self activityForIndex:indexPath.row];
    NSMutableArray * indexPaths = [NSMutableArray arrayWithObject:indexPath];
    NSUInteger idx = [self.organizer activityIndexForFilteredIndex:indexPath.row];
    if (self.organizer.hasCompareActivity && idx == self.organizer.selectedCompareActivityIndex) {
        self.organizer.hasCompareActivity = false;
    }else{
        if (self.organizer.selectedCompareActivityIndex < self.organizer.countOfActivities &&
            self.organizer.selectedCompareActivityIndex != idx) {
            NSUInteger toclear = [self.organizer filteredIndexForActivityIndex:self.organizer.selectedCompareActivityIndex];
            if (toclear!=NSNotFound) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:toclear inSection:indexPath.section]];
            }
        }
        self.organizer.selectedCompareActivityIndex = idx;
        self.organizer.hasCompareActivity = true;
    }

    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];

}

-(void)cellGrid:(GCCellGrid*)cell didSelectLeftButtonAt:(NSIndexPath*)indexPath{
    self.activityForAction = [self activityForIndex:indexPath.row];

    if( self.activityForAction.skipAlways) {
        self.activityForAction.skipAlways = false;
    }else{
        self.activityForAction.skipAlways = true;
    }
    if( self.activityForAction.db ){
        [self.activityForAction saveToDb:self.activityForAction.db];
    }
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - UIContextMenuInteractionDelegate

-(UIContextMenuConfiguration*)tableView:(UITableView *)tableView contextMenuConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath point:(CGPoint)point API_AVAILABLE(ios(13.0)){
    if( @available( iOS 13.0, *)){
        return [UIContextMenuConfiguration configurationWithIdentifier:nil
                                                       previewProvider:^(){
            GCActivity * activity = [self.organizer activityForIndex:[self.organizer activityIndexForFilteredIndex:indexPath.row]];
            
            GCActivityPreviewingViewController * preview = [[[GCActivityPreviewingViewController alloc] initWithNibName:nil bundle:nil] autorelease];
            preview.activity = activity;
            
            preview.preferredContentSize = CGSizeMake(0., self.view.frame.size.height*0.75);
            return preview;
        }
                                                        actionProvider:^(NSArray<UIMenuElement *> *suggestedActions){
            UIAction * open = [UIAction actionWithTitle:@"Open" image:nil identifier:nil handler:^(UIAction * action){
                GCActivity * activity = [self.organizer activityForIndex:[self.organizer activityIndexForFilteredIndex:indexPath.row]];
                [GCAppGlobal focusOnActivityId:activity.activityId];
            }];
            return [UIMenu menuWithTitle:@"" children:@[open]];
        }];
    }else{
        return nil;
    }
}

@end
