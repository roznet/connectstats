//  MIT License
//
//  Created on 04/08/2020 for ConnectStats
//
//  Copyright (c) 2020 Brice Rosenzweig
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
#import "GCFields.h"
#import "GCActivity.h"

typedef NS_ENUM(NSUInteger, gcAggregatedType) {
    gcAggregatedSum = 0,
    gcAggregatedAvg = 1,
    gcAggregatedCnt = 2,
    gcAggregatedMax = 3,
    gcAggregatedMin = 4,
    gcAggregatedStd = 5,
    gcAggregatedSsq = 6,
    gcAggregatedWvg = 7,
    gcAggregatedTypeEnd = 8
};


NS_ASSUME_NONNULL_BEGIN

@interface GCHistoryAggregatedDataHolder : NSObject

@property (nonatomic,retain,nullable) NSDate * date;
@property (nonatomic,retain) NSString * activityType;

-(GCHistoryAggregatedDataHolder*)initForDate:(NSDate*)adate andFields:(NSArray<GCField*>*)fields NS_DESIGNATED_INITIALIZER;

-(void)aggregateActivity:(GCActivity*)act;
-(void)aggregateEnd:(nullable NSDate*)adate;

-(BOOL)hasField:(GCField*)field;
-(nullable GCNumberWithUnit*)numberWithUnit:(GCField*)field statType:(gcAggregatedType)tp;
/**
 * Will return preferred statistic for field.
 *  Speed will be reconstructed from distance and duration for better accurary and consistency
 */
-(nullable GCNumberWithUnit*)preferredNumberWithUnit:(GCField*)field;
-(gcAggregatedType)preferredAggregatedTypeForField:(GCField*)field;

-(NSArray<GCField*>*)availableFields;


@end


NS_ASSUME_NONNULL_END
