//  MIT License
//
//  Created on 07/06/2020 for ConnectStats
//
//  Copyright (c) 2020 Brice Rosenzweig
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



#import "GCStatsDerivedHistory.h"
#import "GCAppGlobal.h"
#import "GCSimpleGraphCachedDataSource+Templates.h"
#import "GCStatsDerivedAnalysisConfig.h"

@implementation GCStatsDerivedHistory

+(GCStatsDerivedHistory*)analysisWith:(GCStatsMultiFieldConfig*)multiFieldConfig and:(GCStatsDerivedAnalysisConfig*)derivedConfig{
    GCStatsDerivedHistory * rv = [[[GCStatsDerivedHistory alloc] init] autorelease];
    if( rv){
        rv.lookbackPeriod = [GCLagPeriod periodFor:gcLagPeriodSixMonths];
        rv.mode = gcDerivedHistModeAbsolute;
        rv.longTermSmoothing = gcDerivedHistSmoothingMax;
        rv.shortTermSmoothing = gcDerivedHistSmoothingMovingAverage;
        rv.pointsForGraphs = @[ @(0), @(60), @(1800) ];
        rv.multiFieldConfig = multiFieldConfig;
        rv.derivedAnalysisConfig = derivedConfig;
        rv.longTermPeriod = [GCLagPeriod periodFor:gcLagPeriodTwoWeeks];
        rv.shortTermPeriod = [GCLagPeriod periodFor:gcLagPeriodNone];
    }
    return rv;
}
-(void)dealloc{
    [_shortTermPeriod release];
    [_longTermPeriod release];
    [_lookbackPeriod release];
    [super dealloc];
}

-(NSDate*)fromDate{
    return [self.lookbackPeriod applyToDate:[[GCAppGlobal organizer] lastActivity].date];
}

-(GCField *)field{
    return self.derivedAnalysisConfig.currentDerivedDataSerie.field;
}

-(NSString*)method{
    if( self.longTermSmoothing == gcDerivedHistSmoothingMax && self.shortTermSmoothing == gcDerivedHistSmoothingMax){
        return NSLocalizedString( @"Max", @"Derived Hist Method");
    }else if (self.longTermSmoothing == gcDerivedHistSmoothingMovingAverage && self.shortTermSmoothing == gcDerivedHistSmoothingMovingAverage ){
        return NSLocalizedString( @"Trend", @"Derived Hist Method");
    }else{
        return NSLocalizedString( @"Max/Trend", @"Derived Hist Method");
    }
}
-(void)setMethod:(NSString *)method{
    if( [method isEqualToString:NSLocalizedString( @"Max", @"Derived Hist Method")] ){
        self.longTermSmoothing = gcDerivedHistSmoothingMax;
        self.shortTermSmoothing = gcDerivedHistSmoothingMax;
    }else if( [method isEqualToString:NSLocalizedString( @"Trend", @"Derived Hist Method")] ){
        self.longTermSmoothing = gcDerivedHistSmoothingMovingAverage;
        self.shortTermSmoothing = gcDerivedHistSmoothingMovingAverage;
    }else{
        self.longTermSmoothing = gcDerivedHistSmoothingMax;
        self.shortTermSmoothing = gcDerivedHistSmoothingMovingAverage;
    }
}

-(NSArray<NSString*>*)methods{
    return @[ NSLocalizedString( @"Max/Trend", @"Derived Hist Method"),
              NSLocalizedString( @"Max", @"Derived Hist Method"),
              NSLocalizedString( @"Trend", @"Derived Hist Method"),
    ];
}

-(GCCellSimpleGraph*)tableView:(UITableView *)tableView derivedHistCellForRowAtIndexPath:(NSIndexPath *)indexPath with:(nonnull GCDerivedOrganizer *)derived{
    GCCellSimpleGraph * graphCell = [GCCellSimpleGraph graphCell:tableView];

    GCDerivedDataSerie * current = [self.derivedAnalysisConfig currentDerivedDataSerie];
    GCStatsSerieOfSerieWithUnits * serieOfSerie = nil;
    GCField * field = nil;
    
    if( current ){
        
        field = current.field;
        NSDate * from = self.fromDate;
        serieOfSerie = [derived timeserieOfSeriesFor:field inActivities:[[GCAppGlobal organizer] activitiesMatching:^(GCActivity * act){
            BOOL rv = [act.activityType isEqualToString:field.activityType] && ([act.date compare:from] == NSOrderedDescending);
            return rv;
        } withLimit:500]];
    }
    GCSimpleGraphCachedDataSource * cache = nil;
    if (serieOfSerie) {
        cache = [GCSimpleGraphCachedDataSource derivedHist:self field:field series:serieOfSerie width:tableView.frame.size.width];
        cache.emptyGraphLabel = @"";
        graphCell.legend = true;
        [graphCell setDataSource:cache andConfig:cache];
    }else{
        cache = [GCSimpleGraphCachedDataSource dataSourceWithStandardColors];
        cache.emptyGraphLabel = @"";
        [graphCell setDataSource:cache andConfig:cache];
    }
    return graphCell;
}

@end
