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

#import <Foundation/Foundation.h>

@interface GCXMLElement : NSObject

@property (nonatomic,retain) NSString * tag;
@property (nonatomic,retain) NSString * value;
@property (nonatomic,retain) NSMutableArray * children;
@property (nonatomic,retain) NSMutableArray * params;

+(GCXMLElement*)element:(NSString*)atag;
+(GCXMLElement*)element:(NSString*)atag withValue:(NSString*)aValue;
+(GCXMLElement*)elementValue:(NSString*)aValue;
-(void)addChild:(GCXMLElement*)aChild;
-(void)addParameter:(NSString*)aKey withValue:(NSString*)value;
-(NSString*)valueForParameter:(NSString*)aKey;

-(NSString*)toXML:(NSString*)prefix;
-(void)setAttributeDict:(NSDictionary*)aDict;
-(NSDictionary*)attributeDict;

-(NSArray*)findElements:(NSString*)elementName;
-(GCXMLElement*)findFirstElement:(NSString*)elementName;

@end
