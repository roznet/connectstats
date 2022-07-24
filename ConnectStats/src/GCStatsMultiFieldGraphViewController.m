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

#import "GCStatsMultiFieldGraphViewController.h"
#import "GCSimpleGraphCachedDataSource+Templates.h"
#import "GCViewConfig.h"
@import Flurry_iOS_SDK;
#import "GCAppConstants.h"
#import "GCViewIcons.h"
#import "GCHistoryFieldDataSerie.h"
#import "GCAppGlobal.h"
#import "GCFieldsForCategory.h"
@import RZExternal;

@interface GCStatsMultiFieldGraphViewController ()

@end

@implementation GCStatsMultiFieldGraphViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.graphView = [[[GCSimpleGraphView alloc] initWithFrame:CGRectZero ] autorelease];
        self.legendView = [[[GCSimpleGraphGradientLegendView alloc] initWithFrame:CGRectZero] autorelease];
        self.gestures = [[[GCSimpleGraphGestures alloc] init] autorelease];
        self.rulerView = [[[GCSimpleGraphRulerView alloc] initWithFrame:CGRectZero] autorelease];
        self.rulerView.graphView = self.graphView;

        ;
    }
    return self;
}
-(void)dealloc{
    [_cache release];
    [_scatterStats release];
    [_gestures release];
    [_legendView release];
    [_graphView release];
    [_rulerView release];
    [_maturityButton release];
    [_fieldOrder release];
    [_x_field release];
    
    [super dealloc];
}

-(void)publishEvent{
    GCField * x  = self.historyFieldConfig.x_activityField;
    GCField * f  = self.historyFieldConfig.activityField;

    NSDictionary * params= @{@"XField": x ?: @"None",
                            @"Field": f ?: @"None"};
    [Flurry logEvent:EVENT_GRAPH_HISTORY withParameters:params];
}

-(GCHistoryFieldDataSerieConfig *)historyFieldConfig{
    return self.scatterStats.config;
}
-(gcViewChoice)viewChoice{
    return gcViewChoiceFields;
}

-(void)showOptions{
    //FIXME: what to do?
    NSLog(@"SHOULD NOT BE CALLED???");
}

-(void)nextConfig{
    NSMutableArray<GCField*>*allFields = [NSMutableArray array];
    for( GCFieldsForCategory * fieldForCategory in self.fieldOrder){
        [allFields addObjectsFromArray:fieldForCategory.fields];
    }
    GCField * nextKey = [GCViewConfig nextFieldForGraph:self.historyFieldConfig.x_activityField
                         fieldOrder:[GCViewConfig validChoicesForGraphIn:allFields]
                      differentFrom:self.historyFieldConfig.activityField];

    self.x_field = nextKey;
    if (self.x_field ) {
        [self configureGraph];
#ifdef GC_USE_FLURRY
        [self publishEvent];
#endif
    }
}

-(void)configureGraph{
    if (self.x_field) {
        dispatch_async([GCAppGlobal worker], ^(){
            GCHistoryFieldDataSerieConfig * config = [GCHistoryFieldDataSerieConfig configWithField:self.historyFieldConfig.activityField xField:self.x_field  filter:false fromDate:[self.maturityButton currentFromDate]];
            [self.scatterStats setupAndLoadForConfig:config andOrganizer:[GCAppGlobal organizer]];
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self notifyCallBack:self.scatterStats info:nil];
            });
        });
    }
}

- (NSCalendarUnit)calendarUnit {
    return NSCalendarUnitYear;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.cache = [GCSimpleGraphCachedDataSource scatterPlotCacheFrom:self.scatterStats];
    
    self.graphView.dataSource = self.cache;
    self.graphView.displayConfig = self.cache;
    
    UINavigationItem * item = self.navigationItem;
    
    UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithImage:[GCViewIcons navigationIconFor:gcIconNavGear] style:UIBarButtonItemStylePlain target:self action:@selector(nextConfig)];
    UIBarButtonItem * slide = [[UIBarButtonItem alloc] initWithImage:[GCViewIcons navigationIconFor:gcIconNavSliders] style:UIBarButtonItemStylePlain target:self action:@selector(showOptions)];
    self.maturityButton = [GCViewMaturityButton maturityButtonForDelegate:self];
    item.rightBarButtonItems = @[rightButton,self.maturityButton.fromButtonItem,slide];
    
    [rightButton release];
    [slide release];
    
    self.legendView.gradientColors = [self.cache respondsToSelector:@selector(gradientColors:)] ? [self.cache gradientColors:0] : nil;
    
    if ([self.scatterStats.gradientSerie count]) {
        self.legendView.first = [[self.scatterStats.gradientSerie dataPointAtIndex:0] date];
        self.legendView.last  = [[self.scatterStats.gradientSerie dataPointAtIndex:[self.scatterStats.gradientSerie count]-1] date];
    }else{
        self.legendView.first = nil;
        self.legendView.last  = nil;
    }
    
    [self.view addSubview:self.graphView];
    [self.view addSubview:self.legendView];
    [self.view addSubview:self.rulerView];
    [self.gestures setupForView:self.graphView andDataSource:self.cache];
    
    //[self setupFrames];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [self setupFrames];
    
    [super viewWillAppear:animated];
}
// iphone 5
//2012-12-08 15:09:06.865 ConnectStats[23986:c07] frame: 0,20 548x320 portrait 1
//2012-12-08 15:09:12.851 ConnectStats[23986:c07] frame: 0,0 219x568 landscape 3
//2012-12-08 15:09:25.378 ConnectStats[23986:c07] frame: 0,0 219x568 landscape 4
//2012-12-08 15:09:30.362 ConnectStats[23986:c07] frame: 0,0 455x320 portrait 1

// ipad
//2012-12-09 08:51:14.660 ConnectStats[25390:c07] frame: 20,0 1024x748 landscape 4
//2012-12-09 08:51:18.915 ConnectStats[25390:c07] frame: 0,0 704x703 landscape 3
//2012-12-09 08:51:22.149 ConnectStats[25390:c07] frame: 0,0 704x703 landscape 4

// iphone 4
//2012-12-09 08:52:07.476 ConnectStats[25498:c07] frame: 0,20 460x320 portrait 1
//2012-12-09 08:52:09.960 ConnectStats[25498:c07] frame: 0,0 219x480 landscape 3
//2012-12-09 08:52:13.924 ConnectStats[25498:c07] frame: 0,0 219x480 landscape 4
//2012-12-09 08:52:15.940 ConnectStats[25498:c07] frame: 0,0 367x320 portrait 1


-(void)setupFrames{
    //UIInterfaceOrientation  orientation = self.interfaceOrientation;
    BOOL portrait = false;
    /*if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown) {
     portrait = true;
     }*/
    
    CGRect rect = self.view.frame;
    CGRect drawRect = rect;
    
    self.graphView.frame = rect;
    self.rulerView.frame = rect;
    
    if (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular) {// special case, squarish = portrait
        portrait = true;
    }
    
    if (portrait) {
        rect.origin.y = self.view.frame.size.height-55.;
        rect.origin.x = 5.;
        rect.size.height = 50.;
        rect.size.width = 150.;
        
        drawRect.origin.y = 0.;
        drawRect.size.height -= 50.;
        self.graphView.drawRect = drawRect;
        
        CGAffineTransform transform = CGAffineTransformMakeRotation(0);
        self.legendView.transform = transform;
        
    }else{
        rect.origin.y = 5.;
        rect.origin.x = rect.size.width-55.;
        rect.size.height = 150.;
        rect.size.width = 50.;
        drawRect.size.width -= 50.;
        self.graphView.drawRect = drawRect;
        
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI/2);
        self.legendView.transform = transform;
    }
    
    self.legendView.frame = rect;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    if ([self.scatterStats ready]) {
        self.cache = [GCSimpleGraphCachedDataSource scatterPlotCacheFrom:self.scatterStats];
        self.graphView.dataSource = self.cache;
        self.graphView.displayConfig = self.cache;
        [self.gestures setupForView:self.graphView andDataSource:self.cache];
        if ([self.scatterStats.gradientSerie count]) {
            self.legendView.first = [[self.scatterStats.gradientSerie dataPointAtIndex:0] date];
        }
        [self.legendView setNeedsDisplay];
        [self.graphView setNeedsDisplay];
    }
}

-(void)traitCollectionDidChange:(UITraitCollection*)previous{
    [super traitCollectionDidChange:previous];
    [self.graphView setNeedsDisplay];
    [self.legendView setNeedsDisplay];
    [self setupFrames];
}
@end
