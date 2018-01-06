//  MIT Licence
//
//  Created on 19/01/2013.
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

#import "GCSettingsBugReportViewController.h"
@import RZExternal;
#import "GCActivitiesCacheManagement.h"
#import "GCActivitiesOrganizer.h"
#import "GCAppGlobal.h"
#import "GCService.h"
#import "GCViewConfig.h"

#define BUG_FILENAME @"bugreport.zip"
#define BUG_NO_COMMON_ID @"-1"

@interface GCSettingsBugReportViewController ()

@end

@implementation GCSettingsBugReportViewController
-(void)dealloc{

    [_webView release];
    [_parent release];
    [_hud release];

    [super dealloc];
}
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.webView.frame = self.view.frame;
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.webView.frame = self.view.frame;
}
-(void)configCheck{
    NSDictionary * settings = [GCAppGlobal settings];
    NSArray*keys=@[
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

                   ];
    for (NSString * key in keys) {
        id val = settings[key];
        if (val) {
            RZLog(RZLogInfo, @"%@=%@",key,val);
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

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view.
	UIWebView *contentView	= [[UIWebView alloc] initWithFrame: self.view.frame];
    contentView.delegate = self;

    if ([GCAppGlobal worker]) {
        dispatch_sync([GCAppGlobal worker],^(){
            [self checkDb];
        });

    }else{
        // in multiple failure to start, no worker thread yet
        [self checkDb];
    }

    self.webView = contentView;
    NSString * aUrl = @"https://www.ro-z.net/connectstats/bugreport.php?dir=bugs";
#if TARGET_IPHONE_SIMULATOR
    //aUrl = @"http://localhost/connectstats/bugreport.php?dir=bugs";
#endif
    NSString * applicationName = [GCAppGlobal connectStatsVersion] ? @"ConnectStats" : @"HealthStats";

    NSDictionary * pData =@{
                           @"systemName": [UIDevice currentDevice].systemName,
                           @"applicationName": applicationName,
                           @"systemVersion": [UIDevice currentDevice].systemVersion,
                           @"platformString": [DeviceUtil hardwareDescription],
                           @"version": [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"],
                           @"commonid": [GCAppGlobal configGetString:CONFIG_BUG_COMMON_ID defaultValue:BUG_NO_COMMON_ID],
                           };
    if (![[GCAppGlobal configGetString:CONFIG_BUG_COMMON_ID defaultValue:BUG_NO_COMMON_ID] isEqualToString:BUG_NO_COMMON_ID]) {
        RZLog(RZLogInfo, @"Had previous bug report: id=%@", [GCAppGlobal configGetString:CONFIG_BUG_COMMON_ID defaultValue:BUG_NO_COMMON_ID] );
    }
    NSString * log = RZLogFileContent();

    NSString * bugpath = [RZFileOrganizer writeableFilePath:BUG_FILENAME];

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

    }

    [zipFile close];
    [zipFile release];

    NSMutableURLRequest * urlRequest = [RZRemoteDownload urlRequestWithURL:aUrl
                                                                postData:(NSDictionary*)pData
                                                                fileName:@"bugreport.zip"
                                                                filePath:bugpath tmpPath:nil];

    [contentView loadRequest:urlRequest];

    [self.view addSubview:contentView];
    self.hud =[MBProgressHUD showHUDAddedTo:contentView animated:YES];
    self.hud.labelText = @"Preparing Report";

	[contentView release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    RZLog(RZLogWarning, @"memory warning %@", [RZMemory formatMemoryInUse]);
    // Dispose of any resources that can be recreated.
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}
-(void)webViewDidFinishLoad:(UIWebView *)aWebView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [RZFileOrganizer removeEditableFile:BUG_FILENAME];
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
    NSString * commonid = [aWebView stringByEvaluatingJavaScriptFromString:@"document.getElementById('commonid').value"];
    if (commonid.integerValue>1) {
        [GCAppGlobal configSet:CONFIG_BUG_COMMON_ID stringVal:commonid];
        [GCAppGlobal saveSettings];
    }
    RZLogReset();
    [self.hud hide:YES];
    if (self.parent) {
        [(self.parent).tableView reloadData];
    }
}

@end
