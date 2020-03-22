//  MIT Licence
//
//  Created on 05/03/2013.
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

#import "GCMapLapInfoView.h"
#import "GCViewConfig.h"

@implementation GCMapLapInfoView

-(void)dealloc{
    [_lap release];
    [_activity release];
    [_gradientField release];

    [super dealloc];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if (self.lap == nil) {
        return;
    }
    //CGContextRef context = UIGraphicsGetCurrentContext();

    UIBezierPath *roundedRectanglePath = nil;

    roundedRectanglePath = [UIBezierPath bezierPathWithRect:rect];
    [[GCViewConfig backgroundForLegend] setStroke];
    [[GCViewConfig backgroundForLegend] setFill];

    roundedRectanglePath.lineWidth = 1.;
    [roundedRectanglePath fill];
    [roundedRectanglePath stroke];

    [[UIColor blackColor] setFill];

    NSDictionary * titleAttr = @{NSFontAttributeName:[GCViewConfig systemFontOfSize:12.]};
    NSDictionary * subTextAttr = @{NSFontAttributeName:[GCViewConfig systemFontOfSize:10.]};

    NSString * elapsedDesc = nil;
    NSString * distDesc = nil;

    //NSMutableArray * toDisplay = @[];

    NSString * title = nil;
    NSString * subText = nil;
    NSString * pointInfo = nil;

    if ([self.activity trackpoints].count>0) {
        NSTimeInterval interval = [self.lap timeIntervalSince:[self.activity trackpoints][0]];
        elapsedDesc = [[GCUnit unitForKey:@"second"] formatDouble:interval];
        double dist = 0.;
        for (GCTrackPoint * point in [self.activity trackpoints]) {
            if ([point.time compare:self.lap.time] == NSOrderedDescending) {
                break;
            }
            dist = point.distanceMeters;
        }
        GCNumberWithUnit * distN = [GCNumberWithUnit numberWithUnitName:@"meter" andValue:dist];
        distN = [distN convertToUnit:self.activity.distanceDisplayUnit];

        distDesc = [distN formatDouble];
        pointInfo = [NSString stringWithFormat:@"After: %@ and %@", elapsedDesc, distDesc];
    }

    if (self.gradientField == gcFieldFlagNone) {
        // Fastest km/mile display
        GCUnit * unit = self.activity.distanceDisplayUnit;
        GCNumberWithUnit * time = [self.lap numberWithUnitForField:[GCField fieldForFlag:gcFieldFlagSumDuration andActivityType:self.activity.activityType] inActivity:self.activity];

        title = [NSString stringWithFormat:@"Time: %@", time];
        subText = [NSString stringWithFormat:@"Fastest %@", unit.description];
    }else{
        GCNumberWithUnit * val = [self.lap numberWithUnitForField:self.gradientField inActivity:self.activity];
        val = [val convertToUnit:[self.activity displayUnitForField:self.gradientField]];

        title = [NSString stringWithFormat:@"%@",  val];
        subText = [self.gradientField displayName];
    }

    [title drawAtPoint:CGPointMake(7., 5.) withAttributes:titleAttr];
    [subText drawAtPoint:CGPointMake(7., 20.) withAttributes:subTextAttr];
    [pointInfo drawAtPoint:CGPointMake(7., 35.) withAttributes:subTextAttr];

}

@end
