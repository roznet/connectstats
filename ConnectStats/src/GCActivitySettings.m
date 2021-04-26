//  MIT Licence
//
//  Created on 30/01/2016.
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

#import "GCActivitySettings.h"
#import "GCAppGlobal.h"
#import "GCActivity.h"
#import "ConnectStats-Swift.h"

@interface GCActivitySettings ()
@property (nonatomic,retain) NSMutableDictionary<GCField*,NSNumber*>*reported;
@end

@implementation GCActivitySettings

+(GCActivitySettings*)defaultsFor:(GCActivity*)act{
    GCActivitySettings * rv = [[[GCActivitySettings alloc] init] autorelease];
    if (rv) {
        [rv setupWithGlobalConfig:act];
    }
    return rv;
}

-(void)dealloc{
    [_serieFilters release];
    [_reported release];
    [_worker release];
    [_updateRecord release];
    
    [super dealloc];
}
-(BOOL)alreadyReported:(GCField*)field{
    BOOL rv = false;
    if( self.reported == nil){
        self.reported = [NSMutableDictionary dictionaryWithObject:@1 forKey:field];
    }else{
        if( self.reported[field] != nil){
            rv = true;
        }else{
            self.reported[field] = @1;
        }
    }
    return rv;
}
-(void)disableFiltersAndAdjustments{
    self.serieFilters = [NSDictionary dictionary];
    self.adjustSeriesToMatchLapAverage = false;
    self.treatGapAsNoValueInSeries = false;
}

-(void)setupWithGlobalConfig:(GCActivity*)act{
    NSMutableDictionary * filters = [NSMutableDictionary dictionary];
    GCStatsDataSerieFilter * filter = nil;
    GCField * field = nil;

    self.adjustSeriesToMatchLapAverage = [GCAppGlobal configGetBool:CONFIG_FILTER_ADJUST_FOR_LAP defaultValue:false];
    
    self.worker = [GCAppGlobal worker];
    self.updateRecord = RZReturnAutorelease([[GCActivityUpdateRecordTracker alloc] init]);
    if( act.garminSwimAlgorithm ){
        self.treatGapAsNoValueInSeries = false;
        self.gapTimeInterval = 0.;

    }else{
        self.treatGapAsNoValueInSeries = false;
        self.gapTimeInterval = 10.;
        
        if ( [GCAppGlobal configGetBool:CONFIG_FILTER_BAD_VALUES defaultValue:YES]){
            
            field = [GCField fieldForFlag:gcFieldFlagAltitudeMeters andActivityType:act.activityType];
            filter = [[[GCStatsDataSerieFilter alloc] init] autorelease];
            filter.filterHighAcceleration = true;
            filter.maxAccelerationSpeedThreshold = -1000.; // any altitude checks for big change
            filter.maxAcceleration = 20.;                // 20. meter change / second
            filters[ field ] = filter;
            
            field = [GCField fieldForFlag:gcFieldFlagCadence andActivityType:act.activityType];
            filter = [[[GCStatsDataSerieFilter alloc] init] autorelease];
            filter.minValue = 1e-8;
            filter.filterMinValue = true;
            filters[ field ] =filter;
            
            field = [GCField fieldForFlag:gcFieldFlagWeightedMeanSpeed andActivityType:act.activityType];
            filter = [[[GCStatsDataSerieFilter alloc] init] autorelease];
            filter.minValue = [GCAppGlobal configGetDouble:CONFIG_FILTER_SPEED_BELOW defaultValue:1.0];
            filter.filterMinValue = [act.activityType isEqualToString:GC_TYPE_RUNNING] ||[act.activityType isEqualToString:GC_TYPE_CYCLING];
            if ([GCAppGlobal configGetBool:CONFIG_FILTER_BAD_ACCEL defaultValue:YES]) {
                filter.filterHighAcceleration = true;
                filter.maxAccelerationSpeedThreshold = 5.55; // about 20kph in mps
                filter.maxAcceleration = 1.2;                // 1.2 mps change / second
            }
            filters[ field ] = filter;
            field = [GCField fieldForKey:CALC_10SEC_SPEED andActivityType:act.activityType];
            filters[ field ] = filter;
            
            field = [GCField fieldForFlag:gcFieldFlagWeightedMeanHeartRate andActivityType:act.activityType];
            filter = [[[GCStatsDataSerieFilter alloc] init] autorelease];
            filter.minValue = 5.;
            filter.filterMinValue = true;
            filters[ field ] = filter;
            
            field = [GCField fieldForFlag:gcFieldFlagPower andActivityType:act.activityType];
            filter = [[[GCStatsDataSerieFilter alloc] init] autorelease];
            filter.maxValue = [GCAppGlobal configGetDouble:CONFIG_FILTER_POWER_ABOVE defaultValue:CONFIG_FILTER_DISABLED_POWER];
            filter.filterMaxValue = true;
            filter.minValue = 0.01;
            filter.filterMinValue = true;
            filters[ field] = filter;
            
            field = [GCField fieldForFlag:gcFieldFlagVerticalOscillation andActivityType:act.activityType];
            filter = [[[GCStatsDataSerieFilter alloc] init] autorelease];
            filter.minValue = 0.01;
            filter.filterMinValue = true;
            filters[ field ] = filter;
            
            field = [GCField fieldForFlag:gcFieldFlagGroundContactTime andActivityType:act.activityType];
            filter = [[[GCStatsDataSerieFilter alloc] init] autorelease];
            filter.minValue = 0.01;
            filter.filterMinValue = true;
            filters[ field ] = filter;
            
            field = [GCField fieldForKey:@"WeightedMeanFormPower" andActivityType:act.activityType];
            filter = [[[GCStatsDataSerieFilter alloc] init] autorelease];
            filter.minValue = 0.01;
            filter.filterMinValue = true;
            filters[ field ] = filter;
            
            field = [GCField fieldForKey:@"WeightedMeanGroundContactBalanceLeft" andActivityType:act.activityType];
            filter = [[[GCStatsDataSerieFilter alloc] init] autorelease];
            filter.minValue = 0.01;
            filter.filterMinValue = true;
            filters[ field ] = filter;
            
            field = [GCField fieldForKey:@"WeightedMeanVerticalRatio" andActivityType:act.activityType];
            filter = [[[GCStatsDataSerieFilter alloc] init] autorelease];
            filter.minValue = 0.01;
            filter.filterMinValue = true;
            filters[ field ] = filter;
            
        }
    }
    self.serieFilters = [NSDictionary dictionaryWithDictionary:filters];

}

-(BOOL)shouldAdjustToMatchLapAverageForField:(GCField*)field{
    return self.adjustSeriesToMatchLapAverage == true && field.fieldFlag == gcFieldFlagWeightedMeanSpeed;
}
@end
