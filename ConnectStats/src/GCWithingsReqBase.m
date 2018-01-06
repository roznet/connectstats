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


@end

@implementation GCWithingsReqBase

-(GCWithingsReqBase*)init{
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
    [_userId release];
    [_navigationController release];

    [super dealloc];
}

-(void)checkToken{
    self.oauthToken = [[GCAppGlobal profile] configGetString:CONFIG_WITHINGS_TOKEN defaultValue:@""];
    self.oauthTokenSecret = [[GCAppGlobal profile] configGetString:CONFIG_WITHINGS_TOKENSECRET defaultValue:@""];
    self.userId = [[GCAppGlobal profile] configGetString:CONFIG_WITHINGS_USERID defaultValue:@""];
    if ((self.oauthTokenSecret).length==0) {
        self.oauthTokenSecret = nil;
        self.oauthToken = nil;
        self.userId = nil;
    }
}

-(BOOL)isSignedIn{
    return self.oauthToken != nil;
}


-(void)signInToWithings{
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

        self.oauth1Controller = [[[OAuth1WithingsController alloc] init] autorelease];
        [self.oauth1Controller loginWithWebView:webView completion:^(NSDictionary *oauthTokens, NSError *error) {
            if (error != nil) {
                RZLog(RZLogError, @"Withings identification error %@", error);
                self.status = GCWebStatusLoginFailed;
                [[GCAppGlobal profile] serviceSuccess:gcServiceWithings set:NO];
                [self processDone];
            } else {
                self.oauthToken = oauthTokens[@"oauth_token"];
                self.oauthTokenSecret = oauthTokens[@"oauth_token_secret"];
                self.userId = oauthTokens[@"userid"];
                [[GCAppGlobal profile] configSet:CONFIG_WITHINGS_TOKENSECRET stringVal:self.oauthTokenSecret];
                [[GCAppGlobal profile] configSet:CONFIG_WITHINGS_TOKEN stringVal:self.oauthToken];
                [[GCAppGlobal profile] configSet:CONFIG_WITHINGS_USERID stringVal:self.userId];//188427
                [[GCAppGlobal profile] serviceSuccess:gcServiceWithings set:YES];
                [GCAppGlobal saveSettings];
                [self processDone];
            }

            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}

+(void)signout{

    [[GCAppGlobal profile] configSet:CONFIG_WITHINGS_TOKEN  stringVal:@""];
    [[GCAppGlobal profile] configSet:CONFIG_WITHINGS_TOKENSECRET stringVal:@""];
    [[GCAppGlobal profile] configSet:CONFIG_WITHINGS_USERID stringVal:@""];
    [[GCAppGlobal profile] serviceSuccess:gcServiceWithings set:NO];
}

-(NSURLRequest*)preparedUrlRequest:(NSString*)path params:(NSDictionary*)parameters{
    NSURLRequest *preparedRequest = [OAuth1WithingsController preparedRequestForPath:path
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
