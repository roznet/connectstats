//  MIT License
//
//  Created on 17/06/2019 for ConnectStats
//
//  Copyright (c) 2019 Brice Rosenzweig
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



#import "GCConnectStatsRequestFitFile.h"
#import "GCWebUrl.h"
#import "GCActivity.h"
#import "GCService.h"
#import "ConnectStats-Swift.h"
#import "GCGarminActivityTrack13Request.h"
#import "GCConnectStatsActivityTCXParser.h"
#import "GCGarminLoginSSORequest.h"

@interface GCConnectStatsRequestFitFile ()
@property (nonatomic,retain) GCActivity * activity;
@property (nonatomic,assign) BOOL tryAlternativeService;
@property (nonatomic,assign) BOOL shouldCheckForAlternativeWhenEmpty;
@end

@implementation GCConnectStatsRequestFitFile

+(GCConnectStatsRequestFitFile*)requestWithActivity:(GCActivity*)act andNavigationController:(UINavigationController*)nav{
    GCConnectStatsRequestFitFile * rv = RZReturnAutorelease([[GCConnectStatsRequestFitFile alloc] init]);
    if( rv ){
        rv.activity = act;
        rv.navigationController = nav;
        rv.shouldCheckForAlternativeWhenEmpty = true;
    }
    return rv;
}

-(GCConnectStatsRequestFitFile*)initNextWith:(GCConnectStatsRequestFitFile*)current{
    self = [super initNextWith:current];
    if( self ){
        self.activity = current.activity;
        self.tryAlternativeService = current.tryAlternativeService;
        self.shouldCheckForAlternativeWhenEmpty = ! self.tryAlternativeService;
        
    }
    return self;
}

#if !__has_feature(objc_arc)
-(void)dealloc{
    [_activity release];
    [super dealloc];
}
#endif

-(id<GCWebRequest>)nextReq{
    
    if( self.navigationController ){
        return RZReturnAutorelease([[GCConnectStatsRequestFitFile alloc] initNextWith:self]);
    }
    else{
        if( self.shouldCheckForAlternativeWhenEmpty && [self validAlternativeService]){
            self.tryAlternativeService = true;
            return RZReturnAutorelease([[GCConnectStatsRequestFitFile alloc] initNextWith:self]);
        }
        return nil;
    }
}
-(NSString*)url{
    return nil;
}

-(NSString*)debugDescription{
    return [NSString stringWithFormat:@"<%@: %@ %@>",
            NSStringFromClass([self class]),
            self.activity.activityId,
            [self.urlDescription truncateIfLongerThan:192 ellipsis:@"..."] ];
}

-(NSString*)description{
    return [NSString stringWithFormat:NSLocalizedString(@"Downloading Activity... %@",@"Request Description"),[self.activity.date dateFormatFromToday]];
}

-(BOOL)validAlternativeService{
    BOOL rv = false;
    BOOL garminSuccess = [[GCAppGlobal profile] serviceSuccess:gcServiceGarmin];
    if( garminSuccess && self.activity.externalServiceActivityId) {
        GCService * service = [GCService serviceForActivityId:self.activity.externalActivityId];
        if( service.service == gcServiceGarmin ){
            RZLog(RZLogInfo, @"%@ has garmin alternative %@, trying that", self.activity.activityId, self.activity.externalServiceActivityId);
            rv = true;
        }
    }
    return rv;
}
-(id<GCWebRequest>)remediationReq{
    if (self.status==GCWebStatusAccessDenied && self.tryAlternativeService == true) {
        self.status = GCWebStatusOK;
        self.stage = gcRequestStageDownload;
        RZLog(RZLogInfo, @"%@ garmin alternative %@ access denied, attempting login", self.activity.activityId, self.activity.externalServiceActivityId);

        return [GCGarminLoginSSORequest requestWithUser:[[GCAppGlobal profile] currentLoginNameForService:gcServiceGarmin]
                                                 andPwd:[[GCAppGlobal profile] currentPasswordForService:gcServiceGarmin]];
    }
    return nil;
}

-(NSURLRequest*)preparedUrlRequest{
    if( [self isSignedIn] ){
        self.navigationController = nil;
    }
    
    if (self.navigationController) {
        return nil;
    }else{
        if( self.tryAlternativeService ){
            NSString * path = GCWebActivityURLFitFile(self.activity.externalServiceActivityId);
            NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
            return request;
        }
        
        NSString * path = GCWebConnectStatsFitFile([[GCAppGlobal profile] configGetInt:CONFIG_CONNECTSTATS_CONFIG defaultValue:gcWebConnectStatsConfigProduction]);
        GCService * service = self.activity.service;
        NSString * aid = [service serviceIdFromActivityId:self.activity.activityId ];
        
        NSDictionary *parameters = @{
                                     @"token_id" : @(self.tokenId),
                                     @"activity_id" : @(aid.integerValue)
                                     };
        
        return [self preparedUrlRequest:path params:parameters];
    }
}

-(NSString*)fitFileName{
    if( self.tryAlternativeService){
        return [NSString stringWithFormat:@"track_csalt_%@.fit", self.activity.externalServiceActivityId];
    }else{
        NSString * aid = [self.activity.service serviceIdFromActivityId:self.activity.activityId ];
        return [NSString stringWithFormat:@"track_cs_%@.fit", aid];
    }
}

-(void)process:(NSData *)theData andDelegate:(id<GCWebRequestDelegate>)delegate{
    self.delegate = delegate;
    
    if (![self isSignedIn]) {
        [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
        dispatch_async(dispatch_get_main_queue(),^(){
            [self signIn];
        });
        
    }else{
        NSString * fname = [self fitFileName];
        
        if( self.tryAlternativeService ){
            if( delegate.lastStatusCode == 403){
                self.status = GCWebStatusAccessDenied;
            }
            if( self.status == GCWebStatusOK && ![GCGarminActivityTrack13Request extractFitDataFromZip:theData intoFitFile:fname] ){
                NSString * string = RZReturnAutorelease([[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding]);
                if( [string hasPrefix:@"{\""] ){
                    if( [string rangeOfString:@"NotFoundException"].location != NSNotFound ){
                        RZLog(RZLogInfo, @"%@/%@ was deleted from alternate service: %@", self.activity.activityId, self.activity.externalServiceActivityId, string);
                    }else{
                        RZLog(RZLogWarning, @"Error from Alternate Service for %@/%@: %@", self.activity.activityId, self.activity.externalServiceActivityId, string);
                    }
                }else{
                    RZLog(RZLogError, @"Failed to save and process %@.", fname);
                }
            }
        }else{
            if(![theData writeToFile:[RZFileOrganizer writeableFilePath:fname] atomically:true]){
                RZLog(RZLogError, @"Failed to save %@.", fname);
            }
        }
        self.stage = gcRequestStageParsing;
        [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
        dispatch_async([GCAppGlobal worker],^(){
            [self processParse:fname];
        });
    }
}

-(void)processParse:(NSString*)fileName{
    if( [self checkNoErrors]){
        NSString * fp = [[NSFileManager defaultManager] fileExistsAtPath:fileName] ? fileName : [RZFileOrganizer writeableFilePath:fileName];
        
        NSDate * useStartDate = self.activity.parentId != nil ? self.activity.date : nil;
        
        NSData * data = [NSData dataWithContentsOfFile:fp];
        const char * start = data.bytes;
        
        GCActivity * fitAct = nil;
        
        if( data.length > 5 && strncmp(start,"<?xml", 5 ) == 0 ){
            GCConnectStatsActivityTCXParser * parser = [GCConnectStatsActivityTCXParser activityTCXParserWithActivityId:self.activity.activityId andData:data];
            fitAct = parser.activity;
        }else{
            NSString * activityId = self.activity.activityId;
            if( activityId == nil){
                activityId = [[fileName lastPathComponent] stringByDeletingPathExtension];
            }
            fitAct = RZReturnAutorelease([[GCActivity alloc] initWithId:activityId fitFileData:data fitFilePath:fp startTime:useStartDate]);
        }
        if( fitAct ){ // check if we could parse. Could be no fit file available.
            if( self.activity == nil){
                self.activity = fitAct;
            }else{
                [self.activity updateSummaryDataFromActivity:fitAct];
                [self.activity updateTrackpointsFromActivity:fitAct];
                [self.activity saveTrackpoints:self.activity.trackpoints andLaps:self.activity.laps];
            }
        }
    }
    [self processDone];
}

+(GCActivity*)testForActivity:(GCActivity*)act withFilesIn:(NSString*)path{
    
    GCConnectStatsRequestFitFile * req = [GCConnectStatsRequestFitFile requestWithActivity:act andNavigationController:nil];
    
    BOOL isDirectory = false;
    
    if( [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory]){
        NSString * fp = isDirectory ? [path stringByAppendingPathComponent:[req fitFileName]] : path;

        [req processParse:fp];
    }
    return req.activity;
}

@end
