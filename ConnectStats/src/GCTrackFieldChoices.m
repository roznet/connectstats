//  MIT Licence
//
//  Created on 21/08/2013.
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

#import "GCTrackFieldChoices.h"
#import "GCHealthZoneCalculator.h"
#import "GCActivity.h"
#import "GCTrackStats.h"
#import "GCAppGlobal.h"
#import "GCActivity+CachedTracks.h"


@implementation GCTrackFieldChoices

-(void)dealloc{
    [_choices release];
    [_activityType release];
    [super dealloc];
}

#pragma mark - Extract Choices from Activities

// HealthKit Field Map
//    gcFieldFlagDistance                 "SumDistance"         HKQuantityTypeIdentifierDistanceWalkingRunning
//    gcFieldFlagCadence                  "SumStep"             HKQuantityTypeIdentifierStepCount
//    gcFieldFlagAltitudeMeters           "SumFloorClimbed",    HKQuantityTypeIdentifierFlightsClimbed
//    gcFieldFlagPower                    "SumDistanceCycling"  HKQuantityTypeIdentifierDistanceCycling


+(GCTrackFieldChoices*)trackFieldChoicesWithDayActivity:(GCActivity*)activity{
    GCTrackFieldChoices * rv = [[[GCTrackFieldChoices alloc] init] autorelease];
    if (rv) {
        rv.activityType = activity.activityType;
        NSString * aT = rv.activityType;
        NSMutableArray * all = [NSMutableArray arrayWithCapacity:5];
        if ([activity hasTrackField:gcFieldFlagSumStep]) {
            rv.trackFlag |= gcFieldFlagSumStep;
            [all addObject:@[
                             [GCTrackFieldChoiceHolder trackFieldChoice:gcFieldFlagSumStep style:gcTrackStatsBucket type:aT],
                             [GCTrackFieldChoiceHolder trackFieldChoice:gcFieldFlagSumStep style:gcTrackStatsCumulative  type:aT],
                             ]];

        }
        if ([activity hasTrackField:gcFieldFlagWeightedMeanHeartRate] && [activity hasTrackField:gcFieldFlagWeightedMeanSpeed]) {
            [all addObject:@[ [GCTrackFieldChoiceHolder trackFieldChoice:gcFieldFlagSumDistance xField:gcFieldFlagWeightedMeanHeartRate movingAverage:0  type:aT] ]];
        }

        if ([activity hasTrackField:gcFieldFlagSumDistance]) {
            rv.trackFlag |= gcFieldFlagSumDistance;
            [all addObject:@[
                             [GCTrackFieldChoiceHolder trackFieldChoice:gcFieldFlagSumDistance style:gcTrackStatsBucket  type:aT],
                             [GCTrackFieldChoiceHolder trackFieldChoice:gcFieldFlagSumDistance style:gcTrackStatsCumulative  type:aT],
                             ]];

        }
        if ([activity hasTrackField:gcFieldFlagAltitudeMeters]) {
            rv.trackFlag |= gcFieldFlagAltitudeMeters;
            [all addObject:@[
                             [GCTrackFieldChoiceHolder trackFieldChoice:gcFieldFlagAltitudeMeters style:gcTrackStatsBucket  type:aT],
                             [GCTrackFieldChoiceHolder trackFieldChoice:gcFieldFlagAltitudeMeters style:gcTrackStatsCumulative  type:aT],
                             ]];
        }
        if ([activity hasTrackField:gcFieldFlagWeightedMeanSpeed]) {
            GCField * actSpeed = [GCField fieldForFlag:gcFieldFlagWeightedMeanSpeed andActivityType:activity.activityType];
            GCHealthZoneCalculator * calc = [[GCAppGlobal health] zoneCalculatorForField:actSpeed];

            [all addObject:@[
                             [GCTrackFieldChoiceHolder trackFieldChoice:gcFieldFlagWeightedMeanSpeed style:gcTrackStatsBucket  type:aT],
                             [GCTrackFieldChoiceHolder trackFieldChoice:gcFieldFlagWeightedMeanSpeed style:gcTrackStatsHistogram  type:aT],
                             [GCTrackFieldChoiceHolder trackFieldChoice:gcFieldFlagWeightedMeanSpeed zone:calc  type:aT],
                             [GCTrackFieldChoiceHolder trackFieldChoice:gcFieldFlagWeightedMeanSpeed style:gcTrackStatsRollingBest  type:aT],
                             ]];
        }
        if ([activity hasTrackField:gcFieldFlagWeightedMeanHeartRate]) {
            //GCHealthZoneCalculator * calc = [[GCAppGlobal health] zoneCalculatorForActivityType:activity.activityType andField:gcFieldFlagWeightedMeanHeartRate];

            [all addObject:@[
                             [GCTrackFieldChoiceHolder trackFieldChoice:gcFieldFlagWeightedMeanHeartRate style:gcTrackStatsBucket  type:aT],
                             [GCTrackFieldChoiceHolder trackFieldChoice:gcFieldFlagWeightedMeanHeartRate style:gcTrackStatsHistogram  type:aT],
                             //[GCTrackFieldChoiceHolder trackFieldChoice:gcFieldFlagWeightedMeanHeartRate zone:calc  type:aT],
                             [GCTrackFieldChoiceHolder trackFieldChoice:gcFieldFlagWeightedMeanHeartRate style:gcTrackStatsRollingBest  type:aT],
                             ]];

        }
        rv.choices = all;
        rv.trackFlag = (gcFieldFlag)activity.trackFlags;

    }
    return rv;
}

/**
 *  Include extra fields
 */
+(GCTrackFieldChoices*)allTrackFieldChoicesWithActivity:(GCActivity*)activity{
    GCTrackFieldChoices * rv = [[[GCTrackFieldChoices alloc] init] autorelease];
    if (rv) {
        NSArray * allFields = [activity availableTrackFields];

        NSMutableArray * all = [NSMutableArray arrayWithCapacity:allFields.count];

        GCActivity * compareActivity = [[GCAppGlobal organizer] validCompareActivityFor:activity];

        for (GCField * first in allFields) {
            NSMutableArray * styles = [NSMutableArray array];
            BOOL noisy = [first isNoisy];
            [styles addObject:[GCTrackFieldChoiceHolder trackFieldChoice:first xField:nil movingAverage:noisy?60:0]];
            // Add Zone Calculator if there
            GCHealthZoneCalculator * calc = [[GCAppGlobal health] zoneCalculatorForField:first];
            if (calc){
                [styles addObject:[GCTrackFieldChoiceHolder trackFieldChoice:first zone:calc]];
            }
            if (first.fieldFlag == gcFieldFlagWeightedMeanSpeed && compareActivity) {
                [styles addObject:[GCTrackFieldChoiceHolder trackFieldChoiceComparing:compareActivity timeAxis:false]];
                [styles addObject:[GCTrackFieldChoiceHolder trackFieldChoiceComparing:compareActivity timeAxis:true]];
            }
            // Add Rolling best
            if (first.fieldFlag==gcFieldFlagWeightedMeanSpeed || first.fieldFlag==gcFieldFlagWeightedMeanHeartRate || first.fieldFlag==gcFieldFlagPower) {
                if (![first.activityType isEqualToString:GC_TYPE_SWIMMING]) {
                    [styles addObject:[GCTrackFieldChoiceHolder trackFieldChoice:first style:gcTrackStatsRollingBest]];
                    [styles addObject:[GCTrackFieldChoiceHolder trackFieldChoice:first style:gcTrackStatsHistogram]];
                }
            }
            if (first.fieldFlag == gcFieldFlagWeightedMeanSpeed && (![first.activityType isEqualToString:GC_TYPE_SWIMMING])) {
                GCField * speed = [GCField fieldForKey:CALC_10SEC_SPEED andActivityType:activity.activityType];
                if ([activity hasCalculatedSerieForField:speed]) {
                    [styles addObject:[GCTrackFieldChoiceHolder trackFieldChoice:speed xField:nil]];
                }
            }
            if (first.fieldFlag==gcFieldFlagAltitudeMeters) {
                GCField * ascent = [GCField fieldForKey:CALC_VERTICAL_SPEED andActivityType:activity.activityType];
                if ([activity hasCalculatedSerieForField:ascent]) {
                    [styles addObject:[GCTrackFieldChoiceHolder trackFieldChoice:ascent xField:nil]];
                }
            }

            for (GCField * second in allFields) {
                if ([first isEqualToField:second]) {
                    continue;
                }
                [styles addObject:[GCTrackFieldChoiceHolder trackFieldChoice:first xField:second]];
            }

            if (styles.count>0) {
                [all addObject:styles];
            }
        }
        rv.choices = all;
        rv.trackFlag = (gcFieldFlag)activity.trackFlags;
    }
    return rv;
}

+(GCTrackFieldChoices*)trackFieldChoicesWithActivity:(GCActivity*)activity{
    return  [GCTrackFieldChoices allTrackFieldChoicesWithActivity:activity];
}

#pragma mark - Checks

-(BOOL)validForActivity:(GCActivity*)activity{
    BOOL valid = false;
    if (self.currentChoice < (self.choices).count) {
        NSArray * styles = (self.choices)[self.currentChoice];
        if (self.currentStyle < styles.count) {
            GCTrackFieldChoiceHolder * current = styles[self.currentStyle];
            valid = [activity hasField:[current.field correspondingFieldForActivityType:activity.activityType]];
            if (current.x_field!=gcFieldFlagNone && ![activity hasField:[current.x_field correspondingFieldForActivityType:activity.activityType]]) {
                valid = false;
            }
        }
    }
    return valid;
}

-(BOOL)trackFlagSameAs:(GCActivity*)activity{
    return self.trackFlag == activity.trackFlags;
}

#pragma mark - Setup
-(void)setupTrackStats:(GCTrackStats*)trackStats{
    GCTrackFieldChoiceHolder * current = [self current];
    if (current) {
        [current setupTrackStats:trackStats];
    }else{
        RZLog(RZLogWarning, @"Inconsistent choices in track options %d but %d options", (int)self.currentChoice, (int)[self.choices count]);
    }
}

#pragma mark - Navigate

-(GCTrackFieldChoiceHolder*)current{
    GCTrackFieldChoiceHolder * rv = nil;
    if (self.currentChoice < (self.choices).count) {
        NSArray * styles = (self.choices)[self.currentChoice];
        if (self.currentStyle < styles.count) {
            rv = styles[self.currentStyle];
        }
    }
    return rv;
}

-(void)next{
    self.currentChoice +=1;
    if (self.currentChoice >= (self.choices).count) {
        self.currentChoice = 0;
    }
    self.currentStyle = 0;
}
-(void)previous{
    if (self.currentStyle > 0) {
        self.currentStyle = 0;
    }else{
        if (self.currentChoice > 0) {
            self.currentChoice -=1;
            self.currentStyle = 0;
        }else{
            self.currentChoice = self.choices.count-1;
            self.currentStyle = 0;
        }
    }
}
-(void)nextStyle{
    if (self.currentChoice < (self.choices).count) {
        self.currentStyle += 1;
        NSArray * styles= (self.choices)[self.currentChoice];
        if (self.currentStyle >= styles.count) {
            //Either loop or go to next
            //self.currentStyle = 0;
            [self next];
        }
    }
}
-(NSArray*)holdersForField:(GCField*)field{

    for (NSArray * holders in self.choices) {
        if (0<holders.count) {
            GCTrackFieldChoiceHolder * holder = holders[0];
            if ([holder.field isEqualToField:field]) {
                return holders;
            }
        }
    }
    return nil;
}


@end
