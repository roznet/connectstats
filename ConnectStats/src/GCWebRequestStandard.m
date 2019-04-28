//  MIT Licence
//
//  Created on 10/09/2017.
//
//  Copyright (c) 2017 Brice Rosenzweig.
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


#import "GCWebRequestStandard.h"

NSStringEncoding kRequestDebugFileEncoding = NSUTF8StringEncoding;

@implementation GCWebRequestStandard
-(instancetype)init{
    return [super init];
}

#if !__has_feature(objc_arc)
-(void)dealloc{
    [_nextReq release];
    [_theString release];

    [super dealloc];
}
#endif

-(NSString*)description{
    return @"";
}
-(NSString*)url{
    return nil;
}

-(NSDictionary*)postData{
    return nil;
}
-(NSDictionary*)deleteData{
    return nil;
}

-(NSString*)logfileName{
    return @"request_log.html";
}

-(NSData*)fileData{
    return nil;
}
-(NSString*)fileName{
    return nil;
}

-(gcWebService)service{
    return gcWebServiceNone;
}

-(void)process:(NSString*)aString encoding:(NSStringEncoding)aencoding andDelegate:(id<GCWebRequestDelegate>) adelegate{
    self.theString = aString;
    self.encoding = aencoding;
    self.delegate = adelegate;

    [self process];
}

-(void)process{
    [self processDone];
}

-(void)processDone{
    [self setTheString:nil];// don't keep these
    [self.delegate processDone:self];
}
-(void)processNewStage{
    [self.delegate processNewStage];
}
-(NSString*)httpUserAgent{
    return RZWebRandomUserAgent();
}

-(BOOL)checkNoErrors{
    return self.status == GCWebStatusOK;
}

@end
