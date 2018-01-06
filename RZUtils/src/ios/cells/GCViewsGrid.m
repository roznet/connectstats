//  MIT Licence
//
//  Created on 28/11/2015.
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

#import "GCViewsGrid.h"
#import "RZMacros.h"
#import "GCCellGridConfig.h"


@interface GCCellViewHolder : NSObject

@property (nonatomic,retain) UILabel * label;
@property (nonatomic,retain) UIView  * view;
@property (nonatomic,retain) GCCellGridConfig * config;

-(CGSize)size;

@end

@implementation GCCellViewHolder

#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_label release];
    [_view release];
    [_config release];
    [super dealloc];
}
#endif
+(GCCellViewHolder*)holder:(UIView*)parentView{
    GCCellViewHolder * rv = RZReturnAutorelease([[GCCellViewHolder alloc] init]);
    if (rv) {
        rv.label = RZReturnAutorelease([[UILabel alloc] initWithFrame:CGRectZero]);
        [parentView addSubview:rv.label];
        rv.config  = [GCCellGridConfig cellGridConfig];
    }
    return rv;
}

-(void)resetInView:(UIView*)parentView{
    if (self.view) {
        [self.view removeFromSuperview];
        self.view = nil;
    }
    if (self.label) {
        self.label.frame = CGRectZero;
    }
}

-(void)resetToEmptyInView:(UIView*)parentView{
    [self resetInView:parentView];
    self.label.attributedText = nil;
    self.label.text = nil;
    // reset to defaults;
    self.config = [GCCellGridConfig cellGridConfig];
}

-(void)setupForView:(UIView*)view inParentView:(UIView*)parentView{
    if (self.view && self.view == view) {
        return;
    }
    if (self.view) {
        [self.view removeFromSuperview];
        self.view = nil;
    }
    if (self.label) {
        [self.label removeFromSuperview];
        self.label = nil;
    }
    self.view = view;
    self.config.verticalAlign = gcVerticalAlignFill;
    self.config.horizontalAlign = gcHorizontalAlignFill;
    [parentView addSubview:self.view];
}

-(void)setupForLabel:(UIView*)parentView{
    if(self.label == nil){
        if (self.view) {
            [self.view removeFromSuperview];
            self.view = nil;
        }
        self.label = RZReturnAutorelease([[UILabel alloc] initWithFrame:CGRectZero]);
        self.config.verticalAlign = gcVerticalAlignAuto;
        self.config.horizontalAlign= gcHorizontalAlignAuto;
        [parentView addSubview:self.label];

    }
}

-(CGSize)size{
    CGSize rv = CGSizeZero;
    if (self.label) {
        if (self.label.attributedText) {
            rv = [self.label.attributedText size];
        }else if (self.label.text){
            rv = [self.label.text sizeWithAttributes:@{NSFontAttributeName:self.label.font}];
        }
    }else if (self.view){
        rv = self.view.frame.size;
    }

    rv.height = MAX(self.config.minimumSize.height, rv.height);
    rv.width  = MAX(self.config.minimumSize.width,  rv.width);

    return rv;
}

-(void)setFrame:(CGRect)rect{
    if (self.label) {
        self.label.frame = rect;
    }else if (self.view){
        self.view.frame = rect;
    }
}
@end

#pragma mark

@interface GCViewsGridGeometry : NSObject

@property (nonatomic,retain) NSArray * sizes;
@property (nonatomic,retain) NSArray * columnsWidths;
@property (nonatomic,retain) NSArray * rowsHeights;
@property (nonatomic,assign) CGFloat columnsTotalWidth;
@property (nonatomic,assign) CGFloat rowsTotalHeight;

@end

@implementation GCViewsGridGeometry

#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_sizes release];
    [_columnsWidths release];
    [_rowsHeights release];

    [super dealloc];
}
#endif

@end
#pragma mark

@interface GCViewsGrid ()

@property (nonatomic,retain) UIView * parentView;
@property (nonatomic,retain) NSArray<GCCellViewHolder*> * viewHolders;

@property (nonatomic,assign) GCCellCoordinate dimension;

@property (nonatomic,retain) GCViewsGridGeometry * geometry;

@end

@implementation GCViewsGrid

+(GCViewsGrid*)viewsGrid:(UIView*)parentView{
    GCViewsGrid*rv = RZReturnAutorelease([[GCViewsGrid alloc] init]);
    if (rv) {
        rv.parentView = parentView;
        rv.viewHolders = @[];
    }
    return rv;
}

#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_parentView release];
    [_viewHolders release];
    [_geometry release];

    [super dealloc];
}
#endif

#pragma mark - Access

-(NSUInteger)rowsCount{
    return _dimension.row;
}

-(NSUInteger)columnsCount{
    return _dimension.column;
}

-(NSUInteger)count{
    return GCCellCountFromDimension(_dimension);
}

-(NSArray<NSValue*>*)sizes{
    [self calculateGeometry];
    return self.geometry.sizes;
}

-(NSArray<NSNumber*>*)columnsWidths{
    [self calculateGeometry];
    return self.geometry.columnsWidths;
}

-(NSArray<NSNumber*>*)rowsHeights{
    [self calculateGeometry];
    return self.geometry.rowsHeights;
}


#pragma mark -  Setup

-(void)setDimension:(GCCellCoordinate)dimension{
    _dimension = dimension;
    NSUInteger targetCount = GCCellCountFromDimension(self.dimension);
    NSUInteger currentCount = self.viewHolders.count;

    NSMutableArray * missing = [NSMutableArray array];

    while (currentCount < targetCount) {
        GCCellViewHolder * holder = [GCCellViewHolder holder:self.parentView];
        [missing addObject:holder];
        currentCount++;
    }
    if (missing.count>0) {
        self.viewHolders = [self.viewHolders arrayByAddingObjectsFromArray:missing];
    }
    self.geometry = nil;
}
-(void)setDefaultMarginX:(CGFloat)mX andY:(CGFloat)mY{
    for (GCCellViewHolder * holder in self.viewHolders) {
        holder.config.marginX = mX;
        holder.config.marginY = mY;
    }
}

-(UILabel*)labelForRow:(NSUInteger)row andColumn:(NSUInteger)col{
    NSUInteger idx = GCCellIndexFromCoordinate(GCCellCoordinateMake(row, col), self.dimension);
    self.geometry = nil;
    GCCellViewHolder * holder = self.viewHolders[idx];
    [holder setupForLabel:self.parentView];

    return holder.label;
}
-(UIView*)viewForRow:(NSUInteger)row andColumn:(NSUInteger)col{
    NSUInteger idx = GCCellIndexFromCoordinate(GCCellCoordinateMake(row, col), self.dimension);
    self.geometry = nil;
    GCCellViewHolder * holder = self.viewHolders[idx];
    return holder.view ?: holder.label;
}

-(void)setupView:(UIView*)view forRow:(NSUInteger)row andColumn:(NSUInteger)col{
    NSUInteger idx = GCCellIndexFromCoordinate(GCCellCoordinateMake(row, col), self.dimension);
    self.geometry = nil;
    [self.viewHolders[idx] setupForView:view inParentView:self.parentView];
}

-(GCCellGridConfig*)configForRow:(NSUInteger)row andColumn:(NSUInteger)col{
    NSUInteger idx = GCCellIndexFromCoordinate(GCCellCoordinateMake(row, col), self.dimension);
    self.geometry = nil;
    return self.viewHolders[idx].config;
}

-(void)setupForRows:(NSUInteger)rowsCount andColumns:(NSUInteger)columnsCount{
    self.dimension = GCCellCoordinateMake(rowsCount, columnsCount);
    self.geometry = nil;
};

#pragma  mark - Geometry

-(void)calculateGeometry{
    if (self.geometry) {
        return;
    }
    NSUInteger count = self.count;
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:count];

    CGFloat * colSizes = calloc(sizeof(CGFloat), count);
    CGFloat * rowSizes = calloc(sizeof(CGFloat), count);

    for (NSUInteger idx = 0; idx<count; idx++) {
        GCCellViewHolder * holder = self.viewHolders[idx];
        CGSize size = [holder size];
        GCCellCoordinate coord = GCCellCoordinateFromIndex(idx, _dimension);
        colSizes[coord.column] = MAX(colSizes[coord.column], size.width);
        rowSizes[coord.row] = MAX(rowSizes[coord.row], size.height);

        [rv addObject:[NSValue valueWithCGSize:size]];
    }
    NSMutableArray * geomColSizes = [NSMutableArray arrayWithCapacity:_dimension.column];
    NSMutableArray * geomRowSizes = [NSMutableArray arrayWithCapacity:_dimension.row];

    CGFloat totalWidth = 0.;
    CGFloat totalHeight = 0.;

    for (size_t i=0; i<_dimension.column; i++) {
        totalWidth += colSizes[i];
        [geomColSizes addObject:@(colSizes[i])];
    }
    for (size_t i=0; i<_dimension.row; i++) {
        totalHeight += rowSizes[i];
        [geomRowSizes addObject:@(rowSizes[i])];
    }

    free(colSizes);
    free(rowSizes);

    self.geometry = RZReturnAutorelease([[GCViewsGridGeometry alloc] init]);
    self.geometry.sizes = rv;
    self.geometry.rowsHeights = geomRowSizes;
    self.geometry.columnsWidths = geomColSizes;
    self.geometry.columnsTotalWidth = totalWidth;
    self.geometry.rowsTotalHeight = totalHeight;

}
-(NSArray<NSValue*>*)cellRectsEvenIn:(CGRect)rect{
    NSUInteger count = self.count;
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:count];

    CGSize oneSize = CGSizeMake(rect.size.width/_dimension.column, rect.size.height/_dimension.row);

    for (NSUInteger idx = 0; idx < count; idx++) {
        GCCellCoordinate coord = GCCellCoordinateFromIndex(idx, _dimension);
        CGRect cellRect = CGRectMake(rect.origin.x+oneSize.width*coord.column, rect.origin.y+oneSize.height*coord.row,
                                     oneSize.width, oneSize.height);
        [rv addObject:[NSValue valueWithCGRect:cellRect]];
    }
    return rv;
}
-(void)resetToEmpty{
    for (GCCellViewHolder * holder in self.viewHolders) {
        [holder resetToEmptyInView:self.parentView];
    }
}

-(void)setupFrames:(NSArray<NSValue*>*)cellRects inViewRect:(CGRect)viewRect{
    NSArray<NSValue*> * sizes = [self sizes];
    NSUInteger count = self.count;

    for (NSUInteger idx=0; idx<count; idx++) {
        GCCellViewHolder * holder = self.viewHolders[idx];

        CGRect cellRect = [cellRects[idx] CGRectValue];

        if (holder.config.columnSpan>1) {
            NSUInteger n = holder.config.columnSpan;
            GCCellCoordinate coord = GCCellCoordinateFromIndex(idx, _dimension);
            for (NSUInteger sc = 1; sc < n && coord.column < _dimension.column; sc++) {
                coord.column++;
                CGRect nextCell = [cellRects[GCCellIndexFromCoordinate(coord, _dimension)] CGRectValue];
                cellRect.size.width += nextCell.size.width;
            }
        }

        if (holder.config.rowSpan>1) {
            NSUInteger n = holder.config.rowSpan;
            GCCellCoordinate coord = GCCellCoordinateFromIndex(idx, _dimension);
            for (NSUInteger sc = 1; sc < n && coord.row < _dimension.row; sc++) {
                coord.row++;
                CGRect nextCell = [cellRects[GCCellIndexFromCoordinate(coord, _dimension)] CGRectValue];
                cellRect.size.height += nextCell.size.height;
            }
        }

        CGSize size = [sizes[idx] CGSizeValue];
        CGRect rect = [holder.config positionSize:size inCellRect:cellRect inViewRect:viewRect];

        if (holder.label && [holder.config shouldAdjustsFontSizeToFitWidth:rect inCellRect:cellRect]) {
            holder.label.adjustsFontSizeToFitWidth = YES;
            holder.label.minimumScaleFactor = 0.8;
            rect.size.width = cellRect.size.width;
        }

        [holder setFrame:rect];
    }
}


@end
