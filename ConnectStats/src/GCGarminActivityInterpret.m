//  MIT License
//
//  Created on 12/11/2018 for FitFileExplorer
//
//  Copyright (c) 2018 Brice Rosenzweig
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



#import "GCGarminActivityInterpret.h"
@import RZUtils;
#import "GCField.h"
#import "GCActivitySummaryValue.h"
#import "GCActivityType.h"
#import "GCActivityTypes.h"

@interface GCGarminActivityInterpret ()

@property (nonatomic,retain) NSDictionary * data;
@property (nonatomic,assign) BOOL dtoUnits;
@property (nonatomic,retain) GCActivityType * activityType;
@property (nonatomic,retain) NSString * activityTypeAsString;
@end

@implementation GCGarminActivityInterpret

+(GCGarminActivityInterpret*)interpret:(NSDictionary*)data usingDTOUnit:(BOOL)dtoUnits withTypes:(GCActivityTypes*)activityTypes{
    GCGarminActivityInterpret * rv = [[GCGarminActivityInterpret alloc] init];
    rv.data = data;
    rv.dtoUnits = dtoUnits;
    
    NSDictionary * typeData = data[@"activityType"] ?: data[@"activityTypeDTO"];
    if([typeData isKindOfClass:[NSDictionary class]]){
        NSString * foundType = typeData[@"typeKey"] ?: typeData[@"key"]; // activityType->key, activityTypeDTO->typeKey
        if([foundType isKindOfClass:[NSString class]]){
            rv.activityType = [activityTypes activityTypeForKey:foundType];
            rv.activityTypeAsString = [rv.activityType topSubRootType].key;
        }
    }

    return rv;
}

-(NSString*)activityId{
    NSString * foundActivityId = self.data[@"activityId"];
    return foundActivityId;
}

/**
 Build summary data using new format from garmin. Note some format have inconsistent units
 the dictionary for search have a few units for elevation and elapsed duration that are smaller.
 
 @param data dictionary coming from garmin
 @param dtoUnits true if data cames from summaryDTO dictionary (as some units are different)
 @return dictionary field -> summary data
 */
-(NSDictionary<NSString*,GCNumberWithUnit*>*)buildSummaryDataFromGarminModernData{
    NSDictionary * data = self.data;
    BOOL dtoUnitsFlag = self.dtoUnits;
    
    static NSDictionary * defs = nil;
    static NSDictionary * defs_dto = nil;
    if( defs == nil){
        NSDictionary * nonDto = @{
                                  @"maxElevation":        @[ @"MaxElevation",        @"",                                    @"centimeter"],
                                  @"minElevation":        @[ @"MinElevation",        @"",                                    @"centimeter"],
                                  @"elapsedDuration":     @[ @"SumElapsedDuration",   @"",                                    @"ms"],
                                  
                                  };
        
        NSDictionary * dto = @{
                               @"maxElevation":        @[ @"MaxElevation",        @"",                                    @"meter"],
                               @"minElevation":        @[ @"MinElevation",        @"",                                    @"meter"],
                               @"elapsedDuration":     @[ @"SumElapsedDuration",   @"",                                    @"second"],
                               
                               };
        
        
        NSDictionary * commondefs = @{
                                      @"distance":            @[ @"SumDistance",          @(gcFieldFlagSumDistance),              @"meter"],
                                      @"movingDuration":      @[ @"SumMovingDuration",    @"",                                    @"second"],
                                      @"duration":            @[ @"SumDuration",          @(gcFieldFlagSumDuration),              @"second"],
                                      
                                      @"elevationGain":       @[ @"GainElevation",        @(gcFieldFlagAltitudeMeters),           @"meter"],
                                      @"elevationLoss":       @[ @"LossElevation",        @"",                                    @"meter"],
                                      
                                      
                                      @"averageSpeed":        @[ @"WeightedMeanSpeed",    @(gcFieldFlagWeightedMeanSpeed),        @"mps"],
                                      @"averageMovingSpeed":  @[ @"WeightedMeanMovingSpeed",    @"",        @"mps"],
                                      @"maxSpeed":            @[ @"MaxSpeed",             @"",                                    @"mps"],
                                      
                                      @"calories":            @[ @"SumEnergy",            @"",                                    @"kilocalorie"],
                                      
                                      @"averageHR":           @[ @"WeightedMeanHeartRate",@(gcFieldFlagWeightedMeanHeartRate),    @"bpm"],
                                      @"maxHR":               @[ @"MaxHeartRate",         @"",                                    @"bpm"],
                                      
                                      @"averageTemperature":        @[ @"WeightedMeanAirTemperature",@"",                               @"celcius"],
                                      @"maxTemperature":        @[ @"MaxAirTemperature",@"",                               @"celcius"],
                                      @"minTemperature":        @[ @"MinAirTemperature",@"",                               @"celcius"],
                                      
                                      /* RUNNING */
                                      @"groundContactTime":   @[ @"WeightedMeanGroundContactTime", @"", @"ms"],
                                      @"groundContactBalanceLeft":   @[ @"WeightedMeanGroundContactBalanceLeft", @"", @"percent"],
                                      @"verticalRatio":           @[ @"WeightedMeanVerticalRatio", @"", @"percent"],//CHECK
                                      @"avgPower":               @[ @"WeightedMeanPower", @(gcFieldFlagPower), @"watt"],
                                      @"strideLength":    @[ @"WeightedMeanStrideLength", @"", @"centimeter"],
                                      @"avgStrideLength": @[ @"WeightedMeanStrideLength", @"", @"centimeter"],
                                      @"averageStrideLength": @[ @"WeightedMeanStrideLength", @"", @"centimeter"],
                                      @"verticalOscillation": @[@"WeightedMeanVerticalOscillation", @"", @"centimeter"],
                                      
                                      @"averageRunCadence": @[ @"WeightedMeanRunCadence", @(gcFieldFlagCadence), @"doubleStepsPerMinute"],
                                      @"maxRunCadence":   @[ @"MaxRunCadence", @"", @"doubleStepsPerMinute"],
                                      
                                      @"trainingEffect": @[ @"SumTrainingEffect", @"", @"te"],
                                      @"aerobicTrainingEffect": @[ @"SumTrainingEffect", @"", @"te"],
                                      @"lactateThresholdHeartRate":      @[ @"DirectLactateThresholdHeartRate", @"", @"bpm"],
                                      @"lactateThresholdSpeed":     @[ @"DirectLactateThresholdSpeed", @"", @"mps"],
                                      
                                      /* CYCLE */
                                      @"averageBikeCadence": @[ @"WeightedMeanBikeCadence", @(gcFieldFlagCadence), @"rpm"],
                                      @"maxBikeCadence":   @[ @"MaxBikeCadence", @"", @"rpm"],
                                      
                                      @"averagePower":       @[ @"WeightedMeanPower",    @(gcFieldFlagPower),                    @"watt"],
                                      @"maxPower":       @[ @"MaxPower",    @"",                    @"watt"],
                                      @"minPower":       @[ @"MinPower",    @"",                    @"watt"],
                                      @"maxPowerTwentyMinutes":       @[ @"MaxPowerTwentyMinutes",    @"",                    @"watt"],
                                      @"max20MinPower":              @[ @"MaxPowerTwentyMinutes",     @"",                    @"watt"],
                                      @"normalizedPower":       @[ @"WeightedMeanNormalizedPower",    @"",                    @"watt"],
                                      @"normPower":              @[ @"WeightedMeanNormalizedPower",    @"",                    @"watt"],
                                      @"functionalThresholdPower":    @[@"ThresholdPower", @"", @"watt"],
                                      
                                      @"totalWork":          @[ @"SumTotalWork",         @"",                                    @"kilocalorie"],
                                      @"trainingStressScore": @[ @"SumTrainingStressScore", @"", @"dimensionless"],
                                      @"intensityFactor": @[ @"SumIntensityFactor", @"", @"if"],
                                      
                                      @"leftTorqueEffectiveness": @[ @"WeightedMeanLeftTorqueEffectiveness", @"", @"percent"],
                                      @"leftPedalSmoothness": @[ @"WeightedMeanLeftPedalSmoothness", @"", @"percent"],
                                      @"totalNumberOfStrokes": @[ @"SumStrokes", @"", @"dimensionless"],
                                      
                                      /* SWIMMING */
                                      @"averageSwimCadence": @[ @"WeightedMeanSwimCadence", @"", @"strokesPerMinute"],
                                      @"maxSwimCadence" : @[ @"MaxSwimCadence", @"", @"strokesPerMinute"],
                                      @"totalNumberOfStrokes" : @[ @"SumStrokes", @"", @"dimensionless"],
                                      @"averageStrokes": @[ @"WeightedMeanStrokes", @"", @"dimensionless"],
                                      @"averageSWOLF" : @[ @"WeightedMeanSwolf", @"", @"dimensionless"],
                                      //@"averageStrokeDistance" : @[ @""],
                                      
                                      /* ALL */
                                      @"vO2MaxValue" : @[ @"DirectVO2Max", @"", @"ml/kg/min"],
                                      };
        
        NSMutableDictionary * buildDefs = [NSMutableDictionary dictionaryWithDictionary:commondefs];
        NSMutableDictionary * buildDefs_dto = [NSMutableDictionary dictionaryWithDictionary:commondefs];
        for (NSString * key in nonDto) {
            buildDefs[key] = nonDto[key];
        }
        for (NSString * key in dto) {
            buildDefs_dto[key] = dto[key];
        }
        
        defs = [NSDictionary dictionaryWithDictionary:buildDefs];
        defs_dto = [NSDictionary dictionaryWithDictionary:buildDefs_dto];
        
        RZRetain(defs);
        RZRetain(defs_dto);
    }
    NSMutableDictionary * newSummaryData = [NSMutableDictionary dictionaryWithCapacity:data.count];
    [self parseDataInto:newSummaryData usingDefs:dtoUnitsFlag?defs_dto:defs];
    // few extra derived
    [self addPaceIfNecessaryWithSummary:newSummaryData];
    
    return newSummaryData;
}

-(CLLocationCoordinate2D)buildCoordinateFromGarminModernData{
    
    NSNumber * startLat = self.data[@"startLatitude"];
    NSNumber * startLon = self.data[@"startLongitude"];
    
    if (startLat && startLon && [startLat isKindOfClass:[NSNumber class]] && [startLon isKindOfClass:[NSNumber class]]) {
        return CLLocationCoordinate2DMake([startLat doubleValue], [startLon doubleValue]);
    }
    return CLLocationCoordinate2DMake(0, 0);
}

-(NSDate*)dateFor:(NSString*)field{
    NSDate*rv=nil;
    NSString * startdate = self.data[field];
    if([startdate isKindOfClass:[NSString class]]) {
        rv = [NSDate dateForGarminModernString:startdate];
        if (!rv) {
            RZLog(RZLogError, @"%@: Invalid date %@", self.activityId, startdate);
        }
    }
    return rv;

}

-(NSDate*)startDate{
    return [self dateFor:@"startTimeGMT"];
}

-(void)parseDataInto:(NSMutableDictionary<NSString*,GCNumberWithUnit*>*)newSummaryData usingDefs:(NSDictionary*)defs{
    
    NSDictionary * data = self.data;
    
    for (NSString * key in data) {
        id def = defs[key];
        NSString * fieldkey = nil;
        NSString * uom = nil;
        NSNumber * val = nil;
        if (def) {
            id valo = data[key];
            if ([valo isKindOfClass:[NSNumber class]]) {
                val = valo;
            }else if ([valo isKindOfClass:[NSString class]]){
                val = @([valo doubleValue]);
            }
            if ([def isKindOfClass:[NSDictionary class]]) {
                NSDictionary * subdefs = def;
                NSArray * thisdef = subdefs[self.activityTypeAsString];
                if (thisdef) {
                    fieldkey = thisdef[0];
                    uom = thisdef[1];
                }
            }else if ([def isKindOfClass:[NSArray class]]){
                NSArray * subdefs = def;
                if (subdefs) {
                    fieldkey = subdefs[0];
                    uom = subdefs[2];
                    // Ignore subdefs[1] that contains the flag as int
                }
            }
        }
        if (fieldkey && uom && val) {
            newSummaryData[fieldkey] = [GCNumberWithUnit numberWithUnitName:uom andValue:val.doubleValue];
        }
    }
}

-(void)addPaceIfNecessaryWithSummary:(NSMutableDictionary<NSString*,GCNumberWithUnit*>*)newSummaryData{
    if( ([self.activityTypeAsString isEqualToString:GC_TYPE_RUNNING] || [self.activityTypeAsString isEqualToString:GC_TYPE_SWIMMING]) ){
        for( NSString * fieldkey in @[ @"WeightedMeanSpeed", @"WeightedMeanMovingSpeed" ] ){
            GCNumberWithUnit * speed = newSummaryData[ fieldkey ];
            if (speed ) {
                GCField * field = [GCField fieldForKey:fieldkey andActivityType:self.activityTypeAsString];
                newSummaryData[fieldkey] = [speed convertToUnit:field.unit];
            }
        }
    }
}

@end
