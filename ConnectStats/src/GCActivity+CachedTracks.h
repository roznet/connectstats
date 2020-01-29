//  MIT Licence
//
//  Created on 23/12/2013.
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

#import "GCActivity.h"

typedef NS_ENUM(NSUInteger, gcCalculatedCachedTrack) {
    gcCalculatedCachedTrackRollingBest,
    gcCalculatedCachedTrackDistanceResample,
    gcCalculatedCachedTrackDataSerie
};

@interface GCActivity (CachedTracks)



-(nullable GCStatsDataSerieWithUnit*)calculatedDerivedTrack:(gcCalculatedCachedTrack)track forField:(nonnull GCField*)field thread:(nullable dispatch_queue_t)thread;
-(nullable GCStatsDataSerieWithUnit*)standardizedBestRollingTrack:(nonnull GCField*)field thread:(nullable dispatch_queue_t)thread;

-(BOOL)hasCalculatedDerivedTrack:(gcCalculatedCachedTrack)track forField:(nonnull GCField*)field;

-(nonnull NSArray<GCTrackPoint*>*)resample:(nonnull NSArray<GCTrackPoint*>*)points forUnit:(double)unit useTimeAxis:(BOOL)timeAxis;
-(nonnull NSArray<GCTrackPoint*>*)matchDistance:(CLLocationDistance)target withPoints:(nonnull NSArray<GCTrackPoint*>*)points;

-(void)addStandardCalculatedTracks:(nullable dispatch_queue_t)threadOrNil;
+(nullable GCStatsDataSerieWithUnit*)standardSerieSampleForXUnit:(nonnull GCUnit*)xUnit;

@end
