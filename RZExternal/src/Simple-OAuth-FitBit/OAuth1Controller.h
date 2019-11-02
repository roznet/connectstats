//
//  OAuth1Controller.h
//  Simple-OAuth1
//
//  Created by Christian Hansen on 02/12/12.
//  Copyright (c) 2012 Christian-Hansen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@import WebKit;

typedef void (^WebWiewDelegateHandler)(NSDictionary *oauthParams);

extern NSArray * CHQueryStringPairsFromDictionary(NSDictionary *dictionary);
extern NSArray * CHQueryStringPairsFromKeyAndValue(NSString *key, id value);
extern NSString * CHQueryStringFromParametersWithEncoding(NSDictionary *parameters, NSStringEncoding stringEncoding);
extern NSArray * CHQueryStringPairsFromDictionary(NSDictionary *dictionary);
extern NSArray * CHQueryStringPairsFromKeyAndValue(NSString *key, id value);
extern NSDictionary *CHParametersFromQueryString(NSString *queryString);

@interface OAuth1Controller : NSObject <WKNavigationDelegate>
@property (nonatomic, weak) WKWebView *webView;
@property (nonatomic, strong) WebWiewDelegateHandler delegateHandler;

+(NSDictionary*)serviceParametersFromJson:(NSData*)jsonData forServiceName:(NSString*)serviceName;

-(instancetype)initWithServiceParameters:(NSDictionary*)serviceParameters;

- (void)loginWithWebView:(WKWebView *)webWiew
              completion:(void (^)(NSDictionary *oauthTokens, NSError *error))completion;

- (void)requestAccessToken:(NSString *)oauth_token_secret
                oauthToken:(NSString *)oauth_token
             oauthVerifier:(NSString *)oauth_verifier
                completion:(void (^)(NSError *error, NSDictionary *responseParams))completion;

- (NSURLRequest *)preparedRequestForPath:(NSString *)url
                              parameters:(NSDictionary *)parameters
                              HTTPmethod:(NSString *)method
                              oauthToken:(NSString *)oauth_token
                             oauthSecret:(NSString *)oauth_token_secret;

@end
