//  MIT Licence
//
//  Created on 26/02/2016.
//
//  Copyright (c) 2016 Brice Rosenzweig.
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

#import "GCCellEntryFieldChoiceViewController.h"
#import "GCFieldsForCategory.h"
#import "GCTableHeaderFieldsCategory.h"
#import "GCFields.h"

@interface GCCellEntryFieldChoiceViewController ()
@property (nonatomic,retain) NSArray<GCField*> *choices;
@property (nonatomic,retain) GCField * currentChoice;
@property (nonatomic,assign) NSObject<GCEntryFieldDelegate>*entryDelegate;
@property (nonatomic,retain) NSArray<GCFieldsForCategory*> * fieldOrder;



@end
@implementation GCCellEntryFieldChoiceViewController

+(GCCellEntryFieldChoiceViewController*)fieldChoiceAmong:(NSArray<GCField*>*)fields
                                           currentChoice:(GCField*)current
                                            withDelegate:(NSObject<GCEntryFieldDelegate>*)delegate{

    GCCellEntryFieldChoiceViewController * rv = [[[GCCellEntryFieldChoiceViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    if (rv) {
        rv.choices = fields;
        rv.entryDelegate = delegate;
        rv.currentChoice = current;
        rv.fieldOrder = [GCFields categorizeAndOrderFields:fields forActivityType:nil];
    }
    return rv;
}

-(void)dealloc{
    [_choices release];
    [_currentChoice release];
    [_fieldOrder release];
    [super dealloc];
}
-(NSArray<GCField*>*)fieldsForSection:(NSInteger)section{
    if (section < self.fieldOrder.count) {
        GCFieldsForCategory * sub = self.fieldOrder[section];
        return sub.fields;
    }
    return  nil;
}
-(NSString*)categoryNameForSection:(NSInteger)section{
    if (section < self.fieldOrder.count) {
        GCFieldsForCategory * sub = _fieldOrder[section];
        return sub.category;
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.fieldOrder.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray * fields = [self fieldsForSection:section];
    return fields.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GCCellGrid * cell = [GCCellGrid gridCell:tableView];
    [cell setupForRows:1 andCols:1];
    NSArray * fields = [self fieldsForSection:indexPath.section];
    [cell labelForRow:0 andCol:0].text = [fields[indexPath.row] displayName];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSString * category = [self categoryNameForSection:section];
    return [GCTableHeaderFieldsCategory tableView:tableView viewForHeaderCategory:category];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    NSString * category = [self categoryNameForSection:section];
    return [GCTableHeaderFieldsCategory tableView:tableView heightForHeaderCategory:category];
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self categoryNameForSection:section];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray * fields = [self fieldsForSection:indexPath.section];
    self.currentChoice = fields[indexPath.row];
    [self.entryDelegate cellWasChanged:self];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
