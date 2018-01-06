//  MIT Licence
//
//  Created on 29/11/2015.
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

#import "GCCellGridConfig.h"

#ifdef __LP64__
NS_INLINE BOOL RZEqualsCGFloat( CGFloat val1, CGFloat val2) { return fabs( val1-val2) < 1.e-5; };
#else
NS_INLINE BOOL RZEqualsCGFloat( CGFloat val1, CGFloat val2) { return fabsf( val1-val2) < 1.e-2; };
#endif


@implementation GCCellGridConfig

+(GCCellGridConfig*)cellGridConfig{
    return RZReturnAutorelease([[GCCellGridConfig alloc] init]);
}

-(BOOL)shouldAdjustsFontSizeToFitWidth:(CGRect)rect inCellRect:(CGRect)cellRect{
    return (rect.size.width>cellRect.size.width && self.horizontalOverflow == NO);
}

-(CGRect)positionSize:(CGSize)size inCellRect:(CGRect)cellRect inViewRect:(CGRect)viewRect{

    CGRect rv = cellRect;

    BOOL leftMost = RZEqualsCGFloat(cellRect.origin.x, viewRect.origin.x );
    BOOL rightMost = RZEqualsCGFloat( CGRectGetMaxX(cellRect), CGRectGetMaxX(viewRect) );

    BOOL topMost = RZEqualsCGFloat(cellRect.origin.y, viewRect.origin.y );
    BOOL bottomMost = RZEqualsCGFloat( CGRectGetMaxY(cellRect), CGRectGetMaxY(viewRect));

    gcHorizontalAlign useHAlign = self.horizontalAlign;
    if (useHAlign == gcHorizontalAlignAuto) {
        if (leftMost && rightMost) {
            useHAlign=gcHorizontalAlignLeft;
        }else if (leftMost) {
            useHAlign=gcHorizontalAlignLeft;
        }else if(rightMost){
            useHAlign=gcHorizontalAlignRight;
        }else{
            useHAlign=gcHorizontalAlignCenter;
        }
    }

    gcVerticalAlign useVAlign = self.verticalAlign;
    if (useVAlign == gcVerticalAlignAuto) {
        if (topMost) {
            useVAlign = gcVerticalAlignCenter;
        }else if( bottomMost){
            useVAlign = gcVerticalAlignCenter;
        }else{
            useVAlign = gcVerticalAlignCenter;
        }
    }

    if (useHAlign == gcHorizontalAlignCenter) {
        rv.origin.x+=cellRect.size.width/2.-size.width/2.;
    }else if (useHAlign == gcHorizontalAlignRight){
        rv.origin.x+=cellRect.size.width-size.width-self.marginX;
    }else if (useHAlign == gcHorizontalAlignLeft){
        rv.origin.x+=self.marginX;
    }else if (useHAlign == gcHorizontalAlignFill){
        size.width = cellRect.size.width;
    }

    if (useVAlign == gcVerticalAlignTop){
        rv.origin.y+=self.marginY;
    }else if (useVAlign==gcVerticalAlignBottom){
        rv.origin.y += cellRect.size.height-size.height-self.marginY;
    }else if (useVAlign==gcVerticalAlignCenter){
        rv.origin.y += cellRect.size.height/2.-size.height/2.;
    }else if(useVAlign==gcVerticalAlignFill){
        size.height = cellRect.size.height;
    }
    rv.size = size;
    return rv;
}

@end

