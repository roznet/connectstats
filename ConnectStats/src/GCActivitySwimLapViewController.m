//  MIT Licence
//
//  Created on 21/12/2012.
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

#import "GCActivitySwimLapViewController.h"
#import "GCActivity.h"
#import "GCCellGrid+Templates.h"
#import "GCViewIcons.h"
#import "GCTrackPoint+Swim.h"

#define GCVIEW_SECTION_SUMMARY 0
#define GCVIEW_SECTION_GRAPH   1
#define GCVIEW_SECTION_LENGTHS 2
#define GCVIEW_SECTION_DETAILS 3
#define GCVIEW_SECTION_END     4


@interface GCActivitySwimLapViewController ()

@end

@implementation GCActivitySwimLapViewController
-(void)dealloc{
    [_lengthsCache release];
    [super dealloc];
}

-(void)viewDidLoad{
    [super viewDidLoad];

    (self.navigationItem).rightBarButtonItems = @[
                                                  [[[UIBarButtonItem alloc] initWithImage:[GCViewIcons navigationIconFor:gcIconNavEye] style:UIBarButtonItemStylePlain target:self action:@selector(changeStyle:)] autorelease],

                                                 [[[UIBarButtonItem alloc] initWithImage:[GCViewIcons navigationIconFor:gcIconNavForward] style:UIBarButtonItemStylePlain target:self action:@selector(nextLap:)] autorelease],

                                                 [[[UIBarButtonItem alloc] initWithImage:[GCViewIcons navigationIconFor:gcIconNavBack] style:UIBarButtonItemStylePlain target:self action:@selector(previousLap:)] autorelease]

                                                 ];

}

#pragma mark - Table view data source

-(void)changeStyle:(id)sender{
    self.lengthsCache = nil;
    self.lengthView = ! self.lengthView;
    [self.tableView reloadData];
}
-(void)nextLap:(id)cb{
    self.lengthsCache = nil;
    [super nextLap:cb];
}
-(void)previousLap:(id)cb{
    self.lengthsCache = nil;
    [super previousLap:cb];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return GCVIEW_SECTION_DETAILS+(self.setupFields).count;
}

-(NSArray*)lengths{
    if (!self.lengthsCache) {
        NSArray * all = [self.activity trackpoints];
        NSMutableArray * rv = nil;
        if (all) {
            rv = [NSMutableArray arrayWithCapacity:all.count];
            for (GCTrackPoint * point in all) {
                if (point.lapIndex==self.lapIndex) {
                    [rv addObject:point];
                }
            }
        }
        self.lengthsCache = rv;
    }
    return self.lengthsCache;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.lengthView) {
        return nil;
    }
    return [super tableView:tableView viewForHeaderInSection:section];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.lengthView) {
        return 0.;
    }
    return [super tableView:tableView heightForHeaderInSection:section];
}


-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (self.lengthView) {
        return nil;
    }
    return [super tableView:tableView titleForHeaderInSection:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.lengthView) {
        if (section==GCVIEW_SECTION_LENGTHS) {
            return [self lengths].count;
        }
    }else{
        if (section == GCVIEW_SECTION_SUMMARY) {
            return 1;
        }else if (section >= GCVIEW_SECTION_DETAILS){
            return [self fieldsForSection:section].count;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GCCellGrid *cell = [GCCellGrid gridCell:tableView];

    // Configure the cell...
    if (indexPath.section >= GCVIEW_SECTION_DETAILS) {

        NSArray<GCField*> * keys = [self fieldsForSection:indexPath.section];

        [cell setupForLap:[self.activity lapNumber:self.lapIndex] key:[keys[indexPath.row] key] andActivity:self.activity width:tableView.frame.size.width];
    }else if(indexPath.section == GCVIEW_SECTION_LENGTHS){
        GCTrackPoint * point = [self lengths][indexPath.row];
        [cell setupForSwimTrackpoint:point index:indexPath.row andActivity:self.activity width:tableView.frame.size.width];
    }else{
        [cell setupForLap:self.lapIndex andActivity:self.activity width:tableView.frame.size.width];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 52.;
}



@end
