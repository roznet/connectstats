//  MIT Licence
//
//  Created on 16/06/2015.
//
//  Copyright (c) 2015 Brice Rosenzweig.
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

#import "RZMultiSliderControl.h"
#import "RZMultiSliderKnob.h"
#import <RZUtils/RZMacros.h>

@interface RZMultiSliderControl ()

@property (nonatomic,retain) NSMutableArray * knobs;
@property (nonatomic,retain) NSMutableArray * knobsDescriptions;
@property (nonatomic,retain) NSMutableArray * rangeDescriptions;
@property (nonatomic,retain) NSMutableArray * rangeBoxes;

@property (nonatomic,assign) CGFloat touchedOffset;
@property (nonatomic,assign) UIView * guide;

@end

@implementation RZMultiSliderControl



-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];

    if (self) {
        self.knobSize = CGSizeMake(40., 40.);
    }
    return self;
}

#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_knobs release];
    [_knobsDescriptions release];
    [_rangeDesriptions release];
    [_values release];

    [_guide release];

    [super dealloc];
}
#endif

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {

    CGSize knobSize = self.knobSize;

    UIBezierPath * track = [UIBezierPath bezierPathWithRect:CGRectMake(knobSize.width/2., 0., 1., rect.size.height)];
    [[UIColor redColor] setFill];
    [track fill];


}
-(void)layoutSubviews{
    if (self.knobs==nil) {
        [self buildViews:self.values];
    }
    [self setupFrames];
}

-(void)setupFrames{
    CGSize knobSize = self.knobSize;

    NSUInteger n = self.values.count;

    CGFloat height = self.frame.size.height - n * knobSize.height;
    CGFloat valueRange = self.maximumValue-self.minimumValue;

    for (NSUInteger i=0; i<n; i++) {
        NSNumber * valueN = self.values[i];
        RZMultiSliderKnob * knob = self.knobs[i];
        CGFloat y = (valueN.floatValue - self.minimumValue)/(valueRange)*height;
        y += i * knobSize.height;
        knob.frame = CGRectMake(0., y, knobSize.width, knobSize.height);
    }

    // Two loops because for frame to be setup right the next knob index
    // frame needs to be set
    for (NSUInteger i=0; i<n; i++) {
        RZMultiSliderKnob * knob = self.knobs[i];
        CGFloat y = knob.frame.origin.y;
        [self setupFramesForKnobAtIndex:i andY:y];
    }
    [self updateAllLabels];
}

-(NSArray*)valuesFromKnobs{
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:self.knobs.count];

    for (RZMultiSliderKnob * knob in self.knobs) {
        [rv addObject:@(knob.value)];
    }
    return rv;
}

-(void)pan:(UIPanGestureRecognizer*)recognizer{

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSUInteger idx = recognizer.view.tag;
        if (idx < self.knobs.count) {
            RZMultiSliderKnob * knob = self.knobs[idx];
            self.touchedOffset = [recognizer locationInView:knob].y;
        }else{
            self.touchedOffset = 0.;
        }
    }else if (recognizer.state == UIGestureRecognizerStateChanged){
        NSUInteger idx = recognizer.view.tag;
        CGFloat y = [recognizer locationInView:self].y-self.touchedOffset;
        [self setupFramesForKnobAtIndex:idx andY:y];
        self.values = [self valuesFromKnobs];
        if ([self.multiDelegate respondsToSelector:@selector(multiSlider:valuesChanged:)]) {
            [self.multiDelegate multiSlider:self valuesChanged:self.values];
        }
        [self updateAllLabels];
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        self.touchedOffset = 0.;
    }
}

-(void)updateAllLabels{
    NSUInteger n = self.knobs.count;
    for (NSUInteger idx=0; idx<n; idx++) {
        RZMultiSliderKnob * knob = self.knobs[idx];
        RZMultiSliderKnob * next = idx < n-1 ? self.knobs[idx+1] : nil;
        CGRect rect = knob.frame;

        CGFloat start = knob.frame.origin.y+knob.frame.size.height;
        CGFloat end   = next ? next.frame.origin.y : start;

        if (idx < self.knobsDescriptions.count) {
            UILabel * desc = self.knobsDescriptions[idx];
            if ([self.multiDelegate respondsToSelector:@selector(multiSlider:describeValue:)] &&
                idx < self.knobsDescriptions.count) {
                NSAttributedString * text = [self.multiDelegate multiSlider:self describeValue:knob.value];
                CGSize textSize = text.size;
                CGRect textRect = CGRectMake(rect.origin.x + rect.size.width + 5.,
                                             rect.origin.y + rect.size.height/2. - textSize.height/2.,
                                             textSize.width,
                                             textSize.height);
                desc.attributedText = text;
                desc.frame = textRect;
            }else{
                desc.attributedText = nil;
                desc.frame = CGRectZero;
            }
        }
        if(idx < self.rangeDescriptions.count && start != end){
            UILabel * desc = self.rangeDescriptions[idx];

            if ([self.multiDelegate respondsToSelector:@selector(multiSlider:describeRange:)]) {
                NSAttributedString * text = [self.multiDelegate multiSlider:self describeRange:idx];
                CGSize textSize = text.size;
                CGRect textRect = CGRectMake(rect.origin.x + rect.size.width + 5.,
                                             (start + end) / 2. - textSize.height/2.,
                                             textSize.width,
                                             textSize.height);
                desc.attributedText = text;
                desc.frame = textRect;
            }else{
                desc.frame = CGRectZero;
            }
        }
    }
}

/**
 @brief setup frame of descriptions, value and range
 @param y the origin.y of the knob rect
 */
-(void)setupFramesForKnobAtIndex:(NSUInteger)idx andY:(CGFloat)y{
    if (idx < self.knobs.count) {
        CGFloat start = 0.;
        CGFloat startVal = self.minimumValue;
        if (idx>0) {
            RZMultiSliderKnob * knob = self.knobs[idx-1];
            start = knob.frame.origin.y + knob.frame.size.height;
            startVal = knob.value;
        }
        CGFloat end = self.frame.size.height;
        CGFloat endVal = self.maximumValue;
        if (idx+1<self.knobs.count) {
            RZMultiSliderKnob * knob = self.knobs[idx+1];
            end = knob.frame.origin.y;
            endVal = knob.value;
        }
        //[self guideAt:end];
        RZMultiSliderKnob * knob = self.knobs[idx];
        end -= knob.frame.size.height;

        if (y>= start && y<=end) {
            CGRect rect = knob.frame;
            rect.origin.y = y;
            knob.frame = rect;
            knob.value = startVal + (y-start)/(end-start)*(endVal-startVal);
            /*if (y<=start) {
                self.minimumValue = knob.value;
            }
            if(y>=end){
                self.maximumValue = knob.value;
            }*/
            if ([self.multiDelegate respondsToSelector:@selector(multiSlider:formatValue:)]) {
                knob.attributedText = [self.multiDelegate multiSlider:self formatValue:knob.value];
            }else{
                knob.attributedText = nil;
            }
            [knob setNeedsDisplay];
        }
    }

}

-(void)guideAt:(CGFloat)y{
    self.guide.frame = CGRectMake(0., y, self.frame.size.width, 1.);
}

-(void)buildViews:(NSArray*)values{
    // Clear all subviews
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];

    self.knobs = [NSMutableArray array];
    self.knobsDescriptions = [NSMutableArray array];
    self.rangeDescriptions = [NSMutableArray array];
    NSInteger tag = 0;
    NSDictionary * attr = @{NSFontAttributeName:[UIFont systemFontOfSize:12.],NSForegroundColorAttributeName:[UIColor whiteColor]};

    for (NSUInteger i=0;i<values.count;i++) {
        UIView * box = RZReturnAutorelease([[UIView alloc] initWithFrame:CGRectZero]);
        box.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.1+i/values.count*0.8];
        [self addSubview:box];
        [self.rangeBoxes addObject:box];
    }
    for (NSNumber * num in values) {
        RZMultiSliderKnob * knob =RZReturnAutorelease([[RZMultiSliderKnob alloc] initWithFrame:CGRectZero]);
        knob.value = num.floatValue;
        knob.attributedText = RZReturnAutorelease([[NSAttributedString alloc] initWithString:num.description attributes:attr]);
        knob.backgroundColor = [UIColor clearColor];
        knob.tag = tag;
        tag++;
        [self addSubview:knob];
        [self.knobs addObject:knob];
        UIPanGestureRecognizer * pan= RZReturnAutorelease([[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)]);
        [knob addGestureRecognizer:pan];

        UILabel * rangeDesc = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:rangeDesc];
        [self.rangeDescriptions addObject:rangeDesc];

        UILabel * knobDesc = RZReturnAutorelease([[UILabel alloc] initWithFrame:CGRectZero]);
        [self addSubview:knobDesc];
        [self.knobsDescriptions addObject:knobDesc];
    }
    // One more range after the last knob
    UILabel * rangeDesc = RZReturnAutorelease([[UILabel alloc] initWithFrame:CGRectZero]);
    [self addSubview:rangeDesc];
    [self.rangeDescriptions addObject:rangeDesc];

    UIView * guide = [[UIView alloc] initWithFrame:CGRectZero];
    guide.backgroundColor = [UIColor blackColor];
    self.guide = guide;
    [self addSubview:guide];

}


@end
