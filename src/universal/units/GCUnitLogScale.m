//  MIT Licence
//
//  Created on 05/03/2016.
//
//  Copyright (c) 2016 Brice Rosenzweig.
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

#import "GCUnitLogScale.h"
#import "RZMacros.h"

#define FROM_LOG_SCALE(x) (pow(_base, x)-_shift)/_scale
#define TO_LOG_SCALE(x) log(x*_scale+_shift)/log(_base)

@interface GCUnitLogScale ()
@property (nonatomic,retain) GCUnit * underlyingUnit;
@property (nonatomic,assign) double base;
@property (nonatomic,assign) double scale;
@property (nonatomic,assign) double shift;

@end

@implementation GCUnitLogScale

+(GCUnitLogScale*)logScaleUnitFor:(GCUnit*)underlying base:(double)base scaling:(double)scale shift:(double)shift{
    GCUnitLogScale * rv = RZReturnAutorelease([[GCUnitLogScale alloc] init]);
    if (rv) {
        rv.underlyingUnit = underlying;
        rv.referenceUnit = underlying.key;
        rv.base = base;
        rv.scale = scale;
        rv.shift = shift;
    }
    return rv;
}


#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_underlyingUnit release];
    [super dealloc];
}
#endif

-(double)valueToReferenceUnit:(double)aVal{
    return FROM_LOG_SCALE(aVal);
}

-(double)valueFromReferenceUnit:(double)aVal{
    return TO_LOG_SCALE(aVal);
}

-(NSString*)formatDoubleNoUnits:(double)aDbl{
    double unitValue = FROM_LOG_SCALE(aDbl);
    return [self.underlyingUnit formatDoubleNoUnits:unitValue];
}

-(NSString*)formatDouble:(double)aDbl{
    double unitValue = FROM_LOG_SCALE(aDbl);
    return [self.underlyingUnit formatDouble:unitValue];
}

@end
