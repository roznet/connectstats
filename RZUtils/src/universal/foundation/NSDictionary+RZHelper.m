//  MIT Licence
//
//  Created on 30/01/2016.
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

#import "NSDictionary+RZHelper.h"

@implementation NSDictionary (RZHelper)

-(NSDictionary*)dictionaryByAddingEntriesFromDictionary:(NSDictionary*)other{
    NSMutableDictionary * rv = [NSMutableDictionary dictionaryWithDictionary:self];
    if (other) {
        [rv addEntriesFromDictionary:other];
    }
    return [NSDictionary dictionaryWithDictionary:rv];
}

-(NSDictionary*)dictionaryByRemovingObjectsForKeys:(NSArray*)keys{
    NSMutableDictionary * rv = [NSMutableDictionary dictionaryWithDictionary:self];
    for (NSObject<NSCopying> * key in keys) {
        [rv removeObjectForKey:key];
    }
    return [NSDictionary dictionaryWithDictionary:rv];
}
-(NSDictionary*)dictionarySwappingKeysForObjects{
    NSMutableDictionary * rv = [NSMutableDictionary dictionaryWithCapacity:self.count];
    for (NSObject<NSCopying> * key in self) {
        id object = self[key];
        if ([object conformsToProtocol:@protocol(NSCopying) ]) {
            rv[ object ] = key;
        }
    }
    return [NSDictionary dictionaryWithDictionary:rv];
}

@end
