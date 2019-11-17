//  MIT Licence
//
//  Created on 25/08/2013.
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

#import "GCTestTracks.h"
#import "GCAppGlobal.h"
#import "GCActivitiesCacheManagement.h"
#import "GCActivitiesOrganizer.h"
#import "GCTrackStats.h"
#import "GCFields.h"
#import "GCTrackFieldChoices.h"


@implementation GCTestTracks

-(NSArray*)testDefinitions{
    return @[ @{TK_SEL:NSStringFromSelector(@selector(testTracks)),
                TK_DESC:@"Test breakdown of laps with highlightSerieForLap",
                TK_SESS:@"GC Tracks"}];
}

-(void)testTracks{
	[self startSession:@"GC Tracks"];

    [self loopThroughActivitiesdb];

	[self endSession:@"GC Tracks"];
}


-(void)loopThroughActivitiesdb{
    GCActivitiesCacheManagement * cache = [[[GCActivitiesCacheManagement alloc] init] autorelease];
    cache.useBundlePath = true;

    NSUInteger i = 0;

    NSUInteger countDb = 0;
    NSUInteger countTotalTracks = 0;

    for (NSString * filename in [cache fileNamesForType:gcCacheFileActivityDb]) {
        FMDatabase * db = [FMDatabase databaseWithPath:[RZFileOrganizer bundleFilePath:filename]];
        [db open];

        GCActivitiesOrganizer * organizer = [[GCActivitiesOrganizer alloc] initTestModeWithDb:db];

        countDb++;
        NSUInteger countTracks = 0;
        NSMutableArray * tracksAvailable = [NSMutableArray arrayWithCapacity:5];
        for (GCActivity * activity in organizer.activities) {
            i++;
            if (i%100==0) {
                NSLog(@"%@:%d", filename,(int)i);
            }
            NSString * trackfilename = [RZFileOrganizer bundleFilePath:[NSString stringWithFormat:@"track_%@.db",activity.activityId]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:trackfilename]) {
                FMDatabase * trackdb = [FMDatabase databaseWithPath:trackfilename];
                [trackdb open];
                [activity loadTrackPointsFromDb:trackdb];
                [trackdb close];
                [tracksAvailable addObject:activity];
                countTracks++;
                countTotalTracks++;
                if (countTotalTracks == 10) {
                    //DEBUG_BREAK();
                }
            }
        }
        //NSLog(@"%@:%d tracks", info.filename,(int)countTracks);
        for (GCActivity * activity in tracksAvailable) {
            [self runActivityTrackTest:activity];
        }


        [organizer release];
        [db close];
    }
    NSLog(@"total tracks: %d", (int)countTotalTracks);

}
-(void)runActivityTrackTest:(GCActivity*)activity{

    if ([[activity laps] count]>0 && [[activity trackpoints] count]>10 && ![[activity activityType] isEqualToString:GC_TYPE_SWIMMING]) {
        GCTrackStats * s = [[[GCTrackStats alloc] init] autorelease];
        [s setActivity:activity];
        GCTrackFieldChoices * choices = [GCTrackFieldChoices trackFieldChoicesWithActivity:activity];
        [choices setupTrackStats:s];
        [self assessTrue:[s.data count]>0 msg:@"Setup generated number"];
        if ([s.data count]==0) {
            DEBUG_BREAK();
        }

        NSUInteger all_n = [s.data count];
        NSUInteger laps_n = [[activity laps] count];
        for (NSUInteger i=0; i<[[activity laps] count]; i++) {
            [s setNeedsForRecalculate];
            s.highlightLap = true;
            s.highlightLapIndex = i;
            [choices setupTrackStats:s];
            GCStatsDataSerie * gserie = [activity highlightSerieForLap:s.highlightLapIndex timeAxis:!s.distanceAxis];

            laps_n += [[s.data filterForNonZeroIn:gserie] count];
        }
        [self assessTrue:abs((int)(all_n-laps_n))<5  msg:@"Reconstructed by %d laps %d==%d", (int)[[activity laps] count], (int)all_n,laps_n];
        if(abs((int)(all_n-laps_n))>5){
            DEBUG_BREAK();
        }

    }

}
@end
