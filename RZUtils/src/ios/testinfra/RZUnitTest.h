//  MIT Licence
//
//  Created on 19/02/2009.
//
//  Copyright (c) None Brice Rosenzweig.
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
-(void)log:(NSString*)fmt, ...;

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
