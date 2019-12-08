//  MIT Licence
//
//  Created on 11/02/2014.
//
//  Copyright (c) 2014 Brice Rosenzweig.
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

#import "GCActivityTennisDetailSource.h"
#import "GCCellGrid+Templates.h"
#import "GCTrackFieldChoices.h"
#import "GCTrackStats.h"
#import "GCSimpleGraphCachedDataSource+Templates.h"
#import "GCFormattedField.h"
#import "GCActivityTennisHeatmap.h"
#import "GCTableHeaderFieldsCategory.h"
#import "GCActivity+Fields.h"

#define GC_SECTION_TITLE    0
#define GC_SECTION_GRAPH    1
#define GC_SECTION_FIELDS   2
#define GC_SECTION_SHOTS    3
#define GC_SECTION_END      4

@implementation GCActivityTennisDetailSource

+(GCActivityTennisDetailSource*)tennisDetailSourceFor:(GCActivity*)activity{
    GCActivityTennisDetailSource * rv = nil;
    if ([activity isKindOfClass:[GCActivityTennis class]]) {
        rv = [[[GCActivityTennisDetailSource alloc] init] autorelease];
        if (rv) {
            rv.activity = (GCActivityTennis*) activity;
            rv.fields = @[ @[@"forehands", @"forehands_flat", @"forehands_lifted", @"forehands_sliced" ],
                           @[@"backhands", @"backhands_flat", @"backhands_lifted", @"backhands_sliced" ],
                           @[@"serves", @"serves_effect", @"serves_flat", @"first_serves"],
                           @[@"smash"],
                           @[@"heatmap_all_center", @"heatmap_all_up"],
                           @[@"heatmap_forehands_center", @"heatmap_forehands_up"],
                           @[@"heatmap_backhands_center", @"heatmap_backhands_up"],
                           @[@"heatmap_serves_center", @"heatmap_serves_up"]
                           ];
            rv.sections = @[ @"power", @[ @0, @1, @2, @3 ], @"precision", @[ @4, @5, @6, @7] ];
            rv.currentField = [NSMutableArray arrayWithArray: @[ @0, @0, @0, @0, @0, @0, @0, @0]];
        }
    }
    return rv;
}

-(void)dealloc{
    [_activity release];
    [_trackStats release];
    [_choices release];
    [_fields release];
    [_currentField release];
    [_sections release];
    [super dealloc];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return GC_SECTION_SHOTS + (self.sections.count/2);
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==GC_SECTION_FIELDS) {
        return 1;
    }else if (section >= GC_SECTION_SHOTS){
        return [self fieldsForSection:section].count;
    }
    return 1;
}

-(NSArray * )fieldsForSection:(NSInteger)section{
    NSUInteger idx = (section - GC_SECTION_SHOTS)*2 + 1;
    return( self.sections[ idx ] );
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.activity sessionDataReady];
    UITableViewCell * rv = nil;
    if (indexPath.section == GC_SECTION_TITLE) {
        GCCellGrid * cell = [GCCellGrid gridCell:tableView];
        [cell setupDetailHeader:self.activity];

        rv = cell;
    }else if (indexPath.section == GC_SECTION_FIELDS) {
        GCCellGrid * cell = [GCCellGrid gridCell:tableView];

        if (indexPath.row == 0) {
            GCNumberWithUnit * mainN = [self.activity numberWithUnitForFieldKey:@"SumDuration"];
            GCFormattedField * mainF = [GCFormattedField formattedField:[GCField fieldForKey:@"SumDuration" andActivityType:self.activity.activityType] forNumber:mainN forSize:16.];

            GCNumberWithUnit * secondN = [self.activity numberWithUnitForFieldKey:@"shots"];
            
            GCFormattedField * secondF = [GCFormattedField formattedField:[GCField fieldForKey:@"shots" andActivityType:self.activity.activityType] forNumber:secondN forSize:16.];

            secondF.noUnits = true;
            [cell setupForRows:2 andCols:2];
            [cell labelForRow:0 andCol:0].attributedText = [mainF attributedString];
            [cell labelForRow:1 andCol:0].attributedText = [secondF attributedString];

        }else{
            [cell setupForRows:2 andCols:2];
        }
        rv = cell;
    }else if (indexPath.section >= GC_SECTION_SHOTS){
        NSArray * fieldIndexes = [self fieldsForSection:indexPath.section];
        NSInteger idx = [fieldIndexes[indexPath.row] integerValue];

        GCCellGrid * cell = [GCCellGrid gridCell:tableView];

        NSUInteger curr = [(self.currentField)[idx] integerValue];
        NSArray * fieldschoices = (self.fields)[idx];
        NSString * field = fieldschoices[curr];
        if ([GCActivityTennisHeatmap isHeatmapField:field]) {
            [cell setupForTennisHeatmap:self.activity field:field];
        }else{
            [cell setupForTennisShotValue:self.activity shotValue:[self.activity valuesForShotType:field]];
        }
        rv = cell;

    }else if(indexPath.section == GC_SECTION_GRAPH){
        GCCellSimpleGraph * cell = [GCCellSimpleGraph graphCell:tableView];
        //cell.cellDelegate = self;
        GCTrackStats * s = [[GCTrackStats alloc] init];
        self.trackStats = s;
        if (!self.choices) {
            self.choices = [GCTrackFieldChoices trackFieldChoicesWithTennisActivity:self.activity];
        }
        s.activity = self.activity;
        [self.choices setupTrackStats:self.trackStats];
        GCSimpleGraphCachedDataSource * ds = [GCSimpleGraphCachedDataSource trackFieldFrom:s];
        [cell setDataSource:ds andConfig:ds];

        [s release];
        rv = cell;
    }
    return rv?:[GCCellGrid gridCell:tableView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    BOOL high = tableView.frame.size.height > 600.;

    if(indexPath.section==GC_SECTION_GRAPH){
        return high ? 200. : 150.;
    }
    return 58.;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==GC_SECTION_GRAPH) {
        [self.choices nextStyle];
        [tableView reloadData];

    }else if (indexPath.section>=GC_SECTION_SHOTS){
        NSArray * fieldIndexes = [self fieldsForSection:indexPath.section];
        NSInteger idx = [fieldIndexes[indexPath.row] integerValue];

        NSUInteger curr = [(self.currentField)[idx] integerValue];
        NSUInteger max = [(self.fields)[idx] count];
        curr++;
        if (curr>=max) {
            curr=0;
        }
        [self.currentField setObject:@(curr) atIndexedSubscript:idx];
        [tableView reloadData];
    }
    return;
}

-(NSString*)categoryNameForSection:(NSInteger)section{
    if (section >= GC_SECTION_SHOTS) {
        NSInteger idx = (section-GC_SECTION_SHOTS) *2;
        return (self.sections)[idx];
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSString * category = [self categoryNameForSection:section];
    UIView * rv = [GCTableHeaderFieldsCategory tableView:tableView viewForHeaderCategory:category];
    return rv;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    NSString * category = [self categoryNameForSection:section];
    CGFloat rv = [GCTableHeaderFieldsCategory tableView:tableView heightForHeaderCategory:category];
    return rv;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self categoryNameForSection:section];
}


@end
