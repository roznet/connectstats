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

#import <TargetConditionals.h>

#if TARGET_OS_IPHONE
#import <Foundation/Foundation.h>
#else
#import <Cocoa/Cocoa.h>
#endif
#import <RZUtils/RZUtils.h>
#import "GCSimpleGraphProtocol.h"

@class GCViewGradientColors;

@interface  GCSimpleGraphDataHolder : NSObject{
    GCStatsDataSerie * dataSerie;
    gcGraphType graphType;
    RZColor * color;
    GCUnit * yUnit;
    CGFloat lineWidth;
    GCViewGradientColors * gradientColors;
    id<GCStatsFunction> gradientFunction;
    GCStatsDataSerie * gradientDataSerie;
    gcStatsRange range;
    CGPoint currentPoint;
    BOOL highlightCurrent;
    NSString * legend;
}
@property (nonatomic,retain) GCStatsDataSerie * dataSerie;
@property (nonatomic,assign) gcGraphType graphType;
@property (nonatomic,retain) RZColor * color;
@property (nonatomic,retain) GCUnit * yUnit;
@property (nonatomic,assign) CGFloat lineWidth;
@property (nonatomic,retain) GCViewGradientColors * gradientColors;
@property (nonatomic,retain) id<GCStatsFunction> gradientFunction;
@property (nonatomic,retain) GCStatsDataSerie * gradientDataSerie;
@property (nonatomic,assign) gcStatsRange range;
@property (nonatomic,assign) CGPoint currentPoint;
@property (nonatomic,assign) BOOL highlightCurrent;
@property (nonatomic,assign) BOOL disableHighlight;
@property (nonatomic,retain) NSString * legend;
@property (nonatomic,assign) NSUInteger axisForSerie;
@property (nonatomic,retain) RZColor * fillColorForSerie;
@property (nonatomic,retain) GCUnit * gradientSerieXUnit;

+(GCSimpleGraphDataHolder*)dataHolder:(GCStatsDataSerie*)data type:(gcGraphType)aType color:(RZColor*)aColor andUnit:(GCUnit*)aUnit;
-(void)setupAsBackgroundGraph;
-(BOOL)isEmpty;

@end

@interface GCSimpleGraphCachedDataSource : NSObject<GCSimpleGraphDataSource,GCSimpleGraphDisplayConfig>

@property (nonatomic,retain) NSArray<GCSimpleGraphDataHolder*> * series;
@property (nonatomic,retain) GCUnit * xUnit;
@property (nonatomic,retain) NSString * title;
@property (nonatomic,assign) CGPoint zoomPercentage;
@property (nonatomic,assign) CGPoint offsetPercentage;
@property (nonatomic,assign) NSString * emptyGraphLabel;
@property (nonatomic,assign) BOOL maximizeGraph;
@property (nonatomic,retain) RZColor * useBackgroundColor;
@property (nonatomic,retain) RZColor * useForegroundColor;
@property (nonatomic,retain) RZColor * axisColor;
@property (nonatomic,assign) BOOL xAxisIsVertical;

+(GCSimpleGraphCachedDataSource*)graphDataSourceWithTitle:(NSString*)title andXUnit:(GCUnit*)xUnit;

-(void)addDataHolder:(GCSimpleGraphDataHolder*)dataHolder;


-(void)setupAsBackgroundGraph;
-(void)addDataSource:(GCSimpleGraphCachedDataSource*)other;

@end

