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

#import "RZViewConfig.h"
#import "UIColor+HexString.h"

static gcFontStyle _fontStyle;

@implementation RZViewConfig
#pragma mark - Fonts

+(gcFontStyle)fontStyle{
    return _fontStyle;
}

+(void)setFontStyle:(gcFontStyle)fontStyle{
    _fontStyle = fontStyle;
}

+(RZColor*)backgroundForLegend{
    return [RZColor colorWithHexValue:0xE7EDF5 andAlpha:1.];
}


+(NSAttributedString*)attributedString:(NSString*)str attribute:(SEL)sel{
    if (str==nil) {
        return nil;
    }
    // needs below because ARC can't call performSelector it does not know.
    IMP imp = [self methodForSelector:sel];
    id (*func)(id, SEL) = (void *)imp;
    id attr = func(self, sel);

    return RZReturnAutorelease([[NSAttributedString alloc] initWithString:str attributes:attr]);
}

+(NSDictionary<NSString*,id>*)attribute16{
    return @{ NSFontAttributeName: [self systemFontOfSize:16.],
              NSForegroundColorAttributeName: [self colorForText:rzColorStylePrimaryText]
              };

}

+(NSDictionary<NSString*,id>*)attributeBold16{
    return @{ NSFontAttributeName:  [self boldSystemFontOfSize:16.],
              NSForegroundColorAttributeName: [self colorForText:rzColorStylePrimaryText]
              };
}

+(NSDictionary<NSString*,id>*)attributeBold16Highlighted{
    return @{ NSFontAttributeName:  [self boldSystemFontOfSize:16.],
              NSForegroundColorAttributeName: [self colorForText:rzColorStyleHighlightedText]
              };
}

+(NSDictionary<NSString*,id>*)attribute16Highlighted{
    return @{ NSFontAttributeName:  [self systemFontOfSize:16.],
              NSForegroundColorAttributeName: [self colorForText:rzColorStyleHighlightedText]
              };
}

+(NSDictionary<NSString*,id>*)attribute16Gray{
    return @{ NSFontAttributeName: [self systemFontOfSize:16.],
              NSForegroundColorAttributeName: [self colorForText:rzColorStyleSecondaryText]
              };

}
+(NSDictionary<NSString*,id>*)attribute14{
    return @{ NSFontAttributeName: [self systemFontOfSize:14.],
              NSForegroundColorAttributeName: [self colorForText:rzColorStylePrimaryText]
              };

}

+(NSDictionary<NSString*,id>*)attribute14Highlighted{
    return @{ NSFontAttributeName:  [self systemFontOfSize:14.],
              NSForegroundColorAttributeName: [self colorForText:rzColorStyleHighlightedText]
              };
}

+(NSDictionary<NSString*,id>*)attribute14White{
    return @{ NSFontAttributeName: [self systemFontOfSize:14.],
              NSForegroundColorAttributeName: [RZColor whiteColor]
              };

}

+(NSDictionary<NSString*,id>*)attributeBold14{
    return @{ NSFontAttributeName: [self boldSystemFontOfSize:14.],
              NSForegroundColorAttributeName: [self colorForText:rzColorStylePrimaryText]
              };

}

+(NSDictionary<NSString*,id>*)attribute14Gray{
    return @{ NSFontAttributeName: [self systemFontOfSize:14.],
              NSForegroundColorAttributeName: [self colorForText:rzColorStyleSecondaryText]
              };
}

+(NSDictionary<NSString*,id>*)attribute12{
    return @{ NSFontAttributeName: [self systemFontOfSize:12.],
              NSForegroundColorAttributeName: [self colorForText:rzColorStylePrimaryText]
              };

}
+(NSDictionary<NSString*,id>*)attribute12Highlighted{
    return @{ NSFontAttributeName:  [self systemFontOfSize:12.],
              NSForegroundColorAttributeName: [self colorForText:rzColorStyleHighlightedText]
              };
}

+(NSDictionary<NSString*,id>*)attribute12Gray{
    return @{ NSFontAttributeName: [self systemFontOfSize:12.],
              NSForegroundColorAttributeName: [self colorForText:rzColorStyleSecondaryText]
              };
}

+(RZImage*)checkMarkImage:(BOOL)val{
    return [RZImage imageNamed:val ? @"check" : @"checkoff"];
}
+(RZColor*)colorForText:(rzTextColor)which{
    if( @available( iOS 13.0, * ) ){
        switch (which) {
                case rzColorStylePrimaryText:
                    return [RZColor labelColor];
                case rzColorStyleSecondaryText:
                    return [RZColor secondaryLabelColor];
                case rzColorStyleTertiaryText:
                    return [RZColor tertiaryLabelColor];
                case rzColorStyleHighlightedText:
                    return [RZColor linkColor];
            }

    }else{
        switch (which) {
            case rzColorStylePrimaryText:
                return [RZColor blackColor];
            case rzColorStyleSecondaryText:
                return [RZColor darkGrayColor];
            case rzColorStyleTertiaryText:
                return [RZColor darkGrayColor];
            case rzColorStyleHighlightedText:
                return [RZColor blueColor];
        }
    }
    return nil;
}

+(CGFloat)sizeForNumberOfRows:(NSUInteger)rows{
    CGSize size = [@"A" sizeWithAttributes:[self attribute16]];
    CGFloat rv = size.height  * rows;
    return ceil( rv * 1.05 ); // 5% margin
}

+(RZFont*)systemFontOfSize:(CGFloat)size{
#if TARGET_OS_IPHONE
    if (_fontStyle == gcFontStyleDynamicType) {
        UIFontDescriptor * descriptor = nil;
        if (size == 12.) {
            descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleFootnote];
        }else if(size==14.){
            descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
        }else if (size==16.){
            descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
        }
        //return [RZFont boldSystemFontOfSize:size];
        if (descriptor == nil) {
            return [RZFont systemFontOfSize:size];
        }else{
            descriptor = [descriptor fontDescriptorByAddingAttributes:@{UIFontWeightTrait:@( UIFontWeightLight )}];
            return [UIFont fontWithDescriptor:descriptor size:descriptor.pointSize];
        }
    }else{
        return [RZFont fontWithName:@"HelveticaNeue-Light" size:size];
    }
#else
    //return [RZFont fontWithName:@"HelveticaNeue-Light" size:size];
    return [RZFont systemFontOfSize:size];
#endif
}
+(RZFont*)boldSystemFontOfSize:(CGFloat)size{
#if TARGET_OS_IPHONE
    if (_fontStyle == gcFontStyleDynamicType) {

        UIFontDescriptor * descriptor = nil;
        if (size == 12.) {
            descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleFootnote];
        }else if(size==14.){
            descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
        }else if (size==16.){
            descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
        }
        //return [RZFont boldSystemFontOfSize:size];
        if (descriptor == nil) {
            return [RZFont systemFontOfSize:size];
        }else{
            descriptor = [descriptor fontDescriptorByAddingAttributes:@{UIFontWeightTrait:@(UIFontWeightRegular)}];
            return [UIFont fontWithDescriptor:descriptor size:descriptor.pointSize];
        }
    }else{
        return [RZFont fontWithName:@"HelveticaNeue" size:size];
    }
#else
      return [RZFont fontWithName:@"HelveticaNeue" size:size];
#endif
}

#pragma mark - OS Dependent

#if TARGET_OS_IPHONE
+(UIImage*)imageWithView:(UIView *)view{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];

    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return img;
}
#endif


@end

@implementation NSDictionary (RZViewConfig)

-(NSDictionary<NSString*,id>*)viewConfigAttributeDisabled{
    NSMutableDictionary * rv = [NSMutableDictionary dictionaryWithDictionary:self];
    rv[NSForegroundColorAttributeName] = [RZViewConfig colorForText:rzColorStyleSecondaryText];
    return rv;
}

@end
