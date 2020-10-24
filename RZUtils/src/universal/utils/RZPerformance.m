//  MIT Licence
//
//  Created on 26/10/2014.
//
//  Copyright (c) 2014 Brice Rosenzweig.
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

#import "RZPerformance.h"
#import <RZUtils/RZMacros.h>
#import "RZMemory.h"

@interface RZPerformance ()
@property (nonatomic,retain) NSDate * timeStart;
@property (nonatomic,assign) unsigned memoryStart;
@end

@implementation RZPerformance
+(RZPerformance*)start{
    RZPerformance * rv = RZReturnAutorelease([[RZPerformance alloc] init]);
    if (rv) {
        rv.timeStart = [NSDate date];
        rv.memoryStart = [RZMemory memoryInUse];
    }
    return rv;
}

#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_timeStart release];
    [super dealloc];
}
#endif

-(void)reset{
    self.timeStart = [NSDate date];
    self.memoryStart = [RZMemory memoryInUse];

}

-(NSString*)description{
    return [NSString stringWithFormat:@"[%.1f sec %@]",
            [[NSDate date] timeIntervalSinceDate:_timeStart],
            [RZMemory formatMemoryInUseChangeSince:self.memoryStart]];
}

-(BOOL)significant{
    unsigned last = [RZMemory memoryInUse];
    return [[NSDate date] timeIntervalSinceDate:_timeStart] > 0.5 || ( last>_memoryStart && (last - _memoryStart)> 10*1024*1024);
}
@end
