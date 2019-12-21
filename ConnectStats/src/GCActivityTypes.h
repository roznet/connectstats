//  MIT Licence
//
//  Created on 01/12/2013.
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
#import "GCActivityType.h"

@interface GCActivityTypes : NSObject

+(GCActivityTypes*)activityTypes;

/**
 type for specific key. Key should be typically activityTypeDetail

 @param aType key
 @return type corresponding for key
 */
-(GCActivityType*)activityTypeForKey:(NSString*)aType;

-(BOOL)isExistingActivityType:(NSString*)aType;

-(GCActivityType*)activityTypeForGarminId:(NSUInteger)garminActivityId;
-(GCActivityType*)activityTypeForStravaType:(NSString*)stravaType;
-(GCActivityType*)activityTypeForConnectStatsType:(NSString*)input;

-(NSArray<GCActivityType*>*)allTypes;
/**
 All parent types (except root)

 @return array of types that are parent of other types
 */
-(NSArray<GCActivityType*>*)allParentTypes;
-(NSArray<NSString*>*)allTypesKeys;
-(NSArray<GCActivityType*>*)allTypesForParent:(GCActivityType*)parentType;

/**
 Add missing types from structures downloaded from garmin

 @param modern information download from modern activity types json request
 @param legacy information download from legacy activity types with display name
 @return number of new types found
 */
-(NSUInteger)loadMissingFromGarmin:(NSArray<NSDictionary*>*)modern withDisplayInfoFrom:(NSArray<NSDictionary*>*)legacy;


+(NSString*)remappedLegacy:(NSString*)activityType;
@end
