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

#import "GCWithingsActivityMeasures.h"
#import "GCAppGlobal.h"
#import "GCWithingsActivityParser.h"
#import "GCAppGlobal.h"
#import "GCActivitiesOrganizer.h"

@implementation GCWithingsActivityMeasures

+(GCWithingsActivityMeasures*)measuresFromDate:(NSDate*)from toDate:(NSDate*)to with:(UINavigationController*)nav{
    GCWithingsActivityMeasures * rv = [[[GCWithingsActivityMeasures alloc] init] autorelease];
    if (rv) {
        rv.navigationController = nav;
        if (from && to ) {
            rv.fromDate = from;
            rv.toDate = to;
        }else{
            NSDateComponents * comp = [[NSDateComponents alloc] init];
            if (from && !to) {
                comp.day = 30;
                rv.fromDate = from;
                rv.toDate = [rv.fromDate dateByAddingGregorianComponents:comp];
            }else{
                comp.day = -30;
                rv.toDate = to;
                rv.fromDate = [rv.toDate dateByAddingGregorianComponents:comp];

            }
            [comp release];
        }

    }
    return rv;
}
-(void)dealloc{
    [_fromDate release];
    [_toDate release];
    [super dealloc];
}

-(NSString*)url{
    return nil;
}

-(NSURLRequest*)preparedUrlRequest{
    if (self.navigationController) {
        return nil;
    }else{
        /*NSString * path = [NSString stringWithFormat:@"v2/measure"];
        NSDictionary *parameters = @{@"action" : @"getactivity",
                                     @"startdateymd":[self.fromDate YYYYdashMMdashDD],
                                     @"enddateymd":[[NSDate date] YYYYdashMMdashDD],
                                     @"userid":self.userId
                                     };
         */
        return nil;//[self preparedUrlRequest:path params:parameters];
    }
}

-(NSDictionary*)postData{
    return nil;
}

-(NSString*)description{
    return [NSString stringWithFormat: @"Withings Activities"];
}

-(void)process{
    if (![self isSignedIn]) {
        [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(signInToWithings) withObject:nil waitUntilDone:NO];
    }else{
#if TARGET_IPHONE_SIMULATOR
        NSError * e = nil;
        NSString * fn = [NSString stringWithFormat:@"withings_activity_%@.json", self.userId];
        [self.theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:self.encoding error:&e];
#endif
        dispatch_async([GCAppGlobal worker],^(){
            [self parse];
        });
    }
}

-(void)parse{
    if (self.theString) {
        GCWithingsActivityParser * parser = [GCWithingsActivityParser activitiesParser:[self.theString dataUsingEncoding:self.encoding]];
        if (parser.activities.count>0) {
            NSUInteger existingOverlap = 0;
            for (GCActivity * act in parser.activities) {
                if ([[GCAppGlobal organizer] activityForId:act.activityId]) {
                    existingOverlap++;
                }
                [[GCAppGlobal organizer ] registerActivity:act forActivityId:act.activityId];
            }
        }

        RZLog(RZLogInfo, @"parsed %d", (int)parser.activities.count);
    }else{
        if (self.navigationController==nil) {
            RZLog(RZLogWarning, @"No data received");
        }
    }

    [self performSelectorOnMainThread:@selector(processDone) withObject:nil waitUntilDone:NO];
}

-(id<GCWebRequest>)nextReq{
    GCWithingsActivityMeasures * next = nil;
    if (self.navigationController) {
        next = [GCWithingsActivityMeasures measuresFromDate:self.fromDate toDate:self.toDate with:nil];
    }else{
    }
    return next;
}
-(id<GCWebRequest>)remediationReq{
    if (self.status == GCWebStatusLoginFailed && self.navigationController  && [self isSignedIn]) {
        [GCWithingsReqBase signout];
        GCWithingsActivityMeasures * next = [GCWithingsActivityMeasures measuresFromDate:self.fromDate toDate:self.toDate with:self.navigationController];
        return next;
    }
    return nil;
}

@end
