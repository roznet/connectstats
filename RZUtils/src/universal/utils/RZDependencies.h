//  MIT Licence
//
//  Created on 20/09/2010.
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
#import "RZMacros.h"

@interface RZDependencyInfo : NSObject

@property (nonatomic,retain) NSString * stringInfo;
@property (nonatomic,readonly) int intInfo;

+(RZDependencyInfo*)rzDependencyInfoWithInt:(int)aInt;
+(RZDependencyInfo*)rzDependencyInfoWithString:(NSString *)aStr;
-(NSString*)describe;

@end


@protocol RZChildObject

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo*)theInfo;

@end

@interface RZParentObject : NSObject

-(void)attach:(id<RZChildObject>)aChild;
-(void)attach:(id<RZChildObject>)aChild withString:(NSString*)aString;
-(void)attach:(id<RZChildObject>)aChild withInt:(int)aInt;
-(void)detach:(id<RZChildObject>)aChild;

/**
 Will notify all attached children with the info they attached with (or nil)
 */
-(void)notify;

/**
 Will notify all attached children such that:
 - info they attached with was nil
 - info they attached with is equal to aString
 */
-(void)notifyForString:(NSString*)aString;
/**
    Will attempt notifyForString up to maxTries within a @try block
    This is cheap but potentially useful to guard about multi threaded attach resulting into a mutation of
    the dependency list
*/
-(void)notifyForString:(NSString *)aString safeTries:(NSUInteger)maxTries;

/**
 For Debugging purpose mostly
 */
-(NSString*)describeDependencies;
-(NSString*)parentCurrentDescription;

@end
