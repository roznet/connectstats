//  MIT Licence
//
//  Created on 26/10/2014.
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

#import <TargetConditionals.h>

#if TARGET_OS_IPHONE
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

#import <RZUtils/RZUtils.h>

typedef NS_ENUM(NSUInteger, gcFontStyle){
    gcFontStyleDynamicType,
    gcFontStyleHelveticaNeue

};

typedef NS_ENUM(NSUInteger, rzTextColor){
    rzColorStylePrimaryText,
    rzColorStyleSecondaryText,
    rzColorStyleTertiaryText,
    rzColorStyleHighlightedText
};

@interface RZViewConfig : NSObject

+(gcFontStyle)fontStyle;
+(void)setFontStyle:(gcFontStyle)fontStyle;

+(RZColor*)backgroundForLegend;


+(NSDictionary<NSString*,id>*)attribute16;
+(NSDictionary<NSString*,id>*)attribute16Gray;
+(NSDictionary<NSString*,id>*)attribute16Highlighted;
+(NSDictionary<NSString*,id>*)attributeBold16;
+(NSDictionary<NSString*,id>*)attributeBold16Highlighted;
+(NSDictionary<NSString*,id>*)attribute14;
+(NSDictionary<NSString*,id>*)attribute14Gray;
+(NSDictionary<NSString*,id>*)attribute14White;
+(NSDictionary<NSString*,id>*)attribute14Highlighted;
+(NSDictionary<NSString*,id>*)attributeBold14;
+(NSDictionary<NSString*,id>*)attribute12;
+(NSDictionary<NSString*,id>*)attribute12Gray;
+(NSDictionary<NSString*,id>*)attribute12Highlighted;
+(NSAttributedString*)attributedString:(NSString*)str attribute:(SEL)sel;

+(RZColor*)colorForText:(rzTextColor)which;
+(RZImage*)checkMarkImage:(BOOL)val;
+(RZFont*)systemFontOfSize:(CGFloat)size;
+(RZFont*)boldSystemFontOfSize:(CGFloat)size;
+(CGFloat)sizeForNumberOfRows:(NSUInteger)rows;

#if TARGET_OS_IPHONE
+(RZImage*)imageWithView:(UIView *)view;
#endif


@end

@interface NSDictionary (RZViewConfig)

-(NSDictionary<NSString*,id>*)viewConfigAttributeDisabled;

@end
