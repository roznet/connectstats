//  MIT Licence
//
//  Created on 27/10/2015.
//
//  Copyright (c) 2015 Brice Rosenzweig.
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

#import "CLLocation+RZHelper.h"
#import <RZUtils/RZMacros.h>

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiandsToDegrees(x) (x * 180.0 / M_PI)


@implementation CLLocation (RZHelper)


+(CLLocationDegrees)getHeadingForDirectionFromCoordinate:(CLLocationCoordinate2D)fromLoc
                                            toCoordinate:(CLLocationCoordinate2D)toLoc
{
    float fLat = degreesToRadians(fromLoc.latitude);
    float fLng = degreesToRadians(fromLoc.longitude);
    float tLat = degreesToRadians(toLoc.latitude);
    float tLng = degreesToRadians(toLoc.longitude);

    float degree = radiandsToDegrees(atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)));

    if (degree >= 0) {
        return degree;
    } else {
        return 360+degree;
    }
}


-(CLLocation*)locationAtDistance:(CLLocationDistance)distance andBearing:(CLLocationDegrees)bearing{
    // This calculation is taken wholesale from http://www.movable-type.co.uk/scripts/latlong.html
    // Taken from the "Destination point given distance and bearing from start point" section
    const int R = 6371000;
    // Bearing needs to be in radians
    double bearingRad = bearing * M_PI / 180;
    double dOverR = distance/R;
    // Lat and lon need to be radians, too
    double currentLat = self.coordinate.latitude * M_PI / 180;
    double currentLon = self.coordinate.longitude * M_PI / 180;
    double newLat = asin(sin(currentLat)*cos(dOverR) + cos(currentLat)*sin(dOverR)*cos(bearingRad));
    double newLon = currentLon + atan2(sin(bearingRad)*sin(dOverR)*cos(currentLat), cos(dOverR) - sin(currentLat)*sin(newLat));

    // Convert back to degrees for the CLLocation
    CLLocation* new = RZReturnAutorelease([[CLLocation alloc] initWithLatitude:newLat * 180 / M_PI longitude:newLon * 180 / M_PI]);
    return new;
}
-(CLLocationDegrees) bearingTo:(CLLocation*) otherPoint {
    // This calculation is taken wholesale from http://www.movable-type.co.uk/scripts/latlong.html
    // Taken from the "Bearing" section

    // Everything in radians first.
    double thisLat = self.coordinate.latitude * M_PI / 180;
    double thisLon = self.coordinate.longitude * M_PI / 180;
    double otherLat = otherPoint.coordinate.latitude * M_PI / 180;
    double otherLon = otherPoint.coordinate.longitude * M_PI / 180;

    // Do the actual calculation
    double y = sin(otherLon - thisLon) * cos(otherLat);
    double x = cos(thisLat)*sin(otherLat) - sin(thisLat)*cos(otherLat)*cos(otherLon - thisLon);

    double bearing = atan2(y, x) * 180 / M_PI;

    // Convert the range -180 to 180 to 0 to 360.
    return fmod(bearing + 360, 360.0);
}


@end
