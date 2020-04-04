//  MIT License
//
//  Created on 07/03/2020 for ConnectStats
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



#import "GCTrackPoint+Swim.h"
#import "GCActivity.h"
#import "GCActivitySummaryValue.h"

@implementation GCTrackPoint (Swim)

-(GCTrackPoint*)initAt:(NSDate*)timestamp
                    stroke:(gcSwimStrokeType)type
                    active:(BOOL)active
                       with:(NSDictionary<GCField*,GCActivitySummaryValue*>*)sumValues
                inActivity:(GCActivity*)act{
    self = [self init];
    if (self) {
        self.time = timestamp;
        [self setNumberWithUnit:[GCNumberWithUnit numberWithUnit:GCUnit.dimensionless andValue:type]
                       forField:[GCField fieldForKey:INTERNAL_DIRECT_STROKE_TYPE andActivityType:GC_TYPE_ALL] inActivity:act];
        
        for (GCField * field in sumValues) {
            GCActivitySummaryValue * value = sumValues[field];
            [self setNumberWithUnit:value.numberWithUnit forField:field inActivity:act];
        }
        if( ! active ){
            [self setNumberWithUnit:[GCNumberWithUnit numberWithUnit:GCUnit.meter andValue:0.0] forField:[GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:act.activityType] inActivity:act];
        }
        if( active && self.distanceMeters == 0){
            GCNumberWithUnit * length = [act numberWithUnitForField:[GCField fieldForKey:@"pool_length" andActivityType:act.activityType]];
            if( length ){
                self.distanceMeters = [length convertToUnit:[GCUnit meter]].value;
            }
        }
        
    }
    return self;
}

-(gcSwimStrokeType)directSwimStroke{
    GCNumberWithUnit * found = [self numberWithUnitForField:[GCField fieldForKey:INTERNAL_DIRECT_STROKE_TYPE andActivityType:GC_TYPE_ALL] inActivity:nil];
    if( found ){
        return (gcSwimStrokeType)found.value;
    }
    return gcSwimStrokeOther;
}

-(BOOL)active{
    return self.distanceMeters > 0.;
}

@end
