//  MIT Licence
//
//  Created on 28/02/2014.
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

#import "GCGarminLoginSSORequest.h"
#import "ConnectStats-Swift.h"

@interface GCGarminLoginSSORequest ()
@property (nonatomic,retain) NSString * uname;
@property (nonatomic,retain) NSString * pwd;
@property (nonatomic,copy) GCGarminLoginValidationFunc validationFunc;


@end

@implementation GCGarminLoginSSORequest
+(GCGarminLoginSSORequest*)requestWithUser:(NSString*)name andPwd:(NSString*)pwd validation:(GCGarminLoginValidationFunc)val{
    GCGarminLoginSSORequest * rv = RZReturnAutorelease([[GCGarminLoginSSORequest alloc] init]);
    if (rv) {
        rv.uname = name;
        rv.pwd = pwd;
        rv.validationFunc = val;
    }
    return rv;
}

-(NSString*)description{
    return NSLocalizedString( @"Garmin Connect Login", @"Garmin Connect");
}

#if !__has_feature(objc_arc)
-(void)dealloc{
    [_uname release];
    [_pwd release];
    [_validationFunc release];
    [_ssoLogin release];

    [super dealloc];
}
#endif

-(NSString*)url{
    return nil;
}

-(BOOL)incomplete{
    return self.pwd.length == 0 || self.uname.length == 0;
}

-(BOOL)shouldRun{
    return self.validationFunc == nil || self.validationFunc();
}

-(NSString*)urlDescription{
    return @"https://sso.garmin.com/sso/signin";
}

-(gcWebService)service{
    return gcWebServiceGarmin;// login
}

-(BOOL)priorityRequest{
    return true;
}

-(void)process{
    if( ![self shouldRun] || [self incomplete]){
        NSMutableArray * msg = [NSMutableArray array];
        if(  [self incomplete] ){
            [msg addObject:@"incomplete"];
        }
        if( ![self shouldRun] ){
            [msg addObject:@"should not run"];
        }

        if( [self shouldRun] && [self incomplete] ){
            self.status = GCWebStatusIncompleteCredential;
            RZLog(RZLogError,@"Trying to do garmin login but %@", [msg componentsJoinedByString:@" and "] );
        }else{
            RZLog(RZLogInfo,@"Trying to do garmin login but %@", [msg componentsJoinedByString:@" and "] );
            self.status = GCWebStatusOK;
        }
        [self processDone];
    }else{
        [self swiftLogin];
    }
}

-(id<GCWebRequest>)nextReq{
    return nil;
}

-(void)loginCompleted:(GCWebStatus)status{
    self.status = status;
    [self processDone];
}
@end
