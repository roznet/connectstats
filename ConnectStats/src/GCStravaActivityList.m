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
#import "GCActivitiesOrganizerListRegister.h"
#import "GCService.h"

@interface GCStravaActivityList ()

@property (nonatomic,assign) BOOL reloadAll;
@property (nonatomic,assign) NSUInteger page;
@property (nonatomic,retain) NSDate * lastFoundDate;
@property (nonatomic,assign) BOOL searchMore;

@end

@implementation GCStravaActivityList

+(GCStravaActivityList*)stravaActivityList:(UINavigationController*)nav start:(NSUInteger)start andMode:(BOOL)mode{
    GCStravaActivityList * rv = [[[GCStravaActivityList alloc] init] autorelease];
    if (rv) {
        rv.navigationController = nav;
        rv.lastFoundDate = [NSDate date];
        rv.reloadAll = mode;
        rv.page = start;
    }
    return rv;
}

-(GCStravaActivityList*)initNextWith:(GCStravaActivityList*)current{
    self = [super init];
    if( self ){
        if( current.navigationController ){
            self.page = current.page;
        }else{
            self.page = current.page + 1;
        }
        self.lastFoundDate = current.lastFoundDate;
        self.reloadAll = current.reloadAll;
        self.stravaAuth = current.stravaAuth;
    }
    return self;
}

-(void)dealloc{
    [_lastFoundDate release];
    [super dealloc];
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
            return [NSString stringWithFormat:NSLocalizedString(@"Downloading Strava %@", @"Strava Upload"), [self.lastFoundDate?:[NSDate date] dateFormatFromToday]];
        }else{
            return NSLocalizedString(@"Downloading strava History", @"Strava Upload");
        }
    }
}

-(NSString*)searchFileNameForPage:(int)page{
    return  [NSString stringWithFormat:@"last_strava_search_%d.json", page];
}


-(void)process{
    if (self.navigationController) {
        [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(signInToStrava) withObject:nil waitUntilDone:NO];
    }else{
#if TARGET_IPHONE_SIMULATOR
        NSError * e = nil;
        NSString * fn = [self searchFileNameForPage:(int)self.page];
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
        GCActivitiesOrganizer * organizer = [GCAppGlobal organizer];
        
        [[GCAppGlobal profile] serviceSuccess:gcServiceGarmin set:true];
        self.stage = gcRequestStageSaving;
        [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
        
        [self addActivitiesFromParser:parser toOrganizer:organizer];
    }
    [self performSelectorOnMainThread:@selector(processDone) withObject:nil waitUntilDone:NO];

}

+(GCActivitiesOrganizer*)testForOrganizer:(GCActivitiesOrganizer*)organizer withFilesInPath:(NSString*)path{
    return [self testForOrganizer:organizer withFilesInPath:path start:0];
}
+(GCActivitiesOrganizer*)testForOrganizer:(GCActivitiesOrganizer*)organizer withFilesInPath:(NSString*)path start:(NSUInteger)start{
    GCStravaActivityList * search = [GCStravaActivityList stravaActivityList:nil start:start andMode:false];
    
    BOOL isDirectory = false;
    if( [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory]){
        NSString * fn = isDirectory ? [path stringByAppendingPathComponent:[search searchFileNameForPage:(int)start]] : path;
        
        NSData * info = [NSData dataWithContentsOfFile:fn];
        GCStravaActivityListParser * parser = [GCStravaActivityListParser activityListParser:info];
        [search addActivitiesFromParser:parser toOrganizer:organizer];
    }
    
    return organizer;
}

-(void)addActivitiesFromParser:(GCStravaActivityListParser*)parser
                   toOrganizer:(GCActivitiesOrganizer*)organizer{
    GCActivitiesOrganizerListRegister * listRegister = [GCActivitiesOrganizerListRegister listRegisterFor:parser.activities from:[GCService service:gcServiceStrava] isFirst:self.page == 0];
    [listRegister addToOrganizer:organizer];
    if (listRegister.childIds.count > 0) {
        RZLog( RZLogWarning, @"ChildIDs not supported for strava");
    }
    //self.activities = parser.activities;
    NSDate * newDate = parser.activities.lastObject.date;
    if(newDate){
        self.lastFoundDate = newDate;
    }
    
    self.searchMore = [listRegister shouldSearchForMoreWith:30 reloadAll:self.reloadAll];
}

-(id<GCWebRequest>)nextReq{
    if (self.navigationController || self.searchMore) {
        GCStravaActivityList * next = RZReturnAutorelease([[GCStravaActivityList alloc] initNextWith:self]);
        return next;
    }
    return nil;
}


@end
