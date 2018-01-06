//  MIT Licence
//
//  Created on 03/03/2013.
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

#import "GCActivityTrackOptions.h"

@implementation GCActivityTrackOptions
-(void)dealloc{
    [_zoneCalculator release];
    [_field release];
    [_x_field release];
    [_l_field release];
    [_o_field release];

    [super dealloc];
}
+(GCActivityTrackOptions*)optionForHolder:(GCTrackFieldChoiceHolder*)holder{
    GCActivityTrackOptions * rv = [[[GCActivityTrackOptions alloc] init] autorelease];
    if (rv) {
        rv.field = holder.field;
        rv.x_field = holder.x_field;
        rv.movingAverage = holder.movingAverage;
        rv.statsStyle = holder.statsStyle;
        rv.zoneCalculator = holder.zoneCalculator;
    }
    return rv;

}

+(GCActivityTrackOptions*)optionFor:(GCField*)aF x:(GCField*)aXf andMovingAverage:(NSUInteger)aMA{
    GCActivityTrackOptions * rv = [[[GCActivityTrackOptions alloc] init] autorelease];
    if (rv) {
        rv.field = aF;
        rv.x_field = aXf;
        rv.movingAverage = aMA;
        rv.statsStyle = gcTrackStatsData;
    }
    return rv;
}
+(GCActivityTrackOptions*)optionFor:(GCField*)aF l:(GCField*)aLf andMovingAverage:(NSUInteger)aMA{
    GCActivityTrackOptions * rv = [[[GCActivityTrackOptions alloc] init] autorelease];
    if (rv) {
        rv.field = aF;
        rv.l_field = aLf;
        rv.movingAverage = aMA;
        rv.statsStyle = gcTrackStatsData;
    }
    return rv;

}

-(void)setupTrackStatsForOther:(GCTrackStats *)trackStats{
    trackStats.movingAverage = [GCActivityTrackOptions movingAverageForSmoothingFlag:self.o_smoothing];
    [trackStats setupForField:self.o_field xField:nil andLField:nil];
}

-(void)setupTrackStats:(GCTrackStats*)trackStats{

    if (trackStats.movingAverage != [GCActivityTrackOptions movingAverageForSmoothingFlag:self.smoothing]) {
        trackStats.movingAverage = [GCActivityTrackOptions movingAverageForSmoothingFlag:self.smoothing];
        [trackStats setNeedsForRecalculate];
    }
    if (trackStats.x_movingAverage != [GCActivityTrackOptions movingAverageForSmoothingFlag:self.x_smoothing ]) {
        trackStats.x_movingAverage = [GCActivityTrackOptions movingAverageForSmoothingFlag:self.x_smoothing ];
        [trackStats setNeedsForRecalculate];
    }
    if (trackStats.l_movingAverage != [GCActivityTrackOptions movingAverageForSmoothingFlag:self.l_smoothing]) {
        trackStats.l_movingAverage = [GCActivityTrackOptions movingAverageForSmoothingFlag:self.l_smoothing];
        [trackStats setNeedsForRecalculate];
    }
    trackStats.l_movingAverage = [GCActivityTrackOptions movingAverageForSmoothingFlag:self.l_smoothing];
    if (trackStats.distanceAxis != self.distanceAxis || trackStats.statsStyle!=self.statsStyle||trackStats.zoneCalculator!=self.zoneCalculator||
        ![trackStats.field isEqualToField:self.field]||![trackStats.x_field isEqualToField:self.x_field] || ![trackStats.l_field isEqualToField:self.l_field]) {
        // force reload
        [trackStats setNeedsForRecalculate];
    }
    trackStats.distanceAxis = self.distanceAxis;
    trackStats.statsStyle = self.statsStyle;
    trackStats.zoneCalculator = self.zoneCalculator;

    [trackStats setupForField:self.field xField:self.x_field andLField:self.l_field];
}

+(NSArray*)smoothingDescriptions{
    return @[@"Auto",@"None",@"Weak",@"Normal",@"Strong",@"Strongest"];
}
+(NSUInteger)movingAverageForSmoothingFlag:(gcSmoothingFlag)flag{
    NSArray * vals = @[@0,@1,@5,@10,@15,@20];
    if (flag < vals.count) {
        return [vals[flag] integerValue];
    }
    return 0;
}

@end
