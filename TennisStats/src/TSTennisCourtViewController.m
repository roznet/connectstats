//  MIT Licence
//
//  Created on 11/10/2014.
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

#import "TSTennisCourtViewController.h"
#import "TSTennisCourtGeometry.h"
#import "TSTennisSessionState.h"
#import "TSTennisCourtAnnotationView.h"
#import "TSAppGlobal.h"
#import "TSTennisOrganizer.h"
#import "TSTennisRallyResultView.h"
#import "TSTennisScorePanelView.h"
#import "TSTennisCourtAnnotatedLocation.h"
#import "TSTennisTagSelectionView.h"
#import "TSTennisFields.h"
#import <math.h>

typedef NS_ENUM(NSUInteger, tsSliderIcons){
    tsSliderPreviousIcon,
    tsSliderStepIcon,
    tsSliderNextIcon
};

@interface TSIconViewInfo : NSObject

@property (nonatomic,assign) tsEvent type;
@property (nonatomic,retain) NSString * name;
@property (nonatomic,retain) UIImageView * imageView;
+(TSIconViewInfo*)infoFor:(NSString*)name type:(tsEvent)type andImage:(NSString*)imgName;



@end

@implementation TSIconViewInfo
+(TSIconViewInfo*)infoFor:(NSString *)name type:(tsEvent)type andImage:(NSString *)imgName{
    TSIconViewInfo * rv = [[TSIconViewInfo alloc] init];
    if (rv) {
        rv.name = name;
        rv.type = type;
        rv.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
    }
    return rv;
}

@end

const CGFloat kCourtLeftMargin = 35.;
const CGFloat kCourtRightMargin = 35.;
const CGFloat kCourtTopMargin  = 75.;
const CGFloat kCourtBottomMargin = 24.;
const CGFloat kIconSpacing = 15.;
const CGFloat kTextSpacing = 2.;
const CGFloat kTextTopMargin = 30.;
const CGFloat kTextSideMargin = 5.;
const CGFloat kScoreHeight = 50.;
const CGFloat kScoreTop = 10.;

@interface TSTennisCourtViewController ()
@property (nonatomic,assign) CGPoint lastPointStart;
@property (nonatomic,assign) CGPoint lastPointEnd;
@property (nonatomic,assign) CGPoint lastTap;
@property (nonatomic,retain) FMDatabase * db;
@property (nonatomic,retain) NSArray * topRightIcons;
@property (nonatomic,retain) NSArray * bottomRightIcons;

@property (nonatomic,retain) UIImageView * userBack;
@property (nonatomic,retain) UIImageView * userFront;

@property (nonatomic,retain) NSArray * topLeftIcons;

@property (nonatomic,retain) UILabel * backDescription;
@property (nonatomic,retain) UILabel * frontDescription;

@property (nonatomic,retain) UILabel * backScore;
@property (nonatomic,retain) UILabel * frontScore;
@property (nonatomic,retain) TSTennisRallyResultView * rallyResultView;
@property (nonatomic,retain) TSTennisScorePanelView * scorePanelView;
@property (nonatomic,retain) TSTennisTagSelectionView * tagPanelView;

@property (nonatomic,retain) NSMutableArray * touchPoints;
@property (nonatomic,retain) UILabel * readOnlyLabel;

@property (nonatomic,retain) UISlider * slider;
@property (nonatomic,retain) NSArray * sliderButtons;

@property (nonatomic,retain) FMDatabase * regressiondb;


@end

@implementation TSTennisCourtViewController

#pragma mark - Notifications

-(void)dealloc{
    [self.slider removeTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.session detach:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)sessionChangedCallback{
    [self changeSession:[[TSAppGlobal organizer] currentSession]];
    [self performSelectorOnMainThread:@selector(updateDescriptions) withObject:nil waitUntilDone:NO];
    [self setupFrames:self.view.frame];
    [self updateDescriptions];

}
-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    [self performSelectorOnMainThread:@selector(updateDescriptions) withObject:nil waitUntilDone:NO];
}

-(void)changeSession:(TSTennisSession*)session{
    if (session!=self.session) {
        [self.session detach:self];
        self.session = session;
        [self.session attach:self];
#if TARGET_IPHONE_SIMULATOR
        // IF you want to log description
        [self.session setupForLogging:YES];
#endif
    }
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma mark - UIViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];

    [self changeSession:[[TSAppGlobal organizer] currentSession]];
    [self setupFrames:self.view.frame];
    [self updateDescriptions];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    self.frontDescription = [[UILabel alloc] initWithFrame:CGRectZero];
    self.backDescription = [[UILabel alloc] initWithFrame:CGRectZero];
    self.frontDescription.textAlignment = NSTextAlignmentRight;
    self.backDescription.textAlignment = NSTextAlignmentRight;
    self.frontDescription.font = [UIFont systemFontOfSize:14.];
    self.backDescription.font = [UIFont systemFontOfSize:14.];

    self.frontScore = [[UILabel alloc] initWithFrame:CGRectZero];
    self.backScore = [[UILabel alloc] initWithFrame:CGRectZero];
    self.frontScore.textAlignment = NSTextAlignmentLeft;
    self.backScore.textAlignment = NSTextAlignmentLeft;
    self.frontScore.font = [UIFont fontWithName:@"Chalkboard SE" size:14];
    self.backScore.font = [UIFont fontWithName:@"Chalkboard SE" size:14];

    self.scorePanelView =[[TSTennisScorePanelView alloc] initWithFrame:CGRectZero];
    self.scorePanelView.scorePanelDelegate = self;
    [self.scorePanelView updateForSession:[[TSAppGlobal organizer] currentSession]];

    self.geometry = [[TSTennisCourtGeometry alloc] init];

    self.tennisView = [[TSTennisCourtView alloc] initWithFrame:CGRectZero];
    self.tennisView.geometry = self.geometry;

    UIPanGestureRecognizer * shot = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    UITapGestureRecognizer * tap  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    self.annotationView = [[TSTennisCourtAnnotationView alloc] initWithFrame:CGRectZero];
    self.annotationView.backgroundColor = [UIColor clearColor];
    [self.annotationView addGestureRecognizer:shot];
    [self.annotationView addGestureRecognizer:tap];

    self.userBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"973-user"]];
    self.userFront = [[UIImageView alloc] initWithFrame:CGRectZero];

    self.userBack.contentMode = UIViewContentModeScaleAspectFit;

    self.rallyResultView = [TSTennisRallyResultView resultViewFor:self];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.rallyResultView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2];
    }
    self.tagPanelView = [TSTennisTagSelectionView tagSelectionViewFor:self];

    self.readOnlyLabel = [[UILabel alloc] initWithFrame:CGRectZero];

    self.topRightIcons = @[
                           [TSIconViewInfo infoFor:@"Won"
                                              type:tsEventBackPlayerWon
                                          andImage:@"777-thumbs-up"],
                           [TSIconViewInfo infoFor:@"Lost"
                                              type:tsEventBackPlayerLost
                                          andImage:@"778-thumbs-down"],
                           [TSIconViewInfo infoFor:@"Switch"
                                              type:tsEventPlayerSwithSide
                                          andImage:@"759-refresh-2"],
                           [TSIconViewInfo infoFor:@"Tag"
                                              type:tsEventTag
                                          andImage:@"909-tags"]

                                ];
    self.bottomRightIcons = @[
                              [TSIconViewInfo infoFor:@"count" type:tsEventNone andImage:@"1041-count"],
                              [TSIconViewInfo infoFor:@"front_lost"
                                                 type:tsEventFrontPlayerLost
                                             andImage:@"778-thumbs-down.png"],
                              [TSIconViewInfo infoFor:@"front_won"
                                                 type:tsEventFrontPlayerWon
                                             andImage:@"777-thumbs-up.png"],

                              ];

    [self.view addSubview:self.tennisView];
    [self.view addSubview:self.annotationView];
    [self.view addSubview:self.frontDescription];
    [self.view addSubview:self.backDescription];
    [self.view addSubview:self.userFront];
    [self.view addSubview:self.userBack];
    [self.view addSubview:self.frontScore];
    [self.view addSubview:self.backScore];

    for (TSIconViewInfo * info in self.topRightIcons) {
        UIImageView * iv = info.imageView;
        iv.userInteractionEnabled = YES;
        [iv addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapIcon:)]];
        [self.view addSubview:iv];
    }

    for (TSIconViewInfo * info in self.bottomRightIcons) {
        UIImageView * iv = info.imageView;
        iv.userInteractionEnabled = YES;
        [iv addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapIcon:)]];
        [self.view addSubview:iv];
    }
    self.slider = [[UISlider alloc] initWithFrame:CGRectZero];
    self.slider.value = 1.0;
    self.slider.minimumTrackTintColor = [UIColor blackColor];
    self.slider.maximumTrackTintColor = [UIColor grayColor];
    [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.sliderButtons = @[
                           [UIButton buttonWithType:UIButtonTypeCustom],
                           [UIButton buttonWithType:UIButtonTypeCustom],
                           [UIButton buttonWithType:UIButtonTypeCustom]
                           ];
    [self.sliderButtons[tsSliderNextIcon] setImage:[UIImage imageNamed:@"next"] forState:UIControlStateNormal];
    [self.sliderButtons[tsSliderNextIcon] setImage:[UIImage imageNamed:@"next"] forState:UIControlStateHighlighted];
    [self.sliderButtons[tsSliderPreviousIcon] setImage:[UIImage imageNamed:@"previous"] forState:UIControlStateNormal];
    [self.sliderButtons[tsSliderPreviousIcon] setImage:[UIImage imageNamed:@"previous"] forState:UIControlStateHighlighted];
    [self.sliderButtons[tsSliderStepIcon] setImage:[UIImage imageNamed:@"step"] forState:UIControlStateNormal];
    [self.sliderButtons[tsSliderStepIcon] setImage:[UIImage imageNamed:@"step"] forState:UIControlStateHighlighted];

    NSInteger i = 0;
    for (UIButton * b in self.sliderButtons) {
        [b addTarget:self action:@selector(sliderButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        b.tag = i++;
    }

    [self.view addSubview:self.rallyResultView];
    [self.view addSubview:self.tagPanelView];
    [self.view addSubview:self.scorePanelView];

    [self.view addSubview:self.readOnlyLabel];
    [self.view addSubview:self.slider];

    [self.view addSubview:self.sliderButtons[tsSliderPreviousIcon]];
    [self.view addSubview:self.sliderButtons[tsSliderNextIcon]];
    [self.view addSubview:self.sliderButtons[tsSliderStepIcon]];

    [self setupFrames:self.view.frame];

    [self changeSession:[[TSAppGlobal organizer] currentSession]];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionChangedCallback) name:kNotifyOrganizerSessionChanged object:nil];
}


#pragma mark - GestureRecognizer

-(void)sliderButtonSelected:(UIButton*)button{
    tsSliderIcons which = button.tag;
    TSScore gameNumber = 0;
    switch (which) {
        case tsSliderStepIcon:
            [self.session replayNextEvent];
            break;
        case tsSliderNextIcon:
            gameNumber = self.session.state.currentScore.gameNumber + 1;
            [self.session replayToEventMatching:^(TSTennisSessionState*cur) {
                return (BOOL)(cur.currentScore.gameNumber == gameNumber);
            } hint:NO];
            break;
        case tsSliderPreviousIcon:
            gameNumber = self.session.state.currentScore.gameNumber - 1;
            [self.session replayToEventMatching:^(TSTennisSessionState*cur) {
                return (BOOL)(cur.currentScore.gameNumber == gameNumber);
            } hint:YES];
            break;
        default:
            break;
    }
}

-(void)sliderValueChanged:(UISlider*)slider{
    NSUInteger val =  _session.countOfEvents * slider.value;
    [self.session replayToEventIndex:val];
}

-(void)rallyResultViewHide{
    self.rallyResultView.frame = CGRectZero;
    self.tagPanelView.frame = CGRectZero;
    [self deselectAllIcons];
}

-(BOOL)rallyResultViewIsHidden{
    return self.rallyResultView.frame.size.width == 0;
}

-(void)rallyResultViewToggleTop:(BOOL)top{
    if (self.rallyResultView.frame.size.width == 0) {
        BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);

        CGRect rect = self.tennisView.frame;
        CGSize size = CGSizeMake(200., 150.);

        rect.origin.x = iPad ? CGRectGetMaxX(rect)+40. : CGRectGetMaxX(rect)-size.width-10.;
        rect.origin.y += 10.;

        if (top == false) {
            rect.origin.y = CGRectGetMaxY(rect)-size.height-10.;
        }

        rect.size = size;
        self.rallyResultView.frame = rect;
    }else{
        self.rallyResultView.frame = CGRectZero;
    }
}


-(void)tagPanelViewToggleTop:(BOOL)top{
    if (self.tagPanelView.frame.size.width == 0) {
        BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);

        CGRect rect = self.tennisView.frame;
        CGSize size = CGSizeMake(200., 200.);

        rect.origin.x = iPad ?  CGRectGetMaxX(rect)+40. : CGRectGetMaxX(rect)-size.width-10.;
        rect.origin.y += 10.;

        if (top == false) {
            rect.origin.y = CGRectGetMaxY(rect)-size.height-10.;
        }

        rect.size = size;
        self.tagPanelView.frame = rect;
    }else{
        self.tagPanelView.frame = CGRectZero;
    }
}

-(void)rallyResultView:(TSTennisRallyResultView *)view result:(tsRallyResult)res{
    if (res != tsResultNone) {
        [self addEvent:[TSTennisEvent event:tsEventRallyResult withValue:res]];
    }

    [self rallyResultViewHide];

}

-(void)iconPanelView:(RZIconPanelView *)panelView selected:(NSInteger)choice{
    if (panelView == self.tagPanelView && choice != kInvalidIdentifier) {
        [self addEvent:[TSTennisEvent event:tsEventTag withValue:choice]];
    }else if (panelView == self.rallyResultView && choice != kInvalidIdentifier){
        [self addEvent:[TSTennisEvent event:tsEventRallyResult withValue:choice]];
    }
    [self rallyResultViewHide];
}

-(void)panel:(TSTennisScorePanelView *)view updateScore:(tsContestant)contestant sets:(CGFloat)sets games:(CGFloat)games points:(CGFloat)points{
    TSTennisEvent * event = nil;
    if (contestant == tsContestantOpponent) {
        event = [TSTennisEvent event:tsEventOpponentUpdateScore withValue:sets second:games third:points];
    }else if(contestant == tsContestantPlayer){
        event = [TSTennisEvent event:tsEventPlayerUpdateScore withValue:sets second:games third:points];
    }
    if (event) {
        [self addEvent:event];
    }
}

-(void)panel:(TSTennisScorePanelView *)view tapped:(tsContestant)contestant{
    CGRect current = self.scorePanelView.frame;

    if (current.origin.y == 10.) {
        self.scorePanelView.frame = CGRectMake(5., 200., self.view.frame.size.width-10., kScoreHeight*2);
        self.scorePanelView.backgroundColor = [UIColor lightGrayColor];
        self.scorePanelView.enableAdjustments =true;
    }else{
        CGRect scoreFrame = CGRectMake(5., kScoreTop, self.view.frame.size.width-10., kScoreHeight);
        self.scorePanelView.frame = scoreFrame;
        self.scorePanelView.backgroundColor = [UIColor lightGrayColor];
        self.scorePanelView.enableAdjustments =false;
    }

}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

-(void)deselectAllIcons{
    for (TSIconViewInfo * info in self.topRightIcons) {
        info.imageView.backgroundColor = [UIColor clearColor];
    }
    for (TSIconViewInfo * info in self.bottomRightIcons) {
        info.imageView.backgroundColor = [UIColor clearColor];
    }
}

-(void)tapIcon:(UITapGestureRecognizer*)recognizer{

    for (TSIconViewInfo * info in self.topRightIcons) {
        if (info.imageView == recognizer.view) {
            if (info.type != tsEventNone) {
                if (info.type==tsEventTag) {
                    [self tagPanelViewToggleTop:YES];
                }else{
                    [self addEvent:[TSTennisEvent event:info.type]];
                    if (info.type!=tsEventPlayerSwithSide) {
                        info.imageView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2];

                        [self rallyResultViewToggleTop:YES];
                        if ([self rallyResultViewIsHidden]) {
                            info.imageView.backgroundColor = [UIColor clearColor];
                        }
                    }
                }
            }else{
                if ([info.name isEqualToString:@"count"]) {
                    [TSAppGlobal tabBarToStats];
                }
            }
        }else{
            info.imageView.backgroundColor = [UIColor clearColor];
        }
    }
    for (TSIconViewInfo * info in self.bottomRightIcons) {
        if (info.imageView == recognizer.view) {
            if (info.type != tsEventNone) {
                info.imageView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2];

                [self addEvent:[TSTennisEvent event:info.type]];
                [self rallyResultViewToggleTop:NO];
                if ([self rallyResultViewIsHidden]) {
                    info.imageView.backgroundColor = [UIColor clearColor];
                }

            }else{
                if ([info.name isEqualToString:@"count"]) {
                    [TSAppGlobal tabBarToStats];
                }
            }
        }else{
            info.imageView.backgroundColor = [UIColor clearColor];
        }
    }
}

-(void)pan:(UIPanGestureRecognizer*)recognizer{
    if (![self isEditable]) {
        return;
    }
    [self rallyResultViewHide];
    CGPoint point = [recognizer locationInView:self.annotationView];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.annotationView.currentPath = [UIBezierPath bezierPath];
        [self.annotationView.currentPath moveToPoint:point];
        self.lastPointStart = [self.geometry courtLocation:point];
        tsCourtSide side = [self.geometry shotSideForLocation:point];
        tsShotCourtArea area = [self.geometry shotCourtAreaForShotLocation:point];
        CGRect rect = [self.geometry rectForShotCourtArea:area side:side];
        self.annotationView.currentArea = [UIBezierPath bezierPathWithRect:rect];
        self.touchPoints = [NSMutableArray arrayWithObject:[NSValue valueWithCGPoint:point]];

    }else if(recognizer.state == UIGestureRecognizerStateEnded){
        [self.annotationView.currentPath addLineToPoint:point];
        self.lastPointEnd = [self.geometry courtLocation:point];

        CGPoint first =  [self.touchPoints[0] CGPointValue];
        CGPoint last  = [[self.touchPoints lastObject] CGPointValue];
        NSUInteger minI = 0;
        double minAngleDiff = 10.; // max pi

        for (NSUInteger i=1;i<self.touchPoints.count-1;i++) {
            NSValue * val = self.touchPoints[i];
            CGPoint current = [val CGPointValue];

            CGFloat distFirst = sqrtf( (current.y-first.y)*(current.y-first.y) + (current.x-first.x)*(current.x-first.x));
            CGFloat distLast  = sqrtf( (current.y-last.y)*(current.y-last.y)   + (current.x-last.x)*(current.x-last.x));

            if (distFirst > 3 && distLast > 3) {
                double angleFirst = atan( (current.y-first.y)/(current.x-first.x+0.0001));
                double angleLast = atan( (current.y-last.y)/(current.x-last.x+0.0001));

                double angleDiff = fabs(angleFirst-angleLast);
                if (fabs(angleDiff-M_PI_2)<minAngleDiff) {
                    minI =i ;
                    minAngleDiff=fabs(angleDiff-M_PI_2);
                    //NSLog(@"%d: (%f,%f) %f MIN", (int)i, angleFirst, angleLast, angleDiff );
                }else{
                    //NSLog(@"%d: (%f,%f) %f", (int)i, angleFirst, angleLast, angleDiff );
                }
            }
        }
        CGPoint delta = CGPointMake(self.lastPointEnd.x-self.lastPointStart.x, self.lastPointEnd.y-self.lastPointStart.y);
        CGPoint gamma = CGPointZero;

        if (minAngleDiff < M_PI_2/3) {
            CGPoint middle = [self.geometry courtLocation:[self.touchPoints[minI] CGPointValue]];
            //CGPoint full = delta;
            delta = CGPointMake( middle.x-self.lastPointStart.x, middle.y-self.lastPointStart.y );
            gamma = CGPointMake( self.lastPointEnd.x-middle.x, self.lastPointEnd.y-middle.y);
            //NSLog(@"D1=%@ D2=%@ (F=%@)", NSStringFromCGPoint(delta), NSStringFromCGPoint(gamma),NSStringFromCGPoint(full));
        }else{
            //NSLog(@"D1=%@", NSStringFromCGPoint(delta));

        }
        TSTennisEvent * event = [TSTennisEvent event:tsEventShot
                                        withLocation:self.lastPointStart
                                            andDelta:delta
                                            andGamma:gamma
                                 ];
        [self addEvent:event];
    }else{
        [self.touchPoints addObject:[NSValue valueWithCGPoint:point]];
        [self.annotationView.currentPath addLineToPoint:point];
        self.lastPointEnd = [self.geometry courtLocation:point];
    }
    [self updateDescriptions];
    [self.annotationView setNeedsDisplay];
}
-(void)tap:(UITapGestureRecognizer*)recognizer{
    if (![self isEditable]) {
        return;
    }
    [self rallyResultViewHide];

    CGPoint center = [recognizer locationInView:self.annotationView];
    tsCourtSide side = [self.geometry ballSideForLocation:center];
    tsBallCourtArea area = [self.geometry ballCourtAreaForShotLocation:center];
    CGRect rect = [self.geometry rectForBallCourtArea:area side:side];
    self.annotationView.currentArea = [UIBezierPath bezierPathWithRect:rect];

    self.annotationView.annotations = @[
                                        [TSTennisCourtAnnotatedLocation annotationForPoint:center
                                                                                     color:[UIColor yellowColor]
                                                                                  andStyle:tsAnnotationStyleCircle],
                                        [TSTennisCourtAnnotatedLocation annotationForPoint:CGPointMake(0., 0.)
                                                                                     color:[UIColor greenColor]
                                                                                  andStyle:tsAnnotationStylePlus],
                                        ];
    [self.annotationView setNeedsDisplay];
    CGPoint position = [self.geometry courtLocation:center];
    TSTennisEvent * event = [TSTennisEvent event:tsEventBall withLocation:position];
    [self addEvent:event];
}

#pragma mark - Annotate Events

-(void)annotateBallEvent:(TSTennisEvent*)event{
    CGPoint center = [self.geometry drawLocation:event.location];
    tsCourtSide side = [self.geometry ballSideForLocation:center];
    tsBallCourtArea area = [self.geometry ballCourtAreaForShotLocation:center];
    CGRect rect = [self.geometry rectForBallCourtArea:area side:side];
    self.annotationView.currentArea = [UIBezierPath bezierPathWithRect:rect];

    self.annotationView.annotations = @[
                                        [TSTennisCourtAnnotatedLocation annotationForPoint:center
                                                                                     color:[UIColor yellowColor]
                                                                                  andStyle:tsAnnotationStyleCircle],
                                        [TSTennisCourtAnnotatedLocation annotationForPoint:CGPointMake(0., 0.)
                                                                                     color:[UIColor greenColor]
                                                                                  andStyle:tsAnnotationStylePlus],
                                        ];
    [self.annotationView setNeedsDisplay];

}

-(void)annotateShotEvent:(TSTennisEvent*)event{
    CGPoint center = [self.geometry drawLocation:event.location];
    CGPoint first  = [self.geometry drawLocation:CGPointMake(event.location.x+event.delta.x, event.location.y+event.delta.y)];
    CGPoint second = [self.geometry drawLocation:CGPointMake(event.location.x+event.delta.x+event.gamma.x, event.location.y+event.delta.y+event.gamma.y)];

    self.annotationView.currentPath = [UIBezierPath bezierPath];
    [self.annotationView.currentPath moveToPoint:center];
    [self.annotationView.currentPath addLineToPoint:first];
    [self.annotationView.currentPath addLineToPoint:second];

    [self.annotationView setNeedsDisplay];
}

#pragma mark - Setup Frames and Values

-(void)setupFrames:(CGRect)rect{
    CGRect courtFrame = self.view.frame;

    //CGFloat fullWidth = self.view.frame.size.width;
    CGFloat courtWidth = courtFrame.size.width;
    if (courtWidth>500) {
        courtWidth = 450;
    }
    courtFrame.size.width = courtWidth;

    courtFrame.origin.x += kCourtLeftMargin;
    courtFrame.origin.y += kCourtTopMargin;
    courtFrame.size.height -= kCourtTopMargin + kCourtBottomMargin;
    courtFrame.size.width  -= kCourtLeftMargin+kCourtRightMargin;
    CGRect scoreFrame = CGRectMake(5., kScoreTop, courtWidth-10., kScoreHeight);
    CGRect backDescFrame = CGRectMake(kTextSideMargin, kTextSpacing+kTextTopMargin, courtWidth-2*(kTextSideMargin), kCourtTopMargin - (kTextSpacing*2));
    CGRect frontDescFrame =CGRectMake(kTextSideMargin, CGRectGetMaxY(courtFrame)+kTextSpacing, courtWidth-2*(kTextSideMargin), kCourtBottomMargin - (kTextSpacing*2));

    [self.geometry calculateFor:CGRectMake(0., 0., courtFrame.size.width, courtFrame.size.height)];

    if ([self isEditable]) {
        self.readOnlyLabel.hidden=YES;
        self.slider.hidden = YES;

        self.readOnlyLabel.frame = CGRectZero;
        self.slider.frame = CGRectZero;
        [self.sliderButtons[tsSliderNextIcon] setFrame:CGRectZero];
        [self.sliderButtons[tsSliderStepIcon] setFrame:CGRectZero];
        [self.sliderButtons[tsSliderPreviousIcon] setFrame:CGRectZero];


    }else{
        self.readOnlyLabel.hidden= NO;
        CGSize lsize = [[self nonEditableAttributedString] size];
        self.readOnlyLabel.frame = CGRectMake(courtFrame.origin.x+(courtFrame.size.width-lsize.width)/2,
                                              courtFrame.origin.y+courtFrame.size.height/2-10-lsize.height,
                                              lsize.width,
                                              lsize.height);
        // Can be either readonly or nil/no session
        if (_session.isReadOnly) {
            self.slider.hidden = NO;

            CGFloat sliderButtonSize = 35.;
            CGFloat sliderButtonSpacing = 2.;
            CGFloat sliderHeight = 20.;
            CGFloat sliderCenter = courtFrame.origin.y+courtFrame.size.height/2;
            CGFloat sliderRightButton = courtFrame.origin.x+courtFrame.size.width- (sliderButtonSize+sliderButtonSpacing)*2;

            self.slider.frame = CGRectMake(courtFrame.origin.x + sliderButtonSize+sliderButtonSpacing,
                                           sliderCenter-sliderHeight/2.,
                                           courtFrame.size.width - (sliderButtonSpacing+sliderButtonSize)*3,
                                           sliderHeight);

            [self.sliderButtons[tsSliderPreviousIcon] setFrame:CGRectMake(courtFrame.origin.x,
                                                                          sliderCenter-sliderButtonSize/2.,
                                                                          sliderButtonSize,
                                                                          sliderButtonSize)];
            [self.sliderButtons[tsSliderStepIcon] setFrame:CGRectMake(sliderRightButton,
                                                                      sliderCenter-sliderButtonSize/2.,
                                                                      sliderButtonSize,
                                                                      sliderButtonSize)];
            [self.sliderButtons[tsSliderNextIcon] setFrame:CGRectMake(sliderRightButton+sliderButtonSize+sliderButtonSpacing,
                                                                      sliderCenter-sliderButtonSize/2.,
                                                                      sliderButtonSize,
                                                                      sliderButtonSize)];
        }
    }

    self.tennisView.frame = courtFrame;
    self.annotationView.frame = courtFrame;
    self.scorePanelView.frame = scoreFrame;
    self.backDescription.frame  = backDescFrame;
    self.frontDescription.frame = frontDescFrame;
    //Same frame but aligned right:
    self.backScore.frame = backDescFrame;
    self.frontScore.frame = frontDescFrame;

    CGRect iconRect = CGRectZero;
    iconRect.origin.y = kCourtTopMargin;

    for (TSIconViewInfo * info in self.topRightIcons) {
        UIImageView * iv = info.imageView;
        CGSize is = iv.frame.size;
        iconRect.origin.x =courtWidth-iv.frame.size.width-2.;
        iconRect.size = is;
        iv.frame = iconRect;
        iconRect.origin.y += is.height+kIconSpacing;
    }

    iconRect.origin.y = rect.size.height-kCourtBottomMargin;
    for (TSIconViewInfo * info in self.bottomRightIcons) {
        UIImageView * iv = info.imageView;
        CGSize is = iv.frame.size;
        iconRect.origin.x =courtWidth-iv.frame.size.width-2.;
        iconRect.size = is;
        iconRect.origin.y -= is.height+kIconSpacing;
        iv.frame = iconRect;
    }

    self.userBack.frame = CGRectMake(2., kCourtTopMargin, 32., 32.);
    self.userFront.frame = CGRectMake(2., rect.size.height-kCourtBottomMargin-32., 32., 32.);

}

-(void)updateDescriptions{
    TSTennisSessionState * state = _session.state;
    [self.scorePanelView updateForSession:self.session];
    [self.scorePanelView updateForState:state];
    tsCourtSide side = [state playerSide];
    UILabel * pdesc = nil;
    UILabel * pscore = nil;
    UILabel * odesc = nil;
    UILabel * oscore = nil;

    if (side == tsCourtFront) {
        pdesc = self.frontDescription;
        odesc = self.backDescription;
        pscore = self.frontScore;
        oscore = self.backScore;
    }else{
        odesc = self.frontDescription;
        pdesc = self.backDescription;
        oscore = self.frontScore;
        pscore = self.backScore;
    }
    pscore.text = [[state currentScore] playerScore];
    oscore.text = [[state currentScore] opponentScore];
    pdesc.text = [state playerCurrentShotDescription];
    odesc.text = [state opponentCurrentShotDescription];

    if (_session.state.playerSide == tsCourtBack) {
        self.userBack.image = [UIImage imageNamed:@"973-user"];
        self.userFront.image = nil;
    }else{
        self.userFront.image = [UIImage imageNamed:@"973-user"];
        self.userBack.image = nil;
    }

    if (![self isEditable]) {
        self.readOnlyLabel.attributedText = [self nonEditableAttributedString];
        if (_session.isReadOnly) {
            self.slider.value = (CGFloat)self.session.lastEventIdx / self.session.countOfEvents;
            TSTennisEvent * last = [self.session currentEvent];
            if (last.type == tsEventBall) {
                [self annotateBallEvent:last];
            }else if (last.type == tsEventShot){
                [self annotateShotEvent:last];
            }
        }
    }
}


-(NSAttributedString*)nonEditableAttributedString{
    return [NSAttributedString attributedString:@{NSFontAttributeName:[RZViewConfig boldSystemFontOfSize:22.], NSForegroundColorAttributeName:[UIColor yellowColor]}
                                     withString:_session.isReadOnly ? NSLocalizedString(@"Read Only", @"No Session") : NSLocalizedString( @"No Current Session", @"No Session")];
}

-(BOOL)isEditable{
    return (_session && ! _session.isReadOnly);
}


-(void)addEvent:(TSTennisEvent*)event{
    [_session addEvent:event];
    [self updateDescriptions];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
