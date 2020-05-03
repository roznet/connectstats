//  MIT Licence
//
//  Created on 26/02/2013.
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
#ifdef GC_USE_HEALTHKIT
#import <HealthKit/HealthKit.h>
#endif

#define WS_KEY_TYPE     @"type"
#define WS_KEY_UNIT     @"unit"
#define WS_KEY_VALUE    @"value"
#define WS_KEY_DATE     @"date"
#define WS_KEY_GRPID    @"grpid"
#define WS_KEY_MEASURES @"measures"

#define GC_HEALTH_PREFIX @"__health"

@class GCField;
@class GCFieldInfo;
@class GCNumberWithUnit;

@interface GCHealthMeasure : NSObject

@property (nonatomic,retain) NSString * measureId;
@property (nonatomic,retain) NSDate * date;
@property (nonatomic,retain) GCField * field;
@property (nonatomic,retain) GCNumberWithUnit * value;

/**
 @brief test for healthfield,
 @param field either GCField or NSString
 */
+(BOOL)isHealthField:(id)field;
+(GCFieldInfo*)fieldInfoFromField:(GCField*)field;
+(NSDictionary<GCField*,GCFieldInfo*>*)fieldInfoForMeasureFields;

+(GCField*)weight;
+(GCField*)height;

+(GCHealthMeasure*)healthMeasureFromWithings:(NSDictionary*)dict forDate:(NSDate*)aDate andId:(NSUInteger)aId;
+(GCHealthMeasure*)healthMeasureFromResultSet:(FMResultSet*)res;
-(void)saveToDb:(FMDatabase*)db;

+(void)ensureDbStructure:(FMDatabase*)db;

#ifdef GC_USE_HEALTHKIT
+(GCHealthMeasure*)healthMeasureFromHKSample:(HKQuantitySample*)sample;
#endif
/*
+(NSString*)measureKeyFromType:(gcMeasureType)type DEPRECATED_MSG_ATTRIBUTE("Use GCField");
+(GCField*)healthFieldFromMeasureType:(gcMeasureType)type forActivityType:(NSString*)aType DEPRECATED_MSG_ATTRIBUTE("Use GCField");
+(NSString*)healthFieldKeyFromMeasureType:(gcMeasureType)type DEPRECATED_MSG_ATTRIBUTE("Use GCField");
+(GCField*)healthFieldFromMeasureType:(gcMeasureType)type DEPRECATED_MSG_ATTRIBUTE("Use GCField");
+(GCUnit*)measureUnit:(gcMeasureType)type DEPRECATED_MSG_ATTRIBUTE("Use GCField");
+(NSString*)measureName:(gcMeasureType)type DEPRECATED_MSG_ATTRIBUTE("Use GCField");
*/

@end
