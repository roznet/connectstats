//  MIT Licence
//
//  Created on 26/07/2013.
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

#import "GCStatsGraphOptionViewController.h"
#import "GCStatsMultiFieldGraphViewController.h"
#import "GCCellGrid+Templates.h"
#import "GCFormattedFieldText.h"
#import "GCFields.h"
#import "GCHistoryFieldDataSerie.h"
#import "GCFieldsForCategory.h"

#define GC_SECTION_MAIN 0
#define GC_SECTION_END  1

#define GC_ROW_MATURITY 0
#define GC_ROW_XFIELD   1
#define GC_ROW_FIELD    2
#define GC_ROW_END      2

@interface GCStatsGraphOptionViewController ()

@end

@implementation GCStatsGraphOptionViewController
-(void)dealloc{
    [_graphViewController release];
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return GC_SECTION_END;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return GC_ROW_END;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GCCellGrid * cell = [GCCellGrid gridCell:tableView];
    [cell setupForRows:1 andCols:1];
    if (indexPath.row== GC_ROW_MATURITY) {
        NSString * val = [(self.graphViewController).maturityButton  currentFromDateChoice];
        GCFormattedFieldText * field = [GCFormattedFieldText formattedFieldText:@"Look back" value:val forSize:16.];
        [cell labelForRow:0 andCol:0].attributedText = [field attributedString];
    }else if (indexPath.row == GC_ROW_XFIELD){
        NSString * val = [self.graphViewController.x_field displayName];
        GCFormattedFieldText * field = [GCFormattedFieldText formattedFieldText:@"XField" value:val forSize:16.];
        [cell labelForRow:0 andCol:0].attributedText = [field attributedString];
    }else if (indexPath.row == GC_ROW_FIELD){
        NSString * val = [self.graphViewController.scatterStats.config.activityField displayName];
        GCFormattedFieldText * field = [GCFormattedFieldText formattedFieldText:@"Field" value:val forSize:16.];
        [cell labelForRow:0 andCol:0].attributedText = [field attributedString];
    }

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == GC_ROW_MATURITY) {
        GCCellEntryListViewController * entry = [[[GCCellEntryListViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
        NSArray * choices = [(self.graphViewController).maturityButton fromDateChoices];
        NSString * cur = [(self.graphViewController).maturityButton currentFromDateChoice];
        entry.choices = choices;
        NSUInteger selected = 0;
        for (selected = 0; selected<choices.count; selected++) {
            if ([cur isEqualToString:choices[selected]]) {
                break;
            }
        }
        entry.selected = selected;
        [entry setIndexPath:indexPath];
        entry.entryFieldDelegate = self;
        [self.navigationController pushViewController:entry animated:YES];
        [self.graphViewController notifyCallBack:self info:nil];
    }else if (indexPath.row==GC_ROW_XFIELD){
        NSArray * fieldOrder = [self fieldOrder];
        NSMutableArray * nice = [NSMutableArray arrayWithCapacity:fieldOrder.count];
        NSUInteger i = 0;
        NSUInteger selected = 0;
        for (GCField * field in fieldOrder) {
            NSString * display = field.displayName;
            [nice addObject:display];
            if ([field isEqualToField:self.graphViewController.x_field]) {
                selected = i;
            }
            i++;
        }
        GCCellEntryListViewController * entry = [[[GCCellEntryListViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
        entry.selected = selected;
        [entry setIndexPath:indexPath];
        entry.choices = nice;
        entry.entryFieldDelegate = self;
        [self.navigationController pushViewController:entry animated:YES];
        [self.graphViewController notifyCallBack:self info:nil];
    }
}

-(NSArray<GCField*>*)fieldOrder{
    NSMutableArray * rv = [NSMutableArray array];
    for (id obj in [self.graphViewController.fieldOrder arrayFlattened]) {
        if( [obj isKindOfClass:[GCField class]]){
            GCField * field = (GCField*)obj;
            [rv addObject:field];
        }else if( [obj isKindOfClass:[GCFieldsForCategory class]]){
            GCFieldsForCategory * fieldsForCategory = (GCFieldsForCategory*)obj;
            for (GCField * field in fieldsForCategory.fields) {
                [rv addObject:field];
            }
        }
    }
    return rv;
}
// hard code type here because need to use indexpath
-(void)cellWasChanged:(GCCellEntryListViewController*)cell{
    NSIndexPath * indexPath = [cell indexPath];
    if (indexPath.row==GC_ROW_MATURITY) {
        NSString * choice = (cell.choices)[cell.selected];
        [(self.graphViewController).maturityButton setCurrentFromDateChoice:choice];
    }else if (indexPath.row == GC_ROW_XFIELD){
        NSArray<GCField*>*fieldOrder = self.fieldOrder;
        if( cell.selected < fieldOrder.count){
            GCField * xfield= fieldOrder[cell.selected];
            self.graphViewController.x_field = xfield;
            [self.graphViewController configureGraph];
        }
        [self.tableView reloadData];
    }
}

-(UINavigationController*)baseNavigationController{
    return self.navigationController;
}
-(UINavigationItem*)baseNavigationItem{
    return self.navigationController.navigationItem;
}

@end
