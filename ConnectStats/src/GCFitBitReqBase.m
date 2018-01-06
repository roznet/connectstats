//  MIT Licence
//
//  Created on 28/08/2014.
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

#import "GCFitBitReqBase.h"
#import "GCAppGlobal.h"
#import <RZExternal/RZExternal.h>

@interface GCFitBitReqBase ()
@property (nonatomic,retain) NSString * oauthTokenSecret;
@property (nonatomic,retain) NSString * oauthToken;
@property (nonatomic,retain) OAuth1Controller * oauth1Controller;
@property (nonatomic,retain) UIWebView * webView;
@end

@implementation GCFitBitReqBase

-(GCFitBitReqBase*)init{
    self = [super init];
    if (self) {
        [self checkToken];
    }
    return self;
}

-(void)dealloc{
    self.webView.delegate = nil;
    [_webView release];
    [_oauth1Controller release];
    [_oauthToken release];
    [_oauthTokenSecret release];
    [_navigationController release];

    [super dealloc];
}

-(void)checkToken{
    self.oauthToken = [[GCAppGlobal profile] configGetString:CONFIG_FITBIT_TOKEN defaultValue:@""];
    self.oauthTokenSecret = [[GCAppGlobal profile] configGetString:CONFIG_FITBIT_TOKENSECRET defaultValue:@""];
    if ((self.oauthTokenSecret).length==0) {
        self.oauthTokenSecret = nil;
        self.oauthToken = nil;
    }
}

-(BOOL)isSignedIn{
    return self.oauthToken != nil;
}
-(void)signInToFitBit{
    if (self.oauthToken) {
        [self processDone];

    }else{

        UIViewController * webCont = [[UIViewController alloc] initWithNibName:nil bundle:nil];
        UIWebView * webView = [[UIWebView alloc] initWithFrame:self.navigationController.view.frame];
        // keep hold so we can clear the delegate.
        self.webView = webView;
        webCont.view = webView;
        [self.navigationController pushViewController:webCont animated:YES];
        [webCont release];
        [webView release];

        self.oauth1Controller = [[[OAuth1Controller alloc] init] autorelease];
        [self.oauth1Controller loginWithWebView:webView completion:^(NSDictionary *oauthTokens, NSError *error) {
            if (error != nil) {
                RZLog(RZLogError, @"FitBit identification error %@", error);
                self.status = GCWebStatusLoginFailed;
                [[GCAppGlobal profile] serviceSuccess:gcServiceFitBit set:NO];
                [self processDone];
            } else {
                self.oauthToken = oauthTokens[@"oauth_token"];
                self.oauthTokenSecret = oauthTokens[@"oauth_token_secret"];
                [[GCAppGlobal profile] configSet:CONFIG_FITBIT_TOKENSECRET stringVal:self.oauthTokenSecret];
                [[GCAppGlobal profile] configSet:CONFIG_FITBIT_TOKEN stringVal:self.oauthToken];
                [[GCAppGlobal profile] serviceSuccess:gcServiceFitBit set:YES];
                [GCAppGlobal saveSettings];

                [self processDone];
            }

            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}

+(void)signout{
    /*
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *each in cookieStorage.cookies) {
        [cookieStorage deleteCookie:each];
    }
     */

    [[GCAppGlobal profile] configSet:CONFIG_FITBIT_TOKEN  stringVal:@""];
    [[GCAppGlobal profile] configSet:CONFIG_FITBIT_TOKENSECRET stringVal:@""];
    [[GCAppGlobal profile] serviceSuccess:gcServiceFitBit set:NO];
}

-(NSURLRequest*)preparedUrlRequest:(NSString*)path params:(NSDictionary*)parameters{
    NSURLRequest *preparedRequest = [OAuth1Controller preparedRequestForPath:path
                                                                  parameters:parameters
                                                                  HTTPmethod:@"GET"
                                                                  oauthToken:self.oauthToken
                                                                 oauthSecret:self.oauthTokenSecret];
    return preparedRequest;
}

-(gcWebService)service{
    return gcWebServiceFitbit;
}


@end
