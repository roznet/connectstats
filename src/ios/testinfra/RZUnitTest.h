//
//  Test.h
//  MacroDialTest
//
//  Created by brice on 19/02/2009.
//  Copyright 2009 ro-z.net. All rights reserved.
//

#include "RZUnitTestRecord.h"


#define RZ_ASSERT(success, fmt, ...) [self assertTrue:success path:__FILE__ line:__LINE__ function:__PRETTY_FUNCTION__ msg:fmt, ##__VA_ARGS__]

@class RZUnitTest;

@protocol UnitTestDelegate <NSObject>

-(void)finishedSession:(NSString*)session for:(RZUnitTest*)test;
-(void)testFinished;

@end

@interface RZUnitTest : NSObject

@property (nonatomic,retain) NSMutableDictionary *	results;
@property (nonatomic,retain) NSString*				session;
@property (nonatomic,retain) NSDate*				lastStartedTime;
@property (nonatomic,retain) id<UnitTestDelegate>   delegate;

@property (nonatomic,retain) dispatch_queue_t          thread;
@property (nonatomic,retain) NSString *             endSessionName;
@property (nonatomic,retain) NSDictionary *         currentTest;

-(RZUnitTest*)init;
-(RZUnitTest*)initWithUnitTest:(RZUnitTest*)ut;

-(void)startSession:(NSString*)aSession;
-(void)endSession:(NSString*)aSession;
-(void)assertTrue:(BOOL)success
             path:(const char *)path
             line:(uint32_t)line
         function:(const char *)function
              msg:(NSString *)fmt, ...;
-(void)assessTestResult:(NSString*)message result:(bool)success;
-(void)assessTrue:(BOOL)success msg:(NSString*)fmt, ...;
-(void)log:(NSString*)aStr;

-(RZUnitTestRecord*)recordObject;

-(NSArray*)testDefinitions;
-(void)runTests:(dispatch_queue_t)athread;
-(void)runOneTest:(NSDictionary*)def onThread:(dispatch_queue_t)thread;

-(NSUInteger)totalRun;
-(NSUInteger)totalSuccess;
-(NSUInteger)totalFailure;
-(double)totalTime;

-(NSUInteger)sessionsCount;
-(NSString*)sessionNameForIdx:(NSUInteger)aIdx;
-(RZUnitTestRecord*)sessionRecordForIdx:(NSUInteger)aIdx;
-(NSUInteger)sessionTotalRunForIdx:(NSUInteger)aIdx;
-(NSUInteger)sessionTotalSuccessForIdx:(NSUInteger)aIdx;
-(NSUInteger)sessionTotalFailureForIdx:(NSUInteger)aIdx;
-(double)sessionTimeForIdx:(NSUInteger)aIdx;
-(void)clearResults;


@end
