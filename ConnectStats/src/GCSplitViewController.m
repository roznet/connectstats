//  MIT Licence
//
//  Created on 26/11/2012.
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

#import "GCSplitViewController.h"
#import "GCAppGlobal.h"
#import "GCSharingViewController.h"
#import "GCWebConnect+Requests.h"
@import RZExternal;

@interface GCSplitViewController ()

@property (nonatomic,retain) GCActivityListViewController * activityListViewController;
@property (nonatomic,retain) GCActivityDetailViewController * activityDetailViewController;
@property (nonatomic,retain) KalViewController * calendarViewController;
@property (nonatomic,retain) GCCalendarDataSource * calendarDataSource;
@property (nonatomic,retain) GCStatsMultiFieldViewController * fieldListViewController;
@property (nonatomic,retain) GCSettingsViewController * settingsViewController;

@end

@implementation GCSplitViewController

-(void)dealloc{
    [_activityDetailViewController release];
    [_activityListViewController release];
    [_calendarDataSource release];
    [_calendarViewController release];
    [_fieldListViewController release];
    [_settingsViewController release];
    
    [super dealloc];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _activityListViewController = [[GCActivityListViewController		alloc] init];
        _activityDetailViewController = [[GCActivityDetailViewController alloc] init];
        _activityListViewController.detailController = _activityDetailViewController;
        _calendarViewController = [[KalViewController alloc] init];
        _calendarDataSource = [[GCCalendarDataSource alloc] init];
        _calendarViewController.dataSource = _calendarDataSource;
        _calendarViewController.delegate = _calendarDataSource;
        _fieldListViewController = [[GCStatsMultiFieldViewController alloc] init];
        _settingsViewController = [[GCSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];

        UINavigationController *activityNav	= [[UINavigationController alloc] initWithRootViewController:_activityListViewController];
        UINavigationController *detailNav	= [[UINavigationController alloc] initWithRootViewController:_activityDetailViewController];

        (detailNav.navigationBar).titleTextAttributes = @{NSFontAttributeName:[GCViewConfig boldSystemFontOfSize:16.]};
        (activityNav.navigationBar).titleTextAttributes = @{NSFontAttributeName:[GCViewConfig boldSystemFontOfSize:16.]};

        UIBarStyle style = UIBarStyleDefault;

        activityNav.navigationBar.barStyle						= style;
        detailNav.navigationBar.barStyle						= style;

        [detailNav setNavigationBarHidden:NO animated:YES];
        [activityNav setNavigationBarHidden:NO animated:YES];

        _activityDetailViewController.navigationItem.leftBarButtonItem = self.displayModeButtonItem;

        self.viewControllers = @[activityNav,detailNav];
        self.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
        self.presentsWithGesture = true;
        [activityNav release];
        [detailNav release];
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [GCAppGlobal startSuccessful];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self startWorkflow];

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)updateBadge:(NSUInteger)count{
    
}
-(void)focusOnActivityAtIndex:(NSUInteger)aIdx{
    GCActivitiesOrganizer * organizer = [GCAppGlobal organizer];
    organizer.currentActivityIndex = aIdx;
    [_activityDetailViewController.navigationController popToRootViewControllerAnimated:YES];
    [_activityDetailViewController.navigationController setNavigationBarHidden:NO animated:YES];
    [_activityDetailViewController notifyCallBack:nil info:nil];
    [organizer notifyOnMainThread:NOTIFY_CHANGE];
    [_activityListViewController ipadSetupStatButton];

}

-(void)focusOnActivityId:(NSString*)aId{
    GCActivitiesOrganizer * organizer = [GCAppGlobal organizer];
    [organizer setCurrentActivityId:aId];
    [_activityDetailViewController notifyCallBack:nil info:nil];
    [_activityDetailViewController.navigationController popToRootViewControllerAnimated:YES];
    [_activityDetailViewController.navigationController setNavigationBarHidden:NO animated:YES];
    [_activityListViewController ipadSetupStatButton];
}
-(void)focusOnListWithFilter:(NSString*)aFilter{
    [_activityListViewController setupFilterForString:aFilter];
    [self focusOnActivityList];
}

-(void)focusOnStatsSummary{

}
-(void)focusOnActivityList{
    [self.viewControllers.firstObject  popToRootViewControllerAnimated:YES];
}

-(void)login{
    [_activityListViewController.navigationController popToRootViewControllerAnimated:YES];
    [[GCAppGlobal web] garminLogin];
    [_activityListViewController beginRefreshing];
    [_activityListViewController refreshData];
}
-(void)beginRefreshing{
    [_activityListViewController.navigationController popToRootViewControllerAnimated:YES];
    [_activityListViewController beginRefreshing];
}
-(void)logout{
    [_activityListViewController.navigationController popToRootViewControllerAnimated:YES];
    [[GCAppGlobal web] garminLogout];
    [_activityListViewController beginRefreshing];
}

-(void)startWorkflow{
    NSInteger last_version = [GCAppGlobal configGetInt:CONFIG_LAST_USED_VERSION defaultValue:0];
    if (last_version == 0) {
        NSString * msg = NSLocalizedString(@"Setup your service, enter your user name and password to start downloading your activities", @"Initial");

        [self presentSimpleAlertWithTitle:NSLocalizedString(@"Welcome", @"Welcome") message:msg];

        [GCAppGlobal configSet:CONFIG_LAST_USED_VERSION intVal:1];
        [GCAppGlobal saveSettings];
        [_activityListViewController.navigationController pushViewController:_settingsViewController animated:YES];
        [_settingsViewController showServices];
    }else{
        if ([[GCAppGlobal profile] profileRequireSetup]) {
            [_activityListViewController.navigationController pushViewController:_settingsViewController animated:YES];
            [_settingsViewController showServices];
        }
    }
}

-(UINavigationController*)currentNavigationController{
    return _activityDetailViewController.navigationController;
}
- (UISplitViewControllerDisplayMode)targetDisplayModeForActionInSplitViewController:(UISplitViewController *)svc {
#if __IPHONE_14_0
    if (svc.displayMode == UISplitViewControllerDisplayModeOneOverSecondary || svc.displayMode == UISplitViewControllerDisplayModeSecondaryOnly) {
        return UISplitViewControllerDisplayModeOneBesideSecondary;
    }
    return UISplitViewControllerDisplayModeSecondaryOnly;
#else
    if (svc.displayMode == UISplitViewControllerDisplayModePrimaryOverlay || svc.displayMode == UISplitViewControllerDisplayModePrimaryHidden) {
        return UISplitViewControllerDisplayModeAllVisible;
    }
    return UISplitViewControllerDisplayModePrimaryHidden;
#endif
}
@end
