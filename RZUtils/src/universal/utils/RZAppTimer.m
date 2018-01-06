//  MIT Licence
//
//  Created on 25/07/2009.
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

#import "RZAppTimer.h"
#import "RZMacros.h"

@implementation RZAppTimer

-(RZAppTimer*)init{
	self = [super init];
	if( self ){
        self.timerData = [NSMutableDictionary dictionaryWithDictionary:@{ TIMER_INIT: [NSDate date]}];
		self.timerRecord = [NSMutableDictionary dictionary];
	}
	return( self );
}
-(void)dealloc{
    RZAutorelease(_timerData);
    RZAutorelease(_timerRecord);
    RZSuperDealloc;
}
-(void)start:(NSString*)tag{
    _timerData[tag] = [NSDate date];
}
-(void)record:(NSString*)tag{
	NSTimeInterval elapsed = [self elapsed:tag];
	if( elapsed < 0.0 ){
		elapsed = [self elapsed:TIMER_INIT];
	}
    _timerRecord[tag] = @(elapsed);
}
-(NSTimeInterval)elapsed:(NSString*)tag{
	NSDate * timer = _timerData[tag];
	NSTimeInterval rv = -1.0;
	if( timer ){
		rv = [timer timeIntervalSinceNow] * -1.0;
	}
	return( rv );
}
-(NSTimeInterval)elapsedAndReset:(NSString*)tag{
	NSTimeInterval rv = [self elapsed:tag];
	[self start:tag];
	return( rv );
}

@end
