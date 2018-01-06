//  MIT Licence
//
//  Created on 09/02/2013.
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

#import <RZUtilsUniversal/RZUtilsUniversal.h>
#import "GCSimpleGraphLegendView.h"
#import "RZViewConfig.h"

@implementation GCSimpleGraphLegendView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setOpaque:NO];
    }
    return self;
}

#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_dataSource release];
    [_displayConfig release];

    [super dealloc];
}
#endif

-(UIColor*)useBackgroundColor{
    if (self.darkMode) {
        return [UIColor blackColor];
    }else{
        return [UIColor whiteColor];//[RZViewConfig backgroundForLegend]
    }
}

-(UIColor*)useForegroundColor{
    if (self.darkMode) {
        return [UIColor whiteColor];
    }else{
        return [UIColor blackColor];
    }
}

-(NSArray*)numberOfLegends{
    NSMutableArray * r = [NSMutableArray arrayWithCapacity:[self.dataSource nDataSeries]];
    for (NSUInteger i = 0; i<[self.dataSource nDataSeries]; i++) {
        if ([self.dataSource legend:i]) {
            [r insertObject:@(i) atIndex:0];
        }
    }
    return r;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    NSArray * legendsIdx = [self numberOfLegends];
    if (legendsIdx.count==0) {
        return;
    }
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect box = rect;
    UIBezierPath *roundedRectanglePath = nil;
    roundedRectanglePath = [UIBezierPath bezierPathWithRect:box];
    [self.useBackgroundColor setStroke];
    [self.useBackgroundColor setFill];

    roundedRectanglePath.lineWidth = 1.;
    [roundedRectanglePath fill];
    [roundedRectanglePath stroke];

    [self.useForegroundColor setFill];

    CGFloat margin =2.;
    CGFloat lineLength = 10.;

    CGFloat nextX = box.origin.x+margin;
    CGFloat nextY = box.origin.y+margin;

    NSDictionary * valAttr = @{NSFontAttributeName:[RZViewConfig systemFontOfSize:10.],NSForegroundColorAttributeName:self.useForegroundColor};

    CGPoint left = CGPointMake(nextX, nextY);

    for (NSNumber * idx in legendsIdx) {
        NSUInteger serieIdx = idx.integerValue;
        NSString * text = [self.dataSource legend:serieIdx];
        CGFloat lineWidth   = [self.displayConfig lineWidth:serieIdx];
        UIColor * color = [self.displayConfig colorForSerie:serieIdx];
        if ([color isEqual:self.useBackgroundColor]) {
            color = self.useForegroundColor;
        }
        CGSize size = [text sizeWithAttributes:valAttr];
        if (left.y + size.height > CGRectGetMaxY(box)) {
            left  = CGPointMake(nextX, box.origin.y+margin);
        }

        CGFloat right = left.x+size.width+lineLength+margin;
        if (right > nextX) {
            nextX = right;
        }

        CGContextBeginPath(context);
        CGContextSetStrokeColorWithColor(context, color.CGColor);
        CGContextSetLineWidth(context, lineWidth);
        CGContextMoveToPoint(context, left.x, left.y+size.height/2.);
        CGContextAddLineToPoint(context, left.x+lineLength,left.y+size.height/2.);
        CGContextStrokePath(context);

        [text drawAtPoint:CGPointMake(left.x+lineLength, left.y) withAttributes:valAttr];
        left.y += size.height;
    }


}

@end
