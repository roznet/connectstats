//  MIT Licence
//
//  Created on 05/08/2016.
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

#import "GCStravaTrainingZones.h"
@import RZExternal;
#import "GCAppGlobal.h"

@implementation GCStravaTrainingZones

+(GCStravaTrainingZones*)stravaTrainingZones:(UINavigationController *)nav{
    GCStravaTrainingZones * rv = [[[GCStravaTrainingZones alloc] init] autorelease];
    if (rv) {
        rv.navigationController = nav;
    }
    return rv;
}

-(NSString*)url{
    if (self.navigationController) {
        return nil;
    }else{
        return [NSString stringWithFormat:@"https://www.strava.com/api/v3/athlete/zones?access_token=%@",(self.stravaAuth).accessToken];
    }
}

-(NSDictionary*)postData{
    return nil;
}

-(NSString*)description{
    if (self.navigationController) {
        return NSLocalizedString(@"Login to strava", @"Strava Download");
    }else{
        return NSLocalizedString(@"Downloading strava Zones", @"Strava Download");
    }
}

-(void)process{
    if (self.navigationController) {
        [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(signInToStrava) withObject:nil waitUntilDone:NO];
    }else{
#if TARGET_IPHONE_SIMULATOR
        NSError * e = nil;
        NSString * fn = [NSString stringWithFormat:@"strava_training_zones.json"];
        [self.theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:self.encoding error:&e];
#endif
        dispatch_async([GCAppGlobal worker],^(){
            [self parse];
        });
    }
}

-(void)parse{
    [self performSelectorOnMainThread:@selector(processDone) withObject:nil waitUntilDone:NO];

}

-(id<GCWebRequest>)nextReq{
    if (self.navigationController) {
        GCStravaTrainingZones * next = [GCStravaTrainingZones stravaTrainingZones:nil];
        next.stravaAuth = self.stravaAuth;
        return next;
    }
    return nil;
}


@end
