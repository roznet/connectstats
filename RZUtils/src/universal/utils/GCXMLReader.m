//  MIT Licence
//
//  Created on 08/09/2014.
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

#import "GCXMLReader.h"
#import <RZUtils/RZMacros.h>

@interface GCXMLReader ()
@property (nonatomic,retain) NSMutableArray * elementStack;
@property (nonatomic,retain) NSMutableString * currentString;
@end

@implementation GCXMLReader

#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_elementStack release];
    [_currentString release];
    [super dealloc];
}
#endif
+(GCXMLElement*)elementForData:(NSData*)data{
    GCXMLReader * reader = [[GCXMLReader alloc] init];

    GCXMLElement * rv = [reader parseForData:data];
    RZRelease(reader);

    return rv;
}

-(GCXMLElement*)parseForData:(NSData*)data{

    self.elementStack = [NSMutableArray arrayWithCapacity:50];

    NSXMLParser * parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    BOOL success = [parser parse];
    RZRelease(parser);

    return success? (self.elementStack).lastObject : nil;
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    GCXMLElement * parent = self.elementStack.count > 0 ? (self.elementStack).lastObject : nil;

    GCXMLElement * element = [GCXMLElement element:elementName];
    [element setAttributeDict:attributeDict];
    if (parent) {
        if (self.currentString.length>0) {
            [parent updateValue:self.currentString];
        }
        [parent addChild:element];
    }
    [self.elementStack addObject:element];
    self.currentString = nil;
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    GCXMLElement * parent = self.elementStack.count > 0 ? (self.elementStack).lastObject : nil;
    if (parent) {
        if (self.currentString.length>0) {
            [parent updateValue:self.currentString];
            self.currentString = nil;
        }
    }
    if (self.elementStack.count>1) {
        [self.elementStack removeLastObject];
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)instring{
    NSString * string = [instring stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!self.currentString) {
        self.currentString = [NSMutableString stringWithString:string];
    }else{
        [self.currentString appendString:string];
    }
}

@end
