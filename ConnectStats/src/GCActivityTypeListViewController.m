//  MIT Licence
//
//  Created on 02/12/2013.
//
//  Copyright (c) 2013 Brice Rosenzweig.
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

@import Flurry_iOS_SDK;

#import "GCActivityTypeListViewController.h"
#import "GCAppGlobal.h"
#import "GCViewIcons.h"
#import "GCViewConfig.h"
#import "GCWebConnect+Requests.h"
#import "GCActivityType.h"

@interface GCActivityTypeListViewController ()

@end

@implementation GCActivityTypeListViewController

-(void)dealloc{
    [_activity release];
    [_types release];

    [super dealloc];
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //GCActivityTypes * manager = [GCAppGlobal activityTypes];
    // FIXME:
    //self.types = manager.types;

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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return (self.types).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GCCellGrid * cell = [GCCellGrid cellGrid:tableView];

    GCActivityType * holder = (self.types)[indexPath.row];

    [cell setupForRows:1 andCols:1];
    UIImage * icon = [GCViewIcons activityTypeColoredIconFor:holder.key];
    [cell setIconImage:icon];
    SEL attr = @selector(attributeBold16);
    /*
    if ([holder.activityTypeParent isEqualToString:@"all"]) {
        [GCViewConfig setupGradient:cell ForActivity:holder.activityTypeDetail];
    }else{
        attr = @selector(attributeBold14);
        [GCViewConfig setupGradientForDetails:cell];
    }*/

    [cell labelForRow:0 andCol:0].attributedText = [GCViewConfig attributedString:holder.description attribute:attr];
    return cell;
}

@end
