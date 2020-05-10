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

@property (nonatomic,assign) NSUInteger derivedSerieMonthIndex;
@property (nonatomic,assign) NSUInteger derivedSerieFieldIndex;
@property (nonatomic,assign) gcFieldFlag summaryCumulativeFieldFlag;

@end

@implementation GCStatsMultiFieldConfig

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
            rv.calChoice = other.calChoice;
            rv.historyStats = other.historyStats;
        }else{
            rv.calChoice = gcStatsCalAll;
            rv.historyStats = gcHistoryStatsWeek;
        }
    }
    return rv;
}
-(GCStatsMultiFieldConfig*)sameFieldListConfig{
    return [GCStatsMultiFieldConfig fieldListConfigFrom:self];
}

-(NSString*)description{
    return [NSString stringWithFormat:@"<%@: %@ %@>", NSStringFromClass([self class]),
                self.activityType,
                [GCViewConfig viewChoiceDesc:self.viewChoice]
            ];
}

-(BOOL)isEqualToConfig:(GCStatsMultiFieldConfig*)other{
    return [self.activityType isEqualToString:other.activityType] && self.viewChoice==other.viewChoice && self.useFilter == other.useFilter
    && self.calChoice==other.calChoice && self.historyStats==other.historyStats;
}

-(GCStatsMultiFieldConfig*)nextViewChoiceConfig{
    GCStatsMultiFieldConfig * rv = [GCStatsMultiFieldConfig fieldListConfigFrom:self];
    rv.viewChoice = [GCViewConfig nextViewChoice:self.viewChoice];
    return rv;
}

-(GCStatsMultiFieldConfig*)configForNextFilter{
    GCStatsMultiFieldConfig * nconfig = [GCStatsMultiFieldConfig fieldListConfigFrom:self];
    // View all Fields, then rotate between view week or month
    if (nconfig.viewChoice == gcViewChoiceAll || nconfig.viewChoice == gcViewChoiceSummary) {
        switch (nconfig.historyStats) {
            case gcHistoryStatsAll:
                nconfig.historyStats = gcHistoryStatsWeek;
                break;
            case gcHistoryStatsWeek:
                nconfig.historyStats = gcHistoryStatsMonth;
                break;
            default:
                nconfig.historyStats = gcHistoryStatsAll;
                break;
        }
    }else{ // View monthly, weekly or yearly aggregated stats
        gcStatsCalChoice start = gcStatsCalAll;
        if (nconfig.viewChoice==gcViewChoiceWeekly) {
            start = gcStatsCal3M;
        }else if(nconfig.viewChoice==gcViewChoiceMonthly){
            start = gcStatsCal6M;
        }else{
            start = gcStatsCalToDate;
        }
        if (nconfig.calChoice==gcStatsCalAll) {
            nconfig.calChoice = start;
        }else{
            nconfig.calChoice++;
        }
        if (nconfig.calChoice >= gcStatsCalEnd) {
            nconfig.calChoice = gcStatsCalAll;
        }
    }

    return nconfig;
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
    if (self.viewChoice==gcViewChoiceAll ) {
        switch (self.historyStats) {
            case gcHistoryStatsMonth:
                image = [GCViewIcons navigationIconFor:gcIconNavMonthly];
                break;
            case gcHistoryStatsWeek:
                image = [GCViewIcons navigationIconFor:gcIconNavWeekly];
                break;
            default:
                image = [GCViewIcons navigationIconFor:gcIconNavAggregated];
                break;
        }
    }else if (self.viewChoice==gcViewChoiceSummary){
        image = nil;
    }else{
        switch (self.calChoice) {
            case gcStatsCal3M:
                image = [GCViewIcons navigationIconFor:gcIconNavQuarterly];
                break;
            case gcStatsCal6M:
                image = [GCViewIcons navigationIconFor:gcIconNavSemiAnnually];
                break;
            case gcStatsCal1Y:
                image = [GCViewIcons navigationIconFor:gcIconNavYearly];
                break;
            case gcStatsCalToDate:
            case gcStatsCalAll:
            case gcStatsCalEnd:
                image = nil;//[GCViewIcons navigationIconFor:gcIconNavAggregated];
                break;

        }
    }
    NSString * calTitle = NSLocalizedString(@"All", @"Button Calendar");
    if (self.viewChoice == gcViewChoiceSummary) {
        calTitle = nil;
    }
    if (self.calChoice == gcStatsCalToDate) {
        if (self.viewChoice == gcViewChoiceYearly) {
            calTitle = NSLocalizedString(@"YTD", @"Button Calendar");
        }else if (self.viewChoice == gcViewChoiceWeekly){
            calTitle= NSLocalizedString(@"WTD", @"Button Calendar");
        }else if (self.viewChoice == gcViewChoiceMonthly){
            calTitle= NSLocalizedString(@"MTD", @"Button Calendar");
        }
    }

    self.filterButtonImage = image;
    self.filterButtonTitle = calTitle;
}

-(GCSimpleGraphCachedDataSource*)dataSourceForFieldDataSerie:(GCHistoryFieldDataSerie*)fieldDataSerie{
    GCField * field = fieldDataSerie.activityField;
    GCSimpleGraphCachedDataSource * cache = nil;
    gcGraphChoice choice = self.viewChoice == gcViewChoiceYearly ? gcGraphChoiceCumulative : gcGraphChoiceBarGraph;

    NSDate * afterdate = nil;
    NSString * compstr = nil;
    NSCalendarUnit calunit =NSCalendarUnitWeekOfYear;
    if (self.viewChoice == gcViewChoiceAll ||self.viewChoice == gcViewChoiceSummary) {
        switch (self.historyStats) {
            case gcHistoryStatsMonth:
                compstr = @"-1Y";
                calunit = NSCalendarUnitMonth;
                break;
            case gcHistoryStatsWeek:
                compstr = @"-3M";
                calunit = NSCalendarUnitWeekOfYear;
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
        calunit = [GCViewConfig calendarUnitForViewChoice:self.viewChoice];
        switch (self.calChoice) {
            case gcStatsCal1Y:
                compstr = @"-1Y";
                break;
            case gcStatsCal3M:
                compstr = @"-3M";
                break;
            case gcStatsCal6M:
                compstr = @"-6M";
                break;
            case gcStatsCalAll:
            case gcStatsCalEnd:
            case gcStatsCalToDate:
                break;
        }
    }

    if (compstr) {
        afterdate = [[fieldDataSerie lastDate] dateByAddingGregorianComponents:[NSDateComponents dateComponentsFromString:compstr]];
    }

    cache = [GCSimpleGraphCachedDataSource historyView:fieldDataSerie
                                          calendarUnit:calunit
                                           graphChoice:choice
                                                 after:afterdate];
    if (self.calChoice == gcStatsCalToDate && ( self.viewChoice == gcViewChoiceMonthly||self.viewChoice== gcViewChoiceWeekly || self.viewChoice == gcViewChoiceYearly)) {
        [cache setupAsBackgroundGraph];
        GCHistoryFieldDataSerie * cut = [fieldDataSerie serieWithCutOff:fieldDataSerie.lastDate inCalendarUnit:calunit withReferenceDate:nil];
        GCSimpleGraphCachedDataSource * main = [GCSimpleGraphCachedDataSource historyView:cut
                                                                             calendarUnit:calunit
                                                                              graphChoice:choice
                                                                                    after:afterdate];
        [main addDataSource:cache];
        cache = main;
    }
    return cache;
}

#pragma mark - DerivedDataSerie Management

-(NSArray<GCDerivedGroupedSeries*>*)availableDataSeries{
    NSArray * series = [[GCAppGlobal derived] groupedSeriesMatching:^(GCDerivedDataSerie*serie){
        BOOL rv = [serie.activityType isEqualToString:self.activityType] &&
        serie.derivedPeriod == gcDerivedPeriodMonth &&
        serie.derivedType == gcDerivedTypeBestRolling ;
        return rv;
    }];
    return series;
}

- (void)nextDerivedSerie {
    NSArray<GCDerivedGroupedSeries*>*available = [self availableDataSeries];
    
    if (self.derivedSerieFieldIndex<available.count) {
        GCDerivedGroupedSeries*current = available[self.derivedSerieFieldIndex];
        
        self.derivedSerieMonthIndex++;
        if (self.derivedSerieMonthIndex>=MIN(3, current.series.count)) {
            self.derivedSerieMonthIndex = 0;
            self.derivedSerieFieldIndex++;
            if (self.derivedSerieFieldIndex>=available.count) {
                self.derivedSerieFieldIndex = 0;
            }
        }
    }else{
        self.derivedSerieFieldIndex = 0;
        self.derivedSerieMonthIndex = 0;
    }
}

- (void)nextDerivedSerieField { 
    NSArray<GCDerivedGroupedSeries*> * available = [self availableDataSeries];
    
    self.derivedSerieFieldIndex++;
    if (available && self.derivedSerieFieldIndex < available.count) {
        self.derivedSerieMonthIndex = 0;
    }else{
        self.derivedSerieMonthIndex = 0;
        self.derivedSerieFieldIndex = 0;
    }
}
-(void)nextSummaryCumulativeField{
    if( self.summaryCumulativeFieldFlag != gcFieldFlagSumDuration ){
        self.summaryCumulativeFieldFlag = gcFieldFlagSumDuration;
    }else{
        self.summaryCumulativeFieldFlag = gcFieldFlagSumDistance;
    }

}

-(GCDerivedDataSerie*)currentDerivedDataSerie{
    NSArray<GCDerivedGroupedSeries*>*available = [self availableDataSeries];
    GCDerivedDataSerie * current = nil;

    if (self.derivedSerieFieldIndex >= available.count) {
        self.derivedSerieFieldIndex = 0;
        self.derivedSerieMonthIndex = 0;
    }

    if (self.derivedSerieFieldIndex < available.count) {
        GCDerivedGroupedSeries * group = available[self.derivedSerieFieldIndex];
        if( self.derivedSerieMonthIndex < group.series.count){
            current = group.series[self.derivedSerieMonthIndex];
        }else if( group.series.count > 0){ // if index is too far reset to zero
            self.derivedSerieMonthIndex = 0;
            current = group.series[self.derivedSerieMonthIndex];
        }
    }
    return current;
}

-(void)setCurrentDerivedDataSerie:(GCDerivedDataSerie *)currentDerivedDataSerie{
    NSArray<GCDerivedGroupedSeries*>*available = [self availableDataSeries];
    NSUInteger newFieldIndex = 0;
    NSUInteger newMonthIndex = 0;
    BOOL found = false;
    
    for (newFieldIndex = 0; available.count; newFieldIndex++) {
        if( [available[newFieldIndex].field isEqualToField:currentDerivedDataSerie.field] ){
            break;
        }
    }
    
    if( newFieldIndex < available.count ){
        GCDerivedGroupedSeries * group = available[newFieldIndex];
        for (newMonthIndex = 0; newMonthIndex < group.series.count; newMonthIndex++) {
            if( [group.series[newMonthIndex].bucketStart isEqualToDate:currentDerivedDataSerie.bucketStart]){
                found = true;
                break;
            }
        }
        if( newMonthIndex < group.series.count ){
            self.derivedSerieFieldIndex = newFieldIndex;
            self.derivedSerieMonthIndex = newMonthIndex;
        }
    }
}

#pragma mark - cumulative Summary Field

-(GCField*)currentCumulativeSummaryField{
    // Ignore any value other than sumDuration or SumDistance
    gcFieldFlag which = self.summaryCumulativeFieldFlag == gcFieldFlagSumDuration ? gcFieldFlagSumDuration : gcFieldFlagSumDistance;
    return [GCField fieldForFlag:which andActivityType:self.activityType];
}
@end
