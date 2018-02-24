//  MIT Licence
//
//  Created on 13/03/2014.
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

#import "GCStravaReqBase.h"
#import "GCAppGlobal.h"
@import RZExternal;

@implementation GCStravaReqBase

-(void)dealloc{
    [_stravaAuth release];
    [_lastError release];
    [_navigationController release];

    [super dealloc];
}


NSString *kClientID = @"82";
NSString *kClientSecret = @"a1fc467908cffad6a512877d0cc937eaaeba8027";
static NSString *const kKeychainItemName = @"OAuth2 ConnectStats Strava";

- (GTMOAuth2Authentication *)buildStravaAuth {
    if (!self.stravaAuth) {
        NSURL *tokenURL = [NSURL URLWithString:@"https://www.strava.com/oauth/token"];
        NSString *redirectURI = @"http://www.ro-z.net/connectstats/oauth";

        GTMOAuth2Authentication *auth;
        auth = [GTMOAuth2Authentication authenticationWithServiceProvider:@"Strava Service"
                                                                 tokenURL:tokenURL
                                                              redirectURI:redirectURI
                                                                 clientID:kClientID
                                                             clientSecret:kClientSecret];
        self.stravaAuth = auth;
    }

    return self.stravaAuth;
    ;
}

+(void)signout{
    [[GCAppGlobal profile] serviceSuccess:gcServiceStrava set:NO];
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:[kKeychainItemName stringByAppendingString:[[GCAppGlobal profile] currentLoginNameForService:gcServiceGarmin]]];
}

-(void)signInToStrava{
    GTMOAuth2Authentication *auth = [self buildStravaAuth];
    NSError * error = nil;
    NSString * keyChainName = [kKeychainItemName stringByAppendingString:[[GCAppGlobal profile] currentLoginNameForService:gcServiceGarmin]];
    BOOL didAuth = [GTMOAuth2ViewControllerTouch authorizeFromKeychainForName:keyChainName
                                                               authentication:auth error:&error];

    if (!didAuth && error) {
        RZLog(RZLogError, @"Failed to initiate oauth2 %@", error.localizedDescription);
    }
    if (didAuth && auth.canAuthorize) {
        [[GCAppGlobal profile] serviceSuccess:gcServiceStrava set:YES];
        [self processDone];
    }else{
        // Specify the appropriate scope string, if any, according to the service's API documentation
        auth.scope = @"view_private,write";

        NSURL *authURL = [NSURL URLWithString:@"https://www.strava.com/oauth/authorize"];

        // Display the authentication view
        GTMOAuth2ViewControllerTouch *viewController;
        viewController = [[[GTMOAuth2ViewControllerTouch alloc] initWithAuthentication:auth
                                                                      authorizationURL:authURL
                                                                      keychainItemName:keyChainName
                                                                              delegate:self
                                                                      finishedSelector:@selector(viewController:finishedWithAuth:error:)] autorelease];

        // Now push our sign-in view
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
    if (error != nil) {
        RZLog(RZLogError, @"strava connection error %@", error);
        self.status = GCWebStatusConnectionError;
        self.lastError = error;
        [[GCAppGlobal profile] serviceSuccess:gcServiceStrava set:NO];
        [self processDone];
    } else {
        [[GCAppGlobal profile] serviceSuccess:gcServiceStrava set:YES];
        [self processDone];
    }
}

-(gcWebService)service{
    return gcWebServiceStrava;
}

@end
