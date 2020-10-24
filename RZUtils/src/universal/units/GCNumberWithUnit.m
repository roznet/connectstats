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

#import <RZUtils/RZMacros.h>
#import <RZUtils/GCNumberWithUnit.h>

#define GC_CODER_VALUE      @"value"
#define GC_CODER_UNIT       @"unit"


@implementation GCNumberWithUnit

+(BOOL)supportsSecureCoding{
    return YES;
}

-(instancetype)init{
    return [super init];
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [self init];
    if (self) {
        self.value = [aDecoder decodeDoubleForKey:GC_CODER_VALUE];
        self.unit = [GCUnit unitForKey:[aDecoder decodeObjectOfClass:[NSString class] forKey:GC_CODER_UNIT]];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.unit.key forKey:GC_CODER_UNIT];
    [aCoder encodeDouble:self.value forKey:GC_CODER_VALUE];
}

-(GCNumberWithUnit*)initWithUnit:(GCUnit*)aU andValue:(double)aVal{
    self = [super init];
    if (self) {
        self.value = aVal;
        self.unit = aU;
    }
    return self;
}

+(GCNumberWithUnit*)numberWithUnitFromSavedDict:(NSDictionary*)dict{
    NSNumber * num = dict[GC_CODER_VALUE];
    NSString * key = dict[GC_CODER_UNIT];
    GCNumberWithUnit * rv = nil;
    if (num && key && [num isKindOfClass:[NSNumber class]] && [key isKindOfClass:[NSString class]]) {
        rv = [GCNumberWithUnit numberWithUnitName:key andValue:num.doubleValue];
    }
    return rv;
}

-(NSDictionary*)savedDict{
    return @{ GC_CODER_UNIT: self.unit.key, GC_CODER_VALUE: @(self.value)};
}

+(GCNumberWithUnit*)numberWithUnitFromString:(NSString*)toParse{
    NSScanner * scanner = [NSScanner scannerWithString:toParse];

    double value = 0.;
    GCUnit * unit = [GCUnit unitForKey:@"dimensionless"];

    BOOL valid = false;
    double val = 0.;
    if ([scanner scanDouble:&val]) {
        valid = true;
        value = val;
        BOOL hasSecs = false;
        if ([scanner scanString:@":" intoString:nil]) {
            double secs;
            if ([scanner scanDouble:&secs]) {
                value *= 60.;
                value += secs;
                hasSecs = true;
                unit = [GCUnit unitForKey:@"second"];
            };
        }
        GCUnit * foundUnit = nil;
        NSString * unitstr = nil;
        [scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet].invertedSet intoString:nil];
        if ([scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:&unitstr]) {
            foundUnit = [GCUnit unitMatchingString:unitstr];
            if (foundUnit) {
                if (hasSecs) {
                    // hack if has sec must be min/xx
                    value/=60.;
                }
                unit = foundUnit;
            }
            else{
                valid = false;
            }
        }
    }
    if (valid) {
        return [GCNumberWithUnit numberWithUnit:unit andValue:value];
    }else{
        return nil;
    }
}
#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_unit release];
    [super dealloc];
}
#endif

+(GCNumberWithUnit*)numberWithUnit:(GCUnit*)aUnit andValue:(double)aVal{
    return RZReturnAutorelease([[GCNumberWithUnit alloc] initWithUnit:aUnit andValue:aVal]);
}
+(GCNumberWithUnit*)numberWithUnitName:(NSString*)aUnit andValue:(double)aVal{
    return RZReturnAutorelease([[GCNumberWithUnit alloc] initWithUnit:[GCUnit unitForKey:aUnit] andValue:aVal]);
}


#pragma mark - Conversions

-(GCNumberWithUnit*)convertToUnit:(GCUnit*)aUnit{
    if ([_unit canConvertTo:aUnit]) {
        return [GCNumberWithUnit numberWithUnit:aUnit andValue:[aUnit convertDouble:_value fromUnit:_unit]];
    }else{
        return [GCNumberWithUnit numberWithUnit:_unit andValue:_value];
    }
}
-(GCNumberWithUnit*)convertToGlobalSystem{
    return [self convertToUnit:[_unit unitForGlobalSystem]];
}
-(GCNumberWithUnit*)convertToUnitName:(NSString*)aUnitN{
    return [self convertToUnit:[GCUnit unitForKey:aUnitN]];
}
-(GCNumberWithUnit*)convertToSystem:(gcUnitSystem)system{
    return [self convertToUnit:[_unit unitForSystem:system]];
}

-(BOOL)sameUnit:(GCNumberWithUnit*)other{
    return [_unit.key isEqualToString:other.unit.key];
}
-(NSNumber*)number{
    return @(_value);
}
-(GCUnitSumWeightBy)sumWeightBy{
    return self.unit.sumWeightBy;
}

#pragma mark - Format

-(NSAttributedString*)attributedStringWithValueAttr:(NSDictionary*)vAttr andUnitAttr:(NSDictionary*)uAttr{
    return [_unit attributedStringFor:_value valueAttr:vAttr unitAttr:uAttr];
}

-(NSString*)description{
    return [_unit formatDouble:_value];
}
-(NSString*)formatDouble{
    return [_unit formatDouble:_value];
}
-(NSString*)formatDoubleNoUnits{
    return [_unit formatDoubleNoUnits:_value];
}

#pragma mark - Operations

-(nullable GCNumberWithUnit*)numberWithUnitMultipliedBy:(double)multiplier{
    return [GCNumberWithUnit numberWithUnit:self.unit andValue:self.value * multiplier];
}
-(GCNumberWithUnit*)addNumberWithUnit:(GCNumberWithUnit*)other weight:(double)weight{
    if ([other.unit canConvertTo:self.unit]) {
        return [GCNumberWithUnit numberWithUnit:self.unit andValue:(self.value + weight*[other convertToUnit:self.unit].value)];
    };
    return nil;
}
-(nullable GCNumberWithUnit*)addNumberWithUnit:(GCNumberWithUnit*)other thisWeight:(double)w0 otherWeight:(double)w1{
    if ([other.unit canConvertTo:self.unit]) {
        return [GCNumberWithUnit numberWithUnit:self.unit andValue:(self.value * w0 + w1 *[other convertToUnit:self.unit].value)];
    };
    return nil;

}
-(GCNumberWithUnit*)maxNumberWithUnit:(GCNumberWithUnit*)other{
    if ([other.unit canConvertTo:self.unit]) {
        return [GCNumberWithUnit numberWithUnit:self.unit andValue:MAX(self.value, [[other convertToUnit:self.unit] value])];
    };
    return nil;
}

-(GCNumberWithUnit*)minNumberWithUnit:(GCNumberWithUnit*)other{
    if ([other.unit canConvertTo:self.unit]) {
        return [GCNumberWithUnit numberWithUnit:self.unit andValue:MIN(self.value, [[other convertToUnit:self.unit] value])];
    };
    return nil;
}

-(nullable GCNumberWithUnit*)nonZeroMinNumberWithUnit:(GCNumberWithUnit*)other{
    if ([other.unit canConvertTo:self.unit]) {
        GCNumberWithUnit * converted = [other convertToUnit:self.unit];
        double rv = self.value;
        BOOL selfIsZero = (fabs(self.value) < 1.0e-10);
        BOOL otherIsZero = (fabs(converted.value) < 1.0e-10);
        
        if( selfIsZero ){
            rv = other.value;
        }else{
            if( !otherIsZero ){
                rv = MIN(other.value,self.value);
            }
        }
        return [GCNumberWithUnit numberWithUnit:self.unit andValue:rv];
    };
    return nil;
}

#pragma mark - Comparison

-(BOOL)isEqualToNumberWithUnit:(GCNumberWithUnit*)other{
    double v1, v2;

    if ([other.unit canConvertTo:self.unit]) {
        v1 = self.value;
        v2 = [other convertToUnit:self.unit].value;
    }else{
        v1 = self.value;
        v2 = other.value;
    }

    double tolerance = MAX(fabs(v1),fabs(v2))*1.e-13;
    if(tolerance == 0){//if v1 or v2 == 0
        tolerance = 1.e-13;
    }
    if (fabs(v2-v1) < tolerance) {
        return true;
    }else {
        return false;
    }

}

-(NSUInteger)hash{
    return self.unit.hash + [@(self.value) hash];
}

-(BOOL)isEqual:(id)object{
    if([object isKindOfClass:[self class]]){
        return [self isEqualToNumberWithUnit:object];
    }else{
        return false;
    }
}

-(NSComparisonResult)compare:(GCNumberWithUnit*)other{
    if ([other.unit canConvertTo:self.unit]) {
        return [[self number] compare:[[other convertToUnit:self.unit] number]];
    }else{
        return [[self number] compare:[other number]];
    }
}


-(NSComparisonResult)compare:(GCNumberWithUnit*)other withTolerance:(double)eps{
    double v1, v2;
    if ([other.unit canConvertTo:self.unit]) {
        v1 = self.value;
        v2 = [other convertToUnit:self.unit].value;
    }else{
        v1 = self.value;
        v2 = other.value;
    }
    if (fabs(v2-v1) < eps) {
        return NSOrderedSame;
    }else {
        return v1 > v2 ? NSOrderedAscending : NSOrderedDescending;
    }
}
-(BOOL)isValidValue{
    return !isinf(_value) && !isnan(_value);
}



@end
