//  MIT Licence
//
//  Created on 17/11/2012.
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

#import "GCActivityLapViewController.h"
#import "GCCellGrid+Templates.h"
#import "GCCellMap.h"
#import "GCAppGlobal.h"
#import "GCViewIcons.h"
#import "GCTrackStats.h"
#import "GCSimpleGraphCachedDataSource+Templates.h"
#import "GCFieldsCalculated.h"
#import "GCTableHeaderFieldsCategory.h"
#import "GCField.h"
#import "GCFieldsForCategory.h"

#define GCVIEW_SECTION_SUMMARY 0
#define GCVIEW_SECTION_MAP     1
#define GCVIEW_SECTION_GRAPH   2
#define GCVIEW_SECTION_DETAILS 3
#define GCVIEW_SECTION_END     4

@interface GCActivityLapViewController ()

@end

@implementation GCActivityLapViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)dealloc{
    [_organizedFields release];
    [_activity release];
    [_choices release];

    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    ;

    (self.navigationItem).rightBarButtonItems = @[[[[UIBarButtonItem alloc] initWithImage:[GCViewIcons navigationIconFor:gcIconNavForward] style:UIBarButtonItemStylePlain target:self action:@selector(nextLap:)] autorelease],

                                                 [[[UIBarButtonItem alloc] initWithImage:[GCViewIcons navigationIconFor:gcIconNavBack] style:UIBarButtonItemStylePlain target:self action:@selector(previousLap:)] autorelease]];
    [self setOrganizedFields:nil];
    [self.activity focusOnLapIndex:self.lapIndex];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [GCViewConfig setupViewController:self];
}
-(NSArray<GCFieldsForCategory*>*)setupFields{
    if (self.organizedFields==nil) {
        NSArray<GCField*>*fields = [[self.activity lapNumber:self.lapIndex] availableFieldsInActivity:self.activity];
        self.organizedFields = [GCFields categorizeAndOrderFields:fields];
    }
    return self.organizedFields;
}

-(NSString*)categoryNameForSection:(NSInteger)section{
    if (section>= GCVIEW_SECTION_DETAILS) {
        NSUInteger idx = section-GCVIEW_SECTION_DETAILS;
        NSArray<GCFieldsForCategory*> * fields = self.setupFields;
        if (idx<fields.count) {
            GCFieldsForCategory * defs = fields[idx];
            return defs.category;
        }
    }
    return nil;
}

-(NSArray<GCField*>*)fieldsForSection:(NSInteger)section{
    if (section>= GCVIEW_SECTION_DETAILS) {
        NSUInteger idx = section-GCVIEW_SECTION_DETAILS;
        NSArray<GCFieldsForCategory*> * fields = self.setupFields;
        if (idx<fields.count) {
            GCFieldsForCategory * defs = fields[idx];
            return defs.fields;
        }
    }
    return nil;
}


-(void)nextLap:(id)cb{
    if (self.lapIndex + 1 < [self.activity lapCount]) {
        self.lapIndex++;
        [self.activity focusOnLapIndex:self.lapIndex];
        [self setOrganizedFields:nil];
        UITableView * tv = (UITableView*)self.view;
        [tv reloadData];
    }
}

-(void)previousLap:(id)cb{
    if (self.lapIndex > 0) {
        self.lapIndex--;
        [self.activity focusOnLapIndex:self.lapIndex];
        [self setOrganizedFields:nil];
        UITableView * tv = (UITableView*)self.view;
        [tv reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    RZLog(RZLogWarning, @"memory warning %@", [RZMemory formatMemoryInUse]);

    // Dispose of any resources that can be recreated.
}

-(void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    [self.tableView reloadData];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return GCVIEW_SECTION_DETAILS+(self.setupFields).count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == GCVIEW_SECTION_SUMMARY || section == GCVIEW_SECTION_MAP || section == GCVIEW_SECTION_GRAPH) {
        return 1;
    }
    return [self fieldsForSection:section].count;
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GCCellGrid * cell = [GCCellGrid cellGrid:tableView];

    // Configure the cell...
    if (indexPath.section >= GCVIEW_SECTION_DETAILS) {
        NSArray<GCField*> * keys = [self fieldsForSection:indexPath.section];
        [cell setupForLap:[self.activity lapNumber:self.lapIndex] key:[keys[indexPath.row] key] andActivity:self.activity width:tableView.frame.size.width];
    }else if(indexPath.section== GCVIEW_SECTION_MAP){
        GCCellMap *mcell = (GCCellMap*)[tableView dequeueReusableCellWithIdentifier:@"GCMap"];
        if (mcell == nil) {
            mcell = [[[GCCellMap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GCMap"] autorelease];
        }
        if ([GCAppGlobal configGetBool:CONFIG_MAPS_INLINE_GRADIENT defaultValue:true]) {
            if (!self.choices || (self.choices).choices.count==0) {
                self.choices = [GCTrackFieldChoices trackFieldChoicesWithActivity:self.activity];
            }
            mcell.mapController.gradientField = self.choices.current.field;
        }else{
            mcell.mapController.gradientField = nil;
        }

        (mcell.mapController).activity = self.activity;
        (mcell.mapController).showLaps = gcLapDisplaySingle;
        (mcell.mapController).lapIndex = self.lapIndex;
        [mcell.mapController notifyCallBack:nil info:nil];
        return mcell;
    }else if (indexPath.section == GCVIEW_SECTION_GRAPH){
        GCCellSimpleGraph * gcell = [GCCellSimpleGraph graphCell:tableView];
        gcell.cellDelegate = self;
        GCTrackStats * s = [[GCTrackStats alloc] init];
        [self setupGraphFields];
        s.activity = self.activity;
        [s setHighlightLap:true];
        s.highlightLapIndex = self.lapIndex;
        if (!self.choices) {
            self.choices = [GCTrackFieldChoices trackFieldChoicesWithActivity:self.activity];
        }
        [self.choices setupTrackStats:s];
        GCSimpleGraphCachedDataSource * ds = [GCSimpleGraphCachedDataSource trackFieldFrom:s];
        [gcell setDataSource:ds andConfig:ds];

        [s release];
        return gcell;
    }else{
        [cell setupForLap:self.lapIndex andActivity:self.activity width:tableView.frame.size.width];
    }

    return cell;
}

-(BOOL)setupGraphFields{
    return false;
}
-(void)nextGraphFields{
    [self.choices next];
}
-(void)swipeLeft:(GCCellSimpleGraph*)cell{
    [self.choices next];
    [self.tableView reloadData];
}
-(void)showMap{
    GCMapViewController *detailViewController = [[GCMapViewController alloc] initWithNibName:nil bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    detailViewController.gradientField =  [GCField  fieldForFlag:gcFieldFlagWeightedMeanSpeed andActivityType:self.activity.activityType];
    detailViewController.activity = self.activity;
    detailViewController.lapIndex = self.lapIndex;
    detailViewController.showLaps = gcLapDisplaySingle;
    detailViewController.mapType = (gcMapType)[GCAppGlobal configGetInt:CONFIG_USE_MAP defaultValue:gcMapBoth];

    if ([UIViewController useIOS7Layout]) {
        [UIViewController setupEdgeExtendedLayout:detailViewController];
    }

    [self.navigationController setNavigationBarHidden:NO animated:YES];

    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // go into stat page
    // stats page:
    // history/activity either accross  time or for this activity points
    // graph
    // table aggregated by week/month/all, sum or avg
    if (indexPath.section == GCVIEW_SECTION_MAP) {
        [self showMap];
    }else if (indexPath.section==GCVIEW_SECTION_GRAPH){
        [self.choices nextStyle];
        [self.tableView reloadData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGSize rect = tableView.frame.size;

    if(indexPath.section==GCVIEW_SECTION_MAP||indexPath.section == GCVIEW_SECTION_GRAPH){
        if (rect.height > 600.) {
            return 200.;
        }
        return 150.;
    }
    return 52.;
}



@end
