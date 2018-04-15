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

// Definition of a test:
//  selector: selector to be called
//  session:  session name called in endSession when test is finished. Other session can be called as long as this session
//            is last one called when test finished
//  description: arbitrary description
//
//

#import "RZUnitTest.h"
#import "RZUnitTestRecord.h"
#import "RZUtils/RZUtils.h"

@implementation RZUnitTest

-(RZUnitTest*)initWithUnitTest:(RZUnitTest*)ut{
	self = [super init];
	if( self ){
		[self setResults:[ut results]];
		[self setSession:[ut session]];
	}
	return( self );
}

-(RZUnitTest*)init{
	self = [super init];
	if( self ){
		self.results = [NSMutableDictionary dictionary];
	}
	return( self );
}
#if ! __has_feature(objc_arc)
-(void)dealloc{
	[_results release];
	[_session release];
	[_lastStartedTime release];
    [_thread release];
    [_endSessionName release];
    [_currentTest release];
    [_delegate release];
	[super dealloc];
}
#endif

-(void)clearResults{
	[self setResults:RZReturnAutorelease([[NSMutableDictionary alloc] init])];
}

-(void)runOneTest:(NSDictionary*)def onThread:(dispatch_queue_t)thread{
    self.thread = thread;
    NSString * selname = def[TK_SEL];
    NSString * desc    = def[TK_DESC];
    self.endSessionName = def[TK_SESS];

    id arg = def[TK_ARG];
    if (selname) {
        SEL selector = NSSelectorFromString(selname);
        RZLog(RZLogInfo, @"**Starting %@ @%@ %@", NSStringFromClass([self class]), selname, desc);
        self.currentTest = def;
        if (thread) {
            dispatch_async(self.thread,^(){
                @autoreleasepool {
#if ! __has_feature(objc_arc)
                    [self performSelector:selector withObject:arg];
#else
                    // needs below because ARC can't call performSelector it does not know.
                    IMP imp = [self methodForSelector:selector];
                    void (*func)(id, SEL,id) = (void*)imp;
                    func(self, selector,arg);
#endif
                }
            });
        }else{
            @autoreleasepool {
#if ! __has_feature(objc_arc)
                [self performSelector:selector withObject:arg];
#else
                // needs below because ARC can't call performSelector it does not know.
                IMP imp = [self methodForSelector:selector];
                void (*func)(id, SEL,id) = (void*)imp;
                func(self, selector,arg);
#endif
            }
        }
    }
}

-(void)runTests:(dispatch_queue_t)athread{
    NSArray * defs = [self testDefinitions];
    if (defs) {
        for (NSDictionary * def in defs) {
            [self runOneTest:def onThread:athread];
        }
    }
};

-(void)startSession:(NSString*)aSession{
	[self setSession:aSession];
	if( ![_results objectForKey:aSession] ){
        [self recordObject];//force creation
	}
	[self setLastStartedTime:[NSDate date]];// reset counter
}
-(void)endSession:(NSString*)aSession{
    dispatch_async(self.thread, ^(){
        [[self recordObject] setTimeTaken:[self.lastStartedTime timeIntervalSinceNow]*-1];
        if (self.delegate){
            RZLog(RZLogInfo, @"**Ending %@ %@", NSStringFromClass([self class]), aSession);
            [self.delegate finishedSession:aSession for:self];

            if ( self.endSessionName==nil || [aSession isEqualToString:self.endSessionName]) {
                [self.delegate testFinished];
            }
        }
    });
}
-(NSDictionary*)testDefinitions{
    return nil;
}
-(void)log:(NSString*)fmt, ...{
    va_list args;
    va_start(args, fmt);
    NSString * aStr = RZReturnAutorelease([[NSString alloc] initWithFormat:fmt arguments:args]);
    
	if( aStr ){
#ifdef TARGET_IPHONE_SIMULATOR
        NSLog(@"##%@", aStr);
#endif
		[[self recordObject] logString:aStr];
	};
}
-(RZUnitTestRecord*)recordObject{
	RZUnitTestRecord * rv = [_results objectForKey:_session];
	if( ! rv ){
        RZUnitTestRecord * res = RZReturnAutorelease([[RZUnitTestRecord alloc] init]);
        res.testDefinition = self.currentTest;
        res.testClass = NSStringFromClass([self class]);
        res.session = self.session;
		[_results setObject:res forKey:_session];
		rv = [_results objectForKey:_session];
	}
	return( rv );
}


-(void)assessTrue:(BOOL)success msg:(NSString*)fmt, ... {
    va_list args;
    va_start(args, fmt);
    NSString * msg = RZReturnAutorelease([[NSString alloc] initWithFormat:fmt arguments:args]);
    va_end(args);

    [self assessTestResult:msg result:success];

}
-(void)assertTrue:(BOOL)success
             path:(const char *)path
             line:(uint32_t)line
         function:(const char *)function
              msg:(NSString *)fmt, ...{

    va_list args;
    va_start(args, fmt);
    NSString * msg = RZReturnAutorelease([[NSString alloc] initWithFormat:fmt arguments:args]);
    va_end(args);

    msg= [NSString stringWithFormat:@">>%sL%d %@", function, line, msg];
    [self assessTestResult:msg result:success];
}

-(void)assessTestResult:(NSString*)message result:(bool)success{
	[[self recordObject] recordResult:success tag:message];

	if( !success ){
#ifdef TARGET_IPHONE_SIMULATOR
		NSLog(@"[FAILED] %@\n", message);
#endif
	}
}

-(void)dumpStats{
}

-(RZUnitTestRecord*)sessionRecordForIdx:(NSUInteger)aIdx{
	return( (RZUnitTestRecord*)[_results objectForKey:[self sessionNameForIdx:aIdx]] );
}

-(NSUInteger)totalRun{
	NSUInteger n = [self sessionsCount];
	NSUInteger i = 0;
	NSUInteger rv = 0;
	for(i=0;i<n;i++){
		rv += [[self sessionRecordForIdx:i] total];
	}
	return( rv );
}
-(NSUInteger)totalSuccess{
	NSUInteger n = [self sessionsCount];
	NSUInteger i = 0;
	NSUInteger rv = 0;
	for(i=0;i<n;i++){
		rv += [[self sessionRecordForIdx:i] success];
	}
	return( rv );
}
-(double)totalTime{
	NSUInteger n = [self sessionsCount];
	NSUInteger i = 0;
	double rv = 0;
	for(i=0;i<n;i++){
		rv += [[self sessionRecordForIdx:i] timeTaken];
	}
	return( rv );
}

-(NSUInteger)totalFailure{
	NSUInteger n = [self sessionsCount];
	NSUInteger i = 0;
	NSUInteger rv = 0;
	for(i=0;i<n;i++){
		rv += [[self sessionRecordForIdx:i] failure];
	}
	return( rv );
}


-(NSUInteger)sessionsCount{
	return( [_results count] );
}
-(NSString*)sessionNameForIdx:(NSUInteger)aIdx{
	return( [[_results allKeys] objectAtIndex:aIdx] );
}
-(NSUInteger)sessionTotalRunForIdx:(NSUInteger)aIdx{
	return( [[self sessionRecordForIdx:aIdx] total] );
}
-(double)sessionTimeForIdx:(NSUInteger)aIdx{
	return( [[self sessionRecordForIdx:aIdx] timeTaken] );
}
-(NSUInteger)sessionTotalSuccessForIdx:(NSUInteger)aIdx{
	return( [[self sessionRecordForIdx:aIdx] success] );
}
-(NSUInteger)sessionTotalFailureForIdx:(NSUInteger)aIdx{
	return( [[self sessionRecordForIdx:aIdx] failure] );
}


@end
