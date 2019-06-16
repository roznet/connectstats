//  MIT Licence
//
//  Created on 29/09/2013.
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

#import "GCGarminRequest.h"

typedef NS_ENUM(NSUInteger, gcTrack13RequestStage){
    gcTrack13RequestTracks,
    gcTrack13RequestLaps,
    gcTrack13RequestFit,
    gcTrack13RequestEnd
};
@class GCActivity;
@class GCLap;
@class GCTrackPoint;
@class GCTrackPointSwim;

@interface GCGarminActivityTrack13Request : GCGarminReqBase
@property (nonatomic,readonly) NSArray<GCTrackPoint*> * trackpoints;
@property (nonatomic,readonly) NSArray<GCLap*> * laps;

@property (nonatomic,readonly) NSArray<GCTrackPointSwim*> * trackpointsSwim;

@property (nonatomic,readonly) NSString * activityId;
@property (nonatomic,assign) gcTrack13RequestStage track13Stage;

+(GCGarminActivityTrack13Request*)requestWithActivity:(GCActivity*)aId;
+(GCGarminActivityTrack13Request*)nextRequest:(GCGarminActivityTrack13Request*)prev;

+(GCActivity*)testForActivity:(GCActivity*)act withFilesIn:(NSString*)path;
+(GCActivity*)testForActivity:(GCActivity*)act withFilesIn:(NSString*)path mergeFit:(BOOL)mergeFit;

@end
