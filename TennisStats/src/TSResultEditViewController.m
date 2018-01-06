//  MIT Licence
//
//  Created on 12/01/2015.
//
//  Copyright (c) 2015 Brice Rosenzweig.
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

#import "TSResultEditViewController.h"
#import "TSResultEditOneRow.h"

@interface TSResultEditViewController ()

@property (nonatomic,retain) TSTennisSession * session;
@property (nonatomic,retain) TSTennisResult * result;
@property (nonatomic,retain) NSArray * rows;

@property (nonatomic,retain) UILabel * playerName;
@property (nonatomic,retain) UILabel * opponentName;
@property (nonatomic,retain) UISegmentedControl * playerSegment;
@property (nonatomic,retain) UISegmentedControl * opponentSegment;

@end

@implementation TSResultEditViewController

-(TSResultEditViewController*)initWithSession:(TSTennisSession*)session{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.session = session;
        // Trick to make a copy
        self.result = [[[TSTennisResult alloc] init] unpack:[session.result pack]];
    }
    return self;
}


-(void)buildViews{

    NSMutableArray * views = [NSMutableArray arrayWithCapacity:5];
    NSArray * setnames = @[ NSLocalizedString(@"First Set", @"Set Names"),
                            NSLocalizedString(@"Second Set", @"Set Names"),
                            NSLocalizedString(@"Third Set", @"Set Names"),
                            NSLocalizedString(@"Fourth Set", @"Set Names"),
                            NSLocalizedString(@"Fifth Set", @"Set Names")
                            ];

    NSArray * sets = self.result.sets;
    for (NSUInteger i = 0; i < 5; i++) {
        TSResultEditOneRow * one = [[TSResultEditOneRow alloc] init];
        one.setName = [[UILabel alloc] initWithFrame:CGRectZero];
        one.setName.textAlignment = NSTextAlignmentCenter;
        one.playerSetField = [[UITextField alloc] initWithFrame:CGRectZero];
        one.opponentSetField = [[UITextField alloc] initWithFrame:CGRectZero];

        one.playerSetField.tag = 100 + i;
        one.opponentSetField.tag = 200 + i;
        one.playerSetField.delegate = self;
        one.opponentSetField.delegate = self;

        one.opponentSetField.borderStyle = UITextBorderStyleLine;
        one.playerSetField.borderStyle = UITextBorderStyleLine;
        one.playerSetField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        one.opponentSetField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        one.playerSetField.autocorrectionType = UITextAutocorrectionTypeNo;
        one.opponentSetField.autocorrectionType = UITextAutocorrectionTypeNo;
        one.playerSetField.returnKeyType = UIReturnKeyDone;
        one.opponentSetField.returnKeyType = UIReturnKeyDone;
        one.opponentSetField.textAlignment = NSTextAlignmentCenter;
        one.playerSetField.textAlignment = NSTextAlignmentCenter;

        one.setName.text = setnames[i];
        if (i<sets.count) {
            TSTennisResultSet * set = sets[i];
            one.playerSetField.text = [@(set.playerGames) stringValue];
            one.opponentSetField.text = [@(set.opponentGames) stringValue];
        }

        [self.view addSubview:one.setName];
        [self.view addSubview:one.playerSetField];
        [self.view addSubview:one.opponentSetField];

        [views addObject:one];
    }

    self.playerName = [[UILabel alloc] initWithFrame:CGRectZero];
    self.opponentName = [[UILabel alloc] initWithFrame:CGRectZero];
    self.playerName.text = self.session.displayPlayerName;
    self.opponentName.text = self.session.displayOpponentName;
    self.playerName.textAlignment = NSTextAlignmentLeft;
    self.opponentName.textAlignment = NSTextAlignmentRight;

    [self.view addSubview:self.playerName];
    [self.view addSubview:self.opponentName];

    self.rows = views;

}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    NSInteger player = textField.tag / 100;
    NSInteger set = textField.tag - (100 * player);

    TSScore value = [textField.text integerValue];
    TSTennisResultSet * resset = nil;
    if( set < self.result.sets.count){
        resset = self.result.sets[set];
    }else if (set == self.result.sets.count && set < self.session.scoreRule.setsPerMatch) {
        [self.result nextSet];
        resset = self.result.sets[set];
    }
    if (resset) {
        if (player == 1) {
            resset.playerGames = value;
        }else{
            resset.opponentGames = value;
        }
        [self.session saveResult:self.result];
    }

}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)setupFrames{
    CGRect rect = self.view.frame;

    CGFloat y = 72.;
    CGFloat x = 15.;
    CGFloat width = rect.size.width - (x*2.);
    CGFloat height = 16.;
    CGFloat yspacing = 5.;

    self.playerName.frame = CGRectMake(x, y, width, height);
    y+=height+yspacing;
    self.opponentName.frame = CGRectMake(x, y, width, height);

    //NSArray * sets = self.result.sets;
    CGFloat setWidth = 32.;
    CGFloat nameWidth = 120.;
    CGFloat xspacing = 15.;
    CGFloat row_x = (rect.size.width - ( setWidth *2. + nameWidth + xspacing *2.))/2;

    height = 24.;
    yspacing = 10.;

    for (NSUInteger i=0; i<5; i++) {
        if (i<self.session.scoreRule.setsPerMatch) {
            y+=height+yspacing;
            TSResultEditOneRow * row = self.rows[i];
            row.playerSetField.frame = CGRectMake(row_x, y, setWidth, height);
            row.opponentSetField.frame = CGRectMake(row_x+nameWidth+ setWidth+xspacing*2., y, setWidth, height);
            row.setName.frame = CGRectMake(row_x+setWidth+xspacing, y, nameWidth, height);
        }

    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self buildViews];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self setupFrames];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
