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
@import RZExternal;
#import "GCAppGlobal.h"

@interface GCWithingsReqBase ()
@property (nonatomic,retain) NSString * oauthTokenSecret;
@property (nonatomic,retain) NSString * oauthToken;

@property (nonatomic,retain) OAuth1WithingsController * oauth1Controller;

@property (nonatomic,retain) UIWebView * webView;

@property (nonatomic,retain) NSError * lastError;


@end


static NSString *kClientID = @"a7523288be94b6d823003d7c30b607de4aae7603726761aca50b74d1c3e80281";
static NSString *kClientSecret = @"b89c0e3f7bb40ec54f45c54ecf516209ab346b8ae2b1f3a3ecb7ae3d4395fcc2";
static NSString * kKeychainItemName = @"OAuth2 ConnectStats Withings";
static NSString * kRedirectCallback = @"https://ro-z.net/connectstats/oauth";


@implementation GCWithingsReqBase

-(GCWithingsReqBase*)init{
    self = [super init];
    return self;
}

-(void)dealloc{
    self.webView.delegate = nil;
    [_webView release];
    [_oauth1Controller release];
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
        NSURL *tokenURL = [NSURL URLWithString:@"https://account.withings.com/oauth2/token"];
        NSString *redirectURI = kRedirectCallback;
        
        GTMOAuth2Authentication *auth;
        auth = [GTMOAuth2Authentication authenticationWithServiceProvider:@"Withings Service"
                                                                 tokenURL:tokenURL
                                                              redirectURI:redirectURI
                                                                 clientID:kClientID
                                                             clientSecret:kClientSecret];
        //auth.additionalTokenRequestParameters = @{@"state":@"connectstats"};

        self.withingsAuth = auth;
    }
    
    return self.withingsAuth;
    ;
}

-(BOOL)isSignedIn{
    return self.withingsAuth != nil;
}

-(void)signInToWithings{
    GTMOAuth2Authentication *auth = [self buildWithingsAuth];
    NSError * error = nil;
    NSString * keyChainName = [kKeychainItemName stringByAppendingString:[[GCAppGlobal profile] currentLoginNameForService:gcServiceGarmin]];
    BOOL didAuth = [GTMOAuth2ViewControllerTouch authorizeFromKeychainForName:keyChainName
                                                               authentication:auth error:&error];
    
    if (!didAuth && error) {
        RZLog(RZLogError, @"Failed to initiate oauth2 %@", error.localizedDescription);
    }
    if (didAuth && auth.canAuthorize) {
        [auth authorizeRequest:nil completionHandler:^(NSError*error){
            [[GCAppGlobal profile] serviceSuccess:gcServiceWithings set:YES];
            [self processDone];
        }];
    }else{
        // Specify the appropriate scope string, if any, according to the service's API documentation
        auth.scope = @"user.metrics,user.info,user.activity";
        
        NSURL *authURL = [NSURL URLWithString:@"https://account.withings.com/oauth2_user/authorize2"];
        
        // Display the authentication view
        GTMOAuth2ViewControllerTouch *viewController;
        viewController = [[[GTMOAuth2ViewControllerTouch alloc] initWithAuthentication:auth
                                                                      authorizationURL:authURL
                                                                      keychainItemName:keyChainName
                                                                              delegate:self
                                                                      finishedSelector:@selector(viewController:finishedWithAuth:error:)] autorelease];
        viewController.signIn.additionalAuthorizationParameters = @{@"state":@"connectstats"};
        // Now push our sign-in view
        [self.navigationController pushViewController:viewController animated:YES];
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
        [[GCAppGlobal profile] serviceSuccess:gcServiceWithings set:YES];
        [self processDone];
    }
}


+(void)signout{

}

-(NSURLRequest*)preparedUrlRequest:(NSString*)path params:(NSDictionary*)parameters{
    NSURLRequest *preparedRequest = [self.oauth1Controller preparedRequestForPath:path
                                                                  parameters:parameters
                                                                  HTTPmethod:@"GET"
                                                                  oauthToken:self.oauthToken
                                                                 oauthSecret:self.oauthTokenSecret];
    return preparedRequest;
}

-(gcWebService)service{
    return gcWebServiceWithings;
}


@end
