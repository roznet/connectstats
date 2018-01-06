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

#import "GCBabolatLoginRequest.h"
#import "GCBabolatPlayersRequest.h"
#import "GCAppGlobal.h"
#import "GCBabolatSessionRequest.h"
#import "GCActivitiesOrganizer.h"

static NSString * kClientId = @"3_65aeu1yu7lwksw48oog44c4ogwg8cwsckswkskso4wcso48o88";
static NSString * kClientSecret = @"1vx7bgu1hg9w8g4ksk0kss0wkcococcco0csok4ks4s4wkoocw";

//http://api.babolatplay.as44099.com/oauth/v2/token?grant_type=password&client_id=3_65aeu1yu7lwksw48oog44c4ogwg8cwsckswkskso4wcso48o88&client_secret=1vx7bgu1hg9w8g4ksk0kss0wkcococcco0csok4ks4s4wkoocw&username=brice_rosenzweig@yahoo.com&password=XXXXXXXX

NSString * GCWebUrlBabolatGetToken(NSString*uname,NSString*password){

    return [NSString stringWithFormat:@"https://api.babolatplay.com/oauth/v2/token?grant_type=password&client_id=%@&client_secret=%@&username=%@&password=%@",
     kClientId,kClientSecret,uname,password];
}

@implementation GCBabolatLoginRequest
-(gcWebService)service{
    return gcWebServiceBabolat;
}

+(GCBabolatLoginRequest*)babolatLoginRequest{
    NSString * uname = [[GCAppGlobal profile] currentLoginNameForService:gcServiceBabolat];
    NSString * pwd   = [[GCAppGlobal profile] currentPasswordForService:gcServiceBabolat];

    GCBabolatLoginRequest * rv = nil;
    if (uname&&pwd) {
        rv = RZReturnAutorelease([[GCBabolatLoginRequest alloc] init]);
        if (rv) {
            rv.uname = uname;
            rv.pwd = pwd;
        }
    }
    return rv;
}
#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_token release];
    [_sessionId release];
    [_uname release];
    [_pwd release];

    [super dealloc];
}
#endif
-(NSString*)description{
    return @"Login to Babolat";
}
-(NSString*)url{
    return GCWebUrlBabolatGetToken(self.uname,self.pwd);
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
    NSString * fname = @"error_babolat_token.json";
    if(![theString writeToFile:[RZFileOrganizer writeableFilePath:fname] atomically:true encoding:NSUTF8StringEncoding error:&e]){
        RZLog(RZLogError, @"Failed to save %@. %@", fname, e.localizedDescription);
    }
}

-(void)process:(NSString*)theString encoding:(NSStringEncoding)encoding andDelegate:(id<GCWebRequestDelegate>) delegate{
    NSError * err = nil;
#if TARGET_IPHONE_SIMULATOR
    NSError * e = nil;
    NSString * fn = [NSString stringWithFormat:@"babolat_token.json"];
    if(![theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:encoding error:&e]){
        RZLog(RZLogError, @"Failed to save %@. %@", fn, e.localizedDescription);
    }
#endif

    NSDictionary * json = [NSJSONSerialization JSONObjectWithData:[theString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&err ];
    if (json==nil) {
        RZLog(RZLogError, @"json parsing failed %@", err);
        [self saveError:theString];
        self.status = GCWebStatusParsingFailed;
    }else {
        self.token = json[@"access_token"];
        if (self.token==nil) {
            self.status = GCWebStatusLoginFailed;
        }
    }
    [delegate processDone:self];

}
-(id<GCWebRequest>)nextReq{
    if (self.token) {
        if (self.sessionId) {
            return [GCBabolatSessionRequest babolatSession:self.sessionId withToken:self.token];
        }
        return [GCBabolatPlayersRequest babolatPlayersRequest:self.token];
    }
    return nil;
}

@end
