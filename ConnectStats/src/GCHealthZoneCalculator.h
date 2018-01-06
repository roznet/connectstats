//  MIT Licence
//
//  Created on 19/08/2013.
//
//  Copyright (c) 2013 Brice Rosenzweig.
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

#import <Foundation/Foundation.h>
#import "GCHealthZone.h"
#import "GCFields.h"
#import "GCField.h"

@interface GCHealthZoneCalculator : NSObject
@property (nonatomic,retain) NSArray<GCHealthZone*> * zones;
@property (nonatomic,retain) GCField * field;
@property (nonatomic,assign) gcHealthZoneSource source;

@property (nonatomic,readonly) NSString * activityType;
@property (nonatomic,readonly) NSString * key;

+(GCHealthZoneCalculator*)manualZoneCalculatorFrom:(GCHealthZoneCalculator*)other;

+(GCHealthZoneCalculator*)zoneCalculatorForZones:(NSArray<GCHealthZone*>*)zones andField:(GCField*)field;
/**
 @brief Create a zone calculator with zone between values. If names is less than values.count, empty name will be used
    values.count - 1 zones will be created, starting from values[0]
 */
+(GCHealthZoneCalculator*)zoneCalculatorForValues:(NSArray<NSNumber *> *)values
                                           inUnit:(GCUnit*)unit
                                            withNames:(NSArray<NSString*>*)names
                                            field:(GCField *)field
                                        forSource:(gcHealthZoneSource)source;


-(GCHealthZone*)zoneForNumber:(GCNumberWithUnit*)number;
/** @brief Return serie with zone number for each value in serie
    @param scale each number in the input serie is rescaled before being compared for zone thresholds
 */
-(GCStatsDataSerieWithUnit*)zoneSerieFor:(GCStatsDataSerieWithUnit*)serie withScaling:(double)scale;

-(GCStatsDataSerieWithUnit*)bucketSerieWithUnit;
-(GCStatsDataSerieWithUnit*)bucketSerieWithUnit:(GCUnit*)unit;

-(GCUnit*)unit;
+(NSString*)keyForField:(GCField*)field andSource:(gcHealthZoneSource)source;

-(BOOL)betterIsMin;
@end

