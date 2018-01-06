//
//  GCTestFields.m
//  GarminConnect
//
//  Created by Brice Rosenzweig on 02/01/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GCField.h"
#import "GCFields.h"
#import "GCFieldCache.h"
#import "GCActivityType.h"

@interface GCTestFields : XCTestCase

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
    GCField * fSumDistance = [GCField field:@"SumDistance" forActivityType:GC_TYPE_RUNNING];
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
    info = [cache infoForField:@"WeightedMeanPace" andActivityType:GC_TYPE_RUNNING];
    XCTAssertEqualObjects(info.displayName, @"Allure moy.");
    XCTAssertEqualObjects(info.uom, @"minperkm");
    XCTAssertEqualObjects([[GCField fieldForKey:@"WeightedMeanPace" andActivityType:GC_TYPE_RUNNING] displayName], @"Allure moy.");
    XCTAssertEqualObjects([[GCField fieldForKey:@"WeightedMeanPace" andActivityType:GC_TYPE_RUNNING] unitName], @"minperkm");
    
    [cache registerField:@"WeightedMeanPace" activityType:GC_TYPE_RUNNING displayName:@"Pace" andUnitName:@"minpermile"];
    info = [cache infoForField:@"WeightedMeanPace" andActivityType:GC_TYPE_RUNNING];
    XCTAssertEqualObjects(info.displayName, @"Pace");
    XCTAssertEqualObjects(info.uom, @"minpermile");
    XCTAssertEqualObjects([[GCField fieldForKey:@"WeightedMeanPace" andActivityType:GC_TYPE_RUNNING] displayName], @"Pace");
    XCTAssertEqualObjects([[GCField fieldForKey:@"WeightedMeanPace" andActivityType:GC_TYPE_RUNNING] unitName], @"minpermile");
    
    // Second time register nothing happens
    [cache registerField:@"WeightedMeanPace" activityType:GC_TYPE_RUNNING displayName:@"Pace23" andUnitName:@"kph"];
    info = [cache infoForField:@"WeightedMeanPace" andActivityType:GC_TYPE_RUNNING];
    XCTAssertEqualObjects(info.displayName, @"Pace");
    XCTAssertEqualObjects(info.uom, @"minpermile");
    XCTAssertEqualObjects([[GCField fieldForKey:@"WeightedMeanPace" andActivityType:GC_TYPE_RUNNING] displayName], @"Pace");
    XCTAssertEqualObjects([[GCField fieldForKey:@"WeightedMeanPace" andActivityType:GC_TYPE_RUNNING] unitName], @"minpermile");
    
    // After prefer predefined go back to previous language
    cache.preferPredefined = true;
    info = [cache infoForField:@"WeightedMeanPace" andActivityType:GC_TYPE_RUNNING];
    XCTAssertEqualObjects(info.displayName, @"Allure moy.");
    XCTAssertEqualObjects(info.uom, @"minperkm");
    XCTAssertEqualObjects([[GCField fieldForKey:@"WeightedMeanPace" andActivityType:GC_TYPE_RUNNING] displayName], @"Allure moy.");
    XCTAssertEqualObjects([[GCField fieldForKey:@"WeightedMeanPace" andActivityType:GC_TYPE_RUNNING] unitName], @"minperkm");
    
    // REgister one that does not exists
    [cache registerField:@"WeightedMeanPace2" activityType:GC_TYPE_RUNNING displayName:@"Pace2" andUnitName:@"kph"];
    info = [cache infoForField:@"WeightedMeanPace2" andActivityType:GC_TYPE_RUNNING];
    XCTAssertEqualObjects(info.displayName, @"Pace2");
    XCTAssertEqualObjects(info.uom, @"kph");
    XCTAssertEqualObjects([[GCField fieldForKey:@"WeightedMeanPace2" andActivityType:GC_TYPE_RUNNING] displayName], @"Pace2");
    XCTAssertEqualObjects([[GCField fieldForKey:@"WeightedMeanPace2" andActivityType:GC_TYPE_RUNNING] unitName], @"kph");
    
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
            XCTAssertEqualObjects(sub.topSubRootType, parent);
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
    
    
    
    NSData * saved = [NSKeyedArchiver archivedDataWithRootObject:[GCActivityType allTypes]];
    NSArray * retrieved = [NSKeyedUnarchiver unarchiveObjectWithData:saved];
    
    XCTAssertEqualObjects(retrieved, [GCActivityType allTypes]);
    
    
    
}
- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
