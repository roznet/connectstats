//  MIT Licence
//
//  Created on 17/05/2015.
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

#import "RZShapeFileMapView.h"
#import "RZShapeFile.h"


@interface RZShapeFileMapView ()
@property (nonatomic,retain) RZShapeFile *file;
@end

@implementation RZShapeFileMapView

+(instancetype)shapeFileMapViewFor:(RZShapeFile*)file{
    RZShapeFileMapView * rv = [[RZShapeFileMapView alloc] init];
    if (rv) {
        rv.file = file;
    }
    return rv;
}


-(void)updateForMapView:(MKMapView*)mapView andIndexSet:(NSIndexSet*)indexSet{
    [mapView removeOverlays:mapView.overlays];
    [mapView removeAnnotations:mapView.annotations];

    NSArray * overlays = [self.file polygonsForIndexSet:indexSet];

    NSMutableArray * poly = [NSMutableArray arrayWithCapacity:overlays.count];
    NSMutableArray * annot = [NSMutableArray arrayWithCapacity:overlays.count];
    MKMapRect bounding = MKMapRectNull;
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(0., 0.);
    BOOL boundingStarted = false;
    BOOL centerStarted = false;

    for (id obj in overlays) {
        if ([obj isKindOfClass:[MKPolygon class]]) {
            if (boundingStarted) {
                bounding = MKMapRectUnion(bounding, [obj boundingMapRect]);
            }else{
                bounding = [obj boundingMapRect];
            }
            boundingStarted = true;
            [poly addObject:obj];
        }else if ([obj conformsToProtocol:@protocol(MKAnnotation)]){
            id<MKAnnotation> an = obj;
            [annot addObject:obj];
            if (boundingStarted) {

            }else{
                center = [an coordinate];
                centerStarted = true;
            }
        }
    }
    if(poly.count>0){
        [mapView addOverlays:poly];
    }
    if (annot.count>0) {
        [mapView addAnnotations:annot];
    }

    if (boundingStarted) {
        bounding = MKMapRectInset(bounding, MKMapRectGetWidth(bounding)*-0.05, MKMapRectGetHeight(bounding)*-0.05);
        [mapView setRegion:MKCoordinateRegionForMapRect(bounding)];
    }else if (centerStarted){
        [mapView setCenterCoordinate:center];
    }

}

-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    MKPinAnnotationView * rv = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinview"];
    [rv setCanShowCallout:YES];
    return rv;

}

-(MKOverlayRenderer*)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    if ([overlay isKindOfClass:[MKPolygon class]]) {
        MKPolygonRenderer * rv = [[MKPolygonRenderer alloc] initWithPolygon:(MKPolygon*)overlay];
        rv.fillColor = [self.fillColor colorWithAlphaComponent:self.alpha];
        if (self.strokeColor) {
            rv.strokeColor = [self.strokeColor colorWithAlphaComponent:self.alpha];
            rv.lineWidth = 1.0;
        }
        return rv;
    }
    return nil;
}

@end
