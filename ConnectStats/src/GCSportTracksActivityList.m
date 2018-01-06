//  MIT Licence
//
//  Created on 22/03/2014.
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

#import "GCSportTracksActivityList.h"
#import "GCAppGlobal.h"
#import "GCSportTracksActivityListParser.h"
#import "GCActivitiesOrganizer.h"

@interface GCSportTracksActivityList ()
@property (nonatomic,retain) NSString * nextUrl;
@property (nonatomic,retain) NSString * thisUrl;
@property (nonatomic,assign) NSUInteger page;

@end

@implementation GCSportTracksActivityList

+(GCSportTracksActivityList*)activityList:(UINavigationController*)nav{

    GCSportTracksActivityList * rv = [[[GCSportTracksActivityList alloc] init] autorelease];
    if (rv) {
        rv.navigationController = nav;
        rv.nextUrl = nil;
        rv.thisUrl = nil;
        rv.page = 0;
    }
    return rv;
}

-(void)dealloc{
    [_thisUrl release];
    [_nextUrl release];
    [super dealloc];
}
-(NSString*)url{
    if (self.navigationController) {
        return nil;
    }else{
        if (_thisUrl) {
            return [NSString stringWithFormat:@"%@&data=summary", _thisUrl];
        }else{
            return [NSString stringWithFormat:@"https://api.sporttracks.mobi/api/v2/fitnessActivities?data=summary"];
        }
    }
}

-(NSDictionary*)postData{
    return nil;
}

-(NSString*)description{
    if (self.navigationController) {
        return NSLocalizedString(@"Login to SportTracks", @"SportTracks download");
    }else{
        return NSLocalizedString(@"Downloading SportTracks History", @"SportTracks Upload");
    }
}

-(void)process{
    if (self.navigationController) {
        [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self signInToSportTracks];
        });
    }else{
#if TARGET_IPHONE_SIMULATOR
        NSError * e = nil;
        NSString * fn = [NSString stringWithFormat:@"sporttracks_list_%d.json", (int)_page];
        [self.theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:self.encoding error:&e];
#endif
        dispatch_async([GCAppGlobal worker],^(){
            [self parse];
        });
    }
}

-(void)parse{
    GCSportTracksActivityListParser * parser = [GCSportTracksActivityListParser activityListParser:[self.theString dataUsingEncoding:self.encoding]];
    for (GCActivity * act in parser.activities) {
        if ([[GCAppGlobal organizer] activityForId:act.activityId]) {
            self.reachedExisting = true;
        }

        [[GCAppGlobal organizer ] registerActivity:act forActivityId:act.activityId];
    }
    self.nextUrl = parser.nextUrl;

    [self performSelectorOnMainThread:@selector(processDone) withObject:nil waitUntilDone:NO];
}

-(id<GCWebRequest>)nextReq{
    if (self.navigationController) {
        GCSportTracksActivityList * next = [GCSportTracksActivityList activityList:nil];
        next.sportTracksAuth = self.sportTracksAuth;
        return next;
    }else{
        if (self.nextUrl && ! self.reachedExisting) {
            GCSportTracksActivityList * next = [GCSportTracksActivityList activityList:nil];
            next.sportTracksAuth = self.sportTracksAuth;
            next.thisUrl = _nextUrl;
            next.page = _page+1;
            return next;
        }
        return nil;
    }
    return nil;
}


@end
