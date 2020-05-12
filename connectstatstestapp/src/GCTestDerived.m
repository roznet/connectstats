//  MIT Licence
//
//  Created on 27/07/2015.
//
//  Copyright (c) 2015 Brice Rosenzweig.
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

#import "GCTestDerived.h"
#import "GCAppGlobal.h"
#import "GCActivity+Database.h"
#import "GCActivity+CachedTracks.h"
#import "GCWebConnect+Requests.h"
#import "GCTestsSamples.h"

#define STAGE_START @(0)
#define STAGE_END   @(1)

#define IS_START(x) x.integerValue == 0
#define IS_END(x)   x.integerValue == 1

@interface GCTestDerived ()
@property (nonatomic,assign) NSUInteger stage;
@end

@implementation GCTestDerived

-(NSArray*)testDefinitions{
    return @[@{TK_SEL: NSStringFromSelector(@selector(testDerived)),
               TK_DESC:@"Test Derived Best Rolling",
               TK_SESS:@"GC Derived"}
             ];
}

-(void)testDerived{
    [self startSession:@"GC Derived"];
    [GCAppGlobal setupEmptyStateWithDerived:@"activities_derived.db"];
    self.stage = 0;
    [[GCAppGlobal derived] attach:self];
    RZ_ASSERT([[GCAppGlobal organizer] countOfActivities] == 0, @"Starts empty");

    dispatch_async([GCAppGlobal worker],^(){
        [self processStage:STAGE_START];
    });
}

-(GCActivity*)importActivity:(NSString*)dbname{
    [RZFileOrganizer createEditableCopyOfFile:dbname];
    NSArray * comp = [dbname componentsSeparatedByString:@"_"];
    NSString * aId = [comp lastObject];
    if ([aId hasSuffix:@".db"]) {
        aId= [aId substringToIndex:([aId length]-3)];
    }

    NSString * trackdbname = [NSString stringWithFormat:@"track_%@.db", aId];
    NSError * e = nil;
    [RZFileOrganizer removeEditableFile:trackdbname];
    [[NSFileManager defaultManager] copyItemAtPath:[RZFileOrganizer writeableFilePath:dbname]
                                            toPath:[RZFileOrganizer writeableFilePath:trackdbname] error:&e];
    RZ_ASSERT(e==nil, @"Could copy trackdb");
    FMDatabase * adb = [GCTestsSamples sampleActivityDatabase:dbname];
    GCActivity * act = [GCActivity activityWithId:aId andDb:adb];
    NSUInteger startWith = [[GCAppGlobal organizer] countOfActivities];
    [[GCAppGlobal organizer] registerActivity:act forActivityId:act.activityId];
    RZ_ASSERT(act.trackPointsRequireDownload == NO, @"No need for download");
    RZ_ASSERT(act.trackpoints.count>0, @"Has Points");
    RZ_ASSERT([[GCAppGlobal organizer] countOfActivities] == 1+startWith, @"Added Activity");

    return [[GCAppGlobal organizer] activityForId:aId];
}

-(void)processStage:(NSNumber*)which{

    if (self.stage == 0) {
        if (IS_START(which)) {
            GCActivity * max19k   = [self importActivity:@"test_activity_running_830807000.db"];
            [[GCAppGlobal derived] processActivities:@[max19k]];
        }else{
            GCActivity * max19k = [[GCAppGlobal organizer] activityForId:@"830807000"];
            GCDerivedDataSerie * derived = [[GCAppGlobal derived] derivedDataSerie:gcDerivedTypeBestRolling
                                                                             field:gcFieldFlagWeightedMeanHeartRate
                                                                            period:gcDerivedPeriodMonth
                                                                           forDate:max19k.date
                                                                   andActivityType:max19k.activityType];
            RZ_ASSERT(derived.serieWithUnit.count>0, @"Has Points");
            GCField * bestRolling = [GCField fieldForFlag:gcFieldFlagWeightedMeanHeartRate andActivityType:GC_TYPE_RUNNING].correspondingBestRollingField;
            GCStatsDataSerieWithUnit * serie = [max19k calculatedSerieForField:bestRolling thread:nil];
            RZ_ASSERT([derived.serieWithUnit.serie isEqualToSerie:serie.serie], @"Same as original");

            [self processNextStage:which];
        }

    }else if( self.stage == 1 ){
        if (IS_START(which)) {
            GCActivity * max5k    = [self importActivity:@"test_activity_running_828298988.db"];
            [[GCAppGlobal derived] processActivities:@[max5k]];

        }else{
            GCActivity * max19k = [[GCAppGlobal organizer] activityForId:@"830807000"];
            GCActivity * max5k = [[GCAppGlobal organizer] activityForId:@"828298988"];

            GCDerivedDataSerie * derived = [[GCAppGlobal derived] derivedDataSerie:gcDerivedTypeBestRolling
                                                                             field:gcFieldFlagWeightedMeanHeartRate
                                                                            period:gcDerivedPeriodMonth
                                                                           forDate:max19k.date
                                                                   andActivityType:max19k.activityType];
            // force trackpoints
            [max19k trackpoints];
            [max5k trackpoints];
            GCField * bestRollingHr = [GCField fieldForFlag:gcFieldFlagWeightedMeanHeartRate andActivityType:GC_TYPE_RUNNING].correspondingBestRollingField;
            GCStatsDataSerieWithUnit * serie19k = [max19k calculatedSerieForField:bestRollingHr thread:nil];
            GCStatsDataSerieWithUnit * serie5k = [max5k calculatedSerieForField:bestRollingHr
                                                                    thread:nil];
            RZ_ASSERT(![derived.serieWithUnit.serie isEqualToSerie:serie19k.serie], @"Not Same as original");
            RZ_ASSERT(derived.serieWithUnit.serie.count == MAX(serie19k.serie.count, serie5k.serie.count), @"count is max of the 2");
            BOOL isMax = true;
            for (NSUInteger i=0; i<MIN(serie5k.count, serie19k.count); i++) {
                GCStatsDataPoint * p1 = serie5k.serie[i];
                GCStatsDataPoint * p2 = serie19k.serie[i];
                GCStatsDataPoint * d  = derived.serieWithUnit.serie[i];

                if (fabs(p1.x_data-p2.x_data)>1e-7) {
                    isMax = false;
                }
                if (fabs(MAX(p1.y_data,p2.y_data)-d.y_data)>1e-7) {
                    isMax = false;
                }

            }
            RZ_ASSERT(isMax, @"Got max of both");
            [self processNextStage:which];

        }
    }else if( self.stage == 2){
        if (IS_START(which)) {
            GCActivity * slow10k  = [self importActivity:@"test_activity_running_835175535.db"];
            [[GCAppGlobal derived] processActivities:@[slow10k]];
        }else{
            GCActivity * max19k = [[GCAppGlobal organizer] activityForId:@"830807000"];
            GCActivity * max5k = [[GCAppGlobal organizer] activityForId:@"828298988"];
            GCActivity * slow10k = [[GCAppGlobal organizer] activityForId:@"835175535"];

            GCField * hrField = [GCField fieldForFlag:gcFieldFlagWeightedMeanHeartRate andActivityType:GC_TYPE_RUNNING];

            GCDerivedDataSerie * derived = [[GCAppGlobal derived] derivedDataSerie:gcDerivedTypeBestRolling
                                                                             field:gcFieldFlagWeightedMeanHeartRate
                                                                            period:gcDerivedPeriodMonth
                                                                           forDate:max19k.date
                                                                   andActivityType:max19k.activityType];
            // force trackpoints
            [max19k trackpoints];
            [max5k trackpoints];
            [slow10k trackpoints];
            GCStatsDataSerieWithUnit * serie19k = [max19k calculatedSerieForField:hrField.correspondingBestRollingField
                                                                    thread:nil];
            GCStatsDataSerieWithUnit * serie5k = [max5k calculatedSerieForField:hrField.correspondingBestRollingField
                                                                  thread:nil];
            GCStatsDataSerieWithUnit * serie10k = [slow10k calculatedSerieForField:hrField.correspondingBestRollingField
                                                                  thread:nil];
            RZ_ASSERT(![derived.serieWithUnit.serie isEqualToSerie:serie19k.serie], @"Not Same as original");
            RZ_ASSERT(![derived.serieWithUnit.serie isEqualToSerie:serie10k.serie], @"Not Same as original");
            RZ_ASSERT(derived.serieWithUnit.serie.count == MAX(serie19k.serie.count, serie5k.serie.count), @"count is max of the 2");
            BOOL isMax = true;
            for (NSUInteger i=0; i<MIN(serie5k.count, serie19k.count); i++) {
                GCStatsDataPoint * p1 = serie5k.serie[i];
                GCStatsDataPoint * p2 = serie19k.serie[i];
                GCStatsDataPoint * p3 = serie10k.serie[i];
                GCStatsDataPoint * d  = derived.serieWithUnit.serie[i];

                if (fabs(p1.x_data-p2.x_data)>1e-7) {
                    isMax = false;
                }
                if (fabs(MAX(MAX(p1.y_data,p2.y_data),p3.y_data)-d.y_data)>1e-7) {
                    isMax = false;
                }
            }
            RZ_ASSERT(isMax, @"Got max of both");
            [self processNextStage:which];
        }

    }




}

-(void)processNextStage:(NSNumber*)which{
    if (IS_START(which)) {
        dispatch_async([GCAppGlobal worker],^(){
            [self processStage:STAGE_END];
        });

    }else{
        self.stage++;
        if (self.stage < 3) {
            dispatch_async([GCAppGlobal worker],^(){
                [self processStage:STAGE_START];
            });
        }else{
            dispatch_async([GCAppGlobal worker],^(){
                [self finishedDerived];
            });
        }
    }
}

-(void)finishedDerived{
    [[GCAppGlobal derived] detach:self];
    // Force re-init/cleanup of derived
    [GCAppGlobal setupEmptyState:@"activities_derived.db"];
    [self endSession:@"GC Derived"];
}

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    if (theParent == [GCAppGlobal derived]) {
        if ([theInfo.stringInfo isEqualToString:kNOTIFY_DERIVED_END]) {
            dispatch_async([GCAppGlobal worker],^(){
                [self processStage:STAGE_END];
            });
        }
    }
}
@end
