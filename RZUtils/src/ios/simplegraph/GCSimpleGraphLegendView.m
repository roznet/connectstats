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
#import "GCSimpleGraphLegendInfo.h"

@interface GCSimpleGraphLegendView ()
@property (nonatomic,retain) NSArray<GCSimpleGraphLegendInfo*>*legends;
@end

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
    [_legends release];
    [_dataSource release];
    [_displayConfig release];

    [super dealloc];
}
#endif

-(UIColor*)useBackgroundColor{
    return [self.displayConfig useBackgroundColor];
}

-(UIColor*)useForegroundColor{
    return [self.displayConfig useForegroundColor];
}

-(void)setupWithLegends:(NSArray<GCSimpleGraphLegendInfo*>*)legends{
    self.legends = legends;
    self.dataSource = nil;
}

-(void)setupLegendsFromDataSource{
    NSMutableArray * r = [NSMutableArray arrayWithCapacity:[self.dataSource nDataSeries]];
    for (NSUInteger i = 0; i<[self.dataSource nDataSeries]; i++) {
        NSString * legendText = [self.dataSource legend:i];
        if (legendText) {
            GCSimpleGraphLegendInfo * info = [[GCSimpleGraphLegendInfo alloc] init];
            CGFloat lineWidth   = [self.displayConfig lineWidth:i];
            UIColor * color = [self.displayConfig colorForSerie:i];
            if ([color isEqual:self.useBackgroundColor]) {
                color = self.useForegroundColor;
            }

            info.text = legendText;
            info.color = color;
            info.lineWidth = lineWidth;
            [r addObject:info];
            RZRelease(info);
        }
    }
    self.legends = r;
}

-(void)setupLegends{
    if( self.dataSource){
        [self setupLegendsFromDataSource];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [self setupLegends];
    if (self.legends.count==0) {
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

    for (GCSimpleGraphLegendInfo * info in self.legends) {
        NSString * text = info.text;
        CGFloat lineWidth   = info.lineWidth;
        UIColor * color = info.color;
        
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
