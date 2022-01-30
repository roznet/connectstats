//  MIT Licence
//
//  Created on 13/07/2014.
//
//  Copyright (c) 2014 Brice Rosenzweig.
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

#import "GCStatsMultiFieldConfig.h"
#import "GCViewIcons.h"
#import "GCHistoryFieldDataSerie.h"
#import "GCSimpleGraphCachedDataSource+Templates.h"
#import "GCDerivedGroupedSeries.h"
#import "GCAppGlobal.h"
#import "ConnectStats-Swift.h"

@interface GCStatsMultiFieldConfig ()
@property (nonatomic,retain) NSString * filterButtonTitle;
@property (nonatomic,retain) UIImage * filterButtonImage;

@property (nonatomic,assign) gcFieldFlag summaryCumulativeFieldFlag;
@property (nonatomic,retain) GCStatsCalendarAggregationConfig * calendarConfig;
@end

@implementation GCStatsMultiFieldConfig

-(GCStatsMultiFieldConfig*)init{
    self = [super init];
    if( self ){
        self.viewConfig = gcStatsViewConfigAll;
        self.viewChoice = gcViewChoiceSummary;
        self.calendarConfig = [GCStatsCalendarAggregationConfig globalConfigFor:NSCalendarUnitWeekOfYear];
        self.activityTypeSelection = RZReturnAutorelease([[GCActivityTypeSelection alloc] initWithActivityTypeDetail:GCActivityType.all matchPrimaryType:true]);

    }
    return self;
}

-(void)dealloc{
    [_filterButtonImage release];
    [_filterButtonTitle release];
    [_activityTypeSelection release];
    [_calendarConfig release];
    [super dealloc];
}

+(GCStatsMultiFieldConfig*)fieldListConfigFrom:(GCStatsMultiFieldConfig*)other{
    GCStatsMultiFieldConfig * rv = [[[GCStatsMultiFieldConfig alloc] init] autorelease];
    if (rv) {
        if (other!=nil) {
            rv.activityTypeSelection = RZReturnAutorelease([[GCActivityTypeSelection alloc] initWithSelection:other.activityTypeSelection]);
            rv.viewChoice = other.viewChoice;
            rv.useFilter = other.useFilter;
            rv.viewConfig = other.viewConfig;
            rv.graphChoice = other.graphChoice;
            rv.comparisonMetric = other.comparisonMetric;
            rv.calendarConfig = [GCStatsCalendarAggregationConfig configFrom:other.calendarConfig];
            rv.summaryCumulativeFieldFlag = other.summaryCumulativeFieldFlag;
        }else{
            rv.viewConfig = gcStatsViewConfigUnused;
            rv.viewChoice = gcViewChoiceSummary;
            rv.graphChoice = gcGraphChoiceBarGraph;
            rv.comparisonMetric = gcComparisonMetricNone;
            rv.calendarConfig = [GCStatsCalendarAggregationConfig globalConfigFor:kCalendarUnitNone];
            rv.summaryCumulativeFieldFlag = gcFieldFlagSumDistance;
            rv.activityTypeSelection = RZReturnAutorelease([[GCActivityTypeSelection alloc] initWithActivityTypeDetail:[[[GCAppGlobal organizer] currentActivity] activityTypeDetail]
                                                                                                      matchPrimaryType:true]);
        }
    }
    return rv;
}

-(GCStatsMultiFieldConfig*)sameFieldListConfig{
    return [GCStatsMultiFieldConfig fieldListConfigFrom:self];
}
-(NSString *)viewDescription{
    return [GCViewConfig viewChoiceDesc:self.viewChoice calendarConfig:self.calendarConfig];
}
-(GCActivityType*)activityTypeDetail {
    return self.activityTypeSelection.activityTypeDetail;
}

-(void)setActivityTypeDetails:(GCActivityType *)activityType{
    self.activityTypeSelection.activityTypeDetail = activityType;
}

-(NSString*)description{
    return [NSString stringWithFormat:@"<%@: %@ view:%@ calUnit:%@ config:%@ period:%@ gr:%@ comp:%@>", NSStringFromClass([self class]),
            self.activityType,
            self.viewChoiceKey,
            self.calendarConfig.calendarUnitKey,
            self.viewConfigKey,
            self.calendarConfig.periodTypeKey,
            self.graphChoiceKey,
            self.comparisonMetricKey
            ];
}

-(NSString*)diffDescription:(GCStatsMultiFieldConfig*)other{
    NSMutableArray * diff = [NSMutableArray array];
    NSDictionary * defs = @{
        @"type": @"activityType",
        @"view": @"viewChoiceKey",
        @"calUnit": @"calendarConfig.calendarUnitKey",
        @"config": @"viewConfigKey",
        @"period": @"calendarConfig.periodTypeKey",
        @"gr": @"graphChoiceKey",
        @"comp": @"comparisonMetricKey"
    };
    
    for (NSString * key in defs) {
        NSString * path = defs[key];
        NSString * value = [self valueForKeyPath:path];
        NSString * otherValue = [other valueForKeyPath:path];
        if( ! [value isEqualToString:otherValue] ){
            [diff addObject:[NSString stringWithFormat:@"%@:%@>%@", key, value,otherValue]];
        }
    }
    if( diff.count > 0){
        return [NSString stringWithFormat:@"(%@: %@)", NSStringFromClass([self class]), [diff componentsJoinedByString:@" "]];
    }else{
        return [NSString stringWithFormat:@"(%@: nodiff )", NSStringFromClass([self class])];
    }
}

-(NSString*)activityType{
    return self.activityTypeDetail.primaryActivityType.key;
}

-(BOOL)isEqual:(GCStatsMultiFieldConfig*)object{
    if( [object isKindOfClass:[GCStatsMultiFieldConfig class]]){
        return [self isEqualToConfig:object];
    }else{
        return FALSE;
    }
}

-(BOOL)isEqualToConfig:(GCStatsMultiFieldConfig*)other{
    return(
           [self.activityTypeSelection isEqualToSelection:other.activityTypeSelection] &&
           self.viewChoice==other.viewChoice &&
           self.useFilter == other.useFilter &&
           self.viewConfig==other.viewConfig &&
           self.historyStats==other.historyStats &&
           self.graphChoice == other.graphChoice &&
           self.comparisonMetric == other.comparisonMetric &&
           [self.calendarConfig isEqualToConfig:other.calendarConfig]
           );
}

-(BOOL)requiresAggregateRebuild:(GCStatsMultiFieldConfig*)other{
    return !(
             [self.activityTypeSelection isEqualToSelection:other.activityTypeSelection] &&
             self.viewChoice==other.viewChoice &&
             self.useFilter == other.useFilter &&
             self.viewConfig==other.viewConfig &&
             [self.calendarConfig isEqualToConfig:other.calendarConfig]
             );

}

-(gcHistoryStats)historyStats{
    return self.calendarConfig.historyStats;
}

-(NSString*)viewChoiceKey{
    switch (self.viewChoice) {
        case gcViewChoiceFields:
            return @"all";
        case gcViewChoiceCalendar:
            return @"calendar";
        case gcViewChoiceSummary:
            return @"summary";
    }
    return nil;
}

-(void)setViewChoiceKey:(NSString *)viewChoiceKey{
    if( [viewChoiceKey isEqualToString:@"all"]){
        self.viewChoice =  gcViewChoiceFields;
    }else if ([viewChoiceKey isEqualToString:@"calendar"]){
        self.viewChoice =  gcViewChoiceCalendar;
    }else if ([viewChoiceKey isEqualToString:@"summary"]){
        self.viewChoice =  gcViewChoiceSummary;
    }
    self.viewChoice =  gcViewChoiceSummary;
}

-(NSString*)viewConfigKey{
    switch(self.viewConfig){
        case gcStatsViewConfigAll:
            return @"all";
        case gcStatsViewConfigLast3M:
            return @"last3m";
        case gcStatsViewConfigLast6M:
            return @"last6m";
        case gcStatsViewConfigLast1Y:
            return @"last1y";
        case gcStatsViewConfigUnused:
            return @"unused";
    }
    return nil;
}

-(void)setViewConfigKey:(NSString *)viewConfigKey{
    if( [viewConfigKey isEqualToString:@"all"] ){
        self.viewConfig = gcStatsViewConfigAll;
    }else if( [viewConfigKey isEqualToString:@"last3m"] ){
        self.viewConfig = gcStatsViewConfigLast3M;
    }else if( [viewConfigKey isEqualToString:@"last6m"] ){
            self.viewConfig = gcStatsViewConfigLast6M;
    }else if( [viewConfigKey isEqualToString:@"last1y"] ){
        self.viewConfig = gcStatsViewConfigLast1Y;
    }else if( [viewConfigKey isEqualToString:@"unused"] ){
        self.viewConfig = gcStatsViewConfigUnused;
    }
    self.viewConfig = gcStatsViewConfigUnused;
}

-(NSString*)comparisonMetricKey{
    switch( self.comparisonMetric ){
        case gcComparisonMetricValue:
            return @"value";
        case gcComparisonMetricPercent:
            return @"percent";
        case gcComparisonMetricValueDifference:
            return @"valuediff";
        case gcComparisonMetricNone:
        default:
            return @"none";
    }
}

-(void)setComparisonMetricKey:(NSString*)comparisonKey{
    if( [comparisonKey isEqualToString:@"value"]){
        self.comparisonMetric = gcComparisonMetricValue;
    }else if( [comparisonKey isEqualToString:@"percent"]){
        self.comparisonMetric = gcComparisonMetricPercent;
    }else if( [comparisonKey isEqualToString:@"valuediff"]){
        self.comparisonMetric = gcComparisonMetricValueDifference;
    }else{
        self.comparisonMetric = gcComparisonMetricNone;
    }
}

-(NSString*)graphChoiceKey{
    return self.graphChoice == gcGraphChoiceCumulative ? @"cum" : @"bar";
}

-(void)setGraphChoiceKey:(NSString *)graphChoiceKey{
    if( [graphChoiceKey isEqualToString:@"cum"] ){
        self.graphChoice = gcGraphChoiceCumulative;
    }else{
        self.graphChoice = gcGraphChoiceBarGraph;
    }
}

-(BOOL)nextView{
    switch (self.viewChoice) {
        case gcViewChoiceFields:
        {
            self.viewChoice = gcViewChoiceCalendar;
            self.viewConfig = gcStatsViewConfigLast1Y;
            self.calendarConfig.calendarUnit = NSCalendarUnitWeekOfYear;
            self.calendarConfig.periodType = gcPeriodCalendar;
            self.graphChoice = gcGraphChoiceBarGraph;
            break;
        }
        case gcViewChoiceCalendar:
        {
            BOOL done = [self.calendarConfig nextCalendarUnit];
            if( done || self.calendarConfig.calendarUnit == kCalendarUnitNone){
                self.viewChoice = gcViewChoiceSummary;
                self.viewConfig = gcStatsViewConfigUnused;
                self.calendarConfig.calendarUnit = kCalendarUnitNone;
            }
            if( self.calendarConfig.calendarUnit == NSCalendarUnitYear){
                self.viewConfig = gcStatsViewConfigAll;
                self.graphChoice = gcGraphChoiceBarGraph;
            }else{
                self.viewConfig = gcStatsViewConfigLast1Y;
                self.graphChoice = gcGraphChoiceBarGraph;
            }
            break;
        }
        case gcViewChoiceSummary:
        {
            self.viewChoice = gcViewChoiceFields;
            self.viewConfig = gcStatsViewConfigUnused;
            self.calendarConfig.calendarUnit = NSCalendarUnitWeekOfYear;
            break;
        }
    }
    // summary is the first
    return (self.viewChoice == gcViewChoiceSummary);
}

-(BOOL)nextViewConfig{
    if( [GCViewConfig is2021Style]){
        return [self nextViewConfigNewStyle];
    }else{
        return [self nextViewConfigOldStyle];
    }
}

-(BOOL)nextViewConfigNewStyle{
    BOOL rv = false;
    
    switch (self.viewChoice ){
        case gcViewChoiceSummary:
        {
            // no config for summary;
            self.viewConfig = gcStatsViewConfigAll;
            rv = true;
            break;
        }
        case gcViewChoiceFields:
        {
            // View all Fields, then rotate between view week or month
            // if comes as anything but end, next is end nd use calendarUnit
            // (if was switch to all then next is End/CalUnit)
            self.viewConfig = gcStatsViewConfigUnused;
            if( [self.calendarConfig nextCalendarUnit] ){
                rv = true;
            }
            break;
        }
        case gcViewChoiceCalendar:
        {
            rv = [self nextViewConfigCalendar];
            break;
        }
    }

    return rv;
}

-(BOOL)nextViewConfigCalendar{
    BOOL rv = false;
    // View monthly, weekly or yearly aggregated stats
    // :          all,  last3m, last6m, last1y, todate
    // viewConfig last1y
    // periodType cal,             todate
    // metrics    none, val, pct,  none, val, pct
    // graph W|M  bar,  cum, cum,  bar,  cum, cum
    
    self.viewConfig = gcStatsViewConfigLast1Y;
    NSCalendarUnit calUnit = self.calendarConfig.calendarUnit;
    if (calUnit == NSCalendarUnitWeekOfYear) {
        self.viewConfig = gcStatsViewConfigLast1Y;
    }else if(calUnit == NSCalendarUnitMonth){
        self.viewConfig = gcStatsViewConfigLast1Y;
    }else if(calUnit == NSCalendarUnitYear){
        self.viewConfig = gcStatsViewConfigAll;
    }
    
    self.comparisonMetric++;
    if( self.comparisonMetric == gcComparisonMetricValueDifference || self.comparisonMetric == gcComparisonMetricPercent ){
        self.graphChoice = gcGraphChoiceCumulative;
    }else{
        self.graphChoice = gcGraphChoiceBarGraph;
    }
    
    if( self.comparisonMetric == gcComparisonMetricValue){
        self.comparisonMetric = gcComparisonMetricNone;
        if( self.calendarConfig.periodType == gcPeriodToDate ){
            self.calendarConfig.periodType = gcPeriodCalendar;
            rv = true;
        }else if( self.calendarConfig.periodType == gcPeriodCalendar){
            self.calendarConfig.periodType = gcPeriodToDate;
        }
    }
    return rv;
}

-(BOOL)nextViewConfigOldStyle{
    BOOL rv = false;
    
    switch (self.viewChoice ){
        case gcViewChoiceSummary:
        {
            // no config for summary;
            self.viewConfig = gcStatsViewConfigAll;
            rv = true;
            break;
        }
        case gcViewChoiceFields:
        {
            // View all Fields, then rotate between view week or month
            // if comes as anything but end, next is end nd use calendarUnit
            // (if was switch to all then next is End/CalUnit)
            self.viewConfig = gcStatsViewConfigUnused;
            if( [self.calendarConfig nextCalendarUnit] ){
                rv = true;
            }
            break;
        }
        case gcViewChoiceCalendar:
        { // View monthly, weekly or yearly aggregated stats
            // :          all, last3m, last6m, last1y, todate
            // viewConfig all, last3m, last6m, last1y, 1m:last1y|1w:last6m
            // periodType cal, cal,    cal,    cal,    todate
            
            gcStatsViewConfig start = gcStatsViewConfigUnused;
            gcStatsViewConfig todate = gcStatsViewConfigUnused;
            NSCalendarUnit calUnit = self.calendarConfig.calendarUnit;
            if (calUnit == NSCalendarUnitWeekOfYear) {
                start = gcStatsViewConfigLast3M;
                todate = gcStatsViewConfigLast6M;
            }else if(calUnit == NSCalendarUnitMonth){
                start = gcStatsViewConfigLast6M;
                todate = gcStatsViewConfigLast1Y;
            }
            
            // if all and todate: end of the cycle, start again
            // don't change viewConfig as remains all, but switch back to calendar period
            // otherwise start at next one.
            if (self.calendarConfig.periodType == gcPeriodToDate) {
                self.calendarConfig.periodType = gcPeriodCalendar;
                self.viewConfig = gcStatsViewConfigAll;
                rv = true;
            }else if( self.viewConfig == gcStatsViewConfigAll){
                self.viewConfig = start;
            }else{
                self.viewConfig++;
            }
            // When reach unused, go to the todate config
            if (self.viewConfig >= gcStatsViewConfigUnused) {
                self.viewConfig = todate;
                self.calendarConfig.periodType = gcPeriodToDate;
            }
            break;
        }
    }

    return rv;
}

-(NSDate*)selectAfterDateFrom:(NSDate*)lastDate{
    NSDate * afterDate = nil;
    NSString * compstr = nil;
    if (self.viewChoice == gcViewChoiceFields ||self.viewChoice == gcViewChoiceSummary) {
        switch (self.historyStats) {
            case gcHistoryStatsMonth:
                compstr = @"-1Y";
                break;
            case gcHistoryStatsWeek:
                compstr = @"-3M";
                break;
            case gcHistoryStatsYear:
                compstr = @"-5Y";
                break;
            case gcHistoryStatsAll:
            case gcHistoryStatsEnd:
                compstr = nil;
                break;
        }
    }else{
        switch (self.viewConfig) {
            case gcStatsViewConfigLast1Y:
                compstr = @"-1Y";
                break;
            case gcStatsViewConfigLast3M:
                compstr = @"-3M";
                break;
            case gcStatsViewConfigLast6M:
                compstr = @"-6M";
                break;
            case gcStatsViewConfigAll:
            case gcStatsViewConfigUnused:
                break;
        }
    }
    if (compstr) {
        afterDate = [lastDate dateByAddingGregorianComponents:[NSDateComponents dateComponentsFromString:compstr]];
    }
    return afterDate;
}

#pragma mark - Setups

-(UIBarButtonItem*)viewChoiceButtonForTarget:(id)target action:(SEL)sel longPress:(SEL)longPressSel{
    NSString * title = self.viewDescription;
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button addGestureRecognizer:RZReturnAutorelease([[UITapGestureRecognizer alloc] initWithTarget:target action:sel])];
    if(longPressSel){
        [button addGestureRecognizer:RZReturnAutorelease(([[UILongPressGestureRecognizer alloc] initWithTarget:target action:longPressSel]))];
    }
    
    UIBarButtonItem * rv = RZReturnAutorelease([[UIBarButtonItem alloc] initWithCustomView:button]);

    return rv;
}

-(UIBarButtonItem*)viewConfigButtonForTarget:(id)target action:(SEL)sel longPress:(SEL)longPressSel{
    [self setupButtonInfo];

    UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
    
    if (self.filterButtonImage) {
        [button setImage:self.filterButtonImage forState:UIControlStateNormal];
        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }else if (self.filterButtonTitle){
        [button setTitle:self.filterButtonTitle forState:UIControlStateNormal];
    }
    [button addGestureRecognizer:RZReturnAutorelease([[UITapGestureRecognizer alloc] initWithTarget:target action:sel])];
    if(longPressSel){
        [button addGestureRecognizer:RZReturnAutorelease(([[UILongPressGestureRecognizer alloc] initWithTarget:target action:longPressSel]))];
    }
    UIBarButtonItem * rv = RZReturnAutorelease([[UIBarButtonItem alloc] initWithCustomView:button]);
    return rv;
}

-(void)setupButtonInfo{
    UIImage * image = nil;
    if (self.viewChoice==gcViewChoiceFields ) {
        switch (self.historyStats) {
            case gcHistoryStatsMonth:
                image = [GCViewIcons navigationIconFor:gcIconNavMonthly];
                break;
            case gcHistoryStatsWeek:
                image = [GCViewIcons navigationIconFor:gcIconNavWeekly];
                break;
            case gcHistoryStatsYear:
                image = [GCViewIcons navigationIconFor:gcIconNavYearly];
                break;
            case gcHistoryStatsAll:
            case gcHistoryStatsEnd:
                image = [GCViewIcons navigationIconFor:gcIconNavAggregated];
                break;
        }
    }else if (self.viewChoice==gcViewChoiceSummary){
        image = nil;
    }else{
        if( [GCViewConfig is2021Style]){
            NSMutableArray * iconNameComponent = [NSMutableArray array];
            // monthly, weekly, yearly
            [iconNameComponent addObject:self.calendarConfig.calendarUnitKey];
            // todate, calendar, rolling
            [iconNameComponent addObject:self.calendarConfig.periodTypeKey];
            if( self.comparisonMetric != gcComparisonMetricNone){
                [iconNameComponent addObject:@"compare"];
            }
            image = [UIImage imageNamed:[iconNameComponent componentsJoinedByString:@"-"]];
            if( image == nil){
                RZLog(RZLogInfo,@"Missing icon %@", [iconNameComponent componentsJoinedByString:@"-"] );
            }
        }else{
            if( self.calendarConfig.periodType == gcPeriodToDate){
                image = nil;
            }else{
                switch (self.viewConfig) {
                    case gcStatsViewConfigLast3M:
                        image = [GCViewIcons navigationIconFor:gcIconNavQuarterly];
                        break;
                    case gcStatsViewConfigLast6M:
                        image = [GCViewIcons navigationIconFor:gcIconNavSemiAnnually];
                        break;
                    case gcStatsViewConfigLast1Y:
                        image = [GCViewIcons navigationIconFor:gcIconNavYearly];
                        break;
                    case gcStatsViewConfigAll:
                    case gcStatsViewConfigUnused:
                        image = nil;//[GCViewIcons navigationIconFor:gcIconNavAggregated];
                        break;
                        
                }
            }
            
        }
    }
    NSString * calTitle = NSLocalizedString(@"All", @"Button Calendar");
    if (self.viewChoice == gcViewChoiceSummary) {
        calTitle = nil;
    }
    if (self.calendarConfig.periodType == gcPeriodToDate) {
        NSCalendarUnit calUnit = self.calendarConfig.calendarUnit;
        if (calUnit == NSCalendarUnitYear) {
            calTitle = NSLocalizedString(@"YTD", @"Button Calendar");
        }else if (calUnit == NSCalendarUnitWeekOfYear){
            calTitle= NSLocalizedString(@"WTD", @"Button Calendar");
        }else if (calUnit == NSCalendarUnitMonth){
            calTitle= NSLocalizedString(@"MTD", @"Button Calendar");
        }
    }

    self.filterButtonImage = image;
    self.filterButtonTitle = calTitle;
}

-(GCSimpleGraphCachedDataSource*)dataSourceForFieldDataSerie:(GCHistoryFieldDataSerie*)fieldDataSerie{
    GCField * field = fieldDataSerie.activityField;
    GCSimpleGraphCachedDataSource * cache = nil;
    gcGraphChoice choice = self.graphChoice;

    NSDate * afterdate = nil;
    NSCalendarUnit calunit = NSCalendarUnitWeekOfYear;
    if (self.viewChoice == gcViewChoiceFields ||self.viewChoice == gcViewChoiceSummary) {
        switch (self.historyStats) {
            case gcHistoryStatsMonth:
                calunit = NSCalendarUnitMonth;
                break;
            case gcHistoryStatsWeek:
                calunit = NSCalendarUnitWeekOfYear;
                break;
            case gcHistoryStatsYear:
                calunit = NSCalendarUnitYear;
                break;
            case gcHistoryStatsAll:
            case gcHistoryStatsEnd:
                calunit = NSCalendarUnitYear;
                if ([field canSum]){
                    choice = gcGraphChoiceCumulative;
                }else{
                    choice = gcGraphChoiceBarGraph;
                    calunit = NSCalendarUnitMonth;
                }
                break;
        }
    }else{
        calunit = self.calendarConfig.calendarUnit;
    }
    afterdate = [self selectAfterDateFrom:fieldDataSerie.lastDate];

    cache = [GCSimpleGraphCachedDataSource historyView:fieldDataSerie
                                        calendarConfig:[self.calendarConfig equivalentConfigFor:calunit]
                                           graphChoice:choice
                                                 after:afterdate];
    if (self.calendarConfig.periodType == gcPeriodToDate &&  self.viewChoice == gcViewChoiceCalendar) {
        [cache setupAsBackgroundGraph];
        GCHistoryFieldDataSerie * cut = [fieldDataSerie serieWithCutOff:self.calendarConfig.cutOff
                                                         inCalendarUnit:calunit
                                                      withReferenceDate:nil];
        GCSimpleGraphCachedDataSource * main = [GCSimpleGraphCachedDataSource historyView:cut
                                                                           calendarConfig:self.calendarConfig
                                                                              graphChoice:choice
                                                                                    after:afterdate];
        [main addDataSource:cache];
        cache = main;
    }
    return cache;
}

-(void)nextSummaryCumulativeField{
    if( self.summaryCumulativeFieldFlag == gcFieldFlagSumDistance ){
        self.summaryCumulativeFieldFlag = gcFieldFlagSumDuration;
    }else if( self.summaryCumulativeFieldFlag == gcFieldFlagSumDuration){
        self.summaryCumulativeFieldFlag = gcFieldFlagAltitudeMeters;
    }else if( self.summaryCumulativeFieldFlag == gcFieldFlagAltitudeMeters){
        self.summaryCumulativeFieldFlag = gcFieldFlagSumDistance;
    }else{
        self.summaryCumulativeFieldFlag = gcFieldFlagSumDistance;
    }
}


#pragma mark - cumulative Summary Field

-(GCField*)currentCumulativeSummaryField{
    // Ignore any value other than sumDuration or SumDistance
    if( self.summaryCumulativeFieldFlag != gcFieldFlagSumDistance && self.summaryCumulativeFieldFlag != gcFieldFlagSumDuration && self.summaryCumulativeFieldFlag != gcFieldFlagAltitudeMeters){
        self.summaryCumulativeFieldFlag = gcFieldFlagSumDistance;
    }
    
    gcFieldFlag which = self.summaryCumulativeFieldFlag;
    
    return [GCField fieldForFlag:which andActivityType:self.activityType];
}
@end
