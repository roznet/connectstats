//  MIT Licence
//
//  Created on 08/11/2012.
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

#import "GCFormattedField.h"
#import "GCViewConfig.h"
#import "GCField.h"

@interface GCFormattedField ()

@property (nonatomic,retain) NSString * useFieldDisplay;
@end

@implementation GCFormattedField

+(GCFormattedField*)formattedField:(GCField*)field forNumber:(GCNumberWithUnit*)nu forSize:(CGFloat)aSize{
    GCFormattedField * rv = [[[GCFormattedField alloc] init] autorelease];
    if (rv) {
        rv.field = field;
        rv.numberWithUnit = nu;
        rv.labelFont = [GCViewConfig systemFontOfSize:aSize];
        rv.valueFont = [GCViewConfig boldSystemFontOfSize:aSize];
        rv.valueColor = [GCViewConfig defaultColor:gcSkinDefaultColorPrimaryText];
        rv.labelColor = [GCViewConfig defaultColor:gcSkinDefaultColorPrimaryText];
    }
    return rv;
}
+(GCFormattedField*)formattedFieldDisplay:(NSString*)fieldDisplay forNumber:(GCNumberWithUnit*)nu forSize:(CGFloat)aSize{
    GCFormattedField * rv = [GCFormattedField formattedField:nil forNumber:nu forSize:aSize];
    rv.useFieldDisplay = fieldDisplay;
    return rv;
}
+(GCFormattedField*)formattedFieldForNumber:(GCNumberWithUnit*)nu forSize:(CGFloat)aSize{
    return [GCFormattedField formattedField:nil forNumber:nu forSize:aSize];
}

+(GCFormattedField*)formattedField:(NSString*)field activityType:(NSString*)aType forNumber:(GCNumberWithUnit*)aN forSize:(CGFloat)aSize{
    GCFormattedField * rv = [[[GCFormattedField alloc] init] autorelease];
    if (rv) {
        rv.field = field ? [GCField fieldForKey:field andActivityType:aType] : nil;
        rv.numberWithUnit = aN;
        rv.labelFont = [GCViewConfig systemFontOfSize:aSize];
        rv.valueFont = [GCViewConfig boldSystemFontOfSize:aSize];
        rv.valueColor = [GCViewConfig defaultColor:gcSkinDefaultColorPrimaryText];
        rv.labelColor = [GCViewConfig defaultColor:gcSkinDefaultColorPrimaryText];
    }
    return rv;
}
-(void)dealloc{
    [_field release];
    [_useFieldDisplay release];
    [_numberWithUnit release];
    [_labelColor release];
    [_valueColor release];
    [_labelFont release];
    [_valueFont release];
    [super dealloc];
}
-(void)setColor:(UIColor*)aColor{
    self.valueColor = aColor;
    self.labelColor = aColor;
}
-(NSAttributedString*)attributedString{
    NSDictionary * attributesLabel = @{NSFontAttributeName: self.labelFont, NSForegroundColorAttributeName:self.labelColor};
    NSDictionary * attributesValue = @{NSFontAttributeName: self.valueFont, NSForegroundColorAttributeName:self.valueColor};

    NSMutableAttributedString * rv = [[[NSMutableAttributedString alloc] init] autorelease];
    if (_field) {
        NSString * useFieldDisplay = self.noDisplayField  ? self.field.key : [_field displayName];
        if( self.useFieldDisplay ){
            useFieldDisplay = self.useFieldDisplay;
        }
        if (useFieldDisplay == nil) {
            RZLog(RZLogError, @"Invalid %@ missing display name", _field);
        }else{
            if( self.shareFieldLabel && !self.noDisplayField){
                if( [self.shareFieldLabel isEqualToField:[self.field correspondingWeightedMeanField]]){
                    // Try to remove duplicated text
                    NSString * shareFieldDisplay = self.shareFieldLabel.displayName;
                    if( [shareFieldDisplay hasPrefix:@"Avg "] && [useFieldDisplay hasPrefix:@"Max "] ){
                        useFieldDisplay = @"Max";
                    }
                    if( [shareFieldDisplay hasPrefix:@"Avg "] && [useFieldDisplay hasPrefix:@"Min "] ){
                        useFieldDisplay = @"Min";
                    }
                }
            }
            
            [rv appendAttributedString:[[[NSAttributedString alloc] initWithString:useFieldDisplay attributes:attributesLabel] autorelease]];
            [rv appendAttributedString:[[[NSAttributedString alloc] initWithString:@" " attributes:attributesLabel] autorelease]];
        }
    }
    GCUnit * useUnit = self.numberWithUnit.unit;
    GCNumberWithUnit * num = self.numberWithUnit;

    if (useUnit && [useUnit unitForGlobalSystem] != useUnit) {
        useUnit = [useUnit unitForGlobalSystem];
        if ([_field.key hasSuffix:@"Elevation"] && [useUnit.key isEqualToString:@"yard"]) {
            useUnit = [GCUnit unitForKey:@"foot"];
        }
        if( useUnit ){
            num = [num convertToUnit:useUnit];
        }
    }
    [rv appendAttributedString:[num attributedStringWithValueAttr:attributesValue andUnitAttr: (!self.noUnits)?attributesLabel:nil]];

    return rv;
}
-(NSAttributedString*)attributedStringForSize:(CGFloat)aSize andColor:(UIColor*)aColor{
    return  nil;
}


@end

