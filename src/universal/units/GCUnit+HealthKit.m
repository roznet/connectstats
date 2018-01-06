//  MIT Licence
//
//  Created on 17/09/2016.
//
//  Copyright (c) 2016 Brice Rosenzweig.
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

#import "GCUnit+HealthKit.h"
NSDictionary * _unitsToHKUnits = nil;
NSDictionary * _unitsFromHKUnits =nil;

@implementation GCUnit (HealthKit)

+(void)setupHealthUnitCache{

    if (_unitsToHKUnits==nil && [HKHealthStore class]) {
        _unitsToHKUnits = @{
                            @"kilogram":  [HKUnit gramUnitWithMetricPrefix:HKMetricPrefixKilo],       // g
                            @"gram":   [HKUnit gramUnit],   // g
                            @"pound":  [HKUnit poundUnit],  // lb
                            //@"oz":  [HKUnit ounceUnit],  // oz
                            //@"st":  [HKUnit stoneUnit],  // st
                            //@"mol<double>": [HKUnit moleUnitWithMetricPrefix:(HKMetricPrefix)prefix molarMass:(double)gramsPerMole],   // mol<double>
                            //@"mol<double>": [HKUnit moleUnitWithMolarMass:(double)gramsPerMole], // mol<double>

                            /* Length Units */
                            @"kilometer":   [HKUnit meterUnitWithMetricPrefix:HKMetricPrefixKilo],      // m
                            @"meter":       [HKUnit meterUnit],  // m
                            @"inch": [HKUnit inchUnit],   // in
                            @"foot": [HKUnit footUnit],   // ft
                            @"mile": [HKUnit mileUnit],   // mi

                            /* Volume Units */
                            //@"L": [HKUnit literUnitWithMetricPrefix:(HKMetricPrefix)prefix],      // L
                            //@"L": [HKUnit literUnit],              // L
                            //@"fl_oz_us": [HKUnit fluidOunceUSUnit],       // fl_oz_us
                            //@"fl_oz_imp": [HKUnit fluidOunceImperialUnit], // fl_oz_imp
                            //@"pt_us": [HKUnit pintUSUnit],             // pt_us
                            //@"pt_imp": [HKUnit pintImperialUnit],       // pt_imp

                            /* Pressure Units */
                            //@"Pa": [HKUnit pascalUnitWithMetricPrefix:(HKMetricPrefix)prefix],     // Pa
                            //@"Pa": [HKUnit pascalUnit],                 // Pa
                            //@"mmHg": [HKUnit millimeterOfMercuryUnit],    // mmHg
                            //@"cmAq": [HKUnit centimeterOfWaterUnit],      // cmAq
                            //@"atm": [HKUnit atmosphereUnit],             // atm

                            /* Time Units */
                            @"ms": [HKUnit secondUnitWithMetricPrefix:HKMetricPrefixMilli],     // s
                            @"second": [HKUnit secondUnit], // s
                            @"minute": [HKUnit minuteUnit], // min
                            @"hour": [HKUnit hourUnit],   // hr
                            //@"day": [HKUnit dayUnit],    // d

                            /* Energy Units */
                            @"kilojoule": [HKUnit jouleUnitWithMetricPrefix:HKMetricPrefixKilo],      // J
                            //@"J": [HKUnit jouleUnit],          // J
                            //@"cal": [HKUnit calorieUnit],        // cal
                            @"kilocalorie": [HKUnit kilocalorieUnit],    // kcal

                            /* Temperature Units */
                            @"celcius": [HKUnit degreeCelsiusUnit],          // degC
                            @"fahrenheit": [HKUnit degreeFahrenheitUnit],       // degF
                            //@"K": [HKUnit kelvinUnit],                 // K

                            /* Electrical Conductance Units */
                            //@"S": [HKUnit siemenUnitWithMetricPrefix:(HKMetricPrefix)prefix],     // S
                            //@"S": [HKUnit siemenUnit], // S

                            /* Scalar Units */
                            @"dimensionless": [HKUnit countUnit],      // count
                            //@"percent": [HKUnit percentUnit],    // % (0.0 - 1.0)
                            @"step": [HKUnit countUnit],

                            @"bpm": [[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]],
                            };
        RZRetain( _unitsToHKUnits);
        NSMutableDictionary * reverse = [NSMutableDictionary dictionaryWithCapacity:_unitsToHKUnits.count];
        for (NSString*s in _unitsToHKUnits) {
            HKUnit * other = _unitsToHKUnits[s];
            [reverse setObject:[GCUnit unitForKey:s] forKeyedSubscript:other.unitString];
        }
        _unitsFromHKUnits = [NSDictionary dictionaryWithDictionary:reverse];
        RZRetain(_unitsFromHKUnits);

    }

}

+(GCUnit*)fromHkUnit:(HKUnit*)unit{
    [GCUnit setupHealthUnitCache];
    return _unitsFromHKUnits[unit.unitString];
}
-(HKUnit*)hkUnit{
    [GCUnit setupHealthUnitCache];
    // special case
    if( [self.key isEqualToString:@"floor"] ){
        return [HKUnit countUnit];
    }
    return _unitsToHKUnits[self.key];
}

@end
