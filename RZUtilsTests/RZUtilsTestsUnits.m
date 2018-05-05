//
//  RZUtilsTestsGCUnits.m
//  RZUtils
//
//  Created by Brice Rosenzweig on 16/07/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <RZUtils/RZUtils.h>

#define EPS 1e-10

@interface RZUtilsTestsUnits : XCTestCase

@end

@implementation RZUtilsTestsUnits

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testUnitSystem{
    GCUnit * meters = [GCUnit unitForKey:@"meter"];
    GCUnit * km     = [GCUnit unitForKey:@"kilometer"];
    GCUnit * kph = [GCUnit unitForKey:@"kph"];
    GCUnit * minperkm = [GCUnit unitForKey:@"minperkm"];
    
    GCUnit * miles  = [GCUnit unitForKey:@"mile"];
    GCUnit * yard   = [GCUnit unitForKey:@"yard"];
    GCUnit * feet   = [GCUnit unitForKey:@"foot"];
    GCUnit * mph = [GCUnit unitForKey:@"mph"];
    GCUnit * minpermile=[GCUnit unitForKey:@"minpermile"];
    
    GCUnit * kg     = [GCUnit unitForKey:@"kilogram"];
    GCUnit * pd     = [GCUnit unitForKey:@"pound"];
    
    NSArray * metric = @[meters,yard,meters,feet,km,miles,kph,mph,minperkm,minpermile,kg,pd];
    for (NSUInteger i = 0; i<[metric count]; i+=2) {
        GCUnit * me = [metric objectAtIndex:i];
        GCUnit * im = [metric objectAtIndex:i+1];
        XCTAssertEqualObjects(me, [im unitForSystem:GCUnitSystemMetric],   @"%@-%@ metric/imperial",[me key],[im key]);
        XCTAssertEqualObjects(me, [me unitForSystem:GCUnitSystemMetric],   @"%@-%@ metric/imperial",[me key],[im key]);
        XCTAssertEqualObjects(me, [me unitForSystem:GCUnitSystemDefault],  @"%@-%@ metric/imperial",[me key],[im key]);
        
        XCTAssertEqualObjects(im, [im unitForSystem:GCUnitSystemImperial], @"%@-%@ metric/imperial",[me key],[im key]);
        if (im != feet) {// because meters -> yard or foot is ambiguous
            XCTAssertEqualObjects(im, [me unitForSystem:GCUnitSystemImperial], @"%@-%@ metric/imperial",[me key],[im key]);
        }
        XCTAssertEqualObjects(im, [im unitForSystem:GCUnitSystemDefault],  @"%@-%@ metric/imperial",[me key],[im key]);
    }
    XCTAssertEqual([meters system], GCUnitSystemMetric);
    XCTAssertEqual([yard system], GCUnitSystemImperial);
}

-(void)testLogScaleUnits{
    GCUnit * second = [GCUnit unitForKey:@"second"];
    
    GCUnit * logSeconds = [GCUnitLogScale logScaleUnitFor:second base:10. scaling:0.1 shift:1.];
    
    
    for (NSNumber * tval in @[ @(68.), @(5.), @(65.*10.), @(63.*72.)]) {
        double val = tval.doubleValue;
        double lval = log(val*0.1+1.)/log(10.);
        
        GCNumberWithUnit * nu  = [GCNumberWithUnit numberWithUnit:second andValue:val];
        GCNumberWithUnit * lnu = [nu convertToUnit:logSeconds];
        GCNumberWithUnit * rnu = [lnu convertToUnit:second];
        
        XCTAssertEqualWithAccuracy(nu.value, rnu.value, EPS);
        XCTAssertEqualWithAccuracy(lnu.value, lval, EPS);
        
        XCTAssertEqualObjects(nu.description, lnu.description);
    }
    
}

-(void)testUnitsDates{
    
    NSDate * start= [NSDate dateForRFC3339DateTimeString:@"2012-11-11T18:48:16.000Z"];
    NSDictionary * expected = @{
                                start : @"00",
                                [NSDate dateForRFC3339DateTimeString:@"2012-11-11T18:48:17.000Z"] : @"01",
                                [NSDate dateForRFC3339DateTimeString:@"2012-11-11T18:49:17.000Z"] : @"01:01",
                                [NSDate dateForRFC3339DateTimeString:@"2012-11-11T19:50:20.000Z"] : @"01:02:04"
                                };
                        
    
    GCUnitElapsedSince * elapsed = [GCUnitElapsedSince elapsedSince:start];
    for (NSDate*testDate in expected) {
        NSString * expect = expected[testDate];
        XCTAssertEqualObjects([elapsed formatDouble:testDate.timeIntervalSinceReferenceDate], expect);
    }
    
    
}

-(void)testUnits{
    GCUnit * meters = [GCUnit unitForKey:@"meter"];
    GCUnit * km     = [GCUnit unitForKey:@"kilometer"];
    GCUnit * miles  = [GCUnit unitForKey:@"mile"];
    GCUnit * foot   = [GCUnit unitForKey:@"foot"];
    GCUnit * yard   = [GCUnit unitForKey:@"yard"];
    GCUnit * inch   = [GCUnit unitForKey:@"inch"];
    GCUnit * cm     = [GCUnit unitForKey:@"centimeter"];
    GCUnit * kg     = [GCUnit unitForKey:@"kilogram"];
    GCUnit * pd     = [GCUnit unitForKey:@"pound"];
    
    
    // Distances
    double miles2km = 1.609344;
    double foot2m   = 3.2808399;
    XCTAssertEqualWithAccuracy(0.001,           [meters convertDouble:1.0 toUnit:km],       EPS, @"meters to km");
    XCTAssertEqualWithAccuracy(1./miles2km,     [meters convertDouble:1000.0 toUnit:miles], EPS, @"1000 meters to miles");
    XCTAssertEqualWithAccuracy(0.005/miles2km,  [meters convertDouble:5.0 toUnit:miles],    EPS, @"meters to miles");
    XCTAssertEqualWithAccuracy(1./miles2km,     [km convertDouble:1.0 toUnit:miles],        EPS, @"km to miles");
    XCTAssertEqualWithAccuracy(miles2km*2.,     [miles convertDouble:2.0 toUnit:km],        EPS, @"miles to km");
    XCTAssertEqualWithAccuracy(foot2m,          [meters convertDouble:1.0 toUnit:foot],     EPS, @"meters to feet");
    XCTAssertEqualWithAccuracy(2.54,            [inch convertDouble:1.0 toUnit:cm],       1.e-8, @"inch to cm");
    XCTAssertEqualWithAccuracy(1./0.9144,       [meters convertDouble:1.0 toUnit:yard],     EPS, @"m to yd");
    
    XCTAssertEqualWithAccuracy(0.45359237, [kg convertDouble:1.0 fromUnit:pd], 1.e-8, @"kg to pound");
    
    
    // time
    GCUnit * ms = [GCUnit unitForKey:@"ms"];
    GCUnit * second = [GCUnit unitForKey:@"second"];
    GCUnit * minute = [GCUnit unitForKey:@"minute"];
    GCUnit * hour = [GCUnit unitForKey:@"hour"];
    NSString * formatted = [minute formatDouble:[minute convertDouble:72. fromUnit:second]];
    XCTAssertEqualObjects(formatted, @"01:12", @"72sec format in minutes");
    
    XCTAssertEqualWithAccuracy([ms convertDouble:500. toUnit:second], 0.5, EPS, @"ms to seconds");
    XCTAssertEqualObjects([hour formatDouble:1.111], @"01:06:40", @"1.111 hour");
    XCTAssertEqualObjects([second formatDouble:81.], @"01:21", @"81 sec");
    XCTAssertEqualObjects([second formatDouble:3795], @"01:03:15", @"3795 sec");
    
    //SPeed
    GCUnit * kph = [GCUnit unitForKey:@"kph"];
    GCUnit * mph = [GCUnit unitForKey:@"mph"];
    //GCUnit * mps = [GCUnit unitForKey:@"mps"];
    GCUnit *minpermile=[GCUnit unitForKey:@"minpermile"];
    GCUnit *minperkm = [GCUnit unitForKey:@"minperkm"];
    
    XCTAssertEqualObjects([minperkm formatDouble:[minperkm convertDouble:11. fromUnit:kph]],         @"05:27 min/km", @"11kmh in min/km");
    XCTAssertEqualObjects([kph formatDouble:[kph convertDouble:6. fromUnit:minperkm]],               @"10.0 km/h",   @"6 min/km in kmh");
    XCTAssertEqualObjects([minpermile formatDouble:[minpermile convertDouble:11. fromUnit:kph]],     @"08:47 min/mi", @"11kmh in min/mi");
    XCTAssertEqualObjects([minpermile formatDouble:[minpermile convertDouble:5. fromUnit:minperkm]], @"08:03 min/mi", @"5min/km in min/mi");
    XCTAssertEqualObjects([minpermile formatDouble:5.99],                                            @"05:59 min/mi", @"5.99min/mi round down");
    XCTAssertEqualObjects([minpermile formatDouble:5.99999],                                         @"06:00 min/mi", @"5.9999min/mi round up");
    XCTAssertEqualObjects([mph formatDouble:[kph convertDouble:20. toUnit:mph]],                     @"12.4 mph",    @"20kph in mph");
    XCTAssertEqualObjects([mph formatDouble:[minperkm convertDouble:5. toUnit:mph]],                 @"7.5 mph",     @"5 min/km in mph");
    
    GCUnit * date = [GCUnit unitForKey:@"dateshort"];
    NSDateComponents * comp = [[NSDateComponents alloc] init];
    NSCalendar * cal = [NSCalendar currentCalendar];
    [comp setDay:1];
    [comp setMonth:2];
    [comp setYear:2012];
    
    NSDate * sampledate = [cal dateFromComponents:comp];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    XCTAssertEqualObjects([date formatDouble:[sampledate timeIntervalSinceReferenceDate]], [dateFormatter stringFromDate:sampledate], @"testDate");
    
    GCUnit * bpm = [GCUnit unitForKey:@"bpm"];
    XCTAssertEqualObjects([bpm formatDouble:162.1], @"162 bpm", @"bpm format");
    XCTAssertEqualObjects([bpm formatDoubleNoUnits:162.1], @"162", @"bpm format no abbr");
    
    GCUnit * min100m = [GCUnit unitForKey:@"min100m"];
    
    // Common units
    XCTAssertEqual(km,          [meters commonUnit:km],         @"Km vs m common");
    XCTAssertEqual(meters,      [meters commonUnit:kph],        @"Kph vs m common");
    XCTAssertEqual(kph,         [minperkm commonUnit:kph],      @"kph vs minperkm common");
    XCTAssertEqual(minperkm,    [minperkm commonUnit:min100m],  @"minperkm vs min100m common");
    XCTAssertEqual(kph,         [kph commonUnit:min100m],       @"kph vs min100m common");
    
    GCUnit * celcius = [GCUnit unitForKey:@"celcius"];
    GCUnit * fahrenheit = [GCUnit unitForKey:@"fahrenheit"];
    
    XCTAssertEqualWithAccuracy([fahrenheit convertDouble:0.  fromUnit:celcius], 32.0, 1e-8, @"0C = 32F");
    XCTAssertEqualWithAccuracy([fahrenheit convertDouble:20. fromUnit:celcius], 68.,  1e-8, @"20C = 68F");
    XCTAssertEqualWithAccuracy([celcius convertDouble:64.4 fromUnit:fahrenheit], 18., 1e-8, @"18C = 64.4F");
    XCTAssertEqualWithAccuracy([fahrenheit convertDouble:-20. fromUnit:celcius], -4., 1e-8, @"-20C = -4C");
    
    //angle
    GCUnit * radian = [GCUnit unitForKey:@"radian"];
    GCUnit * dd     = [GCUnit unitForKey:@"dd"];
    GCUnit * semi   = [GCUnit unitForKey:@"semicircle"];
    
    XCTAssertEqualWithAccuracy( 180.,    [dd convertDouble:M_PI fromUnit:radian], EPS, @"180dd=pi");
    XCTAssertEqualWithAccuracy( M_PI/2., [dd convertDouble:90. toUnit:radian], EPS, @"90dd=pi/2");
    XCTAssertEqualWithAccuracy( 29.274448016658425, [semi convertDouble:349257769. toUnit:dd], EPS, @"semicircle");
    //(/ (* 349257769. 180.) 2147483648.0)
    //29.274448016658425
    
    // Step stride
    GCUnit * stride   = [GCUnit unitForKey:@"stride"];
    GCUnit * strideyd = [GCUnit unitForKey:@"strideyd"];
    GCUnit * spm      = [GCUnit unitForKey:@"stepsPerMinute"];
    GCUnit * dspm     = [GCUnit unitForKey:@"doubleStepsPerMinute"];
    
    [GCUnit setStrideStyle:GCUnitStrideSameFoot];
    GCNumberWithUnit * st2p1 = [GCNumberWithUnit numberWithUnit:stride andValue:2.1];
    GCNumberWithUnit * spm90 = [GCNumberWithUnit numberWithUnit:spm andValue:90];
    GCNumberWithUnit * styd  = [st2p1 convertToUnit:strideyd];
    GCNumberWithUnit * dspm9 = [GCNumberWithUnit numberWithUnit:dspm andValue:180];
    
    XCTAssertEqualObjects([spm90 formatDouble], @"90 spm", @"spm format orig");
    XCTAssertEqualObjects([dspm9 formatDouble], @"90 spm", @"spm format orig");
    XCTAssertEqualObjects([st2p1 formatDouble], @"2.10 m", @"stride format orig");
    XCTAssertEqualObjects([styd  formatDouble], @"2.30 yd", @"strideyd format orig");
    XCTAssertEqualObjects([[spm90 convertToUnit:dspm] formatDouble], @"90 spm", @"spm format orig");
    XCTAssertEqualObjects([[dspm9 convertToUnit:spm] formatDouble], @"90 spm", @"spm format orig");
    
    [GCUnit setStrideStyle:GCUnitStrideBetweenFeet];
    XCTAssertEqualObjects([dspm9 formatDouble], @"180 spm", @"spm format orig");
    XCTAssertEqualObjects([spm90 formatDouble], @"180 spm", @"spm format orig");
    XCTAssertEqualObjects([st2p1 formatDouble], @"1.05 m", @"stride format orig");
    XCTAssertEqualObjects([styd  formatDouble], @"1.15 yd", @"strideyd format orig");
    XCTAssertEqualObjects([[spm90 convertToUnit:dspm] formatDouble], @"180 spm", @"spm format orig");
    XCTAssertEqualObjects([[dspm9 convertToUnit:spm] formatDouble], @"180 spm", @"spm format orig");
    
    // New Value but not in original settings
    st2p1 = [GCNumberWithUnit numberWithUnit:stride andValue:2.2];
    spm90 = [GCNumberWithUnit numberWithUnit:spm andValue:80];
    styd  = [st2p1 convertToUnit:strideyd];
    
    [GCUnit setStrideStyle:GCUnitStrideSameFoot];
    XCTAssertEqualObjects([spm90 formatDouble], @"80 spm", @"spm format orig");
    XCTAssertEqualObjects([st2p1 formatDouble], @"2.20 m", @"stride format orig");
    XCTAssertEqualObjects([styd  formatDouble], @"2.41 yd", @"strideyd format orig");
    
    [GCUnit setStrideStyle:GCUnitStrideBetweenFeet];
    XCTAssertEqualObjects([spm90 formatDouble], @"160 spm", @"spm format orig");
    XCTAssertEqualObjects([st2p1 formatDouble], @"1.10 m", @"stride format orig");
    XCTAssertEqualObjects([styd  formatDouble], @"1.20 yd", @"strideyd format orig");
    
}

-(void)testNumberWithUnit{
    NSArray * tests = @[
                        @[@"14 km/h",           @14.0,   @"kph"],
                        @[@"14km/h",            @14.0,   @"kph"],
                        @[@"21℃",               @21.0,   @"celcius"],
                        @[@"21 °C",             @21.0,   @"celcius"],
                        @[@"  10:20",           @620.,   @"second"],
                        @[@"10:30 min/km",      @10.5,   @"minperkm"],
                        @[@"10:30 minperkm",    @10.5,   @"minperkm"],
                        @[@" 2",                @2.0,    @"dimensionless"],
                        // Fail cases:
                        @[@"X2F"],
                        @[@"2XFFFF"]
                        ];
    for (NSArray*one in tests) {
        NSString * text     = [one objectAtIndex:0];
        GCNumberWithUnit * num = [GCNumberWithUnit numberWithUnitFromString:text];
        
        if ([one count]==3) {
            NSNumber * val      = [one objectAtIndex:1];
            NSString * unitkey  = [one objectAtIndex:2];
            if (num) {
                XCTAssertEqualWithAccuracy(num.value, [val doubleValue], EPS, @"%@ value match", text);
                XCTAssertEqualObjects(unitkey, num.unit.key, @"%@ unit match",text);
            }else{
                XCTAssertNotNil(num, @"%@ should parse",text);
            }
        }else{
            XCTAssertNil(num, @"%@ should fail", text);
        }
    }
    
    
}
-(void)testNumberWithUnitAttributed{
    NSArray * tests = @[
                        @[ @1800.,  @"yard",            @"1.02 mi",         @"1.02" ],
                        @[ @800.,   @"meter",           @"800 m",           @"800"  ],
                        @[ @10.5,   @"minperkm",        @"10:30 min/km",    @"10:30"],
                        @[ @2,      @"dimensionless",   @"2",               @"2"    ],
                        @[ @135,    @"second" ,         @"02:15",           @"02:15"]
                        ];
    for (NSArray * one in tests) {
        
        GCNumberWithUnit * num = [GCNumberWithUnit numberWithUnitName:one[1]  andValue:[one[0] doubleValue]];
        XCTAssertEqualObjects([num attributedStringWithValueAttr:@{} andUnitAttr:@{}].string, one[2], @"%@ attributed", one[2]);
        XCTAssertEqualObjects([num attributedStringWithValueAttr:@{} andUnitAttr:nil].string, one[3], @"%@ attributed (noabbr)", one[3]);
        
    }
}

-(void)testUnitThousandsFormat{
    GCUnit * km = [GCUnit unitForKey:@"kilometer"];
    GCUnit * step = [GCUnit unitForKey:@"step"];
    
    XCTAssertEqualObjects([step formatDouble:1000.], @"1,000 s");
    XCTAssertEqualObjects([km formatDouble:1000.], @"1,000 km");
    XCTAssertEqualObjects([step formatDouble:123300.], @"123k s");
}

-(void)testMaxMin{
    GCNumberWithUnit * nu = [GCNumberWithUnit numberWithUnit:GCUnit.meter andValue:0.0];
    GCNumberWithUnit * min = [nu nonZeroMinNumberWithUnit:[GCNumberWithUnit numberWithUnit:GCUnit.meter andValue:1.0]];
    XCTAssertEqualWithAccuracy(min.value, 1.0, 1.e-10);
    min = [min nonZeroMinNumberWithUnit:[GCNumberWithUnit numberWithUnit:GCUnit.meter andValue:0.0]];
    XCTAssertEqualWithAccuracy(min.value, 1.0, 1.e-10);
    min = [min nonZeroMinNumberWithUnit:[GCNumberWithUnit numberWithUnit:GCUnit.meter andValue:2.0]];
    XCTAssertEqualWithAccuracy(min.value, 1.0, 1.e-10);
    min = [min nonZeroMinNumberWithUnit:[GCNumberWithUnit numberWithUnit:GCUnit.meter andValue:0.5]];
    XCTAssertEqualWithAccuracy(min.value, 0.5, 1.e-10);
}
@end
