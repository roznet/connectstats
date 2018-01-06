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

#import <Foundation/Foundation.h>

@interface GCFormattedFieldText : NSObject{
    NSString * label;
    NSString * value;

    UIColor * labelColor;
    UIColor * valueColor;

    UIFont * labelFont;
    UIFont * valueFont;

}
@property (nonatomic,retain) NSString * label;
@property (nonatomic,retain) NSString * value;

@property (nonatomic,retain) UIColor * labelColor;
@property (nonatomic,retain) UIColor * valueColor;
@property (nonatomic,retain) UIFont * labelFont;
@property (nonatomic,retain) UIFont * valueFont;

+(GCFormattedFieldText*)formattedFieldText:(NSString*)alabel value:(NSString*)aVal forSize:(CGFloat)aSize;

-(void)setColor:(UIColor*)aColor;
-(NSAttributedString*)attributedString;

@end
