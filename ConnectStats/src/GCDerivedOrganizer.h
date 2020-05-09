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

@interface GCDerivedOrganizer : RZParentObject<RZChildObject>


-(GCDerivedOrganizer*)initWithDb:(FMDatabase*)aDb andThread:(dispatch_queue_t)thread NS_DESIGNATED_INITIALIZER;
-(GCDerivedOrganizer*)initForTestModeWithDb:(FMDatabase*)aDb andFilePrefix:(NSString*)filePrefix;

-(FMDatabase*)deriveddb;

/// Return time serie of best rolling series for field for all the calculated dates
/// @param field field to query
-(GCStatsSerieOfSerieWithUnits*)historicalTimeSeriesOfSeriesFor:(GCField*)field;
-(GCStatsSerieOfSerieWithUnits*)timeserieOfSeriesFor:(GCField*)field
                                        inActivities:(NSArray<GCActivity*>*)activities;

-(GCDerivedDataSerie*)derivedDataSerie:(gcDerivedType)type
                                 field:(gcFieldFlag)field
                                period:(gcDerivedPeriod)period
                               forDate:(NSDate*)date
                       andActivityType:(NSString*)aType;

-(void)processActivities:(NSArray<GCActivity*>*)activities;
-(void)processSome;

-(void)rebuildDerivedDataSerie:(gcDerivedType)type
                   forActivity:(GCActivity*)act
                  inActivities:(NSArray<GCActivity*>*)activities;

-(NSArray<NSNumber*>*)availableFieldsForType:(NSString*)aType;
-(NSArray<GCDerivedGroupedSeries*>*)groupedSeriesMatching:(GCDerivedDataSerieMatchBlock)match;

+(void)ensureDbStructure:(FMDatabase*)db;

// Debug utils
-(void)forceReprocessActivity:(NSString*)aId;


@end
