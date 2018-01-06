//  MIT Licence
//
//  Created on 27/10/2012.
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

#if TARGET_OS_IPHONE
#import <Foundation/Foundation.h>
#else
#import <Cocoa/Cocoa.h>
#endif

#import "GCViewGradientColors.h"
#import <RZUtils/RZUtils.h>

typedef NS_ENUM(NSUInteger, gcGraphType) {
    gcGraphLine,
    gcGraphStep,
    gcScatterPlot
};

@protocol GCSimpleGraphDataSource <NSObject>

-(NSUInteger)nDataSeries;
-(GCStatsDataSerie*)dataSerie:(NSUInteger)idx;
-(gcStatsRange)rangeForSerie:(NSUInteger)idx;
-(GCUnit*)xUnit;
-(GCUnit*)yUnit:(NSUInteger)idx;
-(NSString*)title;
-(NSString*)legend:(NSUInteger)idx;
-(CGPoint)currentPoint:(NSUInteger)idx;

@optional

-(id<GCStatsFunction>)gradientFunction:(NSUInteger)idx;
-(GCStatsDataSerie*)gradientDataSerie:(NSUInteger)idx;
-(NSUInteger)axisForSerie:(NSUInteger)idx;
-(GCUnit*)gradientSerieXUnit:(NSUInteger)idx;


@end

@protocol GCSimpleGraphDisplayConfig <NSObject>

-(gcGraphType)graphTypeForSerie:(NSUInteger)idx;
-(RZColor*)colorForSerie:(NSUInteger)idx;
-(CGFloat)lineWidth:(NSUInteger)idx;
-(BOOL)highlightCurrent:(NSUInteger)idx;
-(BOOL)disableHighlight:(NSUInteger)idx;


@optional

-(GCViewGradientColors*)gradientColors:(NSUInteger)idx;
-(CGPoint)zoomPercentage;
-(CGPoint)offsetPercentage;
-(NSString*)emptyGraphLabel;
-(BOOL)emptyGraphActivityIndicator;
-(RZColor*)fillColorForSerie:(NSUInteger)idx;
-(BOOL)maximizeGraph;
-(RZColor*)useBackgroundColor;
-(RZColor*)useForegroundColor;
-(RZColor*)axisColor;
-(BOOL)xAxisIsVertical;

@end

