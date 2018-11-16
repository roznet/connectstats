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
@property (nonatomic,retain) GCActivityTypes * activityTypes;
@end

@implementation GCGarminActivityInterpret
+(GCGarminActivityInterpret*)interpret:(NSDictionary*)data usingDTOUnit:(BOOL)dtoUnits withTypes:(GCActivityTypes*)activityTypes{
    GCGarminActivityInterpret * rv = [[GCGarminActivityInterpret alloc] init];
    rv.data = data;
    rv.dtoUnits = dtoUnits;
    rv.activityTypes = activityTypes;
    
    NSDictionary * typeData = data[@"activityType"] ?: data[@"activityTypeDTO"];
    if([typeData isKindOfClass:[NSDictionary class]]){
        NSString * foundType = typeData[@"typeKey"] ?: typeData[@"key"]; // activityType->key, activityTypeDTO->typeKey
        if([foundType isKindOfClass:[NSString class]]){
            rv.activityType = [rv.activityTypes activityTypeForKey:foundType];
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
-(NSMutableDictionary*)buildSummaryDataFromGarminModernData{
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

-(NSDate*)buildStartDateFromGarminModernData{
    NSDate*rv=nil;
    NSString * startdate = self.data[@"startTimeGMT"];
    if([startdate isKindOfClass:[NSString class]]) {
        rv = [NSDate dateForGarminModernString:startdate];
        if (!rv) {
            RZLog(RZLogError, @"%@: Invalid date %@", self.activityId, startdate);
        }
    }
    return rv;
}


-(void)parseDataInto:(NSMutableDictionary<GCField*,GCActivitySummaryValue*>*)newSummaryData usingDefs:(NSDictionary*)defs{
    
    NSDictionary * data = self.data;
    
    for (NSString * key in data) {
        id def = defs[key];
        NSString * fieldkey = nil;
        NSString * uom = nil;
        NSNumber * val = nil;
        gcFieldFlag flag = gcFieldFlagNone;
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
                    id flago = subdefs[1];
                    if ([flago isKindOfClass:[NSNumber class]]) {
                        flag = [flago intValue];
                    }
                }
            }
#if TARGET_IPHONE_SIMULATOR
            // If running in simulator display what fields are missing
        }else{
            static NSDictionary * knownMissing = nil;
            if( knownMissing == nil){
                knownMissing = @{
                                 @"activityId" : @1, // sample: 2477200414
                                 @"isMultiSportParent" : @1, // sample: 0
                                 @"userProfileId" : @1, // sample: 3020883
                                 @"endLongitude" : @1, // sample: -0.1953904610127211
                                 @"startLongitude" : @1, // sample: -0.1958300918340683
                                 @"endLatitude" : @1, // sample: 51.4716518484056
                                 @"startLatitude" : @1, // sample: 51.47172099910676
                                 @"maxVerticalSpeed" : @1, // sample: 0.6000003814697266
                                 
                                 @"achievement_count" : @1, // sample: 0
                                 @"anaerobicTrainingEffect" : @1, // sample: 1.600000023841858
                                 @"athlete_count" : @1, // sample: 4
                                 @"autoCalcCalories" : @1, // sample: 0
                                 @"averageBikingCadenceInRevPerMinute" : @1, // sample: 68
                                 @"averageRunningCadenceInStepsPerMinute" : @1, // sample: 80
                                 @"averageStrokeDistance" : @1, // sample: 2.589999914169312
                                 @"comment_count" : @1, // sample: 0
                                 @"commute" : @1, // sample: 0
                                 @"device_watts" : @1, // sample: 1
                                 @"elev_high" : @1, // sample: -12.6
                                 @"elev_low" : @1, // sample: -27.2
                                 @"favorite" : @1, // sample: 0
                                 @"flagged" : @1, // sample: 0
                                 @"hasVideo" : @1, // sample: 0
                                 @"has_heartrate" : @1, // sample: 1
                                 @"has_kudoed" : @1, // sample: 0
                                 @"id" : @1, // sample: 730019974
                                 @"kudos_count" : @1, // sample: 0
                                 @"lapIndex" : @1, // sample: 1
                                 @"lengthIndex" : @1, // sample: 1
                                 @"manual" : @1, // sample: 0
                                 @"maxBikingCadenceInRevPerMinute" : @1, // sample: 91
                                 @"maxRunningCadenceInStepsPerMinute" : @1, // sample: 120
                                 @"max_watts" : @1, // sample: 474
                                 @"numberOfActiveLengths" : @1, // sample: 120
                                 @"ownerId" : @1, // sample: 3020883
                                 @"parent" : @1, // sample: 0
                                 @"photo_count" : @1, // sample: 0
                                 @"poolLength" : @1, // sample: 33.33000183105469
                                 @"pr" : @1, // sample: 0
                                 @"private" : @1, // sample: 0
                                 @"resource_state" : @1, // sample: 2
                                 @"start_latitude" : @1, // sample: 51.52
                                 @"start_longitude" : @1, // sample: -0.1
                                 @"steps" : @1, // sample: 8342
                                 @"suffer_score" : @1, // sample: 9
                                 @"total_photo_count" : @1, // sample: 0
                                 @"trainer" : @1, // sample: 0
                                 @"upload_id" : @1, // sample: 804813097
                                 @"userPro" : @1, // sample: 0
                                 @"weighted_average_watts" : @1, // sample: 129
                                 };
                [knownMissing retain];
            }
            
            static NSMutableDictionary * recordMissing = nil;
            if( recordMissing == nil){
                recordMissing = [NSMutableDictionary dictionary];
                [recordMissing retain];
            }
            if( ! recordMissing[key] ){
                NSNumber * sample = nil;
                if( [data[key] isKindOfClass:[NSNumber class]]){
                    sample = data[key];
                    recordMissing[key] = @1;
                }
                if( sample != nil && knownMissing[key] == nil){
                    RZLog(RZLogInfo, @"Modern Unknown Key: %@ sample: %@", key,  sample);
                }
            }
#endif
        }
        if (fieldkey && uom && val) {
            GCField * field = [GCField fieldForKey:fieldkey andActivityType:self.activityTypeAsString];
            GCActivitySummaryValue * sumVal = [self buildSummaryValue:fieldkey uom:uom fieldFlag:flag andValue:val.doubleValue];
            newSummaryData[field] = sumVal;
        }
    }
}

-(void)addPaceIfNecessaryWithSummary:(NSMutableDictionary<GCField*,GCActivitySummaryValue*>*)newSummaryData{
    GCActivitySummaryValue * speed = newSummaryData[ [GCField fieldForKey:@"WeightedMeanSpeed" andActivityType:self.activityTypeAsString]];
    if (speed && ([self.activityTypeAsString isEqualToString:GC_TYPE_RUNNING] || [self.activityTypeAsString isEqualToString:GC_TYPE_SWIMMING])) {
        GCField * field = [GCField fieldForKey:@"WeightedMeanPace" andActivityType:self.activityTypeAsString];
        NSString * uom = [GCFields predefinedUomForField:field.key andActivityType:field.activityType];
        NSString * display = [GCFields predefinedDisplayNameForField:field.key andActivityType:field.activityType];
        
        [GCFields registerField:field.key activityType:self.activityTypeAsString displayName:display andUnitName:uom];
        [GCFields registerField:field.key activityType:GC_TYPE_ALL       displayName:display andUnitName:uom];
        GCNumberWithUnit * val = [[speed numberWithUnit] convertToUnitName:uom];
        newSummaryData[field] = [GCActivitySummaryValue activitySummaryValueForField:field.key value:val];
    }else if(speed){ // otherwise it would set for swim or running when speed = nil
    }
    GCActivitySummaryValue * movingSpeed = newSummaryData[ [GCField fieldForKey:@"WeightedMeanMovingSpeed" andActivityType:self.activityTypeAsString] ];
    if(movingSpeed && [self.activityTypeAsString isEqualToString:GC_TYPE_RUNNING]){
        GCField * field = [GCField fieldForKey:@"WeightedMeanMovingSpeed" andActivityType:self.activityTypeAsString];
        NSString * uom = [GCFields predefinedUomForField:field.key andActivityType:self.activityTypeAsString];
        NSString * display = [GCFields predefinedDisplayNameForField:field.key andActivityType:self.activityTypeAsString];
        
        [GCFields registerField:field.key activityType:self.activityTypeAsString displayName:display andUnitName:uom];
        [GCFields registerField:field.key activityType:GC_TYPE_ALL       displayName:display andUnitName:uom];
        GCNumberWithUnit * val = [[movingSpeed numberWithUnit] convertToUnitName:uom];
        newSummaryData[field] = [GCActivitySummaryValue activitySummaryValueForField:field.key value:val];
    }
    
}
-(GCActivitySummaryValue*)buildSummaryValue:(NSString*)fieldkey uom:(NSString*)uom fieldFlag:(gcFieldFlag)flag andValue:(double)val{
    NSString * display = [GCFields predefinedDisplayNameForField:fieldkey andActivityType:self.activityTypeAsString];
    NSString * displayuom     = [GCFields predefinedUomForField:fieldkey andActivityType:self.activityTypeAsString];
    if (!displayuom) {
        displayuom     = [GCFields predefinedUomForField:fieldkey andActivityType:GC_TYPE_ALL];
    }
    if( !displayuom && [GCUnit unitForKey:uom]){
        displayuom = uom;
    }
    if (!display) {
        display = [GCFields predefinedDisplayNameForField:fieldkey andActivityType:GC_TYPE_ALL];
    }
    GCNumberWithUnit * nu = [GCNumberWithUnit numberWithUnitName:uom andValue:val];
    if (displayuom && ![displayuom isEqualToString:uom]) {
        nu = [nu convertToUnitName:displayuom];
    }
    GCActivitySummaryValue * sumVal = [GCActivitySummaryValue activitySummaryValueForField:fieldkey value:nu];
    [GCFields registerField:fieldkey activityType:self.activityTypeAsString displayName:display andUnitName:displayuom];
    [GCFields registerField:fieldkey activityType:GC_TYPE_ALL       displayName:display andUnitName:displayuom];
    return sumVal;
}

@end
