//  MIT Licence
//
//  Created on 07/10/2012.
//
//  Copyright (c) 2012 Brice Rosenzweig.
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

#import "GCCellEntryText.h"
#import "RZViewConfig.h"
#import "RZMacros.h"

#define kMarginX 2.f

@implementation GCCellEntryText
@synthesize label,textField,gradientLayer;

+(GCCellEntryText*)textCell:(UITableView*)tableView{
    GCCellEntryText * cell = (GCCellEntryText*)[tableView dequeueReusableCellWithIdentifier:@"GCText"];
    if (cell == nil) {
        cell = RZReturnAutorelease([[GCCellEntryText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GCText"]);
    }
    return cell;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:frame reuseIdentifier:reuseIdentifier]) {

		label						= [[UILabel alloc] initWithFrame:CGRectZero];
		label.backgroundColor		= [UIColor clearColor];
		label.font					= [RZViewConfig boldSystemFontOfSize:16];
		label.textColor				= [UIColor blackColor];

		textField					= [[UITextField alloc] initWithFrame:CGRectZero];
		textField.backgroundColor	= [UIColor clearColor];
		textField.font				= [RZViewConfig systemFontOfSize:16];
		textField.textColor			= [UIColor blueColor];
		textField.keyboardType		= UIKeyboardTypeDefault;
		textField.borderStyle		= UITextBorderStyleRoundedRect;

		textField.delegate = self;

        gradientLayer               = [[CAGradientLayer alloc] init];

		[self.contentView addSubview:textField];
		[self.contentView addSubview:label];

        [self.contentView.layer insertSublayer:gradientLayer atIndex:0];
    }
    return self;
}
#if ! __has_feature(objc_arc)
-(void)dealloc{
    [textField release];
    [label release];
    [gradientLayer release];

    [super dealloc];
}
#endif

- (void)layoutSubviews {
	[super layoutSubviews];

	// Rect that start at 5 from left bound x
	CGRect baseRect = self.contentView.bounds;
	CGRect rect = baseRect;

	CGSize labelSize	= [label.text	sizeWithAttributes:@{NSFontAttributeName:label.font}];

    CGRect labelRect = CGRectMake( kMarginX, rect.size.height/2.-labelSize.height/2., labelSize.width, labelSize.height);
	CGRect fieldRect = CGRectMake(CGRectGetMaxX(labelRect)+10., labelRect.origin.y-2.,
                                  CGRectGetMaxX(baseRect)-(CGRectGetMaxX(labelRect)+15.), labelSize.height+4.);

	label.frame			= labelRect;
	textField.frame		= fieldRect;

    gradientLayer.frame = self.contentView.bounds;
    //[GCViewConfig setupGradientForDetails:gradientLayer];
}

-(NSString*)text{
    return textField.text;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(BOOL)resignFirstResponder{
    [super resignFirstResponder];
    return [self.textField resignFirstResponder];
}

-(void)textFieldDidBeginEditing:(UITextField*)aField{
	[entryFieldDelegate baseNavigationItem].rightBarButtonItem = RZReturnAutorelease([[UIBarButtonItem alloc]
                                                                 initWithTitle:NSLocalizedString(@"Done", @"Cell Entry Button")
                                                                 style:UIBarButtonItemStyleDone
                                                                 target:self
                                                                 action:@selector(doneEditing:)]
                                                                );

}

-(void)textFieldDidEndEditing:(UITextField*)aField{
	[entryFieldDelegate cellWasChanged:self];
    [entryFieldDelegate baseNavigationItem].rightBarButtonItem = nil;
}


-(void)doneEditing:(id)sender{
	[self.textField resignFirstResponder];
	[entryFieldDelegate cellWasChanged:self];
}

@end
