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

const NSUInteger kCalendarUnitNone = 0;


@interface GCStatsCalendarAggregationConfig ()
@property (nonatomic,retain) NSDate * fixedReferenceDate;
@end
@implementation GCStatsCalendarAggregationConfig

+(GCStatsCalendarAggregationConfig*)configFor:(NSCalendarUnit)aUnit calendar:(NSCalendar*)calendar{
    GCStatsCalendarAggregationConfig * rv = [[[GCStatsCalendarAggregationConfig alloc] init] autorelease];
    if (rv) {
        rv.calendar = calendar;
        rv.periodType = gcPeriodCalendar;
        rv.calendarUnit = aUnit;
    }
    return rv;
}
+(GCStatsCalendarAggregationConfig*)configFrom:(GCStatsCalendarAggregationConfig*)other{
    GCStatsCalendarAggregationConfig * rv = [[[GCStatsCalendarAggregationConfig alloc] init] autorelease];
    if (rv) {
        rv.calendar = other.calendar;
        rv.periodType = other.periodType;
        rv.fixedReferenceDate = other.fixedReferenceDate;
        rv.calendarUnit = other.calendarUnit;
    }
    return rv;

}
+(GCStatsCalendarAggregationConfig*)globalConfigFor:(NSCalendarUnit)aUnit{
    GCStatsCalendarAggregationConfig * rv = [GCStatsCalendarAggregationConfig configFor:aUnit calendar:[GCAppGlobal calculationCalendar]];
    rv.periodType = (gcPeriodType)[GCAppGlobal configGetInt:CONFIG_PERIOD_TYPE defaultValue:gcPeriodCalendar];
    return rv;
}

-(void)dealloc{
    [_fixedReferenceDate release];
    [_calendar release];
    
    [super dealloc];
}

-(NSDate*)referenceDate{
    switch (self.periodType){
        case gcPeriodRolling:
            return [NSDate date];
        case gcPeriodCalendar:
            return nil;
        case gcPeriodReferenceDate:
            return self.fixedReferenceDate;
    }
    return nil;
}

-(void)setReferenceDate:(NSDate *)referenceDate{
    if( referenceDate == nil ){
        self.periodType = gcPeriodCalendar;
        self.fixedReferenceDate = nil;
    }else{
        self.fixedReferenceDate = referenceDate;
        self.periodType = gcPeriodReferenceDate;
    }
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
    GCStatsCalendarAggregationConfig * rv = [GCStatsCalendarAggregationConfig configFrom:self];
    rv.calendarUnit = aUnit;
    return rv;
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
    }else if(self.calendarUnit == NSCalendarUnitYear ){
        self.calendarUnit = kCalendarUnitNone;
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
