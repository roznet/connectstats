//  MIT Licence
//
//  Created on 19/08/2013.
//
//  Copyright (c) 2013 Brice Rosenzweig.
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

#import "GCHealthZoneCalculator.h"

/*
 http://www.ontherunevents.com/ns0060.htm

 3 ZONES

 LEVEL 1: INACTIVE:    -100
 LEVEL 2: MODERATE: 100-140
 LEVEL 3: ACTIVE:   140-

 WALKING PACE CHART

 LEVEL 1: VERY INACTIVE:	80-100 steps per minute = 2 mph (30 minute mile)
 LEVEL 2: LIGHTLY ACTIVE:	120 steps per minute = 3 mph (20 minute mile)
 LEVEL 3: MODERATELY ACTIVE: 130 steps per minute = 3.5 mph (17-18 minute mile)
 LEVEL 4: ACTIVE:	140 steps per minute = 4 mph (15 minute mile)
 LEVEL 5: VERY ACTIVE:	150 steps per minute = 4.3 mph (14 minute mile)
 LEVEL 6: EXCEPTIONALLY ACTIVE: 160 steps per minute = 4.6 mph (13 minute mile)
 LEVEL 7: ATHLETE:	170 steps per minute = 5 mph (12 minute mile)
 LEVEL 8: ATHLETE	:	180 steps per minute = 5.5 mph (11 minute mile)
 LEVEL 9: ATHLETE:	190 steps per minute = 6.0 mph (9-10 minute mile)

 RUNNING PACE CHART (RECREATIONAL TO ATHLETE)

 LEVEL 5: VERY ACTIVE:	150 steps per minute = 6.0 mph (10-11 minute mile)
 LEVEL 6: EXCEPTIONALLY ACTIVE: 160 steps per minute = 6.7 mph (9 minute mile)
 LEVEL 7: ATHLETE	170 steps per minute = 7.5 mph (8 minute mile)
 LEVEL 8: ATHLETE	180 steps per minute = 8.8 mph (7 minute mile)
 LEVEL 9: ATHLETE	190 steps per minute = 10-12 mph (5-6 minute mile)

 CYCLING PACE CHART

 LEVEL 1: VERY INACTIVE:	50 rpm (100 beats or steps per minute)
 LEVEL 2: LIGHTLY ACTIVE:	60 rpm (120 beats or steps per minute)
 LEVEL 3: MODERATELY ACTIVE:	65 rpm (130 beats or steps per minute)
 LEVEL 4: ACTIVE:	70 rpm (140 beats or steps per minute)
 LEVEL 5: VERY ACTIVE:	75 rpm (150 beats or steps per minute)
 LEVEL 6: EXCEPTIONALLY ACTIVE:	80 rpm (160 beats or steps per minute)
 LEVEL 7: ATHLETE:	85 rpm (170 beats or steps per minute)
 LEVEL 8: ATHLETE:	90 rpm (180 beats or steps per minute)
 LEVEL 9: ATHLETE	:	95 rpm (190 beats or steps per minute)

 HEART RATE RUNNING
 HR Reserve = MAX HR - RESTING HR

 ZONE 1: AEROBIC/FAT BURNING    50-75% of HR Reserve
 ZONE 2: AEROBIC/FITNESS        75-85%
 ZONE 3: THRESHOLD              85-90%
 ZONE 4: ANAEROBIC              90%-

 GARMIN RUNNING/CYCLING
 ZONE 1: 50%-60% of HR MAX
 ZONE 2: 60%-70% of HR MAX
 ZONE 3: 70%-80%
 ZONE 4: 80%-90%
 ZONE 5: 90%-


 */

@implementation GCHealthZoneCalculator

-(void)dealloc{
    [_zones release];
    [_field release];
    [super dealloc];
}

+(GCHealthZoneCalculator*)zoneCalculatorForValues:(NSArray<NSNumber *> *)values
                                           inUnit:(GCUnit*)unit
                                        withNames:(NSArray<NSString*>*)names
                                         field:(GCField *)field
                                        forSource:(gcHealthZoneSource)source;
{
    NSArray * ordered = [values sortedArrayUsingSelector:@selector(compare:)];

    NSUInteger count = ordered.count;

    NSMutableArray * zones = [NSMutableArray arrayWithCapacity:count];
    for(NSUInteger idx=0;idx<count-1;idx++){
        NSNumber * one = ordered[idx];
        NSNumber * next= ordered[idx+1];

        NSString * name = idx < names.count ? names[idx] : @"";
        GCHealthZone * zone = [GCHealthZone zoneForField:field from:one.doubleValue to:next.doubleValue inUnit:unit index:idx name:name andSource:source];
        [zones addObject:zone];
    };

    return [self zoneCalculatorForZones:zones andField:field];
}

+(GCHealthZoneCalculator*)manualZoneCalculatorFrom:(GCHealthZoneCalculator*)other{
    GCHealthZoneCalculator * rv = [[[GCHealthZoneCalculator alloc] init] autorelease];
    if(rv){
        NSMutableArray*newZones = [NSMutableArray arrayWithCapacity:other.zones.count];
        for (GCHealthZone*zone in other.zones) {
            [newZones addObject:[GCHealthZone manualZoneFromZone:zone]];
        }
        rv.zones = newZones;
        rv.source = gcHealthZoneSourceManual;
        rv.field = other.field;
    }
    return rv;
}
+(GCHealthZoneCalculator*)zoneCalculatorForZones:(NSArray<GCHealthZone*>*)azones andField:(GCField *)field{
    if( azones.count == 0){
        return nil;
    }

    GCHealthZoneCalculator * rv = [[[GCHealthZoneCalculator alloc] init] autorelease];
    if (rv) {
        rv.zones = [azones sortedArrayUsingComparator:^(GCHealthZone* obj1, GCHealthZone* obj2) {
            double f1 = [obj1 floor];
            double f2 = [obj2 floor];
            return f1 < f2 ? NSOrderedAscending : ( f1 > f2 ? NSOrderedDescending : NSOrderedSame );
        }];
        rv.field = field;
        GCHealthZone * first = azones[0];
        rv.source = first.source;
        BOOL consistent = true;
        for (GCHealthZone * zone in rv.zones) {
            if( zone.source != rv.source || ![rv.field isEqualToField:zone.field]){
                consistent = false;
            }
        }
        if (!consistent) {
            RZLog(RZLogWarning, @"Inconsistent zone or field in zone calculator");
        }
    }
    return rv;
}

-(NSString*)description{
    return [NSString stringWithFormat:@"<GCHealthZoneCalculator %@ %d zones>", self.field, (int)(self.zones).count];
}
-(GCStatsDataSerieWithUnit*)bucketSerieWithUnit{
    return [self bucketSerieWithUnit:nil];
}
-(NSString*)activityType{
    return self.field.activityType;
}
+(NSString*)keyForField:(GCField *)field andSource:(gcHealthZoneSource)source{
    return [NSString stringWithFormat:@"%@%@", [GCHealthZone zoneSourceToKey:source], field];
}

-(GCUnit*)unit{
    GCUnit * rv = nil;
    if (self.zones.count) {
        GCHealthZone * first = self.zones[0];
        rv = first.unit;
    }
    return rv;
}
-(NSString*)key{
   return  [GCHealthZoneCalculator keyForField:self.field andSource:self.source];
}
-(GCStatsDataSerieWithUnit*)bucketSerieWithUnit:(GCUnit*)unit{
    GCStatsDataSerieWithUnit * rv = nil;
    if (self.zones.count) {
        GCHealthZone * first = self.zones[0];
        GCUnit * useUnit = unit ?: first.unit;

        rv = [GCStatsDataSerieWithUnit dataSerieWithUnit:useUnit];
        if (rv) {
            NSMutableArray * values = [NSMutableArray array];
            // Add value in correct unit, we'll sort after in case of inverted units
            for (GCHealthZone * zone in self.zones) {
                [values addObject:@( [useUnit convertDouble:zone.floor fromUnit:zone.unit] )];
            }
            [values sortUsingSelector:@selector(compare:)];
            NSUInteger i = 0;
            for (NSNumber * number in values) {
                [rv.serie addDataPointWithX:i++ andY:number.doubleValue];
            }
        }
    }
    return rv;
}

-(GCStatsDataSerieWithUnit*)zoneSerieFor:(GCStatsDataSerieWithUnit*)serie withScaling:(double)scale{
    if (self.zones.count==0) {
        return serie;
    }
    size_t zonesCount = self.zones.count;
    double * zones = calloc(zonesCount, sizeof(double));

    for (size_t i=0; i<zonesCount; i++) {
        GCHealthZone * zone = self.zones[i];
        zones[i] = [zone.unit convertDouble:zone.floor toUnit:serie.unit];
    }

    GCStatsDataSerieWithUnit * rv = [GCStatsDataSerieWithUnit dataSerieWithUnit:serie.unit];
    rv.xUnit = serie.xUnit;

    for (GCStatsDataPoint * point in serie.serie) {
        double y = point.y_data*scale;
        size_t found = 0;
        for (found=0; found<zonesCount; found++) {
            if (zones[found] > y) {
                break;
            }
        }
        [rv.serie addDataPointWithX:point.x_data andY:found];
    }

    free(zones);
    return rv;
}
-(GCHealthZone*)zoneForNumber:(GCNumberWithUnit*)number{
    GCHealthZone * rv = nil;
    if( (self.zones).count>0){
        GCUnit * unit = [(self.zones)[0] unit];
        GCNumberWithUnit * useN = number;
        if (![unit isEqualToUnit:number.unit]) {
            useN = [number convertToUnit:unit];
        }
        NSUInteger found = 0;
        for (found = 0; found<(self.zones).count; found++) {
            GCHealthZone * next = (self.zones)[found];
            if (next.floor > useN.value) {
                if (rv==nil) {
                    rv=next;
                }
                break;
            }
            rv = next;
        }
        // if nothing found return last zone
    }
    return rv;
}
-(BOOL)betterIsMin{
    BOOL rv = false;
    if (self.zones.count>0) {
        GCHealthZone * first = self.zones[0];
        rv = [first.unit betterIsMin];
    }
    return rv;
}
@end

