//  MIT Licence
//
//  Created on 28/09/2014.
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

#import "GCFitBitWeight.h"
#import "GCAppGlobal.h"

@implementation GCFitBitWeight

-(void)dealloc{
    [_fromDate release];
    [_toDate release];
    [super dealloc];
}

+(GCFitBitWeight*)activitiesFromDate:(NSDate*)fromD to:(NSDate*)toD with:(UINavigationController*)nav{
    GCFitBitWeight * rv = [[[GCFitBitWeight alloc] init]autorelease];
    if (rv) {
        rv.navigationController = nav;
        if (fromD==nil) {
            NSDateComponents * comp = [[NSDateComponents alloc] init];
            comp.day = -90;
            rv.fromDate = [toD dateByAddingGregorianComponents:comp];
            [comp release];
        }else{
            rv.fromDate = fromD;
        }
        rv.toDate = toD;
    }
    return rv;
}
-(NSString*)url{
    return nil;
}

-(NSURLRequest*)preparedUrlRequest{
    if (self.navigationController && ![self isSignedIn]) {
        return nil;
    }else{
        NSString * path = [NSString stringWithFormat:@"1/user/-/body/log/weight/date/%@/1m.json", [self.toDate YYYYdashMMdashDD]];
        NSDictionary *parameters = @{@"format" : @"json"};
        return [self preparedUrlRequest:path params:parameters];
    }
}

-(NSDictionary*)postData{
    return nil;
}

-(NSString*)description{
    return @"Fitbit Weight";
}

-(void)process{
    if (![self isSignedIn]) {
        [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
        dispatch_async(dispatch_get_main_queue(),^(){
            [self signInToFitBit];
        });

    }else{
#if TARGET_IPHONE_SIMULATOR
        NSError * e = nil;
        NSString * fn = @"fitbit_weight.json";
        [self.theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:self.encoding error:&e];
#endif
        dispatch_async([GCAppGlobal worker],^(){
            [self parse];
        });
    }
}

-(void)parse{
    if (self.theString) {
    }else{
        RZLog(RZLogWarning, @"No data received");
    }

    [self performSelectorOnMainThread:@selector(processDone) withObject:nil waitUntilDone:NO];
}

-(id<GCWebRequest>)nextReq{
    GCFitBitWeight * next = nil;
    if (self.navigationController) {
        next = [GCFitBitWeight activitiesFromDate:self.fromDate to:self.toDate with:nil];
    }else{
        next = nil;
    }
    return next;
}
-(id<GCWebRequest>)remediationReq{
    if (self.status == GCWebStatusLoginFailed && self.navigationController  && [self isSignedIn]) {
        [GCFitBitReqBase signout];
        GCFitBitWeight * next = [GCFitBitWeight activitiesFromDate:self.fromDate to:self.toDate with:self.navigationController];
        return next;
    }
    return nil;
}

@end
