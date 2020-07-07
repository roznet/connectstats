//  MIT License
//
//  Created on 13/06/2020 for ConnectStats
//
//  Copyright (c) 2020 Brice Rosenzweig
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



#import "GCStatsDerivedHistoryViewController.h"
#import "GCStatsDerivedHistoryViewControllerConsts.h"
#import "GCStatsDerivedHistory.h"
#import "GCAppGlobal.h"
#import "GCStatsDerivedAnalysisConfig.h"

@interface GCStatsDerivedHistoryViewController ()
@property (nonatomic,retain) NSObject<GCStatsDerivedHistoryViewDelegate>*analysisDelegate;
@property (nonatomic,readonly) GCStatsMultiFieldConfig * config;
@property (nonatomic,readonly) GCStatsDerivedHistory * derivedHistAnalysis;
@end

@implementation GCStatsDerivedHistoryViewController

+(GCStatsDerivedHistoryViewController*)controllerWithDelegate:(NSObject<GCStatsDerivedHistoryViewDelegate> *)delegate{
    GCStatsDerivedHistoryViewController * rv = RZReturnAutorelease([[GCStatsDerivedHistoryViewController alloc] initWithStyle:UITableViewStyleGrouped]);
    if( rv ){
        rv.analysisDelegate = delegate;
    }
    return rv;
}

-(void)dealloc{
    [_analysisDelegate release];
    
    [super dealloc];
}

-(GCStatsMultiFieldConfig*)multiFieldConfig{
    return self.analysisDelegate.multiFieldConfig;
}
-(GCStatsDerivedHistory*) derivedHistAnalysis{
    return self.analysisDelegate.derivedHistAnalysis;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return GC_SECTION_END;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if( section == GC_SECTION_GRAPHS){
        return 1;
    }else if (section == GC_SECTION_OPTIONS){
        return GC_OPTIONS_END;
    }else if (section == GC_SECTION_PERIODS){
        return GC_PERIODS_END;
    }else if (section == GC_SECTION_XS){
        return GC_XS_END;
    }
    return 0;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if( indexPath.section==GC_SECTION_GRAPHS){
        GCCellSimpleGraph * graphCell = [self.derivedHistAnalysis tableView:tableView derivedHistCellForRowAtIndexPath:indexPath with:[GCAppGlobal derived]];
        cell = graphCell;
    }else if (indexPath.section == GC_SECTION_OPTIONS){
        GCCellGrid * gridCell = [GCCellGrid gridCell:tableView];
        [gridCell setupForRows:1 andCols:2];
        if (indexPath.row == GC_OPTIONS_FIELD){
            [gridCell labelForRow:0 andCol:0].text = NSLocalizedString(@"Field", @"Derived Hist Analysis Options");
            GCField * current = self.derivedHistAnalysis.field;
            [gridCell labelForRow:0 andCol:1].text = current.displayName;
            //[gridCell labelForRow:0 andCol:1].text = self
        }else if (indexPath.row == GC_OPTIONS_METHOD){
            [gridCell labelForRow:0 andCol:0].text = NSLocalizedString(@"Method", @"Derived Hist Analysis Options");
            [gridCell labelForRow:0 andCol:1].text = self.derivedHistAnalysis.method;
        }
        cell = gridCell;
    }else if (indexPath.section == GC_SECTION_PERIODS){
        GCCellGrid * gridCell = [GCCellGrid gridCell:tableView];
        [gridCell setupForRows:2 andCols:2];
        if( indexPath.row == GC_PERIODS_LAG){
            [gridCell labelForRow:0 andCol:0].text = NSLocalizedString(@"Period", @"Derived Hist Analysis Options");
            [gridCell labelForRow:0 andCol:1].text = self.derivedHistAnalysis.lookbackPeriod.displayName;
        }else if (indexPath.row == GC_PERIODS_LTPERIOD){
            [gridCell labelForRow:0 andCol:0].text = NSLocalizedString(@"Long Term",@"Derived Hist Analysis Options");
            [gridCell labelForRow:0 andCol:1].text = self.derivedHistAnalysis.longTermPeriod.displayName;
            if( self.derivedHistAnalysis.longTermSmoothing == gcDerivedHistSmoothingMax ){
                [gridCell labelForRow:1 andCol:0].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute14Gray] withFormat:NSLocalizedString( @"Max", @"Derived Hist Method")];
            }else{
                [gridCell labelForRow:1 andCol:0].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute14Gray] withFormat:NSLocalizedString( @"Trend", @"Derived Hist Method")];
            }

        }else if (indexPath.row == GC_PERIODS_STPERIOD){
            [gridCell labelForRow:0 andCol:0].text = NSLocalizedString(@"Short Term",@"Derived Hist Analysis Options");
            [gridCell labelForRow:0 andCol:1].text = self.derivedHistAnalysis.shortTermPeriod.displayName;
            if( self.derivedHistAnalysis.shortTermSmoothing == gcDerivedHistSmoothingMax ){
                [gridCell labelForRow:1 andCol:0].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute14Gray] withFormat:NSLocalizedString( @"Max", @"Derived Hist Method")];
            }else{
                [gridCell labelForRow:1 andCol:0].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute14Gray] withFormat:NSLocalizedString( @"Trend", @"Derived Hist Method")];
            }

        }
        cell = gridCell;
    }else if (indexPath.section == GC_SECTION_XS){
        GCCellGrid * gridCell = [GCCellGrid gridCell:tableView];
        [gridCell setupForRows:2 andCols:2];
        NSArray<GCNumberWithUnit*>*points = self.derivedHistAnalysis.pointsForGraphs;
        if( indexPath.row == GC_XS_SHORT){
            [gridCell labelForRow:0 andCol:0].text = NSLocalizedString(@"Short Period for CP", @"x unit for CP");
            [gridCell labelForRow:0 andCol:1].text = [points[1] description];
        }else if( indexPath.row == GC_XS_LONG){
            [gridCell labelForRow:0 andCol:0].text = NSLocalizedString(@"Long Period for CP", @"x unit for CP");
            [gridCell labelForRow:0 andCol:1].text = [points[2] description];
        }
        cell = gridCell;
    }
    return cell ?: [GCCellGrid gridCell:tableView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if( indexPath.section == GC_SECTION_GRAPHS){
        return 200.;
    }else{
        return 58.;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if( indexPath.section == GC_SECTION_PERIODS){
        NSArray<NSString*> * labels = [[GCLagPeriod validPeriods] arrayByMappingBlock:^(GCLagPeriod*period){
            return period.displayName;
        }];
        GCLagPeriod * current = nil;
        if( indexPath.row == GC_PERIODS_STPERIOD ){
            current = self.derivedHistAnalysis.shortTermPeriod;
        }else if (indexPath.row == GC_PERIODS_LTPERIOD){
            current = self.derivedHistAnalysis.longTermPeriod;
        }else if( indexPath.row == GC_PERIODS_LAG){
            current = self.derivedHistAnalysis.lookbackPeriod;
        }
        NSUInteger selected = [labels indexOfObject:current.displayName];
        
        GCCellEntryListViewController * list = [GCViewConfig standardEntryListViewController:labels
                                                                                    selected:selected];
        list.entryFieldCompletion = ^(NSObject<GCEntryFieldProtocol>*cb){
            GCLagPeriod * choice = [GCLagPeriod validPeriods][cb.selected];
            if( indexPath.row == GC_PERIODS_STPERIOD ){
                self.derivedHistAnalysis.shortTermPeriod = choice;
            }else if (indexPath.row == GC_PERIODS_LTPERIOD){
                self.derivedHistAnalysis.longTermPeriod = choice;
            }else if( indexPath.row == GC_PERIODS_LAG){
                self.derivedHistAnalysis.lookbackPeriod = choice;
            }
            [self.tableView reloadData];
            [self.analysisDelegate configChanged];
        };
        [self.navigationController pushViewController:list animated:YES];
    }else if (indexPath.section == GC_SECTION_OPTIONS){
        if( indexPath.row == GC_OPTIONS_METHOD ){
            NSArray<NSString*>*labels = self.derivedHistAnalysis.methods;
            NSUInteger selected = [labels indexOfObject:self.derivedHistAnalysis.method];
            GCCellEntryListViewController * list = [GCViewConfig standardEntryListViewController:labels
                                                                                        selected:selected];
            list.entryFieldCompletion = ^(NSObject<GCEntryFieldProtocol>*cb){
                self.derivedHistAnalysis.method = self.derivedHistAnalysis.methods[cb.selected];
                [self.tableView reloadData];
                [self.analysisDelegate configChanged];
            };
            [self.navigationController pushViewController:list animated:YES];
        }else if( indexPath.row == GC_OPTIONS_FIELD){
            
            GCStatsDerivedAnalysisConfig * derivedAnalysisConfig = self.derivedHistAnalysis.derivedAnalysisConfig;
            NSArray<GCDerivedGroupedSeries*>*series = derivedAnalysisConfig.availableDataSeries;
            NSMutableArray<GCDerivedDataSerie*> * choices = [NSMutableArray array];
            NSMutableArray<NSString*>* labels = [NSMutableArray array];
            NSUInteger selected = 0;

            GCDerivedDataSerie * current = derivedAnalysisConfig.currentDerivedDataSerie;
            GCField * field = current.field;
            NSDate * date = current.bucketStart;
            NSUInteger idx = 0;
            for (GCDerivedGroupedSeries * group in series) {
                [labels addObject:group.field.displayName];
                if( [group.field isEqualToField:field]){
                    selected = idx;
                }
                idx++;
                GCDerivedDataSerie * found = nil;
                for (GCDerivedDataSerie * one in group.series) {
                    if( [one.bucketStart compare:date] != NSOrderedDescending){
                        found = one;
                        break;
                    }
                }
                
                [choices addObject:found ?: group.series.firstObject];
            }
            GCCellEntryListViewController * list = [GCViewConfig standardEntryListViewController:labels
                                                                                        selected:selected];
            
            list.entryFieldCompletion = ^(NSObject<GCEntryFieldProtocol>*cb){
                derivedAnalysisConfig.currentDerivedDataSerie = choices[cb.selected];
                [tableView reloadData];
                [self.analysisDelegate configChanged];
            };
            [self.navigationController pushViewController:list animated:YES];
        }
    }else if( indexPath.section == GC_SECTION_XS){
        GCStatsSerieOfSerieWithUnits * serieOfSeries = [self.derivedHistAnalysis serieOfSeries:[GCAppGlobal derived]];
        NSArray<GCNumberWithUnit*>* Xs = [serieOfSeries allXs];
        NSArray<NSString*>* xsLabels = [Xs arrayByMappingBlock:^(GCNumberWithUnit*nu){
            return [nu formatDouble];
        }];

        GCCellEntryFieldCompletion cb = nil;
        NSUInteger current = 0;

        NSArray<GCNumberWithUnit*>*points = self.derivedHistAnalysis.pointsForGraphs;
        if( indexPath.row == GC_XS_SHORT){
            
            GCNumberWithUnit * sx = points[1];
            for (GCNumberWithUnit * nu in Xs) {
                if( [nu isEqualToNumberWithUnit:sx] ){
                    break;
                }
                current++;
            }
            cb = ^(NSObject<GCEntryFieldProtocol>*cb){
                self.derivedHistAnalysis.shortTermX = Xs[cb.selected];
                [tableView reloadData];
                [self.analysisDelegate configChanged];
            };
        }else if (indexPath.row == GC_XS_LONG){
            GCNumberWithUnit * lx = points[2];
            for (GCNumberWithUnit * nu in Xs) {
                if( [nu isEqualToNumberWithUnit:lx] ){
                    break;
                }
                current++;
            }
            cb = ^(NSObject<GCEntryFieldProtocol>*cb){
                self.derivedHistAnalysis.longTermX = Xs[cb.selected];
                [tableView reloadData];
                [self.analysisDelegate configChanged];
            };
        }
        GCCellEntryListViewController * list = [GCViewConfig standardEntryListViewController:xsLabels selected:current];
        list.entryFieldCompletion = cb;
        [self.navigationController pushViewController:list animated:YES];

    }
}
@end
