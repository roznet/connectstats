//  MIT Licence
//
//  Created on 20/09/2015.
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

#import "GCAppActions.h"
#import "GCAppGlobal.h"
#import "GCAppDelegate.h"
#import "GCFields.h"

NSString * kArgumentActivityType = @"activityType";
NSString * kArgumentViewChoice   = @"viewChoice";
NSString * kArgumentActivityId   = @"activityId";
NSString * kArgumentCalChoice    = @"calChoice";
NSString * kArgumentHistoryStats = @"historyStats";

@interface GCAppActions ()
// Can stay private?
-(void)actionFocusOnActivity:(RZAction*)action;
-(void)actionFocusOnStatsSummary:(RZAction*)action;
-(void)actionFocusOnListAndRefresh:(RZAction*)action;

@end

@implementation GCAppActions

+(instancetype)appActions{
    return [[[GCAppActions alloc] init] autorelease];
}
-(NSObject<GCAppActionDelegate>*)appActionDelegate{
    GCAppDelegate * app = (GCAppDelegate*)[UIApplication sharedApplication].delegate;
    return [app actionDelegate];
}

-(BOOL)execute:(NSURL*)url{
    RZAction * action = [RZAction actionFromUrl:url withPrefix:@"/app-ios/c/"];
    BOOL rv = false;
    if ([action.methodName hasPrefix:@"action"]) {
        RZLog(RZLogInfo, @"Trying %@", action);
        rv = [action executeOn:self];
    }else{
        RZLog(RZLogInfo, @"Skipping %@", url.path);
    }
    return rv;
}

#pragma mark - Parsing Of Arguments

-(BOOL)setupMultiFieldConfig:(GCStatsMultiFieldConfig*)config fromChoice:(NSString*)val{
    BOOL rv = true;
    NSString * vallower = [val lowercaseString];
    if ([vallower isEqualToString:@"all"]) {
        config.viewChoice = gcViewChoiceAll;
    }else if ([vallower isEqualToString:@"weekly"]){
        config.viewChoice = gcViewChoiceCalendar;
        config.calendarConfig.calendarUnit = NSCalendarUnitWeekOfYear;
    }else if ([vallower isEqualToString:@"monthly"]){
        config.viewChoice = gcViewChoiceCalendar;
        config.calendarConfig.calendarUnit = NSCalendarUnitMonth;
    }else if ([vallower isEqualToString:@"yearly"]){
        config.viewChoice = gcViewChoiceCalendar;
        config.calendarConfig.calendarUnit = NSCalendarUnitMonth;
    }else if ([vallower isEqualToString:@"summary"]){
        config.viewChoice = gcViewChoiceSummary;
    }else{
        rv = false;
    }
    return  rv;
}

-(gcStatsViewConfig)statsCalChoiceFromString:(NSString*)val default:(gcStatsViewConfig)def{
    gcStatsViewConfig rv = def;
    NSString * vallower = [val lowercaseString];
    if ([vallower isEqualToString:@"all"]) {
        rv = gcStatsViewConfigAll;
    }else if ([vallower isEqualToString:@"3m"]){
        rv = gcStatsViewConfigLast3M;
    }else if ([vallower isEqualToString:@"1y"]){
        rv = gcStatsViewConfigLast1Y;
    }else if ([vallower isEqualToString:@"6m"]){
        rv = gcStatsViewConfigLast6M;
    }else if ([vallower isEqualToString:@"todate"]){
        rv = gcStatsViewConfigToDate;
    }
    return rv;
}

-(NSString*)activityTypeFromString:(NSString*)val default:(NSString*)def{
    NSString * rv = def;
    if (val) {
        NSArray * valid = [[GCAppGlobal organizer] listActivityTypes];
        if ([valid containsObject:val]) {
            rv = val;
        }
    }
    return rv;
}

#pragma mark - Actions

-(void)actionFocusOnActivity:(RZAction*)action{
    NSString * activityId = nil;
    NSDictionary * dict = [action argumentAsDictionary];

    if (action.argumentCount == 1) {
        activityId = action.argumentAsString;
    }else{
        activityId = dict[kArgumentActivityId];
    }

    [[self appActionDelegate] focusOnActivityId:activityId];
}

-(void)actionFocusOnStatsSummary:(RZAction*)action{
    [[self appActionDelegate] focusOnStatsSummary];
    GCStatsMultiFieldViewController * vc = [[self appActionDelegate] fieldListViewController];
    [vc.navigationController popToRootViewControllerAnimated:YES];

    NSDictionary * vals = [action argumentAsDictionary];

    GCStatsMultiFieldConfig * nconfig = [GCStatsMultiFieldConfig fieldListConfigFrom:vc.multiFieldConfig];

    if (vals[kArgumentViewChoice]) {
        [self setupMultiFieldConfig:nconfig fromChoice:vals[kArgumentViewChoice]];
    }
    if (vals[kArgumentActivityType]) {
        nconfig.activityType = [self activityTypeFromString:vals[kArgumentActivityType] default:nconfig.activityType];
    }
    if (vals[kArgumentCalChoice]) {
        nconfig.viewConfig = [self statsCalChoiceFromString:vals[kArgumentCalChoice] default:nconfig.viewConfig];
    }
    if (vals[kArgumentHistoryStats]) {
        nconfig.calendarConfig.calendarUnitKey = vals[kArgumentHistoryStats];
    }

    [vc setupForFieldListConfig:nconfig];
}

-(void)actionFocusOnListAndRefresh:(RZAction*)action{
    [GCAppGlobal searchRecentActivities];
    [[self appActionDelegate] beginRefreshing];
}

@end
