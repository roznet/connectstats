//  MIT Licence
//
//  Created on 16/08/2016.
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

#import "GCUnitTrainingZone.h"
#import "GCHealthZoneCalculator.h"

@implementation GCUnitTrainingZone

-(void)dealloc{
    [_zoneCalculator release];
    [super dealloc];
}

+(GCUnitTrainingZone*)unitTrainingZoneFor:(GCHealthZoneCalculator*)calc{
    GCUnitTrainingZone * rv = [[[GCUnitTrainingZone alloc] init] autorelease];
    if (rv) {
        rv.key = [GCHealthZoneCalculator keyForField:calc.field andSource:calc.source];
        rv.zoneCalculator = calc;
    }
    return rv;
}

-(NSString*)formatDouble:(double)aDbl addAbbr:(BOOL)addAbbr{

    NSUInteger idx = (NSUInteger)ceil(aDbl);
    GCHealthZone * zone = nil;
    double val = 0.;

    if (idx < [self.zoneCalculator.bucketSerieWithUnit count]) {
        zone = self.zoneCalculator.zones[idx];
        val = zone.floor;
    }else{
        return @"";
        /*zone = [self.zoneCalculator.zones lastObject];
         val = zone.ceiling;
         */
    }

    BOOL useName = false;
    if( useName ){
        return zone ? zone.zoneName : @"";
    }else{
        GCUnit * disp = [zone.unit unitForGlobalSystem];
        if ([disp isEqualToUnit:zone.unit]) {
            return [zone.unit  formatDouble:val];
        }else{
            return [disp formatDouble:[disp convertDouble:val fromUnit:zone.unit]];
        }
    }
}

-(double)axisKnobSizeFor:(NSUInteger)n min:(double)x_min max:(double)x_max{
    return 1.;
}

-(BOOL)betterIsMin{
    return [self.zoneCalculator betterIsMin];
}

@end
