//  MIT Licence
//
//  Created on 23/12/2013.
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

#import "GCActivity+CachedTracks.h"
#import "GCFields.h"
#import "GCAppGlobal.h"
#import "GCActivity+Fields.h"

@interface GCCalculactedCachedTrackInfo : NSObject

@property (nonatomic,assign) gcCalculatedCachedTrack track;
@property (nonatomic,retain) GCField * field;
@property (nonatomic,retain) GCStatsDataSerieWithUnit * serie;
@property (nonatomic,retain) NSArray * trackpoints;

+(GCCalculactedCachedTrackInfo*)info:(gcCalculatedCachedTrack)track field:(GCField*)field;
-(gcFieldFlag)fieldFlag;
@end

@implementation GCCalculactedCachedTrackInfo

/**

 */
+(GCCalculactedCachedTrackInfo*)info:(gcCalculatedCachedTrack)atrack field:(GCField*)afield{
    GCCalculactedCachedTrackInfo * rv = [[[GCCalculactedCachedTrackInfo alloc] init] autorelease];
    if (rv) {
        rv.track = atrack;
        rv.field = afield;
        rv.serie = nil;
    }
    return rv;
}

-(gcFieldFlag)fieldFlag{
    return _field.fieldFlag;
}

-(void)dealloc{
    [_serie release];
    [_field release];
    [_trackpoints release];

    [super dealloc];
}




@end

#define MAX_FILL_POINTS 28800


@implementation GCActivity (CachedTracks)


-(nonnull NSArray<GCTrackPoint*>*)resample:(nonnull NSArray<GCTrackPoint*>*)points forUnit:(double)unit useTimeAxis:(BOOL)timeAxis{

#define X_FOR(p) (timeAxis ? p.elapsed : p.distanceMeters)

    GCTrackPoint * first_p = points[0];
    size_t last_i   = 0;
    double first_x  =  X_FOR(first_p);

    BOOL inconsistentPoint=false;

    NSUInteger n = points.count;

    double accrued = 0.;

    GCTrackPoint * currentPoint = [[GCTrackPoint alloc] init];

    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:n];
    [rv addObject:currentPoint];

    for (NSUInteger idx_p = 1;idx_p <= n;idx_p++) {
        GCTrackPoint * from_p = points[idx_p-1];
        GCTrackPoint * to_p   = idx_p < n ? points[idx_p] : nil;

        //double elapsed  = [to_p.time timeIntervalSinceDate:from_p.time];
        //double distance = to_p.validCoordinate && from_p.validCoordinate ? [to_p distanceMetersFrom:from_p] : to_p.distanceMeters-from_p.distanceMeters;

        double from_x  = X_FOR(from_p)-first_x;
        double to_x    = to_p ? X_FOR(to_p)-first_x : from_x;

        NSUInteger from_i = MIN(from_x/unit,MAX_FILL_POINTS-1);
        NSUInteger to_i   = MIN(to_x/unit,MAX_FILL_POINTS-1);

        if (from_i!=last_i) {
            inconsistentPoint = true;
        }

        //last_i = to_i;

        if (to_p == nil) {
            // last point allocated to last
            [currentPoint add:from_p withAccrued:(unit-accrued)/unit timeAxis:timeAxis];
            // values[from_i] += from_p.y_data * (unit - accrued)/unit;
        }else if ( to_i==from_i) {
            // didn't cross to next point yet, weighted allocation to current i
            //      f     t
            // I: --|aa---|---
            // P: ----X-X-----
            //        f t
            [currentPoint add:from_p withAccrued:(to_x-from_x)/unit timeAxis:timeAxis];
            // values[from_i] += from_p.y_data * (to_x-from_x)/unit;
            accrued += (to_x-from_x);
        }else{
            // got to next
            //
            //    f     t
            // I: |aaa--|-----|-----|-----|
            // P:  --X-----X----------
            //       f     t
            //
            //    f     s     s     t
            // I: |aaa--|-----|-----|-----|
            // P:  --X----------------X---
            //       f                t

            for (size_t step_i = from_i; step_i<to_i; step_i++) {
                size_t next_i = step_i+1;
                double next_x = unit*next_i;

                double step_x = step_i == from_i ? from_x : unit*step_i;

                double weight =(next_x-step_x)/unit;
                // fill steps to far from last with zero (else with last value)
                // could impose limit: fill w zero when more than L since last
                /* if (step_i!=from_i && fill == gcStatsZero) {
                 step_v = 0.;
                 }*/

                [currentPoint add:from_p withAccrued:weight timeAxis:timeAxis];
                last_i = step_i;

                if (next_i < MAX_FILL_POINTS && next_i == to_i) {
                    [currentPoint release];
                    currentPoint = [[GCTrackPoint alloc] init];
                    [rv addObject:currentPoint];
                    [currentPoint add:from_p withAccrued:(to_x-next_x)/unit timeAxis:timeAxis];
                    last_i = to_i;
                    accrued = (to_x-next_x);
                }
            }
        }
    }
    [currentPoint release];
    if (inconsistentPoint) {
        RZLog(RZLogError, @"Logic Error: Inconsistent x");
    }

    return rv;
}

-(NSString*)calculatedCachedTrackKey:(gcCalculatedCachedTrack)track forField:(GCField*)field{
    if (track == gcCalculatedCachedTrackDataSerie) {
        return field.key;
    }else{
        NSString * prefix = @"__RollingBest";
        if (track==gcCalculatedCachedTrackDistanceResample) {
            prefix = @"__DistanceResample";
        }
        return [NSString stringWithFormat:@"%@%@", prefix, field.key];
    }
}

-(void)calculatedCachedTrackCalculations{
    NSMutableDictionary * rv = [NSMutableDictionary dictionaryWithCapacity:(self.cachedCalculatedTracks).count];
    RZPerformance * perf = [RZPerformance start];
    NSUInteger i = 0;
    NSUInteger pts = 0;
    GCCalculactedCachedTrackInfo * info = nil;
    for (NSString * key in self.cachedCalculatedTracks) {
        id obj = (self.cachedCalculatedTracks)[key];
        if ([obj isKindOfClass:[GCCalculactedCachedTrackInfo class]]) {
            info = obj;

            if (info.track==gcCalculatedCachedTrackRollingBest) {
                BOOL timeAxis = info.fieldFlag != gcFieldFlagWeightedMeanSpeed;

                GCStatsDataSerieWithUnit * serie = timeAxis?[self timeSerieForField:info.field]:[self distanceSerieForField:info.field];
                pts += serie.serie.count;
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
                
                serie.serie = [serie.serie movingBestByUnitOf:unitstride fillMethod:gcStatsZero select:select];
                rv[key] = serie;
            }else if(info.track == gcCalculatedCachedTrackDataSerie){
                if ([info.field.key isEqualToString:CALC_VERTICAL_SPEED]) {
                    NSDictionary * standard = [self calculateAltitudeDerivedFields];
                    if (standard) {
                        [rv addEntriesFromDictionary:standard];
                    }
                }
                if ([info.field.key isEqualToString:CALC_10SEC_SPEED]) {
                    NSDictionary * standard = [self calculateSpeedDerivedFields];
                    if (standard) {
                        [rv addEntriesFromDictionary:standard];
                    }
                }
            }

            i++;
        }else{
            rv[key] = obj;
        }
    }
    self.cachedCalculatedTracks = rv;
    if ([perf significant]) {
        RZLog(RZLogInfo, @"Computed %d tracks (%d pts) %@",(int)i, (int)pts, perf);
    }
    [self performSelectorOnMainThread:@selector(calculateCachedTrackNotify) withObject:nil waitUntilDone:NO];
}

-(void)calculateCachedTrackNotify{
    [[GCAppGlobal organizer] notifyForString:self.activityId];
    [self notify];
}


-(BOOL)hasCalculatedDerivedTrack:(gcCalculatedCachedTrack)track forField:(nonnull GCField*)field{
    return (self.cachedCalculatedTracks)[[self calculatedCachedTrackKey:track forField:field]]!=nil;
}

-(void)addStandardCalculatedTracks:(nullable dispatch_queue_t)threadOrNil{
    if ([self isCalculatingTracks]) {
        return;
    }

    NSMutableDictionary * rv = [NSMutableDictionary dictionaryWithDictionary:self.cachedCalculatedTracks];
    NSString * key = nil;

    BOOL hasMissing = false;

    if (RZTestOption(self.trackFlags, gcFieldFlagAltitudeMeters)) {
        GCField * field = [GCField field:CALC_VERTICAL_SPEED forActivityType:self.activityType];
        key = [self calculatedCachedTrackKey:gcCalculatedCachedTrackDataSerie forField:field];
        if (rv[key] == nil) {
            GCCalculactedCachedTrackInfo * info = [GCCalculactedCachedTrackInfo info:gcCalculatedCachedTrackDataSerie field:field];
            rv[key] = info;
            hasMissing = true;
        }
    }
    if (RZTestOption(self.trackFlags, gcFieldFlagSumDistance)) {
        GCField * field = [GCField fieldForKey:CALC_10SEC_SPEED andActivityType:self.activityType];
        key = [self calculatedCachedTrackKey:gcCalculatedCachedTrackDataSerie forField:field];
        if (rv[key] == nil) {
            GCCalculactedCachedTrackInfo * info = [GCCalculactedCachedTrackInfo info:gcCalculatedCachedTrackDataSerie field:field];
            rv[key] = info;
            hasMissing = true;
        }
    }
    if (hasMissing) {
        self.cachedCalculatedTracks = rv;
    }

    if (threadOrNil) {
        dispatch_async(threadOrNil,^(){
            [self calculatedCachedTrackCalculations];
        });
    }else{
        [self calculatedCachedTrackCalculations];
    }
}

-(BOOL)isCalculatingTracks{
    BOOL calculating = false;
    if (self.cachedCalculatedTracks) {
        for (NSString * key in self.cachedCalculatedTracks) {
            if ([(self.cachedCalculatedTracks)[key] isKindOfClass:[GCCalculactedCachedTrackInfo class]]) {
                calculating = true;
            }
        }
    }
    return calculating;
}

+(nullable GCStatsDataSerieWithUnit*)standardSerieSampleForXUnit:(GCUnit*)xUnit{
    
    if( [xUnit canConvertTo:GCUnit.second] ){
        GCStatsDataSerieWithUnit * rv = nil;
        
        double xs[] = {
            5., 10., 15., 30., 45., 60.,
            2.*60., 5.*60., 10.*60., 15.*60., 20.*60., 25.0*60.,
            30.*60., 35.*60., 40.*60., 45.*60., 50.0*60., 55.0*60.,
            60.*60, 90.*60., 2*60.*60., 5*60.*60. };

        size_t n = sizeof(xs)/sizeof(double);
        rv = [GCStatsDataSerieWithUnit dataSerieWithUnit:xUnit xUnit:xUnit andSerie:RZReturnAutorelease([[GCStatsDataSerie alloc] init])];
        for (size_t i=0; i<n; ++i) {
            [rv.serie addDataPointWithX:xs[i] andY:xs[i]];
        }
        return rv;
    }else if( [xUnit canConvertTo:GCUnit.meter] ){
        GCStatsDataSerieWithUnit * rv = nil;
        
        double mile = 1609.344;
        double km = 1000.0;
        double marathon = 42.195;
        
        double small_xs[] = { 100., 200., 400., 500., 800., 1500. };
        double big_xs[]   = { 1., 2., 3., 5., 10., 15., 20., 30., 40., 50., 100. };
        double std_xs[]   = { marathon/2.*km, marathon*km };

        size_t small_n = sizeof(small_xs)/sizeof(double);
        size_t big_n = sizeof(big_xs)/sizeof(double);
        size_t std_n = sizeof(std_xs)/sizeof(double);

        rv = [GCStatsDataSerieWithUnit dataSerieWithUnit:xUnit xUnit:xUnit andSerie:RZReturnAutorelease([[GCStatsDataSerie alloc] init])];
        for (size_t i=0; i<small_n; ++i) {
            [rv.serie addDataPointWithX:small_xs[i] andY:small_xs[i]];
        }
        for (size_t i=0; i<big_n; ++i) {
            [rv.serie addDataPointWithX:big_xs[i]*km andY:big_xs[i]*km];
            [rv.serie addDataPointWithX:big_xs[i]*mile andY:big_xs[i]*mile];
        }
        for (size_t i=0; i<std_n; ++i) {
            [rv.serie addDataPointWithX:std_xs[i] andY:std_xs[i]];
        }
        [rv.serie sortByX];

        return rv;
    }else{
        return nil;
    }
}

-(nullable GCStatsDataSerieWithUnit*)standardizedBestRollingTrack:(nonnull GCField*)field
                                                           thread:(nullable dispatch_queue_t)thread{
    
    GCStatsDataSerieWithUnit * base = [self calculatedDerivedTrack:gcCalculatedCachedTrackRollingBest forField:field thread:thread];
    if( base ){
        GCStatsDataSerieWithUnit * standardSerie = [GCActivity standardSerieSampleForXUnit:base.xUnit];
        // If standard serie exist, then resample, if not, it means the xUnit likely does not have standard serie
        if( standardSerie ){
            // Make sure we reduce from a copy so we don't destroy the main serie
            base = [GCStatsDataSerieWithUnit dataSerieWithOther:base];
            [GCStatsDataSerie reduceToCommonRange:standardSerie.serie and:base.serie];
            
        }else{
            base = nil;
        }
    }
    return base;
}

-(nullable GCStatsDataSerieWithUnit*)calculatedDerivedTrack:(gcCalculatedCachedTrack)track
                                                   forField:(nonnull GCField*)field
                                                     thread:(nullable dispatch_queue_t)thread{
    if (![self trackpointsReadyOrLoad]) {//don't bother if no trackpoints
        return nil;
    }
    if (!self.cachedCalculatedTracks) {
        self.cachedCalculatedTracks = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    GCStatsDataSerieWithUnit * rv = nil;
    NSString * key = [self calculatedCachedTrackKey:track forField:field];
    id exiting = (self.cachedCalculatedTracks)[key];
    if (exiting == nil && ![self isCalculatingTracks])  {
        // start calculation

        NSMutableDictionary * next = [NSMutableDictionary dictionaryWithDictionary:self.cachedCalculatedTracks];
        next[key] = [GCCalculactedCachedTrackInfo info:track field:field];
        self.cachedCalculatedTracks = next;
        if (thread) {
            dispatch_async(thread,^(){
                [self calculatedCachedTrackCalculations];
            });

        }else{
            [self calculatedCachedTrackCalculations];
            exiting = (self.cachedCalculatedTracks)[key];
        }
    }

    if (exiting && [exiting isKindOfClass:[GCStatsDataSerieWithUnit class]]){
        rv = (GCStatsDataSerieWithUnit*) exiting;
        if (track == gcCalculatedCachedTrackDataSerie && self.settings.serieFilters[field]) {
            rv = [GCStatsDataSerieWithUnit dataSerieWithUnit:rv.unit xUnit:rv.xUnit andSerie:rv.serie];
            rv = [self applyStandardFilterTo:rv ForField:field];
        }
    }

    return rv;
}

#pragma mark - Derived TRacks

-(NSDictionary*)calculateAltitudeDerivedFields{
    GCField * altitude = [GCField fieldForFlag:gcFieldFlagAltitudeMeters andActivityType:self.activityType];

    GCStatsDataSerieWithUnit * serie = [self timeSerieForField:altitude];
    GCStatsDataSerieWithUnit * adjusted = [GCStatsDataSerieWithUnit dataSerieWithUnit:serie.unit];
    adjusted.xUnit = serie.xUnit;
    
    double threshold = [[GCNumberWithUnit numberWithUnit:GCUnit.meter andValue:5.0] convertToUnit:serie.unit].value;
    
    GCNumberWithUnit * current_altitude = [GCNumberWithUnit numberWithUnit:serie.unit andValue:[serie dataPointAtIndex:0].y_data];
    for (GCStatsDataPoint * point in serie) {
        if( fabs( current_altitude.value - point.y_data ) > threshold ){
            current_altitude = [GCNumberWithUnit numberWithUnit:serie.unit andValue:point.y_data];
        }
        [adjusted addNumberWithUnit:current_altitude forX:point.x_data];
    }
    
    
    // compute speed with minimum of 10 sec and report for 1min (60secs)
    GCStatsDataSerie * ascentspeed = [serie.serie deltaYSerieForDeltaX:10. scalingFactor:60.0*60.0];
    GCStatsDataSerieWithUnit * final = [GCStatsDataSerieWithUnit dataSerieWithUnit:[GCUnit unitForKey:@"meterperhour"] andSerie:ascentspeed];
    final.xUnit = [GCUnit unitForKey:@"second"];
    [GCFields registerField:CALC_VERTICAL_SPEED activityType:self.activityType displayName:NSLocalizedString(@"Vertical Speed", @"Calculated Field") andUnitName:@"meterperhour"];

    NSDictionary * stats = [final.serie summaryStatistics];
    NSMutableDictionary * newFields = [NSMutableDictionary dictionary];
    NSDictionary * fields = @{
                              CALC_VERTICAL_SPEED: [GCActivityCalculatedValue calculatedValue:CALC_VERTICAL_SPEED value:[stats[STATS_AVG] doubleValue] unit:final.unit],
                              CALC_ASCENT_SPEED: [GCActivityCalculatedValue calculatedValue:CALC_ASCENT_SPEED value:[stats[STATS_AVGPOS] doubleValue] unit:final.unit],
                              CALC_DESCENT_SPEED: [GCActivityCalculatedValue calculatedValue:CALC_DESCENT_SPEED value:[stats[STATS_AVGNEG] doubleValue] unit:final.unit],
                              CALC_MAX_ASCENT_SPEED: [GCActivityCalculatedValue calculatedValue:CALC_MAX_ASCENT_SPEED value:[stats[STATS_MAX] doubleValue] unit:final.unit],
                              CALC_MAX_DESCENT_SPEED: [GCActivityCalculatedValue calculatedValue:CALC_MAX_DESCENT_SPEED value:[stats[STATS_MIN] doubleValue] unit:final.unit],
                              };

    for (NSString * key in fields) {
        newFields[ [GCField fieldForKey:key andActivityType:self.activityType] ] = fields[key];
    }
    [self addEntriesToCalculatedFields:newFields];

    return @{CALC_VERTICAL_SPEED:final};
}

-(NSDictionary*)calculateSpeedDerivedFields{
    GCField * distanceField = [GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:self.activityType];

    GCStatsDataSerieWithUnit * serie = [self timeSerieForField:distanceField];

    [serie convertToUnit:[GCUnit unitForKey:@"meter"]];

    GCStatsDataSerie * speedmps = [serie.serie deltaYSerieForDeltaX:10. scalingFactor:1.];

    GCStatsDataSerieWithUnit * final = [GCStatsDataSerieWithUnit dataSerieWithUnit:[GCUnit unitForKey:@"mps"] andSerie:speedmps];
    final.xUnit = [GCUnit unitForKey:@"second"];
    if ([self.activityType isEqualToString:GC_TYPE_RUNNING]) {
        [final convertToUnit:[GCUnit unitForKey:@"minperkm"]];
        [GCFields registerField:CALC_10SEC_SPEED activityType:self.activityType displayName:NSLocalizedString(@"10sec Pace", @"Calculated Field") andUnitName:@"minperkm"];
    }else{
        [final convertToUnit:[GCUnit unitForKey:@"kph"]];
        [GCFields registerField:CALC_10SEC_SPEED activityType:self.activityType displayName:NSLocalizedString(@"10sec Speed", @"Calculated Field") andUnitName:@"kph"];

    }

    return  @{CALC_10SEC_SPEED:final};
}


@end
