//  MIT Licence
//
//  Created on 30/03/2013.
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

#import "GCStatsDataSerieWithUnit.h"
#import "RZMacros.h"

#define GC_CODER_SERIE @"serie"
#define GC_CODER_UNIT @"unit"
#define GC_CODER_XUNIT @"xunit"

@implementation GCStatsDataSerieWithUnit

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.serie = [aDecoder decodeObjectForKey:GC_CODER_SERIE];
        self.unit  = [GCUnit unitForKey:[aDecoder decodeObjectForKey:GC_CODER_UNIT]];
        NSString * xKey = [aDecoder decodeObjectForKey:GC_CODER_XUNIT];
        self.xUnit = xKey ? [GCUnit unitForKey:xKey] : nil;
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.serie forKey:GC_CODER_SERIE];
    [aCoder encodeObject:self.unit.key forKey:GC_CODER_UNIT];
    if (self.xUnit) {
        [aCoder encodeObject:self.xUnit.key forKey:GC_CODER_XUNIT];
    }
}

#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_serie release];
    [_unit release];
    [_xUnit release];

    [super dealloc];
}
#endif

+(GCStatsDataSerieWithUnit*)dataSerieWithOther:(GCStatsDataSerieWithUnit*)other{
    GCStatsDataSerieWithUnit * rv = RZReturnAutorelease([[GCStatsDataSerieWithUnit alloc] init]);
    if (rv) {
        rv.unit = other.unit;
        rv.xUnit = other.xUnit;
        rv.serie = [GCStatsDataSerie dataSerieWithPointsIn:other.serie];
    }
    return rv;
}
+(GCStatsDataSerieWithUnit*)dataSerieWithUnit:(GCUnit*)unit{
    GCStatsDataSerieWithUnit * rv = RZReturnAutorelease([[GCStatsDataSerieWithUnit alloc] init]);
    if (rv) {
        rv.serie = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);
        rv.unit  = unit;
    }
    return rv;
}


+(GCStatsDataSerieWithUnit*)dataSerieWithUnit:(GCUnit*)unit andSerie:(GCStatsDataSerie*)serie{
    GCStatsDataSerieWithUnit * rv = RZReturnAutorelease([[GCStatsDataSerieWithUnit alloc] init]);
    if (rv) {
        rv.serie = serie;
        rv.unit  = unit;
    }
    return rv;
}

+(GCStatsDataSerieWithUnit*)statsDataSerieWithUnit:(GCUnit*)unit xUnit:(GCUnit*)xUnit andSerie:(GCStatsDataSerie*)serie{
    GCStatsDataSerieWithUnit * rv = RZReturnAutorelease([[GCStatsDataSerieWithUnit alloc] init]);
    if (rv) {
        rv.serie = serie;
        rv.unit  = unit;
        rv.xUnit = xUnit;
    }
    return rv;
}

+(GCStatsDataSerieWithUnit*)dataSerieWithUnit:(GCUnit*)unit xUnit:(GCUnit*)xUnit andSerie:(GCStatsDataSerie*)serie{
    GCStatsDataSerieWithUnit * rv = RZReturnAutorelease([[GCStatsDataSerieWithUnit alloc] init]);
    if (rv) {
        rv.serie = serie;
        rv.unit  = unit;
        rv.xUnit = xUnit;
    }
    return rv;
}


-(GCStatsDataSerieWithUnit*)dataSerieConvertedToUnit:(GCUnit*)unit{
    if ([self.unit isEqualToUnit:unit]) {
        return self;
    }
    if (![self.unit canConvertTo:unit]) {
        return nil;
    }
    GCStatsDataSerieWithUnit * rv = [GCStatsDataSerieWithUnit dataSerieWithUnit:unit];
    rv.xUnit = self.xUnit;

    for (GCStatsDataPoint * point in self.serie) {
        [rv.serie addDataPointWithPoint:point andValue:[unit convertDouble:point.y_data fromUnit:self.unit]];
    }
    return rv;
}

-(GCStatsDataSerieWithUnit*)dataSerieConvertedToXUnit:(GCUnit*)xUnit{
    if ([self.xUnit isEqualToUnit:xUnit]) {
        return self;
    }
    if (![self.xUnit canConvertTo:xUnit]) {
        return nil;
    }
    GCStatsDataSerieWithUnit * rv = [GCStatsDataSerieWithUnit dataSerieWithUnit:self.unit];
    rv.xUnit = xUnit;

    for (GCStatsDataPoint * point in self.serie) {
        if (point.hasValue) {
            [rv.serie addDataPointWithX:[xUnit convertDouble:point.x_data fromUnit:self.xUnit] andY:point.y_data];
        }else{
            [rv.serie addDataPointNoValueWithX:[xUnit convertDouble:point.x_data fromUnit:self.xUnit]];
        }
    }
    return rv;
}

-(void)convertToUnit:(GCUnit *)unit andXUnit:(GCUnit*)xunit{
    BOOL convertUnit  = unit            && ( ! [_unit isEqualToUnit:unit] && [_unit canConvertTo:unit] );
    BOOL convertXUnit = xunit && _xUnit && ( ! [_xUnit isEqualToUnit:xunit] && [_xUnit canConvertTo:xunit]);

    if (convertUnit || convertXUnit) {
        double lastvalid  =0.;
        double lastvalid_x=0.;
        for (GCStatsDataPoint * point in self.serie) {
            if( convertUnit){
                double converted = [unit convertDouble:point.y_data fromUnit:self.unit];
                if (isnan(converted) || isinf(converted) ) {
                    converted = lastvalid;
                }
                point.y_data = converted;
                lastvalid = converted;
            }
            if (convertXUnit) {
                double converted_x = [xunit convertDouble:point.x_data fromUnit:_xUnit];
                if (isnan(converted_x) || isinf(converted_x) ) {
                    converted_x = lastvalid_x;
                }
                point.x_data = converted_x;
                lastvalid_x = converted_x;

            }
        }
        if (convertUnit) {
            self.unit = unit;
        }
        if (convertXUnit) {
            self.xUnit = xunit;
        }
    }

}

-(void)convertToXUnit:(GCUnit*)xUnit{
    [self convertToUnit:nil andXUnit:xUnit];
}

-(void)convertToUnit:(GCUnit *)unit{
    [self convertToUnit:unit andXUnit:nil];
}
-(void)convertToCommonUnitWith:(GCUnit*)unit{
    if (![unit isEqualToUnit:self.unit]) {
        GCUnit * common = [self.unit commonUnit:unit];
        [self convertToUnit:common andXUnit:nil];
    }
}

-(void)convertToGlobalSystem{
    [self convertToUnit:[self.unit unitForGlobalSystem] andXUnit:[self.xUnit unitForGlobalSystem]];
}

-(void)addNumberWithUnit:(GCNumberWithUnit*)number forDate:(NSDate*)date{
    if(self.serie == nil){
        self.serie = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);
    }
    if (self.unit == nil) {
        self.unit = number.unit;
    }
    [self convertToCommonUnitWith:number.unit];

    GCNumberWithUnit * toAdd = [number convertToUnit:self.unit];
    double val = toAdd.value;
    if (isnan(val)||isinf(val)) {
        return;
    }
    [self.serie addDataPointWithDate:date andValue:val];
}

-(void)addNumberWithUnit:(GCNumberWithUnit*)number forX:(double)x{
    if(self.serie == nil){
        self.serie = RZReturnAutorelease([[GCStatsDataSerie alloc] init]);
    }
    if (self.unit == nil) {
        self.unit = number.unit;
    }

    [self convertToCommonUnitWith:number.unit];

    GCNumberWithUnit * toAdd = [number convertToUnit:self.unit];
    [self.serie addDataPointWithX:x andY:toAdd.value];

}

-(NSString*)description{
    return [NSString stringWithFormat:@"<%@ %@ %d points>", NSStringFromClass([self class]), self.unit, (int)[self.serie count]];
}

-(BOOL)isEqual:(id)object{
    if (self == object) {
        return true;
    }else if (object && [object isKindOfClass:[self class]]){
        return [self isEqualToSerieWithUnit:object];
    }else{
        return false;
    }
}

-(NSUInteger)hash{
    return self.unit.hash + self.xUnit.hash + self.serie.hash;
}

-(BOOL)isEqualToSerieWithUnit:(GCStatsDataSerieWithUnit*)other{
    return other != nil
    && RZNilOrEqual(self.unit, other.unit)
    && RZNilOrEqual(self.xUnit, other.xUnit)
    && RZNilOrEqual(self.serie, other.serie);
}
#pragma mark - access

-(NSUInteger)count{
    return _serie.count;
}
-(GCStatsDataPoint*)dataPointAtIndex:(NSUInteger)idx{
    return [_serie dataPointAtIndex:idx];
}
#pragma mark - stats methods

-(GCStatsDataSerieWithUnit*)movingAverage:(NSUInteger)nSamples{
    GCStatsDataSerieWithUnit * rv = RZReturnAutorelease([[GCStatsDataSerieWithUnit alloc] init]);
    if (rv) {
        rv.unit = self.unit;
        rv.xUnit = self.xUnit;
        rv.serie = [self.serie movingAverage:nSamples];
    }
    return rv;
}

-(GCStatsDataSerieWithUnit*)histogramWith:(NSUInteger)buckets{
    GCStatsDataSerieWithUnit * rv = RZReturnAutorelease([[GCStatsDataSerieWithUnit alloc] init]);
    if (rv) {
        rv.unit = self.unit;
        rv.serie = [self.serie histogramWith:buckets];
    }
    return rv;

}

-(GCStatsDataSerieWithUnit*)summedBy:(double)unit{
    GCStatsDataSerieWithUnit * rv = RZReturnAutorelease([[GCStatsDataSerieWithUnit alloc] init]);
    if (rv) {
        rv.unit = self.unit;
        rv.xUnit = self.xUnit;
        rv.serie = [self.serie summedSerieByUnit:unit fillMethod:gcStatsZero];
    }
    return rv;
}

-(GCStatsDataSerieWithUnit*)filledForUnit:(double)unit{
    GCStatsDataSerieWithUnit * rv = RZReturnAutorelease([[GCStatsDataSerieWithUnit alloc] init]);
    if (rv) {
        rv.unit = self.unit;
        rv.xUnit = self.xUnit;
        rv.serie = [self.serie filledSerieForUnit:unit fillMethod:gcStatsZero];
    }
    return rv;
}

-(GCStatsDataSerieWithUnit*)cumulative{
    GCStatsDataSerieWithUnit * rv = RZReturnAutorelease([[GCStatsDataSerieWithUnit alloc] init]);
    if (rv) {
        rv.unit = self.unit;
        rv.xUnit = self.xUnit;
        rv.serie = [self.serie cumulativeValue];
    }
    return rv;
}

-(GCStatsDataSerieWithUnit*)cumulativeDifferenceWith:(GCStatsDataSerieWithUnit*)other{

    GCStatsDataSerieWithUnit * rv = RZReturnAutorelease([[GCStatsDataSerieWithUnit alloc] init]);
    if (rv) {
        [self convertToCommonUnitWith:other.unit];
        [other convertToCommonUnitWith:self.unit];
        rv.unit = self.unit;
        rv.xUnit = self.xUnit;
        rv.serie = [self.serie cumulativeDifferenceWith:other.serie];
    }
    return rv;

}
-(GCStatsDataSerieWithUnit*)bucketWith:(GCStatsDataSerieWithUnit*)buckets{
        GCStatsDataSerieWithUnit * rv = RZReturnAutorelease([[GCStatsDataSerieWithUnit alloc] init]);
        if (rv) {
            rv.unit = self.unit;
            if ([rv.unit isEqualToUnit:buckets.unit]) {
                rv.serie = [self.serie bucketWith:buckets.serie];
            }else{
                GCStatsDataSerieWithUnit * converted = [buckets dataSerieConvertedToUnit:self.unit];
                rv.serie = [self.serie bucketWith:converted.serie];
            }
            rv.xUnit = self.unit;
        }
        return rv;

}

-(GCStatsDataSerieWithUnit*)movingAverageOrSumOf:(GCStatsDataSerieWithUnit*)rawother forUnit:(double)unit offset:(double)offset average:(BOOL)avg{
    GCStatsDataSerieWithUnit * rv = RZReturnAutorelease([[GCStatsDataSerieWithUnit alloc] init]);
    if (rv) {
        rv.unit = rawother.unit;
        rv.serie = [self.serie movingAverageOrSumOf:rawother.serie forUnit:unit offset:offset average:avg];
        rv.xUnit = self.unit;
    }
    return rv;
}


-(GCStatsDataSerieWithUnit*)filterForNonZeroIn:(GCStatsDataSerie*)other{
    GCStatsDataSerieWithUnit * rv = RZReturnAutorelease([[GCStatsDataSerieWithUnit alloc] init]);
    if (rv) {
        rv.unit = self.unit;
        rv.serie = [self.serie filterForNonZeroIn:other];
    }
    return rv;

}

+(void)reduceToCommonRange:(GCStatsDataSerieWithUnit*)serie1 and:(GCStatsDataSerieWithUnit*)serie2{
    [serie1 convertToCommonUnitWith:serie2.unit];
    [serie2 convertToCommonUnitWith:serie1.unit];

    [GCStatsDataSerie reduceToCommonRange:serie1.serie and:serie2.serie];
}

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len{
    return [self.serie countByEnumeratingWithState:state objects:buffer count:len];
}
-(GCStatsDataSerieWithUnit*)serieWithCutOff:(NSDate*)cutOff
                                   withUnit:(NSCalendarUnit)aUnit
                              referenceDate:(NSDate*)refOrNil
                                andCalendar:(NSCalendar*)calendar{
    GCStatsDataSerieWithUnit * rv = RZReturnAutorelease([[GCStatsDataSerieWithUnit alloc] init]);
    if (rv) {
        rv.unit = self.unit;
        rv.serie = [self.serie serieWithCutOff:cutOff withUnit:aUnit referenceDate:refOrNil andCalendar:calendar];
    }
    return rv;

}
-(BOOL)isStrictlyIncreasingByX{
    return [self.serie isStrictlyIncreasingByX];
}

@end
