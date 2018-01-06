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

-(gcViewChoice)viewChoiceFromString:(NSString*)val default:(gcViewChoice)def{
    gcViewChoice rv = def;
    NSString * vallower = [val lowercaseString];
    if ([vallower isEqualToString:@"all"]) {
        rv = gcViewChoiceAll;
    }else if ([vallower isEqualToString:@"weekly"]){
        rv = gcViewChoiceWeekly;
    }else if ([vallower isEqualToString:@"monthly"]){
        rv = gcViewChoiceMonthly;
    }else if ([vallower isEqualToString:@"yearly"]){
        rv = gcViewChoiceYearly;
    }else if ([vallower isEqualToString:@"summary"]){
        rv = gcViewChoiceSummary;
    }
    return  rv;
}

-(gcHistoryStats)historyStatsFromString:(NSString*)val default:(gcHistoryStats)def{
    gcHistoryStats rv = def;

    NSString*vallower = [val lowercaseString];
    if ([vallower isEqualToString:@"all"]) {
        rv = gcHistoryStatsAll;
    }else if ([vallower isEqualToString:@"week"]){
        rv = gcHistoryStatsWeek;
    }else if ([vallower isEqualToString:@"month"]){
        rv = gcHistoryStatsMonth;
    }
    return rv;
}
-(gcStatsCalChoice)statsCalChoiceFromString:(NSString*)val default:(gcStatsCalChoice)def{
    gcStatsCalChoice rv = def;
    NSString * vallower = [val lowercaseString];
    if ([vallower isEqualToString:@"all"]) {
        rv = gcStatsCalAll;
    }else if ([vallower isEqualToString:@"3m"]){
        rv = gcStatsCal3M;
    }else if ([vallower isEqualToString:@"1y"]){
        rv = gcStatsCal1Y;
    }else if ([vallower isEqualToString:@"6m"]){
        rv = gcStatsCal6M;
    }else if ([vallower isEqualToString:@"todate"]){
        rv = gcStatsCalToDate;
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

    GCStatsMultiFieldConfig * nconfig = [GCStatsMultiFieldConfig fieldListConfigFrom:vc.config];

    if (vals[kArgumentViewChoice]) {
        nconfig.viewChoice = [self viewChoiceFromString:vals[kArgumentViewChoice] default:nconfig.viewChoice];
    }
    if (vals[kArgumentActivityType]) {
        nconfig.activityType = [self activityTypeFromString:vals[kArgumentActivityType] default:nconfig.activityType];
    }
    if (vals[kArgumentCalChoice]) {
        nconfig.calChoice = [self statsCalChoiceFromString:vals[kArgumentCalChoice] default:nconfig.calChoice];
    }
    if (vals[kArgumentHistoryStats]) {
        nconfig.historyStats = [self historyStatsFromString:vals[kArgumentHistoryStats] default:nconfig.historyStats];
    }

    [vc setupForFieldListConfig:nconfig];
}

-(void)actionFocusOnListAndRefresh:(RZAction*)action{
    [GCAppGlobal searchAllActivities];
    [[self appActionDelegate] beginRefreshing];
}

@end
