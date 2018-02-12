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

@class GCFieldCache;

@interface GCActivityType : NSObject<NSCopying,NSCoding>

@property (nonnull,readonly) NSString * key;
@property (readonly) NSUInteger typeId;
@property (nullable,readonly) GCActivityType * parentType;

+(nullable GCFieldCache*)fieldCache;
+(void)setFieldCache:(nonnull GCFieldCache*)cache;

+(nonnull GCActivityType*)activityType:(nonnull NSString*)key typeId:(NSUInteger)typeId andParent:(nullable GCActivityType*)parent;

+(nonnull GCActivityType*)activityTypeForKey:(nonnull NSString*)key;

-(nonnull NSString*)displayName;
-(BOOL)isRootType;
-(BOOL)isSameRootType:(nonnull GCActivityType*)other;
-(nonnull GCActivityType*)rootType;
-(nonnull GCActivityType*)topSubRootType;
-(BOOL)isEqualToActivityType:(nonnull GCActivityType*)other;
/**
 Will compare to activity type string
 */
-(BOOL)isEqualToString:(nonnull NSString*)activityTypeString;
/**
 Determine if of same parent type. If either is root, then yes, as root is parent to all.
 Not that if one is parent of the other, then it will return true.

 @param other another type
 @return true or false if same parent
 */
-(BOOL)isSameParentType:(nonnull GCActivityType*)other;


// Access Convenience
+(nonnull GCActivityType*)running;
+(nonnull GCActivityType*)cycling;
+(nonnull GCActivityType*)swimming;
+(nonnull GCActivityType*)other;
+(nonnull GCActivityType*)all;
+(nonnull GCActivityType*)day;

/**
 All Types
 */
+(nonnull NSArray<GCActivityType*>*)allTypes;
/**
 All parent types (except root)

 @return array of types that are parent of other types
 */
+(nonnull NSArray<GCActivityType*>*)allParentTypes;
+(nonnull NSArray<GCActivityType*>*)allTypesForParent:(nonnull GCActivityType*)parentType;

@end
