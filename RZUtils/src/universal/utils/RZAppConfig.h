//  MIT Licence
//
//  Created on 30/05/2009.
//
//  Copyright (c) None Brice Rosenzweig.
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

#define RECORDEVENT_STEP_FIRSTONLY	0
#define RECORDEVENT_STEP_EVERY		1

@interface RZAppConfig : NSObject {

}

+(NSMutableDictionary*)	settings;

+(NSArray*)				configGetArray:	(NSString*)key	defaultValue:(NSArray*)aDefault;
+(void)					configSet:		(NSString*)key  arrayVal:(NSArray*)aValue;

+(BOOL)					configGetBool:	(NSString*)key  defaultValue:(BOOL)aDefault;
+(BOOL)					configToggleBool:(NSString*)key;
+(void)					configSet:		(NSString*)key	boolVal:(BOOL)value;

+(NSString*)			configGetString:(NSString*)key	defaultValue:(NSString*)aDefault;
+(void)					configSet:		(NSString*)key	stringVal:(NSString*)aValue;

+(NSInteger)					configGetInt:	(NSString*)key	defaultValue:(NSInteger)aDefault;
+(void)					configSet:		(NSString*)key	intVal:(NSInteger)aValue;
+(NSInteger)					configIncInt:	(NSString*)key;

+(double)				configGetDouble:(NSString*)key	defaultValue:(double)aDefault;
+(void)					configSet:		(NSString*)key	doubleVal:(double)aValue;

+(NSInteger)					getEventOccurence:	(NSString*)name;
+(void)					recordEvent:		(NSString*)name every:(int)aStep;

+(void)					publishEvent:		(NSString*)name;

@end
