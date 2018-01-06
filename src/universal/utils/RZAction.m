//  MIT Licence
//
//  Created on 27/09/2015.
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

#import "RZAction.h"
#import "RZMacros.h"
#import <objc/runtime.h>

@interface RZAction ()
@property (nonatomic,retain) NSURLComponents * components;
@property (nonatomic,retain) NSArray * actionComponents;
@property (nonatomic,retain) NSString * prefix;

@end

@implementation RZAction

+(instancetype)actionFromUrl:(NSURL *)url withPrefix:(NSString*)prefix{
    RZAction * rv = RZReturnAutorelease([[RZAction alloc] init]);
    if (rv) {
        rv.components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
        rv.prefix = prefix;
        if (prefix) {
            if ([rv.components.path hasPrefix:rv.prefix]){
                NSString * string = [rv.components.path substringFromIndex:rv.prefix.length];
                rv.actionComponents = [string pathComponents];
            }else{
                rv = nil;
            }
        }else{
            rv.actionComponents = [rv.components.path pathComponents];
        }
    }
    return rv;
}

#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_components release];
    [_actionComponents release];
    [_prefix release];
    [super dealloc];
}
#endif

-(NSString*)description{
    return [NSString stringWithFormat:@"<%@:%@:%@>", NSStringFromClass([self class]), self.methodName, self.argumentAsString];
}

-(BOOL)validateHost:(NSString *)host{
    BOOL rv = false;

    if ([self.components.host hasSuffix:host] ) {
        rv = true;
    }
    return rv;
}

-(NSString*)methodName{
    NSArray * comp = self.actionComponents;
    return comp.count > 0 ? comp[0] : nil;
}

-(NSUInteger)argumentCount{
    NSUInteger total = self.actionComponents.count ;
    return total > 0 ? total - 1 : 0;
}

-(NSDictionary*)argumentAsDictionary{
    NSArray * comp = self.actionComponents;
    NSUInteger count = comp.count;

    NSDictionary * rv = nil;
    if(count > 2){
        NSMutableDictionary * arg = [NSMutableDictionary dictionary];
        for (NSUInteger i = 1; i+1<count; i+=2) {
            arg[comp[i]] = comp[i+1];
        }
        rv = arg;
    }
    return rv;
}

-(NSArray*)queryItems{
    return [self.components queryItems];
}

-(NSDictionary*)queryItemsAsDictionary{
    NSArray * items = [self.components queryItems];
    NSMutableDictionary * rv = [NSMutableDictionary dictionaryWithCapacity:items.count];
    for (NSURLQueryItem * item in items) {
        rv[ item.name ] = item.value;
    }
    return rv;
}

-(NSString*)argumentAsString{
    return [[self argumentAsArray] componentsJoinedByString:@"/"];
}

-(NSArray*)argumentAsArray{
    if (self.actionComponents.count > 1) {
        return [self.actionComponents subarrayWithRange:NSMakeRange(1, self.actionComponents.count-1)];
    }
    return nil;
}

-(BOOL)isInProtocol:(SEL)sel protocol:(Protocol*)pro{
    struct objc_method_description hasMethod = protocol_getMethodDescription(pro, sel, NO, YES);

    return ( hasMethod.name != NULL );
}

-(BOOL)executeOn:(id)obj{

    BOOL rv = false;
    NSString * methodName = [self methodName];
    NSUInteger count = self.argumentCount;

    SEL selector = NSSelectorFromString(methodName);
    SEL selectorArg = [methodName hasSuffix:@":"] ? selector : NSSelectorFromString([methodName stringByAppendingString:@":"]);

    if (count > 0) {
        if( [obj respondsToSelector:selectorArg]){
            [obj performSelector:selectorArg withObject:self];
            rv = true;
        }
    }else{
        if ([obj respondsToSelector:selectorArg]) {
            [obj performSelector:selectorArg withObject:self];
            rv = true;
        }else if([obj respondsToSelector:selector]){
            [obj performSelector:selector withObject:nil];
            rv = true;
        }
    }
    return rv;
}

@end
