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

#import <Foundation/Foundation.h>
#import "GCFields.h"
#import <CoreLocation/CoreLocation.h>

@class GCViewGradientColors;
@class GCActivity;
@class GCField;

typedef NS_ENUM(NSUInteger, gcLapDisplay){
    gcLapDisplayNone,
    gcLapDisplayMarkers,
    gcLapDisplaySingle,
    gcLapDisplayFastestDistanceUnit,
    gcLapDisplayPointInfo
};

@protocol GCMapImplementorProtocol

-(NSUInteger)numberOfColors;
-(GCViewGradientColors*)gradientColors;

+(NSUInteger)numberOfMapType;
-(void)toggleMapType:(NSUInteger)mapType;
-(void)forceRedisplay;
-(void)setupFrame:(CGRect)frame;
-(void)setupOverlayAndAnnotations;
-(void)zoomInOnRoute;

@optional
-(void)focusOnLocation:(CLLocation*)location;

@end

@protocol GCMapDataSourceProtocol <NSObject>

-(GCActivity*)activity;
-(GCActivity*)compareActivity;
-(GCField*)gradientField;
-(void)loadAnnotations;
-(NSArray*)annotations;
-(gcLapDisplay)showLaps;
-(NSUInteger)lapIndex;
-(void)setupLegendViewWithThresholds:(NSArray*)thresholds;
-(BOOL)enableTap;
-(void)tapPoint:(CLLocationCoordinate2D)coord;

@end
