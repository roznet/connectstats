/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import <CoreGraphics/CoreGraphics.h>

#import "KalGridView.h"
#import "KalView.h"
#import "KalMonthView.h"
#import "KalTileView.h"
#import "KalLogic.h"
#import "KalDate.h"
#import "KalPrivate.h"

#define SLIDE_NONE 0
#define SLIDE_UP 1
#define SLIDE_DOWN 2

//const CGSize kTileSize = { 46.f, 44.f };

static NSString *kSlideAnimationId = @"KalSwitchMonths";

@interface KalGridView ()
@property (nonatomic, retain) KalTileView *selectedTile;
@property (nonatomic, retain) KalTileView *highlightedTile;
- (void)swapMonthViews;
@end

@implementation KalGridView

@synthesize selectedTile, highlightedTile, transitioning;

- (id)initWithFrame:(CGRect)frame dataSource:(id<KalDataSource>)source logic:(KalLogic *)theLogic delegate:(id<KalViewDelegate>)theDelegate
{
    // MobileCal uses 46px wide tiles, with a 2px inner stroke
    // along the top and right edges. Since there are 7 columns,
    // the width needs to be 46*7 (322px). But the iPhone's screen
    // is only 320px wide, so we need to make the
    // frame extend just beyond the right edge of the screen
    // to accomodate all 7 columns. The 7th day's 2px inner stroke
    // will be clipped off the screen, but that's fine because
    // MobileCal does the same thing.
    self.tileSize = CGSizeMake(46.f, 44.f);
    
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        logic = [theLogic retain];
        delegate = theDelegate;
        _dataSource = source;
        
        frontMonthView = [[KalMonthView alloc] initWithFrame:frame dataSource:source andTileSize:self.tileSize];
        backMonthView = [[KalMonthView alloc] initWithFrame:frame dataSource:source andTileSize:self.tileSize];
        backMonthView.hidden = YES;
        [self addSubview:backMonthView];
        [self addSubview:frontMonthView];
        
        [self jumpToSelectedMonth];
        
        UISwipeGestureRecognizer * gestureDown = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)] autorelease];
        UISwipeGestureRecognizer * gestureUp   = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)] autorelease];
        UITapGestureRecognizer * gestureTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)] autorelease];
        
        gestureDown.direction = UISwipeGestureRecognizerDirectionDown;
        gestureUp.direction = UISwipeGestureRecognizerDirectionUp;
        
        [self addGestureRecognizer:gestureDown];
        [self addGestureRecognizer:gestureUp];
        [self addGestureRecognizer:gestureTap];
        
        self.backgroundColor = self.dataSource.backgroundColor;

    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [self.dataSource.backgroundColor setFill];
    CGContextFillRect(ctx, rect);
    
    [self.dataSource.separatorColor setFill];
    CGRect line;
    line.origin = CGPointMake(0.f, self.height - 1.f);
    line.size = CGSizeMake(self.width, 1.f);
    CGContextFillRect(ctx, line);
}

-(void)setupFrame:(CGRect)frame{
    
    CGRect monthRect = CGRectMake(0.f, 0.f, frame.size.width, frame.size.height);
    self.frame = monthRect;
    frontMonthView.frame = monthRect;
    backMonthView.frame = monthRect;
    frontMonthView.tileSize = self.tileSize;
    backMonthView.tileSize = self.tileSize;
    [frontMonthView setupFrame:monthRect];
    [backMonthView setupFrame:monthRect];
    [self sizeToFit];
}
- (void)sizeToFit
{
  self.height = frontMonthView.height;
}

#pragma mark -
#pragma mark Touches

- (void)setHighlightedTile:(KalTileView *)tile
{
  if (highlightedTile != tile) {
    highlightedTile.highlighted = NO;
    highlightedTile = [tile retain];
    tile.highlighted = YES;
    [tile setNeedsDisplay];
  }
}

- (void)setSelectedTile:(KalTileView *)tile
{
  if (selectedTile != tile) {
    selectedTile.selected = NO;
    selectedTile = [tile retain];
    tile.selected = YES;
    [delegate didSelectDate:tile.date];
  }
}

- (void)receivedTouches:(NSSet *)touches withEvent:event
{
  UITouch *touch = [touches anyObject];
  CGPoint location = [touch locationInView:self];
  UIView *hitView = [self hitTest:location withEvent:event];
  
  if (!hitView)
    return;
  
  if ([hitView isKindOfClass:[KalTileView class]]) {
    KalTileView *tile = (KalTileView*)hitView;
    if (tile.belongsToAdjacentMonth) {
      self.highlightedTile = tile;
    } else {
      self.highlightedTile = nil;
      self.selectedTile = tile;
    }
  }
}

-(void)swipeGesture:(UISwipeGestureRecognizer*)gesture{
    if (gesture.direction == UISwipeGestureRecognizerDirectionDown) {
        [delegate showPreviousMonth];
    }else{
        [delegate showFollowingMonth];
    }
}

-(void)tapGesture:(UITapGestureRecognizer*)gesture
{
    CGPoint location = [gesture locationInView:self];
    UIView *hitView = [self hitTest:location withEvent:nil];
    
    if ([hitView isKindOfClass:[KalTileView class]]) {
        KalTileView *tile = (KalTileView*)hitView;
        if (tile.belongsToAdjacentMonth) {
            if ([tile.date compare:[KalDate dateFromNSDate:logic.baseDate]] == NSOrderedDescending) {
                [delegate showFollowingMonth];
            } else {
                [delegate showPreviousMonth];
            }
            self.selectedTile = [frontMonthView tileForDate:tile.date];
        } else {
            self.selectedTile = tile;
        }
    }
    self.highlightedTile = nil;
}

#pragma mark -
#pragma mark Slide Animation

- (void)swapMonthsAndSlide:(int)direction keepOneRow:(BOOL)keepOneRow
{
  backMonthView.hidden = NO;
  
  // set initial positions before the slide
  if (direction == SLIDE_UP) {
    backMonthView.top = keepOneRow
      ? frontMonthView.bottom - _tileSize.height
      : frontMonthView.bottom;
  } else if (direction == SLIDE_DOWN) {
    NSUInteger numWeeksToKeep = keepOneRow ? 1 : 0;
    NSInteger numWeeksToSlide = [backMonthView numWeeks] - numWeeksToKeep;
    backMonthView.top = -numWeeksToSlide * _tileSize.height;
  } else {
    backMonthView.top = 0.f;
  }
  
  // trigger the slide animation
  [UIView beginAnimations:kSlideAnimationId context:NULL]; {
    [UIView setAnimationsEnabled:direction!=SLIDE_NONE];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    
    frontMonthView.top = -backMonthView.top;
    backMonthView.top = 0.f;

    frontMonthView.alpha = 0.f;
    backMonthView.alpha = 1.f;
    
    self.height = backMonthView.height;
    
    [self swapMonthViews];
  } [UIView commitAnimations];
 [UIView setAnimationsEnabled:YES];
}

- (void)slide:(int)direction
{
  transitioning = YES;
  
  [backMonthView showDates:logic.daysInSelectedMonth
      leadingAdjacentDates:logic.daysInFinalWeekOfPreviousMonth
     trailingAdjacentDates:logic.daysInFirstWeekOfFollowingMonth];
  
  // At this point, the calendar logic has already been advanced or retreated to the
  // following/previous month, so in order to determine whether there are 
  // any cells to keep, we need to check for a partial week in the month
  // that is sliding offscreen.
  
  BOOL keepOneRow = (direction == SLIDE_UP && [logic.daysInFinalWeekOfPreviousMonth count] > 0)
                 || (direction == SLIDE_DOWN && [logic.daysInFirstWeekOfFollowingMonth count] > 0);
  
  [self swapMonthsAndSlide:direction keepOneRow:keepOneRow];
  
  self.selectedTile = [frontMonthView firstTileOfMonth];
}

- (void)slideUp { [self slide:SLIDE_UP]; }
- (void)slideDown { [self slide:SLIDE_DOWN]; }

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
  transitioning = NO;
  backMonthView.hidden = YES;
}

#pragma mark -

- (void)selectDate:(KalDate *)date
{
  self.selectedTile = [frontMonthView tileForDate:date];
}

- (void)swapMonthViews
{
  KalMonthView *tmp = backMonthView;
  backMonthView = frontMonthView;
  frontMonthView = tmp;
  [self exchangeSubviewAtIndex:[self.subviews indexOfObject:frontMonthView] withSubviewAtIndex:[self.subviews indexOfObject:backMonthView]];
}

- (void)jumpToSelectedMonth
{
  [self slide:SLIDE_NONE];
}

- (void)markTilesForDates:(NSArray *)dates andSource:(id<KalDataSource>)source { [frontMonthView markTilesForDates:dates andSource:source]; }

- (KalDate *)selectedDate { return selectedTile.date; }

#pragma mark -

- (void)dealloc
{
  [selectedTile release];
  [highlightedTile release];
  [frontMonthView release];
  [backMonthView release];
  [logic release];
  [super dealloc];
}

@end
