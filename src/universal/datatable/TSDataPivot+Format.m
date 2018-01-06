//  MIT Licence
//
//  Created on 24/10/2014.
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

#import "TSDataPivot+Format.h"

@implementation TSDataPivot (Format)

-(NSString*)formatAsString{
    NSMutableString * rv = nil;
    NSArray * grid = [self asGrid];

    NSUInteger nr = grid.count;
    NSMutableArray * str = [NSMutableArray array];
    NSMutableArray * widths = [NSMutableArray array];
    if (nr>0) {
        NSUInteger nc = [grid[0] count];

        // First Format and collect width
        for (NSUInteger r=0; r<nr; r++) {
            NSMutableArray * line = [NSMutableArray array];

            for (NSUInteger c=0; c<nc; c++) {
                id val = grid[r][c];
                NSString * formatted = nil;
                if ([val isKindOfClass:[NSNull class]]) {
                    formatted = @"";
                }else if([val respondsToSelector:@selector(stringValue)]){
                    formatted = [val stringValue];
                }else{
                    formatted = [val description];
                }
                NSUInteger width = [formatted length];
                if (widths.count<=c) {
                    [widths addObject:@(width)];
                }else{
                    [widths setObject:@(MAX(width, [widths[c] integerValue])) atIndexedSubscript:c];
                }
                [line addObject:formatted];
            }
            [str addObject:line];
        }

        // then print
        rv = [NSMutableString string];
        for (NSUInteger r=0; r<nr; r++) {
            NSMutableArray * line = [NSMutableArray array];
            if (r == self.columns.count) {
                for (NSUInteger c=0; c<nc; c++) {
                    NSUInteger width = [widths[c] integerValue];
                    [line addObject:[@"" stringByPaddingToLength:width withString:@"-" startingAtIndex:0]];
                }
                [rv appendFormat:@"%@\n", [line componentsJoinedByString:@"-|-"] ];
                line = [NSMutableArray array];
            }


            for (NSUInteger c=0; c<nc; c++) {
                NSUInteger width = [widths[c] integerValue];
                NSString * formatted = str[r][c];
                [line addObject:[formatted stringByPaddingToLength:width withString:@" " startingAtIndex:0]];
            }
            [rv appendFormat:@"%@\n", [line componentsJoinedByString:@" | "] ];

        }
    }
    return rv;
}

-(NSString*)formatAsHtml{
    NSMutableString * rv = [NSMutableString stringWithString:@"<table>\n"];
    NSArray * grid = [self asGrid];

    NSUInteger nr = grid.count;
    if (nr>0) {
        NSUInteger nc = [grid[0] count];

        NSUInteger ncf = self.columns.count;
        NSUInteger nrf = self.rows.count;

        NSUInteger cignorecount = 0; // easier one row at a time
        NSUInteger * rignorecount = calloc(sizeof(NSUInteger), nrf); // multiple columns

        //NSUInteger rignorecount = 0;

        for (NSUInteger r=0; r<nr; r++) {
            [rv appendString:@"<tr>"];
            for (NSUInteger c=0; c<nc; c++) {
                if (r<ncf) { // In columns headers
                    if (r==0 && c==0) { // fill space with empty squart
                        [rv appendFormat:@"<td class=\"empty\" rowspan=\"%d\" colspan=\"%d\"></td>", (int)ncf, (int)nrf];
                    }else if (c>=nrf){
                        if (cignorecount>0) {
                            cignorecount--;
                        }else{
                            while( c+cignorecount+1<nc && [grid[r][c+cignorecount+1] isKindOfClass:[NSNull class]]){
                                cignorecount++;
                            }
                            if (cignorecount>0) {
                                [rv appendFormat:@"<th class=\"col\" colspan=\"%d\">%@</th>", (int)( cignorecount+1), grid[r][c]];
                            }else{
                                [rv appendFormat:@"<th class=\"col\">%@</th>", grid[r][c]];
                            }
                        }
                    }
                }else{ // in rows
                    if (c<nrf) { // rows description
                        if (rignorecount[c]>0) {
                            rignorecount[c]--;
                        }else{
                            while (r+rignorecount[c]+1<nr && [grid[r+rignorecount[c]+1][c] isKindOfClass:[NSNull class]]) {
                                rignorecount[c]++;
                            }
                            if(rignorecount[c]>0){
                                [rv appendFormat:@"<th class=\"row\" rowspan=\"%d\">%@</th>", (int)(rignorecount[c]+1), grid[r][c]];
                            }else{
                                [rv appendFormat:@"<th class=\"row\">%@</th>", grid[r][c]];
                            }
                        }

                    }else{ // data
                        id val = grid[r][c];
                        if ([val isKindOfClass:[NSNull class]]) {
                            [rv appendFormat:@"<td class=\"empty\"></td>"];
                        }else{
                            [rv appendFormat:@"<td class=\"cell\">%@</td>", val];
                        }
                    }
                }
            }
            [rv appendString:@"</tr>\n"];
        }
        free(rignorecount);
    }
    [rv appendString:@"</table>\n"];
    return rv;
}
@end
