//  MIT Licence
//
//  Created on 26/10/2013.
//
//  Copyright (c) 2013 Brice Rosenzweig.
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

#import "RZMemory.h"
#import <mach/mach.h>


@implementation RZMemory

+(NSString*)formatMemoryValue:(unsigned)umem{
    NSString * unit = @"b";
    double val = umem;
    if (val>1024.) {
        val/=1024.;
        unit = @"Kb";
    }
    if (val>1024.) {
        val/=1024.;
        unit = @"Mb";
    }
    if (val>1024.) {
        val/=1024.;
        unit = @"Gb";
    }
    return [NSString stringWithFormat:@"%.1f %@", val, unit];
}

+(unsigned)memoryInUse{
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kerr == KERN_SUCCESS ) {
        return (unsigned)info.resident_size;
    } else {
        return 0;
    }
}
+(unsigned)memoryChangeSince:(unsigned)last{
    return [RZMemory memoryInUse] - last;
}
+(NSString*)formatMemoryInUse{
    return [RZMemory formatMemoryValue:[RZMemory memoryInUse]];
}
+(NSString*)formatMemoryInUseChangeSince:(unsigned)last{
    unsigned cur = [RZMemory memoryInUse];
    int diff = cur-last;

    return [NSString stringWithFormat:@"%@ (%@%@)", [RZMemory formatMemoryValue:cur], diff >= 0 ? @"+" : @"-", [RZMemory formatMemoryValue:abs(diff)]];
}

@end
