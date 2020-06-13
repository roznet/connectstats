//  MIT License
//
//  Created on 13/06/2020 for ConnectStats
//
//  Copyright (c) 2020 Brice Rosenzweig
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



#import "GCLagPeriod.h"

@interface GCLagPeriod ()
@property (nonatomic,assign) gcLagPeriod period;

@end

@implementation GCLagPeriod
+(GCLagPeriod*)periodFor:(gcLagPeriod)period{
    GCLagPeriod * rv = RZReturnAutorelease([[GCLagPeriod alloc] init]);
    if( rv ){
        rv.period = period;
    }
    return rv;
}

-(NSDate*)applyToDate:(NSDate*)date{
    return [date dateByAddingGregorianComponents:self.dateComponents];
}

-(NSDateComponents*)dateComponents{
    NSDateComponents * rv = nil;

    switch (self.period) {
        case gcLagPeriodDay:
            rv = [NSDateComponents dateComponentsFromString:@"-1d"];
            break;
        case gcLagPeriodThreeMonths:
            rv = [NSDateComponents dateComponentsFromString:@"-3m"];
            break;
        case gcLagPeriodSixMonths:
            rv = [NSDateComponents dateComponentsFromString:@"-6m"];
            break;
        case gcLagPeriodMonth:
            rv = [NSDateComponents dateComponentsFromString:@"-1m"];
            break;
        case gcLagPeriodTwoWeeks:
            rv = [NSDateComponents dateComponentsFromString:@"-2w"];
            break;
        case gcLagPeriodWeek:
            rv = [NSDateComponents dateComponentsFromString:@"-1w"];
            break;
        case gcLagPeriodYear:
            rv = [NSDateComponents dateComponentsFromString:@"-1y"];
            break;
        case gcLagPeriodNone:
            rv = nil;
            break;
    }
    return rv;
}

+(NSArray<GCLagPeriod*>*)validPeriods{
    return @[
        [GCLagPeriod periodFor:gcLagPeriodNone],
        [GCLagPeriod periodFor:gcLagPeriodDay],
        [GCLagPeriod periodFor:gcLagPeriodWeek],
        [GCLagPeriod periodFor:gcLagPeriodTwoWeeks],
        [GCLagPeriod periodFor:gcLagPeriodMonth],
        [GCLagPeriod periodFor:gcLagPeriodThreeMonths],
        [GCLagPeriod periodFor:gcLagPeriodSixMonths],
        [GCLagPeriod periodFor:gcLagPeriodYear]
    ];
}
-(NSString * )displayName{
    NSString * rv = @"";
    
    switch (self.period) {
        case gcLagPeriodDay:
            rv = NSLocalizedString(@"1d", @"Lag period");
            break;
        case gcLagPeriodThreeMonths:
            rv = NSLocalizedString(@"3m", @"Lag period");
            break;
        case gcLagPeriodSixMonths:
            rv = NSLocalizedString(@"6m", @"Lag period");
            break;
        case gcLagPeriodMonth:
            rv = NSLocalizedString(@"1m", @"Lag period");
            break;
        case gcLagPeriodTwoWeeks:
            rv = NSLocalizedString(@"2w", @"Lag period");
            break;
        case gcLagPeriodWeek:
            rv = NSLocalizedString(@"1w", @"Lag period");
            break;
        case gcLagPeriodYear:
            rv = NSLocalizedString(@"1y", @"Lag period");
            break;
        case gcLagPeriodNone:
            rv = @"";
            break;
    }
    return rv;

}
-(NSUInteger)numberOfDays{
    NSUInteger rv = 0;

    switch (self.period) {
        case gcLagPeriodNone:
            rv = 0;
            break;
        case gcLagPeriodDay:
            rv = 1;
            break;
        case gcLagPeriodMonth:
            rv = 30;
            break;
        case gcLagPeriodWeek:
            rv = 7;
            break;
        case gcLagPeriodYear:
            rv = 365;
            break;
        case gcLagPeriodThreeMonths:
            rv = 30*3;
            break;
        case gcLagPeriodSixMonths:
            rv = 30*6;
            break;
        case gcLagPeriodTwoWeeks:
            rv = 7*2;
            break;
    }
    return rv;

}

-(NSTimeInterval)timeInterval{
    NSTimeInterval rv = 0;
    const NSTimeInterval oneDay = 24.0*60.0*60.0;
    
    switch (self.period) {
        case gcLagPeriodNone:
            rv = 0;
            break;
        case gcLagPeriodDay:
            rv = 1*oneDay;
            break;
        case gcLagPeriodMonth:
            rv = 30*oneDay;
            break;
        case gcLagPeriodWeek:
            rv = 7*oneDay;
            break;
        case gcLagPeriodYear:
            rv = 365*oneDay;
            break;
        case gcLagPeriodThreeMonths:
            rv = 30*3*oneDay;
            break;
        case gcLagPeriodSixMonths:
            rv = 30*6*oneDay;
            break;
        case gcLagPeriodTwoWeeks:
            rv = 7*2*oneDay;
            break;
    }
    return rv;

}

@end
