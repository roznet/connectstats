//  MIT Licence
//
//  Created on 01/11/2012.
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
#import "GCActivitiesOrganizer.h"
#import "GCHistoryAggregatedDataHolder.h"




@interface GCHistoryAggregatedActivityStats : NSObject

+(GCHistoryAggregatedActivityStats*)aggregatedActivitStatsForActivityType:(NSString*)activityType;

@property (nonatomic,retain) NSArray<GCActivity*> * activities;
@property (nonatomic,retain) NSString * activityType;
@property (nonatomic,assign) BOOL useFilter;

-(void)aggregate:(NSCalendarUnit)aUnit referenceDate:(NSDate*)refOrNil ignoreMode:(gcIgnoreMode)ignoreMode;
-(void)aggregate:(NSCalendarUnit)aUnit referenceDate:(NSDate*)refOrNil cutOff:(NSDate*)cutOff ignoreMode:(gcIgnoreMode)ignoreMode;
-(NSUInteger)count;
-(GCHistoryAggregatedDataHolder*)dataForIndex:(NSUInteger)idx;
-(GCHistoryAggregatedDataHolder*)dataForDate:(NSDate*)date;
-(void)setActivitiesFromOrganizer:(GCActivitiesOrganizer*)organizer;
@end
