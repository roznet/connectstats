//  MIT Licence
//
//  Created on 26/10/2014.
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

#import "TSSessionListViewController.h"
#import "TSAppGlobal.h"
#import "TSTennisOrganizer.h"
#import "TSTennisSession+Cells.h"

@interface TSSessionListViewController ()

@property (nonatomic,retain) NSArray * sessions;
@property (nonatomic,retain) TSTennisSession * pendingDelete;

@end

@implementation TSSessionListViewController

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notification:) name:kNotifyOrganizerSessionChanged object:nil];
}

-(void)notification:(id)sender{
    self.sessions = [[TSAppGlobal organizer] sessions];
    self.pendingDelete = nil;

    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    self.sessions = [[TSAppGlobal organizer] sessions];
    self.pendingDelete = nil;
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
    return self.sessions.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GCCellGrid * rv = [GCCellGrid gridCell:tableView];
    rv.delegate = self;
    [self.sessions[indexPath.row] setupSummary:rv];
    return rv;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.sessionListDelegate sessionList:self didSelect:self.sessions[indexPath.row]];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.sessions[indexPath.row] summaryCellHeight];
}

-(void)cellGrid:(GCCellGrid *)cell didSelectLeftButtonAt:(NSIndexPath *)indexPath{

}
-(void)cellGrid:(GCCellGrid *)cell didSelectRightButtonAt:(NSIndexPath *)indexPath{
    self.pendingDelete = self.sessions[indexPath.row];
    [[UIAlertController simpleConfirmWithTitle:NSLocalizedString(@"Delete Session", @"Delete Alert")
                                      message:NSLocalizedString(@"Are you sure you want to delete this session", @"Delete Alert") action:^(){
                                          if (self.pendingDelete) {
                                              [[TSAppGlobal organizer] deleteSession:self.pendingDelete];
                                          }
                                          self.pendingDelete = nil;

                                      }] show];

}

@end
