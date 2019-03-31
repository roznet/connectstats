//  MIT Licence
//
//  Created on 29/12/2015.
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

#import "GCActivityOrganizedFields.h"
#import "GCActivity+Fields.h"

#define kGCPrimaryFields @"primaryFields"
#define kGCOtherFields @"otherFields"
#define kGCVersion @"version"

@implementation GCActivityOrganizedFields

+(BOOL)supportsSecureCoding{
    return YES;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.groupedOtherFields = [aDecoder decodeObjectOfClass:[NSArray class] forKey:kGCOtherFields];
        self.groupedPrimaryFields = [aDecoder decodeObjectOfClass:[NSArray class] forKey:kGCPrimaryFields];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeInt:1 forKey:kGCVersion];
    [aCoder encodeObject:self.groupedPrimaryFields forKey:kGCPrimaryFields];
    [aCoder encodeObject:self.groupedOtherFields forKey:kGCOtherFields];
}


-(void)dealloc{
    [_groupedOtherFields release];
    [_groupedPrimaryFields release];

    [super dealloc];
}

-(NSString*)description{
    return [NSString stringWithFormat:@"<%@:%@:%@>", NSStringFromClass([self class]),self.groupedPrimaryFields, self.groupedOtherFields];
}
@end

