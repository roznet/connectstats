//  MIT Licence
//
//  Created on 09/09/2012.
//
//  Copyright (c) 2012 Brice Rosenzweig.
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

#import "GCGarminActivityXMLParser.h"

@implementation GCGarminActivityXMLParser
@synthesize currentElement,currentValue,trackPoints,currentPoint,currentLap,laps;

-(instancetype)init{
    return [self init];
}

-(GCGarminActivityXMLParser*)initWithString:(NSString*)aString andEncoding:(NSStringEncoding)encoding{
    self = [super init];
    if (self) {
        currentElement = nil;
        currentValue = nil;
        self.trackPoints = [[[NSMutableArray alloc] initWithCapacity:100] autorelease];
        self.laps = [[[NSMutableArray alloc] initWithCapacity:100] autorelease];
        currentPoint = nil;
        NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:[aString dataUsingEncoding:encoding] ] autorelease];
        parser.delegate = self;
        BOOL success = [parser parse];
        if (!success) {
            RZLog(RZLogError, @"parsing failed %@", [parser parserError]);
            [self setTrackPoints:nil];
            [self setLaps:nil];
        }
    }
    return self;
}

-(void)dealloc{
    [currentElement release];
    [currentValue release];
    [trackPoints release];
    [currentPoint release];
    [laps release];
    [currentLap release];

    [super dealloc];
}

-(BOOL)skipElement:(NSString*)elementName{
    return [elementName isEqualToString:@"Position"]
        || [elementName isEqualToString:@"Value"]
        || [elementName isEqualToString:@"Extensions"]
        || [elementName isEqualToString:@"TPX"];
}

// Descend to a new element
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if (currentPoint == nil && [elementName isEqualToString:@"Trackpoint"]) {
        self.currentPoint = [[[NSMutableDictionary alloc] initWithCapacity:5] autorelease];
    }else if ( currentLap == nil && [elementName isEqualToString:@"Lap"]){
        self.currentLap = [NSMutableDictionary dictionaryWithCapacity:5];
        if (attributeDict[@"StartTime"]) {
            currentLap[@"StartTime"] = attributeDict[@"StartTime"];
        }
    }else if( ! [self skipElement:elementName] ){
        self.currentElement = elementName;
        self.currentValue = [NSMutableString string];
    }
}

// Pop after finishing element
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if (currentPoint) {
        if ([elementName isEqualToString:@"Trackpoint"]) {
            [self.trackPoints addObject:self.currentPoint];
            [self setCurrentPoint:nil];
        }else if( ![self skipElement:elementName]){
            if (currentValue && elementName) {
                self.currentPoint[elementName] = currentValue;
            }
            [self setCurrentElement:nil];
            [self setCurrentValue:nil];
        }
    }else if(currentLap){
        if ([elementName isEqualToString:@"Lap"]) {
            [self.laps addObject:self.currentLap];
            [self setCurrentLap:nil];
        }else if( ![self skipElement:elementName]){
            if (currentValue && elementName) {
                self.currentLap[elementName] = currentValue;
            }
            [self setCurrentElement:nil];
            [self setCurrentValue:nil];
        }

    }
}

// Reached a leaf
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (currentValue) {
        [currentValue appendString:string];
    }
}

-(BOOL)success{
    return trackPoints != nil;
}
@end
