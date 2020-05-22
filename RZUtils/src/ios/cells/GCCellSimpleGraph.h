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

#import <UIKit/UIKit.h>
#import <RZUtilsUniversal/RZUtilsUniversal.h>

@class GCCellSimpleGraph;

@protocol GCCellSimpleGraphDelegate <NSObject>

-(void)swipeLeft:(GCCellSimpleGraph*)cell;
@optional
-(void)swipeRight:(GCCellSimpleGraph*)cell;
-(void)longPress:(GCCellSimpleGraph*)cell;
@end


@class GCSimpleGraphGestures;
@class GCSimpleGraphLegendView;

@interface GCCellSimpleGraph : UITableViewCell

@property (nonatomic,assign) NSObject<GCCellSimpleGraphDelegate> * cellDelegate;
@property (nonatomic,assign) BOOL legend;
@property (nonatomic,retain) GCSimpleGraphLegendView * legendView;
@property (nonatomic,assign) NSInteger identifier;

+(GCCellSimpleGraph*)graphCell:(UITableView*)tableView;
-(void)setDataSource:(id<GCSimpleGraphDataSource>)aSource andConfig:(id<GCSimpleGraphDisplayConfig>)aConfig;



@end
