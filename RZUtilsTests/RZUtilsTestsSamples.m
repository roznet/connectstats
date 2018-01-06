//
//  RZUtilsTestsSamples.m
//  RZUtils
//
//  Created by Brice Rosenzweig on 16/07/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

#import "RZUtilsTestsSamples.h"

@implementation RZUtilsTestsSamples


// {1.2,1.3,2.1}
// {3.2,2.1,3.2,2.3,2.9,3.0,2.1,1.5,5.2,4.2,3.7}
// {0.2}
+(NSDictionary*)aggregateSample{
    // CutOff November 13 (last):
    //    Nov -> Cnt 1, Sum 0.2
    //    Oct -> Cnt 2, Sum 3.2+2.1=5.3
    //    Sep -> Cnt 1, Sum 1.2
    NSDictionary * sample = @{
                              @"2012-09-13T18:48:16.000Z":@(1.2), //thu
                              @"2012-09-14T19:10:16.000Z":@(1.3), //fri
                              @"2012-09-21T18:10:01.000Z":@(2.1), //fri
                              @"2012-10-10T15:00:01.000Z":@(3.2), //wed
                              @"2012-10-11T15:00:01.000Z":@(2.1), //thu
                              @"2012-10-21T15:00:01.000Z":@(3.2), //sun
                              @"2012-10-22T15:00:01.000Z":@(2.3), //mon
                              @"2012-10-23T15:00:01.000Z":@(2.9), //tue
                              @"2012-10-24T15:00:01.000Z":@(3.0), //wed
                              @"2012-10-25T15:00:01.000Z":@(2.1), //thu
                              @"2012-10-26T15:00:01.000Z":@(1.5), //fri
                              @"2012-10-27T15:00:01.000Z":@(5.2), //sat
                              @"2012-10-28T15:00:01.000Z":@(4.2), //sun
                              @"2012-10-29T15:00:01.000Z":@(3.7), //mon
                              @"2012-11-13T16:01:02.000Z":@(0.2), //tue
                              };
    return sample;
}
+(NSDictionary*)aggregateExpected{
    NSDictionary * expected = @{
                                @"2012-09-09T18:48:16.000Z":@[  @(1.25),        @(2.5),     @(1.3) ],
                                @"2012-09-16T18:48:16.000Z":@[  @(2.1),         @(2.1),     @(2.1) ],
                                @"2012-10-07T15:00:01.000Z":@[  @(2.65),        @(5.3),     @(3.2) ],
                                @"2012-10-21T15:00:01.000Z":@[  @(2.885714286), @(20.2),    @(5.2) ],
                                @"2012-10-28T18:48:16.000Z":@[  @(3.95),        @(7.9),     @(4.2) ],
                                @"2012-11-11T18:48:16.000Z":@[  @(0.2),         @(0.2),     @(0.2) ]
                                };
    return expected;
}

+(NSCalendar*)calculationCalendar{
    static NSCalendar * _cacheCalendar = nil;
    
    if (_cacheCalendar == nil) {
        _cacheCalendar = [NSCalendar currentCalendar];
    }
    
    NSInteger firstday = 1;
    if (firstday!=_cacheCalendar.firstWeekday) {
        _cacheCalendar.firstWeekday = firstday;
    }
    
    return _cacheCalendar;
}

@end
