//  MIT Licence
//
//  Created on 26/03/2016.
//
//  Copyright (c) 2016 Brice Rosenzweig.
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

@class GCField;
@class GCUnit;

@interface GCFieldInfo : NSObject

@property (nonatomic,readonly) NSString * displayName;
@property (nonatomic,readonly) GCUnit * unit;
@property (nonatomic,readonly) GCField * field;
@property (nonatomic,readonly) NSString * activityType;

+(GCFieldInfo*)fieldInfoFor:(NSString*)field type:(NSString*)aType displayName:(NSString*)aDisplayName andUnitName:(NSString*)aUom DEPRECATED_MSG_ATTRIBUTE("Use fieldInfoFor:(GCField*)");
+(GCFieldInfo*)fieldInfoFor:(GCField*)field displayName:(NSString*)aDisplayName andUnits:(NSDictionary<NSNumber*,GCUnit*>*)units;
+(GCFieldInfo*)fieldInfoForActivityType:( NSString*)activityType displayName:(NSString*)aDisplayName;

-(BOOL)match:(NSString*)str;
-(GCUnit*)unitForSystem:(gcUnitSystem)system;

@end
