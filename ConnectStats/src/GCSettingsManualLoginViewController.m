//  MIT Licence
//
//  Created on 01/03/2013.
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

#import "GCSettingsManualLoginViewController.h"
#import "GCAppGlobal.h"
#import "GCViewIcons.h"
#import "GCWebConnect.h"
#import "GCActivitiesOrganizer.h"

@interface GCSettingsManualLoginViewController ()

@end

@implementation GCSettingsManualLoginViewController
-(void)dealloc{
    [[GCAppGlobal web] detach:self];
    [self.webView setDelegate:nil];
    [_debugLog release];
    [_webView release];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	UIWebView *contentView	= [[UIWebView alloc] initWithFrame: self.view.frame];
    contentView.scrollView.scrollEnabled = true;
    contentView.delegate = self;

    self.webView = contentView;

    NSString * aUrl = @"http://connect.garmin.com/en-US/signin";
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:aUrl]];

    [contentView loadRequest:urlRequest];
    [self.view addSubview:contentView];
    UIImage * img = [GCViewIcons navigationIconFor:gcIconNavBack];

    UIBarButtonItem * back = [[[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self.webView action:@selector(goBack)] autorelease];
    UIBarButtonItem * refresh = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Refresh", @"ManualLogin")
                                                                  style:UIBarButtonItemStylePlain target:self action:@selector(executeRefresh)] autorelease];
    UIBarButtonItem * test = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"List", @"ManualLogin")
                                                               style:UIBarButtonItemStylePlain target:self action:@selector(executeTest)] autorelease];
    UIBarButtonItem * test2 = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"One", @"ManualLogin") style:UIBarButtonItemStylePlain target:self action:@selector(executeTest2)] autorelease];

    self.navigationItem.rightBarButtonItems = @[ test2,test,refresh,back];
	[contentView release];
}

-(void)executeTest{
    NSString * aUrl = @"http://connect.garmin.com/proxy/activity-search-service-1.2/json/activities";
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:aUrl]];

    [self.webView loadRequest:urlRequest];
}

-(void)executeTest2{
    NSString * aUrl = [NSString stringWithFormat:@"http://connect.garmin.com/proxy/activity-service-1.3/json/activityDetails/%@",
                       [[GCAppGlobal organizer] currentActivity].activityId];
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:aUrl]];

    [self.webView loadRequest:urlRequest];
}

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    NSString * msg = [[GCAppGlobal web] currentDescription];
    NSString * url = [[GCAppGlobal web] currentUrl];
    if (url) {
        msg = [NSString stringWithFormat:@"<a href=\"%@\">%@</a>", url, msg];
    }

    if (self.debugLog) {
        [self.debugLog addObject:msg];
        msg = [self.debugLog componentsJoinedByString:@"\n"];
    }
    if ([theInfo.stringInfo isEqualToString:NOTIFY_END]) {
        [[GCAppGlobal web] detach:self];
    }else if ([theInfo.stringInfo isEqualToString:NOTIFY_ERROR]) {
        [[GCAppGlobal web] detach:self];
    }

    NSString * html = [NSString stringWithFormat:@"<p>Refreshing</p><pre>%@</pre>", msg];
    [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:@"https://www.ro-z.net/connectstats"]];
}

-(void)executeRefresh{
    self.debugLog = [NSMutableArray arrayWithCapacity:10];
    GCWebConnect * web = [GCAppGlobal web];

    if (web.requests && web.requests.count > 0) {
        [self.debugLog addObject:@"--- previous refresh"];
        for (id<GCWebRequest> one in web.requests) {
            NSString * u = [one url];
            NSString * d = [one description];
            [self.debugLog addObject:[NSString stringWithFormat:@"<a href=\"%@\">%@</a>", u, d]];
        }
        [self.debugLog addObject:@"--- current refresh"];
    }

    [GCAppGlobal searchAllActivities];
    [[GCAppGlobal web] attach:self];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    (self.webView).frame = self.view.frame;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    RZLog(RZLogError, @"request=%@ error=%@",[webView request],error);
    [webView loadHTMLString:[NSString stringWithFormat:@"<pre>Connection Error:\n%@\n%@",webView.request,error] baseURL:[NSURL URLWithString:@"http://connect.garmin.com"]];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    RZLog(RZLogInfo, @"request=%@",[webView request]);
}

@end
