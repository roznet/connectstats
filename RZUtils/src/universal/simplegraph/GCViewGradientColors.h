//  MIT Licence
//
//  Created on 01/11/2012.
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
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif
#import <RZUtils/RZUtils.h>

@interface GCViewGradientColors : NSObject

@property (nonatomic,retain) NSArray<RZColor*> * colors;
@property (nonatomic,readonly) NSUInteger numberOfColors;
@property (nonatomic,assign) BOOL valueIsIndex;

+(GCViewGradientColors*)gradientColorsRainbow16;
+(GCViewGradientColors*)gradientColorsTrackHighlight16;
+(GCViewGradientColors*)gradientColorsRainbowHighlight16;
+(GCViewGradientColors*)gradientColors:(NSUInteger)nColors from:(RZColor*)fromC to:(RZColor*)toC;
+(GCViewGradientColors*)gradientColorsSingle:(RZColor*)color;
+(GCViewGradientColors*)gradientColorsWith:(NSArray<RZColor*>*)colors;
+(GCViewGradientColors*)gradientColorsTrackHighlight:(RZColor*)color alpha:(CGFloat)alpha;

-(RZColor*)colorsForValue:(CGFloat)aVal;

-(GCViewGradientColors*)gradientAsBackground;
-(GCViewGradientColors*)gradientAsBackgroundWithAlpha:(CGFloat)alpha;
-(GCViewGradientColors*)gradientAsOneColor:(RZColor*)color;

@end

