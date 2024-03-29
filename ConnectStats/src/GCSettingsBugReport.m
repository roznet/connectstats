//  MIT License
//
//  Created on 13/01/2018 for ConnectStats
//
//  Copyright (c) 2018 Brice Rosenzweig
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



#import "GCSettingsBugReport.h"
#import "GCAppGlobal.h"
@import RZExternal;
#import "GCActivitiesCacheManagement.h"
#import "GCActivitiesOrganizer.h"
#import "GCAppGlobal.h"
#import "GCService.h"
#import "GCViewConfig.h"
#import "GCAppDelegate.h"
#import "GCFieldCache.h"
#import "ConnectStats-Swift.h"

NSString * kBugFilename = @"bugreport.zip";
NSString * kBugNoCommonId = @"-1";

@interface GCSettingsBugReport ()
@property (nonatomic,assign) BOOL archiveSuccess;
@property (nonatomic,retain) NSURLSessionDataTask * statusTask;
@end

@implementation GCSettingsBugReport

-(void)dealloc{
    [_statusTask release];
    
    [super dealloc];
}

+(GCSettingsBugReport*)bugReport{
    return [[[GCSettingsBugReport alloc] init] autorelease];
}

-(void)configCheck{
    NSDictionary * settings = [GCAppGlobal settings];
    NSArray*keys=[@[
                   
                   CONFIG_CONNECTSTATS_USE         ,
                   CONFIG_CONNECTSTATS_TOKEN_ID    ,
                   CONFIG_CONNECTSTATS_USER_ID
                   
                   ] sortedArrayUsingSelector:@selector(compare:)];
    for (NSString * key in keys) {
        id val = settings[key];
        if (val) {
            RZLog(RZLogInfo, @"setting.%@=%@",key,val);
        }else{
            val = [[GCAppGlobal profile] configHasKey:key];
            if( val ){
                RZLog(RZLogInfo, @"profile.%@=%@",key,val);
            }
        }
    }
    
    for (gcService service=0; service<gcServiceEnd; service++) {
        GCService * serviceObj = [GCService service:service];
        if ([[GCAppGlobal profile] serviceEnabled:service]) {
            RZLog(RZLogInfo, @"Enabled:  %@", [serviceObj statusDescription] );
        }
    }
    [GCAppGlobal versionSummary];
    
    NSString * ckey = [GCAppGlobal credentialsForService:@"garmin" andKey:@"consumer_key"];
    NSString * cid = [GCAppGlobal credentialsForService:@"strava" andKey:@"client_id"];
    NSString * token = [[GCAppGlobal profile] currentPasswordForService:gcServiceConnectStats];
    NSString * csStatus = token.length != 0 ? @"Has CS Token" : @"Missing CS Token";
    
    RZLog(RZLogInfo, @"consumer_key=%@, client_id=%@, %@", ckey, cid, csStatus);
    
    
}

-(void)checkDb{
    RZLog(RZLogInfo, @"Memory %@", [RZMemory formatMemoryInUse]);
    [GCActivitiesOrganizer sanityCheckDb:[GCAppGlobal db]];
    [GCWebConnect sanityCheck];
    [self configCheck];
}

-(NSURLRequest*)urlRequest{
    NSString * aURL = GCWebConnectStatsBugReport([GCAppGlobal webConnectsStatsConfig]);
#if TARGET_IPHONE_SIMULATOR
    //aURL = @"https://localhost.ro-z.me/dev/bugreport/new?verbose=1";
#endif
    return [self urlResquestFor:aURL];
}

-(void)prepareRequest:(void(^)(NSURLRequest * request))cb{
    NSString * aURL = GCWebConnectStatsBugReportStatus([GCAppGlobal webConnectsStatsConfig]);
#if TARGET_IPHONE_SIMULATOR
    //aURL = @"https://localhost.ro-z.me/dev/bugreport/status";
#endif
    
    NSDictionary<NSString*,NSString*>*pData = [self createBugReportDictionaryWithExtra:@{}];
    NSURL * statusURL = [NSURL URLWithString:RZWebEncodeURLwGet(aURL, pData)];
    
    self.statusTask = [[NSURLSession sharedSession] dataTaskWithURL:statusURL completionHandler:^(NSData * data, NSURLResponse*response, NSError * error ){
        BOOL canIncludeActivityFiles = false;
        if( error == nil){
            if( [response isKindOfClass:[NSHTTPURLResponse class]]){
                NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse*)response;
                if( httpResponse.statusCode == 200){
                    NSError * jsonError = nil;
                    NSDictionary * status = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                    if( [status isKindOfClass:[NSDictionary class]] && [status[@"status"] respondsToSelector:@selector(integerValue)] ){
                        if( [status[@"status"] integerValue] == 1){
                            canIncludeActivityFiles = true;
                        }
                    }
                }
            }else{
                RZLog(RZLogError, @"Invalid Response %@", response);
            }
        }else{
            RZLog(RZLogError, @"Status check error %@", error);
        }
        if( ! canIncludeActivityFiles ){
            RZLog(RZLogInfo, @"Bugreport without valid status, disabling activityFiles include");
            self.includeActivityFiles = false;
        }
        cb([self urlRequest]);
    }];
    
    [self.statusTask resume];
}

- (NSURLRequest*)urlResquestFor:(NSString*)aUrl;
{
    [self checkDb];
    
    NSString * bugpath = [RZFileOrganizer writeableFilePath:kBugFilename];
    
    self.archiveSuccess = [self createBugReportArchive];
    
    NSError * err = nil;
    NSDictionary * attribute = [[NSFileManager defaultManager] attributesOfItemAtPath:bugpath error:&err];
    NSDictionary<NSString*,NSString*>*extra = @{ @"filesize": [attribute[NSFileSize] description]  };
    NSDictionary<NSString*,NSString*>*pData = [self createBugReportDictionaryWithExtra:extra];

    NSMutableURLRequest * urlRequest = [RZRemoteDownload urlRequestWithURL:aUrl
                                                                  postData:(NSDictionary*)pData
                                                                  fileName:@"bugreport.zip"
                                                                  filePath:bugpath
                                                                   tmpPath:nil];

    return urlRequest;
}

-(NSData*)missingFieldsAsJson{
    NSData * data = nil;
    NSDictionary * dict = [self jsonifiedMissingFields];
    if( dict.count > 0 ){
        data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingSortedKeys|NSJSONWritingPrettyPrinted error:nil];
    }
    return data;
}

-(NSDictionary*)jsonifiedMissingFields{
    GCFieldCache * cache = [GCFields fieldCache];
    NSDictionary * missing = [cache missingPredefinedField];

    NSMutableDictionary * display = [NSMutableDictionary dictionary];
    NSMutableDictionary * uom     = [NSMutableDictionary dictionary];
    
    for (GCField * field  in missing) {
        GCFieldInfo * info = missing[field];
        if( info.displayName ){
            display[field.key] = @{ @"en": info.displayName };
        }
        if( uom[field.key] == nil){
            uom[field.key] = [NSMutableDictionary dictionary];
        }
        if( info.unit.key && field.activityType){
            uom[field.key][field.activityType] = @{@"metric":info.unit.key};
        }
    }
    
    return @{ @"gc_fields_display": display, @"gc_fields_uom": uom};
}

-(void)cleanupAndReset{
    [RZFileOrganizer removeEditableFile:kBugFilename];
    NSArray * crashes = [GCActivitiesCacheManagement crashFiles];
    for (NSString * file in crashes) {
        [RZFileOrganizer removeEditableFile:file];
    }
    if (self.includeErrorFiles) {
        NSArray * errors = [GCActivitiesCacheManagement errorFiles];
        for (NSString * file in errors) {
            [RZFileOrganizer removeEditableFile:file];
        }
    }
    if( self.archiveSuccess ){
        RZLog(RZLogInfo,@"BugReport sent");
    }else{
        RZLog(RZLogInfo,@"BugReport not complete, keeping old log");
    }
}

+(void)checkBugReportEnabled:(void (^)(BOOL))cb{
}
@end
