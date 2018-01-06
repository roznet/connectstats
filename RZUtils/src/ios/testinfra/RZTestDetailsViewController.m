//
//  TestDetailsViewController.m
//  MacroDialTest
//
//  Created by brice on 20/05/2009.
//  Copyright 2009 ro-z.net. All rights reserved.
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
