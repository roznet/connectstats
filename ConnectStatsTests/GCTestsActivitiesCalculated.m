//  MIT License
//
//  Created on 23/03/2020 for ConnectStatsXCTests
//
//  Copyright (c) 2020 Brice Rosenzweig
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



#import "GCTestCase.h"
#import "GCTrackPoint.h"
#import "GCActivity+Database.h"
#import "GCActivity+Import.h"
#import "GCAppGlobal.h"
#import "GCActivityTypes.h"
#import "ConnectStats-Swift.h"
#import "GCActivity+ExportText.h"
#import "GCActivity+TestBackwardCompat.h"
#import "GCActivity+TrackTransform.h"
#import "GCCalculatedCachedTrackInfo.h"
#import "GCActivity+BestRolling.h"

@interface GCTestsActivitiesCalculated : GCTestCase

@end

@implementation GCTestsActivitiesCalculated

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

-(void)testParseFitAndEvents{
    NSString * db_name = @"test_activity_fit_event.db";
    
    [RZFileOrganizer removeEditableFile:db_name];
    
    FMDatabase * db = [FMDatabase databaseWithPath:[RZFileOrganizer writeableFilePath:db_name]];
    [db open];
    [GCActivitiesOrganizer ensureDbStructure:db];
    
    NSString * fp = [RZFileOrganizer bundleFilePath:@"track_cs_544406.fit" forClass:[self class]];
    GCActivity * fitAct = RZReturnAutorelease([[GCActivity alloc] initWithId:@"DummyTestId" fitFilePath:fp startTime:nil]);
    
    [fitAct fullSaveToDb:db];

    GCActivity * reload = [GCActivity activityWithId:@"544406b" andDb:db];
    [reload trackpoints];
    
    NSUInteger events = 0;
    XCTAssertEqual(reload.trackpoints.count, fitAct.trackpoints.count);
    for (NSUInteger i=0; i<MIN(reload.trackpoints.count, fitAct.trackpoints.count); i++) {
        XCTAssertEqual([reload.trackpoints[i] trackEventType], [fitAct.trackpoints[i] trackEventType]);
        if( [reload.trackpoints[i] trackEventType] != gcTrackEventTypeNone){
            events+=1;
        }
    }
    XCTAssertGreaterThan(events, 0);
    
    NSString * raw = [fitAct csvTrackPoints:fitAct.trackpoints];
    NSString * noStop = [fitAct csvTrackPoints:[fitAct removedStoppedTimer:fitAct.trackpoints]];
    
    [raw writeToFile:[RZFileOrganizer writeableFilePath:@"tp_raw.csv"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [noStop writeToFile:[RZFileOrganizer writeableFilePath:@"tp_noStop.csv"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    GCField * speed = [GCField fieldForFlag:gcFieldFlagWeightedMeanSpeed andActivityType:fitAct.activityType];
    GCCalculactedCachedTrackInfo * info = [GCCalculactedCachedTrackInfo info:gcCalculatedCachedTrackRollingBest field:speed];
    GCStatsDataSerieWithUnit * serieU = [fitAct calculatedRollingBest:info];
    [[serieU.serie asCSVString:false] writeToFile:[RZFileOrganizer writeableFilePath:@"s_best.csv"]
                                      atomically:YES encoding:NSUTF8StringEncoding error:nil];

}


@end
