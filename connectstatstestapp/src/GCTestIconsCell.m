//  MIT Licence
//
//  Created on 08/08/2013.
//
//  Copyright (c) 2013 Brice Rosenzweig.
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

#import "GCTestIconsCell.h"
#import "GCViewIcons.h"
#import "GCViewConfig.h"

@implementation GCTestIconsCell

-(UIImageView*)addImage:(UIImage*)img{
    UIImageView * view = nil;
    if (img) {
        view = [[[UIImageView alloc] initWithImage:img] autorelease];
        [self.contentView addSubview:view];
    }
    return view;
}

+(GCTestIconsCell*)iconsCellForActivityType:(NSString*)atype{
    GCTestIconsCell * rv = [[[GCTestIconsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IconView"] autorelease];
    NSMutableArray * v = [NSMutableArray arrayWithCapacity:5];
    UIImageView * view =[rv addImage:[GCViewIcons activityTypeColoredIconFor:atype]];
    if (view) {
        [v addObject:view];
    }
    view =[rv addImage:[GCViewIcons activityTypeBWIconFor:atype]];
    if (view) {
        [v addObject:view];
    }
    
    UIImage * dynIcon = [GCViewIcons activityTypeDynamicIconFor:atype];
    if( dynIcon ){
        [v addObject:[rv addImage:dynIcon]];
    }
    [rv.contentView setBackgroundColor:[GCViewConfig cellBackgroundLighterForActivity:atype]];
    rv.imageViews = v;
    return rv;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)dealloc{
    [_imageViews release];
    [super dealloc];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)layoutSubviews {
	[super layoutSubviews];
    for (NSUInteger i=0; i<[self.imageViews count]; i++) {
        UIImageView * view = [self.imageViews objectAtIndex:i];
        CGRect rect = view.frame;
        rect.origin.x = i * 45+5;
        rect.origin.y = 5;
        view.frame = rect;
    }
}
@end
