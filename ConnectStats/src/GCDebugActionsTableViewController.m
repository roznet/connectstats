//  MIT Licence
//
//  Created on 10/05/2015.
//
//  Copyright (c) 2015 Brice Rosenzweig.
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

#import "GCAppGlobal.h"
#import "GCWebConnect+Requests.h"
#import "GCHealthKitDailySummaryParser.h"
#import "GCDebugActionsTableViewController.h"
#import "GCHealthKitWorkoutParser.h"
#import "GCHealthKitDayDetailParser.h"
#import "GCService.h"
#import "GCActivity+Database.h"
#import "GCActivityThumbnails.h"
#import "GCAppActions.h"
#import "GCActivity+Database.h"
#import "GCDerivedOrganizer.h"
#import "GCHealthOrganizer.h"
#import "GCViewConfig.h"
#import "GCConnectStatsRequestFitFile.h"
#import "GCFieldInfo.h"

@import ObjectiveC;

@interface GCDebugActionsTableViewController ()

@property (nonatomic,retain) NSArray * availableActions;

@end

@implementation GCDebugActionsTableViewController
-(void)dealloc{
    [_availableActions release];
    [super dealloc];
}
- (void)viewDidLoad {
    [super viewDidLoad];

    self.availableActions = [self listActions];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [GCViewConfig setupViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.availableActions.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GCCellGrid * cell = [GCCellGrid gridCell:tableView];
    [cell setupForRows:1 andCols:1];
    NSString * methodName =self.availableActions[indexPath.row];

    [cell labelForRow:0 andCol:0].text = [methodName fromCamelCaseToSeparatedByString:@" "];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"action%@", self.availableActions[indexPath.row]]);
    if ([self respondsToSelector:selector]) {
        RZLog(RZLogInfo, @"Executing %@", NSStringFromSelector(selector));
        [self performSelector:selector withObject:nil afterDelay:0.0];
    }
    [tableView reloadData];
}

-(NSArray*)listActions{
    Class cls = [self class];
    NSMutableArray * rv = [NSMutableArray array];
    
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(cls, &methodCount);
    
    for (unsigned int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        NSString * methodName = @(sel_getName(method_getName(method)));
        if ([methodName hasPrefix:@"action"]) {
            [rv addObject:[methodName substringFromIndex:6]];
        }
    }
    
    free(methods);
    return rv;
}

#pragma mark - Actions


-(void)actionDumpCountriesCoord{
    NSArray * activities = [[GCAppGlobal organizer] activities];
    
    [RZFileOrganizer removeEditableFile:@"countries.db"];
    FMDatabase * db = [FMDatabase databaseWithPath:[RZFileOrganizer writeableFilePath:@"countries.db"]];
    [db open];
    RZEXECUTEUPDATE(db, @"CREATE TABLE countries (location TEXT, latitude REAL, longitude REAL)")
    for (GCActivity * activity in activities) {
        if( activity.location && activity.beginCoordinate.longitude != 0 && activity.beginCoordinate.latitude){
            RZEXECUTEUPDATE(db, @"INSERT INTO countries (location,latitude,longitude) VALUES (?,?,?)",
                            activity.location, @(activity.beginCoordinate.latitude),@(activity.beginCoordinate.longitude));
        }
    }
    [db close];
    RZLog(RZLogInfo,@"Saved %@", [RZFileOrganizer writeableFilePath:@"countries.db"]);

}

-(void)actionUpdateWeather{
    NSArray * activities = [[GCAppGlobal organizer] activities];
    NSUInteger i = 0;
    for (GCActivity * activity in activities) {
        if (activity.downloadMethod == gcDownloadMethod13 || activity.downloadMethod == gcDownloadMethodModern) {
            [[GCAppGlobal web] connectStatsDownloadWeather:activity];
            i++;
        }
    }
}

-(void)actionClearAndReprocessDerived{
    //db tableExists:@"gc_derived_activity_processed"
    FMDatabase * db = [[GCAppGlobal derived] deriveddb];
    RZEXECUTEUPDATE(db, @"DROP TABLE gc_derived_activity_processed");
}

-(void)actionProcessSomeDerived{
    //db tableExists:@"gc_derived_activity_processed"
    [[GCAppGlobal derived] processSome];
}


-(void)actionReparseCurrentActivity{
    GCActivity * act = [[GCAppGlobal organizer] currentActivity];
    if( act.service.service == gcServiceConnectStats){
        [GCConnectStatsRequestFitFile testForActivity:act withFilesIn:[RZFileOrganizer writeableFilePath:nil]];
    }
}

-(void)actionTestNetwork{
    BOOL wifi = [RZSystemInfo wifiAvailable];
    BOOL network = [RZSystemInfo networkAvailable];

    RZLog(RZLogInfo,@"Network: %@ Wifi: %@", network ? @"Yes" : @"No", wifi?@"Yes": @"No");
}

-(void)actionSaveCurrentActivity{
    GCActivity * activity = [[GCAppGlobal organizer] currentActivity];

    NSString * fn = [NSString stringWithFormat:@"test_activity_%@_%@.db", activity.activityType, activity.activityId];
    FMDatabase * db = [FMDatabase databaseWithPath:[RZFileOrganizer writeableFilePath:fn]];
    [db open];
    [activity fullSaveToDb:db];
    GCHealthOrganizer * health= [GCAppGlobal health];
    NSArray<GCHealthMeasure*> * measures = [health measuresForDate:activity.date];
    [GCHealthOrganizer ensureDbStructure:db];
    for (GCHealthMeasure * one in measures) {
        [one saveToDb:db];
    }
}

-(void)actionSaveThumbnails{
    GCActivityThumbnails * thumbs = [[GCActivityThumbnails alloc] init];

    GCField * distfield = [GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:GC_TYPE_RUNNING];
    UIImage * img = [thumbs historyPlotFor:distfield andSize:CGSizeMake(150., 150.)];
    NSData * data = UIImagePNGRepresentation(img);
    NSString * imgname = [NSString stringWithFormat:@"thumb-graph.png"];
    [data writeToFile:[RZFileOrganizer writeableFilePath:imgname] atomically:YES];
    RZLog(RZLogInfo,@"%@", [RZFileOrganizer writeableFilePath:imgname]);
    [thumbs release];
}

-(void)actionTestUrl{
    NSString * action = @"actionFocusOnStatsSummary";
    action = @"actionFocusOnStatsSummary/viewChoice/yearly/activityType/cycling/calChoice/toDate";
    //action = @"actionFocusOnActivity";
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.ro-z.net/app-ios/c/%@", action]];
    GCAppActions * appAction = [GCAppActions appActions];

    [appAction execute:url];
}

-(void)actionClearRunningPower{
    NSArray<GCActivity*>* activities = [[GCAppGlobal organizer] activities];
    NSMutableArray<GCActivity*>* withPower = [NSMutableArray array];
    for (GCActivity * activity in activities) {
        if( [activity.activityType isEqualToString:GC_TYPE_RUNNING] && [activity hasTrackForField:[GCField fieldForFlag:gcFieldFlagPower andActivityType:GC_TYPE_RUNNING]]){
            [withPower addObject:activity];
            [[GCAppGlobal derived] forceReprocessActivity:activity.activityId];
        }
    }
    [[GCAppGlobal derived] clearDataForActivityType:GC_TYPE_RUNNING andFieldFlag:gcFieldFlagPower];
    RZLog(RZLogInfo,@"%@", withPower);
    //[[GCAppGlobal derived] processActivities:withPower];
}

@end
