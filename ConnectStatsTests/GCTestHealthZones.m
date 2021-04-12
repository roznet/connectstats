//
//  GCTestHealthZones.m
//  GarminConnect
//
//  Created by Brice Rosenzweig on 16/08/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GCHealthOrganizer.h"
#import "GCGarminUserJsonParser.h"
#import "GCHealthZoneCalculator.h"
#import "GCGarminHeartRateZoneParser.h"
#import "GCTestsHelper.h"
#import "GCAppGlobal.h"

@interface GCTestHealthZones : XCTestCase
@property (nonatomic,retain) GCTestsHelper * helper;
@end

@implementation GCTestHealthZones
-(void)dealloc{
    [_helper release];
    [super dealloc];
}

- (void)setUp {
    [super setUp];
    if( ! _helper){
        self.helper = [GCTestsHelper helper];
    }else{
        [self.helper setUp];
    }
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    [self.helper tearDown];
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testUserHealthZoneParsing{
    NSError * error = nil;
    
    NSString * fp = [RZFileOrganizer writeableFilePath:@"test_health_organizer.db"];
    [RZFileOrganizer removeEditableFile:@"test_health_organizer.db"];
    
    FMDatabase * db = [FMDatabase databaseWithPath:fp];
    [db open];
    [GCHealthOrganizer ensureDbStructure:db];
    GCHealthOrganizer * health = [[[GCHealthOrganizer alloc] initForTestModeWithDb:db andThread:nil] autorelease];
    
    NSString * theString = [NSString stringWithContentsOfFile:[RZFileOrganizer bundleFilePath:@"user.json" forClass:[self class]] encoding:NSUTF8StringEncoding error:&error];
    XCTAssertNotNil(theString, @"Could read file without error %@", error);
    
    NSMutableDictionary * defaultZones = [NSMutableDictionary dictionary];
    [health addDefaultZoneCalculatorTo:defaultZones];
    
    GCGarminUserJsonParser * parser = [[[GCGarminUserJsonParser alloc] initWithString:theString andEncoding:NSUTF8StringEncoding] autorelease];
    XCTAssertTrue(parser.success);
    
    for (NSString * key in parser.data) {
        XCTAssertNil(health.zones[key], @"Should start without %@", key);
    }
    [health registerZoneCalculators:parser.data];
    XCTAssertTrue(parser.success, @"JsonParser Success");
    GCHealthZoneCalculator * calculator = nil;
    GCHealthOrganizer * reloaded = [[[GCHealthOrganizer alloc] initForTestModeWithDb:db andThread:nil] autorelease];
    
    // New format, but same zone for the last 5:
    NSData * data = [NSData dataWithContentsOfFile:[RZFileOrganizer bundleFilePath:@"user_hr_zones.json" forClass:[self class]]];
    GCGarminHeartRateZoneParser * hrParser = [GCGarminHeartRateZoneParser parserWithData:data];

    for (NSString * key in parser.data){
        calculator = parser.data[key];
        if (calculator.field.fieldFlag != gcFieldFlagWeightedMeanHeartRate) {
            continue;
        }
        void(^runOne)(double,NSUInteger)=^(double hr,NSUInteger z){
            NSUInteger computed=[[calculator zoneForNumber:[GCNumberWithUnit numberWithUnitName:@"bpm" andValue:hr]] zoneIndex];
            GCHealthZoneCalculator * recalc = [reloaded zoneCalculatorForField:calculator.field];

            NSUInteger recomp = [[recalc zoneForNumber:[GCNumberWithUnit numberWithUnitName:@"bpm" andValue:hr]] zoneIndex];
            XCTAssertEqual(z, computed, @"zone(%@)=%@ (exp %@)", @(hr), @(computed), @(z) );
            XCTAssertEqual(z, recomp, @"zone(%@)=%@ (exp %@) [Reloaded]", @(hr), @(computed), @(z));
            
            // New format, but same zone for the last 5, only check if > 0,
            // then should be equal to +1 (0 could be 0 or 1)
            if( z > 0){
                GCHealthZoneCalculator * newZoneCalc = hrParser.calculators[key];
                XCTAssertNotNil(newZoneCalc);
                if( newZoneCalc){
                    NSUInteger newZ = [[newZoneCalc zoneForNumber:[GCNumberWithUnit numberWithUnitName:@"bpm" andValue:hr]] zoneIndex];
                    XCTAssertEqual(z, newZ+1, @"zone(%@)=%@ (exp %@)", @(hr), @(computed), @(newZ+1) );
                }
            }
        };
        runOne(166.,3);
        runOne(133.,1);
        runOne(210.,5);
        runOne(-10.,0);
        runOne(20.,0);
    }
    GCField * runningHr = [GCField fieldForFlag:gcFieldFlagWeightedMeanHeartRate andActivityType:GC_TYPE_RUNNING];
    GCNumberWithUnit * nu = [GCNumberWithUnit numberWithUnitName:@"bpm" andValue:140.];

    [[GCAppGlobal profile] configSet:CONFIG_ZONE_PREFERRED_SOURCE stringVal:@"garmin"];
    GCHealthZoneCalculator * chosen = [health zoneCalculatorForField:runningHr];
    XCTAssertEqual(chosen.source, gcHealthZoneSourceGarmin );
    
    NSUInteger idx = [chosen zoneForNumber:nu].zoneIndex;
    XCTAssertEqual(idx, 1);
    
    // Now create a manual calculator and modify the zone containing nu
    GCHealthZoneCalculator * manual = [GCHealthZoneCalculator manualZoneCalculatorFrom:chosen];
    XCTAssertEqual(manual.source, gcHealthZoneSourceManual);
    XCTAssertEqual(manual.zones[idx].source, gcHealthZoneSourceManual);
    manual.zones[idx].ceiling = 139;
    manual.zones[idx+1].floor = 139;
    
    // Now Register Manual and switch to that
    [health registerZoneCalculators:@{ [GCHealthZoneCalculator keyForField:runningHr andSource:manual.source]: manual}];
    [[GCAppGlobal profile] configSet:CONFIG_ZONE_PREFERRED_SOURCE stringVal:@"manual"];
    chosen = [health zoneCalculatorForField:runningHr];
    XCTAssertEqual(chosen.source, gcHealthZoneSourceManual );
    idx = [chosen zoneForNumber:nu].zoneIndex;
    XCTAssertEqual(idx, 2);

    // Back to grmin, should be original zone
    [[GCAppGlobal profile] configSet:CONFIG_ZONE_PREFERRED_SOURCE stringVal:@"garmin"];
    chosen = [health zoneCalculatorForField:runningHr];
    XCTAssertEqual(chosen.source, gcHealthZoneSourceGarmin );
    idx = [chosen zoneForNumber:nu].zoneIndex;
    XCTAssertEqual(idx, 1);

    
    XCTAssertTrue(health.hasZoneData, @"Has Zone Data");
}

-(void)testSimpleZones{
    GCField * speed = [GCField fieldForFlag:gcFieldFlagWeightedMeanSpeed andActivityType:GC_TYPE_RUNNING];
    GCHealthZoneCalculator * calc = [GCHealthZoneCalculator zoneCalculatorForValues:@[ @0.0, @10.0, @20.]
                                                                             inUnit:[GCUnit unitForKey:@"mps"]
                                                                          withNames:@[@"SingleDigit", @"DoubleDigit"]
                                                                           field:speed forSource:gcHealthZoneSourceManual];
    XCTAssertEqual(calc.zones.count, 2);
    
    NSArray * expected = @[ @[ @(-1.), @5.],
                            @[ @10., @15., @30.]
                            ];
    NSUInteger expectedIndex = 0;
    for (NSArray<NSNumber*>*ones in expected) {
        for (NSNumber*one in ones) {
            GCHealthZone * zone = [calc zoneForNumber:[GCNumberWithUnit numberWithUnitName:@"mps" andValue:one.doubleValue]];
            XCTAssertEqual(zone.zoneIndex, expectedIndex);
        }
        expectedIndex++;
    }
}

@end
