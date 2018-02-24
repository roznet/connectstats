//  MIT Licence
//
//  Created on 21/05/2016.
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

#import "RZUtils/RZUtils.h"

NS_ASSUME_NONNULL_BEGIN

@interface FITFitFieldValue : NSObject

@property (nonatomic,strong) NSString * fieldKey;

#pragma mark - Value, only one is non nil

@property (nonatomic,strong,nullable) NSString * stringValue;
@property (nonatomic,strong,nullable) NSDate * dateValue;
@property (nonatomic,strong,nullable) GCNumberWithUnit * numberWithUnit;
@property (nonatomic,strong,nullable) NSString * enumValue;
@property (nonatomic,strong,nullable) CLLocation * locationValue;

#pragma mark - Readonly values

/**
 Will sort first: date, enum, string, numbers
 */
@property (nonatomic,readonly) NSUInteger sortCategory;

-(NSString*)displayString;
/**
 This will update current field to be a locationValue assuming
 other is the match: self field ends with _lat and complement ends with _long
 ownership of the fit::FIeld in other will be transfered, so other field can be
 lost. fieldKey with be the common prefix.

 @param other Assumme fieldKey is same prefix but with _long
 @return location field if success or nil
 */
-(nullable FITFitFieldValue*)locationFieldForComplement:(FITFitFieldValue*)other;

@end

NS_ASSUME_NONNULL_END

#if __cplusplus
#include "RZExternalCpp/RZExternalCpp.h"

@interface FITFitFieldValue (cplusplus)

+(nullable FITFitFieldValue*)fieldValueFrom:(const fit::Field&)ff;
+(nullable FITFitFieldValue*)fieldValueFromDeveloper:(const fit::DeveloperField&)ff;
-(void)setFromField:(const fit::Field& )ff;
-(void)setFromDeveloperField:(const fit::DeveloperField& )ff;
-(nullable fit::DeveloperField*)developerField;
-(nullable fit::Field*)field;
-(nullable fit::Field*)additionalField;

@end

#endif

