//  MIT License
//
//  Created on 22/03/2020 for ConnectStats
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



#import "GCActivity+BestRolling.h"
#import "GCCalculatedCachedTrackInfo.h"
#import "GCAppGlobal.h"
#import "GCActivity+Series.h"
#import "GCActivity+TrackTransform.h"

@implementation GCActivity (BestRolling)

-(GCStatsDataSerieWithUnit*)calculatedRollingBestForSpeed:(GCCalculactedCachedTrackInfo *)info{
    GCStatsDataSerieWithUnit * rv = nil;
    
    BOOL timeByDistance = true;
    BOOL removePause = true;
    BOOL matchMaxSpeed = true;
    
    GCStatsDataSerieWithUnit * serie = nil;
    GCField * referenceField = nil;
    gcStatsSelection select = gcStatsMin;
    
    double unitstride = [GCAppGlobal configGetDouble:CONFIG_CRITICAL_CALC_UNIT defaultValue:5.];
    unitstride = 10;
    
    NSArray<GCTrackPoint*>*trackpoints = removePause ? [self removedStoppedTimer:self.trackpoints] : self.trackpoints;

    if( timeByDistance ){
        referenceField = [GCField fieldForFlag:gcFieldFlagSumDuration andActivityType:self.activityType];
        // x is distance, y is time
        serie = [self trackSerieForField:referenceField trackpoints:trackpoints timeAxis:NO];
    }else{
        referenceField = [GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:self.activityType];
        // x is time, y is distance
        serie = [self trackSerieForField:referenceField trackpoints:trackpoints timeAxis:YES];
        select = gcStatsMax;
        [serie convertToUnit:[GCUnit meter]];
    }
    
    // Compute the difference between points (so x,y = dist,dTime or y = time,dDistance)
    GCStatsDataSerie * diffSerie = [serie.serie differenceSerieForLag:0.0];
    // Add zero at the beginning if missing
    if( diffSerie.count > 0 && diffSerie.firstObject.x_data > 0 ){
        [diffSerie addDataPointWithX:0.0 andY:0.0];
        [diffSerie sortByX];
    }

    info.processedPointsCount = diffSerie.count;
    
    // rescale by unit of 10 (either every 10 seconds or every 10 meters.
    GCStatsDataSerie * filled = [diffSerie filledSerieForUnit:10. fillMethod:gcStatsZero statistic:gcStatsSum];
    
#if TARGET_IPHONE_SIMULATOR
    // For debugging
    [[serie.serie asCSVString:false] writeToFile:[RZFileOrganizer writeableFilePath:@"s_raw.csv"]
                                      atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [[diffSerie asCSVString:false] writeToFile:[RZFileOrganizer writeableFilePath:@"s_diff.csv"]
                                    atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [[filled asCSVString:false] writeToFile:[RZFileOrganizer writeableFilePath:@"s_filled.csv"]
                                 atomically:YES encoding:NSUTF8StringEncoding error:nil];
#endif
    
    serie.serie = [diffSerie movingBestByUnitOf:unitstride fillMethod:gcStatsZero select:select statistic:gcStatsSum];
    for (GCStatsDataPoint * point in serie.serie) {
        if( point.y_data > 0.){
            // Add unitstride because a point is applicable between x and next point (= x+stride)
            // Otherwise the early stage will be counted wrong:
            //   x = 0*stride -> y_0 meters, x = 1*stride - > y_1
            //=>         y_0 / 1*stride,        y_1 / (2*stride)
            if( timeByDistance ){
                point.y_data = (point.x_data+unitstride)/point.y_data; // convert in mps
            }else{
                point.y_data = point.y_data/( point.x_data + unitstride ); // convert in mps
            }
        }
    }
    serie.unit = [GCUnit mps];
    
    if( [serie dataPointAtIndex:0].y_data == 0 ){
        [serie.serie removePointAtIndex:0];
    }
    
    if( matchMaxSpeed ){
        GCNumberWithUnit * maxSpeed = [self numberWithUnitForField:[GCField fieldForKey:@"MaxSpeed" andActivityType:self.activityType]];
        if( maxSpeed ){
            double maxValue = [maxSpeed convertToUnit:[GCUnit mps]].value;
            NSUInteger n = 0;
            NSUInteger start_n = serie.serie.count;
            
            while( serie.serie.count > 0 && [serie dataPointAtIndex:0].y_data > maxValue ){
                [serie.serie removePointAtIndex:0];
                n++;
            }
            RZLog(RZLogInfo, @"Removed %@/%@ points faster than MaxSpeed = %@", @(n),@(start_n), maxSpeed );
        }
    }
    
    [serie convertToUnit:[GCUnit minperkm]];
    if( serie.serie.count > 1 && [serie.serie dataPointAtIndex:0].x_data == 0){
        [serie.serie dataPointAtIndex:0].y_data = [serie.serie dataPointAtIndex:1].y_data;
    }
    
    rv = serie;
    return rv;
}

-(GCStatsDataSerieWithUnit*)calculatedRollingBest:(GCCalculactedCachedTrackInfo *)info{
    GCStatsDataSerieWithUnit * rv = nil;

    if( info.fieldFlag == gcFieldFlagWeightedMeanSpeed){
        rv = [self calculatedRollingBestForSpeed:info];
    }else{
        
        GCStatsDataSerieWithUnit * serie = [self timeSerieForField:info.field];
        
        NSArray<GCTrackPoint*>*trackpoints = [self removedStoppedTimer:self.trackpoints];
        
        serie = [self trackSerieForField:info.field trackpoints:trackpoints timeAxis:YES];
        
        info.processedPointsCount = serie.serie.count;
        gcStatsSelection select = gcStatsMax;
        if ([serie.unit isKindOfClass:[GCUnitInverseLinear class]]) {
            select = gcStatsMin;
        }
        
        double unitstride = [GCAppGlobal configGetDouble:CONFIG_CRITICAL_CALC_UNIT defaultValue:5.];
        
        // HACK serie that are missing zero, as otherwise the best of may not start consistently
        // and doing max over multiple will have weird quirks at the beginning.
        if( serie.serie.count > 0 && serie.serie.firstObject.x_data > 0 ){
            [serie.serie addDataPointWithX:0.0 andY:serie.serie.firstObject.y_data];
            [serie.serie sortByX];
        }
        
        serie.serie = [serie.serie movingBestByUnitOf:unitstride fillMethod:gcStatsZero select:select statistic:gcStatsWeightedMean];
        rv = serie;
    }
    return rv;
}


-(GCStatsDataSerieWithUnit*)calculatedRollingBestOLD:(GCCalculactedCachedTrackInfo *)info{
    GCStatsDataSerieWithUnit * rv = nil;

    BOOL timeAxis = info.fieldFlag != gcFieldFlagWeightedMeanSpeed;
    BOOL useElapsed = false;
    if( info.fieldFlag == gcFieldFlagWeightedMeanSpeed){

        if( useElapsed ){
            GCField * elapsedfield = [GCField fieldForFlag:gcFieldFlagSumDuration andActivityType:self.activityType];
            GCStatsDataSerieWithUnit * serie = [self distanceSerieForField:elapsedfield];
            if( serie.serie.count > 0 && serie.serie.firstObject.x_data > 0 ){
                [serie.serie addDataPointWithX:0.0 andY:0.0];
                [serie.serie sortByX];
            }
            [[serie.serie asCSVString:false] writeToFile:[RZFileOrganizer writeableFilePath:@"distance.csv"]
                                              atomically:YES encoding:NSUTF8StringEncoding error:nil];
            GCStatsDataSerie * diffSerie = [serie.serie differenceSerieForLag:0.0];
            [[diffSerie asCSVString:false] writeToFile:[RZFileOrganizer writeableFilePath:@"distance_diff.csv"]
                                              atomically:YES encoding:NSUTF8StringEncoding error:nil];

            info.processedPointsCount = diffSerie.count;
            gcStatsSelection select = gcStatsMin;
            GCStatsDataSerie * filled = [diffSerie filledSerieForUnit:10. fillMethod:gcStatsZero statistic:gcStatsSum];
            [[filled asCSVString:false] writeToFile:[RZFileOrganizer writeableFilePath:@"distance_filled.csv"]
                                              atomically:YES encoding:NSUTF8StringEncoding error:nil];

            double //unitstride = [GCAppGlobal configGetDouble:CONFIG_CRITICAL_CALC_UNIT defaultValue:5.];
            unitstride = 10;
            serie.serie = [diffSerie movingBestByUnitOf:unitstride fillMethod:gcStatsZero select:select statistic:gcStatsSum];
            for (GCStatsDataPoint * point in serie.serie) {
                if( point.y_data > 0.){
                    point.y_data = point.x_data/point.y_data; // convert in mps
                }
            }
            serie.unit = [GCUnit mps];
            [serie convertToUnit:[GCUnit minperkm]];
            if( serie.serie.count > 1 && [serie.serie dataPointAtIndex:0].x_data == 0){
                [serie.serie dataPointAtIndex:0].y_data = [serie.serie dataPointAtIndex:1].y_data;
            }

            rv = serie;
        }else{
            
            GCField * distancefield = [GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:self.activityType];
            GCStatsDataSerieWithUnit * serie = [self timeSerieForField:distancefield];
            if( serie.serie.count > 0 && serie.serie.firstObject.x_data > 0 ){
                [serie.serie addDataPointWithX:0.0 andY:0.0];
                [serie.serie sortByX];
            }
            [[serie.serie asCSVString:false] writeToFile:[RZFileOrganizer writeableFilePath:@"s_time.csv"]
                                              atomically:YES encoding:NSUTF8StringEncoding error:nil];

            GCStatsDataSerie * diffSerie = [serie.serie differenceSerieForLag:0.0];
            [[serie.serie asCSVString:false] writeToFile:[RZFileOrganizer writeableFilePath:@"s_time_diff.csv"]
                                              atomically:YES encoding:NSUTF8StringEncoding error:nil];
            info.processedPointsCount = diffSerie.count;
            gcStatsSelection select = gcStatsMax;
            
            GCStatsDataSerie * filled = [diffSerie filledSerieForUnit:10. fillMethod:gcStatsZero statistic:gcStatsSum];
            [[filled asCSVString:false] writeToFile:[RZFileOrganizer writeableFilePath:@"s_time_filled.csv"]
                                              atomically:YES encoding:NSUTF8StringEncoding error:nil];


            double //unitstride = [GCAppGlobal configGetDouble:CONFIG_CRITICAL_CALC_UNIT defaultValue:5.];
            unitstride = 10;
            serie.serie = [diffSerie movingBestByUnitOf:unitstride fillMethod:gcStatsZero select:select statistic:gcStatsSum];
            [serie convertToUnit:[GCUnit meter]];
            for (GCStatsDataPoint * point in serie.serie) {
                if( point.x_data > 0.){
                    point.y_data /= point.x_data; // convert in mps
                }
            }
            serie.unit = [GCUnit mps];
            [serie convertToUnit:[GCUnit minperkm]];
            if( serie.serie.count > 1 && [serie.serie dataPointAtIndex:0].x_data == 0){
                [serie.serie dataPointAtIndex:0].y_data = [serie.serie dataPointAtIndex:1].y_data;
            }
            rv = serie;
        }
    }else{
        
        GCStatsDataSerieWithUnit * serie = timeAxis?[self timeSerieForField:info.field]:[self distanceSerieForField:info.field];
        info.processedPointsCount = serie.serie.count;
        gcStatsSelection select = gcStatsMax;
        if (info.fieldFlag == gcFieldFlagWeightedMeanSpeed && [serie.unit isKindOfClass:[GCUnitInverseLinear class]]) {
            select = gcStatsMin;
        }
        
        double unitstride = [GCAppGlobal configGetDouble:CONFIG_CRITICAL_CALC_UNIT defaultValue:5.];
        if (info.fieldFlag == gcFieldFlagWeightedMeanSpeed) {
            unitstride = 10.;
        }
        
        // HACK serie that are missing zero, as otherwise the best of may not start consistently
        // and doing max over multiple will have weird quirks at the beginning.
        if( serie.serie.count > 0 && serie.serie.firstObject.x_data > 0 ){
            [serie.serie addDataPointWithX:0.0 andY:serie.serie.firstObject.y_data];
            [serie.serie sortByX];
        }
        
        serie.serie = [serie.serie movingBestByUnitOf:unitstride fillMethod:gcStatsZero select:select statistic:gcStatsWeightedMean];
        rv = serie;
    }
    return rv;
}
@end
