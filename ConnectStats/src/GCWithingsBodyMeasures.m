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
@import RZExternal;

@implementation GCWithingsBodyMeasures
-(GCWithingsBodyMeasures*)initNextWith:(GCWithingsBodyMeasures*)current{
    if( self = [super initNextWith:current]){
        self.fromDate = current.fromDate;
    }
    return self;
}

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
    if( self.navigationController ){
        return nil;
    }
    if( self.fromDate ){
        return [NSString stringWithFormat:@"https://wbsapi.withings.net/measure?action=getmeas&lastupdate=%@", @(self.fromDate.timeIntervalSince1970)];
    }else{
        return @"https://wbsapi.withings.net/measure?action=getmeas";
    }
}
-(NSString*)debugDescription{
    return [NSString stringWithFormat:@"<%@: %@>",
            NSStringFromClass([self class]),
            
            self.url ? [self.urlDescription truncateIfLongerThan:192 ellipsis:@"..."] : @"oauth"];
}

-(NSDictionary*)postData{
    return nil;
}

-(NSString*)description{
    return [NSString stringWithFormat: @"Withings Weight"];
}

-(void)process{
    
    if (self.navigationController) {
        dispatch_async( dispatch_get_main_queue(), ^(){
            [self processNewStage];
            [self signInToWithings];
        });
    }else{
#if TARGET_IPHONE_SIMULATOR
        NSError * e = nil;
        NSString * fn = [NSString stringWithFormat:@"withings_getmeas_%@.json", @"last"];
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
        self.status = parser.status;
        NSUInteger added = 0;
        if( parser.status == GCWebStatusOK){
            for (GCHealthMeasure * measure in parser.measures) {
                if( [[GCAppGlobal health] addHealthMeasure:measure] ){
                    added += 1;
                }
            }
        }
        if( added > 0){
            RZLog(RZLogInfo, @"Received %lu healths measures and added %lu new ones", parser.measures.count, added);
        }else{
            RZLog(RZLogInfo, @"Received %lu healths measures but no new ones", parser.measures.count);
        }
    }else{
        if (self.navigationController==nil) {
            RZLog(RZLogWarning, @"No data received");
        }
    }
    dispatch_async( dispatch_get_main_queue(), ^(){
        [[GCAppGlobal profile] serviceAnchor:gcServiceWithings set:[NSDate date].timeIntervalSince1970];
        [[GCAppGlobal profile] serviceCompletedFull:gcServiceWithings set:YES];
        [GCAppGlobal saveSettings];
        [self processDone];
    });
}

-(id<GCWebRequest>)nextReq{
    GCWithingsBodyMeasures * next = nil;
    if (self.navigationController) {
        next = RZReturnAutorelease([[GCWithingsBodyMeasures alloc] initNextWith:self]);
    }
    return next;
}

-(id<GCWebRequest>)remediationReq{
    if (self.status == GCWebStatusLoginFailed && [self isSignedIn]) {
        [GCWithingsReqBase signout];
        GCWithingsBodyMeasures * next = [GCWithingsBodyMeasures measuresSinceDate:self.fromDate with:[GCAppGlobal currentNavigationController]];
        return next;
    }else{
        if( self.status == GCWebStatusLoginFailed){
            [GCWithingsReqBase signout];
        }
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
