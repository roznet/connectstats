//  MIT Licence
//
//  Created on 31/10/2014.
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

#import "TSTennisScorePanelView.h"
#import "TSTennisSessionState.h"

#define L_NAME      0
#define L_SETS      1
#define L_GAMES     2
#define L_POINTS    3
#define L_COMMENTS  4
#define L_END       5

@interface TSTennisScorePanelView ()

@property (nonatomic,retain) NSArray * playerLabels;
@property (nonatomic,retain) NSArray * opponentLabels;
@property (nonatomic,assign) CGFloat fontSize;
@property (nonatomic,assign) CGFloat detailFontSize;
@property (nonatomic,retain) TSTennisSessionState * state;
@property (nonatomic,assign) tsContestant gestureContestant;
@property (nonatomic,assign) NSInteger gestureLabelIndex;
@end

@implementation TSTennisScorePanelView

-(NSDictionary*)attributeFor:(NSUInteger)i{
    UIColor * color = [UIColor blackColor];
    if (i==L_SETS) {
        color = [UIColor blackColor];
    }else if (i==L_GAMES){
        color = [UIColor whiteColor];
    }else if (i==L_POINTS){
        color = [UIColor yellowColor];
    }


    if (i==L_NAME) {
        return @{ NSFontAttributeName:[RZViewConfig boldSystemFontOfSize:self.detailFontSize],
                  NSForegroundColorAttributeName:[UIColor blackColor]};
    }else if (i==L_COMMENTS){
        return @{ NSFontAttributeName:[RZViewConfig systemFontOfSize:self.detailFontSize],
                  NSForegroundColorAttributeName:[UIColor blackColor]};
    }else{
        return @{ NSFontAttributeName:[UIFont fontWithName:@"Chalkboard SE" size:self.fontSize],
                  NSForegroundColorAttributeName:color};
    }
}

-(TSTennisScorePanelView*)initWithFrame:(CGRect)rect{
    self = [super initWithFrame:rect];
    if (self) {
        self.fontSize = 16;
        self.detailFontSize = 14;
        self.playerName = @"Player";
        self.opponentName=@"Opponent";
        self.backgroundColor = [UIColor lightGrayColor];
        [self setupSubViews];
        UISwipeGestureRecognizer * swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
        swipe.direction = UISwipeGestureRecognizerDirectionDown;
        [self addGestureRecognizer:swipe];
        swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
        swipe.direction = UISwipeGestureRecognizerDirectionUp;
        [self addGestureRecognizer:swipe];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

-(void)tapGesture:(UITapGestureRecognizer*)recognizer{
    // disabled
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        tsContestant player = tsContestantUnknown;
        NSUInteger i=0;
        CGPoint location = [recognizer locationInView:self];
        for ( i=0; i<L_END; i++) {
            if (CGRectContainsPoint([self.playerLabels[i] frame], location) ) {
                player = tsContestantPlayer;
                break;
            }
            if (CGRectContainsPoint([self.opponentLabels[i] frame], location) ) {
                player = tsContestantOpponent;
                break;
            }
        }
        [self.scorePanelDelegate panel:self tapped:player];
    }

}

-(void)swipeGesture:(UISwipeGestureRecognizer*)recognizer{
    if (self.enableAdjustments) {
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            self.gestureContestant = tsContestantUnknown;
            CGPoint location = [recognizer locationInView:self];
            if ([recognizer numberOfTouches]>0) {
                // look at first touch
                location = [recognizer locationOfTouch:0 inView:self];
            }
            NSUInteger i=0;
            for ( i=0; i<L_END; i++) {
                if (CGRectContainsPoint([self.playerLabels[i] frame], location) ) {
                    self.gestureContestant = tsContestantPlayer;
                    break;
                }
                if (CGRectContainsPoint([self.opponentLabels[i] frame], location) ) {
                    self.gestureContestant = tsContestantOpponent;
                    break;
                }
            }
            self.gestureLabelIndex = i;

            CGFloat val = recognizer.direction == UISwipeGestureRecognizerDirectionUp ? 1. : -1.;
            [self.scorePanelDelegate panel:self
                               updateScore:self.gestureContestant
                                      sets:i==L_SET ? val : 0
                                     games:i==L_GAMES ? val : 0
                                    points:i==L_POINTS ? val : 0];
        }
    }
}

-(NSArray*)setupLabelsArray{
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:L_END];
    for (NSUInteger i=0; i<L_END; i++) {
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectZero];
        if (i==L_NAME || i==L_COMMENTS) {
            label.backgroundColor=[UIColor clearColor];
        }else{
            label.backgroundColor=[UIColor darkGrayColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.minimumScaleFactor = 0.5;
        }

        [rv addObject:label];
        [self addSubview:label];
    }
    return rv;
}

-(void)setupSubViews{
    self.playerLabels = [self setupLabelsArray];
    self.opponentLabels = [self setupLabelsArray];
}

-(void)updateForState:(TSTennisSessionState*)state{
    self.state = state;
    [self setNeedsLayout];
}

-(void)updateLabelsText{
    TSTennisSessionState * state = self.state;

    NSString * pd = [state playerCurrentAnalysis];
    NSString * od = [state opponentCurrentAnalysis];
    if (self.enableAdjustments) {
        pd = @"";
        od = @"";
    }
    if (state.lastRally.winningContestant == tsContestantPlayer) {
        pd = [state.lastRally playerRallyDescription];
        od = @"";
    }else if (state.lastRally.winningContestant == tsContestantOpponent){
        pd = @"";

        od =[state.lastRally opponentRallyDescription];
    }

    TSTennisScore * score = [state currentScore];
    if (score) {
        NSArray * sa = [score playerOpponentFullScoreStringArray];
        NSArray * pa = sa[0];
        NSArray * oa = sa[1];

        NSArray * player = @[self.playerName, pa[0], pa[1], pa[2], pd?pd:@"" ];
        NSArray * opponent = @[self.opponentName, oa[0], oa[1], oa[2], od?od:@"" ];

        for (NSUInteger i=0; i<L_END; i++) {
            UILabel * lp = self.playerLabels[i];
            UILabel * lo = self.opponentLabels[i];

            lp.attributedText = [NSAttributedString attributedString:[self attributeFor:i] withString:player[i]];
            lo.attributedText = [NSAttributedString attributedString:[self attributeFor:i] withString:opponent[i]];
        }
    }

}

-(void)updateForSession:(TSTennisSession*)summary{
    self.playerName = [summary displayPlayerName];
    self.opponentName = [summary displayOpponentName];
}

-(void)layoutSubviews{

    CGRect rect = self.frame;
    if (rect.size.height < 100) {
        self.fontSize = 16;
        self.detailFontSize = 14;
    }else{
        self.fontSize = 32;
        self.detailFontSize = 16;
    }
    [self updateLabelsText];

    CGFloat kMargin = 3.;

    CGSize sizes[L_END];
    CGSize scoreSize = [[NSAttributedString attributedString:[self attributeFor:L_SETS] withString:@"99"] size];

    scoreSize.width += 5;


    CGFloat rowHeight= 0.;

    for (size_t i=0; i<L_END; i++) {
        UILabel * pl = self.playerLabels[i];
        UILabel * ol = self.opponentLabels[i];

        if (i==L_NAME || i==L_COMMENTS) {
            sizes[i] = [pl.attributedText size];
            CGSize os = [ol.attributedText size];
            sizes[i].width = MAX(sizes[i].width, os.width);
            sizes[i].height= MAX(sizes[i].height, os.height);

        }else{
            sizes[i] = scoreSize;
        }
        rowHeight = MAX(sizes[i].height, rowHeight);
    }

    CGFloat x = 0.;
    CGFloat y = (rect.size.height - (rowHeight * 2) - kMargin)/2.
    ;
    for (size_t i=0; i<L_END; i++) {
        UILabel * pl = self.playerLabels[i];
        UILabel * ol = self.opponentLabels[i];

        CGSize os = [ol.attributedText size];
        CGSize ps = [pl.attributedText size];

        //center adjustment
        CGFloat pca = (rowHeight-MAX(ps.height,sizes[i].height))/2.;
        CGFloat oca = (rowHeight-MAX(os.height,sizes[i].height))/2.;

        CGRect pr = CGRectMake(x, y+oca, sizes[i].width, sizes[i].height);
        CGRect or = CGRectMake(x, y+rowHeight+kMargin + pca, sizes[i].width, sizes[i].height);

        pl.frame = pr;
        ol.frame = or;
        x+= sizes[i].width + kMargin;
    }

}
@end
