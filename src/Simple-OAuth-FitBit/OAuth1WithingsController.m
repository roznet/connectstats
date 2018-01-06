//
//  OAuth1WithingsController.m
//  GarminConnect
//
//  Created by Brice Rosenzweig on 05/10/2014.
//  Copyright (c) 2014 Brice Rosenzweig. All rights reserved.
//

#import "OAuth1WithingsController.h"
#import "NSString+URLEncoding.h"
#include "hmac.h"
#include "Base64Transcoder.h"
// Withings:
// Your OAuth key is :e555eef15ef1526431f5bd6c721e8023c7d0d84dcb8461cc67d83f45870
// Your OAuth secret is :1cd7f11c1e6d48e040ec58cf58fee1f1d30492ddc70c46f60c7575978dd


#define OAUTH_CALLBACK       @"http://www.ro-z.net/connectstats"
#define CONSUMER_KEY         @"8163df47b598c89f685c3b8e364632debf35b4f2190fdbd8d58b4c3f5e8d0"
#define CONSUMER_SECRET      @"d5585ec4633b85c2e40ee172c0e011be5f0f8752b4fe0216e98eec4434"
#define AUTH_URL             @"https://oauth.withings.com/"
#define REQUEST_TOKEN_URL    @"account/request_token"
#define AUTHENTICATE_URL     @"account/authorize"
#define ACCESS_TOKEN_URL     @"account/access_token"
#define API_URL              @"https://wbsapi.withings.net/"
#define OAUTH_SCOPE_PARAM    @""

#define REQUEST_TOKEN_METHOD @"GET"
#define ACCESS_TOKEN_METHOD  @"GET"


@implementation OAuth1WithingsController

#pragma mark - Step 1 Obtaining a request token
- (void)obtainRequestTokenWithCompletion:(void (^)(NSError *error, NSDictionary *responseParams))completion
{
    NSString *request_url = [AUTH_URL stringByAppendingString:REQUEST_TOKEN_URL];
    NSString *oauth_consumer_secret = CONSUMER_SECRET;
    
    NSMutableDictionary *allParameters = [self.class standardOauthParameters];
    if ([OAUTH_SCOPE_PARAM length] > 0) [allParameters setValue:OAUTH_SCOPE_PARAM forKey:@"scope"];
    
    NSString *parametersString = CHQueryStringFromParametersWithEncoding(allParameters, NSUTF8StringEncoding);
    
    NSString *baseString = [REQUEST_TOKEN_METHOD stringByAppendingFormat:@"&%@&%@", request_url.utf8AndURLEncode, parametersString.utf8AndURLEncode];
    NSString *secretString = [oauth_consumer_secret.utf8AndURLEncode stringByAppendingString:@"&"];
    NSString *oauth_signature = [self.class signClearText:baseString withSecret:secretString];
    [allParameters setValue:oauth_signature forKey:@"oauth_signature"];
    
    parametersString = CHQueryStringFromParametersWithEncoding(allParameters, NSUTF8StringEncoding);
    
    request_url = [request_url stringByAppendingFormat:@"?%@", parametersString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:request_url]];
    request.HTTPMethod = REQUEST_TOKEN_METHOD;
    
    /*
    NSMutableArray *parameterPairs = [NSMutableArray array];
    for (NSString *name in allParameters) {
        NSString *aPair = [name stringByAppendingFormat:@"=\"%@\"", [allParameters[name] utf8AndURLEncode]];
        [parameterPairs addObject:aPair];
    }
    NSString *oAuthHeader = [@"OAuth " stringByAppendingFormat:@"%@", [parameterPairs componentsJoinedByString:@", "]];
    [request setValue:oAuthHeader forHTTPHeaderField:@"Authorization"];
    */
    
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData*data,NSURLResponse*response,NSError*error){
        NSString *reponseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        completion(nil, CHParametersFromQueryString(reponseString));
    }] resume];
     
    
}

#pragma mark - Step 2 Show login to the user to authorize our app
- (void)authenticateToken:(NSString *)oauthToken withCompletion:(void (^)(NSError *error, NSDictionary *responseParams))completion
{
    NSString *oauth_callback = OAUTH_CALLBACK;
    NSString *authenticate_url = [AUTH_URL stringByAppendingString:AUTHENTICATE_URL];
    authenticate_url = [authenticate_url stringByAppendingFormat:@"?oauth_token=%@", oauthToken];
    authenticate_url = [authenticate_url stringByAppendingFormat:@"&oauth_callback=%@", oauth_callback.utf8AndURLEncode];
    authenticate_url = [authenticate_url stringByAppendingFormat:@"&display=touch"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:authenticate_url]];
    [request setValue:[NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)", [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleExecutableKey] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey], (__bridge id)CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(), kCFBundleVersionKey) ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? [[UIScreen mainScreen] scale] : 1.0f)] forHTTPHeaderField:@"User-Agent"];
    
    self.delegateHandler = ^(NSDictionary *oauthParams) {
        if (oauthParams[@"oauth_verifier"] == nil) {
            NSError *authenticateError = [NSError errorWithDomain:@"com.ideaflasher.oauth.authenticate" code:0 userInfo:@{@"userInfo" : @"oauth_verifier not received and/or user denied access"}];
            completion(authenticateError, oauthParams);
        } else {
            completion(nil, oauthParams);
        }
    };
    [self.webView performSelectorOnMainThread:@selector(loadRequest:) withObject:request waitUntilDone:NO];
    //[self.webView loadRequest:request];
}

#pragma mark - Step 3 Request access token now that user has authorized the app
- (void)requestAccessToken:(NSString *)oauth_token_secret
                oauthToken:(NSString *)oauth_token
             oauthVerifier:(NSString *)oauth_verifier
                completion:(void (^)(NSError *error, NSDictionary *responseParams))completion
{
    NSString *access_url = [AUTH_URL stringByAppendingString:ACCESS_TOKEN_URL];
    NSString *oauth_consumer_secret = CONSUMER_SECRET;
    
    NSMutableDictionary *allParameters = [self.class standardOauthParameters];
    [allParameters setValue:oauth_verifier forKey:@"oauth_verifier"];
    [allParameters setValue:oauth_token    forKey:@"oauth_token"];
    
    NSString *parametersString = CHQueryStringFromParametersWithEncoding(allParameters, NSUTF8StringEncoding);
    
    NSString *baseString = [ACCESS_TOKEN_METHOD stringByAppendingFormat:@"&%@&%@", access_url.utf8AndURLEncode, parametersString.utf8AndURLEncode];
    NSString *secretString = [oauth_consumer_secret.utf8AndURLEncode stringByAppendingFormat:@"&%@", oauth_token_secret.utf8AndURLEncode];
    NSString *oauth_signature = [self.class signClearText:baseString withSecret:secretString];
    [allParameters setValue:oauth_signature forKey:@"oauth_signature"];
    
    CHQueryStringFromParametersWithEncoding(allParameters, NSUTF8StringEncoding);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:access_url]];
    request.HTTPMethod = ACCESS_TOKEN_METHOD;
    
    NSMutableArray *parameterPairs = [NSMutableArray array];
    for (NSString *name in allParameters)
    {
        NSString *aPair = [name stringByAppendingFormat:@"=\"%@\"", [allParameters[name] utf8AndURLEncode]];
        [parameterPairs addObject:aPair];
    }
    NSString *oAuthHeader = [@"OAuth " stringByAppendingFormat:@"%@", [parameterPairs componentsJoinedByString:@", "]];
    [request setValue:oAuthHeader forHTTPHeaderField:@"Authorization"];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData*data,NSURLResponse*response,NSError*error){
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        completion(nil, CHParametersFromQueryString(responseString));
    }] resume];
}


+ (NSMutableDictionary *)standardOauthParameters
{
    NSString *oauth_timestamp = [NSString stringWithFormat:@"%i", (int)[NSDate.date timeIntervalSince1970]];
    NSString *oauth_nonce = [NSString getNonce];
    NSString *oauth_consumer_key = CONSUMER_KEY;
    NSString *oauth_signature_method = @"HMAC-SHA1";
    NSString *oauth_version = @"1.0";
    
    NSMutableDictionary *standardParameters = [NSMutableDictionary dictionary];
    [standardParameters setValue:oauth_consumer_key     forKey:@"oauth_consumer_key"];
    [standardParameters setValue:oauth_nonce            forKey:@"oauth_nonce"];
    [standardParameters setValue:oauth_signature_method forKey:@"oauth_signature_method"];
    [standardParameters setValue:oauth_timestamp        forKey:@"oauth_timestamp"];
    [standardParameters setValue:oauth_version          forKey:@"oauth_version"];
    [standardParameters setValue:OAUTH_CALLBACK         forKey:@"oauth_callback"];
    
    return standardParameters;
}


#pragma mark build authorized API-requests
+ (NSURLRequest *)preparedRequestForPath:(NSString *)path
                              parameters:(NSDictionary *)queryParameters
                              HTTPmethod:(NSString *)HTTPmethod
                              oauthToken:(NSString *)oauth_token
                             oauthSecret:(NSString *)oauth_token_secret
{
    if (!HTTPmethod
        || !oauth_token) return nil;
    
    NSMutableDictionary *allParameters = [self standardOauthParameters];
    allParameters[@"oauth_token"] = oauth_token;
    if (queryParameters) [allParameters addEntriesFromDictionary:queryParameters];
    [allParameters removeObjectForKey:@"oauth_callback"];
    NSString *parametersString = CHQueryStringFromParametersWithEncoding(allParameters, NSUTF8StringEncoding);
    
    NSString *request_url = API_URL;
    if (path) request_url = [request_url stringByAppendingString:path];
    NSString *oauth_consumer_secret = CONSUMER_SECRET;
    NSString *baseString = [HTTPmethod stringByAppendingFormat:@"&%@&%@", request_url.utf8AndURLEncode, parametersString.utf8AndURLEncode];
    NSString *secretString = [oauth_consumer_secret.utf8AndURLEncode stringByAppendingFormat:@"&%@", oauth_token_secret.utf8AndURLEncode];
    NSString *oauth_signature = [self.class signClearText:baseString withSecret:secretString];
    allParameters[@"oauth_signature"] = oauth_signature;
    
    NSString *queryString = nil;
    if (queryParameters) queryString = CHQueryStringFromParametersWithEncoding(allParameters, NSUTF8StringEncoding);
    if (queryString) request_url = [request_url stringByAppendingFormat:@"?%@", queryString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:request_url]];
    request.HTTPMethod = HTTPmethod;
    
    /*
    NSMutableArray *parameterPairs = [NSMutableArray array];
    [allParameters removeObjectsForKeys:queryParameters.allKeys];
    for (NSString *name in allParameters) {
        NSString *aPair = [name stringByAppendingFormat:@"=\"%@\"", [allParameters[name] utf8AndURLEncode]];
        [parameterPairs addObject:aPair];
    }
    NSString *oAuthHeader = [@"OAuth " stringByAppendingFormat:@"%@", [parameterPairs componentsJoinedByString:@", "]];
    [request setValue:oAuthHeader forHTTPHeaderField:@"Authorization"];
     */
    if ([HTTPmethod isEqualToString:@"POST"]
        && queryParameters != nil) {
        NSData *body = [queryString dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:body];
    }
    return request;
}

#pragma mark -
+ (NSString *)signClearText:(NSString *)text withSecret:(NSString *)secret
{
    NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
    NSData *clearTextData = [text dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[20];
    hmac_sha1((unsigned char *)[clearTextData bytes], [clearTextData length], (unsigned char *)[secretData bytes], [secretData length], result);
    
    //Base64 Encoding
    char base64Result[32];
    size_t theResultLength = 32;
    Base64EncodeData(result, 20, base64Result, &theResultLength);
    NSData *theData = [NSData dataWithBytes:base64Result length:theResultLength];
    
    return [NSString.alloc initWithData:theData encoding:NSUTF8StringEncoding];
}



@end
