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
    GCAppDelegate * appDelegate = (GCAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate versionSummary];
}

-(void)checkDb{
    RZLog(RZLogInfo, @"Memory %@", [RZMemory formatMemoryInUse]);
    [GCActivitiesOrganizer sanityCheckDb:[GCAppGlobal db]];
    [GCWebConnect sanityCheck];
    [self configCheck];
}

-(NSURLRequest*)urlRequest{
    NSString * aURL = @"https://ro-z.net/connectstats/bugreport.php?dir=bugs";
#if TARGET_IPHONE_SIMULATOR
    aURL = @"https://localhost.ro-z.me/prod/bugreport/new?verbose=1";
    aURL = @"https://connectstats.app/prod/bugreport/new?verbose=1";
#endif
    //aURL = @"https://ro-z.net/connectstats/bugreport.php?dir=bugs";
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
    DeviceUtil * deviceUtil = RZReturnAutorelease([[DeviceUtil alloc] init]);
    NSMutableDictionary * pData = [NSMutableDictionary dictionaryWithDictionary:@{
                            @"systemName": [UIDevice currentDevice].systemName,
                            @"applicationName": applicationName,
                            @"systemVersion": [UIDevice currentDevice].systemVersion,
                            @"platformString": [deviceUtil hardwareDescription] ?: [deviceUtil hardwareString],
                            @"version": [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"],
                            @"commonid": [GCAppGlobal configGetString:CONFIG_BUG_COMMON_ID defaultValue:kBugNoCommonId],
                            }];
    if (![[GCAppGlobal configGetString:CONFIG_BUG_COMMON_ID defaultValue:kBugNoCommonId] isEqualToString:kBugNoCommonId]) {
        RZLog(RZLogInfo, @"Had previous bug report: id=%@", [GCAppGlobal configGetString:CONFIG_BUG_COMMON_ID defaultValue:kBugNoCommonId] );
    }
    NSString * log = RZLogFileContent();
    
    NSString * bugpath = [RZFileOrganizer writeableFilePath:kBugFilename];
    
    NSError * err = nil;
    
    OZZipFile * zipFile= [[OZZipFile alloc] initWithFileName:bugpath mode:OZZipFileModeCreate error:&err];
    
    OZZipWriteStream *stream= [zipFile writeFileInZipWithName:@"bugreport.log" compressionLevel:OZZipCompressionLevelBest];
    [stream writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
    [stream finishedWriting];
    
    NSDictionary * dict = [self jsonifiedMissingFields];
    if( dict.count > 0 ){
        NSData * data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingSortedKeys|NSJSONWritingPrettyPrinted error:nil];
        if( data ){
            OZZipWriteStream *crashstream= [zipFile writeFileInZipWithName:@"missing_fields.json" compressionLevel:OZZipCompressionLevelBest];
            NSData * data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingSortedKeys|NSJSONWritingPrettyPrinted error:nil];
            [crashstream writeData:data];
            [crashstream finishedWriting];
        }
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
            OZZipWriteStream *dbstream = [zipFile writeFileInZipWithName:@"activities_bugreport.db"
                                                        compressionLevel:OZZipCompressionLevelBest];
            NSData * data = [NSData dataWithContentsOfFile:dbfile];
            [dbstream writeData:data];
            [dbstream finishedWriting];
        }
        
        NSString * derivedfile = [RZFileOrganizer writeableFilePathIfExists:[[GCAppGlobal profile] currentDerivedDatabasePath]];
        if (derivedfile) {
            OZZipWriteStream *dbstream = [zipFile writeFileInZipWithName:@"derived_bugreport.db"
                                                        compressionLevel:OZZipCompressionLevelBest];
            NSData * data = [NSData dataWithContentsOfFile:derivedfile];
            [dbstream writeData:data];
            [dbstream finishedWriting];
        }
    }
    
    NSString * settingsFile = [RZFileOrganizer writeableFilePathIfExists:@"settings.plist"];
    if( settingsFile ){
        OZZipWriteStream *dbstream = [zipFile writeFileInZipWithName:@"settings_bugreport.plist" compressionLevel:OZZipCompressionLevelBest];
        NSData * data = [NSData dataWithContentsOfFile:settingsFile];
        [dbstream writeData:data];
        [dbstream finishedWriting];
    }
    
    NSDictionary * jsonSettings = [[GCAppGlobal settings] dictionaryWithJSONTypesOnly];
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:jsonSettings options:(NSJSONWritingPrettyPrinted|NSJSONWritingSortedKeys) error:&err];
    if( jsonData ){
        OZZipWriteStream *dbstream = [zipFile writeFileInZipWithName:@"settings_bugreport.json" compressionLevel:OZZipCompressionLevelBest];
        [dbstream writeData:jsonData];
        [dbstream finishedWriting];
    }
    
    
    [zipFile close];
    [zipFile release];

    NSDictionary * attribute = [[NSFileManager defaultManager] attributesOfItemAtPath:bugpath error:&err];
    pData[@"filesize"] = attribute[NSFileSize];
    
    NSMutableURLRequest * urlRequest = [RZRemoteDownload urlRequestWithURL:aUrl
                                                                  postData:(NSDictionary*)pData
                                                                  fileName:@"bugreport.zip"
                                                                  filePath:bugpath tmpPath:nil];

    return urlRequest;
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
