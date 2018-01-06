//
//  GCTestsSamples.h
//  GarminConnect
//
//  Created by Brice Rosenzweig on 01/02/2014.
//  Copyright (c) 2014 Brice Rosenzweig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCActivity.h"

@interface GCTestsSamples : NSObject
+(NSDictionary*)aggregateSample;
+(NSDictionary*)aggregateExpected;
+(GCActivity*)sampleCycling;
@end
