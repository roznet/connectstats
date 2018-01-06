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

#import <Foundation/Foundation.h>
#import "GCCellGridConfig.h"

typedef struct {
    NSUInteger row;
    NSUInteger column;
} GCCellCoordinate;

NS_INLINE NSUInteger GCCellCountFromDimension( GCCellCoordinate dimension ){
    return dimension.column * dimension.row;
}
NS_INLINE NSUInteger GCCellIndexFromCoordinate( GCCellCoordinate coord, GCCellCoordinate dimension ){
    return coord.row*dimension.column+ coord.column;
}
NS_INLINE NSUInteger GCCellColumnFromIndex( NSUInteger index, GCCellCoordinate dimension){
    return index%dimension.column;
}
NS_INLINE NSUInteger GCCellRowFromIndex( NSUInteger index, GCCellCoordinate dimension){
    return index / dimension.column;
}
NS_INLINE GCCellCoordinate GCCellCoordinateMake( NSUInteger rows, NSUInteger columns ){
    GCCellCoordinate rv; rv.row = rows; rv.column = columns; return rv;
}
NS_INLINE GCCellCoordinate GCCellCoordinateFromIndex( NSUInteger index, GCCellCoordinate dimension){
    GCCellCoordinate rv; rv.row = index /dimension.column; rv.column = index%dimension.column; return rv;
}

@interface GCViewsGrid : NSObject

@property (nonatomic,readonly) NSUInteger rowsCount;
@property (nonatomic,readonly) NSUInteger columnsCount;

+(GCViewsGrid*)viewsGrid:(UIView*)parentView;
-(void)setDefaultMarginX:(CGFloat)mX andY:(CGFloat)mY;
-(UILabel*)labelForRow:(NSUInteger)row andColumn:(NSUInteger)col;
-(GCCellGridConfig*)configForRow:(NSUInteger)row andColumn:(NSUInteger)col;

-(void)setupForRows:(NSUInteger)rowsCount andColumns:(NSUInteger)columnsCount;
-(void)setupView:(UIView*)view forRow:(NSUInteger)row andColumn:(NSUInteger)col;

-(void)resetToEmpty;

-(NSArray<NSValue*>*)cellRectsEvenIn:(CGRect)rect;
-(void)setupFrames:(NSArray<NSValue*>*)cellRects inViewRect:(CGRect)viewRect;
-(NSArray<NSValue*>*)sizes;
-(NSArray<NSNumber*>*)columnsWidths;
-(NSArray<NSNumber*>*)rowsHeights;

@end
