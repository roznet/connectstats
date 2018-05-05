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

#import "GCCellGrid.h"
#import "RZViewConfig.h"
#import "RZMacros.h"
#import "GCViewsGrid.h"

#define kCatchWidth 148.f

NSString *const GCCellGridShouldHideMenu = @"GCCellGridShouldHideMenu";

@interface GCCellGrid ()

@property (nonatomic,retain) GCViewsGrid * viewsGrid;

@property (nonatomic,retain) RZParentObject * parentObject;
@property (copy) refreshGCCellGridFunc refreshFunc;

@property (nonatomic,retain) NSArray * labels;
@property (nonatomic,retain) NSArray * configs;
@property (nonatomic,assign) NSUInteger rows;
@property (nonatomic,assign) NSUInteger cols;

@property (nonatomic,assign) UITableView * tableView;

@property (nonatomic,retain) CAGradientLayer * gradientLayer;
@property (nonatomic,retain) NSArray< UIColor*>* backgroundColors;

@end

@implementation GCCellGrid
@synthesize cellLayout,marginx,marginy,iconPosition;

+(GCCellGrid*)cellGrid:(UITableView*)tableView{
    GCCellGrid*cell=(GCCellGrid*)[tableView dequeueReusableCellWithIdentifier:@"GCGrid"];
    if (cell==nil) {
        cell=RZReturnAutorelease([[GCCellGrid alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GCGrid"]);
        cell.tableView = tableView;
        cell.iconView = nil;
        
        
    }
    return cell;
}
+(GCCellGrid*)gridCell:(UITableView*)tableView{
    GCCellGrid*cell=(GCCellGrid*)[tableView dequeueReusableCellWithIdentifier:@"GCGrid"];
    if (cell==nil) {
        cell=RZReturnAutorelease([[GCCellGrid alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GCGrid"]);
        cell.tableView = tableView;
        cell.iconView = nil;


    }
    return cell;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _gradientLayer               = [[CAGradientLayer alloc] init];
        marginx = 2.;
        marginy = 1.;
        cellLayout = gcCellLayoutEven;
        self.tableView = nil;

    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.parentObject detach:self];
    RZRelease(_parentObject);

    RZRelease(_viewsGrid);
    RZRelease(_iconView);
    RZRelease(_gradientLayer);
    RZRelease(_scrollView);
    RZRelease(_scrollViewButtonView);
    RZRelease(_scrollViewContentView);
    RZRelease(_scrollViewLeftButton);
    RZRelease(_scrollViewRightButton);
    RZRelease(_leftButtonText);
    RZRelease(_rightButtonText);
    RZRelease(_backgroundColors);

    RZSuperDealloc;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)clearViews{
    for(UIView *subview in (self.contentView).subviews) {
        [subview removeFromSuperview];
    }
    if (self.scrollView) {
        for(UIView *subview in (self.scrollView).subviews) {
            [subview removeFromSuperview];
        }
        [self.scrollView removeFromSuperview];
    }

}

-(void)prepareForReuse{
    [super prepareForReuse];
    //[self clearViews];
}

-(void)setupForRows:(NSUInteger)nRows andCols:(NSUInteger)nCols{
    [self setParent:nil refresh:nil];

    // clear up
    [self clearViews];

    if (self.enableButtons && self.leftButtonText && self.rightButtonText) {

        self.scrollView = RZReturnAutorelease([[UIScrollView alloc] initWithFrame:CGRectZero]);
        self.scrollView.showsHorizontalScrollIndicator = false;
        self.scrollView.delegate = self;
        [self.contentView addSubview:self.scrollView];

        UITapGestureRecognizer * tap = RZReturnAutorelease([[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)]);
        [self.scrollView addGestureRecognizer:tap];

        CGRect buttonViewRect = CGRectMake(CGRectGetWidth(self.bounds) - kCatchWidth, 0.0f, kCatchWidth, CGRectGetHeight(self.bounds));
        CGRect buttonLeftRect = CGRectMake(0.0f, 0.0f, kCatchWidth / 2.0f, CGRectGetHeight(self.bounds));
        CGRect buttonRightRect = CGRectMake(kCatchWidth / 2.0f, 0.0f, kCatchWidth / 2.0f, CGRectGetHeight(self.bounds));

        UIView *scrollViewButtonView = RZReturnAutorelease([[UIView alloc] initWithFrame:buttonViewRect]);
        self.scrollViewButtonView = scrollViewButtonView;
        [self.scrollView addSubview:scrollViewButtonView];

        // Set up our two buttons
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.backgroundColor = [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0f];
        leftButton.frame = buttonLeftRect;
        [leftButton setTitle:self.leftButtonText forState:UIControlStateNormal];
        [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(userPressedLeftButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollViewButtonView addSubview:leftButton];
        self.scrollViewLeftButton = leftButton;

        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        rightButton.backgroundColor = [UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:1.0f];
        rightButton.frame = buttonRightRect;
        [rightButton setTitle:self.rightButtonText forState:UIControlStateNormal];
        [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(userPressedRightButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollViewButtonView addSubview:rightButton];
        self.scrollViewRightButton = rightButton;

        self.scrollViewContentView = RZReturnAutorelease([[UIView alloc] initWithFrame:CGRectZero]);
        [self.scrollView addSubview:self.scrollViewContentView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideMenuOptions) name:GCCellGridShouldHideMenu object:nil];

    }else{
        self.scrollViewContentView = RZReturnAutorelease([[UIView alloc] initWithFrame:CGRectZero]);
        [self.contentView addSubview:self.scrollViewContentView];

    }

    if (self.iconView) {
        [self.scrollViewContentView addSubview:self.iconView];
    }


    [self setIconImage:nil];
    self.iconPosition = gcIconPositionRight;

    self.viewsGrid = [GCViewsGrid viewsGrid:self.scrollViewContentView ];

    [self.viewsGrid setupForRows:nRows andColumns:nCols];
    [self.viewsGrid setDefaultMarginX:marginx andY:marginy];

}

-(void)handleTap:(UITapGestureRecognizer*)sender{
    if (!self.isShowingMenu) {
        NSIndexPath * indexPath = [self.tableView indexPathForCell:self];
        if (self.tableView) {
            [self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:indexPath];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:GCCellGridShouldHideMenu object:self];
}

- (void)hideMenuOptions {
	[self.scrollView setContentOffset:CGPointZero animated:YES];
}

- (void)userPressedRightButton:(id)sender {
	[self.scrollView setContentOffset:CGPointZero animated:YES];
    if (self.delegate) {
        [self.delegate cellGrid:self didSelectRightButtonAt:[self.tableView indexPathForCell:self]];
    }
}

- (void)userPressedLeftButton:(id)sender {
    if (self.delegate) {
        [self.delegate cellGrid:self didSelectLeftButtonAt:[self.tableView indexPathForCell:self]];
    }
}

-(void)setIconView:(UIView *)iconView withSize:(CGSize)size{
    if (self.iconView) {
        [self.iconView removeFromSuperview];
    }
    self.iconView = iconView;
    self.iconSize = size;
    if (self.iconView) {
        [self.scrollViewContentView addSubview:self.iconView];
    }
}

-(void)setIconImage:(UIImage*)aImg{
    if (aImg == nil) {
        if (self.iconView) {
            self.iconView.frame = CGRectZero;
            [self.iconView removeFromSuperview];
        }
        self.iconSize = CGSizeZero;
        self.iconView = nil;
    }
    else{
        UIImageView * iview = nil;
        if ([self.iconView isKindOfClass:[UIImageView class]]) {
            iview = (UIImageView*)self.iconView;
        }

        if (!iview) {
            iview = RZReturnAutorelease([[UIImageView alloc] initWithFrame:CGRectZero]);
            iview.image = aImg;
            self.iconView = iview;
            self.iconSize = aImg.size;
            [self.scrollViewContentView addSubview:_iconView];
        }else{
            iview.image = aImg;
            self.iconSize = aImg.size;
        }
    }
}

-(void)setupBackgroundColors:(NSArray<UIColor*>*)colors{
    self.backgroundColors = colors;
    if (self.backgroundColors.count>1) {
        NSMutableArray * cgcolors = [NSMutableArray arrayWithCapacity:colors.count];
        for (UIColor * color in colors) {
            [cgcolors addObject:(id)color.CGColor];
        }
        self.gradientLayer.colors = cgcolors;
    }else{
        self.gradientLayer.colors = nil;
    }
}

-(void)setupView:(UIView*)view forRow:(NSUInteger)row andColumn:(NSUInteger)col{
    [self.viewsGrid setupView:view forRow:row andColumn:col];
}
-(UILabel*)labelForRow:(NSUInteger)row andCol:(NSUInteger)col{
    return [self.viewsGrid labelForRow:row andColumn:col];
}
-(GCCellGridConfig*)configForRow:(NSUInteger)row andCol:(NSUInteger)col{
    return [self.viewsGrid configForRow:row andColumn:col];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.accessoryType	= UITableViewCellAccessoryNone;

    // ensure same background color for sub content view
    if (self.backgroundColors.count>1) {
        [self.scrollViewContentView.layer insertSublayer:self.gradientLayer atIndex:0];
    }else if (self.backgroundColors.count>0) {
        [self.gradientLayer removeFromSuperlayer];
        self.contentView.backgroundColor = self.backgroundColors[0];
        self.scrollViewContentView.backgroundColor = self.backgroundColors[0];
    }

    CGRect rect = self.frame;
    //rect = CGRectInset(self.frame, 2., 2.);

    if ( RZTestOption(self.cellInset, gcCellInsetTop )) {
        rect.origin.y += self.cellInsetSize;
        rect.size.height -= self.cellInsetSize;
    }

    if (RZTestOption(self.cellInset, gcCellInsetBottom)) {
        rect.size.height -= self.cellInsetSize;
    }

    rect.origin.y = 0.;
    self.scrollViewContentView.frame = rect;

    if (self.enableButtons) {
        CGRect scrollRect = rect;
        scrollRect.size.width += kCatchWidth;

        self.scrollView.frame = rect;
        self.scrollView.contentSize = scrollRect.size;

        CGRect buttonViewRect = CGRectMake(CGRectGetWidth(rect) - kCatchWidth, 0.0f, kCatchWidth, CGRectGetHeight(rect));
        CGRect buttonLeftRect = CGRectMake(0.0f, 0.0f, kCatchWidth / 2.0f, CGRectGetHeight(rect));
        CGRect buttonRightRect = CGRectMake(kCatchWidth / 2.0f, 0.0f, kCatchWidth / 2.0f, CGRectGetHeight(rect));

        self.scrollViewButtonView.frame  = buttonViewRect;
        self.scrollViewLeftButton.frame  = buttonLeftRect;
        self.scrollViewRightButton.frame = buttonRightRect;
    }

    CGRect iconRect = CGRectZero;
    if (_iconView) {

        if (iconPosition == gcIconPositionLeft) {
            rect.size.width -= _iconSize.width+marginx*2.;
            rect.origin.x += _iconSize.width+marginx*2.;
            iconRect.size = _iconSize;
            iconRect.origin.x=marginx;
            iconRect.origin.y=(rect.size.height-_iconSize.height)/2.;
        }else{
            rect.size.width -= _iconSize.width+marginx*2.;
            iconRect.size = _iconSize;
            iconRect.origin.x=CGRectGetMaxX(rect)+marginx;
            iconRect.origin.y=(rect.size.height-_iconSize.height)/2.;
        }
        self.iconView.frame = iconRect;
        [self.iconView setNeedsDisplay];
    }

    // even, fixed width,
    if (cellLayout == gcCellLayoutFloat) {

    }else if(cellLayout == gcCellLayoutEven){
        NSArray * cellRects = [self.viewsGrid cellRectsEvenIn:rect];
        [self.viewsGrid setupFrames:cellRects inViewRect:rect];
    }

    _gradientLayer.frame = self.contentView.bounds;

}
-(void)setParent:(RZParentObject*)parent refresh:(refreshGCCellGridFunc)block{
    if (self.parentObject) {
        [self.parentObject detach:self];
    }
    self.parentObject = parent;
    self.refreshFunc = block;
    [self.parentObject attach:self];
}
-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    if (theParent==self.parentObject) {
        self.refreshFunc(self);
        [self setNeedsLayout];
    }
}
#pragma mark - scrollView delegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
	if (self.scrollView.contentOffset.x > kCatchWidth) {
		targetContentOffset->x = kCatchWidth;
	} else {
		*targetContentOffset = CGPointZero;

		// Need to call this subsequently to remove flickering. Strange.
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.scrollView setContentOffset:CGPointZero animated:YES];
		});
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (self.scrollView.contentOffset.x < 0.0f) {
		self.scrollView.contentOffset = CGPointZero;
	}

	self.scrollViewButtonView.frame = CGRectMake(scrollView.contentOffset.x + (CGRectGetWidth(self.frame) - kCatchWidth), 0.0f, kCatchWidth, CGRectGetHeight(self.frame));

	if (scrollView.contentOffset.x >= kCatchWidth) {
        // show menu yes
        self.isShowingMenu = YES;
	} else if (scrollView.contentOffset.x == 0.0f) {
        // show menu no
        self.isShowingMenu = NO;
	}
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [[NSNotificationCenter defaultCenter] postNotificationName:GCCellGridShouldHideMenu object:self];
}


@end
