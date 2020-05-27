//  MIT Licence
//
//  Created on 24/12/2013.
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
#import "GCDerivedDataSerie.h"

extern NSString * kNOTIFY_DERIVED_END;
extern NSString * kNOTIFY_DERIVED_NEXT;

@class GCActivity;
@class GCDerivedGroupedSeries;

typedef void (^GCDerivedDidCompleteBestMatchingActivitiesBlock)(NSArray<GCActivity*>*activities);
typedef void (^GCDerivedDidCompleteBestMatchingSeriesBlock)(NSArray<GCDerivedDataSerie*>*series);

@interface GCDerivedOrganizer : RZParentObject<RZChildObject>

-(GCDerivedOrganizer*)initWithDb:(FMDatabase*)aDb andThread:(dispatch_queue_t)thread;
-(GCDerivedOrganizer*)initForTestModeWithDb:(FMDatabase*)aDb andFilePrefix:(NSString*)filePrefix;

-(FMDatabase*)deriveddb;

/// Return time serie of best rolling series for field for all the calculated dates
/// @param field field to query
-(GCStatsSerieOfSerieWithUnits*)historicalTimeSeriesOfSeriesFor:(GCField*)field;
-(GCStatsSerieOfSerieWithUnits*)timeserieOfSeriesFor:(GCField*)field
                                        inActivities:(NSArray<GCActivity*>*)activities;

-(GCDerivedDataSerie*)derivedDataSerie:(gcDerivedType)type
                                 field:(GCField*)field
                                period:(gcDerivedPeriod)period
                               forDate:(NSDate*)date;

/// find in the series of higher frequency corresponding to the best for each point in input serie
///  The resulting serie at Index i will have the serie for which the bestRolling value at index i is the best
/// @param serie serie for which to compute the best, if year will return array of monthly serie.
/// @param handler Block to call with resulting series. If nil will compute synchronously and return the values
/// @return activities array or nil if handler provided
-(NSArray<GCDerivedDataSerie*>*)bestMatchingDerivedSerieFor:(GCDerivedDataSerie*)serie completion:(GCDerivedDidCompleteBestMatchingSeriesBlock)handler;

/// find in the series of activities the activity corresponding to the point in current serie
///  The resulting serie at Index i will have the activities for which the bestRolling serie at index i is the best
/// @param serie list of activities with same index as in serie up to idx = count
/// @param activities find activities up to index count
/// @return activities array or nil if handler provided
-(NSArray<GCActivity*>*)bestMatchingActivitySerieFor:(GCDerivedDataSerie*)serie within:(NSArray<GCActivity*>*)activities completion:(GCDerivedDidCompleteBestMatchingActivitiesBlock)handler;

-(void)processActivities:(NSArray<GCActivity*>*)activities;
-(void)processSome;

/// Rebuild all the series matchin a type that contains the activity given in input
/// This will be done asynchronously if worker is provided and give notify callback to child object when done
/// @param type which type of series to rebuild (currently only works for best Rolling)
/// @param act the series for which this activity is relevant will be rebuild (month, year, all )
/// @param activities The list of activities to consider for rebuild. Note that only the activities actually impacting the rebuilt series will be used (filtered by containedActivitiesIn:)
-(void)rebuildDerivedDataSerie:(gcDerivedType)type
                   forActivity:(GCActivity*)act
                  inActivities:(NSArray<GCActivity*>*)activities;

-(NSArray<GCDerivedGroupedSeries*>*)groupedSeriesMatching:(GCDerivedDataSerieMatchBlock)match;

+(void)ensureDbStructure:(FMDatabase*)db;
-(void)updateForNewProfile;

// Debug utils
-(void)forceReprocessActivity:(NSString*)aId;


@end
