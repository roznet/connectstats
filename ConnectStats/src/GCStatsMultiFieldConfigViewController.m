//  MIT License
//
//  Created on 11/07/2020 for ConnectStats
//
//  Copyright (c) 2020 Brice Test User
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



#import "GCStatsMultiFieldConfigViewController.h"
#import "GCStatsMultiFieldViewControllerConsts.h"

@interface GCStatsMultiFieldConfigViewController2 ()

@end

@implementation GCStatsMultiFieldConfigViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
        
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = RZReturnAutorelease([[UIBarButtonItem alloc]
                                                                  initWithTitle:NSLocalizedString(@"Done", @"Cell Entry Button")
                                                                  style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(doneEditing:)]
                                                                 );
}

-(void)doneEditing:(UIButton*)button{
    NSLog(@"DONE");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return GC_SECTION_END;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GCCellGrid * cell = [GCCellGrid cellGrid:tableView];
    [cell setupForRows:1 andCols:2];
    [cell labelForRow:0 andCol:0].text = nil;
    
    
    return cell;
}


@end
