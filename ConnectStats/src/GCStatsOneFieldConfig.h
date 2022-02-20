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

@property (nonatomic,assign) gcOneFieldSecondGraph secondGraphChoice;

/**
 * Used for
 *      viewChoice all, monthly, yearly, summary
 *      viewConfig how far back (3m, 6m, 1y, all)
 *              calendarConfig
 */
@property (nonatomic,readonly) GCStatsMultiFieldConfig * multiFieldConfig;

// Convenience access from multifield config
@property (nonatomic,readonly) GCStatsCalendarAggregationConfig * calendarConfig;

@property (nonatomic,readonly) gcViewChoice viewChoice;
@property (nonatomic,readonly) NSString * viewDescription;

@property (nonatomic,readonly) NSString * activityType;// DEPRECATED_MSG_ATTRIBUTE("Use ActivityType Detail");
@property (nonatomic,readonly) GCActivityType * activityTypeDetail;
//@property (nonatomic,readonly) BOOL useFilter;
@property (nonatomic,readonly) NSArray<GCField*>*fieldsForAggregation;

@property (nonatomic,assign) gcGraphChoice graphChoice;

+(GCStatsOneFieldConfig*)configFromMultiFieldConfig:(GCStatsMultiFieldConfig*)multiFieldConfig forY:(GCField*)field andX:(GCField*)xfield;
+(GCStatsOneFieldConfig*)fieldListConfigFrom:(GCStatsOneFieldConfig*)other;
-(GCStatsOneFieldConfig*)sameFieldListConfig;


-(BOOL)isEqualToConfig:(GCStatsOneFieldConfig*)other;

-(GCHistoryFieldDataSerieConfig*)historyConfig;
-(GCHistoryFieldDataSerieConfig*)historyConfigXY;

-(UIBarButtonItem*)viewChoiceButtonForTarget:(id)target action:(SEL)sel longPress:(SEL)longPressSel;
-(UIBarButtonItem*)viewConfigButtonForTarget:(id)target action:(SEL)sel longPress:(SEL)longPressSel;


-(BOOL)nextView;
-(BOOL)nextViewConfig;

@end
