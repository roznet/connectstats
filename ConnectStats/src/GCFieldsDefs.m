//  MIT Licence
//
//  Created on 12/11/2016.
//
//  Copyright (c) 2016 Brice Rosenzweig.
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
#import "GCFieldsDefs.h"

NSString * GC_TYPE_RUNNING =     @"running";
NSString * GC_TYPE_CYCLING =     @"cycling";
NSString * GC_TYPE_SWIMMING =    @"swimming";
NSString * GC_TYPE_HIKING =      @"hiking";
NSString * GC_TYPE_FITNESS =     @"fitness_equipment";
NSString * GC_TYPE_WALKING =     @"walking";
NSString * GC_TYPE_OTHER =       @"other";
NSString * GC_TYPE_ALL =         @"all";

NSString * GC_TYPE_DAY =         @"day";
NSString * GC_TYPE_TENNIS =      @"tennis";

NSString * GC_TYPE_MULTISPORT =  @"multi_sport";
NSString * GC_TYPE_TRANSITION =  @"transition";

NSString * GC_TYPE_WINTER_SPORTS = @"winter_sports";
NSString * GC_TYPE_SKI_XC =        @"cross_country_skiing_ws";
NSString * GC_TYPE_SKI_DOWN =      @"resort_skiing_snowboarding_ws";
NSString * GC_TYPE_SKI_BACK =      @"backcountry_skiing_snowboarding_ws";

NSString * GC_TYPE_INDOOR_ROWING = @"indoor_rowing";
NSString * GC_TYPE_ROWING =        @"rowing";

NSString * GC_TYPE_UNCATEGORIZED = @"uncategorized";

NSString * GC_META_DEVICE = @"device";
NSString * GC_META_EVENTTYPE = @"eventType";
NSString * GC_META_DESCRIPTION = @"activityDescription";
NSString * GC_META_ACTIVITYTYPE = @"activityType";
NSString * GC_META_SERVICE = @"service";

NSString * STOREUNIT_SPEED =         @"mps";
NSString * STOREUNIT_DISTANCE =      @"meter";
NSString * STOREUNIT_ALTITUDE =      @"meter";
NSString * STOREUNIT_ELAPSED =       @"second";
NSString * STOREUNIT_TEMPERATURE =   @"celcius";
NSString * STOREUNIT_HEARTRATE =     @"bpm";

NSString * INTERNAL_PREFIX = @"__Internal";
NSString * INTERNAL_DIRECT_STROKE_TYPE = @"__InternalDirectStrokeType";

NSString * CALC_PREFIX = @"__Calc";
NSString * CALC_ALTITUDE_GAIN          = @"__CalcGainElevation";
NSString * CALC_ALTITUDE_LOSS          = @"__CalcLossElevation";
NSString * CALC_NORMALIZED_POWER       = @"__CalcNormalizedPower";
NSString * CALC_NONZERO_POWER          = @"__CalcNonZeroAvgPower";
NSString * CALC_METABOLIC_EFFICIENCY   = @"__CalcMetabolicEfficiency";
NSString * CALC_ENERGY                 = @"__CalcEnergy";
NSString * CALC_STRIDE_LENGTH          = @"__CalcStrideLength";
NSString * CALC_DEVELOPMENT            = @"__CalcRotationDevelopment";
NSString * CALC_ELEVATION_GRADIENT     = @"__CalcElevationGradient";
NSString * CALC_ACCUMULATED_SPEED      = @"__CalcAccumulatedSpeed";
NSString * CALC_VERTICAL_SPEED           = @"__CalcVerticalSpeed";
NSString * CALC_ASCENT_SPEED             = @"__CalcAscentSpeed";
NSString * CALC_DESCENT_SPEED            = @"__CalcDescentSpeed";
NSString * CALC_MAX_ASCENT_SPEED         = @"__CalcMaxAscentSpeed";
NSString * CALC_MAX_DESCENT_SPEED        = @"__CalcMaxDescentSpeed";
NSString * CALC_10SEC_SPEED              = @"__Calc10SecSpeed";
NSString * CALC_LAP_SCALED_SPEED         = @"__CalcLapScaledSpeed";
