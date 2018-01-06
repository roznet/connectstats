//  MIT Licence
//
//  Created on 27/12/2014.
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

#import "TSCloudSessionListTableViewController.h"
#import "TSAppGlobal.h"
#import "TSCloudOrganizer.h"
#import "TSCloudTypes.h"
#import "CKRecord+TennisSession.h"

@interface TSCloudSessionListTableViewController ()

@end

@implementation TSCloudSessionListTableViewController

-(TSCloudSessionListTableViewController*)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        TSCloudOrganizer * cloud = [TSAppGlobal cloud];
        [cloud attach:self];
        [cloud fetchNewSessions];
    }
    return self;
}
-(void)dealloc{
    [[TSAppGlobal cloud] detach:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return [[TSAppGlobal cloud] listSessions].count;
}

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GCCellGrid * rv = [GCCellGrid gridCell:tableView];
    [rv setupForRows:3 andCols:2];
    CKRecord * record = [[TSAppGlobal cloud] listSessions][indexPath.row];

    [rv labelForRow:0 andCol:1].attributedText = [RZViewConfig attributedString:[record scoreDescription]
                                                                      attribute:@selector(attribute16)];

    [rv labelForRow:1 andCol:1].attributedText =[RZViewConfig attributedString:[record startTimeDescription]
                                                                     attribute:@selector(attribute14)];

    [rv labelForRow:0 andCol:0].attributedText = [RZViewConfig attributedString:[record playerDescription]
                                                                      attribute:@selector(attribute16)];
    [rv labelForRow:1 andCol:0].attributedText = [RZViewConfig attributedString:[record opponentDescription]
                                                                      attribute:@selector(attribute16)];

    [rv labelForRow:2 andCol:0].attributedText = [RZViewConfig attributedString:[record userNameDescription]
                                                                      attribute:@selector(attribute14Gray)];
    return rv;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 72.;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CKRecord * record = [[TSAppGlobal cloud] listSessions][indexPath.row];
    [[TSAppGlobal cloud] retrieveSessionFromRecord:record completion:^(TSTennisSession * session, NSError * error){
        [self.navigationController popToRootViewControllerAnimated:true];
    }];

}
@end
