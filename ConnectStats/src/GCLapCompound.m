//  MIT Licence
//
//  Created on 30/11/2013.
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

#import "GCLapCompound.h"

@implementation GCLapCompound

-(void)dealloc{
    [_laps release];
    [super dealloc];
}
-(GCLap*)startNewLap:(GCTrackPoint*)point{
    if (!self.laps) {
        self.laps = @[];
    }
    self.laps = [self.laps arrayByAddingObject:[[[GCLap alloc] initWithTrackPoint:point] autorelease]];
    return (self.laps).lastObject;
}

-(void)accumulate:(GCLap*)other  inActivity:(GCActivity*)act{
    [super accumulate:other inActivity:act];
    if (!self.laps) {
        self.laps = @[];
    }
    GCLap * last = (self.laps).lastObject;
    if (last) {
        [last accumulate:other  inActivity:act];
    }
}
-(void)accumulateFrom:(GCTrackPoint*)from to:(GCTrackPoint*)to  inActivity:(GCActivity*)act{
    [super accumulateFrom:from to:to  inActivity:act];
    if (!self.laps) {
        self.laps = @[];
    }
    GCLap * last = (self.laps).lastObject;
    if (!last) {
        last = [self startNewLap:from];
    }
    [last accumulateFrom:from to:to  inActivity:act];

}
-(void)decumulateFrom:(GCTrackPoint*)from to:(GCTrackPoint*)to  inActivity:(GCActivity*)act{
    [super decumulateFrom:from to:to  inActivity:act];
    if (!self.laps) {
        self.laps = @[];
    }
    GCLap * last = (self.laps).lastObject;
    if (last) {
        [last decumulateFrom:from to:to  inActivity:act];
    }
}

-(void)interpolate:(double)delta within:(GCLap*)diff  inActivity:(GCActivity*)act{
    [super interpolate:delta within:diff  inActivity:act];
    if (!self.laps) {
        self.laps = @[];
    }
    GCLap * last = (self.laps).lastObject;
    if (last) {
        [last interpolate:delta within:diff  inActivity:act];
    }
}


-(BOOL)pointInLap:(GCTrackPoint*)point{
    for (GCLap * lap in self.laps) {
        NSDate * end = [lap.time dateByAddingTimeInterval:lap.elapsed];
        if ([point.time compare:lap.time] == NSOrderedDescending && [point.time compare:end] == NSOrderedAscending) {
            return true;
        }
    }
    return false;
}

@end
