//  MIT Licence
//
//  Created on 19/12/2014.
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

#import "TSSplitViewController.h"
#import "TSTennisCourtViewController.h"
#import "TSSessionSetupTableViewController.h"
#import "TSReportListTableViewController.h"
#import "TSCourtReportViewController.h"
#import "TSPlotAnalysisTableViewController.h"

@interface TSSplitViewController ()

@property (nonatomic,retain) TSTennisCourtViewController * courtViewController;
@property (nonatomic,retain) TSSessionSetupTableViewController * sessionSetupViewController;
@property (nonatomic,retain) TSReportListTableViewController * reportViewController;
@property (nonatomic,retain) TSCourtReportViewController * courtReportViewController;
@property (nonatomic,retain) TSPlotAnalysisTableViewController * plotAnalysisViewController;
@property (nonatomic,retain) UINavigationController * displayNavigationController;

@end

@implementation TSSplitViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.courtViewController = [[TSTennisCourtViewController alloc] initWithNibName:nil bundle:nil];
        self.sessionSetupViewController = [[TSSessionSetupTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        self.reportViewController = [[TSReportListTableViewController alloc] initWithNibName:nil bundle:nil];
        self.courtReportViewController = [[TSCourtReportViewController alloc] initWithNibName:nil bundle:nil];
        self.plotAnalysisViewController = [[TSPlotAnalysisTableViewController alloc] initWithStyle:UITableViewStyleGrouped];

        UINavigationController * navSession = [[UINavigationController alloc] initWithRootViewController:self.sessionSetupViewController];
        //UINavigationController * navReport = [[UINavigationController alloc] initWithRootViewController:self.reportViewController];
        self.displayNavigationController = [[UINavigationController alloc] initWithRootViewController:self.courtViewController];
        self.displayNavigationController.navigationBarHidden = true;
        self.displayNavigationController.delegate = self;
        //UINavigationController * navPlotAnalysis = [[UINavigationController alloc] initWithRootViewController:self.plotAnalysisViewController];
        [self setViewControllers:@[ navSession, self.displayNavigationController]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (viewController==self.courtViewController) {
        self.displayNavigationController.navigationBarHidden = true;
    }else{
        self.displayNavigationController.navigationBarHidden = false;
    }
}

-(void)showRecord{
    [self.displayNavigationController popToRootViewControllerAnimated:YES];
}
-(void)showStats{
    [self.displayNavigationController popToRootViewControllerAnimated:YES];
    [self.displayNavigationController pushViewController:self.reportViewController animated:YES];
    self.displayNavigationController.navigationBarHidden = false;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
