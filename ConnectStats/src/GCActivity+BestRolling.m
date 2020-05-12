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

-(GCStatsDataSerieWithUnit*)calculatedRollingBestForSpeed:(GCCalculatedCachedTrackInfo *)info{
    GCStatsDataSerieWithUnit * rv = nil;
    
    BOOL timeByDistance = true;
    BOOL removePause = true;
    
    GCStatsDataSerieWithUnit * serie = nil;
    GCField * referenceField = nil;
    gcStatsSelection select = gcStatsMin;
    
    double unitstride = [GCAppGlobal configGetDouble:CONFIG_CRITICAL_CALC_UNIT defaultValue:10.];
    
    NSArray<GCTrackPoint*>*trackpoints = removePause ? [self removedStoppedTimer:self.trackpoints] : self.trackpoints;

    if( timeByDistance ){
        referenceField = [GCField fieldForFlag:gcFieldFlagSumDuration andActivityType:self.activityType];
        // x is distance, y is time, ratio is mps, so max
        select = gcStatsMin;
        serie = [self trackSerieForField:referenceField trackpoints:trackpoints timeAxis:NO];
    }else{
        referenceField = [GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:self.activityType];
        // x is time, y is distance
        serie = [self trackSerieForField:referenceField trackpoints:trackpoints timeAxis:YES];
        select = gcStatsMax;
        [serie convertToUnit:[GCUnit meter]];
    }

    // Fill for each 10 meter with average seconds of surrounding points
    GCStatsDataSerie * filled = [serie.serie filledSerieForUnit:unitstride fillMethod:gcStatsLinear statistic:gcStatsWeightedMean];
    #if TARGET_IPHONE_SIMULATOR
            [[serie.serie asCSVString:false] writeToFile:[RZFileOrganizer writeableFilePathWithFormat:@"s_raw_%@.csv", self.activityId]
                                              atomically:YES encoding:NSUTF8StringEncoding error:nil];
            [[filled asCSVString:false] writeToFile:[RZFileOrganizer writeableFilePathWithFormat:@"s_filled_%@.csv", self.activityId]
                                            atomically:YES encoding:NSUTF8StringEncoding error:nil];
    #endif

    // Compute the difference between points (so x,y = dist,dTime or y = time,dDistance)
    GCStatsDataSerie * diffSerie = [filled differenceSerieForLag:0.0];
    // Add zero at the beginning if missing
    if( diffSerie.count > 0 && diffSerie.firstObject.x_data > 0 ){
        [diffSerie addDataPointWithX:0.0 andY:0.0];
        [diffSerie sortByX];
    }
    
    info.processedPointsCount = serie.count;
    serie.serie = [diffSerie movingBestByUnitOf:unitstride fillMethod:gcStatsLinear select:select statistic:gcStatsSum];

#if TARGET_IPHONE_SIMULATOR
    // rescale by unit of 10 (either every 10 seconds or every 10 meters.
    // For debugging
    [[serie.serie asCSVString:false] writeToFile:[RZFileOrganizer writeableFilePathWithFormat:@"s_best_%@.csv", self.activityId]
                                      atomically:YES encoding:NSUTF8StringEncoding error:nil];
#endif

    // Convert the best time to speed
    for (GCStatsDataPoint * point in serie.serie) {
        if( point.y_data > 0.){
            
            // Add unitstride because a point is applicable between x and next point (= x+stride)
            // Otherwise the early stage will be counted wrong:
            //   x = 0*stride -> y_0 meters, x = 1*stride - > y_1
            //=>         y_0 / 1*stride,        y_1 / (2*stride)
            
            if( timeByDistance ){
                // x: distance, y: time
                // x_i / y_i   vs x_i+1 / y_i+1, if x_i
                point.y_data = (point.x_data/*+unitstride*/)/point.y_data; // convert in mps
            }else{
                // x: time, y: distance
                point.y_data = point.y_data/( point.x_data + unitstride ); // convert in mps
            }
        }
    }
    serie.unit = [GCUnit mps];
    #if TARGET_IPHONE_SIMULATOR
            // rescale by unit of 10 (either every 10 seconds or every 10 meters.
            // For debugging
    [[serie.serie asCSVString:false] writeToFile:[RZFileOrganizer writeableFilePathWithFormat:@"s_finalmps_%@.csv", self.activityId]
                                              atomically:YES encoding:NSUTF8StringEncoding error:nil];
    #endif

    [self rollingBestMatchMaxForField:info.underlyingField andSerie:serie];
    [self rollingBestCorrectMonotonicity:serie select:select==gcStatsMin?gcStatsMax:gcStatsMin];

    if( serie.serie.count > 1 && [serie.serie dataPointAtIndex:0].x_data == 0){
        [serie.serie dataPointAtIndex:0].y_data = [serie.serie dataPointAtIndex:1].y_data;
    }

    #if TARGET_IPHONE_SIMULATOR
            // rescale by unit of 10 (either every 10 seconds or every 10 meters.
            // For debugging
    [[serie.serie asCSVString:false] writeToFile:[RZFileOrganizer writeableFilePathWithFormat:@"s_finalcorrected_%@.csv", self.activityId]
                                              atomically:YES encoding:NSUTF8StringEncoding error:nil];
    #endif

    [serie convertToUnit:[self speedDisplayUnit]];

    rv = serie;
    return rv;
}

-(void)rollingBestMatchMaxForField:(GCField*)field andSerie:(GCStatsDataSerieWithUnit*)serie{
    GCField * maxfield = field.correspondingMaxField;
    
    GCNumberWithUnit * max_nu = [self numberWithUnitForField:maxfield];
    if( max_nu == nil ){
        maxfield = maxfield.correspondingPaceOrSpeedField;
        if( maxfield ){
            max_nu = [self numberWithUnitForField:maxfield];
        }
    }
    if( max_nu ){
        double maxValue = [max_nu convertToUnit:serie.unit].value;
        NSUInteger n = 0;
        
        for (GCStatsDataPoint * point in serie.serie) {
            double y_data = point.y_data;
            if(y_data > maxValue || y_data == 0.){
                point.y_data = maxValue;
                n++;
            }else{
                // as soon as we reach something below max, stop
                break;
            }
        }
        if( n > 0){
            RZLog(RZLogInfo, @"%@ BestRolling for %@ capped %@/%@ points greater than %@ = %@",self, field, @(n),@(serie.count), maxfield, max_nu );
        }
    }
}

-(void)rollingBestCorrectMonotonicity:(GCStatsDataSerieWithUnit*)serie select:(gcStatsSelection)select{
    double last_y = 0.;
    for (GCStatsDataPoint * point in serie) {
        if( last_y == 0.){
            last_y = point.y_data;
        }else{
            if( (select == gcStatsMax && last_y < point.y_data) ||
               (select == gcStatsMin && last_y > point.y_data) )
            {
                point.y_data = last_y;
            }else{
                last_y = point.y_data;
            }
        }
    }
}

-(GCStatsDataSerieWithUnit*)calculatedRollingBestSimpleSpeed:(GCCalculatedCachedTrackInfo*)info{
    GCStatsDataSerieWithUnit * rv = nil;
    
    BOOL useTimeAxis = false;
    BOOL removePause = true;
    
    NSArray<GCTrackPoint*>*trackpoints = removePause ? [self removedStoppedTimer:self.trackpoints] : self.trackpoints;
    
    GCStatsDataSerieWithUnit * serie = [self trackSerieForField:info.underlyingField trackpoints:trackpoints timeAxis:useTimeAxis];
    
    // Convert to a unit that is by distance so the interpolation will work
    // otherwise mps interpolated by distance will be messed up
    [serie convertToUnit:[GCUnit minperkm]];
    
    #if TARGET_IPHONE_SIMULATOR
    [[serie.serie asCSVString:false] writeToFile:[RZFileOrganizer writeableFilePathWithFormat:@"s_simpleraw_%@.csv", self.activityId]
                                              atomically:YES encoding:NSUTF8StringEncoding error:nil];
    #endif

    info.processedPointsCount = serie.serie.count;
    // Min because we switched to minperkm so min is better
    gcStatsSelection select = gcStatsMin;

    double unitstride = [GCAppGlobal configGetDouble:CONFIG_CRITICAL_CALC_UNIT defaultValue:10.];
    
    // HACK serie that are missing zero, as otherwise the best of may not start consistently
    // and doing max over multiple will have weird quirks at the beginning.
    if( serie.serie.count > 0 && serie.serie.firstObject.x_data > 0 ){
        [serie.serie addDataPointWithX:0.0 andY:serie.serie.firstObject.y_data];
        [serie.serie sortByX];
    }
    
    // If remove pause, then do linear interpolation, otherwise fill with zeros (assuming pause)
    serie.serie = [serie.serie movingBestByUnitOf:unitstride fillMethod:removePause ? gcStatsLinear :gcStatsZero select:select statistic:gcStatsWeightedMean];

    [self rollingBestMatchMaxForField:info.underlyingField andSerie:serie];
    [self rollingBestCorrectMonotonicity:serie select:select];
    // Convert back to what make sense
    [serie convertToUnit:[self speedDisplayUnit]];
    
    rv = serie;

    return rv;

}

-(GCStatsDataSerieWithUnit*)calculatedRollingBestSimple:(GCCalculatedCachedTrackInfo*)info{
    GCStatsDataSerieWithUnit * rv = nil;
    
    BOOL useTimeAxis = true;
    BOOL removePause = true;
    
    NSArray<GCTrackPoint*>*trackpoints = removePause ? [self removedStoppedTimer:self.trackpoints] : self.trackpoints;
    
    GCStatsDataSerieWithUnit * serie = [self trackSerieForField:info.underlyingField trackpoints:trackpoints timeAxis:useTimeAxis];
    
    info.processedPointsCount = serie.serie.count;
    gcStatsSelection select = gcStatsMax;
    if ([serie.unit isKindOfClass:[GCUnitInverseLinear class]]) {
        select = gcStatsMin;
    }

    double unitstride = [GCAppGlobal configGetDouble:CONFIG_CRITICAL_CALC_UNIT defaultValue:10.];
    
    // HACK serie that are missing zero, as otherwise the best of may not start consistently
    // and doing max over multiple will have weird quirks at the beginning.
    if( serie.serie.count > 0 && serie.serie.firstObject.x_data > 0 ){
        [serie.serie addDataPointWithX:0.0 andY:serie.serie.firstObject.y_data];
        [serie.serie sortByX];
    }
    
    // If remove pause, then do linear interpolation, otherwise fill with zeros (assuming pause)
    serie.serie = [serie.serie movingBestByUnitOf:unitstride fillMethod:removePause ? gcStatsLinear :gcStatsZero select:select statistic:gcStatsWeightedMean];

    [self rollingBestMatchMaxForField:info.underlyingField andSerie:serie];
    [self rollingBestCorrectMonotonicity:serie select:select];
    
    rv = serie;

    return rv;
}

-(GCStatsDataSerieWithUnit*)calculatedRollingBest:(GCCalculatedCachedTrackInfo *)info{
    GCStatsDataSerieWithUnit * rv = nil;

    if( info.underlyingFieldFlag == gcFieldFlagWeightedMeanSpeed){
        //rv= [self calculatedRollingBestSimpleSpeed:info];
        rv = [self calculatedRollingBestForSpeed:info];
        
    }else{
        rv= [self calculatedRollingBestSimple:info];
    }
    return rv;
}


@end
