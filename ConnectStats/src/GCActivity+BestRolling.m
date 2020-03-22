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

@implementation GCActivity (BestRolling)

-(GCStatsDataSerieWithUnit*)calculatedRollingBest:(GCCalculactedCachedTrackInfo *)info{
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
            [[serie.serie asCSVString:false] writeToFile:[RZFileOrganizer writeableFilePath:@"time.csv"]
                                              atomically:YES encoding:NSUTF8StringEncoding error:nil];

            GCStatsDataSerie * diffSerie = [serie.serie differenceSerieForLag:0.0];
            [[serie.serie asCSVString:false] writeToFile:[RZFileOrganizer writeableFilePath:@"time_diff.csv"]
                                              atomically:YES encoding:NSUTF8StringEncoding error:nil];
            info.processedPointsCount = diffSerie.count;
            gcStatsSelection select = gcStatsMax;
            
            GCStatsDataSerie * filled = [diffSerie filledSerieForUnit:10. fillMethod:gcStatsZero statistic:gcStatsSum];
            [[filled asCSVString:false] writeToFile:[RZFileOrganizer writeableFilePath:@"time_filled.csv"]
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
