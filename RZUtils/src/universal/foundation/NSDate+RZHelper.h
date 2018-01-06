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

#import <Foundation/Foundation.h>

@interface NSDate (RZHelper)

+(NSDate *)dateForRFC3339DateTimeString:(NSString *)rfc3339DateTimeString;
+(NSDate*)dateForBabolatTimeString:(NSString*)babolatTimeString;
+(NSDate*)dateForStravaTimeString:(NSString*)stravaTimeString;
+(NSDate*)dateForSportTracksTimeString:(NSString*)stravaTimeString;
+(NSDate*)dateForFitTimestamp:(NSUInteger)timesamp;
+(NSDate*)dateForDashedDate:(NSString*)dashedString;
+(NSDate*)dateForGarminModernString:(NSString*)garminString;

-(NSString*)formatAsRFC3339;
-(NSString*)dateFormatFromToday;
-(NSString*)dayFormat;
-(NSString*)dateShortFormat;
-(NSString*)datetimeFormat;
-(NSString*)timeShortFormat;
-(NSString*)YYYYdashMMdashDD;
-(NSString*)YYYYMMDDhhmmGMT;
-(NSString*)YYYYMMDDhhmmssGMT;
-(NSString*)YYYYMMDDhhmm;
-(NSString*)YYYYMMDD;
-(BOOL)isSameCalendarDay:(NSDate*)aDate calendar:(NSCalendar*)cal;
-(NSComparisonResult)compareCalendarDay:(NSDate *)other include:(BOOL)flag calendar:(NSCalendar*)cal;
-(NSString*)calendarUnitFormat:(NSCalendarUnit)aUnit;
-(NSDate*)dateByAddingGregorianComponents:(NSDateComponents*)comp;

@end
