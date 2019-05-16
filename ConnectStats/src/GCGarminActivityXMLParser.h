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

#import <Foundation/Foundation.h>

@interface GCGarminActivityXMLParser : NSObject<NSXMLParserDelegate>{
    NSMutableArray * trackPoints;
    NSMutableArray * laps;
    NSMutableDictionary * currentPoint;
    NSMutableDictionary * currentLap;

    NSMutableString * currentValue;
    NSString * currentElement;

}

@property (nonatomic,retain) NSMutableDictionary * currentPoint;
@property (nonatomic,retain) NSMutableDictionary * currentLap;
@property (nonatomic,retain) NSMutableArray * trackPoints;
@property (nonatomic,retain) NSMutableArray * laps;
@property (nonatomic,retain) NSMutableString * currentValue;
@property (nonatomic,retain) NSString * currentElement;
@property (nonatomic,assign) BOOL success;

-(GCGarminActivityXMLParser*)initWithString:(NSString*)aString andEncoding:(NSStringEncoding)encoding NS_DESIGNATED_INITIALIZER DEPRECATED_MSG_ATTRIBUTE("don't use");

-(BOOL)success;
@end
