//  MIT Licence
//
//  Created on 16/02/2013.
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

#import "GCSettingsHelpViewController.h"
#import "GCViewIcons.h"
@import Flurry_iOS_SDK;
#import "GCAppGlobal.h"
#import "GCViewConfig.h"


@interface GCSettingsHelpViewController ()
@property (nonatomic,retain) WKWebView * webView;
@property (nonatomic,retain) NSURL * url;
@end

@implementation GCSettingsHelpViewController
-(void)dealloc{
    [_webView release];
    [_url release];
    
    [super dealloc];
}


+(GCSettingsHelpViewController*)helpViewControllerFor:(NSURL*)url{
    GCSettingsHelpViewController * rv = RZReturnAutorelease([[GCSettingsHelpViewController alloc] initWithNibName:nil bundle:nil]);
    if (rv) {
        rv.url = url;
        if( rv.url == nil){
            NSString * aUrl = @"https://ro-z.net/blog/connectstats/documentation/";
            
#if TARGET_IPHONE_SIMULATOR
            //aUrl = @"http://localhost/connectstats/connectstatsdoc.php";
#endif
            rv.url = [NSURL URLWithString:aUrl];
        }
    }
    return rv;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	WKWebView *contentView	= [[WKWebView alloc] initWithFrame: self.view.frame];
    contentView.navigationDelegate = self;

    self.webView = contentView;
    
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:self.url];

    [contentView loadRequest:urlRequest];
    [self.view addSubview:contentView];
    UIImage * img = [GCViewIcons navigationIconFor:gcIconNavBack];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self.webView action:@selector(goBack)] autorelease];
	[contentView release];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [GCViewConfig setupViewController:self];
    self.webView.frame = self.view.frame;
    [Flurry logEvent:EVENT_HELP];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
