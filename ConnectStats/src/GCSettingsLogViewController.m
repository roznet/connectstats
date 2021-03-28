//  MIT Licence
//
//  Created on 20/11/2013.
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

#import "GCSettingsLogViewController.h"
#import "GCViewIcons.h"
#import "GCViewConfig.h"

@interface GCSettingsLogViewController ()

@end

@implementation GCSettingsLogViewController

-(void)dealloc{
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

    WKWebView *contentView	= [[WKWebView alloc] initWithFrame: self.view.frame];
    contentView.navigationDelegate = self;

    self.webView = contentView;
    [self.view addSubview:contentView];
    [contentView release];

    UINavigationItem * item = self.navigationItem;

    UIImage * img1= [GCViewIcons navigationIconFor:gcIconNavRedo];

    UIBarButtonItem * rightButton1 = [[UIBarButtonItem alloc] initWithImage:img1 style:UIBarButtonItemStylePlain target:self action:@selector(reloadLog)];

#if TARGET_IPHONE_SIMULATOR
    UIImage * img2= [GCViewIcons navigationIconFor:gcIconNavEye];
    UIBarButtonItem * rightButton2 = [[UIBarButtonItem alloc] initWithImage:img2 style:UIBarButtonItemStylePlain target:self action:@selector(dumpLog)];
    item.rightBarButtonItems = @[rightButton1,rightButton2];
    [rightButton2 release];
#else
    item.rightBarButtonItems = @[rightButton1];
#endif

    [rightButton1 release];

}

-(void)dumpLog{
    NSLog(@"%@",RZLogFileContent());
}

-(void)reloadLog{
    NSString * html = [NSString stringWithFormat:@"<pre>%@</pre>", RZLogFileContent()];
    [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:@"https://ro-z.net/connectstats"]];

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [GCViewConfig setupViewController:self];

    CGRect rect = self.view.frame;
    rect.origin.y=0;
    self.webView.frame = rect;

    [self reloadLog];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.webView.frame= self.view.frame;
}
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [webView evaluateJavaScript:@"window.scrollBy(0,document.body.offsetHeight);" completionHandler:^(id res,NSError*error){

    }];

}
@end
