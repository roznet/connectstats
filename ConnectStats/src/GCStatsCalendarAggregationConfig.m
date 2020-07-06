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
+(GCStatsCalendarAggregationConfig*)configFrom:(GCStatsCalendarAggregationConfig*)other{
    GCStatsCalendarAggregationConfig * rv = [[[GCStatsCalendarAggregationConfig alloc] init] autorelease];
    if (rv) {
        rv.calendar = other.calendar;
        rv.referenceDate = other.referenceDate;
        rv.calendarUnit = other.calendarUnit;
    }
    return rv;

}
+(GCStatsCalendarAggregationConfig*)globalConfigFor:(NSCalendarUnit)aUnit{
    return [GCStatsCalendarAggregationConfig configFor:aUnit referenceDate:[GCAppGlobal referenceDate] calendar:[GCAppGlobal calculationCalendar]];
}

-(void)dealloc{
    [_referenceDate release];
    [_calendar release];
    
    [super dealloc];
}
-(NSString*)description{
    return [NSString stringWithFormat:@"<%@: %@ %@>", NSStringFromClass([self class]), self.calendarUnitDescription, self.referenceDate ? @"Rolling" : @""];
}

-(NSString*)calendarUnitDescription{
    NSString * rv = nil;
    if (self.calendarUnit == NSCalendarUnitWeekOfYear) {
        rv = NSLocalizedString(@"Weekly", @"Calendar Unit Description");
    }else if(self.calendarUnit == NSCalendarUnitMonth){
        rv = NSLocalizedString(@"Monthly", @"Calendar Unit Description");
    }else if(self.calendarUnit == NSCalendarUnitYear){
        rv = NSLocalizedString(@"Yearly", @"Calendar Unit Description");
    }else{
        rv = NSLocalizedString(@"Error", @"Calendar Unit Description");
    }
    return rv;
}
-(NSString *) calendarUnitKey{
    NSString * rv = nil;
    if (self.calendarUnit == NSCalendarUnitWeekOfYear) {
        rv = @"weekly";
    }else if(self.calendarUnit == NSCalendarUnitMonth){
        rv = @"monthly";
    }else if(self.calendarUnit == NSCalendarUnitYear){
        rv = @"yearly";
    }
    return rv;
}

-(void)setCalendarUnitKey:(NSString *)calendarUnitKey{
    if( [calendarUnitKey isEqualToString:@"weekly"] ){
        self.calendarUnit = NSCalendarUnitWeekOfYear;
    }else if ([calendarUnitKey isEqualToString:@"monthly"]){
        self.calendarUnit = NSCalendarUnitMonth;
    }else if ([calendarUnitKey isEqualToString:@"yearly"]){
        self.calendarUnit = NSCalendarUnitYear;
    }
}
-(GCStatsCalendarAggregationConfig*)equivalentConfigFor:(NSCalendarUnit)aUnit{
    return [GCStatsCalendarAggregationConfig configFor:aUnit referenceDate:self.referenceDate calendar:self.calendar];
}

-(gcHistoryStats)historyStats{
    if (self.calendarUnit == NSCalendarUnitWeekOfYear) {
        return gcHistoryStatsWeek;
    }else if(self.calendarUnit == NSCalendarUnitMonth){
        return gcHistoryStatsMonth;
    }else if( self.calendarUnit == NSCalendarUnitYear){
        return gcHistoryStatsYear;
    }else{
        return gcHistoryStatsAll;
    }
}

-(BOOL)nextCalendarUnit{
    BOOL rv = false;
    if (self.calendarUnit == NSCalendarUnitWeekOfYear) {
        self.calendarUnit = NSCalendarUnitMonth;
    }else if(self.calendarUnit == NSCalendarUnitMonth){
        self.calendarUnit = NSCalendarUnitYear;
    }else {
        self.calendarUnit = NSCalendarUnitWeekOfYear;
        rv = true;
    }
    return rv;
}

-(BOOL)isEqualToConfig:(GCStatsCalendarAggregationConfig*)other{
    return self.calendarUnit == other.calendarUnit && RZNilOrEqualToDate(self.referenceDate, other.referenceDate) &&  [self.calendar isEqual:other.calendar];
}

-(BOOL)isEqual:(id)object{
    if( [object isKindOfClass:[self class]] ){
        return [self isEqualToConfig:object];
    }
    return false;
}

-(NSDateFormatter*)dateFormatter{
    NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    //[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    //[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    if (self.calendarUnit == NSCalendarUnitMonth) {
        dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatter.dateFormat = @"MMMM yyyy";
    }else if(self.calendarUnit == NSCalendarUnitYear){
        dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatter.dateFormat = @"yyyy";
    }else{
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
    }
    return dateFormatter;
}

@end
