//  MIT Licence
//
//  Created on 13/02/2014.
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

#import "GCActivityTennisShotValues.h"
#import <RZUtils/RZUtils.h>

#define SHOT_FIELDS @[@"total", @"max_power", @"average_effect_level", @"average_power"]

@implementation GCActivityTennisShotValues

-(void)dealloc{
    [_shotType release];
    [_total release];
    [_max_power release];
    [_average_effect_level release];
    [_average_power release];

    [super dealloc];
}
-(void)saveToDb:(FMDatabase*)db forSessionId:(NSString*)session_id{


    static NSArray * fields = nil;
    if (fields==nil) {
        fields = SHOT_FIELDS;
        [fields retain];
    }
    NSMutableArray * data = [NSMutableArray arrayWithObjects:session_id,self.shotType,nil];

    for (NSString * field in fields) {
        NSNumber * val = [self performSelector:PROPERTY_GET_SELECTOR(field)];
        if (val) {
            [data addObject:val];
        }else{
            [data addObject:[NSNull null]];
        }
    }
    NSString * query = [NSString stringWithFormat:@"INSERT INTO babolat_shots (session_id,shotType,%@) VALUES (?,?,?,?,?,?)",
                        [fields componentsJoinedByString:@","]];
    if (![db executeUpdate:query withArgumentsInArray:data]) {
        RZLog(RZLogError,@"error %@", [db lastErrorMessage]);
    }
}

+(GCActivityTennisShotValues*)tennisShotValuesForResultSet:(FMResultSet*)res{
    GCActivityTennisShotValues * rv = nil;
    if (res) {
        rv = [[[GCActivityTennisShotValues alloc] init] autorelease];
        if (rv) {
            rv.shotType = [res stringForColumn:@"shotType"];

            static NSArray * fields = nil;
            if (fields==nil) {
                fields = SHOT_FIELDS;
                [fields retain];
            }

            for (NSString * field in fields) {
                SEL set =  PROPERTY_SET_SELECTOR(field);
                if (![res columnIsNull:field]) {
                    [rv performSelector:set withObject:@([res doubleForColumn:field])];
                }
            }
        }
    }
    return rv;
}

+(GCActivityTennisShotValues*)tennisShotValuesForType:(NSString*)type{
    GCActivityTennisShotValues * rv = [[[GCActivityTennisShotValues alloc] init] autorelease];
    if (rv) {
        rv.shotType = type;
    }
    return rv;
}
-(void)updateField:(NSString*)f with:(double)value{
    SEL setSel = PROPERTY_SET_SELECTOR(f);
    if ([self respondsToSelector:setSel]) {
        [self performSelector:setSel withObject:@(value)];
    }else{
        RZLog(RZLogWarning,@"Oops does not reply to : %@", NSStringFromSelector(setSel));
    }
}

-(NSString*)description{
    return [NSString stringWithFormat:@"<%@:%.0f>", NSStringFromClass([self class]), (self.total).doubleValue];
}

@end
