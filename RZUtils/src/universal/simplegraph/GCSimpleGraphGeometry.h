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

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#else
#import <Cocoa/Cocoa.h>
#endif
#import <RZUtils/RZUtils.h>
#import <RZUtilsUniversal/GCSimpleGraphProtocol.h>

@interface GCAxisKnob : NSObject

@property (nonatomic,retain) NSString * label;
@property (nonatomic,assign) CGFloat value;
@property (nonatomic,assign) CGRect rect;

@property (nonatomic,assign) GCAxisKnob * next;
@property (nonatomic,assign) GCAxisKnob * prev;

@end


@interface GCSimpleGraphGeometry : NSObject

// Config/Inputs
@property (nonatomic,retain) id<GCSimpleGraphDataSource> dataSource;
@property (nonatomic,assign) CGPoint zoomPercentage;
@property (nonatomic,assign) CGPoint offsetPercentage;
@property (nonatomic,assign) NSUInteger serieIndex;
@property (nonatomic,assign) NSUInteger axisIndex;
@property (nonatomic,assign) BOOL maximizeGraph; // true=no labels/knobs/titles, maximize Graph
@property (nonatomic,assign) BOOL xAxisIsVertical;

// Outputs
/**
 CGRect representing data range
 */
@property (nonatomic,assign) CGRect dataXYRect;
@property (nonatomic,assign) CGRect graphDataRect;
@property (nonatomic,assign) CGRect drawRect;
@property (nonatomic,retain) NSArray<GCAxisKnob*> * xAxisKnobs;
@property (nonatomic,retain) NSArray<GCAxisKnob*> * yAxisKnobs;
@property (nonatomic,assign) gcStatsRange knobRange;
@property (nonatomic,assign) gcStatsRange range;
@property (nonatomic,assign) CGPoint rangeMinPoint;
@property (nonatomic,assign) CGPoint rangeMaxPoint;
@property (nonatomic,assign) CGRect titleRect;

/**
 Convert x,y of the data to CGPoint(x,y) on screen

 */
-(CGPoint)pointForX:(CGFloat)x andY:(CGFloat)y;
-(CGPoint)dataXYForPoint:(CGPoint)point;
-(BOOL)pointInsideGraph:(CGPoint)point;

-(void)calculate;
-(void)calculateAxisKnobRect:(gcGraphType)gtype andAttribute:(NSDictionary*)knobAttr;


-(RZFont*)axisFont;
-(RZFont*)titleFont;


@end
