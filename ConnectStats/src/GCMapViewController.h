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

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "GCActivity.h"
#import "GCMapGradientPathOverlayView.h"
#import "GCFields.h"
#import "GCSharingViewController.h"
#import "GCMapLegendView.h"
#import "GCMapLapInfoView.h"
#import "GCMapImplementorProtocol.h"
#import "GCViewConfig.h"
#import "GCMapWindCompass.h"

@class GCMapAppleViewController;
@class GCMapGoogleViewController;

typedef NS_ENUM(NSUInteger, gcMapImplementor) {
    gcMapImplementorNone,
    gcMapImplementorApple,
    gcMapImplementorGoogle
};

typedef void(^gcMapViewControllerCompletion)(void);

@interface GCMapViewController : UIViewController<RZChildObject,GCSharingImageExporter,GCMapDataSourceProtocol>

@property (nonatomic,retain) GCActivity * activity;
@property (nonatomic,retain) GCActivity * compareActivity;
@property (nonatomic,assign) CLLocationCoordinate2D centerCoordinate;
@property (nonatomic,retain) GCField * gradientField;
@property (nonatomic,retain) NSArray * annotations;
@property (nonatomic,retain) GCMapLegendView * legendView;
@property (nonatomic,assign) gcLapDisplay showLaps;
@property (nonatomic,assign) NSUInteger lapIndex;
@property (nonatomic,assign) NSUInteger movingAverage;
@property (nonatomic,retain) GCMapLapInfoView *lapInfoView;
@property (nonatomic,copy) gcMapViewControllerCompletion completionHandler;

@property (nonatomic,retain) GCMapAppleViewController * appleImplementor;
@property (nonatomic,retain) GCMapGoogleViewController * googleImplementor;
@property (nonatomic,retain) UIViewController<GCMapImplementorProtocol> * implementor;

@property (nonatomic,assign) gcMapImplementor implementorType;
@property (nonatomic,assign) NSUInteger currentMapType;

@property (nonatomic,assign) gcMapType mapType;
@property (nonatomic,assign) BOOL enableTap;

@property (nonatomic,retain) GCTrackPoint * tappedPoint;

@property (nonatomic,retain) GCMapWindCompass * windCompassView;

@property (nonatomic,assign) BOOL disableInfoViews;

-(void)forceRedisplay;
-(void)setupFrames:(CGRect)rect;
-(void)updatePanelFrames;
-(void)zoomInOnRoute;

-(void)toggleMapType:(id)cb;
-(void)toggleShowLap:(id)cb;
-(void)toggleField:(id)cb;

-(void)mapImageForActivity:(GCActivity*)act size:(CGSize)size completion:(void(^)(UIImage*))handler;

@end
