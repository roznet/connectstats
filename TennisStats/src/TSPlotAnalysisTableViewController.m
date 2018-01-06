//  MIT Licence
//
//  Created on 07/12/2014.
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

#import "TSPlotAnalysisTableViewController.h"
#import "TSAppGlobal.h"
#import "TSTennisOrganizer.h"
#import "TSTennisSession.h"

@interface TSPlotAnalysisTableViewController ()
@property (nonatomic,retain) TSTennisSession * session;
@end

@implementation TSPlotAnalysisTableViewController

#pragma mark - Notifications

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.session detach:self];
}
-(void)sessionChangedCallback{
    [self changeSession:[[TSAppGlobal organizer] currentSession]];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}
-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}
-(void)changeSession:(TSTennisSession*)session{
    if (session!=self.session) {
        [self.session detach:self];
        self.session = session;
        [self.session attach:self];
    }
}

#pragma mark - View Controller

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(view) name:kNotifyOrganizerSessionChanged object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self changeSession:[[TSAppGlobal organizer] currentSession]];

    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GCCellSimpleGraph * cell = [GCCellSimpleGraph graphCell:tableView];

    GCSimpleGraphCachedDataSource * ds = [[GCSimpleGraphCachedDataSource alloc] init];

    GCStatsDataSerie * serie = [self.session.state pointsDataSerie];
    GCStatsDataSerie * games = [self.session.state gamesDataSerie];
    GCSimpleGraphDataHolder * holder = [GCSimpleGraphDataHolder dataHolder:serie type:gcGraphLine color:[UIColor blackColor] andUnit:[GCUnit unitForKey:@"dimensionless"]];

    GCSimpleGraphDataHolder * gamesH = [GCSimpleGraphDataHolder dataHolder:games type:gcGraphStep color:[UIColor colorWithRed:0.5 green:0. blue:0. alpha:0.3] andUnit:[GCUnit unitForKey:@"dimensionless"]];
    ds.series = [NSMutableArray arrayWithArray:@[ holder, gamesH]];
    ds.xUnit = [GCUnit unitForKey:@"second"];
    [cell setDataSource:ds andConfig:ds];


    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 256.;
}
/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
