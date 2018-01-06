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

#import "GCBabolatPlayersRequest.h"
#import "GCBabolatSessionsListRequest.h"

//http://api.babolatplay.as44099.com/v1/players/me?access_token=MDdkYTAyYjAzMmYyYWUwZTI5ODNlOGNjYzZhZGU4OGUxMmJkZmE5OTdhYmYwMjk4ZmUwYjQwMjYzOTcxOWVkMA
//http://api.babolatplay.as44099.com/v1/players/1544/sessions?access_token=MDdkYTAyYjAzMmYyYWUwZTI5ODNlOGNjYzZhZGU4OGUxMmJkZmE5OTdhYmYwMjk4ZmUwYjQwMjYzOTcxOWVkMA

NSString * GCWebUrlBabolatGetPlayer(NSString*token){
    return [NSString stringWithFormat:@"https://api.babolatplay.com/v1/players/me?access_token=%@", token];
}

@implementation GCBabolatPlayersRequest

-(gcWebService)service{
    return gcWebServiceBabolat;
}

+(GCBabolatPlayersRequest*)babolatPlayersRequest:(NSString*)atoken{
    GCBabolatPlayersRequest*rv = RZReturnAutorelease([[GCBabolatPlayersRequest alloc] init]);
    if (rv) {
        rv.token = atoken;
    }
    return rv;
}
#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_token release];
    [_playerId release];
    [super dealloc];
}
#endif
-(NSString*)description{
    return @"Download Player";
}
-(NSString*)url{
    return GCWebUrlBabolatGetPlayer(self.token);
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
    NSString * fname = @"error_babolat_player.json";
    if(![theString writeToFile:[RZFileOrganizer writeableFilePath:fname] atomically:true encoding:NSUTF8StringEncoding error:&e]){
        RZLog(RZLogError, @"Failed to save %@. %@", fname, e.localizedDescription);
    }
}

-(void)process:(NSString*)theString encoding:(NSStringEncoding)encoding andDelegate:(id<GCWebRequestDelegate>) delegate{
    NSError * err = nil;
#if TARGET_IPHONE_SIMULATOR
    NSError * e = nil;
    NSString * fn = [NSString stringWithFormat:@"babolat_player.json"];
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
        self.playerId = json[@"player"][@"id"];
        if (self.playerId == nil) {
            self.status = GCWebStatusParsingFailed;
        }
    }
    [delegate processDone:self];

}
-(id<GCWebRequest>)nextReq{
    if (self.token && self.playerId) {
        return [GCBabolatSessionsListRequest babolatSessionsListForPlayer:self.playerId andToken:self.token];
    }
    return nil;
}

@end
