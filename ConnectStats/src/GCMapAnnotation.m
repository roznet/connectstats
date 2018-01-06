//  MIT Licence
//
//  Created on 20/10/2012.
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

#import "GCMapAnnotation.h"
#import <CoreLocation/CoreLocation.h>
#import "GCLap.h"

@implementation GCMapAnnotation

+(GCMapAnnotation*)mapAnnotationWithCoord:(CLLocationCoordinate2D)point title:(NSString*)title andType:(gcMapAnnotation)atype{
    GCMapAnnotation * rv= RZReturnAutorelease([[GCMapAnnotation alloc] init]);
    if (rv) {
        rv.coordinate = point;
        rv.type = atype;
        rv.customTitle = title;
    }
    return rv;
}

#if !__has_feature(objc_arc)
-(void)dealloc{
    [_customTitle release];
    [super dealloc];
}
#endif

-(NSString*)title{
    if (self.customTitle) {
        return self.customTitle;
    }
    switch (self.type) {
        case gcMapAnnotationEnd:
            return NSLocalizedString(@"End", @"Map annotation");
        case gcMapAnnotationLap:
            return NSLocalizedString(@"Lap", @"Map annotation");
        case gcMapAnnotationStart:
            return NSLocalizedString(@"Start", @"Map annotation");
        case gcMapAnnotationUser:
            return NSLocalizedString(@"User", @"Map annotation");
    }
    return nil;
}
-(NSString*)subtitle{
    return @"";
}
@end
