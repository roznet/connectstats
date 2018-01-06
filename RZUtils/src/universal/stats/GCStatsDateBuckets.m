//  MIT Licence
//
//  Created on 19/12/2013.
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

#import "GCStatsDateBuckets.h"
#import "NSDate+RZHelper.h"
#import "RZLog.h"
#import "RZMacros.h"

@implementation GCStatsDateBuckets

#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_refOrNil release];
    [_componentUnit release];
    [_bucketEnd release];
    [_bucketStart release];
    [_calendar release];

    [super dealloc];
}
#endif

+(GCStatsDateBuckets*)statsDateBucketFor:(NSCalendarUnit)unit referenceDate:(NSDate*)refOrNil andCalendar:(NSCalendar*)cal{
    GCStatsDateBuckets * rv = RZReturnAutorelease([[GCStatsDateBuckets alloc] init]);
    if (rv) {
        rv.calendarUnit = unit;
        if (unit!=NSCalendarUnitYear&&unit!=NSCalendarUnitMonth&&unit!=NSCalendarUnitWeekOfYear) {
            RZLog(RZLogError, @"unsupported calendar unit %d, using month", (int)unit);
            rv.calendarUnit = NSCalendarUnitMonth;
        }
        rv.calendar = cal;
        if (refOrNil) {
            // Check ref date and set it to midnight from calc calendar
            NSDateComponents * c = [rv.calendar components:NSCalendarUnitDay fromDate:refOrNil];
            if (c.day > 28 && (unit == NSCalendarUnitMonth || NSCalendarUnitYear==unit)) {
                RZLog(RZLogWarning, @"Ref date too close to end of month %@", refOrNil);
            }
            c = [rv.calendar components:NSCalendarUnitDay+NSCalendarUnitMonth+NSCalendarUnitYear fromDate:refOrNil];
            rv.refOrNil = [rv.calendar dateFromComponents:c];
        }
    }
    return rv;
}

-(void)setComponentUnitFor:(NSInteger)value{
    if (!self.componentUnit) {
        self.componentUnit = RZReturnAutorelease([[NSDateComponents alloc] init]);
    }
    if (self.calendarUnit == NSCalendarUnitWeekOfYear) {
        (self.componentUnit).weekOfYear = value;
        (self.componentUnit).month = 0;
        (self.componentUnit).year = 0;
    }else if(self.calendarUnit == NSCalendarUnitMonth){
        (self.componentUnit).weekOfYear = 0;
        (self.componentUnit).month = value;
        (self.componentUnit).year = 0;
    }else if(self.calendarUnit == NSCalendarUnitYear){
        (self.componentUnit).weekOfYear = 0;
        (self.componentUnit).month = 0;
        (self.componentUnit).year = value;
    }

}
-(NSInteger)componentUnitValueFrom:(NSDateComponents*)comps{
    NSInteger rv = 0;
    if (self.calendarUnit == NSCalendarUnitWeekOfYear) {
        rv = comps.weekOfYear;
    }else if(self.calendarUnit == NSCalendarUnitMonth){
        rv = comps.month;
    }else if(self.calendarUnit == NSCalendarUnitYear){
        rv = comps.year;
    }
    return rv;
}


-(BOOL)bucket:(NSDate*)date{
    BOOL changedBucket = false;

    // find a date before
    if (!self.bucketStart || [self.bucketStart compare:date] == NSOrderedDescending) {
        if (self.refOrNil) {
            NSDateComponents *comps = [self.calendar components:self.calendarUnit fromDate:date  toDate:self.refOrNil  options:0];
            NSInteger diff = [self componentUnitValueFrom:comps];
            if (diff == 0 && [self.refOrNil compare:date] == NSOrderedAscending) {
                self.bucketStart = self.refOrNil;
            }else{
                if (diff >= 0) {
                    diff = -diff-1;
                }else{
                    diff = -diff;
                }
                [self setComponentUnitFor:diff];
                self.bucketStart = [self.calendar dateByAddingComponents:self.componentUnit toDate:self.refOrNil options:0];
            }
        }else{
            NSDate * start = nil;
            NSTimeInterval extends;

            [self.calendar rangeOfUnit:self.calendarUnit startDate:&start interval:&extends forDate:date];
            self.bucketStart = start;
        }
        [self setComponentUnitFor:1];
        self.bucketEnd = [self.calendar dateByAddingComponents:self.componentUnit toDate:self.bucketStart options:0];
        changedBucket = true;

        return changedBucket;
    }
    //FIX if refdate should always compute from refdate
    NSComparisonResult res = [self.bucketEnd compareCalendarDay:date include:true calendar:self.calendar];

    while ( res != NSOrderedDescending) {
        changedBucket = true;
        self.bucketStart = self.bucketEnd;
        self.bucketEnd   = [self.calendar dateByAddingComponents:self.componentUnit toDate:self.bucketStart options:0];

        res = [self.bucketEnd compareCalendarDay:date include:true calendar:self.calendar];
    }

    return changedBucket;
}
-(BOOL)contains:(NSDate*)date{
    if (!self.bucketStart) {
        return false;
    }
    return [self.bucketStart compare:date] != NSOrderedDescending && [self.bucketEnd compare:date] != NSOrderedAscending;

}

@end
