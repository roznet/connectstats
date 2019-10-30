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

#import "GCWithingsReqBase.h"
@import RZUtils;
@import RZExternal;
#import "GCAppGlobal.h"

@interface GCWithingsReqBase ()
@property (nonatomic,retain) NSString * oauthTokenSecret;
@property (nonatomic,retain) NSString * oauthToken;
@property (nonatomic,retain) GTMOAuth2Authentication * withingsAuth;

//@property (nonatomic,retain) UIWebView * webView;

@property (nonatomic,retain) NSError * lastError;

@end


static NSString * kKeychainWithingsItemName = @"OAuth2 ConnectStats Withings ";
static NSString * kCredentialServiceName = @"withings_oauth2";


@implementation GCWithingsReqBase

-(GCWithingsReqBase*)initNextWith:(GCWithingsReqBase*)next{
    if( self = [super init]){
        self.withingsAuth = next.withingsAuth;
        self.navigationController = nil;
    }
    return self;
}
-(GCWithingsReqBase*)init{
    self = [super init];
    return self;
}

-(void)dealloc{
    [_withingsAuth release];
    [_oauthToken release];
    [_oauthTokenSecret release];
    [_userId release];
    [_navigationController release];
    [_lastError release];
    
    [super dealloc];
}
- (GTMOAuth2Authentication *)buildWithingsAuth {
    if (!self.withingsAuth) {
        NSURL *tokenURL = [NSURL URLWithString:[GCAppGlobal credentialsForService:kCredentialServiceName andKey:@"access_token_url"]];
        NSString *redirectURI = [GCAppGlobal credentialsForService:kCredentialServiceName andKey:@"redirect_url"];
        
        GTMOAuth2Authentication *auth;
        auth = [GTMOAuth2Authentication authenticationWithServiceProvider:@"Withings Service"
                                                                 tokenURL:tokenURL
                                                              redirectURI:redirectURI
                                                                 clientID:[GCAppGlobal credentialsForService:kCredentialServiceName andKey:@"client_id"]
                                                             clientSecret:[GCAppGlobal credentialsForService:kCredentialServiceName andKey:@"client_secret"]];

        //auth.additionalTokenRequestParameters = @{@"state":@"connectstats"};

        self.withingsAuth = auth;
    }
    
    return self.withingsAuth;
    ;
}

-(BOOL)isSignedIn{
    return self.withingsAuth != nil;
}
+(NSString*)currentKeyChainName{
    NSString * keyChainName = [kKeychainWithingsItemName stringByAppendingString:[[GCAppGlobal profile] currentProfileName]];
    return keyChainName;
}

-(void)signInToWithings{
    GTMOAuth2Authentication *auth = [self buildWithingsAuth];
    NSError * error = nil;
    BOOL didAuth = [GTMOAuth2ViewControllerTouch authorizeFromKeychainForName:[GCWithingsReqBase currentKeyChainName]
                                                               authentication:auth
                                                                        error:&error];
    if (!didAuth || !auth.canAuthorize) {
        // Specify the appropriate scope string, if any, according to the service's API documentation
        auth.scope = @"user.metrics,user.info,user.activity";
        
        NSURL *authURL = [NSURL URLWithString:[GCAppGlobal credentialsForService:kCredentialServiceName andKey:@"authenticate_url"]];
        
        // Display the authentication view
        GTMOAuth2ViewControllerTouch *viewController;
        viewController = [[[GTMOAuth2ViewControllerTouch alloc] initWithAuthentication:auth
                                                                      authorizationURL:authURL
                                                                      keychainItemName:[GCWithingsReqBase currentKeyChainName]
                                                                              delegate:self
                                                                      finishedSelector:@selector(viewController:finishedWithAuth:error:)] autorelease];
        viewController.signIn.additionalAuthorizationParameters = @{@"state":@"connectstats"};
        // Now push our sign-in view
        [self.navigationController pushViewController:viewController animated:YES];
    }else{
        [self processDone];
    }
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
    if (error != nil) {
        RZLog(RZLogError, @"Withings connection error %@", error);
        self.status = GCWebStatusConnectionError;
        self.lastError = error;
        [[GCAppGlobal profile] serviceSuccess:gcServiceWithings set:NO];
        [self processDone];
    } else {
        RZLog(RZLogInfo, @"finished with auth");
        [[GCAppGlobal profile] serviceSuccess:gcServiceWithings set:YES];
        [self processDone];
    }
}

-(void)authorizeRequest:(NSMutableURLRequest *)request completionHandler:(void (^)(NSError * _Nullable))handler{
    [self.withingsAuth authorizeRequest:request completionHandler:^(NSError*error){
        if( error == nil){
            [[GCAppGlobal profile] serviceSuccess:gcServiceWithings set:YES];
        }else{
            [GCWithingsReqBase signout];
        }
        handler(error);
    }];
}

+(void)signout{
    RZLog(RZLogInfo, @"Withings signout keychain: %@", self.currentKeyChainName);
    
    [[GCAppGlobal profile] serviceSuccess:gcServiceWithings set:NO];
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:self.currentKeyChainName];

}

-(gcWebService)service{
    return gcWebServiceWithings;
}


@end
