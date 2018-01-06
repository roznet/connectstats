//  MIT Licence
//
//  Created on 03/10/2015.
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

#import "GCActivityPreviewingViewController.h"
#import "GCMapViewController.h"
#import "GCSimpleGraphCachedDataSource+Templates.h"
#import "GCTrackStats.h"
#import "GCTrackFieldChoices.h"

@interface GCActivityPreviewingViewController ()

@property (nonatomic,retain) GCMapViewController * mapController;
@property (nonatomic,retain) GCSimpleGraphView * graphView;
@property (nonatomic,retain) GCSimpleGraphView * graphViewAdditional;
@end

@implementation GCActivityPreviewingViewController

-(void)dealloc{
    [_activity release];
    [_graphView release];
    [_graphViewAdditional release];
    [_mapController release];

    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.


    GCTrackFieldChoices * choices =  [self.activity.activityType isEqualToString:GC_TYPE_DAY] ? [GCTrackFieldChoices trackFieldChoicesWithDayActivity:self.activity] :  [GCTrackFieldChoices trackFieldChoicesWithActivity:self.activity];

    BOOL hasMap = [self.activity validCoordinate];

    GCField * firstField = choices.current.field;
    [choices next];
    GCField * secondField = choices.current.field;

    self.graphView = [[[GCSimpleGraphView alloc] initWithFrame:CGRectZero] autorelease];
    GCTrackStats * trackStats = [[[GCTrackStats alloc] init] autorelease];
    trackStats.activity = self.activity;
    [trackStats setupForField:firstField xField:nil andLField:nil];
    GCSimpleGraphCachedDataSource * dataSource = [GCSimpleGraphCachedDataSource trackFieldFrom:trackStats];
    self.graphView.dataSource = dataSource;
    self.graphView.displayConfig = dataSource;

    if (hasMap) {
        self.mapController = [[[GCMapViewController alloc] initWithNibName:nil bundle:nil] autorelease];
        self.mapController.activity = self.activity;
        self.mapController.gradientField = firstField;
    }else if(![firstField isEqualToField:secondField]){
        self.graphViewAdditional = [[[GCSimpleGraphView alloc] initWithFrame:CGRectZero] autorelease];
        [trackStats setupForField:secondField xField:nil andLField:nil];
        dataSource = [GCSimpleGraphCachedDataSource trackFieldFrom:trackStats];
        self.graphViewAdditional.dataSource = dataSource;
        self.graphViewAdditional.displayConfig = dataSource;
    }

    if (self.mapController) {
        [self.view addSubview: self.mapController.view];
    }
    [self.view addSubview:self.graphView];
    if (self.graphViewAdditional) {
        [self.view addSubview:self.graphViewAdditional];
    }
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    CGRect rect = self.view.frame;
    CGRect top = rect;
    top.size.height = rect.size.height/2.0;
    CGRect bottom = top;
    bottom.origin.y += top.size.height;

    BOOL hasTop = false;

    if (self.mapController) {
        self.mapController.view.frame = rect;
        [self.mapController setupFrames:top];
        hasTop = true;
    }else if(self.graphViewAdditional){
        [self.graphViewAdditional setFrame:top];
        hasTop = true;
    }
    [self.graphView setFrame:hasTop ? bottom : rect];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
