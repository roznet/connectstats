//  MIT Licence
//
//  Created on 18/04/2015.
//
//  Copyright (c) 2015 Brice Rosenzweig.
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

#import "GCMapWindCompass.h"
#import "GCViewConfig.h"

@implementation GCMapWindCompass


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.backgroundColor = [UIColor clearColor];

    if (!self.enabled) {
        return;
    }

    [[UIColor blackColor] setStroke];

    CGPoint center = CGPointMake(rect.origin.x + rect.size.width/2.0, rect.origin.y + rect.size.height/2.0);
    CGFloat radius = 0.95*MIN(rect.size.width, rect.size.height)/2.0;

    UIBezierPath * outCircle = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0.0 endAngle:M_PI*2.0 clockwise:YES];
    [outCircle stroke];

    [[[UIColor darkGrayColor] colorWithAlphaComponent:0.7] setStroke];
    CGFloat innerRadius = radius * 0.3;
    for (NSInteger i=0; i<16.; i++) {
        CGFloat angleFrom = 2.0 * M_PI * i / 16.;
        CGFloat angleTo   = 2.0 * M_PI * (i+1)/16.;

        CGFloat angleEnd = angleTo;
        if (i%2==0) {
            angleEnd = angleFrom;
        }
        CGFloat radiusEnd = radius;
        if (i%4==1 || i%4==2) {
            radiusEnd = radius * 0.6;
        }
        CGPoint pointEnd = CGPointMake(center.x+ cosf(angleEnd) * radiusEnd, center.y+ sinf(angleEnd) * radiusEnd);
        UIBezierPath * innerAngle = [UIBezierPath bezierPathWithArcCenter:center radius:innerRadius  startAngle:angleFrom endAngle:angleTo clockwise:YES];
        [innerAngle addLineToPoint:pointEnd];
        [innerAngle closePath];
        [innerAngle stroke];
    }

    // Wind
    CGFloat usePercent = MAX(self.percent, 0.40);
    CGFloat windAngleFrom = self.direction - M_PI/8.*usePercent;
    CGFloat windAngleTo   = self.direction + M_PI/8.*usePercent;

    CGFloat windRadiusEnd = radius * (1. - usePercent);
    CGPoint windPointEnd = CGPointMake(center.x+cosf(self.direction)*windRadiusEnd, center.y + sinf(self.direction)*windRadiusEnd);
    UIBezierPath * windCone = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:windAngleFrom endAngle:windAngleTo clockwise:YES];
    [windCone addLineToPoint:windPointEnd];
    [windCone closePath];
    [[[UIColor redColor] colorWithAlphaComponent:0.6] setFill];
    [windCone fill];

}


@end
