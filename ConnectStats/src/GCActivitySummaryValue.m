//  MIT Licence
//
//  Created on 03/01/2013.
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

#import "GCActivitySummaryValue.h"
#import "GCFields.h"
#import "GCField.h"

#define kGCVersion @"version"
#define kGCField   @"field"
#define kGCValue     @"value"
#define kGCUom @"uom"

@interface GCActivitySummaryValue ()

@property (nonatomic,retain) NSString * uom;
@property (nonatomic,assign) double value;

@end

@implementation GCActivitySummaryValue

+(BOOL)supportsSecureCoding{
    return YES;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.field = [aDecoder decodeObjectOfClass:[NSString class] forKey:kGCField];
        self.uom = [aDecoder decodeObjectOfClass:[NSString class] forKey:kGCUom];
        self.value = [aDecoder decodeDoubleForKey:kGCValue];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeInt:1 forKey:kGCVersion];
    [aCoder encodeObject:self.field forKey:kGCField];
    [aCoder encodeObject:self.uom forKey:kGCUom];
    [aCoder encodeDouble:self.value forKey:kGCValue];
}

#if !__has_feature(objc_arc)
-(void)dealloc{
    [_uom release];
    [_field release];
    [super dealloc];
}
#endif

-(NSString*)description{
    return [NSString stringWithFormat:@"<%@: %@=%@>", NSStringFromClass([self class]), _field,[self formattedValue] ];
}

-(GCNumberWithUnit*)numberWithUnit{
    return [GCNumberWithUnit numberWithUnit:[GCUnit unitForKey:self.uom] andValue:self.value];
}

-(void)setNumberWithUnit:(GCNumberWithUnit *)nu{
    self.value = nu.value;
    if ([self.field.key isEqualToString:@"SumTrainingEffect"]) {
        self.uom = @"te";
    }else if([self.field.key isEqualToString:@"SumIntensityFactor"]){
        self.uom = @"if";
    }else{
        self.uom = nu.unit.key;
    }
}

+(GCActivitySummaryValue*)activitySummaryValueForField:(GCField*)afield value:(GCNumberWithUnit*)nu{
    GCActivitySummaryValue * rv = RZReturnAutorelease([[self alloc] init]);
    if (rv) {
        rv.field = afield;
        rv.numberWithUnit = nu;
    }

    return rv;

}

+(GCActivitySummaryValue*)activitySummaryValueForDict:(NSDictionary*)aDict andField:(GCField*)afield{
    GCActivitySummaryValue * rv = RZReturnAutorelease([[GCActivitySummaryValue alloc] init]);
    if (rv) {
        rv.field = afield;
        if( [aDict[@"value"] respondsToSelector:@selector(doubleValue)]){
            rv.numberWithUnit = [GCNumberWithUnit numberWithUnitName:aDict[@"uom"] andValue:[aDict[@"value"] doubleValue]];
        }else{
            rv.numberWithUnit = [GCNumberWithUnit numberWithUnitName:aDict[@"uom"] andValue:0.0];
        }
    }

    return rv;
}
+(GCActivitySummaryValue*)activitySummaryValueForResultSet:(FMResultSet*)res activityType:(NSString*)activityType{
    GCActivitySummaryValue * rv = RZReturnAutorelease([[GCActivitySummaryValue alloc] init]);
    if (rv) {
        rv.field = [GCField fieldForKey:[res stringForColumn:@"field"] andActivityType:activityType];
        rv.value = [res doubleForColumn:@"value"];
        rv.uom = [res stringForColumn:@"uom"];
        if ([rv.field.key isEqualToString:@"SumIntensityFactor"]) {
            rv.uom = @"if";
        }
    }

    return rv;
}


-(void)updateDb:(FMDatabase*)db forActivityId:(NSString*)activityId{
    if( isnan(self.value) ){
        return;
    }
    if ([db executeUpdate:@"UPDATE gc_activities_values SET value=?, uom=? WHERE activityId = ? AND field = ?",
         @(self.value),
         self.uom,
         activityId,
         self.field.key]){
        // if didn't exist already so save it
        if( [db changes] == 0){
            [self saveToDb:db forActivityId:activityId];
        }
    }else{
        RZLog(RZLogError, @"DB Error %@", [db lastErrorMessage]);
    }
}


-(void)saveToDb:(FMDatabase*)db forActivityId:(NSString*)activityId{
    if( isnan(_value) ){
        return;
    }
    NSNumber * valNum = @(_value);

    NSString * query = [NSString stringWithFormat:@"INSERT INTO gc_activities_values (%@) VALUES(%@)",
                        @"activityId,field,value,uom",
                        @"?,?,?,?"];
    if(![db executeUpdate:query,activityId,self.field.key,valNum,self.uom]){
        RZLog(RZLogError, @"DB error %@",[db lastErrorMessage]);
    }
}

-(NSString*)formattedFieldName{
    return self.field.displayName;
}

-(NSString*)formattedValue{
    return [[GCUnit unitForKey:self.uom] formatDouble:self.value];
}

-(NSString*)formattedValueNoUnits{
    return [[GCUnit unitForKey:self.uom] formatDoubleNoUnits:self.value];
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

-(BOOL)isEqualToValue:(GCActivitySummaryValue*)other{
    if( [other isKindOfClass:[GCActivitySummaryValue class]]){
        return [self.numberWithUnit isEqualToNumberWithUnit:other.numberWithUnit] && [self.field isEqualToField:other.field];
    }
    return false;
}

@end
