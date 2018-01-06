//  MIT Licence
//
//  Created on 19/02/2014.
//
//  Copyright (c) 2014 Brice Rosenzweig.
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

#import <Foundation/Foundation.h>
#import "GCFields.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "GCMapImplementorProtocol.h"
#import "GCField.h"
#import "GCMapRouteLogicPointHolder.h"

@class GCActivity;
@class GCViewGradientColors;

@interface GCMapRouteLogic : NSObject
// Inputs
@property (nonatomic,retain) GCActivity * activity;
@property (nonatomic,retain) GCActivity * compareActivity;
@property (nonatomic,retain) GCField * gradientField;
@property (nonatomic,retain) GCViewGradientColors * gradientColors;
@property (nonatomic,assign) gcLapDisplay showLaps;
@property (nonatomic,assign) NSUInteger lapIndex;
@property (nonatomic,assign) NSUInteger maxPoints;
@property (nonatomic,assign) BOOL lapsRectOnFullRoute;

//Outputs
@property (nonatomic,retain) NSArray * points;
@property (nonatomic,assign) CLLocationCoordinate2D northEastPoint;
@property (nonatomic,assign) CLLocationCoordinate2D southWestPoint;
@property (nonatomic,retain) NSArray * thresholds;

+(GCMapRouteLogic*)routeLogicFor:(GCActivity*)act field:(GCField*)f andColors:(GCViewGradientColors*)col;
+(GCMapRouteLogic*)routeLogicFor:(GCActivity*)act field:(GCField*)f colors:(GCViewGradientColors*)col andLap:(NSUInteger)l;
+(GCMapRouteLogic*)routeLogicFor:(GCActivity*)act comparedTo:(GCActivity*)other andColors:(GCViewGradientColors*)col;

-(void)calculate;
-(NSUInteger)countOfPoints;
-(GCMapRouteLogicPointHolder*)pointFor:(NSUInteger)idx;
-(MKMapPoint)northEastMapPoint;
-(MKMapPoint)southWestMapPoint;
-(CLLocationCoordinate2D)centerPoint;
-(MKMapPoint)centerMapPoint;
-(MKMapRect)routeMapRect;

@end
