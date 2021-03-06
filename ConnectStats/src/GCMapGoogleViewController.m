//  MIT Licence
//
//  Created on 24/02/2013.
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

#import "GCMapGoogleViewController.h"
#import "GCActivity.h"
#import "GCMapAnnotation.h"
#import "GCAppGlobal.h"
#import "GCMapRouteLogic.h"
@import GoogleMaps;

@interface GCMapGoogleViewController ()
@property (nonatomic,retain) GMSMapView * mapView;
@property (nonatomic,retain) GMSCoordinateBounds * bounds;

@end

@implementation GCMapGoogleViewController

#if !__has_feature(objc_arc)
-(void)dealloc{
    [_mapView release];
    [_bounds release];
    [super dealloc];
}
#endif

+(void)provideAPIKey:(NSString*)key{
    [GMSServices provideAPIKey:key];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    CLLocationCoordinate2D coord = [self.mapDataSource activity].beginCoordinate;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:coord zoom:6.];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    [self.view addSubview:self.mapView];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(GCActivity*)activity{
    return self.mapDataSource.activity;
}
+(NSUInteger)numberOfMapType{
    return 4U;
}
-(void)toggleMapType:(NSUInteger)mapType{

    switch (mapType) {
        case 0:
            self.mapView.mapType = kGMSTypeNormal;
            break;
        case 1:
            self.mapView.mapType = kGMSTypeSatellite;
            break;
        case 2:
            self.mapView.mapType = kGMSTypeHybrid;
            break;
        case 3:
            self.mapView.mapType = kGMSTypeTerrain;
            break;
        default:
            break;
    }
}
-(void)forceRedisplay{

}
-(void)setupFrame:(CGRect)frame{
    self.mapView.frame = frame;

}
-(void)setupOverlayAndAnnotations{
    /*
     GMSMutablePath *path = [GMSMutablePath path];
     [path addLatitude:-37.81319 longitude:144.96298];
     [path addLatitude:-31.95285 longitude:115.85734];
     GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
     polyline.strokeColor = [UIColor greenColor];
     polyline.strokeWidth = 10.f;
     polyline.geodesic = YES;
     polyline.map = mapView_;
     */

    GCMapRouteLogic * logic = self.mapDataSource.routeLogic;

    [self.mapView clear];
    GMSMutablePath * path = [GMSMutablePath path];
    UIColor * color = nil;
    for (GCMapRouteLogicPointHolder * point in logic.points) {
        [path addCoordinate:point.point];
        if (point.changeColor) {
            GMSPolyline * poly = [GMSPolyline polylineWithPath:path];
            poly.strokeColor = point.color;
            poly.strokeWidth = 7;
            poly.map = self.mapView;
            path = [GMSMutablePath path];
            [path addCoordinate:point.point];
        }
    }
    GMSPolyline * poly = [GMSPolyline polylineWithPath:path];
    if (color) {
        poly.strokeWidth = 7;
        poly.strokeColor = color;
    }
    poly.map = self.mapView;

    self.bounds = RZReturnAutorelease([[GMSCoordinateBounds alloc] initWithCoordinate:logic.southWestPoint coordinate:logic.northEastPoint]);
    [self zoomInOnRoute];
    [self.mapDataSource setupLegendViewWithThresholds:logic.thresholds];


    NSArray*annotations = self.mapDataSource.annotations;
    for (GCMapAnnotation * annotation in annotations) {
        color = nil;
        switch (annotation.type) {
            case gcMapAnnotationEnd:
                color = [UIColor redColor];
                break;
            case gcMapAnnotationStart:
                color = [UIColor greenColor];
                break;
            default:
                color = [UIColor purpleColor];
                break;
        }
        GMSMarker * marker = [GMSMarker markerWithPosition:annotation.coordinate];
        marker.icon = [GMSMarker markerImageWithColor:color];
        marker.map= self.mapView;
    }
}


-(void)zoomInOnRoute{
    if (self.bounds) {
        GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:self.bounds
                                                 withPadding:50.0f];
        [self.mapView animateWithCameraUpdate:update];
    }

}


@end
