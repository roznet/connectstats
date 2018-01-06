//  MIT Licence
//
//  Created on 09/02/2014.
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

#import "GCBabolatSessionRequest.h"
#import "GCService.h"
#import "GCAppGlobal.h"

NSString * GCWebUrlBabolatGetSession(NSString*token,NSString*sessionId){
    return [NSString stringWithFormat:@"https://api.babolatplay.com/v1/sessions/%@?access_token=%@", sessionId, token];
}
@interface GCBabolatSessionRequest()
@property (nonatomic,retain) NSDictionary * json;
@property (nonatomic,retain) NSObject<GCWebRequestDelegate> * delegate;


@end
@implementation GCBabolatSessionRequest
-(gcWebService)service{
    return gcWebServiceBabolat;
}

+(GCBabolatSessionRequest*)babolatSession:(NSString*)aId withToken:(NSString*)aToken{
    GCBabolatSessionRequest * rv = RZReturnAutorelease([[GCBabolatSessionRequest alloc] init]);
    if (rv) {
        rv.token = aToken;
        rv.sessionId = aId;
    }
    return rv;
}
#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_token release];
    [_sessionId release];
    [_json release];
    [_delegate release];
    [super dealloc];
}
#endif
-(GCWebStatus)status{
    return GCWebStatusOK;
}
-(NSString*)description{
    return @"Download Babolat Sessions";
}
-(NSString*)url{
    return GCWebUrlBabolatGetSession(self.token,self.sessionId);
}
-(NSDictionary*)postData{
    return nil;
}
-(NSDictionary*)deleteData{
    return nil;
}
-(NSData*)fileData{
    return nil;
}
-(NSString*)fileName{
    return nil;
}
-(void)saveError:(NSString*)theString{
    NSError * e;
    NSString * fname = [NSString stringWithFormat: @"error_babolat_session_%@.json", self.sessionId];
    if(![theString writeToFile:[RZFileOrganizer writeableFilePath:fname] atomically:true encoding:NSUTF8StringEncoding error:&e]){
        RZLog(RZLogError, @"Failed to save %@. %@", fname, e.localizedDescription);
    }
}

-(void)process:(NSString*)theString encoding:(NSStringEncoding)encoding andDelegate:(id<GCWebRequestDelegate>) delegate{
    NSError * err = nil;
#if TARGET_IPHONE_SIMULATOR
    NSError * e = nil;
    NSString * fn = [NSString stringWithFormat: @"babolat_session_%@.json", self.sessionId];
    if(![theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:encoding error:&e]){
        RZLog(RZLogError, @"Failed to save %@. %@", fn, e.localizedDescription);
    }
#endif

    NSDictionary * json = [NSJSONSerialization JSONObjectWithData:[theString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&err ];
    if (json==nil) {
        RZLog(RZLogError, @"json parsing failed %@", err);
        [self saveError:theString];
        [delegate processDone:self];
    }else {
        self.json= json;
        self.delegate = delegate;
        dispatch_async([GCAppGlobal worker],^(){
            [self parse];
        });

    }

}

-(void)processJson:(NSDictionary*)json{
    NSDictionary * sessionData = json[@"session"];
    NSString * sid = [sessionData[@"session_id"] stringValue];
    if (sid && [sid isEqualToString:self.sessionId]) {
        [[GCAppGlobal profile] serviceSuccess:gcServiceBabolat set:YES];
        [[GCAppGlobal organizer] registerTennisActivity:sid withFullSession:sessionData];
    }else{
        RZLog(RZLogWarning, @"Expected session_id=%@ got %@", self.sessionId, sid);
    }
}

-(void)parse{
    [self processJson:self.json];
    [self performSelectorOnMainThread:@selector(processDone) withObject:nil waitUntilDone:NO];
}

-(void)processDone{
    [self.delegate processDone:self];
    self.delegate = nil;
    self.json = nil;

}
-(id<GCWebRequest>)nextReq{
    return nil;
}

-(NSString*)activityId{
    return [[GCService service:gcServiceBabolat] activityIdFromServiceId:self.sessionId];
}

@end
