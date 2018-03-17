//  MIT Licence
//
//  Created on 26/02/2013.
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

#import "GCHealthOrganizer.h"
#import "GCAppGlobal.h"
#import "GCHealthZoneCalculator.h"
#import "GCHealthZone.h"
#import "GCHealthSleepBlock.h"
#import "GCField.h"
#import "GCActivitiesOrganizer.h"

@interface GCHealthOrganizer ()
@property (nonatomic,retain) dispatch_queue_t worker;

@end

@implementation GCHealthOrganizer

-(instancetype)init{
    return [super init];
}

-(void)dealloc{
    [_measures release];
    [_db release];
    [_zones release];
    [_sleepBlocks release];
    [_worker release];

    [super dealloc];
}

+(void)ensureDbStructure:(FMDatabase*)db{
    [GCHealthMeasure ensureDbStructure:db];
    [GCHealthZone ensureDbStructure:db];
    [GCHealthSleepBlock ensureDbStructure:db];
}

-(GCHealthOrganizer*)initWithDb:(FMDatabase*)db andThread:(dispatch_queue_t)thread{
    self = [super init];
    if (self) {
        self.db = db;
        self.worker = thread;
        if( thread ){
            dispatch_async(thread,^(){
                [self loadFromDb];
            });
        }else{
            [self loadFromDb];
        }
    }
    return self;
}
-(void)updateForNewProfile{
    self.db = [GCAppGlobal db];
    if (self.worker) {
        dispatch_async(self.worker,^(){
            [self loadFromDb];
        });
    }else{
        [self loadFromDb];
    }
}
-(void)clearAllMeasures{
    if (![self.db executeQuery:@"DELETE FROM gc_health_measures"]) {
        RZLog(RZLogError, @"db error");
    }else{
        self.measures = nil;
    }
}
-(void)loadFromDb{
    NSMutableArray * meas = [NSMutableArray arrayWithCapacity:100];
    FMResultSet * res = [self.db executeQuery:@"SELECT * FROM gc_health_measures ORDER BY measureDate DESC"];
    if (res == nil) {
        RZLog(RZLogError, @"db error: %@", [self.db lastErrorMessage]);
    }
    while ([res next]) {
        GCHealthMeasure * one = [GCHealthMeasure healthMeasureFromResultSet:res];
        if (one) {
            [meas addObject:one];
        }else{
            //one = [GCHealthMeasure healthMeasureFromResultSet:res];
        }
    }
    self.measures = [NSArray arrayWithArray:meas];

    NSMutableDictionary * zon = [NSMutableDictionary dictionaryWithCapacity:5];
    res = [self.db executeQuery:@"SELECT * FROM gc_health_zones ORDER BY zoneNumber"];
    while ([res next]) {
        GCHealthZone * one = [GCHealthZone zoneWithResultSet:res];
        if( one){
            NSString * key = [GCHealthZoneCalculator keyForField:one.field andSource:one.source];
            NSMutableArray * arr = zon[key];
            if (!arr) {
                arr = [NSMutableArray arrayWithCapacity:5];
                zon[key] = arr;
            }
            [arr addObject:one];
        }
    }
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:zon.count];
    for (NSString * key in zon) {
        NSMutableArray * arr = zon[key];
        if (arr.count>0) {
            GCHealthZone * first = arr[0];
            GCHealthZoneCalculator * calc = [GCHealthZoneCalculator zoneCalculatorForZones:arr andField:first.field];
            dict[key] = calc;
        }
    }
    [self addDefaultZoneCalculatorTo:dict];

    self.zones = dict;

    NSMutableArray * blocks = [NSMutableArray arrayWithCapacity:20];
    res = [self.db executeQuery:@"SELECT * FROM gc_health_sleep_blocks ORDER BY startTime"];
    while ([res next]) {
        [blocks addObject:[GCHealthSleepBlock blockWithResultSet:res]];
    }
    self.sleepBlocks = [blocks sortedArrayUsingSelector:@selector(compare:)];

}

-(BOOL)hasHealthData{
    return (self.measures).count>0;
}
-(BOOL)hasZoneData{
    return (self.zones).count>0;
}

#pragma mark - Health Data
-(void)addSleepBlocks:(NSArray*)blocks{

    NSMutableArray * newBlocks= [NSMutableArray arrayWithArray:self.sleepBlocks];

    for (GCHealthSleepBlock *one in blocks) {
        NSUInteger newIndex = [newBlocks indexOfObject:one
                                     inSortedRange:(NSRange){0, newBlocks.count}
                                           options:NSBinarySearchingInsertionIndex
                                       usingComparator:^(GCHealthSleepBlock*o1,GCHealthSleepBlock*o2){
                                           return [o1 compare:o2];
                                       }];
        GCHealthSleepBlock * existing = newIndex < newBlocks.count ? newBlocks[newIndex] : nil;
        if (existing && [existing compare:one] == NSOrderedSame) {
            continue;
        }
        [newBlocks insertObject:one atIndex:newIndex];
        [one saveToDb:self.db];
    }
    self.sleepBlocks = newBlocks;

}
-(void)addHealthMeasure:(GCHealthMeasure*)one{
    if (one && [self measureForId:one.measureId andType:one.type]==nil) {
        [one saveToDb:self.db];
        NSMutableArray * measnew= [NSMutableArray arrayWithArray:self.measures];
        [measnew addObject:one];
        [measnew sortUsingComparator:^(GCHealthMeasure* obj1,GCHealthMeasure* obj2){
            return [obj2.date compare:obj1.date];
        }];
        self.measures = [NSArray arrayWithArray:measnew];
    }
}

-(GCHealthMeasure*)measureForId:(NSString*)aId andType:(gcMeasureType)aType{
    for (GCHealthMeasure * one in self.measures) {
        if ([one.measureId isEqualToString:aId] && one.type==aType) {
            return one;
        }
    }
    return nil;
}

-(GCStatsDataSerieWithUnit*)dataSerieWithUnitForHealthFieldKey:(NSString*)aType{
    gcMeasureType type = [GCHealthMeasure measureTypeFromHealthFieldKey:aType];
    GCUnit * unit = [GCHealthMeasure measureUnit:type];

    GCStatsDataSerieWithUnit * rv = [GCStatsDataSerieWithUnit dataSerieWithUnit:unit];
    for (GCHealthMeasure * one in self.measures) {
        if (one.type == type) {
            [rv addNumberWithUnit:one.value forDate:one.date];
        }
    }
    return rv;

}
-(GCStatsDataSerieWithUnit*)dataSerieWithUnitForHealthField:(GCField*)aType{
    return [self dataSerieWithUnitForHealthFieldKey:aType.key];
}
-(GCHealthMeasure*)measureOnSpecificDate:(NSDate*)aDate forType:(gcMeasureType)aField andCalendar:(NSCalendar*)calendar{
    for (GCHealthMeasure * one in self.measures) {
        if (one.type == aField && [one.date isSameCalendarDay:aDate calendar:calendar]) {
            return one;
        }
    }
    return nil;
}
-(NSArray<GCHealthMeasure*>*)measuresForDate:(NSDate*)aDate{
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    for (GCHealthMeasure * one in self.measures) {
        if ([one.date compare:aDate]==NSOrderedAscending) {
            GCHealthMeasure * found = dict[@(one.type)];
            if (!found) {
                dict[@(one.type)] = one;
            }
        }
    }
    return [dict allValues];
}

-(GCHealthMeasure*)measureForDate:(NSDate*)aDate andType:(gcMeasureType)aType{
    for (GCHealthMeasure * one in self.measures) {
        if (one.type == aType && [one.date compare:aDate]==NSOrderedAscending) {
            return one;
        }
    }
    return nil;
}

#pragma mark - Zones


-(void)saveCalculatorsToDb:(NSDictionary<NSString*,GCHealthZoneCalculator*>*)data{
    [self.db setShouldCacheStatements:YES];
    for (NSString * key in data) {
        GCHealthZoneCalculator * calc = data[key];
        for (GCHealthZone * zone in calc.zones) {
            [zone saveToDb:self.db];
        }
    }
    //[self.db setShouldCacheStatements:NO];
}

-(void)registerZoneCalculators:(NSDictionary<NSString*,GCHealthZoneCalculator*>*)data{
    self.zones = [self.zones dictionaryByAddingEntriesFromDictionary:data];
    if(self.worker){
        dispatch_async(self.worker, ^(){
            [self saveCalculatorsToDb:data];
        });
    }
    else{
        [self saveCalculatorsToDb:data];
    }
}
-(GCHealthZoneCalculator*)zoneCalculatorForField:(GCField *)field andSource:(gcHealthZoneSource)source{
    GCHealthZoneCalculator * rv = nil;
    rv = (self.zones)[[GCHealthZoneCalculator keyForField:field andSource:source]];
    return rv;
}
-(GCHealthZoneCalculator*)zoneCalculatorForField:(GCField*)field{
    GCHealthZoneCalculator * rv = nil;

    NSString * preferred = [[GCAppGlobal profile] configGetString:CONFIG_ZONE_PREFERRED_SOURCE defaultValue:@"garmin"];
    self.preferredSource = [GCHealthZone zoneSourceFromKey:preferred];

    NSArray * sourceOrder = @[ @(self.preferredSource), @(gcHealthZoneSourceGarmin), @(gcHealthZoneSourceStrava), @(gcHealthZoneSourceAuto), @(gcHealthZoneSourceManual)];

    for (NSNumber * sourceVal in sourceOrder) {
        gcHealthZoneSource source = [sourceVal intValue];
        rv = (self.zones)[[GCHealthZoneCalculator keyForField:field andSource:source]];
        if (!rv) {
            rv = (self.zones)[[GCHealthZoneCalculator keyForField:[GCField fieldForKey:field.key andActivityType:GC_TYPE_ALL] andSource:source]];
        }
        // use the first one found.
        if( rv ){
            break;
        }
    }

    return rv;
}
-(NSArray<NSString*>*)availableZoneCalculatorsSources{
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    for (NSString * key in self.zones) {
        GCHealthZoneCalculator * calc = self.zones[key];
        dict[[GCHealthZone zoneSourceToKey:calc.source]] = @(1);
    }
    return dict.allKeys;
}
-(NSArray<GCHealthZoneCalculator*>*)availableZoneCalculatorsForSource:(gcHealthZoneSource)source{
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    for (NSString * key in self.zones) {
        GCHealthZoneCalculator * calc = self.zones[key];
        NSString * sourceKey = [GCHealthZone zoneSourceToKey:calc.source];
        NSMutableArray * allForSource = dict[sourceKey];
        if(allForSource == nil){
            allForSource = [NSMutableArray arrayWithObject:calc];
            dict[sourceKey] = allForSource;
        }else{
            [allForSource addObject:calc];
        }
    }
    NSString * inputKey = [GCHealthZone zoneSourceToKey:source];
    return dict[inputKey];

}

-(void)forceZoneRefresh{
    self.zones = nil;
}

-(void)clearAllZones{
    self.zones = @{};
}
#pragma mark - Automatic Zones
// 5:30 ->  4:30, 4:45, 5:00, 5:30, 6:00
// 5:00 ->  4:00, 4:15, 4:30, 5:00, 5:30

// 8:00 ->  7:00, 7:15, 7:30, 8:00, 8:30
// 9:00 ->  8:00, 8:15, 8:30, 9:00, 9:30

-(GCHealthZoneCalculator*)createCalculatorFromMaxField:(GCField*)field
                                                 since:(NSDate*)from
                                           percentages:(NSArray<NSNumber*>*)pcts
{
    GCHealthZoneCalculator * rv = nil;

    GCField * maxField = [field correspondingMaxField];

    if(maxField){
        GCActivityMatchBlock typeAct = ^(GCActivity*act){
            BOOL rv = [act.activityType isEqualToString:field.activityType] && ([act.date compare:from] == NSOrderedDescending);
            return rv;
        };
        NSDictionary * series = [[GCAppGlobal organizer] fieldsSeries:@[ maxField ]
                                                             matching:typeAct
                                                          useFiltered:NO
                                                           ignoreMode:[field.activityType isEqualToString:GC_TYPE_DAY] ? gcIgnoreModeDayFocus : gcIgnoreModeActivityFocus];
        GCStatsDataSerieWithUnit * serie = series[maxField];
        if (serie) {
            gcStatsRange range = [serie.serie range];
            double max = range.y_max;

            NSMutableArray * zones = [NSMutableArray arrayWithCapacity:5];

            NSNumber * prev = nil;
            NSUInteger idx = 1;
            for (NSNumber * lower in pcts) {
                if( prev ){
                    double pct_to   = [lower doubleValue];
                    double pct_from = [prev doubleValue];
                    NSString * name= [NSString stringWithFormat:@"Zone %lu", (long unsigned)idx];
                    GCHealthZone * one = [GCHealthZone zoneForField:field from:pct_from*max to:pct_to*max inUnit:field.unit index:idx name:name andSource:gcHealthZoneSourceAuto];
                    [zones addObject:one];
                    idx++;
                }
                prev = lower;
            }

            rv = [GCHealthZoneCalculator zoneCalculatorForZones:zones andField:field];
        }

    }
    return rv;

}

-(GCHealthZoneCalculator *)createCalculatorForField:(GCField*)field
                                       unit:(NSString*)unitkey
                                    offsets:(double*)zoneOffset
                                   noffsets:(int)noffset
                                defaultHalf:(double)defaultHalf
                                 defaultInc:(double)defaultInc
{
    GCHealthZoneCalculator * rv = nil;

    GCActivityMatchBlock typeAct = ^(GCActivity*act){
        return [act.activityType isEqualToString:field.activityType];
    };
    NSDictionary * series = [[GCAppGlobal organizer] fieldsSeries:@[ field ]
                                                         matching:typeAct
                                                      useFiltered:NO
                                                       ignoreMode:[field.activityType isEqualToString:GC_TYPE_DAY] ? gcIgnoreModeDayFocus : gcIgnoreModeActivityFocus];
    GCStatsDataSerieWithUnit * serie = series[field];
    if (serie) {
        GCStatsDataSerie * qrt = [serie.serie quantiles:2];
        GCUnit * unit = [GCUnit unitForKey:unitkey];
        double half = defaultHalf;
        double inc  = defaultInc;
        if (qrt && [qrt count]> 1) {
            GCStatsDataPoint * halfPoint = [qrt dataPointAtIndex:1];
            half = [serie.unit convertDouble:halfPoint.y_data toUnit:unit];
        }
        half = round( half/inc )*inc;
        // half+1.,half+0.5,half,half-0.5,half-0.75,half-1.
        NSMutableArray * zones = [NSMutableArray arrayWithCapacity:5];

        for (size_t i=0; i<noffset-1; i++) {
            double from = zoneOffset[i];
            double to   = zoneOffset[i+1];
            to += half;
            from += half;
            GCHealthZone * zone = [GCHealthZone zoneForField:field
                                                        from:from
                                                          to:to
                                                      inUnit:field.unit
                                                       index:i
                                                        name:[NSString stringWithFormat:@"Zone %d", (int)i]
                                                   andSource:gcHealthZoneSourceAuto];

            [zones addObject:zone];
        }
        rv = [GCHealthZoneCalculator zoneCalculatorForZones:zones andField:field];
    }
    return rv;
}

-(void)addDefaultZoneCalculatorTo:(NSMutableDictionary*)dict{
    [self addDefaultZoneCalculatorForHealthTo:dict];
    [self addDefaultZoneCalculatorFromHistoryTo:dict];

    /*
    NSArray * hrZoneNames = @[ NSLocalizedString(@"Warm up", @"HR Zones"),
                               NSLocalizedString(@"Easy", @"HR Zones"),
                               NSLocalizedString(@"Aerobic", @"HR Zones"),
                               NSLocalizedString(@"Threshold", @"HR Zones"),
                               NSLocalizedString(@"Maximum", @"HR Zones") ];

    for (NSString  * key in self.zones) {
        GCHealthZoneCalculator * calc = self.zones[key];
        if (calc.field.fieldFlag == gcFieldFlagWeightedMeanHeartRate) {
            if (calc.zones.count <= hrZoneNames.count+1) {
                for (NSUInteger i=0; i<hrZoneNames.count; i++) {
                    NSUInteger zonesIdx = calc.zones.count-1-i;
                    NSUInteger nameIdx  = hrZoneNames.count-1-i;
                    GCHealthZone * zone = calc.zones[zonesIdx];
                    if ([zone.zoneName hasPrefix:@"Zone "]) {
                        zone.zoneName = hrZoneNames[nameIdx];
                    }
                }
            }
        }
    }*/
}

/*
 http://www.ontherunevents.com/ns0060.htm

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

 */

-(void)addDefaultZoneCalculatorForHealthTo:(NSMutableDictionary*)zones{

    GCHealthZoneCalculator * (^buildOne)(NSArray*defs,GCField*field,GCUnit*unit) = ^(NSArray*defs,GCField*field,GCUnit*unit){
        NSMutableArray * healthZones = [NSMutableArray arrayWithCapacity:defs.count];
        NSUInteger idx = 0;
        for (NSArray * dict in defs) {
            GCHealthZone * zone = [GCHealthZone zoneForField:field
                                                        from:[dict[0] doubleValue]
                                                          to:[dict[1] doubleValue]
                                                      inUnit:unit
                                                       index:idx
                                                        name:dict[2]
                                                   andSource:gcHealthZoneSourceAuto];
            [healthZones addObject:zone];
        }
        return [GCHealthZoneCalculator zoneCalculatorForZones:healthZones andField:field];
    };

    GCField * daySpeed = [GCField fieldForFlag:gcFieldFlagWeightedMeanSpeed andActivityType:GC_TYPE_DAY];

    if ( !zones[[GCHealthZoneCalculator keyForField:daySpeed andSource:gcHealthZoneSourceAuto]]) {
        // in MPH
        NSArray<NSArray*> * defs = @[
                           @[ @(4.5), @(30.), @"Very Active"],
                           @[ @(3.0), @(4.5), @"Moderately Active"],
                           @[ @(0.0), @(3.0), @"Lightly Active"],
                           ];

        GCHealthZoneCalculator * z = buildOne(defs, daySpeed, [GCUnit unitForKey:@"mph"] );
        if (z) {
            [zones setValue:z forKey:[GCHealthZoneCalculator keyForField:daySpeed andSource:gcHealthZoneSourceAuto]];
        }
    }

    GCField * dayCadence = [GCField fieldForFlag:gcFieldFlagCadence andActivityType:GC_TYPE_DAY];
    if ( !zones[[GCHealthZoneCalculator keyForField:dayCadence andSource:gcHealthZoneSourceAuto]]) {
        // in step/min
        NSArray * defs = @[
                           @[ @(70.), @(300.), @"Very Active"],
                           @[ @(50.), @(70.), @"Moderately Active"],
                           @[ @(0.0), @(50.), @"Lightly Active"],

                           ];

        GCHealthZoneCalculator * z = buildOne(defs, dayCadence, [GCUnit unitForKey:@"stepsPerMinute"]);
        if (z) {
            [zones setValue:z forKey:[GCHealthZoneCalculator keyForField:dayCadence andSource:gcHealthZoneSourceAuto]];
        }
    }

}

-(void)addDefaultZoneCalculatorFromHistoryTo:(NSMutableDictionary*)zones{

    GCField * runningSpeed = [GCField fieldForFlag:gcFieldFlagWeightedMeanSpeed andActivityType:GC_TYPE_RUNNING];
    if (!(zones)[[GCHealthZoneCalculator keyForField:runningSpeed andSource:gcHealthZoneSourceAuto]]) {
        GCUnit * unit = [[GCUnit unitForKey:@"minperkm"] unitForGlobalSystem];
        double half = [unit.key isEqualToString:@"minperkm"] ? 5.  : 8.;//default 5min/km or 8min/miles
        double inc  = [unit.key isEqualToString:@"minperkm"] ? 0.5 : 0.5;
        double zoneOffset[6] = { -1., -0.75,-0.5, 0., 0.5, 1.0 };

        GCHealthZoneCalculator * z = [self createCalculatorForField:runningSpeed
                                                               unit:unit.key
                                                            offsets:zoneOffset
                                                           noffsets:6
                                                        defaultHalf:half
                                                         defaultInc:inc];
        if (z) {
            [zones setValue:z forKey:[GCHealthZoneCalculator keyForField:runningSpeed andSource:gcHealthZoneSourceAuto]];
        }
    }

    GCField * cyclingSpeed = [GCField fieldForFlag:gcFieldFlagWeightedMeanSpeed andActivityType:GC_TYPE_CYCLING];
    if (!zones[[GCHealthZoneCalculator keyForField:cyclingSpeed andSource:gcHealthZoneSourceAuto]]) {
        GCUnit * unit = [[GCUnit unitForKey:@"kph"] unitForGlobalSystem];
        double half = [unit.key isEqualToString:@"kph"] ? 20.  : 15.;//default 5min/km or 8min/miles
        double inc  = [unit.key isEqualToString:@"kph"] ? 5. : 5.;
        double zoneOffset[7] = { -15., -10., -5., 0., 5., 7.5, 10. };

        GCHealthZoneCalculator * z = [self createCalculatorForField:cyclingSpeed unit:unit.key offsets:zoneOffset noffsets:7 defaultHalf:half defaultInc:inc];
        if (z) {
            [zones setValue:z forKey:[GCHealthZoneCalculator keyForField:cyclingSpeed andSource:gcHealthZoneSourceAuto]];
        }
    }

    GCField * runningHr = [GCField fieldForFlag:gcFieldFlagWeightedMeanHeartRate andActivityType:GC_TYPE_RUNNING];
    if(!zones[ [GCHealthZoneCalculator keyForField:runningHr andSource:gcHealthZoneSourceAuto]]){
        NSDate *from=[[[GCAppGlobal organizer] lastActivity].date dateByAddingGregorianComponents:[NSDateComponents dateComponentsFromString:@"-6m"]];
        NSArray<NSNumber*>*pcts = @[ @(0.5), @(0.6), @(0.7), @(0.8), @(0.9), @(1.0) ];
        GCHealthZoneCalculator * z = [self createCalculatorFromMaxField:runningHr since:from percentages:pcts];
        if(z) {
            [zones setValue:z forKey:[GCHealthZoneCalculator keyForField:runningHr andSource:gcHealthZoneSourceAuto]];
        }
    }
    GCField * cyclingHr = [GCField fieldForFlag:gcFieldFlagWeightedMeanHeartRate andActivityType:GC_TYPE_CYCLING];
    if(!zones[ [GCHealthZoneCalculator keyForField:cyclingHr andSource:gcHealthZoneSourceAuto]]){
        NSDate *from=[[[GCAppGlobal organizer] lastActivity].date dateByAddingGregorianComponents:[NSDateComponents dateComponentsFromString:@"-6m"]];
        NSArray<NSNumber*>*pcts = @[ @(0.5), @(0.6), @(0.7), @(0.8), @(0.9), @(1.0) ];
        GCHealthZoneCalculator * z = [self createCalculatorFromMaxField:cyclingHr since:from percentages:pcts];
        if(z) {
            [zones setValue:z forKey:[GCHealthZoneCalculator keyForField:cyclingHr andSource:gcHealthZoneSourceAuto]];
        }
    }

    GCField * runningPower = [GCField fieldForFlag:gcFieldFlagPower andActivityType:GC_TYPE_RUNNING];
    if(!zones[ [GCHealthZoneCalculator keyForField:runningPower andSource:gcHealthZoneSourceAuto]]){
        NSDate *from=[[[GCAppGlobal organizer] lastActivity].date dateByAddingGregorianComponents:[NSDateComponents dateComponentsFromString:@"-6m"]];
        NSArray<NSNumber*>*pcts = @[ @(0.5), @(0.6), @(0.7), @(0.8), @(0.9), @(1.0) ];
        GCHealthZoneCalculator * z = [self createCalculatorFromMaxField:runningPower since:from percentages:pcts];
        if(z) {
            [zones setValue:z forKey:[GCHealthZoneCalculator keyForField:runningPower andSource:gcHealthZoneSourceAuto]];
        }
    }
    GCField * cyclingPower = [GCField fieldForFlag:gcFieldFlagPower andActivityType:GC_TYPE_CYCLING];
    if(!zones[ [GCHealthZoneCalculator keyForField:cyclingPower andSource:gcHealthZoneSourceAuto]]){
        NSDate *from=[[[GCAppGlobal organizer] lastActivity].date dateByAddingGregorianComponents:[NSDateComponents dateComponentsFromString:@"-6m"]];
        NSArray<NSNumber*>*pcts = @[ @(0.), @(0.10), @(0.20), @(0.30), @(0.40), @(0.50), @(0.75), @(1.0) ];
        GCHealthZoneCalculator * z = [self createCalculatorFromMaxField:cyclingPower since:from percentages:pcts];
        if(z) {
            [zones setValue:z forKey:[GCHealthZoneCalculator keyForField:cyclingPower andSource:gcHealthZoneSourceAuto]];
        }
    }
}

@end
