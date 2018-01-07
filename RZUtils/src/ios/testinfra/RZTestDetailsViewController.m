//  MIT Licence
//
//  Created on 20/05/2009.
//
//  Copyright (c) None Brice Rosenzweig.
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

#import "RZTestDetailsViewController.h"
#import "RZUtils/RZUtils.h"

@implementation RZTestDetailsViewController


-(RZTestDetailsViewController*)initWithRecord:(RZUnitTestRecord*)aRecord{
	self = [super init];
	if( self ){
		[self setRecord:aRecord];
	}
	return( self );
}

-(void)dealloc{
    [self.runner detach:self];
#if ! __has_feature(objc_arc)
	[_record release];
	[super dealloc];
#endif
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	UIWebView *contentView	= [[UIWebView alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
	NSString * content = [_record detailAsHTML];

	[contentView loadHTMLString:content  baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
	[self setView:contentView];
    RZRelease(contentView);
    self.navigationItem.rightBarButtonItems = @[
                                                RZReturnAutorelease([[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Rerun",nil) style:UIBarButtonItemStylePlain target:self action:@selector(runTests:)]),
                                                ];

}

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    NSArray * found = self.runner.collectedResults;
    for (RZUnitTestRecord * record in found) {
        if ([record.session isEqualToString:self.record.session]) {
            self.record = record;
        }
    }
}

-(NSArray*)testClassNames{
    return @[ [self.record testClass] ];
}

-(void)runTests:(id)arg{
    if (self.runner ==nil) {
        self.runner = RZReturnAutorelease([[RZUnitTestRunner alloc] init]);
        self.runner.testSource = self;
        [self.runner attach:self];
    }
    [self.runner run];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


@end
