//  MIT Licence
//
//  Created on 06/07/2013.
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

@interface NSDateComponents (RZHelper)
/**
 Build date component by parsing string of the form [0-9][myd]
 @param str NSString string with proper format
 @return NSDateComponents if input string is value or nil
 */
+(NSDateComponents*)dateComponentsFromString:(NSString*)str;
/**
 Return the value of the component corresponding to unit
 @param unit NSCalendarUnit should be NSCalendarUnitYear, NSCalendarUnitMonth or NSCalendarUnitWeekOfYear
 @return component value or 0 if not a known NSCalendarUnit
 */
-(NSInteger)monthWeekOrYear:(NSCalendarUnit)unit;

/**
 Return component for the corresponding NSCalendarUnit (month, day, year)
 @param aUnit NSCalendarUnit should be NSCalendarUnitYear, NSCalendarUnitMonth or NSCalendarUnitWeekOfYear
 @param val NSInteger the value to set the component to
 @return component or nil if not a known NSCalendarUnit
 */
+(NSDateComponents*)dateComponentsForCalendarUnit:(NSCalendarUnit)aUnit withValue:(NSInteger)val;
@end
