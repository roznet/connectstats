//  MIT Licence
//
//  Created on 14/12/2012.
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

#import "GCSimpleGraphGeometry.h"
#import "GCUnit.h"
#import "RZViewConfig.h"
#import "RZMacros.h"

@interface GCSimpleGraphGeometry (){
    CGFloat _horizontalScaling;
    CGFloat _verticalScaling;

    gcStatsRange _origRange;

}

@end

@implementation GCAxisKnob

#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_label release];
    [super dealloc];
}
#endif

+(GCAxisKnob*)axisKnobFor:(NSString*)label andValue:(CGFloat)val{
    GCAxisKnob * rv = RZReturnAutorelease([[GCAxisKnob alloc] init]);
    if (rv) {
        rv.label = label;
        rv.value = val;
        rv.rect = CGRectZero;
    }
    return rv;
}

-(NSString*)description{
    return [NSString stringWithFormat:@"<%@(%f)[%@]>",  NSStringFromClass([self class]), self.value, self.label];
}

@end

@implementation GCSimpleGraphGeometry
#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_xAxisKnobs release];
    [_yAxisKnobs release];
    [_dataSource release];

    [super dealloc];
}
#endif

-(CGPoint)pointForX:(CGFloat)x andY:(CGFloat)y{
#if TARGET_OS_IPHONE
    if (_xAxisIsVertical) {
        return CGPointMake( (   _graphDataRect.origin.x + (y-_dataXYRect.origin.y)* _horizontalScaling),
                           _graphDataRect.origin.y + _graphDataRect.size.height - (x - _dataXYRect.origin.x) * _verticalScaling);
    }else{
        return CGPointMake( (   _graphDataRect.origin.x + (x-_dataXYRect.origin.x)* _horizontalScaling),
                           _graphDataRect.origin.y+_graphDataRect.size.height - (y - _dataXYRect.origin.y) * _verticalScaling);
    }
#else
    return CGPointMake( (   _graphDataRect.origin.x + (x-_dataXYRect.origin.x)* _horizontalScaling),
                       _graphDataRect.origin.y+ (y-_dataXYRect.origin.y) * _verticalScaling);
#endif
}

-(BOOL)pointInsideGraph:(CGPoint)point{
    return CGRectContainsPoint(_graphDataRect, point);
}

-(CGPoint)dataXYForPoint:(CGPoint)point{
    double x = _dataXYRect.origin.x + (point.x-_graphDataRect.origin.x)/_horizontalScaling;
    double y = _dataXYRect.origin.y + _dataXYRect.size.height - (point.y-_graphDataRect.origin.y)/_verticalScaling;
    return CGPointMake(x, y);
}

-(RZFont*)axisFont{
    return [RZViewConfig systemFontOfSize:10.];
}

-(RZFont*)titleFont{
    return [RZViewConfig systemFontOfSize:12.];
}

-(void)calculateAll{

    CGFloat y_max = _range.y_max;
    CGFloat y_min = _range.y_min;

    CGFloat x_min   = _range.x_min;
    CGFloat x_max   = _range.x_max;

    NSDictionary * knobAttr = @{NSFontAttributeName:[self axisFont]};

    GCUnit * xUnit = [_dataSource xUnit];
    GCUnit * yUnit = [_dataSource yUnit:0];

    CGFloat C_xKnobOffset = 5.;
    CGFloat C_yKnobOffset = 3.;

    CGRect baseRect = _drawRect;

    NSString * title = [_dataSource title];
    NSDictionary * titleAttr = @{NSFontAttributeName:[self titleFont]};
    CGSize titleSize = [title sizeWithAttributes:titleAttr];

    CGSize xLabelSize = CGSizeZero;
    CGSize yLabelSize = CGSizeZero;

    // Try a few evenly spaces values for x and y to guess
    // the max size of labels. We can't yet know all the knobs
    // because it will depend of the size allocated to draw one
    // only min & max maybe special value so try a few in between
    CGFloat divs[] = { 0.0, 0.25, 0.5, 0.75, 1. };
    size_t ndivs = sizeof(divs) / sizeof(CGFloat);

    for (size_t i=0; i<ndivs; i++) {
        double try_x = x_min + divs[i] * (x_max-x_min);
        double try_y = y_min + divs[i] * (y_max-y_min);
        GCAxisKnob * tryKnobX = [GCAxisKnob axisKnobFor:[xUnit formatDoubleNoUnits:try_x] andValue:try_x];
        GCAxisKnob * tryKnobY = [GCAxisKnob axisKnobFor:[yUnit formatDoubleNoUnits:try_y] andValue:try_y];

        CGSize tryXSize = [tryKnobX.label sizeWithAttributes:knobAttr];
        CGSize tryYSize = [tryKnobY.label sizeWithAttributes:knobAttr];

        xLabelSize = CGSizeMake(MAX(xLabelSize.width, tryXSize.width), MAX(xLabelSize.height, tryXSize.height));
        yLabelSize = CGSizeMake(MAX(yLabelSize.width, tryYSize.width), MAX(yLabelSize.height, tryYSize.height));
    }

    CGFloat leftMargin   = yLabelSize.width + C_xKnobOffset*2.;
    CGFloat rightMargin  = C_xKnobOffset;

    CGFloat topMargin    = titleSize.height+C_yKnobOffset*2.;
    // xAxisIsVertical: should use yMaxMinSize otherwise xMaxMinSize
    CGFloat bottomMargin = xLabelSize.height+C_yKnobOffset;

    if (_xAxisIsVertical) {
        leftMargin = xLabelSize.width +C_xKnobOffset*2.;
        bottomMargin = yLabelSize.height+C_yKnobOffset;
    }

    CGFloat height = MIN(baseRect.size.height-bottomMargin-topMargin, (baseRect.size.width)*0.8);
    CGFloat width  = baseRect.size.width-rightMargin-leftMargin;

#if TARGET_OS_IPHONE
    self.titleRect = CGRectMake(baseRect.size.width/2.-titleSize.width/2., 5.,titleSize.width, titleSize.height);

    _graphDataRect = CGRectMake(leftMargin, topMargin, width, height);

#else
    self.titleRect = CGRectMake(baseRect.size.width/2.-titleSize.width/2.,
                                baseRect.size.height-titleSize.height,
                                titleSize.width,
                                titleSize.height);
    _graphDataRect = CGRectMake(leftMargin, bottomMargin, width, height);

#endif

    NSUInteger y_nKnobs = ceil(height/yLabelSize.height/2.);
    NSUInteger x_nKnobs = ceil(width/xLabelSize.width);

    if (_xAxisIsVertical) {
         y_nKnobs = ceil(width/yLabelSize.width/2.);
         x_nKnobs = ceil(height/xLabelSize.height);
    }

    NSUInteger maxXKnobs = width < 320. ? 8 : 20;
    NSUInteger divisor = 1;
    while (x_nKnobs > maxXKnobs && divisor < 5) {
        divisor+=1;
        x_nKnobs =ceil(width/xLabelSize.width/divisor);
    }

    NSArray * x_knobValues = [xUnit axisKnobs:x_nKnobs min:x_min max:x_max extendToKnobs:NO];
    NSArray * y_knobValues = [yUnit axisKnobs:y_nKnobs min:y_min max:y_max extendToKnobs:YES];

    [self calculateAxisKnobsFromValuesX:x_knobValues xUnit:xUnit valuesY:y_knobValues Unit:yUnit];
}

-(void)calculateMaximizeGraph{

    CGFloat y_max = _range.y_max;
    CGFloat y_min = _range.y_min;

    CGFloat x_min   = _range.x_min;
    CGFloat x_max   = _range.x_max;

    GCUnit * xUnit = [_dataSource xUnit];
    GCUnit * yUnit = [_dataSource yUnit:0];

    CGFloat C_xKnobOffset = 2.;
    CGFloat C_yKnobOffset = 2.;

    CGRect baseRect = _drawRect;


    self.titleRect = CGRectZero;

    CGFloat topMargin    = C_yKnobOffset;
    CGFloat bottomMargin = C_yKnobOffset;
    CGFloat leftMargin   = C_xKnobOffset;
    CGFloat rightMargin  = C_xKnobOffset;

    CGFloat height = MIN(baseRect.size.height-bottomMargin-topMargin, (baseRect.size.width)*0.8);
    CGFloat width  = baseRect.size.width-rightMargin-leftMargin;

    NSUInteger y_nKnobs = 5.;
    NSUInteger x_nKnobs = 5.;

    NSArray * x_knobValues = [xUnit axisKnobs:x_nKnobs min:x_min max:x_max extendToKnobs:NO];
    NSArray * y_knobValues = [yUnit axisKnobs:y_nKnobs min:y_min max:y_max extendToKnobs:YES];

    [self calculateAxisKnobsFromValuesX:x_knobValues xUnit:xUnit valuesY:y_knobValues Unit:yUnit];

    _graphDataRect = CGRectMake(leftMargin, topMargin, width, height);
}

-(void)calculateAxisKnobsFromValuesX:(NSArray*)x_knobValues
                               xUnit:(GCUnit*)xUnit
                                valuesY:(NSArray*)y_knobValues
                                Unit:(GCUnit*)yUnit{


    NSMutableArray * xAxisKnobs = [NSMutableArray arrayWithCapacity:x_knobValues.count];
    NSMutableArray * yAxisKnobs = [NSMutableArray arrayWithCapacity:y_knobValues.count];

    GCAxisKnob * last = nil;
    for (NSNumber * val in x_knobValues) {
        GCAxisKnob * current = [GCAxisKnob axisKnobFor:[xUnit formatDoubleNoUnits:val.doubleValue] andValue:val.doubleValue];
        current.prev = last;
        if (last) {
            last.next = current;
        }
        last = current;
        [xAxisKnobs addObject:current];
    }

    last = nil;
    for (NSNumber * val in y_knobValues) {
        GCAxisKnob * current = [GCAxisKnob axisKnobFor:[yUnit formatDoubleNoUnits:val.doubleValue] andValue:val.doubleValue];
        current.prev = last;
        if (last) {
            last.next = current;
        }
        last = current;
        [yAxisKnobs addObject:current];
    }

    self.xAxisKnobs = xAxisKnobs;
    self.yAxisKnobs = yAxisKnobs;

    if (x_knobValues.count>0) {
        _knobRange.x_min = [x_knobValues[0] doubleValue];
        _knobRange.x_max = [x_knobValues.lastObject doubleValue];
    }else{
        _knobRange.x_min = _range.x_min;
        _knobRange.x_max = _range.x_max;
    }
    if (y_knobValues.count>0) {
        _knobRange.y_min = [y_knobValues[0] doubleValue];
        _knobRange.y_max = [y_knobValues.lastObject doubleValue];
    }else{
        _knobRange.y_min = _range.y_min;
        _knobRange.y_max = _range.y_max;
    }

}

-(void)calculate{

    _range = [_dataSource rangeForSerie:self.serieIndex];

    NSUInteger thisAxis = [_dataSource respondsToSelector:@selector(axisForSerie:)] ?  [_dataSource axisForSerie:self.serieIndex] : 0;

    NSUInteger n = [_dataSource nDataSeries];
    for (NSUInteger i = 0; i<n; i++) {
        if (i!=self.serieIndex) {
            NSUInteger axis = [_dataSource respondsToSelector:@selector(axisForSerie:)] ?  [_dataSource axisForSerie:i] : 0;
            if (axis == thisAxis) {
                _range = maxRange(_range, [_dataSource rangeForSerie:i]);
            }else{
                _range = maxRangeXOnly(_range, [_dataSource rangeForSerie:i]);
            }
        }
    }

    _origRange = _range;

    CGPoint zoom = self.zoomPercentage;
    CGPoint offset = self.offsetPercentage;

    if ( zoom.x > 0. && zoom.y > 0. ) {

        CGFloat zoomwidth = (_range.x_max-_range.x_min) * (1.-MIN(zoom.x,.8));
        CGFloat zoomheight = (_range.y_max-_range.y_min) * (1.- MIN(zoom.y,.8));

        _range.x_min = _range.x_min+offset.x * (_range.x_max-_range.x_min-zoomwidth);
        _range.y_min = _range.y_min+offset.y * (_range.y_max-_range.y_min-zoomheight);

        if (zoom.x < 1. || zoom.y < 1. ) {
            _range.x_max = _range.x_min+zoomwidth;
            _range.y_max = _range.y_min+zoomheight;
        }
    }

    if (self.maximizeGraph) {
        [self calculateMaximizeGraph];
    }else{
        [self calculateAll];
    }

    if (_xAxisIsVertical) {
        _dataXYRect    = CGRectMake(_knobRange.x_min, _knobRange.y_min, _knobRange.x_max-_knobRange.x_min, _knobRange.y_max-_knobRange.y_min);
        _horizontalScaling   = fabs(_dataXYRect.size.width) <1e-8? 1. : _graphDataRect.size.width /  _dataXYRect.size.height;
        _verticalScaling     = fabs(_dataXYRect.size.height)<1e-8? 1. : _graphDataRect.size.height / _dataXYRect.size.width;
    }else{
        _dataXYRect    = CGRectMake(_knobRange.x_min, _knobRange.y_min, _knobRange.x_max-_knobRange.x_min, _knobRange.y_max-_knobRange.y_min);
        _horizontalScaling   = fabs(_dataXYRect.size.width) <1e-8? 1. : _graphDataRect.size.width /  _dataXYRect.size.width;
        _verticalScaling     = fabs(_dataXYRect.size.height)<1e-8? 1. : _graphDataRect.size.height / _dataXYRect.size.height;
    }

#if TARGET_OS_IPHONE
    self.rangeMinPoint =[self pointForX:_range.x_min andY:_range.y_max];
    self.rangeMaxPoint = [self pointForX:_range.x_max andY:_range.y_min];
#else
    self.rangeMinPoint= [self pointForX:_range.x_min andY:_range.y_min];
    self.rangeMaxPoint = [self pointForX:_range.x_max andY:_range.y_max];
#endif

}

-(void)calculateAxisKnobRect:(gcGraphType)gtype andAttribute:(NSDictionary*)knobAttr{
    if (self.maximizeGraph) {
        for (GCAxisKnob * aKnob in self.xAxisKnobs){
            aKnob.rect = CGRectZero;
        }
        for (GCAxisKnob * aKnob in self.yAxisKnobs) {
            aKnob.rect = CGRectZero;
        }
    }else{

        CGRect knobRect;
        CGFloat x_last = 0.;

        CGFloat C_xKnobOffset = 5.;
        CGFloat C_yKnobOffset = 3.;

        for (GCAxisKnob * aKnob in self.xAxisKnobs) {
            knobRect.origin = [self pointForX:aKnob.value andY:self.knobRange.y_min];
            knobRect.size   = [aKnob.label sizeWithAttributes:knobAttr];

#if TARGET_OS_IPHONE
            if (!_xAxisIsVertical) {
                knobRect.origin.y += C_yKnobOffset;
            }
#else
            knobRect.origin.y -= C_yKnobOffset+knobRect.size.height;
#endif
            if (gtype != gcGraphStep) {
                knobRect.origin.x -= knobRect.size.width/2.;
            }else{
                // Shift left if is vertical
                if (_xAxisIsVertical) {
                    knobRect.origin.x -= C_xKnobOffset+knobRect.size.width;
                    // Shift up so the label is above the value/knob
                    knobRect.origin.y -= knobRect.size.height;
                }else{
                    knobRect.origin.x -= C_xKnobOffset;
                }
            }

            if ((knobRect.origin.x+knobRect.size.width)>CGRectGetMaxX(self.drawRect)) {
                knobRect.origin.x = CGRectGetMaxX(self.drawRect)-knobRect.size.width;
            }

            if (_xAxisIsVertical) {
                aKnob.rect = knobRect;
            }else{
                if (x_last == 0. || knobRect.origin.x > x_last ) {
                    aKnob.rect = knobRect;
                    x_last = knobRect.origin.x + knobRect.size.width;
                }else{
                    aKnob.rect = CGRectZero;
                }
            }
        }

        CGFloat x_min = self.dataXYRect.origin.x;

        for (GCAxisKnob * aKnob in self.yAxisKnobs) {
            knobRect.origin = [self pointForX:x_min andY:aKnob.value];
            knobRect.size = [aKnob.label sizeWithAttributes:knobAttr];

            // don't shift if is vertical
            if (_xAxisIsVertical) {
                knobRect.origin.x -= knobRect.size.width/2.;
                knobRect.origin.y += C_yKnobOffset;
            }else{
                knobRect.origin.x -= knobRect.size.width+C_xKnobOffset;
                knobRect.origin.y -= knobRect.size.height/2.;
            }

            aKnob.rect = knobRect;
        }
    }
}


@end
