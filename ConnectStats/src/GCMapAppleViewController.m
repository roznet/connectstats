//  MIT Licence
//
//  Created on 14/09/2013.
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

#import "GCMapAppleViewController.h"
#import "GCMapAnnotation.h"
#import "GCActivity.h"
#import "GCAppGlobal.h"
#import "GCMapRouteLogic.h"

typedef NS_ENUM(NSUInteger,gcMapViewType) {
    gcMapViewTypeStandard,
    gcMapViewTypeSatelliteFlyover,
    gcMapViewTypeHybrid,
    gcMapViewTypeEnd,
    // Disabled:
    gcMapViewTypeSatellite,
};

@interface GCMapAppleViewController ()
@property (nonatomic,assign) BOOL freezeMapAnnotations;
@end

@implementation GCMapAppleViewController
@dynamic activity,gradientField;

-(void)dealloc{
    [_routeLine release];
    [_routeLineView release];
    _mapView.delegate = nil;
    [_mapView release];
    [_gradientRoute release];
    [_gradientRouteView release];
    [_routeMultiLines release];
    [_routeMultiLinesViews release];
    [_compareGradientRoute release];
    [_compareGradientRouteView release];
    [_compareRouteLine release];
    [_compareRouteLineView release];
    [_tap release];

    [super dealloc];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(GCActivity*)activity{
    return [self.mapDataSource activity];
}
-(GCField*)gradientField{
    return [self.mapDataSource gradientField];
}

-(NSUInteger)numberOfColors{
    return (self.gradientColors).numberOfColors;
}

-(GCViewGradientColors*)gradientColors{
    return (self.gradientRoute).gradientColors;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupMapView];

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupMapView{
    CGRect maprect = self.view.frame;
    if ([UIViewController useIOS7Layout]) {
        maprect.origin.y=0.;
    }
    self.mapView = [[[MKMapView alloc] initWithFrame:maprect] autorelease];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    if ([self.mapDataSource enableTap]) {
        self.tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFound:)] autorelease];
        [self.mapView addGestureRecognizer:self.tap];
        self.tap.numberOfTapsRequired = 1;
        self.tap.numberOfTouchesRequired = 1;
        self.tap.delegate = self;
    }
}

-(void)tapFound:(UITapGestureRecognizer*)recognizer{
    CGPoint point = [recognizer locationInView:self.mapView];

    CLLocationCoordinate2D tapPoint = [self.mapView convertPoint:point toCoordinateFromView:self.view];
    [self.mapDataSource tapPoint:tapPoint];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognize{
    return YES;
}

-(void)clearAllOverlayAndAnnotations{
    NSArray * overlays = (self.mapView).overlays;
    if (overlays && [overlays isKindOfClass:[NSArray class]] && overlays.count>0) {
        [self.mapView removeOverlays:overlays];//CRASH
    }
    NSArray * annotations = (self.mapView).annotations;
    if (annotations && [annotations isKindOfClass:[NSArray class]] && annotations.count>0) {
        [self.mapView removeAnnotations:annotations];
    }
}

-(void)setupOverlayAndAnnotations{
    self.freezeMapAnnotations = true;

    if (self.gradientField || [self.mapDataSource compareActivity]) {
        [self loadRouteForGradient];
    }else{
        [self loadRoute];
    }
	// add the overlay to the map
    [self clearAllOverlayAndAnnotations];
    
	if (nil != self.routeLine) {
		[self.mapView addOverlay:self.routeLine];
	}
	if (nil != self.gradientRoute) {
        [self.mapView addOverlay:self.gradientRoute];
    }
    if (nil != self.routeMultiLines) {
        for (id<MKOverlay> ov in self.routeMultiLines) {
            [self.mapView addOverlay:ov];
        }
    }
    if (nil != self.compareGradientRoute) {
        [self.mapView addOverlay:self.compareGradientRoute];
    }

    if (nil != self.compareRouteLine) {
        [self.mapView addOverlay:self.compareRouteLine];
    }
    NSArray * annotations = [self.mapDataSource annotations];
    if (nil!=annotations) {
        [self.mapView addAnnotations:annotations];
    }
    self.freezeMapAnnotations = false;
	// zoom in on the route.
	//[self zoomInOnRoute];
}

-(void)zoomInOnRoute
{
    if (nil == self.routeLine && nil == self.gradientRoute) {
        [self.mapView setRegion:MKCoordinateRegionMakeWithDistance((self.activity).beginCoordinate, 10000., 10000.) animated:YES];
    }else{
        (self.mapView).visibleMapRect = self.routeRect;
    }
}
-(void)setupFrame:(CGRect)rect{
    self.view.frame = rect;
    self.mapView.frame = rect;
}


+(NSUInteger)numberOfMapType{
    return gcMapViewTypeEnd;
}

-(void)focusOnLocation:(CLLocation *)location{
    if (self.mapView.mapType == MKMapTypeSatelliteFlyover) {

        // Look from 10 seconds before and 20meter above
        CLLocation * eye = [location locationAtDistance:-1000. andBearing:location.course];
        MKMapCamera * camera = [MKMapCamera cameraLookingAtCenterCoordinate:location.coordinate
                                                          fromEyeCoordinate:eye.coordinate
                                                                eyeAltitude:location.altitude + 200.];
        //camera.pitch = 50;
        self.mapView.pitchEnabled = YES;
        self.mapView.showsBuildings = YES;
        self.mapView.showsUserLocation = NO;
        [self.mapView setCamera:camera animated:YES];

    }else{
        self.mapView.camera.pitch = 0.;
    }
}



-(void)toggleMapType:(NSUInteger)mapType{
    switch (mapType) {
        case gcMapViewTypeStandard:
            self.mapView.mapType = MKMapTypeStandard;
            break;
        case gcMapViewTypeSatelliteFlyover:
            self.mapView.mapType = MKMapTypeSatelliteFlyover;
            break;
        case gcMapViewTypeHybrid:
            self.mapView.mapType = MKMapTypeHybrid;
            break;
        case gcMapViewTypeSatellite:
            self.mapView.mapType = MKMapTypeSatellite;
            break;

        case gcMapViewTypeEnd:
            break;
    }
}

-(void)forceRedisplay{
    [self setRouteLineView:nil];
    [self setRouteMultiLinesViews:nil];
    [self setGradientRouteView:nil];
    [self setCompareGradientRouteView:nil];
    [self setCompareRouteLineView:nil];

    [self.mapView setNeedsDisplay];

}
#pragma mark - Setup Routes

-(void)clearAllRoutes{
    [self setRouteLine:nil];
    [self setRouteLineView:nil];
    [self setRouteMultiLines:nil];
    [self setRouteMultiLinesViews:nil];
    [self setGradientRoute:nil];
    [self setGradientRouteView:nil];
    [self setCompareGradientRoute:nil];
    [self setCompareGradientRouteView:nil];
    [self setCompareRouteLine:nil];
    [self setCompareRouteLineView:nil];
}

-(void)loadRouteForGradient{
    [self clearAllRoutes];

    self.gradientRoute = [[[GCMapGradientPathOverlay alloc] init] autorelease];

    GCActivity * progressComparedTo = [self.mapDataSource compareActivity];

    GCMapRouteLogic * logic = progressComparedTo ? [GCMapRouteLogic routeLogicFor:self.activity comparedTo:progressComparedTo andColors:self.gradientColors] : [GCMapRouteLogic routeLogicFor:self.activity field:self.gradientField andColors:self.gradientColors];
    logic.showLaps = [self.mapDataSource showLaps];
    logic.lapIndex = [self.mapDataSource lapIndex];

    [logic calculate];

    if ([logic countOfPoints] == 0 ) {
        self.routeLine= nil;
        self.gradientRoute=nil;

    }else{
        self.routeRect = logic.routeMapRect;

        (self.gradientRoute).points = logic.points;
        self.gradientRoute.boundingMapRect = self.routeRect;

        [self.mapDataSource setupLegendViewWithThresholds:logic.thresholds];
    }

    GCActivity * compareActivity = [[GCAppGlobal organizer] compareActivity];
    if (!progressComparedTo && compareActivity) {
        self.compareGradientRoute = [[[GCMapGradientPathOverlay alloc] init] autorelease];
        GCMapRouteLogic * compareLogic = [GCMapRouteLogic routeLogicFor:compareActivity field:self.gradientField andColors:[self.gradientColors gradientAsBackground]];
        compareLogic.showLaps = [self.mapDataSource showLaps];
        compareLogic.lapIndex = [self.mapDataSource lapIndex];

        [compareLogic calculate];

        self.routeRect = MKMapRectUnion(self.routeRect, compareLogic.routeMapRect);

        if ([compareLogic countOfPoints] == 0) {
            self.compareGradientRoute = nil;
        }else{
            (self.compareGradientRoute).points = compareLogic.points;
            self.compareGradientRoute.boundingMapRect = self.routeRect;
        }
    }
}

-(MKPolyline*)routeLineForPoints:(NSArray*)points withMulti:(NSMutableArray*)multi{
    MKPolyline * rv = nil;
    MKMapPoint* pointArr = malloc(sizeof(MKMapPoint) * points.count);
    size_t idx = 0;
    for (GCMapRouteLogicPointHolder * point in points){
        if (point.pathStart) {
            if (multi) {
                [multi addObject:[MKPolyline polylineWithPoints:pointArr count:idx]];
            }
            idx=0;
        }

        pointArr[idx++] = point.mapPoint;
    }
    if (idx>0) {
        // create the polyline based on the array of points.
        rv = [MKPolyline polylineWithPoints:pointArr count:idx];
    }
    free(pointArr);

    return rv;
}

// creates the route (MKPolyline) overlay
-(void)loadRoute{
    [self clearAllRoutes];
    GCMapRouteLogic * logic = [GCMapRouteLogic routeLogicFor:self.activity field:self.gradientField andColors:self.gradientColors];
    logic.showLaps = [self.mapDataSource showLaps];
    logic.lapIndex = [self.mapDataSource lapIndex];
    logic.lapsRectOnFullRoute = true; // no gradient keep zoom on full route.

    [logic calculate];

    if ([logic countOfPoints] == 0 ) {
        self.routeLine= nil;
        self.gradientRoute=nil;

    }else{
        self.routeMultiLines = [NSMutableArray arrayWithCapacity:5];
        self.routeLine = [self routeLineForPoints:logic.points withMulti:self.routeMultiLines];
        if (self.routeMultiLines.count==0) {
            self.routeMultiLines = nil;
        }
        self.routeRect = logic.routeMapRect;

        GCActivity * compareActivity = [[GCAppGlobal organizer] compareActivity];
        if (compareActivity) {
            GCMapRouteLogic * compareLogic = [GCMapRouteLogic routeLogicFor:compareActivity field:self.gradientField andColors:[self.gradientColors gradientAsBackground]];
            compareLogic.showLaps = [self.mapDataSource showLaps];
            compareLogic.lapIndex = [self.mapDataSource lapIndex];
            compareLogic.lapsRectOnFullRoute = true;

            [compareLogic calculate];

            self.routeRect = MKMapRectUnion(self.routeRect, compareLogic.routeMapRect);

            self.compareRouteLine = [self routeLineForPoints:compareLogic.points withMulti:nil];
        }

    }

}

#pragma mark MKMapViewDelegate
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(nonnull id<MKOverlay>)overlay
{
	MKOverlayRenderer* overlayView = nil;

	if(overlay == self.routeLine)
	{
		if(nil == self.routeLineView)
		{
			self.routeLineView = [[[MKPolylineRenderer alloc] initWithPolyline:self.routeLine] autorelease];
			self.routeLineView.fillColor = [UIColor redColor];
			self.routeLineView.strokeColor = [UIColor redColor];
			self.routeLineView.lineWidth = 3;
		}
		overlayView = self.routeLineView;
    }else if(overlay == self.compareRouteLine){
        if (nil == self.compareRouteLineView) {
			self.compareRouteLineView = [[[MKPolylineRenderer alloc] initWithPolyline:self.compareRouteLine] autorelease];
			self.compareRouteLineView.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
			self.compareRouteLineView.strokeColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
			self.compareRouteLineView.lineWidth = 3;
        }
		overlayView = self.compareRouteLineView;
	}else if(overlay == self.gradientRoute){
        self.gradientRouteView = [[[GCMapGradientPathOverlayView alloc] initWithOverlay:self.gradientRoute] autorelease];
        overlayView = self.gradientRouteView;
    }else if(overlay == self.compareGradientRoute){
        self.compareGradientRouteView = [[[GCMapGradientPathOverlayView alloc] initWithOverlay:self.compareGradientRoute] autorelease];
        overlayView = self.compareGradientRouteView;
    }else if(self.routeMultiLines){
        NSUInteger idx = 0;
        for (idx = 0; idx<self.routeMultiLines.count; idx++) {
            if (overlay == self.routeMultiLines[idx]) {
                break;
            }
        }
        if (idx < self.routeMultiLines.count) {
            if (!self.routeMultiLinesViews) {
                self.routeMultiLinesViews = [NSMutableArray arrayWithCapacity:self.routeMultiLines.count];
                for (MKPolyline * line in self.routeMultiLines) {
                    MKPolylineRenderer * lview = [[[MKPolylineRenderer alloc] initWithPolyline:line] autorelease];
                    lview.fillColor = [UIColor redColor];
                    lview.strokeColor = [UIColor redColor];
                    lview.lineWidth = 3;
                    [self.routeMultiLinesViews addObject:lview];
                }
            }
            overlayView = (self.routeMultiLinesViews)[idx];
        }
    }

    return overlayView ?: [[[MKOverlayRenderer alloc] init] autorelease];

}
-(MKAnnotationView*)mapView:(MKMapView *)amapView viewForAnnotation:(id<MKAnnotation>)annotation{
    MKAnnotationView* annotationView = nil;

    if (self.freezeMapAnnotations) {
        return nil;
    }

    if (annotation == amapView.userLocation) {
        if (annotation == self.mapView.userLocation)
        {
            // We can return nil to let the MapView handle the default annotation view (blue dot):
            // return nil;

            // Or instead, we can create our own blue dot and even configure it:

            annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:@"blueDot"];
            if (annotationView != nil)
            {
                annotationView.annotation = annotation;
            }
            else
            {
                annotationView = [[[NSClassFromString(@"MKUserLocationView") alloc] initWithAnnotation:annotation reuseIdentifier:@"blueDot"] autorelease];

                // Optionally configure the MKUserLocationView object here
                // Google MKUserLocationView for the options

            }
        }
    }else if([annotation isKindOfClass:[GCMapAnnotation class]]){
        GCMapAnnotation * an = (GCMapAnnotation*)annotation;
        if (an.type==gcMapAnnotationUser ) {
            annotationView = [[[NSClassFromString(@"MKUserLocationView") alloc] initWithAnnotation:annotation reuseIdentifier:@"blueDot"] autorelease];
        }else{
            MKPinAnnotationView *pinview=[[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinview"] autorelease];
            [pinview setCanShowCallout:YES];
            switch (an.type) {
                case gcMapAnnotationStart:
                    pinview.pinTintColor =   [MKPinAnnotationView greenPinColor];
                    break;
                case gcMapAnnotationEnd:
                    pinview.pinTintColor = [MKPinAnnotationView redPinColor];
                    break;

                default:
                    pinview.pinTintColor = [MKPinAnnotationView purplePinColor];

            }
            annotationView = pinview;
        }
    }
    return annotationView;
}
-(void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered{
    
    [self.mapDataSource finishedRendering:fullyRendered];
}

@end
