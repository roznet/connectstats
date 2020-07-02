//  MIT Licence
//
//  Created on 25/08/2014.
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
#import "GCViewConfig.h"
#import "GCHistoryFieldDataSerieConfig.h"
#import "GCStatsCalendarAggregationConfig.h"

/********
 * History Stats: zoom on a field
 *     weekly/monthly average/[total]
 *     quartiles
 */

typedef NS_ENUM(NSUInteger, gcOneFieldSecondGraph) {
    gcOneFieldSecondGraphHistory,
    gcOneFieldSecondGraphPerformance,
    gcOneFieldSecondGraphHistogram,
    gcOneFieldSecondGraphEnd
};
@class GCStatsMultiFieldConfig;

@interface GCStatsOneFieldConfig : NSObject
@property (nonatomic,retain) GCField * field;
@property (nonatomic,retain) GCField * x_field;

@property (nonatomic,retain) NSString * activityType;
@property (nonatomic,assign) gcViewChoice viewChoice;
@property (nonatomic,assign) gcOneFieldSecondGraph secondGraphChoice;
@property (nonatomic,retain) GCStatsCalendarAggregationConfig * calendarConfig;

@property (nonatomic,assign) BOOL useFilter;
@property (nonatomic,retain) NSArray * fieldOrder;

+(GCStatsOneFieldConfig*)configFromMultiFieldConfig:(GCStatsMultiFieldConfig*)multiFieldConfig;

-(GCHistoryFieldDataSerieConfig*)historyConfig;
-(GCHistoryFieldDataSerieConfig*)historyConfigXY;

-(void)nextViewChoice;

@end
