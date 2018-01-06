//  MIT Licence
//
//  Created on 22/02/2014.
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

#import "GCGarminLoginWebRequest.h"
#import "GCAppGlobal.h"
#import "GCAppProfiles.h"

typedef NS_ENUM(NSUInteger, gcLoginStage) {
    gcLoginStageTest,
    gcLoginStageSignin,
    gcLoginStageEnd
};

@interface GCGarminLoginWebRequest ()
@property (nonatomic,assign) gcLoginStage stage;
@property (nonatomic,retain) id<GCWebRequestDelegate> delegate;

@end

@implementation GCGarminLoginWebRequest
+(GCGarminLoginWebRequest*)request{
    GCGarminLoginWebRequest * rv = [[[GCGarminLoginWebRequest alloc] init] autorelease];
    if (rv) {
        rv.stage = gcLoginStageTest;
    }
    return rv;
}
-(void)dealloc{
    [_delegate release];
    [super dealloc];
}
-(GCWebStatus)status{
    return GCWebStatusOK;
}
-(NSString*)description{
    return @"Login to Garmin";
}
-(gcWebService)service{
    return gcWebServiceGarmin;// login
}

-(NSString*)url{
    NSString * testUrl = nil;
    testUrl = @"https://connect.garmin.com";

    return testUrl;
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
-(BOOL)priorityRequest{
    return true;
}
-(void)saveError:(NSString*)theString{
    NSError * e;
    NSString * fname = @"error_garmin_login.json";
    if(![theString writeToFile:[RZFileOrganizer writeableFilePath:fname] atomically:true encoding:NSUTF8StringEncoding error:&e]){
        RZLog(RZLogError, @"Failed to save %@. %@", fname, e.localizedDescription);
    }
}

-(void)process:(NSString*)theString encoding:(NSStringEncoding)encoding andDelegate:(id<GCWebRequestDelegate>) delegate{
#if TARGET_IPHONE_SIMULATOR
    NSError * err = nil;
    NSString * fn = [NSString stringWithFormat:@"garmin_login.html"];
    [theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:encoding error:&err];
#endif

    if ([theString rangeOfString:[[GCAppGlobal profile] currentLoginNameForService:gcServiceGarmin]].location!=NSNotFound) {
        [delegate processDone:self];
    }else{
        self.delegate = delegate;
        UINavigationController * nav= [GCAppGlobal currentNavigationController];
        if (nav) {
            GCGarminLoginViewController * viewer = [GCGarminLoginViewController loginView:gcLoginMethodGarminConnectSite forDelegate:self];
            [nav pushViewController:viewer animated:YES];
        }
    }
}
-(id<GCWebRequest>)nextReq{
    return nil;
}

-(void)loginSuccess{
    [self.delegate processDone:self];
}

@end
