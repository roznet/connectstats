//  MIT Licence
//
//  Created on 22/02/2016.
//
//  Copyright (c) 2016 Brice Rosenzweig.
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

#import "GCStatsHistGraphViewController.h"
#import "GCStatsHistGraphOptionViewController.h"
@import RZExternal;
#import "GCViewIcons.h"

@interface GCStatsHistGraphViewController ()

@property (nonatomic,retain) GCSimpleGraphView * graphView;
@property (nonatomic,retain) GCSimpleGraphLegendView * legendView;
@property (nonatomic,retain) GCSimpleGraphGestures * gestures;
@property (nonatomic,retain) GCSimpleGraphGradientLegendView * gradientLegendView;
@property (nonatomic,retain) GCSimpleGraphRulerView * rulerView;

@property (nonatomic,retain) GCStatsHistGraphConfig * config;

@end

@implementation GCStatsHistGraphViewController

-(void)dealloc{
    [_config detach:self];
    [_config release];
    [_graphView release];
    [_legendView release];
    [_gradientLegendView release];
    [_rulerView release];
    [_gestures release];
    [_allFields release];

    [super dealloc];
}

-(ECSlidingViewController*)slidingViewControllerWithOptions{
    ECSlidingViewController * sliding = [[[ECSlidingViewController alloc] initWithNibName:nil bundle:nil] autorelease];

    GCStatsHistGraphOptionViewController * optionController = [[GCStatsHistGraphOptionViewController alloc] initWithStyle:UITableViewStyleGrouped];
    optionController.viewController = self;

    sliding.topViewController = self;
    sliding.underLeftViewController = [[[UINavigationController alloc] initWithRootViewController:optionController] autorelease];
    [optionController.navigationController setNavigationBarHidden:YES];

    [UIViewController setupEdgeExtendedLayout:sliding];
    [UIViewController setupEdgeExtendedLayout:self];
    [UIViewController setupEdgeExtendedLayout:sliding.underLeftViewController];

    [optionController release];

    return sliding;
}

-(void)viewDidLoad{
    [super viewDidLoad];

    // Custom initialization
    self.graphView = [[[GCSimpleGraphView alloc] initWithFrame:CGRectZero ] autorelease];
    self.legendView = [[[GCSimpleGraphLegendView alloc] initWithFrame:CGRectZero] autorelease];
    self.gradientLegendView = [[[GCSimpleGraphGradientLegendView alloc] initWithFrame:CGRectZero] autorelease];
    self.gestures = [[[GCSimpleGraphGestures alloc] init] autorelease];
    self.rulerView = [[[GCSimpleGraphRulerView alloc] initWithFrame:CGRectZero] autorelease];
    self.rulerView.graphView = self.graphView;

    [self.view addSubview:self.graphView];
    [self.view addSubview:self.legendView];
    [self.view addSubview:self.gradientLegendView];
    [self.view addSubview:self.rulerView];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self setupFrames];

    [self refreshDataSource];

    [self setupButtons];

}

-(void)setupButtons{
    UINavigationItem * item = self.slidingViewController ? self.slidingViewController.navigationItem : self.navigationItem;

    UIImage * img2= [GCViewIcons navigationIconFor:gcIconNavSliders];

    UIBarButtonItem * rightButton2 = [[UIBarButtonItem alloc] initWithImage:img2 style:UIBarButtonItemStylePlain target:self action:@selector(showOptions)];
    if (self.splitViewController) {
        item.rightBarButtonItems = @[rightButton2];
    }else{
        item.rightBarButtonItems = @[rightButton2];
    }

    [rightButton2 release];

}
-(void)showOptions{
    if ((self.slidingViewController).currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredRight) {
        [self.slidingViewController resetTopViewAnimated:YES];
    }else{
        [self.slidingViewController anchorTopViewToRightAnimated:YES];
    }
}

-(void)setupFrames{
    BOOL portrait = false;

    CGRect rect = self.view.frame;
    if ([UIViewController useIOS7Layout]) {
        rect.origin.y=0.;
    }

    self.graphView.frame = rect;
    CGRect drawRect = rect;

    if (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular) {// special case, squarish = portrait
        portrait = true;
    }

    if (portrait) {
        rect.origin.y = self.view.frame.size.height-55.;
        rect.origin.x = 5.;
        rect.size.height = 50.;
        rect.size.width = 250.;

        drawRect.size.height -= 50.;
        _graphView.drawRect = drawRect;

        CGAffineTransform transform = CGAffineTransformMakeRotation(0);
        self.legendView.transform = transform;

    }else{
        rect.origin.y = 5.;
        rect.origin.x = rect.size.width-55.;
        rect.size.height = 250.;
        rect.size.width = 50.;
        drawRect.size.width -= 50.;
        _graphView.drawRect = drawRect;

        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI/2);
        self.legendView.transform = transform;
    }

    self.legendView.frame = rect;
}

-(void)updateConfig:(GCStatsHistGraphConfig*)config{
    if (self.config != config) {
        [self.config detach:self];
        self.config = config;
        [self.config attach:self];
    }
    [self refreshDataSource];
}

-(void)refreshDataSource{
    if ([self.config build]) {
        [self updateDataSource];
    }
}

-(void)updateDataSource{
    self.graphView.dataSource = self.config.dataSource;
    self.graphView.displayConfig = self.config.dataSource;
    self.legendView.dataSource = self.config.dataSource;
    self.legendView.displayConfig = self.config.dataSource;
    [self.graphView setNeedsDisplay];
    [self.legendView setNeedsDisplay];
}

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    if (theParent == self.config) {
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self updateDataSource];
        });
    }
}
@end
