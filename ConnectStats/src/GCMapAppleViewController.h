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

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "GCMapGradientPathOverlayView.h"
#import "GCActivity.h"
#import "GCMapImplementorProtocol.h"
#import "GCMapGradientPathOverlay.h"

@interface GCMapAppleViewController : UIViewController<MKMapViewDelegate,GCMapImplementorProtocol,UIGestureRecognizerDelegate>
@property (nonatomic,retain) MKMapView * mapView;
@property (nonatomic,retain) MKPolyline * routeLine;
@property (nonatomic,retain) MKPolylineRenderer * routeLineView;
@property (nonatomic,assign) MKMapRect routeRect;
@property (nonatomic,retain) GCMapGradientPathOverlayView * gradientRouteView;
@property (nonatomic,retain) GCMapGradientPathOverlay * gradientRoute;
@property (nonatomic,retain) NSMutableArray * routeMultiLines;
@property (nonatomic,retain) NSMutableArray * routeMultiLinesViews;

@property (nonatomic,readonly) GCActivity*activity;
@property (nonatomic,readonly) GCField * gradientField;

@property (nonatomic,assign) NSObject<GCMapDataSourceProtocol> * mapDataSource;

@property (nonatomic,retain) GCMapGradientPathOverlayView * compareGradientRouteView;
@property (nonatomic,retain) GCMapGradientPathOverlay * compareGradientRoute;

@property (nonatomic,retain) MKPolyline * compareRouteLine;
@property (nonatomic,retain) MKPolylineRenderer * compareRouteLineView;
@property (nonatomic,retain) UITapGestureRecognizer * tap;
@property (nonatomic,assign) CLLocationCoordinate2D tapPoint;

+(NSUInteger)numberOfMapType;
@end

