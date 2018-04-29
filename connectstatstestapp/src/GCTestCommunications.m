//  MIT Licence
//
//  Created on 15/09/2012.
//
//  Copyright (c) 2012 Brice Rosenzweig.
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

#import "GCTestCommunications.h"
#import "GCAppGlobal.h"
#import "GCWebUrl.h"
#import "GCGarminActivityXMLParser.h"
#import <CommonCrypto/CommonDigest.h>
#import "GCWebConnect+Requests.h"
#import "GCActivity+Database.h"
#import "GCActivity+Import.h"


typedef NS_ENUM(NSUInteger, gcTestInstance){
    gcTestInstanceCommunication,
    gcTestInstanceNewStyleAccount,
    gcTestInstanceModernHistory
};

@interface GCTestCommunications ()
@property (nonatomic,assign) NSUInteger nCb;
@property (nonatomic,assign) BOOL completed;
@property (nonatomic,retain) RZRemoteDownload * remoteDownload;
@property (nonatomic,retain) NSString * currentSession;
@property (nonatomic,assign) gcTestInstance testInstance;

@end

@implementation GCTestCommunications

-(void)dealloc{
    [_remoteDownload release];
    [_currentSession release];
    [super dealloc];
}

-(NSArray*)testDefinitions{
    return @[ @{@"selector" : NSStringFromSelector(@selector(testNewStyleAccount)),
                @"description": @"Test New Style Account",
                @"session": @"GC Com New Style"
                },
              @{@"selector": NSStringFromSelector(@selector(testOriginalAccount)),
                @"description": @"test download/communication with roznet simulator",
                @"session": @"GC Communication" // The session called in endAllTests
                },
              @{@"selector": NSStringFromSelector(@selector(testUpload)),
                @"description": @"test upload with roznet simulator",
                @"session": @"GC Com Upload"
                },
              @{@"selector": NSStringFromSelector(@selector(testModernHistory)),
                @"description": @"test modern API with roznet simulator",
                @"session": @"GC Com Modern"
                },

              ];
}



#pragma mark - Upload Test

-(void)testUpload{
    self.currentSession = @"GC Com Upload";
    [self startSession:self.currentSession];

    NSDictionary * postdata = [NSDictionary dictionaryWithObjectsAndKeys:@"value1", @"key1", @"value2", @"key2", nil];
    NSData * filedata = [NSData dataWithContentsOfFile:[RZFileOrganizer bundleFilePath:@"cycling.png"]];
    NSString * url = [NSString stringWithFormat:@"%@/connectstats/upload.php?dir=tests", [GCAppGlobal simulatorUrl]];
    [self setRemoteDownload:[[[RZRemoteDownload alloc] initWithURL:url
                                                        postData:postdata
                                                        fileName:@"cycling.png"
                                                        fileData:filedata andDelegate:self] autorelease]];
}

-(void)testUploadEnd{
    [self endSession:self.currentSession];
}

-(void)downloadFailed:(id)connection{
    RZ_ASSERT(false, @"Upload failed");
    [self testUploadEnd];
}

-(void)downloadArraySuccessful:(id)connection array:(NSArray*)theArray{
    RZ_ASSERT(false, @"Upload failed");
    [self testUploadEnd];
}
-(void)downloadStringSuccessful:(id)connection string:(NSString*)theString{
    NSError * e = nil;
    [theString writeToFile:[RZFileOrganizer writeableFilePath:@"upload.txt"] atomically:YES encoding:NSUTF8StringEncoding error:&e];
    NSData * filedata = [NSData dataWithContentsOfFile:[RZFileOrganizer bundleFilePath:@"cycling.png"]];

    unsigned char result[16];
    CC_MD5( filedata.bytes, (CC_LONG)filedata.length, result );
    NSString * expected = [NSString stringWithFormat:
            @"success:%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];

    NSRange range = [theString rangeOfString:@"success:"];
    NSString * successString = @"";
    if (range.location != NSNotFound) {
        successString = [theString substringFromIndex:range.location];
    }
    if( ! [expected isEqualToString:successString]){
        [self log:@"Upload msg: %@", theString];
    }
    RZ_ASSERT([expected isEqualToString:successString], @"Uploaded file success %@", [theString hasPrefix:@"error:"] ? theString : @"");
    [self testUploadEnd];
}

#pragma mark - Communication Sequence

-(void)testCommunicationStart:(NSString*)sessionName userName:(NSString*)username{
    self.currentSession = sessionName;
    
    [self startSession:self.currentSession];
    GCWebUseSimulator(TRUE, [GCAppGlobal simulatorUrl]);
    GCWebSetSimulatorState(@"");

    _nCb = 0;
    _completed = false;
    [GCAppGlobal setupEmptyState:@"activities_comm.db"];
    [GCAppGlobal configSet:CONFIG_WIFI_DOWNLOAD_DETAILS boolVal:NO];
    [GCAppGlobal configSet:CONFIG_GARMIN_FIT_DOWNLOAD boolVal:FALSE];
    [[GCAppGlobal profile] configSet:CONFIG_GARMIN_USE_MODERN boolVal:NO];
    [[GCAppGlobal profile] configGetInt:CONFIG_GARMIN_LOGIN_METHOD defaultValue:gcGarminLoginMethodLegacy];
    [[GCAppGlobal profile] configSet:CONFIG_GARMIN_ENABLE boolVal:YES];
    [[GCAppGlobal profile] setLoginName:username forService:gcServiceGarmin];
    [[GCAppGlobal profile] setPassword:@"iamatesterfromapple" forService:gcServiceGarmin];
    

    [self assessTestResult:@"Start with 0" result:[[GCAppGlobal organizer] countOfActivities] == 0 ];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self timeOutCheck];
    });
    [[GCAppGlobal web] attach:self];

}

-(void)testCommunicationEnd{
    _completed = true;
    [[GCAppGlobal web] detach:self];
    [GCAppGlobal configSet:CONFIG_GARMIN_FIT_DOWNLOAD boolVal:TRUE];
    [self endSession:self.currentSession];
}


-(void)timeOutCheck{
#if TARGET_IPHONE_SIMULATOR
    RZ_ASSERT(_completed, @"Time out before completion");
    [self testCommunicationEnd];
#endif
}

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    if( [[theInfo stringInfo] isEqualToString:@"error"]){
        NSLog(@"oops");
    }
    RZ_ASSERT(![[theInfo stringInfo] isEqualToString:@"error"], @"Web request had no error");
    if ([[theInfo stringInfo] isEqualToString:@"end"]) {
        _nCb++;
        //NSLog(@"^cb %lu %@ tot=%lu", _nCb,[theInfo stringInfo],[[GCAppGlobal organizer] countOfActivities]);
        dispatch_async(self.thread,^(){
            switch (_testInstance) {
                case gcTestInstanceCommunication:
                    if (_nCb == 1) {
                        [self testInitialLoadDone];
                    }else if (_nCb == 2) {
                        [self testRecentLoadDone];
                    }else if (_nCb == 3) {
                        [self testChangeDone];
                    }else if (_nCb == 4) {
                        [self testDeletedDone];
                    }else{
                        [self testCommunicationEnd];
                    }

                    break;

                case gcTestInstanceNewStyleAccount:
                    if (_nCb == 1) {
                        [self testNewStyleInitialLoadDone];
                    }else if (_nCb ==2){
                        [self testNewStrylePointsLoaded];
                    }else{
                        [self testCommunicationEnd];
                    }
            }

        });

    }else if([[theInfo stringInfo] isEqualToString:@"error"]){
        [self testCommunicationEnd];
    }
}

#pragma mark - Modern History Communication test

-(void)testModernHistory{
    _testInstance = gcTestInstanceModernHistory;
    
    [self testCommunicationStart:@"GC Communication" userName:@"simulator"];
    
    [[GCAppGlobal web] servicesSearchActivitiesFrom:20 reloadAll:true];
}


#pragma mark - Original Communication test sequence

-(void)testOriginalAccount{
    [self testCommunicationStart:@"GC Communication" userName:@"simulator"];
    _testInstance = gcTestInstanceCommunication;

    [[GCAppGlobal web] servicesSearchActivitiesFrom:20 reloadAll:true];
}

-(void)testInitialLoadDone{
    RZ_ASSERT([[GCAppGlobal organizer] countOfActivities] == 468 , @"Loading 468 activities (got %d)", (int)[[GCAppGlobal organizer] countOfActivities]);
    GCActivity * act = nil;
    //NSLog(@"cb initial tot=%d curr=%@ type=%@", [[GCAppGlobal organizer] countOfActivities],[act activityId], [act activityType]);
    act = [[GCAppGlobal organizer] activityForId:@"219881327"];
    RZ_ASSERT(act==nil, @"missing recent");
    [[GCAppGlobal web] servicesSearchRecentActivities];
}

-(void)testRecentLoadDone{
    RZ_ASSERT([[GCAppGlobal organizer] countOfActivities] == 488 , @"Loading 488 activities (got %d)", (int)[[GCAppGlobal organizer] countOfActivities]);
    GCActivity * act = [[GCAppGlobal organizer] activityForId:@"219881327"];
    //NSLog(@"cb recent tot=%d curr=%@ type=%@", [[GCAppGlobal organizer] countOfActivities],[act activityId], [act activityType]);
    RZ_ASSERT([[act activityType] isEqualToString:GC_TYPE_RUNNING], @"found recent after second search");
    // will save/load from db so need to be on worker thread to avoid db conflict.
    dispatch_async(self.thread,^(){
        [self testSaveReloadMatch];
    });
}

-(void)testSaveReloadMatch{
    GCActivity * act = nil;//[[GCAppGlobal organizer] activityForId:@"219881327"];

    for (NSUInteger i=0; i<20; i++) {
        act = [[GCAppGlobal organizer] activityForIndex:i];
        GCActivity * recovered = [GCActivity activityWithId:act.activityId andDb:act.db];
        RZ_ASSERT([recovered isEqualToActivity:act], @"%@[%d] save/reload match", act, (int)i);
    }

    dispatch_async(self.thread,^(){
        [self testParsing];
    });

}

-(void)testChange{
    _completed = false;
    GCActivity * act = [[GCAppGlobal organizer] activityForId:@"222319267"];
    [self assessTestResult:@"starts untitled" result:[[act activityName] isEqualToString:@"Untitled"]];
    [self assessTestResult:@"starts cycling" result:[[act activityType] isEqualToString:GC_TYPE_CYCLING]];

    GCWebSetSimulatorState(@"renamed");
    [[GCAppGlobal web] servicesSearchRecentActivities];
}

-(void)testChangeDone{

    RZ_ASSERT([[GCAppGlobal organizer] countOfActivities] == 488 , @"Loading 488 activities (got %d)", (int)[[GCAppGlobal organizer] countOfActivities]);

    GCActivity * act = [[GCAppGlobal organizer] activityForId:@"222319267"];
    [self assessTestResult:@"Changed name to New Name" result:[[act activityName] isEqualToString:@"New Name"]];
    [self assessTestResult:@"Changed type to running" result:[[act activityType] isEqualToString:GC_TYPE_RUNNING]];
    [self assessTestResult:@"activities exists before delete" result:act!=nil];

    act = [[GCAppGlobal organizer] activityForId:@"222319243"];
    [self assessTestResult:@"activities exists before delete" result:act!=nil];

    GCWebSetSimulatorState(@"deleted");
    [[GCAppGlobal web] servicesSearchRecentActivities];
}

-(void)testDeletedDone{
    RZ_ASSERT([[GCAppGlobal organizer] countOfActivities] == 486 , @"Loading 486 activities (got %d)", (int)[[GCAppGlobal organizer] countOfActivities]);

    GCActivity * act = [[GCAppGlobal organizer] activityForId:@"222319267"];
    [self assessTestResult:@"activities deleted" result:act==nil];
    act = [[GCAppGlobal organizer] activityForId:@"222319243"];
    [self assessTestResult:@"activities deleted" result:act==nil];

    GCWebSetSimulatorState(@"");

    // Manually go to next stage, as no web communication here
    [self notifyCallBack:self info:[RZDependencyInfo rzDependencyInfoWithString:@"end"]];
}

#pragma mark - other tests

-(BOOL)skipField:(NSString*)field{
    return [GCFields skipField:field] || [field hasSuffix:@"Latitude"] || [field hasSuffix:@"Longitude"] || [field isEqualToString:@"SumStrokes"]
        || [field isEqualToString:@"SumPoolLength"] || [field isEqualToString:@"SumStep"];
}

-(void)testParsing{
    [self testOrganizerVsExpected];

    [self testChange];
}

-(NSString*)cleanUpExpected:(NSString*)start{
    NSString * expectedVal = start;
    // cleanup unpleasant format from expected:
    //
    if ([expectedVal hasSuffix:@" h:m:s"]) {
        expectedVal = [expectedVal substringToIndex:[expectedVal length]-6];
        if ([expectedVal hasPrefix:@"00:"]) {
            expectedVal = [expectedVal substringFromIndex:3];
        }
    }
    if ([expectedVal hasSuffix:@" "]) {
        expectedVal = [expectedVal substringToIndex:[expectedVal length]-1];
    }
    return expectedVal;
}

-(void)testOrganizerVsExpected{
    // Compare what was downloaded to what was saved as expected

    NSData * jsonData = [NSData dataWithContentsOfFile:[RZFileOrganizer bundleFilePath:@"expected.json"]];
    NSError * e = nil;
    NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];

    NSArray * activities = [[json objectForKey:@"results"] objectForKey:@"activities"];

    for (NSDictionary * one in activities) {
        NSDictionary * expected = [one objectForKey:@"activity"];
        NSString * activityId = [[expected objectForKey:@"activityId"] stringValue];
        GCActivity * activity = [[GCAppGlobal organizer] activityForId:activityId];
        RZ_ASSERT(activity != nil, @"activity Exists");
        NSDictionary * summary = [expected objectForKey:@"activitySummary"];

        gcFieldFlag gcFields[4] = {gcFieldFlagSumDistance,gcFieldFlagSumDuration,gcFieldFlagWeightedMeanHeartRate,gcFieldFlagWeightedMeanSpeed};
        NSString * valExpected = nil;
        NSString * val = nil;

        for (size_t i = 0; i<3; i++) {
            //NSString * field2 = [GCFields fieldForFlag:gcFields[i] andActivityType:[activity activityType]];
            GCField * field = [GCField fieldForFlag:gcFields[i] andActivityType:activity.activityType];
            if ([activity hasField:field]) {
                NSDictionary * info = [summary objectForKey:field.key];

                valExpected = [info objectForKey:@"fieldDisplayName"];
                val = field.displayName;

                RZ_ASSERT([val isEqualToString:valExpected], @"%@[%@] %@=%@", activityId,field,val,valExpected);

                valExpected = [self cleanUpExpected:[info objectForKey:@"withUnitAbbr"]];
                val = [activity formattedValue:field];

                RZ_ASSERT([val isEqualToString:valExpected], @"%@[%@] %@=%@", activityId,field,val,valExpected);

            }else{
                [self assessTestResult:[NSString stringWithFormat:@"%@ no %@",activityId,field] result:[summary objectForKey:field]==nil];
            }
        }

        for (NSString * fieldkey in summary) {
            if (![self skipField:fieldkey ]) {
                NSDictionary * info = [summary objectForKey:fieldkey];
                GCField * field = [GCField fieldForKey:fieldkey andActivityType:activity.activityType];

                valExpected = [info objectForKey:@"fieldDisplayName"];
                val = field.displayName;

                RZ_ASSERT([val isEqualToString:valExpected], @"%@[%@] %@=%@", activityId,field,val,valExpected);

                valExpected = [self cleanUpExpected:[info objectForKey:@"withUnitAbbr"]];
                val = [activity formattedValue:field];

                RZ_ASSERT([val isEqualToString:valExpected], @"%@[%@] %@=%@", activityId,field,val,valExpected);
            }
        }
    }
}

#pragma mark - Test Account Test

-(void)testNewStyleAccount{
    [self testCommunicationStart:@"GC Com New Style" userName:@"testaccount"];
    _testInstance = gcTestInstanceNewStyleAccount;

    [[GCAppGlobal web] servicesSearchActivitiesFrom:0 reloadAll:true];
}
-(void)testNewStyleInitialLoadDone{
    RZ_ASSERT([[GCAppGlobal organizer] countOfActivities] == 31 , @"Loading 31 activities");

    // Manually go to next stage, as no web communication here
    //[self notifyCallBack:self info:[RZDependencyInfo rzDependencyInfoWithString:@"end"]];
    [self testNewStyleTrackLoading];
}

-(NSArray<NSString*>*)validIdForNewStyle{
    static NSArray * rv = nil;
    if( rv == nil){
        rv = @[
               @"272316713",
               @"272334466",
               @"291906167",
               @"291906345",
               @"400587162",
               @"479063522",
               @"686445081",
               @"686445085",
               @"686445087",
               @"686445091",
               @"686445092",
               @"924421177",
               ];
        [rv retain];
    }
    return rv;

}

-(void)testNewStyleTrackLoading{
    NSArray<NSString*> * actIds = [self validIdForNewStyle];
    // Request in parallel on different thread activities points and make sure it works...
    GCActivity * act = [[GCAppGlobal organizer] activityForId:actIds[0]];
    NSArray<GCTrackPoint*>*points = [act trackpoints];
    RZ_ASSERT(points.count == 0, @"Start without points %@", actIds[0]);

    dispatch_async([GCAppGlobal worker], ^(){
        GCActivity * act = [[GCAppGlobal organizer] activityForId:actIds[1]];
        NSArray<GCTrackPoint*>*points = [act trackpoints];
        RZ_ASSERT(points.count==0, @"Start without points %@", actIds[1]);
    });

    dispatch_async([GCAppGlobal worker], ^(){
        GCActivity * act = [[GCAppGlobal organizer] activityForId:actIds[2]];
        NSArray<GCTrackPoint*>*points = [act trackpoints];
        RZ_ASSERT(points.count==0, @"Start without points %@", actIds[2]);

    });
}

-(void)testNewStrylePointsLoaded{
    NSArray<NSString*> * actIds = [self validIdForNewStyle];
    for(NSUInteger i=0;i<3;i++){
        GCActivity * act = [[GCAppGlobal organizer] activityForId:actIds[i]];
        NSArray<GCTrackPoint*>*points = [act trackpoints];
        RZ_ASSERT(points.count > 0, @"Ends with points %@", actIds[i]);
    }

    // Manually go to next stage, as no web communication here
    [self notifyCallBack:self info:[RZDependencyInfo rzDependencyInfoWithString:@"end"]];

}

@end
