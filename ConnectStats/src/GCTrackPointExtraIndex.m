//  MIT Licence
//
//  Created on 10/01/2016.
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

#import "GCTrackPointExtraIndex.h"
#import "GCField.h"

size_t kMaxExtraIndex = 16;

@interface GCTrackPointExtraIndex ()

@end

@implementation GCTrackPointExtraIndex

+(GCTrackPointExtraIndex*)extraIndexForField:(GCField*)field withUnit:(GCUnit*)unit in:(NSDictionary*)cache{
    if (cache[field]) {
        return cache[field];
    }
    size_t nextidx = cache.count;
    if (nextidx < kMaxExtraIndex) {
        return [GCTrackPointExtraIndex extraIndex:nextidx field:field andUnit:unit];
    }
    return nil;
}

+(GCTrackPointExtraIndex*)extraIndex:(size_t)idx field:(GCField*)field andUnit:(GCUnit*)unit{
    GCTrackPointExtraIndex * rv = [[[GCTrackPointExtraIndex alloc] init] autorelease];
    if (rv) {
        rv.unit = unit;
        rv.idx = idx;
        rv.field = field;
    }
    return rv;
}

-(NSString *)dataColumnName{
    return self.field.key;
}

-(void)dealloc{
    [_unit release];
    [_field release];
    [super dealloc];
}

-(NSString*)description{
    return [NSString stringWithFormat:@"<%@: %@ [%lu] %@>",NSStringFromClass(self.class), _field, (unsigned long)_idx, _unit ];
}

@end
