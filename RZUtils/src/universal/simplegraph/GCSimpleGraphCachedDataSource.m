//  MIT Licence
//
//  Created on 28/10/2012.
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


#import "GCSimpleGraphCachedDataSource.h"
#import <RZUtils/GCStatsDataSerie.h>
#import <RZUtils/RZMacros.h>

@implementation GCSimpleGraphDataHolder;
@synthesize dataSerie,graphType,color,yUnit,lineWidth,gradientColors,gradientFunction,gradientDataSerie,range,currentPoint,highlightCurrent,legend;
+(GCSimpleGraphDataHolder*)dataHolder:(GCStatsDataSerie*)aData type:(gcGraphType)aType color:(RZColor*)aColor andUnit:(GCUnit*)aUnit{
    GCSimpleGraphDataHolder * info = RZReturnAutorelease([[GCSimpleGraphDataHolder alloc] init]);
    if (info) {
        info.color = aColor;
        info.graphType = aType;
        info.dataSerie = aData;
        info.yUnit = aUnit;
        info.range = [aData range];
        switch (aType) {
            case gcGraphLine:
            case gcGraphStep:
            case gcGraphBezier:
                info.lineWidth = 1.;
                break;
                
            case gcScatterPlot:
                info.lineWidth = 4.;
                break;
        }
    }
    return info;
}
#if ! __has_feature(objc_arc)
-(void)dealloc{
    [gradientFunction release];
    [gradientDataSerie release];
    [gradientColors release];
    [_gradientColorsFill release];

    [dataSerie release];
    [color release];
    [yUnit release];
    [legend release];
    [_fillColorForSerie release];

    [super dealloc];
}
#endif

-(void)setupAsBackgroundGraph{
    self.color = [RZColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.2];
    if (self.fillColorForSerie) {
        self.fillColorForSerie = [RZColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.2];
    }
    if (self.gradientColors) {
        //self.gradientColors = [self.gradientColors gradientAsBackground];
        self.gradientColors = [self.gradientColors gradientAsOneColor:[RZColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.2]];
    }
    self.legend = nil;
}

-(BOOL)isEmpty{
    return self.dataSerie == nil || self.dataSerie.count == 0;
}
@end

@implementation GCSimpleGraphCachedDataSource

+(GCSimpleGraphCachedDataSource*)graphDataSourceWithTitle:(NSString*)title andXUnit:(GCUnit*)xUnit{
    GCSimpleGraphCachedDataSource * rv = RZReturnAutorelease([[GCSimpleGraphCachedDataSource alloc] init]);
    
    if (rv) {
        rv.title = title;
        rv.xUnit = xUnit;
    }
    return rv;
}

#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_series release];
    [_xUnit release];
    [_title release];
    [_useBackgroundColor release];
    [_useForegroundColor release];
    [_axisColor release];

    [super dealloc];
}
#endif

-(NSUInteger)nDataSeries{
    return _series.count;
}

-(BOOL)requiresLegend{
    BOOL rv = false;
    for (GCSimpleGraphDataHolder*holder in self.series) {
        if( holder.legend != nil){
            rv = true;
        }
    }
    return rv;
}

-(GCStatsDataSerie*)dataSerie:(NSUInteger)idx{
    if (idx < _series.count) {
        return [_series[idx] dataSerie];
    }
    return nil;
}

-(void)setupAsBackgroundGraph{
    for (GCSimpleGraphDataHolder*holder in self.series) {
        [holder setupAsBackgroundGraph];
    }
}

-(void)addDataHolder:(GCSimpleGraphDataHolder*)dataHolder{
    self.series = self.series ? [self.series arrayByAddingObject:dataHolder] : @[ dataHolder ];
}


-(void)addDataSource:(GCSimpleGraphCachedDataSource *)other{
    NSMutableArray * newSeries = [NSMutableArray arrayWithArray:self.series];
    for (GCSimpleGraphDataHolder * holder in other.series) {
        [newSeries addObject:holder];
    }
    self.series = newSeries;
}

-(gcStatsRange)rangeForSerie:(NSUInteger)idx{
    GCSimpleGraphDataHolder * holder = _series[idx];
    return holder.range;
}

-(gcGraphType)graphTypeForSerie:(NSUInteger)idx{
    return [_series[idx] graphType];
}
-(RZColor*)colorForSerie:(NSUInteger)idx{
    return [_series[idx] color];

}
-(RZColor*)fillColorForSerie:(NSUInteger)idx{
    return [_series[idx] fillColorForSerie];
}
-(GCUnit*)yUnit:(NSUInteger)idx{
    return [_series[idx] yUnit];
}
-(CGFloat)lineWidth:(NSUInteger)idx{
    return [_series[idx] lineWidth];
}

-(GCViewGradientColors*)gradientColors:(NSUInteger)idx{
    return [_series[idx] gradientColors];
}
-(GCViewGradientColors*)gradientColorsFill:(NSUInteger)idx{
    return [_series[idx] gradientColorsFill];
}
-(id<GCStatsFunction>)gradientFunction:(NSUInteger)idx{
    return [_series[idx] gradientFunction];
}
-(GCStatsDataSerie*)gradientDataSerie:(NSUInteger)idx{
    return [_series[idx] gradientDataSerie];
}
-(GCUnit*)gradientSerieXUnit:(NSUInteger)idx{
    return [_series[idx] gradientSerieXUnit];
}
-(CGPoint)currentPoint:(NSUInteger)idx{
    return [_series[idx] currentPoint];
}
-(BOOL)highlightCurrent:(NSUInteger)idx{
    return [_series[idx] highlightCurrent];
}
-(BOOL)disableHighlight:(NSUInteger)idx{
    return [_series[idx] disableHighlight];
}
-(NSString*)legend:(NSUInteger)idx{
    return [_series[idx] legend];
}

-(NSUInteger)axisForSerie:(NSUInteger)idx{
    return [_series[idx] axisForSerie];
}
@end
