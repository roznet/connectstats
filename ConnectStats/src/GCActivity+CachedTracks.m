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
#import "GCActivity+BestRolling.h"
#import "GCActivity+Series.h"
#import "GCFieldInfo.h"

@implementation GCActivity (CachedTracks)

#pragma mark - Calculation Process

-(NSArray<GCCalculatedCachedTrackInfo*>*)remainsToBecalculated{
    NSMutableArray * rv = [NSMutableArray array];
    for (GCCalculatedCachedTrackInfo * info in self.cachedCalculatedTracks.allValues) {
        if( info.requiresCalculation ){
            [rv addObject:info];
        }
    }
    return rv;
}

-(NSArray<GCField*>*)availableCalculatedFields{
    return self.cachedCalculatedTracks.allKeys;
}

-(BOOL)hasCalculatedSerieForField:(nonnull GCField*)field{
    return self.cachedCalculatedTracks[field].serie != nil;
}
-(void)calculatedCachedTrackCalculations{
    RZPerformance * perf = [RZPerformance start];
    
    NSUInteger processedSeriesCount = 0;
    NSUInteger processedPointsCount = 0;
    
    NSArray<GCCalculatedCachedTrackInfo*>*missing = [self remainsToBecalculated];
    NSMutableDictionary * additional = [NSMutableDictionary dictionary];
    
    for (GCCalculatedCachedTrackInfo * info in missing) {
        if( info.requiresCalculation ){
            if (info.field.isBestRollingField) {
                GCStatsDataSerieWithUnit * serie = [self calculatedRollingBest:info];
                if( serie ){
                    info.serie = serie;
                    processedPointsCount = info.processedPointsCount;
                }
            }else{
                if ([info.field.key isEqualToString:CALC_VERTICAL_SPEED]) {
                    NSDictionary * standard = [self calculateAltitudeDerivedFields];
                    if (standard) {
                        [additional addEntriesFromDictionary:standard];
                    }
                }
                if ([info.field.key isEqualToString:CALC_10SEC_SPEED]) {
                    NSDictionary * standard = [self calculateSpeedDerivedFields];
                    if (standard) {
                        [additional addEntriesFromDictionary:standard];
                    }
                }
                
                processedSeriesCount += 1;
            }
        }
        [self recordAdditionalCalculatedFields:additional];
        if ([perf significant]) {
            RZLog(RZLogInfo, @"Computed %d tracks (%d pts) %@",(int)processedSeriesCount, (int)processedPointsCount, perf);
        }
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self calculateCachedTrackNotify];
        });
    }
}

-(void)recordAdditionalCalculatedFields:(NSDictionary<GCField*,GCCalculatedCachedTrackInfo*>*)additional{
    @synchronized (self.cachedCalculatedTracks) {
        NSMutableDictionary * newCache = [NSMutableDictionary dictionaryWithDictionary:self.cachedCalculatedTracks];
        [newCache addEntriesFromDictionary:additional];
        self.cachedCalculatedTracks = newCache;
    }
}

-(void)calculateCachedTrackNotify{
    [[GCAppGlobal organizer] notifyForString:self.activityId];
    [self notify];
}


-(BOOL)hasCalculatedForField:(nonnull GCField*)field{
    GCCalculatedCachedTrackInfo * info = self.cachedCalculatedTracks[field];
    return info != nil && info.serie != nil;
}

-(void)launchCalculationForMissing:(NSDictionary<GCField*,GCCalculatedCachedTrackInfo*>*)newCalcFields thread:(nullable dispatch_queue_t)threadOrNil{
    
    NSMutableDictionary * updated = [NSMutableDictionary dictionaryWithDictionary:self.cachedCalculatedTracks];
    
    for (GCField * field in newCalcFields) {
        if( updated[field] == nil){
            updated[field] = newCalcFields[field];
        }
    }
    
    @synchronized (self.cachedCalculatedTracks) {
        self.cachedCalculatedTracks = updated;
    }
    
    if (threadOrNil) {
        dispatch_async(threadOrNil,^(){
            [self calculatedCachedTrackCalculations];
        });
    }else{
        [self calculatedCachedTrackCalculations];
    }

}

-(void)addStandardCalculatedTracks:(nullable dispatch_queue_t)threadOrNil{
    NSMutableDictionary * missing = [NSMutableDictionary dictionary];

    if (RZTestOption(self.trackFlags, gcFieldFlagAltitudeMeters)) {
        GCField * field = [GCField fieldForKey:CALC_VERTICAL_SPEED andActivityType:self.activityType];
        if (self.cachedCalculatedTracks[field] == nil) {
            GCCalculatedCachedTrackInfo * info = [GCCalculatedCachedTrackInfo infoForField:field];
            missing[field] = info;
        }
    }
    if (RZTestOption(self.trackFlags, gcFieldFlagSumDistance) && ! self.garminSwimAlgorithm) {
        if( [GCAppGlobal configGetBool:CONFIG_ENABLE_SPEED_CALC_FIELDS defaultValue:false]){
            GCField * field = [GCField fieldForKey:CALC_10SEC_SPEED andActivityType:self.activityType];
            if (self.cachedCalculatedTracks[field] == nil) {
                GCCalculatedCachedTrackInfo * info = [GCCalculatedCachedTrackInfo infoForField:field];
                missing[field] = info;
            }
        }
    }
    if( missing.count > 0){
        [self launchCalculationForMissing:missing thread:threadOrNil];
    }
}

+(nullable GCStatsDataSerieWithUnit*)standardSerieSampleForXUnit:(GCUnit*)xUnit{
    
    if( [xUnit canConvertTo:GCUnit.second] ){
        GCStatsDataSerieWithUnit * rv = nil;
        
        double xs[] = {
            0., 5., 10., 15., 30., 45., 60.,
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
        
        double small_xs[] = { 0., 100., 200., 400., 500., 800., 1500. };
        double big_xs[]   = { 1., 2., 3., 4., 5., 6., 7., 8., 9., 10., 12., 15., 17., 20., 25., 30., 35., 40., 45., 50., 75., 100. };
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
    
    GCStatsDataSerieWithUnit * base = [self calculatedSerieForField:field.correspondingBestRollingField thread:thread];
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

-(nullable GCStatsDataSerieWithUnit*)calculatedSerieForField:(nonnull GCField*)field
                                                     thread:(nullable dispatch_queue_t)thread{
    if (![self trackpointsReadyOrLoad]) {//don't bother if no trackpoints
        return nil;
    }
    if (!self.cachedCalculatedTracks) {
        self.cachedCalculatedTracks = [NSMutableDictionary dictionary];
    }
    GCStatsDataSerieWithUnit * rv = nil;
    GCCalculatedCachedTrackInfo * existing = self.cachedCalculatedTracks[field];
    
    if (existing == nil)  {
        // start calculation
        [self launchCalculationForMissing:@{field:[GCCalculatedCachedTrackInfo infoForField:field] } thread:thread];
        existing = self.cachedCalculatedTracks[field];
    }
    
    rv = existing.serie;
    if (rv && !field.isBestRollingField && self.settings.serieFilters[field]) {
        rv = [GCStatsDataSerieWithUnit dataSerieWithUnit:rv.unit xUnit:rv.xUnit andSerie:rv.serie];
        rv = [self applyStandardFilterTo:rv ForField:field];
    }

    return rv;
}

#pragma mark - Derived TRacks

-(NSDictionary<GCField*,GCCalculatedCachedTrackInfo*>*)calculateAltitudeDerivedFields{
    GCField * altitude = [GCField fieldForFlag:gcFieldFlagAltitudeMeters andActivityType:self.activityType];
    GCField * distance = [GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:self.activityType];

    GCStatsDataSerieWithUnit * serie = [GCStatsDataSerieWithUnit dataSerieWithOther:[self timeSerieForField:altitude]];
    GCStatsDataSerieWithUnit * serie_dist = [GCStatsDataSerieWithUnit dataSerieWithOther:[self timeSerieForField:distance]];
    
    [GCStatsDataSerie reduceToCommonRange:serie.serie and:serie_dist.serie];
    
    GCStatsDataSerieWithUnit * adjusted = [GCStatsDataSerieWithUnit dataSerieWithUnit:serie.unit];
    
    adjusted.xUnit = serie.xUnit;

    NSDictionary<NSString*,GCStatsDataSerieWithUnit*>*calc = @{
        CALC_ALTITUDE_GAIN : [GCStatsDataSerieWithUnit dataSerieWithUnit:serie.unit],
        CALC_ALTITUDE_LOSS : [GCStatsDataSerieWithUnit dataSerieWithUnit:serie.unit],
        CALC_ELEVATION_GRADIENT : [GCStatsDataSerieWithUnit dataSerieWithUnit:GCUnit.percent]
    };
    
    double threshold = [[GCNumberWithUnit numberWithUnit:GCUnit.meter andValue:5.0] convertToUnit:serie.unit].value;
    
    if( serie.count == 0 || serie_dist.count == 0){
        return @{};
    }
    
    double current_altitude = [serie dataPointAtIndex:0].y_data;
    double current_altitude_distance = [serie_dist dataPointAtIndex:0].y_data;
    double current_elevation_gain = 0.;
    double current_elevation_loss = 0.;
    double current_elevation_gradient = 0.;
    
        
    double elevation_unit_to_dist_unit = [serie_dist.unit convertDouble:1.0 fromUnit:serie.unit];
    
    if( [serie dataPointAtIndex:0].x_data != [serie_dist dataPointAtIndex:0].x_data ){
        RZLog(RZLogInfo, @"Oops");
    }
    NSUInteger idx = 0;
    NSUInteger idx_current_altitude = 0;
    
    BOOL reportedInconsistency = false;
    
    for (GCStatsDataPoint * point in serie) {
        GCStatsDataPoint * point_dist = [serie_dist dataPointAtIndex:idx];
        if( point.x_data != point_dist.x_data ){
            if( ! reportedInconsistency ){
                // Only report once
                RZLog(RZLogWarning, @"Inconsistency between dist and serie for %@ and %@ at %lu", point, point_dist, (unsigned long) idx);
                reportedInconsistency = true;
            }
        }
        
        if( fabs( current_altitude - point.y_data ) > threshold ){
            if( current_altitude < point.y_data){
                current_elevation_gain += ( point.y_data - current_altitude);
            }
            if( current_altitude > point.y_data){
                current_elevation_loss += (point.y_data - current_altitude);
            }
            current_elevation_gradient = 100.0 * ( point.y_data - current_altitude) * elevation_unit_to_dist_unit / (point_dist.y_data - current_altitude_distance);
            current_altitude = point.y_data;
            current_altitude_distance = point_dist.y_data;
            // Fill Gradient since last elevation
            for( NSUInteger j = idx_current_altitude+1; j <= idx; j++){
                [calc[CALC_ELEVATION_GRADIENT].serie addDataPointWithX:[serie dataPointAtIndex:j].x_data
                                                                  andY:current_elevation_gradient];
            }
            idx_current_altitude = idx;
        }
        [calc[CALC_ALTITUDE_GAIN].serie addDataPointWithX:point.x_data andY:current_elevation_gain];
        [calc[CALC_ALTITUDE_LOSS].serie addDataPointWithX:point.x_data andY:current_elevation_loss];
        [adjusted.serie addDataPointWithX:point.x_data andY:current_altitude];

        idx++;
    }
    
    // compute speed with minimum of 10 sec and report for 1min (60secs)
    GCStatsDataSerie * ascentspeed = [serie.serie deltaYSerieForDeltaX:10. scalingFactor:60.0*60.0];
    GCStatsDataSerieWithUnit * final = [GCStatsDataSerieWithUnit dataSerieWithUnit:[GCUnit unitForKey:@"meterperhour"] andSerie:ascentspeed];
    final.xUnit = [GCUnit unitForKey:@"second"];

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

    NSMutableDictionary<GCField*,GCCalculatedCachedTrackInfo*> * rv = [NSMutableDictionary dictionary];
    if( final.serie.count > 0){
        GCField * field = [GCField fieldForKey:CALC_VERTICAL_SPEED andActivityType:self.activityType];
        rv[ field ] = [GCCalculatedCachedTrackInfo infoForField:field andSerie:final];
    }
    for (NSString*key in calc) {
        GCStatsDataSerieWithUnit * su = calc[key];
        if( su.serie.count > 0){
            GCField * field = [GCField fieldForKey:key andActivityType:self.activityType];
            rv[ field ] = [GCCalculatedCachedTrackInfo infoForField:field andSerie:su];
        }
    }
    return rv;
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
    }else{
        [final convertToUnit:[GCUnit unitForKey:@"kph"]];
    }

    return  @{CALC_10SEC_SPEED:final};
}

+(NSDictionary<GCField*,GCFieldInfo*>*)fieldInfoForCalculatedTrackFields{
    NSArray * defs = @[
        [GCFieldInfo fieldInfoFor:[GCField fieldForKey:CALC_VERTICAL_SPEED andActivityType:GC_TYPE_ALL]
                      displayName:NSLocalizedString(@"Vertical Speed", @"Calculated Field")
                         andUnits:@{@(GCUnitSystemMetric):[GCUnit meterperhour]}],
        
        [GCFieldInfo fieldInfoFor:[GCField fieldForKey:CALC_10SEC_SPEED andActivityType:GC_TYPE_RUNNING]
                      displayName:NSLocalizedString(@"10sec Pace", @"Calculated Field")
                         andUnits:@{@(GCUnitSystemMetric):[GCUnit minperkm],@(GCUnitSystemImperial):[GCUnit minpermile]}],
        [GCFieldInfo fieldInfoFor:[GCField fieldForKey:CALC_10SEC_SPEED andActivityType:GC_TYPE_ALL]
                      displayName:NSLocalizedString(@"10sec Speed", @"Calculated Field")
                         andUnits:@{@(GCUnitSystemMetric):[GCUnit kph],@(GCUnitSystemImperial):[GCUnit mph]}],

    ];
    NSMutableDictionary * rv = [NSMutableDictionary dictionary];
    for (GCFieldInfo * info in defs) {
        rv[info.field] = info;
    }
    return rv;
}


@end
