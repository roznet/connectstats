//  MIT Licence
//
//  Created on 22/09/2012.
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

@interface GCStatsDataPoint : NSObject<NSCoding>
@property (nonatomic,assign) double x_data;
@property (nonatomic,assign) double y_data;
@property (nonatomic,readonly) BOOL hasValue;

+(GCStatsDataPoint*)dataPointWithDate:(NSDate*)aDate andValue:(double)aValue;
+(GCStatsDataPoint*)dataPointWithDate:(NSDate*)aDate sinceDate:(NSDate*)first andValue:(double)aValue;
+(GCStatsDataPoint*)dataPointWithX:(double)aX andY:(double)aY;
+(GCStatsDataPoint*)dataPointWithPoint:(GCStatsDataPoint*)aPoint andValue:(double)aValue;

-(NSDate*)date;
-(void)setDate:(NSDate*)aDate;
-(void)setDate:(NSDate *)aDate andValue:(double)aValue;
-(NSString*)description;
-(NSString*)descriptionWithDate;

-(void)addPoint:(GCStatsDataPoint*)otherPoint;
-(void)divideByDouble:(double)aDouble;
-(BOOL)setToMax:(GCStatsDataPoint*)otherPoint;
-(BOOL)setToMin:(GCStatsDataPoint*)otherPoint;
-(void)multiplyPoint:(GCStatsDataPoint*)otherPoint;

-(BOOL)isEqualToPoint:(GCStatsDataPoint*)other;

@end

@interface GCStatsDataPointNoValue : GCStatsDataPoint

@end
