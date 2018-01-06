//
//  RZTestRunner.m
//  GarminConnect
//
//  Created by Brice Rosenzweig on 03/01/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

#import "RZUnitTestRunner.h"
#import "RZUnitTestTask.h"

NSString * kRZUnitTestAllDone = @"kRZUnitTestAllDone";
NSString * kRZUnitTestNewResults = @"kRZUnitTestNewResults";

@interface RZUnitTestRunner ()
@property (nonatomic,retain)	RZUnitTest*		results;
@property (nonatomic,retain)    dispatch_queue_t testThread;
@property (nonatomic,retain)    NSArray*        testQueue;

@end

@implementation RZUnitTestRunner

-(RZUnitTestRunner*)init{
    self = [super init];
    if( self ){
        [self setResults:RZReturnAutorelease([[RZUnitTest alloc] init])];
        [self setupTestThread];

    }
    return( self );
}

#if ! __has_feature(objc_arc)
- (void)dealloc {
    [_testThread release];
    [_results release];
    [_testQueue release];
    [_collectedResults release];
    [_testSource release];
    [super dealloc];
}
#endif

-(RZUnitTest*)current{
    return self.results;
}

#pragma mark - Test Execution Logic

-(void)run{
    dispatch_async(self.testThread,^(){
        [self doTheTests];
    });
}

-(void)doTheTests{
    NSArray * testClasses = [self.testSource testClassNames];
    if (testClasses) {
        NSMutableArray * queue = [NSMutableArray arrayWithCapacity:testClasses.count*5];
        for (NSString * classname in testClasses) {
            RZUnitTest * test = [[NSClassFromString(classname) alloc] initWithUnitTest:self.results];
            test.delegate = self;
            NSArray * defs = [test testDefinitions];
            for (NSDictionary * def in defs) {
                
                RZUnitTestTask * task = [RZUnitTestTask taskWith:test and:def];
                [queue addObject:task];
            }
        }
        self.testQueue = [NSArray arrayWithArray:queue];
    }
    [self nextTest];
}

-(void)nextTest{
    if (self.testQueue==nil) {
        return;
    }
    RZUnitTestTask * running = nil;
    RZUnitTestTask * firstWaiting = nil;
    for (RZUnitTestTask * task in self.testQueue) {
        if (firstWaiting == nil && task.status == utTaskWaiting) {
            firstWaiting =task;
        }
        if (task.status==utTaskRunning) {
            running = task;
            self.running = true;

        }
    }
    
    if (firstWaiting && ! running) {
        firstWaiting.status = utTaskRunning;
        [firstWaiting.unitTest runOneTest:firstWaiting.def onThread:self.testThread];
    }
    if (!firstWaiting) {
        [self notifyForString:kRZUnitTestAllDone];
        self.running = false;
    }else{
        self.running = true;
    }
    [self updateCollectedResults];
}

-(void)updateCollectedResults{
    NSMutableArray * res = [NSMutableArray arrayWithCapacity:self.results.results.count];
    for (NSString * session in self.results.results) {
        [res addObject:self.results.results[session]];
    }
    self.collectedResults = res;
    [self notifyForString:kRZUnitTestNewResults];
}

-(void)finishedSession:(NSString *)session for:(RZUnitTest *)test{
    RZUnitTestTask * found =nil;
    for (RZUnitTestTask * task in self.testQueue) {
        if (task.unitTest == test && [task.def[TK_SESS] isEqualToString:session]) {
            found = task;
            break;
        }
    }
    if (found) {
        found.status = utTaskDone;
        [self nextTest];
    }
}

-(void)testFinished{
    [self updateCollectedResults];
    [self notifyForString:kRZUnitTestAllDone];
}

#pragma mark - Threads

-(void)setupTestThread{
    dispatch_queue_t q = dispatch_queue_create("net.ro-z.test", DISPATCH_QUEUE_SERIAL);
    self.testThread = q;
#if !__has_feature(objc_arc)
    dispatch_release(q);
#endif
}


-(void)clearResults{
    [self.results clearResults];
}

@end
