//  MIT Licence
//
//  Created on 22/09/2012.
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

#import "GCSimpleGraphView.h"
#import "RZViewConfig.h"
#import "RZLog.h"
#import "RZMacros.h"

#if TARGET_OS_IPHONE
#define UIGRAPHICCURRENTCONTEXT() UIGraphicsGetCurrentContext()
#else
#import <CoreGraphics/CoreGraphics.h>
#import "NSBezierPath+QuartzHelper.h"
#import <AppKit/AppKit.h>
#define UIGRAPHICCURRENTCONTEXT() [[NSGraphicsContext currentContext] CGContext]
#endif
@interface GCSimpleGraphView ()

@end

@implementation GCSimpleGraphView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.displayConfig = RZReturnAutorelease([[GCSimpleGraphDefaultDisplayConfig alloc] init]);
        self.geometries = [NSMutableArray arrayWithCapacity:2];
    }
    return self;
}

#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_geometries release];
    [_dataSource release];
    [_displayConfig release];
    /*
    if (_backgroundGradient) {
        CGGradientRelease(_backgroundGradient);
    }*/
    [super dealloc];
}
#endif

#pragma mark - Geometry

-(BOOL)xAxisIsVertical{
    return [_displayConfig respondsToSelector:@selector(xAxisIsVertical)] ? [_displayConfig xAxisIsVertical] : false;
}

-(GCSimpleGraphGeometry *)geometryForIndex:(NSUInteger)idx{
    NSUInteger axis = [_dataSource respondsToSelector:@selector(axisForSerie:)]?[_dataSource axisForSerie:idx]:0;

    if (axis < (self.geometries).count) {
        return (self.geometries)[axis];
    }

    return (self.geometries).count>0? (self.geometries)[0] : nil;
}

-(void)calculateGeometry{
    self.geometries = [NSMutableArray arrayWithCapacity:2];

    CGPoint zoom= CGPointMake(0., 0.);
    CGPoint offset = CGPointMake(0., 0.);
    if ([_displayConfig respondsToSelector:@selector(zoomPercentage)] && [_displayConfig respondsToSelector:@selector(offsetPercentage)]) {
        zoom = [_displayConfig zoomPercentage];
        offset = [_displayConfig offsetPercentage];
    }


    BOOL xAxisIsVertical = [_displayConfig respondsToSelector:@selector(xAxisIsVertical)] ? [_displayConfig xAxisIsVertical] : false;
    BOOL maximizeGraph = [_displayConfig respondsToSelector:@selector(maximizeGraph)]?[_displayConfig maximizeGraph]:false;

    CGRect baseRect = self.drawRect;

    if (baseRect.size.width == 0 && self.frame.size.width != 0) {
        self.drawRect = self.frame;
    }
    for (NSUInteger i=0; i<[_dataSource nDataSeries]; i++) {
        NSUInteger axis = [_dataSource respondsToSelector:@selector(axisForSerie:)]?[_dataSource axisForSerie:i]:0;
        if (axis>=(self.geometries).count) {

            GCSimpleGraphGeometry * geometry = RZReturnAutorelease([[GCSimpleGraphGeometry alloc] init]);
            geometry.drawRect = self.drawRect;
            geometry.zoomPercentage = zoom;
            geometry.offsetPercentage = offset;
            geometry.dataSource = _dataSource;
            geometry.axisIndex = axis;
            geometry.serieIndex = i;
            geometry.xAxisIsVertical = xAxisIsVertical;
            geometry.maximizeGraph = maximizeGraph;
            [geometry calculate];
            [self.geometries addObject:geometry];
        }
    }
}


#pragma mark - Colors

-(RZColor*)axisColor{
    RZColor * rv = nil;

    if ([self.displayConfig respondsToSelector:@selector(axisColor)]) {
        rv = [self.displayConfig axisColor];
    }
    if (rv == nil) {
        rv = [RZColor blueColor];
    }

    return rv;
}

-(RZColor*)useBackgroundColor{
    if ([self.displayConfig respondsToSelector:@selector(useBackgroundColor)]) {
        RZColor * color = [self.displayConfig useBackgroundColor];
        if (color) {
            return color;
        }
    }
    if (self.darkMode) {
        return [RZColor blackColor];
    }else{
        return [RZColor whiteColor];
    }
}

-(RZColor*)useForegroundColor{
    if ([self.displayConfig respondsToSelector:@selector(useForegroundColor)]) {
        RZColor * color = [self.displayConfig useForegroundColor];
        if (color) {
            return color;
        }
    }
    if (self.darkMode) {
        return [RZColor whiteColor];
    }else{
        return [RZColor blackColor];
    }
}

-(RZColor*)graphColor:(NSUInteger)idx{
    RZColor * color = [_displayConfig colorForSerie:idx];
    if ([color isEqual:[self useBackgroundColor]]) {
        color = [self useForegroundColor];
    }
    return color;
}

-(RZColor*)graphFillColor:(NSUInteger)idx{
    RZColor * fillColor = nil;
    if ([_displayConfig respondsToSelector:@selector(fillColorForSerie:)]) {
        fillColor = [_displayConfig fillColorForSerie:idx];
    }
    return fillColor;
}

-(void)setupGradientColors:(GCViewGradientColors**)gradientColors
                  function:(id<GCStatsFunction>*)gradientFunction
                 dataSerie:(GCStatsDataSerie**)gradientDataSerie
                  forIndex:(NSUInteger)idx
                     count:(NSUInteger)dataCount{
    *gradientColors = [_displayConfig respondsToSelector:@selector(gradientColors:)] ? [_displayConfig gradientColors:idx] : nil;
    *gradientFunction = [_dataSource respondsToSelector:@selector(gradientFunction:)] ? [_dataSource gradientFunction:idx] : nil;
    *gradientDataSerie = [_dataSource respondsToSelector:@selector(gradientDataSerie:)] ? [_dataSource gradientDataSerie:idx] : nil;

    if ((*gradientDataSerie) && ([(*gradientDataSerie) count] != dataCount)){
        RZLog(RZLogError, @"Incompatible gradient size: %d != %d",(int)[*gradientDataSerie count],(int)dataCount);
        *gradientDataSerie = nil;
        *gradientFunction = nil;
    }

}

#pragma mark - Graph Drawing

-(void)drawGraphLines:(NSUInteger)idx{

    NSUInteger i = 0;
    GCStatsDataSerie * data = [_dataSource dataSerie:idx];
    GCSimpleGraphGeometry * geometry = [self geometryForIndex:idx];

    NSUInteger n = [data count];
    if (data == nil || n == 0) {
        return;
    }
    CGFloat lineWidth = [_displayConfig lineWidth:idx];

    RZColor * color = [self graphColor:idx];

    GCViewGradientColors * gradientColors = nil;
    id<GCStatsFunction> gradientFunction = nil;
    GCStatsDataSerie * gradientDataSerie = nil;

    [self setupGradientColors:&gradientColors function:&gradientFunction dataSerie:&gradientDataSerie forIndex:idx count:data.count];

    CGPoint range_min = geometry.rangeMinPoint;
    CGPoint range_max = geometry.rangeMaxPoint;

    CGRect dataXYRect = geometry.dataXYRect;
    CGPoint axis=[geometry pointForX:dataXYRect.origin.x andY:dataXYRect.origin.y];

    RZColor * fillColor = [self graphFillColor:idx];

    CGFloat x = [data dataPointAtIndex:0].x_data;
    CGFloat y = [data dataPointAtIndex:0].y_data;
    CGPoint first =[geometry pointForX:x andY:y];
    CGPoint last = first;
    int badpoints=0;
    RZBezierPath * path = nil;

    CGFloat last_x = first.x;

    path = [RZBezierPath bezierPath];
    path.lineWidth = lineWidth;
    if (CGRectContainsPoint(self.drawRect, first)) {
        [path moveToPoint:first];
    }
    [color setStroke];
    CGColorRef currentColor = color.CGColor;
    CGColorRef nextColor = color.CGColor;

    BOOL shouldFill = (fillColor != nil);
    BOOL shouldFillNext = false;

    if (gradientColors && gradientDataSerie) {
        shouldFill = false;
    }
    NSUInteger paths = 0;
    NSDate * start = [NSDate date];
    BOOL lastPointHasValue = true;

    for (i=1; i<n; i++) {

        BOOL endCurrentPathSegment = (i==n-1);
        BOOL addCurrentPoint = true;

        GCStatsDataPoint * point = [data dataPointAtIndex:i];

        if (!point.hasValue) {
            endCurrentPathSegment = true;
            addCurrentPoint = false;
            lastPointHasValue = false;
            shouldFillNext = shouldFill;
        }

        CGPoint from    = last;
        CGPoint to      = [geometry pointForX:point.x_data andY:point.y_data];

        CGPoint from_adj = lastPointHasValue ? from : to;
        CGPoint to_adj   = to;

        if (to.x >= range_min.x || to.x <= range_max.x) {
            if (gradientColors && gradientDataSerie) {
                CGFloat val = gradientFunction ?
                [gradientFunction valueForX:[gradientDataSerie dataPointAtIndex:i-1].x_data]
                :
                [gradientDataSerie dataPointAtIndex:i].y_data;
                CGColorRef thisColor = [gradientColors colorsForValue:val];
                if (currentColor == nil || !CGColorEqualToColor(thisColor, currentColor)) {
                    endCurrentPathSegment = true;
                    nextColor = thisColor;
                    shouldFillNext = (val != 0.) && (fillColor != nil);
                }
                currentColor = thisColor;
            }


            if (from_adj.y>range_max.y || from_adj.y<range_min.y) {
                from_adj.y = MAX(MIN(from_adj.y, range_max.y),range_min.y);
                from_adj.x = from.x+(from_adj.y-from.y)/(to.y-from.y)*(to.x-from.x);
            }
            if (from_adj.x>range_max.x || from_adj.x<range_min.x) {
                from_adj.x = MAX(MIN(from_adj.x,range_max.x),range_min.x);
                from_adj.y = from.y+(from_adj.x-from.x)/(to.x-from.x)*(to.y-from.y);
            }
            if (to_adj.y>range_max.y || to_adj.y<range_min.y) {
                to_adj.y = MAX(MIN(to_adj.y, range_max.y), range_min.y);
                to_adj.x = from.x+(to_adj.y-from.y)/(to.y-from.y)*(to.x-from.x);
            }
            if (to_adj.x>range_max.x || to_adj.x<range_min.x) {
                to_adj.x = MAX(MIN(to_adj.x, range_max.x), range_min.x);
                to_adj.y = from.y+(to_adj.x-from.x)/(to.x-from.x)*(to.y-from.y);
            }
        }else{
            addCurrentPoint = false;
        }

        if ( addCurrentPoint ) {
            if (path.empty) {
                [path moveToPoint:from_adj];
                first = from_adj;
            }
            if (fabs(to_adj.x-last_x)>0.5) {
                paths++;
                [path addLineToPoint:to_adj];
                last_x = to_adj.x;
            }
            lastPointHasValue = true;
        }
        if( endCurrentPathSegment ){
            if (!path.empty) {
                [path stroke];
                if (shouldFill) {
                    [fillColor setFill];
                    [[RZColor clearColor] setStroke];

                    RZBezierPath * pathIn = [RZBezierPath bezierPathWithCGPath:path.CGPath];
                    [pathIn addLineToPoint:CGPointMake(last.x, axis.y)];
                    [pathIn addLineToPoint:CGPointMake(first.x, axis.y)];
                    [pathIn addLineToPoint:CGPointMake(first.x, first.y)];
                    [pathIn fill];
                }
                shouldFill = shouldFillNext;
            }
            currentColor = nextColor;
            [[RZColor colorWithCGColor:currentColor] setStroke];
            [path removeAllPoints];
            paths = 0;
        }
        last = to;
    }

    BOOL highlightCurrent = [_displayConfig highlightCurrent:idx];
    CGPoint currentPoint = [_dataSource currentPoint:idx];
    BOOL disableHighlight = [_displayConfig disableHighlight:idx];

    if (!disableHighlight && highlightCurrent) {
        CGPoint hPoint = [geometry pointForX:currentPoint.x andY:currentPoint.y];
        CGPoint yPoint = CGPointMake(range_min.x, hPoint.y);
        CGPoint xPoint = CGPointMake(hPoint.x, range_min.y);
        [[RZColor blackColor] setStroke];
        RZBezierPath * pathIn = [RZBezierPath bezierPath];

        [pathIn moveToPoint:yPoint];
        [pathIn addLineToPoint:hPoint];
        [pathIn addLineToPoint:xPoint];

        [pathIn stroke];
    }

    NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:start];
    if (elapsed>0.1) {
        RZLog(RZLogWarning, @"paths %d pts/%d in %0.1f secs %@", (int)paths, (int)[data count], elapsed, [_dataSource title]);
    }
    if (badpoints>1) {
        RZLog(RZLogWarning, @"Total of %d bad points", badpoints);
    }

}

-(void)drawGraphBars:(NSUInteger)idx{
    NSUInteger i = 0;
    GCStatsDataSerie * data = [_dataSource dataSerie:idx];
    GCSimpleGraphGeometry * geometry = [self geometryForIndex:idx];

    NSUInteger n = [data count];
    if (data == nil || n == 0) {
        return;
    }

    BOOL xAxisIsVertical = [_displayConfig respondsToSelector:@selector(xAxisIsVertical)] ? [_displayConfig xAxisIsVertical] : false;

    RZColor * color = [self graphColor:idx];

    GCViewGradientColors * gradientColors = nil;
    id<GCStatsFunction> gradientFunction = nil;
    GCStatsDataSerie * gradientDataSerie = nil;

    [self setupGradientColors:&gradientColors function:&gradientFunction dataSerie:&gradientDataSerie forIndex:idx count:data.count];

    gcStatsRange range= geometry.range;
    CGPoint range_min = geometry.rangeMinPoint;
    CGPoint range_max = geometry.rangeMaxPoint;

    if (xAxisIsVertical) {
        range_min = geometry.rangeMaxPoint;
        range_max = geometry.rangeMinPoint;
    }

    CGRect dataXYRect = geometry.dataXYRect;
    CGPoint axis=[geometry pointForX:dataXYRect.origin.x andY:dataXYRect.origin.y];
    GCStatsDataPoint * point = [data dataPointAtIndex:0];
    CGPoint last      = [geometry pointForX:point.x_data andY:point.y_data];

    CGContextRef context = UIGRAPHICCURRENTCONTEXT();
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGPoint rightMost = last;
    BOOL skip = false;
    for (i=1; i<n; i++) {
        CGPoint from    = last;

        point = [data dataPointAtIndex:i];
        CGPoint to      = [geometry pointForX:point.x_data andY:point.y_data];
        skip = [[data dataPointAtIndex:i-1] isKindOfClass:[GCStatsDataPointNoValue class]];
        if (to.x >= range_min.x || to.x <= range_max.x) {
            if (gradientColors && gradientDataSerie) {
                CGFloat val = gradientFunction ?
                [gradientFunction valueForX:point.x_data]
                :
                [gradientDataSerie dataPointAtIndex:i-1].y_data;
                CGColorRef thisColor = [gradientColors colorsForValue:val];
                CGContextSetStrokeColorWithColor(context, thisColor);
                CGContextSetFillColorWithColor(context, thisColor);
            }

            CGPoint from_adj = from;
            CGPoint to_adj   = to;

            if (xAxisIsVertical) {
                to_adj.x = from_adj.x;
            }else{
                to_adj.y = from_adj.y;
            }
            if (!skip) {
                CGRect marker;
                if (xAxisIsVertical) {
                    marker = CGRectMake(from_adj.x, from_adj.y, -(from_adj.x-axis.x), to_adj.y-from_adj.y);
                }else{
                    marker = CGRectMake(from_adj.x, from_adj.y, to_adj.x-from_adj.x, -(from_adj.y-axis.y));
                }
                //NSLog(@"%lu: %@ %@", (unsigned long)i, NSStringFromCGPoint(to),  NSStringFromCGRect(marker));
                CGContextFillRect(context, marker);
                CGContextStrokeRect(context, marker);
            }
            if (to.x > rightMost.x) {
                rightMost = to;
            }
        }
        last = to;
    }
    if (!xAxisIsVertical && rightMost.x < range_max.x) {
        CGRect marker = CGRectMake(rightMost.x, rightMost.y, range.x_max-rightMost.x, -(rightMost.y-axis.y));
        CGContextFillRect(context, marker);
        CGContextStrokeRect(context, marker);
    }

}
-(void)drawGraphXY:(NSUInteger)idx{
    NSUInteger i = 0;
    GCStatsDataSerie * data = [_dataSource dataSerie:idx];

    GCSimpleGraphGeometry * geometry = [self geometryForIndex:idx];

    NSUInteger n = [data count];
    if (data == nil || n == 0) {
        return;
    }

    CGFloat lineWidth = [_displayConfig lineWidth:idx];

    RZColor * color = [self graphColor:idx];

    GCViewGradientColors * gradientColors = nil;
    id<GCStatsFunction> gradientFunction = nil;
    GCStatsDataSerie * gradientDataSerie = nil;

    [self setupGradientColors:&gradientColors function:&gradientFunction dataSerie:&gradientDataSerie forIndex:idx count:data.count];


    CGPoint range_min = geometry.rangeMinPoint;
    CGPoint range_max = geometry.rangeMaxPoint;

    CGFloat x = [data dataPointAtIndex:0].x_data;
    CGFloat y = [data dataPointAtIndex:0].y_data;
    CGPoint first =[geometry pointForX:x andY:y];
    RZBezierPath * path = nil;

    path = [RZBezierPath bezierPath];
    path.lineWidth = lineWidth;
    if (CGRectContainsPoint(self.drawRect, first)) {
        [path moveToPoint:first];
    }
    [color setStroke];

    CGContextRef context = UIGRAPHICCURRENTCONTEXT();

    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGPoint to =CGPointMake(0., 0.);
    BOOL hasTransparent = false;
    for (NSUInteger ii=0; ii<n; ii++) {
        //i = n-1-ii;
        i = ii;
        if (gradientColors && (gradientDataSerie)) {
            CGFloat val = gradientFunction ?
            [gradientFunction valueForX:[gradientDataSerie dataPointAtIndex:i].x_data]
            :
            [gradientDataSerie dataPointAtIndex:i].y_data;
            CGColorRef thisColor = [gradientColors colorsForValue:val];
            if (CGColorGetAlpha(thisColor)<1.) {
                hasTransparent = true;
            }
            CGContextSetStrokeColorWithColor(context, [RZColor blackColor].CGColor);
            CGContextSetFillColorWithColor(context, thisColor);
        }
        to = [geometry pointForX:[data dataPointAtIndex:i].x_data andY:[data dataPointAtIndex:i].y_data];
        if (to.x >= range_min.x && to.x <= range_max.x && to.y >= range_min.y && to.y <= range_max.y) {
            CGRect marker = CGRectMake(to.x-lineWidth/2., to.y-lineWidth/2., lineWidth, lineWidth);
            CGContextFillRect(context, marker);
        }
    }

    if (hasTransparent) {
        // second layer to highlight non transparent
        for (NSUInteger ii=0; ii<n; ii++) {
            //i = n-1-ii;
            i = ii;
            if (gradientColors && (gradientDataSerie)) {
                CGFloat val = gradientFunction ?
                [gradientFunction valueForX:[gradientDataSerie dataPointAtIndex:i].x_data]
                :
                [gradientDataSerie dataPointAtIndex:i].y_data;
                CGColorRef thisColor = [gradientColors colorsForValue:val];
                if (CGColorGetAlpha(thisColor)<1.) {
                    continue;
                }
                CGContextSetStrokeColorWithColor(context, [RZColor blackColor].CGColor);
                CGContextSetFillColorWithColor(context, thisColor);
            }
            to = [geometry pointForX:[data dataPointAtIndex:i].x_data andY:[data dataPointAtIndex:i].y_data];
            if (to.x > range_min.x && to.x < range_max.x && to.y > range_min.y && to.y < range_max.y) {
                CGRect marker = CGRectMake(to.x-lineWidth/2., to.y-lineWidth/2., lineWidth, lineWidth);
                CGContextFillRect(context, marker);
            }
        }
    }
    BOOL highlightCurrent = [_displayConfig highlightCurrent:idx];
    CGPoint currentPoint = [_dataSource currentPoint:idx];
    BOOL disableHighlight = [_displayConfig disableHighlight:idx];

    if (!disableHighlight) {
        if (highlightCurrent) {
            to = [geometry pointForX:currentPoint.x andY:currentPoint.y];
        }
        CGContextSetStrokeColorWithColor(context, [self useBackgroundColor].CGColor);
        CGContextSetFillColorWithColor(context, [self useBackgroundColor].CGColor);
        CGRect marker = CGRectMake(to.x-lineWidth/2., to.y-lineWidth/2., lineWidth, lineWidth);
        CGContextStrokeRect(context, marker);
        CGContextFillRect(context, marker);
        lineWidth+=1.;
        CGContextSetStrokeColorWithColor(context, [self useForegroundColor].CGColor);
        marker = CGRectMake(to.x-lineWidth/2., to.y-lineWidth/2., lineWidth, lineWidth);
        CGContextStrokeRect(context, marker);
    }

}
#pragma mark - Drawing Areas

-(void)drawAxisKnobs{
    GCSimpleGraphGeometry * geometry = [self geometryForIndex:0];

    CGRect baseRect = self.drawRect;

    NSString * title = [_dataSource title];
    NSDictionary * titleAttr = @{NSFontAttributeName:[geometry titleFont]?:[RZViewConfig systemFontOfSize:12.],NSForegroundColorAttributeName:self.useForegroundColor};
    NSDictionary * knobAttr = @{NSFontAttributeName:[geometry axisFont]?:[RZViewConfig systemFontOfSize:12.],NSForegroundColorAttributeName:self.useForegroundColor};
    gcGraphType gtype = [_displayConfig graphTypeForSerie:0];

    [geometry calculateAxisKnobRect:gtype andAttribute:knobAttr];

    [title drawInRect:geometry.titleRect withAttributes:titleAttr];

    [[self axisColor] setStroke];

    GCAxisKnob * last = nil;

    BOOL xAxisIsVertical = self.xAxisIsVertical;

    for (GCAxisKnob * aKnob in geometry.xAxisKnobs) {
        if (aKnob.rect.size.width > 0. ) {
            if (last && [last.label isEqualToString:aKnob.label]) {
                // Skip if same text as last one to avoid duplicate
            }else{
                BOOL tooClose = false;
                if (last) {
                    if (xAxisIsVertical) {
                        tooClose = (last.rect.origin.y - CGRectGetMaxY( aKnob.rect)) < last.rect.size.height/3.;
                    }else{
                        tooClose = (aKnob.rect.origin.x - CGRectGetMaxX(last.rect)) < last.rect.size.width/3.;
                    }
                }
                if (!tooClose) {
                    [aKnob.label drawInRect:aKnob.rect withAttributes:knobAttr];
                    last = aKnob;
                }
            }

            CGPoint one = [geometry pointForX:aKnob.value andY:geometry.knobRange.y_min];
            if (CGRectContainsPoint(baseRect, one)) {
                RZBezierPath * path = [[RZBezierPath alloc] init];
                [path moveToPoint:one];
                if (xAxisIsVertical) {
                    one.x -= 2.;
                }else{
                    one.y+=2.;
                }
                [path addLineToPoint:one];
                [path stroke];
                RZRelease(path);
            }

        }
    }

    [[RZColor lightGrayColor] setStroke];
    [[RZColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.2] setStroke];
    //CGFloat dashPattern[2] = {1.0, 1.0};

    CGFloat x_min = geometry.dataXYRect.origin.x;
    CGFloat x_max = geometry.dataXYRect.origin.x+geometry.dataXYRect.size.width;

    for (GCAxisKnob * aKnob in geometry.yAxisKnobs) {
        CGPoint start = [geometry pointForX:x_min andY:aKnob.value];
        CGPoint end   = [geometry pointForX:x_max andY:aKnob.value];

        if (CGRectContainsPoint(baseRect, aKnob.rect.origin) && CGRectContainsPoint(baseRect, end)) {
            RZBezierPath * path = [[RZBezierPath alloc] init];
            //[path setLineDash:dashPattern count:2 phase:0.0];

            path.lineWidth = 0.5;
            CGFloat dashes[] = {1., 2.};
            [path setLineDash:dashes count:2 phase:4];
            [path moveToPoint:start];
            [path addLineToPoint:end];
            [path stroke];
            RZRelease(path);

            [aKnob.label drawInRect:aKnob.rect withAttributes:knobAttr];
        }
    }
}

-(void)drawAxis{
    GCSimpleGraphGeometry * geometry = [self geometryForIndex:0];

    RZBezierPath * axis = [RZBezierPath bezierPath];
    if (self.xAxisIsVertical) {
        CGRect dataXYRect = geometry.dataXYRect;
        CGPoint topLeft = [geometry pointForX:dataXYRect.origin.x+dataXYRect.size.width andY:dataXYRect.origin.y];
        CGPoint bottomLeft = [geometry pointForX:dataXYRect.origin.x andY:dataXYRect.origin.y];
        CGPoint bottomRight = [geometry pointForX:dataXYRect.origin.x andY:dataXYRect.origin.y+dataXYRect.size.height];
        if (CGRectContainsPoint(self.drawRect, topLeft)
            && CGRectContainsPoint(self.drawRect, bottomLeft)
            && CGRectContainsPoint(self.drawRect, bottomRight)) {
            [axis moveToPoint:topLeft];
            [axis addLineToPoint:bottomLeft];
            [axis addLineToPoint:bottomRight];
            [[self axisColor] setStroke];
            [axis stroke];
        }
    }else{
        CGRect dataXYRect = geometry.dataXYRect;
        CGPoint topLeft = [geometry pointForX:dataXYRect.origin.x andY:dataXYRect.origin.y+dataXYRect.size.height];
        CGPoint bottomLeft = [geometry pointForX:dataXYRect.origin.x andY:dataXYRect.origin.y];
        CGPoint bottomRight = [geometry pointForX:dataXYRect.origin.x+dataXYRect.size.width andY:dataXYRect.origin.y];
        if (CGRectContainsPoint(self.drawRect, topLeft)
            && CGRectContainsPoint(self.drawRect, bottomLeft)
            && CGRectContainsPoint(self.drawRect, bottomRight)) {
            [axis moveToPoint:topLeft];
            [axis addLineToPoint:bottomLeft];
            [axis addLineToPoint:bottomRight];
            [[self axisColor] setStroke];
            [axis stroke];
        }
    }
}

-(void)drawPath:(NSUInteger)idx{
    gcGraphType type = [_displayConfig graphTypeForSerie:idx];

    switch (type) {
        case gcScatterPlot:
            [self drawGraphXY:idx];
            break;
        case gcGraphLine:
            [self drawGraphLines:idx];
            break;
        case gcGraphStep:
            [self drawGraphBars:idx];
            break;
    }

}

- (void)drawBackgroundGradient:(CGRect)rect {

    RZBezierPath * path = [ RZBezierPath bezierPathWithRect:rect];
    [[self useBackgroundColor] setFill];
    [[self useBackgroundColor] setStroke];
    [path fill];
}


-(void)drawRectEmptyGraph:(CGRect)rect{
    self.drawRect = self.frame;

#if TARGET_OS_IPHONE
    self.backgroundColor = [self useBackgroundColor];
#endif

    CGRect baseRect = self.drawRect;
    [self drawBackgroundGradient:rect];

    NSString * title = [_dataSource title];
    if (title) {
        NSDictionary * titleAttr = @{NSFontAttributeName:[RZViewConfig systemFontOfSize:12.],NSForegroundColorAttributeName:self.useForegroundColor};
        CGSize titleSize = [title sizeWithAttributes:titleAttr];

        CGRect titleRect = CGRectMake(baseRect.size.width/2.-titleSize.width/2., 5.,titleSize.width, titleSize.height);
        [title drawInRect:titleRect withAttributes:titleAttr];
    }

    NSString * emptyMsg = nil;
    if ([self.displayConfig respondsToSelector:@selector(emptyGraphLabel)]) {
        emptyMsg = [self.displayConfig emptyGraphLabel];
    }
    if (emptyMsg == nil) {
        emptyMsg = NSLocalizedString(@"Empty Graph", @"GraphView");
    }
    NSDictionary * msgAttr = @{NSFontAttributeName:[RZViewConfig systemFontOfSize:14.],NSForegroundColorAttributeName:self.useForegroundColor};
    CGSize msgSize = [emptyMsg sizeWithAttributes:msgAttr];

    CGRect msgRect = CGRectMake(baseRect.size.width/2.-msgSize.width/2., baseRect.size.height/2-msgSize.height/2,msgSize.width, msgSize.height);
    [emptyMsg drawInRect:msgRect withAttributes:msgAttr];

}

- (void)drawRect:(CGRect)rect {
    if ([_dataSource nDataSeries] == 0 ) {
        [self drawRectEmptyGraph:rect];
        return;
    }
    if ([[_dataSource dataSerie:0] count] == 0) {
        [self drawRectEmptyGraph:rect];
        return;
    }
    self.drawRect = rect;

    [self calculateGeometry];
    [self drawBackgroundGradient:rect];
    [self drawAxisKnobs];

    for (NSUInteger i = 0; i<[_dataSource nDataSeries]; i++) {
        [self drawPath:i];
    }
    [self drawAxis];
}

@end

@implementation GCSimpleGraphDefaultDisplayConfig

-(RZColor*)colorForSerie:(NSUInteger)idx{
    return [RZColor blackColor];
}

-(CGFloat)lineWidth:(NSUInteger)idx{
    return 1.;
}

-(gcGraphType)graphTypeForSerie:(NSUInteger)idx{
    return gcGraphLine;
}
-(BOOL)highlightCurrent:(NSUInteger)idx{
    return false;
}
-(BOOL)disableHighlight:(NSUInteger)idx{
    return false;
}

@end
