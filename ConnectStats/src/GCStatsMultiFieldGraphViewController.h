//  MIT Licence
//
//  Created on 17/11/2012.
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
#import "GCViewMaturityButton.h"

@class GCSimpleGraphGestures;
@class GCHistoryFieldDataSerie;
@class GCSimpleGraphGradientLegendView;

@interface GCStatsMultiFieldGraphViewController : UIViewController<RZChildObject,GCViewMaturityButtonDelegate>{
    GCSimpleGraphCachedDataSource * cache;
    GCHistoryFieldDataSerie * scatterStats;
    GCSimpleGraphView * graphView;
    GCSimpleGraphGestures * gestures;
    GCSimpleGraphGradientLegendView * legendView;
}
@property (nonatomic,retain) GCSimpleGraphCachedDataSource * cache;
@property (nonatomic,retain) GCHistoryFieldDataSerie * scatterStats;
@property (nonatomic,retain) GCSimpleGraphView * graphView;
@property (nonatomic,retain) GCSimpleGraphGestures * gestures;
@property (nonatomic,retain) GCSimpleGraphGradientLegendView * legendView;
@property (nonatomic,retain) GCSimpleGraphRulerView * rulerView;
@property (nonatomic,retain) GCViewMaturityButton * maturityButton;
@property (nonatomic,retain) GCField * x_field;
@property (nonatomic,retain) NSArray * fieldOrder;

@end
