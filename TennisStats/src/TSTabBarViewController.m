//  MIT Licence
//
//  Created on 22/10/2014.
//
//  Copyright (c) 2014 Brice Rosenzweig.
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

#import "TSTabBarViewController.h"
#import "TSTennisCourtViewController.h"
#import "TSSessionSetupTableViewController.h"
#import "TSReportListTableViewController.h"
#import "TSCourtReportViewController.h"
#import "TSPlotAnalysisTableViewController.h"

@interface TSTabBarViewController ()

@property (nonatomic,retain) TSTennisCourtViewController * courtViewController;
@property (nonatomic,retain) TSSessionSetupTableViewController * sessionSetupViewController;
@property (nonatomic,retain) TSReportListTableViewController * reportViewController;
@property (nonatomic,retain) TSCourtReportViewController * courtReportViewController;
@property (nonatomic,retain) TSPlotAnalysisTableViewController * plotAnalysisViewController;
@property (nonatomic,retain) TSSessionListViewController * sessionListViewController;
@end

@implementation TSTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.courtViewController = [[TSTennisCourtViewController alloc] initWithNibName:nil bundle:nil];
    self.sessionSetupViewController = [[TSSessionSetupTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    self.reportViewController = [[TSReportListTableViewController alloc] initWithNibName:nil bundle:nil];
    self.courtReportViewController = [[TSCourtReportViewController alloc] initWithNibName:nil bundle:nil];
    self.plotAnalysisViewController = [[TSPlotAnalysisTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    self.sessionListViewController = [[TSSessionListViewController alloc] initWithStyle:UITableViewStyleGrouped];

    UIImage * courtImage = [UIImage imageNamed:@"1088-tennis-ball"];
    UIImage * tableImage = [UIImage imageNamed:@"1099-list-1"];
    UIImage * reportImage = [UIImage imageNamed:@"1041-count"];
    UIImage * courtReportImage = [UIImage imageNamed:@"964-game-plan"];
    UIImage * plotImage = [UIImage imageNamed:@"858-line-chart"];
    UIImage * clipboardImage = [UIImage imageNamed:@"809-clipboard"];

    UINavigationController * navList = [[UINavigationController alloc] initWithRootViewController:self.sessionListViewController];
    UINavigationController * navSession = [[UINavigationController alloc] initWithRootViewController:self.sessionSetupViewController];
    UINavigationController * navReport = [[UINavigationController alloc] initWithRootViewController:self.reportViewController];
    UINavigationController * navCourtReport = [[UINavigationController alloc] initWithRootViewController:self.courtReportViewController];
    UINavigationController * navPlotAnalysis = [[UINavigationController alloc] initWithRootViewController:self.plotAnalysisViewController];

    self.courtViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Record" image:courtImage tag:0];
    navSession.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Current" image:clipboardImage tag:0];
    navReport.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Report" image:reportImage tag:0];
    navCourtReport.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Court" image:courtReportImage tag:0];
    navPlotAnalysis.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Plots" image:plotImage tag:0];
    navList.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Sessions" image:tableImage tag:0];
    self.viewControllers = @[  navSession,  self.courtViewController, navReport, navPlotAnalysis,  navCourtReport, navList ];
    self.delegate =self;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    if (viewController == self.courtViewController) {
        self.tabBar.hidden = YES;
    }else{
        self.tabBar.hidden = NO;
    }
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    return TRUE;
}

@end
