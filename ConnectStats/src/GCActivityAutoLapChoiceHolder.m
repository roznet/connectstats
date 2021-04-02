//  MIT License
//
//  Created on 02/04/2021 for ConnectStats
//
//  Copyright (c) 2021 Brice Rosenzweig
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



#import "GCActivityAutoLapChoiceHolder.h"
#import "GCViewConfig.h"
#import "GCHealthZoneCalculator.h"
#import "GCActivity+CachedTracks.h"
#import "GCAppGlobal.h"
#import "GCActivity+Fields.h"

@interface GCActivityAutoLapChoiceHolder ()

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
+(GCActivityAutoLapChoiceHolder*)choiceHolderWithLabel:(NSString*)label{
    GCActivityAutoLapChoiceHolder * rv = [[[GCActivityAutoLapChoiceHolder alloc] init] autorelease];
    if (rv) {
        rv.key = label;
        rv.value = 0.0;
        rv.match = nil;
        rv.compare = nil;
        rv.lapDescription = label;
        rv.style = gcAutoLapStyleMatching;
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

+(GCActivityAutoLapChoiceHolder*)choiceHolderAccumulatedWithLabel:(NSString*)label{
    GCActivityAutoLapChoiceHolder * rv = [[[GCActivityAutoLapChoiceHolder alloc] init] autorelease];
    if (rv) {
        rv.key = label;
        rv.lapDescription = NSLocalizedString(@"Accumulated", @"Laps Description");
        rv.style = gcAutoLapStyleAccumulated;
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

-(NSArray<GCLap*>*)laps:(GCActivity*)activity{
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
        case gcAutoLapStyleAccumulated:
            rv = [activity accumulatedLaps];
            break;
    }
    return rv;
}

-(BOOL)shouldAlwaysRecalculate{
    return self.style == gcAutoLapStyleAccumulated;
}
@end
