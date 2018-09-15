//  MIT Licence
//
//  Created on 12/02/2016.
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

/**
 Instantiate an instance with managerForTestClass: or managerForTestName:

 You then retrieve object with retrieveReferenceObject:

 Set Environment RZ_REFERENCE_OBJECT_DIR = $(SOURCE_ROOT)/GarminConnectTests/samples/ReferenceObjects
 In Scheme were needed.
 */
@interface RZRegressionManager : NSObject

/**
 Turn on or off to record or test
 */
@property (nonatomic,assign) BOOL recordMode;

/**
 @brief instantiate a manager with test name from a class
 @param cl the class to use for the name
 */
+(instancetype)managerForTestClass:(Class)cl;
/**
 @brief instantiate a manager with test name from an arbitrary string
 @param name the NSString to use for the name
 */
+(instancetype)managerForTestName:(NSString*)name;

/**
 @discussion retrieve an object from a regression file. In record mode, the object passed in
    will be saved (and returned). selector and an identifier will be used to differentiate
    the name of the object saved. One can use _cmd as selector to use the current selector.
 @param object an object that can be saved via keyed encoder. Only used in record mode
 @param cls the class of the object
 @param sel Selector that will be used to differientiate the file names
 @param ident NSString used in the file name
 @param error if nil error is not reported. Will point to an NSError if error occurs
 @return nil if error or the regression object saved. In record mode, object will be returned
 */
-(id)retrieveReferenceObject:(NSObject<NSCoding>*)object
                    forClass:(Class)cls
            selector:(SEL)sel
          identifier:(NSString*)ident
               error:(NSError**)error;


@end
