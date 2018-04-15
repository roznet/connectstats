//  MIT Licence
//
//  Created on 25/03/2009.
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

#import "RZTestViewController.h"
#import "RZTestDetailsViewController.h"
@import RZUtils;
@import RZUtilsTouch;

@interface RZTestViewController ()
@property (nonatomic,retain) NSString * singleTestClass;

@end


#pragma mark - TestViewController

@implementation RZTestViewController

#pragma mark Init
-(RZTestViewController*)init{
	self = [super init];
	if( self ){
        self.runner = RZReturnAutorelease([[RZUnitTestRunner alloc] init]);
        self.runner.testSource = self;
        [self.runner attach:self];
        _runTestOnStartup = true;
	}
	return( self );
}

- (void)dealloc {
    [_runner detach:self];
#if ! __has_feature(objc_arc)
    [_runner release];
	[_resultsTableView	release];
    [_mainView          release];
    [_singleTestClass release];
    [super dealloc];
#endif
}

#pragma mark UIViewController

-(void)loadView{
	[super loadView];


	UIView *contentView				= [[UIView alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
	[contentView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
	contentView.autoresizesSubviews = YES;
	contentView.autoresizingMask	= (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);


	CGFloat leftX		= 10;
	CGFloat tableWidth  = 320;
	CGFloat tableHeight = 400;

	CGFloat currentY	= 0.0 ;
    self.navigationItem.rightBarButtonItems = @[
            RZReturnAutorelease([[UIBarButtonItem alloc] initWithTitle:self.runTestOnStartup? NSLocalizedString(@"Rerun",nil):NSLocalizedString(@"RunAll",nil)
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(runTests:)]),
            RZReturnAutorelease([[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"RunSingle",nil)
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(runSingleTest:)])
                                                ];
    NSMutableArray * leftItems = [NSMutableArray arrayWithObject:RZReturnAutorelease([[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Clear",nil)
                                                                                                                      style:UIBarButtonItemStylePlain
                                                                                                                     target:self
                                                                                                                     action:@selector(clearResults:)])
                                  ];
    if( self.additionalLeftNavigationButton.count > 0 ){
        [leftItems addObjectsFromArray:self.additionalLeftNavigationButton];
    }
    
    self.navigationItem.leftBarButtonItems = leftItems;
    
    leftX = 0.;
	UITableView * table = [[UITableView alloc] initWithFrame:CGRectMake(leftX, currentY, tableWidth, tableHeight)];
	[table setDelegate:self];
	[table setDataSource:self];
	[contentView addSubview:table];
	[self setResultsTableView:table];
    RZRelease(table);

	_activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
    [_activityIndicator setCenter:CGPointMake(160.0f, 208.0f)];
    [_activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [contentView addSubview:_activityIndicator];
    RZRelease(_activityIndicator);

	[self setView:contentView];
    [self setMainView:contentView];
    RZRelease(contentView);

    if (self.runTestOnStartup) {
        [_activityIndicator startAnimating];
        [self.runner run];
    }

};

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    self.mainView.frame = [self view].frame;
    self.resultsTableView.frame = self.view.frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


#pragma mark UITableTableDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.displayResults.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    GCCellGrid * cell = [GCCellGrid gridCell:tableView];
    [cell setupForRows:2 andCols:2];

    NSDictionary * attrField = @{NSFontAttributeName: [UIFont systemFontOfSize:16.]};
    NSDictionary * attrValue = @{NSFontAttributeName: [UIFont systemFontOfSize:16.],
                                 NSForegroundColorAttributeName:[UIColor blueColor]};
    NSDictionary * attrError = @{NSFontAttributeName: [UIFont systemFontOfSize:16.],
                                 NSForegroundColorAttributeName:[UIColor redColor]};

    NSDictionary * attrPreview = @{NSFontAttributeName: [UIFont systemFontOfSize:14.],
                                   NSForegroundColorAttributeName: [UIColor darkGrayColor]};

	// Set up the cell's text
	NSInteger row = [indexPath row];

	NSUInteger total,success,failure;
	double timetaken;
	NSString * sessionName;
	if( row > 0 ){
        RZUnitTestRecord * record = self.displayResults[row-1];
		sessionName = record.session;
		total	= record.total;
		success = record.success;
		failure = record.failure;
		timetaken=record.timeTaken;
	}else{
		sessionName = @"Total";
		total	= [self.runner.current totalRun];
		success = [self.runner.current totalSuccess];
		failure = [self.runner.current totalFailure];
		timetaken=[self.runner.current totalTime];
	}
    [cell labelForRow:0 andCol:0].attributedText = [NSAttributedString attributedString:attrField withString:sessionName];
	if( failure > 0 ){
        [cell labelForRow:0 andCol:1].attributedText = [NSAttributedString attributedString:attrError
                                                                                 withFormat:@"%d/%d Failed", (int)failure,
                                                        (int)total];
	}else{
        [cell labelForRow:0 andCol:1].attributedText = [NSAttributedString attributedString:attrValue withFormat:@"%d/%d Succeeded", (int)success, (int)total] ;
	}
    [cell labelForRow:1 andCol:0].attributedText = [NSAttributedString attributedString:attrPreview withFormat:@"Time taken: %.3f", timetaken];

	return cell;
}

#pragma mark UITableViewDelegateMethods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger row = [indexPath row];
	if( row > 0){
		RZUnitTestRecord * record = self.displayResults[indexPath.row-1];
		RZTestDetailsViewController * tvc = [[RZTestDetailsViewController alloc] initWithRecord:record];
		[[self navigationController] pushViewController:tvc animated:YES];
        RZRelease(tvc);
	};
}

#pragma mark Tests UI Buttons

-(IBAction) runSingleTest:(id)sender{
    GCCellEntryListViewController * elvc = [GCCellEntryListViewController entryListViewController:self.allTestClassNames
                                                                                         selected:self.allTestClassNames.count];
    elvc.entryFieldDelegate = self;
    [self.navigationController pushViewController:elvc animated:YES];
}

-(void)cellWasChanged:(id<GCEntryFieldProtocol>)cell{
    [self.navigationController popViewControllerAnimated:YES];
    NSUInteger selected = [cell selected];

    self.singleTestClass = selected < self.allTestClassNames.count ? self.allTestClassNames[selected] : nil;

    [self.runner run];
    [_activityIndicator startAnimating];
}

-(UINavigationController*)baseNavigationController{
    return self.navigationController;
}
-(UINavigationItem*)baseNavigationItem{
    return self.navigationItem;
}

- (IBAction) runTests: (id) sender{
    self.singleTestClass = nil;
    [self.runner run];
	[_activityIndicator startAnimating];
}

- (IBAction) clearResults:(id) sender{
    self.displayResults = [NSArray array];
    [self.runner clearResults];

	[_resultsTableView reloadData];
}
-(void)notifyUpdate{
    [_resultsTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}
-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    if (!self.runner.running) {
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.activityIndicator stopAnimating];
        });
    }

    [self displayCurrentResults];
}

#pragma mark - Test Execution Logic

-(NSArray*)testClassNames{
    if (self.singleTestClass) {
        return @[ self.singleTestClass ];
    }else{
        return self.allTestClassNames;
    }
}

-(NSArray*)allTestClassNames{
    return nil;
}

-(NSArray*)additionalLeftNavigationButton{
    return nil;
}

-(void)displayCurrentResults{
    self.displayResults = self.runner.collectedResults;
    [self.resultsTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

-(void)testFinished{
    [self displayCurrentResults];
}


@end
