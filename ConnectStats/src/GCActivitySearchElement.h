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

#import <Foundation/Foundation.h>
#import "GCFields.h"

typedef NS_ENUM(NSUInteger,gcSearchComparison) {
    gcSearchComparisonLessThan,
    gcSearchComparisonGreaterThan,
    gcSearchComparisonEqual
};

@class GCActivity;

@interface GCActivitySearchElement : NSObject

+(GCActivitySearchElement*)searchElement:(NSScanner*)scanner;
-(GCActivitySearchElement*)nextElementForString:(NSString*)aStr andScanner:(NSScanner*)scanner;
-(BOOL)match:(GCActivity*)activity;

@end

@interface GCSearchElementStringMatch : GCActivitySearchElement{
    NSString * needle;
}

@property (nonatomic,retain) NSString * needle;
@end

@interface GCSearchElementActivityField : GCActivitySearchElement

@property (nonatomic,assign) gcFieldFlag fieldFlag;
@property (nonatomic,retain) NSString * fieldKey;
@property (nonatomic,assign) double value;
@property (nonatomic,assign) gcSearchComparison comparison;
@property (nonatomic,retain) GCUnit* unit;

@end

@interface GCSearchElementDate : GCActivitySearchElement{
    NSDate * date;
    NSCalendarUnit calendarUnits;
    NSCalendar * calendar;
    NSDateComponents * components;
}
@property (nonatomic,retain) NSDate * date;
@property (nonatomic,retain) NSDateComponents * components;
@property (nonatomic,assign) NSCalendarUnit calendarUnits;
@property (nonatomic,retain) NSCalendar * calendar;

@end

@interface GCSearchElementNear : GCActivitySearchElement

@end
