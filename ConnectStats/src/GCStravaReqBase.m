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
#import "GCService.h"

@import RZExternal;

static NSString * kCredentialServiceName = @"strava";


@interface GCStravaReqBase ()
@property (nonatomic,retain) GTMOAuth2Authentication * stravaAuth;
@end

@implementation GCStravaReqBase


-(GCStravaReqBase*)init{
    if( self = [super init] ){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyCallBack:) name:kGTMOAuth2AccessTokenRefreshed object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyCallBack:) name:kGTMOAuth2AccessTokenRefreshFailed object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyCallBack:) name:kGTMOAuth2RefreshTokenChanged object:nil];
    }
    return self;
}

-(GCStravaReqBase*)initNextWith:(GCStravaReqBase*)current{
    if( self = [super init]){
        self.stravaAuth = current.stravaAuth;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyCallBack:) name:kGTMOAuth2AccessTokenRefreshed object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyCallBack:) name:kGTMOAuth2AccessTokenRefreshFailed object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyCallBack:) name:kGTMOAuth2RefreshTokenChanged object:nil];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_stravaAuth release];
    [_lastError release];
    [_navigationController release];

    [super dealloc];
}

-(void)notifyCallBack:(NSNotification*)notification{
    //[@"kGTMOAuth2" length] = 10
    NSString * name = [notification.name substringFromIndex:10];
    
    if( [notification.name isEqualToString:kGTMOAuth2AccessTokenRefreshFailed]){
        RZLog(RZLogError, @"%@ %@", name, notification.userInfo);
        [GCStravaReqBase signout];
        self.status = GCWebStatusAccessDenied;
    }
}

static NSString *const kKeychainItemName = @"OAuth2 ConnectStats Strava";

- (GTMOAuth2Authentication *)buildStravaAuth {
    if (!self.stravaAuth) {
        NSURL *tokenURL = [NSURL URLWithString:[GCAppGlobal credentialsForService:kCredentialServiceName andKey:@"access_token_url"]];
        NSString *redirectURI = [GCAppGlobal credentialsForService:kCredentialServiceName andKey:@"redirect_url"];

        GTMOAuth2Authentication *auth;
        auth = [GTMOAuth2Authentication authenticationWithServiceProvider:@"Strava Service"
                                                                 tokenURL:tokenURL
                                                              redirectURI:redirectURI
                                                                 clientID:[GCAppGlobal credentialsForService:kCredentialServiceName andKey:@"client_id"]
                                                             clientSecret:[GCAppGlobal credentialsForService:kCredentialServiceName andKey:@"client_secret"]];
        auth.scope = @"activity:read_all,read_all";
        self.stravaAuth = auth;
    }

    return self.stravaAuth;
    ;
}

+(void)signout{
    [[GCAppGlobal profile] serviceSuccess:gcServiceStrava set:NO];
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:[kKeychainItemName stringByAppendingString:[[GCAppGlobal profile] currentLoginNameForService:gcServiceGarmin]]];
    [GCAppGlobal saveSettings];
}

-(void)signInToStrava{
    GTMOAuth2Authentication *auth = [self buildStravaAuth];
    NSError * error = nil;
    NSString * keyChainName = [kKeychainItemName stringByAppendingString:[[GCAppGlobal profile] currentLoginNameForService:gcServiceGarmin]];
    BOOL didAuth = [GTMOAuth2ViewControllerTouch authorizeFromKeychainForName:keyChainName
                                                               authentication:auth error:&error];

    if (!didAuth || !auth.canAuthorize) {
        NSURL *authURL = [NSURL URLWithString:[GCAppGlobal credentialsForService:kCredentialServiceName andKey:@"authenticate_url"]];
        
        GTMOAuth2ViewControllerTouch *viewController;
        viewController = [[[GTMOAuth2ViewControllerTouch alloc] initWithAuthentication:auth
                                                                      authorizationURL:authURL
                                                                      keychainItemName:keyChainName
                                                                              delegate:self
                                                                      finishedSelector:@selector(viewController:finishedWithAuth:error:)] autorelease];

        [self.navigationController pushViewController:viewController animated:YES];
    }else{
        [self processDone];
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
        [GCAppGlobal saveSettings];
        [self processDone];
    } else {
        // first success
        if( [[GCAppGlobal profile] serviceEnabled:(gcService)gcServiceStrava] == NO){
            [[GCAppGlobal profile] serviceSuccess:gcServiceStrava set:YES];
            [GCAppGlobal saveSettings];
        }
        [self processDone];
    }
}

-(void)authorizeRequest:(NSMutableURLRequest *)request completionHandler:(void (^)(NSError * _Nullable))handler{
    
    [self.stravaAuth authorizeRequest:request completionHandler:^(NSError*error){
        if( error == nil){
            [[GCAppGlobal profile] serviceSuccess:gcServiceStrava set:YES];
        }else{
            [[GCAppGlobal profile] serviceSuccess:gcServiceStrava set:NO];
            self.lastError = error;
            self.status = GCWebStatusLoginFailed;
            RZLog(RZLogError,@"Failed to connect %@", error);
        }
        handler(error);
    }];
}

-(gcWebService)service{
    return gcWebServiceStrava;
}

+(NSDate*)lastSync:(NSString*)aId{
    return [[GCService service:gcServiceStrava] lastSync:aId];
}

@end
