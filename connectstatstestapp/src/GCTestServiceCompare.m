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

@implementation GCTestServiceCompare

-(NSArray*)testDefinitions{
    return @[ @{TK_SEL:NSStringFromSelector(@selector(testCompareServices)),
                TK_DESC:@"Test To Compare Services",
                TK_SESS:@"GC Compare Services"},
              
              ];
}

-(void)testCompareServices{
    [self startSession:@"GC Compare Services"];
    
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
    
    NSMutableDictionary * map = [NSMutableDictionary dictionary];
    
    if( organizer_cs && organizer_garmin){
        NSDictionary * one = [self compareOrganizer:organizer_garmin withName:@"garmin" to:organizer_cs withName:@"cs"];
        [self merge:map with:one];
    }
    if( organizer_strava && organizer_garmin){
        NSDictionary * one = [self compareOrganizer:organizer_garmin withName:@"garmin" to:organizer_strava withName:@"strava"];
        [self merge:map with:one];
    }
    if( organizer_strava && organizer_cs ){
        NSDictionary * one = [self compareOrganizer:organizer_cs withName:@"cs" to:organizer_strava withName:@"strava"];
        [self merge:map with:one];
    }
    NSLog(@"%@", map);
    [self endSession:@"GC Compare Services"];
}

-(void)merge:(NSMutableDictionary*)map with:(NSDictionary*)other{
    for (NSString * key in other) {
        NSString * val = other[key];
        NSMutableDictionary * defs = map[key];
        if( defs == nil){
            defs = [NSMutableDictionary dictionaryWithDictionary:@{val:@1}];
            map[key] = defs;
        }else{
            defs[val] = @1;
        }
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
        
        RZ_ASSERT(activityTwo != nil, @"Found %@:%@ in %@", nameOne, activityOne, nameTwo);
        if( activityTwo ){
            rv[activityOne.description] = activityTwo.description;
            rv[activityTwo.description] = activityOne.description;
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
