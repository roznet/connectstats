//  MIT Licence
//
//  Created on 19/06/2015.
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

#import "RZMultiSliderKnob.h"
#import "RZMacros.h"

@implementation RZMultiSliderKnob
#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_attributedText release];
    [super dealloc];
}
#endif

- (void)drawRect:(CGRect)rect {
    // Drawing code
    UIBezierPath * circle = [UIBezierPath bezierPathWithOvalInRect:rect];
    [[UIColor blueColor] setFill];
    [circle fill];

    if (self.attributedText) {
        CGSize textSize = [self.attributedText size];
        CGPoint center = CGPointMake(rect.origin.x+rect.size.width/2. - textSize.width/2.,
                                     rect.origin.y+rect.size.height/2.-textSize.height/2.);
        [self.attributedText drawAtPoint:center];
    }
}

@end
