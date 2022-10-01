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

#import "GCActivityTrackGraphViewController.h"
#import "GCViewConfig.h"
@import Flurry_iOS_SDK;
#import "GCAppGlobal.h"
#import "GCViewIcons.h"
#import "GCTrackFieldChoices.h"
#import "GCActivity+Series.h"
#import "GCActivityTrackGraphOptionsViewController.h"

@import RZExternal;

@interface GCActivityTrackGraphViewController ()
@property (nonatomic,retain) GCActivity * attachedActivity;
@property (nonatomic,retain) UIViewController * popoverViewController;
@property (nonatomic,retain) UIBarButtonItem * settingsButtonItem;
@end

@implementation GCActivityTrackGraphViewController

-(void)dealloc{
    [_attachedActivity detach:self];
    [_popoverViewController release];
    [_settingsButtonItem release];
    [_validOptions release];
    [_legendView release];
    [_otherTrackStats release];
    [_graphView release];
    [_dataSource release];
    [_attachedActivity release];
    [_trackStats release];

    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.graphView = [[[GCSimpleGraphView alloc] initWithFrame:(self.view).frame] autorelease];
    self.legendView = [[[GCMapLegendView alloc] initWithFrame:CGRectZero] autorelease];
    self.rulerView = [[[GCSimpleGraphRulerView alloc] initWithFrame:self.view.frame] autorelease];
    self.rulerView.graphView = self.graphView;
    [self.view addSubview:self.graphView];
    [self.view addSubview:self.legendView];
    [self.view addSubview:self.rulerView];
    self.gestures = [[[GCSimpleGraphGestures alloc] init] autorelease];
    [self setupDataSource];
}

#pragma mark - Functionality

-(GCActivity*)activity{
    return self.attachedActivity;
}
-(void)setActivity:(GCActivity *)activity{
    if (activity == self.attachedActivity) {
        return;
    }
    if (self.attachedActivity) {
        [self.attachedActivity detach:self];
    }
    self.attachedActivity = activity;
    [self.attachedActivity attach:self];
}

-(void)fullScreen{
    if (self.splitViewController) {
        GCActivityTrackGraphViewController * vc = [[[GCActivityTrackGraphViewController alloc] initWithNibName:nil bundle:nil] autorelease];
        vc.trackStats = self.trackStats;
        vc.activity = self.activity;
        vc.field = self.field;
        vc.showSplitScreenIcon = true;
        UINavigationController * nav= [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
        if ([UIViewController useIOS7Layout]) {
            [UIViewController setupEdgeExtendedLayout:vc];
        }
        [self.splitViewController presentViewController:nav animated:NO completion:nil];
    }else{
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

-(void)done{
    [self.popoverViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)showOptions{
    
    GCActivityTrackGraphOptionsViewController * optionController = RZReturnAutorelease([[GCActivityTrackGraphOptionsViewController alloc] initWithStyle:UITableViewStyleGrouped]);
    optionController.viewController = self;
    UINavigationController * nav = [[[UINavigationController alloc] initWithRootViewController:optionController] autorelease];
    //[optionController.navigationController setNavigationBarHidden:YES];
    
    optionController.navigationItem.rightBarButtonItem = RZReturnAutorelease([[UIBarButtonItem alloc]
                                                                  initWithTitle:NSLocalizedString(@"Done", @"Cell Entry Button")
                                                                  style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(done)]
                                                                 );

    nav.modalPresentationStyle = UIModalPresentationPopover;
    self.popoverViewController = nav;
    RZAutorelease([[UIPopoverPresentationController alloc] initWithPresentedViewController:nav
                                                                  presentingViewController:self.presentingViewController]);
    nav.popoverPresentationController.barButtonItem = self.settingsButtonItem;
    [self presentViewController:nav animated:YES completion:nil];

}

-(void)viewWillAppear:(BOOL)animated{

    UINavigationItem * item = self.navigationItem;

    UIImage * img = [GCViewIcons navigationIconFor:gcIconNavGear];
    UIImage * img2= [GCViewIcons navigationIconFor:gcIconNavSliders];
    UIImage * img3= [GCViewIcons navigationIconFor:gcIconNavRedo];

    UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(configureGraph)];
    UIBarButtonItem * rightButton2 = [[UIBarButtonItem alloc] initWithImage:img2 style:UIBarButtonItemStylePlain target:self action:@selector(showOptions)];
    UIBarButtonItem * rightButton3 = [[UIBarButtonItem alloc] initWithImage:img3 style:UIBarButtonItemStylePlain target:self action:@selector(flipAxis)];
    if (self.splitViewController) {
        item.rightBarButtonItems = @[rightButton,rightButton3,rightButton2];
    }else{
        item.rightBarButtonItems = @[rightButton,rightButton3,rightButton2];
    }
    self.settingsButtonItem = rightButton2;

    [rightButton release];
    [rightButton2 release];
    [rightButton3 release];

    
    [GCViewConfig setupViewController:self];
    [self setupFrames];
    [super viewWillAppear:animated];
}

-(void)setupFrames{
/*
    self.view.frame = self.navigationController.view.safeAreaLayoutGuide.layoutFrame;
    NSLog(@"%@", NSStringFromUIEdgeInsets(self.navigationController.view.safeAreaInsets));
    self.graphView.frame = self.view.frame;
    self.graphView.drawRect = self.view.frame;
    NSLog(@"%@", NSStringFromCGRect(self.view.frame));
    NSLog(@"%@", NSStringFromCGRect(self.graphView.frame));
 */
}

-(void)publishEvent{
}

-(void)setupDataSource{
    if (!self.validOptions) {
        [self buildOptions];
    }
    GCActivityTrackOptions * option = [self currentOption];
    self.trackStats.movingAverage = option.movingAverage;
    GCSimpleGraphCachedDataSource * ds = [GCSimpleGraphCachedDataSource trackFieldFrom:self.trackStats];

    if (option.o_field) {
        GCTrackStats * s = [[GCTrackStats alloc] init];
        s.activity = self.activity;
        [option setupTrackStatsForOther:s];
        self.otherTrackStats = s;
        [s release];
        UIColor * color = option.movingAverage > 0 ?  [GCViewConfig colorForGraphElement:gcSkinGraphColorRegressionLine]  : [GCViewConfig colorForGraphElement:gcSkinGraphColorRegressionLineSecondary] ;
        GCSimpleGraphDataHolder * plot = [GCSimpleGraphDataHolder dataHolder:[self.otherTrackStats dataSerie:0]
                                                                        type:gcGraphLine color:color
                                                                     andUnit:[self.otherTrackStats yUnit:0]];
        plot.fillColorForSerie = [GCViewConfig fillColorForField:option.o_field];
        [plot setupAsBackgroundGraph];
        plot.axisForSerie = 1;
        [ds addDataHolder:plot];
    }

    self.graphView.dataSource = ds;
    self.graphView.displayConfig = ds;
    self.dataSource = ds;
    [self.gestures setupForView:self.graphView andDataSource:ds];

}

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    [self refreshForCurrentOption];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    RZLog(RZLogWarning, @"memory warning %@", [RZMemory formatMemoryInUse]);

    // Dispose of any resources that can be recreated.
}

-(void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{

    [self setupFrames];
    [self.graphView setNeedsDisplay];
}

-(void)buildOptions{
    NSMutableArray * options = [NSMutableArray array];

    GCTrackFieldChoices * choices = [GCTrackFieldChoices trackFieldChoicesWithActivity:self.activity];
    NSArray * styles = [choices holdersForField:self.field];
    if (styles) {
        for (GCTrackFieldChoiceHolder*holder in styles) {
            [options addObject:[GCActivityTrackOptions optionForHolder:holder]];
        }
    }else{

        [options addObject:[GCActivityTrackOptions optionFor:self.field l:nil andMovingAverage:0]];

        if ([self.field isNoisy]) {
            [options addObject:[GCActivityTrackOptions optionFor:self.field l:nil andMovingAverage:30]];
            [options addObject:[GCActivityTrackOptions optionFor:self.field l:nil andMovingAverage:60]];
        }
        NSArray * fields = [self.activity availableTrackFields];
        for (GCField * xfield in fields) {
            if (![xfield isEqualToField:self.field]) {
                [options addObject:[GCActivityTrackOptions optionFor:self.field l:xfield andMovingAverage:0]];
            }
        }
    }
    self.validOptions = options;
}

-(void)refreshForCurrentOption{
    GCActivityTrackOptions * option = [self currentOption];
    [option setupTrackStats:self.trackStats];
    //[trackStats setupForField:option.field xField:option.x_field andLField:option.l_field];

    [self setupDataSource];

    if (option.l_field!=gcFieldFlagNone) {
        self.legendView.frame = CGRectMake(5., CGRectGetMaxY(self.view.frame)-60.,160., 50.);
        self.legendView.gradientColors = [self.dataSource gradientColors:0];
        self.legendView.activity = self.activity;
        self.legendView.field = option.l_field;
        GCStatsDataSerie * three = [[self.activity timeSerieForField:option.l_field].serie quantiles:16];

        if ([three count]>16) {
            (self.legendView).min = [three dataPointAtIndex:1].y_data;
            (self.legendView).mid = [three dataPointAtIndex:8].y_data;
            (self.legendView).max = [three dataPointAtIndex:15].y_data;
        }
        [self.legendView setNeedsDisplay];
    }else if(option.x_field!=nil){
        self.legendView.frame = CGRectMake(5., CGRectGetMaxY(self.view.frame)-60.,160., 50.);
        self.legendView.gradientColors = [self.dataSource gradientColors:0];
        self.legendView.activity = self.activity;
        self.legendView.field = [GCField fieldForFlag:gcFieldFlagSumDuration andActivityType:self.activity.activityType];
        GCNumberWithUnit * num = [self.activity numberWithUnitForField:self.legendView.field];
        self.legendView.min = 0.;
        self.legendView.mid = num.value/2;
        self.legendView.max = num.value;
        [self.legendView setNeedsDisplay];

    }else{
        self.legendView.frame = CGRectZero;
    }

    [self.graphView setNeedsDisplay];

    self.rulerView.showRuler = false;
    [self.rulerView setNeedsDisplay];
}

-(void)flipAxis{
    GCActivityTrackOptions * option = [self currentOption];

    if (option.o_field != gcFieldFlagNone) {
        option.x_field = option.o_field;
        option.o_field = nil;
        option.l_field = nil;
    }else if(option.x_field != gcFieldFlagNone){
        option.l_field = option.x_field;
        option.x_field = nil;
        option.o_field = nil;
    }else if(option.l_field != gcFieldFlagNone){
        option.o_field = option.l_field;
        option.x_field = nil;
        option.l_field = nil;
    }
    [self refreshForCurrentOption];

}

-(void)configureGraph{
    if (!self.validOptions || (self.validOptions).count == 0) {
        [self buildOptions];
        self.currentOptionIndex = 0;
    }else{
        self.currentOptionIndex++;
        if (self.currentOptionIndex >= (self.validOptions).count) {
            self.currentOptionIndex = 0;
        }
    }
    [self refreshForCurrentOption];
}

-(GCActivityTrackOptions*)currentOption{
    if (self.currentOptionIndex < (self.validOptions).count) {
        return (self.validOptions)[self.currentOptionIndex];
    }
    if ((self.validOptions).count) {
        return (self.validOptions)[0];
    }
    return nil;
}

@end
