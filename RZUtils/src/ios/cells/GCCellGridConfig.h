//  MIT Licence
//
//  Created on 29/11/2015.
//
//  Copyright (c) 2015 Brice Rosenzweig.
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
#import <UIKit/UIKit.h>
#import <RZUtils/RZUtils.h>

typedef struct {
    BOOL flag;
    CGFloat value;
} gcCellOptionalValue;

typedef NS_ENUM(NSUInteger, gcVerticalAlign){
    gcVerticalAlignAuto,
    gcVerticalAlignBottom,
    gcVerticalAlignTop,
    gcVerticalAlignCenter,
    gcVerticalAlignFill
};

typedef NS_ENUM(NSUInteger, gcHorizontalAlign){
    gcHorizontalAlignAuto,
    gcHorizontalAlignLeft,
    gcHorizontalAlignRight,
    gcHorizontalAlignCenter,
    gcHorizontalAlignFill
};


@interface GCCellGridConfig : NSObject

@property (nonatomic,assign) gcCellOptionalValue fixedWidth;

@property (nonatomic,assign) BOOL horizontalOverflow;
@property (nonatomic,assign) BOOL verticalOverflow;

@property (nonatomic,assign) NSUInteger columnSpan;
@property (nonatomic,assign) NSUInteger rowSpan;

@property (nonatomic,assign) gcHorizontalAlign horizontalAlign;
@property (nonatomic,assign) gcVerticalAlign verticalAlign;

@property (nonatomic,assign) CGFloat marginX;
@property (nonatomic,assign) CGFloat marginY;

@property (nonatomic,assign) CGSize minimumSize;

+(GCCellGridConfig*)cellGridConfig;

-(BOOL)shouldAdjustsFontSizeToFitWidth:(CGRect)rect inCellRect:(CGRect)cellRect;
-(CGRect)positionSize:(CGSize)size inCellRect:(CGRect)cellRect inViewRect:(CGRect)viewRect;

@end
