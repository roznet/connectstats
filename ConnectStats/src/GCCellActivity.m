//  MIT Licence
//
//  Created on 28/08/2015.
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

#import "GCCellActivity.h"
#import "GCActivity.h"
#import "GCTrackStats.h"
#import "GCSimpleGraphCachedDataSource+Templates.h"
#import "GCTrackFieldChoiceHolder.h"
#import "GCViewConfig.h"
#import "GCAppGlobal.h"
#import "GCFormattedField.h"
#import "GCActivity+Fields.h"
#import "GCActivitiesOrganizer.h"
#import "GCHealthOrganizer.h"

const CGFloat kGCCellActivityDefaultHeight = 96;

@interface GCCellActivity ()
@property (nonatomic,retain) UITableView * tableView;
@property (nonatomic,retain) GCActivity * activity;

@property (nonatomic,retain) GCViewsGrid * viewsGrid;
@property (nonatomic,retain) UIView * gridContainerView;
@property (nonatomic,retain) GCSimpleGraphView * graphView;

@end

@implementation GCCellActivity

+(GCCellActivity*)activityCell:(UITableView*)tableView{
    GCCellActivity*cell=(GCCellActivity*)[tableView dequeueReusableCellWithIdentifier:@"GCActivity"];
    if (cell==nil) {
        cell=RZReturnAutorelease([[GCCellActivity alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GCActivity"]);
        cell.tableView = tableView;
        GCSimpleGraphView * graphView = RZReturnAutorelease([[GCSimpleGraphView alloc] initWithFrame:CGRectZero]);
        cell.graphView = graphView;
        [cell updateEmptyGraphSource];
        UIView * container = RZReturnAutorelease([[UIView alloc] initWithFrame:CGRectZero]);
        cell.gridContainerView = container;
        [cell.contentView addSubview:cell.gridContainerView];
        cell.gridContainerView.backgroundColor = [cell useBackgroundColor];
        cell.viewsGrid = [GCViewsGrid viewsGrid:container];
        [cell.viewsGrid setupForRows:4 andColumns:4];
        cell.backgroundColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1.00f];//[UIColor colorWithRed:1.f green:1.f blue:0.9f alpha:1.00f];
    }
    return cell;
}

-(void)dealloc{
    [self.activity detach:self];
    RZRelease(_graphView);
    RZRelease(_gridContainerView);
    RZRelease(_tableView);
    RZRelease(_activity);
    RZRelease(_viewsGrid);

    RZSuperDealloc;
}

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    if ([theInfo.stringInfo isEqualToString:kGCActivityNotifyTrackpointReady]) {
        if ([self.activity trackpointsReadyNoLoad]) {
            [self performSelectorOnMainThread:@selector(updateGraphSource) withObject:nil waitUntilDone:NO];
        }
    }
}

-(void)setupForActivity:(GCActivity*)activity{
    [self.activity detach:self];
    self.activity = activity;
    [self.activity attach:self];
}

-(void)updateEmptyGraphSource{
    GCSimpleGraphCachedDataSource * ds = [[[GCSimpleGraphCachedDataSource alloc] init] autorelease];

    ds.useBackgroundColor = [self useBackgroundColor];
    ds.axisColor = [UIColor clearColor];
    ds.maximizeGraph = true;
    ds.emptyGraphLabel = @"";
    self.graphView.dataSource = ds;
    self.graphView.displayConfig = ds;

}

-(void)updateGraphSource{
    GCTrackStats * trackStats = [[GCTrackStats alloc] init];
    trackStats.activity = self.activity;
    trackStats.bucketUnit = 60.*10.;

    GCTrackFieldChoiceHolder * holder = [GCTrackFieldChoiceHolder trackFieldChoice:[GCField fieldForFlag:gcFieldFlagSumStep
                                                                                         andActivityType:self.activity.activityType]
                                                                             style:gcTrackStatsBucket];
    GCSimpleGraphCachedDataSource * ds = nil;

    [holder setupTrackStats:trackStats];
    ds = [GCSimpleGraphCachedDataSource trackFieldFrom:trackStats];

    ds.useBackgroundColor = [self useBackgroundColor];
    ds.axisColor = [UIColor clearColor];
    ds.maximizeGraph = true;
    ds.emptyGraphLabel = @"";
    self.graphView.dataSource = ds;
    self.graphView.displayConfig = ds;

    [trackStats release];
    [self.graphView setNeedsDisplay];
}


-(void)triggerTrackpointLoad{
    [self.activity trackpoints];
}

-(void)setupGraphView:(CGRect)rect{
    [self.viewsGrid setupView:self.graphView forRow:2 andColumn:0];
    GCCellGridConfig * config = [self.viewsGrid configForRow:2 andColumn:0];
    config.columnSpan = 2;
    config.rowSpan = 2;

    if ([self.activity trackpointsReadyNoLoad]) {
        [self updateGraphSource];
    }else{
        [self.activity attach:self];
        dispatch_async([GCAppGlobal worker],^(){
            [self triggerTrackpointLoad];
        });

    }
    [self.graphView setNeedsDisplay];
}
-(void)setupAttributedStrings{
    NSMutableArray * leftStrings = [NSMutableArray arrayWithCapacity:5];
    NSMutableArray * rightStrings = [NSMutableArray arrayWithCapacity:5];

    if (self.activity) {
        GCActivity * activity = self.activity;
        GCFormattedField * distance = [GCFormattedField formattedField:nil activityType:nil
                                                             forNumber:[activity numberWithUnitForFieldFlag:gcFieldFlagSumDistance] forSize:16.];

        GCNumberWithUnit * nu_steps = [activity numberWithUnitForFieldKey:@"SumStep"];
        GCFormattedField * steps = [GCFormattedField formattedField:nil activityType:nil
                                                          forNumber:nu_steps forSize:14.];

        GCHealthMeasure * weight = [[GCAppGlobal health] measureOnSpecificDate:activity.date forType:gcMeasureWeight andCalendar:[GCAppGlobal calculationCalendar]];

        NSDictionary * dateAttributes = @{ NSFontAttributeName:[GCViewConfig boldSystemFontOfSize:16.],
                                           NSForegroundColorAttributeName:[UIColor blackColor]
                                           };

        NSDictionary * dateSmallAttributes = @{ NSFontAttributeName:[GCViewConfig systemFontOfSize:12.],
                                                NSForegroundColorAttributeName:[UIColor blackColor]
                                                };

        GCNumberWithUnit * maxHR = [activity numberWithUnitForFieldKey:@"MaxHeartRate"];
        GCNumberWithUnit * minHR = [activity numberWithUnitForFieldKey:@"MinHeartRate"];

        GCNumberWithUnit * nu_floors = [activity numberWithUnitForFieldKey:@"SumFloorClimbed"];
        NSDate * date = activity.date;
        NSAttributedString * day    = [[[NSAttributedString alloc] initWithString:[date dayFormat]       attributes:dateAttributes] autorelease];
        NSAttributedString * dat    = [[[NSAttributedString alloc] initWithString:[date dateShortFormat] attributes:dateSmallAttributes] autorelease];
        [leftStrings addObject:day];
        [leftStrings addObject:dat];

        [self.viewsGrid labelForRow:0 andColumn:1].attributedText = steps.attributedString;
        [self.viewsGrid labelForRow:0 andColumn:2].attributedText = distance.attributedString;

        if (weight) {
            [self.viewsGrid labelForRow:1 andColumn:2].attributedText = [[GCFormattedField formattedField:nil activityType:nil forNumber:weight.value forSize:12.] attributedString];
        }
        if( nu_floors){
            [rightStrings addObject:[GCViewConfig attributedString:nu_floors.formatDouble attribute:@selector(attribute14)]];
        }

        if (maxHR) {
            [rightStrings addObject:[GCViewConfig attributedString:maxHR.description attribute:@selector(attribute14Gray)]];
        }
        if( minHR){
            [rightStrings addObject:[GCViewConfig attributedString:minHR.description attribute:@selector(attribute14Gray)]];
        }
        for (NSUInteger row = 0; row < MIN(leftStrings.count, 2); row++) {
            [self.viewsGrid labelForRow:row andColumn:0].attributedText = leftStrings[row];
        }
        for (NSUInteger row = 0; row < MIN(rightStrings.count, 4); row++) {
            [self.viewsGrid labelForRow:row andColumn:3].attributedText = rightStrings[row];
        }

    }
}

-(void)updateLabels:(NSArray*)labels withStrings:(NSArray*)strings{
    for (NSUInteger i=0; i<labels.count; i++) {
        UILabel * label = labels[i];
        if (i<strings.count) {
            label.attributedText = strings[i];
        }else{
            label.attributedText = nil;
        }
    }
}

-(NSArray*)ensureLabelsArray:(NSArray*)input hasCount:(NSUInteger)count{
    NSArray * rv = input;
    if (input.count < count) {
        NSMutableArray * extended = [NSMutableArray arrayWithArray:input];
        for (NSUInteger i=input.count; i<count; i++) {
            UILabel * label = [[UILabel alloc] initWithFrame:CGRectZero];
            [extended addObject:label];
            [self.contentView addSubview:label];
            [label release];
        }
        rv = [NSArray arrayWithArray:extended];
    }
    return rv;
}

-(UIColor*)useBackgroundColor{
    // Ivory
    return [UIColor colorWithRed:1.f green:1.f blue:0.95f alpha:1.00f];
    //return [UIColor whiteColor];
    //return [UIColor colorWithRed:0.945f green:0.945f blue:0.945f alpha:1.00f];
}
-(void)layoutSubviews{
    [super layoutSubviews];

    [self.viewsGrid resetToEmpty];

    CGRect rect = self.contentView.frame;
    rect.origin.x += 5.;
    rect.size.width -= 10.;
    rect.size.height -= 5.;
    self.gridContainerView.frame = rect;
    rect.origin.x = 0;
    rect = CGRectInset(rect, 2., 1.);
    [self setupAttributedStrings];
    [self setupGraphView:rect];

    NSArray * sizes = [self.viewsGrid cellRectsEvenIn:rect];
    [self.viewsGrid setupFrames:sizes inViewRect:rect];
}

@end
