//  MIT Licence
//
//  Created on 23/10/2014.
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

#import <RZUtils/TSDataRow.h>
#import <RZUtils/FMDatabase.h>

@interface TSDataRow ()
@end

@implementation TSDataRow

#pragma mark - Creation

+(TSDataRow*)rowWithObj:(id)obj andColumns:(NSArray*)cols{
    TSDataRow * rv = [[TSDataRow alloc] init];
    if (rv) {
        if ([obj isKindOfClass:[TSDataRow class]]) {
            TSDataRow * other = obj;
            rv.row = other.row;
        }else if ([obj isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:cols.count];
            NSDictionary * inDict = obj;
            for (NSString * col in cols) {
                id val = inDict[col];
                if (val) {
                    dict[ col ] = val;
                }
            }
            rv.row = dict;
        }else if ([obj isKindOfClass:[NSArray class]]){
            NSArray * inArray = obj;
            if (inArray.count == cols.count) {
                rv.row = [NSDictionary dictionaryWithObjects:inArray forKeys:cols];
            }
        }else if([obj isKindOfClass:[FMResultSet class]]){
            FMResultSet * res = obj;
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:cols.count];
            for (NSString * col in cols) {
                dict[col] = [res objectForColumnName:col];
            }
            rv.row = dict;
        }else{
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:cols.count];
            for (NSString * col in cols) {
                SEL selector = NSSelectorFromString(col);

                if ([obj respondsToSelector:selector]) {
                    // needs below because ARC can't call performSelector it does not know.
                    IMP imp = [obj methodForSelector:selector];
                    id (*func)(id, SEL) = (void *)imp;
                    id val = func(obj, selector);
                    if (val) {
                        dict[ col ] = val;
                    }
                }
            }
            rv.row = dict;
        }
    }
    return rv;
}

-(TSDataRow*)mergedWithRow:(TSDataRow*)other{
    TSDataRow * rv = [[TSDataRow alloc] init];
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:self.row];

    for (NSString * key in other.row) {
        dict[ key  ] = other.row[key];
    }
    rv.row = dict;
    return rv;
}

#pragma mark - Access

-(id)valueForField:(NSString *)field{
    return _row[field];
}

-(NSNumber*)numberForField:(NSString*)field{
    NSNumber * rv = _row[field];
    if (rv && ![rv isKindOfClass:[NSNumber class]]) {
        rv = nil;
    }
    return rv;
}
-(NSString*)stringForField:(NSString*)field{
    NSString * rv = _row[field];
    if (rv && ![rv isKindOfClass:[NSString class]]) {
        rv = nil;
    }
    return rv;

}
-(NSDate*)dateForField:(NSDate*)field{
    NSDate * rv = _row[field];
    if (rv && ![rv isKindOfClass:[NSDate class]]) {
        rv = nil;
    }
    return rv;
}


-(NSArray*)valuesForFields:(NSArray*)fields{
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:fields.count];
    for (NSString * field in fields) {
        id one = _row[field];
        if(one == nil){
            one = [NSNull null];
        }
        [rv addObject:one];
    }
    return rv;
}

#pragma mark - Syntactic Sugar

- (id)objectForKeyedSubscript:(id<NSCopying>)key{
    return _row[key];
}
- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key{
    NSMutableDictionary * tmp = [NSMutableDictionary dictionaryWithDictionary:self.row];
    tmp[key] = obj;
    self.row = [NSDictionary dictionaryWithDictionary:tmp];
}


@end
