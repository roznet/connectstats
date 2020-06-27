//  MIT Licence
//
//  Created on 20/10/2012.
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

#import "GCMapLegendView.h"
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import "GCViewConfig.h"

@implementation GCMapLegendView
@synthesize min,max,mid,gradientColors,activity;

-(GCMapLegendView*)initWithFrame:(CGRect)rect{
    self = [super initWithFrame:rect];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque=NO;
        self.clearsContextBeforeDrawing=YES;
    }
    return self;
}

-(void)dealloc{
    [gradientColors release];
    [activity release];
    [_field release];
    [super dealloc];
}

-(void)drawRect:(CGRect)rect {
    if (self.field == nil) {
        self.alpha = 0.;
        return;
    }else{
        self.alpha = 1.;
    }
    if (!activity || !activity.activityType) {
        return;
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIBezierPath *roundedRectanglePath = nil;
    roundedRectanglePath = [UIBezierPath bezierPathWithRect:rect];
    [[GCViewConfig backgroundForLegend] setStroke];
    [[GCViewConfig backgroundForLegend] setFill];

    roundedRectanglePath.lineWidth = 1.;
    [roundedRectanglePath fill];
    [roundedRectanglePath stroke];

    [[UIColor blackColor] setFill];
    GCUnit * unit = [activity displayUnitForField:self.field];
    NSString * title = [self.field displayNameWithUnits:unit];
    [title drawAtPoint:CGPointMake(7., 5.) withAttributes:@{NSFontAttributeName:[GCViewConfig systemFontOfSize:12.]}];

    size_t n = gradientColors.numberOfColors;

    CGFloat w = (rect.size.width-8.)/n;
    CGRect gRect = CGRectMake(4., 25., w, 5.);
    for (size_t idx = 0; idx<n; idx++) {
        [gradientColors.colors[idx] setFill];
        CGContextFillRect(context, gRect);
        gRect.origin.x += w;
    }
    [[UIColor blackColor] setFill];
    UIFont * valFont = [GCViewConfig systemFontOfSize:10.];
    NSString * val = [activity formatValueNoUnits:min forField:self.field];
    gRect.origin.x = 4.;
    gRect.origin.y = 32.;
    NSDictionary * valAttr = @{NSFontAttributeName:valFont};
    gRect.size = [val sizeWithAttributes:valAttr];
    [val drawInRect:gRect withAttributes:valAttr];

    val = [activity formatValueNoUnits:mid forField:self.field];
    gRect.size = [val sizeWithAttributes:valAttr];
    gRect.origin.x = rect.size.width/2. - gRect.size.width/2.;
    [val drawInRect:gRect withAttributes:valAttr];

    val = [activity formatValueNoUnits:max forField:self.field];
    gRect.size = [val sizeWithAttributes:valAttr];
    gRect.origin.x = rect.size.width - gRect.size.width - 4.;
    [val drawInRect:gRect withAttributes:valAttr];

}


@end
