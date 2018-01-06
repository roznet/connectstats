//  MIT Licence
//
//  Created on 23/10/2013.
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

#import "GCGarminActivityWeatherParser.h"
@import RZExternal;

@interface GCGarminActivityWeatherParser ()
@property (nonatomic,retain) NSMutableDictionary * weatherDict;

@end

@implementation GCGarminActivityWeatherParser

+(GCGarminActivityWeatherParser*)garminActivityWeatherParser:(NSString*)aString andEncoding:(NSStringEncoding)encoding{
    GCGarminActivityWeatherParser * rv = [[[GCGarminActivityWeatherParser alloc] init] autorelease];
    if (rv) {
        NSError * error = nil;
        NSMutableDictionary * dict = [NSJSONSerialization JSONObjectWithData:[aString dataUsingEncoding:encoding] options:NSJSONReadingMutableContainers error:&error];
        if (error!=nil || dict == nil) {
            NSString * fixedUp = [aString stringByReplacingOccurrencesOfString:@"&amp;" withString:@""];
            fixedUp = [fixedUp stringByReplacingOccurrencesOfString:@"&gt;" withString:@""];
            fixedUp = [fixedUp stringByReplacingOccurrencesOfString:@"&lt;" withString:@""];
            fixedUp = [fixedUp gtm_stringByUnescapingFromHTML];
            NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:[fixedUp dataUsingEncoding:encoding] ] autorelease];
            rv.weatherDict = [NSMutableDictionary dictionaryWithCapacity:5];
            parser.delegate = rv;
            rv.success = [parser parse];
            if (!rv.success){
                RZLog(RZLogError, @"error %@", [parser parserError]);
            }
        }else{
            rv.weatherDict = dict;
            rv.success = true;
        }
        if (rv.success) {
            rv.weather = [GCWeather weatherWithData:rv.weatherDict];
        }
    }
    return rv;
}

-(void)dealloc{
    [_currentElement release];
    [_currentValue release];
    [_weatherDict release];
    [_weather release];

    [super dealloc];
}

// Descend to a new element
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"div"]) {
        NSString * class = attributeDict[@"class"];
        if (class && [class hasPrefix:@"weather-"]) {
            NSRange spaceRange = [class rangeOfString:@" "];
            if (spaceRange.location != NSNotFound) {
                class = [class substringToIndex:spaceRange.location];
            }
            NSString * title = attributeDict[@"title"];
            if (title) {
                (self.weatherDict)[class] = title;
                self.currentValue = nil;
                self.currentElement = nil;
            }else{
                self.currentElement = class;
                self.currentValue = [NSMutableString string];
            }
        }
    }
}

// Pop after finishing element
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if (self.currentValue && self.currentElement) {
        [self.currentValue replaceOccurrencesOfString:@"\n" withString:@""
                                              options:NSCaseInsensitiveSearch
                                                range: NSMakeRange(0, (self.currentValue).length)];
        while ([self.currentValue rangeOfString:@"  "].location!=NSNotFound) {
            [self.currentValue replaceOccurrencesOfString:@"  " withString:@" " options:NSCaseInsensitiveSearch range:NSMakeRange(0, (self.currentValue).length)];
        }
        ;
        (self.weatherDict)[self.currentElement] = [self.currentValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    self.currentElement = nil;
    self.currentValue = nil;
}

// Reached a leaf
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (self.currentValue) {
        [self.currentValue appendString:string];
    }
}

@end
