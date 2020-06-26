//
//  GCUnitCalendarUnit.m
//  RZUtils
//
//  Created by Brice Rosenzweig on 25/06/2020.
//  Copyright © 2020 Brice Rosenzweig. All rights reserved.
//

#import "GCUnitCalendarUnit.h"

@interface GCUnitCalendarUnit ()
@property (nonatomic,retain) NSDateFormatter * dateFormatter;
@property (nonatomic,assign) NSCalendarUnit calendarUnit;
@property (nonatomic,retain) NSCalendar * calendar;
@property (nonatomic,retain,nullable) NSDate * referenceDateOrNil;
@property (nonatomic,retain,nullable) NSDateComponents * referenceDateComponents;
@end

@implementation GCUnitCalendarUnit

+(nullable GCUnitCalendarUnit*)calendarUnit:(NSCalendarUnit)unit
                          calendar:(NSCalendar*)calendar
                     referenceDate:(NSDate*)refOrNil{
    NSString * key = nil;
    
    if( unit == NSCalendarUnitMonth){
        key = @"monthly";
    }else if( unit == NSCalendarUnitYear){
        key = @"yearly";
    }else if( unit == NSCalendarUnitWeekOfYear ){
        key = @"weekly";
    }
    
    if( key ){
        if( refOrNil ){
            key = [NSString stringWithFormat:@"%@[%@]", key, refOrNil];
        }
        GCUnitCalendarUnit * rv = RZReturnAutorelease([[GCUnitCalendarUnit alloc] init]);
        rv.calendar = calendar;
        rv.calendarUnit = unit;
        rv.referenceDateOrNil = refOrNil;
        if( rv.referenceDateOrNil ){
            rv.referenceDateComponents = [rv.calendar components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekOfYear fromDate:rv.referenceDateOrNil];
        }
        rv.dateFormatter = RZReturnAutorelease([[NSDateFormatter alloc] init]);
        rv.dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        rv.key = key;
        rv.abbr = @"";
        rv.display = @"";
     
        return rv;
    }else{
        return nil;
    }
}

#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_dateFormatter release];
    [_calendar release];
    [_referenceDateComponents release];
    [_referenceDateOrNil release];
    [super dealloc];
}
#endif


-(double)axisKnobSizeFor:(double)range numberOfKnobs:(NSUInteger)n{
    if (_calendarUnit == NSCalendarUnitWeekOfYear || _calendarUnit == NSCalendarUnitMonth) {
        double oneday = 24.*60.*60.;
        return ceil(range/n/oneday)* oneday;
    }else if(_calendarUnit == NSCalendarUnitYear){
        double onemonth = 24.*60.*60.*365./12.;
        return ceil(range/n/onemonth)* onemonth;
    }
    return [super axisKnobSizeFor:range numberOfKnobs:n];
}

-(NSArray*)axisKnobs:(NSUInteger)nKnobs min:(double)x_min max:(double)x_max extendToKnobs:(BOOL)extend{
    if (nKnobs > 0) {// don't bother for edge case
        double oneday = 24.*60.*60.;

        if (self.calendarUnit==NSCalendarUnitWeekOfYear){
            NSMutableArray * rv = [NSMutableArray arrayWithCapacity:7];
            for (NSUInteger i = 0; i<8; i++) {
                [rv addObject:@(oneday*i)];
            }
            return rv;
        }
    }
    return [super axisKnobs:nKnobs min:x_min max:x_max extendToKnobs:extend];
}

-(NSString*)formatDouble:(double)aDbl addAbbr:(BOOL)addAbbr{
    if (!_calendar) {
        self.calendar = [NSCalendar currentCalendar];
    }
    double oneday = 24.*60.*60.;
    double onemonth = oneday*365./12.;
    double day = aDbl/oneday;
    if (_calendarUnit == NSCalendarUnitYear) {
        _dateFormatter.dateFormat = @"MMM";

        if( self.referenceDateOrNil ){
            return [_dateFormatter stringFromDate:[self.referenceDateOrNil dateByAddingTimeInterval:aDbl]];
        }else{
            NSDateComponents * comp = RZReturnAutorelease([[NSDateComponents alloc] init]);
            double month = aDbl/onemonth;
            NSUInteger monthIdx = floor(month)+1;
            comp.month = monthIdx;
            return [_dateFormatter stringFromDate:[_calendar dateFromComponents:comp]];
        }
    }else if (_calendarUnit == NSCalendarUnitWeekOfYear){
        NSUInteger firstWeekday = _calendar.firstWeekday;
        double weekday = aDbl/oneday;
        NSDateComponents * comp = RZReturnAutorelease([[NSDateComponents alloc] init]);
        NSUInteger weekdayIdx = floor(weekday)+firstWeekday;
        comp.weekday = weekdayIdx;
        comp.weekdayOrdinal = 1;
        _dateFormatter.dateFormat = @"EEE";
        NSString * s = [_dateFormatter stringFromDate:[_calendar dateFromComponents:comp]];
        return s;
    }

    return [NSString stringWithFormat:@"%.0f", day];
}

@end
