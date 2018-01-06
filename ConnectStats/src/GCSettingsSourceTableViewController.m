//  MIT Licence
//
//  Created on 14/06/2015.
//
//  Copyright (c) 2015 Brice Rosenzweig.
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

#import "GCSettingsSourceTableViewController.h"
#import "GCAppGlobal.h"
#import "GCViewConfig.h"

@interface GCSettingsSourceTableViewController ()
@property (nonatomic,retain) NSArray * sources;
@end

@implementation GCSettingsSourceTableViewController
-(void)dealloc{
    [_sources release];
    [super dealloc];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self notifyCallBack:nil info:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    self.sources = [[GCAppGlobal profile] availableSources];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.sources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GCCellGrid * cell = [GCCellGrid gridCell:tableView];
    [cell setupForRows:2 andCols:1];
    NSString * source = [[GCAppGlobal profile] sourceName:self.sources[indexPath.row]];
    BOOL current = false;
    if ([[[GCAppGlobal profile] currentSource] isEqualToString:self.sources[indexPath.row]]) {
        current = true;
    }
    [cell labelForRow:0 andCol:0].attributedText = [GCViewConfig attributedString:source attribute:current?@selector(attributeBold16):@selector(attribute16)];
    if (current) {
        [cell labelForRow:1 andCol:0 ].attributedText =[GCViewConfig attributedString:NSLocalizedString(@"Current Source", @"Healthkit Source")
                                                                            attribute:@selector( attribute14Gray)];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * identifier = self.sources[indexPath.row];
    [[GCAppGlobal profile] setCurrentSource:identifier];
    [GCAppGlobal saveSettings];
    [tableView reloadData];
}

@end
