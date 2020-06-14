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



#import "GCStatsDerivedHistAnalysis.h"
#import "GCAppGlobal.h"

@implementation GCStatsDerivedHistAnalysis

+(GCStatsDerivedHistAnalysis*)config{
    GCStatsDerivedHistAnalysis * rv = [[[GCStatsDerivedHistAnalysis alloc] init] autorelease];
    if( rv){
        rv.lookbackPeriod = [GCLagPeriod periodFor:gcLagPeriodSixMonths];
        rv.mode = gcDerivedHistModeAbsolute;
        rv.smoothing = gcDerivedHistSmoothingMax;
        rv.pointsForGraphs = @[ @(0), @(60), @(1800) ];

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

/*
-(void)sss{
    GCDerivedDataSerie * current = [self currentDerivedDataSerie];
    GCStatsSerieOfSerieWithUnits * serieOfSerie = nil;
    GCField * field = nil;
    
    GCStatsDerivedHistConfig * config = [GCStatsDerivedHistConfig config];
    config.longTermPeriod = [GCLagPeriod periodFor:gcLagPeriodTwoWeeks];
    config.shortTermPeriod = [GCLagPeriod periodFor:gcLagPeriodTwoWeeks];
    config.mode = gcDerivedHistModeDrop;
    config.smoothing = gcDerivedHistSmoothingMax;
    
    if( current ){
        field = [GCField fieldForFlag:current.fieldFlag andActivityType:self.activityType];
        NSDate * from = config.fromDate;
        serieOfSerie = [[GCAppGlobal derived] timeserieOfSeriesFor:field inActivities:[[GCAppGlobal organizer] activitiesMatching:^(GCActivity * act){
            BOOL rv = [act.activityType isEqualToString:self.activityType] && ([act.date compare:from] == NSOrderedDescending);
            return rv;
        } withLimit:500]];
    }
    //GCStatsSerieOfSerieWithUnits * historical = [[GCAppGlobal derived] timeSeriesOfSeriesFor:field];
    //[serieOfSerie addSerieOfSerie:historical];
    GCSimpleGraphCachedDataSource * cache = nil;
    if (serieOfSerie) {
        cache = [GCSimpleGraphCachedDataSource derivedHist:config field:field series:serieOfSerie width:tableView.frame.size.width];
        cache.emptyGraphLabel = @"";
        graphCell.legend = true;
        [graphCell setDataSource:cache andConfig:cache];
    }else{
        cache = [GCSimpleGraphCachedDataSource dataSourceWithStandardColors];
        cache.emptyGraphLabel = @"";
        [graphCell setDataSource:cache andConfig:cache];
    }

}
*/
@end
