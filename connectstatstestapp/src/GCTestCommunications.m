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
#import <CommonCrypto/CommonDigest.h>
#import "GCWebConnect+Requests.h"
#import "GCActivity+Database.h"
#import "GCActivity+Import.h"
#import "GCTestAppGlobal.h"


typedef NS_ENUM(NSUInteger, gcTestInstance){
    gcTestInstanceCommunication,
    gcTestInstanceNewStyleAccount,
    gcTestInstanceModernHistory
};

@interface GCTestCommunications ()
@property (nonatomic,assign) NSUInteger nCb;
@property (nonatomic,assign) NSUInteger nReq;
@property (nonatomic,retain) NSMutableArray<NSString*>*reqDescriptions;
@property (nonatomic,assign) BOOL completed;
@property (nonatomic,retain) RZRemoteDownload * remoteDownload;
@property (nonatomic,retain) NSString * currentSession;
@property (nonatomic,assign) gcTestInstance testInstance;
@property (nonatomic,retain) NSMutableDictionary*cache;
@property (nonatomic,assign) NSUInteger expectedModernActivitiesCount;
@property (nonatomic,retain) RZRegressionManager * manager;
@property (nonatomic,retain) NSSet * classes;

@end

@implementation GCTestCommunications

-(void)dealloc{
    [_cache release];
    [_remoteDownload release];
    [_currentSession release];
    [_reqDescriptions release];
    [_manager release];
    [_classes release];
    [super dealloc];
}

-(NSArray*)testDefinitions{
    return @[ @{@"selector": NSStringFromSelector(@selector(testModernHistory)),
                @"description": @"test modern API with roznet simulator",
                @"session": @"GC Com Modern"
                },
            
              @{@"selector": NSStringFromSelector(@selector(testUpload)),
                @"description": @"test upload with roznet simulator",
                @"session": @"GC Com Upload"
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

-(void)downloadStringSuccessful:(id)connection string:(NSString*)theString{
    NSError * e = nil;
    [theString writeToFile:[RZFileOrganizer writeableFilePath:@"upload.txt"] atomically:YES encoding:NSUTF8StringEncoding error:&e];
    NSData * filedata = [NSData dataWithContentsOfFile:[RZFileOrganizer bundleFilePath:@"cycling.png"]];

    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256( filedata.bytes, (CC_LONG)filedata.length, result );

    NSMutableString *expected = [NSMutableString stringWithString:@"success:"];
    for (int i=0; i < CC_SHA256_DIGEST_LENGTH; i++) {
      [expected appendFormat:@"%02x", result[i]];
    }
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
    if( _testInstance == gcTestInstanceModernHistory){
        [GCTestAppGlobal setupEmptyState:@"activities_comm_modern.db"];
        [[GCAppGlobal profile] configSet:CONFIG_GARMIN_USE_MODERN boolVal:YES];
        GCWebSetSimulatorDir(@"samples_fullmodern");
    }else{
        [GCTestAppGlobal setupEmptyState:@"activities_comm.db"];
        [[GCAppGlobal profile] configSet:CONFIG_GARMIN_USE_MODERN boolVal:NO];
        GCWebSetSimulatorDir(nil);
    }
    [[GCAppGlobal profile] configSet:CONFIG_ENABLE_DERIVED boolVal:NO];
    [[GCAppGlobal profile] configSet:CONFIG_WIFI_DOWNLOAD_DETAILS boolVal:NO];
    [GCAppGlobal configSet:CONFIG_GARMIN_FIT_DOWNLOAD boolVal:FALSE];
    [[GCAppGlobal profile] configGetInt:CONFIG_GARMIN_LOGIN_METHOD defaultValue:gcGarminLoginMethodSimulator];
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
    if( [[theInfo stringInfo] isEqualToString:NOTIFY_NEXT]){
        self.nReq++;
        NSString * desc = [theParent currentDebugDescription];
        if( [GCAppGlobal simulatorUrl]) {
            desc = [desc stringByReplacingOccurrencesOfString:[GCAppGlobal simulatorUrl] withString:@""];
        }
        [self.reqDescriptions addObject:desc];
    }
    RZ_ASSERT(![[theInfo stringInfo] isEqualToString:@"error"], @"Web request had no error");
    if ([[theInfo stringInfo] isEqualToString:@"end"]) {
        _nCb++;
        dispatch_async(self.thread,^(){
            switch (_testInstance) {
                case gcTestInstanceCommunication:
                case gcTestInstanceNewStyleAccount:
                    // obsolete
                    break;
                case gcTestInstanceModernHistory:
                    if (_nCb == 1){
                        [self testModernHistoryInitialDone];
                    }else if( _nCb == 2 ){
                        [self testModernHistoryTrackLoaded];
                    }else if( _nCb == 3 ){
                        [self testModernHistoryReloadFirst10];
                    }else if( _nCb == 4 ){
                        [self testModernHistoryReloadNothing];
                    }else if( _nCb == 5 ){
                        [self testModernHistoryReloadAll];
                    }else if( _nCb == 6){
                        [self testModernDeletedAndRenamed];
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
    
    [self testCommunicationStart:@"GC Com Modern" userName:@"simulator"];
    self.nReq = 0;
    self.reqDescriptions = [NSMutableArray array];
    
    self.manager = [RZRegressionManager managerForTestClass:[self class]];
    //self.manager.recordMode = true;
    self.classes = [NSSet setWithObjects:[NSArray class], [NSString class], nil];
    
    [[GCAppGlobal web] servicesSearchRecentActivities];
}

-(void)validateReqForBatch:(NSString*)name{
    NSArray * expected = [self.manager retrieveReferenceObject:self.reqDescriptions forClasses:self.classes selector:_cmd identifier:name error:nil];
    RZ_ASSERT([expected isEqualToArray:self.reqDescriptions], @"Have Expected Reqs %@", name);
    if( ! [expected isEqualToArray:self.reqDescriptions] ){
        NSLog(@"Count %@ %@", @(self.reqDescriptions.count), @(expected.count) );
        for( NSUInteger i=0;i<MIN(self.reqDescriptions.count,expected.count);i++){
            if( ![self.reqDescriptions[i] isEqualToString:expected[i]] ){
                NSLog(@"First Diff[%@] %@ %@", @(i), self.reqDescriptions[i], expected[i] );
                break;
            }
        }
    }
    [self.reqDescriptions removeAllObjects];
}

-(void)testModernHistoryInitialDone{
    self.expectedModernActivitiesCount = 2971;
    RZ_ASSERT([[GCAppGlobal organizer] countOfActivities] == self.expectedModernActivitiesCount , @"Loading %d activities (got %d)", (int)self.expectedModernActivitiesCount, (int)[[GCAppGlobal organizer] countOfActivities]);
    
    [self validateReqForBatch:NSStringFromSelector(_cmd)];
    
    self.cache = [NSMutableDictionary dictionary];
    
    for( NSUInteger i=0;i< 10; i++){
        GCActivity * act = [[GCAppGlobal organizer] activityForIndex:i];
        self.cache[act.activityId] = [NSDictionary dictionaryWithDictionary:act.summaryData];
        // Force load of points
        [act clearTrackdb];
        RZ_ASSERT(act.trackpoints.count == 0, @"%@ start with 0 points", act);
    }
}

-(void)testModernHistoryTrackLoaded{
    [self validateReqForBatch:NSStringFromSelector(_cmd)];

    for( NSUInteger i=0;i< 10; i++){
        GCActivity * act = [[GCAppGlobal organizer] activityForIndex:i];
        NSDictionary * prev = self.cache[act.activityId];
        RZ_ASSERT(prev.count <= act.summaryData.count, @"Not less data");
        for (GCField * field in prev) {
            GCActivitySummaryValue * prevVal = prev[field];
            GCActivitySummaryValue * newVal  = act.summaryData[field];
            RZ_ASSERT(newVal != nil, @"%@ still has %@", act, field);
            if( newVal ){
                RZ_ASSERT([prevVal isEqualToValue:newVal], @"%@ == %@ for %@", prevVal, newVal, act);
            }
        }
        // Force load of points
        RZ_ASSERT(act.trackpoints.count > 0, @"%@ loaded %lu points", act, (unsigned long)act.trackpoints.count);
        [act clearTrackdb]; //prep for delete coming
    }

    [[GCAppGlobal organizer] deleteActivityUpToIndex:10];
    RZ_ASSERT([[GCAppGlobal organizer] countOfActivities] == self.expectedModernActivitiesCount-11, @"deleted 10 activities %d", [[GCAppGlobal organizer] countOfActivities] );
    
    [[GCAppGlobal web] servicesSearchRecentActivities];
}

-(void)testModernHistoryReloadFirst10{
    RZ_ASSERT([[GCAppGlobal organizer] countOfActivities] == self.expectedModernActivitiesCount , @"Loading %d activities (got %d)", (int)self.expectedModernActivitiesCount, (int)[[GCAppGlobal organizer] countOfActivities]);
    [self validateReqForBatch:NSStringFromSelector(_cmd)];

    [[GCAppGlobal organizer] deleteActivityFromIndex:2000];
    RZ_ASSERT([[GCAppGlobal organizer] countOfActivities] == 2000, @"deleted tail activities");

    [[GCAppGlobal web] servicesSearchRecentActivities];
}

-(void)testModernHistoryReloadNothing{
    RZ_ASSERT([[GCAppGlobal organizer] countOfActivities] == 2000 , @"Loading 2000 activities (got %d)", (int)[[GCAppGlobal organizer] countOfActivities]);
    [self validateReqForBatch:NSStringFromSelector(_cmd)];
    
    [[GCAppGlobal web] servicesSearchAllActivities];
}

-(void)testModernHistoryReloadAll{
    RZ_ASSERT([[GCAppGlobal organizer] countOfActivities] == self.expectedModernActivitiesCount , @"Loading %d activities (got %d)",(int)self.expectedModernActivitiesCount, (int)[[GCAppGlobal organizer] countOfActivities]);
    [self validateReqForBatch:NSStringFromSelector(_cmd)];
    
    //2655997046 -> deleted
    //2654853600 -> renamed
    
    RZ_ASSERT([[GCAppGlobal organizer] activityForId:@"2655997046"] != nil, @"Activity to be deleted exists");
    
    GCActivity * to_be_edited = [[GCAppGlobal organizer] activityForId:@"2654853600"];
    GCNumberWithUnit * distance = [to_be_edited numberWithUnitForField:[GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:to_be_edited.activityType]];
    GCNumberWithUnit * duration = [to_be_edited numberWithUnitForField:[GCField fieldForFlag:gcFieldFlagSumDuration andActivityType:to_be_edited.activityType]];
    RZ_ASSERT(![distance isEqualToNumberWithUnit:[GCNumberWithUnit numberWithUnitName:@"meter" andValue:10000.0]], @"Start different from 10000m" );
    RZ_ASSERT(![duration isEqualToNumberWithUnit:[GCNumberWithUnit numberWithUnitName:@"second" andValue:2160.0]], @"Start different than 2160sec");
    
    GCWebSetSimulatorState(@"deleted");
    [[GCAppGlobal web] servicesSearchRecentActivities];
}

-(void)testModernDeletedAndRenamed{
    RZ_ASSERT([[GCAppGlobal organizer] activityForId:@"2655997046"] == nil, @"Activity to be deleted is gone");
    
    GCActivity * edited = [[GCAppGlobal organizer] activityForId:@"2654853600"];
    RZ_ASSERT([edited.activityName isEqualToString:@"New Name"], @"Activity was renamed");
    GCNumberWithUnit * distance = [edited numberWithUnitForField:[GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:edited.activityType]];
    GCNumberWithUnit * duration = [edited numberWithUnitForField:[GCField fieldForFlag:gcFieldFlagSumDuration andActivityType:edited.activityType]];
    RZ_ASSERT([distance isEqualToNumberWithUnit:[GCNumberWithUnit numberWithUnitName:@"meter" andValue:10000.0]], @"Start different from 10000m" );
    RZ_ASSERT([duration isEqualToNumberWithUnit:[GCNumberWithUnit numberWithUnitName:@"second" andValue:2160.0]], @"Start different than 2160sec");

    // End manually
    [self notifyCallBack:self info:[RZDependencyInfo rzDependencyInfoWithString:@"end"]];

}


@end
