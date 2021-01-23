//  MIT Licence
//
//  Created on 15/01/2013.
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

#import "GCGarminActivitySummaryParser.h"
#import "GCActivity+Import.h"

@interface GCGarminActivitySummaryParser ()

@property (nonatomic,retain) GCActivity * activity;
@property (nonatomic,assign) GCWebStatus status;

@end

@implementation GCGarminActivitySummaryParser

-(instancetype)init{
    return [super init];
}

-(void)dealloc{
    [_activity release];
    [super dealloc];
}

-(GCGarminActivitySummaryParser*)initWithData:(NSData*)jsonData{
    self = [super init];
    if (self) {
        NSError *e = nil;

        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&e];

        if (json==nil) {
            self.activity = nil;
            self.status = GCWebStatusParsingFailed;
            RZLog(RZLogError, @"parsing failed %@", e);
        }else if(json[@"error"]){
            self.activity = nil;
            self.status = GCWebStatusServiceLogicError;
            RZLog(RZLogWarning, @"Error in reply %@ %@", json[@"error"], json[@"message"]);
        }else{
            self.activity = [[[GCActivity alloc] initWithId:nil andGarminData:json] autorelease];
            self.status = GCWebStatusOK;
        }
    }
    return self;

}


@end
