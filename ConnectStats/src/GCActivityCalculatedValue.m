//  MIT Licence
//
//  Created on 23/02/2013.
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

#import "GCActivityCalculatedValue.h"
#import "GCField.h"

@implementation GCActivityCalculatedValue

+(GCActivityCalculatedValue*)calculatedValue:(GCField*)field value:(double)val unit:(GCUnit*)unit{
    GCActivityCalculatedValue * rv = [[[GCActivityCalculatedValue alloc] init] autorelease];
    if (rv) {
        rv.numberWithUnit = [GCNumberWithUnit numberWithUnit:unit andValue:val];
        rv.field = field;
    }
    return rv;
}
+(GCActivityCalculatedValue*)calculatedValue:(GCField*)field value:(GCNumberWithUnit*)nu{
    GCActivityCalculatedValue * rv = [[[GCActivityCalculatedValue alloc] init] autorelease];
    if (rv) {
        rv.numberWithUnit = nu;
        rv.field = field;
    }
    return rv;
}
-(void)saveToDb:(FMDatabase*)db forActivityId:(NSString*)activityId{
    GCNumberWithUnit * valNum = self.numberWithUnit;

    NSString * query = [NSString stringWithFormat:@"INSERT INTO gc_activities_calculated (%@) VALUES(%@)",
                        @"activityId,field,value,uom",
                        @"?,?,?,?"];
    if(![db executeUpdate:query,activityId,self.field,@(valNum.value),valNum.unit.key]){
        RZLog(RZLogError, @"DB error %@",[db lastErrorMessage]);
    }
}

-(BOOL)isEqual:(id)object{
    if( [object isKindOfClass:[self class]]){
        return [self isEqualToValue:object];
    }else{
        return false;
    }
}

-(NSUInteger)hash{
    return self.field.hash + self.uom.hash + self.numberWithUnit.hash;
}

-(BOOL)isEqualToValue:(GCActivityCalculatedValue*)other{
    if( [other isKindOfClass:[GCActivityCalculatedValue class]]){
        return [self.numberWithUnit isEqualToNumberWithUnit:other.numberWithUnit] && [self.field isEqualToField:other.field];
    }
    return false;
}

@end
