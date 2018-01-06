//  MIT Licence
//
//  Created on 08/12/2012.
//
//  Copyright (c) 2012 Brice Rosenzweig.
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
#import "GCSimpleGraphGradientLegendView.h"
#import "RZViewConfig.h"
#import "NSDate+RZHelper.h"

@implementation GCSimpleGraphGradientLegendView
@synthesize gradientColors,first,last;

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
    [gradientColors release];
    [first release];
    [last release];

    [super dealloc];
}
#endif


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect{
    if (rect.size.height > 30.) {
        [self drawRectBoxStyle:rect];
    }else{
        [self drawRectInline:rect];
    }

}
-(void)drawRectInline:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect box = rect;

    UIBezierPath *roundedRectanglePath = nil;
    roundedRectanglePath = [UIBezierPath bezierPathWithRect:box];
    [[RZViewConfig backgroundForLegend] setStroke];
    [[RZViewConfig backgroundForLegend] setFill];

    roundedRectanglePath.lineWidth = 1.;
    [roundedRectanglePath fill];
    [roundedRectanglePath stroke];

    [[UIColor blackColor] setFill];



    NSDictionary * tAttr = @{NSFontAttributeName:[RZViewConfig systemFontOfSize:12.]};
    NSString * title = nil;
    NSString * dateStr = [first dateShortFormat];
    CGSize textSize = [dateStr sizeWithAttributes:tAttr];

    CGFloat y = (rect.size.height - textSize.height) / 2.;
    CGFloat x = 7.;
    CGFloat space = 2.;

    [dateStr drawAtPoint:CGPointMake(x, y) withAttributes:tAttr];

    x += textSize.width + space;

    size_t n = gradientColors.numberOfColors;

    CGFloat w = 5.; // (rect.size.width-8.)/n;

    CGRect gRect = CGRectMake(x, rect.size.height/2.-2.5, w, 5.);
    for (size_t idx = 0; idx<n; idx++) {
        gRect.origin.x = x;
        CGContextSetFillColorWithColor(context, gradientColors.colors[idx]);
        CGContextFillRect(context, gRect);
        x+= w;
    }
    [[UIColor blackColor] setFill];

    x+= space;
    dateStr = [last dateShortFormat];
    textSize= [dateStr sizeWithAttributes:tAttr];
    [dateStr drawAtPoint:CGPointMake(x, y) withAttributes:tAttr];

    x+= textSize.width+space;

    // Last
    x+=10.;
    title = NSLocalizedString(@"Last", @"Simple Graph Legend");
    CGRect left = rect;

    left.origin.x = x;
    left.origin.y = rect.size.height/2.-2.;
    left.size.width = 4.;
    left.size.height = 4.;
    [[UIColor blackColor] setStroke];
    [[UIColor whiteColor] setFill];
    CGContextFillRect(context, left);
    CGContextStrokeRect(context, left);

    x += space+4.;
    [title drawAtPoint:CGPointMake(x, y) withAttributes:tAttr];
}

-(void)drawRectBoxStyle:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect box = rect;

    UIBezierPath *roundedRectanglePath = nil;
    roundedRectanglePath = [UIBezierPath bezierPathWithRect:box];
    [[RZViewConfig backgroundForLegend] setStroke];
    [[RZViewConfig backgroundForLegend] setFill];

    roundedRectanglePath.lineWidth = 1.;
    [roundedRectanglePath fill];
    [roundedRectanglePath stroke];

    [[UIColor blackColor] setFill];

    NSDictionary * tAttr = @{NSFontAttributeName:[RZViewConfig systemFontOfSize:12.]};
    NSString * title = NSLocalizedString(@"Date", @"Simple Graph Legend");
    [title drawAtPoint:CGPointMake(7., 5.) withAttributes:tAttr];

    title = NSLocalizedString(@"Last", @"Simple Graph Legend");
    CGRect left = rect;
    CGSize tsize = [title sizeWithAttributes:tAttr];

    left.origin.x = left.size.width - tsize.width-2.;
    left.origin.y = 5.;
    [title drawAtPoint:left.origin withAttributes:tAttr];

    left.origin.x -= 7.;
    left.size.width = 4.;
    left.size.height = 4.;
    left.origin.y = tsize.height/2-2.+5.;

    [[UIColor blackColor] setStroke];
    [[UIColor whiteColor] setFill];
    CGContextFillRect(context, left);
    CGContextStrokeRect(context, left);

    size_t n = gradientColors.numberOfColors;

    CGFloat w = (rect.size.width-8.)/n;
    CGRect gRect = CGRectMake(4., 25., w, 5.);
    for (size_t idx = 0; idx<n; idx++) {
        CGContextSetFillColorWithColor(context, gradientColors.colors[idx]);
        CGContextFillRect(context, gRect);
        gRect.origin.x += w;
    }
    [[UIColor blackColor] setFill];
    NSDictionary * valAttr = @{NSFontAttributeName:[RZViewConfig systemFontOfSize:10]};
    NSString * dateStr = [first dateShortFormat];
    gRect.origin.x = 4.;
    gRect.origin.y = 32.;
    gRect.size = [dateStr sizeWithAttributes:valAttr];
    [dateStr drawInRect:gRect withAttributes:valAttr];

    dateStr = [last dateShortFormat];
    gRect.size = [dateStr sizeWithAttributes:valAttr];
    gRect.origin.x = rect.size.width - gRect.size.width - 4.;
    [dateStr drawInRect:gRect withAttributes:valAttr];

}


@end
