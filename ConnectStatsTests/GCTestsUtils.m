//
//  GCTestsUtils.m
//  GarminConnect
//
//  Created by Brice Rosenzweig on 23/10/2013.
//  Copyright (c) 2013 Brice Rosenzweig. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GCHistoryFieldDataSerie.h"
#import "GCFormattedField.h"
#import "GCAppGlobal.h"
#import "GCViewConfig.h"

@interface NSNumber (GCTestsCategory)
-(NSNumber*)divideTwo;
@end

@implementation NSNumber (GCTestsCategory)

-(NSNumber*)divideTwo{
    if (self.integerValue % 2 ==0) {
        return @( self.integerValue / 2.);
    }else{
        return nil;
    }
}

@end

@interface GCTestsUtils : XCTestCase

@end

#define EPS 1e-10

@implementation GCTestsUtils

- (void)setUp
{
    [super setUp];
    static BOOL _started = false;
    if (!_started) {
        [GCAppGlobal startSuccessful];
        _started = true;
    }

    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



#pragma mark - Other




#pragma mark - GCUnit

-(void)testStoreUnit{
    // Make sure store unit consistent with referenceUnit
    // so we can have a generic way to know which unit to use to store just with the unit
    // without doing if on the field for future improvement
    XCTAssertEqualObjects(STOREUNIT_SPEED, [GCUnit minperkm].referenceUnitKey);
    XCTAssertEqualObjects(STOREUNIT_DISTANCE, [GCUnit kilometer].referenceUnitKey);
    XCTAssertEqualObjects(STOREUNIT_ALTITUDE, [GCUnit meter].referenceUnitKey);
    XCTAssertEqualObjects(STOREUNIT_ELAPSED, [GCUnit second].referenceUnitKey);
    XCTAssertEqualObjects(STOREUNIT_TEMPERATURE, [GCUnit celsius].referenceUnitKey);
    XCTAssertEqualObjects(STOREUNIT_HEARTRATE, [GCUnit bpm].referenceUnitKey);
}

#ifdef GC_USE_HEALTHKIT
-(void)testHealthKitUnit{
    
    NSDictionary * bad = @{
        @"cmAq": [HKUnit centimeterOfWaterUnit],      // cmAq
        @"atm": [HKUnit atmosphereUnit]            // atm
    };
    
    NSDictionary * tests = @{
                             @"kilogram":  [HKUnit gramUnitWithMetricPrefix:HKMetricPrefixKilo],       // g
                             @"gram":   [HKUnit gramUnit],   // g
                             @"pound":  [HKUnit poundUnit],  // lb
                             @"kilometer":   [HKUnit meterUnitWithMetricPrefix:HKMetricPrefixKilo],      // m
                             @"meter":       [HKUnit meterUnit],  // m
                             @"inch": [HKUnit inchUnit],   // in
                             @"foot": [HKUnit footUnit],   // ft
                             @"mile": [HKUnit mileUnit],   // mi
                             @"ms": [HKUnit secondUnitWithMetricPrefix:HKMetricPrefixMilli],     // s
                             @"second": [HKUnit secondUnit], // s
                             @"minute": [HKUnit minuteUnit], // min
                             @"hour": [HKUnit hourUnit],   // hr
                             
                             @"kilojoule": [HKUnit jouleUnitWithMetricPrefix:HKMetricPrefixKilo],      // J
                             @"kilocalorie": [HKUnit kilocalorieUnit],    // kcal
                             
                             @"celsius": [HKUnit degreeCelsiusUnit],          // degC
                             @"fahrenheit": [HKUnit degreeFahrenheitUnit],       // degF
                             
                             @"dimensionless": [HKUnit countUnit]      // count
                             };
    for (NSString*key in tests) {
        HKUnit * hku = tests[key];
        
        XCTAssertEqualObjects(key, [GCUnit fromHkUnit:hku].key, @"%@ from %@", key, hku);
        XCTAssertEqualObjects(hku.unitString, [[[GCUnit unitForKey:key] hkUnit] unitString], @"%@ from %@", hku, key);
    }
    
    for (NSString*key in bad) {
        HKUnit * hku = tests[key];
        XCTAssertNil([GCUnit fromHkUnit:hku], @"Invalid %@ == nil", hku);
        XCTAssertNil([[GCUnit unitForKey:key] hkUnit], @"Invalid %@ == nil", key);
    }
    
    
}

-(void)testNumberWithUnitHealthKit{
    GCNumberWithUnit * nu = nil;

    HKQuantity * qu = nil;
    HKQuantity * qu2= nil;
    
    qu = [HKQuantity quantityWithUnit:[HKUnit meterUnit] doubleValue:1000.];
    nu = [GCNumberWithUnit numberWithUnit:[GCUnit unitForKey:@"kilometer"] andQuantity:qu];
    XCTAssertEqualWithAccuracy(nu.value, 1.0, 1e-7, @"1km");
    qu2 = [nu hkQuantity];
    XCTAssertEqual([qu compare:qu2], NSOrderedSame, @"convert gc");
    
    
    
    qu2 = [[nu convertToUnitName:@"mile"] hkQuantity];
    XCTAssertEqual([qu compare:qu2], NSOrderedSame, @"convert gc");
    
    nu = [GCNumberWithUnit numberWithUnit:[GCUnit unitForKey:@"mile"] andQuantity:qu];
    qu2 = [nu hkQuantity];
    XCTAssertEqual([qu compare:qu2], NSOrderedSame, @"convert gc");
    
}
#endif
-(void)testFormattedField{
    gcUnitSystem remember = [GCUnit getGlobalSystem];
    
    NSString * TEST_FIELD = @"testField";
    NSString * TEST_TEXT  = @"testText";
    
    [GCFields registerMissingField:[GCField fieldForKey:TEST_FIELD andActivityType:GC_TYPE_RUNNING] displayName:@"Test" andUnitName:@"dimensionless"];
    
    NSArray * tests = @[
                        @[@"", @"", @1800., @"yard", @"1.02 mi", @"1.65 km"],
                        @[TEST_FIELD, GC_TYPE_RUNNING, @185., @"second", @"Test 03:05", @"Test 03:05"],
                        @[TEST_TEXT, @"", @185., @"meter",  @"Test Text 202.3 yd", @"Test Text 185 m"]
                        ];
    
    for (NSArray * one in tests) {
        NSString * afield = [one[0] isEqualToString:@""] ? nil : one[0];
        NSString * atype = [one[1] isEqualToString:@""] ? nil : one[1];
        
        GCNumberWithUnit * num = [GCNumberWithUnit numberWithUnitName:one[3] andValue:[one[2] doubleValue]];
        
        NSString * expectedImperial = one[4];
        NSString * expectedMetric   = one[5];
        
        GCFormattedField * field = [GCFormattedField formattedField:[GCField fieldForKey:afield andActivityType:atype] forNumber:num forSize:12.];

        [GCUnit setGlobalSystem:gcUnitSystemImperial];
        XCTAssertEqualObjects(field.attributedString.string, expectedImperial, @"Imperial %@", expectedImperial);
        [GCUnit setGlobalSystem:gcUnitSystemMetric];
        XCTAssertEqualObjects(field.attributedString.string, expectedMetric, @"Metric %@", expectedImperial);
        
    }
    
    
    [GCUnit setGlobalSystem:remember];
}

-(void)testUnitParser{
    NSArray*cases = @[
        @[ @"hello", @"", @"hello"],
        @[ @"10km", [GCNumberWithUnit numberWithUnitName:@"km" andValue:10.], @""],
        @[ @"10 km", [GCNumberWithUnit numberWithUnitName:@"km" andValue:10.], @""],
        @[ @"10 km aa", [GCNumberWithUnit numberWithUnitName:@"km" andValue:10.], @"aa"],
        @[ @"10 mile bb", [GCNumberWithUnit numberWithUnitName:@"mile" andValue:10.], @"bb"],
        @[ @"10.5 hello", [GCNumberWithUnit numberWithUnitName:@"dimentionless" andValue:10.5], @"hello"],
        @[ @"1:05 <bye", [GCNumberWithUnit numberWithUnitName:@"second" andValue:65], @"<bye"],
        @[ @"5:05 minperkm", [GCNumberWithUnit numberWithUnitName:@"minperkm" andValue:(5.+(5./60.))], @""],
    ];

    for (NSArray * one in cases) {
        NSString * input = one[0];
        GCNumberWithUnit * expected = [one[1] isKindOfClass:[GCNumberWithUnit class]] ? one[1] : nil;
        NSString * expectedRemain = one[2];
        NSString * foundRemain = nil;
        NSScanner * scanner = [NSScanner scannerWithString:input];
        GCNumberWithUnit * found = [GCNumberWithUnit numberWithUnitFromScanner:scanner];
        [scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:&foundRemain];
        XCTAssertEqualObjects(expected, found);
        XCTAssertEqualObjects(expectedRemain, foundRemain?:@"");
    }

}


-(void)testHealthZoneBuckets{
    
}
@end
