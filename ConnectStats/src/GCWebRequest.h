//  MIT Licence
//
//  Created on 24/02/2014.
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

#import <Foundation/Foundation.h>
#import <RZUtils/RZUtils.h>

#define NOTIFY_NEXT     @"next"
#define NOTIFY_END      @"end"
#define NOTIFY_ERROR    @"error"
#define NOTIFY_NEW      @"new"
#define NOTIFY_CHANGE   @"change"

@class GTMOAuth2Authentication;

typedef NS_ENUM(NSUInteger, GCWebStatus) {
    GCWebStatusOK,
    GCWebStatusLoginFailed,
    GCWebStatusParsingFailed,
    GCWebStatusAccessDenied,
    GCWebStatusTempUnavailable,
    GCWebStatusDeletedActivity,
    GCWebStatusConnectionError,
    GCWebStatusInternalLogicError,
    GCWebStatusServiceInternalError,
    GCWebStatusRequireModern,
    GCWebStatusRequirePasswordRenew,
};

typedef NS_ENUM(NSUInteger, gcWebService) {
    gcWebServiceNone, // typically for sign in/login
    gcWebServiceGarmin,
    gcWebServiceStrava,
    gcWebServiceWithings,
    gcWebServiceBabolat,
    gcWebServiceSportTracks,
    gcWebServiceHealthStore,
    gcWebServiceFitbit,
    gcWebServiceEnd
};

@protocol GCWebRequestDelegate <NSObject>

-(void)processDone:(id)req;
-(void)processNewStage;
-(void)loginSuccess:(gcWebService)service;
-(void)requireLogin:(gcWebService)service;
-(NSInteger)lastStatusCode;

@end

@protocol GCWebRequest <NSObject>

-(GCWebStatus)status;
-(NSString*)description;
-(NSString*)url;
-(NSDictionary*)postData;
-(NSDictionary*)deleteData;
-(NSData*)fileData;
-(NSString*)fileName;
-(void)process:(NSString*)theString encoding:(NSStringEncoding)encoding andDelegate:(id<GCWebRequestDelegate>) delegate;
-(id<GCWebRequest>)nextReq;
-(gcWebService)service;

@optional
-(NSDictionary*)postJson;
-(BOOL)priorityRequest;
-(BOOL)isSameAsRequest:(id)req;
-(void)preConnectionSetup;
-(GTMOAuth2Authentication*)oauth2Authentication;
-(NSString*)activityId;
-(id<GCWebRequest>)remediationReq;
-(NSURLRequest*)preparedUrlRequest;
-(RemoteDownloadPrepareUrl)prepareUrlFunc;
-(NSError*)lastError;
-(NSString*)httpUserAgent;
-(void)process:(NSData*)theData andDelegate:(id<GCWebRequestDelegate>)delegate;
@end

