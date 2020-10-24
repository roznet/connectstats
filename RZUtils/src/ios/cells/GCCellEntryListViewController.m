//  MIT Licence
//
//  Created on 01/01/2013.
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

#import "GCCellEntryListViewController.h"
#import "GCCellGrid.h"
#import "RZViewConfig.h"
#import <RZUtils/RZMacros.h>

@interface GCCellEntryListViewController ()

@end

@implementation GCCellEntryListViewController


+(GCCellEntryListViewController*)entryListViewController:(NSArray*)theChoices selected:(NSUInteger)achoice{
    GCCellEntryListViewController * rv = RZReturnAutorelease([[GCCellEntryListViewController alloc] initWithStyle:UITableViewStylePlain]);
    if (rv) {
        rv.choices = theChoices;
        if (achoice <= theChoices.count) {
            rv.selected = achoice;
        }else{
            rv.selected = 0;
        }
    }
    return rv;
}
#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_choices release];
    [super dealloc];
}
#endif

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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return (self.choices).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GCCellGrid *cell = [GCCellGrid gridCell:tableView];

    if (self.subtext) {
        [cell setupForRows:2 andCols:1];
    }else{
        [cell setupForRows:1 andCols:1];
    }
    id choice = _choices[indexPath.row];
    if ([choice isKindOfClass:[NSString class]]) {
        [cell labelForRow:0 andCol:0].text= choice;
    }else if ([choice isKindOfClass:[NSAttributedString class]]){
        [cell labelForRow:0 andCol:0].attributedText = choice;
    }

    id sub = (self.subtext && indexPath.row < self.subtext.count) ? self.subtext[indexPath.row] : nil;
    if (sub && [sub isKindOfClass:[NSString class]]) {
        [cell labelForRow:1 andCol:0].text = sub;
    }else if(sub && [sub isKindOfClass:[NSAttributedString class]]){
        [cell labelForRow:1 andCol:0].attributedText = sub;
    }
    [cell setIconImage:[RZViewConfig checkMarkImage:(indexPath.row == _selected)]];
    cell.iconPosition = gcIconPositionLeft;
    if( self.cellBackgroundColor ){
        cell.backgroundColor = self.cellBackgroundColor;
    }
    if( self.textPrimaryColor){
        [cell labelForRow:0 andCol:0].textColor = self.textPrimaryColor;
    }
    if( self.textSecondaryColor && self.subtext ){
        [cell labelForRow:1 andCol:0].textColor = self.textSecondaryColor;
    }
    if( self.selectedTextColor && indexPath.row == _selected){
        [cell labelForRow:0 andCol:0].textColor = self.selectedTextColor;
        if( [choice isKindOfClass:[NSAttributedString class]] ){
            NSMutableAttributedString * changed = RZReturnAutorelease([[NSMutableAttributedString alloc] initWithAttributedString:choice]);
            [changed addAttribute:NSForegroundColorAttributeName value:self.selectedTextColor range:NSMakeRange(0,changed.length)];
            [cell labelForRow:0 andCol:0].attributedText = changed;
        }
    }
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selected = indexPath.row;
    [_entryFieldDelegate cellWasChanged:self];
    if( self.entryFieldCompletion ){
        self.entryFieldCompletion(self);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setIndexPath:(NSIndexPath *)indexPath{
    self.identifierInt = indexPath.section*100 + indexPath.row;
}
-(NSIndexPath*)indexPath{
    NSUInteger section = self.identifierInt/100;
    NSUInteger row     = self.identifierInt%100;

    return [NSIndexPath indexPathForItem:row inSection:section];
}

@end
