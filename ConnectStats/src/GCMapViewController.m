//  MIT Licence
//
//  Created on 18/09/2012.
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

@import RZExternal;
#import "GCMapViewController.h"
#import "GCTrackPoint.h"
#import "GCAppGlobal.h"
#import "GCMapAnnotation.h"
@import Flurry_iOS_SDK;
#import "GCViewConfig.h"
#import "GCActivity+CalculatedLaps.h"
#import "GCFields.h"
#import "GCViewIcons.h"
#import "GCMapAppleViewController.h"
#import "GCMapGoogleViewController.h"
#import "GCMapRouteLogic.h"

@interface GCMapViewController ()
// Use to get snapshot
@property (nonatomic,retain) UIWindow * tempWindow;
@property (nonatomic,retain) GCViewGradientColors * gradientColors;
@end

@implementation GCMapViewController
@dynamic implementorType;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.legendView = [[[GCMapLegendView alloc] initWithFrame:CGRectZero] autorelease];
        self.lapInfoView = [[[GCMapLapInfoView alloc] initWithFrame:CGRectZero] autorelease];
        self.windCompassView = [[[GCMapWindCompass alloc] initWithFrame:CGRectZero] autorelease];
        self.gradientColors = [GCViewGradientColors gradientColorsRainbow16];

    }
    return self;
}

- (void)dealloc
{
    if (_appleImplementor) {
        _appleImplementor.mapDataSource = nil;
        RZRelease(_appleImplementor);
    }
    if (_googleImplementor) {
        _googleImplementor.mapDataSource = nil;
        RZRelease(_googleImplementor);
    }
    [_activity release];
    [_annotations release];
    [[GCAppGlobal organizer] detach:self];
    [_legendView release];
    [_lapInfoView release];
    [_windCompassView release];
    [_gradientField release];
    
    [_tempWindow release];
    [_completionHandler release];

    [super dealloc];
}

#pragma mark - Implementor

-(void)toggleImplementor{
    if (self.implementor == self.appleImplementor) {
        self.implementorType = gcMapImplementorGoogle;
    }else{
        self.implementorType = gcMapImplementorApple;
    }
}

-(gcMapImplementor)implementorType{
    if (self.implementor == self.appleImplementor){
        return gcMapImplementorApple;
    }else if (self.implementor == self.googleImplementor){
        return gcMapImplementorGoogle;
    }
    return gcMapImplementorNone;
}

-(void)setImplementorType:(gcMapImplementor)implementorType{
    if (implementorType == gcMapImplementorApple && (self.implementor == nil || self.implementor != self.appleImplementor)) {
        if (self.appleImplementor == nil) {
            self.appleImplementor = [[[GCMapAppleViewController alloc] initWithNibName:nil bundle:nil] autorelease];
            self.appleImplementor.mapDataSource = self;
        }
        if ((self.implementor).view) {
            [(self.implementor).view removeFromSuperview];
        }

        self.implementor = self.appleImplementor;
        [self.view addSubview:(self.implementor).view];
        [self.implementor setupFrame:self.view.safeAreaLayoutGuide.layoutFrame];

    }else if (implementorType == gcMapImplementorGoogle && (self.implementor == nil || self.implementor != self.googleImplementor)){
        if (self.googleImplementor == nil) {
            self.googleImplementor = [[[GCMapGoogleViewController alloc] initWithNibName:nil bundle:nil] autorelease];
            self.googleImplementor.mapDataSource = self;
        }
        if ((self.implementor).view) {
            [(self.implementor).view removeFromSuperview];
        }

        self.implementor = self.googleImplementor;
        [self.view addSubview:(self.implementor).view];
        [self.implementor setupFrame:self.view.safeAreaLayoutGuide.layoutFrame];
    }
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self registerForTraitChanges:@[UITraitUserInterfaceStyle.class, UITraitHorizontalSizeClass.class, UITraitVerticalSizeClass.class] withAction:@selector(traitDidChange)];

    self.view.autoresizesSubviews = YES;
    
    [UIViewController setupEdgeExtendedLayout:self];
	// Do any additional setup after loading the view.
    //self.activity = [[GCAppGlobal organizer] currentActivity] ;
    [[GCAppGlobal organizer] attach:self];

    if (self.mapType == gcMapGoogle) {
        self.implementorType = gcMapImplementorGoogle;
    }else{
        self.implementorType = gcMapImplementorApple;
    }

    [self calculateLogicIfNecessary];
    [self setupOverlayAndAnnotations];
    [self updateInfoViews];

    [self.view addSubview:self.legendView];
    [self.view addSubview:self.lapInfoView];
    [self.view addSubview:self.windCompassView];
    self.windCompassView.backgroundColor = [UIColor clearColor];

    UINavigationItem * item = self.navigationItem;

    UIImage * img  = [GCViewIcons navigationIconFor:gcIconNavTags];
    UIImage * img2 = [GCViewIcons navigationIconFor:gcIconNavEye];

    if(self.showLaps==gcLapDisplaySingle){
        UIImage * img3 = [GCViewIcons navigationIconFor:gcIconNavForward];
        UIImage * img4 = [GCViewIcons navigationIconFor:gcIconNavBack];

        item.rightBarButtonItems = @[[[[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(toggleField:)] autorelease],

                                      [[[UIBarButtonItem alloc] initWithImage:img2 style:UIBarButtonItemStylePlain target:self action:@selector(toggleMapType:)] autorelease],

                                      [[[UIBarButtonItem alloc] initWithImage:img3 style:UIBarButtonItemStylePlain target:self action:@selector(nextLap:)] autorelease],

                                      [[[UIBarButtonItem alloc] initWithImage:img4 style:UIBarButtonItemStylePlain target:self action:@selector(previousLap:)] autorelease]];

    }else{
        UIImage * img3 = [GCViewIcons navigationIconFor:gcIconNavMarker];

        item.rightBarButtonItems = @[[[[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(toggleField:)] autorelease],

                                      [[[UIBarButtonItem alloc] initWithImage:img2 style:UIBarButtonItemStylePlain target:self action:@selector(toggleMapType:)] autorelease],

                                      [[[UIBarButtonItem alloc] initWithImage:img3 style:UIBarButtonItemStylePlain target:self action:@selector(toggleShowLap:)] autorelease],

                                      ];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setupFrames:self.view.safeAreaLayoutGuide.layoutFrame];
    [self zoomInOnRoute];
    
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    [self.googleImplementor didReceiveMemoryWarning];
    [self.appleImplementor didReceiveMemoryWarning];
}

-(void)traitDidChange{
    [self setupFrames:[self adjustedViewFrame]];
    [self forceRedisplay];
}

-(void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];

    if (newCollection.verticalSizeClass ==UIUserInterfaceSizeClassRegular) {
        self.tabBarController.tabBar.hidden = false;
        //self.navigationController.navigationBar.hidden = false;
    }else{
        self.tabBarController.tabBar.hidden = false;
        //self.navigationController.navigationBar.hidden = true;
    }
}

#pragma mark - frame and display setup

-(void)setupFrames:(CGRect)rect{
    self.view.frame = rect;
    [self.implementor setupFrame:rect];
    
    [self updatePanelFrames];
}

-(void)updatePanelFrames{
    
    if (self.disableInfoViews) {
        self.legendView.frame = CGRectZero;
        self.windCompassView.frame = CGRectZero;
        self.lapInfoView.frame = CGRectZero;
    }else{
        CGFloat infoWidth = self.view.frame.size.width > 320. ? 150. : 130.;
        CGFloat compassWidth = self.view.frame.size.width > 320. ? 50. : 40.;

        CGFloat nextX = 5.0;

        self.legendView.frame = CGRectMake(nextX, 5.f, infoWidth, 50.);
        nextX += infoWidth+5.0;

        if (self.showLaps == gcLapDisplayFastestDistanceUnit || (self.showLaps == gcLapDisplayPointInfo && self.gradientField != gcFieldFlagNone)) {
            self.lapInfoView.frame = CGRectMake(nextX, 5., infoWidth, 50.);
            nextX += infoWidth+5.0;
        }else{
            self.lapInfoView.frame = CGRectZero;
            self.lapInfoView.lap = nil;
        }

        if (self.windCompassView.enabled) {
            self.windCompassView.frame = CGRectMake(nextX, 5. + (50.-compassWidth)/2., // Center if < 50
                                                    compassWidth, compassWidth);
        }else{
            self.windCompassView.frame = CGRectZero;
        }
    }
}


-(CGRect)adjustedViewFrame{
    CGRect maprect = self.view.frame;
    return maprect;
}

#pragma mark - Configure Display and Interactions

-(void)tapPoint:(CLLocationCoordinate2D)coord{
    GCTrackPoint * target = [[[GCTrackPoint alloc] init] autorelease];
    target.longitudeDegrees = coord.longitude;
    target.latitudeDegrees  = coord.latitude;

    GCTrackPoint * min = nil;

    CLLocationDistance mindist = 0.;
    NSUInteger min_idx = 0;
    NSUInteger idx = 0;
    for (GCTrackPoint * point in self.activity.trackpoints) {
        if ([point validCoordinate]) {
            CLLocationDistance thisdist = [point distanceMetersFrom:target];
            if (min==nil||thisdist<mindist) {
                min = point;
                mindist = thisdist;
                min_idx = idx;
            }
        }
        idx++;
    }

    CLLocationSpeed speed = min.speed;//mps
    CLLocationDirection direction = 0;

    if (min_idx+1<self.activity.trackpoints.count) {
        GCTrackPoint * next = self.activity.trackpoints[min_idx+1];
        direction = [CLLocation getHeadingForDirectionFromCoordinate:min.coordinate2D toCoordinate:next.coordinate2D];
    }

    self.tappedPoint = min;
    self.showLaps = gcLapDisplayPointInfo;

    [self updatePanelFrames];
    [self refreshOverlayAndInfo];
    if ([self.implementor respondsToSelector:@selector(focusOnLocation:)]) {
        [self.implementor focusOnLocation:[[[CLLocation alloc] initWithCoordinate:min.coordinate2D
                                                                         altitude:min.altitude
                                                               horizontalAccuracy:1.
                                                                 verticalAccuracy:1.
                                                                           course:direction
                                                                            speed:speed
                                                                        timestamp:min.time] autorelease]];
    }
}

-(void)nextLap:(id)cb{
    if (self.lapIndex < self.activity.lapCount-1) {
        self.lapIndex++;
    }
    [self forceRedisplay];

}
-(void)previousLap:(id)cb{
    if (self.lapIndex > 0) {
        self.lapIndex--;
    }
    [self forceRedisplay];

}

-(void)toggleMapType:(id)cb{
    NSUInteger nApple = [GCMapAppleViewController numberOfMapType];
    NSUInteger nGoogle= [GCMapGoogleViewController numberOfMapType];
    self.currentMapType++;

    if (self.mapType == gcMapBoth) {
        if (self.currentMapType == nApple+nGoogle) {
            self.currentMapType = 0;
        }
        if (self.currentMapType < nApple) {
            self.implementorType = gcMapImplementorApple;
            [self.implementor toggleMapType:self.currentMapType];
        }else{
            self.implementorType = gcMapImplementorGoogle;
            [self.implementor toggleMapType:self.currentMapType-nApple];
        }
    }else if (self.mapType == gcMapApple){
        if (self.currentMapType == nApple) {
            self.currentMapType = 0;
        }
        if (self.currentMapType < nApple) {
            self.implementorType = gcMapImplementorApple;
            [self.implementor toggleMapType:self.currentMapType];
        }
    }else if (self.mapType == gcMapGoogle){
        if (self.currentMapType == nGoogle) {
            self.currentMapType = 0;
        }
        self.implementorType = gcMapImplementorGoogle;
        [self.implementor toggleMapType:self.currentMapType];
    }

    
    [self forceRedisplay];
}


-(void)toggleShowLap:(id)cb{
    if (self.showLaps == gcLapDisplaySingle) {
        return;
    }
    if (self.showLaps == gcLapDisplayMarkers) {
        self.showLaps = gcLapDisplayFastestDistanceUnit;
    }else if(self.showLaps == gcLapDisplayFastestDistanceUnit){
        self.showLaps = gcLapDisplayNone;
    }else{
        self.showLaps = gcLapDisplayMarkers;
    }
    [self updatePanelFrames];
    [self refreshOverlayAndInfo];
}

-(void)toggleField:(id)cb{
    self.gradientField = [self.activity nextAvailableTrackField:self.gradientField];
    [self forceRedisplay];
}



#pragma mark - Overlay and Annotations

-(void)forceRedisplay{
    [self calculateLogicIfNecessary];
    [self setupOverlayAndAnnotations];

    [self updateInfoViews];

    [self.implementor forceRedisplay];
    [self.implementor zoomInOnRoute];
}

-(void)refreshOverlayAndInfo{
    [self setupOverlayAndAnnotations];

    [self updateInfoViews];
}

-(void)setupOverlayAndAnnotations{
    [self loadAnnotations];
    [self.implementor setupOverlayAndAnnotations];
}

-(void)clearAllOverlayAndAnnotations{
    if( [self.implementor respondsToSelector:@selector(clearAllOverlayAndAnnotations)]){
        [self.implementor clearAllOverlayAndAnnotations];
    }
}

-(BOOL)hasGradient{
    return self.gradientField || self.compareActivity != nil;
}

-(void)calculateLogicIfNecessary{
    if( self.routeLogic == nil || !self.routeLogic.isCalculating){
        GCActivity * progressComparedTo = self.compareActivity;
        if( progressComparedTo){
            self.routeLogic = [GCMapRouteLogic routeLogicFor:self.activity comparedTo:progressComparedTo andColors:self.gradientColors];
        }else{
            self.routeLogic = [GCMapRouteLogic routeLogicFor:self.activity field:self.gradientField andColors:self.gradientColors];
        }
        self.routeLogic.showLaps = self.showLaps;
        self.routeLogic.lapIndex = self.lapIndex;

        [self.routeLogic calculate];
    }
}

-(void)zoomInOnRoute{
    [self.implementor zoomInOnRoute];
}

-(void)updateInfoViews{
    if (!self.disableInfoViews) {
        //FIX
        self.legendView.field = self.gradientField;
        [self.view bringSubviewToFront:self.legendView];
        [self.legendView setNeedsDisplay];


        self.windCompassView.enabled = false;
        if ([self.activity hasWeather] ) {
            GCWeather * weather = self.activity.weather;
            self.windCompassView.enabled = false;
            if (weather.windDirection && weather.windSpeed) {
                self.windCompassView.enabled = true;
                self.windCompassView.direction = (weather.windDirection).floatValue/180.*M_PI - M_PI/2.0;
                self.windCompassView.percent = MIN(1.0, [[weather.windSpeed convertToUnitName:@"kph"] value]/20.);
            }
        }

        [self.view bringSubviewToFront:self.lapInfoView];
        [self.lapInfoView setNeedsDisplay];
    }

}

-(void)loadAnnotations{
    NSArray * points = [self.activity trackpoints];
    if (points.count>0) {

        NSMutableArray * annot = [NSMutableArray arrayWithCapacity:self.showLaps==gcLapDisplayMarkers?[self.activity lapCount]+2:2];

        if (self.showLaps) {
            NSArray * laps = nil;
            if (self.showLaps == gcLapDisplayPointInfo) {
                if (self.tappedPoint) {
                    GCLap * point = [[[GCLap alloc] initWithTrackPoint:self.tappedPoint] autorelease];
                    laps = @[  point ];
                    (self.lapInfoView).lap = point;
                    (self.lapInfoView).activity = self.activity;
                    //FIX
                    (self.lapInfoView).gradientField = self.gradientField;
                }
            }else if (self.showLaps == gcLapDisplayFastestDistanceUnit) {
                GCUnit * storeUnit = [GCUnit unitForKey:STOREUNIT_DISTANCE];
                GCUnit * unit = self.activity.distanceDisplayUnit;
                double val = [storeUnit convertDouble:1. fromUnit:unit];
                laps = [self.activity calculatedRollingLapFor:val match:[self.activity matchDistanceBlockEqual] compare:[self.activity compareSpeedBlock]];
                if (laps && laps.count>0) {
                    for (GCLap * lap in laps) {
                        lap.label = NSLocalizedString(@"Fastest", @"Lap Callout");
                    }
                    (self.lapInfoView).lap = laps[1];
                    (self.lapInfoView).activity = self.activity;
                    (self.lapInfoView).gradientField = nil;
                }
            }else{
                laps =[self.activity laps];
            }

            BOOL start=false;

            for (GCLap * lap in laps) {
                if (self.showLaps == gcLapDisplayFastestDistanceUnit|| self.showLaps == gcLapDisplayPointInfo || start) {
                    [annot addObject:[GCMapAnnotation mapAnnotationWithCoord:lap.coordinate2D title:lap.displayLabel andType:gcMapAnnotationLap]];
                }
                start = true;
            }
        }

        NSUInteger i = 0;
        while (i<points.count) {
            GCTrackPoint * point =points[i++];
            if ([point validCoordinate]) {
                [annot addObject:[GCMapAnnotation mapAnnotationWithCoord:point.coordinate2D title:point.displayLabel andType:gcMapAnnotationStart]];
                break;
            }
        }
        if (i==points.count) {
            if ([self.activity validCoordinate]) {
                GCTrackPoint * fakepoint = [GCTrackPoint trackPointWithCoordinate2D:(self.activity).beginCoordinate];
                [annot addObject:[GCMapAnnotation mapAnnotationWithCoord:fakepoint.coordinate2D title:nil andType:gcMapAnnotationStart]];
            }
        }else{
            [annot addObject:[GCMapAnnotation mapAnnotationWithCoord:[points.lastObject coordinate2D] title:nil andType:gcMapAnnotationEnd]];
        }
        self.annotations = annot;

    }else{
        [self setAnnotations:nil];
    }
}

// create a GradientPath overlay

-(void)setupLegendViewWithThresholds:(NSArray*)thresholds{

    (self.legendView).activity = self.activity;
    //FIX
    self.legendView.field = self.gradientField;
    self.legendView.invertedColors = [self.activity displayUnitForField:self.gradientField].betterIsMin;
    (self.legendView).gradientColors = self.gradientColors;
    NSUInteger n = self.gradientColors.numberOfColors;
    if (n-1<thresholds.count) {
        self.legendView.min = [thresholds[1] doubleValue];
        self.legendView.mid = [thresholds[n/2] doubleValue];
        self.legendView.max = [thresholds[n-1] doubleValue];
    }
}


#pragma mark - others

-(void)finishedRendering:(BOOL)fullyRendered{
    if( self.completionHandler ){
        self.completionHandler();
    }
}
-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    dispatch_async( dispatch_get_main_queue(), ^(){
        [self forceRedisplay];
    });
}
-(UIImage*)exportImage{
    UIImage * img = [GCViewConfig imageWithView:self.view];
#if TARGET_IPHONE_SIMULATOR
    NSData * data = UIImagePNGRepresentation(img);
    NSString * imgname = [NSString stringWithFormat:@"%@-map.png",(self.activity).activityId];
    [data writeToFile:[RZFileOrganizer writeableFilePath:imgname] atomically:YES];
#endif
    return img;
}

-(void)mapImageForActivity:(GCActivity*)act size:(CGSize)size completion:(void(^)(UIImage*))handler{
    
    self.activity = act;
    self.view.frame = CGRectMake(0.0, 0.0, size.width, size.height);
    
    UIWindow *window = self.view.window;
    if (window == nil) {
        window = RZReturnAutorelease([[UIWindow alloc] initWithFrame:self.view.bounds]);
        [window addSubview:self.view];
        [window makeKeyAndVisible];
        self.tempWindow = window;
    }

    self.completionHandler = ^(){
        UIImage * img = [self mapInternal];
        handler(img);
    };
}

-(UIImage*)mapInternal{
    CGSize screenShotSize = self.view.bounds.size;
    UIGraphicsBeginImageContext(screenShotSize);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:ctx];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end
