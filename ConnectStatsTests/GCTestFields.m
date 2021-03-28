//
//  GCTestFields.m
//  GarminConnect
//
//  Created by Brice Rosenzweig on 02/01/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GCTestCase.h"
#import "GCField.h"
#import "GCFields.h"
#import "GCFieldCache.h"
#import "GCActivityType.h"

@interface GCTestFields : GCTestCase

@end

@implementation GCTestFields

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFieldUniqueness{
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    GCField * fSumDistance = [GCField fieldForKey:@"SumDistance" andActivityType:GC_TYPE_RUNNING];
    dict[fSumDistance] = @(1);
    GCField * fFSumDistance = [GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:GC_TYPE_RUNNING];
    
    XCTAssertEqualObjects(fSumDistance, fFSumDistance);
    XCTAssertEqual(@(1), dict[fFSumDistance]);

    dict[fFSumDistance]= @(2);
    XCTAssertEqual(@(2), dict[fSumDistance]);
    
    GCField * other = [GCField fieldForFlag:gcFieldFlagAltitudeMeters andActivityType:GC_TYPE_RUNNING];
    XCTAssertNotEqual(other, fSumDistance);
}

-(void)testFieldCache{
    NSString * fn = @"test_field_cache.db";
    [RZFileOrganizer removeEditableFile:fn];
    FMDatabase * db = [FMDatabase databaseWithPath:[RZFileOrganizer writeableFilePath:fn]];
    [db open];
    
    GCFieldCache * cache = nil;
    GCFieldInfo * info = nil;
    
    GCFieldCache * oldCache = [GCField fieldCache];
    
    cache = [GCFieldCache cacheWithDb:db andLanguage:@"fr"];
    [GCField setFieldCache: cache];
    
    NSArray<GCField*>*allFields = [cache.availableFields sortedArrayUsingComparator:^(GCField*o1,GCField*o2){
        return [o1.key compare:o2.key];
    }];
    
    for (GCField * field in allFields) {
        GCUnit * metric = [[cache infoForField:field] unitForSystem:gcUnitSystemMetric];
        GCUnit * imperial = [[cache infoForField:field] unitForSystem:gcUnitSystemImperial];
        if( [field.key containsString:@"Elevation"] ){
            XCTAssertEqualObjects(metric.key, @"meterelevation", @"Metric %@ in meter", field);
            XCTAssertEqualObjects(imperial.key, @"footelevation", @"Imperial %@ in foot", field);
        }
        if( [field.key containsString:@"Pace"] && [field.activityType isEqualToString:GC_TYPE_RUNNING] ){
            XCTAssertEqualObjects(metric, [GCUnit minperkm], @"Metric %@ in min/km", field);
            XCTAssertEqualObjects(imperial, [GCUnit minpermile], @"Imperial %@ in min/mi", field);
        }
        if( [field.key containsString:@"Temperature"] ){
            XCTAssertEqualObjects(metric, [GCUnit celsius], @"Metric %@ in celsius", field);
            XCTAssertEqualObjects(imperial, [GCUnit fahrenheit], @"Imperial %@ in fahrenheit", field);
        }
    }
    
    GCField * weightedMeanPace = [GCField fieldForKey:@"WeightedMeanPace" andActivityType:GC_TYPE_RUNNING];
    
    info = [cache infoForField:weightedMeanPace];
    XCTAssertEqualObjects(info.displayName, @"Allure moy.");
    XCTAssertEqualObjects(info.unit,[GCUnit minperkm]);
    XCTAssertEqualObjects([weightedMeanPace displayName], @"Allure moy.");
    XCTAssertEqualObjects([weightedMeanPace unit], [GCUnit minperkm]);
    
    // Now use predefined, register will not change
    [cache registerMissingField:weightedMeanPace displayName:@"Pace" andUnitName:@"minpermile"];
    info = [cache infoForField:weightedMeanPace];
    XCTAssertEqualObjects(info.displayName, @"Allure moy.");
    XCTAssertEqualObjects(info.unit, [GCUnit minperkm]);
    XCTAssertEqualObjects([weightedMeanPace displayName], @"Allure moy.");
    XCTAssertEqualObjects([weightedMeanPace unit], [GCUnit minperkm]);
    
    // After prefer predefined go back to previous language
    info = [cache infoForField:weightedMeanPace];
    XCTAssertEqualObjects(info.displayName, @"Allure moy.");
    XCTAssertEqualObjects(info.unit, [GCUnit minperkm]);
    XCTAssertEqualObjects([weightedMeanPace displayName], @"Allure moy.");
    XCTAssertEqualObjects([weightedMeanPace unit], [GCUnit minperkm]);
    
    // Register one that does not exists
    GCField * weightedMeanPace2 = [GCField fieldForKey:@"WeightedMeanPace2" andActivityType:GC_TYPE_RUNNING];
    [cache registerMissingField:weightedMeanPace2 displayName:@"Pace2" andUnitName:@"kph"];
    info = [cache infoForField:weightedMeanPace2];
    XCTAssertEqualObjects(info.displayName, @"Pace2");
    XCTAssertEqualObjects(info.unit, [GCUnit kph]);
    XCTAssertEqualObjects([weightedMeanPace2 displayName], @"Pace2");
    XCTAssertEqualObjects([weightedMeanPace2 unit], [GCUnit kph]);
    
    [db close];
    [GCField setFieldCache:oldCache];
}

-(void)testActivityTypes{
    
    
    NSArray * allParents = [GCActivityType allParentTypes];
    for (GCActivityType * parent in allParents) {
        XCTAssertNotEqualObjects(parent, [GCActivityType all]);
        NSArray * subs = [GCActivityType allTypesForParent:parent];
        XCTAssertTrue([parent isSameParentType:[GCActivityType all]]);
        for (GCActivityType * sub in subs) {
            XCTAssertEqualObjects(sub.parentType, parent);
            XCTAssertTrue([sub isSameParentType:parent]);
            XCTAssertTrue([parent isSameParentType:sub]);
            XCTAssertEqualObjects(sub.primaryActivityType, parent);
            XCTAssertEqualObjects(sub.rootType, [GCActivityType all]);
            
            XCTAssertFalse([[GCActivityType day] isSameParentType:sub]);
            XCTAssertFalse([[GCActivityType day] isSameParentType:parent]);
        }
    }
    XCTAssertFalse([[GCActivityType day] isSameParentType:[GCActivityType all]]);
    
    XCTAssertEqualObjects([GCActivityType running].parentType,  [GCActivityType all]);
    XCTAssertEqualObjects([GCActivityType cycling].parentType,  [GCActivityType all]);
    XCTAssertEqualObjects([GCActivityType other].parentType,    [GCActivityType all]);
    
    XCTAssertEqualObjects([GCActivityType activityTypeForKey:GC_TYPE_RUNNING], [GCActivityType running]);
    XCTAssertEqualObjects([GCActivityType activityTypeForKey:GC_TYPE_CYCLING], [GCActivityType cycling]);
    XCTAssertEqualObjects([GCActivityType activityTypeForKey:GC_TYPE_DAY], [GCActivityType day]);
    
    
    
    NSData * saved = [NSKeyedArchiver archivedDataWithRootObject:[GCActivityType allTypes] requiringSecureCoding:YES error:nil];
    
    NSSet<Class>*classes = [NSSet setWithObjects:[NSArray class], [GCActivityType class], [NSString class], nil];
    NSArray * retrieved = [NSKeyedUnarchiver unarchivedObjectOfClasses:classes fromData:saved error:nil];
    
    XCTAssertEqualObjects(retrieved, [GCActivityType allTypes]);
    
    
    
}

@end
