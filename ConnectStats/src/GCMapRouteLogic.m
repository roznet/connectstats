//  MIT Licence
//
//  Created on 19/02/2014.
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

#import "GCMapRouteLogic.h"
#import <CoreLocation/CoreLocation.h>
#import "GCActivity.h"
#import "GCAppGlobal.h"


#pragma mark

@implementation GCMapRouteLogic

+(GCMapRouteLogic*)routeLogicFor:(GCActivity*)act field:(GCField*)f andColors:(GCViewGradientColors*)col{
    GCMapRouteLogic * rv = [[[GCMapRouteLogic alloc] init] autorelease];
    if (rv) {
        rv.activity = act;
        rv.gradientColors = col;
        rv.gradientField = f;
        rv.showLaps = false;
        rv.maxPoints = 4000U;
    }
    return rv;
}
+(GCMapRouteLogic*)routeLogicFor:(GCActivity*)act field:(GCField*)f colors:(GCViewGradientColors*)col andLap:(NSUInteger)l{
    GCMapRouteLogic * rv = [GCMapRouteLogic routeLogicFor:act field:f andColors:col];
    if (rv) {
        rv.showLaps = true;
        rv.lapIndex = l;
    }
    return rv;
}

+(GCMapRouteLogic*)routeLogicFor:(GCActivity*)act comparedTo:(GCActivity*)other andColors:(GCViewGradientColors*)col{
    GCMapRouteLogic * rv = [GCMapRouteLogic routeLogicFor:act field:nil andColors:col];
    if (rv) {
        rv.compareActivity = other;
    }
    return rv;

}
-(void)dealloc{
    [_activity release];
    [_gradientField release];
    [_gradientColors release];
    [_points release];
    [_compareActivity release];
    [_thresholds release];

    [super dealloc];
}

-(NSUInteger)countOfPoints{
    return _points.count;
}
-(GCMapRouteLogicPointHolder*)pointFor:(NSUInteger)idx{
    return idx < _points.count ? _points[idx] : nil;
}

-(void)calculate{
    CLLocationCoordinate2D northEastPoint = CLLocationCoordinate2DMake(0., 0.);
	CLLocationCoordinate2D southWestPoint = CLLocationCoordinate2DMake(0., 0.);

	NSArray * points = [self.activity trackpoints];
    if (points && points.count) {

        GCUnit * displayUnit = nil;
        GCUnit * pointUnit   = nil;

        GCStatsDataSerieWithUnit * valsWUnit =nil;
        if (self.compareActivity) {
            // Can only be time axis based.
            valsWUnit = [self.activity cumulativeDifferenceSerieWith:self.compareActivity timeAxis:true];
            displayUnit = valsWUnit.unit;

        }else{
            displayUnit = [[self.activity displayUnitForField:self.gradientField] unitForGlobalSystem];
            pointUnit   = [GCTrackPoint unitForField:self.gradientField.fieldFlag
                                              andActivityType:self.activity.activityType];
            valsWUnit = [self.activity timeSerieForField:self.gradientField];
            [valsWUnit convertToUnit:displayUnit];
        }

        GCStatsDataSerie * vals = valsWUnit.serie;
        GCStatsDataSerie * colorThresholds= [vals quantiles:self.gradientColors.numberOfColors];

        BOOL started=false;

        size_t movingAverage = 0;

        if ([self.gradientField isNoisy]) {
            movingAverage = 10;
        }else{
            movingAverage = 0;
        }

        double * samples = movingAverage > 0 ? calloc(movingAverage,sizeof(double)) : nil;

        NSMutableArray * thresholdsArray = [NSMutableArray arrayWithCapacity:[colorThresholds count]];
        double * thresholds = calloc(colorThresholds.count, sizeof(double));
        size_t n = [colorThresholds count];
        size_t idx=0;

        for (idx=0; idx<n; idx++) {
            double val =[colorThresholds dataPointAtIndex:idx].y_data;
            [thresholdsArray addObject:@(val)];
            thresholds[idx]=val;
        }

        size_t sample_idx = 0;
        size_t sample_n = 0;
        double runningSum = 0.;

        NSUInteger count = 0;
        NSUInteger mod = points.count/self.maxPoints;
        if (![GCAppGlobal configGetBool:CONFIG_FASTER_MAPS defaultValue:YES]) {
            mod=0;
        }
        if (mod!=0) {
            RZLog(RZLogInfo, @"Skipping point for map (%d use every %d)",(int)[points count], (int)mod);
        }
        NSMutableArray * output = [NSMutableArray arrayWithCapacity:points.count];
        NSUInteger lastIdx = 0;
        BOOL pathStart = true;

        NSUInteger serieIndex = 0;
        GCStatsDataPoint * seriePoint = nil;

        double startTime = points.count > 0 ? [[points[0] time] timeIntervalSinceReferenceDate] : 0.;

        for (GCTrackPoint * aPoint in points) {
            if (mod!=0 && count++%mod!=0) {
                continue;
            }

            // break the string down even further to latitude and longitude fields.
            // double lon = [aPoint longitudeDegrees];
            if ([aPoint validCoordinate]) {
                CLLocationCoordinate2D point = [aPoint coordinate2D];

                if (self.lapsRectOnFullRoute == false) {
                    if (self.showLaps == gcLapDisplaySingle && aPoint.lapIndex != self.lapIndex) {
                        pathStart = true; // new path as we just changed lap
                        continue;
                    }
                }

                if (!started) {
                    northEastPoint = point;
                    southWestPoint = point;
                    started = true;
                }
                else
                {
                    if (point.latitude > northEastPoint.latitude)
                        northEastPoint.latitude = point.latitude;
                    if(point.longitude > northEastPoint.longitude)
                        northEastPoint.longitude = point.longitude;
                    if (point.latitude < southWestPoint.latitude)
                        southWestPoint.latitude = point.latitude;
                    if (point.longitude < southWestPoint.longitude)
                        southWestPoint.longitude = point.longitude;
                }

                // second time after calculating full course rect
                if (self.showLaps == gcLapDisplaySingle && aPoint.lapIndex != self.lapIndex) {
                    pathStart = true; // new path as we just changed lap
                    continue;
                }

                double v = 0.;

                double x = aPoint.time.timeIntervalSinceReferenceDate - startTime;
                while (seriePoint.x_data < x && ++serieIndex < vals.count) {
                    seriePoint = [vals dataPointAtIndex:serieIndex];
                }
                v = seriePoint.y_data;

                if (samples && !isinf(v)) {
                    if (sample_n < movingAverage) {
                        sample_n++;
                        samples[sample_idx++] = v;
                        runningSum += v;
                    }else{
                        runningSum += v-samples[sample_idx];
                        samples[sample_idx]=v;
                        sample_idx++;
                        v = (runningSum/movingAverage);
                    }

                    if (sample_idx == movingAverage) {
                        sample_idx = 0;
                    }
                }

                for (idx=0; idx<n; idx++) {
                    double th = thresholds[idx];
                    if (v<th) {
                        break;
                    }
                }
                CGFloat val = (float)idx/n;

                GCMapRouteLogicPointHolder * holder = [GCMapRouteLogicPointHolder pointHolder:point color:[UIColor colorWithCGColor:[self.gradientColors colorsForValue:val]] start:pathStart];
                if (started && lastIdx != idx) {
                    holder.changeColor = true;
                }else{
                    holder.changeColor = false;
                }
                [output addObject:holder];
                lastIdx = idx;
                pathStart = false;

            }
        }
        self.northEastPoint = northEastPoint;
        self.southWestPoint = southWestPoint;
        self.points = output;
        self.thresholds = thresholdsArray;

        // clear the memory allocated earlier for the points
        free(samples);
        free(thresholds);
    }
}

-(CLLocationCoordinate2D)centerPoint{
    return CLLocationCoordinate2DMake((self.northEastPoint.latitude+self.southWestPoint.latitude)/2.,
                                      (self.northEastPoint.longitude+self.southWestPoint.longitude)/2.);
}
-(MKMapPoint)centerMapPoint{
    return MKMapPointForCoordinate(self.centerPoint);
}
-(MKMapPoint)northEastMapPoint{
    return MKMapPointForCoordinate(self.northEastPoint);
}
-(MKMapPoint)southWestMapPoint{
    return MKMapPointForCoordinate(self.southWestPoint);
}

-(MKMapRect)routeMapRect{
    MKMapPoint southWestPoint = self.southWestMapPoint;
    MKMapPoint northEastPoint = self.northEastMapPoint;

    MKMapRect rv = MKMapRectMake(southWestPoint.x, northEastPoint.y, northEastPoint.x - southWestPoint.x, southWestPoint.y-northEastPoint.y );
    rv = MKMapRectInset(rv, MKMapRectGetWidth(rv)*-0.1, MKMapRectGetHeight(rv)*-0.1);

    return rv;
}
@end
