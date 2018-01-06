//  MIT Licence
//
//  Created on 15/09/2014.
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

#import "GCFitBitActivityTypesParser.h"

@implementation GCFitBitActivityTypesParser
+(GCFitBitActivityTypesParser*)activityTypesParser:(NSData*)input{
    GCFitBitActivityTypesParser * rv = [[[GCFitBitActivityTypesParser alloc] init] autorelease];
    if (rv) {
        [rv parse:input];
    }
    return rv;
}

-(void)dealloc{
    [_types release];
    [super dealloc];
}
-(void)parse:(NSData*)data{
    NSError * e = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];

    NSMutableArray * queue = [NSMutableArray arrayWithObject:json[@"categories"]];
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:20];
    while (queue.count) {
        id obj = [queue lastObject];
        [queue removeLastObject];
        if ([obj isKindOfClass:[NSArray class]]) {
            [queue addObjectsFromArray:obj];
        }else if ([obj isKindOfClass:[NSDictionary class]]){
            NSDictionary * dict = obj;
            if (dict[@"id"] && dict[@"name"]) {
                [rv addObject:[NSString stringWithFormat:@"%05d:%@", (int)[dict[@"id"] integerValue], dict[@"name"] ] ];

            }
            for (NSString * key in @[@"activities", @"subCategories"]) {
                if (dict[key] && [dict[key] isKindOfClass:[NSArray class]]) {
                    [queue addObjectsFromArray:dict[key]];
                }
            }
        }
    }
    self.types = rv;

}

@end
