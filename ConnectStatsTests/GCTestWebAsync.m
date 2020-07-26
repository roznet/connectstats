//  MIT License
//
//  Created on 18/06/2020 for ConnectStatsXCTests
//
//  Copyright (c) 2020 Brice Rosenzweig
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
#import "GCTestCase.h"
#import "GCWebConnect.h"
#import "GCWebRequestStandard.h"

@interface GCWebRequestTest : GCWebRequestStandard
@property (nonatomic,retain) XCTestExpectation * expectation;
+(GCWebRequestTest*)testWithExpectation:(XCTestExpectation*)expectation;
@end

@implementation GCWebRequestTest

+(GCWebRequestTest*)testWithExpectation:(XCTestExpectation*)expectation{
    GCWebRequestTest * rv = [[GCWebRequestTest alloc] init];
    rv.expectation = expectation;
    return rv;
}

-(void)dealloc{
    [_expectation release];
    [super dealloc];
}

-(BOOL)isSameAsRequest:(GCWebRequestTest*)req{
    return [self.expectation isEqual:req.expectation];
}
-(NSString*)debugDescription{
    return [NSString stringWithFormat:@"<%@: %@>", NSStringFromClass([self class]), self.expectation];
}
-(void)process{
    NSLog(@"Done %@", self.expectation);
    [self.expectation fulfill];
    [self processDone];
}

@end

@interface GCTestWebAsync : XCTestCase<RZChildObject>
@property (nonatomic,retain) NSMutableArray<XCTestExpectation*> * expectations;
@property (nonatomic,retain) GCWebConnect * web;
@end

@implementation GCTestWebAsync

- (void)setUp {
    self.web = RZReturnAutorelease([[GCWebConnect alloc] init]);
    [self.web attach:self];
    
    dispatch_queue_t queue = dispatch_queue_create("net.ro-z.webtest", DISPATCH_QUEUE_SERIAL);
    self.web.worker = queue;
    dispatch_release(queue);

    [super setUp];
}

- (void)tearDown {
    [self.web detach:self];
    
    [super tearDown];
}

- (void)testParallelAdd {
    self.expectations = [NSMutableArray array];
    
    for( NSUInteger i=0;i<20;i++){
        XCTestExpectation * expectation = [[XCTestExpectation alloc] initWithDescription:[NSString stringWithFormat:@"exp %@",@(i)]];
        [self.expectations addObject:expectation];
        // send them all async at the same time to stress the system...
        dispatch_async( dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^(){
            [self.web addRequest:[GCWebRequestTest testWithExpectation:expectation]];
        });
    }

    [self waitForExpectations:self.expectations timeout:5];
}

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    if( [theInfo.stringInfo isEqualToString:NOTIFY_END] ){
        XCTAssertTrue(true, @"Finished");
    }
}

@end
