//  MIT Licence
//
//  Created on 12/02/2014.
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

#import "GCActivity+Import.h"
#import "GCActivitySummaryValue.h"
#import "GCActivityMetaValue.h"
#import "GCFieldsCalculated.h"
#import "GCAppGlobal.h"
#import "GCActivity+Database.h"
#import "GCService.h"
#import "GCTrackPoint.h"
#import "GCHealthKitSamplesToPointsParser.h"
#import "GCActivityType.h"

#ifdef GC_USE_HEALTHKIT
#import <HealthKit/HealthKit.h>
#endif

@implementation GCActivity (Internal)

-(GCActivity*)initWithId:(NSString*)aId andGarminData:(NSDictionary*)aData{
    self = [self initWithId:aId];
    if (self) {
        if(aData[@"activitySummary"]){
            [self parseGarminJson:aData];
        }else if(aData[@"activity"]){
            [self parseGarminJson:aData[@"activity"]];
        }else{
            [self parseModernGarminJson:aData];
        }
        self.settings = [GCActivitySettings defaultsFor:self];
    }
    return self;
}


-(GCActivity*)initWithId:(NSString*)aId andStravaData:(NSDictionary*)aData{
    self = [self initWithId:aId];
    if (self) {
        self.activityId = aId;
        [self parseStravaJson:aData];
        self.settings = [GCActivitySettings defaultsFor:self];
    }
    return self;
}

-(GCActivity*)initWithId:(NSString*)aId andSportTracksData:(NSDictionary*)aData{
    self = [self initWithId:aId];
    if (self) {
        self.activityId = aId;
        [self parseSportTracksJson:aData];
        self.settings = [GCActivitySettings defaultsFor:self];
    }
    return self;
}


-(GCActivity*)initWithId:(NSString *)aId andHealthKitWorkout:(HKWorkout*)workout withSamples:(NSArray*)samples{
    self = [self init];
    if (self) {
#ifdef GC_USE_HEALTHKIT
        self.activityId = aId;
        [self parseHealthKitWorkout:workout withSamples:samples];
        self.settings = [GCActivitySettings defaultsFor:self];
    }
#endif
    return self;
}

-(GCActivity*)initWithId:(NSString *)aId andHealthKitSummaryData:(NSDictionary*)dict{
    self = [self init];
    if (self) {
        self.activityId = aId;
        [self parseHealthKitSummaryData:dict];
    }
    return self;
}

#pragma mark -

-(void)setSummaryField:(gcFieldFlag)which with:(GCNumberWithUnit*)nu{
    switch (which) {
        case gcFieldFlagSumDistance:
            self.sumDistance = [nu convertToUnitName:STOREUNIT_DISTANCE].value;
            self.flags |= gcFieldFlagSumDistance;
            break;
        case gcFieldFlagSumDuration:
            self.sumDuration = [nu convertToUnitName:STOREUNIT_ELAPSED].value;
            self.flags |= gcFieldFlagSumDuration;
            break;
        case gcFieldFlagWeightedMeanHeartRate:
            self.weightedMeanHeartRate = nu.value;
            self.flags |= gcFieldFlagWeightedMeanHeartRate;
            break;
        case gcFieldFlagWeightedMeanSpeed:
            self.weightedMeanSpeed = [nu convertToUnitName:STOREUNIT_SPEED].value;
            self.flags |= gcFieldFlagWeightedMeanSpeed;
            break;
        default:
            break;
    }
}

-(void)mergeSummaryData:(NSDictionary*)newDict{
    NSMutableDictionary * merged = self.summaryData ? [NSMutableDictionary dictionaryWithDictionary:self.summaryData] : [NSMutableDictionary dictionaryWithCapacity:newDict.count];

    for (NSString * field in newDict) {
        //GCActivitySummaryValue * old = [merged objectForKey:field];
        GCActivitySummaryValue * new = newDict[field];
        merged[field] = new;
    }
    self.summaryData = merged;
    [self updateSummaryFieldFromSummaryData];
}

-(void)parseData:(NSDictionary*)data into:(NSMutableDictionary*)newSummaryData usingDefs:(NSDictionary*)defs{
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
                NSArray * thisdef = subdefs[self.activityType];
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
        }
        if (fieldkey && uom && val) {
            GCActivitySummaryValue * sumVal = [self buildSummaryValue:fieldkey uom:uom fieldFlag:flag andValue:val.doubleValue];
            newSummaryData[fieldkey] = sumVal;
        }
    }
}

-(void)updateSummaryFieldFromSummaryData{
    for (GCField * field in self.summaryData) {
        GCActivitySummaryValue * value = self.summaryData[field];
        if (field.fieldFlag!= gcFieldFlagNone) {
            GCNumberWithUnit * nu = value.numberWithUnit;
            [self setSummaryField:field.fieldFlag with:nu];
            self.flags |= field.fieldFlag;
        }
    }
}

-(GCActivitySummaryValue*)buildSummaryValue:(NSString*)fieldkey uom:(NSString*)uom fieldFlag:(gcFieldFlag)flag andValue:(double)val{
    NSString * display = [GCFields predefinedDisplayNameForField:fieldkey andActivityType:self.activityType];
    NSString * displayuom     = [GCFields predefinedUomForField:fieldkey andActivityType:self.activityType];
    if (!displayuom) {
        displayuom     = [GCFields predefinedUomForField:fieldkey andActivityType:GC_TYPE_ALL];
    }
    if (!display) {
        display = [GCFields predefinedDisplayNameForField:fieldkey andActivityType:GC_TYPE_ALL];
    }
    GCNumberWithUnit * nu = [GCNumberWithUnit numberWithUnitName:uom andValue:val];
    if (displayuom && ![displayuom isEqualToString:uom]) {
        nu = [nu convertToUnitName:displayuom];
    }
    GCActivitySummaryValue * sumVal = [GCActivitySummaryValue activitySummaryValueForField:fieldkey value:nu];
    [GCFields registerField:fieldkey activityType:self.activityType displayName:display andUnitName:displayuom];
    [GCFields registerField:fieldkey activityType:GC_TYPE_ALL       displayName:display andUnitName:displayuom];
    return sumVal;
}

-(void)addPaceIfNecessaryWithSummary:(NSMutableDictionary<GCField*,GCActivitySummaryValue*>*)newSummaryData{
    GCActivitySummaryValue * speed = newSummaryData[ [GCField fieldForKey:@"WeightedMeanSpeed" andActivityType:self.activityType]];
    if (speed && ([self.activityType isEqualToString:GC_TYPE_RUNNING] || [self.activityType isEqualToString:GC_TYPE_SWIMMING])) {
        GCField * field = [GCField fieldForKey:@"WeightedMeanPace" andActivityType:self.activityType];
        NSString * uom = [GCFields predefinedUomForField:field.key andActivityType:field.activityType];
        NSString * display = [GCFields predefinedDisplayNameForField:field.key andActivityType:field.activityType];

        [GCFields registerField:field.key activityType:self.activityType displayName:display andUnitName:uom];
        [GCFields registerField:field.key activityType:GC_TYPE_ALL       displayName:display andUnitName:uom];
        GCNumberWithUnit * val = [[speed numberWithUnit] convertToUnitName:uom];
        newSummaryData[field] = [GCActivitySummaryValue activitySummaryValueForField:field.key value:val];
        self.speedDisplayUom = uom;
    }else if(speed){ // otherwise it would set for swim or running when speed = nil
        self.speedDisplayUom = speed ? speed.numberWithUnit.unit.key : @"kph";
    }
    GCActivitySummaryValue * movingSpeed = newSummaryData[ [GCField fieldForKey:@"WeightedMeanMovingSpeed" andActivityType:self.activityType] ];
    if(movingSpeed && [self.activityType isEqualToString:GC_TYPE_RUNNING]){
        GCField * field = [GCField fieldForKey:@"WeightedMeanMovingSpeed" andActivityType:self.activityType];
        NSString * uom = [GCFields predefinedUomForField:field.key andActivityType:self.activityType];
        NSString * display = [GCFields predefinedDisplayNameForField:field.key andActivityType:self.activityType];

        [GCFields registerField:field.key activityType:self.activityType displayName:display andUnitName:uom];
        [GCFields registerField:field.key activityType:GC_TYPE_ALL       displayName:display andUnitName:uom];
        GCNumberWithUnit * val = [[movingSpeed numberWithUnit] convertToUnitName:uom];
        newSummaryData[field] = [GCActivitySummaryValue activitySummaryValueForField:field.key value:val];
    }

}
#pragma mark -

-(void)parseModernGarminJson:(NSDictionary*)data{
    GCService * service = [GCService service:gcServiceGarmin];

    NSString * foundActivityId = data[@"activityId"];
    if( [foundActivityId respondsToSelector:@selector(stringValue)]){
        self.activityId = [service activityIdFromServiceId:[data[@"activityId"] stringValue]];
    }
    NSNumber * parentId = data[@"parentId"];
    if ([parentId isKindOfClass:[NSNumber class]]) {
        self.parentId = [parentId stringValue];
    }

    NSDictionary * typeData = data[@"activityType"] ?: data[@"activityTypeDTO"];
    if([typeData isKindOfClass:[NSDictionary class]]){
        NSString * foundType = typeData[@"typeKey"];
        if([foundType isKindOfClass:[NSString class]]){
            GCActivityType * fullType = [[GCAppGlobal activityTypes] activityTypeForKey:foundType];
            if (fullType) {
                self.activityType = fullType.topSubRootType.key;
                self.activityTypeDetail = fullType.key;
            }else{
                self.activityType = foundType;
                self.activityTypeDetail = self.activityType;
            }
        }
    }
    NSString * foundName = data[@"activityName"];
    if ([foundName isKindOfClass:[NSString class]]) {
        self.activityName = foundName;
    }else{
        self.activityName = @"";
    }

    self.location = @"";
    self.downloadMethod = gcDownloadMethodModern;

    [self parseGarminModernSummaryData:data];
    NSDictionary * foundSummaryDTO = data[@"summaryDTO"];
    if([foundSummaryDTO isKindOfClass:[NSDictionary class]]){
        [self parseGarminModernSummaryData:foundSummaryDTO];
    }
    NSDictionary * foundMetaDTO = data[@"metadataDTO"];
    if( [foundMetaDTO isKindOfClass:[NSDictionary class]]){
        [self updateMetadataFromModernGarminJson:foundMetaDTO];
    }
    if (self.metaData==nil) {
        self.metaData = [NSMutableDictionary dictionary];
    }
}

-(void)updateMetadataFromModernGarminJson:(NSDictionary*)meta{
    NSArray * childIds = meta[@"childIds"];

    if( [childIds isKindOfClass:[NSArray class]] ){
        self.childIds = childIds;
    }

    NSMutableDictionary * extraMeta = self.metaData ? [NSMutableDictionary dictionaryWithDictionary:self.metaData] : [NSMutableDictionary dictionary];

    for( NSString * key in @[ @"agentApplicationInstallationId", @"deviceApplicationInstallationId"]){
        NSNumber * keyValue = meta[key];
        if( [keyValue isKindOfClass:[NSNumber class]]){
            GCActivityMetaValue * metaVal = [GCActivityMetaValue activityMetaValueForDisplay:[keyValue stringValue] andField:key];
            extraMeta[ key ] = metaVal;
        }
    }
    self.metaData = extraMeta;

}

-(NSMutableDictionary*)buildSummaryDataFromGarminModernData:(NSDictionary*)data{
    static NSDictionary * defs = nil;
    if( defs == nil){
        defs = @{
                 @"distance":            @[ @"SumDistance",          @(gcFieldFlagSumDistance),              @"meter"],
                 @"movingDuration":      @[ @"SumMovingDuration",    @"",                                    @"second"],
                 @"duration":            @[ @"SumDuration",          @(gcFieldFlagSumDuration),              @"second"],
                 @"elapsedDuration":     @[ @"SumElapsedDuration",   @"",                                    @"second"],

                 @"elevationGain":       @[ @"GainElevation",        @(gcFieldFlagAltitudeMeters),           @"meter"],
                 @"elevationLoss":       @[ @"LossElevation",        @"",                                    @"meter"],
                 @"maxElevation":        @[ @"MaxElevation",        @"",                                    @"meter"],
                 @"minElevation":        @[ @"MinElevation",        @"",                                    @"meter"],

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

                 @"strideLength":    @[ @"WeightedMeanStrideLength", @"", @"centimeter"],
                 @"verticalOscillation": @[@"WeightedMeanVerticalOscillation", @"", @"centimeter"],

                 @"averageRunCadence": @[ @"WeightedMeanRunCadence", @(gcFieldFlagCadence), @"doubleStepsPerMinute"],
                 @"maxRunCadence":   @[ @"MaxRunCadence", @"", @"doubleStepsPerMinute"],

                 @"trainingEffect": @[ @"SumTrainingEffect", @"", @"te"],
                 @"lactateThresholdHeartRate": 	 @[ @"DirectLactateThresholdHeartRate", @"", @"bpm"],
                 @"lactateThresholdSpeed": 	@[ @"DirectLactateThresholdSpeed", @"", @"mps"],

                 /* CYCLE */
                 @"averageBikeCadence": @[ @"WeightedMeanBikeCadence", @(gcFieldFlagCadence), @"rpm"],
                 @"maxBikeCadence":   @[ @"MaxBikeCadence", @"", @"rpm"],

                 @"averagePower":       @[ @"WeightedMeanPower",    @(gcFieldFlagPower),                    @"watt"],
                 @"maxPower":       @[ @"MaxPower",    @"",                    @"watt"],
                 @"minPower":       @[ @"MinPower",    @"",                    @"watt"],
                 @"maxPowerTwentyMinutes":       @[ @"MaxPowerTwentyMinutes",    @"",                    @"watt"],
                 @"normalizedPower":       @[ @"WeightedMeanNormalizedPower",    @"",                    @"watt"],
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

                 };
        [defs retain];
    }
    NSMutableDictionary * newSummaryData = [NSMutableDictionary dictionaryWithCapacity:data.count];
    [self parseData:data into:newSummaryData usingDefs:defs];
    // few extra derived
    [self addPaceIfNecessaryWithSummary:newSummaryData];

    return newSummaryData;
}

-(CLLocationCoordinate2D)buildCoordinateFromGarminModernData:(NSDictionary*)data{

    NSNumber * startLat = data[@"startLatitude"];
    NSNumber * startLon = data[@"startLongitude"];

    if (startLat && startLon && [startLat isKindOfClass:[NSNumber class]] && [startLon isKindOfClass:[NSNumber class]]) {
        return CLLocationCoordinate2DMake([startLat doubleValue], [startLon doubleValue]);
    }
    return CLLocationCoordinate2DMake(0, 0);
}

-(NSDate*)buildStartDateFromGarminModernData:(NSDictionary*)data{
    NSDate*rv=nil;
    NSString * startdate = data[@"startTimeGMT"];
    if([startdate isKindOfClass:[NSString class]]) {
        rv = [NSDate dateForGarminModernString:startdate];
        if (!rv) {
            RZLog(RZLogError, @"%@: Invalid date %@", self.activityId, startdate);
        }
    }
    return rv;
}

-(void)parseGarminModernSummaryData:(NSDictionary*)data{

    if (self.activityType) {
        NSMutableDictionary * newSummaryData = [self buildSummaryDataFromGarminModernData:data];

        self.distanceDisplayUom = [GCFields predefinedUomForField:@"SumDistance" andActivityType:self.activityType];
        if (!self.distanceDisplayUom) {
            self.distanceDisplayUom = [GCFields predefinedUomForField:@"SumDistance" andActivityType:GC_TYPE_ALL];
        }
        [self mergeSummaryData:newSummaryData];

        self.beginCoordinate = [self buildCoordinateFromGarminModernData:data];
        self.date = [self buildStartDateFromGarminModernData:data];
    }
}

-(void)parseGarminJson:(NSDictionary*)aData{
    NSMutableDictionary * summary= aData[@"activitySummary"];


    NSDictionary * atypeDict = aData[@"activityType"];
    self.activityType = atypeDict[@"parent"][@"key"];
    NSString * activityDisplay = atypeDict[@"parent"][@"display"];
    [GCFields registerField:self.activityType
               activityType:self.activityType
                displayName:activityDisplay
                andUnitName:@"dimensionless"];
    self.activityTypeDetail = atypeDict[@"key"];
    NSString * detailDisplay = atypeDict[@"display"];
    if (detailDisplay && self.activityTypeDetail) {
        [GCFields registerField:self.activityTypeDetail
                   activityType:self.activityTypeDetail
                    displayName:detailDisplay
                    andUnitName:@"dimensionless"];
    }

    self.activityName = aData[@"activityName"];
    self.date = [NSDate dateForRFC3339DateTimeString:summary[@"BeginTimestamp"][@"value"]];
    if ([self.activityType isEqualToString:GC_TYPE_MULTISPORT]) {
        // Hack so the multisport always a bit before the first activity
        self.date = [self.date dateByAddingTimeInterval:-0.0001];
    }
    self.location = @"";

    NSNumber *aId = aData[@"activityId"];
    if( [aId isKindOfClass:[NSNumber class]]){
        self.activityId = [aId stringValue];
    }else{
        NSString * aIdS = aData[@"activityId"];
        if( [aIdS isKindOfClass:[NSString class]]){
            self.activityId = aIdS;
        }
    }


    NSDictionary * dist = summary[@"SumDistance"];
    NSDictionary * dura = summary[@"SumDuration"];
    NSDictionary * hrat = summary[@"WeightedMeanHeartRate"];
    if (hrat[@"bpm"]) {
        hrat=hrat[@"bpm"];
    }
    NSDictionary * spee = summary[[GCFields fieldForFlag:gcFieldFlagWeightedMeanSpeed andActivityType:self.activityType]];

    self.sumDuration = [dura[@"value"] doubleValue];
    self.weightedMeanHeartRate = [hrat[@"value"] doubleValue];

    self.speedDisplayUom = spee[@"uom"];
    if (self.speedDisplayUom==nil) {
        // arbitrary uom for 0 anyway.
        [self setSpeedDisplayUom:STOREUNIT_SPEED];
    }
    GCUnit * speeU = [GCUnit unitForKey:self.speedDisplayUom];
    self.weightedMeanSpeed = [speeU convertDouble:[spee[@"value"] doubleValue] toUnit:[GCUnit unitForKey:STOREUNIT_SPEED]];

    self.distanceDisplayUom = dist[@"uom"];
    if (self.distanceDisplayUom==nil) {
        [self setDistanceDisplayUom:STOREUNIT_DISTANCE];
    }
    GCUnit * distU = [GCUnit unitForKey:self.distanceDisplayUom];
    self.sumDistance = [distU convertDouble:[dist[@"value"] doubleValue] toUnit:[GCUnit unitForKey:STOREUNIT_DISTANCE]];

    self.flags  = dist == nil ? 0 : gcFieldFlagSumDistance;
    self.flags |= dura == nil ? 0 : gcFieldFlagSumDuration;
    self.flags |= hrat == nil ? 0 : gcFieldFlagWeightedMeanHeartRate;
    self.flags |= spee == nil ? 0 : gcFieldFlagWeightedMeanSpeed;

    if (summary[@"WeightedMeanBikeCadence"]||
        summary[@"WeightedMeanRunCadence"]||
        summary[@"WeightedMeanSwimCadence"]) {
        self.flags |= gcFieldFlagCadence;
    }

    // Start with trackFlags is flags, as it's the best guest
    // Later if tracks are downloaded it will be updated from the actual tracks.
    self.trackFlags = self.flags;

    if (summary[@"BeginLatitude"]) {
        self.beginCoordinate = CLLocationCoordinate2DMake([summary[@"BeginLatitude"][@"value"] doubleValue],
                                                     [summary[@"BeginLongitude"][@"value"] doubleValue]);
    }

    NSMutableDictionary *summaryDataTmp = [NSMutableDictionary dictionaryWithCapacity:summary.count];
    for (NSString * field in summary) {
        if (![GCFields skipField:field]) {
            NSDictionary * info = summary[field];
            NSString * thisuom =info[@"uom"];
            if ([field isEqualToString:@"SumTrainingEffect"]) {
                thisuom = @"te";
            }else if([field isEqualToString:@"SumIntensityFactor"]){
                thisuom = @"if";
            }else if([field hasSuffix:@"HeartRate"]){
                if (info[@"bpm"]) {
                    info = info[@"bpm"];
                }
            }

            [GCFields registerField:field activityType:self.activityType displayName:info[@"fieldDisplayName"] andUnitName:thisuom];
            summaryDataTmp[field] = [GCActivitySummaryValue activitySummaryValueForDict:info andField:(NSString*)field];
        }
    }
    self.summaryData = [NSDictionary dictionaryWithDictionary:summaryDataTmp];


    NSMutableDictionary * newMetaData = [NSMutableDictionary dictionary];

    for (NSString * field in @[@"username",@"activityDescription"]) {
        NSString * info = aData[field];
        if (info) {
            newMetaData[field] = [GCActivityMetaValue activityMetaValueForDisplay:info andField:field];
        }
    }

    NSNumber * parentId = aData[@"parentId"];
    if (parentId && [parentId isKindOfClass:[NSNumber class]] && parentId.intValue != 0) {
        self.parentId = parentId.stringValue;
    }

    NSArray * childIds = aData[@"childIds"];
    if (childIds && [childIds isKindOfClass:[NSArray class]] && childIds.count > 0) {
        self.childIds = childIds;
    }


    self.downloadMethod = gcDownloadMethodDefault;
    if ([GCAppGlobal configGetBool:CONFIG_USE_NEW_TRACK_API defaultValue:true]) {
        self.downloadMethod = gcDownloadMethod13;
    }
    for (NSString * field in @[@"device",@"activityType",@"eventType"]) {
        NSDictionary * info = aData[field];
        if (info) {
            GCActivityMetaValue * val = [GCActivityMetaValue activityValueForDict:info andField:field];
            newMetaData[field] = val;
            if ([field isEqualToString:@"device"] && [val.display isEqualToString:@"Garmin Fenix"]) {
                self.downloadMethod = gcDownloadMethodDetails;
            }
        }
    }
    for (NSString * field in @[@"garminSwimAlgorithm",@"ispr",@"favorite"]) {
        NSNumber * info = aData[field];
        if (info) {
            newMetaData[field] = [GCActivityMetaValue activityMetaValueForDisplay:info.stringValue andField:field];
            if ([field isEqualToString:@"garminSwimAlgorithm"]) {
                self.garminSwimAlgorithm = info.boolValue;
                if (self.garminSwimAlgorithm) {
                    self.downloadMethod = gcDownloadMethodSwim;
                }
            }
        }
    }
    [self addEntriesToMetaData:newMetaData];

    [GCFieldsCalculated addCalculatedFields:self];
}

-(void)parseSportTracksJson:(NSDictionary*)data{
/*
 {
 "start_time" : "2014-03-31T07:18:01+01:00",
 "total_distance" : "9985.88",
 "duration" : "1828.00",
 "type" : "Cycling",
 "name" : "cycling",
 "user_id" : "16964",
 "uri" : "https://api.sporttracks.mobi/api/v2/fitnessActivities/5522409"
 }*/
    /*Type:
     Skiing
     Gym
     Skiing: Nordic
     Walking
     Walking: Hiking
     */
    NSDictionary * types = @{
                             @"Cycling":   GC_TYPE_CYCLING,
                             @"Running":    GC_TYPE_RUNNING,
                             @"Swimming":   GC_TYPE_SWIMMING
                             };
    NSDictionary * defs = @{
                            @"total_distance":      @[ @"SumDistance",          @(gcFieldFlagSumDistance),              @"meter"],
                            @"duration":            @[ @"SumDuration",          @(gcFieldFlagSumDuration),              @"second"],
                            @"elevation_gain":      @[ @"GainElevation",        @"",                                    @"meter"],
                            @"avg_speed":           @[ @"WeightedMeanSpeed",    @(gcFieldFlagWeightedMeanSpeed),        @"mps"],
                            @"max_speed":           @[ @"MaxSpeed",             @"",                                    @"mps"],
                            @"avg_heartrate":       @[ @"WeightedMeanHeartRate",@(gcFieldFlagWeightedMeanHeartRate),    @"bpm"],
                            @"max_heartrate":       @[ @"MaxHeartRate",         @"",                                    @"bpm"],
                            @"calories":            @[ @"SumEnergy",            @"",                                    @"kilocalorie"],
                            //@"clock_duration":      @[ @"SumMovingDuration",    @"",                                    @"second"],
                            //@"average_watts":       @[ @"WeightedMeanPower",    @(gcFieldFlagPower),                    @"watt"],
                            //@"kilojoules":          @[ @"SumTotalWork",         @"",                                    @"kilojoule"],
                            //@"average_temp":        @[ @"WeightedMeanAirTemperature",@"",                               @"celcius"],

                            @"avg_cadence":         @{ GC_TYPE_RUNNING: @[ @"WeightedMeanRunCadence", @"spm"],
                                                       GC_TYPE_CYCLING: @[ @"WeightedMeanBikeCadence", @"rpm"] },
                            @"max_cadence":         @{ GC_TYPE_RUNNING: @[ @"MaxRunCadence", @"spm"],
                                                       GC_TYPE_CYCLING: @[ @"MaxBikeCadence", @"rpm"] }

                            };


    self.activityType = types[data[@"type"]];
    if (self.activityType==nil) {
        self.activityType = GC_TYPE_OTHER;
        RZLog(RZLogInfo, @"Unknown SportTracks type %@", data[@"type"]);
    }
    self.activityTypeDetail = self.activityType;
    //NSString * externalId = [GCService serviceIdFromSportTracksUri:uri];

    //GCService * service = [GCService service:gcServiceSportTracks];
    self.activityName = data[@"name"];
    self.location = @"";

    NSMutableDictionary * newSummaryData = [NSMutableDictionary dictionary];
    [self parseData:data into:newSummaryData usingDefs:defs];

    [self addPaceIfNecessaryWithSummary:newSummaryData];

    self.downloadMethod = gcDownloadMethodSportTracks;
    NSString * user_id = data[@"user_id"];
    NSString * uri = data[@"uri"];

    NSDictionary * toAdd = @{
                             @"user_id": [GCActivityMetaValue activityMetaValueForDisplay:user_id andField:@"user_id"],
                             @"uri": [GCActivityMetaValue activityMetaValueForDisplay:uri andField:@"uri"],
                             };
    [self addEntriesToMetaData:toAdd];

    self.distanceDisplayUom = [GCFields predefinedUomForField:@"SumDistance" andActivityType:self.activityType];
    if (!self.distanceDisplayUom) {
        self.distanceDisplayUom = [GCFields predefinedUomForField:@"SumDistance" andActivityType:GC_TYPE_ALL];
    }
    [self mergeSummaryData:newSummaryData];
    NSString * startdate = data[@"start_time"];
    if(startdate) {
        self.date = [NSDate dateForSportTracksTimeString:startdate];
    }
    if (self.date==nil) {
        RZLog(RZLogError, @"Invalid date %@", startdate);
    }

}
-(void)parseHealthKitWorkout:(HKWorkout*)workout withSamples:(NSArray*)samples{
#ifdef GC_USE_HEALTHKIT
    switch (workout.workoutActivityType) {
        case HKWorkoutActivityTypeRunning:
            self.activityType = GC_TYPE_RUNNING;
            self.activityTypeDetail = self.activityType;
            break;
        case HKWorkoutActivityTypeCycling:
            self.activityType = GC_TYPE_CYCLING;
            self.activityTypeDetail = self.activityType;
            break;
        case HKWorkoutActivityTypeSwimming:
            self.activityType = GC_TYPE_SWIMMING;
            self.activityTypeDetail = self.activityType;
            break;
        case HKWorkoutActivityTypeTennis:
            self.activityType = GC_TYPE_TENNIS;
            self.activityTypeDetail = self.activityType;
            break;
        case HKWorkoutActivityTypeHiking:
            self.activityType = GC_TYPE_HIKING;
            self.activityTypeDetail = self.activityType;
            break;
        case HKWorkoutActivityTypeWalking:
            self.activityType = GC_TYPE_WALKING;
            self.activityTypeDetail = self.activityType;
            break;
        case HKWorkoutActivityTypeElliptical:
            self.activityType = GC_TYPE_FITNESS;
            self.activityTypeDetail = @"elliptical";
            break;
        case HKWorkoutActivityTypeTraditionalStrengthTraining:
        case HKWorkoutActivityTypeFunctionalStrengthTraining:
            self.activityType = GC_TYPE_FITNESS;
            self.activityTypeDetail = @"strengh_training";
            break;
        default:
            self.activityType = GC_TYPE_OTHER;
            self.activityTypeDetail = self.activityType;
            break;
    }
    self.date = workout.startDate;
    self.activityName = [NSString stringWithFormat:@"%@ Workout", self.activityType];
    self.location = @"";
    self.downloadMethod = gcDownloadMethodHealthKit;

    self.metaData = [NSMutableDictionary dictionaryWithObject:[GCActivityMetaValue activityMetaValueForDisplay:workout.sourceRevision.source.name
                                                                                                      andField:GC_META_DEVICE]
                                                       forKey:GC_META_DEVICE];

    NSMutableDictionary * summary = [NSMutableDictionary dictionary];

    GCActivitySummaryValue * sumVal = nil;

    self.sumDistance = [workout.totalDistance  doubleValueForUnit:[HKUnit meterUnit]];
    self.sumDuration = workout.duration;
    self.weightedMeanSpeed = self.sumDistance/self.sumDuration;

    sumVal = [self buildSummaryValue:@"SumDistance" uom:@"meter" fieldFlag:gcFieldFlagSumDistance andValue:self.sumDistance];
    summary[sumVal.field] = sumVal;
    sumVal = [self buildSummaryValue:@"SumDuration" uom:@"second" fieldFlag:gcFieldFlagSumDuration andValue:self.sumDuration];
    summary[sumVal.field] = sumVal;
    sumVal = [self buildSummaryValue:@"WeightedMeanSpeed" uom:@"mps" fieldFlag:gcFieldFlagWeightedMeanSpeed andValue:self.weightedMeanSpeed];
    summary[sumVal.field] = sumVal;
    double sumEnergy = [workout.totalEnergyBurned doubleValueForUnit:[HKUnit kilocalorieUnit]];
    if (sumEnergy != 0.) {
        sumVal = [self buildSummaryValue:@"SumEnergy" uom:@"kilocalorie" fieldFlag:gcFieldFlagNone andValue:sumEnergy];
        summary[sumVal.field] = sumVal;
    }
    [self addPaceIfNecessaryWithSummary:summary];
    self.summaryData = summary;

    self.distanceDisplayUom = [GCFields predefinedUomForField:@"SumDistance" andActivityType:self.activityType];
    if (!self.distanceDisplayUom) {
        self.distanceDisplayUom = [GCFields predefinedUomForField:@"SumDistance" andActivityType:GC_TYPE_ALL];
    }

    GCHealthKitSamplesToPointsParser * parser = [GCHealthKitSamplesToPointsParser parserForSamples:samples forActivityType:self.activityType andSource:workout.sourceRevision];
    self.trackFlags = parser.trackFlags;

    NSMutableArray * points = [NSMutableArray arrayWithArray:[parser.points sortedArrayUsingSelector:@selector(compareTime:)]];

    [self updateSummaryFromTrackpoints:points missingOnly:YES];
    [self saveTrackpoints:points andLaps:nil];

#endif
}

-(void)parseHealthKitSummaryData:(NSDictionary*)data{

    NSString * aType = data[@"activityType"];
    if (aType && [aType isKindOfClass:[NSString class]]) {
        // We need a type to process fields
        self.activityType = aType;
        self.downloadMethod = gcDownloadMethodHealthKit;
        self.activityName = @"";
        self.location = @"";
        self.speedDisplayUom = [[GCUnit unitForKey:@"minperkm"] unitForGlobalSystem].key;
        self.distanceDisplayUom = [[GCUnit unitForKey:@"kilometer"] unitForGlobalSystem].key;

        NSMutableDictionary * sumData = [NSMutableDictionary dictionary];
        for (NSString * field in data) {
            id obj = data[field];
            NSString * str = nil;
            GCNumberWithUnit * nu = nil;
            NSDate * da = nil;

            if ([obj isKindOfClass:[NSString class]]) {
                str = obj;
            }else if([obj isKindOfClass:[GCNumberWithUnit class]]){
                nu = obj;
            }else if ([obj isKindOfClass:[NSDate class]]){
                da = obj;
            }

            if ([field isEqualToString:@"activityType"] && str) {
                self.activityTypeDetail = str;
            }else if ([field isEqualToString:@"BeginTimestamp"] && da){
                self.date = da;
            }else if (nu) {
                gcFieldFlag flag = [GCFields trackFieldFromActivityField:field];
                if (flag != gcFieldFlagNone) {
                    [self setSummaryField:flag with:nu];
                }
                GCActivitySummaryValue * val = [self buildSummaryValue:field
                                                                   uom:nu.unit.key
                                                             fieldFlag:flag
                                                              andValue:nu.value];
                sumData[field] = val;
            }
        }
        self.summaryData = sumData;
        [self updateSummaryFieldFromSummaryData];
    }
}


-(void)parseStravaJson:(NSDictionary*)data{
    NSDictionary * defs = @{
                            @"distance":            @[ @"SumDistance",          @(gcFieldFlagSumDistance),              @"meter"],
                            @"moving_time":         @[ @"SumMovingDuration",    @"",                                    @"second"],
                            @"elapsed_time":        @[ @"SumDuration",          @(gcFieldFlagSumDuration),              @"second"],
                            @"total_elevation_gain":@[ @"GainElevation",        @"",                                    @"meter"],
                            @"average_speed":       @[ @"WeightedMeanSpeed",    @(gcFieldFlagWeightedMeanSpeed),        @"mps"],
                            @"max_speed":           @[ @"MaxSpeed",             @"",                                    @"mps"],
                            @"average_watts":       @[ @"WeightedMeanPower",    @(gcFieldFlagPower),                    @"watt"],
                            @"kilojoules":          @[ @"SumTotalWork",         @"",                                    @"kilojoule"],
                            @"average_heartrate":   @[ @"WeightedMeanHeartRate",@(gcFieldFlagWeightedMeanHeartRate),    @"bpm"],
                            @"max_heartrate":       @[ @"MaxHeartRate",         @"",                                    @"bpm"],
                            @"calories":            @[ @"SumEnergy",            @"",                                    @"kilocalorie"],
                            @"average_temp":        @[ @"WeightedMeanAirTemperature",@"",                               @"celcius"],

                            //@"start_date":          @[ @"BeginTimeStamp",       @"",                                    @"time"],
                            //@"start_latlng":        @[ @[@"BeginLatitude",@"BeginLongitude"],@"vector", @"dd"],
                            //@"end_latlng":          @[ @[@"EndLatitude",  @"EndLongitude"],  @"vector", @"dd"],

                            @"average_cadence":     @{ GC_TYPE_RUNNING: @[ @"WeightedMeanRunCadence", @"stepsPerMinute"],
                                                       GC_TYPE_CYCLING: @[ @"WeightedMeanBikeCadence", @"rpm"] }

                            };

    NSDictionary * types = @{
                             @"Ride":   GC_TYPE_CYCLING,
                             @"Run":    GC_TYPE_RUNNING,
                             @"Swim":   GC_TYPE_SWIMMING,
                             @"Hike":   GC_TYPE_HIKING,
                             @"Walk":   GC_TYPE_WALKING,
                             @"Workout":GC_TYPE_FITNESS,
                             @"VirtualRide":GC_TYPE_CYCLING

                             //From Strava API
                             //@"Ride",
                             //@"Kitesurf",
                             //@"Run",
                             //@"NordicSki",
                             //@"Swim",
                             //@"RockClimbing",
                             //@"Hike",
                             //@"RollerSki",
                             //@"Walk",
                             //@"Rowing",
                             //@"AlpineSki",
                             //@"Snowboard",
                             //@"BackcountrySki",
                             //@"Snowshoe",
                             //@"Canoeing",
                             //@"StairStepper",
                             //@"Crossfit",
                             //@"StandUpPaddling",
                             //@"EBikeRide",
                             //@"Surfing",
                             //@"Elliptical",
                             //@"VirtualRide",
                             //@"IceSkate",
                             //@"WeightTraining",
                             //@"InlineSkate",
                             //@"Windsurf",
                             //@"Kayaking",
                             //@"Workout",
                             //@"Yoga",

                             };
    GCService * service = [GCService service:gcServiceStrava];

    self.activityId = [service activityIdFromServiceId:[data[@"id"] stringValue]];
    self.activityType = types[data[@"type"]];
    self.activityName = data[@"name"];
    self.location = @"";
    if (self.activityType == nil) {
        self.activityType = GC_TYPE_OTHER;
        NSDictionary * subtypes= @{
                                   @"NordicSki":@"cross_country_skiing",
                                   @"AlpineSki":@"resort_skiing_snowboarding",
                                   @"BackcountrySki": @"backcountry_skiing_snowboarding",
                                   //IceSkate
                                   //InlineSkate
                                   //Kitesurf
                                   //RollerSki
                                   //Windsurf
                                   //Snowboard
                                   //Snowshoe
                                   };
        self.activityTypeDetail = subtypes[data[@"type"]];
        if (self.activityTypeDetail==nil) {
            self.activityTypeDetail = GC_TYPE_OTHER;
        }
    }
    self.activityTypeDetail = self.activityType;
    self.downloadMethod = gcDownloadMethodStrava;
    if (self.metaData==nil) {
        self.metaData = [NSMutableDictionary dictionary];
    }
    if (self.activityId && self.activityType) {
        NSMutableDictionary * newSummaryData = [NSMutableDictionary dictionaryWithCapacity:data.count];
        [self parseData:data into:newSummaryData usingDefs:defs];

        self.distanceDisplayUom = [GCFields predefinedUomForField:@"SumDistance" andActivityType:self.activityType];
        if (!self.distanceDisplayUom) {
            self.distanceDisplayUom = [GCFields predefinedUomForField:@"SumDistance" andActivityType:GC_TYPE_ALL];
        }
        // few extra derived
        [self addPaceIfNecessaryWithSummary:newSummaryData];
        [self mergeSummaryData:newSummaryData];

        NSArray * latlong = data[@"start_latlng"];
        if ([latlong isKindOfClass:[NSArray class]] && latlong.count == 2) {
            self.beginCoordinate = CLLocationCoordinate2DMake([latlong[0] doubleValue], [latlong[1] doubleValue]);
        }
        NSString * startdate = data[@"start_date"];
        if(startdate) {
            self.date = [NSDate dateForStravaTimeString:startdate];
            if (!self.date) {
                RZLog(RZLogError, @"%@: Invalid date %@", self.activityId, startdate);
            }
        }else{
            RZLog(RZLogError, @"%@: Invalid date %@", self.activityId, startdate);
        }
        NSString * externalId = data[@"external_id"];
        if([externalId isKindOfClass:[NSString class]] && [externalId hasPrefix:@"garmin_push_"]){
            NSString * garminId = [externalId substringFromIndex:[@"garmin_push_" length]];
            self.externalServiceActivityId = [[GCService service:gcServiceGarmin] activityIdFromServiceId:garminId];
        }
    }
}

#pragma mark -

-(void)updateWithGarminData:(NSDictionary*)data{

    [self parseGarminJson:data];

}

-(BOOL)updateTrackpointsFromActivity:(GCActivity*)other{
    BOOL rv = false;
    
    if( ! self.trackpointsReadyNoLoad && other.trackpointsReadyNoLoad){
        // Special case: other has trackpoint self doesnt, just use
        self.trackpoints = other.trackpoints;
        self.cachedExtraTracksIndexes = other.cachedExtraTracksIndexes;
        rv = true;
    }else if( self.trackpointsReadyNoLoad && other.trackpointsReadyNoLoad ){
        // Only bother if both have trackpoint
        NSArray<GCTrackPoint*> * trackpoints = self.trackpoints;
        NSArray<GCTrackPoint*> * otherTrackpoints = other.trackpoints;
        
        if( trackpoints.count > 0 &&
           otherTrackpoints.count > 0 &&
           [trackpoints[0] isMemberOfClass:[GCTrackPoint class]] &&
           [otherTrackpoints[0] isMemberOfClass:[GCTrackPoint class]]){
            // Don't handle swim points
            
            NSMutableArray<GCField*>*fields = [NSMutableArray array];
            NSArray<GCField*>*otherFields = other.availableTrackFields;
            
            for (GCField * otherField in otherFields) {
                if( ! [self hasTrackForField:otherField]){
                    [fields addObject:otherField];
                    rv = true;
                }
            }
            if( rv ){
                NSUInteger otherIndex = 0;
                
                GCTrackPoint * last = otherTrackpoints[otherIndex];
                
                for (GCTrackPoint * one in trackpoints) {
                    while( last && [last timeIntervalSince:one] < 0.0){
                        otherIndex++;
                        if (otherIndex < otherTrackpoints.count) {
                            last = otherTrackpoints[otherIndex];
                        }else{
                            last = nil;
                        }
                    }
                    if( last ){
                        [one updateInActivity:self fromTrackpoint:last fromActivity:other forFields:fields];
                        self.trackFlags |= one.trackFlags;
                    }
                }
            }
        }
    }
    return rv;
}

-(BOOL)updateSummaryDataFromActivity:(GCActivity*)other{
    BOOL rv = false;
    
    if (self.metaData) {
        NSMutableDictionary * newMetaData = nil;
        for (NSString * field in self.metaData) {
            GCActivityMetaValue * thisVal  = (self.metaData)[field];
            GCActivityMetaValue * otherVal = (other.metaData)[field];
            if (otherVal && ! [otherVal isEqualToValue:thisVal]) {
                if (!newMetaData) {
                    newMetaData = [NSMutableDictionary dictionaryWithDictionary:self.metaData];
                }
                RZLog(RZLogInfo, @"%@ changed %@", self, field);
                [newMetaData setValue:otherVal forKey:field];
                FMDatabase * db = self.db;
                [db beginTransaction];
                [otherVal updateDb:db forActivityId:self.activityId];
                [db commit];
                rv = true;
            }
        }
        if (newMetaData) {
            self.metaData = newMetaData;
        }
    }
    
    if (self.summaryData) {
        NSMutableDictionary<GCField*,GCActivitySummaryValue*> * newSummaryData = nil;
        for (GCField * field in self.summaryData) {
            GCActivitySummaryValue * thisVal = self.summaryData[field];
            GCActivitySummaryValue * otherVal = other.summaryData[field];
            if (otherVal && ! [otherVal isEqualToValue:thisVal]) {
                if (!newSummaryData) {
                    newSummaryData = [NSMutableDictionary dictionaryWithDictionary:self.summaryData];
                }
                RZLog(RZLogInfo, @"%@ changed %@ %@ -> %@", self, field, thisVal.numberWithUnit, otherVal.numberWithUnit);
                newSummaryData[field] = otherVal;
                
                FMDatabase * db = self.db;
                [db beginTransaction];
                [otherVal updateDb:db forActivityId:self.activityId];
                [db commit];
                rv = true;
            }
        }
        for (GCField * field in other.summaryData) {
            if (self.summaryData[field]==nil) {
                if (!newSummaryData) {
                    newSummaryData = [NSMutableDictionary dictionaryWithDictionary:self.summaryData];
                }
                GCActivitySummaryValue * otherVal = other.summaryData[field];
                
                RZLog(RZLogInfo, @"%@ new data %@ -> %@", self, field, otherVal.numberWithUnit);
                newSummaryData[field] = otherVal;
            }
        }
        if (newSummaryData) {
            self.summaryData = newSummaryData;
        }
    }
    
    if (fabs(self.sumDistance - other.sumDistance) > 1.e-8) {
        self.sumDistance = other.sumDistance;
        rv = true;
        
        FMDatabase * db = self.db;
        [db beginTransaction];
        [db executeUpdate:@"UPDATE gc_activities SET sumDistance=? WHERE activityId = ?", @(self.sumDistance), self.activityId];
        [db commit];
        
    }
    if (fabs(self.sumDuration - other.sumDuration) > 1.e-8) {
        self.sumDuration = other.sumDuration;
        rv = true;
        FMDatabase * db = self.db;
        [db beginTransaction];
        [db executeUpdate:@"UPDATE gc_activities SET sumDuration=? WHERE activityId = ?", @(self.sumDuration), self.activityId];
        [db commit];
        
    }
    if( other.speedDisplayUom && ( ![self.speedDisplayUom isEqualToString:other.speedDisplayUom]) ){
        self.speedDisplayUom = other.speedDisplayUom;
        rv = true;
        FMDatabase * db = self.db;
        [db beginTransaction];
        [db executeUpdate:@"UPDATE gc_activities SET speedDisplayUom=? WHERE activityId = ?", self.speedDisplayUom, self.activityId];
        [db commit];
    }
    if(fabs(self.weightedMeanSpeed-other.weightedMeanSpeed) > 1.e-8){
        self.weightedMeanSpeed = other.weightedMeanSpeed;
        rv = true;
        FMDatabase * db = self.db;
        [db beginTransaction];
        [db executeUpdate:@"UPDATE gc_activities SET WeightedMeanSpeed=? WHERE activityId = ?", @(self.weightedMeanSpeed), self.activityId];
        [db commit];
    }

    return rv;
}

-(BOOL)updateWithActivity:(GCActivity*)other{

    BOOL rv = false;

    NSString * aType = other.activityType;
    if (![aType isEqualToString:self.activityType]) {
        RZLog(RZLogInfo, @"change activity type %@ -> %@", self.activityType,aType);
        rv = true;
        self.activityType = aType;
        FMDatabase * db = self.db;
        [db beginTransaction];
        [db executeUpdate:@"UPDATE gc_activities SET activityType=? WHERE activityId = ?", self.activityType, self.activityId];
        [db commit];
    }

    if (self.activityTypeDetail!=nil && ![other.activityTypeDetail isEqualToString:self.activityTypeDetail]) {
        // Don't update db because activityTypeDetail comes from meta field which
        // Should be updated later, but still need to process here, or some icons
        // may not update properly until restart/reload from db otherwise
        self.activityTypeDetail = other.activityTypeDetail;
        rv = true;
    }

    NSString * aName = other.activityName;
    if (![aName isEqualToString:self.activityName]) {
        RZLog(RZLogInfo, @"change activity name");
        rv = true;
        self.activityName = aName;
        FMDatabase * db = self.db;
        [db beginTransaction];
        [db executeUpdate:@"UPDATE gc_activities SET activityName=? WHERE activityId = ?", self.activityName, self.activityId];
        [db commit];
    }

    if( [self updateSummaryDataFromActivity:other] ){
        rv = true;
    }
    
    if( [self updateTrackpointsFromActivity:other] ){
        rv = true;
    }
    return rv;
}

-(void)updateSummaryFromTrackpoints:(NSArray<GCTrackPoint*>*)trackpoints missingOnly:(BOOL)missingOnly{
    NSDictionary<GCField*,GCActivitySummaryValue*> * fromPoints = [self buildSummaryFromTrackpoints:trackpoints];
    
    NSMutableDictionary<GCField*,GCActivitySummaryValue*>* newSum = [NSMutableDictionary dictionaryWithDictionary:self.summaryData];
    
    for (GCField * field in fromPoints) {
        if( !missingOnly || newSum[field] == nil){
            newSum[field] = fromPoints[field];
        }
    }
    
    self.summaryData = newSum;
}

-(NSDictionary<GCField*,GCActivitySummaryValue*>*)buildSummaryFromTrackpoints:(NSArray<GCTrackPoint*>*)trackpoints{

    NSMutableDictionary<GCField*,GCNumberWithUnit*> * results = [NSMutableDictionary dictionary];
    
    NSArray<GCField*>*fields = self.availableTrackFields;
    
    double totalElapsed = 0.0;
    GCTrackPoint * point = nil;
    for (GCTrackPoint * next in trackpoints) {
        if (point) {
            NSTimeInterval elapsed = [next timeIntervalSince:point];
            totalElapsed += elapsed;
            for (GCField * field in fields) {

                GCNumberWithUnit * num = [point numberWithUnitForField:field inActivity:self];

                GCNumberWithUnit * current = results[field];

                if (!current) {
                    current = num;
                }else{
                    current.value *= (totalElapsed-elapsed)/totalElapsed;
                    current = [current addNumberWithUnit:num weight:elapsed/totalElapsed];
                }
                if( current ){
                    results[field] = current;
                    if( field.isWeightedAverage){
                        for (GCField * secondary in @[ field.correspondingMaxField, field.correspondingMinField ]) {
                            GCNumberWithUnit * secondaryCurrent = results[secondary];
                            if( ! secondaryCurrent ){
                                secondaryCurrent = num;
                            }else{
                                if( secondary.isMax ){
                                    secondaryCurrent = [secondaryCurrent maxNumberWithUnit:num];
                                }else if ( secondary.isMin ){
                                    secondaryCurrent = [secondaryCurrent nonZeroMinNumberWithUnit:num];
                                }
                            }
                            if (secondaryCurrent) {
                                results[secondary] = secondaryCurrent;
                            }
                        }
                    }
                }
            }
        }
        point = next;
    }
    NSMutableDictionary<GCField*,GCActivitySummaryValue*> * newSum = [NSMutableDictionary dictionaryWithDictionary:self.summaryData];
    
    for (GCField *field in results) {
        GCNumberWithUnit * num = results[field];
        GCActivitySummaryValue * val = [self buildSummaryValue:field.key uom:num.unit.key fieldFlag:field.fieldFlag andValue:num.value];
        newSum[field] = val;
    }
    [self addPaceIfNecessaryWithSummary:newSum];
    
    return newSum;
}

#pragma mark -

-(BOOL)isEqualToActivity:(GCActivity*)other{

    NSString * aType = other.activityType;
    if (![aType isEqualToString:self.activityType]) {
        return false;
    }
    if (![other.activityName isEqualToString:self.activityName]) {
        return false;
    }
    if (fabs([other.date timeIntervalSinceDate:self.date])>=1.e-5) {
        return false;
    }
    NSArray * fields = self.availableTrackFields;
    NSArray * otherFields = other.availableTrackFields;

    if (fields.count != otherFields.count) {
        return false;
    }
    for (GCField * one in fields) {
        GCNumberWithUnit * nu1 = [self numberWithUnitForField:one];
        GCNumberWithUnit * nu2 = [self numberWithUnitForField:one];
        if (nu1 == nil || nu2 == nil) {
            return false;
        }
        if ([nu1 compare:nu2 withTolerance:1.e-8]!=NSOrderedSame ){
            return false;
        }
    }
    if (fabs(self.sumDuration - other.sumDuration) > 1.e-8 || fabs(self.sumDistance-other.sumDistance)> 1.e-8) {
        return false;
    }
    if (self.metaData) {
        for (NSString * field in self.metaData) {
            GCActivityMetaValue * thisVal  = (self.metaData)[field];
            GCActivityMetaValue * otherVal = (other.metaData)[field];
            if (otherVal && ! [otherVal isEqualToValue:thisVal]) {
                return false;
            }
        }
    }else if(other.metaData){
        return false;
    }
    if (self.summaryData) {
        for (GCField * field in self.summaryData) {
            GCActivitySummaryValue * thisVal = self.summaryData[field];
            GCActivitySummaryValue * otherVal = other.summaryData[field];
            if (otherVal && ! [otherVal isEqualToValue:thisVal]) {
                return false;
            }
        }
    }else if (other.summaryData){
        return false;
    }

    return true;

}

-(BOOL)testForDuplicate:(GCActivity*)other{
    if (fabs([other.date timeIntervalSinceDate:self.date])<1. && [self.activityType isEqualToString:other.activityType]) {
        return true;
    }

    // check if from same system (strava/garmin)
    if( (self.externalServiceActivityId && ([self.externalServiceActivityId isEqualToString:other.activityId]))||
       (other.externalServiceActivityId && ([other.externalServiceActivityId isEqualToString:self.activityId]))){
        return true;
    }

    return false;
}



@end
