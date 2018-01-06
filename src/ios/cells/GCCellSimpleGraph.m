//  MIT Licence
//
//  Created on 06/10/2012.
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

#import "GCCellSimpleGraph.h"
#import "GCSimpleGraphGestures.h"
#import "GCSimpleGraphCachedDataSource.h"
#import "RZMacros.h"
#import "GCSimpleGraphLegendView.h"

@interface GCCellSimpleGraph ()
@property (nonatomic,retain) GCSimpleGraphView * graphView;
@property (nonatomic,retain) GCSimpleGraphLegendView * legendView;

@end

@implementation GCCellSimpleGraph

+(GCCellSimpleGraph*)graphCell:(UITableView*)tableView{
    GCCellSimpleGraph * rv = (GCCellSimpleGraph*)[tableView dequeueReusableCellWithIdentifier:@"GCGraph"];
    if (rv==nil) {
        rv = RZReturnAutorelease([[GCCellSimpleGraph alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GCGraph"]);
    }else{
        rv.legend = false;// remove legend by default
    }
    return rv;
}

-(void)setLegend:(BOOL)legend{
    if (legend) {
        if (!self.legendView) {
            self.legendView = RZReturnAutorelease([[GCSimpleGraphLegendView alloc] initWithFrame:CGRectZero]);
            self.legendView.dataSource = self.graphView.dataSource;
            self.legendView.displayConfig = self.graphView.displayConfig;
            [self.contentView addSubview:self.legendView];
        }
    }else{
        if (self.legendView) {
            [self.legendView removeFromSuperview];
        }
        self.legendView = nil;
    }
}
-(BOOL)legend{
    return self.legendView == nil;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setGraphView:RZReturnAutorelease([[GCSimpleGraphView alloc] initWithFrame:CGRectZero])];
        [self.contentView addSubview:self.graphView];

        UISwipeGestureRecognizer * swipe = nil;

        swipe = RZReturnAutorelease([[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)]);
        swipe.direction = UISwipeGestureRecognizerDirectionRight;
        [self.contentView addGestureRecognizer:swipe];

        swipe = RZReturnAutorelease([[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)]);
        swipe.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.contentView addGestureRecognizer:swipe];
    }
    return self;
}

-(void)swipeRight:(UISwipeGestureRecognizer*)recognizer{
    if ([self.cellDelegate respondsToSelector:@selector(swipeRight:)]) {
        [self.cellDelegate swipeRight:self];
    }
}

-(void)swipeLeft:(UISwipeGestureRecognizer*)recognizer{
    [self.cellDelegate swipeLeft:self];
}

-(void)setDataSource:(id<GCSimpleGraphDataSource>)aSource andConfig:(id<GCSimpleGraphDisplayConfig>)aConfig{
    (self.graphView).dataSource = aSource;
    (self.graphView).displayConfig = aConfig;
    if (self.legendView) {
        self.legendView.dataSource = aSource;
        self.legendView.displayConfig = aConfig;
    }
    [self.graphView setNeedsDisplay];
    [self.legendView setNeedsDisplay];
}

#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_graphView release];
    [_legendView release];
    [super dealloc];
}
#endif
#define LEGEND_HEIGHT 15.

- (void)layoutSubviews {
	[super layoutSubviews];
    CGRect rect = self.contentView.bounds;
    if (self.legendView) {
        CGRect legendRect = CGRectMake(rect.origin.x,
                                       rect.origin.y+rect.size.height-LEGEND_HEIGHT,
                                       rect.size.width,
                                       LEGEND_HEIGHT);
        rect.size.height -= LEGEND_HEIGHT;
        self.legendView.frame = legendRect;
    }
    self.graphView.frame = rect;
    self.graphView.drawRect = rect;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
