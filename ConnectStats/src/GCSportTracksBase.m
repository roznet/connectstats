//  MIT Licence
//
//  Created on 22/03/2014.
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

#import "GCSportTracksBase.h"
@import RZExternal;
#import "GCAppGlobal.h"

//http://www.sporttracks.mobi/api/doc

@class GTMOAuth2Authentication;
static NSString *kClientID = @"connectstats";
static NSString *kClientSecret = @"WSQKEBQXJ2VAH5MT";
static NSString *const kKeychainItemName = @"OAuth2 ConnectStats SportTracks";

@implementation GCSportTracksBase
-(void)dealloc{
    [_sportTracksAuth release];
    [_navigationController release];

    [super dealloc];
}

+(NSString*)keyChainName{
    return [kKeychainItemName stringByAppendingString:[[GCAppGlobal profile] currentProfileName]];
}

- (GTMOAuth2Authentication *)buildSportTracksAuth {
    if (!self.sportTracksAuth) {
        NSURL *tokenURL = [NSURL URLWithString:@"https://sporttracks.mobi/oauth2/token"];
        NSString *redirectURI = @"https://www.ro-z.net/connectstats/sporttracks_oauth_redirect";

        GTMOAuth2Authentication *auth;
        auth = [GTMOAuth2Authentication authenticationWithServiceProvider:@"SportTracks Service"
                                                                 tokenURL:tokenURL
                                                              redirectURI:redirectURI
                                                                 clientID:kClientID
                                                             clientSecret:kClientSecret];
        self.sportTracksAuth = auth;
    }

    return self.sportTracksAuth;
}

-(RemoteDownloadPrepareUrl)prepareUrlFunc{
    return Block_copy(^(NSMutableURLRequest*req){
        [req setValue:[NSString stringWithFormat:@"Bearer %@", self.oauth2Authentication.accessToken] forHTTPHeaderField:@"Authorization"];
    });
}
+(void)signout{
    [[GCAppGlobal profile] serviceSuccess:gcServiceSportTracks set:NO];
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:[GCSportTracksBase keyChainName] ];
}

-(void)signInToSportTracks{
    GTMOAuth2Authentication *auth = [self buildSportTracksAuth];
    NSError * error = nil;
    NSString * keyChainName =[GCSportTracksBase keyChainName];
    BOOL didAuth = [GTMOAuth2ViewControllerTouch authorizeFromKeychainForName:keyChainName
                                                               authentication:auth error:&error];
    if (!didAuth && error) {
        RZLog(RZLogError, @"Failed to call oauth2 %@", error.localizedDescription);
    }
    if (didAuth && auth.canAuthorize) {
        if (auth.accessToken==nil) {
            NSMutableURLRequest * req=[[NSMutableURLRequest alloc] init];
            [auth authorizeRequest:req completionHandler:^(NSError*err){
                if (err) {
                    self.status = GCWebStatusLoginFailed;
                    RZLog(RZLogError, @"failed to authorize %@", err);
                }else{
                    [[GCAppGlobal profile] serviceSuccess:gcServiceSportTracks set:YES];
                }
                [self processDone];

            }];
        }else{
            [[GCAppGlobal profile] serviceSuccess:gcServiceSportTracks set:YES];
            [self processDone];
        }
    }else{

        NSURL *authURL = [NSURL URLWithString:@"https://sporttracks.mobi/oauth2/authorize"];

        // Display the authentication view
        GTMOAuth2ViewControllerTouch *viewController;
        viewController = [[[GTMOAuth2ViewControllerTouch alloc] initWithAuthentication:auth
                                                                      authorizationURL:authURL
                                                                      keychainItemName:keyChainName
                                                                              delegate:self
                                                                      finishedSelector:@selector(viewController:finishedWithAuth:error:)] autorelease];
        GTMOAuth2SignIn *signin = viewController.signIn;
        signin.additionalAuthorizationParameters = @{@"state":@"start"};

        // Now push our sign-in view
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
    if (error != nil) {
        RZLog(RZLogError, @"sport tracks identification error %@", error);
        self.status = GCWebStatusLoginFailed;
        [[GCAppGlobal profile] serviceSuccess:gcServiceSportTracks set:NO];
        [self processDone];
    } else {
        [[GCAppGlobal profile] serviceSuccess:gcServiceSportTracks set:YES];
        [self processDone];
    }
}

-(GTMOAuth2Authentication*)oauth2Authentication{
    return self.sportTracksAuth;
}

-(gcWebService)service{
    return gcWebServiceSportTracks;
}

@end
