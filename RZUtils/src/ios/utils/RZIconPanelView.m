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

#import "RZIconPanelView.h"
#import "RZMacros.h"
#import "RZIconPanelItem.h"

NSInteger kInvalidIdentifier = -1;

@interface RZIconPanelView ()
@property (nonatomic,retain) NSArray * items;

@end

@implementation RZIconPanelView

-(RZIconPanelView*)initFor:(NSArray*)items delegate:(NSObject<RZIconPanelViewDelegate>*)delegate{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.items = items;
        self.iconPanelDelegate = delegate;
        [self setupSubViews];
        self.backgroundColor = [UIColor whiteColor];
        self.alpha = 0.9;
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapIcon:)]];
    }
    return self;
}

+(RZIconPanelView*)viewFor:(NSArray*)items delegate:(NSObject<RZIconPanelViewDelegate>*)delegate{
    RZIconPanelView * rv = RZReturnAutorelease([[RZIconPanelView alloc] initFor:items delegate:delegate]);
    return rv;
}

-(void)setupSubViews{
    for (RZIconPanelItem * item in self.items) {
        [item addToView:self];
    }
}

-(void)tapIcon:(UITapGestureRecognizer*)recognizer{
    CGPoint location = [recognizer locationInView:self];
    for (RZIconPanelItem * item in self.items) {

        if ([item containsPoint:location]){
            [self.iconPanelDelegate iconPanelView:self selected:item.identifier];
            return;
        }
    }
    [self.iconPanelDelegate iconPanelView:self selected:kInvalidIdentifier];
}

-(void)layoutSubviews{
    if (self.frame.size.width == 0 ) {
        for (RZIconPanelItem * item in self.items) {
            [item hide];
        }
    }else{
        CGRect full = self.frame;
        CGPoint at = CGPointZero;
        at.x = 5.;

        CGFloat maxheight = 0;

        for (RZIconPanelItem * item in self.items) {
            CGSize  size = [item setupFrame:at];

            at.x += size.width+5.;
            maxheight = MAX(maxheight, size.height);
            if ((at.x+size.width) > full.size.width ) {
                at.x = 5.;
                at.y += maxheight;
            }
        }
    }
}


@end
