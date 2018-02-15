//  MIT Licence
//
//  Created on 23/01/2016.
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

#import "GCActivity+Fields.h"
#import "GCActivitySummaryValue.h"
#import "GCActivityOrganizedFields.h"

@implementation GCActivity (Fields)


-(GCNumberWithUnit*)numberWithUnitForFieldKey:(NSString*)fieldKey{
    return [self numberWithUnitForField:[GCField field:fieldKey forActivityType:self.activityType]];
}

-(GCNumberWithUnit*)numberWithUnitForFieldFlag:(gcFieldFlag)fieldFlag{
    return [self numberWithUnitForField:[GCField fieldForFlag:fieldFlag andActivityType:self.activityType]];
}

-(GCNumberWithUnit*)summaryFieldNumberWithUnit:(gcFieldFlag)which{
    return [self numberWithUnitForField:[GCField fieldForFlag:which andActivityType:self.activityType]];
}

#pragma mark - Grouped Fields

-(NSArray<GCField*>*)displayPrimaryFieldsOrdered{
    static NSDictionary<NSString*,NSArray<GCField*>*>* cache = nil;
    if (cache == nil) {
        NSDictionary * baseDict = @{
                  GC_TYPE_RUNNING:@[
                          @"SumDistance",
                          @"SumDuration",
                          @"WeightedMeanHeartRate",
                          @"WeightedMeanPace",
                          @"WeightedMeanSpeed",
                          @"WeightedMeanStrokes",
                          @"WeightedMeanSwolf",
                          @"WeightedMeanPower",
                          @"WeightedMeanFormPower",
                          @"SumIntensityFactor",
                          @"WeightedMeanRunCadence",
                          @"WeightedMeanSwimCadence",
                          @"WeightedMeanBikeCadence",
                          @"WeightedMeanVerticalOscillation",
                          @"SumEnergy",
                          @"DirectVO2Max",
                          @"WeightedMeanVerticalRatio",
                          @"WeightedMeanAirTemperature",
                          ],
                  GC_TYPE_CYCLING:@[
                          @"SumDistance",
                          @"SumDuration",
                          @"WeightedMeanHeartRate",
                          @"WeightedMeanSpeed",
                          @"WeightedMeanStrokes",
                          @"WeightedMeanSwolf",
                          @"WeightedMeanPower",
                          @"WeightedMeanNormalizedPower",
                          @"SumIntensityFactor",
                          @"WeightedMeanBikeCadence",
                          @"SumEnergy",
                          @"WeightedMeanAirTemperature",
                          ],
                  GC_TYPE_SWIMMING:@[
                          @"SumDistance",
                          @"SumDuration",
                          @"WeightedMeanHeartRate",
                          @"WeightedMeanPace",
                          @"WeightedMeanSpeed",
                          @"WeightedMeanStrokes",
                          @"WeightedMeanSwolf",
                          @"WeightedMeanPower",
                          @"WeightedMeanNormalizedPower",
                          @"SumIntensityFactor",
                          @"WeightedMeanSwimCadence",
                          @"SumEnergy",
                          @"WeightedMeanAirTemperature",
                          ],
                  GC_TYPE_DAY:@[
                          @"SumDistance",
                          @"SumDuration",
                          @"SumStep",
                          @"SumFloorClimbed",
                          @"SumEnergy",
                          @"WeightedMeanHeartRate",
                          ],
                  GC_TYPE_SKI_BACK:@[
                          @"SumDistance",
                          @"SumDuration",
                          @"WeightedMeanHeartRate",
                          @"WeightedMeanPace",
                          @"SumIntensityFactor",
                          CALC_ASCENT_SPEED,
                          @"WeightedMeanVerticalOscillation",
                          @"SumEnergy",
                          @"WeightedMeanAirTemperature",
                          ],
                  GC_TYPE_SKI_DOWN:@[
                          @"SumDistance",
                          @"SumDuration",
                          @"WeightedMeanHeartRate",
                          @"WeightedMeanSpeed",
                          @"SumIntensityFactor",
                          CALC_DESCENT_SPEED,
                          @"WeightedMeanVerticalOscillation",
                          @"SumEnergy",
                          @"WeightedMeanAirTemperature",
                          ],
                  GC_TYPE_INDOOR_ROWING:@[
                          @"SumDistance",
                          @"SumDuration",
                          @"WeightedMeanHeartRate",
                          @"WeightedMeanPace",
                          @"WeightedMeanSpeed",
                          @"WeightedMeanStrokes",
                          @"WeightedMeanStrokeCadence",
                          @"SumIntensityFactor",
                          @"SumEnergy",
                          @"WeightedMeanAirTemperature",

                          ],

                  GC_TYPE_OTHER:@[
                          @"SumDistance",
                          @"SumDuration",
                          @"WeightedMeanHeartRate",
                          @"WeightedMeanPace",
                          @"WeightedMeanSpeed",
                          @"WeightedMeanStrokes",
                          @"WeightedMeanSwolf",
                          @"WeightedMeanPower",
                          @"WeightedMeanNormalizedPower",
                          @"SumIntensityFactor",
                          CALC_VERTICAL_SPEED,
                          @"WeightedMeanRunCadence",
                          @"WeightedMeanSwimCadence",
                          @"WeightedMeanBikeCadence",
                          @"WeightedMeanVerticalOscillation",
                          @"SumEnergy",
                          @"WeightedMeanAirTemperature",
                          @"shots"

                          ]
                  };
        NSMutableDictionary * mutCache = [NSMutableDictionary dictionary];
        for (NSString * aType in baseDict) {
            NSArray<NSString*> * fieldKeys = baseDict[aType];
            NSMutableArray<GCField*> * fields = [NSMutableArray arrayWithCapacity:fieldKeys.count];
            for (NSString * fieldKey in fieldKeys) {
                [fields addObject:[GCField fieldForKey:fieldKey andActivityType:aType]];
            }
            mutCache[aType] = fields;
        }
        cache = [NSDictionary dictionaryWithDictionary:mutCache];
        [cache retain];
    }
    NSArray * rv = nil;
    if (self.activityTypeDetail) {
        rv = cache[self.activityTypeDetail];
    }
    if (!rv) {
        rv = cache[self.activityType];
    }
    if (!rv) {
        rv = cache[GC_TYPE_OTHER];
    }

    return rv;
}


-(GCActivityOrganizedFields*)groupedFields{
    NSArray<GCField*> * primary = [self displayPrimaryFieldsOrdered];

    NSMutableDictionary<GCField*,id> * found = [NSMutableDictionary dictionary];
    NSMutableDictionary<GCField*,id> * allUsed = [NSMutableDictionary dictionary];

    GCNumberWithUnit * nu = nil;
    for (GCField * field in primary) {
        NSArray<GCField*> * related = field.relatedFields;

        NSMutableArray<GCField*> * existingRelated = [NSMutableArray array];
        nu = [self numberWithUnitForField:field];
        if (nu) {
            [existingRelated addObject:field];
            found[field] = existingRelated;
            allUsed[field] = @1;

            for (GCField * subfield in related) {
                nu = [self numberWithUnitForField:subfield];
                if (nu) {
                    [existingRelated addObject:subfield];
                    allUsed[subfield] = @1;
                }
            }
        }
    }

    NSMutableArray<NSArray<GCField*>*> * groupedPrimary = [NSMutableArray array];
    for (GCField * field in primary) {
        NSArray<GCField*> * group = found[field];
        if (group) {
            [groupedPrimary addObject:group];
        }
    }

    GCActivityOrganizedFields * rv = [[[GCActivityOrganizedFields alloc] init] autorelease];
    rv.groupedPrimaryFields = groupedPrimary;

    NSMutableDictionary<GCField*,NSArray<GCField*>*> * others = [NSMutableDictionary dictionary];

    for (GCField * field in self.summaryData) {
        if (!allUsed[field]) {
            others[field] = field.relatedFields;
        }
    }

    NSMutableArray<NSArray<GCField*>*> * groupedOther = [NSMutableArray array];
    NSArray<GCField*> * allOthers = [others allKeys];

    static NSMutableDictionary<NSString*,NSNumber*> * _reportedOthers = nil;
    if (_reportedOthers==nil) {
        _reportedOthers = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                          @"WeightedMeanStrideLength":@1,
                                                                          @"MaxDoubleCadence":@1,
                                                                          @"MinCorrectedElevation":@1,
                                                                          @"MaxUncorrectedElevation":@1,
                                                                          @"MinElevation":@1,
                                                                          @"MaxCorrectedElevation":@1,
                                                                          @"WeightedMeanVerticalRatio":@1,
                                                                          @"MinRunCadence":@1,
                                                                          @"WeightedMeanGroundContactBalanceLeft":@1,
                                                                          @"MinUncorrectedElevation":@1,
                                                                          @"WeightedMeanDoubleCadence":@1,
                                                                          @"MaxFractionalCadence":@1,
                                                                          @"WeightedMeanFractionalCadence":@1,

                                                                          }];
        [_reportedOthers retain];
    }

    for (GCField * one in allOthers) {
        if (_reportedOthers[one.key]==nil) {
            _reportedOthers[one.key] = @1;
            // This means the fields that were not organized in displayPrimaryFieldsOrdered
            // or that was not a related field of one of the displayPrimaryFieldsOrdered fields.
            // What needs to be excluded can be added explicitely in the _reportedOthres dictionary cache
            // Or it needs to be added to displayPrimaryFieldsOrdered
            RZLog(RZLogInfo, @"Other Summary Field: %@ %@", one, self.activityType);
        }
        NSArray<GCField*> * related = others[one];
        if (related.count > 0) {
            NSMutableArray * oneRelated = [NSMutableArray array];
            for (GCField * done in related) {
                if (others[done]) {
                    others[done] = @[];
                    [oneRelated addObject:done];
                }
            }
            if (oneRelated.count>0) {
                [groupedOther addObject:oneRelated];
            }
        }
    }
    rv.groupedOtherFields = groupedOther;
    return rv;
}

@end
