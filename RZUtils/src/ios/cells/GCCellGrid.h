//  MIT Licence
//
//  Created on 09/10/2012.
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

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <RZUtils/RZUtils.h>
#import "GCCellGridConfig.h"

typedef NS_ENUM(NSUInteger, gcCellLayout){
    gcCellLayoutEven,  // divide by number of cols
    gcCellLayoutAlign, // left, center, right
    gcCellLayoutFloat  // stack left to right.
};

typedef NS_ENUM(NSUInteger, gcIconPosition){
    gcIconPositionRight = 0,
    gcIconPositionLeft = 1
};

typedef NS_OPTIONS(NSUInteger, gcCellInset) {
    gcCellInsetNone = 0,
    gcCellInsetTop = 1 << 0,
    gcCellInsetBottom = 2<<0
};

extern NSString *const GCCellGridShouldHideMenu;

@class GCCellGrid;

typedef void(^refreshGCCellGridFunc)(GCCellGrid*cell);

@protocol GCCellGridDelegate <NSObject>

-(void)cellGrid:(GCCellGrid*)cell didSelectRightButtonAt:(NSIndexPath*)indexPath;
-(void)cellGrid:(GCCellGrid*)cell didSelectLeftButtonAt:(NSIndexPath*)indexPath;

@end


@interface GCCellGrid : UITableViewCell<UIScrollViewDelegate,RZChildObject>{
    gcCellLayout cellLayout;

    CGFloat marginx;
    CGFloat marginy;
}


@property (nonatomic,retain) UIView * iconView;
@property (nonatomic,assign) CGSize iconSize;
@property (nonatomic,assign) gcCellLayout cellLayout;
@property (nonatomic,assign) CGFloat marginx;
@property (nonatomic,assign) CGFloat marginy;
@property (nonatomic,assign) CGFloat height;
@property (nonatomic,assign) gcIconPosition iconPosition;

@property (nonatomic,assign) BOOL enableButtons;
@property (nonatomic,retain) UIScrollView * scrollView;
@property (nonatomic,retain) UIView * scrollViewButtonView;
@property (nonatomic,retain) UIView * scrollViewContentView;

@property (nonatomic,retain) UIButton * scrollViewLeftButton;
@property (nonatomic,retain) UIButton * scrollViewRightButton;

@property (nonatomic,assign) BOOL isShowingMenu;
@property (nonatomic,assign) NSObject<GCCellGridDelegate> * delegate;

@property (nonatomic,retain) NSString * leftButtonText;
@property (nonatomic,retain) NSString * rightButtonText;

@property (nonatomic,assign) gcCellInset cellInset;
@property (nonatomic,assign) CGFloat cellInsetSize;

+(GCCellGrid*)gridCell:(UITableView*)tableView;
+(GCCellGrid*)cellGrid:(UITableView*)tableView;

-(void)setupForRows:(NSUInteger)nRows andCols:(NSUInteger)nCols;
-(void)setIconImage:(UIImage*)aImg;
-(void)setIconView:(UIView *)iconView withSize:(CGSize)size;

/**
 @brief array of colors, if one background else gradient
 */
-(void)setupBackgroundColors:(NSArray<UIColor*>*)colors;

-(UILabel*)labelForRow:(NSUInteger)row andCol:(NSUInteger)col;
-(GCCellGridConfig*)configForRow:(NSUInteger)row andCol:(NSUInteger)col;
-(void)setupView:(UIView*)view forRow:(NSUInteger)row andColumn:(NSUInteger)col;

-(void)setParent:(RZParentObject*)parent refresh:(refreshGCCellGridFunc)block;


@end
