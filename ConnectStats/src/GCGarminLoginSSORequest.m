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
    gcSSOGetServiceTicket,
    gcSSOLoginWithServiceTicket,
    gcSSOSecondLogin,

    gcSSOAllDone,
};

NSString * kGarminFullUrl = @"https://sso.garmin.com/sso/login?service=https%3A%2F%2Fconnect.garmin.com%2Fmodern%2F&webhost=olaxpw-conctmodern006.garmin.com&source=https%3A%2F%2Fconnect.garmin.com%2Fen-US%2Fsignin&redirectAfterAccountLoginUrl=https%3A%2F%2Fconnect.garmin.com%2Fmodern%2F&redirectAfterAccountCreationUrl=https%3A%2F%2Fconnect.garmin.com%2Fmodern%2F&gauthHost=https%3A%2F%2Fsso.garmin.com%2Fsso&locale=en_US&id=gauth-widget&cssUrl=https%3A%2F%2Fstatic.garmincdn.com%2Fcom.garmin.connect%2Fui%2Fcss%2Fgauth-custom-v1.2-min.css&privacyStatementUrl=%2F%2Fconnect.garmin.com%2Fen-US%2Fprivacy%2F&clientId=GarminConnect&rememberMeShown=true&rememberMeChecked=false&createAccountShown=true&openCreateAccount=false&usernameShown=false&displayNameShown=false&consumeServiceTicket=false&initialFocus=true&embedWidget=false&generateExtraServiceTicket=false&globalOptInShown=false&globalOptInChecked=false&mobile=false&connectLegalTerms=true";


@interface GCGarminLoginSSORequest ()
@property (nonatomic,retain) NSString * uname;
@property (nonatomic,retain) NSString * pwd;
@property (nonatomic,assign) gcSSOStages ssoStage;
@property (nonatomic,retain) NSString * serviceTicket;

@end

@implementation GCGarminLoginSSORequest
+(GCGarminLoginSSORequest*)requestWithUser:(NSString*)name andPwd:(NSString*)pwd{
    GCGarminLoginSSORequest * rv = [[[GCGarminLoginSSORequest alloc] init] autorelease];
    if (rv) {
        rv.uname = name;
        rv.pwd = pwd;
    }
    return rv;
}

-(NSString*)description{
    switch (self.ssoStage) {
        case gcSSOGetServiceTicket:
            return @"Garmin Connect Authorize";
        case gcSSOLoginWithServiceTicket:
        case gcSSOSecondLogin:
            return @"Garmin Connect Login";
        case gcSSOAllDone:
            return @"Garmin Connect Success";
    }
}

-(void)dealloc{
    [_uname release];
    [_pwd release];
    [_serviceTicket release];

    [super dealloc];
}

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
        case gcSSOSecondLogin:
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
          @"_eventId": @"submit",
          @"embed": @"true",
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

-(NSString*)url{
    switch (self.ssoStage) {
        case gcSSOGetServiceTicket:
            return kGarminFullUrl;
        case gcSSOLoginWithServiceTicket:
            return RZWebEncodeURLwGet(@"https://connect.garmin.com/modern/", [self dictForGetRequest]);
        case gcSSOSecondLogin:
            return @"https://connect.garmin.com/legacy/session";
        default:
            return @"https://connect.garmin.com";
    }
}

-(gcWebService)service{
    return gcWebServiceGarmin;// login
}

-(BOOL)priorityRequest{
    return true;
}

-(void)process{
#if TARGET_IPHONE_SIMULATOR
    NSString * fn = [NSString stringWithFormat:@"garmin_sso_stage_%d.html", (int)self.ssoStage];
    NSError * e = nil;
    [self.theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:self.encoding error:&e];
#endif

    if (self.ssoStage == gcSSOGetServiceTicket){

        NSString * prefix = @"https://connect.garmin.com/modern/?ticket=";

        NSMutableArray<NSString*> * tries =[NSMutableArray arrayWithObject:prefix];

        [tries addObject:[prefix stringByReplacingOccurrencesOfString:@"/" withString:@"\\/"]];

        self.serviceTicket = nil;
        for( NSString * try in tries){
            NSRange range = [self.theString rangeOfString:try];
            if (range.location != NSNotFound) {
                NSString * valuestr = [self.theString substringFromIndex:range.location+range.length];
                range = [valuestr rangeOfString:@"\""];
                if (range.location != NSNotFound) {
                    valuestr = [valuestr substringToIndex:range.location];
                    self.serviceTicket = valuestr;
                }
            }
        }
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
        rv = [GCGarminLoginSSORequest requestWithUser:self.uname andPwd:self.pwd];
        rv.serviceTicket = self.serviceTicket;
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
