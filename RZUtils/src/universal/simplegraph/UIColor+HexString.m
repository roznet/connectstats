//  MIT Licence
//
//  Created on 06/04/2014.
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

#import "UIColor+HexString.h"

@implementation RZColor(HexString)

+ (RZColor *)colorWithHexValue:(NSUInteger)rgbValue andAlpha:(double)alpha{
    return [RZColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:alpha];
}

+ (RZColor *)colorWithHexLight:(NSUInteger)rgbValue dark:(NSUInteger)darkRgbValue andAlpha:(double)alpha{
#ifdef __IPHONE_13_0xx
    
    if( @available(iOS 13.0, *) ) {
        return [RZColor colorWithDynamicProvider:^(UITraitCollection*trait){
            if( trait.userInterfaceStyle == UIUserInterfaceStyleDark){
                return [RZColor colorWithRed:((darkRgbValue & 0xFF0000) >> 16)/255.0 green:((darkRgbValue & 0xFF00) >> 8)/255.0 blue:(darkRgbValue & 0xFF)/255.0 alpha:alpha];
            }else{
                return [RZColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:alpha];
            }
        }];
    }else{
        return [RZColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:alpha];
    }
#else
    return [RZColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:alpha];
#endif
}
-(NSArray*)rgbComponents{
#if TARGET_OS_IPHONE
    CGFloat red=0.0,green=0.0,blue=0.0,alpha=0.0;
    if ([self getRed:&red green:&green blue:&blue alpha:&alpha]){
        return @[ @(red), @(green), @(blue)];
    }else if( [self getWhite:&red alpha:&alpha] ){
        return @[ @(red), @(red), @(red)];
    }else{
        return nil;
    }
#else
    RZColor * inRgb = [self colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
    return @[ @(inRgb.redComponent), @(inRgb.greenComponent), @(inRgb.blueComponent)];
#endif
}
-(NSArray*)rgbaComponents{
#if TARGET_OS_IPHONE
    CGFloat red=0.0,green=0.0,blue=0.0,alpha=0.0;
    if ([self getRed:&red green:&green blue:&blue alpha:&alpha]){
        return @[ @(red), @(green), @(blue), @(alpha)];
    }else if( [self getWhite:&red alpha:&alpha] ){
        return @[ @(red), @(red), @(red),@(alpha)];
    }else{
        return nil;
    }
#else
    RZColor * inRgb = [self colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
    return @[ @(inRgb.redComponent), @(inRgb.greenComponent), @(inRgb.blueComponent), @(inRgb.alphaComponent)];
#endif
}


-(NSDictionary*)rgbComponentColorSetJsonFormat{
    CGFloat red=0.0,green=0.0,blue=0.0,alpha=0.0;
#if TARGET_OS_IPHONE
    if ([self getRed:&red green:&green blue:&blue alpha:&alpha]){
        //all set
    }else if( [self getWhite:&red alpha:&alpha] ){
        green=red;
        blue=red;
    }
#else
    RZColor * inRgb = [self colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
    
    red = inRgb.redComponent;
    green = inRgb.greenComponent;
    blue = inRgb.blueComponent;
    alpha = inRgb.alphaComponent;
#endif

    return @{
             @"color-space":@"srgb",
             @"components":@{
                     @"red":@(red),
                     @"green":@(green),
                     @"blue":@(blue),
                     @"alpha":@(alpha)
                     }
             };
}
+(RZColor*)colorWithRgbComponents:(NSArray*)array andAlpha:(double)alpha{
    if (array.count >= 3) {
        return [RZColor colorWithRed:[array[0] doubleValue] green:[array[1] doubleValue] blue:[array[2] doubleValue] alpha:alpha];
    }
    return nil;
}

+ (RZColor *) colorWithHexString: (NSString *) hexString {
    NSString *colorString = [hexString stringByReplacingOccurrencesOfString: @"#" withString: @""].uppercaseString;
    CGFloat alpha, red, blue, green;
    switch (colorString.length) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 1];
            green = [self colorComponentFrom: colorString start: 1 length: 1];
            blue  = [self colorComponentFrom: colorString start: 2 length: 1];
            break;
        case 4: // #ARGB
            alpha = [self colorComponentFrom: colorString start: 0 length: 1];
            red   = [self colorComponentFrom: colorString start: 1 length: 1];
            green = [self colorComponentFrom: colorString start: 2 length: 1];
            blue  = [self colorComponentFrom: colorString start: 3 length: 1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 2];
            green = [self colorComponentFrom: colorString start: 2 length: 2];
            blue  = [self colorComponentFrom: colorString start: 4 length: 2];
            break;
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom: colorString start: 0 length: 2];
            red   = [self colorComponentFrom: colorString start: 2 length: 2];
            green = [self colorComponentFrom: colorString start: 4 length: 2];
            blue  = [self colorComponentFrom: colorString start: 6 length: 2];
            break;
        default:
            [NSException raise:@"Invalid color value" format: @"Color value %@ is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString];
            break;
    }
    return [RZColor colorWithRed: red green: green blue: blue alpha: alpha];
}

+ (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}


@end
