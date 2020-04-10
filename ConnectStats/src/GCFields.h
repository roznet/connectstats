//  MIT Licence
//
//  Created on 04/10/2012.
//
//  Copyright (c) 2012 Brice Rosenzweig.
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
#import "GCFieldsCategory.h"
#import "GCFieldsDefs.h"

@class GCField;
@class GCFieldInfo;

NS_INLINE BOOL GCActivityTypeIsDay(NSString*at){
    return [at isEqualToString:GC_TYPE_DAY];
}

NS_INLINE BOOL GCActivityTypeIsSki(NSString*at, NSString*atdetail){
    return [at isEqualToString:GC_TYPE_OTHER] && ([atdetail isEqualToString:GC_TYPE_SKI_BACK] || [atdetail isEqualToString:GC_TYPE_SKI_DOWN] || [atdetail isEqualToString:GC_TYPE_SKI_XC]);
}

@class GCFieldsForCategory;
@class GCFieldCache;

@interface GCFields : NSObject

+(GCFieldCache*)fieldCache;
+(void)setFieldCache:(GCFieldCache*)cache;

/**
 Will group the list of fields into appropriate categories
 The array will be sorted by category sort order and fields by field order within category
 @param fields is an array of GCField or NSString field Keys (in which case activityType is required
 @param activityType is required if a field key is passed instead of GCField
 */
+(NSArray<GCFieldsForCategory*>*)categorizeAndOrderFields:(NSArray*)fields forActivityType:(NSString*)activityType;

+(NSString*)activityTypeDisplay:(NSString*)activityType;

+(NSArray*)knownFieldsMatching:(NSString*)str;
+(NSDictionary<GCField*,GCFieldInfo*>*)missingPredefinedField;

+(NSString*)metaFieldDisplayName:(NSString*)metaField;
+(NSString*)activityFieldFromTrackField:(gcFieldFlag)aTrackField andActivityType:(NSString*)aAct ;
+(NSArray<GCField*>*)availableFieldsIn:(NSUInteger)flag forActivityType:(NSString*)atype;

+(NSString*)lapFieldForField:(NSString*)field;
+(NSString*)fieldForLapField:(NSString*)field andActivityType:(NSString*)aType;
+(GCUnit*)unitForLapField:(NSString*)field activityType:(NSString*)aType;

+(void)registerField:(GCField*)field displayName:(NSString*)aName andUnitName:(NSString*)uom;

/**
 used in import, can't be on GCField because used on input dictionary of fieldKeys
 */
+(BOOL)skipField:(NSString*)field  ;
+(void)ensureDbStructure:(FMDatabase*)aDb;

+(NSArray*)swimLapFields;
+(NSString*)swimLapFieldFromTrackField:(gcFieldFlag)tfield;
+(gcFieldFlag)trackFieldFromSwimLapField:(NSString*)f;
+(NSString*)swimStrokeName:(gcSwimStrokeType)tp;

+(NSString*)predefinedDisplayNameForField:(NSString*)afield andActivityType:(NSString*)atype DEPRECATED_MSG_ATTRIBUTE("Use GCField cache");
+(NSString*)predefinedUomForField:(NSString*)afield andActivityType:(NSString*)atype DEPRECATED_MSG_ATTRIBUTE("Use GCField cache");

@end
