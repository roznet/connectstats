//  MIT Licence
//
//  Created on 10/05/2015.
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

#import "NSString+CamelCase.h"


@implementation NSString (CamelCase)

- (NSString *)fromCamelCaseToSeparatedByString:(NSString *)aSep {

    NSScanner *scanner = [NSScanner scannerWithString:self];
    scanner.caseSensitive = YES;

    NSMutableString *rv = [NSMutableString string];
    NSString *buffer = nil;

    NSCharacterSet * upperCaseSet = [NSCharacterSet uppercaseLetterCharacterSet];

    while (scanner.atEnd == NO) {

        if ([scanner scanUpToCharactersFromSet:upperCaseSet intoString:&buffer]) {

            [rv appendString:buffer];

            if ([scanner scanCharactersFromSet:upperCaseSet intoString:&buffer]) {
                [rv appendString:aSep];
                [rv appendString:buffer];
            }
        }else if ([scanner scanCharactersFromSet:upperCaseSet intoString:&buffer]) {
            [rv appendString:buffer];
        }

    }

    return rv;
}

-(NSString *)dashSeparatedToSpaceCapitalized{
    NSArray * separated = [self componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"_"]];
    NSMutableArray * capitalized = [NSMutableArray arrayWithCapacity:separated.count];
    for (NSString * one in separated) {
        [capitalized addObject:[one capitalizedString]];
    }
    return [capitalized componentsJoinedByString:@" "];
}

-(NSString *)truncateIfLongerThan:(NSUInteger)nchar ellipsis:(NSString*)ellipsis{
    NSString * rv = self;
    NSUInteger length = self.length;
    if(length > nchar){
        NSString * middle = @"";
        NSUInteger left = nchar/2;
        if( ellipsis.length < length){
            middle = ellipsis;
            left = (nchar-ellipsis.length)/2;
        }
        NSUInteger right = length-left;
        rv = [NSString stringWithFormat:@"%@%@%@", [self substringToIndex:left], middle, [self substringFromIndex:right]];
    }
    return rv;
}
@end
