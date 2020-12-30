//  MIT Licence
//
//  Created on 05/11/2012.
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

#import "GCTestUICellsViewController.h"
#import "GCCellGrid+Templates.h"
#import "GCFormattedField.h"
#import "GCViewConfig.h"
#import "GCAppGlobal.h"
#import "GCHistoryAggregatedActivityStats.h"
#import "GCTestIconsCell.h"
#import "GCTestUISamples.h"

@interface GCTestUICellsViewController ()
@property (nonatomic,retain) GCTestUISamples * samples;
@end

@implementation GCTestUICellsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.samples = [[[GCTestUISamples alloc] init] autorelease];
    }
    return self;
}

-(void)dealloc{
    [_samples release];
    [_cells release];
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Refresh",nil)
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(refresh)] autorelease];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Dark/Light",nil)
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(darkLight)] autorelease];

}

-(void)darkLight {
    if( self.overrideUserInterfaceStyle == UIUserInterfaceStyleDark ){
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }else{
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
    }
    [GCAppGlobal setUserInterfaceStyle:self.overrideUserInterfaceStyle];
    [self refresh];
}
-(void)refresh{
    dispatch_sync([GCAppGlobal worker],^(){
        [self buildSamples];
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            [[self tableView] reloadData];
        });
        
    });
}

-(void)buildSamples{
    self.cells = [self.samples gridCellSamples];
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
    return [self.cells count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section < [self.cells count]) {
        return [[self.cells objectAtIndex:section] count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self holderForIndexPath:indexPath].cell;
}

-(GCTestUISampleCellHolder*)holderForIndexPath:(NSIndexPath*)indexPath{
    if ([indexPath section] < [self.cells count]) {
        NSArray * ar = [self.cells objectAtIndex:[indexPath section]];
        if ([indexPath row] < [ar count]) {
            GCTestUISampleCellHolder * holder = ar[indexPath.row];
            return holder;
        }
    }
    return nil;

}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self holderForIndexPath:indexPath].height;

}

@end
