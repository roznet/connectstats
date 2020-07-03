//  MIT Licence
//
//  Created on 15/09/2012.
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
#import "GCHistoryFieldDataSerieConfig.h"

@class GCActivitiesOrganizer;
@class GCHistoryFieldDataSerieConfig;
// Full StatsDataSerie for a field (or two: x)


@interface GCHistoryFieldDataSerie : RZParentObject<GCSimpleGraphDataSource,RZChildObject>

@property (nonatomic,retain) GCStatsDataSerieWithUnit * history;
@property (nonatomic,retain) GCStatsDataSerieWithUnit * gradientSerie;
@property (nonatomic,retain) GCStatsScaledFunction * gradientFunction;

@property (nonatomic,retain) GCHistoryFieldDataSerieConfig * config;

@property (nonatomic,readonly) NSString * fieldDisplayName;
@property (nonatomic,readonly) NSString * uom;
@property (nonatomic,readonly) NSString * x_fieldDisplayName;
@property (nonatomic,readonly) NSString * x_uom;

// Exposed for testing purpose only
@property (nonatomic,retain) GCActivitiesOrganizer * organizer;
@property (nonatomic,retain) FMDatabase * db;
@property (nonatomic,assign) BOOL dataLock;


+(GCHistoryFieldDataSerie*)historyFieldDataSerieFrom:(GCHistoryFieldDataSerie*)other;
/**
 Init with Config and load on worker
 @param config Config for loading
 @param worker NSThread or nil
 */
-(GCHistoryFieldDataSerie*)initAndLoadFromConfig:(GCHistoryFieldDataSerieConfig*)config withThread:(dispatch_queue_t)worker NS_DESIGNATED_INITIALIZER;
/**
 Init with Config. Will not trigger any load.
 */
-(GCHistoryFieldDataSerie*)initFromConfig:(GCHistoryFieldDataSerieConfig*)config NS_DESIGNATED_INITIALIZER;

/**
 Init with Config and load on worker
 @param config Config for loading
 @param worker NSThread or nil
 */
-(void)setupAndLoadForConfig:(GCHistoryFieldDataSerieConfig*)config withThread:(dispatch_queue_t)worker;

/**
 @brief return a serie where all the point after cutoff w.r.t to the unit are excluded, this allows to do MTD, YTD, etc
 @param (NSDate*)cutoff date to use as cut off
 @param (NSCalendarUnit)unit month, week, year unit within which cutoff date is used
 */
-(GCHistoryFieldDataSerie*)serieWithCutOff:(NSDate*)cutoff inCalendarUnit:(NSCalendarUnit)unit withReferenceDate:(NSDate*)refOrNil;

-(GCField*)activityField;
-(BOOL)ready;
-(BOOL)isEmpty;

-(NSString*)formattedValue:(double)aVal;
-(NSUInteger)count;
-(NSDate*)lastDate;

// Exposed for testing purpose only
-(void)loadFromOrganizer;



@end

