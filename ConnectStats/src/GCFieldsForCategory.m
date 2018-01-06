//  MIT Licence
//
//  Created on 12/02/2016.
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

#import "GCFieldsForCategory.h"

#define kGCFields @"fields"
#define kGCCategory @"category"
#define kGCVersion @"version"

@implementation GCFieldsForCategory

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.fields = [aDecoder decodeObjectForKey:kGCFields];
        self.category = [aDecoder decodeObjectForKey:kGCCategory];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeInt:1 forKey:kGCVersion];
    [aCoder encodeObject:self.fields forKey:kGCFields];
    [aCoder encodeObject:self.category forKey:kGCCategory];
}

#if !__has_feature(objc_arc)
-(void)dealloc{
    [_category release];
    [_fields release];

    [super dealloc];
}
#endif

-(void)addField:(GCField*)field{
    if(self.fields){
        NSArray * extended = [self.fields arrayByAddingObject:field];
        self.fields = [extended sortedArrayUsingSelector:@selector(compare:)];
    }else{
        self.fields = @[ field ];
    }
}
-(NSString*)description{
    return [NSString stringWithFormat:@"<%@:%@:%@>", NSStringFromClass([self class]),self.category, self.fields];
}

-(BOOL)isEqual:(id)object{
    if ([object isKindOfClass:[self class]]) {
        return [self isEqualToFieldsForCategory:object];
    }else{
        return [super isEqual:object];
    }
}

-(NSUInteger)hash{
    return [self.category hash] + [self.fields hash];
}

-(BOOL)isEqualToFieldsForCategory:(GCFieldsForCategory*)other{
    return RZNilOrEqualToString(self.category, other.category) && RZNilOrEqualToArray(self.fields, other.fields);
}

@end
