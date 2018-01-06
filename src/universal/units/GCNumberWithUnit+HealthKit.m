//  MIT Licence
//
//  Created on 17/09/2016.
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

#import "GCNumberWithUnit+HealthKit.h"
#import "GCUnit+HealthKit.h"

@implementation GCNumberWithUnit (HealthKit)

+(GCNumberWithUnit*)numberWithUnit:(GCUnit*)unit andQuantity:(HKQuantity*)qu{
    GCNumberWithUnit * rv = nil;
    HKUnit * hku = [unit hkUnit];
    if (hku&&[qu isCompatibleWithUnit:hku]) {
        double value = [qu doubleValueForUnit:hku];
        rv = [GCNumberWithUnit numberWithUnit:unit andValue:value];
    }
    return rv;
}
-(HKQuantity*)hkQuantity{
    HKQuantity * rv = nil;
    HKUnit * hku = [self.unit hkUnit];
    if (hku) {
        rv = [HKQuantity quantityWithUnit:hku doubleValue:self.value];
    }
    return rv;
}

@end
