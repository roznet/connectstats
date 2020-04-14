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
#import "GCSettingsBugReport.h"

#define BUG_FILENAME @"bugreport.zip"
#define BUG_NO_COMMON_ID @"-1"

@interface GCSettingsBugReportViewController ()
@property (nonatomic,retain) GCSettingsBugReport * report;
@property (nonatomic,retain) NSURLSessionDataTask * task;
@property (nonatomic,retain) NSURLRequest * urlRequest;
@end

@implementation GCSettingsBugReportViewController
-(void)dealloc{
    [_report release];
    [_webView release];
    [_parent release];
    [_hud release];
    [_task release];
    [_urlRequest release];
    
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
    [GCViewConfig setupViewController:self];
    self.webView.frame = self.view.frame;
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.webView.frame = self.view.frame;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view.
	WKWebView *contentView	= [[WKWebView alloc] initWithFrame: self.view.frame];
    contentView.navigationDelegate = self;

    self.report = [GCSettingsBugReport bugReport];
    self.report.includeErrorFiles = self.includeErrorFiles;
    self.report.includeActivityFiles = self.includeActivityFiles;
    
    self.webView = contentView;

    [self.view addSubview:contentView];
    self.hud =[MBProgressHUD showHUDAddedTo:contentView animated:YES];
    self.hud.labelText = @"Preparing Report";

	[contentView release];
    self.urlRequest = self.report.urlRequest;
    
    self.task = [[NSURLSession sharedSession] dataTaskWithRequest:self.urlRequest
                                        completionHandler:^(NSData*data,NSURLResponse*response,NSError*error){
        if (error) {
            RZLog(RZLogError,@"Error loading bugreport %@",error);
        }else{
            NSString *encodingName = [response textEncodingName];
            NSStringEncoding encodingType = encodingName ? CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)encodingName)) : NSUTF8StringEncoding;
            NSString * html = RZReturnAutorelease([[NSString alloc] initWithData:data encoding:encodingType]);
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self.webView loadHTMLString:html baseURL:self.urlRequest.URL];;
            });
        }
    }];
    if (self.task) {
        [self.task resume];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    RZLog(RZLogWarning, @"memory warning %@", [RZMemory formatMemoryInUse]);
    // Dispose of any resources that can be recreated.
}


-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [self.report cleanupAndReset];
    [self.webView evaluateJavaScript:@"document.getElementById('commonid').value" completionHandler:^(NSString * commonid, NSError*error){
        if (commonid.integerValue>1) {
            [GCAppGlobal configSet:CONFIG_BUG_COMMON_ID stringVal:commonid];
            [GCAppGlobal saveSettings];
        }

        [self.hud hide:YES];
        if (self.parent) {
            [(self.parent).tableView reloadData];
        }
    }];
}

@end
