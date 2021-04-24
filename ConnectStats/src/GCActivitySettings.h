//  MIT Licence
//
//  Created on 30/01/2016.
//
//  Copyright (c) 2016 Brice Rosenzweig.
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
#import "GCField.h"
#import "GCActivityUpdateRecordProtocol.h"

@class GCActivity;
@class GCActivitiesOrganizer;

NS_ASSUME_NONNULL_BEGIN

@interface GCActivitySettings : NSObject

+(GCActivitySettings*)defaultsFor:(GCActivity*)act;

/**
 Filter settings for series extracted from trackpoints
 */
@property (nonatomic,retain) NSDictionary<GCField*,GCStatsDataSerieFilter*> * serieFilters;

/**
 If Yes, timeseries will be adjusted such that the average
 over a lap matches the average of the corresponding lap object
 */
@property (nonatomic,assign) BOOL adjustSeriesToMatchLapAverage;

/**
 If true, any gap of more than gapTimeInterval will be treated
 as no value in series
 */
@property (nonatomic,assign) BOOL treatGapAsNoValueInSeries;
/**
 minimum time interval treated as a gap. if 0 will then use the elapsed of last point
 */
@property (nonatomic,assign) NSTimeInterval gapTimeInterval;
/**
 * dispatch queue to use for background calculation, nil to do everything synchronously
 */
@property (nonatomic,retain,nullable) dispatch_queue_t worker;

@property (nonatomic,weak,nullable) GCActivitiesOrganizer * organizer;

@property (nonatomic,retain,nullable) NSObject<GCActivityUpdateRecordProtocol>* updateRecord;

-(void)setupWithGlobalConfig:(GCActivity*)act;
-(BOOL)shouldAdjustToMatchLapAverageForField:(GCField*)field;
-(void)disableFiltersAndAdjustments;

/**
 * Check if already report field, will only return true after first call
 */
-(BOOL)alreadyReported:(GCField*)field;


@end

NS_ASSUME_NONNULL_END
