//  MIT Licence
//
//  Created on 13/12/2014.
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

#import "RZIconPanelItem.h"
#import "RZMacros.h"
#import "RZViewConfig.h"

@interface RZIconPanelItem()
@property (nonatomic,retain) UIImageView * imageView;
@property (nonatomic,retain) UILabel* label;
@property (nonatomic,assign) NSInteger identifier;

@end

@implementation RZIconPanelItem

+(RZIconPanelItem*)itemForImage:(UIImage*)img label:(NSString*)label andIdentifier:(NSInteger)identifier{
    RZIconPanelItem * rv = RZReturnAutorelease([[RZIconPanelItem alloc] init]);
    if (rv) {
        rv.imageView = RZReturnAutorelease([[UIImageView alloc] initWithImage:img]);
        rv.imageView.contentMode = UIViewContentModeScaleAspectFill;
        rv.imageView.frame = CGRectZero;
        rv.label = RZReturnAutorelease([[UILabel alloc] initWithFrame:CGRectZero]);
        rv.label.text = label;
        rv.label.font = [RZViewConfig systemFontOfSize:12.];
        rv.identifier = identifier;
    }
    return rv;
}

-(CGSize)setupFrame:(CGPoint)at{
    CGSize imgSize = self.imageView.image.size;
    CGSize textSize = [self.label.text sizeWithAttributes:@{NSFontAttributeName:self.label.font}];

    CGSize size = CGSizeMake(MAX(textSize.width, imgSize.width), imgSize.height+textSize.height);

    self.imageView.frame = CGRectMake(at.x +((size.width-imgSize.width)/2.), at.y, imgSize.width, imgSize.height);
    self.label.frame = CGRectMake(at.x +((size.width-textSize.width)/2.), at.y+imgSize.height, textSize.width, textSize.height);

    return size;
}

-(void)hide{
    self.imageView.frame = CGRectZero;
    self.label.frame = CGRectZero;
}

-(void)addToView:(UIView *)view{
    [view addSubview:self.imageView];
    [view addSubview:self.label];
}

-(BOOL)containsPoint:(CGPoint)point{
    return CGRectContainsPoint(self.imageView.frame, point);
}
@end
