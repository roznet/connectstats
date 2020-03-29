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
#import "RZMacros.h"

@implementation GCCellEntrySwitch
@synthesize toggle,label,gradientLayer;


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
		label						= [[UILabel alloc] initWithFrame:CGRectZero];
		label.backgroundColor		= [UIColor clearColor];
		label.font					= [RZViewConfig boldSystemFontOfSize:16];
		label.textColor				= [RZViewConfig colorForText:rzColorStylePrimaryText];
		toggle						= [[UISwitch alloc] initWithFrame:CGRectZero];
		[toggle addTarget:self action:@selector(switchElement:) forControlEvents:UIControlEventValueChanged];
        
        gradientLayer               = [[CAGradientLayer alloc] init];

		[self.contentView addSubview:label];
		[self.contentView addSubview:toggle];

        [self.contentView.layer insertSublayer:gradientLayer atIndex:0];
    }
    return self;
}

#if ! __has_feature(objc_arc)
-(void)dealloc{
    [label release];
    [toggle release];
    [gradientLayer release];

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

    CGSize labelSize = label.attributedText.size;
    CGSize detailLabelSize = CGSizeZero;
    CGSize toggleSize = toggle.frame.size;
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

	label.frame			= labelRect;
    self.detailTextLabel.frame = detailLabelRect;
    
	toggle.frame		= toggleRect;
    gradientLayer.frame = self.contentView.bounds;
}

-(void)switchElement:(id)sender{
	[entryFieldDelegate cellWasChanged:self];
}

-(BOOL)on{
    return toggle.on;
}
@end
