//
//  GCUnitCalendarUnit.h
//  RZUtils
//
//  Created by Brice Rosenzweig on 25/06/2020.
//  Copyright © 2020 Brice Rosenzweig. All rights reserved.
//

#import <RZUtils/RZUtils.h>

NS_ASSUME_NONNULL_BEGIN

@interface  GCUnitCalendarUnit : GCUnit

+(nullable GCUnitCalendarUnit*)calendarUnit:(NSCalendarUnit)unit
                          calendar:(nullable NSCalendar*)calendar
                     referenceDate:(nullable NSDate*)refOrNil;

@end

NS_ASSUME_NONNULL_END
