//  MIT Licence
//
//  Created on 29/09/2012.
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
#import "RZMacros.h"
#import "GCUnit.h"

NS_ASSUME_NONNULL_BEGIN

@interface GCNumberWithUnit : NSObject<NSCoding>

@property (nonatomic,assign) double value;
@property (nonatomic,retain) GCUnit * unit;

-(instancetype)init NS_DESIGNATED_INITIALIZER;
-(GCNumberWithUnit*)initWithUnit:(GCUnit*)aU andValue:(double)aVal NS_DESIGNATED_INITIALIZER;

+(GCNumberWithUnit*)numberWithUnit:(GCUnit*)aUnit andValue:(double)aVal;
+(GCNumberWithUnit*)numberWithUnitName:(NSString*)aUnit andValue:(double)aVal;
+(nullable GCNumberWithUnit*)numberWithUnitFromString:(NSString*)toParse;

+(nullable GCNumberWithUnit*)numberWithUnitFromSavedDict:(NSDictionary*)dict;
-(NSDictionary*)savedDict;

-(NSString*)formatDouble;
-(NSString*)formatDoubleNoUnits;

-(NSAttributedString*)attributedStringWithValueAttr:(NSDictionary*)vAttr andUnitAttr:(nullable NSDictionary*)uAttr;

-(GCNumberWithUnit*)convertToUnit:(GCUnit*)aUnit;
-(GCNumberWithUnit*)convertToUnitName:(NSString*)aUnit;
-(GCNumberWithUnit*)convertToGlobalSystem;
-(GCNumberWithUnit*)convertToSystem:(gcUnitSystem)system;

-(BOOL)sameUnit:(GCNumberWithUnit*)other;
-(NSNumber*)number;
-(BOOL)isValidValue;
-(GCUnitSumWeightBy)sumWeightBy;
-(nullable GCNumberWithUnit*)numberWithUnitMultipliedBy:(double)multiplier;
-(nullable GCNumberWithUnit*)addNumberWithUnit:(GCNumberWithUnit*)other weight:(double)weight;
-(nullable GCNumberWithUnit*)addNumberWithUnit:(GCNumberWithUnit*)other thisWeight:(double)w0 otherWeight:(double)w1;
-(nullable GCNumberWithUnit*)maxNumberWithUnit:(GCNumberWithUnit*)other;
-(nullable GCNumberWithUnit*)minNumberWithUnit:(GCNumberWithUnit*)other;
-(nullable GCNumberWithUnit*)nonZeroMinNumberWithUnit:(GCNumberWithUnit*)other;

-(NSComparisonResult)compare:(GCNumberWithUnit*)other;
-(NSComparisonResult)compare:(GCNumberWithUnit*)other withTolerance:(double)eps;

-(BOOL)isEqualToNumberWithUnit:(GCNumberWithUnit*)other;
@end

NS_ASSUME_NONNULL_END
