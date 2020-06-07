//  MIT Licence
//
//  Created on 22/10/2012.
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

#import "GCTestUIGraphViewController.h"
//#import "GCTestSampleDataSource.h"
#import "GCAppGlobal.h"
#import "GCHistoryFieldDataSerie.h"
#import "GCHistoryFieldDataSerie+Test.h"
#import "GCViewSwimStrokeColors.h"
//#import "GCSimpleGraphCachedDataSource+Templates.h"
#import "GCFields.h"
//#import "GCActivity+Import.h"
//#import "GCTrackStats.h"
@import RZExternalTestUtils;
#import "GCTestUISamples.h"

enum uiTestSection {
    uiTestSectionGraph = 0,
    uiTestSectionEnd
};

#pragma mark - GCTestUIGraphViewController

@interface GCTestUIGraphViewController ()
@property (nonatomic,retain) FBSnapshotTestController * snapshotTestController;
@property (nonatomic,retain) GCTestUISamples * samples;
@property (nonatomic,retain) NSArray * dataSourcesCached;
@end

@implementation GCTestUIGraphViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.samples = [[[GCTestUISamples alloc] init] autorelease];
        self.dataSourcesCached = @[];
    }
    return self;
}
-(void)dealloc{
    [_dataSourcesCached release];
    [_samples release];
    [_snapshotTestController release];
    [super dealloc];
}

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{

}
-(NSArray*)dataSources{
    return self.dataSourcesCached;
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Refresh",nil) style:UIBarButtonItemStylePlain target:self action:@selector(refresh)] autorelease];
}

-(void)buildSamples{
    self.dataSourcesCached = [self.samples dataSourceSamples];
}

-(void)refresh{
    dispatch_sync([GCAppGlobal worker],^(){
        [self buildSamples];

        dispatch_async(dispatch_get_main_queue(), ^(){
            [[self tableView] reloadData];
        });
        
    });
}
                
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return uiTestSectionEnd;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == uiTestSectionGraph) {
        return [self.dataSources count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = nil;
    if ([indexPath section] == uiTestSectionGraph) {
        GCCellSimpleGraph * gcell = (GCCellSimpleGraph*)[tableView dequeueReusableCellWithIdentifier:@"GCGraph"];
        if (gcell == nil) {
            gcell = [[[GCCellSimpleGraph alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GCGraph"] autorelease];
        }
        GCTestUISampleDataSourceHolder * holder = self.dataSources[indexPath.row];
        [gcell setDataSource:holder.source andConfig:holder.source];
        if( holder.source.requiresLegend ){
            gcell.legend = true;
        }
        cell = gcell;
    }

    // Configure the cell...

    return cell ?: [GCCellGrid gridCell:tableView];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == uiTestSectionGraph) {
        GCSimpleGraphViewController * graphViewController = [[GCSimpleGraphViewController alloc] init];
        [self.navigationController pushViewController:graphViewController animated:YES];
        [self.navigationController setNavigationBarHidden:NO animated:YES];

        GCTestUISampleDataSourceHolder * holder = self.dataSources[indexPath.row];

        [graphViewController.graphView setDataSource:holder.source];
        [graphViewController.graphView setDisplayConfig:holder.source];
        [graphViewController release];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([indexPath section]==uiTestSectionGraph){
        return 150.;
    }
    return 58.;
}

@end
