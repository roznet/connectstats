//  MIT License
//
//  Created on 14/01/2018 for ConnectStatsTestAppXCTests
//
//  Copyright (c) 2018 Brice Rosenzweig
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


#import <XCTest/XCTest.h>
@import RZUtilsTestInfra;
#import "GCTestAppGlobal.h"

NSString * kExpectationAllDone = @"RZUnitRunner All Done";

@interface ConnectStatsTestAppXCTests : XCTestCase<RZUnitTestSource,RZChildObject>
@property (nonatomic,retain) RZUnitTestRunner * runner;
@property (nonatomic,retain) XCTestExpectation * expectation;
@property (nonatomic,retain) NSString * testClassToRun;
@end

@implementation ConnectStatsTestAppXCTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.runner = RZReturnAutorelease([[RZUnitTestRunner alloc] init]);
    self.runner.testSource = self;
    [self.runner attach:self];
}

- (void)tearDown {
    [self.runner detach:self];
    self.runner = nil;
    self.testClassToRun = nil;
    self.expectation = nil;
    
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)rzRunnerExecute{
    
    [GCTestAppGlobal prepareForTestOnMainThread];
    
    self.expectation = [self expectationWithDescription:kExpectationAllDone];
    
    [self.runner run];
    
    [self waitForExpectations:@[ self.expectation ] timeout:60];
    for (RZUnitTestRecord * record in self.runner.collectedResults) {
        XCTAssertEqual(record.success, record.total, @"%@", record);
        if( record.success != record.total){
            for (UnitTestRecordDetail * detail in record.failureDetails) {
                // To put the error detail on the report
                XCTAssertTrue(false, @"%@", detail);
            }
        }
    }
}
/*

NSStringFromClass([GCTestCommunications class])
*/

-(void)testGCTestCommunications{
    self.testClassToRun = @"GCTestCommunications";
    [self rzRunnerExecute];
}

-(void)testGCFitTest{
    self.testClassToRun = @"GCFitTest";
    [self rzRunnerExecute];
}

-(void)testGCTestOrganizer{
    self.testClassToRun = @"GCTestOrganizer";
    [self rzRunnerExecute];
}
-(void)testGCTestUIUnitTest{
    self.testClassToRun = @"GCTestUIUnitTest";
    [self rzRunnerExecute];
}

-(void)testGCTestDerived{
    self.testClassToRun = @"GCTestDerived";
    [self rzRunnerExecute];
}

-(void)testGCTestParsing{
    self.testClassToRun = @"GCTestParsing";
    [self rzRunnerExecute];
}

-(void)testGCTestStats{
    self.testClassToRun = @"GCTestStats";
    [self rzRunnerExecute];
}

- (void)testGCTestBasics{
    self.testClassToRun = @"GCTestBasics";
    [self rzRunnerExecute];
}

-(void)testGCTestTracks{
    self.testClassToRun = @"GCTestParsing";
    [self rzRunnerExecute];
}

-(NSArray*)testClassNames{
    return @[ self.testClassToRun];
}

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    if( [theInfo.stringInfo isEqualToString:kRZUnitTestAllDone] ){
        [self.expectation fulfill];
        self.expectation = nil;
    }
}
@end
