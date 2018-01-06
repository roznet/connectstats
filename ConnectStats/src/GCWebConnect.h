//  MIT Licence
//
//  Created on 02/09/2012.
//
//  Copyright (c) 2012 Brice Rosenzweig.
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
#import "GCWebRequest.h"

#pragma mark -

@interface GCWebConnect : RZParentObject<RZRemoteDownloadDelegate,GCWebRequestDelegate>

@property (retain,nonatomic) NSMutableArray * requests;
@property (assign) GCWebStatus status;
@property (nonatomic,assign) NSInteger lastStatusCode;
@property (nonatomic,retain) NSError * lastError;
@property (nonatomic,retain) dispatch_queue_t worker;

-(NSString*)currentDescription;
-(NSString*)currentUrl;

-(void)next;
-(void)addRequest:(id<GCWebRequest>)req;

-(GCWebStatus)statusForService:(gcWebService)service;
-(NSString*)statusDescriptionForService:(gcWebService)service;
-(NSString*)webServiceDescription:(gcWebService)service;
-(BOOL)didLoginSuccessfully:(gcWebService)service;
-(void)resetSuccessfulLogin;
-(void)resetStatus;

-(BOOL)isProcessing;
-(void)clearCookies;

+(void)sanityCheck;
@end
