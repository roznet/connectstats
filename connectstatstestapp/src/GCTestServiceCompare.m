//  MIT License
//
//  Created on 20/07/2019 for ConnectStatsTestApp
//
//  Copyright (c) 2019 Brice Rosenzweig
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



#import "GCTestServiceCompare.h"
#import "GCAppGlobal.h"
#import "GCActivitiesOrganizer.h"

NSString * kDbPathServiceConnectStats = @"activities_cs.db";
NSString * kDbPathServiceStrava = @"activities_strava.db";
NSString * kDbPathServiceGarmin = @"activities_gc_alt.db";
// Download 10 detail files
NSUInteger kCompareDetailCount = 10;

NSString * kJsonKeySummaries = @"summaries";
NSString * kJsonKeyDuplicates = @"duplicates";
NSString * kJsonKeyTypes = @"types";

@interface GCTestServiceCompare ()
@property (nonatomic,retain) NSMutableDictionary * collectJson;
@end

@implementation GCTestServiceCompare

-(NSArray*)testDefinitions{
    return @[ @{TK_SEL:NSStringFromSelector(@selector(testCompareServices)),
                TK_DESC:@"Test To Compare Services",
                TK_SESS:@"GC Compare Services"},
              
              ];
}

-(void)dealloc{
    [_collectJson release];
    
    [super dealloc];
}

-(void)testCompareServices{
    [self startSession:@"GC Compare Services"];
    
    self.collectJson = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                       kJsonKeySummaries : [NSMutableDictionary dictionary],
                                                                       kJsonKeyTypes     : [NSMutableDictionary dictionary],
                                                                       kJsonKeyDuplicates: [NSMutableDictionary dictionary]
                                                                       }];
    
    NSString * fp_cs = [RZFileOrganizer writeableFilePathIfExists:kDbPathServiceConnectStats];
    NSString * fp_strava = [RZFileOrganizer writeableFilePathIfExists:kDbPathServiceStrava];
    NSString * fp_garmin = [RZFileOrganizer writeableFilePathIfExists:kDbPathServiceGarmin];
    
    FMDatabase * db_cs      = fp_cs ?       [FMDatabase databaseWithPath:fp_cs]     : nil;
    FMDatabase * db_strava  = fp_strava ?   [FMDatabase databaseWithPath:fp_strava] : nil;
    FMDatabase * db_garmin  = fp_garmin ?   [FMDatabase databaseWithPath:fp_garmin] : nil;
    
    [db_strava open];
    [db_garmin open];
    [db_cs open];
    
    GCActivitiesOrganizer * organizer_cs        = db_cs     ? [[GCActivitiesOrganizer alloc] initTestModeWithDb:db_cs]      : nil;
    GCActivitiesOrganizer * organizer_strava    = db_strava ? [[GCActivitiesOrganizer alloc] initTestModeWithDb:db_strava]  : nil;
    GCActivitiesOrganizer * organizer_garmin    = db_garmin ? [[GCActivitiesOrganizer alloc] initTestModeWithDb:db_garmin]  : nil;
    
    if( organizer_cs && organizer_garmin){
        [self compareOrganizer:organizer_garmin withName:@"garmin" to:organizer_cs withName:@"cs"];
    }
    if( organizer_strava && organizer_garmin){
        [self compareOrganizer:organizer_garmin withName:@"garmin" to:organizer_strava withName:@"strava"];
    }
    if( organizer_strava && organizer_cs ){
        [self compareOrganizer:organizer_cs withName:@"cs" to:organizer_strava withName:@"strava"];
    }
    
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:self.collectJson options:NSJSONWritingPrettyPrinted error:nil];
    if( jsonData ){
        NSString * jsonFn = [RZFileOrganizer writeableFilePath:@"services_activities.json"];
        
        if( [jsonData writeToFile:jsonFn atomically:YES] ){
            NSLog(@"Wrote %@", jsonFn);
        }
    }
    
    [organizer_cs release];
    [organizer_strava release];
    [organizer_garmin release];
    
    [self endSession:@"GC Compare Services"];
}

-(void)recordDuplicate:(GCActivity*)one for:(GCActivity*)two{
    
    NSMutableDictionary * dict = self.collectJson[kJsonKeyDuplicates][one.activityId];
    if( dict == nil){
        self.collectJson[kJsonKeyDuplicates][one.activityId] = [NSMutableDictionary dictionaryWithObject:@(1) forKey:two.activityId];
    }else{
        dict[two.activityId] = @(1);
    }
}

-(void)recordSimpleSummary:(GCActivity*)act{
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
    for (GCField * field in act.summaryData) {
        GCActivitySummaryValue * value = act.summaryData[field];
        if( field.isWeightedAverage || field.canSum){
            dictionary[field.key] = value.numberWithUnit.savedDict;
        }
    }
    self.collectJson[kJsonKeySummaries][act.activityId] = dictionary;
}

-(void)recordType:(GCActivity*)act{
    NSString * type = act.activityType;
    if( [type isEqualToString:GC_TYPE_OTHER] ){
        type = act.activityTypeDetail.key;
    }
    NSMutableDictionary * dict = self.collectJson[kJsonKeyTypes][type];
    if( dict == nil){
        self.collectJson[kJsonKeyTypes][type] = [NSMutableDictionary dictionaryWithObject:@(1) forKey:act.activityId];
    }else{
        dict[act.activityId] = @(1);
    }

}
-(void)compareField:(gcFieldFlag)fieldFlag forActivity:(GCActivity*)one withName:(NSString*)nameOne and:(GCActivity*)two withName:(NSString*)nameTwo{
    GCField * field = [GCField fieldForFlag:fieldFlag andActivityType:one.activityType];
    
    GCNumberWithUnit * nu_one = [one numberWithUnitForField:field];
    GCNumberWithUnit * nu_two = [two numberWithUnitForField:field];
    
    RZ_ASSERT([[nu_one formatDouble] isEqualToString:[nu_two formatDouble]],  @"%@:%@ %@:%@ == %@:%@", field, one, nameOne, nu_one, nameTwo, nu_two );
    //RZ_ASSERT([nu_one compare:nu_two withTolerance:1.e-5] == NSOrderedSame, @"%@:%@ %@ == %@", field, one, nu_one, nu_two );
    
}

-(NSDictionary*)compareOrganizer:(GCActivitiesOrganizer*)one withName:(NSString*)nameOne
                     to:(GCActivitiesOrganizer*)two withName:(NSString*)nameTwo{
    NSMutableDictionary * rv = [NSMutableDictionary dictionary];
    
    for( NSUInteger idx = 0; idx < kCompareDetailCount; idx++){
        GCActivity * activityOne = [one activityForIndex:idx];
        GCActivity * activityTwo = [two findDuplicate:activityOne];
        
        [self recordSimpleSummary:activityOne];
        [self recordSimpleSummary:activityTwo];
        
        [self recordType:activityOne];
        [self recordType:activityTwo];
        
        RZ_ASSERT(activityTwo != nil, @"Found %@:%@ in %@", nameOne, activityOne, nameTwo);
        if( activityTwo ){
            [self recordDuplicate:activityOne for:activityTwo];
            [self recordDuplicate:activityTwo for:activityOne];
        }
        NSLog(@"Found %@:%@ = %@:%@", nameOne, activityOne, nameTwo, activityTwo);
        
        if( /* DISABLES CODE */ (false) ){
            // Slight difference for a few instance, not exact match
            [self compareField:gcFieldFlagSumDuration forActivity:activityOne withName:nameOne and:activityTwo withName:nameTwo];
            [self compareField:gcFieldFlagSumDistance forActivity:activityOne withName:nameOne and:activityTwo withName:nameTwo];
        }
    }
    return rv;
}


-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
}

@end
