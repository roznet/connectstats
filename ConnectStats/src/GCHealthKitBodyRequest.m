//  MIT Licence
//
//  Created on 22/08/2014.
//
//  Copyright (c) 2014 Brice Rosenzweig.
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

#import "GCHealthKitBodyRequest.h"
#import "GCHealthMeasure.h"
#import "GCAppGlobal.h"
#import "GCActivitiesOrganizer.h"
#import "GCHealthOrganizer.h"

#ifdef GC_USE_HEALTHKIT
#import <HealthKit/HealthKit.h>
#endif

@implementation GCHealthKitBodyRequest

#ifdef GC_USE_HEALTHKIT
-(NSArray*)readSampleTypes{
    return @[ [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass],
              [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyFatPercentage],
              [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierLeanBodyMass]
              ];
}
-(void)processResults{
    for (HKQuantitySample * sample in self.results) {
        GCHealthMeasure * hm = [GCHealthMeasure healthMeasureFromHKSample:sample];
        [[GCAppGlobal health] addHealthMeasure:hm];
    }
    [self.delegate loginSuccess:gcWebServiceHealthStore];

    [self.delegate processDone:self];
}
#endif

@end
