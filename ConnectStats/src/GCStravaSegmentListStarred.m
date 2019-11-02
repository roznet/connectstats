//  MIT Licence
//
//  Created on 23/07/2016.
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

#import "GCStravaSegmentListStarred.h"
@import RZExternal;
#import "GCAppGlobal.h"
#import "ConnectStats-Swift.h"


@interface GCStravaSegmentListStarred ()
@property (nonatomic,assign) NSUInteger page;
@property (nonatomic,assign) NSUInteger parsedCount;
@property (nonatomic,assign) BOOL reachedExisting;

@end

@implementation GCStravaSegmentListStarred

+(GCStravaSegmentListStarred*)segmentListStarred:(UINavigationController*)nav{
    GCStravaSegmentListStarred * rv = [[[GCStravaSegmentListStarred alloc] init] autorelease];
    if (rv) {
        rv.navigationController = nav;
    }
    return rv;
}

-(NSString*)url{
    if (self.navigationController) {
        return nil;
    }else{
        return [NSString stringWithFormat:@"https://www.strava.com/api/v3/segments/starred?access_token=%@&page=%d",@"FIX ME WITH PREP REQ",(int)self.page+1];;
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
            return [NSString stringWithFormat:NSLocalizedString(@"Downloading strava Segments %d", @"Strava Download"), self.page+1];
        }else{
            return NSLocalizedString(@"Downloading Strava Segments", @"Strava Download");
        }
    }
}

-(NSString*)segmentsListFileForPage:(int)page{
    return [NSString stringWithFormat:@"strava_segments_%d.json", (int)self.page];
}

-(void)process{
    if (self.navigationController) {
        [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(signInToStrava) withObject:nil waitUntilDone:NO];
    }else{
#if TARGET_IPHONE_SIMULATOR
        NSError * e = nil;
        NSString * fn = [self segmentsListFileForPage:(int)self.page];

        [self.theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:self.encoding error:&e];
#endif
        dispatch_async([GCAppGlobal worker],^(){
            [self parse];
        });
    }
}

-(void)parse{
    self.reachedExisting = true;
    //GCStravaSegmentListParser * parser = [[[GCStravaSegmentListParser alloc] initWithData:[self.theString dataUsingEncoding:self.encoding]] autorelease];
    //[parser registerInOrganizer:<#(GCSegmentOrganizer * _Nonnull)#>;

    [self performSelectorOnMainThread:@selector(processDone) withObject:nil waitUntilDone:NO];

}

-(id<GCWebRequest>)nextReq{
    if (self.navigationController) {
        GCStravaSegmentListStarred * next = [GCStravaSegmentListStarred segmentListStarred:nil];
        //next.stravaAuth = self.stravaAuth;
        return next;
    }else{
        if (self.parsedCount == 30 && !self.reachedExisting) {
            GCStravaSegmentListStarred * next = [GCStravaSegmentListStarred segmentListStarred:nil];
            next.page = self.page + 1;
            return next;
        }
    }
    return nil;
}

+(GCStravaSegmentListParser*)testParserWithFilesInPath:(NSString*)path{
    GCStravaSegmentListStarred * listSearch = [[[GCStravaSegmentListStarred alloc] init] autorelease];

    NSString * fn = [path stringByAppendingPathComponent:[listSearch segmentsListFileForPage:0]];

    NSData * info = [NSData dataWithContentsOfFile:fn];

    GCStravaSegmentListParser * parser = [[[GCStravaSegmentListParser alloc] initWithData:info] autorelease];
    return parser;
}

@end
