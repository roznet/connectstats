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

#import <Foundation/Foundation.h>
#import "GCFields.h"

@interface GCFormattedField : NSObject{
    GCUnit * unit;
    double value;

    BOOL noUnits;
    BOOL noDisplayField;

    UIColor * labelColor;
    UIColor * valueColor;

    UIFont * labelFont;
    UIFont * valueFont;
}


@property (nonatomic,retain) GCUnit*unit;
@property (nonatomic,assign) double value;

@property (nonatomic,assign) BOOL noDisplayField;
@property (nonatomic,assign) BOOL noUnits;

@property (nonatomic,retain) UIColor * labelColor;
@property (nonatomic,retain) UIColor * valueColor;
@property (nonatomic,retain) UIFont * labelFont;
@property (nonatomic,retain) UIFont * valueFont;

//+(GCFormattedField*)formattedField:(NSString*)field activityType:(NSString*)aType forValue:(double)value inUnit:(NSString*)aUnit forSize:(CGFloat)aSize;
+(GCFormattedField*)formattedField:(NSString*)field activityType:(NSString*)aType forNumber:(GCNumberWithUnit*)aN forSize:(CGFloat)aSize;

-(NSAttributedString*)attributedString;
-(void)setColor:(UIColor*)aColor;

@end
