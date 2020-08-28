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
#import "NSArray+Map.h"

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

-(NSDictionary*)smartCompareDict:(NSDictionary*)other{
    NSMutableDictionary * rv = [NSMutableDictionary dictionaryWithCapacity:self.count];
    for (NSObject<NSCopying>*key in self) {
        NSObject * selfVal = self[key];
        NSObject * otherVal = other[key];
        if( otherVal == nil){
            rv[key] = @{@"self":selfVal};
        }else{
            if( [selfVal isKindOfClass:[NSDictionary class]] && [otherVal isKindOfClass:[NSDictionary class]]){
                NSDictionary * selfValDict = (NSDictionary*)selfVal;
                NSDictionary * otherValDict = (NSDictionary*)otherVal;
                NSDictionary * subSmartDict = [selfValDict smartCompareDict:otherValDict];
                if( subSmartDict ){
                    rv[key] = subSmartDict;
                }
            }else if( [selfVal isKindOfClass:[NSNumber class]] && [otherVal isKindOfClass:[NSNumber class]]){
                NSNumber * selfValNum = (NSNumber*)selfVal;
                NSNumber * otherValNum = (NSNumber*)otherVal;
                
                if( strcmp( selfValNum.objCType, @encode(double)) == 0) {
                    double selfDouble = selfValNum.doubleValue;
                    double otherDouble = otherValNum.doubleValue;
                    if( fabs(selfDouble-otherDouble) > 1.0e-10 ){
                        rv[key] = @{ @"self":selfValNum, @"other":otherValNum };
                    }
                }else{
                    if( ![selfValNum isEqualToNumber:otherValNum] ){
                        rv[key] = @{ @"self": selfValNum, @"other": otherValNum };
                    }
                }
            }else{
                if ([selfVal respondsToSelector:@selector(isEqual:)]){
                    if( ![selfVal isEqual:otherVal]) {
                        rv[key] = @{ @"self": selfVal, @"other": selfVal };
                    }
                }else{
                    rv[key] = @{ @"unknownSelf": selfVal, @"unknownOther": selfVal };
                }
            }
        }
    }
    if( rv.count ){
        return rv;
    }else{
        return nil;
    }
}

-(NSDictionary*)dictionaryWithJSONTypesOnly{
    NSMutableDictionary * rv = [NSMutableDictionary dictionaryWithCapacity:self.count];
    for (NSObject<NSCopying>*key in self) {
        NSObject * obj = self[key];
        
        if( [obj isKindOfClass:[NSNumber class]] || [obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNull class]] ){
            rv[key] = obj;
        }else if( [obj isKindOfClass:[NSDictionary class]] ){
            NSDictionary * dict = (NSDictionary*)obj;
            rv[key] = [dict dictionaryWithJSONTypesOnly];
        }else if( [obj isKindOfClass:[NSArray class]] ){
            NSArray * array = (NSArray*)obj;
            rv[key] = [array arrayWithJSONTypesOnly];
        }else if( [obj respondsToSelector:@selector(description)] ){
            rv[key] = [obj description];
        }
    }
    return rv;
}

-(id)objectOfClass:(Class)cls forFirstmatchingKeyPaths:(NSArray<NSString*>*)keyPaths{
    for (NSString * path in keyPaths) {
        id val = [self valueForKeyPath:path];
        if( [val isKindOfClass:cls] ){
            return val;
        }
    }
    return nil;
}

-(NSNumber*)numberForFirstMatchingKeyPaths:(NSArray<NSString*>*)keypaths{
    return [self objectOfClass:[NSNumber class] forFirstmatchingKeyPaths:keypaths];
}
-(NSString*)stringForFirstMatchingKeyPaths:(NSArray<NSString*>*)keypaths{
    return [self objectOfClass:[NSString class] forFirstmatchingKeyPaths:keypaths];
}



@end
