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

#import "GCActivityMetaValue.h"
#import "GCField.h"
#import "GCFieldCache.h"

#define kGCVersion @"version"
#define kGCField   @"field"
#define kGCKey     @"key"
#define kGCDisplay @"display"

@interface GCActivityMetaValue ()
@property (nonatomic,retain) NSString * displayOriginal;

@end

@implementation GCActivityMetaValue
+(BOOL)supportsSecureCoding{
    return YES;
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.field = [aDecoder decodeObjectOfClass:[NSString class] forKey:kGCField];
        self.display = [aDecoder decodeObjectOfClass:[NSString class] forKey:kGCDisplay];
        self.key = [aDecoder decodeObjectOfClass:[NSString class] forKey:kGCKey];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeInt:1 forKey:kGCVersion];
    [aCoder encodeObject:self.field forKey:kGCField];
    [aCoder encodeObject:self.display forKey:kGCDisplay];
    [aCoder encodeObject:self.key forKey:kGCKey];
}

-(void)dealloc{
    [_field release];
    [_displayOriginal release];
    [_key release];

    [super dealloc];
}

-(void)setDisplay:(NSString *)display{
    self.displayOriginal = display;
}

-(NSString*)display{
    if ([self.field isEqualToString:@"activityType"]) {
        GCFieldCache * cache = [GCField fieldCache];
        if (cache.preferPredefined) {
            GCFieldInfo * info = [cache infoForActivityType:self.key];
            return info ? info.displayName : self.displayOriginal;
        }else{
            return self.displayOriginal;
        }
    }else{
        return self.displayOriginal;
    }
}

-(NSString*)description{
    NSString * keyStr = @"";
    if( self.key && ![self.key isEqualToString:@""]){
        keyStr = [NSString stringWithFormat:@" key=%@", self.key];
    }
    return [NSString stringWithFormat:@"<%@: %@=%@%@>", NSStringFromClass([self class]), _field,self.display, keyStr ];
}

+(GCActivityMetaValue*)activityValueForResultSet:(FMResultSet*)res{
    GCActivityMetaValue * rv = [[[GCActivityMetaValue alloc] init] autorelease];
    if (rv) {
        rv.display = [res stringForColumn:@"display"];
        rv.field = [res stringForColumn:@"field"];
        rv.key = [res stringForColumn:@"key"];
    }
    return rv;
}

+(GCActivityMetaValue*)activityValueForDict:(NSDictionary*)aDict andField:(NSString*)afield{
    GCActivityMetaValue * rv = [[[GCActivityMetaValue alloc] init] autorelease];
    if (rv) {
        rv.field = afield;
        rv.display = aDict[@"display"];
        rv.key = aDict[@"key"];
    }
    return rv;

}
+(GCActivityMetaValue*)activityMetaValueForDisplay:(NSString*)aDisp andField:(NSString*)afield{
    GCActivityMetaValue * rv = [[[GCActivityMetaValue alloc] init] autorelease];
    if (rv) {
        rv.field = afield;
        rv.display = aDisp;
        rv.key = @"";
    }
    return rv;

}
+(GCActivityMetaValue*)activityMetaValueForDisplay:(NSString*)aDisp key:(NSString*)key andField:(NSString*)afield{
    GCActivityMetaValue * rv = [[[GCActivityMetaValue alloc] init] autorelease];
    if (rv) {
        rv.field = afield;
        rv.display = aDisp;
        rv.key = key;
    }
    return rv;

}

-(void)updateDb:(FMDatabase*)db forActivityId:(NSString*)activityId{
    if( [db executeUpdate:@"UPDATE gc_activities_meta SET display=?, key=? WHERE activityId = ? AND field = ?",
           self.display,
           self.key?:@"",
           activityId,
           self.field] ){
        // if didn't exist already so save it
        if( [db changes] == 0){
            [self saveToDb:db forActivityId:activityId];
        }
    }else{
        RZLog(RZLogError, @"DB Error %@", [db lastErrorMessage]);
    }

}


-(void)saveToDb:(FMDatabase*)db forActivityId:(NSString*)activityId{
    NSString * query = [NSString stringWithFormat:@"INSERT INTO gc_activities_meta (%@) VALUES(%@)",
                        @"activityId,field,display,key",
                        @"?,?,?,?"];
    if(![db executeUpdate:query,activityId,self.field,self.display,self.key?:@""]){
        RZLog(RZLogError, @"DB error %@",[db lastErrorMessage]);
    }

}

-(BOOL)isEqualToValue:(GCActivityMetaValue*)other{
    if (!other) {
        return false;
    }
    BOOL rv = self.display && other.display && [self.display isEqualToString:other.display];
    if (self.key && other.key && ![self.key isEqualToString:other.key]) {
        rv = false;
    }
    if (self.key && !other.key) {
        rv = false;
    }
    return rv;
}

-(BOOL)match:(NSString*)str{
    NSRange res = [self.display rangeOfString:str options:NSCaseInsensitiveSearch];

    if (res.location != NSNotFound) {
        return true;
    }
    return false;
}
@end
