//  MIT License
//
//  Created on 06/01/2019 for FitFileExplorer
//
//  Copyright (c) 2019 Brice Rosenzweig
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



import Foundation

typealias GarminFieldInfo = (field:String, num:gcFieldFlag, unit:String)

class GarminDataFieldDefinitions {
    
    private static let nonDto : [String:GarminFieldInfo] = [
        "maxElevation":               ( "MaxElevation",                         gcFieldFlag.none,                  "centimeter"),
        "minElevation":               ( "MinElevation",                         gcFieldFlag.none,                  "centimeter"),
        "elapsedDuration":            ( "SumElapsedDuration",                   gcFieldFlag.none,                  "ms"),
        
        ]
    
    private static let dto = [
        "maxElevation":               ( "MaxElevation",                         gcFieldFlag.none,                  "meter"),
        "minElevation":               ( "MinElevation",                         gcFieldFlag.none,                  "meter"),
        "elapsedDuration":            ( "SumElapsedDuration",                   gcFieldFlag.none,                  "second"),
        
        ]
    
    
    private static let commondefs = [
        "distance":                   ( "SumDistance",                          gcFieldFlag.sumDistance,           "meter"),
        "movingDuration":             ( "SumMovingDuration",                    gcFieldFlag.none,                  "second"),
        "duration":                   ( "SumDuration",                          gcFieldFlag.sumDuration,           "second"),
        
        "elevationGain":              ( "GainElevation",                        gcFieldFlag.altitudeMeters,        "meter"),
        "elevationLoss":              ( "LossElevation",                        gcFieldFlag.none,                  "meter"),
        
        
        "averageSpeed":               ( "WeightedMeanSpeed",                    gcFieldFlag.weightedMeanSpeed,     "mps"),
        "averageMovingSpeed":         ( "WeightedMeanMovingSpeed",              gcFieldFlag.none,                  "mps"),
        "maxSpeed":                   ( "MaxSpeed",                             gcFieldFlag.none,                  "mps"),
        
        "calories":                   ( "SumEnergy",                            gcFieldFlag.none,                  "kilocalorie"),
        
        "averageHR":                  ( "WeightedMeanHeartRate",                gcFieldFlag.weightedMeanHeartRate, "bpm"),
        "maxHR":                      ( "MaxHeartRate",                         gcFieldFlag.none,                  "bpm"),
        
        "averageTemperature":         ( "WeightedMeanAirTemperature",           gcFieldFlag.none,                  "celcius"),
        "maxTemperature":             ( "MaxAirTemperature",                    gcFieldFlag.none,                  "celcius"),
        "minTemperature":             ( "MinAirTemperature",                    gcFieldFlag.none,                  "celcius"),
        
        /* RUNNING */
        "groundContactTime":           ( "WeightedMeanGroundContactTime",        gcFieldFlag.none,                  "ms"),
        "groundContactBalanceLeft":    ( "WeightedMeanGroundContactBalanceLeft", gcFieldFlag.none,                  "percent"),
        "verticalRatio":               ( "WeightedMeanVerticalRatio",            gcFieldFlag.none,                  "percent"),//CHECK
        "avgPower":                    ( "WeightedMeanPower",                    gcFieldFlag.power,                 "watt"),
        "strideLength":                ( "WeightedMeanStrideLength",             gcFieldFlag.none,                  "centimeter"),
        "avgStrideLength":             ( "WeightedMeanStrideLength",             gcFieldFlag.none,                  "centimeter"),
        "averageStrideLength":         ( "WeightedMeanStrideLength",             gcFieldFlag.none,                  "centimeter"),
        "verticalOscillation":         ("WeightedMeanVerticalOscillation",       gcFieldFlag.none,                  "centimeter"),
        
        "averageRunCadence":           ( "WeightedMeanRunCadence",               gcFieldFlag.cadence,               "doubleStepsPerMinute"),
        "maxRunCadence":               ( "MaxRunCadence",                        gcFieldFlag.none,                  "doubleStepsPerMinute"),
        
        "trainingEffect":              ( "SumTrainingEffect",                    gcFieldFlag.none,                  "te"),
        "aerobicTrainingEffect":       ( "SumTrainingEffect",                    gcFieldFlag.none,                  "te"),
        "lactateThresholdHeartRate":   ( "DirectLactateThresholdHeartRate",      gcFieldFlag.none,                  "bpm"),
        "lactateThresholdSpeed":       ( "DirectLactateThresholdSpeed",          gcFieldFlag.none,                  "mps"),
        
        /* CYCLE */
        "averageBikeCadence":          ( "WeightedMeanBikeCadence",              gcFieldFlag.cadence,               "rpm"),
        "maxBikeCadence":              ( "MaxBikeCadence",                       gcFieldFlag.none,                  "rpm"),
        
        "averagePower":                ( "WeightedMeanPower",                    gcFieldFlag.power,                 "watt"),
        "maxPower":                    ( "MaxPower",                             gcFieldFlag.none,                  "watt"),
        "minPower":                    ( "MinPower",                             gcFieldFlag.none,                  "watt"),
        "maxPowerTwentyMinutes":       ( "MaxPowerTwentyMinutes",                gcFieldFlag.none,                  "watt"),
        "max20MinPower":               ( "MaxPowerTwentyMinutes",                gcFieldFlag.none,                  "watt"),
        "normalizedPower":             ( "WeightedMeanNormalizedPower",          gcFieldFlag.none,                  "watt"),
        "normPower":                   ( "WeightedMeanNormalizedPower",          gcFieldFlag.none,                  "watt"),
        "functionalThresholdPower":    ("ThresholdPower",                        gcFieldFlag.none,                  "watt"),
        
        "totalWork":                   ( "SumTotalWork",                         gcFieldFlag.none,                  "kilocalorie"),
        "trainingStressScore":         ( "SumTrainingStressScore",               gcFieldFlag.none,                  "dimensionless"),
        "intensityFactor":             ( "SumIntensityFactor",                   gcFieldFlag.none,                  "if"),
        
        "leftTorqueEffectiveness":     ( "WeightedMeanLeftTorqueEffectiveness",  gcFieldFlag.none,                  "percent"),
        "leftPedalSmoothness":         ( "WeightedMeanLeftPedalSmoothness",      gcFieldFlag.none,                  "percent"),
        
        /* SWIMMING */
        "averageSwimCadence":         ( "WeightedMeanSwimCadence",              gcFieldFlag.none,                  "strokesPerMinute"),
        "maxSwimCadence" :            ( "MaxSwimCadence",                       gcFieldFlag.none,                  "strokesPerMinute"),
        "totalNumberOfStrokes" :      ( "SumStrokes",                           gcFieldFlag.none,                  "dimensionless"),
        "averageStrokes":             ( "WeightedMeanStrokes",                  gcFieldFlag.none,                  "dimensionless"),
        "averageSWOLF" :              ( "WeightedMeanSwolf",                    gcFieldFlag.none,                  "dimensionless"),
        //"averageStrokeDistance" :     ( ""),
        
        /* ALL */
        "vO2MaxValue" :               ( "DirectVO2Max",                         gcFieldFlag.none,                  "ml/kg/min"),
        ]
    
    
    static var dtoDefinition : [String:GarminFieldInfo]{
        var rv = self.commondefs
        for (key,val) in dto {
            rv[key] = val
        }
        
        return rv
    }
    
    static var nonDtoDefinition:[String:GarminFieldInfo]{
        var rv = self.commondefs
        for (key,val) in nonDto {
            rv[key] = val
        }
        
        return rv

    }
    
}
