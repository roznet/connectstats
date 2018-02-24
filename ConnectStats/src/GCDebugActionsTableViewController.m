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

#pragma mark - Actions



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

-(void)actionUpdateWeather{
    NSArray * activities = [[GCAppGlobal organizer] activities];
    NSUInteger i = 0;
    for (GCActivity * activity in activities) {
        if (activity.downloadMethod == gcDownloadMethod13 || activity.downloadMethod == gcDownloadMethodModern) {
            [[GCAppGlobal web] garminDownloadWeather:activity];
            i++;
        }
    }
}

-(void)actionClearAndReprocessDerived{
    //db tableExists:@"gc_derived_activity_processed"
    FMDatabase * db = [[GCAppGlobal derived] deriveddb];
    RZEXECUTEUPDATE(db, @"DROP TABLE gc_derived_activity_processed");
}

-(void)actionLoadActivity{
    NSCalendar * cal = [NSCalendar currentCalendar];
    NSDateComponents * comp = [[[NSDateComponents alloc] init] autorelease];
    comp.day = 30;
    comp.month = 5;
    comp.year = 2015;
    NSDate * date = [cal dateFromComponents:comp];

    [[GCAppGlobal web] healthStoreDayDetails:date];
    //[[GCAppGlobal web] garminDownloadActivitySummary:@"577776645"];
}

-(void)actionParseSavedHealthKitData{
    NSArray * summaryFiles = [RZFileOrganizer writeableFilesMatching:^(NSString*f){
        return (BOOL)([f hasPrefix:@"health_daysummary"] && [f hasSuffix:@".data"]);
    }];
    for (NSString * fn in summaryFiles) {
        NSString * fp = [RZFileOrganizer writeableFilePath:fn];
        NSDictionary * daysummary = [NSKeyedUnarchiver unarchiveObjectWithFile:fp];
        NSMutableArray * days = [NSMutableArray array];
        GCHealthKitDailySummaryParser * sparser = [GCHealthKitDailySummaryParser parserWithSamples:daysummary];
        sparser.sourceValidator = [[GCAppGlobal profile] currentSourceValidator];
        [sparser parse:^(GCActivity*act,NSString*aId){
            [days addObject:act];
            [[GCAppGlobal organizer] registerActivity:act forActivityId:aId];
        }];
    }

    NSArray * workoutFiles = [RZFileOrganizer writeableFilesMatching:^(NSString*f){
        return (BOOL)([f hasPrefix:@"health_workout"] && [f hasSuffix:@".data"]);
    }];

    for (NSString * fn in workoutFiles) {
        NSString * fp = [RZFileOrganizer writeableFilePath:fn];
        NSDictionary * workout = [NSKeyedUnarchiver unarchiveObjectWithFile:fp];

        NSMutableArray * workouts = [NSMutableArray array];
        //F752F959-3B3C-4A32-BBE4-96C2592153F5
        GCHealthKitWorkoutParser * wparser = [GCHealthKitWorkoutParser parserWithWorkouts:workout[@"r"] andSamples:workout[@"s"]];
        [wparser parse:^(GCActivity*act,NSString*aId){
            [[GCAppGlobal organizer] registerActivity:act forActivityId:aId];

            [workouts addObject:act];
        }];
    }

    NSArray * daydetailsFiles = [RZFileOrganizer writeableFilesMatching:^(NSString*f){
        return (BOOL)([f hasPrefix:@"health_daydetail"] && [f hasSuffix:@".data"]);
    }];

    for (NSString * fn in daydetailsFiles) {
        NSString * fp = [RZFileOrganizer writeableFilePath:fn];
        NSString * aId = [fn substringFromIndex:(@"health_daydetail_").length];
        aId = [aId substringToIndex:(aId.length - (@".data").length) ];
        aId = [[GCService service:gcServiceHealthKit] activityIdFromServiceId:aId];
        NSDictionary * daydetail = [NSKeyedUnarchiver unarchiveObjectWithFile:fp];
        GCHealthKitDayDetailParser * dparser = [GCHealthKitDayDetailParser parserWithSamples:daydetail];
        dparser.sourceValidator = [[GCAppGlobal profile] currentSourceValidator];
        [dparser parse:^(NSArray*points){
            if ([[GCAppGlobal organizer] activityForId:aId]) {
                [[GCAppGlobal organizer] registerActivity:aId withTrackpoints:points andLaps:nil];
            }

        }];
    }


}

-(void)actionTestNetwork{
    BOOL wifi = [RZSystemInfo wifiAvailable];
    BOOL network = [RZSystemInfo networkAvailable];

    NSLog(@"Network: %@ Wifi: %@", network ? @"Yes" : @"No", wifi?@"Yes": @"No");
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
    NSLog(@"%@", [RZFileOrganizer writeableFilePath:imgname]);
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

-(void)actionSaveActivityBlob{
    NSArray * list = [[GCAppGlobal organizer] activities];
    FMDatabase * db = [[GCAppGlobal organizer] db];
    RZPerformance * perf = [RZPerformance start];
    for (GCActivity * act in list) {
        [act saveDictAsBlobToDb:db];
    }
    NSLog(@"Finished %@", perf);
}

-(void)actionLoadActivityBlob{
    FMDatabase * db = [[GCAppGlobal organizer] db];
    NSMutableDictionary * sFound = [NSMutableDictionary dictionary];
    NSMutableDictionary * mFound = [NSMutableDictionary dictionary];
    RZPerformance * perf = [RZPerformance start];
    FMResultSet * res = [db executeQuery:@"SELECT * FROM gc_activities_data"];
    while ([res next]) {
        NSDictionary * sData = [NSKeyedUnarchiver unarchiveObjectWithData:[res dataForColumn:@"summaryData"]];
        NSMutableDictionary * mData = [NSKeyedUnarchiver unarchiveObjectWithData:[res dataForColumn:@"metaData"]];
        sFound[ [res stringForColumn:@"activityId"] ] = sData;
        mFound[ [res stringForColumn:@"activityId"] ] = mData;
    }
    NSLog(@"New Finished %@", perf);
    NSLog(@"Found %lu", (unsigned long) sFound.count);

    perf = [RZPerformance start];

    NSString * query = @"SELECT * FROM gc_activities_values ORDER BY activityId DESC";

    NSMutableDictionary * data = [NSMutableDictionary dictionary];
    NSMutableDictionary * meta = [NSMutableDictionary dictionary];
    NSString * currentId = nil;
    GCActivitySummaryValue * currentValue = nil;
    GCActivityMetaValue * metaValue = nil;

    NSMutableDictionary * currentSummary = nil;
    NSMutableDictionary * currentMeta = nil;

    res = [db executeQuery:query];
    while ([res next]) {
        if (![currentId isEqualToString:[res stringForColumn:@"activityId"]]) {
            currentId = [res stringForColumn:@"activityId"];
            currentSummary = [NSMutableDictionary dictionaryWithCapacity:20];
            data[currentId] = currentSummary;
        }
        currentValue = [GCActivitySummaryValue activitySummaryValueForResultSet:res];
        currentSummary[[res stringForColumn:@"field"]] = currentValue;
    }
    query = @"SELECT * FROM gc_activities_meta ORDER BY activityId DESC";
    res = [db executeQuery:query];
    while ([res next]) {
        if (![currentId isEqualToString:[res stringForColumn:@"activityId"]]) {
            currentId = [res stringForColumn:@"activityId"];
            currentMeta = [NSMutableDictionary dictionaryWithCapacity:20];
            meta[currentId] = currentMeta;
        }
        metaValue = [GCActivityMetaValue activityValueForResultSet:res];
        currentMeta[[res stringForColumn:@"field"]] = metaValue;
    }
    NSLog(@"Old Finished %@", perf);
    NSLog(@"Found %lu", (unsigned long) data.count);

}
-(void)actionDumpMissingFields{
    NSArray * missing = [GCFields missingPredefinedField];

    //[rv addObject:@[ info.field ?: @"missing", info.activityType ?: @"missing", info.uom ?: @"missing", info.displayName ?: @"missing"]];
    for (NSArray * one in missing) {
        RZLog(RZLogInfo, @"INSERT INTO table_name (activityType,field,uom,fieldDisplayName) VALUES ('%@','%@','%@','%@')", one[1], one[0], one[2], one[3]);
    }
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
    NSLog(@"%@", withPower);
    //[[GCAppGlobal derived] processActivities:withPower];
}
@end
