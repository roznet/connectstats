//  MIT Licence
//
//  Created on 14/01/2014.
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

#import <RZUtilsUniversal/RZUtilsUniversal.h>
#import "GCSimpleGraphRulerView.h"
#import "RZViewConfig.h"
#import <RZUtils/RZMacros.h>

@implementation GCSimpleGraphRulerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.tapGesture = RZReturnAutorelease([[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]);
        self.backgroundColor = [UIColor clearColor];
        [self addGestureRecognizer:self.tapGesture];
    }
    return self;
}

#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_graphView release];
    [_tapGesture release];

    [super dealloc];
}
#endif

-(void)tap:(UITapGestureRecognizer*)recognizer{

    gcGraphType graphType = gcGraphLine;

    // Find first serie of the right type
    NSUInteger serieIndex = 0;
    NSUInteger nDataSeries = [self.graphView.dataSource nDataSeries];
    for (serieIndex = 0; serieIndex < nDataSeries; serieIndex++) {
        graphType = [self.graphView.displayConfig graphTypeForSerie:serieIndex];
        if (graphType == gcGraphLine || graphType == gcScatterPlot) {
            break;
        }
    }
    self.serieIndex = serieIndex;

    if (self.serieIndex < nDataSeries) {
        CGPoint point = [recognizer locationInView:self];
        GCSimpleGraphGeometry * geometry =[self.graphView geometryForIndex:serieIndex];

        if (point.x >= geometry.graphDataRect.origin.x) {//Right of Y axis
            CGPoint xy = [geometry dataXYForPoint:point];
            if (self.showRuler && (CGPointEqualToPoint(self.highlightValue,xy)||CGRectContainsPoint(self.labelRect, point) )) {
                self.showRuler = false;
            }else{
                GCStatsDataSerie * serie = [(self.graphView).dataSource dataSerie:serieIndex];
                if (graphType == gcGraphLine) {
                    GCStatsInterpFunction * fct = [GCStatsInterpFunction interpFunctionWithSerie:serie];
                    xy.y = [fct valueForX:xy.x];

                    self.highlightValue = xy;
                    self.showRuler = true;
                }else if (graphType == gcScatterPlot){
                    NSUInteger i = 0;
                    NSUInteger closest = 0;
                    double minDistance = -1.;
                    double x_width = geometry.range.x_max-geometry.range.x_min;
                    double y_width = geometry.range.y_max-geometry.range.y_min;
                    for (i=0; i<serie.count; i++) {
                        GCStatsDataPoint * xypoint = serie[i];

                        double dist = sqrt((xypoint.x_data-xy.x)*(xypoint.x_data-xy.x)/(x_width*x_width) + (xypoint.y_data-xy.y)*(xypoint.y_data-xy.y)/(y_width*y_width));
                        if (minDistance<0. || dist<minDistance) {
                            minDistance = dist;
                            closest = i;
                        }
                    }
                    GCStatsDataPoint * found = serie[closest];
                    self.highlightValue = CGPointMake(found.x_data, found.y_data);
                    GCStatsDataSerie * gradient = [(self.graphView).dataSource gradientDataSerie:serieIndex];
                    found = closest < gradient.count ? gradient[closest] : nil;
                    self.scatterValue = found ? found.x_data : 0.;
                    self.showRuler = true;
                }
            }
        }else{
            self.showRuler = false;
        }
    }else{
        self.showRuler = false;
    }
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    if (self.showRuler) {
        GCSimpleGraphGeometry * geometry =[self.graphView geometryForIndex:self.serieIndex];
        gcGraphType graphType = [self.graphView.displayConfig graphTypeForSerie:self.serieIndex];

        CGPoint highlightPoint = [geometry pointForX:self.highlightValue.x andY:self.highlightValue.y];

        CGRect around = CGRectMake(highlightPoint.x-4., highlightPoint.y-4., 8., 8.);
        UIBezierPath * path = [UIBezierPath bezierPathWithOvalInRect:around];
        UIColor * fill = [UIColor colorWithRed:0.8 green:0.2 blue:0.2 alpha:0.5];
        [fill setFill];
        [fill setStroke];
        [path fill];

        path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(geometry.graphDataRect.origin.x, highlightPoint.y)];
        [path addLineToPoint:CGPointMake(highlightPoint.x, highlightPoint.y)];
        [path addLineToPoint:CGPointMake(highlightPoint.x, geometry.graphDataRect.origin.y+geometry.graphDataRect.size.height)];
        path.lineWidth = 2.;
        [path stroke];

        NSString * x_str = [[(self.graphView).dataSource xUnit] formatDouble:self.highlightValue.x];
        NSString * y_str = [[(self.graphView).dataSource yUnit:0] formatDouble:self.highlightValue.y];

        NSString * msg = nil;
        if (graphType==gcScatterPlot) {

            GCUnit * unit = [(self.graphView).dataSource respondsToSelector:@selector(gradientSerieXUnit:)] ?
                [self.graphView.dataSource gradientSerieXUnit:0]:nil;
            if (unit) {
                msg = [NSString stringWithFormat:@"%@\n%@,%@", [unit formatDouble:self.scatterValue],  x_str,y_str];
            }else{
                msg = [NSString stringWithFormat:@"%@,%@", x_str,y_str];
            }
        }else{
            msg = [NSString stringWithFormat:@"%@=%@", x_str, y_str];
        }

        NSDictionary * attr = @{NSFontAttributeName:[RZViewConfig systemFontOfSize:12.]};
        CGSize size = [msg sizeWithAttributes:attr];
        CGPoint middle = CGPointMake(geometry.graphDataRect.origin.x+geometry.graphDataRect.size.width/2.,
                                     geometry.graphDataRect.origin.y+geometry.graphDataRect.size.height/2.);
        CGPoint labelOrigin = CGPointMake( highlightPoint.x > middle.x ? highlightPoint.x-10.-size.width : highlightPoint.x+10,
                                          highlightPoint.y > middle.y ? highlightPoint.y-5.-size.height : highlightPoint.y+5.);

        CGRect wrap = CGRectZero;
        wrap.origin = labelOrigin;
        wrap.size = size;
        self.labelRect = wrap;

        path = [UIBezierPath bezierPathWithRect: CGRectInset(wrap, -2., -2.)];
        [[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.8] setFill];
        [path fill];

        [[UIColor blackColor] setFill];
        [[UIColor blackColor] setStroke];
        [msg drawAtPoint:labelOrigin withAttributes:attr];
    }
}


@end
