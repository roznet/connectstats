//  MIT Licence
//
//  Created on 26/11/2012.
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

#import "GCSimpleGraphGestures.h"
#import "GCSimpleGraphCachedDataSource.h"
#import "GCSimpleGraphView.h"
#import <RZUtils/RZMacros.h>

@interface GCSimpleGraphGestures ()
@property (nonatomic,assign) CGPoint zoomStart;
@property (nonatomic,assign) CGPoint panStart;
@property (nonatomic,assign) CGPoint offsetStart;

@end

@implementation GCSimpleGraphGestures

-(void)dealloc{
    if (_pinchGesture) {
        [_graphView removeGestureRecognizer:self.pinchGesture];
    }
    if (_panGesture) {
        [_graphView removeGestureRecognizer:self.panGesture];
    }
    if (_longPressGesture) {
        [_graphView removeGestureRecognizer:self.longPressGesture];
    }
#if ! __has_feature(objc_arc)
    [_graphView release];
    [_panGesture release];
    [_pinchGesture release];
    [_dataSource release];
    [_longPressGesture release];

    [super dealloc];
#endif
}

-(void)setupForView:(GCSimpleGraphView*)gview andDataSource:(GCSimpleGraphCachedDataSource*)aDs{
    if (self.graphView && self.pinchGesture) {
        [self.graphView removeGestureRecognizer:self.pinchGesture];
    }
    if (self.graphView && self.panGesture) {
        [self.graphView removeGestureRecognizer:self.panGesture];
    }
    self.graphView = gview;
    self.dataSource = aDs;

	UIPinchGestureRecognizer * pi = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
	[self.graphView addGestureRecognizer:pi];
    self.pinchGesture = pi;
    RZRelease(pi);

    UIPanGestureRecognizer * pa = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    [self.graphView addGestureRecognizer:pa];
    self.panGesture = pa;
    RZRelease(pa);
    
    UILongPressGestureRecognizer * lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
    [self.graphView addGestureRecognizer:pa];
    self.longPressGesture = lp;
    RZRelease(lp);

}

-(void)longPressGesture:(UILongPressGestureRecognizer*)gestureRecognizer{
}
-(void)panGesture:(UIPanGestureRecognizer*)panRecognizer {
    if (panRecognizer.state == UIGestureRecognizerStateBegan) {
        self.panStart = [panRecognizer translationInView:self.graphView];
        self.offsetStart = self.dataSource.offsetPercentage;
    }else if(panRecognizer.state == UIGestureRecognizerStateChanged){
        CGPoint current = [panRecognizer translationInView:self.graphView];
        CGRect rect = self.graphView.frame;
        CGPoint newOffset = self.offsetStart;
        newOffset.x -= (current.x-self.panStart.x)/rect.size.width;
        newOffset.y += (current.y-self.panStart.y)/rect.size.height;
        self.dataSource.offsetPercentage = newOffset;
        [self.graphView setNeedsDisplay];
    }
}

-(void)pinchGesture:(UIPinchGestureRecognizer*)pinchRecognizer{

	if (pinchRecognizer.state == UIGestureRecognizerStateBegan) {
        if ([pinchRecognizer numberOfTouches] == 2) {
            CGRect rect = self.graphView.frame;
            CGPoint one = [pinchRecognizer locationOfTouch:0 inView:self.graphView];
            CGPoint two = [pinchRecognizer locationOfTouch:1 inView:self.graphView];
            self.zoomStart = CGPointMake(fabs( one.x-two.x )/rect.size.width, fabs(one.y-two.y)/rect.size.height);
        }
	}
	else if (pinchRecognizer.state == UIGestureRecognizerStateChanged) {
        if ([pinchRecognizer numberOfTouches] == 2) {
            CGRect rect = self.graphView.frame;
            CGPoint one = [pinchRecognizer locationOfTouch:0 inView:self.graphView];
            CGPoint two = [pinchRecognizer locationOfTouch:1 inView:self.graphView];
            CGPoint zoom = CGPointMake(fabs( one.x-two.x )/rect.size.width, fabs(one.y-two.y)/rect.size.height);
            CGPoint orig = self.dataSource.zoomPercentage;
            orig.x = MAX(MIN(orig.x+zoom.x-self.zoomStart.x, 1.), 0.);
            orig.y = MAX(MIN(orig.y+zoom.y-self.zoomStart.y, 1.), 0.);
            self.dataSource.zoomPercentage = orig;
            CGPoint middle = [pinchRecognizer locationInView:self.graphView];
            middle.x/=rect.size.width;
            middle.y/=rect.size.height;
            self.dataSource.offsetPercentage = CGPointMake(middle.x, middle.y);
            [self.graphView setNeedsDisplay];
        }
	}
}



@end
