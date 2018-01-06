//  MIT Licence
//
//  Created on 11/09/2012.
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

#import "NSDate+RZHelper.h"
#import "RZMacros.h"


@implementation NSDate (RZHelper)

+(NSDate*)dateForFitTimestamp:(NSUInteger)timesamp{
    //seconds since UTC 00:00 Dec 31 1989
    static NSDate * refdate = nil;
    if (refdate==nil) {
        refdate = [NSDate dateForRFC3339DateTimeString:@"1989-12-31T00:00:00.000Z"];
        RZRetain(refdate);

    }
    return [refdate dateByAddingTimeInterval:timesamp];
}

+(NSDateFormatter*)rfc3339DateFormatter{
    static NSDateFormatter * _rfc3339DateFormatter = nil;

    if (!_rfc3339DateFormatter) {
        NSDateFormatter *   rfc3339DateFormatter;
        NSLocale *          enUSPOSIXLocale;

        // Convert the RFC 3339 date time string to an NSDate.

        rfc3339DateFormatter = RZReturnAutorelease([[NSDateFormatter alloc] init]);
        assert(rfc3339DateFormatter != nil);

        enUSPOSIXLocale = RZReturnAutorelease([[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]);
        assert(enUSPOSIXLocale != nil);

        rfc3339DateFormatter.locale = enUSPOSIXLocale;
        rfc3339DateFormatter.dateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.000Z'";
        rfc3339DateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        _rfc3339DateFormatter = rfc3339DateFormatter;
        RZRetain(_rfc3339DateFormatter);
    }
    return _rfc3339DateFormatter;
}

+(NSDateFormatter*)babolatDateFormatter{
    static NSDateFormatter * formatter = nil;
    if (formatter==nil) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"yyyy'-'MM'-'dd' 'HH':'mm':'ss";
    }
    return formatter;
}

+(NSDateFormatter*)stravaDateFormatter{
    static NSDateFormatter * formatter = nil;
    if (formatter==nil) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ssX";
    }
    return formatter;

}

+(NSDateFormatter*)garminModernDateFormatter{
    static NSDateFormatter * formatter = nil;
    if (formatter==nil) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0.0];
        formatter.dateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ss.0";
    }
    return formatter;

}

+(NSDateFormatter*)garminModernAlternateDateFormatter{
    static NSDateFormatter * formatter = nil;
    if (formatter==nil) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0.0];
        formatter.dateFormat = @"yyyy'-'MM'-'dd' 'HH':'mm':'ss";
    }
    return formatter;

}


+(NSDateFormatter*)sportTracksDateFormatter{
    static NSDateFormatter * formatter = nil;
    if (formatter==nil) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ssX";
    }
    return formatter;

}

+(NSDateFormatter*)dashedDateFormatter{
    static NSDateFormatter * formatter = nil;
    if (formatter==nil) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"yyyy'-'MM'-'dd";
    }
    return formatter;
}

-(NSString*)YYYYdashMMdashDD{
    return [[NSDate dashedDateFormatter] stringFromDate:self];
}

-(NSString*)YYYYMMDDhhmm{
    static NSDateFormatter * formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"yyyyMMddHHmm";

    }
    return [formatter stringFromDate:self];

}

-(NSString*)YYYYMMDDhhmmGMT{
    static NSDateFormatter * formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"yyyyMMddHHmm";
        formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    }
    return [formatter stringFromDate:self];

}

-(NSString*)YYYYMMDDhhmmssGMT{
    static NSDateFormatter * formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    }
    return [formatter stringFromDate:self];
}


-(NSString*)YYYYMMDD{
    static NSDateFormatter * formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"yyyyMMdd";

    }
    return [formatter stringFromDate:self];

}

+(NSDate*)dateForDashedDate:(NSString*)dashedString{
    return [[NSDate dashedDateFormatter] dateFromString:dashedString];
}

+(NSDate*)dateForBabolatTimeString:(NSString*)babolatTimeString{
    return [[NSDate babolatDateFormatter] dateFromString:babolatTimeString];
}

+(NSDate*)dateForGarminModernString:(NSString*)garminString{
    NSDate * rv = [[NSDate garminModernDateFormatter] dateFromString:garminString];
    if (rv == nil) {
        rv = [[NSDate garminModernAlternateDateFormatter ]dateFromString:garminString];
    }
    return rv;
}

+(NSDate*)dateForStravaTimeString:(NSString*)stravaTimeString{
    return [[NSDate stravaDateFormatter] dateFromString:stravaTimeString];
}
+(NSDate*)dateForSportTracksTimeString:(NSString*)str{
    NSDate * rv = [[NSDate sportTracksDateFormatter] dateFromString:str];
    if (rv==nil) {
        rv = [[NSDate stravaDateFormatter] dateFromString:str];
    }
    return rv;
}

+ (NSDate *)dateForRFC3339DateTimeString:(NSString *)rfc3339DateTimeString
// Returns a user-visible date time string that corresponds to the
// specified RFC 3339 date time string. Note that this does not handle
// all possible RFC 3339 date time strings, just one of the most common
// styles.
{
    NSDateFormatter *   rfc3339DateFormatter = [NSDate rfc3339DateFormatter];
    NSDate * date = [rfc3339DateFormatter dateFromString:rfc3339DateTimeString];
    return date;
}
-(NSString*)formatAsRFC3339{
    NSDateFormatter * rfc3339DateFormatter = [NSDate rfc3339DateFormatter];
    return [rfc3339DateFormatter stringFromDate:self];
}

-(NSString*)dayFormat{
    static NSDateFormatter * formatter = nil;
    if (formatter == nil) {
        formatter = ([[NSDateFormatter alloc] init]);

        formatter.locale = [NSLocale currentLocale];
        formatter.timeStyle = NSDateFormatterNoStyle;
        formatter.dateFormat = @"EEEE";
    }
    return [[formatter stringFromDate:self] capitalizedString];
}

-(NSString*)dateShortFormat{
    static NSDateFormatter * formatter = nil;
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.timeStyle = NSDateFormatterNoStyle;
        formatter.dateStyle = NSDateFormatterMediumStyle;
    }
    return [formatter stringFromDate:self];
}

-(NSString*)timeShortFormat{
    static NSDateFormatter * formatter = nil;
    if (formatter == nil) {
        formatter = ([[NSDateFormatter alloc] init]);
        formatter.timeStyle = NSDateFormatterShortStyle;
        formatter.dateStyle = NSDateFormatterNoStyle;
    }
    return [formatter stringFromDate:self];

}

-(NSString*)datetimeFormat{
    static NSDateFormatter * formatter = nil;
    if (formatter == nil) {
        formatter = ([[NSDateFormatter alloc] init]);
        formatter.timeStyle = NSDateFormatterMediumStyle;
        formatter.dateStyle = NSDateFormatterShortStyle;
    }
    return [formatter stringFromDate:self];

}


-(NSString*)dateFormatFromToday{
    NSDate * today = [NSDate date];
    NSCalendar * currentCalendar = [NSCalendar currentCalendar];

    NSDateComponents * todayComponents = [currentCalendar components:(NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitDay|NSCalendarUnitWeekOfYear) fromDate:today];
    NSDateComponents * selfComponents  = [currentCalendar components:(NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitDay|NSCalendarUnitWeekOfYear) fromDate:self];

    NSDateFormatter * formatter = RZReturnAutorelease([[NSDateFormatter alloc] init]);
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.timeStyle = NSDateFormatterNoStyle;

    BOOL sameYear = todayComponents.year == selfComponents.year;
    BOOL sameDay  = todayComponents.day  == selfComponents.day;
    BOOL sameMonth = todayComponents.month == selfComponents.month;
    BOOL sameWeek  = todayComponents.weekOfYear == selfComponents.weekOfYear;

    if ( sameYear && sameMonth && sameDay){
        return @"Today";
    }else if (sameWeek){
        formatter.dateFormat = @"EEEE";
    }else if (sameMonth && sameYear) {
        formatter.dateFormat = @"EEEE d";
    }else if (sameYear) {
        formatter.dateFormat = @"MMMM d";
    }else {
        formatter.dateStyle = NSDateFormatterMediumStyle;
    }
    return [formatter stringFromDate:self];
}

-(BOOL)isSameCalendarDay:(NSDate*)aDate calendar:(NSCalendar *)cal{
    NSDateComponents * other = [cal components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitYear fromDate:aDate];
    NSDateComponents * this =[cal components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitYear fromDate:self];

    return other.day == this.day && other.month == this.month && other.year == this.year;
}
-(NSComparisonResult)compareCalendarDay:(NSDate *)aDate include:(BOOL)flag calendar:(NSCalendar *)cal{
    NSDateComponents * other = [cal components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitYear fromDate:aDate];
    NSDateComponents * this =[cal components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitYear fromDate:self];

    if (other.day == this.day && other.month == this.month && other.year == this.year) {
        return flag?NSOrderedAscending:NSOrderedDescending;
    }else {
        return self.timeIntervalSince1970 > aDate.timeIntervalSince1970 ? NSOrderedDescending : NSOrderedAscending;
    }

}

-(NSDate*)previousDay{
    NSDateComponents *adjustUnit = RZReturnAutorelease([[NSDateComponents alloc] init]);
    NSCalendar * cal = [NSCalendar currentCalendar];
    //[cal setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    adjustUnit.day = -1;

    NSDate *rv = [cal dateByAddingComponents:adjustUnit toDate:self options:0];
    return rv;
}

-(NSString*)calendarUnitFormat:(NSCalendarUnit)aUnit{
    if (aUnit == NSCalendarUnitMonth) {
        NSDateFormatter * formatter = RZReturnAutorelease([[NSDateFormatter alloc] init]);
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"MMM yyyy";
        return [formatter stringFromDate:self];
    }else if(aUnit == NSCalendarUnitYear){
        NSDateFormatter * formatter = RZReturnAutorelease([[NSDateFormatter alloc] init]);
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"yyyy";
        return [formatter stringFromDate:self];
    }else{
        NSDateFormatter * formatter = RZReturnAutorelease([[NSDateFormatter alloc] init]);
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateStyle = NSDateFormatterShortStyle;
        formatter.timeStyle = NSDateFormatterNoStyle;
        return [formatter stringFromDate:self];
    }
    return [self dateShortFormat];
}

-(NSDate*)dateByAddingGregorianComponents:(NSDateComponents*)comp{
    static NSCalendar * _gregorianCalendar = nil;

    if (_gregorianCalendar == nil) {
        _gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    }
    return [_gregorianCalendar dateByAddingComponents:comp toDate:self options:0];
}


@end
