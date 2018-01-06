//  MIT Licence
//
//  Created on 17/01/2016.
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

#import "GCCalendarDataMarkerInfo.h"
#import "GCActivity.h"

#import "GCActivity+Fields.h"

@implementation GCCalendarDataMarkerInfo

-(void)dealloc{
    [_activityTypeKey release];
    [_sumDistance release];
    [_sumDuration release];
    [_sumSteps release];
    [super dealloc];
}

-(NSString*)description{
    NSMutableArray * show = [NSMutableArray array];
    if (self.sumDuration) {
        [show addObject:[self.sumDuration formatDouble]];
    }
    if (self.sumDistance) {
        [show addObject:[self.sumDistance formatDouble]];
    }
    if (self.sumSteps) {
        [show addObject:[self.sumSteps formatDouble]];
    }
    return [NSString stringWithFormat:@"<%@[%lu]:%@>", NSStringFromClass([self class]), (long unsigned)self.count,[show componentsJoinedByString:@":"]];
}
+(GCCalendarDataMarkerInfo*)markerInfo{
    return [[[GCCalendarDataMarkerInfo alloc] init] autorelease];
}

-(void)addActivity:(GCActivity*)act{
    self.count += 1;

    GCNumberWithUnit * dist = [act numberWithUnitForFieldFlag:gcFieldFlagSumDistance];
    self.sumDistance = self.sumDistance ? [self.sumDistance addNumberWithUnit:dist weight:1.] : dist;

    GCNumberWithUnit * dur = [act numberWithUnitForFieldFlag:gcFieldFlagSumDuration];
    self.sumDuration = self.sumDuration ? [self.sumDuration addNumberWithUnit:dur weight:1.] : dur;

    if ([act hasTrackField:gcFieldFlagSumStep]) {
        GCNumberWithUnit * step = [act numberWithUnitForFieldFlag:gcFieldFlagSumStep];
        self.sumSteps = self.sumSteps ? [self.sumSteps addNumberWithUnit:step weight:1.] : step;
    }
}

-(void)maxMarkerInfo:(GCCalendarDataMarkerInfo*)marker{
    if (self.sumDistance) {
        if (marker.sumDistance) {
            self.sumDistance = [self.sumDistance maxNumberWithUnit:marker.sumDistance];
        }
    }else{
        self.sumDistance = marker.sumDistance;
    }

    if (self.sumDuration) {
        if (marker.sumDuration) {
            self.sumDuration = [self.sumDuration maxNumberWithUnit:marker.sumDuration];
        }
    }else{
        self.sumDuration = marker.sumDuration;
    }

    if (self.sumSteps) {
        if (marker.sumSteps) {
            self.sumSteps = [self.sumSteps maxNumberWithUnit:marker.sumSteps];
        }
    }else{
        self.sumSteps = marker.sumSteps;
    }
}
@end
