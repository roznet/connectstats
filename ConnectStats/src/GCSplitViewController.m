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

@end

@implementation GCSplitViewController
@synthesize activityDetailViewController,activityListViewController,calendarViewController,calendarDataSource,fieldListViewController,settingsViewController;

-(void)dealloc{
    [activityDetailViewController release];
    [activityListViewController release];
    [calendarDataSource release];
    [calendarViewController release];
    [fieldListViewController release];
    [settingsViewController release];
    [super dealloc];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        activityListViewController = [[GCActivityListViewController		alloc] init];
        activityDetailViewController = [[GCActivityDetailViewController alloc] init];
        activityListViewController.detailController = activityDetailViewController;
        calendarViewController = [[KalViewController alloc] init];
        calendarDataSource = [[GCCalendarDataSource alloc] init];
        calendarViewController.dataSource = calendarDataSource;
        calendarViewController.delegate = calendarDataSource;
        fieldListViewController = [[GCStatsMultiFieldViewController alloc] init];
        settingsViewController = [[GCSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];

        ECSlidingViewController * detailSliding = [[ECSlidingViewController alloc] initWithNibName:nil bundle:nil];
        detailSliding.topViewController = activityDetailViewController;
        detailSliding.underLeftViewController = [[[GCSharingViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];

        UINavigationController *activityNav	= [[UINavigationController alloc] initWithRootViewController:activityListViewController];
        UINavigationController *detailNav	= [[UINavigationController alloc] initWithRootViewController:detailSliding];

        (detailNav.navigationBar).titleTextAttributes = @{NSFontAttributeName:[GCViewConfig boldSystemFontOfSize:16.]};
        (activityNav.navigationBar).titleTextAttributes = @{NSFontAttributeName:[GCViewConfig boldSystemFontOfSize:16.]};

        UIBarStyle style = UIBarStyleBlack;
        if ([GCViewConfig uiStyle]==gcUIStyleIOS7) {
            style = UIBarStyleDefault;
        }

        activityNav.navigationBar.barStyle						= style;
        detailNav.navigationBar.barStyle						= style;

        [detailNav setNavigationBarHidden:NO animated:YES];
        [activityNav setNavigationBarHidden:NO animated:YES];

        detailSliding.navigationItem.leftBarButtonItem = self.displayModeButtonItem;

        self.viewControllers = @[activityNav,detailNav];
        self.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;

        [activityNav release];
        [detailNav release];
        [detailSliding release];
        //self.maximumPrimaryColumnWidth = 320.;
        //self.minimumPrimaryColumnWidth = 320.;
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
    [activityDetailViewController.navigationController popToRootViewControllerAnimated:YES];
    [activityDetailViewController.navigationController setNavigationBarHidden:NO animated:YES];
    [activityDetailViewController notifyCallBack:nil info:nil];
    [organizer notifyOnMainThread:NOTIFY_CHANGE];
    [activityListViewController ipadSetupStatButton];

}

-(void)focusOnActivityId:(NSString*)aId{
    GCActivitiesOrganizer * organizer = [GCAppGlobal organizer];
    [organizer setCurrentActivityId:aId];
    [activityDetailViewController notifyCallBack:nil info:nil];
    [activityDetailViewController.navigationController popToRootViewControllerAnimated:YES];
    [activityDetailViewController.navigationController setNavigationBarHidden:NO animated:YES];
    [activityListViewController ipadSetupStatButton];
}
-(void)focusOnListWithFilter:(NSString*)aFilter{
    [activityListViewController setupFilterForString:aFilter];
    [self focusOnActivityList];
}

-(void)focusOnStatsSummary{

}
-(void)focusOnActivityList{
    [self.viewControllers.firstObject  popToRootViewControllerAnimated:YES];
}

-(void)login{
    [activityListViewController.navigationController popToRootViewControllerAnimated:YES];
    [[GCAppGlobal web] garminLogin];
    [activityListViewController beginRefreshing];
    [activityListViewController refreshData];
}
-(void)beginRefreshing{
    [activityListViewController.navigationController popToRootViewControllerAnimated:YES];
    [activityListViewController beginRefreshing];
}
-(void)logout{
    [activityListViewController.navigationController popToRootViewControllerAnimated:YES];
    [[GCAppGlobal web] garminLogout];
    [activityListViewController beginRefreshing];
}

-(void)startWorkflow{
    NSInteger last_version = [GCAppGlobal configGetInt:CONFIG_LAST_USED_VERSION defaultValue:0];
    if (last_version == 0) {
        NSString * msg = NSLocalizedString(@"Setup your service, enter your user name and password to start downloading your activities", @"Initial");

        [self presentSimpleAlertWithTitle:NSLocalizedString(@"Welcome", @"Welcome") message:msg];

        [GCAppGlobal configSet:CONFIG_LAST_USED_VERSION intVal:1];
        [GCAppGlobal saveSettings];
        [activityListViewController.navigationController pushViewController:settingsViewController animated:YES];
        [settingsViewController showServices];
    }else{
        if ([[GCAppGlobal profile] profileRequireSetup]) {
            [activityListViewController.navigationController pushViewController:settingsViewController animated:YES];
            [settingsViewController showServices];
        }
    }
}

-(UINavigationController*)currentNavigationController{
    return activityDetailViewController.navigationController;
}
- (UISplitViewControllerDisplayMode)targetDisplayModeForActionInSplitViewController:(UISplitViewController *)svc {
    if (svc.displayMode == UISplitViewControllerDisplayModePrimaryOverlay || svc.displayMode == UISplitViewControllerDisplayModePrimaryHidden) {
        return UISplitViewControllerDisplayModeAllVisible;
    }
    return UISplitViewControllerDisplayModePrimaryHidden;
}
@end
