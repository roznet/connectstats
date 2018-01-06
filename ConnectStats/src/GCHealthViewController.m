//  MIT Licence
//
//  Created on 20/08/2013.
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

#import "GCHealthViewController.h"
#import "GCAppGlobal.h"
#import "GCHealthZoneCalculator.h"
#import "GCViewConfig.h"
#import "GCViewIcons.h"
#import "GCWebConnect+Requests.h"
#import "ConnectStats-Swift.h"

#define GC_SECTION_REFRESH  0
#define GC_SECTION_END      1

#define GC_REFRESH_ZONES    0
#define GC_PREFERRED_SOURCE 1
#define GC_REFRESH_END      2

@interface GCHealthViewController ()
@property (nonatomic,retain) NSArray<NSString*>*zoneSources;
@end

@implementation GCHealthViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc{
    [_zoneSources release];
    [super dealloc];
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
    self.zoneSources = [[GCAppGlobal health] availableZoneCalculatorsSources];
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
    return GC_SECTION_END + self.zoneSources.count;
}

-(NSArray<GCHealthZoneCalculator*>*)calculatorsForSection:(NSInteger)section{
    NSUInteger idx = section-GC_SECTION_END;
    if( idx < self.zoneSources.count){
        NSString * sourceKey = self.zoneSources[idx];
        return [[GCAppGlobal health] availableZoneCalculatorsForSource:[GCHealthZone zoneSourceFromKey:sourceKey]];
    }else{
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == GC_SECTION_REFRESH) {
        return GC_REFRESH_END;
    }else if (section>=GC_SECTION_END){
        return [self calculatorsForSection:section].count;
    }else{
        return 0;
    }
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if( section == GC_SECTION_REFRESH){
        return nil;
    }else{
        NSUInteger idx = section-GC_SECTION_END;
        if( idx < self.zoneSources.count){
            NSString * sourceKey = self.zoneSources[idx];
            return [GCHealthZone zoneSourceDescription:[GCHealthZone zoneSourceFromKey:sourceKey]];
        }
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * rv = nil;

    if (indexPath.section == GC_SECTION_REFRESH) {
        if(indexPath.row == GC_REFRESH_ZONES){
            GCCellGrid * cell = [GCCellGrid gridCell:tableView];
            [cell setupForRows:1 andCols:1];
            [cell labelForRow:0 andCol:0].text = NSLocalizedString(@"Refresh Training Zone", @"Health View");
            rv = cell;
        }else{
            GCCellGrid * cell = [GCCellGrid gridCell:tableView];
            [cell setupForRows:1 andCols:2];
            [cell labelForRow:0 andCol:0].text = NSLocalizedString(@"Preferred Source", @"Health View");
            NSString*preferred = [[GCAppGlobal profile] configGetString:CONFIG_ZONE_PREFERRED_SOURCE defaultValue:@"garmin"];
            NSString * desc = [GCHealthZone zoneSourceDescription:[GCHealthZone zoneSourceFromKey:preferred]];
            [cell labelForRow:0 andCol:1].text = desc;
            rv = cell;
        }
    }else if (indexPath.section>=GC_SECTION_END){

        NSArray<GCHealthZoneCalculator*>*calculators = [self calculatorsForSection:indexPath.section];
        GCCellGrid * cell = [GCCellGrid gridCell:tableView];
        [cell setupForRows:2 andCols:2];

        if( indexPath.row < calculators.count){
            GCHealthZoneCalculator * calc = calculators[indexPath.row];

            NSString * desc = calc.field.displayName;
            if (desc==nil && calc.field.fieldFlag == gcFieldFlagPower) {
                desc = NSLocalizedString(@"Power", @"Health View Controller");
            }
            UIImage * icon=[GCViewIcons activityTypeColoredIconFor:calc.field.activityType];
            [cell setIconImage:icon];
            if (!icon) {
                [cell labelForRow:0 andCol:1].text = calc.activityType;
            }
            NSMutableArray * z = [NSMutableArray arrayWithCapacity:(calc.zones).count];
            BOOL first = true;
            for (GCHealthZone * zone in calc.zones) {
                if( first ){
                    [z addObject:[zone ceilingLabel]];
                    first = false;
                }else{
                    [z addObject:[zone ceilingLabelNoUnits]];
                }
            }
            NSString * subtitle = [z componentsJoinedByString:@", "];
            [cell labelForRow:0 andCol:0].text = desc;
            [cell labelForRow:1 andCol:0].attributedText = [GCViewConfig attributedString:subtitle attribute:@selector(attribute14Gray)];
            [cell configForRow:1 andCol:0].horizontalOverflow = true;

        }else{
            [cell labelForRow:0 andCol:0].text = NSLocalizedString(@"Missing...", @"HealthView");
        }
        rv = cell;
    }

    return rv?:[GCCellGrid gridCell:tableView];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.section == GC_SECTION_REFRESH) {
        if( indexPath.row == GC_REFRESH_ZONES){
            [[GCAppGlobal health] forceZoneRefresh];
            [[GCAppGlobal web] servicesSearchRecentActivities];
        }else if (indexPath.row == GC_PREFERRED_SOURCE){
            NSString*preferred = [[GCAppGlobal profile] configGetString:CONFIG_ZONE_PREFERRED_SOURCE defaultValue:@"garmin"];
            NSUInteger found = 0;
            for (NSString * one in self.zoneSources) {
                if( [one isEqualToString:preferred]){
                    break;
                }
                found++;
            }
            found++; // go to next source
            if(found >= self.zoneSources.count){
                found= 0;
            }

            if(found < self.zoneSources.count){
                preferred = self.zoneSources[found];
                [[GCAppGlobal profile] configSet:CONFIG_ZONE_PREFERRED_SOURCE stringVal:preferred];
                [GCAppGlobal saveSettings];
                [tableView reloadData];
            }
        }
    }else{
        NSArray< GCHealthZoneCalculator*>*calcs = [self calculatorsForSection:indexPath.section];
        GCHealthZoneCalculator * manual = [GCHealthZoneCalculator manualZoneCalculatorFrom:calcs[indexPath.row]];
        GCHealthZonesViewController * vc = [[[GCHealthZonesViewController alloc] initWithZone:manual] autorelease];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
