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
#import <RZUtils/RZMacros.h>

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
            rv.refOrNil = refOrNil;
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

-(NSString*)description{
    if( self.bucketStart) {
        return [NSString stringWithFormat:@"<%@: [%@,%@]>", NSStringFromClass([self class]), self.bucketStart, self.bucketEnd];
    }else{
        return [NSString stringWithFormat:@"<%@: Empty>", NSStringFromClass([self class])];
    }
}

-(BOOL)bucket:(NSDate*)date{
    // if already set up and same, just continue;
    if( self.bucketStart != nil && [self.bucketStart compare:date] != NSOrderedDescending && [self.bucketEnd compare:date] == NSOrderedDescending){
        return false;
    }
    
    if (self.refOrNil) {
        if (!self.bucketStart ) {
            [self setComponentUnitFor:-1];
            self.bucketEnd = self.refOrNil;
            self.bucketStart = [self.calendar dateByAddingComponents:self.componentUnit toDate:self.bucketEnd options:0];
            [self setComponentUnitFor:1];
        }
        NSComparisonResult res = [self.bucketEnd compare:date];
        [self setComponentUnitFor:1];
        // look forwards
        while ( res != NSOrderedDescending) {
            self.bucketStart = self.bucketEnd;
            self.bucketEnd   = [self.calendar dateByAddingComponents:self.componentUnit toDate:self.bucketStart options:0];
            
            res = [self.bucketEnd compare:date];
        }
        
        res = [self.bucketStart compare:date];
        
        // look backwards
        [self setComponentUnitFor:-1];
        while ( res != NSOrderedAscending) {
            self.bucketEnd = self.bucketStart;
            self.bucketStart   = [self.calendar dateByAddingComponents:self.componentUnit toDate:self.bucketStart options:0];
            
            res = [self.bucketStart compare:date];
        }
        [self setComponentUnitFor:1];
    }else{
        NSDate * start = nil;
        NSTimeInterval extends;
        // We already know we are not in the same bucket from first test.
        [self.calendar rangeOfUnit:self.calendarUnit startDate:&start interval:&extends forDate:date];
        
        self.bucketStart = start;
        [self setComponentUnitFor:1];
        self.bucketEnd   = [self.calendar dateByAddingComponents:self.componentUnit toDate:self.bucketStart options:0];
        
    }

    return true;
}
-(BOOL)contains:(NSDate*)date{
    if (!self.bucketStart) {
        return false;
    }
    return [self.bucketStart compare:date] != NSOrderedDescending && [self.bucketEnd compare:date] != NSOrderedAscending;

}

@end
