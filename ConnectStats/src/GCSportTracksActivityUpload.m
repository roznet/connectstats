//  MIT Licence
//
//  Created on 06/04/2014.
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

#import "GCSportTracksActivityUpload.h"
#import "GCService.h"
#import "GCWebUrl.h"
#import "GCAppGlobal.h"

@implementation GCSportTracksActivityUpload


+(NSDate*)lastSync:(NSString*)aId{
    return [[GCService service:gcServiceStrava] lastSync:aId];
}

+(void)recordSync:(NSString*)aId{
    [[GCService service:gcServiceStrava] recordSync:aId];
}

+(GCSportTracksActivityUpload*)garminTransferSportTracks:(NSString*)aId andController:(UINavigationController*)nav{
    if ([[GCService service:gcServiceStrava] lastSync:aId]) {// already
        return nil;
    }

    GCSportTracksActivityUpload * rv = [[[GCSportTracksActivityUpload alloc] init] autorelease];
    if (rv) {
        rv.activityId = aId;
        rv.navigationController = nav;
    }
    return rv;
}

-(void)dealloc{
    [_activityId release];
    [_tcxString release];

    [super dealloc];
}

-(gcWebService)service{
    return gcWebServiceStrava;
}

-(NSString*)url{
    if (self.navigationController) {
        return GCWebActivityURL(self.activityId);
    }else{
        return @"https://api.sporttracks.mobi/api/v2/fileUpload";
    }
}

-(NSString*)description{
    if (self.tcxString) {
        return NSLocalizedString(@"Uploading to sporttracks", @"SportTracks Upload");
    }else{
        return NSLocalizedString(@"Downloading file for sporttracks", @"SportTracks Upload");
    }
}

-(void)process{
    if (self.navigationController) {
#if TARGET_IPHONE_SIMULATOR
        NSError * e = nil;
        NSString * fn = [NSString stringWithFormat:@"activity_%@.tcx", self.activityId];
        [self.theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:self.encoding error:&e];
#endif
        self.tcxString = self.theString;
        [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self signInToSportTracks];
        });
    }else{
#if TARGET_IPHONE_SIMULATOR
        NSError * e = nil;
        NSString * fn = [NSString stringWithFormat:@"sporttracks_%@.json", self.activityId];
        [self.theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:self.encoding error:&e];
#endif
        dispatch_async([GCAppGlobal worker],^(){
            [self parseResponse];
        });
    }
}

-(void)parseResponse{
    //CRASH in parseResponse 'NSInvalidArgumentException', reason: '-[__NSCFArray objectForKeyedSubscript:]: unrecognized selector sent
    BOOL dumpjson = false;
    BOOL dumptcx  = false;
    NSError * e = nil;
    NSDictionary * json = [NSJSONSerialization JSONObjectWithData:[self.theString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&e ];
    if (json==nil) {
        RZLog(RZLogError, @"failed to parse json answer %@", e);
        dumpjson = true;
    }else{
        NSNumber * size = json[@"fitnessActivities"][@"size"];
        if (size && size.intValue>0) {
            [[GCService service:gcServiceSportTracks] recordSync:self.activityId];
            RZLog(RZLogInfo, @"sporttracks upload successful");
        }else{
            RZLog(RZLogError, @"sporttracks upload failed");
            dumpjson = true;
        }
    }
    if (dumpjson) {
        NSString * fn = [NSString stringWithFormat:@"error_sporttracks_%@.json", self.activityId];
        [self.theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:self.encoding error:&e];
    }
    if (dumptcx) {
        NSString * fn = [NSString stringWithFormat:@"error_sporttracks_%@.tcx", self.activityId];
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
        return [NSString stringWithFormat:@"sporttracks_%@.tcx", self.activityId];
    }
    return nil;
}
-(NSDictionary*)postData{
    if (self.tcxString) {
        return @{ @"format":@"tcx",
                  @"data": self.tcxString};
    }
    return nil;
}

-(id<GCWebRequest>)nextReq{
    if (self.navigationController) {
        GCSportTracksActivityUpload * next = [GCSportTracksActivityUpload garminTransferSportTracks:self.activityId andController:nil];
        next.sportTracksAuth = self.sportTracksAuth;
        next.tcxString = self.tcxString;
        return next;
    }
    return nil;
}





@end
