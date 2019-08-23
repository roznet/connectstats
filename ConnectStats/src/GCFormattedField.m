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
@property (nonatomic,retain) GCField*field;

@end

@implementation GCFormattedField
@synthesize unit,value,valueColor,labelColor,valueFont,labelFont,noUnits,noDisplayField;

+(GCFormattedField*)formattedField:(NSString*)field activityType:(NSString*)aType forValue:(double)value inUnit:(NSString*)aUnit forSize:(CGFloat)aSize{
    GCFormattedField * rv = [[[GCFormattedField alloc] init] autorelease];
    if (rv) {
        rv.field = field ? [GCField fieldForKey:field andActivityType:aType] : nil;
        rv.value = value;
        rv.unit = [GCUnit unitForKey:aUnit];
        rv.labelFont = [GCViewConfig systemFontOfSize:aSize];
        rv.valueFont = [GCViewConfig boldSystemFontOfSize:aSize];
        rv.valueColor = [GCViewConfig defaultColor:gcSkinKeyDefaultColorPrimaryText];
        rv.labelColor = [GCViewConfig defaultColor:gcSkinKeyDefaultColorPrimaryText];
    }
    return rv;
}

+(GCFormattedField*)formattedField:(NSString*)field activityType:(NSString*)aType forNumber:(GCNumberWithUnit*)aN forSize:(CGFloat)aSize{
    GCFormattedField * rv = [[[GCFormattedField alloc] init] autorelease];
    if (rv) {
        rv.field = field ? [GCField fieldForKey:field andActivityType:aType] : nil;
        rv.value = aN.value;
        rv.unit = aN.unit;
        rv.labelFont = [GCViewConfig systemFontOfSize:aSize];
        rv.valueFont = [GCViewConfig boldSystemFontOfSize:aSize];
        rv.valueColor = [GCViewConfig defaultColor:gcSkinKeyDefaultColorPrimaryText];
        rv.labelColor = [GCViewConfig defaultColor:gcSkinKeyDefaultColorPrimaryText];
    }
    return rv;
}
-(void)dealloc{
    [_field release];
    [unit release];
    [labelColor release];
    [valueColor release];
    [labelFont release];
    [valueFont release];
    [super dealloc];
}
-(void)setColor:(UIColor*)aColor{
    self.valueColor = aColor;
    self.labelColor = aColor;
}
-(NSAttributedString*)attributedString{
    NSDictionary * attributesLabel = @{NSFontAttributeName: labelFont, NSForegroundColorAttributeName:labelColor};
    NSDictionary * attributesValue = @{NSFontAttributeName: valueFont, NSForegroundColorAttributeName:valueColor};

    NSMutableAttributedString * rv = [[[NSMutableAttributedString alloc] init] autorelease];
    if (_field) {
        NSString * useField = noDisplayField  ? _field.key : [_field displayName];
        if (useField == nil) {
            RZLog(RZLogError, @"Invalid %@ missing display name", _field);
        }else{
            [rv appendAttributedString:[[[NSAttributedString alloc] initWithString:useField attributes:attributesLabel] autorelease]];
            [rv appendAttributedString:[[[NSAttributedString alloc] initWithString:@" " attributes:attributesLabel] autorelease]];
        }
    }
    GCUnit * useUnit = unit;
    if (!useUnit) {
        useUnit = [GCUnit unitForKey:@"dimensionless"];
    }
    GCNumberWithUnit * num = [GCNumberWithUnit numberWithUnit:useUnit andValue:value];

    if (useUnit && [useUnit unitForGlobalSystem] != useUnit) {
        useUnit = [unit unitForGlobalSystem];
        if ([_field.key hasSuffix:@"Elevation"] && [useUnit.key isEqualToString:@"yard"]) {
            useUnit = [GCUnit unitForKey:@"foot"];
        }
        if( useUnit ){
            num = [num convertToUnit:useUnit];
        }
    }
    [rv appendAttributedString:[num attributedStringWithValueAttr:attributesValue andUnitAttr: (!noUnits&&unit)?attributesLabel:nil]];

    return rv;
}
-(NSAttributedString*)attributedStringForSize:(CGFloat)aSize andColor:(UIColor*)aColor{
    return  nil;
}


@end

