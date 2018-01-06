//  MIT Licence
//
//  Created on 08/10/2014.
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

#import "GCWithingsSleepMeasures.h"
#import "GCAppGlobal.h"
#import "GCWithingsBodyMeasuresParser.h"
#import "GCWithingsSleepParser.h"

@implementation GCWithingsSleepMeasures
+(GCWithingsSleepMeasures*)measuresSinceDate:(NSDate*)date with:(UINavigationController*)nav{
    GCWithingsSleepMeasures * rv = [[[GCWithingsSleepMeasures alloc] init] autorelease];
    if (rv) {
        rv.navigationController = nav;
        if (date ) {
            rv.fromDate = date;
        }else{
            NSDateComponents * comp = [[NSDateComponents alloc] init];
            comp.day = -7;
            rv.fromDate = [[NSDate date] dateByAddingGregorianComponents:comp];
            [comp release];
        }

    }
    return rv;
}
-(void)dealloc{
    [_fromDate release];
    [super dealloc];
}

-(NSString*)url{
    return nil;
}

-(NSURLRequest*)preparedUrlRequest{
    if (self.navigationController) {
        return nil;
    }else{
        NSString * path = [NSString stringWithFormat:@"v2/sleep"];

        NSString * f_s= [NSString stringWithFormat:@"%.0f",(self.fromDate).timeIntervalSince1970];
        NSString * t_s= [NSString stringWithFormat:@"%.0f",[NSDate date].timeIntervalSince1970];

        NSDictionary *parameters = @{@"action" : @"get",
                                     @"startdate":f_s,
                                     @"enddate":t_s,
                                     @"userid":self.userId
                                     };

        return [self preparedUrlRequest:path params:parameters];
    }
}

-(NSDictionary*)postData{
    return nil;
}

-(NSString*)description{
    return [NSString stringWithFormat: @"Withings Sleep"];
}

-(void)process{
    if (![self isSignedIn]) {
        [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(signInToWithings) withObject:nil waitUntilDone:NO];
    }else{
#if TARGET_IPHONE_SIMULATOR
        NSError * e = nil;
        NSString * fn = [NSString stringWithFormat:@"withings_sleep_%@_%@.json", self.userId, [self.fromDate YYYYMMDD]];
        [self.theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:self.encoding error:&e];
#endif
        dispatch_async([GCAppGlobal worker],^(){
            [self parse];
        });
    }
}

-(void)parse{
    if (self.theString) {
        GCWithingsSleepParser * parser = [GCWithingsSleepParser sleepParserFor:[self.theString dataUsingEncoding:self.encoding]];
        [[GCAppGlobal health] addSleepBlocks:parser.blocks];
    }else{
        if (self.navigationController==nil) {
            RZLog(RZLogWarning, @"No data received");
        }
    }

    [self performSelectorOnMainThread:@selector(processDone) withObject:nil waitUntilDone:NO];
}

-(id<GCWebRequest>)nextReq{
    GCWithingsSleepMeasures * next = nil;
    if (self.navigationController) {
        next = [GCWithingsSleepMeasures measuresSinceDate:self.fromDate with:nil];
    }else{
    }
    return next;
}
-(id<GCWebRequest>)remediationReq{
    if (self.status == GCWebStatusLoginFailed && self.navigationController  && [self isSignedIn]) {
        [GCWithingsReqBase signout];
        GCWithingsSleepMeasures * next = [GCWithingsSleepMeasures measuresSinceDate:self.fromDate with:self.navigationController];
        return next;
    }
    return nil;
}

@end
