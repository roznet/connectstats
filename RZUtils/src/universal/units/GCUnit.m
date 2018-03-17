//  MIT Licence
//
//  Created on 29/09/2012.
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

#import "GCUnit.h"
#import "RZMacros.h"
#include <math.h>
#import "NSDictionary+RZHelper.h"

#define GCUNITFORKEY(my_unit_key) +(GCUnit*)my_unit_key{ return [GCUnit unitForKey:@#my_unit_key]; }


NSMutableDictionary * _unitsRegistry = nil;
NSDictionary * _unitsMetrics = nil;
NSDictionary * _unitsImperial = nil;
gcUnitSystem globalSystem = GCUnitSystemDefault;
GCUnitStrideStyle _strideStyle = GCUnitStrideSameFoot;

//1.6093440
static const double GCUNIT_MILES = 1609.344;
static const double GCUNIT_POUND = 0.45359237;
static const double GCUNIT_FOOT = 1./3.2808399;
static const double GCUNIT_YARD = 0.9144;
static const double GCUNIT_INCHES = 1./39.3700787;
static const double GCUNIT_JOULES = 1./4.184;// in kcal

static const double EPS = 1.e-10;

void buildUnitSystemCache(){
    if (_unitsImperial == nil) {

        _unitsMetrics = @{
                          @"yard"       : @"meter",
                          @"foot"       : @"meter",
                          @"mile"       : @"kilometer",
                          @"minpermile" : @"minperkm",
                          @"mph"        : @"kph",
                          @"fahrenheit" : @"celcius",
                          @"min100yd"   : @"min100m",
                          @"hydph"      : @"hmph",
                          @"strideyd"   : @"stride",
                          @"pound"      : @"kilogram",
                          @"feetperhour": @"meterperhour",
                          };

        // Meter -> yard or foot ambiguous, default should be yard
        NSMutableDictionary * tempImperial = [NSMutableDictionary dictionaryWithDictionary:[_unitsMetrics dictionarySwappingKeysForObjects]];
        tempImperial[@"meter"] = @"yard";
        _unitsImperial = [NSDictionary dictionaryWithDictionary:tempImperial];
        RZRetain(_unitsMetrics);
        RZRetain(_unitsImperial);
    }
}

void registerDouble( NSArray * defs){
    GCUnit * unit = RZReturnAutorelease([[GCUnit alloc] initWithArray:defs]);
    unit.format = GCUnitDoubleFormat;
    _unitsRegistry[defs[0]] = unit;
}


void registerSimple( NSArray * defs){
    GCUnit * unit = RZReturnAutorelease([[GCUnit alloc] initWithArray:defs]);
    unit.format = GCunitDoubleTwoDigitFormat;
    _unitsRegistry[defs[0]] = unit;
}

void registerSimpl0( NSArray * defs){
    GCUnit * unit = RZReturnAutorelease([[GCUnit alloc] initWithArray:defs]);
    unit.format = GCUnitIntegerFormat;
    unit.referenceUnit = unit.key;  // make sure can convert to itself...
    _unitsRegistry[defs[0]] = unit;
}

void registerSimpl1( NSArray * defs){
    GCUnit * unit = RZReturnAutorelease([[GCUnit alloc] initWithArray:defs]);
    unit.format = GCUnitDoubleOneDigitFormat;
    _unitsRegistry[defs[0]] = unit;
}
void registerSimpl3( NSArray * defs){
    GCUnit * unit = RZReturnAutorelease([[GCUnit alloc] initWithArray:defs]);
    unit.format = GCunitDoubleThreeDigitFormat;
    _unitsRegistry[defs[0]] = unit;
}

void registerLinear( NSArray * defs, NSString * ref, double m, double o){
    GCUnitLinear * unit = [GCUnitLinear unitLinearWithArray:defs reference:ref multiplier:m andOffset:o];
    unit.format = GCunitDoubleTwoDigitFormat;
    _unitsRegistry[defs[0]] = unit;
}

void registerLinea1( NSArray * defs, NSString * ref, double m, double o){
    GCUnitLinear * unit = [GCUnitLinear unitLinearWithArray:defs reference:ref multiplier:m andOffset:o];
    unit.format = GCUnitDoubleOneDigitFormat;
    _unitsRegistry[defs[0]] = unit;
}

void registerLinea0( NSArray * defs, NSString * ref, double m, double o){
    GCUnitLinear * unit = [GCUnitLinear unitLinearWithArray:defs reference:ref multiplier:m andOffset:o];
    unit.format = GCUnitIntegerFormat;
    _unitsRegistry[defs[0]] = unit;
}

void registerLinTim( NSArray * defs, NSString * ref, double m, double o){
    GCUnitLinear * unit = [GCUnitLinear unitLinearWithArray:defs reference:ref multiplier:m andOffset:o];
    unit.format = GCUnitTimeFormat;
    _unitsRegistry[defs[0]] = unit;
}

void registerInvLin( NSArray * defs, NSString * ref, double m, double o){
    GCUnitInverseLinear * unit = [GCUnitInverseLinear unitInverseLinearWithArray:defs reference:ref multiplier:m andOffset:o];
    unit.format = GCUnitTimeFormat;
    _unitsRegistry[defs[0]] = unit;
}
void registerDaCa( NSString * name, NSDateFormatterStyle dateStyle, NSDateFormatterStyle timeStyle, NSString * fmt, NSCalendarUnit cal){
    GCUnitDate * unit = [[GCUnitDate alloc] init];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    unit.key = name;
    unit.abbr = @"";
    unit.display = @"";

    if (fmt) {
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = fmt;
    }else{
        formatter.dateStyle = dateStyle;
        formatter.timeStyle = timeStyle;
    }
    unit.dateFormatter = formatter;
    unit.useCalendarUnit = true;
    unit.calendarUnit = cal;

    _unitsRegistry[name] = unit;
    RZRelease(unit);
    RZRelease(formatter);
}
void registerDate( NSString * name, NSDateFormatterStyle dateStyle, NSDateFormatterStyle timeStyle, NSString * fmt){
    GCUnitDate * unit = [[GCUnitDate alloc] init];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    unit.key = name;
    unit.abbr = @"";
    unit.display = @"";

    if (fmt) {
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = fmt;
    }else{
        formatter.dateStyle = dateStyle;
        formatter.timeStyle = timeStyle;
    }
    unit.dateFormatter = formatter;

    _unitsRegistry[name] = unit;
    RZRelease(unit);
    RZRelease(formatter);
}

void registerTofD(NSString * name){
    GCUnitTimeOfDay * unit = [[GCUnitTimeOfDay alloc] init];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];

    formatter.dateStyle = NSDateFormatterNoStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    unit.dateFormatter = formatter;
    unit.key = name;
    unit.abbr = @"";
    unit.display = @"";

    _unitsRegistry[name] = unit;
    RZRelease(unit);
    RZRelease(formatter);
}

void registerCalUnit( NSString * name, NSCalendarUnit calUnit){
    GCUnitCalendarUnit * unit = [[GCUnitCalendarUnit alloc] init];
    unit.calendarUnit = calUnit;
    unit.key = name;
    unit.abbr = @"";
    unit.display = @"";

    _unitsRegistry[name] = unit;
    RZRelease(unit);
}

#pragma mark

void registerUnits(){
    if (!_unitsRegistry) {
        _unitsRegistry = RZReturnRetain([NSMutableDictionary dictionaryWithCapacity:60]);
        //simple
        BOOL allUnitSet = true;

        if (allUnitSet) {
            registerSimple( @[ @"revolution", @"Revolutions", @"rev"]);
            registerSimple( @[ @"numberOfActivities", @"Activities", @"Activities"]);
            registerSimple( @[ @"sampleCount", @"Samples", @"Samples"]);

            registerSimple( @[ @"ml/kg/min", @"ml/kg/min", @"ml/kg/min"]);
            registerSimple( @[ @"volt", @"Volt", @""]);
            registerSimpl0( @[ @"watt", @"Watts", @"W"]);
            registerSimple( @[ @"kN/m", @"kN/m", @"kN/m"]);

            registerSimpl0( @[ @"strokesPerMinute", @"strokes/min", @"strokes/min"]);

            registerSimple( @[ @"c/Hr", @"c/Hr", @"c/Hr"]); // Energy Expenditure
            
            registerLinea0( @[ @"kilocalorie", @"Calories", @"C"], @"kilocalorie", 1., 0. );
            registerLinear( @[ @"kilojoule", @"Kilojoule", @"kj"], @"kilocalorie", GCUNIT_JOULES, 0.);
            registerLinear( @[ @"joule", @"joule", @"J"], @"kilocalorie", GCUNIT_JOULES/1000., 0.);

            registerSimpl0( @[ @"rpm", @"Revolutions per Minute", @"rpm"]);
            registerSimple( @[ @"te", @"Training Effect", @""]);
            registerSimpl3( @[ @"if", @"Intensity Factor", @""]);
        }
        registerSimple( @[ @"percent", @"Percent", @"%"]);
        registerSimpl0( @[ @"dimensionless", @"Dimensionless", @""]);

        registerSimpl0( @[ @"step", @"Steps", @"s"]);
        registerLinea0( @[ @"stepsPerMinute", @"Steps per Minute", @"spm"], @"stepsPerMinute", 1., 0.);
        registerLinea0( @[ @"doubleStepsPerMinute", @"Steps per Minute", @"spm"], @"stepsPerMinute", 0.5, 0.);
        registerSimple( @[ @"strideRate", @"Stride rate", @"Stride rate"]);

        registerSimple( @[ @"year", @"Year", @""]);
        registerSimple( @[ @"day", @"Days", @"d"]);

        registerSimpl0( @[ @"bpm", @"Beats per Minute", @"bpm"]);

        //angle
        if (allUnitSet) {
            registerLinea0( @[ @"radian", @"Radian", @"rad"],       @"radian", 1.,        0.);
            registerLinea0( @[ @"dd", @"Decimal Degrees", @"dd"],   @"radian", M_PI/180., 0.);
            registerLinea0( @[ @"semicircle", @"Semicircle", @"sc"],@"radian", M_PI/2147483648.,0.);
        }

        //time
        registerLinTim( @[ @"ms",     @"Milliseconds",@"ms"   ],          @"second", 1./1000., 0.);
        registerLinTim( @[ @"second", @"Seconds",     @""     ],          @"second", 1.,       0.);
        registerLinTim( @[ @"minute", @"Minutes",     @"",    @"second"], @"second", 60.,      0.);
        registerLinTim( @[ @"hour",   @"Hours",       @"",    @"minute"], @"second", 3600.,    0.);

        //speed
        registerLinea1( @[ @"mps",        @"Meters per Second",   @"mps"  ],                 @"mps", 1.0,                 0.);
        registerLinea1( @[ @"kph",        @"Kilometers per Hour", @"km/h" ],                 @"mps", 1000./3600.,         0.);
        registerLinea1( @[ @"mph",        @"Miles per Hour",      @"mph"  ],                 @"mps", GCUNIT_MILES/3600.,  0.);
        registerInvLin( @[ @"secperkm",   @"Seconds per Kilometer",@"sec/km"],               @"mps", 1000.,               0.);
        registerInvLin( @[ @"minperkm",   @"Minutes per Kilometer",@"min/km", @"secperkm"],  @"mps", 60./3600.*1000.,     0.);
        registerInvLin( @[ @"secpermile", @"Seconds per Mile",    @"sec/mi" ],               @"mps", GCUNIT_MILES,        0.);
        registerInvLin( @[ @"minpermile", @"Minutes per Mile",    @"min/mi",  @"secpermile"],@"mps", 60./3600.*GCUNIT_MILES,0.);

        registerInvLin( @[ @"sec100yd",   @"sec/100 yd",          @"sec/100 yd"],              @"mps", 100.*GCUNIT_YARD,   0.);
        registerInvLin( @[ @"sec100m",    @"sec/100 m",           @"sec/100 m" ],              @"mps", 100.,               0.);
        registerInvLin( @[ @"min100m",    @"min/100 m",           @"min/100 m",  @"sec100m"],  @"mps", 60./3600.*100.,     0.);
        registerInvLin( @[ @"min100yd",   @"min/100 yd",          @"min/100 yd", @"sec100yd"], @"mps", 60./3600.*100.*GCUNIT_YARD,0.);
        registerLinea1( @[ @"hmph",       @"100m/hour",           @"100m/hour"],               @"mps", 100./3600.,         0.);
        registerLinea1( @[ @"hydph",      @"100yd/hour",          @"100yd/hour"],              @"mps", 100./3600.*GCUNIT_YARD,0.);

        // Ascent speed
        registerLinea1( @[ @"meterperhour", @"Meters per hour",   @"m/h"  ],                @"mps", 1.0/3600.,               0.);
        registerLinea1( @[ @"feetperhour", @"Feet per hour",   @"ft/h"  ],                @"mps", GCUNIT_FOOT/3600.,         0.);

        if (allUnitSet) {
            registerSimple( @[ @"mpm",        @"Meters per Minute",   @"mpm"]);
            registerSimple( @[ @"cpm",        @"Centimeters per Minute", @"cpm"]);
            registerSimple( @[ @"cps",        @"Centimeters per Second", @"cps"]);
            registerLinear(@[ @"centimetersPerMillisecond", @"Centimeters per Millisecond", @"cm/ms"], @"mps", 10., 0.);
        }

        //distance
        registerLinear( @[ @"development",@"Development",@"m"],  @"meter", 1.0,           0.0);
        registerLinear( @[ @"stride",    @"Stride",     @"m" ],  @"meter", 1.0,           0.0);
        registerLinear( @[ @"strideyd",  @"Strideyd",   @"yd"],  @"meter", GCUNIT_YARD,   0.0);
        registerLinea0( @[ @"meter",     @"Meters",     @"m" ],  @"meter", 1.0,           0.0);
        registerLinear( @[ @"mile",      @"Miles",      @"mi"],  @"meter", GCUNIT_MILES,  0.0);
        registerLinear( @[ @"kilometer", @"Kilometers", @"km"],  @"meter", 1000.,         0.0);
        registerLinear( @[ @"foot",      @"Feet",       @"ft"],  @"meter", GCUNIT_FOOT,   0.0);
        registerLinear( @[ @"yard",      @"Yards",      @"yd"],  @"meter", GCUNIT_YARD,   0.0);
        registerLinear( @[ @"inch",      @"Inches",     @"in"],  @"meter", GCUNIT_INCHES, 0.0);
        registerLinea1( @[ @"centimeter",@"Centimeters",@"cm"],  @"meter", 0.01,          0.0);
        registerLinea1( @[ @"millimeter",@"Millimeter",@"mm"],   @"meter", 0.001,         0.0);
        registerLinea0( @[ @"floor",     @"Floor",      @"floors"],    @"meter", 3.0,           0.0);

        //mass
        registerLinear( @[ @"kilogram", @"Kilograms", @"kg"],  @"kilogram", 1.0, 0.0);
        registerLinear( @[ @"pound",    @"Pounds",    @"lbs"], @"kilogram", GCUNIT_POUND, 0.0);
        registerLinear( @[ @"gram",     @"Gram",      @""],    @"kilogram", 0.001, 0.0);

        // temperature
        registerLinea0( @[ @"celcius",    @"°Celsius",    @"°C"], @"fahrenheit", 1.8,      32.0);
        registerLinea0( @[ @"fahrenheit", @"°Fahrenheit", @"°F"], @"fahrenheit", 1.,     0.0);

        // dates
        registerDate(@"date",      NSDateFormatterMediumStyle, NSDateFormatterNoStyle, nil);
        registerDate(@"dateshort", NSDateFormatterShortStyle,  NSDateFormatterNoStyle, nil);
        registerDate(@"datetime",  NSDateFormatterShortStyle, NSDateFormatterMediumStyle, nil);
        registerDaCa(@"datemonth", NSDateFormatterNoStyle,     NSDateFormatterNoStyle, @"MMM yy", NSCalendarUnitMonth);
        registerDaCa(@"dateyear", NSDateFormatterNoStyle,     NSDateFormatterNoStyle, @"yyyy",    NSCalendarUnitYear);

        registerTofD(@"timeofday");

        registerCalUnit(@"weekly", NSCalendarUnitWeekOfYear);
        registerCalUnit(@"monthly", NSCalendarUnitMonth);
        registerCalUnit(@"yearly", NSCalendarUnitYear);

        if (allUnitSet) {
            //storage
            registerSimple( @[ @"byte",     @"bytes",     @"b"]);
            registerSimple( @[ @"megabyte", @"megabytes", @"Mb"]);
            registerSimple( @[ @"terabyte", @"terrabytes",@"tb"]);
            registerSimple( @[ @"kilobyte", @"kilobytes", @"kb"]);
            registerSimple( @[ @"gigabyte", @"gigabytes", @"gb"]);

            // tennis
            registerSimpl0( @[ @"shots", @"shots", @"shots" ] );
        }

        // need both registered, so do after initial register;
        [_unitsRegistry[@"minute"] setCompoundUnit:_unitsRegistry[@"hour"]];
        [_unitsRegistry[@"second"] setCompoundUnit:_unitsRegistry[@"minute"]];
        [_unitsRegistry[@"meter"]  setCompoundUnit:_unitsRegistry[@"kilometer"]];
        [_unitsRegistry[@"yard"]   setCompoundUnit:_unitsRegistry[@"mile"]];
        [_unitsRegistry[@"centimeter"]   setCompoundUnit:_unitsRegistry[@"meter"]];
        [_unitsRegistry[@"second"] setAxisBase:60.];
        [_unitsRegistry[@"minperkm"] setAxisBase:1./60.];
        [_unitsRegistry[@"minpermile"] setAxisBase:1./60.];

        [_unitsRegistry[@"step"] setEnableNumberAbbreviation:true];

        // Fill in the proper weighting when doing sum
        GCUnit * speed = _unitsRegistry[@"mps"];
        GCUnit * bpm = _unitsRegistry[@"bpm"];
        GCUnit * spm = _unitsRegistry[@"stepsPerMinute"];
        GCUnit * rpm = _unitsRegistry[@"rpm"];

        for (GCUnit * unit in _unitsRegistry.allValues) {
            unit.sumWeightBy = GCUnitSumWeightByCount;

            if( [unit canConvertTo:speed]){
                if( unit.betterIsMin ){
                    unit.sumWeightBy = GCUnitSumWeightByDistance;
                }else{
                    unit.sumWeightBy = GCUnitSumWeightByTime;
                }
            }
            if( [unit canConvertTo:bpm] || [unit canConvertTo:spm] || [unit canConvertTo:rpm]){
                unit.sumWeightBy = GCUnitSumWeightByTime;
            }
        }
    }
}


@implementation GCUnit

#if !__has_feature(objc_arc)
-(void)dealloc{
    [_key release];
    [_display release];
    [_abbr release];
    [_fractionUnit release];
    [_compoundUnit release];
    [_referenceUnit release];

    [super dealloc];
}
#endif

-(instancetype)init{
    return [super init];
}

-(GCUnit*)initWithArray:(NSArray*)aArray{
    self = [super init];
    if (self) {
        self.key = aArray[0];
        self.display = aArray[1];
        self.abbr = aArray[2];
        self.axisBase = 1.;
        if (aArray.count > 3) {
            self.fractionUnit = [GCUnit unitForKey:aArray[3]];
            _format = GCUnitTimeFormat;
        }else{
            _fractionUnit = nil;
        }
        if (aArray.count > 4) {
            self.compoundUnit = [GCUnit unitForKey:aArray[4]];
            _format = GCUnitTimeFormat;
        }else{
            _compoundUnit = nil;
        }
    }
    return self;
}


#pragma mark - Description and debug

-(NSString*)description{
    return _key;
}
-(NSString*)debugDescription{
    return _key;
}
#pragma mark - Comparison

-(NSComparisonResult)compare:(GCUnit*)other{
    return [self.key compare:other.key];
}
-(BOOL)isEqualToUnit:(GCUnit*)otherUnit{
    return [self.key isEqualToString:otherUnit.key];
}
- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [_key isEqualToString:[other key]];
}
-(NSUInteger)hash{
    return [_key hash];
}

#pragma mark - Axis

-(double)axisKnobSizeFor:(double)range numberOfKnobs:(NSUInteger)n{
    // default
    if (n<2 || fabs(range)<1.e-12) {
        return 0.;
    }
    if(self.axisBase != 0.){
        double count = n-1.;
        double base = self.axisBase;

        double unrounded = range/count/base;
        double x = ceil(log10(unrounded)-1.);

        double pow10x = pow(10., x);
        double roundedRange = unrounded/pow10x;

        if (roundedRange < 1.5) {
            roundedRange = 1.;
        }else if (roundedRange < 3){
            roundedRange = 2.;
        }else if (roundedRange < 7) {
            roundedRange = 5.;
        }else{
            roundedRange = 10.;
        }

        return roundedRange*base*pow10x;
    }else{
        double count = n-1.;
        double unrounded = range/count;
        double x = ceil(log10(unrounded)-1.);

        double pow10x = pow(10., x);
        double roundedRange = ceil(unrounded/pow10x)*pow10x;
        return roundedRange;
    }
}

-(NSArray*)axisKnobs:(NSUInteger)nKnobs min:(double)x_min_input max:(double)x_max extendToKnobs:(BOOL)extend{

    double x_min = x_min_input;

    NSUInteger x_nKnobs = MIN(nKnobs, 100U);

    double x_knobSize = [self axisKnobSizeFor:x_max-x_min numberOfKnobs:x_nKnobs];
    if (fabs(x_knobSize)<EPS) {
        x_knobSize = x_min/2.;
        x_min /= 2.;
        if (fabs(x_knobSize)<EPS) {
            // if still 0, use arbitrary size, protect divition by 0
            x_knobSize = 1.;
        }
    }


    double x_knob_min = floor(x_min/x_knobSize)*x_knobSize;
    double x_knob_max = x_knob_min;
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:x_nKnobs];

    while (x_knob_min + x_knobSize * x_nKnobs < x_max) {
        x_nKnobs++;
    }
    [rv addObject:@(extend ? x_knob_min : x_min)];
    for (NSUInteger idx=0; idx<x_nKnobs; idx++) {
        x_knob_max += x_knobSize;
        if (x_knob_max > x_max) {
            [rv addObject:@(extend ? x_knob_max : x_max)];
            break;
        }else{
            [rv addObject:@(x_knob_max)];
        }
    }
    return rv;
}

#pragma mark - Access

+(GCUnit*)unitForKey:(NSString *)aKey{
    if (!_unitsRegistry) {
        registerUnits();
    }
    return aKey ? _unitsRegistry[aKey] : nil;
}

-(BOOL)matchString:(NSString*)aStr{
    return [_abbr isEqualToString:aStr] || [_key isEqualToString:aStr] || [_display isEqualToString:aStr];
}

+(GCUnit*)unitMatchingString:(NSString*)aStr{
    if(!_unitsRegistry){
        registerUnits();
    }

    GCUnit * rv = nil;
    for (NSString * key in _unitsRegistry) {
        GCUnit * one = _unitsRegistry[key];
        if ([one matchString:aStr]) {
            rv= one;
            break;
        }
    }
    // few special cases
    if (!rv) {
        if ([aStr isEqualToString:@"\U00002103"]) {
            rv = [GCUnit unitForKey:@"celcius"];
        }else if ([aStr isEqualToString:@"\U00002109"]){
            rv = [GCUnit unitForKey:@"fahrenheit"];
        }
    }
    return rv;
}

#pragma mark - Conversions

+(double)convert:(double)aN from:(NSString*)fUnitKey to:(NSString*)tUnitKey{
    GCUnit * from = [GCUnit unitForKey:fUnitKey];
    GCUnit * to   = [GCUnit unitForKey:tUnitKey];

    return [from convertDouble:aN toUnit:to];
}


-(BOOL)canConvertTo:(GCUnit*)otherUnit{
    return _referenceUnit != nil && otherUnit.referenceUnit && [otherUnit.referenceUnit isEqualToString:_referenceUnit];
}
-(NSArray<GCUnit*>*)compatibleUnits{
    if (!_unitsRegistry) {
        registerUnits();
    }
    NSMutableArray<GCUnit*>*rv = [NSMutableArray arrayWithObject:self];
    for (NSString * key in _unitsRegistry) {
        GCUnit * other = _unitsRegistry[key];
        if( [other.referenceUnit isEqualToString:self.referenceUnit] && ![other.key isEqualToString:self.key]){
            [rv addObject:other];
        }
    }
    return rv;
}

-(GCUnit*)commonUnit:(GCUnit*)otherUnit{
    GCUnit * rv = self;
    if (_referenceUnit != nil && otherUnit.referenceUnit && [otherUnit.referenceUnit isEqualToString:_referenceUnit]) {
        double thisInv = [self isKindOfClass:[GCUnitInverseLinear class]] ? -1. : 1.;
        double otherInv= [otherUnit isKindOfClass:[GCUnitInverseLinear class]] ? -1. : 1.;

        double thisV = [self valueToReferenceUnit:1.];
        double otherV= [otherUnit valueToReferenceUnit:1.];

        // avoid mps
        if ([self.key isEqualToString:@"mps"]) {
            thisV = 0.00001;
        }
        if ([otherUnit.key isEqualToString:@"mps"]) {
            otherV = 0.00001;
        }

        // same type: take biggest
        if (thisInv*otherInv == 1.) {
            if (otherV > thisV) {
                rv = otherUnit;
            }
        }else{ // different, favor non inverted one
            if (otherV*otherInv > thisV*thisInv) {
                rv = otherUnit;
            }
        }
    }
    return rv;
}

-(double)convertDouble:(double)aN toUnit:(GCUnit*)otherUnit{
    // cheap optimization
    if (self == otherUnit) {
        return aN;
    }

    if ([self canConvertTo:otherUnit]) {
        return [otherUnit valueFromReferenceUnit:[self valueToReferenceUnit:aN]];
    }
    return aN;
}
-(double)convertDouble:(double)aN fromUnit:(GCUnit*)otherUnit{
    // cheap optimization
    if (self == otherUnit) {
        return aN;
    }
    if ([self canConvertTo:otherUnit]) {
        return [self valueFromReferenceUnit:[otherUnit valueToReferenceUnit:aN]];
    }
    return aN;
}

-(double)valueToReferenceUnit:(double)aValue{
    return aValue;
}
-(double)valueFromReferenceUnit:(double)aValue{
    return aValue;
}

#pragma mark - Format

+(NSString*)format:(double)aN from:(NSString*)key to:(NSString*)tkey{
    double val = aN;
    if (key != nil) {
        val= [GCUnit convert:aN from:key to:tkey];
    }
    return [[GCUnit unitForKey:tkey] formatDouble:val];
}

-(NSString*)formatDouble:(double)aDbl addAbbr:(BOOL)addAbbr{
    NSArray * comp = [self formatComponentsForDouble:aDbl];
    if (addAbbr) {
        return [comp componentsJoinedByString:@" "];
    }else{
        if (comp.count==0) {
            return @"ERROR";
        }else{
            return comp[0];
        }
    }
}

-(NSArray*)formatComponentsForDouble:(double)aDbl{
    NSNumberFormatter * formatter = nil;

    double toFormat = aDbl;
    if (self.scaling!=0.) {
        toFormat *= self.scaling;
    }
    double fraction = 0.;

    NSString * fmt = nil;
    //isTimeFormat ? @"%02.0f" : @"%.2f";
    switch (_format) {
        case GCUnitDoubleOneDigitFormat:
            fmt = @"%.1f";
            break;
        case GCunitDoubleThreeDigitFormat:
            fmt = @"%.3f";
            break;
        case GCunitDoubleTwoDigitFormat:
            fmt = @"%.2f";
            if (log10(toFormat)>=1.1) {
                fmt = @"%.1f";
            }
            break;
        case GCUnitIntegerFormat:
            fmt = @"%.0f";
            break;
        case GCUnitTimeFormat:
            fmt = @"%02.0f";
            break;
        case GCUnitDoubleFormat:
            fmt = @"%f";
            break;
    }
    if (_compoundUnit) {
        double cval = [_compoundUnit convertDouble:aDbl fromUnit:self];
        if (fabs( cval ) > 1) {
            return [_compoundUnit formatComponentsForDouble:cval];
        }
    }

    NSArray * fractComponents = nil;

    if (_fractionUnit) {
        toFormat = floor(toFormat);
        fraction = aDbl-toFormat;
        if (_format == GCUnitTimeFormat) {
            fmt = @"%02.0f";
        }else{
            fmt = @"%.0f";
        }
        double fractVal = [_fractionUnit convertDouble:fraction fromUnit:self];
        if ([_fractionUnit convertDouble:round(fractVal) toUnit:self] > (1.-EPS)) {
            // edge case, fraction is closer to next unit.
            fractVal = 0.;
            toFormat += 1.;
        }
        fractComponents = [_fractionUnit formatComponentsForDouble:fractVal];
    }

    if (toFormat >= 1000.) {
        if (self.enableNumberAbbreviation) {
            if (toFormat >= 100000.) {
                fmt = [NSString stringWithFormat:@"%@k", fmt];
                toFormat /= 1000.;
            }else{
                formatter = RZReturnAutorelease([[NSNumberFormatter alloc] init]);
                formatter.numberStyle = NSNumberFormatterDecimalStyle;
                formatter.maximumFractionDigits = 0;
            }
        }else{
            formatter = RZReturnAutorelease([[NSNumberFormatter alloc] init]);
            formatter.numberStyle = NSNumberFormatterDecimalStyle;
            formatter.maximumFractionDigits = 0;
        }
    }

    NSMutableString * rv_val = formatter ? [NSMutableString stringWithString:[formatter stringFromNumber:@(toFormat)]]
                                         : [NSMutableString stringWithFormat:fmt, toFormat];

    NSMutableArray * rv = [NSMutableArray arrayWithObject:rv_val];

    if (_fractionUnit) {
        if (_format == GCUnitTimeFormat) {
            [rv_val appendString:@":"];
            [rv_val appendString:fractComponents[0]];
            if (_abbr.length > 0) {
                [rv addObject:_abbr];
            }
        }else{
            [rv addObject:_abbr];
            [rv addObjectsFromArray:fractComponents];
        }
    }else{
        if (_abbr.length > 0) {
            [rv addObject:_abbr];
        }
    }

    return rv;
}

-(NSAttributedString*)attributedStringFor:(double)aDbl valueAttr:(NSDictionary*)vAttr unitAttr:(NSDictionary*)uAttr{
    NSMutableAttributedString * rv = RZReturnAutorelease([[NSMutableAttributedString alloc] init]);
    NSArray * comp = [self formatComponentsForDouble:aDbl];
    NSUInteger done = 0;
    for (NSUInteger i=0; i<comp.count; i++) {
        NSAttributedString * next = nil;
        if (i%2==0) {
            next = RZReturnAutorelease([[NSAttributedString alloc] initWithString:comp[i] attributes:vAttr]);
        }else{
            if (uAttr) {
                next = RZReturnAutorelease([[NSAttributedString alloc] initWithString:comp[i] attributes:uAttr]);
            }
        }
        if (next) {
            if (done>0) {
                NSAttributedString * space = [[NSAttributedString alloc] initWithString:@" " attributes:uAttr?: vAttr];
                [rv appendAttributedString:space];
                RZRelease(space);
            }
            done++;
            [rv appendAttributedString:next];
        }
    }
    return rv;
}


-(NSString*)formatDouble:(double)aDbl{
    return [self formatDouble:aDbl addAbbr:true];
}

-(NSString*)formatDoubleNoUnits:(double)aDbl{
    return [self formatDouble:aDbl addAbbr:false];
}

#pragma mark - Unit Systems

-(GCUnit*)unitForSystem:(gcUnitSystem)system{
    if (_unitsImperial == nil) {
        buildUnitSystemCache();
    }
    NSString * converted = nil;
    switch (system) {
        case GCUnitSystemImperial:
            converted = _unitsImperial[_key];
            break;
        case GCUnitSystemMetric:
            converted = _unitsMetrics[_key];
            break;
        default:
            break;
    }

    return converted ? [GCUnit unitForKey:converted] : self;
}

-(gcUnitSystem)system{
    if (_unitsImperial == nil) {
        buildUnitSystemCache();
    }
    // Dictionary are equivalent unit, so if exist it means it's the
    // other system..
    if (_unitsImperial[_key] ) {
        return GCUnitSystemMetric;
    }else if (_unitsMetrics[_key]){
        return GCUnitSystemImperial;
    }else{
        return GCUnitSystemDefault;
    }
}

-(GCUnit*)unitForGlobalSystem{
    return [self unitForSystem:globalSystem];
}
+(void)setGlobalSystem:(gcUnitSystem)system{
    globalSystem = system;
}
+(gcUnitSystem)getGlobalSystem{
    return globalSystem;
}
#pragma mark - Configuration

+(void)setCalendar:(NSCalendar*)cal{
    for (NSString * key in @[@"datemonth",@"dateyear",@"weekly",@"monthly",@"yearly",@"timeofday"]) {
        id unit = [GCUnit unitForKey:key];
        if ([unit respondsToSelector:@selector(setCalendar:)]) {
            [unit setCalendar:cal];
        }
    }
}


+(NSArray*)strideStyleDescriptions{
    return @[NSLocalizedString(@"Same Foot",     @"Stride Style"),
             NSLocalizedString(@"Between Feet",  @"Stride Style")
             ];
}
+(void)setStrideStyle:(GCUnitStrideStyle)style{
    if (!_unitsRegistry) {
        registerUnits();
    }

    if (style < GCUnitStrideEnd) {
        double scaleStride[GCUnitStrideEnd] = { 1., 0.5 };
        double scaleSteps[GCUnitStrideEnd]  = { 1., 2.  };
        double scaleDoubleSteps[GCUnitStrideEnd]  = { 0.5, 1.  };

        GCUnit * stride      = _unitsRegistry[@"stride"];
        GCUnit * strideyd    = _unitsRegistry[@"strideyd"];
        GCUnit * steps       = _unitsRegistry[@"stepsPerMinute"];
        GCUnit * doublesteps = _unitsRegistry[@"doubleStepsPerMinute"];

        stride.scaling = scaleStride[style];
        strideyd.scaling = scaleStride[style];
        steps.scaling = scaleSteps[style];
        doublesteps.scaling = scaleDoubleSteps[style];
    }
}
+(GCUnitStrideStyle)strideStyle{
    return _strideStyle;
}
-(BOOL)betterIsMin{
    return false;
}

#pragma mark - Convenience

+(NSString*)formatBytes:(NSUInteger)bytes{
    NSString * unit = @"b";
    double val = bytes;
    if (val>1024.) {
        val/=1024.;
        unit = @"Kb";
    }
    if (val>1024.) {
        val/=1024.;
        unit = @"Mb";
    }
    if (val>1024.) {
        val/=1024.;
        unit = @"Gb";
    }
    return [NSString stringWithFormat:@"%.1f %@", val, unit];
}

+(double)kilojoulesFromWatts:(double)watts andSeconds:(double)seconds{
    // http://www.rapidtables.com/convert/electric/watt-to-kj.htm
    return watts * seconds/1000.;
}

+(double)wattsFromKilojoules:(double)kj andSeconds:(double)seconds{
    return kj*1000./seconds;
}

+(double)stepsForCadence:(double)cadence andSeconds:(double)seconds{
    return cadence * seconds / 60.;
}
+(double)cadenceForSteps:(double)steps andSeconds:(double)seconds{
    return  steps * 60. / seconds;
}

GCUNITFORKEY(kilobyte);
GCUNITFORKEY(year);
GCUNITFORKEY(kilocalorie);
GCUNITFORKEY(centimeter);
GCUNITFORKEY(megabyte);
GCUNITFORKEY(ms);
GCUNITFORKEY(sec100m);
GCUNITFORKEY(mile);
GCUNITFORKEY(yard);
GCUNITFORKEY(joule);
GCUNITFORKEY(dateyear);
GCUNITFORKEY(kph);
GCUNITFORKEY(millimeter);
GCUNITFORKEY(date);
GCUNITFORKEY(timeofday);
GCUNITFORKEY(mps);
GCUNITFORKEY(meterperhour);
GCUNITFORKEY(stride);
GCUNITFORKEY(foot);
GCUNITFORKEY(shots);
GCUNITFORKEY(datetime);
GCUNITFORKEY(numberOfActivities);
GCUNITFORKEY(stepsPerMinute);
GCUNITFORKEY(hydph);
GCUNITFORKEY(te);
GCUNITFORKEY(sampleCount);
GCUNITFORKEY(minpermile);
GCUNITFORKEY(cpm);
GCUNITFORKEY(secperkm);
GCUNITFORKEY(strideyd);
GCUNITFORKEY(mph);
GCUNITFORKEY(dd);
GCUNITFORKEY(revolution);
GCUNITFORKEY(inch);
GCUNITFORKEY(strokesPerMinute);
GCUNITFORKEY(datemonth);
GCUNITFORKEY(doubleStepsPerMinute);
GCUNITFORKEY(kilogram);
GCUNITFORKEY(dimensionless);
GCUNITFORKEY(minute);
GCUNITFORKEY(secpermile);
GCUNITFORKEY(min100m);
GCUNITFORKEY(second);
GCUNITFORKEY(celcius);
GCUNITFORKEY(percent);
GCUNITFORKEY(minperkm);
GCUNITFORKEY(sec100yd);
GCUNITFORKEY(hour);
GCUNITFORKEY(feetperhour);
GCUNITFORKEY(gigabyte);
GCUNITFORKEY(yearly);
GCUNITFORKEY(semicircle);
GCUNITFORKEY(kilojoule);
GCUNITFORKEY(day);
GCUNITFORKEY(step);
GCUNITFORKEY(radian);
GCUNITFORKEY(centimetersPerMillisecond);
GCUNITFORKEY(meter);
GCUNITFORKEY(pound);
GCUNITFORKEY(bpm);
GCUNITFORKEY(dateshort);
GCUNITFORKEY(strideRate);
GCUNITFORKEY(mpm);
GCUNITFORKEY(development);
GCUNITFORKEY(min100yd);
GCUNITFORKEY(cps);
GCUNITFORKEY(watt);
GCUNITFORKEY(byte);
GCUNITFORKEY(hmph);
GCUNITFORKEY(volt);
GCUNITFORKEY(fahrenheit);
GCUNITFORKEY(gram);
GCUNITFORKEY(weekly);
GCUNITFORKEY(terabyte);
GCUNITFORKEY(monthly);
GCUNITFORKEY(rpm);
GCUNITFORKEY(kilometer);


@end

#pragma mark -
@implementation GCUnitLinear
@synthesize multiplier,offset;

+(GCUnitLinear*)unitLinearWithArray:(NSArray*)defs reference:(NSString*)ref multiplier:(double)aMult andOffset:(double)aOffset{
    GCUnitLinear * rv = RZReturnAutorelease([[GCUnitLinear alloc] initWithArray:defs]);
    if (rv) {
        rv.multiplier = aMult;
        rv.offset = aOffset;
        rv.referenceUnit = ref;
    }
    return rv;
}

-(double)valueToReferenceUnit:(double)aValue{
    // Multiplier is how many reference unit in unit
    // km mult=1000 m (ref unit=m)
    // x km -> x * 1000 m
    // x m  -> x / 1000 km
    // miles mult = 1609m (ref unit=m)
    // x miles -> x*1609 m
    // x m -> x/1609m
    // x km -> x*1000 m / 1609m
    return aValue * multiplier + offset;
}
-(double)valueFromReferenceUnit:(double)aValue{
    return (aValue-offset) / multiplier;
}

@end

#pragma mark -
@implementation GCUnitInverseLinear
@synthesize multiplier,offset;

+(GCUnitInverseLinear*)unitInverseLinearWithArray:(NSArray*)defs reference:(NSString*)ref multiplier:(double)aMult andOffset:(double)aOffset{
    GCUnitInverseLinear * rv = RZReturnAutorelease([[GCUnitInverseLinear alloc] initWithArray:defs]) ;
    if (rv) {
        rv.multiplier = aMult;
        rv.offset = aOffset;
        rv.referenceUnit = ref;
    }
    return rv;
}
-(BOOL)betterIsMin{
    return true;
}

-(double)valueToReferenceUnit:(double)aValue{
    return 1./aValue * multiplier + offset;
}
-(double)valueFromReferenceUnit:(double)aValue{
    return 1./ aValue * multiplier - offset;
}

@end

#pragma mark -
@implementation GCUnitDate
@synthesize dateFormatter;
#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_calendar release];
    [dateFormatter release];
    [super dealloc];
}
#endif

-(double)axisKnobSizeFor:(double)range numberOfKnobs:(NSUInteger)n{
    if (self.useCalendarUnit) {
        if (self.calendarUnit == NSCalendarUnitWeekOfYear || self.calendarUnit == NSCalendarUnitMonth) {
            double oneday = 24.*60.*60.;
            return ceil(range/n/oneday)* oneday;
        }else if(self.calendarUnit == NSCalendarUnitYear){
            double onemonth = 24.*60.*60.*365./12.;
            return ceil(range/n/onemonth)* onemonth;
        }
    }
    return [super axisKnobSizeFor:range numberOfKnobs:n];
}

-(NSString*)formatDouble:(double)aDbl{
    if (!dateFormatter) {
        [self setDateFormatter:RZReturnAutorelease( [[NSDateFormatter alloc] init])];
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
    }
    if (self.useCalendarUnit) {
        if (!self.calendar) {
            self.calendar = [NSCalendar currentCalendar];

        }
    }
    return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:aDbl]];
}

-(NSArray*)axisKnobs:(NSUInteger)nKnobs min:(double)x_min max:(double)x_max extendToKnobs:(BOOL)extend{

    if (self.useCalendarUnit && nKnobs > 0) {// don't bother for edge case
        if (!self.calendar) {
            self.calendar = [NSCalendar currentCalendar];
        }
        NSDate * startDate = nil;
        NSTimeInterval interval;
        [self.calendar rangeOfUnit:self.calendarUnit startDate:&startDate interval:&interval forDate:[NSDate dateWithTimeIntervalSinceReferenceDate:x_min]];
        NSDateComponents * diff = [self.calendar components:self.calendarUnit fromDate:startDate toDate:[NSDate dateWithTimeIntervalSinceReferenceDate:x_max] options:0];

        NSDateComponents * increment = RZReturnAutorelease([[NSDateComponents alloc] init]);

        NSUInteger n = 1;
        if (self.calendarUnit==NSCalendarUnitMonth) {
            n = diff.month;
            [increment setMonth:MAX(n/nKnobs,1)];
        }else if (self.calendarUnit==NSCalendarUnitWeekOfYear){
            n = diff.weekOfYear;
            [increment setWeekOfYear:MAX(n/nKnobs,1)];
        }else if (self.calendarUnit==NSCalendarUnitYear){
            n = diff.year;
            [increment setYear:MAX(n/nKnobs,1)];
        }
        n = MIN(n, 100)+1;
        NSMutableArray * rv = [NSMutableArray arrayWithCapacity:n];
        while (n > 0 && startDate.timeIntervalSinceReferenceDate<x_max) {
            n--;// protection against big while loop
            [rv addObject:@(startDate.timeIntervalSinceReferenceDate)];
            startDate = [self.calendar dateByAddingComponents:increment toDate:startDate options:0];
        }
        if (startDate.timeIntervalSinceReferenceDate>=x_max) {
            [rv addObject:@(x_max)];
        }
        return rv;
    }else{
        return [super axisKnobs:nKnobs min:x_min max:x_max extendToKnobs:extend];
    }
}


-(NSString*)formatDoubleNoUnits:(double)aDbl{
    return [self formatDouble:aDbl];
}
@end

@interface GCUnitElapsedSince ()
@property (nonatomic,retain) NSDate * since;
@property (nonatomic,retain) GCUnit * second;
@end

@implementation GCUnitElapsedSince

#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_since release];
    [_second release];
    [super dealloc];
}
#endif

+(GCUnitElapsedSince*)elapsedSince:(NSDate *)date{
    GCUnitElapsedSince * rv = RZReturnAutorelease([[GCUnitElapsedSince alloc] init]);
    if( rv ){
        rv.key = [NSString stringWithFormat:@"elapsedSince(%@)", date];
        rv.second = [GCUnit second];
        rv.since = date;
    }
    return rv;
}
/*
-(double)axisKnobSizeFor:(double)range numberOfKnobs:(NSUInteger)n{
    return [self.second axisKnobSizeFor:range numberOfKnobs:n];
}

-(NSArray*)axisKnobs:(NSUInteger)nKnobs min:(double)x_min max:(double)x_max extendToKnobs:(BOOL)extend{


    return [self.second axisKnobs:nKnobs min:(x_min - self.since.timeIntervalSinceReferenceDate) max:(x_max-self.since.timeIntervalSinceReferenceDate) extendToKnobs:extend];
}
*/
-(NSString*)formatDouble:(double)aDbl addAbbr:(BOOL)addAbbr{
    return [self.second formatDouble:(aDbl-self.since.timeIntervalSinceReferenceDate) addAbbr:addAbbr];
}


@end

#pragma mark -
@implementation GCUnitTimeOfDay
#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_calendar release];
    [_dateFormatter release];
    [super dealloc];
}
#endif

-(NSString*)formatDouble:(double)aDbl addAbbr:(BOOL)addAbbr{
    if (!_dateFormatter) {
        [self setDateFormatter:RZReturnAutorelease( [[NSDateFormatter alloc] init])];
        _dateFormatter.dateStyle = NSDateFormatterNoStyle;
        _dateFormatter.timeStyle = NSDateFormatterShortStyle;
    }
    return [_dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:aDbl]];
}

-(double)axisKnobSizeFor:(double)range numberOfKnobs:(NSUInteger)n{
    return ceil(24./n);
}

-(NSArray*)axisKnobs:(NSUInteger)nKnobs min:(double)x_min max:(double)x_max extendToKnobs:(BOOL)extend{

    if (nKnobs > 0) {// don't bother for edge case
        // |----------------------|
        // 0                      24
        //
        double size = ceil(24./(nKnobs))*3600.;
        NSDate * startDate = nil;
        NSTimeInterval interval;
        if (!self.calendar) {
            self.calendar = [NSCalendar currentCalendar];
        }
        [self.calendar rangeOfUnit:NSCalendarUnitDay startDate:&startDate interval:&interval forDate:[NSDate dateWithTimeIntervalSinceReferenceDate:x_min]];

        NSMutableArray * rv = [NSMutableArray arrayWithCapacity:nKnobs];

        for (NSUInteger i=0; i<nKnobs; i++) {
            double x = MIN(startDate.timeIntervalSinceReferenceDate+ size*(i+1), startDate.timeIntervalSinceReferenceDate+24.*3600.);

            [rv addObject:@(x)];
        }
        return rv;
    }
    return [super axisKnobs:nKnobs min:x_min max:x_max extendToKnobs:extend];
}



@end

#pragma mark -
@implementation GCUnitCalendarUnit
#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_dateFormatter release];
    [_calendar release];
    [super dealloc];
}
#endif

-(double)axisKnobSizeFor:(double)range numberOfKnobs:(NSUInteger)n{
    if (_calendarUnit == NSCalendarUnitWeekOfYear || _calendarUnit == NSCalendarUnitMonth) {
        double oneday = 24.*60.*60.;
        return ceil(range/n/oneday)* oneday;
    }else if(_calendarUnit == NSCalendarUnitYear){
        double onemonth = 24.*60.*60.*365./12.;
        return ceil(range/n/onemonth)* onemonth;
    }
    return [super axisKnobSizeFor:range numberOfKnobs:n];
}

-(NSArray*)axisKnobs:(NSUInteger)nKnobs min:(double)x_min max:(double)x_max extendToKnobs:(BOOL)extend{

    if (nKnobs > 0) {// don't bother for edge case
        double oneday = 24.*60.*60.;

        if (self.calendarUnit==NSCalendarUnitWeekOfYear){
            NSMutableArray * rv = [NSMutableArray arrayWithCapacity:7];
            for (NSUInteger i = 0; i<8; i++) {
                [rv addObject:@(oneday*i)];
            }
            return rv;
        }
    }
    return [super axisKnobs:nKnobs min:x_min max:x_max extendToKnobs:extend];
}



-(NSString*)formatDouble:(double)aDbl addAbbr:(BOOL)addAbbr{
    if (!_dateFormatter) {
        [self setDateFormatter:RZReturnAutorelease([[NSDateFormatter alloc] init])];
        _dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];

    }
    if (!_calendar) {
        self.calendar = [NSCalendar currentCalendar];
    }
    double oneday = 24.*60.*60.;
    double onemonth = oneday*365./12.;
    double day = aDbl/oneday;
    if (_calendarUnit == NSCalendarUnitYear) {
        double month = aDbl/onemonth;
        NSUInteger monthIdx = floor(month)+1;
        NSDateComponents * comp = RZReturnAutorelease([[NSDateComponents alloc] init]);
        comp.month = monthIdx;
        _dateFormatter.dateFormat = @"MMM";
        return [_dateFormatter stringFromDate:[_calendar dateFromComponents:comp]];
    }else if (_calendarUnit == NSCalendarUnitWeekOfYear){
        NSUInteger firstWeekday = _calendar.firstWeekday;
        double weekday = aDbl/oneday;
        NSDateComponents * comp = RZReturnAutorelease([[NSDateComponents alloc] init]);
        NSUInteger weekdayIdx = floor(weekday)+firstWeekday;
        comp.weekday = weekdayIdx;
        comp.weekdayOrdinal = 1;
        _dateFormatter.dateFormat = @"EEE";
        NSString * s = [_dateFormatter stringFromDate:[_calendar dateFromComponents:comp]];
        return s;
    }

    return [NSString stringWithFormat:@"%.0f", day];
}


@end

#pragma mark -
@implementation GCUnitPerformanceRange

+(GCUnitPerformanceRange*)performanceUnitFrom:(double)aMin to:(double)aMax{
    GCUnitPerformanceRange * rv = RZReturnAutorelease([[self alloc] init]);
    if (rv) {
        rv.min = aMin;
        rv.max = aMax;
    }
    return rv;
}
-(NSString*)formatDouble:(double)aDbl addAbbr:(BOOL)addAbbr{
    double val = (aDbl-self.min)/(self.max-self.min)*100.;
    return [NSString stringWithFormat:@"%.1f", val];
}

-(double)axisKnobSizeFor:(double)range numberOfKnobs:(NSUInteger)n{
    double rv = [super axisKnobSizeFor:self.max-self.min
                         numberOfKnobs:n];
    return rv;
}

-(NSArray*)axisKnobs:(NSUInteger)nKnobs min:(double)x_min max:(double)x_max extendToKnobs:(BOOL)extend{

    NSArray * rv = [super axisKnobs:nKnobs min:self.min max:self.max extendToKnobs:false];
    return rv;
}

@end
