//  MIT Licence
//
//  Created on 22/09/2012.
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

#import <RZUtils/GCStatsDataPoint.h>
#import <RZUtils/RZMacros.h>

#define GC_CODER_X_DATA     @"x_data"
#define GC_CODER_Y_DATA     @"y_data"

@implementation GCStatsDataPoint
+(BOOL)supportsSecureCoding{
    return YES;
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.x_data = [aDecoder decodeDoubleForKey:GC_CODER_X_DATA];
        self.y_data = [aDecoder decodeDoubleForKey:GC_CODER_Y_DATA];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeDouble:self.x_data forKey:GC_CODER_X_DATA];
    [aCoder encodeDouble:self.y_data forKey:GC_CODER_Y_DATA];
}

+(GCStatsDataPoint*)dataPointWithDate:(NSDate*)aDate andValue:(double)aValue{
    GCStatsDataPoint * rv = RZReturnAutorelease([[self alloc] init]);
    if (rv) {
        rv.x_data = aDate.timeIntervalSinceReferenceDate;
        rv.y_data = aValue;
    }
    return rv;
}


+(GCStatsDataPoint*)dataPointWithDate:(NSDate*)aDate sinceDate:(NSDate*)first andValue:(double)aValue{
    GCStatsDataPoint * rv = [self dataPointWithDate:aDate andValue:aValue];
    if (first) {
        rv.x_data = [aDate timeIntervalSinceDate:first];
    }
    return rv;
}

+(GCStatsDataPoint*)dataPointWithX:(double)aX andY:(double)aY{
    GCStatsDataPoint * rv = RZReturnAutorelease([[self alloc] init]);
    if (rv) {
        rv.x_data = aX;
        rv.y_data = aY;
    }
    return rv;
}

+(GCStatsDataPoint*)dataPointWithPoint:(GCStatsDataPoint*)aPoint andValue:(double)aValue{
    GCStatsDataPoint * rv = RZReturnAutorelease([[aPoint.class alloc] init]);
    if (rv) {
        rv.x_data = aPoint.x_data;
        rv.y_data = aValue;
    }
    return rv;
}
-(GCStatsDataPoint*)duplicate{
    GCStatsDataPoint * rv = RZReturnAutorelease([[self.class alloc] init]);
    if (rv) {
        rv.x_data = self.x_data;
        rv.y_data = self.y_data;
        
    }
    return rv;
}

-(BOOL)hasValue{
    return true;
}
-(NSDate*)date{
    return [NSDate dateWithTimeIntervalSinceReferenceDate:_x_data];
}


-(void)setDate:(NSDate*)aDate{
    _x_data = aDate.timeIntervalSinceReferenceDate;
}
-(void)setDate:(NSDate *)aDate andValue:(double)aValue{
    _x_data = aDate.timeIntervalSinceReferenceDate;
    _y_data = aValue;
}

-(NSString*)description{
    return  [NSString stringWithFormat:@"<%@ x(%@)=%@>", NSStringFromClass(self.class), @(_x_data).stringValue, @(_y_data).stringValue];
}
-(NSString*)descriptionWithDate{
    return  [NSString stringWithFormat:@"x(%@)=%@", self.date, @(_y_data).stringValue];

}


-(void)addPoint:(GCStatsDataPoint*)otherPoint{
    _y_data += otherPoint.y_data;
}

-(void)minusPoint:(GCStatsDataPoint*)otherPoint{
    _y_data -= otherPoint.y_data;
}

-(void)multiplyPoint:(GCStatsDataPoint *)otherPoint{
    _y_data *= otherPoint.y_data;
}
-(void)divideByDouble:(double)aDouble{
    _y_data /= aDouble;
}
-(BOOL)setToMax:(GCStatsDataPoint*)otherPoint{
    BOOL rv = false;
    if (otherPoint.y_data>_y_data) {
        _y_data=otherPoint.y_data;
        rv = true;
    }
    return rv;
}
-(BOOL)setToMin:(GCStatsDataPoint*)otherPoint{
    BOOL rv = false;
    if (otherPoint.y_data<_y_data) {
        _y_data = otherPoint.y_data;
        rv= true;
    }
    return rv;
}

-(BOOL)isEqual:(id)object{
    if (self==object) {
        return true;
    }else if ([object isKindOfClass:[GCStatsDataPoint class]]){
        return [self isEqualToPoint:object];
    }else{
        return false;
    }
}

-(NSUInteger)hash{
    return @(_x_data).hash + @(_y_data).hash;
}

-(BOOL)isEqualToPoint:(GCStatsDataPoint*)other{
    return fabs(other.x_data - self.x_data) < 1.e-10 && fabs(other.y_data-self.y_data) < 1.e-8;
}
@end

@implementation GCStatsDataPointNoValue

-(BOOL)hasValue{
    return false;
}

-(NSString*)description{
    return  [NSString stringWithFormat:@"<%@ x(%@)>", NSStringFromClass(self.class), @(self.x_data).stringValue];
}
@end
