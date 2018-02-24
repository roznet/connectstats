//  MIT Licence
//
//  Created on 26/10/2014.
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

#import "TSTennisSession+Cells.h"
#import "TSTennisResult.h"


@implementation TSTennisSession (Cells)

-(CGFloat)summaryCellHeight{
    return 64.;
}

-(void)setupSummary:(GCCellGrid*)gridCell{
    gridCell.enableButtons = true;
    gridCell.leftButtonText = NSLocalizedString(@"More", @"Cell Button");
    gridCell.rightButtonText = NSLocalizedString(@"Delete", @"Cell Button");

    [gridCell setupForRows:3 andCols:2];

    static NSDateFormatter * formatter = nil;
    if (formatter==nil) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
    }
    static NSDateFormatter * timeformatter = nil;
    if (timeformatter==nil) {
        timeformatter = [[NSDateFormatter alloc] init];
        [timeformatter setTimeStyle:NSDateFormatterShortStyle];
    }

    NSString * s1 = [formatter stringFromDate:self.startTime];
    NSString * s2 = [NSString stringWithFormat:@"Duration %@", [GCNumberWithUnit numberWithUnitName:@"second" andValue:self.duration]];
    NSString * s3 = [timeformatter stringFromDate:self.startTime];
    NSString * s4 = [[self result] asString];
    if (s4 == nil) {
        s4 = @"";
    }
    [gridCell labelForRow:1 andCol:1].attributedText = [RZViewConfig attributedString:s1 attribute:@selector(attribute16)];
    [gridCell labelForRow:0 andCol:1].attributedText = [RZViewConfig attributedString:s4 attribute:@selector(attribute16)];
    [gridCell labelForRow:2 andCol:0].attributedText = [RZViewConfig attributedString:s2 attribute:@selector(attribute14Gray)];
    [gridCell labelForRow:2 andCol:1].attributedText = [RZViewConfig attributedString:s3 attribute:@selector(attribute14Gray)];

    [gridCell labelForRow:0 andCol:0].attributedText = [RZViewConfig attributedString:self.displayPlayerName attribute:@selector(attributeBold14)];
    [gridCell labelForRow:1 andCol:0].attributedText = [RZViewConfig attributedString:self.displayOpponentName attribute:@selector(attribute14)];

    [gridCell setParent:self refresh:^(GCCellGrid*cell){
        NSString * s4 = [[self.state currentResult] asString];
        if (s4 == nil) {
            s4 = @"";
        }

        [cell labelForRow:0 andCol:1].attributedText = [RZViewConfig attributedString:s4 attribute:@selector(attribute16)];

    }];

    if (self.contestantWinner==tsContestantPlayer) {

        //DarkSeaGreen
        [gridCell setupBackgroundColors:@[  [UIColor colorWithHexValue:0x8FBC8F andAlpha:1.0] ] ];
    }else if(self.contestantWinner == tsContestantOpponent){
        //LightCoral
        [gridCell setupBackgroundColors:@[ [UIColor colorWithHexValue:0xF08080 andAlpha:1.0] ] ];
    }else{
        [gridCell setupBackgroundColors:@[ [UIColor whiteColor] ] ];

    }
}

-(void)setupPlayers:(GCCellGrid*)gridCell{
    [gridCell setupForRows:2 andCols:2];

    NSString * s1 = NSLocalizedString(@"Player", @"Player Names");
    NSString * s2 = self.displayPlayerName;
    NSString * s3 = NSLocalizedString(@"Opponent", @"Player Names");
    NSString * s4 = self.displayOpponentName;


    [gridCell labelForRow:0 andCol:0].attributedText = [RZViewConfig attributedString:s1 attribute:@selector(attributeBold14)];
    [gridCell labelForRow:0 andCol:1].attributedText = [RZViewConfig attributedString:s2 attribute:@selector(attribute14)];
    [gridCell labelForRow:1 andCol:0].attributedText = [RZViewConfig attributedString:s3 attribute:@selector(attributeBold14)];
    [gridCell labelForRow:1 andCol:1].attributedText = [RZViewConfig attributedString:s4 attribute:@selector(attribute14)];


}
@end
