//  MIT License
//
//  Created on 28/03/2020 for ConnectStats
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



#import "GCActivity+Series.h"
#import "GCActivity+CachedTracks.h"

@implementation GCActivity (Series)

-(GCStatsDataSerieWithUnit*)trackSerieForField:(GCField*)field
                                   trackpoints:(NSArray<GCTrackPoint*>*)trackpoints
                                      timeAxis:(BOOL)timeAxis{
    if( self.cachedCalculatedTracks[field].serie != nil){
        return self.cachedCalculatedTracks[field].serie;
    }
    BOOL treatGapAsNoValue = self.settings.treatGapAsNoValueInSeries;
    NSTimeInterval gapTimeInterval = self.settings.gapTimeInterval;

    GCUnit * displayUnit = [self displayUnitForField:field];
    GCUnit * storeUnit   = [self storeUnitForField:field];

    GCStatsDataSerieWithUnit * serieWithUnit = [GCStatsDataSerieWithUnit dataSerieWithUnit:storeUnit];
    if (timeAxis) {
        serieWithUnit.xUnit = [GCUnit unitForKey:STOREUNIT_ELAPSED];
    }else{
        serieWithUnit.xUnit = [GCUnit unitForKey:STOREUNIT_DISTANCE];
    }
    NSDate * firstDate = nil;
    BOOL useElapsed = ![self.activityType isEqualToString:GC_TYPE_DAY];
    if (!useElapsed&&timeAxis) {
        serieWithUnit.xUnit = [GCUnit unitForKey:@"timeofday"];
    }

    NSArray<GCNumberWithUnit*> * lapAdjustments = nil;
    if (self.settings.adjustSeriesToMatchLapAverage) {
        lapAdjustments = [self trackSerieLapAdjustment:field];
    }

    GCTrackPoint * lastPoint = nil;
    for (GCTrackPoint * point in trackpoints) {
        // We should always take the first date of the first trackpoint as reference
        // So time elapsed match even for series where the first few points don't have data
        if (firstDate == nil) {
            firstDate = point.time;
        }

        GCNumberWithUnit * nu = [point numberWithUnitForField:field inActivity:self];
        
        if (nu) {
            if (lapAdjustments && point.lapIndex < lapAdjustments.count) {
                GCNumberWithUnit * adjustment = lapAdjustments[ point.lapIndex];
                [nu addNumberWithUnit:adjustment weight:1.0];
            }

            if (timeAxis) {
                if (useElapsed) {
                    if(lastPoint && treatGapAsNoValue){
                        NSTimeInterval elapsed = [point.time timeIntervalSinceDate:lastPoint.time];
                        NSTimeInterval checkGapTimeInterval = gapTimeInterval == 0. ? lastPoint.elapsed : gapTimeInterval;
                        if(elapsed > checkGapTimeInterval){
                            NSDate * nextDate = [lastPoint.time dateByAddingTimeInterval:checkGapTimeInterval];
                            [serieWithUnit.serie addDataPointNoValueWithX:[nextDate timeIntervalSinceDate:firstDate]];
                        }
                    }

                    [serieWithUnit addNumberWithUnit:nu forDate:point.time since:firstDate];
                }else{
                    [serieWithUnit addNumberWithUnit:nu forDate:point.time];
                }
            }else{
                [serieWithUnit addNumberWithUnit:nu forX:point.distanceMeters];
            }
        }else if( self.garminSwimAlgorithm){
            // No value, add point for consistency in number of points
            [serieWithUnit.serie addDataPointNoValueWithX:[point.time timeIntervalSinceDate:firstDate]];
        }
        lastPoint = point;
    }

    [self applyStandardFilterTo:serieWithUnit ForField:field];

    if (![displayUnit isEqualToUnit:storeUnit]) {
        [serieWithUnit convertToUnit:displayUnit];
    }
    [serieWithUnit convertToGlobalSystem];
    return serieWithUnit;
}


-(GCStatsDataSerieWithUnit*)distanceSerieForField:(GCField*)field{
    return [self trackSerieForField:field trackpoints:self.trackpoints timeAxis:false];
}


-(GCStatsDataSerieWithUnit*)timeSerieForField:(GCField*)field{
    GCStatsDataSerieWithUnit * rv = nil;

    if ([self hasCalculatedSerieForField:field]) {
        rv = [self calculatedSerieForField:field thread:nil];
    }else{
        rv = [self trackSerieForField:field trackpoints:self.trackpoints timeAxis:true];
    }
    return rv;
}

-(GCStatsDataSerie * )timeSerieForSwimStrokeMatching:(GCStatsDataSerie*)other{
    if (self.garminSwimAlgorithm) {
        GCStatsDataSerieWithUnit * rv = [self trackSerieForField:[GCField fieldForKey:INTERNAL_DIRECT_STROKE_TYPE andActivityType:GC_TYPE_ALL] trackpoints:self.trackpoints timeAxis:true];
        if( rv.count != other.count){
           // [GCStatsDataSerie reduceToCommonRange:rv.serie and:[GCStatsDataSerie dataSerieWithPointsIn:other]];
        }
        return rv.serie;
    }else{
        return nil;
    }
}

-(GCStatsDataSerieWithUnit*)progressSerie:(BOOL)timeAxis{
    GCUnit * unit = timeAxis ? [GCUnit unitForKey:STOREUNIT_DISTANCE] : [GCUnit unitForKey:STOREUNIT_ELAPSED];
    GCUnit * xUnit= timeAxis ? [GCUnit unitForKey:STOREUNIT_ELAPSED] : [GCUnit unitForKey:STOREUNIT_DISTANCE];

    GCStatsDataSerieWithUnit * serieWithUnit = [GCStatsDataSerieWithUnit dataSerieWithUnit:unit];
    serieWithUnit.xUnit = xUnit;

    NSDate * firstDate = nil;

    GCTrackPoint * lastPoint = nil;

    for (GCTrackPoint * point in [self trackpoints]) {
        if (!lastPoint) {
            firstDate = point.time;
        }
        lastPoint = point;

        if (timeAxis) {
            [serieWithUnit.serie addDataPointWithX:[point.time timeIntervalSinceDate:firstDate] andY:point.distanceMeters];
        }else{
            [serieWithUnit.serie addDataPointWithX:point.distanceMeters andY:[point.time timeIntervalSinceDate:firstDate]];
        }
    }
    return serieWithUnit;

}

-(GCStatsDataSerieWithUnit*)cumulativeDifferenceSerieWith:(GCActivity*)other timeAxis:(BOOL)timeAxis{
    GCStatsDataSerieWithUnit * progress = [self progressSerie:timeAxis];
    GCStatsDataSerieWithUnit * otherProgress = [other progressSerie:timeAxis];

    return timeAxis ? [progress cumulativeDifferenceWith:otherProgress] : [otherProgress cumulativeDifferenceWith:progress];
}
-(GCStatsDataSerie*)highlightSerieForLap:(NSUInteger)lap timeAxis:(BOOL)timeAxis{
    GCStatsDataSerieWithUnit * serieWithUnit = [GCStatsDataSerieWithUnit dataSerieWithUnit:[GCUnit unitForKey:@"dimensionless"]];
    NSDate * lastDate = nil;
    NSDate * firstDate = nil;
    double lastDist = 0.;

    BOOL started = false;

    NSUInteger currLap = 0;

    for (GCTrackPoint * point in [self trackpoints]) {

        if (!started) {
            firstDate = point.time;
        }
        if (currLap != point.lapIndex || !started) {
            lastDist = point.distanceMeters;
            lastDate = point.time;
            currLap = point.lapIndex;
        }

        started = true;

        double y = 0.;
        if (point.lapIndex == lap) {
            // +1 so it's not equal to 0
            y = timeAxis ? [point.time timeIntervalSinceDate:lastDate]+1. : point.distanceMeters - lastDist;
        }

        if (timeAxis) {
            [serieWithUnit.serie addDataPointWithDate:point.time since:firstDate andValue:y];
        }else{
            [serieWithUnit.serie addDataPointWithX:point.distanceMeters andY:y];
        }
    }
    return serieWithUnit.serie;
}

-(NSArray<GCNumberWithUnit*>*)trackSerieLapAdjustment:(GCField*)field{

    NSMutableArray<GCNumberWithUnit*> * rv = nil;

    BOOL error = false;
    GCUnit * storeUnit = [self storeUnitForField:field];

    NSUInteger lapCount = self.laps.count;
    NSUInteger lapIdx = 0;
    GCNumberWithUnit * currentLapSum = [GCNumberWithUnit numberWithUnit:storeUnit andValue:0.0];
    double currentLapCount = 0.;
    
    if ([self.settings shouldAdjustToMatchLapAverageForField:field] && lapCount > 0) {
        rv = [NSMutableArray arrayWithCapacity:lapCount];
        // Init with zeros
        for (NSUInteger i=0;i<lapCount;i++) {
            [rv addObject:[GCNumberWithUnit numberWithUnit:storeUnit andValue:0.0]]; // 0 -> no adjustment (additive adjustment)
        }

        for (GCTrackPoint * point in self.trackpoints) {

            GCNumberWithUnit * nu = [point numberWithUnitForField:field inActivity:self];

            if (nu) {
                if (point.lapIndex == lapIdx) {
                    currentLapCount += 1.;
                    [currentLapSum   addNumberWithUnit:nu weight:1.0];
                }else{
                    GCLap * lap = self.laps[lapIdx];
                    currentLapSum.value /= currentLapCount;
                    // store the difference
                    rv[lapIdx] = [[lap numberWithUnitForField:field inActivity:self] addNumberWithUnit:currentLapSum weight:-1.0];

                    if (point.lapIndex == lapIdx + 1 && lapIdx + 1 < self.laps.count) {
                        lapIdx ++;
                        // reset sum
                        currentLapSum.value = 0.;
                        currentLapCount = 0.;
                    }else{
                        RZLog(RZLogError, @"Inconsistent laps.count=%lu, point.lapIndex=%lu, lapIdx=%lu",
                              (unsigned long) self.laps.count,
                              (unsigned long)point.lapIndex,
                              (unsigned long)lapIdx);
                        error = true;
                        break;
                    }
                }

            }
        }
    }
    if (error) {
        rv = nil;
    }
    return rv;

}

-(GCStatsDataSerieWithUnit*)applyStandardFilterTo:(GCStatsDataSerieWithUnit*)serieWithUnit ForField:(GCField*)field{
    GCStatsDataSerieFilter * filter = self.settings.serieFilters[field];

    if (filter) {
        NSUInteger count_total = serieWithUnit.count;

        serieWithUnit.serie = [filter filteredSerieFrom:serieWithUnit.serie];

        NSUInteger count_serie = serieWithUnit.serie.count;
        NSUInteger count_filtered = count_total-count_serie;

        if ((double)count_filtered/count_total > 0.10) {
            RZLog(RZLogInfo, @"%@ filtered %d out of %d", field,
                  (int)count_filtered,(int)count_total);
        }

    }
    return serieWithUnit;
}

-(GCStatsDataSerieWithUnit*)lapSerieForTrackField:(GCField*)field timeAxis:(BOOL)timeAxis{
    GCUnit * displayUnit = [self displayUnitForField:field];
    GCUnit * storeUnit   = [self storeUnitForField:field];

    GCStatsDataSerieWithUnit * serieWithUnit = [GCStatsDataSerieWithUnit dataSerieWithUnit:storeUnit];
    if (!timeAxis) {
        serieWithUnit.xUnit = [GCUnit unitForKey:STOREUNIT_DISTANCE];
    }
    NSDate * firstDate = nil;

    for (GCLap * lap in [self laps]) {
        GCNumberWithUnit * nu = [lap numberWithUnitForField:field inActivity:self];

        if (timeAxis) {
            if (firstDate == nil) {
                firstDate = lap.time;
            }
            [serieWithUnit addNumberWithUnit:nu forDate:lap.time since:firstDate];
        }else{
            [serieWithUnit addNumberWithUnit:nu forX:lap.distanceMeters];
        }
    }

    if (![displayUnit isEqualToUnit:storeUnit]) {
        [serieWithUnit convertToUnit:displayUnit];
    }
    [serieWithUnit convertToGlobalSystem];
    return serieWithUnit;
}

@end
