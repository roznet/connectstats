//  MIT Licence
//
//  Created on 24/10/2012.
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

#import "GCActivitySearchElement.h"
#import "GCActivity.h"
#import "GCAppGlobal.h"
#import "GCActivity+Fields.h"

// comp keyword:  distance,d,speed,s,cadence,duration,t
// keyword: cycling,running,bike,biking,swim,swimming,
// keyword: near (me,current)
// pattern: 4digits->year,year (number)
// keyword: and,or
// value: number,number unit,
// keyword: this,last (month,week,year)
// keyword: morning,evening,afternoon

NSArray * _elementCache = nil;

@implementation GCActivitySearchElement

+(void)buildCache{
    if (!_elementCache) {
        NSMutableArray * cache = [NSMutableArray arrayWithCapacity:20];
        [cache addObject:[[[GCSearchElementActivityField alloc] init] autorelease]];
        [cache addObject:[[[GCSearchElementDate alloc] init] autorelease]];
        _elementCache = [NSArray arrayWithArray:cache];
        RZRetain(_elementCache);
    }
}

+(GCActivitySearchElement*)searchElement:(NSScanner*)scanner{
    [GCActivitySearchElement buildCache];

    NSString * nextKeyword;
    if ([scanner scanString:@"\"" intoString:nil]) {
        if (![scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\""] intoString:&nextKeyword]) {
            return nil;
        }
        [scanner scanString:@"\"" intoString:nil];
    }else{
        if (![scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@" <>:,"] intoString:&nextKeyword]) {
            return nil;
        }
    }

    for (GCActivitySearchElement * elem in _elementCache) {
        GCActivitySearchElement * next = [elem nextElementForString:nextKeyword andScanner:scanner];
        if (next) {
            return next;
        }
    }
    GCSearchElementStringMatch * elem = [[[GCSearchElementStringMatch alloc] init] autorelease];
    elem.needle = nextKeyword;

    return elem;
}

-(GCActivitySearchElement*)nextElementForString:(NSString*)aStr andScanner:(NSScanner*)scanner{
    return nil;
}
-(BOOL)match:(GCActivity*)activity{
    return false;
}

@end

#pragma mark -

@implementation GCSearchElementStringMatch
@synthesize needle;
-(void)dealloc{
    [needle release];
    [super dealloc];
}
-(GCActivitySearchElement*)nextElementForString:(NSString*)aStr andScanner:(NSScanner*)scanner{
    GCSearchElementStringMatch * elem = [[[GCSearchElementStringMatch alloc] init] autorelease];
    elem.needle = aStr;

    return elem;
}

-(BOOL)match:(GCActivity*)activity{
    NSRange res;
    res = [activity.activityName rangeOfString:needle options:NSCaseInsensitiveSearch];
    if (activity.activityName && res.location != NSNotFound) {
        return true;
    }
    res = [activity.location     rangeOfString:needle options:NSCaseInsensitiveSearch];
    if (activity.location && res.location != NSNotFound) {
        return true;
    }
    res = [activity.activityType rangeOfString:needle options:NSCaseInsensitiveSearch];
    if (activity.activityType && res.location != NSNotFound) {
        return true;
    }
    res = [activity.activityTypeDetail.key rangeOfString:needle options:NSCaseInsensitiveSearch];
    if (activity.activityTypeDetail && res.location != NSNotFound) {
        return true;
    }
    res = [activity.activityId rangeOfString:needle options:NSCaseInsensitiveSearch];
    if (activity.activityId && res.location != NSNotFound) {
        return true;
    }

    if (activity.metaData) {
        for (NSString*field in activity.metaData) {
            GCActivityMetaValue * m = activity.metaData[field];
            if (m && [m match:needle]) {
                return true;
            }
        }
    }

    return false;
}

@end
#pragma mark -

@implementation GCSearchElementActivityField
@synthesize field,value,unit;
-(void)dealloc{
    [unit release];
    [_summaryField release];

    [super dealloc];
}
/*
 Keywords
 dist
 distance
 heart
 heartrate
 duration
 dur
 speed
 pace
 */
-(GCActivitySearchElement*)nextElementForString:(NSString*)aStr andScanner:(NSScanner*)scanner{
    gcFieldFlag foundField = gcFieldFlagNone;
    NSString * foundSummaryField = nil;

    // If aStr is a valid activity type, skip and just match that
    if( [[GCAppGlobal activityTypes] isExistingActivityType:aStr]){
        return nil;
    }

    if ([aStr isEqualToString:@"dist"]||[aStr isEqualToString:@"distance"]) {
        foundField = gcFieldFlagSumDistance;
    }else if([aStr isEqualToString:@"heart"]||[aStr isEqualToString:@"heartrate"]){
        foundField = gcFieldFlagWeightedMeanHeartRate;
    }else if([aStr isEqualToString:@"duration"]||[aStr isEqualToString:@"dur"]){
        foundField = gcFieldFlagSumDuration;
    }else if([aStr isEqualToString:@"speed"]||[aStr isEqualToString:@"pace"]){
        foundField = gcFieldFlagWeightedMeanSpeed;
    }
    if (foundField == gcFieldFlagNone) {
        NSArray * knowns = [GCFields knownFieldsMatching:aStr];
        if (knowns && knowns.count>0) {
            foundSummaryField = knowns[0];
        }
    }
    if (foundField != gcFieldFlagNone || foundSummaryField) {
        GCSearchElementActivityField * rv = [[[GCSearchElementActivityField alloc] init] autorelease];
        rv.field = foundField;
        rv.summaryField = foundSummaryField;

        NSUInteger location = scanner.scanLocation;
        NSString * foundstr = nil;
        BOOL valid = false;

        [scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet].invertedSet intoString:nil];
        if ([scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@" 0123456789"] intoString:&foundstr]) {
            if ([foundstr hasPrefix:@"<"]) {
                rv.comparison = gcSearchComparisonLessThan;
            }else if([foundstr hasPrefix:@">"]){
                rv.comparison = gcSearchComparisonGreaterThan;
            }else{
                rv.comparison = gcSearchComparisonEqual;
            }
            double val = 0.;
            if ([scanner scanDouble:&val]) {
                valid = true;
                rv.value = val;
                BOOL hasSecs = false;
                if ([scanner scanString:@":" intoString:nil]) {
                    double secs;
                    if ([scanner scanDouble:&secs]) {
                        rv.value *= 60.;
                        rv.value += secs;
                        hasSecs = true;
                    };
                }
                NSUInteger locBeforeUnit =scanner.scanLocation;
                GCUnit * foundUnit = nil;
                NSString * unitstr = nil;
                [scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet].invertedSet intoString:nil];
                if ([scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:&unitstr]) {
                    foundUnit = [GCUnit unitMatchingString:unitstr];
                    if (foundUnit) {
                        if (hasSecs) {
                            // hack if has sec must be min/xx
                            rv.value/=60.;
                        }
                        rv.unit = foundUnit;
                    }
                }
                if (!foundUnit) {
                    scanner.scanLocation = locBeforeUnit;
                }
            }
        }
        if (valid) {
            return rv;
        }else{
            scanner.scanLocation = location;
        }
    }
    return nil;

}
-(BOOL)match:(GCActivity*)activity{
    double compareval = 0.;
    if (self.summaryField) {
        GCNumberWithUnit * num = [activity numberWithUnitForFieldKey:self.summaryField];
        if (num==nil) {
            return false;
        }
        if (unit) {
            compareval = [num convertToUnit:unit].value;
        }else{
            compareval = num.value;
        }
    }else{
        switch (field) {
            case gcFieldFlagSumDistance:
            {
                compareval = activity.sumDistance;
                if (unit) {
                    compareval = [unit convertDouble:compareval fromUnit:[GCUnit unitForKey:STOREUNIT_DISTANCE]];
                }
                break;
            }
            case gcFieldFlagSumDuration:
                compareval = activity.sumDuration;
                break;
            case gcFieldFlagWeightedMeanHeartRate:
                compareval = activity.weightedMeanHeartRate;
                break;
            case gcFieldFlagWeightedMeanSpeed:
            {
                compareval = activity.weightedMeanSpeed;
                if (unit) {
                    compareval = [unit convertDouble:compareval fromUnit:[GCUnit unitForKey:STOREUNIT_SPEED]];
                }
                break;
            }
            default:
                break;
        }
    }
    switch (self.comparison) {
        case gcSearchComparisonEqual:
            return fabs(compareval/value-1)<0.01;
        case gcSearchComparisonGreaterThan:
            return compareval > value;
        case gcSearchComparisonLessThan:
            return compareval < value;

    }
}

@end

@implementation GCSearchElementDate
@synthesize date,calendarUnits,calendar,components;
-(void)dealloc{
    [date release];
    [calendar release];
    [components release];
    [super dealloc];
}
-(GCActivitySearchElement*)nextElementForString:(NSString*)aStr andScanner:(NSScanner*)scanner{
    GCSearchElementDate * rv = nil;
    // check for month
    NSDateFormatter * dateformatter = [[[NSDateFormatter alloc] init] autorelease];

    if ([aStr.lowercaseString isEqualToString:@"weekof"]) {
        dateformatter.dateStyle = NSDateFormatterShortStyle;
        dateformatter.timeStyle = NSDateFormatterNoStyle;

        NSUInteger location = scanner.scanLocation;
        NSString * foundstr = nil;
        NSDate * found = nil;

        [scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet].invertedSet intoString:nil];
        if ([scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:&foundstr]) {
            found = [dateformatter dateFromString:foundstr];
        }
        if (found) {
            rv = [[[GCSearchElementDate alloc] init] autorelease];
            rv.calendar = [GCAppGlobal calculationCalendar];
            rv.calendarUnits = NSCalendarUnitWeekOfYear+NSCalendarUnitYearForWeekOfYear;
            rv.components = [rv.calendar components:rv.calendarUnits fromDate:found];
        }else{
            scanner.scanLocation = location;
        }

    }else{
        NSArray * fmts = @[@"MMM",@"MMMM",@"EEE",@"EEEE",@"yyyy"];
        NSCalendarUnit units[5] = {NSCalendarUnitMonth,NSCalendarUnitMonth,NSCalendarUnitWeekday,NSCalendarUnitWeekday,NSCalendarUnitYear};
        NSUInteger which = 0;
        NSDate * found = nil;

        for (NSString * fmt in fmts) {
            dateformatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
            dateformatter.dateFormat = fmt;
            found = [dateformatter dateFromString:aStr];
            if (found) {
                break;
            }
            which++;
        }
        if (found && which < 5) {
            rv = [[[GCSearchElementDate alloc] init] autorelease];
            rv.calendar = [GCAppGlobal calculationCalendar];
            rv.calendarUnits = units[which];
            rv.components = [rv.calendar components:rv.calendarUnits fromDate:found];

            NSUInteger location = scanner.scanLocation;
            NSString * foundstr = nil;

            [scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet].invertedSet intoString:nil];
            if ([scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:&foundstr]) {
                int year = foundstr.intValue;
                if (year > 2000 && year < 2020) {
                    (rv.components).year = year;
                    rv.calendarUnits += NSCalendarUnitYear;
                }else{
                    // ignore
                    scanner.scanLocation = location;
                }
            }
        }
    }
    return rv;
}
-(BOOL)match:(GCActivity*)activity{
    NSDateComponents * actComponent = [calendar components:calendarUnits fromDate:activity.date];
    BOOL rv = false;
    BOOL first = true;

    NSCalendarUnit units[6] = {NSCalendarUnitMonth,NSCalendarUnitWeekday,NSCalendarUnitYear,NSCalendarUnitWeekOfYear,NSCalendarUnitWeekOfYear,NSCalendarUnitYearForWeekOfYear};
    SEL selectors[6] = {@selector(month),@selector(weekday),@selector(year),@selector(week),@selector(weekOfYear),@selector(yearForWeekOfYear)};
    for( size_t i = 0 ; i<6;i++){
        if (units[i] & calendarUnits) {
            SEL selector = selectors[i];
            BOOL test = [actComponent performSelector:selector] == [components performSelector:selector];
            rv = first ? test : rv && test;
            first = false;
        }
    }

    return rv;
}

-(NSString*)description{
    NSCalendarUnit units[5] = {NSCalendarUnitMonth,NSCalendarUnitWeekday,NSCalendarUnitYear,NSCalendarUnitWeekOfYear,NSCalendarUnitWeekOfYear};
    SEL selectors[5] = {@selector(month),@selector(weekday),@selector(year),@selector(week),@selector(weekOfYear)};
    NSMutableString * s = [[[NSMutableString alloc]initWithCapacity:10] autorelease];
    for( size_t i = 0 ; i<5;i++){
        if (units[i] & calendarUnits) {
            [s appendFormat:@"%@=%d,", NSStringFromSelector(selectors[i]), (int)[components performSelector:selectors[i]]];
        }
    }
    return [NSString stringWithFormat:@"<GCSearchElementDate:%@>",s];
}
@end
