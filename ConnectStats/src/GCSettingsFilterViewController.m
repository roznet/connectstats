//  MIT Licence
//
//  Created on 13/04/2013.
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

#import "GCSettingsFilterViewController.h"
#import "GCCellGrid+Templates.h"
#import "GCAppGlobal.h"

#define GCVIEW_FILTER_MAIN          0
#define GCVIEW_FILTER_LOW_SPEED     1
#define GCVIEW_FILTER_ACCEL         2
#define GCVIEW_FILTER_HIGH_POWER    3
#define GCVIEW_FILTER_ADJUST_LAP    4
#define GCVIEW_FILTER_END           5


@interface GCSettingsFilterViewController ()

@end

@implementation GCSettingsFilterViewController

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
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [GCViewConfig setupViewController:self];
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
    return GCVIEW_FILTER_END;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * rv = nil;


    if (indexPath.row == GCVIEW_FILTER_MAIN) {
        GCCellEntrySwitch * cell = [GCCellEntrySwitch switchCell:tableView];
        
        cell.label.attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                    withString:NSLocalizedString(@"Filter bad values", @"Settings Filter")];

        cell.entryFieldDelegate = self;
        cell.identifierInt = GCVIEW_FILTER_MAIN;
        (cell.toggle).on = [GCAppGlobal configGetBool:CONFIG_FILTER_BAD_VALUES defaultValue:YES];

        rv = cell;
    }else if(indexPath.row==GCVIEW_FILTER_LOW_SPEED){
        GCCellGrid * cell = [GCCellGrid gridCell:tableView];
        cell.marginx = 5.;
        [cell setupForRows:1 andCols:2];
        [cell labelForRow:0 andCol:0].attributedText = [GCViewConfig attributedString:NSLocalizedString(@"Minimum running speed", @"Settings Filter") attribute:@selector(attributeBold16)];
        [cell configForRow:0 andCol:0].horizontalOverflow=true;
        NSUInteger choice = [self minimumSpeedChoiceForSpeed:[GCAppGlobal configGetDouble:CONFIG_FILTER_SPEED_BELOW defaultValue:1.0]];
        NSString  * val = [self minimumSpeedChoicesDescriptions][choice];
        [cell labelForRow:0 andCol:1].attributedText = [GCViewConfig attributedString:val attribute:@selector(attributeBold16)];

        rv = cell;
    }else if(indexPath.row==GCVIEW_FILTER_HIGH_POWER){
        GCCellGrid * cell = [GCCellGrid gridCell:tableView];
        cell.marginx = 5.;
        [cell setupForRows:1 andCols:2];
        [cell labelForRow:0 andCol:0].attributedText = [GCViewConfig attributedString:NSLocalizedString(@"Maximum cycling power", @"Settings Filter") attribute:@selector(attributeBold16)];
        [cell configForRow:0 andCol:0].horizontalOverflow=true;
        NSUInteger choice = [self maximumPowerChoiceForPower:[GCAppGlobal configGetDouble:CONFIG_FILTER_POWER_ABOVE defaultValue:CONFIG_FILTER_DISABLED_POWER]];
        NSString  * val = [self maximumPowerChoicesDescriptions][choice];
        [cell labelForRow:0 andCol:1].attributedText = [GCViewConfig attributedString:val attribute:@selector(attributeBold16)];

        rv = cell;
    }else if(indexPath.row==GCVIEW_FILTER_ACCEL){
        GCCellEntrySwitch * cell = [GCCellEntrySwitch switchCell:tableView];
        cell.label.attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                              withString:NSLocalizedString(@"Filter Bad Accelerations", @"Settings Filter")];

        cell.entryFieldDelegate = self;
        cell.identifierInt = GCVIEW_FILTER_ACCEL;
        (cell.toggle).on = [GCAppGlobal configGetBool:CONFIG_FILTER_BAD_ACCEL defaultValue:YES];

        rv = cell;

    }else if(indexPath.row==GCVIEW_FILTER_ADJUST_LAP){
        GCCellEntrySwitch * cell = [GCCellEntrySwitch switchCell:tableView];
        cell.label.attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                              withString:NSLocalizedString(@"Adjust For Lap Avg", @"Settings Filter")];
        cell.entryFieldDelegate = self;
        cell.identifierInt = GCVIEW_FILTER_ADJUST_LAP;
        (cell.toggle).on = [GCAppGlobal configGetBool:CONFIG_FILTER_ADJUST_FOR_LAP defaultValue:NO];

        rv = cell;

    }
    if( rv == nil){
        rv = [GCCellGrid gridCell:tableView];
    }
    rv.backgroundColor = [GCViewConfig defaultColor:gcSkinDefaultColorBackground];
    
    return rv;
}

#pragma mark - Maximum Power

-(NSArray*)maximumPowerChoices{
    return @[ @500., @750., @1000., @1500., @2000., @2500., @(CONFIG_FILTER_DISABLED_POWER)];
}

-(NSUInteger)maximumPowerChoiceForPower:(double)curr{
    NSUInteger idx = 0;
    NSArray * choices = [self maximumPowerChoices];

    for (idx=0; idx<choices.count; idx++) {
        if (curr <= [choices[idx] doubleValue]) {
            break;
        }
    }

    if (idx==choices.count) {
        idx = choices.count-1;
    }
    return idx;

}

-(NSArray*)maximumPowerChoicesDescriptions{
    NSArray * sp = [self maximumPowerChoices];
    NSMutableArray * ar = [NSMutableArray arrayWithCapacity:sp.count];
    GCUnit * unit = [GCUnit unitForKey:@"watt"];
    for (NSNumber * v in sp) {
        double power = v.doubleValue;
        if (power == CONFIG_FILTER_DISABLED_POWER) {
            [ar addObject:@"None"];
        }else{
            NSString * msg = [unit formatDouble:power];
            [ar addObject:msg];
        }
    }

    return ar;
}


#pragma mark - Minimum Speed

-(NSUInteger)minimumSpeedChoiceForSpeed:(double)curr{
    NSUInteger idx = 0;
    NSArray * choices = [self minimumSpeedChoices];

    for (idx=0; idx<choices.count; idx++) {
        if (curr <= [choices[idx] doubleValue]) {
            break;
        }
    }

    if (idx==choices.count) {
        idx = choices.count-1;
    }
    return idx;
}

-(NSArray*)minimumSpeedChoices{
    return @[@0., @0.5, @1.,@1.5,@1.75,@2.,@2.25, @2.6, @3., @3.25 ];
}

-(NSArray*)minimumSpeedChoicesDescriptions{
    NSArray * sp = [self minimumSpeedChoices];
    NSMutableArray * ar = [NSMutableArray arrayWithCapacity:sp.count];
    GCUnit * unit = [GCFields fieldUnit:[GCFields fieldForFlag:gcFieldFlagWeightedMeanSpeed andActivityType:GC_TYPE_RUNNING] activityType:GC_TYPE_RUNNING];
    unit = [unit unitForGlobalSystem];
    for (NSNumber * v in sp) {
        double mps = v.doubleValue;
        if (mps == 0.) {
            [ar addObject:@"None"];
        }else{
            NSString * msg = [unit formatDouble:[unit convertDouble:mps fromUnit:[GCUnit unitForKey:STOREUNIT_SPEED]]];
            if (!msg) {
                RZLog(RZLogWarning, @"Couldn't find unit for running speed");
                msg = [[GCUnit unitForKey:STOREUNIT_SPEED] formatDouble:mps];
            }
            if (msg) {
                [ar addObject:msg];
            }else{
                [ar addObject:@"Error"];
            }
        }
    }

    return ar;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == GCVIEW_FILTER_LOW_SPEED) {
        NSArray * choices = [self minimumSpeedChoicesDescriptions];
        NSUInteger selected = [self minimumSpeedChoiceForSpeed:[GCAppGlobal configGetDouble:CONFIG_FILTER_SPEED_BELOW defaultValue:1.0]];
        GCCellEntryListViewController * detailViewController = [GCViewConfig standardEntryListViewController:choices selected:selected];
        detailViewController.entryFieldDelegate = self;
        detailViewController.identifierInt = GCVIEW_FILTER_LOW_SPEED;
        [self.navigationController pushViewController:detailViewController animated:YES];
    }else if (indexPath.row==GCVIEW_FILTER_HIGH_POWER){
        NSArray * choices = [self maximumPowerChoicesDescriptions];
        NSUInteger selected = [self maximumPowerChoiceForPower:[GCAppGlobal configGetDouble:CONFIG_FILTER_POWER_ABOVE defaultValue:CONFIG_FILTER_DISABLED_POWER]];
        GCCellEntryListViewController * detailViewController = [GCViewConfig standardEntryListViewController:choices selected:selected];
        detailViewController.entryFieldDelegate = self;
        detailViewController.identifierInt = GCVIEW_FILTER_HIGH_POWER;
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
}


-(void)cellWasChanged:(id<GCEntryFieldProtocol>)cell{
    switch ([cell identifierInt]) {
        case GCVIEW_FILTER_MAIN:
            [GCAppGlobal configSet:CONFIG_FILTER_BAD_VALUES boolVal:[cell on]];
            [GCAppGlobal saveSettings];
            break;
        case GCVIEW_FILTER_LOW_SPEED:
            [GCAppGlobal configSet:CONFIG_FILTER_SPEED_BELOW doubleVal:[[self minimumSpeedChoices][[cell selected]] doubleValue]];
            [GCAppGlobal saveSettings];
            break;
        case GCVIEW_FILTER_HIGH_POWER:
            [GCAppGlobal configSet:CONFIG_FILTER_POWER_ABOVE doubleVal:[[self maximumPowerChoices][[cell selected]] doubleValue]];
            [GCAppGlobal saveSettings];
            break;
        case GCVIEW_FILTER_ACCEL:
            [GCAppGlobal configSet:CONFIG_FILTER_BAD_ACCEL boolVal:[cell on]];
            [GCAppGlobal saveSettings];
            break;
        case GCVIEW_FILTER_ADJUST_LAP:
            [GCAppGlobal configSet:CONFIG_FILTER_ADJUST_FOR_LAP boolVal:[cell on]];
            [GCAppGlobal saveSettings];
            break;
        default:
            break;
    }
    [self.tableView reloadData];
}

-(UINavigationController*)baseNavigationController{
    return self.navigationController;
}
-(UINavigationItem*)baseNavigationItem{
    return self.navigationItem;
}
@end
