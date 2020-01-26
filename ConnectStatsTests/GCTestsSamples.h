//
//  GCTestsSamples.h
//  GarminConnect
//
//  Created by Brice Rosenzweig on 01/02/2014.
//  Copyright (c) 2014 Brice Rosenzweig. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GCActivity;

@interface GCTestsSamples : NSObject

+(NSDictionary*)aggregateSample;
+(NSDictionary*)aggregateExpected;
+(GCActivity*)sampleCycling;

+(FMDatabase*)sampleActivityDatabase:(NSString*)name;
+(NSString*)sampleActivityDatabasePath:(NSString*)name;
+(void)ensureSampleDbStructure;

@end
