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
    }
    return self;
}

-(void)dealloc{
    [_filterButtonImage release];
    [_filterButtonTitle release];
    [_activityType release];
    [super dealloc];
}

+(GCStatsMultiFieldConfig*)fieldListConfigFrom:(GCStatsMultiFieldConfig*)other{
    GCStatsMultiFieldConfig * rv = [[[GCStatsMultiFieldConfig alloc] init] autorelease];
    if (rv) {
        if (other!=nil) {
            rv.activityType = other.activityType;
            rv.viewChoice = other.viewChoice;
            rv.useFilter = other.useFilter;
            rv.viewConfig = other.viewConfig;
            rv.graphChoice = other.graphChoice;
            rv.calendarConfig = [GCStatsCalendarAggregationConfig configFrom:other.calendarConfig];
        }else{
            rv.viewConfig = gcStatsViewConfigUnused;
            rv.viewChoice = gcViewChoiceSummary;
            rv.calendarConfig = [GCStatsCalendarAggregationConfig globalConfigFor:kCalendarUnitNone];
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
-(NSString*)description{
    return [NSString stringWithFormat:@"<%@: %@ view:%@ calUnit:%@ config:%@ period:%@ gr:%@>", NSStringFromClass([self class]),
            self.activityType,
            self.viewChoiceKey,
            self.calendarConfig.calendarUnitKey,
            self.viewConfigKey,
            self.calendarConfig.periodTypeKey,
            self.graphChoiceKey
            ];
}

-(BOOL)isEqual:(GCStatsMultiFieldConfig*)object{
    if( [object isKindOfClass:[GCStatsMultiFieldConfig class]]){
        return [self isEqualToConfig:object];
    }else{
        return FALSE;
    }
}

-(BOOL)isEqualToConfig:(GCStatsMultiFieldConfig*)other{
    return [self.activityType isEqualToString:other.activityType] && self.viewChoice==other.viewChoice &&
    self.useFilter == other.useFilter && self.viewConfig==other.viewConfig && self.historyStats==other.historyStats &&
    self.graphChoice == other.graphChoice &&
    [self.calendarConfig isEqualToConfig:other.calendarConfig];
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
            self.viewConfig = gcStatsViewConfigAll;
            self.calendarConfig.calendarUnit = NSCalendarUnitWeekOfYear;
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
                self.graphChoice = gcGraphChoiceCumulative;
            }else{
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
            // viewConfig all, last3m, last6m, last1y, all
            // periodType cal, cal,    cal,    cal,    todate
            
            gcStatsViewConfig start = gcStatsViewConfigUnused;
            NSCalendarUnit calUnit = self.calendarConfig.calendarUnit;
            if (calUnit == NSCalendarUnitWeekOfYear) {
                start = gcStatsViewConfigLast3M;
            }else if(calUnit == NSCalendarUnitMonth){
                start = gcStatsViewConfigLast6M;
            }
            
            // if all and todate: end of the cycle, start again
            // don't change viewConfig as remains all, but switch back to calendar period
            // otherwise start at next one.
            if (self.viewConfig==gcStatsViewConfigAll) {
                if( self.calendarConfig.periodType == gcPeriodToDate ){
                    self.calendarConfig.periodType = gcPeriodCalendar;
                    rv = true;
                }else{
                    self.viewConfig = start;
                }
            }else{
                self.viewConfig++;
            }
            if (self.viewConfig >= gcStatsViewConfigUnused) {
                self.viewConfig = gcStatsViewConfigAll;
                self.calendarConfig.periodType = gcPeriodToDate;
            }
            break;
        }
    }

    return rv;
}

#pragma mark - Setups


-(UIBarButtonItem*)buttonForTarget:(id)target action:(SEL)sel{
    [self setupButtonInfo];
    UIBarButtonItem * cal = nil;

    if (self.filterButtonImage) {
        cal = [[[UIBarButtonItem alloc] initWithImage:self.filterButtonImage
                                                style:UIBarButtonItemStylePlain
                                               target:target
                                               action:sel] autorelease];
    }else if (self.filterButtonTitle){
        cal = [[[UIBarButtonItem alloc] initWithTitle:self.filterButtonTitle
                                                style:UIBarButtonItemStylePlain
                                               target:target
                                               action:sel] autorelease];
    }
    return cal;
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
    NSString * compstr = nil;
    NSCalendarUnit calunit = NSCalendarUnitWeekOfYear;
    if (self.viewChoice == gcViewChoiceFields ||self.viewChoice == gcViewChoiceSummary) {
        switch (self.historyStats) {
            case gcHistoryStatsMonth:
                compstr = @"-1Y";
                calunit = NSCalendarUnitMonth;
                break;
            case gcHistoryStatsWeek:
                compstr = @"-3M";
                calunit = NSCalendarUnitWeekOfYear;
                break;
            case gcHistoryStatsYear:
                compstr = @"-5Y";
                calunit = NSCalendarUnitYear;
                break;
            case gcHistoryStatsAll:
            case gcHistoryStatsEnd:
                compstr = nil;
                calunit = NSCalendarUnitYear;
                if ([field canSum]){
                    choice = gcGraphChoiceCumulative;
                }else{
                    compstr = @"-1Y";
                    choice = gcGraphChoiceBarGraph;
                    calunit = NSCalendarUnitMonth;
                }
                break;
        }
    }else{
        calunit = self.calendarConfig.calendarUnit;
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
        afterdate = [[fieldDataSerie lastDate] dateByAddingGregorianComponents:[NSDateComponents dateComponentsFromString:compstr]];
    }

    cache = [GCSimpleGraphCachedDataSource historyView:fieldDataSerie
                                        calendarConfig:[self.calendarConfig equivalentConfigFor:calunit]
                                           graphChoice:choice
                                                 after:afterdate];
    if (self.calendarConfig.periodType == gcPeriodToDate &&  self.viewChoice == gcViewChoiceCalendar) {
        [cache setupAsBackgroundGraph];
        GCHistoryFieldDataSerie * cut = [fieldDataSerie serieWithCutOff:fieldDataSerie.lastDate inCalendarUnit:calunit withReferenceDate:nil];
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
    if( self.summaryCumulativeFieldFlag != gcFieldFlagSumDuration ){
        self.summaryCumulativeFieldFlag = gcFieldFlagSumDuration;
    }else{
        self.summaryCumulativeFieldFlag = gcFieldFlagSumDistance;
    }

}


#pragma mark - cumulative Summary Field

-(GCField*)currentCumulativeSummaryField{
    // Ignore any value other than sumDuration or SumDistance
    gcFieldFlag which = self.summaryCumulativeFieldFlag == gcFieldFlagSumDuration ? gcFieldFlagSumDuration : gcFieldFlagSumDistance;
    return [GCField fieldForFlag:which andActivityType:self.activityType];
}
@end
