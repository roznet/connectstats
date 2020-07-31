/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import "KalViewController.h"
#import "KalLogic.h"
#import "KalDataSource.h"
#import "KalDate.h"
#import "KalPrivate.h"
#import "RZNavigationTitleView.h"

#define PROFILER 0
#if PROFILER
#include <mach/mach_time.h>
#include <time.h>
#include <math.h>
void mach_absolute_difference(uint64_t end, uint64_t start, struct timespec *tp)
{
    uint64_t difference = end - start;
    static mach_timebase_info_data_t info = {0,0};

    if (info.denom == 0)
        mach_timebase_info(&info);
    
    uint64_t elapsednano = difference * (info.numer / info.denom);
    tp->tv_sec = elapsednano * 1e-9;
    tp->tv_nsec = elapsednano - (tp->tv_sec * 1e9);
}
#endif

NSString *const KalDataSourceChangedNotification = @"KalDataSourceChangedNotification";

@interface KalViewController ()
@property (nonatomic, retain, readwrite) NSDate *initialDate;
@property (nonatomic, retain, readwrite) NSDate *selectedDate;
@property (nonatomic,retain) RZNavigationTitleView * titleView;
- (KalView*)calendarView;
@end

@implementation KalViewController

@synthesize dataSource, delegate, initialDate, selectedDate;

- (id)initWithSelectedDate:(NSDate *)date
{
  if ((self = [super init])) {
    logic = [[KalLogic alloc] initForDate:date];
    self.initialDate = date;
    self.selectedDate = date;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(significantTimeChangeOccurred) name:UIApplicationSignificantTimeChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:KalDataSourceChangedNotification object:nil];
  }
  return self;
}

- (id)init
{
  return [self initWithSelectedDate:[NSDate date]];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationSignificantTimeChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KalDataSourceChangedNotification object:nil];
    [initialDate release];
    [selectedDate release];
    [logic release];
    [_tableView release];
    [_titleView release];
    [super dealloc];
}

#pragma mark -

- (KalView*)calendarView {
    return (KalView*)self.view;
}

-(KalView*)kalView{
    return (KalView*)self.view;
}

- (void)setDataSource:(id<KalDataSource>)aDataSource
{
    if (dataSource != aDataSource) {
        dataSource = aDataSource;
        self.tableView.dataSource = dataSource;
    }
}

- (void)setDelegate:(id<UITableViewDelegate>)aDelegate
{
    if (delegate != aDelegate) {
        delegate = aDelegate;
        self.tableView.delegate = delegate;
    }
}

- (void)clearTable
{
    [dataSource removeAllItems];
    [self.tableView reloadData];
}

- (void)reloadData
{
    [dataSource presentingDatesFrom:logic.fromDate to:logic.toDate delegate:self];
    
    if (self.isViewLoaded && self.view.window ) {
        self.navigationItem.rightBarButtonItems = [dataSource rightButtonItems];
    }
    [self setupTitleView];
    
}

- (void)significantTimeChangeOccurred
{
    [[self calendarView] jumpToSelectedMonth];
    [self reloadData];
}

// -----------------------------------------
#pragma mark - KalViewDelegate protocol

- (void)didSelectDate:(KalDate *)date userAction:(BOOL)userAction
{
    NSDate * selected = [date NSDate];
    self.selectedDate = selected;
    if( userAction && [self.dataSource respondsToSelector:@selector(didSelectDate:)] ){
        [self.dataSource didSelectDate:selected];
    }
    NSDate *from = [[date NSDate] cc_dateByMovingToBeginningOfDay];
    NSDate *to = [[date NSDate] cc_dateByMovingToEndOfDay];
    [self clearTable];
    [dataSource loadItemsFromDate:from toDate:to];
    [self.tableView reloadData];
    [self.tableView flashScrollIndicators];
}

-(void)setupTitleView{
    NSString * text = [logic selectedMonthNameAndYear];

    NSAttributedString * attr = [[NSAttributedString alloc] initWithString:text
                                                                attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.],
                                                                             NSForegroundColorAttributeName:[self.dataSource primaryTextColor]
                                                                             }];
    self.titleView.title = attr  ;
    NSAttributedString * attr2 = [[NSAttributedString alloc] initWithString:[dataSource title]
                                                                 attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.],
                                                                              NSForegroundColorAttributeName:[self.dataSource secondaryTextColor]}];
    self.titleView.subtitle = attr2;
    
    [attr release];
    [attr2 release];
    [self.titleView setNeedsDisplay];
}

- (void)showPreviousMonth
{
    if( self.navigationController ){
        [self setupTitleView];
    }
    [self clearTable];
    [logic retreatToPreviousMonth];
    [[self calendarView] slideDown];
    [self reloadData];
}

- (void)showFollowingMonth
{
    if( self.navigationController ){
        [self setupTitleView];
    }
    [self clearTable];
    [logic advanceToFollowingMonth];
    [[self calendarView] slideUp];
    [self reloadData];
}

// -----------------------------------------
#pragma mark - KalDataSourceCallbacks protocol

- (void)loadedDataSource:(id<KalDataSource>)theDataSource;
{
    NSArray *markedDates = [theDataSource markedDatesFrom:logic.fromDate to:logic.toDate];
    NSMutableArray *dates = [[markedDates mutableCopy] autorelease];
    for (int i=0; i<[dates count]; i++)
        [dates replaceObjectAtIndex:i withObject:[KalDate dateFromNSDate:[dates objectAtIndex:i]]];
    
    [[self calendarView] markTilesForDates:dates andSource:dataSource];
    [self didSelectDate:self.calendarView.selectedDate userAction:false];
    [self setupNavigationItem];
}

-(void)setupNavigationItem{
    //self.navigationItem.title = [logic selectedMonthNameAndYear];
    [self setupTitleView];
    //self.navigationItem.title = [dataSource title];
}

// ---------------------------------------

- (void)showAndSelectDate:(NSDate *)date
{
    if ([[self calendarView] isSliding])
        return;
    
    [logic moveToMonthForDate:date];
    
#if PROFILER
    uint64_t start, end;
    struct timespec tp;
    start = mach_absolute_time();
#endif
    
    [[self calendarView] jumpToSelectedMonth];
    
#if PROFILER
    end = mach_absolute_time();
    mach_absolute_difference(end, start, &tp);
    printf("[[self calendarView] jumpToSelectedMonth]: %.1f ms\n", tp.tv_nsec / 1e6);
#endif
    
    [[self calendarView] selectDate:[KalDate dateFromNSDate:date]];
    [self reloadData];
    [self setupNavigationItem];
    
}

- (NSDate *)selectedDate
{
    return [self.calendarView.selectedDate NSDate];
}


#pragma mark - UIViewController

- (void)didReceiveMemoryWarning
{
    self.initialDate = self.selectedDate; // must be done before calling super
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    UIEdgeInsets insets = [[UIApplication sharedApplication] keyWindow].safeAreaInsets;
    
    CGRect bar = self.navigationController.navigationBar.frame;
    CGRect frame = self.view.frame;

    CGFloat adjustTop = bar.size.height + insets.top;
    
    frame.origin.y+= adjustTop;
    frame.size.height -= adjustTop;
    
    self.view.frame = frame;

    self.titleView.backgroundColor = [UIColor clearColor]; // should match navigationbar color
    self.tableView.backgroundColor = self.dataSource.backgroundColor;
    [self.kalView setupFrame:frame];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.titleTextAttributes =@{NSFontAttributeName:[UIFont systemFontOfSize:16.]};
    
    self.navigationItem.rightBarButtonItems = [dataSource rightButtonItems];
    self.navigationItem.leftBarButtonItems = [dataSource leftButtonItems];
    self.navigationItem.leftItemsSupplementBackButton = YES;
    self.titleView = [[[RZNavigationTitleView alloc] initWithFrame:CGRectMake(0., 0., 120., 44)] autorelease];
    self.titleView.backgroundColor = [UIColor clearColor]; // should match navigationbar color
    self.navigationItem.titleView = self.titleView;
    
    KalView *kalView = [[[KalView alloc] initWithFrame:self.view.frame dataSource:self.dataSource delegate:self logic:logic] autorelease];
    self.view = kalView;
    self.tableView = kalView.tableView;
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self.dataSource;
    self.tableView.backgroundColor = self.dataSource.backgroundColor;
    [kalView selectDate:[KalDate dateFromNSDate:self.initialDate]];
    [self reloadData];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAll;
    }else{
        return UIInterfaceOrientationMaskPortrait;
    }
}
    
-(void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    
    if( @available( iOS 13.0, * )){
        if( self.traitCollection.userInterfaceStyle != previousTraitCollection.userInterfaceStyle ){
            [self.tableView reloadData];
        }
    }
}


@end
