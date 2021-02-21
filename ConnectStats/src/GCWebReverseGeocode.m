//  MIT Licence
//
//  Created on 18/11/2012.
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

#import "GCWebReverseGeocode.h"
#import "GCActivitiesOrganizer.h"
#import "GCAppGlobal.h"
@import RZExternalUniversal;

@interface GCWebReverseGeocode ()
@property (nonatomic,assign)    NSUInteger countOfSuccessfulRequest;
@property (nonatomic,assign)    BOOL reachedGeocodingLimit;


@end

@implementation GCWebReverseGeocode


-(instancetype)init{
    return [super init];
}
-(GCWebReverseGeocode*)initWithOrganizer:(GCActivitiesOrganizer*)aOrg andDel:(id<GCWebReverseGeocodeDelegate>)aDel{
    self = [super init];
    if (self) {
        self.organizer = aOrg;
        self.delegate = aDel;
        geocoding = false;
        nextForGeocoding = 0;
        self.geocoder = [[[CLGeocoder alloc] init] autorelease];
    }
    return self;
}

-(void)dealloc{
    _delegate = nil;
    _organizer = nil;
    [self.geocoder cancelGeocode];
    [_geocoder release];
    [_activity release];

    [super dealloc];
}
#pragma - organizer

-(void)next{
    if (!geocoding && nextForGeocoding < [_organizer countOfActivities] && !self.reachedGeocodingLimit) {
        geocoding = true;
        somethingDone = false;
        self.activity = [_organizer activityForIndex:nextForGeocoding];
        nextForGeocoding += 1;
        [self reverseGeocodeActivity];
    }
}

-(void)start{
    nextForGeocoding = 0;
    [self next];
}

-(void)saveLocation:(CLPlacemark*)aPlacemark{
    if (aPlacemark.locality && aPlacemark.ISOcountryCode) {
        [_activity saveLocation:[NSString stringWithFormat:@"%@, %@", aPlacemark.locality, aPlacemark.ISOcountryCode]];
        somethingDone = true;
    }
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self reverseGeocodeDone];
    });
}

-(void)reverseGeocodeDone{
    geocoding = false;
    if (somethingDone) {
        [_delegate reverseGeocodeDone];
        somethingDone = false;
    }
    [self next];
}

-(void)reverseGeocodeActivity{
    if (self.activity.location == nil || [self.activity.location isEqualToString:@""]) {
        CLLocation * loc = [[[CLLocation alloc] initWithLatitude:_activity.beginCoordinate.latitude
                                                       longitude:_activity.beginCoordinate.longitude] autorelease];
        [self.geocoder reverseGeocodeLocation:loc completionHandler:^(NSArray *placemarks, NSError *error) {
            if (self.organizer==nil) {
                return ;
            }
            if (error){
                self.reachedGeocodingLimit = true;
                RZLog(RZLogInfo, @"Reached geocoding limit after %lu requests", (unsigned long)self.countOfSuccessfulRequest);
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [self reverseGeocodeDone];
                });
                return;
            }
            if (placemarks.count) {
                self.countOfSuccessfulRequest++;
                dispatch_async([GCAppGlobal worker],^(){
                    [self saveLocation:placemarks[0]];
                });
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self reverseGeocodeDone];
            });
        }];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self reverseGeocodeDone];
        });
    }
}

+(NSString*)countryISOFromCoordinate:(CLLocationCoordinate2D)coord{
    static RZShapeFile * worldShapeFile = nil;
    if( worldShapeFile == nil){
        worldShapeFile = [RZShapeFile shapeFileWithBase:[RZFileOrganizer bundleFilePath:@"TM_WORLD_BORDERS-0.2"]];
        RZRetain(worldShapeFile);
    }
    
    NSIndexSet * closest_set = [worldShapeFile indexSetForShapeContainingOrClosest:coord];
    NSArray * closest_found = [[worldShapeFile allShapes] objectsAtIndexes:closest_set];
    if( closest_found.count > 0){
        return closest_found[0][@"ISO2"];
    }
    
    return @"Unknown";
}


@end
