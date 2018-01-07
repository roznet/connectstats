//  MIT Licence
//
//  Created on 03/01/2016.
//
//  Copyright (c) 2016 Brice Rosenzweig.
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

#import "RZUnitTestTask.h"
#import "RZUtils/RZUtils.h"

@implementation RZUnitTestTask

+(RZUnitTestTask*)taskWith:(RZUnitTest*)ut and:(NSDictionary*)d{
    RZUnitTestTask * rv = RZReturnAutorelease([[RZUnitTestTask alloc] init]);
    if (rv) {
        rv.unitTest = ut;
        rv.def = d;
        rv.status = utTaskWaiting;
    }
    return rv;
}

#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_unitTest release];
    [_def release];
    [super dealloc];
}
#endif

-(NSString*)statusString{
    switch (_status) {
        case utTaskDone:
            return @"Done";
        case utTaskRunning:
            return @"Running";
        case utTaskWaiting:
            return @"Waiting";
    }
    return @"Other";
}
-(NSString*)description{
    return [NSString stringWithFormat:@"<%@:%@:%@>", NSStringFromClass([self.unitTest class]), self.def[@"session"], [self statusString]];
}


@end
