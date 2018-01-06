//  MIT Licence
//
//  Created on 01/12/2012.
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

#import "GCFormattedFieldText.h"
#import "GCViewConfig.h"

@implementation GCFormattedFieldText
@synthesize label,value,valueColor,labelColor,valueFont,labelFont;

+(GCFormattedFieldText*)formattedFieldText:(NSString*)alabel value:(NSString*)aVal forSize:(CGFloat)aSize{
    GCFormattedFieldText * rv = [[[GCFormattedFieldText alloc] init] autorelease];
    if (rv) {
        rv.label = alabel;
        rv.value = aVal;

        rv.labelFont = [GCViewConfig systemFontOfSize:aSize];
        rv.valueFont = [GCViewConfig boldSystemFontOfSize:aSize];
        rv.valueColor = [UIColor blackColor];
        rv.labelColor = [UIColor blackColor];
    }
    return rv;
}
-(void)dealloc{
    [label release];
    [value release];

    [labelFont release];
    [valueFont release];

    [labelColor release];
    [valueColor release];

    [super dealloc];
}

-(void)setColor:(UIColor*)aColor{
    self.valueColor = aColor;
    self.labelColor = aColor;
}


-(NSAttributedString*)attributedString{
    NSMutableDictionary * attributesLabel = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             labelFont, NSFontAttributeName,
                                             labelColor, NSForegroundColorAttributeName,
                                             nil];
    NSMutableDictionary * attributesValue = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             valueFont, NSFontAttributeName,
                                             valueColor, NSForegroundColorAttributeName,
                                             nil];
    NSMutableAttributedString * rv = [[[NSMutableAttributedString alloc] init] autorelease];

    if (label) {
        [rv appendAttributedString:[[[NSAttributedString alloc] initWithString:label attributes:attributesLabel] autorelease]];
        [rv appendAttributedString:[[[NSAttributedString alloc] initWithString:@" " attributes:attributesLabel] autorelease]];
    }
    if (value) {
        [rv appendAttributedString:[[[NSAttributedString alloc] initWithString:value attributes:attributesValue] autorelease]];
    }
    return rv;
}

@end
