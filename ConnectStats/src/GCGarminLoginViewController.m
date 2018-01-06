//  MIT Licence
//
//  Created on 20/02/2014.
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

#import "GCGarminLoginViewController.h"

@interface GCGarminLoginViewController ()

@end

@implementation GCGarminLoginViewController
+(GCGarminLoginViewController*)loginView:(gcLoginMethod)meth forDelegate:(NSObject<GCGarminLoginDelegate>*)del{
    GCGarminLoginViewController*rv= [[[GCGarminLoginViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    if (rv) {
        rv.delegate = del;
        rv.method = meth;
    }
    return rv;
}
-(void)dealloc{
    _webView.delegate = nil;
    if (_webView.loading) {
        [_webView stopLoading];
    }
    [_webView release];
    [_serviceTicket release];

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

	UIWebView *contentView	= [[UIWebView alloc] initWithFrame: self.view.frame];
    contentView.scrollView.scrollEnabled = true;
    contentView.delegate = self;

    self.webView = contentView;

    NSString * aUrl = nil;
    // works only for activity
    switch (self.method) {
        case gcLoginMethodGarminConnectApp:
            aUrl =@"https://sso.garmin.com/sso/login";
            break;
        case gcLoginMethodGarminConnectSite:
            aUrl = @"http://connect.garmin.com/en-US/signin";
            break;
    }
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:aUrl]];

    [contentView loadRequest:urlRequest];
    [self.view addSubview:contentView];

}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.delegate loginSuccess];
    self.delegate = nil;
    if ((self.webView).loading) {
        [self.webView stopLoading];
    }
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
    NSString *html = [_webView stringByEvaluatingJavaScriptFromString:
                      @"document.body.innerHTML"];
    switch (self.method) {
        case gcLoginMethodGarminConnectSite:
        {

            break;
        }
        case gcLoginMethodGarminConnectApp:
        {
            NSRange range = [html rangeOfString:@"{serviceUrl:"];
            if (range.location != NSNotFound) {
                NSString * jsonstr = [html substringFromIndex:range.location];
                NSRange service = [jsonstr rangeOfString:@"serviceTicket: '"];
                NSString * ticketbeg = [jsonstr substringFromIndex:service.location +16];
                NSRange ticketend = [ticketbeg rangeOfString:@"'}"];
                NSString * ticket = [ticketbeg substringToIndex:ticketend.location];

                if (self.serviceTicket==nil) {
                    NSString * aUrl = [NSString stringWithFormat:@"http://connect.garmin.com/post-auth/login?ticket=%@", ticket];
                    NSMutableURLRequest * theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:aUrl]];

                    self.serviceTicket = ticket;
                    [_webView loadRequest:theRequest];
                }
            }
            break;
        }
    }
}

-(BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    //NSLog(@"Start: %@",[[[request URL] absoluteString] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding]);
    if ([[request.URL.absoluteString stringByRemovingPercentEncoding] hasPrefix:@"http://connect.garmin.com/dashboard"]) {
        RZLog(RZLogInfo,@"WebLogin success");
        [self.delegate loginSuccess];
        self.delegate = nil;
        [webView stopLoading];
        [self.navigationController popViewControllerAnimated:YES];
        return false;
    }
    return TRUE;
}

@end
