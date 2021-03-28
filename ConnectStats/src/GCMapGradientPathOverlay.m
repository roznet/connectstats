//  MIT Licence
//
//  Created on 13/11/2016.
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

#import "GCMapGradientPathOverlay.h"
#import "GCMapRouteLogicPointHolder.h"

@interface GCMapGradientPathOverlay ()
@property (nonatomic,assign) CLLocationCoordinate2D coordinate;
@end

@implementation GCMapGradientPathOverlay


#if !__has_feature(objc_arc)
- (void)dealloc
{
    [_points release];
    [super dealloc];
}
#endif

-(MKMapRect)calculateBoundingMapRect{
    BOOL started = false;

    CLLocationCoordinate2D northEastPoint = CLLocationCoordinate2DMake(0., 0.);
    CLLocationCoordinate2D southWestPoint = CLLocationCoordinate2DMake(0., 0.);

    for (GCMapRouteLogicPointHolder * holder in self.points) {
        CLLocationCoordinate2D point = holder.point;
        if (!started) {
            northEastPoint = point;
            southWestPoint = point;
            started = true;
        }
        else
        {
            if (point.latitude > northEastPoint.latitude)
                northEastPoint.latitude = point.latitude;
            if(point.longitude > northEastPoint.longitude)
                northEastPoint.longitude = point.longitude;
            if (point.latitude < southWestPoint.latitude)
                southWestPoint.latitude = point.latitude;
            if (point.longitude < southWestPoint.longitude)
                southWestPoint.longitude = point.longitude;
        }
    }
    MKMapPoint southWestMapPoint = MKMapPointForCoordinate(southWestPoint);
    MKMapPoint northEastMapPoint = MKMapPointForCoordinate(northEastPoint);

    MKMapRect rv = MKMapRectMake(southWestMapPoint.x, northEastMapPoint.y, northEastMapPoint.x - southWestMapPoint.x, southWestMapPoint.y-northEastMapPoint.y );
    self.boundingMapRect = MKMapRectInset(rv, MKMapRectGetWidth(rv)*-0.1, MKMapRectGetHeight(rv)*-0.1);

    return self.boundingMapRect;

}
@end
