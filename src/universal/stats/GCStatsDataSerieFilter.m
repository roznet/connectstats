//  MIT Licence
//
//  Created on 02/04/2013.
//
//  Copyright (c) 2013 Brice Rosenzweig.
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

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif
#import "GCStatsDataSerieFilter.h"
#import "RZLog.h"
#import "RZMacros.h"

@implementation GCStatsDataSerieFilter

#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_unit release];
    [super dealloc];
}
#endif

-(void)disableAll{
    self.filterHighAcceleration = false;
    self.filterMaxValue = false;
    self.filterMinValue = false;
}
-(GCStatsDataSerie*)filteredSerieFrom:(GCStatsDataSerie*)serie{

    GCStatsDataSerie * rv = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);
    GCStatsDataPoint * lastpoint = nil;

    BOOL keep;

    NSUInteger filtered = 0;

    double dt_threshold = self.ignore_dt;

    for (GCStatsDataPoint * point in serie) {
        keep = true;

        if (!point.hasValue) {
            [rv addDataPointNoValueWithX:point.x_data];
            lastpoint = nil;
            continue;
        }

        double dt = lastpoint ? point.x_data-lastpoint.x_data : 0.;
        if( dt_threshold == 0. || dt < dt_threshold){// don't apply if dt too big
            if (self.filterHighAcceleration) {
                if (lastpoint) {
                    double y     = point.y_data;
                    double lasty = lastpoint.y_data;
                    double dy    = y-lasty;
                    double dydt  = fabs( (dy)/(dt));

                    if (((y>self.maxAccelerationSpeedThreshold || lasty>self.maxAccelerationSpeedThreshold) && dydt > self.maxAcceleration)) {
                        keep = false;
                    }
                }
            }
            if (self.filterMaxValue && point.y_data > self.maxValue) {
                keep = false;
            }
            if (self.filterMinValue && point.y_data < self.minValue) {
                keep = false;
            }
        }
        if (keep) {
            [rv addDataPointWithDate:point.date andValue:point.y_data];
        }else{
            filtered++;
        }
        lastpoint = point;
    }
    return rv;
}

-(GCStatsDataSerieWithUnit*)filteredSerieWithUnitFrom:(GCStatsDataSerieWithUnit*)aSerie{
    GCStatsDataSerieWithUnit * rv = RZReturnAutorelease([[GCStatsDataSerieWithUnit alloc] init] );
    rv.unit = aSerie.unit;
    rv.serie = aSerie.serie;

    if (self.unit) {
        [rv convertToUnit:self.unit];
    }
    rv.serie = [self filteredSerieFrom:rv.serie];
    [rv convertToUnit:aSerie.unit];
    return rv;
}
@end
