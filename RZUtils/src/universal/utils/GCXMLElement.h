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

@property (nonatomic,readonly) NSString * tag;
@property (nonatomic,readonly) NSString * value;

+(GCXMLElement*)element:(NSString*)atag;
+(GCXMLElement*)element:(NSString*)atag withValue:(NSString*)aValue;
+(GCXMLElement*)elementValue:(NSString*)aValue;

-(void)addChild:(GCXMLElement*)aChild;
-(void)addChildren:(NSArray<GCXMLElement*>*)aChild;
-(void)addParameter:(NSString*)aKey withValue:(NSString*)value;

-(NSString*)toXML:(NSString*)prefix;
-(void)setAttributeDict:(NSDictionary*)aDict;
-(NSDictionary*)attributeDict;
-(void)updateValue:(NSString*)value;

/**
 * Return value for the parameter of the element if exists or nil
 */
-(NSString*)valueForParameter:(NSString*)aKey;
/**
 * Return value for a direct child of the element if exists or nil
 */
-(NSString*)valueForChild:(NSString*)aKey;

/**
 * Return the value for specific path on children
 */
-(NSString*)valueForChildPath:(NSArray<NSString*>*)path;
/**
 * find all element recursively in any child of specific name
 */
-(NSArray*)findElements:(NSString*)elementName;
/**
* search recursively children and return the first one matchin elementName
*/
-(GCXMLElement*)findFirstElement:(NSString*)elementName;

@end
