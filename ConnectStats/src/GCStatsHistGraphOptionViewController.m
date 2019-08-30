//  MIT Licence
//
//  Created on 22/02/2016.
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

#import "GCStatsHistGraphOptionViewController.h"
#import "GCStatsHistGraphViewController.h"

#define GC_SECTION_MAIN     0
#define GC_SECTION_END      1


#define GC_ROW_GRAPH_TYPE   0
#define GC_ROW_FIELD        1
#define GC_ROW_X_FIELD      2

@interface GCStatsHistGraphOptionViewController ()

@property (nonatomic,retain) GCStatsHistGraphConfig * editedConfig;
@property (nonatomic,retain) RZTableIndexRemap * remap;

@end
@implementation GCStatsHistGraphOptionViewController

-(instancetype)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        self.remap = [RZTableIndexRemap tableIndexRemap];
        [self.remap addSection:0 withRows:@[@(GC_ROW_GRAPH_TYPE)]];
        [self.remap addSection:1 withRows:@[@(GC_ROW_FIELD), @(GC_ROW_X_FIELD)]];
    }
    return self;
}

-(void)dealloc{
    [_editedConfig release];
    [_viewController release];
    [_editedConfig release];
    [_remap release];

    [super dealloc];
}

-(GCStatsHistGraphConfig*)config{
    return self.editedConfig ?: self.viewController.config;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.remap.numberOfSections;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  [self.remap numberOfRowsInSection:section];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPathI{
    NSIndexPath * indexPath = [self.remap remap:indexPathI];

    GCCellGrid * gridCell = [GCCellGrid gridCell:tableView];
    if (GC_ROW_FIELD == indexPath.row) {
        [gridCell setupForRows:1 andCols:1];
        [gridCell labelForRow:0 andCol:0].text = [self.config.fieldConfig.activityField displayName];
    }else if (GC_ROW_X_FIELD == indexPath.row){
        [gridCell setupForRows:1 andCols:1];
        [gridCell labelForRow:0 andCol:0].text = [self.config.fieldConfig.x_activityField displayName];
    }else if (GC_ROW_GRAPH_TYPE == indexPath.row){
        [gridCell setupForRows:1 andCols:1];
        NSArray * dn = [GCStatsHistGraphConfig graphTypeDisplayNames];
        [gridCell labelForRow:0 andCol:0].text = dn[self.config.graphType];
    }
    return gridCell;
}


-(void)cellWasChanged:(id<GCEntryFieldProtocol>)cell{
    BOOL changed = false;
    GCCellEntryListViewController * lv = RZDynamicCast(cell, GCCellEntryListViewController);
    GCCellEntryFieldChoiceViewController * vc = RZDynamicCast(cell, GCCellEntryFieldChoiceViewController);

    NSInteger identifierInt = [cell identifierInt];

    if (identifierInt == GC_ROW_FIELD && vc) {
        self.config.fieldConfig.activityField = vc.currentChoice;
        changed = true;
    }else if(identifierInt == GC_ROW_GRAPH_TYPE && lv){
        self.config.graphType = lv.selected;
        changed = true;
    }
    if (changed) {
        [self.viewController updateConfig:self.config];
        [self.tableView reloadData];
    }
}
-(void)validateConfigForGraphType{
    if (self.config.graphType == gcHistGraphTypeBarSum) {

    }
}

-(UINavigationController*)baseNavigationController{
    return( self.navigationController );
}
-(UINavigationItem*)baseNavigationItem{
    return( self.navigationItem );
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPathI{
    NSIndexPath * indexPath = [self.remap remap:indexPathI];
    if (indexPath.row == GC_ROW_GRAPH_TYPE) {
        GCCellEntryListViewController * vc = [GCViewConfig standardEntryListViewController:[GCStatsHistGraphConfig graphTypeDisplayNames]
                                                                                           selected:self.config.graphType];
        vc.identifierInt = indexPath.row;
        vc.entryFieldDelegate = self;


        [self.navigationController pushViewController:vc animated:YES];

    }else if (indexPath.row == GC_ROW_FIELD || indexPath.row == GC_ROW_X_FIELD){
        GCField * field = indexPath.row == GC_ROW_FIELD ? self.config.fieldConfig.activityField : self.config.fieldConfig.x_activityField;

        GCCellEntryFieldChoiceViewController * vc = [GCCellEntryFieldChoiceViewController fieldChoiceAmong:self.viewController.allFields
                                                                                             currentChoice:field
                                                                                              withDelegate:self];
        vc.identifierInt = indexPath.row;

        [self.navigationController pushViewController:vc animated:YES];
    }
}
@end
