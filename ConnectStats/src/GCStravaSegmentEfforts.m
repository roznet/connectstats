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

#import "GCStravaSegmentEfforts.h"

@import RZExternal;
#import "GCAppGlobal.h"

@interface GCStravaSegmentEfforts ()
@property (nonatomic,assign) NSUInteger page;
@property (nonatomic,assign) NSUInteger parsedCount;
@property (nonatomic,assign) BOOL reachedExisting;
@property (nonatomic,retain) NSString * segmentId;
@property (nonatomic,retain) NSString * athleteId;

@end

@implementation GCStravaSegmentEfforts

+(GCStravaSegmentEfforts*)segmentEfforts:(UINavigationController*)nav for:(NSString*)segmentId and:(NSString*)athleteId{
    GCStravaSegmentEfforts * rv = [[[GCStravaSegmentEfforts alloc] init] autorelease];
    if (rv) {
        rv.navigationController = nav;
        rv.segmentId = segmentId;
        rv.athleteId = athleteId;
    }
    return rv;
}

-(void)dealloc{
    [_segmentId release];
    [_athleteId release];
    [super dealloc];
}

-(NSString*)urlToPrepare{
    return [NSString stringWithFormat:@"https://www.strava.com/api/v3/segments/%@/all_efforts?page=%d&athlete_id=%@",
    self.segmentId,(int)self.page+1,self.athleteId];;
}
-(NSString*)url{
    return nil;
}

-(NSDictionary*)postData{
    return nil;
}

-(NSString*)description{
    if (self.navigationController) {
        return NSLocalizedString(@"Login to strava", @"Strava Upload");
    }else{
        return NSLocalizedString(@"Downloading strava Segment", @"Strava Upload");
    }
}

-(void)process{
    if (self.navigationController) {
        [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(signInToStrava) withObject:nil waitUntilDone:NO];
    }else{
#if TARGET_IPHONE_SIMULATOR
        NSError * e = nil;
        NSString * fn = [NSString stringWithFormat:@"strava_segment_effort_%d.json", (int)self.page];
        [self.theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:self.encoding error:&e];
#endif
        dispatch_async([GCAppGlobal worker],^(){
            [self parse];
        });
    }
}

-(void)parse{
    self.reachedExisting = true;
    [self performSelectorOnMainThread:@selector(processDone) withObject:nil waitUntilDone:NO];

}

-(id<GCWebRequest>)nextReq{
    if (self.navigationController) {
        GCStravaSegmentEfforts * next = [GCStravaSegmentEfforts segmentEfforts:nil for:self.segmentId and:self.athleteId];

        return next;
    }else{
        if (self.parsedCount == 30 && !self.reachedExisting) {
            GCStravaSegmentEfforts * next = [GCStravaSegmentEfforts segmentEfforts:nil for:self.segmentId and:self.athleteId];

            next.page = self.page + 1;
            return next;
        }
    }
    return nil;
}

+(NSObject*)testParserWithFilesInPath:(NSString*)path forPage:(NSUInteger)page{

    NSString * fn = [NSString stringWithFormat:@"strava_segment_effort_%lu.json", (long unsigned)page];

    NSData * info = [NSData dataWithContentsOfFile:fn];
    /*GCStravaAthleteParser * parser = nil;
    if( info ){
        parser = [[[GCStravaAthleteParser alloc] initWithData:info] autorelease];
    }*/
    return info;
}



@end
