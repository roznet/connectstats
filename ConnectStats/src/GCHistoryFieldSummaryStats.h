//  MIT Licence
//
//  Created on 04/10/2012.
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
#import "GCActivity.h"

@class GCHealthMeasure;
@class GCHistoryFieldSummaryDataHolder;
@class GCActivityTypeSelection;

NS_ASSUME_NONNULL_BEGIN
// Summary of all fields stats
@interface GCHistoryFieldSummaryStats : NSObject

/**
 Summary Stats for fields in activities, all, last month, last week
 Keys will be each fields broken down the activityTypes and total in GC_TYPE_ALL
 */
@property (nonatomic,retain) NSDictionary<GCField*,GCHistoryFieldSummaryDataHolder*> * fieldData;
/**
 Array of all types found while processing activities
 */
@property (nonatomic,retain) NSArray<NSString*> * foundActivityTypes;

+(GCHistoryFieldSummaryStats*)fieldStatsWithActivities:(NSArray<GCActivity*>*)activities
                                              activityTypeSelection:(nullable GCActivityTypeSelection*)typeSelection
                                         referenceDate:(nullable NSDate*)refOrNil
                                            ignoreMode:(gcIgnoreMode)ignoreMode;
+(GCHistoryFieldSummaryStats*)fieldStatsWithHealthMeasures:(NSArray*)measures;
-(void)addHealthMeasures:(NSArray<GCHealthMeasure*>*)measures referenceDate:(nullable NSDate*)refOrNil;

-(GCHistoryFieldSummaryDataHolder*)dataForField:(GCField*)aField;

@end

NS_ASSUME_NONNULL_END
