//  MIT Licence
//
//  Created on 05/10/2014.
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

#import "GCWithingsBodyMeasuresParser.h"
#import "GCHealthMeasure.h"

@implementation GCWithingsBodyMeasuresParser
-(void)dealloc{
    [_measures release];
    [super dealloc];
}

+(GCWithingsBodyMeasuresParser*)bodyMeasuresParser:(NSData *)data{
    GCWithingsBodyMeasuresParser * rv = [[[GCWithingsBodyMeasuresParser alloc] init] autorelease];
    if (rv) {
        [rv parse:data];
    }
    return rv;
}

-(void)parse:(NSData*)data{
    NSError * err = nil;
    self.status = GCWebStatusParsingFailed;
    NSDictionary * json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err ];
    if (json==nil) {
        RZLog(RZLogError, @"json parsing failed %@", err);
    }else {
        NSArray * raw = json[@"body"][@"measuregrps"];
        NSMutableArray * found = [NSMutableArray arrayWithCapacity:raw.count];
        if (raw) {

            for (NSDictionary * one in raw) {
                NSDate * date = nil;
                NSNumber * grpid = nil;

                NSNumber * dateN = one[WS_KEY_DATE];
                if (dateN && [dateN isKindOfClass:[NSNumber class]]) {
                    date = [NSDate dateWithTimeIntervalSince1970:dateN.longValue];
                }

                grpid = one[WS_KEY_GRPID];
                if (![grpid isKindOfClass:[NSNumber class]]) {
                    grpid = nil;
                }

                if (grpid&&date) {
                    NSArray * meas = one[WS_KEY_MEASURES];
                    if (meas) {
                        for (NSDictionary * m in meas) {
                            GCHealthMeasure * hm = [GCHealthMeasure healthMeasureFromWithings:m forDate:date andId:grpid.integerValue];
                            [found addObject:hm];
                        }
                    }
                }
            }
            self.measures = found;
            self.status = GCWebStatusOK;
        }else{
            if( [json[@"status"] respondsToSelector:@selector(integerValue)]){
                NSInteger errorCode = [json[@"status"] integerValue];
                if( errorCode == 401){
                    self.status = GCWebStatusLoginFailed;
                }else{
                    self.status = GCWebStatusParsingFailed;
                }
            }
            RZLog(RZLogError, @"Withings issue: Status=%@, error=%@", json[@"status"], json[@"error"]);
        }
    }
}

@end
