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

#import "GCWithingsBodyMeasures.h"
#import "GCAppGlobal.h"
#import "GCWithingsBodyMeasuresParser.h"
#import "GCHealthOrganizer.h"

@implementation GCWithingsBodyMeasures

+(GCWithingsBodyMeasures*)measuresSinceDate:(NSDate*)date with:(UINavigationController*)nav{
    GCWithingsBodyMeasures * rv = [[[GCWithingsBodyMeasures alloc] init] autorelease];
    if (rv) {
        rv.navigationController = nav;
        rv.fromDate = date;
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
        NSString * path = [NSString stringWithFormat:@"measure"];
        NSDictionary *parameters = @{@"action" : @"getmeas"};

        return [self preparedUrlRequest:path params:parameters];
    }
}

-(NSDictionary*)postData{
    return nil;
}

-(NSString*)description{
    return [NSString stringWithFormat: @"Withings Weight"];
}

-(void)process{
    if (![self isSignedIn]) {
        [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(signInToWithings) withObject:nil waitUntilDone:NO];
    }else{
#if TARGET_IPHONE_SIMULATOR
        NSError * e = nil;
        NSString * fn = [NSString stringWithFormat:@"withings_getmeas_%@.json", self.userId];
        [self.theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:kRequestDebugFileEncoding error:&e];
#endif
        dispatch_async([GCAppGlobal worker],^(){
            [self parse];
        });
    }
}

-(void)parse{
    if (self.theString) {
        GCWithingsBodyMeasuresParser * parser =[GCWithingsBodyMeasuresParser bodyMeasuresParser:[self.theString dataUsingEncoding:self.encoding]];
        for (GCHealthMeasure * measure in parser.measures) {
            [[GCAppGlobal health] addHealthMeasure:measure];
        }
    }else{
        if (self.navigationController==nil) {
            RZLog(RZLogWarning, @"No data received");
        }
    }

    [self performSelectorOnMainThread:@selector(processDone) withObject:nil waitUntilDone:NO];
}

-(id<GCWebRequest>)nextReq{
    GCWithingsBodyMeasures * next = nil;
    if (self.navigationController) {
        next = [GCWithingsBodyMeasures measuresSinceDate:self.fromDate with:nil];
    }else{
    }
    return next;
}
-(id<GCWebRequest>)remediationReq{
    if (self.status == GCWebStatusLoginFailed && self.navigationController  && [self isSignedIn]) {
        [GCWithingsReqBase signout];
        GCWithingsBodyMeasures * next = [GCWithingsBodyMeasures measuresSinceDate:self.fromDate with:self.navigationController];
        return next;
    }
    return nil;
}

+(GCHealthOrganizer*)testForHealth:(GCHealthOrganizer*)health withFilesIn:(NSString*)path forId:(NSString*)userId{
    NSString * fn = [NSString stringWithFormat:@"withings_getmeas_%@.json", userId];
    NSString * fp = [path stringByAppendingPathComponent:fn];

    NSString * info = [NSString stringWithContentsOfFile:fp encoding:kRequestDebugFileEncoding error:nil];
    GCWithingsBodyMeasuresParser * parser =[GCWithingsBodyMeasuresParser bodyMeasuresParser:[info dataUsingEncoding:kRequestDebugFileEncoding]];
    for (GCHealthMeasure * measure in parser.measures) {
        [health addHealthMeasure:measure];
    }

    return health;
}
@end
