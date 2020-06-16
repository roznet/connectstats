//  MIT Licence
//
//  Created on 01/08/2014.
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

#import "GCHistoryPerformanceAnalysis.h"
#import "GCAppGlobal.h"
#import "GCActivitiesOrganizer.h"

static const NSTimeInterval kOneDayTimeInterval = 24.*60.*60.;

@interface GCHistoryPerformanceAnalysis ()
@property (nonatomic,retain) GCActivitiesOrganizer * organizer;
@property (nonatomic,retain) NSArray * series;
@property (nonatomic,retain) NSString * seriesDescription;
@end

@implementation GCHistoryPerformanceAnalysis

+(GCHistoryPerformanceAnalysis*)performanceAnalysisFromDate:(NSDate*)date forField:(GCField *)field{
    GCHistoryPerformanceAnalysis * rv = RZReturnAutorelease([[GCHistoryPerformanceAnalysis alloc] init]);
    if (rv) {
        NSString * activityType = field.activityType;
        if ([field canSum]) {
            rv.summableField = field;
            rv.scalingField = [GCField fieldForKey:@"WeightedMeanHeartRate" andActivityType:activityType] ;
        }else{
            rv.summableField = [GCField fieldForKey:@"SumDistance" andActivityType:activityType];
            rv.scalingField = field;
        }

        rv.shortTermPeriod = [GCLagPeriod periodFor:gcLagPeriodWeek];
        rv.longTermPeriod = [GCLagPeriod periodFor:gcLagPeriodMonth];

        rv.fromDate = date;
    }
    return rv;

}

-(void)dealloc{

    [_organizer release];
    [_fromDate release];

    [_summableField release];
    [_scalingField release];
    [_series release];
    [_seriesDescription release];

    [_shortTermPeriod release];
    [_longTermPeriod release];
    
    [_longTermSerie release];
    [_shortTermSerie release];
    [_serie release];

    [super dealloc];
}

-(void)useOrganizer:(GCActivitiesOrganizer*)organizer{
    self.organizer = organizer;
}


#pragma mark - Main Calculations

-(NSString*)activityType{
    return self.summableField.activityType;
}

-(NSArray<GCField*>*)fields{
    if (self.scalingField) {
        return @[self.summableField,self.scalingField];
    }else{
        return @[self.summableField];
    }
}

-(void)loadFromOrganizer{
    if (self.organizer==nil) {
        self.organizer = [GCAppGlobal organizer];
    }
    GCActivityMatchBlock filter = nil;
    BOOL checkActivityType = ![self.activityType isEqualToString:GC_TYPE_ALL];
    NSDate * filterDate = nil;
    if(self.fromDate) {
        // substract longTermPeriod for the moving average and short Term Period to account for the shift
        filterDate = [self.longTermPeriod applyToDate:self.fromDate];
        filterDate = [self.shortTermPeriod applyToDate:filterDate];
    }

    if (checkActivityType || filterDate!=nil) {
        filter = ^(GCActivity*act){
            BOOL keep = !checkActivityType || [act.activityType isEqualToString:self.activityType];
            if (filterDate) {
                keep = keep && ([filterDate compare:act.date] == NSOrderedAscending);
            }
            return keep;
        };
    }

    gcIgnoreMode ignoreMode = [self.activityType isEqualToString:GC_TYPE_DAY] ? gcIgnoreModeDayFocus : gcIgnoreModeActivityFocus;
    NSDictionary * series = [self.organizer fieldsSeries:self.fields matching:filter useFiltered:self.useFilter ignoreMode:ignoreMode];
    NSMutableArray * seriesArray = [NSMutableArray arrayWithCapacity:self.fields.count];
    NSUInteger minimumPoints = 0;
    for (GCField * field in self.fields) {
        GCStatsDataSerieWithUnit * serie = series[field];
        GCStatsDataSerieFilter * seriefilter = [self.organizer standardFilterForField:field];
        if (seriefilter) {
            serie = [seriefilter filteredSerieWithUnitFrom:serie];
        }
        if (serie && serie.count > minimumPoints) {
            [seriesArray addObject:serie];
        }else{
            RZLog(RZLogInfo, @"Not enough points for performance %@: %lu < 30", self.activityType, serie.count);
        }
    }

    self.series = [NSArray arrayWithArray:seriesArray];
}

-(GCStatsDataSerie*)adjustSerie:(GCStatsDataSerie*)serie shift:(GCLagPeriod*)period{
    double from_x = self.fromDate ? (self.fromDate).timeIntervalSinceReferenceDate : 0.;
    double to_x = (serie.lastObject).x_data;
    NSUInteger shift = period ? period.numberOfDays : 0;
    GCStatsDataSerie * rv = [[[GCStatsDataSerie alloc] init] autorelease];
    for (GCStatsDataPoint * point in serie) {
        //double x_data = [[point.date dateByAddingTimeInterval:(shift*GC_ONE_DAY)] timeIntervalSinceReferenceDate];
        double x_data = point.x_data + (shift*kOneDayTimeInterval);
        if (x_data >= from_x && x_data <= to_x) {
            [rv addDataPointWithX:x_data andY:point.y_data];
        }
    }

    return rv;
}

-(BOOL)isEmpty{
    return self.series.count == 0 || (self.series.count > 0 && [self.series[0] count] ==0 );
}
-(void)calculate{
    [self loadFromOrganizer];

    GCStatsDataSerieWithUnit * serie = nil;
    NSString * scaleDesc = [self.scalingField displayName];
    NSString * sumdesc   = [self.summableField displayName];

    if (self.series.count == 1) {
        serie = self.series[0];
        self.seriesDescription = sumdesc;
    }else if (self.series.count == 2){
        GCStatsDataSerie * s1 = ((GCStatsDataSerieWithUnit*)self.series[0]).serie;
        GCStatsDataSerie * s2 = ((GCStatsDataSerieWithUnit*)self.series[1]).serie;
        [s1 sortByX];
        [s2 sortByX];
        self.seriesDescription = [NSString stringWithFormat:@"%@ x %@", sumdesc, scaleDesc];
        serie = [GCStatsDataSerieWithUnit dataSerieWithUnit:[GCUnit unitForKey:@"dimensionless"] andSerie:[s1 operate:gcStatsOperandMultiply with:s2]];
    }else if( self.series.count != 0){
        RZLog(RZLogError, @"Invalid number of series %lu", (unsigned long)self.series.count);
    }
    if (serie) {
        serie.serie = [serie.serie summedSerieByUnit:kOneDayTimeInterval fillMethod:gcStatsZero];
        self.serie = serie;
        
        self.longTermSerie = [GCStatsDataSerieWithUnit dataSerieWithUnit:serie.unit andSerie:[serie.serie movingAverageForUnit:self.longTermPeriod.timeInterval]];
        self.shortTermSerie = [GCStatsDataSerieWithUnit dataSerieWithUnit:serie.unit andSerie:[serie.serie movingAverageForUnit:self.shortTermPeriod.timeInterval]];
        self.longTermSerie.serie = [self adjustSerie:self.longTermSerie.serie shift:self.shortTermPeriod];
        self.shortTermSerie.serie= [self adjustSerie:self.shortTermSerie.serie shift:nil];
    }
}
@end
