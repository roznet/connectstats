//
//  GCNumberWithUnit+Scanner.m
//  RZUtils
//
//  Created by Brice Rosenzweig on 15/08/2020.
//  Copyright © 2020 Brice Rosenzweig. All rights reserved.
//

#import "GCNumberWithUnit+Scanner.h"

@implementation GCNumberWithUnit (Scanner)

+(GCNumberWithUnit*)numberWithUnitFromScanner:(NSScanner*)scanner{
    GCNumberWithUnit * rv = nil;
    
    double val = 0.;
    if ([scanner scanDouble:&val]) {
        rv = RZReturnAutorelease([[GCNumberWithUnit alloc] init]);
        
        rv.value = val;
        
        BOOL hasSecs = false;
        if ([scanner scanString:@":" intoString:nil]) {
            double secs;
            if ([scanner scanDouble:&secs]) {
                rv.value *= 60.;
                rv.value += secs;
                hasSecs = true;
            };
        }
        NSUInteger locBeforeUnit =scanner.scanLocation;
        GCUnit * foundUnit = nil;
        NSString * unitstr = nil;
        [scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet].invertedSet intoString:nil];
        if ([scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:&unitstr]) {
            foundUnit = [GCUnit unitMatchingString:unitstr];
            if (foundUnit) {
                if (hasSecs) {
                    // hack if has sec must be min/xx
                    rv.value/=60.;
                }
                rv.unit = foundUnit;
            }
        }
        if (!foundUnit) {
            scanner.scanLocation = locBeforeUnit;
            rv.unit = [GCUnit dimensionless];
        }
    }
    return rv;
}
@end
