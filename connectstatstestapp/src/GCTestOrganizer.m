//  MIT Licence
//
//  Created on 09/08/2014.
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

#import "GCTestOrganizer.h"
#import "GCAppGlobal.h"
#import "GCGarminRequestSearch.h"
#import "GCStravaActivityList.h"

#define STAGE_START 0
#define STAGE_END   1

@interface GCTestOrganizer ()
@property (nonatomic,assign) NSUInteger stage;

@end

@implementation GCTestOrganizer

-(NSArray*)testDefinitions{
    return @[@{TK_SEL: NSStringFromSelector(@selector(testOrganizerMerge)),
               TK_DESC:@"Test Merging Garmin/Strava",
               TK_SESS:@"GC Organizer Merge"}
             ];
}

-(void)testOrganizerMerge{
    [self startSession:@"GC Organizer Merge"];

    self.stage = 0;
    [self stageProcess:STAGE_START];


}

-(void)finishedOrganizer{
    [self endSession:@"GC Organizer Merge"];
}


-(void)processStrava:(NSString*)filename{
    NSError * e = nil;
    GCStravaActivityList * req = [[[GCStravaActivityList alloc] init] autorelease];
    NSString * firstStrava = [NSString stringWithContentsOfFile:[RZFileOrganizer bundleFilePath:filename] encoding:NSUTF8StringEncoding error:&e];
    [req process:firstStrava encoding:NSUTF8StringEncoding andDelegate:self];
}

-(void)processGarmin:(NSString*)filename{
    dispatch_async([GCAppGlobal worker],^(){
        [self processGarminAction:filename];
    });

}

-(void)processGarminAction:(NSString*)filename{
    NSError * e = nil;
    GCGarminSearch * req = [[[GCGarminSearch alloc] initWithStart:0 percent:0 andMode:false ] autorelease];
    NSString * firstGarmin = [NSString stringWithContentsOfFile:[RZFileOrganizer bundleFilePath:filename] encoding:NSUTF8StringEncoding error:&e];
    [req process:firstGarmin encoding:NSUTF8StringEncoding andDelegate:self];

}

-(NSUInteger)countDuplicate{
    NSArray * activities = [[GCAppGlobal organizer] activities];

    NSMutableDictionary * duplicates = [NSMutableDictionary dictionary];

    for (GCActivity * activity in activities) {
        NSString * duplicateId = [duplicates objectForKey:activity.activityId];
        // Check if found already else look
        if (!duplicateId) {
            GCActivity * other = [[GCAppGlobal organizer] findDuplicate:activity];
            if (other) {
                [duplicates setObject:other.activityId forKey:activity.activityId];
                [duplicates setObject:activity.activityId forKey:other.activityId];
            }
        }
    }
    return [duplicates count];
}

-(void)resetStateWithMerge:(BOOL)merge{
    [GCAppGlobal setupEmptyState:@"activities_org.db"];

    [GCAppGlobal configSet:CONFIG_MERGE_IMPORT_DUPLICATE boolVal:merge];

    [[GCAppGlobal profile] serviceEnabled:gcServiceGarmin set:YES];
    [[GCAppGlobal profile] serviceEnabled:gcServiceStrava set:YES];

    RZ_ASSERT([[GCAppGlobal organizer] countOfActivities] == 0, @"Start with 0 activities");

}

-(void)stageProcess:(NSUInteger)call{
    dispatch_async([GCAppGlobal worker],^(){
        [self runStageProcess:@(call)];
    });

}

-(void)runStageProcess:(NSNumber*)callN{
    NSUInteger call = [callN integerValue];

    if (self.stage == 0) { ///////// Load 20 activities from garmin
        if (call == STAGE_START) {
            [self resetStateWithMerge:false];
            [self processGarmin:@"last_search_0.json"];
        }else{
            RZ_ASSERT([[GCAppGlobal organizer] countOfActivities]==20, @"Added 20 garmin activities (found %d)",(int)[[GCAppGlobal organizer] countOfActivities] );
        }
    }else if (self.stage==1){
        if (call == STAGE_START) {
            [self processStrava:@"strava_list_0_merge.json"];
        }else{
            RZ_ASSERT([[GCAppGlobal organizer] countOfActivities]==50, @"Added 30 strava activities");
            NSUInteger dups = [self countDuplicate];
            RZ_ASSERT(dups == 42, @"Found expected 42 duplicates (%d found)", (int)dups);
        }
    }else if (self.stage==2){
        if (call == STAGE_START) {
            [self resetStateWithMerge:false];
            RZ_ASSERT([[GCAppGlobal organizer] countOfActivities] == 0, @"Start with 0 activities");
            [self processStrava:@"strava_list_0_merge.json"];
        }else{
            RZ_ASSERT([[GCAppGlobal organizer] countOfActivities]==30, @"Added 30 strava activities (found %d)",(int)[[GCAppGlobal organizer] countOfActivities]);
        }
    }else if (self.stage == 3){
        if (call == STAGE_START) {
            [self processGarmin:@"last_search_0.json"];
        }else{
            RZ_ASSERT([[GCAppGlobal organizer] countOfActivities]==50, @"Added 20 garmin activities (found %d)", (int)[[GCAppGlobal organizer] countOfActivities]);
            NSUInteger dups = [self countDuplicate];
            RZ_ASSERT(dups == 42, @"Found 42 expected duplicates (found %d)", (int)dups);
        }
    }else if (self.stage == 4){
        if (call == STAGE_START) {
            [self resetStateWithMerge:true];
            [self processGarmin:@"last_search_0.json"];
        }else{
            RZ_ASSERT([[GCAppGlobal organizer] countOfActivities]==20, @"Added 20 garmin activities (found %d)", (int)[[GCAppGlobal organizer] countOfActivities]);
        }
    }else if (self.stage == 5){
        if (call == STAGE_START) {
            [self processStrava:@"strava_list_0_merge.json"];
        }else{
            RZ_ASSERT([[GCAppGlobal organizer] countOfActivities]==28, @"Added 30 merged strava activities (found %d)", (int)[[GCAppGlobal organizer] countOfActivities]);
            NSUInteger dups = [self countDuplicate];
            RZ_ASSERT(dups == 0, @"Found expected 0 duplicates (found %d)", (int)dups);
        }
    }

    if (call == STAGE_END) {
        self.stage++;
        if (self.stage == 6) {
            [self finishedOrganizer];
        }else{
            [self stageProcess:STAGE_START];
        }
    }
}

-(void)stageEnd{

}

#pragma mark - GCWebRequest

-(void)processDone:(id)req{
    [self stageProcess:STAGE_END];
}


-(NSInteger)lastStatusCode{
    return 0;
}

-(void)loginSuccess:(gcWebService)service{

}
-(void)requireLogin:(gcWebService)service{
}
-(void)processNewStage{

}


@end
