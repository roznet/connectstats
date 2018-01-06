//  MIT Licence
//
//  Created on 19/11/2013.
//
//  Copyright (c) 2013 Brice Rosenzweig.
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

#import "GCStravaActivityTransfer.h"
#import "GCWebUrl.h"
#import "GCAppGlobal.h"
#import "Flurry.h"
#import "GCService.h"
@import RZExternal;

#pragma mark - GCGarminActivityTransferStrava

@implementation GCStravaActivityTransfer

+(NSDate*)lastSync:(NSString*)aId{
    return [[GCService service:gcServiceStrava] lastSync:aId];
}

+(void)recordSync:(NSString*)aId{
    [[GCService service:gcServiceStrava] recordSync:aId];
}

+(GCStravaActivityTransfer*)garminTransferStrava:(NSString*)aId andController:(UINavigationController*)nav extra:(NSDictionary*)extra{
    if ([GCStravaActivityTransfer lastSync:aId]) {// already
        return nil;
    }

    GCStravaActivityTransfer * rv = [[[GCStravaActivityTransfer alloc] init] autorelease];
    if (rv) {
        rv.activityId = aId;
        rv.navigationController = nav;
        rv.extra = extra;
    }
    return rv;
}

-(void)dealloc{
    [_activityId release];
    [_tcxString release];
    [_extra release];

    [super dealloc];
}

-(gcWebService)service{
    return gcWebServiceStrava;
}

-(NSString*)url{
    if (self.navigationController) {
        return GCWebActivityURL(self.activityId);
    }else{
        return GCWebStravaUpload();
    }
}

-(NSString*)description{
    if (self.tcxString) {
        return NSLocalizedString(@"Uploading to strava", @"Strava Upload");
    }else{
        return NSLocalizedString(@"Downloading file for strava", @"Strava Upload");
    }
}

-(void)process{
    if (self.navigationController) {
        NSError * e = nil;
#if TARGET_IPHONE_SIMULATOR
        NSString * fn = [NSString stringWithFormat:@"activity_%@.tcx", self.activityId];
        if(![self.theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:self.encoding error:&e]){
            RZLog(RZLogError, @"Failed to save %@. %@", fn, e.localizedDescription);
        }
#endif
        self.tcxString = self.theString;
        [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
        if ([self checkNoErrors]) {
            [self performSelectorOnMainThread:@selector(signInToStrava) withObject:nil waitUntilDone:NO];
        }else{
            NSString * efn = [NSString stringWithFormat:@"error_strava_%@.tcx", self.activityId];
            if(![self.tcxString writeToFile:[RZFileOrganizer writeableFilePath:efn] atomically:true encoding:self.encoding error:&e]){
                RZLog(RZLogError, @"Failed to save %@. %@", efn, e.localizedDescription);
            }

            [self performSelectorOnMainThread:@selector(processDone) withObject:nil waitUntilDone:NO];
        }
    }else{
#if TARGET_IPHONE_SIMULATOR
        NSError * e = nil;
        NSString * fn = [NSString stringWithFormat:@"strava_%@.json", self.activityId];
        if(![self.theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:self.encoding error:&e]){
            RZLog(RZLogError, @"Failed to save %@. %@", fn, e.localizedDescription);
        }
#endif
        dispatch_async([GCAppGlobal worker],^(){
            [self parseResponse];
        });
    }
}

-(void)parseResponse{
    BOOL dumpjson = false;
    BOOL dumptcx  = false;
    NSError * e = nil;
    NSDictionary * json = [NSJSONSerialization JSONObjectWithData:[self.theString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&e ];
    if (json==nil || ![json isKindOfClass:[NSDictionary class]]) {
        RZLog(RZLogError, @"failed to parse json answer %@", e?:NSStringFromClass([json class]));
        dumpjson = true;
    }else{
        id error = json[@"error"];
        if ([error isKindOfClass:[NSNull class]]) {
            [GCStravaActivityTransfer recordSync:self.activityId];
            RZLog(RZLogInfo, @"strava upload successful");
        }else if([error isKindOfClass:[NSString class]]){
            NSString * errorString = error;
            if ([errorString rangeOfString:@"duplicate of"].location == NSNotFound) {
                RZLog(RZLogError, @"strava returned an error: %@", errorString);
                dumptcx = true;
                dumpjson = true;
            }else{
                RZLog(RZLogInfo, @"strava duplicate %@", errorString);
                // mark it so we don't try again
                [GCStravaActivityTransfer recordSync:self.activityId];
                [Flurry logEvent:EVENT_UPLOAD_STRAVA];
            }
        }else{
            RZLog(RZLogInfo,@"strava error not recognized %@", error ? error : @"nil");
            dumpjson = true;
        }
    }
    if (dumpjson) {
        NSString * fn = [NSString stringWithFormat:@"error_strava_%@.json", self.activityId];
        [self.theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:self.encoding error:&e];
    }
    if (dumptcx) {
        NSString * fn = [NSString stringWithFormat:@"error_strava_%@.tcx", self.activityId];
        [self.tcxString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:self.encoding error:&e];
    }
    [self performSelectorOnMainThread:@selector(processDone) withObject:nil waitUntilDone:NO];
}

-(NSData*)fileData{
    if (self.tcxString) {
        return [self.tcxString dataUsingEncoding:NSUTF8StringEncoding];
    }else{
        return nil;
    }
}
-(NSString*)fileName{
    if (self.tcxString) {
        return [NSString stringWithFormat:@"strava_%@.tcx", self.activityId];
    }
    return nil;
}
-(NSDictionary*)postData{
    if (self.tcxString) {
        if (self.stravaAuth==nil||self.activityId==nil) {
            return nil;
        }
        NSMutableDictionary * post = [NSMutableDictionary dictionaryWithDictionary:@{ @"access_token":(self.stravaAuth).accessToken,
                                                                                      @"external_id": self.activityId,
                                                                                      @"data_type":@"tcx"}];
        if (self.extra) {
            [post addEntriesFromDictionary:self.extra];
        }
        return post;
    }
    return nil;
}

-(id<GCWebRequest>)nextReq{
    if (self.navigationController && self.status == GCWebStatusOK) {
        GCStravaActivityTransfer * next = [GCStravaActivityTransfer garminTransferStrava:self.activityId andController:nil extra:self.extra];
        next.stravaAuth = self.stravaAuth;
        next.tcxString = self.tcxString;
        return next;
    }
    return nil;
}



@end
