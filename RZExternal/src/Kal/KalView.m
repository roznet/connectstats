/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import "KalView.h"
#import "KalGridView.h"
#import "KalLogic.h"
#import "KalPrivate.h"

@interface KalView ()
@property (nonatomic,retain) UIView * headerView;
@property (nonatomic,retain) UIImageView *backgroundView;
@property (nonatomic,retain) UIButton * previousMonthButton;
@property (nonatomic,retain) UIButton *nextMonthButton;
@property (nonatomic,retain) NSArray* weekdayLabels;

@property (nonatomic,retain) UIView * contentView;

- (void)addSubviewsToHeaderView:(UIView *)headerView;
- (void)addSubviewsToContentView:(UIView *)contentView;
- (void)setHeaderTitleText:(NSString *)text;
@end

static const CGFloat kHeaderHeight = 20.f;
static const CGFloat kMonthLabelHeight = 17.f;

@implementation KalView

@synthesize delegate, tableView;

- (id)initWithFrame:(CGRect)frame delegate:(id<KalViewDelegate>)theDelegate logic:(KalLogic *)theLogic
{
    if ((self = [super initWithFrame:frame])) {
        float kVerticalOffset = 0.f;
        if([[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue] >= 7){
            kVerticalOffset = 60.f;
        }
        delegate = theDelegate;
        logic = [theLogic retain];
        [logic addObserver:self forKeyPath:@"selectedMonthNameAndYear" options:NSKeyValueObservingOptionNew context:NULL];
        self.autoresizesSubviews = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        self.headerView = [[[UIView alloc] initWithFrame:CGRectMake(0.f, kVerticalOffset, MIN(frame.size.width,322.), kHeaderHeight)] autorelease];
        self.headerView.backgroundColor = [UIColor grayColor];
        [self addSubviewsToHeaderView:self.headerView];
        [self addSubview:self.headerView];
        
        self.contentView = [[[UIView alloc] initWithFrame:CGRectMake(0.f, kVerticalOffset+kHeaderHeight, MIN(frame.size.width,322.), frame.size.height - kHeaderHeight)] autorelease];
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self addSubviewsToContentView:self.contentView];
        [self addSubview:self.contentView];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
  [NSException raise:@"Incomplete initializer" format:@"KalView must be initialized with a delegate and a KalLogic. Use the initWithFrame:delegate:logic: method."];
  return nil;
}

- (void)redrawEntireMonth { [self jumpToSelectedMonth]; }

- (void)slideDown { [gridView slideDown]; }
- (void)slideUp { [gridView slideUp]; }

- (void)showPreviousMonth
{
  if (!gridView.transitioning)
    [delegate showPreviousMonth];
}

- (void)showFollowingMonth
{
  if (!gridView.transitioning)
    [delegate showFollowingMonth];
}

- (void)setupFrame:(CGRect)frame{
    self.tileSize = CGSizeMake(46.f, 44.f);
    if (frame.size.width != 320.) {
        self.tileSize = CGSizeMake(frame.size.width/7., 44.f );
    }
    //frame.size.width = 7 * self.tileSize.width;
    gridView.tileSize = self.tileSize;
    self.frame = frame;

    [self setupHeaderViewFrame:frame];
    [self setupContentViewFrame:frame];
    
}

-(void)setupHeaderViewFrame:(CGRect)frame{
    const CGFloat kChangeMonthButtonWidth = 46.0f;
    const CGFloat kChangeMonthButtonHeight = 30.0f;
    const CGFloat kMonthLabelWidth = 200.0f;
    const CGFloat kHeaderVerticalAdjust = 3.f;
    
    CGRect imageFrame = frame;
    imageFrame.origin = CGPointZero;
    self.backgroundView.frame = imageFrame;

    CGRect previousMonthButtonFrame = CGRectMake(self.left,
                                                 kHeaderVerticalAdjust,
                                                 kChangeMonthButtonWidth,
                                                 kChangeMonthButtonHeight);
    self.previousMonthButton.frame = previousMonthButtonFrame;
    self.previousMonthButton.frame = CGRectZero;
    
    CGRect monthLabelFrame = CGRectMake((MIN(self.width,322.)/2.0f) - (kMonthLabelWidth/2.0f),
                                        kHeaderVerticalAdjust,
                                        kMonthLabelWidth,
                                        kMonthLabelHeight);
    headerTitleLabel.frame = monthLabelFrame;
    headerTitleLabel.frame = CGRectZero;
    CGRect nextMonthButtonFrame = CGRectMake(MIN(self.width,322.) - kChangeMonthButtonWidth,
                                             kHeaderVerticalAdjust,
                                             kChangeMonthButtonWidth,
                                             kChangeMonthButtonHeight);
    self.nextMonthButton.frame = nextMonthButtonFrame;
    self.nextMonthButton.frame = CGRectZero;
    
    CGFloat xOffset = 0.f;
    for (UILabel * one in self.weekdayLabels) {
//        CGRect weekdayFrame = CGRectMake(xOffset, 30.f, self.tileSize.width, kHeaderHeight - 29.f);
        CGRect weekdayFrame = CGRectMake(xOffset, 30.f-14.f, self.tileSize.width, kHeaderHeight - 29.f);
        one.frame = weekdayFrame;
        xOffset += self.tileSize.width;
    }
}

- (void)addSubviewsToHeaderView:(UIView *)headerView
{
    
    // Header background gradient
    self.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:kalBundleFile(@"kal_grid_background.png")]] autorelease];
    [headerView addSubview:self.backgroundView];
    
    // Create the previous month button on the left side of the view
    UIButton *previousMonthButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [previousMonthButton setAccessibilityLabel:NSLocalizedString(@"Previous month", nil)];
    [previousMonthButton setImage:[UIImage imageNamed:kalBundleFile(@"kal_left_arrow.png")] forState:UIControlStateNormal];
    previousMonthButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    previousMonthButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [previousMonthButton addTarget:self action:@selector(showPreviousMonth) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:previousMonthButton];
    self.previousMonthButton = previousMonthButton;
    [previousMonthButton release];
    
    // Draw the selected month name centered and at the top of the view
    headerTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerTitleLabel.backgroundColor = [UIColor clearColor];
    headerTitleLabel.font = [UIFont boldSystemFontOfSize:22.f];
    headerTitleLabel.textAlignment = NSTextAlignmentCenter;
    if (useIOS7Look()) {
        headerTitleLabel.textColor = [UIColor darkGrayColor];
    }else{
        headerTitleLabel.textColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kalBundleFile(@"kal_header_text_fill.png")]];
        headerTitleLabel.shadowColor = [UIColor whiteColor];
        headerTitleLabel.shadowOffset = CGSizeMake(0.f, 1.f);
    }
    [self setHeaderTitleText:[logic selectedMonthNameAndYear]];
    [headerView addSubview:headerTitleLabel];
    
    // Create the next month button on the right side of the view
    UIButton *nextMonthButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [nextMonthButton setAccessibilityLabel:NSLocalizedString(@"Next month", nil)];
    [nextMonthButton setImage:[UIImage imageNamed:kalBundleFile(@"kal_right_arrow.png")] forState:UIControlStateNormal];
    nextMonthButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    nextMonthButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [nextMonthButton addTarget:self action:@selector(showFollowingMonth) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:nextMonthButton];
    self.nextMonthButton = nextMonthButton;
    [nextMonthButton release];
    
    // Add column labels for each weekday (adjusting based on the current locale's first weekday)
    NSArray *weekdayNames = [[[[NSDateFormatter alloc] init] autorelease] shortWeekdaySymbols];
    NSArray *fullWeekdayNames = [[[[NSDateFormatter alloc] init] autorelease] standaloneWeekdaySymbols];
    NSCalendar * cal = [NSDate cc_calculationCalendar];
    NSUInteger firstWeekday = [cal firstWeekday];
    NSUInteger i = firstWeekday - 1;
    NSMutableArray * labels = [NSMutableArray arrayWithCapacity:7];
    for (CGFloat xOffset = 0.f; xOffset < headerView.width; xOffset += 46.f, i = (i+1)%7) {
        CGRect weekdayFrame = CGRectMake(xOffset, 30.f, 46.f, kHeaderHeight - 29.f);
        UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:weekdayFrame];
        weekdayLabel.backgroundColor = [UIColor clearColor];
        //weekdayLabel.font = [GCViewConfig boldSystemFontOfSize:10.f];
        weekdayLabel.font = [self.dataSource boldSystemFontOfSize:10.f];
        weekdayLabel.textAlignment = NSTextAlignmentCenter;
        weekdayLabel.textColor = [UIColor colorWithRed:0.3f green:0.3f blue:0.3f alpha:1.f];
        if (!useIOS7Look()) {
            weekdayLabel.shadowColor = [UIColor whiteColor];
            weekdayLabel.shadowOffset = CGSizeMake(0.f, 1.f);
        }
        weekdayLabel.text = [weekdayNames objectAtIndex:i];
        [weekdayLabel setAccessibilityLabel:[fullWeekdayNames objectAtIndex:i]];
        [headerView addSubview:weekdayLabel];
        [labels addObject:weekdayLabel];
        [weekdayLabel release];
    }
    self.weekdayLabels = labels;
    [self setupHeaderViewFrame:headerView.frame];
}

-(void)setupContentViewFrame:(CGRect)frame{
    CGRect cf = self.contentView.frame;
    cf.size.width = frame.size.width;
    self.contentView.frame = cf;
    self.width = frame.size.width;
    CGRect fullWidthAutomaticLayoutFrame = gridView.frame;
    fullWidthAutomaticLayoutFrame.size.width = frame.size.width;
    gridView.frame = fullWidthAutomaticLayoutFrame;
    [gridView setupFrame:fullWidthAutomaticLayoutFrame];
    CGRect tableFrame = tableView.frame;
    tableFrame.size.width = frame.size.width;
    tableView.frame = tableFrame;
    [gridView sizeToFit];

}

- (void)addSubviewsToContentView:(UIView *)contentView
{
    // Both the tile grid and the list of events will automatically lay themselves
    // out to fit the # of weeks in the currently displayed month.
    // So the only part of the frame that we need to specify is the width.
    CGRect fullWidthAutomaticLayoutFrame = CGRectMake(0.f, 0.f, self.width, 0.f);
    
    // The tile grid (the calendar body)
    gridView = [[KalGridView alloc] initWithFrame:fullWidthAutomaticLayoutFrame logic:logic delegate:delegate];
    [gridView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];
    [contentView addSubview:gridView];
    
    // The list of events for the selected day
    tableView = [[UITableView alloc] initWithFrame:fullWidthAutomaticLayoutFrame style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [contentView addSubview:tableView];
    
    // Drop shadow below tile grid and over the list of events for the selected day
    if (!useIOS7Look()) {
        shadowView = [[UIImageView alloc] initWithFrame:fullWidthAutomaticLayoutFrame];
        shadowView.image = [UIImage imageNamed:kalBundleFile(@"kal_grid_shadow.png")];
        shadowView.height = shadowView.image.size.height;
        [contentView addSubview:shadowView];
    }
    
    // Trigger the initial KVO update to finish the contentView layout
    [gridView sizeToFit];
    [self setupContentViewFrame:contentView.frame];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == gridView && [keyPath isEqualToString:@"frame"]) {
        
        /* Animate tableView filling the remaining space after the
         * gridView expanded or contracted to fit the # of weeks
         * for the month that is being displayed.
         *
         * This observer method will be called when gridView's height
         * changes, which we know to occur inside a Core Animation
         * transaction. Hence, when I set the "frame" property on
         * tableView here, I do not need to wrap it in a
         * [UIView beginAnimations:context:].
         */
        CGFloat gridBottom = gridView.top + gridView.height;
        CGRect frame = tableView.frame;
        frame.origin.y = gridBottom;
        frame.size.height = tableView.superview.height - gridBottom;
        tableView.frame = frame;
        if (shadowView) {
            shadowView.top = gridBottom;
        }
        
    } else if ([keyPath isEqualToString:@"selectedMonthNameAndYear"]) {
        [self setHeaderTitleText:[change objectForKey:NSKeyValueChangeNewKey]];
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)setHeaderTitleText:(NSString *)text
{
/*
  [headerTitleLabel setText:text];
  [headerTitleLabel sizeToFit];
  headerTitleLabel.left = floorf(MIN(self.width,322.)/2.f - headerTitleLabel.width/2.f);
 */
}

- (void)jumpToSelectedMonth {
    
    [gridView jumpToSelectedMonth];
    
    //
    NSArray *weekdayNames = [[[[NSDateFormatter alloc] init] autorelease] shortWeekdaySymbols];
    NSUInteger firstWeekday = [[NSDate cc_calculationCalendar] firstWeekday];
    NSUInteger il = firstWeekday - 1;
    for (NSUInteger i=0; i<self.weekdayLabels.count; i++) {
        UILabel * label = self.weekdayLabels[i];
        if (il < weekdayNames.count) {
            label.text = weekdayNames[il];
        }
        il = (il+1)%7;
    }
    
}

- (void)selectDate:(KalDate *)date { [gridView selectDate:date]; }

- (BOOL)isSliding { return gridView.transitioning; }

- (void)markTilesForDates:(NSArray *)dates andSource:(id<KalDataSource>)source { [gridView markTilesForDates:dates andSource:source]; }

- (KalDate *)selectedDate { return gridView.selectedDate; }

- (void)dealloc
{
    [_headerView release];
    [_backgroundView release];
    [_previousMonthButton release];
    [_nextMonthButton release];
    [_weekdayLabels release];
    
    [_contentView release];
    
    [logic removeObserver:self forKeyPath:@"selectedMonthNameAndYear"];
    [logic release];
    
    [headerTitleLabel release];
    [gridView removeObserver:self forKeyPath:@"frame"];
    [gridView release];
    [tableView release];
    [shadowView release];
    [super dealloc];
}

@end
