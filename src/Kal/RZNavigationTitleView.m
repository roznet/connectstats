//
//  RZNavigationTitleView.m
//  GarminConnect
//
//  Created by Brice Rosenzweig on 24/05/2015.
//  Copyright (c) 2015 Brice Rosenzweig. All rights reserved.
//

#import "RZNavigationTitleView.h"

@interface RZNavigationTitleView ()

@end

@implementation RZNavigationTitleView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGRect titleRect = [self.title boundingRectWithSize:rect.size options:0 context:nil];
    CGRect subtitleRect = [self.subtitle boundingRectWithSize:rect.size options:0 context:nil];
    
    CGPoint center = CGPointMake(rect.origin.x + rect.size.width/2., rect.origin.y + rect.size.height/2.);
    CGFloat totalHeight = titleRect.size.height+subtitleRect.size.height;
    CGFloat spacing = (rect.size.height-totalHeight)/3.;
    titleRect.origin.x = center.x - titleRect.size.width/2.;
    titleRect.origin.y = center.y - totalHeight/2.-spacing/2.;
    
    subtitleRect.origin.x =center.x - subtitleRect.size.width/2.;
    subtitleRect.origin.y = center.y - (totalHeight/2.-titleRect.size.height) +spacing;
    [self.title drawInRect:titleRect];
    [self.subtitle drawInRect:subtitleRect];
}

@end
