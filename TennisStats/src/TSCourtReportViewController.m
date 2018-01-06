//  MIT Licence
//
//  Created on 29/11/2014.
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

#import "TSCourtReportViewController.h"
#import "TSTennisCourtView.h"
#import "TSTennisCourtGeometry.h"
#import "TSAppGlobal.h"
#import "TSTennisSessionState.h"
#import "TSTennisOrganizer.h"
#import "TSTennisCourtAnnotatedLocation.h"
#import "TSTennisCourtAnnotationView.h"

@interface TSCourtReportViewController ()
@property (nonatomic,retain) TSTennisCourtGeometry * geometry;
@property (nonatomic,retain) TSTennisCourtView * tennisView;
@property (nonatomic,retain) TSTennisCourtAnnotationView * annotationView;
@property (nonatomic,assign) tsCourtReportType reportType;
@property (nonatomic,retain) TSTennisSession * session;
@end

@implementation TSCourtReportViewController

#pragma mark - Notifications

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.session detach:self];
}
-(void)sessionChangedCallback{
    [self changeSession:[[TSAppGlobal organizer] currentSession]];
    [self buildAnnotations];
}
-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    [self buildAnnotations];
}
-(void)changeSession:(TSTennisSession*)session{
    if (session!=self.session) {
        [self.session detach:self];
        self.session = session;
        [self.session attach:self];
    }
}

#pragma mark - Setup Views

-(void)setupFrames:(CGRect)rect{
    CGFloat kCourtLeftMargin   = 35.;
    CGFloat kCourtRightMargin  = 35.;
    CGFloat kCourtTopMargin    = 75.;
    CGFloat kCourtBottomMargin = 24.;

    kCourtTopMargin = 250.;

    CGRect courtFrame = self.view.frame;
    courtFrame.origin.x += kCourtLeftMargin;
    courtFrame.origin.y += kCourtTopMargin;
    courtFrame.size.height -= 75. + kCourtBottomMargin;
    courtFrame.size.width  -= kCourtLeftMargin+kCourtRightMargin;

    self.tennisView.frame = courtFrame;
    self.annotationView.frame = courtFrame;

    [self.geometry calculateFor:CGRectMake(0., 0., courtFrame.size.width, courtFrame.size.height)];

}

-(void)changeReportType:(tsCourtReportType)type{
    self.reportType = type;
}
-(void)buildAnnotations{
    TSTennisSessionState * state = self.session.state;

    NSUInteger i = 0;
    NSMutableArray * shots = [NSMutableArray array];

    for (TSTennisRally * rally in state) {
        TSTennisShot * last = [rally lastPlayerShot];
        tsDifferential diff = [rally.score playerPointDifferential];
        for (TSTennisShot * shot in rally) {
            if (shot.shotCourtSide == rally.playerCourtSide && shot.shotType != tsShotServe) {
                TSTennisCourtAnnotatedLocation * aloc  = [[TSTennisCourtAnnotatedLocation alloc] init];

                aloc.location = [self.geometry drawLocation:shot.ballLocation];
                aloc.location = [self.geometry equivalentPointBack:aloc.location];

                // Winning/Loosing
                if (self.reportType == tsCourtReportTypeDifferential) {
                    aloc.color = rally.winningContestant == tsContestantPlayer ? [UIColor yellowColor] : [UIColor redColor];
                    aloc.style = tsAnnotationStyleCircle;
                    if (shot != last) {
                        aloc.color = [UIColor whiteColor];
                        aloc.style = tsAnnotationStyleDot;
                    }

                }else if(self.reportType == tsCourtReportTypeWinning){
                    if (diff == tsDifferentialAhead) {
                        aloc.color = [UIColor yellowColor];
                        aloc.style = tsAnnotationStyleCircle;
                    }else if (diff == tsDifferentialBehind){
                        aloc.color = [UIColor redColor];
                        aloc.style = tsAnnotationStyleCircle;
                    }else{
                        aloc.color = [UIColor whiteColor];
                        aloc.style = tsAnnotationStyleCross;
                    }
                }else if(self.reportType == tsCourtReportTypeShotType){
                    if (shot.shotType == tsShotBackhand) {
                        aloc.color = [UIColor redColor];
                        aloc.style = tsAnnotationStyleCircle;
                    }else if (shot.shotType == tsShotForehand){
                        aloc.color = [UIColor greenColor];
                        aloc.style = tsAnnotationStyleCircle;
                    }else{
                        aloc.color = [UIColor whiteColor];
                        aloc.style = tsAnnotationStyleCross;
                    }
                }
                i++;

                [shots addObject:aloc];
            }
        }
    }
    self.annotationView.annotations = shots;
    [self.annotationView  performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
}


#pragma mark - ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.geometry = [[TSTennisCourtGeometry alloc] init];

    self.tennisView = [[TSTennisCourtView alloc] initWithFrame:CGRectZero];
    self.tennisView.geometry = self.geometry;

    self.annotationView = [[TSTennisCourtAnnotationView alloc] initWithFrame:CGRectZero];
    self.annotationView.backgroundColor = [UIColor clearColor];

    [self.view addSubview:self.tennisView];
    [self.view addSubview:self.annotationView];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self changeSession:[[TSAppGlobal organizer] currentSession]];
    [self setupFrames:self.view.frame];
    [self buildAnnotations];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
