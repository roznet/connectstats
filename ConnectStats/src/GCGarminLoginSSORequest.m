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

typedef NS_ENUM(NSUInteger, gcSSOStages) {
    gcSSOGetSigninFormCRSFToken,     // first get the signin page and extract the csrf token
    gcSSOGetServiceTicket,  // then do the login and extract the service ticket
    gcSSOLoginWithServiceTicket, // finaly login with the service ticket

    gcSSOAllDone,
};

NSString * kGarminFullUrl =
@"https://sso.garmin.com/sso/signin?service=https%3A%2F%2Fconnect.garmin.com%2Fmodern%2F&webhost=https%3A%2F%2Fconnect.garmin.com&source=https%3A%2F%2Fconnect.garmin.com%2Fen-US%2Fsignin&redirectAfterAccountLoginUrl=https%3A%2F%2Fconnect.garmin.com%2Fmodern%2F&redirectAfterAccountCreationUrl=https%3A%2F%2Fconnect.garmin.com%2Fmodern%2F&gauthHost=https%3A%2F%2Fsso.garmin.com%2Fsso&locale=en_GB&id=gauth-widget&cssUrl=https%3A%2F%2Fstatic.garmincdn.com%2Fcom.garmin.connect%2Fui%2Fcss%2Fgauth-custom-v1.2-min.css&privacyStatementUrl=%2F%2Fconnect.garmin.com%2Fen-US%2Fprivacy%2F&clientId=GarminConnect&rememberMeShown=true&rememberMeChecked=false&createAccountShown=true&openCreateAccount=false&displayNameShown=false&consumeServiceTicket=false&initialFocus=true&embedWidget=false&generateExtraServiceTicket=true&generateTwoExtraServiceTickets=false&generateNoServiceTicket=false&globalOptInShown=true&globalOptInChecked=false&mobile=false&connectLegalTerms=true&locationPromptShown=true&showPassword=true";


@interface GCGarminLoginSSORequest ()
@property (nonatomic,retain) NSString * uname;
@property (nonatomic,retain) NSString * pwd;
@property (nonatomic,assign) gcSSOStages ssoStage;
@property (nonatomic,retain) NSString * serviceTicket;
@property (nonatomic,retain) NSString * csrfToken;
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
    switch (self.ssoStage) {
        case gcSSOGetServiceTicket:
            
        case gcSSOGetSigninFormCRSFToken:
            return @"Garmin Connect Authorize";
        case gcSSOLoginWithServiceTicket:
        case gcSSOAllDone:
            return @"Garmin Connect Success";
    }
}
#if !__has_feature(objc_arc)
-(void)dealloc{
    [_uname release];
    [_pwd release];
    [_csrfToken release];
    [_serviceTicket release];
    [_validationFunc release];

    [super dealloc];
}
#endif
-(NSDictionary*)dictForGetRequest{
    switch (self.ssoStage) {
        case gcSSOGetServiceTicket:
            return @{
                     @"service":    @"https://connect.garmin.com/post-auth/login",
                     @"clientId":   @"GarminConnect",
                     @"consumeServiceTicket": @"false",
                     @"rememberMeChecked": @"true"
                     };
            break;
        case gcSSOLoginWithServiceTicket:
            if (self.serviceTicket) {
                return @{@"ticket": self.serviceTicket};
            }
        case gcSSOGetSigninFormCRSFToken:
        case gcSSOAllDone:
            break;
    }
    return nil;
}
-(NSDictionary*)postData{
    if (self.ssoStage == gcSSOGetServiceTicket ) {
        return @{
          @"username": self.uname,
          @"password": self.pwd,
          @"embed": @"false",          
          @"_csrf":self.csrfToken?:@"",
          };
    }
    return nil;
}
-(RemoteDownloadPrepareUrl)prepareUrlFunc{
    // to get the service ticket it needs to have these headers, other reuqest are fine
    if( self.ssoStage == gcSSOGetServiceTicket){
        return ^(NSMutableURLRequest*req){
            [req setValue:@"https://sso.garmin.com" forHTTPHeaderField:@"origin"];
            [req setValue:kGarminFullUrl forHTTPHeaderField:@"referer"];
        };
    }
    return nil;
}

-(void)setCookiesForStage{
}
-(void)saveCookiesForStage{
}

-(void)preConnectionSetup{
}

-(BOOL)incomplete{
    return self.pwd.length == 0 || self.uname.length == 0;
}

-(BOOL)shouldRun{
    return self.validationFunc == nil || self.validationFunc();
}

-(NSString*)url{
    if( [self incomplete] || ![self shouldRun]){
        return nil;
    }
    
    switch (self.ssoStage) {
        case gcSSOGetServiceTicket:
            return kGarminFullUrl;
        case gcSSOGetSigninFormCRSFToken:
            return kGarminFullUrl;
        case gcSSOLoginWithServiceTicket:
            return RZWebEncodeURLwGet(@"https://connect.garmin.com/modern/", [self dictForGetRequest]);
        case gcSSOAllDone:
            return @"https://connect.garmin.com";
    }
}

-(NSString*)urlDescription{
    // Special implementation or it's too long
    switch (self.ssoStage) {
        case gcSSOGetServiceTicket:
            return @"https://sso.garmin.com/sso/signin?serviceticket";
        case gcSSOGetSigninFormCRSFToken:
            return @"https://sso.garmin.com/sso/signin?crsftoken";
        case gcSSOLoginWithServiceTicket:
            return RZWebEncodeURLwGet(@"https://connect.garmin.com/modern/", [self dictForGetRequest]);
        case gcSSOAllDone:
            return @"https://connect.garmin.com";
    }
}


-(gcWebService)service{
    return gcWebServiceGarmin;// login
}

-(BOOL)priorityRequest{
    return true;
}

-(nullable NSString*)extractQuotedFrom:(NSString*)prefix{
    NSMutableArray<NSString*> * tries =[NSMutableArray arrayWithObject:prefix];
    
    [tries addObject:[prefix stringByReplacingOccurrencesOfString:@"/" withString:@"\\/"]];
    
    NSString * rv = nil;
    for( NSString * try in tries){
        NSRange range = [self.theString rangeOfString:try];
        if (range.location != NSNotFound) {
            NSString * valuestr = [self.theString substringFromIndex:range.location+range.length];
            range = [valuestr rangeOfString:@"\""];
            if (range.location != NSNotFound) {
                valuestr = [valuestr substringToIndex:range.location];
                rv = valuestr;
            }
        }
    }
    return rv;
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
            self.status = GCWebStatusLoginFailed;
            RZLog(RZLogError,@"Trying to do garmin login but %@", [msg componentsJoinedByString:@" and "] );
        }else{
            RZLog(RZLogInfo,@"Trying to do garmin login but %@", [msg componentsJoinedByString:@" and "] );
            self.status = GCWebStatusOK;
        }

        // don't do anything more
        self.ssoStage = gcSSOAllDone;
        [self processDone];
        return;
    }
    
#if TARGET_IPHONE_SIMULATOR
    NSString * fn = [NSString stringWithFormat:@"garmin_sso_stage_%d.html", (int)self.ssoStage];
    NSError * e = nil;
    [self.theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:self.encoding error:&e];
#endif
    if (self.ssoStage == gcSSOGetSigninFormCRSFToken){
        NSString * prefix = @"type=\"hidden\" name=\"_csrf\" value=\"";
        self.csrfToken = [self extractQuotedFrom:prefix];

    }else if (self.ssoStage == gcSSOGetServiceTicket){
        NSString * prefix = @"https://connect.garmin.com/modern/?ticket=";
        self.serviceTicket = [self extractQuotedFrom:prefix];
        if (!self.serviceTicket) {
            NSRange range = [self.theString rangeOfString:@"RENEW_PASSWORD_STATE"];
            NSRange range2 = [self.theString rangeOfString:@"'status':'SUCCESS'"];

            if( range.location != NSNotFound){
                RZLog(RZLogError, @"Require Password Renew");
                self.status = GCWebStatusRequirePasswordRenew;
            }else if(range2.location != NSNotFound){
                RZLog(RZLogError, @"Login successful, but API seem to have changed???");
                self.status = GCWebStatusServiceInternalError;
            }else{
                RZLog(RZLogError, @"Failed to extract service ticket");
                self.status = GCWebStatusLoginFailed;
            }
            [self.delegate requireLogin:gcWebServiceGarmin];
        }
    }else if (self.ssoStage == gcSSOLoginWithServiceTicket){
        [self.delegate loginSuccess:gcWebServiceGarmin];
        
    }
    [self saveCookiesForStage];

    if( self.status != GCWebStatusOK){
        NSString * efn = [NSString stringWithFormat:@"error_garmin_sso_stage_%d.html", (int)self.ssoStage];
        NSError * ee = nil;
        if(![self.theString writeToFile:[RZFileOrganizer writeableFilePath:efn] atomically:true encoding:self.encoding error:&ee]){
            RZLog(RZLogError, @"Failed to save %@. %@", efn, ee.localizedDescription);
        }
    }
    [self processDone];
}

-(id<GCWebRequest>)nextReq{
    GCGarminLoginSSORequest * rv = nil;

    gcSSOStages nextStage = self.ssoStage+1;

    if (nextStage < gcSSOAllDone) {
        rv = [GCGarminLoginSSORequest requestWithUser:self.uname andPwd:self.pwd validation:self.validationFunc];
        rv.serviceTicket = self.serviceTicket;
        rv.csrfToken = self.csrfToken;
        rv.ssoStage = nextStage;
    }
    return rv;
}

-(BOOL)isSameAsRequest:(id)req{
    if ([req isMemberOfClass:[self class]]) {
        GCGarminLoginSSORequest * other = (GCGarminLoginSSORequest*)req;
        return other.ssoStage == self.ssoStage && self.uname == other.uname && self.pwd == other.pwd;
    }
    return false;
}


@end
