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

#import "GCViewGradientColors.h"
#import "RZMacros.h"

@implementation GCViewGradientColors
@synthesize colors,numberOfColors;

- (void)dealloc
{
    if (colors) {
        int i;
        for (i = 0; i < numberOfColors; i++) {
            CGColorRelease(colors[i]);
        }
        free(colors);
    }

    RZSuperDealloc;
}

+(GCViewGradientColors*)gradientColors:(NSUInteger)nColors from:(RZColor*)fromC to:(RZColor*)toC{
    GCViewGradientColors * rv = RZReturnAutorelease([[GCViewGradientColors alloc] init]);
    if (rv) {
        CGFloat startRGBA[4];
        CGFloat endRGBA[4];

        [fromC getRed:startRGBA green:startRGBA+1 blue:startRGBA+2 alpha:startRGBA+3];
        [toC getRed:endRGBA green:endRGBA+1 blue:endRGBA+2 alpha:endRGBA+3];

        rv.numberOfColors = nColors;

        CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
        rv.colors = malloc(sizeof(CGColorRef) * rv.numberOfColors);

        for (NSUInteger i=0; i<nColors; i++) {
            CGFloat fract = (CGFloat)i/(CGFloat)(rv.numberOfColors-1);
            CGFloat components[4];
            for(size_t j = 0; j < 4;j++ ){
                components[j] = startRGBA[j] + fract * ( endRGBA[j] - startRGBA[j]);
            }

            rv.colors[i] = CGColorCreate(rgb, components);
        }
        CGColorSpaceRelease(rgb);
    }
    return rv;
}
+(GCViewGradientColors*)gradientColorsTrackHighlight16{
    GCViewGradientColors * rv = RZReturnAutorelease([[GCViewGradientColors alloc] init]);
    if (rv) {
        rv.numberOfColors = 16;

        CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
        rv.colors = malloc(sizeof(CGColorRef) * rv.numberOfColors);
        int i = 0;
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.132,0.820,1.000,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.,0.,0.,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.,0.,0.,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.,0.,0.,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.,0.,0.,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.,0.,0.,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.,0.,0.,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.,0.,0.,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.,0.,0.,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.,0.,0.,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.,0.,0.,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.,0.,0.,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.,0.,0.,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.,0.,0.,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.,0.,0.,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.,0.,0.,1.000 });

        CGColorSpaceRelease(rgb);
    }
    return rv;
}

+(GCViewGradientColors*)gradientColorsRainbowHighlight16{
    GCViewGradientColors * rv = RZReturnAutorelease([[GCViewGradientColors alloc] init] );
    if (rv) {
        rv.numberOfColors = 16;

        CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
        rv.colors = malloc(sizeof(CGColorRef) * rv.numberOfColors);
        int i = 0;
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.596,0.961,1.000,0.800 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.397,0.890,1.000,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.132,0.820,1.000,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.000,0.749,1.000,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.329,1.000,0.624 ,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.343,0.924,0.542 ,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.357,0.848,0.460 ,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.371,0.773,0.378 ,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.384,0.697,0.297 ,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.398,0.621,0.215 ,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.412,0.545,0.133 ,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.820,0.573,0.459 ,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.816,0.507,0.381 ,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.812,0.441,0.304 ,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.808,0.375,0.226 ,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.804,0.310,0.149 ,1.000 });

        CGColorSpaceRelease(rgb);
    }
    return rv;

}

+(GCViewGradientColors*)gradientColorsSingle:(RZColor*)color{
    GCViewGradientColors * rv = RZReturnAutorelease([[GCViewGradientColors alloc] init]);
    if (rv) {
        rv.numberOfColors = 1;
        rv.colors = malloc(sizeof(CGColorRef) * rv.numberOfColors);
        rv.colors[0] = CGColorCreateCopy(color.CGColor);
    }
    return rv;
}

+(GCViewGradientColors*)gradientColorsRainbow16{
    GCViewGradientColors * rv = RZReturnAutorelease([[GCViewGradientColors alloc] init]);
    if (rv) {
        rv.numberOfColors = 16;

        rv.colors = malloc(sizeof(CGColorRef) * rv.numberOfColors);

        size_t i = 0;

        CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.596,0.961,1.000,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.397,0.890,1.000,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.132,0.820,1.000,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.000,0.749,1.000,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.329,1.000,0.624 ,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.343,0.924,0.542 ,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.357,0.848,0.460 ,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.371,0.773,0.378 ,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.384,0.697,0.297 ,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.398,0.621,0.215 ,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.412,0.545,0.133 ,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.820,0.573,0.459 ,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.816,0.507,0.381 ,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.812,0.441,0.304 ,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.808,0.375,0.226 ,1.000 });
        rv.colors[i++] = CGColorCreate(rgb, (CGFloat[]){ 0.804,0.310,0.149 ,1.000 });

        CGColorSpaceRelease(rgb);
    }
    return rv;
}

-(GCViewGradientColors*)gradientAsOneColor:(RZColor*)color{
    GCViewGradientColors * rv = RZReturnAutorelease([[GCViewGradientColors alloc] init]);
    if (rv) {
        rv.numberOfColors = self.numberOfColors;

        rv.colors = malloc(sizeof(CGColorRef) * rv.numberOfColors);
        int i = 0;
        for (i=0; i<rv.numberOfColors; i++) {
            rv.colors[i] = CGColorCreateCopy(color.CGColor);
        }
    }
    return rv;

}

-(GCViewGradientColors*)gradientAsBackground{
    GCViewGradientColors * rv = RZReturnAutorelease([[GCViewGradientColors alloc] init]);
    if (rv) {
        rv.numberOfColors = self.numberOfColors;

        rv.colors = malloc(sizeof(CGColorRef) * rv.numberOfColors);
        int i = 0;
        for (i=0; i<rv.numberOfColors; i++) {
            rv.colors[i] = CGColorCreateCopyWithAlpha(self.colors[i], 0.6);
        }
    }
    return rv;
}


-(CGColorRef)colorsForValue:(CGFloat)aVal{
    NSUInteger idx = MAX(MIN(self.numberOfColors-1, aVal*self.numberOfColors),0);
    return self.colors[idx];
}

@end
