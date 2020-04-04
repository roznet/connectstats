//  MIT License
//
//  Created on 22/03/2020 for ConnectStats
//
//  Copyright (c) 2020 Brice Rosenzweig
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



#import "GCActivity.h"

NS_ASSUME_NONNULL_BEGIN

@interface GCActivity (TrackTransform)

-(nonnull NSArray<GCTrackPoint*>*)resample:(nonnull NSArray<GCTrackPoint*>*)points forUnit:(double)unit useTimeAxis:(BOOL)timeAxis;
-(nonnull NSArray<GCTrackPoint*>*)matchDistance:(CLLocationDistance)target withPoints:(nonnull NSArray<GCTrackPoint*>*)points;
-(NSArray<GCTrackPoint*>*)removedStoppedTimer:(nonnull NSArray<GCTrackPoint*>*)points;
-(nonnull NSArray<GCTrackPoint*>*)recalculatedSpeed:(nonnull NSArray<GCTrackPoint*>*)points
                                    minimumDistance:(CLLocationDistance)minDistance
                                     minimumElapsed:(NSTimeInterval)minElapsed
                                             useGPS:(BOOL)useGPS;
-(NSString*)csvTrackPoints:(NSArray<GCTrackPoint*>*)trackpoints;

@end

NS_ASSUME_NONNULL_END
