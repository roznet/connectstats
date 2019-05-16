//  MIT Licence
//
//  Created on 13/09/2012.
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

#import "GCTestBasics.h"
#import "GCAppGlobal.h"
#import "GCGarminActivityXMLParser.h"
#import "GCGarminActivityDetailJsonParser.h"
#import "GCGarminActivitySummaryParser.h"
#import "GCActivity+Calculated.h"
#import "GCGarminUserJsonParser.h"
#import "GCHealthOrganizer.h"
#import "GCHealthZoneCalculator.h"
#import "GCGarminActivityLapsParser.h"
#import "GCGarminActivityDetailJsonParser.h"
#import "GCGarminActivityWeatherParser.h"
#import "GCGarminActivityWeatherHtml.h"
#import "GCActivity+Import.h"

#define kRegrUnit @"unit"
#define kRegrValue @"value"


@implementation GCTestBasics

-(NSArray*)testDefinitions{
    return @[ @{@"selector":NSStringFromSelector(@selector(testBasics)),
                @"description":@"Test Upgrade of datasbe for swim and fenix",
                @"session":@"GC Basics"},
              @{@"selector":NSStringFromSelector(@selector(testWeatherParsing)),
                @"description":@"Test weather parsing",
                @"session":@"GC Weather"},
              ];
}



#pragma mark - Basics

-(void)testBasics{
    [self startSession:@"GC Basics"];

    [GCAppGlobal cleanWritableFiles];

    // Need to turn off duplicate check as it will compare to count from db select
    [GCAppGlobal setupSampleState:@"sample_activities_v1.db" config:@{CONFIG_FULL_DUPLICATE_CHECK:@(false)}];
    [self testSwimAlgo:@"sample_activities_v1.db"];

    [GCAppGlobal setupSampleState:@"sample_activities.db" config:@{CONFIG_FULL_DUPLICATE_CHECK:@(false)}];
    [self testSwimAlgo:@"sample_activities.db"];

    [self endSession:@"GC Basics"];

}

-(void)testSwimAlgo:(NSString*)sampleName{
    FMDatabase * db = [FMDatabase databaseWithPath:[RZFileOrganizer bundleFilePath:sampleName]];
    [db open];
    int count = [db intForQuery:@"SELECT count(*) from gc_activities"];
    int countswim = [db intForQuery:@"SELECT count(*) from gc_activities_meta where field='garminSwimAlgorithm' and display=1"];
    [db close];

    RZ_ASSERT([[GCAppGlobal organizer] countOfActivities]==count, @"loaded activities %d==%d", (int)[[GCAppGlobal organizer] countOfActivities], count);
    NSUInteger swim = 0;
    for (GCActivity * act in [[GCAppGlobal organizer] activities]) {
        if ([act garminSwimAlgorithm]) {
            [self assessTestResult:@"downloadMethod" result:[act downloadMethod] == gcDownloadMethodSwim];
            swim += 1;
        }else{
            [self assessTestResult:@"downloadMethod" result:[act downloadMethod] != gcDownloadMethodSwim];
        }
    }
    [self assessTestResult:@"Swim algo" result:swim == countswim];
}

#pragma mark - TracksLap

-(NSDictionary*)lapDictionary:(GCLap*)lap forActivity:(GCActivity*)act{
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    for (NSDictionary * one in @[[lap calculated],[lap extra]]) {
        for (NSString*key in one) {
            id val = [one objectForKey:key];
            if ([val isKindOfClass:[GCNumberWithUnit class]]) {
                GCNumberWithUnit * nu = val;
                [dict setObject:[nu savedDict] forKey:key];
            }else{
                [dict setObject:val forKey:key];
            }
        }
    }
    gcFieldFlag flags[] = { gcFieldFlagWeightedMeanSpeed,gcFieldFlagSumDistance,gcFieldFlagWeightedMeanHeartRate,gcFieldFlagPower,gcFieldFlagCadence };
    NSString * atype = act.activityType;
    size_t n = sizeof(flags)/sizeof(gcFieldFlag);
    for (size_t i=0; i<n; i++) {
        gcFieldFlag flag = flags[i];
        GCField * field = [GCField fieldForFlag:flag andActivityType:atype];
        
        if ([act hasTrackForField:field]) {
            GCNumberWithUnit * nu = [lap numberWithUnitForField:field inActivity:act];
            [dict setObject:nu.savedDict?:@{} forKey:field?:@""];
        }
    }
    [dict setObject:[lap time] forKey:@"time"];
    return [NSDictionary dictionaryWithDictionary:dict];
}

-(NSNumber*)numberFromObject:(id)o{
    NSNumber * rv = nil;
    if ([o isKindOfClass:[NSDictionary class]]) {
        GCNumberWithUnit * nu = [GCNumberWithUnit numberWithUnitFromSavedDict:o];
        rv = nu.number;
    }else if ([o isKindOfClass:[NSNumber class]]){
        rv = o;
    }else if ([o respondsToSelector:@selector(doubleValue)]){
        rv = @([o doubleValue]);
    }else if ([o isKindOfClass:[NSDate class]]){
        rv = @([o timeIntervalSinceReferenceDate]);
    }else{
        NSLog(@"Oops: %@", o);
    }
    return rv;
}

-(void)compareLapsCalculated:(NSArray*)one toExpected:(NSDictionary*)expected forName:(NSString*)name{
    NSArray * oneExpected = [expected objectForKey:name];

    [self assessTrue:[one count]==[oneExpected count] msg:@"Number of laps: got %d, expected %d", [one count],[oneExpected count]];

    double TOLERANCE = 1.e-3; // iOS8 numerical diffs

    for (NSUInteger i=0; i<MIN([one count], [oneExpected count]); i++) {
        NSDictionary * d_calc = [one objectAtIndex:i];
        NSDictionary * d_expected = [oneExpected objectAtIndex:i];
        for (NSString*key in d_expected) {
            NSNumber * val = [self numberFromObject:[d_expected objectForKey:key]];
            NSNumber * got = [self numberFromObject:[d_calc objectForKey:key]];


            if (val && got) {
                double dval = [val doubleValue];
                double dgot = [got doubleValue];
                double eps = 0.;
                if (dval!= 0.) {
                    eps = dgot/dval-1.;
                }else{
                    eps = dgot-dval;
                }
                [self assessTrue:fabs(eps)<TOLERANCE msg:@"%@[%d] %@ diff %@!=%@ (%f)", name,i,key,val,got,eps];
            }else{
                [self assessTrue:[got isEqual:val] msg:@"%@[%d] %@ diff %@!=%@", name,i,key,val,got?got:@"(NULL)"];
            }

        }

    }

}

-(void)testLapsCalculated{
    NSString * aid = @"234979239";
    [GCAppGlobal configSet:CONFIG_USE_MOVING_ELAPSED boolVal:true];
    NSMutableDictionary * rebase =[NSMutableDictionary dictionaryWithCapacity:5];
    NSDictionary * expected = [NSDictionary dictionaryWithContentsOfFile:[RZFileOrganizer bundleFilePath:@"laps_regr.plist"]];

    GCActivity * act = [[GCAppGlobal organizer] activityForId:aid];
    NSMutableArray * one = [NSMutableArray arrayWithCapacity:[act.laps count]];

    for (GCLap * lap in act.laps) {
        [one addObject:[self lapDictionary:lap forActivity:act]];

    }
    [rebase setObject:[NSArray arrayWithArray:one] forKey:@"recorded"];
    [self compareLapsCalculated:one toExpected:expected forName:@"recorded"];

    void(^runOne)(double,NSString*,BOOL) = ^(double dist,NSString*name,BOOL roll){
        NSMutableArray * laps = nil;
        if (roll) {
            laps = [NSMutableArray arrayWithArray:[act calculatedRollingLapFor:dist match:[act matchDistanceBlockEqual] compare:[act compareSpeedBlock]]];
        }else{
            laps = [NSMutableArray arrayWithArray:[act calculatedLapFor:dist match:[act matchDistanceBlockGreater] inLap:GC_ALL_LAPS]];
        }
        [act registerLaps:laps forName:name];
        [act useLaps:name];
        NSMutableArray * claps = [NSMutableArray arrayWithCapacity:[act.laps count]];
        for (GCLap * lap in act.laps) {
            [claps addObject:[self lapDictionary:lap forActivity:act]];
        }
        [rebase setObject:[NSArray arrayWithArray:claps] forKey:name];
        [self compareLapsCalculated:claps toExpected:expected forName:name];

    };

    runOne(1609.34,@"1mile",false);
    runOne(1000.,@"1km",false);
    runOne(1000.,@"fast1km",true);
    runOne(1609.34,@"fast1mile",true);

    NSDictionary * save = [NSDictionary dictionaryWithDictionary:rebase];

    if(![save writeToFile:[RZFileOrganizer writeableFilePath:@"laps_regr.plist"] atomically:YES]){
        NSLog(@"Fail");
    }
}


#pragma mark - New Parsing


-(void)compareActivityTrackpoints:(GCActivity*)activity with:(GCActivity*)activity13 id:(NSString*)aId{
    [self assessTrue:[activity.trackpoints count]==[activity13.trackpoints count]
                 msg:@"%@ Same number of track points %d==%d",aId,[activity.trackpoints count],[activity13.trackpoints count]];
    [self assessTrue:[activity.laps count]==[activity13.laps count]
                 msg:@"%@ Same number of laps %d==%d",aId,[activity.laps count],[activity13.laps count]];
    // extra flags don't exist in old format
    RZ_ASSERT(activity.trackFlags == activity13.trackFlags, @"%@ same fields %d==%d", aId, activity13.trackFlags,activity.trackFlags);

    NSArray<GCField*> * fields = activity.availableTrackFields;
    NSUInteger diffValue = 0;
    NSUInteger diffLapIndex = 0;
    NSUInteger diffTime = 0;

    GCNumberWithUnit * lastBadVal = nil;
    GCNumberWithUnit * lastBadVal2 = nil;
    NSString * lastBadValField = nil;
    NSUInteger lastBadValIdx = 0;

    NSDate * lastBadTime = nil;
    NSDate * lastBadTime2= nil;
    NSUInteger lastBadTimeIdx = 0;

    NSUInteger lastBadLapIdx = 0;

    for (NSUInteger i=0; i<MIN([activity.trackpoints count], [activity13.trackpoints count]); i++) {
        GCTrackPoint * p   = [activity.trackpoints objectAtIndex:i];
        GCTrackPoint * p13 = [activity13.trackpoints objectAtIndex:i];
        for (GCField * field in fields) {
            GCNumberWithUnit * v = [p numberWithUnitForField:field inActivity:activity];
            GCNumberWithUnit * v13 = [p13 numberWithUnitForField:field inActivity:activity13];
            if (![v isEqualToNumberWithUnit:v13]) {
                diffValue++;
                if (diffValue==1) {
                    lastBadVal=v;
                    lastBadVal2=v13;
                    lastBadValField =field.displayName;
                    lastBadValIdx = i;
                }
            }
            if (!(p.lapIndex==p13.lapIndex)) {
                diffLapIndex++;
            }
            if (![p.time isEqualToDate:p13.time]) {
                diffTime++;
                lastBadTime = p.time;
                lastBadTime2 = p13.time;
                lastBadTimeIdx = i;
            }
        }
    }
    [self assessTrue:(diffValue==0)    msg:@"%@ %d valueDiff: point[%d] %@: %f=%f", aId, diffValue, lastBadValIdx, lastBadValField, lastBadVal,lastBadVal2];
    [self assessTrue:(diffLapIndex==0) msg:@"%@ %d lapDiff:   point[%d]",aId, diffLapIndex, lastBadLapIdx];
    [self assessTrue:(diffTime==0)     msg:@"%@ %d timeDiff:  point[%d] %@/%@",aId, diffTime, lastBadTimeIdx, lastBadTime,lastBadTime2];

    diffValue = 0;
    diffTime  = 0;
    for (NSUInteger i = 0; i<MIN([activity.laps count], [activity13.laps count]); i++) {
        GCLap * lap = [activity.laps objectAtIndex:i];
        GCLap * lap13=[activity13.laps objectAtIndex:i];
        for (GCField * field in fields) {
            BOOL common = [activity13 hasTrackForField:field];
            if (!common) {
                NSLog(@"not common: %@", field.displayName);
            }
            if (field.fieldFlag==gcFieldFlagAltitudeMeters) {
                // old format didn't have altitude in laps
                continue;
            }
            GCNumberWithUnit * v = [lap numberWithUnitForField:field inActivity:activity];
            GCNumberWithUnit * v13 = [lap13 numberWithUnitForField:field inActivity:activity13];

            if (![v isEqualToNumberWithUnit:v13]) {
                diffValue++;
                if (diffValue==1) {
                    lastBadVal=v;
                    lastBadVal2=v13;
                    lastBadValField =field.displayName;
                    lastBadValIdx = i;
                }
            }
            if (![lap.time isEqualToDate:lap13.time]) {
                diffTime++;
                if (diffTime==1) {
                    lastBadTime = lap.time;
                    lastBadTime2 = lap13.time;
                    lastBadTimeIdx = i;
                }
            }
        }

    }
    [self assessTrue:(diffValue==0)    msg:@"%@ %d valueDiff: lap[%d] %@: %f=%f", aId, diffValue, lastBadValIdx, lastBadValField, lastBadVal,lastBadVal2];
    [self assessTrue:(diffTime==0)     msg:@"%@ %d timeDiff:  lap[%d] %@/%@",aId,diffTime, lastBadTimeIdx, lastBadTime,lastBadTime2];
}

#pragma mark - Weather

-(void)testWeatherParsing{
    [self startSession:@"GC Weather"];

    NSArray * aIds = @[@"395288954",@"395288975",@"397686263",@"397686271",@"397686279",@"397686290",@"398557492"];
    for (NSString * aId in aIds) {
        NSStringEncoding encoding = NSUTF8StringEncoding;
        NSString * fn = [NSString stringWithFormat:@"activity_%@.html",aId];
        NSError*error =nil;
        NSString * theString = [NSString stringWithContentsOfFile:[RZFileOrganizer bundleFilePath:fn] encoding:encoding error:&error];
        theString = [GCGarminActivityWeatherHtml extractWeatherSection:theString];
        [self assessTrue:theString!=nil msg:@"Extract weather subpart"];
        if (theString) {
            GCGarminActivityWeatherParser * parser = [GCGarminActivityWeatherParser garminActivityWeatherParser:theString andEncoding:encoding];
            [self assessTrue:parser.success msg:@"Weather parsing succeeded"];
            if (parser.success) {
                GCWeather * weather= parser.weather;
                [self assessTrue:weather.valid msg:@"Weather valid"];
            }
        }
    }
    [self endSession:@"GC Weather"];

}
@end
