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

#define GC_ONE_DAY 24.*60.*60.

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
            if ([activityType isEqualToString:GC_TYPE_TENNIS]) {
                rv.scalingField = [GCField fieldForKey:@"heatmap_all_center" andActivityType:activityType];
            }else{
                rv.scalingField = [GCField fieldForKey:@"WeightedMeanHeartRate" andActivityType:activityType] ;
            }
        }else{
            if ([activityType isEqualToString:GC_TYPE_TENNIS]) {
                rv.summableField = [GCField fieldForKey:@"shots" andActivityType:activityType];
            }else{
                rv.summableField = [GCField fieldForKey:@"SumDistance" andActivityType:activityType];
            }
            rv.scalingField = field;
        }

        rv.shortTermPeriod = gcPerformancePeriodWeek;
        rv.longTermPeriod = gcPerformancePeriodMonth;

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

    [_longTermSerie release];
    [_shortTermSerie release];
    [_serie release];

    [super dealloc];
}

#pragma mark - Utils

-(NSDateComponents*)dateComponentsFromPerformancePeriod:(gcPerformancePeriod)p{
    NSDateComponents * rv = nil;

    switch (p) {
        case gcPerformancePeriodDay:
            rv = [NSDateComponents dateComponentsFromString:@"-1d"];
            break;
        case gcPerformancePeriodThreeMonths:
            rv = [NSDateComponents dateComponentsFromString:@"-3m"];
            break;
        case gcPerformancePeriodMonth:
            rv = [NSDateComponents dateComponentsFromString:@"-1m"];
            break;
        case gcPerformancePeriodTwoWeeks:
            rv = [NSDateComponents dateComponentsFromString:@"-2w"];
            break;
        case gcPerformancePeriodWeek:
            rv = [NSDateComponents dateComponentsFromString:@"-1w"];
            break;
        case gcPerformancePeriodYear:
            rv = [NSDateComponents dateComponentsFromString:@"-1y"];
            break;
        case gcPerformancePeriodNone:
            rv = nil;
            break;
    }
    return rv;
}

-(NSUInteger)samplesForPerformancePeriod:(gcPerformancePeriod)p{
    NSUInteger rv = 0;

    switch (p) {
        case gcPerformancePeriodNone:
            rv = 0;
            break;
        case gcPerformancePeriodDay:
            rv = 1;
            break;
        case gcPerformancePeriodMonth:
            rv = 30;
            break;
        case gcPerformancePeriodWeek:
            rv = 7;
            break;
        case gcPerformancePeriodYear:
            rv = 365;
            break;
        case gcPerformancePeriodThreeMonths:
            rv = 30*3;
            break;
        case gcPerformancePeriodTwoWeeks:
            rv = 7*2;
            break;
    }
    return rv;

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
        filterDate = [self.fromDate dateByAddingGregorianComponents:[self dateComponentsFromPerformancePeriod:self.longTermPeriod]];
        filterDate = [filterDate dateByAddingGregorianComponents:[self dateComponentsFromPerformancePeriod:self.shortTermPeriod]];
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
    NSUInteger minimumPoints = [self samplesForPerformancePeriod:self.longTermPeriod];
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

-(GCStatsDataSerie*)adjustSerie:(GCStatsDataSerie*)serie shift:(gcPerformancePeriod)period{
    double from_x = self.fromDate ? (self.fromDate).timeIntervalSinceReferenceDate : 0.;
    double to_x = (serie.lastObject).x_data;
    NSUInteger shift = [self samplesForPerformancePeriod:period];
    GCStatsDataSerie * rv = [[[GCStatsDataSerie alloc] init] autorelease];
    for (GCStatsDataPoint * point in serie) {
        //double x_data = [[point.date dateByAddingTimeInterval:(shift*GC_ONE_DAY)] timeIntervalSinceReferenceDate];
        double x_data = point.x_data + (shift*GC_ONE_DAY);
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
        serie.serie = [serie.serie summedSerieByUnit:GC_ONE_DAY fillMethod:gcStatsZero];
        self.serie = serie;
        self.longTermSerie = [GCStatsDataSerieWithUnit dataSerieWithUnit:serie.unit andSerie:[serie.serie movingAverage:[self samplesForPerformancePeriod:self.longTermPeriod]]];
        self.shortTermSerie = [GCStatsDataSerieWithUnit dataSerieWithUnit:serie.unit andSerie:[serie.serie movingAverage:[self samplesForPerformancePeriod:self.shortTermPeriod]]];
        self.longTermSerie.serie = [self adjustSerie:self.longTermSerie.serie shift:self.shortTermPeriod];
        self.shortTermSerie.serie= [self adjustSerie:self.shortTermSerie.serie shift:gcPerformancePeriodNone];
    }
}
@end
