//  MIT Licence
//
//  Created on 06/04/2013.
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

#import "GCActivityAutoLapChoices.h"
#import "GCViewConfig.h"
#import "GCHealthZoneCalculator.h"
#import "GCActivity+CachedTracks.h"
#import "GCAppGlobal.h"
#import "Flurry.h"
#import "GCActivity+Fields.h"

@interface GCActivityAutoLapChoiceHolder ()
@property (nonatomic,retain) NSString * lapDescription;

@end

@implementation GCActivityAutoLapChoiceHolder

+(GCActivityAutoLapChoiceHolder*)choiceForZoneCalculator:(GCHealthZoneCalculator*)zoneCalc andLabel:(NSString*)label{
    GCActivityAutoLapChoiceHolder * rv = [[[GCActivityAutoLapChoiceHolder alloc] init] autorelease];
    if (rv) {
        rv.key = [GCHealthZoneCalculator keyForField:zoneCalc.field andSource:zoneCalc.source];
        rv.lapDescription = label;
        rv.style = gcAutoLapStyleZone;
        rv.zoneCalc = zoneCalc;
    }
    return rv;
}

+(GCActivityAutoLapChoiceHolder*)choiceForIndexSerie:(GCStatsDataSerieWithUnit*)serie andLabel:(NSString*)label{
    GCActivityAutoLapChoiceHolder * rv = [[[GCActivityAutoLapChoiceHolder alloc] init] autorelease];
    if (rv) {
        rv.key = label;
        rv.lapDescription = [NSString stringWithFormat:NSLocalizedString(@"Best Rolling %@", @"Autolap Choice"), label];
        rv.style = gcAutoLapStyleIndexSerie;
        rv.indexSerie = serie;
    }
    return rv;

}
+(GCActivityAutoLapChoiceHolder*)choiceHolder:(GCActivityMatchLapBlock)match value:(double)value andLabel:(NSString*)label{
    GCActivityAutoLapChoiceHolder * rv = [[[GCActivityAutoLapChoiceHolder alloc] init] autorelease];
    if (rv) {
        rv.key = label;
        rv.value = value;
        rv.match = match;
        rv.compare = nil;
        rv.lapDescription = label;
        rv.style = gcAutoLapStyleMatching;
    }
    return rv;

}

+(GCActivityAutoLapChoiceHolder*)choiceHolder:(GCActivityMatchLapBlock)match compare:(GCActivityCompareLapBlock)comp value:(double)value andLabel:(NSString*)label{
    GCActivityAutoLapChoiceHolder * rv = [[[GCActivityAutoLapChoiceHolder alloc] init] autorelease];
    if (rv) {
        rv.key = label;
        rv.value = value;
        rv.match = match;
        rv.compare = comp;
        rv.lapDescription = label;
        rv.style = gcAutoLapStyleRolling;
    }
    return rv;
}

+(GCActivityAutoLapChoiceHolder*)choiceHolderSki{
    GCActivityAutoLapChoiceHolder * rv = [[[GCActivityAutoLapChoiceHolder alloc] init] autorelease];
    if (rv) {
        rv.key = @"skilaps";
        rv.lapDescription = NSLocalizedString(@"Ski Laps", @"Autolap Choice");
        rv.style = gcAutoLapStyleSki;
    }
    return rv;

}

-(void)dealloc{
    [_key release];
    [_lapDescription release];
    [_zoneCalc release];
    [_indexSerie release];

    [super dealloc];
}

-(NSArray*)laps:(GCActivity*)activity{
    NSArray * rv = nil;
    switch (self.style) {
        case gcAutoLapStyleMatching:
            rv = [activity calculatedLapFor:self.value match:self.match inLap:GC_ALL_LAPS];
            break;
        case gcAutoLapStyleRolling:
            rv = [activity calculatedRollingLapFor:self.value match:self.match compare:self.compare];
            break;
        case gcAutoLapStyleSki:
            rv = [activity calculateSkiLaps];
            break;
        case gcAutoLapStyleZone:
            rv = [activity compoundLapForZoneCalculator:self.zoneCalc];
            break;
        case gcAutoLapStyleIndexSerie:
            rv = [activity compoundLapForIndexSerie:self.indexSerie desc:self.key];
            break;
    }
    return rv;
}
@end


@implementation GCActivityAutoLapChoices
-(instancetype)init{
    return [super init];
}
-(void)dealloc{
    [_activity release];
    [_choices release];

    [super dealloc];
}

-(GCActivityAutoLapChoices*)initWithActivity:(GCActivity*)act{
    self = [super init];
    if (self) {
        [self changeActivity:act];
    }
    return self;
}

-(void)changeActivity:(GCActivity*)act{
    if (act!=self.activity) {
        self.activity = act;
        GCUnit *  store = [GCUnit unitForKey:STOREUNIT_DISTANCE];

        GCUnit * unit  = [[GCUnit unitForKey:act.distanceDisplayUom] unitForGlobalSystem];
        GCUnit * mile = [GCUnit unitForKey:@"mile"];
        GCUnit * km   = [GCUnit unitForKey:@"kilometer"];
        GCUnit * other = [unit isEqualToUnit:km] ? mile : km;
        GCUnit * small = [[GCUnit unitForKey:@"meter"] unitForGlobalSystem];
        GCUnit * second = [GCUnit unitForKey:@"second"];
        GCUnit * minute = [GCUnit unitForKey:@"minute"];
        GCUnit * hour = [GCUnit unitForKey:@"hour"];

        NSArray * dist = @[ [GCNumberWithUnit numberWithUnit:store andValue:[unit convertDouble:50. toUnit:store]],
                            [GCNumberWithUnit numberWithUnit:store andValue:[unit convertDouble:10. toUnit:store]],
                            [GCNumberWithUnit numberWithUnit:store andValue:[unit convertDouble:5.  toUnit:store]],
                            [GCNumberWithUnit numberWithUnit:store andValue:[unit convertDouble:3.  toUnit:store]],
                            [GCNumberWithUnit numberWithUnit:store andValue:[unit convertDouble:1.  toUnit:store]],
                            [GCNumberWithUnit numberWithUnit:store andValue:[other convertDouble:1.  toUnit:store]],
                            [GCNumberWithUnit numberWithUnit:store andValue:[small convertDouble:400.  toUnit:store]],
                            [GCNumberWithUnit numberWithUnit:store andValue:[small convertDouble:100.  toUnit:store]],
                            ];
        NSMutableArray * choices = [NSMutableArray arrayWithCapacity:5];
        GCActivityAutoLapChoiceHolder * recorded = [GCActivityAutoLapChoiceHolder choiceHolder:nil value:0. andLabel:GC_LAPS_RECORDED];
        recorded.lapDescription = [GCActivityAutoLapChoices defaultDescriptionText];
        [choices addObject:recorded];

        ;
        GCHealthZoneCalculator * zoneCalc = [[GCAppGlobal health] zoneCalculatorForField:[GCField fieldForFlag:gcFieldFlagWeightedMeanHeartRate andActivityType:act.activityType]];
        if (zoneCalc && [act hasTrackField:gcFieldFlagWeightedMeanHeartRate]) {
            [choices addObject:[GCActivityAutoLapChoiceHolder choiceForZoneCalculator:zoneCalc andLabel:@"Heart Rate Zone"]];
        }
        GCHealthZoneCalculator * powerZoneCalc = [[GCAppGlobal health] zoneCalculatorForField:[GCField fieldForFlag:gcFieldFlagPower andActivityType:act.activityType]];
        if (powerZoneCalc && [act hasTrackField:gcFieldFlagPower]) {
            [choices addObject:[GCActivityAutoLapChoiceHolder choiceForZoneCalculator:powerZoneCalc andLabel:@"Power Zone"]];
        }

        gcFieldFlag forBestRolling[] = {gcFieldFlagPower,gcFieldFlagWeightedMeanHeartRate,gcFieldFlagWeightedMeanSpeed};
        for (size_t ii=0; ii<3; ii++) {
            gcFieldFlag fieldFlag = forBestRolling[ii];
            GCField * field = [GCField fieldForFlag:fieldFlag andActivityType:act.activityType];
            if ([act hasCalculatedDerivedTrack:gcCalculatedCachedTrackRollingBest forField:field ]) {
                GCStatsDataSerieWithUnit * serieu = [act calculatedDerivedTrack:gcCalculatedCachedTrackRollingBest forField:field thread:[GCAppGlobal worker]];
                if (serieu) {
                    [choices addObject:[GCActivityAutoLapChoiceHolder choiceForIndexSerie:serieu
                                                                                 andLabel:[field displayName]]];
                }
            }
        }

        if (act.activityTypeDetail.isSki) {
            [choices addObject:[GCActivityAutoLapChoiceHolder choiceHolderSki]];
        }

        GCActivityAutoLapChoiceHolder * disthalf = [GCActivityAutoLapChoiceHolder choiceHolder:[act matchDistanceBlockGreater] value:act.sumDistance/2. andLabel:GC_LAPS_SPLIT_DISTHALF];
        disthalf.lapDescription = NSLocalizedString(@"Split Half Distance", @"Autolap Choice");
        [choices addObject:disthalf];
        GCActivityAutoLapChoiceHolder * distquarter = [GCActivityAutoLapChoiceHolder choiceHolder:[act matchDistanceBlockGreater] value:act.sumDistance/4. andLabel:GC_LAPS_SPLIT_DISTQTER];
        distquarter.lapDescription = NSLocalizedString(@"Split Quarter Distance", @"Autolap Choice");
        [choices addObject:distquarter];

        NSUInteger idx = 0;
        for (GCNumberWithUnit * number in dist) {
            double value = [number convertToUnit:store].value;
            if (value < act.sumDistance) {
                [choices addObject:[GCActivityAutoLapChoiceHolder choiceHolder:[act matchDistanceBlockGreater] value:value andLabel:number.description]];
                idx++;
                if (idx>5) {
                    break;
                }
            }
        }

        [choices addObject:[GCActivityAutoLapChoiceHolder choiceHolder:[act matchDistanceBlockEqual] compare:[act compareSpeedBlock] value:1000. andLabel:NSLocalizedString(@"Fastest km", @"Autolap Choice")]];

        [choices addObject:[GCActivityAutoLapChoiceHolder choiceHolder:[act matchDistanceBlockEqual] compare:[act compareSpeedBlock] value:[store convertDouble:1. fromUnit:mile] andLabel:NSLocalizedString(@"Fastest mile", @"Autolap Choice")]];

        double totaltime = act.sumDuration;
        if (act.trackpoints.count>3) {
            totaltime =  [[(act.trackpoints).lastObject time]  timeIntervalSinceDate:[(act.trackpoints)[0] time]];
        }

        GCActivityAutoLapChoiceHolder * timehalf = [GCActivityAutoLapChoiceHolder choiceHolder:[act matchTimeBlock] value:totaltime/2. andLabel:GC_LAPS_SPLIT_TIMEHALF];
        timehalf.lapDescription = NSLocalizedString(@"Split Half Time", @"Autolap Choice");
        [choices addObject:timehalf];
        GCActivityAutoLapChoiceHolder * timequarter = [GCActivityAutoLapChoiceHolder choiceHolder:[act matchTimeBlock] value:totaltime/4. andLabel:GC_LAPS_SPLIT_TIMEQTER];
        timequarter.lapDescription = NSLocalizedString(@"Split Quarter Time", @"Autolap Choice");
        [choices addObject:timequarter];


        NSArray * time = @[ [GCNumberWithUnit numberWithUnit:hour andValue:1.],
                            [GCNumberWithUnit numberWithUnit:minute andValue:30.],
                            [GCNumberWithUnit numberWithUnit:minute andValue:15.],
                            [GCNumberWithUnit numberWithUnit:minute andValue:10.],
                            [GCNumberWithUnit numberWithUnit:minute andValue:5.],
                            [GCNumberWithUnit numberWithUnit:minute andValue:1.]
                            ];
        idx = 0;
        for (GCNumberWithUnit * number in time) {
            double value = [number convertToUnit:second].value;
            if (value < act.sumDuration) {
                [choices addObject:[GCActivityAutoLapChoiceHolder choiceHolder:[act matchTimeBlock] value:value andLabel:number.description]];
                idx++;
                if (idx>5) {
                    break;
                }
            }
        }


        self.choices = choices;
        self.selected = 0;
        if (self.activity.calculatedLapName) {
            NSUInteger found = 0;
            for (found=0; found<(self.choices).count; found++) {
                GCActivityAutoLapChoiceHolder * holder = (self.choices)[found];
                if ([holder.key isEqualToString:self.activity.calculatedLapName] ) {
                    self.selected = found;
                    break;
                }
            }
        }
    }
}
-(void)changeSelectedTo:(NSUInteger)idx{
    if (idx!=self.selected) {
        GCActivityAutoLapChoiceHolder * holder = (self.choices)[idx];
        if (![self.activity useLaps:holder.key]) {
            NSMutableArray * laps = [NSMutableArray arrayWithArray:[holder laps:self.activity]];
            [self.activity registerLaps:laps forName:holder.key];
            [self.activity useLaps:holder.key];
            if (holder.lapDescription) {
                [Flurry logEvent:EVENT_AUTO_LAP withParameters:@{@"description":holder.lapDescription}];
            }
        }
        self.selected = idx;
    }
}
+(NSString*)defaultDescriptionText{
    return NSLocalizedString(@"As Recorded", @"Autolap Choice");
}
+(NSAttributedString*)defaultDescription{
    return [[[NSAttributedString alloc] initWithString:[GCActivityAutoLapChoices defaultDescriptionText] attributes:[GCViewConfig attribute14Gray]] autorelease];
}

-(NSAttributedString*)currentDetailledDescription{
    return [[[NSAttributedString alloc] initWithString:[self currentHolder].lapDescription attributes:[GCViewConfig attribute14Gray]] autorelease];
}

+(NSAttributedString*)currentDescription:(GCActivity*)activity{
    NSString * lapName = [activity isSkiActivity] ? @"Run" : @"Lap";
    int count = (int)[activity lapCount];
    return [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d %@%@", count, lapName, count > 1 ? @"s" : @""]
                                            attributes:[GCViewConfig attributeBold16]] autorelease];
}
-(GCActivityAutoLapChoiceHolder*)currentHolder{
    if (self.selected < (self.choices).count) {
        return (self.choices)[self.selected];
    }
    return nil;
}
-(NSArray*)choicesDescriptions{
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:(self.choices).count];
    for (GCActivityAutoLapChoiceHolder * holder in self.choices) {
        [rv addObject:holder.lapDescription];
    }
    return rv;
}
@end
