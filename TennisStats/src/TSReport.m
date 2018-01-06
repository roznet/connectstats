//  MIT Licence
//
//  Created on 27/10/2014.
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

#import "TSReport.h"

@interface TSReport ()
@property (nonatomic,retain) NSMutableArray * elements;
@end

@implementation TSReport

+(TSReport*)report{
    TSReport * rv = [[TSReport alloc] init];
    if (rv) {
        rv.elements = [NSMutableArray array];
    }
    return rv;
}

-(void)addReportElement:(TSReportElement*)element{
    [self.elements addObject:element];
}

-(NSString*)html{
    NSError * err = nil;
    NSMutableString * rv = [NSMutableString stringWithContentsOfFile:[RZFileOrganizer bundleFilePath:@"reportheader.html"]
                                                            encoding:NSUTF8StringEncoding
                                                               error:&err];

    NSMutableDictionary * css = [NSMutableDictionary dictionary];
    for (TSReportElement * elem in _elements) {
        NSString * cl = NSStringFromClass([elem class]);
        if (!css[cl]) {
            css[cl] = [[elem class] css];
        }
    }
    for (NSString * one in css.allValues) {
        [rv appendString:one];
    }
    [rv appendString:[NSString stringWithContentsOfFile:[RZFileOrganizer bundleFilePath:@"reportbody.html"]
                                               encoding:NSUTF8StringEncoding error:&err]];
    for (TSReportElement * elem in _elements) {
        [rv appendString:elem.html];
    }
    [rv appendString:[NSString stringWithContentsOfFile:[RZFileOrganizer bundleFilePath:@"reportfooter.html"]
                                               encoding:NSUTF8StringEncoding error:&err]];


    return rv;
}

@end
