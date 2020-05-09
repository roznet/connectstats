    //  MIT License
//
//  Created on 19/04/2020 for ConnectStats
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



#import "GCStatsMultiFieldConfigViewController.h"
#import "GCStatsMultiFieldConfig.h"
#import "GCDerivedGroupedSeries.h"
#import "GCDerivedOrganizer.h"
#import "GCSimpleGraphCachedDataSource+Templates.h"

@interface GCStatsMultiFieldConfigViewController ()
@property (nonatomic,retain) NSObject<GCStatsMultiFieldConfigViewDelegate> * delegate;
@end

@implementation GCStatsMultiFieldConfigViewController

-(void)dealloc{
    [_delegate release];
    [super dealloc];
}

+(GCStatsMultiFieldConfigViewController*)controllerWithDelegate:(NSObject<GCStatsMultiFieldConfigViewDelegate>*)delegate{
    GCStatsMultiFieldConfigViewController * rv = RZReturnAutorelease([[GCStatsMultiFieldConfigViewController alloc] initWithStyle:UITableViewStyleGrouped]);
    rv.delegate = delegate;
    rv.modalPresentationStyle = UIModalPresentationPopover;

    return rv;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if( section == 0){
        return 2;
    }else{
        return 2;
    }
}

-(GCDerivedDataSerie*)currentDerivedDataSerie{
    return [self.config currentDerivedDataSerie];
}
-(GCStatsMultiFieldConfig*)config{
    return self.delegate.config;
}

-(nonnull UITableViewCell *)tableView:(UITableView *)tableView derivedCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GCCellSimpleGraph * graphCell = [GCCellSimpleGraph graphCell:tableView];
    GCDerivedDataSerie * current = [self currentDerivedDataSerie];

    GCSimpleGraphCachedDataSource * cache = nil;
    if (current) {
        gcDerivedPeriod period = indexPath.row == 0 ? gcDerivedPeriodYear : gcDerivedPeriodMonth;
        
        cache = [GCSimpleGraphCachedDataSource derivedDataSingleHighlighted:self.config.activityType field:current.fieldFlag period:period on:current.bucketStart width:tableView.frame.size.width];
        cache.emptyGraphLabel = @"";
        graphCell.legend = true;
        [graphCell setDataSource:cache andConfig:cache];
    }else{
        cache = [GCSimpleGraphCachedDataSource dataSourceWithStandardColors];
        cache.emptyGraphLabel = @"";
        [graphCell setDataSource:cache andConfig:cache];
    }

    return graphCell;

}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell * cell = nil;
    
    if( indexPath.section == 0){
        GCCellGrid * grcell = [GCCellGrid gridCell:tableView];
        [grcell setupForRows:1 andCols:1];
        
        if( indexPath.row == 0){
            [grcell labelForRow:0 andCol:0].text = NSLocalizedString(@"Rebuild Derived", "Dummy");
        }else{
            [grcell labelForRow:0 andCol:0].text = NSLocalizedString(@"Done", "Dummy");
        }
        cell = grcell;
    }else if( indexPath.section == 1){
        if( indexPath.row == 0 || indexPath.row == 1){
            cell = [self tableView:tableView derivedCellForRowAtIndexPath:indexPath];
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.delegate configViewController:self didSelectRowAtIndexPath:indexPath];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if( indexPath.section == 0){
        return 58.;
    }else{
        return 200.;
    }
}
@end
