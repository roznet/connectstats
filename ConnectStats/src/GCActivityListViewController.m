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

#import "GCActivityListViewController.h"
#import "GCActivitiesOrganizer.h"
#import "GCAppGlobal.h"
#import "GCViewConfig.h"
#import "GCActivitySearch.h"
#import "GCCellGrid+Templates.h"
#import "GCSplitViewController.h"
#import "GCViewIcons.h"
#import "GCActivityTypeListViewController.h"
#import "Flurry.h"
#import "GCWebConnect+Requests.h"
#import "GCCellActivity.h"
#import "GCActivityPreviewingViewController.h"
#import <RZExternal/RZExternal.h>

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

        self.refreshControl = RZReturnAutorelease([[UIRefreshControl alloc] init]);
        self.refreshControl.attributedTitle = nil;
        [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyCallBack:) name:kNotifySettingsChange object:nil];

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

-(void)deletedActivity{
    [self performSelectorOnMainThread:@selector(delayedEndRefreshing:) withObject:self waitUntilDone:NO];

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

-(NSArray*)processServiceError{
    NSMutableArray * errorsString = [NSMutableArray arrayWithCapacity:gcWebServiceEnd];
    gcWebService others[] = {gcWebServiceGarmin,gcWebServiceStrava,gcWebServiceSportTracks,gcWebServiceWithings,gcWebServiceBabolat};
    for (size_t i=0; i<5; i++) {
        gcWebService service = others[i];
        GCWebStatus status= [[GCAppGlobal web] statusForService:service];
        if ( status!= GCWebStatusOK) {
            [errorsString addObject:[NSString stringWithFormat:@"%@: %@",
                                     [[GCAppGlobal web] webServiceDescription:service],
                                     [[GCAppGlobal web] statusDescriptionForService:service]]];
            if (service == gcWebServiceGarmin) {
                NSString * lastName = [[GCAppGlobal organizer] lastGarminLoginUsername];
                NSString *username = [[GCAppGlobal profile] currentLoginNameForService:gcServiceGarmin];
                if (lastName && ![username isEqualToString:lastName] ) {
                    RZLog(RZLogError, @"Inconsistent username before=%@ now=%@", lastName, [[GCAppGlobal profile] currentLoginNameForService:gcServiceGarmin]);
                    NSString * extra = [NSString stringWithFormat:@"Inconsistent username before=%@ now=%@",
                                        lastName,
                                        [[GCAppGlobal profile] currentLoginNameForService:gcServiceGarmin]];
                    [errorsString addObject:extra];
                }
                if (![username isEqualToString:username.lowercaseString]) {
                    RZLog(RZLogError, @"Inconsistent case in username %@ try=%@?", username, [username lowercaseString]);
                    NSString * extra = [NSString stringWithFormat:@"Inconsistent case in username %@ try=%@?", username, username.lowercaseString];
                    [errorsString addObject:extra];
                }
            }
        }
    }
    if( errorsString.count == 0){
        if ([[GCAppGlobal web] lastError]) {
            [errorsString addObject:[[[GCAppGlobal web] lastError] localizedDescription]];
        }
    }
    // second loop because login resets status
    for (size_t i=0; i<5; i++) {
        gcWebService service = others[i];
        GCWebStatus status= [[GCAppGlobal web] statusForService:service];
        if (service == gcWebServiceGarmin) {
            if (status == GCWebStatusAccessDenied || status == GCWebStatusLoginFailed) {
                [[GCAppGlobal web] garminLogin];// will try again.
            }
        }
    }
    return errorsString;
}

-(void)reportServiceError{
    NSArray * errorsString = [self processServiceError];

    // Tested by turning off internet
    [self presentSimpleAlertWithTitle:NSLocalizedString(@"Error updating", @"Error") message:[errorsString componentsJoinedByString:@"\n"]];

}

-(void)updateRefreshControlTitle{
    if ((self.refreshControl).refreshing) {
        self.refreshControl.attributedTitle = RZReturnAutorelease([[NSAttributedString alloc] initWithString:[[GCAppGlobal web] currentDescription]]);
    }
}

-(void)notifyCallBack:(id)theParent{
    if ([[NSThread currentThread] isMainThread]) {
        [self.tableView reloadData];
        [self setupQuickFilterIcon];
    }else{
        [self performSelectorOnMainThread:@selector(notifyCallBack:) withObject:theParent waitUntilDone:NO];
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
        [self performSelectorOnMainThread:@selector(updateRefreshControlTitle) withObject:nil waitUntilDone:NO];
        if ([theInfo.stringInfo isEqualToString:NOTIFY_END]) {
            [self performSelectorOnMainThread:@selector(delayedEndRefreshing:) withObject:self waitUntilDone:NO];
            self.loginTries = 0;
        }else if ([theInfo.stringInfo isEqualToString:NOTIFY_ERROR]) {

            if ([GCAppGlobal web].status == GCWebStatusDeletedActivity) {
                [self performSelectorOnMainThread:@selector(deletedActivity) withObject:nil waitUntilDone:NO];
            }else{
                [self performSelectorOnMainThread:@selector(reportServiceError) withObject:nil waitUntilDone:NO];
                [self performSelectorOnMainThread:@selector(delayedEndRefreshing:) withObject:self waitUntilDone:NO];
            }
        }
    }
}

- (void)viewDidLoad
{
    RZLogTrace(@"");

    [super viewDidLoad];

    //self.tableView.backgroundColor = [GCViewConfig defaultBackgroundColor];

    self.navigationItem.titleView = self.titleLabel;

	self.search = RZReturnAutorelease([[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 280.0f, 44.0f)]);
	_search.barStyle					= UIBarStyleDefault;
	_search.delegate					= self;
	_search.autocorrectionType		= UITextAutocorrectionTypeNo;
	_search.autocapitalizationType	= UITextAutocapitalizationTypeNone;
    _search.placeholder              = NSLocalizedString(@"Search",@"SearchBar");

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.tableView.tableHeaderView = self.search;
        UIImage * imagel = [GCViewIcons tabBarIconFor:gcIconTabCalendar];
        UIImage * imager = [GCViewIcons tabBarIconFor:gcIconTabStatsIPad];
        UIImage * imagec = [GCViewIcons tabBarIconFor:gcIconTabSettings];

        self.navigationItem.rightBarButtonItem = RZReturnAutorelease([[UIBarButtonItem alloc] initWithImage:imager style:UIBarButtonItemStylePlain target:self action:@selector(ipadSelectStats)]);
         self.navigationItem.leftBarButtonItems = @[
                                                    RZReturnAutorelease([[UIBarButtonItem alloc] initWithImage:imagel style:UIBarButtonItemStylePlain target:self action:@selector(ipadSelectCalendar)]),
                                                   RZReturnAutorelease([[UIBarButtonItem alloc] initWithImage:imagec style:UIBarButtonItemStylePlain target:self action:@selector(ipadSelectSettings)])
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

-(void)setupQuickFilterIcon{
    // iPhone only will have day activities
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
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
    RZLogTrace(@"");

    //if 3DTouch:
    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)] &&  self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        RZLog(RZLogInfo, @"forceTouch Enabled");
        [self registerForPreviewingWithDelegate:self sourceView:self.view];
    }

    [super viewDidAppear:animated];

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
    [self performSelectorOnMainThread:@selector(refreshAfterFilterSetup:) withObject:nil waitUntilDone:NO];
}

-(UIImage*)imageForQuickFilter{
    return  self.quickFilter ? [GCViewIcons navigationIconFor:gcIconNavFilterSelected] : [GCViewIcons navigationIconFor:gcIconNavFilter];

}
#pragma mark - Refreshing

-(void)searchActivities{
    dispatch_async([GCAppGlobal worker], ^(){
        [GCAppGlobal searchAllActivities];
    });
}

-(void)beginRefreshing{
    if ([NSThread isMainThread]) {
        self.refreshControl.attributedTitle = [[[NSAttributedString alloc] initWithString:@""] autorelease];
        [self.tableView setContentOffset:CGPointMake(0, -self.tableView.contentInset.top-self.refreshControl.frame.size.height) animated:YES];
        [self.refreshControl beginRefreshing];
    }else{
        [self performSelectorOnMainThread:@selector(beginRefreshing) withObject:nil waitUntilDone:NO];
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
        [self performSelectorOnMainThread:@selector(delayedEndRefreshing:) withObject:aObj waitUntilDone:NO];
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
        //return [self tableView:tableView activityCellForRowAtIndexPath:indexPath];
        return [self tableView:tableView dayCellForRowAtIndexPath:indexPath];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView dayCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GCCellActivity * cell = [GCCellActivity activityCell:tableView];
    [cell setupForActivity:[self activityForIndex:indexPath.row]];
    return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView activityCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GCCellGrid * cell = [GCCellGrid gridCell:tableView];
    cell.delegate = self;
    gcViewActivityStatus status = gcViewActivityStatusNone;
    if (self.organizer.hasCompareActivity && [self.organizer activityIndexForFilteredIndex:indexPath.row]==self.organizer.selectedCompareActivityIndex) {
        status = gcViewActivityStatusCompare;
    }
    [cell setupSummaryFromActivity:[self activityForIndex:indexPath.row] width:tableView.frame.size.width status:status];
    cell.cellInset = [self insetForRowAtIndexPath:indexPath];
    cell.cellInsetSize = kCellDaySpacing;
	return cell;
}

-(gcCellInset)insetForRowAtIndexPath:(NSIndexPath*)indexPath{
    return gcCellInsetNone;
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
    CGFloat rv = 64.;

    GCActivity * act = [self activityForIndex:indexPath.row];
    if ([act.activityType isEqualToString:GC_TYPE_DAY]) {
        rv = kGCCellActivityDefaultHeight;
    }

    if ([self insetForRowAtIndexPath:indexPath]) {
        rv += kCellDaySpacing;
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
    [self performSelectorOnMainThread:@selector(refreshAfterFilterSetup:) withObject:aFilter waitUntilDone:NO];
}

-(void)refreshAfterFilterSetup:(NSString*)aFilter{
    if( [NSThread isMainThread]){
        [self.tableView reloadData];
        self.search.text = aFilter;
        [self.search setNeedsDisplay];
    }else{
        [self performSelectorOnMainThread:@selector(setupFilterForString:) withObject:aFilter waitUntilDone:NO];
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
        [GCAppGlobal configSet:CONFIG_ENABLE_DEBUG stringVal:CONFIG_ENABLE_DEBUG_ON];
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


    UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"More Actions", @"More Actions")
                                                                    message:nil
                                                             preferredStyle:UIAlertControllerStyleActionSheet];

    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"More Actions")
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction*action){

                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Ignore Activity", @"More Actions")
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction*action){
                                                  

                                              }]];
    
    if (self.tabBarController) {
        [self.tabBarController presentViewController:alert animated:YES completion:^(){
            [[NSNotificationCenter defaultCenter] postNotificationName:GCCellGridShouldHideMenu object:self];
        }];
    }else{
        alert.popoverPresentationController.sourceView = cell;
        CGRect rect = cell.frame;
        alert.popoverPresentationController.sourceRect = CGRectMake(rect.size.width, rect.size.height/2., 1, 1);
        [self presentViewController:alert animated:YES completion:^(){
            [[NSNotificationCenter defaultCenter] postNotificationName:GCCellGridShouldHideMenu object:self];
        }];
    }

}

#pragma mark - UIViewControllerPreviewingDelegate

-(UIViewController*)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location{
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:location];
    GCCellGrid * gridCell = [self.tableView cellForRowAtIndexPath:indexPath];
    GCActivity * activity = [self.organizer activityForIndex:[self.organizer activityIndexForFilteredIndex:indexPath.row]];

    GCActivityPreviewingViewController * preview = [[[GCActivityPreviewingViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    preview.activity = activity;

    preview.preferredContentSize = CGSizeMake(0., self.view.frame.size.height*0.75);
    previewingContext.sourceRect = gridCell.frame;

    return preview;
}

-(void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit{
    GCActivityPreviewingViewController * preview = nil;
    if ([viewControllerToCommit isKindOfClass:[GCActivityPreviewingViewController class]]) {
        preview = (GCActivityPreviewingViewController*)viewControllerToCommit;
    }
    [GCAppGlobal focusOnActivityId:preview.activity.activityId];
}
@end
