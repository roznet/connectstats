//  MIT Licence
//
//  Created on 11/10/2014.
//
//  Copyright (c) 2014 Brice Rosenzweig.
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

#import "TSTennisCourtView.h"
#import "TSTennisCourtGeometry.h"



@implementation TSTennisCourtView

-(TSTennisCourtView*)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor darkGrayColor];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code

    [[UIColor whiteColor] setStroke];
    [[UIColor blueColor] setFill];
    [[UIBezierPath bezierPathWithRect:_geometry.fullCourt] fill];
    [[UIColor clearColor] setFill];
    NSArray * boxes = @[

                        [UIBezierPath bezierPathWithRect:_geometry.frontHalfCourt],
                        [UIBezierPath bezierPathWithRect:_geometry.backHalfCourt],
                        [UIBezierPath bezierPathWithRect:_geometry.singleFullCourt],
                        [UIBezierPath bezierPathWithRect:_geometry.frontServiceBoxLeft],
                        [UIBezierPath bezierPathWithRect:_geometry.frontServiceBoxRight],
                        [UIBezierPath bezierPathWithRect:_geometry.backServiceBoxLeft],
                        [UIBezierPath bezierPathWithRect:_geometry.backServiceBoxRight],

                        ];
    for (UIBezierPath * path in boxes) {
        [path setLineWidth:2.];
        [path stroke];
        [path fill];
    }

    [[UIColor colorWithWhite:0.8 alpha:0.6] setFill];
    [[UIColor clearColor] setStroke];
    [[UIBezierPath bezierPathWithRect:_geometry.backNet] fill];
    [[UIBezierPath bezierPathWithRect:_geometry.frontNet] fill];

}

@end
