//  MIT Licence
//
//  Created on 28/02/2013.
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

#import "GCFieldsCalculated.h"
#import "GCActivity.h"
#import "GCActivity+CalculatedTracks.h"
#import "GCFieldsCalculatedFromTrack.h"
#import "GCAppGlobal.h"
#import "GCActivity+Fields.h"
#import "GCFieldInfo.h"
#import "GCField.h"

static NSArray * _calculatedFields = nil;
// Power formulas
// http://www.kreuzotter.de/english/espeed.htm

@implementation GCFieldsCalculated


+(NSString*)unitName:(GCField*)field{
    return nil;
}

+(NSDictionary<GCField*,GCFieldInfo*>*)fieldInfoForCalculatedFields{
    static NSDictionary<GCField*,GCFieldInfo*> * infoCache = nil;
    if( infoCache == nil){
        NSArray * defs = @[
            [GCFieldInfo fieldInfoFor:[GCField fieldForKey:CALC_ALTITUDE_GAIN andActivityType:GC_TYPE_ALL]
                          displayName:NSLocalizedString( @"GPS Elevation Gain", @"Calculated Field")
                             andUnits:@{@(gcUnitSystemMetric):[GCUnit unitForKey:STOREUNIT_ALTITUDE], @(gcUnitSystemImperial):[GCUnit foot]}],
             [GCFieldInfo fieldInfoFor:[GCField fieldForKey:CALC_ALTITUDE_LOSS andActivityType:GC_TYPE_ALL]
                           displayName:NSLocalizedString( @"GPS Elevation Loss", @"Calculated Field")
                              andUnits:@{@(gcUnitSystemMetric):[GCUnit unitForKey:STOREUNIT_ALTITUDE],@(gcUnitSystemImperial):[GCUnit foot]}],
             [GCFieldInfo fieldInfoFor:[GCField fieldForKey:CALC_NORMALIZED_POWER andActivityType:GC_TYPE_ALL]
                           displayName:NSLocalizedString( @"Normalized Power", @"Calculated Field")
                              andUnits:@{@(gcUnitSystemMetric):[GCUnit watt]}],
            [GCFieldInfo fieldInfoFor:[GCField fieldForKey:CALC_NONZERO_POWER andActivityType:GC_TYPE_ALL]
                          displayName:NSLocalizedString( @"Non Zero Avg Power", @"Calculated Field")
                             andUnits:@{@(gcUnitSystemMetric):[GCUnit watt]}],
            [GCFieldInfo fieldInfoFor:[GCField fieldForKey:CALC_VERTICAL_SPEED andActivityType:GC_TYPE_ALL]
                          displayName:NSLocalizedString( @"Vertical Speed", @"Calculated Field")
                             andUnits:@{@(gcUnitSystemMetric):[GCUnit unitForKey:@"meterperhour"]}],
            [GCFieldInfo fieldInfoFor:[GCField fieldForKey:CALC_ELEVATION_GRADIENT andActivityType:GC_TYPE_ALL]
                          displayName:NSLocalizedString( @"Elevation Gradient", @"Calculated Field")
                             andUnits:@{@(gcUnitSystemMetric):[GCUnit percent]}],
            [GCFieldInfo fieldInfoFor:[GCField fieldForKey:CALC_ELEVATION_GRADIENT andActivityType:GC_TYPE_ALL]
                          displayName:NSLocalizedString( @"Elevation Gradient", @"Calculated Field")
                             andUnits:@{@(gcUnitSystemMetric):[GCUnit percent]}],
            [GCFieldInfo fieldInfoFor:[GCField fieldForKey:CALC_ASCENT_SPEED andActivityType:GC_TYPE_ALL]
                          displayName:NSLocalizedString( @"Ascent Speed", @"Calculated Field")
                             andUnits:@{@(gcUnitSystemMetric):[GCUnit meterperhour]}],
            [GCFieldInfo fieldInfoFor:[GCField fieldForKey:CALC_DESCENT_SPEED andActivityType:GC_TYPE_ALL]
                          displayName:NSLocalizedString( @"Descent Speed", @"Calculated Field")
                             andUnits:@{@(gcUnitSystemMetric):[GCUnit meterperhour]}],
            [GCFieldInfo fieldInfoFor:[GCField fieldForKey:CALC_MAX_ASCENT_SPEED andActivityType:GC_TYPE_ALL]
                          displayName:NSLocalizedString( @"Max Ascent Speed", @"Calculated Field")
                             andUnits:@{@(gcUnitSystemMetric):[GCUnit meterperhour]}],
            [GCFieldInfo fieldInfoFor:[GCField fieldForKey:CALC_MAX_DESCENT_SPEED andActivityType:GC_TYPE_ALL]
                          displayName:NSLocalizedString( @"Max Descent Speed", @"Calculated Field")
                             andUnits:@{@(gcUnitSystemMetric):[GCUnit meterperhour]}],
            [GCFieldInfo fieldInfoFor:[GCField fieldForKey:CALC_10SEC_SPEED andActivityType:GC_TYPE_RUNNING]
                          displayName:NSLocalizedString( @"10sec Speed", @"Calculated Field")
                             andUnits:@{@(gcUnitSystemMetric):[GCUnit minperkm]}],
            [GCFieldInfo fieldInfoFor:[GCField fieldForKey:CALC_10SEC_SPEED andActivityType:GC_TYPE_ALL]
                          displayName:NSLocalizedString( @"10sec Speed", @"Calculated Field")
                             andUnits:@{@(gcUnitSystemMetric):[GCUnit kph]}],

        ];
        NSMutableDictionary * cache = [NSMutableDictionary dictionary];
        for (GCFieldInfo * info in defs) {
            cache[info.field] = info;
        }
        for (GCFieldsCalculated * calculated in [GCFieldsCalculated calculatedFields]) {
            GCField * field = [GCField fieldForKey:calculated.fieldKey andActivityType:GC_TYPE_ALL];
            cache[field] = [GCFieldInfo fieldInfoFor:field
                                              displayName:calculated.displayName
                                            andUnits:@{@(gcUnitSystemMetric):[GCUnit unitForKey:calculated.unitName]}];
            [field correspondingFieldForActivityType:GC_TYPE_RUNNING];
        }
        infoCache = [NSDictionary dictionaryWithDictionary:cache];
        RZRetain(infoCache);
    }
    
    return infoCache;
}

+(GCFieldInfo*)fieldInfoForCalculatedField:(GCField*)field{
    NSDictionary<GCField*,GCFieldInfo*> * infoCache = [self fieldInfoForCalculatedFields];
    GCFieldInfo * rv = infoCache[field];
    
    if( rv == nil){
        rv = infoCache[ [field correspondingFieldForActivityType:GC_TYPE_ALL] ];
    }
    return rv;
}

+(NSString*)displayFieldName:(GCField*)field{
    return [self fieldInfoForCalculatedField:field].displayName;
}

+(NSArray*)calculatedFields{
    if (_calculatedFields==nil) {
        _calculatedFields = @[
            RZReturnAutorelease([[GCFieldCalcKiloJoules alloc] init]),
            RZReturnAutorelease([[GCFieldCalcStrideLength alloc] init]),
            RZReturnAutorelease([[GCFieldCalcMetabolicEfficiency alloc] init]),
            RZReturnAutorelease([[GCFieldCalcRotationDevelopment alloc] init]),
            RZReturnAutorelease([[GCFieldCalcElevationGradient alloc] init]),
            RZReturnAutorelease([[GCFieldCalcRunningEffectiveness alloc] init])
        ] ;
        RZRetain(_calculatedFields);
    }
    return _calculatedFields;
}

+(void)addCalculatedFieldsToLaps:(NSArray*)laps forActivity:(GCActivity*)act{
    [GCFieldsCalculatedFromTrack addCalculatedFieldsToTrackPointsAndLaps:act];
    NSArray * calcFields = [GCFieldsCalculated calculatedFields];
    for (GCTrackPoint * point in laps) {
        for (GCFieldsCalculated * one in calcFields) {
            if ([one validForActivity:act] && [one trackPointHasRequiredFields:point inActivity:act]) {
                GCActivityCalculatedValue * val = [one evaluateForTrackPoint:point inActivity:act];
                if (val) {
                    [point addNumberWithUnitForCalculated:[val numberWithUnit] forField:[one fieldInActivity:act]];
                }
            }
        }
    }
    
    //This use to check for [GCAppGlobal worker] == [NSThread currentThread]
    //[act addStandardCalculatedTracks:[GCAppGlobal worker] == [NSThread currentThread] ? nil : [GCAppGlobal worker] ];
    // Only pass a thread if on main thread.
    // The reason it's important, is if on a worker thread already during a test that require
    // everything in sync on worker, it would break (example derived test in connectstats app)
    
    [act addStandardCalculatedTracks:[NSThread isMainThread] ? act.settings.worker : nil];

}

+(void)addCalculatedFields:(GCActivity*)act{
    NSArray * calcFields = [GCFieldsCalculated calculatedFields];

    NSMutableDictionary<GCField*,GCActivityCalculatedValue*> * newFields = [NSMutableDictionary dictionary];

    for (GCFieldsCalculated * one in calcFields) {
        if ([one activityHasRequiredFields:act] && [one validForActivity:act]) {
            GCActivityCalculatedValue * val = [one evaluateForActivity:act];
            if (val) {
                newFields[ [one fieldInActivity:act] ] = val;
            }
        }
    }
    [act addEntriesToCalculatedFields:newFields];
}


-(GCField*)fieldInActivity:(GCActivity*)act{
    return [GCField fieldForKey:self.fieldKey andActivityType:act.activityType];
}

-(NSArray<GCField*>*)inputFieldsTrackPointForActivity:(GCActivity*)act{
    NSArray * inputs = self.inputFieldsTrackPoint;
    NSMutableArray<GCField*>*rv = [NSMutableArray arrayWithCapacity:inputs.count];
    
    for (id obj in inputs) {
        if( [obj isKindOfClass:[NSString class]]) {
            [rv addObject:[GCField fieldForKey:obj andActivityType:act.activityType]];
        }else if ([obj isKindOfClass:[NSNumber class]]){
            [rv addObject:[GCField fieldForFlag:[obj integerValue] andActivityType:act.activityType]];
        }else{
            RZLog(RZLogError, @"Invalid input for %@", self);
            return nil; // BAD!
        }
    }
    return rv;
}
-(NSArray<GCField*>*)inputFieldsForActivity:(GCActivity*)act{
    NSArray * inputs = self.inputFields;
    
    NSMutableArray<GCField*>*rv = [NSMutableArray arrayWithCapacity:inputs.count];
    for (NSString * key in inputs) {
        [rv addObject:[GCField fieldForKey:key andActivityType:act.activityType]];
    }
    return rv;
}

#pragma mark - default implementation

-(NSArray*)inputFields{
    return @[];
}
-(NSArray*)inputFieldsTrackPoint{
    return @[];
}
-(NSString*)fieldKey{
    return @"None";
}
-(NSString*)displayName{
    return @"None";
}
-(BOOL)validForActivity:(GCActivity*)act{
    return false;
}
-(BOOL)validForTrackPoint:(GCTrackPoint *)trackPoint inActivity:(GCActivity *)act{
    return [self validForActivity:act];
}
-(GCNumberWithUnit*)evaluateWithInputs:(NSArray *)inputs{
    return nil;
}
-(NSString*)unitName{
    return nil;
}
#pragma mark - shared functions

-(BOOL)activityHasRequiredFields:(GCActivity*)act{
    NSArray<GCField*> * inputF = [self inputFieldsForActivity:act];
    for (GCField * f in inputF) {
        if (![act hasField:f]) {
            if( f.isHealthField ){
                return [[GCAppGlobal health] hasHealthData];
            }
            return false;
        }
    }
    return true;
}

-(BOOL)trackPointHasRequiredFields:(GCTrackPoint*)trackPoint inActivity:(GCActivity*)act{
    NSArray<GCField*> * inputF = [self inputFieldsTrackPointForActivity:act];
    if( inputF == nil){
        return false;
    }
    for (GCField * f in inputF) {
        if( ![trackPoint hasField:f inActivity:act] ){
            if( f.isHealthField ){
                return [[GCAppGlobal health] hasHealthData];
            }
            return false;
        }
    }
    return true;
}
-(GCActivityCalculatedValue*)evaluateForActivity:(GCActivity *)act{
    GCActivityCalculatedValue * rv = nil;

    if ([self validForActivity:act]) {
        NSArray<GCField*> * inputF= [self inputFieldsForActivity:act];
        NSMutableArray * inputs = [NSMutableArray arrayWithCapacity:inputF.count];

        for (GCField * f in inputF) {
            GCNumberWithUnit * arg = nil;

            if( f.isHealthField ){
                arg = [[GCAppGlobal health] measureForDate:act.date andField:f].value;
            }else{
                arg = [act numberWithUnitForField:f];
            }
            
            if( arg ){
                [inputs addObject:arg];
            }
        }
        if( inputs.count == inputF.count){
            GCNumberWithUnit * val = [self evaluateWithInputs:inputs];
            if (val) {
                rv = [[[GCActivityCalculatedValue alloc] init] autorelease];
                rv.numberWithUnit = val;
                rv.field = [self fieldInActivity:act];
            }
        }
    }
    return rv;
}

-(GCActivityCalculatedValue*)evaluateForTrackPoint:(GCTrackPoint *)trackPoint inActivity:(GCActivity*)act{
    GCActivityCalculatedValue * rv = nil;

    if ([self validForTrackPoint:trackPoint inActivity:act]){
        NSArray<GCField*> * inputF= [self inputFieldsTrackPointForActivity:act];
        NSMutableArray * inputs = [NSMutableArray arrayWithCapacity:inputF.count];

        for (GCField * f in inputF) {
            GCNumberWithUnit * arg = nil;
            
            if( f.isHealthField ){
                arg = [[GCAppGlobal health] measureForDate:act.date andField:f].value;
            }else{
                arg = [trackPoint numberWithUnitForField:f inActivity:act];
            }
            
            if (arg) {
                [inputs addObject:arg];
            }
        }
        if( inputs.count == inputF.count){
            GCNumberWithUnit * val = [self evaluateWithInputs:inputs];
            rv = [[[GCActivityCalculatedValue alloc] init] autorelease];
            rv.numberWithUnit = val;
            rv.field = [GCField fieldForKey:[self fieldKey] andActivityType:act.activityType];
        }
    }
    return rv;

}

-(BOOL)ensureInputs:(NSArray<GCNumberWithUnit*>*)inputs{
    if (inputs.count!=[self inputFields].count) {
        RZLog(RZLogError, @"%@ expected %d inputs got %@", NSStringFromClass([self class]),(int)[[self inputFields] count ],inputs);
        return false;
    }
    NSUInteger i =0;
    for (id one in inputs) {
        if (![one isKindOfClass:[GCNumberWithUnit class]]) {
            RZLog(RZLogError, @"%@ expected NumberWithUnit for inputs[%d] got %@",
                  NSStringFromClass([self class]),
                  (int)i,
                  one
                  );
            return false;
        }
        i++;
    }
    return true;
}

@end

#pragma mark - efficiency

@implementation GCFieldCalcMetabolicEfficiency
-(BOOL)validForActivity:(GCActivity*)act{
    return true;
}
-(NSString*)fieldKey{
    return CALC_METABOLIC_EFFICIENCY;
}
-(NSString*)displayName{
    return @"Efficiency";
}

-(NSArray<NSString*>*)inputFields{
    return @[@"SumDuration",@"WeightedMeanPower",@"SumEnergy"];
}
-(NSArray*)inputFieldsTrackPoint{
    return @[@(gcFieldFlagSumDuration), @(gcFieldFlagPower),@"SumEnergy"];
}
-(GCNumberWithUnit*)evaluateWithInputs:(NSArray<GCNumberWithUnit*> *)inputs{
    if (![self ensureInputs:inputs]) {
        return nil;
    }

    GCNumberWithUnit * dur = inputs[0];
    GCNumberWithUnit * pow = inputs[1];
    GCNumberWithUnit * ene = inputs[2];

    if (ene.value == 0.) {
        return nil;
    }

    dur = [dur convertToUnitName:@"second"];
    // http://www.rapidtables.com/convert/electric/watt-to-kj.htm
    double val = pow.value * dur.value / 1000. * 0.239005736 / ene.value*100.;

    return [GCNumberWithUnit numberWithUnitName:@"percent" andValue:val];
}
-(NSString*)unitName{
    return @"percent";
}
@end


#pragma mark - runningefficiency

@implementation GCFieldCalcRunningEffectiveness
-(BOOL)validForActivity:(GCActivity*)act{
    return [act.activityTypeDetail hasSamePrimaryType:GCActivityType.running];
}
-(NSString*)fieldKey{
    return CALC_RUNNING_EFFECTIVENESS;
}
-(NSString*)displayName{
    return @"Running Effectiveness";
}

-(NSArray<NSString*>*)inputFields{
    return @[@"WeightedMeanSpeed",@"WeightedMeanPower", GC_HEALTH_PREFIX @"weight" ];
}
-(NSArray*)inputFieldsTrackPoint{
    return @[@(gcFieldFlagWeightedMeanSpeed), @(gcFieldFlagPower), GC_HEALTH_PREFIX @"weight" ];
}
-(GCNumberWithUnit*)evaluateWithInputs:(NSArray<GCNumberWithUnit*> *)inputs{
    if (![self ensureInputs:inputs]) {
        return nil;
    }

    GCNumberWithUnit * speed = inputs[0];
    GCNumberWithUnit * pow = inputs[1];
    GCNumberWithUnit * weight = inputs[2];

    if( pow.value == 0.){
        return nil;
    }
    
    double val =  [speed convertToUnit:GCUnit.mps].value / pow.value * [weight convertToUnit:GCUnit.kilogram].value * 100.0;

    return [GCNumberWithUnit numberWithUnitName:@"dimensionless" andValue:val];
}
-(NSString*)unitName{
    return @"dimensionless";
}

@end

#pragma mark - efficiencyFactor

@implementation GCFieldCalcEfficiencyFactor
-(BOOL)validForActivity:(GCActivity*)act{
    return true;
}
-(NSString*)fieldKey{
    return CALC_EFFICIENCY_FACTOR;
}
-(NSString*)displayName{
    return @"Efficiency";
}

-(NSArray<NSString*>*)inputFields{
    return @[@"WeightedMeanHeartRate",@"WeightedMeanPower"];
}
-(NSArray*)inputFieldsTrackPoint{
    return @[@(gcFieldFlagWeightedMeanHeartRate), @(gcFieldFlagPower)];
}
-(GCNumberWithUnit*)evaluateWithInputs:(NSArray<GCNumberWithUnit*> *)inputs{
    if (![self ensureInputs:inputs]) {
        return nil;
    }

    GCNumberWithUnit * hr  = inputs[0];
    GCNumberWithUnit * pow = inputs[1];

    if( hr.value == 0.){
        return nil;
    }
    double val =  pow.value / hr.value;

    return [GCNumberWithUnit numberWithUnitName:@"dimensionless" andValue:val];
}
-(NSString*)unitName{
    return @"dimensionless";
}
@end
#pragma mark - kiloJoules

@implementation GCFieldCalcKiloJoules
-(BOOL)validForActivity:(GCActivity*)act{
    return true;
}
-(NSString*)fieldKey{
    return CALC_ENERGY;
}
-(NSString*)displayName{
    return @"Energy";
}
-(NSString*)unitName{
    return @"kilojoule";
}
-(NSArray*)inputFields{
    return @[@"SumDuration",@"WeightedMeanPower"];
}
-(NSArray*)inputFieldsTrackPoint{
    return @[@(gcFieldFlagSumDuration), @(gcFieldFlagPower)];
}

-(GCNumberWithUnit*)evaluateWithInputs:(NSArray<GCNumberWithUnit*> *)inputs{
    if (![self ensureInputs:inputs]) {
        return nil;
    }

    GCNumberWithUnit * dur = inputs[0];
    GCNumberWithUnit * pow = inputs[1];

    dur = [dur convertToUnitName:@"second"];

    // http://www.rapidtables.com/convert/electric/watt-to-kj.htm
    double val = pow.value * dur.value / 1000.;

    return [GCNumberWithUnit numberWithUnitName:@"kilojoule" andValue:val];
}

@end

#pragma mark - strike length

@implementation GCFieldCalcStrideLength

-(BOOL)validForActivity:(GCActivity*)act{
    return act.activityType == nil || [act.activityType isEqualToString:GC_TYPE_RUNNING];
}
-(NSString*)fieldKey{
    return CALC_STRIDE_LENGTH;
}
-(NSString*)displayName{
    return @"Stride Length";
}

-(NSArray*)inputFields{
    return @[@"WeightedMeanSpeed",@"WeightedMeanRunCadence"];
}
-(NSArray*)inputFieldsTrackPoint{
    return @[@(gcFieldFlagWeightedMeanSpeed),@(gcFieldFlagCadence)];
}

-(GCNumberWithUnit*)evaluateWithInputs:(NSArray<GCNumberWithUnit*> *)inputs{
    if (![self ensureInputs:inputs]) {
        return nil;
    }

    GCNumberWithUnit * speed    = inputs[0];
    GCNumberWithUnit * cadence  = inputs[1];

    speed = [speed convertToUnitName:@"mps"];

    if (cadence.value == 0.) {
        return nil;
    }

    double val = speed.value / cadence.value * 60. ;


    return [GCNumberWithUnit numberWithUnitName:@"stride" andValue:val];
}

-(NSString*)unitName{
    return @"stride";
}
@end

#pragma mark - Development

@implementation GCFieldCalcRotationDevelopment

-(BOOL)validForActivity:(GCActivity*)act{
    return act.activityType == nil || [act.activityType isEqualToString:GC_TYPE_CYCLING];;
}
-(NSString*)fieldKey{
    return CALC_DEVELOPMENT;
}
-(NSString*)displayName{
    return @"Development";
}

-(NSArray*)inputFields{
    return @[@"WeightedMeanSpeed",@"WeightedMeanBikeCadence"];
}
-(NSArray*)inputFieldsTrackPoint{
    return @[@(gcFieldFlagWeightedMeanSpeed),@(gcFieldFlagCadence)];
}

-(GCNumberWithUnit*)evaluateWithInputs:(NSArray<GCNumberWithUnit*> *)inputs{
    if (![self ensureInputs:inputs]) {
        return nil;
    }

    GCNumberWithUnit * speed    = inputs[0];
    GCNumberWithUnit * cadence  = inputs[1];

    speed = [speed convertToUnitName:@"mps"];

    if (cadence.value == 0.) {
        return nil;
    }
    double val = speed.value / cadence.value * 60. ;


    return [GCNumberWithUnit numberWithUnitName:@"development" andValue:val];
}

-(NSString*)unitName{
    return @"development";
}
@end

#pragma mark - Gradient
@implementation GCFieldCalcElevationGradient

-(BOOL)validForActivity:(GCActivity*)act{
    return true;
}
-(NSString*)fieldKey{
    return CALC_ELEVATION_GRADIENT;
}
-(NSString*)displayName{
    return @"Avg Gradient";
}

-(NSArray*)inputFields{
    return @[@"SumDistance",CALC_ALTITUDE_GAIN,CALC_ALTITUDE_LOSS];
}
-(NSArray*)inputFieldsTrackPoint{
    return @[@(gcFieldFlagSumDistance),CALC_ALTITUDE_GAIN,CALC_ALTITUDE_LOSS];
}

-(GCNumberWithUnit*)evaluateWithInputs:(NSArray<GCNumberWithUnit*> *)inputs{
    if (![self ensureInputs:inputs]) {
        return nil;
    }

    GCNumberWithUnit * dist  = inputs[0];
    GCNumberWithUnit * gain  = inputs[1];
    GCNumberWithUnit * loss  = inputs[2];

    gain = [gain convertToUnit:dist.unit];
    loss = [loss convertToUnit:dist.unit];

    double valgain = gain.value / dist.value * 100. ;
    double valloss = loss.value / dist.value * 100. ;
    double val = valgain;
    if (valloss > valgain+5.) { // mostly down
        val = valloss;
    }
    return [GCNumberWithUnit numberWithUnitName:@"percent" andValue:val];
}

-(NSString*)unitName{
    return @"percent";
}

@end


