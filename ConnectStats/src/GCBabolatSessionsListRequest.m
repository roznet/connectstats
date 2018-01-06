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

#import "GCBabolatSessionsListRequest.h"
#import "GCBabolatSessionRequest.h"
#import "GCAppGlobal.h"
#import "GCActivitiesOrganizer.h"

//http://api.babolatplay.as44099.com/v1/players/1544/sessions?access_token=MDdkYTAyYjAzMmYyYWUwZTI5ODNlOGNjYzZhZGU4OGUxMmJkZmE5OTdhYmYwMjk4ZmUwYjQwMjYzOTcxOWVkMA

NSString * GCWebUrlBabolatGetSessionsList(NSString*token,NSString*playerId){
    return [NSString stringWithFormat:@"https://api.babolatplay.com/v1/players/%@/sessions?access_token=%@", playerId, token];
}


@implementation GCBabolatSessionsListRequest
-(gcWebService)service{
    return gcWebServiceBabolat;
}

+(GCBabolatSessionsListRequest*)babolatSessionsListForPlayer:(NSString*)aId andToken:(NSString*)aToken{
    GCBabolatSessionsListRequest * rv = RZReturnAutorelease([[GCBabolatSessionsListRequest alloc] init]);
    if (rv) {
        rv.token = aToken;
        rv.playerId = aId;
    }
    return rv;
}
#if !__has_feature(objc_arc)
-(void)dealloc{
    [_token release];
    [_playerId release];
    [_sessions release];
    [_delegate release];
    [_json release];
    [super dealloc];
}
#endif

-(NSString*)description{
    return @"Download Babolat Sessions";
}
-(NSString*)url{
    return GCWebUrlBabolatGetSessionsList(self.token,self.playerId);
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
    NSString * fname = @"error_babolat_sessions.json";
    if(![theString writeToFile:[RZFileOrganizer writeableFilePath:fname] atomically:true encoding:NSUTF8StringEncoding error:&e]){
        RZLog(RZLogError, @"Failed to save %@. %@", fname, e.localizedDescription);
    }
}

-(void)process:(NSString*)theString encoding:(NSStringEncoding)encoding andDelegate:(id<GCWebRequestDelegate>) delegate{
    NSError * err = nil;
#if TARGET_IPHONE_SIMULATOR
    NSError * e = nil;
    NSString * fn = [NSString stringWithFormat:@"babolat_sessions.json"];
    if(![theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:encoding error:&e]){
        RZLog(RZLogError, @"Failed to save %@. %@", fn, e.localizedDescription);
    }
#endif

    NSDictionary * json = [NSJSONSerialization JSONObjectWithData:[theString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&err ];
    if (json==nil) {
        RZLog(RZLogError, @"json parsing failed %@", err);
        [self saveError:theString];
        [delegate processDone:self];
        self.status = GCWebStatusParsingFailed;
    }else {
        self.json = json;
        self.delegate = delegate;
        dispatch_async([GCAppGlobal worker],^(){
            [self processParse];
        });

    }

}

-(void)processJson:(NSDictionary*)json{
    NSDictionary * timeline = json[@"timeline"];
    NSMutableArray * sessions = [NSMutableArray arrayWithCapacity:10];
    if (timeline) {
        [[GCAppGlobal profile] serviceSuccess:gcServiceBabolat set:YES];
        for (id key in timeline) {
            NSArray * items = timeline[key][@"items"];
            for (NSDictionary * item in items) {
                [sessions addObject:item];
            }
        }
    }
    for (NSDictionary * item in sessions) {
        NSString * sessionId = [item[@"session_id"] stringValue];
        if (sessionId) {
            [[GCAppGlobal organizer] registerTennisActivity:sessionId withBabolatData:item];
        }
    }
    self.sessions = sessions;
}

-(void)processParse{
    [self processJson:self.json];
    [self performSelectorOnMainThread:@selector(processDone) withObject:nil waitUntilDone:NO];
}

-(void)processDone{
    [self.delegate processDone:self];
    self.delegate = nil;
}
-(id<GCWebRequest>)nextReq{
    if (/* DISABLES CODE */ (false) && (self.sessions).count) {
        return [GCBabolatSessionRequest babolatSession:[(self.sessions)[0][@"session_id"] stringValue] withToken:self.token];
    }
    return nil;
}


@end
