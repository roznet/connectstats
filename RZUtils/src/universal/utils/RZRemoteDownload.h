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

#import <Foundation/Foundation.h>
#import <RZUtils/RZMacros.h>
#import <RZUtils/RZRemoteDownloadDelegate.h>

@interface RZRemoteDownload : NSObject<NSURLSessionDelegate>

@property (nonatomic,assign) NSInteger responseCode;
@property (nonatomic,assign) NSStringEncoding receivedEncoding;
@property (nonatomic,retain) NSError * lastError;
@property (nonatomic,RZWEAK) NSObject<RZRemoteDownloadDelegate>*	downloadDelegate;


-(instancetype)init NS_DESIGNATED_INITIALIZER;
-(RZRemoteDownload*)initWithURLRequest:(NSURLRequest*)request
                         andDelegate:(NSObject<RZRemoteDownloadDelegate>*)aDelegate NS_DESIGNATED_INITIALIZER;

-(RZRemoteDownload*)initWithURL:(NSString*)aUrl
                  andDelegate:(NSObject<RZRemoteDownloadDelegate>*)aDelegate;
-(RZRemoteDownload*)initWithURL:(NSString*)aUrl
                     postData:(NSDictionary*)aData
                  andDelegate:(NSObject<RZRemoteDownloadDelegate>*)aDelegate;
-(RZRemoteDownload*)initWithURL:(NSString*)aUrl
                     postData:(NSDictionary*)pData
                     fileName:(NSString*)fname
                     fileData:(NSData*)uData
                  andDelegate:(NSObject<RZRemoteDownloadDelegate>*)aDelegate;
-(RZRemoteDownload*)initWithURL:(NSString*)aUrl
                     postJson:(id)aData
                  andDelegate:(NSObject<RZRemoteDownloadDelegate>*)aDelegate;
-(RZRemoteDownload*)initWithURL:(NSString*)aUrl
                   deleteData:(NSDictionary*)pData
                  andDelegate:(NSObject<RZRemoteDownloadDelegate>*)aDelegate;


+(NSMutableURLRequest*)urlRequestWithURL:(NSString*)aUrl
                                postData:(NSDictionary*)pData
                                fileName:(NSString*)fname
                                fileData:(NSData*)uData;
+(NSMutableURLRequest*)urlRequestWithURL:(NSString*)aUrl
                                postData:(NSDictionary*)pData
                                fileName:(NSString*)fname
                                filePath:(NSString*)fpath
                                 tmpPath:(NSString*)tmppath;
+(NSMutableURLRequest*)urlRequestWithURL:(NSString*)aUrl
                              deleteData:(NSDictionary*)pData;



+(NSUInteger)totalDataUsage;
+(NSString*)formattedTotalDataUsage;
@end
