//  MIT Licence
//
//  Created on 31/03/2014.
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

#import "GCSportTracksActivityDetail.h"
#import "GCAppGlobal.h"
#import "GCSportTracksActivityListParser.h"
#import "GCService.h"
#import "GCActivity+Import.h"
#import "GCSportTracksActivityDetailParser.h"
#import "GCActivitiesOrganizer.h"

@interface GCSportTracksActivityDetail ()
@property (nonatomic,retain) NSString*uri;
@end

@implementation GCSportTracksActivityDetail
-(void)dealloc{
    [_activityId release];
    [_uri release];

    [super dealloc];
}

+(GCSportTracksActivityDetail*)activityDetail:(UINavigationController*)nav forActivityId:(NSString*)aId andUri:(NSString*)aUri{

    GCSportTracksActivityDetail * rv = [[[GCSportTracksActivityDetail alloc] init] autorelease];
    if (rv) {
        rv.navigationController = nav;
        rv.uri = aUri;
        rv.activityId = aId;
    }
    return rv;
}

-(NSString*)url{
    if (self.navigationController) {
        return nil;
    }else{
        return self.uri;
    }
}

-(NSDictionary*)postData{
    return nil;
}

-(NSString*)description{
    if (self.navigationController) {
        return NSLocalizedString(@"Login to SportTracks", @"SportTracks download");
    }else{
        return NSLocalizedString(@"Downloading SportTracks Track", @"SportTracks Upload");
    }
}

-(void)process{
    if (self.navigationController) {
        [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self performSelector:@selector(signInToSportTracks) withObject:nil afterDelay:0.];
        });

    }else{
#if TARGET_IPHONE_SIMULATOR
        NSError * e = nil;

        NSString * fn = [NSString stringWithFormat:@"sporttracks_track_%@.json", [[GCService service:gcServiceSportTracks] serviceIdFromActivityId:self.activityId]];
        [self.theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:self.encoding error:&e];
#endif
        if (self.theString) {
            dispatch_async([GCAppGlobal worker],^(){
                [self parse];
            });
        }else{

            [self performSelectorOnMainThread:@selector(processDone) withObject:nil waitUntilDone:NO];
        }
    }
}

-(void)parse{

    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[self.theString dataUsingEncoding:self.encoding] options:NSJSONReadingMutableContainers error:nil];
    if (json) {

        id uri = json[@"uri"];
        if (uri) {
            NSString * activityId =  [GCService serviceIdFromSportTracksUri:uri];
            activityId = [[GCService service:gcServiceSportTracks] activityIdFromServiceId:activityId];

            GCActivity * act = [[GCActivity alloc] initWithId:activityId andSportTracksData:json];

            GCSportTracksActivityDetailParser * parser = [GCSportTracksActivityDetailParser activityDetailParser:json];

            [[GCAppGlobal organizer] registerActivity:activityId withTrackpoints:parser.points andLaps:nil];

            [act release];

        }else{
            RZLog(RZLogError, @"Missing key uri (%@)", json);
        }
    }

    [self performSelectorOnMainThread:@selector(processDone) withObject:nil waitUntilDone:NO];
}

-(id<GCWebRequest>)nextReq{
    if (self.navigationController) {
        GCSportTracksActivityDetail * next = [GCSportTracksActivityDetail activityDetail:nil forActivityId:_activityId andUri:_uri];
        next.sportTracksAuth = self.sportTracksAuth;
        return next;
    }else{
        return nil;
    }
    return nil;
}


@end
