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


NSString * kBugFilename = @"bugreport.zip";
NSString * kBugNoCommonId = @"-1";

@implementation GCSettingsBugReport

+(GCSettingsBugReport*)bugReport{
    return [[[GCSettingsBugReport alloc] init] autorelease];
}

-(void)configCheck{
    NSDictionary * settings = [GCAppGlobal settings];
    NSArray*keys=[@[
                   CONFIG_FILTER_BAD_VALUES        ,
                   CONFIG_FILTER_SPEED_BELOW       ,
                   CONFIG_FILTER_POWER_ABOVE       ,
                   CONFIG_FILTER_BAD_ACCEL         ,
                   CONFIG_FILTER_ADJUST_FOR_LAP    ,
                   CONFIG_UNIT_SYSTEM              ,
                   CONFIG_STRIDE_STYLE             ,
                   CONFIG_FIRST_DAY_WEEK           ,
                   
                   CONFIG_ZONE_PREFERRED_SOURCE    ,
                   
                   CONFIG_REFRESH_STARTUP          ,
                   CONFIG_CONTINUE_ON_ERROR        ,
                   CONFIG_GARMIN_USE_MODERN        ,
                   CONFIG_MERGE_IMPORT_DUPLICATE   ,
                   
                   CONFIG_USE_MOVING_ELAPSED       ,
                   CONFIG_USE_MAP                  ,
                   CONFIG_FASTER_MAPS              ,
                   CONFIG_STATS_INLINE_GRAPHS      ,
                   CONFIG_PERIOD_TYPE              ,
                   
                   CONFIG_GRAPH_LAP_OVERLAY        ,
                   CONFIG_MAPS_INLINE_GRADIENT     ,
                   CONFIG_ZONE_GRAPH_HORIZONTAL    ,
                   
                   CONFIG_QUICK_FILTER             ,
                   CONFIG_QUICK_FILTER_TYPE        ,
                   
                   CONFIG_GARMIN_FIT_DOWNLOAD      ,
                   CONFIG_GARMIN_FIT_MERGE         ,

                   
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
    if ([[GCAppGlobal profile] serviceEnabled:gcServiceGarmin]) {
        gcGarminLoginMethod method = (gcGarminLoginMethod)[[GCAppGlobal profile] configGetInt:CONFIG_GARMIN_LOGIN_METHOD defaultValue:GARMINLOGIN_DEFAULT];
        NSArray * methods = [GCViewConfig validChoicesForGarminLoginMethod];
        RZLog(RZLogInfo, @"Garmin Method %@", method < methods.count ? methods[method] : @"INVALID");
    }
    
}

-(void)checkDb{
    RZLog(RZLogInfo, @"Memory %@", [RZMemory formatMemoryInUse]);
    [GCActivitiesOrganizer sanityCheckDb:[GCAppGlobal db]];
    [GCWebConnect sanityCheck];
    [self configCheck];
}

-(NSURLRequest*)urlRequest{
    NSString * aURL = @"https://www.ro-z.net/connectstats/bugreport.php?dir=bugs";
#if TARGET_IPHONE_SIMULATOR
    //aURL = @"http://localhost/connectstats/bugreport.php?dir=bugs";
#endif

    return [self urlResquestFor:aURL];
}

- (NSURLRequest*)urlResquestFor:(NSString*)aUrl;
{
    if ([GCAppGlobal worker]) {
        dispatch_sync([GCAppGlobal worker],^(){
            [self checkDb];
        });
        
    }else{
        // in multiple failure to start, no worker thread yet
        [self checkDb];
    }
    
    NSString * applicationName = [GCAppGlobal connectStatsVersion] ? @"ConnectStats" : @"HealthStats";
    
    NSDictionary * pData =@{
                            @"systemName": [UIDevice currentDevice].systemName,
                            @"applicationName": applicationName,
                            @"systemVersion": [UIDevice currentDevice].systemVersion,
                            @"platformString": [DeviceUtil hardwareDescription],
                            @"version": [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"],
                            @"commonid": [GCAppGlobal configGetString:CONFIG_BUG_COMMON_ID defaultValue:kBugNoCommonId],
                            };
    if (![[GCAppGlobal configGetString:CONFIG_BUG_COMMON_ID defaultValue:kBugNoCommonId] isEqualToString:kBugNoCommonId]) {
        RZLog(RZLogInfo, @"Had previous bug report: id=%@", [GCAppGlobal configGetString:CONFIG_BUG_COMMON_ID defaultValue:kBugNoCommonId] );
    }
    NSString * log = RZLogFileContent();
    
    NSString * bugpath = [RZFileOrganizer writeableFilePath:kBugFilename];
    
    OZZipFile * zipFile= [[OZZipFile alloc] initWithFileName:bugpath mode:OZZipFileModeCreate];
    
    OZZipWriteStream *stream= [zipFile writeFileInZipWithName:@"bugreport.log" compressionLevel:OZZipCompressionLevelBest];
    [stream writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
    [stream finishedWriting];
    
    NSArray * crashes = [GCActivitiesCacheManagement crashFiles];
    for (NSString * file in crashes) {
        OZZipWriteStream *crashstream= [zipFile writeFileInZipWithName:file compressionLevel:OZZipCompressionLevelBest];
        NSData * data = [NSData dataWithContentsOfFile:[RZFileOrganizer writeableFilePath:file]];
        [crashstream writeData:data];
        [crashstream finishedWriting];
    }
    
    if (self.includeErrorFiles) {
        NSArray * errors = [GCActivitiesCacheManagement errorFiles];
        for (NSString * file in errors) {
            OZZipWriteStream *errorstream= [zipFile writeFileInZipWithName:file compressionLevel:OZZipCompressionLevelBest];
            NSData * data = [NSData dataWithContentsOfFile:[RZFileOrganizer writeableFilePath:file]];
            [errorstream writeData:data];
            [errorstream finishedWriting];
        }
    }
    
    if (self.includeActivityFiles) {
        if ([[GCAppGlobal organizer] currentActivity]) {
            NSString * aName = [NSString stringWithFormat:@"track_%@.db", [[GCAppGlobal organizer] currentActivity].activityId];
            NSString * currActivity = [RZFileOrganizer writeableFilePathIfExists:aName];
            if (currActivity) {
                OZZipWriteStream *filestream = [zipFile writeFileInZipWithName:aName compressionLevel:OZZipCompressionLevelBest];
                NSData * data = [NSData dataWithContentsOfFile:currActivity];
                [filestream writeData:data];
                [filestream finishedWriting];
            }
        }
        
        NSString * dbfile = [RZFileOrganizer writeableFilePathIfExists:[[GCAppGlobal profile] currentDatabasePath]];
        if (dbfile) {
            OZZipWriteStream *dbstream = [zipFile writeFileInZipWithName:[[GCAppGlobal profile] currentDatabasePath]
                                                        compressionLevel:OZZipCompressionLevelBest];
            NSData * data = [NSData dataWithContentsOfFile:dbfile];
            [dbstream writeData:data];
            [dbstream finishedWriting];
        }
        
        NSString * derivedfile = [RZFileOrganizer writeableFilePathIfExists:[[GCAppGlobal profile] currentDerivedDatabasePath]];
        if (derivedfile) {
            OZZipWriteStream *dbstream = [zipFile writeFileInZipWithName:[[GCAppGlobal profile] currentDerivedDatabasePath]
                                                        compressionLevel:OZZipCompressionLevelBest];
            NSData * data = [NSData dataWithContentsOfFile:derivedfile];
            [dbstream writeData:data];
            [dbstream finishedWriting];
        }
        
        NSString * settingsFile = [RZFileOrganizer writeableFilePathIfExists:@"settings.plist"];
        if( settingsFile ){
            OZZipWriteStream *dbstream = [zipFile writeFileInZipWithName:@"settings_debug.plist" compressionLevel:OZZipCompressionLevelBest];
            NSData * data = [NSData dataWithContentsOfFile:settingsFile];
            [dbstream writeData:data];
            [dbstream finishedWriting];
        }
    }
    
    [zipFile close];
    [zipFile release];
    
    NSMutableURLRequest * urlRequest = [RZRemoteDownload urlRequestWithURL:aUrl
                                                                  postData:(NSDictionary*)pData
                                                                  fileName:@"bugreport.zip"
                                                                  filePath:bugpath tmpPath:nil];

    return urlRequest;
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
