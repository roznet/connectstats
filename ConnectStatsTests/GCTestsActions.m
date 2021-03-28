//
//  GCTestsActions.m
//  GarminConnect
//
//  Created by Brice Rosenzweig on 20/09/2015.
//  Copyright © 2015 Brice Rosenzweig. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface GCTestsActions : XCTestCase
@property (nonatomic,retain) NSObject * argument;
@property (nonatomic,retain) NSString * method;
@property (nonatomic,assign) NSUInteger testInteger;
@end

@implementation GCTestsActions

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)focusOnList{
    self.argument = [NSNull null];
    self.method = @"focusOnList";
}

-(void)focusOnActivity:(RZAction*)aId{
    self.argument = [aId argumentAsDictionary] ?: [aId argumentAsString];
    self.method = @"focusOnActivity:";
}

-(void)resetRecord{
    self.argument = nil;
    self.method = nil;
}

- (void)testURLParsing {
    RZAction * actions = nil;
    BOOL success = false;
    
    NSString * prefix = @"/app-ios/c/";
    
    actions = [RZAction actionFromUrl:[NSURL URLWithString:@"http://connectstats.app/app-ios/c/focusOnActivity/id123"] withPrefix:prefix];
    
    
    [self resetRecord];
    success = [actions executeOn:self];
    XCTAssertTrue(success);
    XCTAssertEqualObjects(self.argument, @"id123");
    XCTAssertEqualObjects(self.method, @"focusOnActivity:");
    
    actions = [RZAction actionFromUrl:[NSURL URLWithString:@"https://connectstats.app/app-ios/c/focusOnActivity/activityId/id123/view/Graph"] withPrefix:prefix];
    [self resetRecord];
    XCTAssertTrue([actions validateHost:@"connectstats.app"]);
    XCTAssertFalse([actions validateHost:@"ro-z.net"]);
    success = [actions executeOn:self];
    
    XCTAssertTrue(success);
    XCTAssertTrue([self.argument isKindOfClass:[NSDictionary class]]);
    XCTAssertEqualObjects(self.method, @"focusOnActivity:");
    if ([self.argument isKindOfClass:[NSDictionary class]]) {
        NSDictionary * dict = (NSDictionary*)self.argument;
        XCTAssertEqualObjects(dict[@"activityId"], @"id123");
        XCTAssertEqualObjects(dict[@"activityId"], @"id123");

    }

    actions = [RZAction actionFromUrl:[NSURL URLWithString:@"https://connectstats.app/app-ios/c/focusOnList"] withPrefix:prefix];
    [self resetRecord];
    success=[actions executeOn:self];
    XCTAssertTrue(success);
    XCTAssertTrue([self.argument isKindOfClass:[NSNull class]]);
    XCTAssertEqualObjects(self.method, @"focusOnList");

    actions = [RZAction actionFromUrl:[NSURL URLWithString:@"focusOnActivity"] withPrefix:nil];
    [self resetRecord];
    success = [actions executeOn:self];
    XCTAssertTrue(success);
    XCTAssertEqualObjects(self.method, @"focusOnActivity:");

    actions = [RZAction actionFromUrl:[NSURL URLWithString:@"https://connectstats.app/app-ios/c/focusOnList"] withPrefix:@"/appios/"];
    XCTAssertNil(actions);
}

@end
