//  MIT Licence
//
//  Created on 28/02/2013.
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
#import "GCActivityCalculatedValue.h"
#import "GCTrackPoint.h"
#import "GCField.h"

@class GCActivity;
@class GCField;
@class GCFieldInfo;

@interface GCFieldsCalculated : NSObject

+(NSArray<GCFieldsCalculated*>*)calculatedFields;
+(void)addCalculatedFields:(GCActivity*)act;
+(void)addCalculatedFieldsToLaps:(NSArray*)laps forActivity:(GCActivity*)act;

+(NSString*)displayFieldName:(GCField*)field;

+(NSDictionary<GCField*,GCFieldInfo*>*)fieldInfoForCalculatedFields;
+(GCFieldInfo*)fieldInfoForCalculatedField:(GCField*)field;

-(GCActivityCalculatedValue*)evaluateForActivity:(GCActivity*)act;
-(GCActivityCalculatedValue*)evaluateForTrackPoint:(GCTrackPoint *)trackPoint inActivity:(GCActivity*)act;

/// Shared Implementation
-(GCField*)fieldInActivity:(GCActivity*)act;
-(NSArray<GCField*>*)inputFieldsTrackPointForActivity:(GCActivity*)act;
-(NSArray<GCField*>*)inputFieldsForActivity:(GCActivity*)act;
-(BOOL)ensureInputs:(NSArray<GCNumberWithUnit*>*)inputs;
-(BOOL)activityHasRequiredFields:(GCActivity*)act;

/// To implement in derived class
-(NSString*)fieldKey;
-(NSString*)displayName;
-(NSString*)unitName;
-(GCNumberWithUnit*)evaluateWithInputs:(NSArray<GCNumberWithUnit*>*)inputs;

-(BOOL)validForActivity:(GCActivity*)act;
-(BOOL)validForTrackPoint:(GCTrackPoint*)trackPoint inActivity:(GCActivity*)act;

/**
 Array of either NSNumber for fieldFlag or NSString for field Key

 @return Array of inputs
 */
-(NSArray*)inputFieldsTrackPoint;

-(NSArray<NSString*>*)inputFields;

@end

@interface GCFieldCalcMetabolicEfficiency : GCFieldsCalculated

@end

@interface GCFieldCalcKiloJoules : GCFieldsCalculated

@end

@interface GCFieldCalcStrideLength : GCFieldsCalculated

@end

@interface GCFieldCalcElevationGradient : GCFieldsCalculated

@end

@interface GCFieldCalcRotationDevelopment : GCFieldsCalculated

@end

