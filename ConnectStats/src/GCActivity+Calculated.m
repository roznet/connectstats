//  MIT Licence
//
//  Created on 20/02/2013.
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

#import "GCActivity+Calculated.h"
#import "GCAppGlobal.h"
#import "GCHealthZoneCalculator.h"
#import "GCActivity+CachedTracks.h"
#import "GCLapCompound.h"

typedef  NS_ENUM(NSUInteger, gcSkiLapType){
    gcSkiLapNone,
    gcSkiLapClimbing,
    gcSkiLapDownhill,
    gcSkiLapStationary
};

@implementation GCActivity (Calculated)

-(NSArray*)calculatedLapsMatching:(double)val with:(GCActivityMatchLapBlock)match{
    NSMutableArray * array = [NSMutableArray array];

    if (self.trackpoints) {
        GCTrackPoint * lastPoint = self.trackpoints[0];

        GCLap * lap = [[[GCLap alloc] init] autorelease];

        for (GCTrackPoint * point in self.trackpoints) {
            [lap accumulateFrom:lastPoint to:point inActivity:self];
            lastPoint = point;
            BOOL isLap = match(lap,nil,val,true);
            if (isLap) {
                [array addObject:lap];
                lap = [[[GCLap alloc] init] autorelease];
            }
        }
    }
    return array;
}

-(GCActivityMatchLapBlock)matchDistanceBlockEqual{
    return
        Block_copy(^(GCLap*l,GCLap*diff,double valueMeters,BOOL interp){
            //if (l.distanceMeters-valueMeters < diff.distanceMeters && l.distanceMeters > valueMeters) {
            if (fabs(l.distanceMeters-valueMeters) < diff.distanceMeters ) {
                if (interp) {
                    double delta = (valueMeters-l.distanceMeters)/diff.distanceMeters;
                    [l interpolate:delta within:diff inActivity:self];
                }

                return NSOrderedSame;
            }else if(l.distanceMeters > valueMeters){
                return NSOrderedAscending;
            }else {
                return NSOrderedDescending;
            }

            return NSOrderedSame;
        });
}

-(GCActivityMatchLapBlock)matchDistanceBlockGreater{
    return
    Block_copy(^(GCLap*l,GCLap*diff,double valueMeters,BOOL interp){
        if (l.distanceMeters-valueMeters < diff.distanceMeters && l.distanceMeters > valueMeters) {
            if (interp) {
                double delta = (valueMeters-l.distanceMeters)/diff.distanceMeters;
                [l interpolate:delta within:diff inActivity:self];
            }

            return NSOrderedSame;
        }else if(l.distanceMeters > valueMeters){
            return NSOrderedAscending;
        }else {
            return NSOrderedDescending;
        }

        return NSOrderedSame;
    });
}

-(GCActivityMatchLapBlock)matchTimeBlock{
    return
    Block_copy(^(GCLap*l,GCLap*diff,double valueSeconds,BOOL interp){
        if (fabs(l.elapsed-valueSeconds) < diff.elapsed) {
            if (interp) {
                double delta = (valueSeconds-l.elapsed)/diff.elapsed;
                [l interpolate:delta within:diff inActivity:self];
            }

            return NSOrderedSame;
        }else if(l.elapsed > valueSeconds){
            return NSOrderedAscending;
        }else {
            return NSOrderedDescending;
        }

        return NSOrderedSame;
    });
}


-(GCActivityCompareLapBlock)compareSpeedBlock{

    GCActivityCompareLapBlock rv = ^(GCLap*current,GCLap*candidate){
        if(candidate.speed > current.speed){
            return (BOOL)true;
        }
        return (BOOL)false;
    };
    return rv;
}

-(NSArray*)calculatedLapFor:(double)val match:(GCActivityMatchLapBlock)match inLap:(NSUInteger)lapidx{
    NSArray * trackpointsCache = self.trackpoints;

    if (trackpointsCache.count == 0) {
        return nil;
    }
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:10];

    GCLap * candidateLap = nil;
    GCLap * diff = [[[GCLap alloc] init] autorelease];
    BOOL useMovingElapse = [GCAppGlobal configGetBool:CONFIG_USE_MOVING_ELAPSED defaultValue:false];
    NSUInteger countPoints = 0;
    double gpsDistance = 0.;

    for (NSUInteger idx = 0; idx < trackpointsCache.count; idx++) {
        if (candidateLap == nil) {
            candidateLap = [[[GCLap alloc] initWithTrackPoint:trackpointsCache[idx]] autorelease];
            candidateLap.useMovingElapsed=useMovingElapse;
        }
        if (idx > 0) {
            GCTrackPoint * prevPoint = trackpointsCache[idx-1];
            GCTrackPoint * currPoint = trackpointsCache[idx];
            [diff difference:currPoint minus:prevPoint inActivity:self];
            [candidateLap accumulateFrom:prevPoint to:currPoint inActivity:self];
            countPoints++;

            if ([prevPoint validCoordinate] && [currPoint validCoordinate]) {
                gpsDistance += [currPoint distanceMetersFrom:prevPoint];
            }else if(currPoint.distanceMeters!=0. && prevPoint.distanceMeters!=0.){
                gpsDistance += currPoint.distanceMeters-prevPoint.distanceMeters;
            }
            NSComparisonResult currCompareResult = match(candidateLap,diff,val,true );
            if (currCompareResult != NSOrderedDescending) {
                [candidateLap augmentElapsed:nil inActivity:self];
                [rv addObject:candidateLap];
                candidateLap = [[[GCLap alloc] initWithTrackPoint:trackpointsCache[idx]] autorelease];
                candidateLap.useMovingElapsed=useMovingElapse;

                countPoints=0;
            }
        }
    }
    /*
    if (fabs(gpsDistance-self.sumDistance)>10.) {
        RZLog(RZLogWarning, @"gpsDistance=%.0f actDistance=%.0f diff=%0.f", gpsDistance,self.sumDistance, gpsDistance-self.sumDistance);
    }*/
    if (candidateLap) {
        [candidateLap augmentElapsed:nil inActivity:self];
        [rv addObject:candidateLap];
    }

    return rv;
}

-(double)trackPointDistanceMetersFrom:(NSUInteger)fromI_ to:(NSUInteger)toI_{
    double check=0.;

    NSArray * trackpointsCache = self.trackpoints;
    if (trackpointsCache) {
        NSUInteger toI = MIN(toI_,trackpointsCache.count);
        NSUInteger fromI = MIN(fromI_, toI);

        for (NSUInteger ii=fromI; ii<toI; ii++) {
            GCTrackPoint * a = trackpointsCache[ii];
            GCTrackPoint * b = trackpointsCache[ii+1];
            check+= [a distanceMetersFrom:b];
        }
    }

    return check;
}

-(NSArray*)calculatedRollingLapFor:(double)val match:(GCActivityMatchLapBlock)match compare:(GCActivityCompareLapBlock)compare{

    NSArray * trackpointsCache = self.trackpoints;

    if (trackpointsCache.count == 0) {
        return nil;
    }
    GCLap * foundLap = nil;
    GCLap * foundNext = nil;
    GCLap * foundFirst = nil;

    GCLap * candidateFirst = [[[GCLap alloc] initWithTrackPoint:trackpointsCache[0]] autorelease];
    GCLap * candidateLap   = [[[GCLap alloc] initWithTrackPoint:trackpointsCache[0]] autorelease];
    GCLap * diff = [[[GCLap alloc] init] autorelease];

    NSUInteger leftIdx = 0;

    //  +--+--....---+--+
    //  |--------|          NSOrderedDescending -> too small
    //  |------------|      NSOrderedSame
    //  |---------------|   NSOrderedAscending  -> too big
    //     |------------|   NSOrderedSame

    for (NSUInteger idx = 1; idx < trackpointsCache.count; idx++) {

        GCTrackPoint * prevPoint = trackpointsCache[idx-1];
        GCTrackPoint * currPoint = trackpointsCache[idx];
        [diff difference:currPoint minus:prevPoint inActivity:self];
        [candidateLap accumulateFrom:prevPoint to:currPoint inActivity:self];
        [candidateFirst accumulateFrom:prevPoint to:currPoint inActivity:self];
        if (foundNext) {
            [foundNext accumulateFrom:prevPoint to:currPoint inActivity:self];
        }
        NSComparisonResult currCompareResult = match(candidateLap,diff,val,false );
        // if too big try to reduce from the left.
        if (currCompareResult == NSOrderedAscending) {
            while ((currCompareResult = match(candidateLap,diff,val,false)) == NSOrderedAscending && leftIdx < idx) {
                GCTrackPoint * leftPoint =trackpointsCache[leftIdx];
                GCTrackPoint * leftNextPoint =trackpointsCache[leftIdx+1];
                [candidateLap decumulateFrom:leftPoint to:leftNextPoint inActivity:self];
                //NSLog(@"decumulate %@ resulting in %@ at %@", candidateLap, @(candidateLap.distanceMeters), @(candidateLap.speed));
                leftIdx++;

                [diff difference:leftNextPoint minus:leftPoint inActivity:self];
            }
            if (leftIdx==idx) {
                RZLog(RZLogError, @"rolling lap matching is too small?");
                if (foundLap) {

                    NSArray * rv = @[foundLap,foundNext];

                    [foundLap release];
                    [foundNext release];
                    [foundFirst release];

                    return rv;
                }else{
                    [foundFirst release];
                    [foundNext release];
                    [foundLap release];
                }

                return nil;
            }
        }

        if( currCompareResult == NSOrderedSame){
            if (foundLap == nil || compare(foundLap,candidateLap)) {
                [foundLap release];
                foundLap =  [[GCLap alloc] initWithLap:candidateLap];
                //NSLog(@"found[%@] %@ with %@ and %@ at %@", @(idx), candidateLap,  @(candidateLap.elapsed), @(candidateLap.distanceMeters), @(candidateLap.speed));

                match(foundLap,diff,val,true);
                [foundNext release];
                foundNext = [[GCLap alloc] initWithTrackPoint:currPoint];
                foundNext.distanceMeters = 0.;
                foundNext.elapsed = 0.;
                [foundFirst release];
                foundFirst = [[GCLap alloc] initWithLap:candidateFirst];

            }
            // reset interpolation
            candidateLap.distanceMeters = [self trackPointDistanceMetersFrom:leftIdx to:idx];
        }
    }
    if (!foundFirst||!foundLap||!foundNext) {
        [foundFirst release];
        [foundLap release];
        [foundNext release];
        return @[];
    }
    [foundFirst augmentElapsed:nil inActivity:self];
    [foundLap augmentElapsed:nil inActivity:self];
    [foundNext augmentElapsed:nil inActivity:self];

    [foundFirst autorelease];
    [foundLap autorelease];
    [foundNext autorelease];

    return @[foundFirst,foundLap,foundNext];
}

-(NSArray*)calculateSkiLaps{
    NSArray * trackpointsCache = self.trackpoints;

    if (trackpointsCache.count == 0) {
        return nil;
    }

    GCLap * candidateLap   = nil;
    GCLap * nextLap        = nil;

    GCLap * diff = [[[GCLap alloc] init] autorelease];

    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:10];

    gcSkiLapType candidateLapType = gcSkiLapNone;
    gcSkiLapType nextLapType      = gcSkiLapNone;

    for (NSUInteger idx = 0; idx < trackpointsCache.count; idx++) {
        if (candidateLap == nil) {
            candidateLap = [[[GCLap alloc] initWithTrackPoint:trackpointsCache[idx]] autorelease];
        }
        if (idx > 0) {
            GCTrackPoint * prevPoint = trackpointsCache[idx-1];
            GCTrackPoint * currPoint = trackpointsCache[idx];
            [diff difference:currPoint minus:prevPoint inActivity:self];

            if (diff.altitude < 0){
                nextLapType = gcSkiLapDownhill;
            }else{
                nextLapType = gcSkiLapClimbing;
            }

            if (candidateLapType == gcSkiLapNone) {
                candidateLapType = nextLapType;
            }else{
                if (nextLapType==candidateLapType) {
                    if (nextLap==nil) {
                        // same type, and currently accumulating lap
                        [candidateLap accumulateFrom:prevPoint to:currPoint inActivity:self];
                    }else{
                        // same type but had temporarily switched, put back
                        [candidateLap accumulateLap:nextLap  inActivity:self];
                        nextLap=nil;
                    }
                }else{
                    // different type
                    if (!nextLap) {
                        nextLap = [[[GCLap alloc] initWithTrackPoint:currPoint] autorelease];
                    }

                    [nextLap accumulateFrom:prevPoint to:currPoint  inActivity:self];
                    // switch of 1min or more: next lap
                    if (nextLap.elapsed > 60.) {
                        if (candidateLapType==gcSkiLapClimbing) {
                            candidateLap.label = NSLocalizedString(@"Lift", @"Ski Lap Label");
                        }else{
                            candidateLap.label = NSLocalizedString(@"Downhill", @"Ski Lap Label");
                        }
                        [rv addObject:candidateLap];
                        candidateLap = nextLap;
                        nextLap = nil;
                        candidateLapType=nextLapType;
                    }
                }
            }
        }
    }
    if (candidateLap.elapsed > 1) {
        if (nextLap) {
            [candidateLap accumulateLap:nextLap  inActivity:self];
        }
        if (candidateLap) {
            [rv addObject:candidateLap];
        }
    }
    return rv;
}

-(NSArray*)compoundLapForZoneCalculator:(GCHealthZoneCalculator*)zoneCalc{
    NSUInteger n = (zoneCalc.zones).count;

    NSArray * trackpointsCache = self.trackpoints;

    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:n];
    for (NSUInteger i=0; i<n; i++) {
        GCLapCompound * lap = [[[GCLapCompound alloc] init] autorelease];
        GCHealthZone * zone = (zoneCalc.zones)[i];
        lap.label = [NSString stringWithFormat:@"Zone %ld: %.0f-%.0f",(long)zone.zoneIndex+1, zone.floor, zone.ceiling ];
        [rv addObject:lap ];
    }

    NSUInteger lastZoneIdx = 0;
    GCLapCompound * lastZoneLap = nil;

    for (NSUInteger idx = 0; idx < trackpointsCache.count; idx++) {
        GCTrackPoint * to = trackpointsCache[idx];
        GCNumberWithUnit * val = [to numberWithUnitForField:zoneCalc.field inActivity:self];
        GCHealthZone * zone = [zoneCalc zoneForNumber:val];

        NSUInteger zoneIdx = zone.zoneIndex;

        if (idx > 0) {
            GCLapCompound * lap = zoneIdx < rv.count ? rv[zoneIdx] : rv.lastObject;
            if (lastZoneLap == nil) {
                lastZoneLap = lap;
            }

            GCTrackPoint * from = trackpointsCache[(idx-1)];
            if (lastZoneIdx != zoneIdx) {
                [lastZoneLap accumulateFrom:from to:to  inActivity:self];
                //NSLog(@"LAP %f adds %f to [%d]=%f Bucket[%d]", from.heartRateBpm, [to timeIntervalSince:from], (int)lastZoneIdx, lastZoneLap.elapsed, (int)lastZoneIdx);
                [lap startNewLap:to];
            }else{
                [lap accumulateFrom:from to:to  inActivity:self];
                //NSLog(@"LAP %f adds %f to [%d]=%f Bucket[%d]=%f", from.heartRateBpm, [to timeIntervalSince:from], (int)zoneIdx, lap.elapsed, (int)zoneIdx, zone.ceiling);

            }
            lastZoneIdx = zoneIdx;
            lastZoneLap = lap;
        }
    }

    return rv;
}

-(NSArray*)compoundLapForIndexSerie:(GCStatsDataSerieWithUnit*)serieu desc:(NSString *)desc{
    if([serieu.xUnit canConvertTo:[GCUnit unitForKey:@"meter"]]) {
        return [self compoundLapForDistanceIndexSerie:serieu desc:desc];
    }else{
        return [self compoundLapForTimeIndexSerie:serieu desc:desc];
    }
}

+(NSArray*)sampleDistancesUpTo:(double)distanceMeters{
    GCUnit * smallu = [[GCUnit unitForKey:@"meter"] unitForGlobalSystem];
    GCUnit * bigu   = [[GCUnit unitForKey:@"kilometer"] unitForGlobalSystem];

    GCUnit * ref    = [GCUnit unitForKey:@"meter"];

    NSMutableArray * rv = [NSMutableArray array];
    double small_xs[] = { 25., 50., 75., 100., 200., 400., 500., 800., 1000., 1500., 2000. };
    double big_xs[]   = { 1., 2., 3., 5., 10., 15., 20., 30., 40., 50., 100. };
    double std_xs[]   = { 1000., 1609.344, 42.195/2.*1000., 42.195*1000. };

    size_t small_n = sizeof(small_xs)/sizeof(double);
    size_t big_n = sizeof(big_xs)/sizeof(double);
    size_t std_n = sizeof(std_xs)/sizeof(double);

    double switch_dist =  [ref convertDouble:big_xs[0] fromUnit:bigu];

    for (size_t i=0; i<small_n; i++) {
        double d_ref = [ref convertDouble:small_xs[i] fromUnit:smallu];
        if (d_ref>switch_dist || d_ref>distanceMeters) {
            break;
        }
        [rv addObject:@(d_ref)];
    }

    for (size_t i=0; i<big_n; i++) {
        double d_ref = [ref convertDouble:big_xs[i] fromUnit:bigu];
        if (d_ref>distanceMeters) {
            break;
        }
        [rv addObject:@(d_ref)];
    }
    for (size_t i=0; i<std_n; i++) {
        double d_ref = [ref convertDouble:std_xs[i] fromUnit:smallu];
        if (d_ref>distanceMeters) {
            break;
        }
        [rv addObject:@(d_ref)];
    }

    return [[NSSet setWithArray:rv].allObjects sortedArrayUsingSelector:@selector(compare:)];
}

-(NSArray*)compoundLapForDistanceIndexSerie:(GCStatsDataSerieWithUnit*)serieu desc:(NSString *)desc{
    //GCTrackPoint * first_p = self.trackpointsCache[0];
    GCTrackPoint * last_p  = (self.trackpoints).lastObject;

    double totalDistance = last_p.distanceMeters;

    NSArray * dists = [GCActivity sampleDistancesUpTo:totalDistance];
    NSUInteger n = dists.count;
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:n];

    double startx = [serieu.serie dataPointAtIndex:0].x_data;
    NSUInteger serieIndex = 0;
    GCUnit * meters = [GCUnit unitForKey:@"meter"];
    GCUnit * disp =  [[GCUnit unitForKey:self.distanceDisplayUom] unitForGlobalSystem];

    NSArray * trackpointsCache = self.trackpoints;

    for (NSUInteger i=0; i<n; i++) {
        double dist = [dists[i] doubleValue];
        double xval =startx+dist;
        if (dist>totalDistance) {
            break;
        }
        NSString * label = nil;
        label = [NSString stringWithFormat:@"max(%@) %@", desc, [disp formatDouble:[disp convertDouble:dist fromUnit:meters]]];

        GCLapCompound * lap = [[[GCLapCompound alloc] init] autorelease];
        lap.label = label;

        gcStatsIndexes indexes_serie = [serieu.serie indexForXVal:xval from:serieIndex];

        GCStatsDataPoint * point = [serieu.serie dataPointAtIndex:indexes_serie.left];
        GCStatsDataPointMulti * mpoint = nil;
        if ([point isKindOfClass:[GCStatsDataPointMulti class]]) {
            mpoint = (GCStatsDataPointMulti*)point;
        }
        if (mpoint) {
            double lapStart_x = mpoint.z_data;

            for (NSUInteger idx = 0; idx < trackpointsCache.count-1; idx++) {
                GCTrackPoint * from = trackpointsCache[idx];
                GCTrackPoint * to =   trackpointsCache[idx+1];
                double dist_from = from.distanceMeters;
                double dist_to   = to.distanceMeters;

                BOOL inside = (lapStart_x < dist_to && lapStart_x >= dist_from);

                if( (inside || lapStart_x <= dist_from) && lap.distanceMeters<dist){
                    [lap accumulateFrom:from to:to  inActivity:self];
                    if (lap.distanceMeters > dist) { // if we went too far, remove extra
                        GCLap * diff = [[GCLap alloc] init];
                        [diff difference:to minus:from  inActivity:self];
                        double delta = -(lap.distanceMeters - dist)/diff.distanceMeters;
                        //NSLog(@"lap secs=%.0f elapsed=%.0f lastelapsed=%.0f adjust %.0f", secs, lap.elapsed, diff.elapsed, delta*diff.elapsed);
                        [lap interpolate:delta within:diff  inActivity:self];
                        //NSLog(@"output elapsed %.0f", lap.elapsed);
                        [diff release];
                    }

                }
            }
        }
        [rv addObject:lap ];
    }
    return rv;
}

-(NSArray*)compoundLapForTimeIndexSerie:(GCStatsDataSerieWithUnit*)serieu desc:(NSString *)desc{

    NSArray * trackpointsCache = self.trackpoints;

    // 5s, 10s, 15s, 30s, 45s, 1m, 2m, 5m, 10m, 15m, 30m, 45m, 1h, 1h30, 2h
    double xs[] = { 5., 10., 15., 30., 45., 60., 2.*60., 5.*60., 10.*60., 15.*60., 30.*60., 45.*60., 60.*60, 90.*60., 120.*60. };

    size_t n = sizeof(xs)/sizeof(double);
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:n];

    if (self.trackpoints==nil||self.trackpoints.count<3) {
        return rv;
    }

    GCTrackPoint * first_p = self.trackpoints[0];
    GCTrackPoint * last_p  = (self.trackpoints).lastObject;
    double totalElapsed = [last_p.time timeIntervalSinceDate:first_p.time];
    NSUInteger cnt = serieu.serie.count;
    if (cnt < 3) {
        //edge case
        return rv;
    }

    double startx = [serieu.serie dataPointAtIndex:0].x_data;
    NSUInteger serieIndex = 0;

    for (NSUInteger i=0; i<n; i++) {
        double secs = xs[i];
        double xval =startx+secs;
        if (secs>totalElapsed) {
            break;
        }
        NSString * label = nil;
        if (secs < 60.) {
            label = [NSString stringWithFormat:@"max(%@) %.0fs", desc, secs];
        }else if(secs < 60.*60.){
            label = [NSString stringWithFormat:@"max(%@) %.0fmn", desc, secs/60.];
        }else {
            int hours = (int) (secs/(60.*60.));
            int mins  = (int)(secs - hours*(60.*60.));
            label = [NSString stringWithFormat:@"max(%@) %d:%02d", desc, hours, mins/60];
        }

        GCLapCompound * lap = [[[GCLapCompound alloc] init] autorelease];
        lap.label = label;

        gcStatsIndexes indexes_serie = [serieu.serie indexForXVal:xval from:serieIndex];

        GCStatsDataPoint * point = [serieu.serie dataPointAtIndex:indexes_serie.left];
        GCStatsDataPointMulti * mpoint = nil;
        if ([point isKindOfClass:[GCStatsDataPointMulti class]]) {
            mpoint = (GCStatsDataPointMulti*)point;
        }
        if (mpoint) {
            double lapStart_x = mpoint.z_data;

            NSDate * startTime=[trackpointsCache[0] time];
            for (NSUInteger idx = 0; idx < trackpointsCache.count-1; idx++) {
                GCTrackPoint * from = trackpointsCache[idx];
                GCTrackPoint * to =   trackpointsCache[idx+1];
                double elapsed_from = [from.time timeIntervalSinceDate:startTime];

                if(lapStart_x <= elapsed_from && lap.elapsed<secs){
                    [lap accumulateFrom:from to:to  inActivity:self];
                    if (lap.elapsed > secs) { // if we went too far, remove extra
                        GCLap * diff = [[GCLap alloc] init];
                        [diff difference:to minus:from  inActivity:self];
                        double delta = -(lap.elapsed - secs)/diff.elapsed;
                        //NSLog(@"lap secs=%.0f elapsed=%.0f lastelapsed=%.0f adjust %.0f", secs, lap.elapsed, diff.elapsed, delta*diff.elapsed);
                        [lap interpolate:delta within:diff  inActivity:self];
                        //NSLog(@"output elapsed %.0f", lap.elapsed);
                        [diff release];
                    }

                }
            }
        }
        [rv addObject:lap ];
    }
    return rv;
}

@end
