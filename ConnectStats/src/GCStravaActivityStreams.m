//  MIT Licence
//
//  Created on 18/03/2014.
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

#import "GCStravaActivityStreams.h"
@import RZExternal;
#import "GCAppGlobal.h"
#import "GCService.h"
#import "GCStravaActivityStreamsParser.h"
#import "GCStravaActivityLapsParser.h"
#import "GCActivitiesOrganizer.h"

@interface GCStravaActivityStreams ()
@property (nonatomic,assign) BOOL inError;
@property (nonatomic,readonly) NSString * activityId;

@end

@implementation GCStravaActivityStreams

+(GCStravaActivityStreams*)stravaActivityStream:(UINavigationController*)nav for:(GCActivity*)act{
    GCStravaActivityStreams * rv = [[[GCStravaActivityStreams alloc] init] autorelease];
    if (rv) {
        rv.navigationController = nav;
        rv.activity = act;
    }
    return rv;
}

-(GCStravaActivityStreams*)initNextWith:(GCStravaActivityStreams*)current{
    if( self = [super initNextWith:current]){
        self.activity = current.activity;
        self.points = current.points;
        self.laps = current.laps;
    }
    return self;
}

-(void)dealloc{
    [_activity release];
    [_points release];
    [_laps release];
    [super dealloc];
}
-(NSString*)activityId{
    return self.activity.activityId;
}
-(NSString*)url{
    if( self.navigationController ){
        return nil;
    }
    NSString * sid = [[GCService service:gcServiceStrava] serviceIdFromActivityId:self.activityId];
    
    /*
     time:	integer seconds
     latlng:	floats [latitude, longitude]
     distance:	float meters
     altitude:	float meters
     velocity_smooth:	float meters per second
     heartrate:	integer BPM
     cadence:	integer RPM
     watts:	integer watts
     temp:	integer degrees Celsius
     moving:	boolean
     grade_smooth:	float percent
     */
    NSString * url = [NSString stringWithFormat:@"https://www.strava.com/api/v3/activities/%@/%@",
                      sid,
                      self.points ? @"laps" : @"streams/latlng,heartrate,time,altitude,cadence,watts,velocity_smooth"
                      ];
    return url;
    
}

-(NSDictionary*)postData{
    return nil;
}

-(NSString*)description{
    if (self.navigationController) {
        return NSLocalizedString(@"Login to strava", @"Strava Upload");
    }else{
        return NSLocalizedString(@"Downloading strava track", @"Strava Upload");
    }
}

-(void)process{
    if (self.navigationController) {
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self processNewStage];
            [self signInToStrava];
        });
    }else if(self.points==nil){

#if TARGET_IPHONE_SIMULATOR
        NSError * e = nil;
        NSString * fn = [NSString stringWithFormat:@"strava_stream_%@.json",[[GCService service:gcServiceStrava] serviceIdFromActivityId:self.activityId]];
        [self.theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:self.encoding error:&e];
#endif
        dispatch_async([GCAppGlobal worker],^(){
            [self parseStreams];
        });
    }else{
#if TARGET_IPHONE_SIMULATOR
        NSError * e = nil;
        NSString * fn = [NSString stringWithFormat:@"strava_laps_%@.json",[[GCService service:gcServiceStrava] serviceIdFromActivityId:self.activityId]];
        [self.theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:self.encoding error:&e];
#endif
        dispatch_async([GCAppGlobal worker],^(){
            [self parseLaps];
        });

    }
}

-(void)parseStreams{

    GCStravaActivityStreamsParser * parser = [GCStravaActivityStreamsParser activityStreamsParser:[self.theString dataUsingEncoding:self.encoding]];
    self.points = parser.points;
    self.inError = parser.inError;
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self processDone];
    });
}

-(void)parseLaps{
    self.laps = @[];
    GCStravaActivityLapsParser * parser = [GCStravaActivityLapsParser activityLapsParser:[self.theString dataUsingEncoding:self.encoding] withPoints:self.points inActivity:self.activity];
    [[GCAppGlobal organizer] registerActivity:self.activityId withTrackpoints:self.points andLaps:parser.laps];
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self processDone];
    });
}

-(id<GCWebRequest>)nextReq{
    if (self.inError) {
        return nil;
    }
    if (self.navigationController || !self.laps) {
        GCStravaActivityStreams * next = RZReturnAutorelease([[GCStravaActivityStreams alloc] initNextWith:self]);
        return next;
    }
    return nil;
}


@end
