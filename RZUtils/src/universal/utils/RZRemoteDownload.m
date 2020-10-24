//  MIT Licence
//
//  Created on 01/04/2009.
//
//  Copyright (c) None Brice Rosenzweig.
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

#import "RZRemoteDownload.h"
#import "RZWebURL.h"
#import "RZLog.h"
#import <RZUtils/RZMacros.h>

static NSUInteger _totalDataUsage = 0;

static NSURLRequestCachePolicy _cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;


@interface RZRemoteDownload ()
@property (nonatomic,retain) NSString*                          url;
@property (nonatomic,retain) NSURLRequest *                     request;
@property (nonatomic,retain) NSURLSessionDataTask *             task;

@end
//NSURLRequestUseProtocolCachePolicy;
//NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
@implementation RZRemoteDownload

-(instancetype)init{
    return [super init];
}
-(void)dealloc{
    [_task cancel];
    RZRelease(_url);
    RZRelease(_task);
    RZRelease(_request);
    RZRelease(_lastError);

    RZSuperDealloc;
}


#pragma mark - init

-(RZRemoteDownload*)initWithURLRequest:(NSURLRequest*)request
                         andDelegate:(NSObject<RZRemoteDownloadDelegate>*)aDelegate{
    self = [super init];
    if( self ){
        self.url = request.URL.path;
        self.downloadDelegate = aDelegate;

        self.request = request;
        [self processStart];

    }
    return( self );

}

-(RZRemoteDownload*)initWithURL:(NSString*)aUrl
                  andDelegate:(NSObject<RZRemoteDownloadDelegate>*)aDelegate{
    NSMutableURLRequest *theRequest = [RZRemoteDownload preparedRequestForURL:aUrl andDelegate:aDelegate];

    return [self initWithURLRequest:theRequest andDelegate:aDelegate];
}


-(RZRemoteDownload*)initWithURL:(NSString*)aUrl postData:(NSDictionary*)aData andDelegate:(NSObject<RZRemoteDownloadDelegate>*)aDelegate{

    NSMutableURLRequest *theRequest = [RZRemoteDownload preparedRequestForURL:aUrl andDelegate:aDelegate];

    NSString * encoded = RZWebEncodeDictionary(aData);
    theRequest.HTTPBody = [NSData dataWithBytes:encoded.UTF8String length:encoded.length];
    theRequest.HTTPMethod = @"POST";

    return [self initWithURLRequest:theRequest andDelegate:aDelegate];
}


-(RZRemoteDownload*)initWithURL:(NSString*)aUrl postJson:(id)aData andDelegate:(NSObject<RZRemoteDownloadDelegate>*)aDelegate{
	NSMutableURLRequest *theRequest = [RZRemoteDownload preparedRequestForURL:aUrl andDelegate:aDelegate];

    NSError * e = nil;
    NSData * json = nil;
    if (aData) {
        json = [NSJSONSerialization dataWithJSONObject:aData options:0 error:&e];
        if (json==nil) {
            RZLog(RZLogError, @"json serialization failed %@",e);
            return nil;
        }
    }
    [theRequest addValue:@"application/json" forHTTPHeaderField: @"Content-Type"];

    theRequest.HTTPBody = json;
    theRequest.HTTPMethod = @"POST";

    return [self initWithURLRequest:theRequest andDelegate:aDelegate];
}


-(RZRemoteDownload*)initWithURL:(NSString*)aUrl
                     postData:(NSDictionary*)pData
                     fileName:(NSString*)fname
                     fileData:(NSData*)uData
                  andDelegate:(NSObject<RZRemoteDownloadDelegate>*)aDelegate{
    return [self initWithURLRequest:[RZRemoteDownload urlRequestWithURL:aUrl postData:pData fileName:fname fileData:uData] andDelegate:aDelegate];
}

-(RZRemoteDownload*)initWithURL:(NSString*)aUrl
                     deleteData:(NSDictionary*)pData
                  andDelegate:(NSObject<RZRemoteDownloadDelegate>*)aDelegate{
    return [self initWithURLRequest:[RZRemoteDownload urlRequestWithURL:aUrl deleteData:pData] andDelegate:aDelegate];
}


#pragma mark - urlRequests
+(NSMutableURLRequest*)preparedRequestForURL:(NSString*)aUrl andDelegate:(NSObject<RZRemoteDownloadDelegate>*)aDelegate{
    NSMutableURLRequest *theRequest = [NSMutableURLRequest	requestWithURL:[NSURL URLWithString:aUrl]
                                                              cachePolicy:_cachePolicy
                                                          timeoutInterval:60];
    if (aDelegate) {
        if ([aDelegate respondsToSelector:@selector(httpUserAgent)]) {
            NSString * agent = [aDelegate httpUserAgent];
            if (agent) {
                [theRequest setValue:agent forHTTPHeaderField:@"User-Agent"];
            }
        }
        if ([aDelegate respondsToSelector:@selector(prepareUrlFunc)]) {
            RemoteDownloadPrepareUrl func = [aDelegate prepareUrlFunc];
            if (func) {
                func(theRequest);
            }
        }
    }
    //[theRequest setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
    return theRequest;
}



+(NSMutableURLRequest*)urlRequestWithURL:(NSString*)aUrl
                                postData:(NSDictionary*)pData
                                fileName:(NSString*)fname
                                filePath:(NSString*)fpath
                                 tmpPath:(NSString*)tmppath{

    NSURL *tmpDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    NSURL *fileURL = [[tmpDirURL URLByAppendingPathComponent:@"mail"] URLByAppendingPathExtension:@"txt"];
    NSError* err = nil;
    [[NSFileManager defaultManager] createFileAtPath:fileURL.path contents:nil attributes:nil];
    NSFileHandle * fileHandle = [NSFileHandle fileHandleForWritingToURL:fileURL error:&err];
    if (!fileHandle) {
        RZLog(RZLogError, @"Failed to access %@. %@", fileURL, err.localizedDescription);
    }

    NSMutableURLRequest *theRequest = [NSMutableURLRequest		requestWithURL:[NSURL URLWithString:aUrl]
                                                               cachePolicy:_cachePolicy
                                                           timeoutInterval:60];


    //Add the header info
    NSString *stringBoundary = @"0xKhTmLbOuNdArY";
    //stringBoundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",stringBoundary];
    [theRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];

    //create the body

    [fileHandle writeData:[[NSString stringWithFormat:@"--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];

    if (pData) {
        //add key values from the NSDictionary object
        for (NSString * tempKey in pData) {
            [fileHandle writeData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",tempKey] dataUsingEncoding:NSUTF8StringEncoding]];
            [fileHandle writeData:[[NSString stringWithFormat:@"%@",pData[tempKey]] dataUsingEncoding:NSUTF8StringEncoding]];
            [fileHandle writeData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }

    //add data field and file data
    if (fpath) {
        [fileHandle writeData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n",fname] dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandle writeData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        NSData * fd = [[NSData alloc] initWithContentsOfFile:fpath options:NSDataReadingMappedIfSafe error:&err];
        [fileHandle writeData:fd];
        RZRelease(fd);
        [fileHandle writeData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [fileHandle closeFile];
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fileURL.path error:&err];
    unsigned long long fileSize = [attributes fileSize];
    NSString * lengthMsg = [NSString stringWithFormat:@"%u", (unsigned)fileSize];
    [theRequest addValue:lengthMsg forHTTPHeaderField:@"Content-Length"];
    //add the body to the post
    theRequest.HTTPBodyStream = [NSInputStream inputStreamWithFileAtPath:fileURL.path];
    theRequest.HTTPMethod = @"POST";
    return theRequest;
}

+(NSMutableURLRequest*)urlRequestWithURL:(NSString*)aUrl
                              deleteData:(NSDictionary*)pData{
    NSMutableURLRequest *theRequest = [NSMutableURLRequest		requestWithURL:[NSURL URLWithString:aUrl]
                                                               cachePolicy:_cachePolicy
                                                           timeoutInterval:60];
    theRequest.HTTPMethod = @"DELETE";
    return theRequest;
}


+(NSMutableURLRequest*)urlRequestWithURL:(NSString*)aUrl
                                postData:(NSDictionary*)pData
                                fileName:(NSString*)fname
                                fileData:(NSData*)uData{
    NSMutableURLRequest *theRequest = [NSMutableURLRequest		requestWithURL:[NSURL URLWithString:aUrl]
                                                               cachePolicy:_cachePolicy
                                                           timeoutInterval:60];
    //Add the header info
    NSString *stringBoundary = @"0xKhTmLbOuNdArY";
    //stringBoundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",stringBoundary];
    [theRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];

    //create the body
    NSMutableData *postBody = [NSMutableData data];
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];

    if (pData) {
        //add key values from the NSDictionary object
        for (NSString * tempKey in pData) {
            [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",tempKey] dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:[[NSString stringWithFormat:@"%@",pData[tempKey]] dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }

    //add data field and file data
    if (uData) {
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n",fname] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[NSData dataWithData:uData]];
        [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }

    //add the body to the post
    theRequest.HTTPBody = postBody;
    theRequest.HTTPMethod = @"POST";
    return theRequest;
}

#pragma mark - Connection

-(NSURLSession*)sharedSession{
    static NSURLSession * _shared = nil;
    if(_shared == nil){
        _shared = [NSURLSession sessionWithConfiguration:[[NSURLSession sharedSession] configuration] delegate:self delegateQueue:nil];
    }
    return _shared;
}

-(void)processStart{
    if( [self.downloadDelegate respondsToSelector:@selector(authorizeRequest:completionHandler:)]){
        [self.downloadDelegate authorizeRequest:(NSMutableURLRequest *)self.request completionHandler:^(NSError*error){
            if( error ){
                [self dataTaskDidFailWithError:error];
            }else{
                [self processStartDataTask];
            }
        }];
    }else{
        [self processStartDataTask];
    }
}
-(void)processStartDataTask{
    self.lastError = nil;

    self.task = [[self sharedSession] dataTaskWithRequest:self.request completionHandler:^(NSData*data,NSURLResponse*response,NSError*error){
        if (error) {
            [self dataTaskDidFailWithError:error];
        }else{
            [self dataTaskDidFinishLoading:data response:response];
        }
    }];
    if (self.task) {
        [self.task resume];
    }else{
        RZLog(RZLogError, @"Failed to create connection");
        [_downloadDelegate downloadFailed:self];
    }

}

-(void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
    bool isTesting = false;

#if TARGET_IPHONE_SIMULATOR
    if( [challenge.protectionSpace.host isEqualToString:@"localhost"] ||
       [challenge.protectionSpace.host isEqualToString:@"roznet.ro-z.me"] ){
        isTesting = true;
    }
#endif
    if( isTesting ){
        completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
    }else{
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
    }
}

-(void)dataTaskDidFailWithError:(NSError*)error{

    RZLog(RZLogError, @"Connection error[%ld] %@ %@", (long)error.code, error.localizedDescription, error.userInfo);
    self.lastError = error;
    [self.downloadDelegate downloadFailed:self];
}

-(void)dataTaskDidFinishLoading:(NSData*)data response:(NSURLResponse*)response{
    self.lastError = nil;
    NSString * enc = response.textEncodingName;
    BOOL dataOnly = false;
    NSHTTPURLResponse * httpResponse = nil;
    NSString * contentType = nil;
    if ([response isKindOfClass:[NSHTTPURLResponse class]]){
        httpResponse = (NSHTTPURLResponse*)response;
        contentType = httpResponse.allHeaderFields[@"Content-Type"];
        if ([contentType hasPrefix:@"application/x-zip-compressed"] || [contentType hasPrefix:@"application/octet-stream"]) {
            dataOnly = true;
        }
    }

    if( enc ){
        self.receivedEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)enc));
    }else{
        dataOnly = true;
        self.receivedEncoding = NSUTF8StringEncoding;
    }
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        self.responseCode = httpResponse.statusCode;
    }

    if (data.length>0) {
        _totalDataUsage += data.length;
    }

    if (dataOnly && [self.downloadDelegate respondsToSelector:@selector(downloadDataSuccessful:data:)]) {
        [self.downloadDelegate downloadDataSuccessful:self data:data];
    }else{
        NSString * rv = RZReturnAutorelease([[NSString alloc] initWithData:data encoding:self.receivedEncoding]);

        if (rv == nil && data.length>0) {
            rv =RZReturnAutorelease([[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
        }
        [self.downloadDelegate downloadStringSuccessful:self string:rv];
    }
}

+(NSUInteger)totalDataUsage{
    return _totalDataUsage;
}
+(NSString*)formattedTotalDataUsage{
    NSString * unit = @"b";
    double val = _totalDataUsage;
    if (val>1024.) {
        val/=1024.;
        unit = @"Kb";
    }
    if (val>1024.) {
        val/=1024.;
        unit = @"Mb";
    }
    if (val>1024.) {
        val/=1024.;
        unit = @"Gb";
    }
    return [NSString stringWithFormat:@"%.1f %@", val, unit];

}

@end
