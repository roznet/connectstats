//  MIT Licence
//
//  Created on 08/05/2016.
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

#import "GCUnit+FIT.h"
#import "RZUtils/RZUtils.h"

@implementation GCUnit (FIT)

+(GCUnit*)unitForFitUnit:(NSString*)fitUnit{
    static NSDictionary * unitMap = nil;

    if (unitMap == nil) {
        unitMap = @{
                  @"%": @"percent",
                  @"bpm": @"bpm",
                  @"counts": @"dimensionless",
                  @"cycles": @"dimensionless",
                  @"C":@"celcius",
                  @"g/d": @"dimensionless",
                  @"if": @"if",
                  @"kcal": @"kilocalorie",
                  @"lengths": @"dimensionless",
                  @"m": @"meter",
                  @"m/s": @"mps",
                  @"mm": @"millimeter",
                  @"ms": @"ms",
                  @"percent": @"percent",
                  @"rpm": @"rpm",
                  @"s": @"second",
                  @"semicircles": @"semicircle",
                  @"strides": @"dimensionless",
                  @"strides/min": @"spm",
                  @"strokes/lap": @"dimensionless",
                  @"swim": @"dimensionless",
                  @"tss": @"dimensionless",
                  @"V":@"volt",
                  @"watts": @"watt",
                  @"J":@"joule",
                  @"kg":@"kilogram",

                  };
        RZRetain(unitMap);
    }
    GCUnit * rv = nil;

    NSString * useKey = unitMap[fitUnit];
    if (useKey) {
        rv = [GCUnit unitForKey:useKey];
    }
    return rv;
}
@end
