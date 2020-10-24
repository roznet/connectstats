//  MIT Licence
//
//  Created on 11/01/2013.
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

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif
#import <RZUtils/GCXMLElement.h>
#import <RZUtils/RZMacros.h>

@interface GCXMLElement ( )
@property (nonatomic,retain) NSString * tag;
@property (nonatomic,retain) NSString * value;
@property (nonatomic,retain) NSMutableArray * children;
@property (nonatomic,retain) NSMutableArray * params;

@end
@implementation GCXMLElement

-(void)dealloc{
    RZRelease(_tag);
    RZRelease(_value);
    RZRelease(_children);
    RZRelease(_params);

    RZSuperDealloc;
}

-(NSString*)description{
    return [NSString stringWithFormat:@"GCXMLElement<%@>", _tag ?: @"!--Value"];
}

-(NSString*)debugDescription{
    NSString * childrenstring = self.children.count?[NSString stringWithFormat:@"(%d children)", (int)self.children.count]:@"";
    if (_tag && _value) {
        return [NSString stringWithFormat:@"GCXMLElement<%@=%@>%@", _tag, _value,childrenstring];
    }else if (_tag){
        return [NSString stringWithFormat:@"GCXMLElement<%@>%@", _tag, childrenstring];

    }else{
        return [NSString stringWithFormat:@"GCXMLElement<>%@", childrenstring];
    }
}

+(GCXMLElement*)element:(NSString*)atag{
    GCXMLElement * elem = RZReturnAutorelease([[GCXMLElement alloc] init]);
    if (elem) {
        elem.tag = atag;
    }
    return elem;
}

+(GCXMLElement*)element:(NSString*)atag withValue:(NSString*)aValue{
    GCXMLElement * elem = [GCXMLElement element:atag];
    if (elem) {
        elem.value = aValue;
    }
    return elem;
}
+(GCXMLElement*)elementValue:(NSString*)aValue{
    GCXMLElement * elem = RZReturnAutorelease([[GCXMLElement alloc] init]);
    if (elem) {
        elem.value = aValue;
    }
    return elem;

}

-(void)addChild:(GCXMLElement*)aChild{
    if (!_children) {
        self.children = [NSMutableArray arrayWithCapacity:10];
    }
    [_children addObject:aChild];
}
-(void)addChildren:(NSArray<GCXMLElement*>*)aChild{
    if (!_children) {
        self.children = [NSMutableArray arrayWithCapacity:10];
    }
    [_children addObjectsFromArray:aChild];

}

-(void)addParameter:(NSString*)aKey withValue:(NSString*)aValue{
    if (!_params) {
        self.params = [NSMutableArray arrayWithCapacity:10];
    }
    [_params addObject:[GCXMLElement element:aKey withValue:aValue]];
}

-(NSString*)valueForParameter:(NSString*)aKey{
    if (self.params) {
        for (GCXMLElement*elem in self.params) {
            if ([elem.tag isEqualToString:aKey]) {
                return elem.value;
            }
        }
    }
    return nil;
}
-(NSString*)valueForChild:(NSString*)aKey{
    if( self.children ){
        for (GCXMLElement * elem in self.children) {
            if( [elem.tag isEqualToString:aKey] ){
                return elem.value;
            }
        }
    }
    return nil;
}

-(NSString*)valueForChildPath:(NSArray<NSString*>*)path{
    GCXMLElement * current = self;
    
    for (NSString * key in path) {
        GCXMLElement * next = nil;
        if( current.children ){
            for (GCXMLElement * elem in current.children) {
                if( [elem.tag isEqualToString:key] ){
                    next = elem;
                    break;
                }
            }
        }else{
            return nil;
        }
        current = next;
    }
    return current.value;
}

-(NSString*)toXML:(NSString*)aprefix{
    NSString * prefix = aprefix ?: @"";
    if (_tag) {
        NSString * tagstr = _tag;
        if (_params && _params.count > 0) {
            NSMutableString * tmp = [NSMutableString stringWithString:_tag];
            for (GCXMLElement * p in _params) {
                [tmp appendFormat:@" %@=\"%@\"",p.tag,p.value];
            }
            tagstr = tmp;
        }
        if (!_children) {
            return [NSString stringWithFormat:@"%@<%@>%@</%@>\n", prefix, tagstr,_value,_tag];
        }else{
            NSMutableString * rv = [NSMutableString stringWithCapacity:256];
            [rv appendFormat:@"%@<%@>\n",prefix,tagstr];
            if (_value) {
                [rv appendFormat:@"%@%@\n",prefix,_value];
            }
            for (GCXMLElement * elem in _children) {
                [rv appendString:[elem toXML:[NSString stringWithFormat:@"%@  ",prefix]]];
            }
            [rv appendFormat:@"%@</%@>\n",prefix,_tag];
            return rv;
        }
    }else{
        return [NSString stringWithFormat:@"%@%@\n",prefix,_value];
    }
    return @"";
}
-(void)updateValue:(NSString*)newValue{
    self.value = newValue;
}
-(void)setAttributeDict:(NSDictionary*)aDict{
    self.params = nil;
    for (NSString * key in aDict) {
        NSString*val=aDict[key];
        [self addParameter:key withValue:val];
    }
}
-(NSDictionary*)attributeDict{
    NSMutableDictionary*rv=[NSMutableDictionary dictionaryWithCapacity:self.params.count];
    for (GCXMLElement*elem in self.params) {
        rv[elem.tag] = elem.value;
    }
    return rv;
}

-(NSArray*)findElements:(NSString*)elementName{
    return [self searchElement:elementName firstOnly:NO];
}

-(GCXMLElement*)findFirstElement:(NSString*)elementName{
    NSArray * found = [self searchElement:elementName firstOnly:YES];
    if (found.count>0) {
        return found[0];
    }
    return nil;
}

-(NSArray*)searchElement:(NSString*)elementName firstOnly:(BOOL)firstOnly{
    NSMutableArray * stack = [NSMutableArray arrayWithCapacity:50];
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:50];
    [stack addObjectsFromArray:self.children];
    while (stack.count) {
        GCXMLElement * current = stack[0];
        [stack removeObjectAtIndex:0];
        if ([current.tag isEqualToString:elementName]) {
            [rv addObject:current];
            if (firstOnly) {
                return rv;
            }
        }else{
            [stack addObjectsFromArray:current.children];
        }
    }
    return rv;
}




@end
