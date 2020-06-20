//  MIT Licence
//
//  Created on 01/08/2014.
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
#import "GCLagPeriod.h"

@class  GCStatsDataSerieWithUnit;
@class  GCActivitiesOrganizer;
@class GCField;

@interface GCHistoryPerformanceAnalysis : NSObject

@property (nonatomic,retain) GCField * summableField;
@property (nonatomic,retain) GCField * scalingField;

@property (nonatomic,readonly,retain) NSString *seriesDescription;

@property (nonatomic,retain) GCLagPeriod * longTermPeriod;
@property (nonatomic,retain) GCLagPeriod * shortTermPeriod;

@property (nonatomic,assign) BOOL useFilter;
@property (nonatomic,retain) NSDate * fromDate;

@property (nonatomic,retain) GCStatsDataSerieWithUnit * serie;
@property (nonatomic,retain) GCStatsDataSerieWithUnit * longTermSerie;
@property (nonatomic,retain) GCStatsDataSerieWithUnit * shortTermSerie;

@property (nonatomic,readonly) NSString * activityType;

+(GCHistoryPerformanceAnalysis*)performanceAnalysisFromDate:(NSDate*)date
                                                   forField:(GCField *)field;

-(void)calculate;
-(BOOL)isEmpty;
// For Test purpose
-(void)useOrganizer:(GCActivitiesOrganizer*)organizer;
@end
