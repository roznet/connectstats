//  MIT Licence
//
//  Created on 29/11/2014.
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

#import "TSCourtReportAnnotationView.h"
#import "TSTennisCourtAnnotatedLocation.h"


@implementation TSCourtReportAnnotationView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code

    for (TSTennisCourtAnnotatedLocation * aloc in self.annotations) {
        [aloc.color setStroke];
        switch (aloc.style) {
            case tsAnnotationStyleCircle:
                [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(aloc.location.x-2., aloc.location.y-2., 4., 4.)] stroke];

                break;
            case tsAnnotationStyleDot:
                [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(aloc.location.x-0.5, aloc.location.y-0.5, 1., 1.)] stroke];
                break;
            default:

            {
                UIBezierPath * rv = [UIBezierPath bezierPath];
                [rv moveToPoint:aloc.location];
                [rv addLineToPoint:aloc.location];
                [rv setLineWidth:1.];
                [rv stroke];
                break;
            }
            case tsAnnotationStyleCross:
            {
                UIBezierPath * rv = [UIBezierPath bezierPath];
                [rv moveToPoint:CGPointMake(aloc.location.x-2, aloc.location.y-2)];
                [rv addLineToPoint:CGPointMake(aloc.location.x+2, aloc.location.y+2)];
                [rv setLineWidth:1.];
                [rv stroke];
                rv = [UIBezierPath bezierPath];
                [rv moveToPoint:CGPointMake(aloc.location.x+2, aloc.location.y-2)];
                [rv addLineToPoint:CGPointMake(aloc.location.x-2, aloc.location.y+2)];
                [rv setLineWidth:1.];
                [rv stroke];
                break;
            }
            case tsAnnotationStylePlus:
            {
                UIBezierPath * rv = [UIBezierPath bezierPath];
                [rv moveToPoint:CGPointMake(aloc.location.x-2, aloc.location.y)];
                [rv addLineToPoint:CGPointMake(aloc.location.x+2, aloc.location.y)];
                [rv setLineWidth:1.];
                [rv stroke];
                rv = [UIBezierPath bezierPath];
                [rv moveToPoint:CGPointMake(aloc.location.x, aloc.location.y-2)];
                [rv addLineToPoint:CGPointMake(aloc.location.x, aloc.location.y+2)];
                [rv setLineWidth:1.];
                [rv stroke];
                break;
            }



        }
    }
}


@end
