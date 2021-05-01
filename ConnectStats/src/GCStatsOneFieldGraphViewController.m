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

#import "GCStatsOneFieldGraphViewController.h"
#import "GCSimpleGraphCachedDataSource+Templates.h"
#import "GCAppGlobal.h"
#import "GCHistoryFieldDataSerie.h"
#import "GCViewIcons.h"

@interface GCStatsOneFieldGraphViewController ()

@end

@implementation GCStatsOneFieldGraphViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIImage * img = [GCViewIcons navigationIconFor:gcIconNavGear];
        UIImage * img2= [GCViewIcons navigationIconFor:gcIconNavCalendar];

        // Custom initialization
        self.graphView = [[[GCSimpleGraphView alloc] initWithFrame:CGRectZero ] autorelease];
        self.legendView = [[[GCSimpleGraphLegendView alloc] initWithFrame:CGRectZero] autorelease];
        //[self setGestures:[[[GCSimpleGraphGestures alloc] init] autorelease]];
        UIBarButtonItem * gearButton = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(nextGraphStyle)];
        UIBarButtonItem * calendarButton = [[UIBarButtonItem alloc] initWithImage:img2 style:UIBarButtonItemStylePlain target:self action:@selector(nextCalendarUnit)];
        self.maturityButton = [GCViewMaturityButton maturityButtonForDelegate:self];
        self.maturityButton.useWorkerThread = true;
        self.navigationItem.rightBarButtonItems = @[self.maturityButton.fromButtonItem, gearButton, calendarButton];
        [gearButton release];
        [calendarButton release];
    }
    return self;
}

-(void)dealloc{
    [_activityStats release];
    [_graphView release];
    [_dataSource release];
    [_legendView release];
    [_maturityButton release];
    [_oneFieldConfig release];
    
    [super dealloc];
}

-(GCField*)x_activityField{
    return self.oneFieldConfig.x_field;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.graphView];
    [self.view addSubview:self.legendView];

	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [self setupFrames];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSCalendarUnit)calendarUnit{
    return self.oneFieldConfig.calendarConfig.calendarUnit;
}
-(void)nextCalendarUnit{
    [self.oneFieldConfig.calendarConfig nextCalendarUnit];
    dispatch_async([GCAppGlobal worker],^(){
        [self configureGraph];
    });
}
-(void)nextGraphStyle{
    /*
    size_t nchoices = 4;
    gcGraphChoice choices[4] = { gcGraphChoiceLine,gcGraphChoiceDistribution,gcGraphChoiceCumulative,gcGraphChoiceBarGraph };
     */
    size_t nchoices = 2;
    gcGraphChoice choices[2] = { gcGraphChoiceCumulative,gcGraphChoiceBarGraph };
    if (self.graphChoice == gcGraphChoiceCumulative && self.canSum && self.x_activityField == nil) {
        self.oneFieldConfig.x_field = [GCField fieldForFlag:gcFieldFlagSumDuration andActivityType:self.activityStats.activityField.activityType];
    }else{
        size_t i = 0;
        for (i = 0; i<nchoices; i++) {
            if (self.graphChoice == choices[i]) {
                break;
            }
        }
        i+=1;
        if (i>=nchoices) {
            i=0;
        }
        if (!self.canSum && i>1) {
            i=0;
        }
        self.graphChoice = choices[i];
        self.oneFieldConfig.x_field = nil;
    }
    dispatch_async([GCAppGlobal worker],^(){
        [self configureGraph];
    });
}

-(void)setupForHistoryField:(GCHistoryFieldDataSerie*)serie graphChoice:(gcGraphChoice)gChoice andConfig:(GCStatsOneFieldConfig *)vChoice{
    self.activityStats = [GCHistoryFieldDataSerie historyFieldDataSerieFrom:serie];
    self.oneFieldConfig=vChoice;
    self.graphChoice = gChoice;
    self.activityStats.config.fromDate = nil;
    dispatch_async([GCAppGlobal worker],^(){
        [self configureGraph];
    });
}

-(void)configureGraph{
    if (self.activityStats) {
        GCSimpleGraphCachedDataSource * ds = nil;
        
        self.activityStats.config.fromDate = [self.maturityButton currentFromDate];
        self.activityStats.config.x_activityField = self.oneFieldConfig.x_field;
        [self.activityStats loadFromOrganizer:[GCAppGlobal organizer]];
        ds = [GCSimpleGraphCachedDataSource historyView:self.activityStats
                                         calendarConfig:self.oneFieldConfig.calendarConfig
                                            graphChoice:self.graphChoice
                                                  after:nil];

        self.dataSource = ds;
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self display];
        });
    }
}

-(void)display{
    (self.graphView).dataSource = self.dataSource;
    (self.graphView).displayConfig = self.dataSource;
    (self.legendView).dataSource = self.dataSource;
    (self.legendView).displayConfig = self.dataSource;
    [self.graphView setNeedsDisplay];
    [self.legendView setNeedsDisplay];
}

-(void)setupFrames{
    BOOL portrait = false;
    /*
    UIInterfaceOrientation  orientation = self.interfaceOrientation;
    if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown) {
        portrait = true;
    }*/

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

-(void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    [self.graphView setNeedsDisplay];
    //[[self legendView] setNeedsDisplay];
    [self setupFrames];

}

@end
