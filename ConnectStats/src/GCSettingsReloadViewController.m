//  MIT Licence
//
//  Created on 24/10/2013.
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

#import "GCSettingsReloadViewController.h"
#import "GCAppGlobal.h"
#import "GCViewConfig.h"
#import "GCWebConnect+Requests.h"
#import "GCActivitiesOrganizer.h"
#import "GCHealthOrganizer.h"

#define GC_SECTION_STATUS  0
#define GC_SECTION_OPTIONS 1
#define GC_SECTION_END     2

#define GC_ROW_RELOAD_ALL   0
#define GC_ROW_FILL_DETAIL  1
#define GC_ROW_FILL_WEATHER 2
#define GC_ROW_END          3

@interface GCSettingsReloadViewController ()

@end

@implementation GCSettingsReloadViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [[GCAppGlobal web] attach:self];
    }
    return self;
}

-(void)dealloc{
    [[GCAppGlobal web] detach:self];

    [super dealloc];
}

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
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
    return GC_SECTION_END;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == GC_SECTION_STATUS) {
        return 1;
    }
    // Return the number of rows in the section.
    return GC_ROW_END;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * rv = nil;

    if (indexPath.section == GC_SECTION_STATUS) {
            GCCellActivityIndicator * indic = [GCCellActivityIndicator activityIndicatorCell:tableView parent:[GCAppGlobal web]];
            if ([[GCAppGlobal web] isProcessing]) {
                indic.label.attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                       withString:[[GCAppGlobal web] currentDescription]];
            }else{
                indic.label.attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                       withString:NSLocalizedString(@"Waiting", @"Cell Status")];
            }
            rv = indic;
    }else{
        GCCellGrid * cell = [GCCellGrid gridCell:tableView];
        [cell setupForRows:2 andCols:1];
        if (indexPath.row == GC_ROW_FILL_WEATHER) {
            NSUInteger total = [[GCAppGlobal organizer] countOfActivities];

            FMDatabase*db=[GCAppGlobal db];
            NSString * query = @"select COUNT(a.activityId) FROM gc_activities a LEFT JOIN gc_activities_weather o ON o.activityId = a.activityId WHERE o.activityId IS NULL";
            NSUInteger missing = [db intForQuery:query];//CRASH could fail if db busy

            [cell labelForRow:0 andCol:0].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                                     withString:NSLocalizedString(@"Reload Weather for 50 activities", @"Reload Settings")];
            NSString * msg = [NSString stringWithFormat:NSLocalizedString(@"Missing %lu out of %lu activities", @"Reload Settings"),missing,total];
            [cell labelForRow:1 andCol:0].attributedText =[GCViewConfig attributedString:msg attribute:@selector(attribute14Gray)];

        }else if(indexPath.row==GC_ROW_RELOAD_ALL){
            [cell labelForRow:0 andCol:0].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                                     withString:NSLocalizedString(@"Reload All Activities", @"Reload Settings")];
        }else if(indexPath.row==GC_ROW_FILL_DETAIL){
            [cell labelForRow:0 andCol:0].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                                     withString:NSLocalizedString(@"Reload Details for 50 activities", @"Reload Settings")];
            NSUInteger total = [[GCAppGlobal organizer] countOfActivities];
            NSUInteger missing = [self activitiesWithout13Detail].count;
            NSString * msg = [NSString stringWithFormat:NSLocalizedString(@"Missing %lu out of %lu activities", @"Reload Settings"),missing,total];
            [cell labelForRow:1 andCol:0].attributedText =[GCViewConfig attributedString:msg attribute:@selector(attribute14Gray)];

        }
        rv = cell;
    }
    return rv;
}

-(NSArray*)missingActivitiesIn:(NSString*)table{
    NSString * query = [NSString stringWithFormat:@"select a.activityId FROM gc_activities a LEFT JOIN %@ o ON o.activityId = a.activityId WHERE o.activityId IS NULL ORDER BY a.activityId DESC LIMIT 50", table];
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:50];
    FMResultSet * res = [[GCAppGlobal db] executeQuery:query];
    while ([res next]) {
        [rv addObject:[res stringForColumn:@"activityId"]];
    }
    return rv;
}

-(NSArray*)activitiesWithout13Detail{
    NSArray * activities = [[GCAppGlobal organizer] activities];
    [activities retain];
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:50];

    for (GCActivity * activity in activities) {
        if (![activity hasTrackDb]) {
            [rv addObject:activity];
        }else{
            FMDatabase * trackdb = [FMDatabase databaseWithPath:[activity trackDbFileName]];
            [trackdb open];//CRASH could fail if db busy
            NSInteger version = [trackdb intForQuery:@"SELECT MAX(version) FROM gc_version"];
            [trackdb close];
            if (version < 3) {
                [rv addObject:activity];
            }
        }
    }
    [activities release];
    return rv;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==GC_SECTION_OPTIONS && indexPath.row ==GC_ROW_FILL_WEATHER) {
        /*NSArray * missing = [self missingActivitiesIn:@"gc_activities_weather"];
        for (NSUInteger i=0; i<missing.count; i++) {
            NSString * aId = missing[i];
            //[[GCAppGlobal web] garminDownloadWeather:aId];
        }*/
    }else if (indexPath.section == GC_SECTION_OPTIONS && indexPath.row ==GC_ROW_RELOAD_ALL){
        [[GCAppGlobal web] servicesSearchAllActivities];
    }else if (indexPath.section == GC_SECTION_OPTIONS && indexPath.row == GC_ROW_FILL_DETAIL){
        NSArray * missing = [self activitiesWithout13Detail];
        for (NSUInteger i=0; i<MIN(50,[missing count]); i++) {
            GCActivity * activity = missing[i];
            [activity clearTrackdb];
            [activity trackpoints];
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==GC_SECTION_STATUS) {
        return [GCCellActivityIndicator height];
    }
    return tableView.rowHeight;
}
@end
