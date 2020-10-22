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

#import "GCCellEntrySwitch.h"
#import "RZViewConfig.h"
#import <RZUtils/RZMacros.h>

@implementation GCCellEntrySwitch

+(GCCellEntrySwitch*)switchCell:(UITableView*)tableView{
    GCCellEntrySwitch * cell = (GCCellEntrySwitch*)[tableView dequeueReusableCellWithIdentifier:@"GCSwitch"];
    if (cell == nil) {
        cell = RZReturnAutorelease([[GCCellEntrySwitch alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"GCSwitch"]);
    }
    cell.detailTextLabel.text = nil;
    cell.textLabel.text = nil;
    
    return cell;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.label						= RZReturnAutorelease([[UILabel alloc] initWithFrame:CGRectZero]);
		self.label.backgroundColor		= [UIColor clearColor];
		self.label.font					= [RZViewConfig boldSystemFontOfSize:16];
		self.label.textColor				= [RZViewConfig colorForText:rzColorStylePrimaryText];
		self.toggle						= RZReturnAutorelease([[UISwitch alloc] initWithFrame:CGRectZero]);
		[self.toggle addTarget:self action:@selector(switchElement:) forControlEvents:UIControlEventValueChanged];
        
        self.gradientLayer               = [[CAGradientLayer alloc] init];

		[self.contentView addSubview:self.label];
		[self.contentView addSubview:self.toggle];

        [self.contentView.layer insertSublayer:self.gradientLayer atIndex:0];
    }
    return self;
}

#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_label release];
    [_toggle release];
    [_gradientLayer release];

    [super dealloc];
}
#endif

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
	[super layoutSubviews];

	// Rect that start at 5 from left bound x
	CGRect baseRect = self.contentView.bounds;

    CGSize labelSize = self.label.attributedText.size;
    CGSize detailLabelSize = CGSizeZero;
    CGSize toggleSize = self.toggle.frame.size;
    CGRect labelRect = CGRectZero;
    CGRect detailLabelRect = CGRectZero;
    
    if( self.detailTextLabel.attributedText){
        detailLabelSize = self.detailTextLabel.attributedText.size;
        
        CGFloat spacing = 1.;
        CGFloat totalHeight = detailLabelSize.height + labelSize.height + spacing;
        
        labelRect  = CGRectMake(4., baseRect.size.height/2.-totalHeight/2., labelSize.width, labelSize.height);
        detailLabelRect = CGRectMake(4., labelRect.origin.y + spacing + labelSize.height, detailLabelSize.width, detailLabelSize.height);
    }else{
        labelRect  = CGRectMake(4., baseRect.size.height/2.-labelSize.height/2., labelSize.width, labelSize.height);
    }
    
    CGRect toggleRect = CGRectMake(CGRectGetMaxX(baseRect)-5.-toggleSize.width, baseRect.size.height/2.-toggleSize.height/2.,
                                   toggleSize.width, toggleSize.height );

	self.label.frame			= labelRect;
    self.detailTextLabel.frame = detailLabelRect;
    
	self.toggle.frame		= toggleRect;
    self.gradientLayer.frame = self.contentView.bounds;
}

-(void)switchElement:(id)sender{
    [self.entryFieldDelegate cellWasChanged:self];
    if( self.entryFieldCompletion){
        self.entryFieldCompletion(self);
    }
}

-(BOOL)on{
    return self.toggle.on;
}
@end
