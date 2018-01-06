//  MIT Licence
//
//  Created on 30/09/2012.
//
//  Copyright (c) 2012 Brice Rosenzweig.
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

#import "GCTrackStats.h"
#import "GCHealthZoneCalculator.h"
#import "GCTrackPoint.h"
#import "GCActivity+CachedTracks.h"
#import "GCAppGlobal.h"

@interface GCTrackStats ()
@property (nonatomic,retain) GCStatsDataSerieWithUnit * data;
@property (nonatomic,retain) GCStatsDataSerieWithUnit * extra_data;
@property (nonatomic,retain) GCStatsDataSerie * gradientSerie;
@property (nonatomic,retain) NSObject<GCStatsFunction> * gradientFunction;

@end

@implementation GCTrackStats


-(BOOL)timeAxis{
    return !self.distanceAxis;
}
-(void)setTimeAxis:(BOOL)timeAxis{
    self.distanceAxis = !timeAxis;
}

-(NSUInteger)nDataSeries{
    return self.extra_data ? 2 : 1;
}

-(GCStatsDataSerie * )dataSerie:(NSUInteger)idx{
    if (idx==1 && self.extra_data) {
        return self.extra_data.serie;
    }
    if (_data != nil) {
        return _data.serie;
    }
    return _data.serie;
}

-(gcStatsRange)rangeForSerie:(NSUInteger)idx{
    return [[self dataSerie:idx] range];
}

-(void)dealloc{
    [_field release];
    [_x_field release];
    [_l_field release];

    [_data release];
    [_extra_data release];
    [_activity release];
    [_gradientFunction release];
    [_gradientSerie release];
    [_zoneCalculator release];
    [_fieldSourceMap release];
    [_compareActivity release];

    [super dealloc];
}

-(void)updateConfigFrom:(GCTrackStats*)other{
    self.field = other.field;
    self.x_field = other.x_field;
    self.l_field = other.l_field;
    self.data = nil;
    self.activity = other.activity;
    self.movingAverage = other.movingAverage;
    self.x_movingAverage = other.x_movingAverage;
    self.l_movingAverage = other.l_movingAverage;
    self.statsStyle = other.statsStyle;
    self.fieldSourceMap = other.fieldSourceMap;
    self.movingSumForUnit = other.movingSumForUnit;
    self.bucketUnit = other.bucketUnit;
    self.zoneCalculator = other.zoneCalculator;
    self.highlightLapIndex = other.highlightLapIndex;
    self.highlightLap = other.highlightLap;
}

-(CGFloat)maxValue{
    return [self.data.serie max].y_data;
}
-(CGFloat)minValue{
    return [self.data.serie min].y_data;
}

-(NSUInteger)estimateMovingAverageFor:(GCStatsDataSerie*)serie{
    GCStatsDataSerie * counts = [serie countByXInterval:10. xMax:120.];// first 2min sample
    if (counts.count<2) { // degenerate case,
        return 0;
    }
    GCStatsDataPoint * avg = [[counts average] dataPointAtIndex:0];
    NSUInteger maPoints = ceil(avg.y_data);

    return maPoints;
}

-(void)defaultMovingAverage{

    if (self.field && self.movingAverage==0 && [self.field isNoisy]) {
        self.movingAverage = [self estimateMovingAverageFor:self.data.serie];
    }
    if (self.x_field && self.x_movingAverage==0 && [self.x_field isNoisy]) {
        self.x_movingAverage=10;
    }
    if (self.l_field && self.l_movingAverage==0 && [self.l_field isNoisy]) {
        self.l_movingAverage=10;
    }
}

#pragma mark - Setup

-(GCStatsDataSerieWithUnit*)serieForStyle:(gcTrackStatsStyle)statsStyle field:(GCField*)field{

    GCStatsDataSerieWithUnit * rv = nil;

    GCField * useField = self.fieldSourceMap[field] ?: field;

    switch (statsStyle) {
        case gcTrackStatsData:
        {

            if (self.distanceAxis) {
                rv = [self.activity distanceSerieForField:useField];
            }else{
                rv = [self.activity timeSerieForField:useField];
            }
            [self defaultMovingAverage];
            if (self.movingAverage > 0) {
                rv = [rv movingAverage:self.movingAverage];
            }
            break;
        }

        case gcTrackStatsRollingBest:
        {
            GCStatsDataSerieWithUnit * nu = [self.activity calculatedDerivedTrack:gcCalculatedCachedTrackRollingBest forField:field thread:[GCAppGlobal worker]];
            [nu convertToGlobalSystem];

            if(self.field.fieldFlag == gcFieldFlagPower && [GCAppGlobal configGetBool:CONFIG_POWER_CURVE_LOG_SCALE defaultValue:true]){
                GCUnit * logScale = [GCUnitLogScale logScaleUnitFor:nu.xUnit base:10. scaling:0.1 shift:1.];
                [nu convertToXUnit:logScale];
            }

            rv = nu;
            break;
        }
        case gcTrackStatsHistogram:
        {
            GCStatsDataSerieWithUnit * serie = [self.activity timeSerieForField:useField];
            // Special for power, filter zero values
            if (self.field.fieldFlag == gcFieldFlagPower) {
                GCStatsDataSerieFilter * filter = [[GCStatsDataSerieFilter alloc] init];
                filter.minValue = 0.000001;
                filter.filterMinValue = true;
                serie = [filter filteredSerieWithUnitFrom:serie];
                [filter release];
            }
            rv = [serie histogramWith:30];
            break;
        }
        case gcTrackStatsCumulative:
        {
            rv = [[self.activity timeSerieForField:useField] cumulative];
            break;
        }
        case gcTrackStatsBucket:
        {
            if ([field canSum]){
                rv = [[self.activity timeSerieForField:useField] summedBy:self.bucketUnit];
            }else{
                rv = [[self.activity timeSerieForField:useField] filledForUnit:self.bucketUnit];
            }
            break;
        }
        case gcTrackStatsCompare:
        {
            if (self.compareActivity) {
                rv = [self.activity cumulativeDifferenceSerieWith:self.compareActivity timeAxis:self.timeAxis];
            }
        }
    }

    return rv;
}

-(void)setupForFieldFlags:(gcFieldFlag)aField xField:(gcFieldFlag)xField andLField:(gcFieldFlag)lField{
    NSString * activityType = self.activity.activityType;
    [self setupForField:[GCField fieldForFlag:aField andActivityType:activityType]
                 xField:xField ? [GCField fieldForFlag:xField andActivityType:activityType] : nil
              andLField:lField ? [GCField fieldForFlag:lField andActivityType:activityType] : nil];
}

-(void)setNeedsForRecalculate{
    self.data = nil;
}
-(void)setupForField:(GCField*)aField xField:(GCField*)xField andLField:(GCField*)lField{
    if (self.data != nil &&
        [aField isEqualToField:self.field] &&
        ((xField == nil && self.x_field == nil) || [xField isEqualToField:self.x_field] ) &&
        ((lField == nil && self.l_field == nil) || [lField isEqualToField:self.l_field] ) ){
        return;
    }
    self.field = aField;
    self.x_field= xField;
    self.l_field=lField;

    self.data = [self serieForStyle:self.statsStyle field:self.field];

    if (xField!=gcFieldFlagNone) {

        GCStatsDataSerieWithUnit * xdata = [self serieForStyle:self.statsStyle field:self.x_field];

        [GCStatsDataSerieWithUnit reduceToCommonRange:self.data and:xdata];

        if (self.highlightLap) {
            self.gradientSerie = self.data.serie;
            GCStatsDataSerie * gserie = [self.activity highlightSerieForLap:self.highlightLapIndex timeAxis:!self.distanceAxis];
            GCStatsScaledFunction * scaledF= [GCStatsScaledFunction scaledFunctionWithSerie:gserie];
            self.gradientFunction = scaledF;
        }else{
            self.gradientSerie = self.data.serie;
            GCStatsScaledFunction * scaledF= [GCStatsScaledFunction scaledFunctionWithSerie:self.gradientSerie];
            [scaledF setScale_x:true];
            self.gradientFunction = scaledF;
        }
        GCStatsDataSerieWithUnit * xy = [GCStatsInterpFunction xySerieWithUnitForX:xdata andY:self.data];
        if (self.x_field.fieldFlag == gcFieldFlagSumDistance) {
            [xy.serie sortByX];
        }
        self.data = xy;
    }else if (lField!=nil){
        GCStatsDataSerieWithUnit * ldata = [self serieForStyle:self.statsStyle field:self.l_field];
        if (self.l_movingAverage > 0) {
            ldata = [ldata movingAverage:self.l_movingAverage];
        }
        self.gradientSerie = self.data.serie;
        self.gradientFunction = [GCStatsQuantileFunction quantileFunctionWith:ldata.serie andQuantiles:16];
    }else if(self.highlightLap){
        GCStatsDataSerie * gserie = [self.activity highlightSerieForLap:self.highlightLapIndex timeAxis:!self.distanceAxis];
        if (self.zoneCalculator) {
            // extra data is the bucket for the lap, data for the whole serie so we see the lap over total
            self.extra_data = [[self.data filterForNonZeroIn:gserie] bucketWith:[self.zoneCalculator bucketSerieWithUnit]];
            self.data = [self.data bucketWith:[self.zoneCalculator bucketSerieWithUnit]];
        }else{
            GCStatsNonZeroIndicatorFunction * scaledF= [GCStatsNonZeroIndicatorFunction nonZeroIndicatorFor:gserie];
            self.gradientFunction = scaledF;
            self.gradientSerie = self.data.serie;
        }
    }else if(self.zoneCalculator) {
        self.data = [self.data bucketWith:[self.zoneCalculator bucketSerieWithUnit:self.data.unit]];
    }

    if (xField==nil && self.activity.garminSwimAlgorithm) {
        self.gradientSerie = [self.activity timeSerieForSwimStroke];
        [self setGradientFunction:nil];
    }
}

#pragma mark - Data Source

-(GCUnit*)yUnit:(NSUInteger)idx{
    if (self.statsStyle==gcTrackStatsHistogram) {
        return [GCUnit unitForKey:@"dimensionless"];
    }
    return self.data.unit;
}

-(GCUnit*)xUnit{
    if (self.statsStyle==gcTrackStatsHistogram) {
        return [self.activity displayUnitForField:self.field];
    }else if (self.x_field == gcFieldFlagNone) {
        if (self.data.xUnit) {
            return self.data.xUnit;
        }else{
            return self.distanceAxis ? [GCUnit unitForKey:STOREUNIT_DISTANCE] : [GCUnit unitForKey:@"second"];
        }
    }else{
        return [self.activity displayUnitForField:self.x_field];
    }
}

-(NSString*)title{
    if (self.zoneCalculator) {
        return [NSString stringWithFormat:@"%@ (time in zone)", [self.field displayName]];
    }else if( self.statsStyle == gcTrackStatsCompare){
        if (self.timeAxis) {
            return [NSString stringWithFormat:NSLocalizedString(@"Distance ahead (+) in %@", @"Compare Title"),
                    self.data.unit.display
                    ];
        }else{
            return [NSString stringWithFormat:NSLocalizedString(@"Time ahead (+) in %@", @"Compare Title"),
                    self.data.unit.display
                    ];

        }
    }else{
        return [self.field displayNameWithUnits:[self yUnit:0]];
    }
}

-(CGPoint)currentPoint:(NSUInteger)idx{
    return CGPointMake(0., 0.);
}
-(NSString*)legend:(NSUInteger)idx{
    return nil;
}

@end
