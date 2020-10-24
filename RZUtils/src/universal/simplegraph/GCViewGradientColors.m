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

#import <RZUtilsUniversal/GCViewGradientColors.h>
#import <RZUtils/RZMacros.h>

@implementation GCViewGradientColors

#if !__has_feature(objc_arc)
- (void)dealloc
{
    [_colors release];

    [super dealloc];
}
#endif

-(NSUInteger)numberOfColors{
    return self.colors.count;
}

+(GCViewGradientColors*)gradientColorsWith:(NSArray<RZColor*>*)colors{
    GCViewGradientColors * rv = RZReturnAutorelease([[GCViewGradientColors alloc] init]);
    if (rv) {
        rv.colors = colors;
        rv.valueIsIndex = true;
    }
    return rv;
}

+(GCViewGradientColors*)gradientColors:(NSUInteger)nColors from:(RZColor*)fromC to:(RZColor*)toC{
    GCViewGradientColors * rv = RZReturnAutorelease([[GCViewGradientColors alloc] init]);
    if (rv) {
        CGFloat startRGBA[4];
        CGFloat endRGBA[4];

        [fromC getRed:startRGBA green:startRGBA+1 blue:startRGBA+2 alpha:startRGBA+3];
        [toC getRed:endRGBA green:endRGBA+1 blue:endRGBA+2 alpha:endRGBA+3];

        NSMutableArray<RZColor*>*colors = [NSMutableArray array];

        for (NSUInteger i=0; i<nColors; i++) {
            CGFloat fract = (CGFloat)i/(CGFloat)(nColors-1);
            CGFloat components[4];
            for(size_t j = 0; j < 4;j++ ){
                components[j] = startRGBA[j] + fract * ( endRGBA[j] - startRGBA[j]);
            }

            RZColor * one = [RZColor colorWithRed:components[0] green:components[1] blue:components[2] alpha:components[3]];
            [colors addObject:one];
        }
        rv.colors = colors;
    }
    return rv;
}
+(GCViewGradientColors*)gradientColorsTrackHighlight:(RZColor*)color alpha:(CGFloat)alpha{
    GCViewGradientColors * rv = RZReturnAutorelease([[GCViewGradientColors alloc] init]);
    if (rv) {
        rv.colors = @[ [color colorWithAlphaComponent:alpha], color ];
        rv.valueIsIndex = true;
    }
    return rv;
}
+(GCViewGradientColors*)gradientColorsTrackHighlight16{
    GCViewGradientColors * rv = RZReturnAutorelease([[GCViewGradientColors alloc] init]);
    if (rv) {
        NSMutableArray<RZColor*>*colors = [NSMutableArray array];
        [colors addObject:[RZColor colorWithRed:0.132 green:0.820 blue:1.0 alpha:1.0]];
        for(NSUInteger i = 1; i< 16; i++){
            [colors addObject:[RZColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
        }
        rv.colors = colors;
    }
    return rv;
}

+(GCViewGradientColors*)gradientColorsRainbowHighlight16{
    GCViewGradientColors * rv = RZReturnAutorelease([[GCViewGradientColors alloc] init] );
    if (rv) {
        CGFloat defs[4*16] = {
            0.596,0.961,1.000,0.800 ,
            0.397,0.890,1.000,1.000 ,
            0.132,0.820,1.000,1.000 ,
            0.000,0.749,1.000,1.000 ,
            0.329,1.000,0.624,1.000 ,
            0.343,0.924,0.542,1.000 ,
            0.357,0.848,0.460,1.000 ,
            0.371,0.773,0.378,1.000 ,
            0.384,0.697,0.297,1.000 ,
            0.398,0.621,0.215,1.000 ,
            0.412,0.545,0.133,1.000 ,
            0.820,0.573,0.459,1.000 ,
            0.816,0.507,0.381,1.000 ,
            0.812,0.441,0.304,1.000 ,
            0.808,0.375,0.226,1.000 ,
            0.804,0.310,0.149,1.000 ,
        };
        
        NSMutableArray<RZColor*>*colors = [NSMutableArray array];
        for( NSUInteger i=0; i < 16; i++){
            RZColor * one = [RZColor colorWithRed:defs[i*4] green:defs[i*4+1] blue:defs[i*4+2] alpha:defs[i*4+3]];
            [colors addObject:one];
        }
        rv.colors = colors;
    }
    return rv;
}

+(GCViewGradientColors*)gradientColorsRainbow16{
    GCViewGradientColors * rv = RZReturnAutorelease([[GCViewGradientColors alloc] init] );
    if (rv) {
        CGFloat defs[4*16] = {
            0.596,0.961,1.000,0.800 ,
            0.397,0.890,1.000,1.000 ,
            0.132,0.820,1.000,1.000 ,
            0.000,0.749,1.000,1.000 ,
            0.329,1.000,0.624,1.000 ,
            0.343,0.924,0.542,1.000 ,
            0.357,0.848,0.460,1.000 ,
            0.371,0.773,0.378,1.000 ,
            0.384,0.697,0.297,1.000 ,
            0.398,0.621,0.215,1.000 ,
            0.412,0.545,0.133,1.000 ,
            0.820,0.573,0.459,1.000 ,
            0.816,0.507,0.381,1.000 ,
            0.812,0.441,0.304,1.000 ,
            0.808,0.375,0.226,1.000 ,
            0.804,0.310,0.149,1.000 ,
        };
        
        NSMutableArray<RZColor*>*colors = [NSMutableArray array];
        for( NSUInteger i=0; i < 16; i++){
            RZColor * one = [RZColor colorWithRed:defs[i*4] green:defs[i*4+1] blue:defs[i*4+2] alpha:defs[i*4+3]];
            [colors addObject:one];
        }
        rv.colors = colors;
    }
    return rv;
}

+(GCViewGradientColors*)gradientColorsSingle:(RZColor*)color{
    GCViewGradientColors * rv = RZReturnAutorelease([[GCViewGradientColors alloc] init]);
    if (rv) {
        rv.colors = @[ color ];
    }
    return rv;
}


-(GCViewGradientColors*)gradientAsOneColor:(RZColor*)color{
    GCViewGradientColors * rv = RZReturnAutorelease([[GCViewGradientColors alloc] init]);
    if (rv) {
        NSMutableArray * colors = [NSMutableArray array];
        for (NSUInteger i=0; i<self.colors.count; i++) {
            [colors addObject:color];
        }
        rv.colors = colors;
        rv.valueIsIndex = self.valueIsIndex;
    }
    return rv;

}

-(GCViewGradientColors*)gradientAsBackground{
    return [self gradientAsBackgroundWithAlpha:0.6];
}
-(GCViewGradientColors*)gradientAsBackgroundWithAlpha:(CGFloat)alpha{

    GCViewGradientColors * rv = RZReturnAutorelease([[GCViewGradientColors alloc] init]);
    if (rv) {
        NSMutableArray * colors = [NSMutableArray array];
        for (RZColor * one in self.colors) {
            [colors addObject:[one colorWithAlphaComponent:alpha]];
        }
        rv.colors = colors;
        rv.valueIsIndex = self.valueIsIndex;
    }
    return rv;
}


-(RZColor*)colorsForValue:(CGFloat)aVal{
    NSUInteger idx = self.valueIsIndex ? aVal : aVal*self.numberOfColors;
    idx = MAX(MIN(self.numberOfColors-1, idx),0);
    return self.colors[idx];
}

@end
