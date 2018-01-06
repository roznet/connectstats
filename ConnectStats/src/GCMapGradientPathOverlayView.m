//  MIT Licence
//
//  Created on 09/10/2012.
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

#import "GCMapGradientPathOverlayView.h"
#import "GCMapRouteLogic.h"
#import "GCMapGradientPathOverlay.h"

@implementation GCMapGradientPathOverlayView

-(void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context{
    GCMapGradientPathOverlay * path = (GCMapGradientPathOverlay*)self.overlay;
    NSUInteger i = 0;
    NSUInteger n = (path.points).count;
    if (n<2) {
        return;
    }
    for (i=0; i<n-1; i++) {
        GCMapRouteLogicPointHolder * p_from = (path.points)[i];
        GCMapRouteLogicPointHolder * p_to   = (path.points)[i+1];
        if (!p_to.pathStart) {
            CGColorRef color = p_from.color.CGColor;
            CGPoint from = [self pointForMapPoint:[p_from mapPoint]];
            CGPoint to = [self pointForMapPoint:[p_to mapPoint]];
            CGContextBeginPath(context);
            CGContextSetLineWidth(context, 10.f/zoomScale);
            CGContextMoveToPoint(context, from.x, from.y);
            CGContextAddLineToPoint(context, to.x, to.y);
            CGContextSetStrokeColorWithColor(context, color);
            CGContextStrokePath(context);
        }
    }
}

@end
