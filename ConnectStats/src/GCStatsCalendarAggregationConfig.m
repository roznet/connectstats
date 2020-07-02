//  MIT License
//
//  Created on 01/07/2020 for ConnectStats
//
//  Copyright (c) 2020 Brice Test User
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



#import "GCStatsCalendarAggregationConfig.h"
#import "GCAppGlobal.h"

@implementation GCStatsCalendarAggregationConfig

+(GCStatsCalendarAggregationConfig*)configFor:(NSCalendarUnit)aUnit referenceDate:(nullable NSDate*)referenceDate calendar:(NSCalendar*)calendar{
    GCStatsCalendarAggregationConfig * rv = [[[GCStatsCalendarAggregationConfig alloc] init] autorelease];
    if (rv) {
        rv.calendar = calendar;
        rv.referenceDate = referenceDate;
        rv.calendarUnit = aUnit;
    }
    return rv;
}

-(void)dealloc{
    [_referenceDate release];
    [_calendar release];
    
    [super dealloc];
}

+(GCStatsCalendarAggregationConfig*)globalConfigFor:(NSCalendarUnit)aUnit{
    return [GCStatsCalendarAggregationConfig configFor:aUnit referenceDate:[GCAppGlobal referenceDate] calendar:[GCAppGlobal calculationCalendar]];
}

-(GCStatsCalendarAggregationConfig*)equivalentConfigFor:(NSCalendarUnit)aUnit{
    return [GCStatsCalendarAggregationConfig configFor:aUnit referenceDate:self.referenceDate calendar:self.calendar];
}
@end
