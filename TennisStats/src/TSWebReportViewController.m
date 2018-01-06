//  MIT Licence
//
//  Created on 23/10/2014.
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

#import "TSWebReportViewController.h"
#import "TSTennisOrganizer.h"
#import "TSAppGlobal.h"
#import "TSTennisRally.h"
#import "TSTennisSessionState.h"
#import "TSTennisFields.h"
#import "TSReport.h"
#import "TSReportElementPivot.h"

@interface TSWebReportViewController ()
@property (nonatomic,retain) UIWebView * webView;
@property (nonatomic,retain) TSSessionReport * report;
@property (nonatomic,retain) TSTennisSession * session;
@end

@implementation TSWebReportViewController

+(TSWebReportViewController*)webViewForReport:(TSSessionReport*)report{
    TSWebReportViewController * rv = [[TSWebReportViewController alloc]initWithNibName:nil bundle:nil];
    if (rv) {
        rv.report = report;
    }
    return rv;
}

-(void)dealloc{
    [self.session detach:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setupFrame:(CGRect)rect{
    self.webView.frame = rect;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.webView];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(organizerSessionChangedCallback)
                                                 name:kNotifyOrganizerSessionChanged
                                               object:nil];
}

-(void)organizerSessionChangedCallback{
    [self changeSession:[[TSAppGlobal organizer] currentSession]];
    [self displayReport];
}

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    [self displayReport];
}
-(void)changeSession:(TSTennisSession*)session{
    if (session!=self.session) {
        [self.session detach:self];
        self.session = session;
        [self.session attach:self];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self changeSession:[[TSAppGlobal organizer] currentSession]];
    [self displayReport];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)displayReport{
    NSString * html = [[self.report reportForSession:self.session] html];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.webView loadHTMLString:html  baseURL:[NSURL fileURLWithPath:[RZFileOrganizer writeableFilePath:@""]]];
    });
}

@end
