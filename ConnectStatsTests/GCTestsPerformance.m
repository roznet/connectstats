//  MIT License
//
//  Created on 13/02/2018 for ConnectStatsXCTests
//
//  Copyright (c) 2018 Brice Rosenzweig
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



#import <XCTest/XCTest.h>
#import "GCTestCase.h"
#import "GCActivitiesOrganizer.h"
#import "GCHistoryFieldSummaryStats.h"
#import "GCTrackStats.h"
#import "GCActivity+Database.h"
#import "GCGarminActivityTrack13Request.h"
#import "GCGarminRequestActivityReload.h"
#import "GCService.h"
#import "GCActivitiesOrganizerListRegister.h"
#import "GCActivityAutoLapChoices.h"
#import "ConnectStats-Swift.h"
#import "GCGarminSearchJsonParser.h"
#import "GCTestsSamples.h"
#import "GCHistoryAggregatedActivityStats.h"


@interface GCTestsPerformance : GCTestCase

@end

@implementation GCTestsPerformance

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testPerformanceOrganizerLoad {
    [self measureBlock:^{
        FMDatabase * db = [GCTestsSamples sampleActivityDatabase:@"activities_duplicate.db"];
        
        GCActivitiesOrganizer * organizer = [[GCActivitiesOrganizer alloc] initTestModeWithDb:db];
        XCTAssertEqual(organizer.activities.count, 126, @"filtered duplicate properly");
        [organizer release];
        [db close];

        // Put the code you want to measure the time of here.
    }];
}

-(void)testPerformanceOrganizerStatistics{
    FMDatabase * db = [GCTestsSamples sampleActivityDatabase:@"activities_stats.db"];
    
    GCActivitiesOrganizer * organizer = [[GCActivitiesOrganizer alloc] initTestModeWithDb:db];
    
    [self measureBlock:^{
        [GCHistoryFieldSummaryStats fieldStatsWithActivities:organizer.activities
                                                    matching:nil
                                               referenceDate:nil
                                                  ignoreMode:gcIgnoreModeActivityFocus];
    }];
    
    
    [organizer release];
    [db close];
    

}

-(void)testPerformanceAggregatedStatistics{
    FMDatabase * db = [GCTestsSamples sampleActivityDatabase:@"activities_stats.db"];
    
    GCActivitiesOrganizer * organizer = [[GCActivitiesOrganizer alloc] initTestModeWithDb:db];
    
    [self measureBlock:^{
        GCHistoryAggregatedActivityStats * stats = [GCHistoryAggregatedActivityStats aggregatedActivitStatsForActivityType:GC_TYPE_RUNNING];
        stats.activities = organizer.activities;
        [stats aggregate:NSCalendarUnitWeekOfYear referenceDate:nil ignoreMode:gcIgnoreModeActivityFocus];
    }];

    [organizer release];
    [db close];

}

-(void)testPerformanceTrackpoints{
    
    NSString * aId = @"1083407258";
    
    GCActivity * act = [GCGarminRequestActivityReload testForActivity:aId withFilesIn:[RZFileOrganizer bundleFilePath:nil forClass:[self class]]];
    [GCGarminActivityTrack13Request testForActivity:act withFilesIn:[RZFileOrganizer bundleFilePath:nil forClass:[self class]]];

    NSString * fn = [RZFileOrganizer bundleFilePath:[NSString stringWithFormat:@"activity_%@.fit", aId] forClass:[self class]];
    
    GCActivity * fitAct = [[GCActivity alloc] initWithId:aId fitFilePath:fn startTime:act.date];

    //act = fitAct;
    GCField * speedField = [GCField fieldForFlag:gcFieldFlagWeightedMeanSpeed andActivityType:act.activityType];
    
    [self measureBlock:^{
        for (GCField * field in act.availableTrackFields) {
            if( ![field isEqualToField:speedField]){
                GCTrackStats * trackStats = [[GCTrackStats alloc] init];
                trackStats.activity = act;
                [trackStats setupForField:speedField xField:field andLField:nil];
                [trackStats release];
            }
        }
        
        for (GCField * field in fitAct.availableTrackFields) {
            if( ![field isEqualToField:speedField]){
                GCTrackStats * trackStats = [[GCTrackStats alloc] init];
                trackStats.activity = fitAct;
                [trackStats setupForField:speedField xField:field andLField:nil];
                [trackStats release];
            }
        }

    }];
    

}

-(void)testPerformanceParsingModern{
    NSString * aId = @"1083407258";
    
    [self measureBlock:^{
        
        GCActivity * act = [GCGarminRequestActivityReload testForActivity:aId withFilesIn:[RZFileOrganizer bundleFilePath:nil forClass:[self class]]];
        [GCGarminActivityTrack13Request testForActivity:act withFilesIn:[RZFileOrganizer bundleFilePath:nil forClass:[self class]]];
        XCTAssertGreaterThan(act.trackpoints.count, 1);
    }];
    
    
}

-(void)testPerformanceParsingFit{
    NSArray<NSString*>*aIds = @[ @"1083407258"/*, @"2477200414"*/];
    
    [self measureBlock:^{
        for( NSString * aId in aIds ) {
            NSString * fn = [RZFileOrganizer bundleFilePath:[NSString stringWithFormat:@"activity_%@.fit", aId] forClass:[self class]];
            GCActivity * act = [[GCActivity alloc] initWithId:aId fitFilePath:fn startTime:[NSDate date]];
            XCTAssertGreaterThan(act.trackpoints.count, 1);
            [act release];
        }
    }];
    
}

-(void)testPerformanceOrganizerRegister{
    NSData * searchLegacyInfo = [NSData  dataWithContentsOfFile:[RZFileOrganizer bundleFilePath:@"last_search_modern.json"
                                                                                       forClass:[self class]]];
    GCService * service = [GCService service:gcServiceGarmin];
    NSString * dbn = [RZFileOrganizer writeableFilePath:@"test_organizer_register_perf.db"];
    
    [self measureBlock:^{
        GCGarminSearchJsonParser * parser=[[GCGarminSearchJsonParser alloc] initWithData:searchLegacyInfo] ;
        
        [RZFileOrganizer removeEditableFile:@"test_organizer_register_perf.db"];
        FMDatabase * db = [FMDatabase databaseWithPath:dbn];
        [db open];
        [GCActivitiesOrganizer ensureDbStructure:db];
        
        GCActivitiesOrganizer * organizer = [[GCActivitiesOrganizer alloc] initTestModeWithDb:db];
        
        GCActivitiesOrganizerListRegister * listregister =[GCActivitiesOrganizerListRegister activitiesOrganizerListRegister:parser.activities from:service isFirst:YES];
        [listregister addToOrganizer:organizer];
        
        [db close];
        [organizer release];
        [parser release];
    }];
    
}

-(void)testPerformanceLapsCalculations{
    NSString * aId = @"2477200414";
    GCActivity * act = [GCGarminRequestActivityReload testForActivity:aId withFilesIn:[RZFileOrganizer bundleFilePath:nil forClass:[self class]]];
    [GCGarminActivityTrack13Request testForActivity:act withFilesIn:[RZFileOrganizer bundleFilePath:nil forClass:[self class]]];
    XCTAssertGreaterThan(act.trackpoints.count, 1);
    GCActivityAutoLapChoices * choices = [[[GCActivityAutoLapChoices alloc] initWithActivity:act] autorelease];
    
    NSMutableDictionary * keep = [NSMutableDictionary dictionary];
    // only test 1 of each kind of style
    for (GCActivityAutoLapChoiceHolder * choice  in choices.choices) {
        keep[ @(choice.style)] = choice;
    }
    
    choices.choices = keep.allValues;
    choices.selected = 0;
    NSUInteger n = choices.choices.count;
    
    [self measureBlock:^{
        [act clearCalculatedLaps];
        for (NSUInteger i=0; i<n; i++) {
            [choices changeSelectedTo:i];
        }
    }];

}
@end
