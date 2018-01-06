//  MIT Licence
//
//  Created on 21/09/2014.
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

#import "GCHealthKitActivityRequest.h"
#import "GCAppGlobal.h"
#import "GCService.h"

#ifdef GC_USE_HEALTHKIT
#import <HealthKit/HealthKit.h>
#endif
#import "GCHealthKitActivityParser.h"

/*
 *  Workout Summary Download
 *  Day Aggregated Download
 *  Workout Detail Download
 *  Day Detail Download
 */

/*
HK_EXTERN NSString * const HKQuantityTypeIdentifierStepCount NS_AVAILABLE_IOS(8_0);                 // Scalar(Count),               Cumulative
HK_EXTERN NSString * const HKQuantityTypeIdentifierDistanceWalkingRunning NS_AVAILABLE_IOS(8_0);    // Length,                      Cumulative
HK_EXTERN NSString * const HKQuantityTypeIdentifierDistanceCycling NS_AVAILABLE_IOS(8_0);           // Length,                      Cumulative
HK_EXTERN NSString * const HKQuantityTypeIdentifierBasalEnergyBurned NS_AVAILABLE_IOS(8_0);         // Energy,                      Cumulative
HK_EXTERN NSString * const HKQuantityTypeIdentifierActiveEnergyBurned NS_AVAILABLE_IOS(8_0);        // Energy,                      Cumulative
HK_EXTERN NSString * const HKQuantityTypeIdentifierFlightsClimbed NS_AVAILABLE_IOS(8_0);            // Scalar(Count),               Cumulative
HK_EXTERN NSString * const HKQuantityTypeIdentifierNikeFuel NS_AVAILABLE_IOS(8_0);                  // Scalar(Count),               Cumulative
*/

// HealthKit Field Map
//    gcFieldFlagDistance                 "SumDistance"         HKQuantityTypeIdentifierDistanceWalkingRunning
//    gcFieldFlagCadence                  "SumStep"             HKQuantityTypeIdentifierStepCount
//    gcFieldFlagAltitudeMeters           "SumFloorClimbed",    HKQuantityTypeIdentifierFlightsClimbed
//    gcFieldFlagPower                    "SumDistanceCycling"  HKQuantityTypeIdentifierDistanceCycling


@implementation GCHealthKitActivityRequest

#ifdef GC_USE_HEALTHKIT
-(NSArray*)readSampleTypes{
    return @[ [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
              [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning],
              [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling],
              [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed]
              ];
}

-(void)processResults{
    HKQuantityType * qt = [self currentQuantityType];
    if (!self.data) {
        self.data = [NSMutableDictionary dictionary];
    }
    self.data[qt.identifier] = self.results;
    if ([self isLastRequest]) {
        GCHealthKitActivityParser * parser = [GCHealthKitActivityParser healthKitActivityParserWith:self.data andOrganizer:[GCAppGlobal organizer]];
        RZLog(RZLogInfo, @"Parsed %d days", (int)parser.activities.count);
    }
    [self.delegate loginSuccess:gcWebServiceHealthStore];

    [self.delegate processDone:self];
}
#endif

@end
