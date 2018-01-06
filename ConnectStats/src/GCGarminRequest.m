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
#import "GCAppGlobal.h"
#import "GCWebUrl.h"
#import "GCAppGlobal.h"
#import "GCGarminActivityXMLParser.h"
#import "GCGarminSearchJsonParser.h"
#import "Flurry.h"
#import "GCGarminLoginSSORequest.h"
#import "GCGarminLoginWebRequest.h"



@implementation GCGarminReqBase


-(BOOL)checkNoErrors{
    if (self.status == GCWebStatusOK) {
        if (self.theString) {
            NSRange res1 = [self.theString rangeOfString:GC_HTML_ACCESS_DENIED];
            NSRange res2 = [self.theString rangeOfString:GC_HTML_TEMP_UNAVAILABLE];
            NSRange res3 = [self.theString rangeOfString:GC_HTML_TEMP_MAINTENANCE];
            NSRange res4 = [self.theString rangeOfString:GC_HTML_DELETED_ACTIVITY];
            NSRange res5 = [self.theString rangeOfString:GC_HTML_INTERNAL_ERROR];
            NSRange res6 = [self.theString rangeOfString:GC_HTML_WEBAPPEXCEPTION];
            if (res1.location != NSNotFound || res6.location != NSNotFound) {
                self.status = GCWebStatusAccessDenied;
                [self.delegate requireLogin:gcWebServiceGarmin];
            }else if(res2.location != NSNotFound || res3.location != NSNotFound){
                self.status = GCWebStatusTempUnavailable;
            }else if(res4.location != NSNotFound){
                self.status = GCWebStatusDeletedActivity;
            }else if(res5.location != NSNotFound){
                self.status = GCWebStatusServiceInternalError;
            }
        }
    }
    return self.status == GCWebStatusOK;
}
-(id<GCWebRequest>)remediationReq{
    if (self.status==GCWebStatusAccessDenied) {
        gcGarminLoginMethod method = (gcGarminLoginMethod)[[GCAppGlobal profile] configGetInt:CONFIG_GARMIN_LOGIN_METHOD defaultValue:GARMINLOGIN_DEFAULT];
        if (method == gcGarminLoginMethodDirect){
            self.status = GCWebStatusOK;
            self.stage = gcRequestStageDownload;
            return [GCGarminLoginSSORequest requestWithUser:[[GCAppGlobal profile] currentLoginNameForService:gcServiceGarmin]
                                                                       andPwd:[[GCAppGlobal profile] currentPasswordForService:gcServiceGarmin]];
        }else if(method == gcGarminLoginMethodWebview){//gcGarminLoginMethodWebview
            self.status = GCWebStatusOK;
            self.stage = gcRequestStageDownload;
            return [GCGarminLoginWebRequest request];
        }
    }
    return nil;
}

@end

#pragma mark -
@implementation GCGarminLogout
-(NSString*)url{
    return GCWebLogoutURL();
}
-(void)process{
    // ignore first output only to establish
    [self setNextReq:nil];
    [self processDone];
}

-(NSString*)description{
    return @"Logging out";
}
@end

#pragma mark -



