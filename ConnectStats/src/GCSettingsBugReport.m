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
@import RZExternalUniversal;
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

@implementation GCSettingsBugReport

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
    if([[GCAppGlobal profile] configGetBool:CONFIG_SHARING_STRAVA_AUTO defaultValue:false]){
        RZLog(RZLogInfo, @"Enabled:  Strava Upload");
    }
    [GCAppGlobal versionSummary];
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

- (NSURLRequest*)urlResquestFor:(NSString*)aUrl;
{
    [self checkDb];
    
    NSString * bugpath = [RZFileOrganizer writeableFilePath:kBugFilename];
    
    [self createBugReportArchive];
    
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
    RZLogReset();
}
@end
