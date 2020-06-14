//  MIT Licence
//
//  Created on 04/10/2012.
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
#import "GCHistoryFieldSummaryStats.h"
#import "GCViewConfig.h"
#import "GCHistoryAggregatedActivityStats.h"
#import "GCHistoryFieldDataSerie.h"
#import "GCViewActivityTypeButton.h"
#import "GCStatsMultiFieldConfig.h"
#import "GCStatsDerivedAnalysisViewController.h"
#import "GCStatsDerivedHistAnalysis.h"
#import "GCStatsHistoryAnalysisViewController.h"

@class  GCFieldsForCategory;

@interface GCStatsMultiFieldViewController : UITableViewController<RZChildObject,GCViewActivityTypeButtonDelegate,GCCellSimpleGraphDelegate,GCStatsMultiFieldConfigViewDelegate,GCStatsHistoryAnalysisViewDelegate>

@property (nonatomic,retain) GCHistoryFieldSummaryStats * fieldStats;
@property (nonatomic,retain) GCHistoryAggregatedActivityStats * aggregatedStats;
@property (nonatomic,retain) NSArray<GCFieldsForCategory*> * fieldOrder;
@property (nonatomic,retain) NSArray<GCField*> * allFields;
@property (nonatomic,retain) NSDictionary<GCField*,GCHistoryFieldDataSerie*> * fieldDataSeries;
@property (nonatomic,retain) GCViewActivityTypeButton * activityTypeButton;
@property (nonatomic,retain) GCStatsMultiFieldConfig * config;
@property (nonatomic,retain) GCStatsDerivedHistAnalysis * derivedHistAnalysis;

-(void)setupForCurrentActivityType:(NSString*)aType filter:(BOOL)aFilter andViewChoice:(gcViewChoice)choice;
-(void)setupForCurrentActivityType:(NSString*)aType andViewChoice:(gcViewChoice)choice;
-(void)setupForCurrentActivityType:(NSString*)aType andFilter:(BOOL)aFilter;
-(void)setupForCurrentActivityAndViewChoice:(gcViewChoice)choice;
-(void)setupForFieldListConfig:(GCStatsMultiFieldConfig*)nConfig;

-(void)setupBarButtonItem;

-(void)setupTestModeWithFieldListConfig:(GCStatsMultiFieldConfig*)nConfig;


@end
