//  MIT Licence
//
//  Created on 22/07/2015.
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

#import "GCDerivedRequest.h"
#import "GCAppGlobal.h"
#import "GCDerivedOrganizer.h"

@interface GCDerivedRequest ()
@property (nonatomic,assign) NSUInteger numberOfRequests;
@property (nonatomic,assign) NSUInteger currentRequest;
@property (nonatomic,retain) NSObject<GCWebRequestDelegate>* delegate;
@end

@implementation GCDerivedRequest

+(GCDerivedRequest*)requestFor:(NSUInteger)n{
    GCDerivedRequest * rv = [[[GCDerivedRequest alloc] init] autorelease];
    if (rv) {
        rv.numberOfRequests = n;
        rv.currentRequest = 0;
    }
    return rv;
}


-(void)dealloc{
    [[GCAppGlobal derived] detach:self];
    [_delegate release];

    [super dealloc];
}
-(GCWebStatus)status{
    return GCWebStatusOK;
}
-(NSString*)description{
    if (self.numberOfRequests > 1) {
        NSUInteger pct = (100 * self.currentRequest) / self.numberOfRequests;
        return [NSString stringWithFormat:NSLocalizedString(@"Computing Best Overall (%lu%%)", @"Derived Request"), pct];
    }else{
        return NSLocalizedString(@"Computing Best Overall", @"Derived Request");
    }
}

-(NSString*)debugDescription{
    if (self.numberOfRequests > 1) {
        return [NSString stringWithFormat:@"<%@: %@/%@>", NSStringFromClass([self class]), @(self.currentRequest), @(self.numberOfRequests)];
    }else{
        return [NSString stringWithFormat:@"<%@: %@>", NSStringFromClass([self class]), @(self.numberOfRequests)];
    }
    
}

-(NSString*)url{
    return nil;
}
-(NSDictionary*)postData{
    return nil;
}
-(NSDictionary*)deleteData{
    return nil;
}
-(NSData*)fileData{
    return nil;
}
-(NSString*)fileName{
    return nil;
}
-(void)process:(NSString*)theString encoding:(NSStringEncoding)encoding andDelegate:(NSObject<GCWebRequestDelegate>*) delegate{
    self.delegate = delegate;
    GCDerivedOrganizer * derived = [GCAppGlobal derived];
    if (derived) {
        [derived attach:self];
        dispatch_async([GCAppGlobal worker],^(){
            [derived processSome];
        });
    }else{
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.delegate processDone:self];
        });
    }
}
-(id<GCWebRequest>)nextReq{
    GCDerivedRequest * rv = nil;
    NSUInteger nextIndex = self.currentRequest + 1;
    if (nextIndex < self.numberOfRequests) {
        rv = [GCDerivedRequest requestFor:self.numberOfRequests];
        rv.currentRequest = nextIndex;
    }
    return rv;
}
-(gcWebService)service{
    return gcWebServiceNone;
}

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    if ([theInfo.stringInfo isEqualToString:kNOTIFY_DERIVED_END]) {
        [[GCAppGlobal derived] detach:self];
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.delegate processDone:self];
        });
    }
}

@end
