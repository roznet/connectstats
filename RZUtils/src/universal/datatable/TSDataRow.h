//  MIT Licence
//
//  Created on 23/10/2014.
//
//  Copyright (c) 2014 Brice Rosenzweig.
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

@interface TSDataRow : NSObject
@property (nonatomic,retain) NSDictionary * row;

/**
 @brief Create Row
 @param obj NSArray of length cols.
    or NSDictionary with value for each cols
    or TSDataRow, will use the same data, not a copy
    or FMResultSet
    or id in which case will call for each column selector(col)
 */
+(TSDataRow*)rowWithObj:(id)obj andColumns:(NSArray*)cols;

-(id)valueForField:(id)field;
-(NSArray*)valuesForFields:(NSArray*)fields;

-(NSNumber*)numberForField:(id)field;
-(NSString*)stringForField:(id)field;
-(NSDate*)dateForField:(id)field;

/**
 @brief Create a new row with the current row merge with other row
 */
-(TSDataRow*)mergedWithRow:(TSDataRow*)other;

- (id)objectForKeyedSubscript:(id<NSCopying>)key;
- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key;

@end
