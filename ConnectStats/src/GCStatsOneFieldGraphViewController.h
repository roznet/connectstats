//  MIT Licence
//
//  Created on 05/02/2013.
//
//  Copyright (c) 2013 Brice Rosenzweig.
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
#import "GCViewConfig.h"
#import "GCHistoryFieldDataSerie.h"
#import "GCViewMaturityButton.h"

@interface GCStatsOneFieldGraphViewController : UIViewController<GCViewMaturityButtonDelegate>

@property (nonatomic,assign) gcViewChoice viewChoice;
@property (nonatomic,assign) gcGraphChoice graphChoice;
@property (nonatomic,retain) GCHistoryFieldDataSerie * activityStats;
@property (nonatomic,retain) GCSimpleGraphView * graphView;
@property (nonatomic,retain) GCSimpleGraphLegendView * legendView;
@property (nonatomic,retain) GCSimpleGraphCachedDataSource * dataSource;
@property (nonatomic,assign) BOOL canSum;
@property (nonatomic,retain) GCViewMaturityButton * maturityButton;
@property (nonatomic,retain) GCField * x_activityField;

-(void)setupForHistoryField:(GCHistoryFieldDataSerie*)serie graphChoice:(gcGraphChoice)gChoice andViewChoice:(gcViewChoice)vChoice;

@end
