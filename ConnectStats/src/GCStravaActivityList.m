//  MIT Licence
//
//  Created on 13/03/2014.
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

#import "GCStravaActivityList.h"
@import RZExternal;
#import "GCAppGlobal.h"
#import "GCStravaActivityListParser.h"
#import "GCActivitiesOrganizer.h"

@implementation GCStravaActivityList

+(GCStravaActivityList*)stravaActivityList:(UINavigationController*)nav{
    GCStravaActivityList * rv = [[[GCStravaActivityList alloc] init] autorelease];
    if (rv) {
        rv.navigationController = nav;
    }
    return rv;
}

-(NSString*)url{
    if (self.navigationController) {
        return nil;
    }else{
        return [NSString stringWithFormat:@"https://www.strava.com/api/v3/athlete/activities?access_token=%@&page=%d",(self.stravaAuth).accessToken,(int)self.page+1];;
    }
}

-(NSDictionary*)postData{
    return nil;
}

-(NSString*)description{
    if (self.navigationController) {
        return NSLocalizedString(@"Login to strava", @"Strava Upload");
    }else{
        if (self.page > 0) {
            return [NSString stringWithFormat:NSLocalizedString(@"Downloading strava History %d", @"Strava Upload"), self.page+1];
        }else{
            return NSLocalizedString(@"Downloading strava History", @"Strava Upload");
        }
    }
}

-(void)process{
    if (self.navigationController) {
        [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(signInToStrava) withObject:nil waitUntilDone:NO];
    }else{
#if TARGET_IPHONE_SIMULATOR
        NSError * e = nil;
        NSString * fn = [NSString stringWithFormat:@"strava_list_%d.json", (int)self.page];
        [self.theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:self.encoding error:&e];
#endif
        dispatch_async([GCAppGlobal worker],^(){
            [self parse];
        });
    }
}

-(void)parse{
    GCStravaActivityListParser * parser = [GCStravaActivityListParser activityListParser:[self.theString dataUsingEncoding:self.encoding]];
    //FIXME: deal with deleted activities on strava
    if (parser.hasError) {
        self.status = GCWebStatusParsingFailed;
    }else{
        self.reachedExisting = false;
        NSUInteger newActivitiesCount = 0;
        for (GCActivity * act in parser.activities) {
            if ([[GCAppGlobal organizer] activityForId:act.activityId]) {
                self.reachedExisting = true;
            }else{
                newActivitiesCount++;
            }

            [[GCAppGlobal organizer] registerActivity:act forActivityId:act.activityId];
        }
        self.parsedCount = parser.parsedCount;
        if (newActivitiesCount > 0 && self.reachedExisting) {
            RZLog(RZLogInfo, @"Found %d new Strava Activities (%d total)", (int)newActivitiesCount,
                  (int)[[GCAppGlobal organizer] countOfActivities]);
        }
    }
    [self performSelectorOnMainThread:@selector(processDone) withObject:nil waitUntilDone:NO];

}

-(id<GCWebRequest>)nextReq{
    if (self.navigationController) {
        GCStravaActivityList * next = [GCStravaActivityList stravaActivityList:nil];
        next.stravaAuth = self.stravaAuth;
        return next;
    }else{
        if (self.parsedCount == 30 && !self.reachedExisting) {
            GCStravaActivityList * next = [GCStravaActivityList stravaActivityList:nil];
            next.stravaAuth = self.stravaAuth;
            next.page = self.page + 1;
            return next;
        }
    }
    return nil;
}


@end
