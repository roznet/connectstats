//  MIT Licence
//
//  Created on 12/11/2012.
//
//  Copyright (c) 2012 Brice Rosenzweig.
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

#import "GCGarminRequest.h"
#import "GCWebUrl.h"
#import "GCGarminLoginSSORequest.h"
#if TARGET_OS_IPHONE
#import "GCAppGlobal.h"
#else

#endif

@implementation GCGarminReqBase

+(BOOL)killSwitchTriggered{
    return true;
}

-(BOOL)checkNoErrors{
    if (self.status == GCWebStatusOK) {
        if( self.delegate && self.delegate.lastStatusCode != 200 ){
            NSInteger code = self.delegate.lastStatusCode;
            if( code == 500 || code == 403 || code == 401 || code == 402){
                self.status = GCWebStatusAccessDenied;
            }else if (code == 404) {
                self.status = GCWebStatusResourceNotFound;
            }else if (code == 429 || code == 503){
                self.status = GCWebStatusTempUnavailable;
            }else if( code != 0 ){ // 0 is for offline / not from web
                RZLog(RZLogWarning, @"Unexpected status code %@ %@", @(code), self.debugDescription)
                self.status = GCWebStatusServiceLogicError;
            }
        }
    }
    return self.status == GCWebStatusOK;
}

-(RemoteDownloadPrepareUrl)prepareUrlFunc{
    return ^(NSMutableURLRequest * req){
        [req setValue:@"NT" forHTTPHeaderField:@"nk"];
    };
}
-(id<GCWebRequest>)remediationReq{
    if (self.status==GCWebStatusAccessDenied) {
        self.status = GCWebStatusOK;
        self.stage = gcRequestStageDownload;
#if TARGET_OS_IPHONE
        return [GCGarminLoginSSORequest requestWithUser:[[GCAppGlobal profile] currentLoginNameForService:gcServiceGarmin]
                                                 andPwd:[[GCAppGlobal profile] currentPasswordForService:gcServiceGarmin]
                                             validation:nil];
#else
        //FIXME:
        return nil;//[GCGarminLoginSSORequest requestWithUser:[FITAppGlobal currentLoginName]
        //                                         andPwd:[FITAppGlobal currentPassword]];

#endif
    }
    return nil;
}

-(gcWebService)service{
    return gcWebServiceGarmin;
}
@end

#pragma mark -
@implementation GCGarminLogout
-(NSString*)url{
    return GCWebLogoutURL();
}
-(void)process{
    // ignore first output only to establish
    [self processDone];
}

-(NSString*)description{
    return @"Logging out";
}
@end

#pragma mark -



