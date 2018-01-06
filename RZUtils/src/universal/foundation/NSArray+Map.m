//  MIT Licence
//
//  Created on 30/03/2015.
//
//  Copyright (c) 2015 Brice Rosenzweig.
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

#import "NSArray+Map.h"

@implementation NSArray (Map)

-(NSArray*)arrayByMappingBlock:(RZMapFunc)mapFunc{
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:self.count];
    for (id obj in self) {
        id val = mapFunc(obj);
        if (val) {
            [rv addObject:val];
        }else{
            [rv addObject:[NSNull null]];
        }
    }
    return rv;
}
-(NSArray*)arrayByMappingSelector:(SEL)selector{
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:self.count];
    for (id obj in self) {
        id val = nil;
        if ([obj respondsToSelector:selector]) {
            // needs below because ARC can't call performSelector it does not know.
            IMP imp = [obj methodForSelector:selector];
            id (*func)(id, SEL) = (void *)imp;
            val = func(obj, selector);
        }
        if (val) {
            [rv addObject:val];
        }else{
            [rv addObject:[NSNull null]];
        }


    }
    return rv;

}
-(NSArray*)arrayFlattened{
    NSMutableArray * rv = [NSMutableArray array];
    BOOL recurse = false;
    for (id obj in self) {
        if ([obj isKindOfClass:[NSArray class]]) {
            [rv addObjectsFromArray:obj];
            for (id sub in obj) {
                if ([sub isKindOfClass:[NSArray class]]) {
                    recurse = true;
                }
            }
        }else{
            [rv addObject:obj];
        }
    }
    if (recurse) {
        return [rv arrayFlattened];
    }else{
        return rv;
    }
}

-(NSArray*)arrayByRemovingObjectsIn:(NSArray*)toRemove{
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:self.count];
    for (id obj in self) {
        if ([toRemove containsObject:obj]) {
            continue;
        }
        [rv addObject:obj];
    }
    return [NSArray arrayWithArray:rv];
}
@end
