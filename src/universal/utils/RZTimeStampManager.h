//  MIT Licence
//
//  Created on 25/03/2017.
//
//  Copyright (c) 2017 Brice Rosenzweig.
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

@class FMDatabase;

typedef NSDate * (^RZTimeStampCollector)(void);

@interface RZTimeStampManager : NSObject
/**
 @brief by default use current date
 */
@property (nonatomic,copy) RZTimeStampCollector collector;

/**
 @brief maximum number of item per query. Default = 10
 */
@property (nonatomic,assign) NSUInteger queryLimit;

/**
 @brief if true only update timestamp when key changes. Default = true
 */
@property (nonatomic,assign) bool recordChangeOnly;

+(instancetype)timeStampManagerWithDb:(FMDatabase*)db andTable:(NSString*)table;


/**
 @brief will record a new timestamp for key. If recordChangeOnly, subsequent
   call with the same key will not add a new timestamp record.
 */
-(void)recordTimeStampForKey:(NSString*)key;

/**
 @brief returns last dates when key was seen
 */
-(NSArray<NSDate*>*)lastTimeStampsForKey:(NSString*)key;
/**
 @brief returns the last keys seen in order of most recent
 */
-(NSArray<NSString*>*)lastKeysSorted;

/**
 @brief returns the last keys seen with corresponding timestamps
 */
-(NSDictionary<NSString*,NSDate*>*)lastKeysAndTimeStamps;


-(void)purgeTimeStampsOlderThan:(NSUInteger)days;

@end
