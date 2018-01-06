//  MIT Licence
//
//  Created on 21/09/2013.
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

#import <TargetConditionals.h>
#import <Foundation/Foundation.h>

#if ! __has_feature(objc_arc)
    #define RZAutorelease(__v) ([__v autorelease])
    #define RZReturnAutorelease(__v) ([__v autorelease])
    #define RZRetain(__v) ([__v retain])
    #define RZReturnRetain(__v) ([__v retain])
    #define RZRelease(__v) ([__v release])
    #define RZSuperDealloc [super dealloc]
    #define RZWEAK assign
#else
// -fobjc-arc
    #define RZAutorelease(__v)
    #define RZReturnAutorelease(__v) __v
    #define RZRetain(__v)
    #define RZReturnRetain(__v) __v
    #define RZRelease(__v)
    #define RZSuperDealloc
    #define RZWEAK weak
#endif

#define RZDynamicCast(ptr,cl) [ptr isKindOfClass:[cl class]] ? (cl*)ptr : nil

#if TARGET_OS_IPHONE
#define RZColor UIColor
#define RZFont UIFont
#define RZImage UIImage
#define RZView UIView
#define RZBezierPath UIBezierPath
#else
#define RZColor NSColor
#define RZFont NSFont
#define RZImage NSImage
#define RZView NSView
#define RZBezierPath NSBezierPath
#endif

#if TARGET_IPHONE_SIMULATOR
#define CHECK(x,msg, ...)       if( ! x ) NSLog(msg,##__VA_ARGS__);
#else
#define CHECK(x,msg,arg)
#endif

#define RZEXECUTEUPDATE(db,cmd,...) if( ![db executeUpdate:cmd,##__VA_ARGS__] ) { RZLog( RZLogError, @"Database Error %@", [db lastErrorMessage] ); }

#define PROPERTY_SET_SELECTOR(property) NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [[property substringToIndex:1] capitalizedString], [property substringFromIndex:1]])
#define PROPERTY_GET_SELECTOR(property) NSSelectorFromString(property)

#define OBJECT_OR_STR( sel, key, default )  { NSString * T_val = [aDict objectForKey:key]; [self sel:T_val ? T_val : default]; };
#define OBJECT_OR_INT( sel, key, default )	{ NSNumber * T_val = [aDict objectForKey:key]; [self sel:T_val ? [T_val intValue] : default]; };

//#define PROFILE_ON
#ifdef PROFILE_ON
#define PROFILE_START() AppTimer * _trace_timer = [[AppTimer alloc] init];
#define PROFILE_REPORT( text ) NSLog( @"Trace %@ Time: %f", text, [_trace_timer elapsed:TIMER_INIT] );
#define PROFILE_STOP( text ) NSLog( @"Trace %@ Time: %f", text, [_trace_timer elapsed:TIMER_INIT] ); [_trace_timer release];
#else
#define PROFILE_START()
#define PROFILE_REPORT( text )
#define PROFILE_STOP( text )
#endif

#if TARGET_IPHONE_SIMULATOR
#define DEBUG_BREAK() asm("int3")
#else
#define DEBUG_BREAK()
#endif

#if TARGET_IPHONE_SIMULATOR
#   define DLog(fmt, ...) NSLog((@"%s(L%d) " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

#ifdef CGFloat
#ifdef __LP64__
NS_INLINE BOOL RZEqualsCGFloat( CGFloat val1, CGFloat val2) { return fabs( val1-val2) < 1.e-5; };
#else
NS_INLINE BOOL RZEqualsCGFloat( CGFloat val1, CGFloat val2) { return fabsf( val1-val2) < 1.e-2; };
#endif
#endif


NS_INLINE BOOL RZEqualsDouble( double val1, double val2, double eps) { return fabs( val1-val2) < eps; };

NS_INLINE BOOL RZTestOption(NSUInteger val, NSUInteger flag) { return (val&flag) == flag; };
NS_INLINE NSUInteger RZClearOption(NSUInteger val, NSUInteger flag) { return ( val & ( ~(flag))); };
NS_INLINE NSUInteger RZSetOption(NSUInteger val, NSUInteger flag) { return val | flag; };

NS_INLINE BOOL RZNilOrEqual(id a, id b) { return ( ( (a == nil) && (b == nil) ) || (b != nil && [a isEqual:b]) ); };
NS_INLINE BOOL RZNilOrEqualToString(NSString * a, NSString * b) { return ( ( (a == nil) && (b == nil) ) || (b != nil && [a isEqualToString:b]) ); };
NS_INLINE BOOL RZNilOrEqualToArray(NSArray* a, NSArray* b) { return ( ( (a == nil) && (b == nil) ) || (b != nil && [a isEqualToArray:b]) ); };
NS_INLINE BOOL RZNilOrEqualToDate(NSDate* a, NSDate* b) { return ( ( (a == nil) && (b == nil) ) || (b != nil && [a isEqualToDate:b]) ); };
