//  MIT Licence
//
//  Created on 11/10/2012.
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

#import "GCCellActivityIndicator.h"
#import "RZViewConfig.h"
#import <RZUtils/RZMacros.h>

@interface GCCellActivityIndicator ()
@property (nonatomic,assign) RZParentObject * parent;

@end

@implementation GCCellActivityIndicator

+(GCCellActivityIndicator*)activityIndicatorCell:(UITableView*)tableView parent:(RZParentObject *)parent{
    GCCellActivityIndicator * rv = [tableView dequeueReusableCellWithIdentifier:@"ActivityCell"];
    if (!rv) {
        rv = RZReturnAutorelease([[GCCellActivityIndicator alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ActivityCell" parent:parent]);
    }
    return rv;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier parent:(RZParentObject*)parent
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if( @available(iOS 13.0, *) ){
            self.indicator = RZReturnAutorelease([[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium]);
        }else{
            self.indicator = RZReturnAutorelease([[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium]);
        }
        self.label = RZReturnAutorelease([[UILabel alloc] initWithFrame:CGRectZero]);
        _label.backgroundColor	= [UIColor clearColor];
		_label.font				= [RZViewConfig systemFontOfSize:10];
		_label.textColor         = [UIColor darkGrayColor];

        self.parent = parent;

        [self.contentView addSubview:_label];
        [self.contentView addSubview:_indicator];

        [self.parent attach:self];

    }
    return self;
}
-(void)dealloc{
    [self.parent detach:self];
    RZSuperDealloc;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];


    // Configure the view for the selected state
}
- (void)layoutSubviews {
	[super layoutSubviews];

    self.accessoryType	= UITableViewCellAccessoryNone;

	CGRect rect = self.contentView.bounds;

	CGSize labelSize	= [_label.text sizeWithAttributes:@{NSFontAttributeName:_label.font}];
    CGRect indicRect = CGRectMake(rect.size.width/2-20, 5, 40, 40);
    CGRect labelRect = CGRectMake(rect.size.width/2-labelSize.width/2, 45, labelSize.width, labelSize.height);

    _indicator.frame = indicRect;
    _label.frame = labelRect;

    [_indicator startAnimating];
}
+(CGFloat)height{
    return 100.;
}

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    dispatch_async(dispatch_get_main_queue(), ^(){
        self.label.text = [self.parent parentCurrentDescription];
        CGRect rect = self.contentView.bounds;

        CGSize labelSize    = [self.label.text sizeWithAttributes:@{NSFontAttributeName:self.label.font}];
        CGRect labelRect = CGRectMake(rect.size.width/2-labelSize.width/2, 45, labelSize.width, labelSize.height);
        self.label.frame = labelRect;

        [self setNeedsDisplay];
    });

}
@end
