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
#import "RZMacros.h"

@implementation GCSimpleGraphGestures
@synthesize graphView,dataSource,pinchGesture,panGesture;

-(void)dealloc{
    if (pinchGesture) {
        [graphView removeGestureRecognizer:pinchGesture];
    }
    if (panGesture) {
        [graphView removeGestureRecognizer:panGesture];
    }
#if ! __has_feature(objc_arc)
    [graphView release];
    [panGesture release];
    [pinchGesture release];
    [dataSource release];

    [super dealloc];
#endif
}

-(void)setupForView:(GCSimpleGraphView*)gview andDataSource:(GCSimpleGraphCachedDataSource*)aDs{
    if (graphView && pinchGesture) {
        [graphView removeGestureRecognizer:pinchGesture];
    }
    if (graphView && panGesture) {
        [graphView removeGestureRecognizer:panGesture];
    }
    self.graphView = gview;
    self.dataSource = aDs;

	UIPinchGestureRecognizer * pi = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
	[graphView addGestureRecognizer:pi];
    self.pinchGesture = pi;
    RZRelease(pi);

    UIPanGestureRecognizer * pa = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    [graphView addGestureRecognizer:pa];
    self.panGesture = pa;
    RZRelease(pa);
}

-(void)panGesture:(UIPanGestureRecognizer*)panRecognizer {
    if (panRecognizer.state == UIGestureRecognizerStateBegan) {
        panStart = [panRecognizer translationInView:graphView];
        offsetStart = dataSource.offsetPercentage;
    }else if(panRecognizer.state == UIGestureRecognizerStateChanged){
        CGPoint current = [panRecognizer translationInView:graphView];
        CGRect rect = graphView.frame;
        CGPoint newOffset = offsetStart;
        newOffset.x -= (current.x-panStart.x)/rect.size.width;
        newOffset.y += (current.y-panStart.y)/rect.size.height;
        dataSource.offsetPercentage = newOffset;
        [graphView setNeedsDisplay];
    }
}

-(void)pinchGesture:(UIPinchGestureRecognizer*)pinchRecognizer{

	if (pinchRecognizer.state == UIGestureRecognizerStateBegan) {
        if ([pinchRecognizer numberOfTouches] == 2) {
            CGRect rect = graphView.frame;
            CGPoint one = [pinchRecognizer locationOfTouch:0 inView:graphView];
            CGPoint two = [pinchRecognizer locationOfTouch:1 inView:graphView];
            zoomStart = CGPointMake(fabs( one.x-two.x )/rect.size.width, fabs(one.y-two.y)/rect.size.height);
        }
	}
	else if (pinchRecognizer.state == UIGestureRecognizerStateChanged) {
        if ([pinchRecognizer numberOfTouches] == 2) {
            CGRect rect = graphView.frame;
            CGPoint one = [pinchRecognizer locationOfTouch:0 inView:graphView];
            CGPoint two = [pinchRecognizer locationOfTouch:1 inView:graphView];
            CGPoint zoom = CGPointMake(fabs( one.x-two.x )/rect.size.width, fabs(one.y-two.y)/rect.size.height);
            CGPoint orig = dataSource.zoomPercentage;
            orig.x = MAX(MIN(orig.x+zoom.x-zoomStart.x, 1.), 0.);
            orig.y = MAX(MIN(orig.y+zoom.y-zoomStart.y, 1.), 0.);
            dataSource.zoomPercentage = orig;
            CGPoint middle = [pinchRecognizer locationInView:graphView];
            middle.x/=rect.size.width;
            middle.y/=rect.size.height;
            dataSource.offsetPercentage = CGPointMake(middle.x, middle.y);
            [graphView setNeedsDisplay];
        }
	}
}



@end
