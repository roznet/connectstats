//  MIT Licence
//
//  Created on 30/09/2012.
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

#import "GCCalendarDataSource.h"
#import "GCAppGlobal.h"
#import "GCViewConfig.h"
#import <RZExternal/RZExternal.h>
#import "GCCellGrid+Templates.h"
#import "GCViewIcons.h"
#import "GCHistoryAggregatedActivityStats.h"
#import "GCCalendarDataDateMarkers.h"
#import "GCActivity+UI.h"
#import "GCActivity+Database.h"
#import "GCStatsCalendarAggregationConfig.h"
#import "GCStatsMultiFieldConfig.h"

#define GC_SUMMARY_WEEKLY   0
#define GC_SUMMARY_MONTHLY  1
#define GC_SUMMARY_END      2

#define GC_IS_PERCENT(x) (x == gcCalendarDisplayDistancePercent || x == gcCalendarDisplayDurationPercent)

@interface GCCalendarDataSource ()

@property (nonatomic,retain) NSArray * activities;
@property (nonatomic,retain) NSArray * selectedActivities;

@property (nonatomic,assign) NSUInteger lastidx;

@property (nonatomic,retain) NSMutableDictionary * dateMarkerCache;
@property (nonatomic,retain) GCCalendarDataMarkerInfo * maxInfo;

@property (nonatomic,retain) GCHistoryAggregatedActivityStats * monthlyStats;
@property (nonatomic,retain) GCHistoryAggregatedActivityStats * weeklyStats;

@property (nonatomic,retain) NSDate * currentDate;

@property (nonatomic,retain) GCViewActivityTypeButton * activityTypeButton;
@property (nonatomic,retain) NSString * activityType;
@property (nonatomic,retain) NSArray * listActivityTypes;

@property (nonatomic,assign) BOOL primaryActivityTypesOnly;

//Just for convenience
@property (nonatomic,weak) GCActivitiesOrganizer * organizer;
@property (nonatomic,weak) GCActivity *activityForAction;
@end

@implementation GCCalendarDataSource

-(instancetype)init{
    self = [super init];
    if (self) {
        [[GCAppGlobal organizer] attach:self];
        self.activityType = GC_TYPE_ALL;
        self.activityTypeButton = [GCViewActivityTypeButton activityTypeButtonForDelegate:self];
        self.listActivityTypes = @[ GC_TYPE_ALL];
        self.primaryActivityTypesOnly = false;//[GCAppGlobal configGetBool:CONFIG_MAIN_ACTIVITY_TYPE_ONLY defaultValue:true];
    }
    return self;
}

-(void)dealloc{
    [[GCAppGlobal organizer] detach:self];
    [_listActivityTypes release];
    [_activityTypeButton release];
    [_activityType release];
    [_weeklyStats release];
    [_monthlyStats release];
    [_activities release];
    [_selectedActivities release];
    [_dateMarkerCache release];
    [_currentDate release];
    [super dealloc];
}

#pragma mark - GCViewActivityTypeButton

-(BOOL)useColoredIcons{
    return false;
}

-(BOOL)useFilter{
    return false;
}

-(BOOL)ignoreFilter{
    return true;
}
-(void)setupForCurrentActivityType:(NSString *)aType andFilter:(BOOL)aFilter{
    self.activityType = aType;
    [self.activityTypeButton setupBarButtonItem:nil];

    [[NSNotificationCenter defaultCenter] postNotificationName:KalDataSourceChangedNotification  object:self];
}

#pragma mark - Kal data source

-(void)didSelectDate:(NSDate*)date{
    RZLog(RZLogInfo, @"selected date %@", date);
}

- (void)presentingDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate delegate:(id<KalDataSourceCallbacks>)delegate{
    [delegate loadedDataSource:self];
}

-(NSString*)title{
    switch (_display) {
        case gcCalendarDisplayMarker:
            return NSLocalizedString(@"Activities", @"Calendar tabbar");
            break;
        case gcCalendarDisplayDistance:
        case gcCalendarDisplayDistancePercent:
            // type should not really matter here
            return [GCField fieldForKey:@"SumDistance" andActivityType:GC_TYPE_RUNNING].displayName;
        case gcCalendarDisplayDuration:
        case gcCalendarDisplayDurationPercent:
            return [GCField fieldForKey:@"SumDuration" andActivityType:GC_TYPE_RUNNING].displayName;
        case gcCalendarDisplaySpeed:
            return NSLocalizedString(@"Speed", @"Calendar tabbar");
        default:
            break;
    }
    return NSLocalizedString(@"Calendar", @"Calendar tabbar title");
}

- (NSArray *)markedDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate{
    self.activities = [[GCAppGlobal organizer] activitiesFromDate:fromDate to:toDate];

    NSMutableDictionary * allTypes = [NSMutableDictionary dictionary];
    if ([self.activityType isEqualToString:GC_TYPE_ALL]) {
        for (GCActivity*act in self.activities) {
            allTypes[[act activityTypeKey:self.primaryActivityTypesOnly]] = act.activityType;
        }
    }else{
        NSMutableArray * filtered = [NSMutableArray arrayWithCapacity:self.activities.count];
        for (GCActivity*act in self.activities) {
            allTypes[[act activityTypeKey:self.primaryActivityTypesOnly]]  = act.activityType;
            if ([[act activityTypeKey:self.primaryActivityTypesOnly] isEqualToString:self.activityType]) {
                [filtered addObject:act];
            }
        }
        self.activities = filtered;
    }
    self.listActivityTypes =[ @[ GC_TYPE_ALL] arrayByAddingObjectsFromArray:allTypes.allKeys];

    _lastidx = 0;
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:_activities.count];
    if (_dateMarkerCache == nil) {
        self.dateMarkerCache = [NSMutableDictionary dictionaryWithCapacity:50];
    }
    [_dateMarkerCache removeAllObjects];

    gcIgnoreMode ignoreMode = gcIgnoreModeActivityFocus;
    if ([self.activityType isEqualToString:GC_TYPE_DAY]) {
        ignoreMode = gcIgnoreModeDayFocus;
    }

    for (GCActivity * act in self.activities) {
        if (![act ignoreForStats:ignoreMode]) {
            [rv addObject:act.date];
            NSDate * dateKey = [[KalDate dateFromNSDate:act.date] NSDate];
            GCCalendarDataDateMarkers * markers = _dateMarkerCache[dateKey];
            if (!markers) {
                markers = [[[GCCalendarDataDateMarkers alloc] init] autorelease];
                markers.primaryActivityTypesOnly = self.primaryActivityTypesOnly;
                _dateMarkerCache[dateKey] = markers;
            }

            [markers addActivity:act];
        }
    }
    self.maxInfo = [GCCalendarDataMarkerInfo markerInfo];
    for (NSDate * date in rv) {
        NSDate * dateKey = [[KalDate dateFromNSDate:date] NSDate];

        GCCalendarDataDateMarkers * info = _dateMarkerCache[dateKey];
        [self.maxInfo maxMarkerInfo:info.infoTotals];
    }

    self.weeklyStats = [[[GCHistoryAggregatedActivityStats alloc] init] autorelease];
    self.monthlyStats =[[[GCHistoryAggregatedActivityStats alloc] init] autorelease];

    self.weeklyStats.activityType = GC_TYPE_ALL;
    self.monthlyStats.activityType = GC_TYPE_ALL;
    self.weeklyStats.activities = self.activities;
    self.monthlyStats.activities = self.activities;
    // reference date nil as always for gcPeriodCalendar
    [self.weeklyStats aggregate:NSCalendarUnitWeekOfYear referenceDate:nil ignoreMode:ignoreMode];
    [self.monthlyStats aggregate:NSCalendarUnitMonth referenceDate:nil ignoreMode:ignoreMode];

    return rv;
}

-(UIFont*)systemFontOfSize:(CGFloat)size{
    return [RZViewConfig systemFontOfSize:size];
}
-(UIFont*)boldSystemFontOfSize:(CGFloat)size{
    return [RZViewConfig boldSystemFontOfSize:size];
}
- (UIColor*)backgroundColor{
    //return [GCViewConfig colo]
    //return [GCViewConfig colorForCalendarElement:gcSkinCalendarElementTileColor];
    return [GCViewConfig defaultColor:gcSkinDefaultColorBackground];
}
-(UIColor*)primaryTextColor{
    return [GCViewConfig defaultColor:gcSkinDefaultColorPrimaryText];
}
-(UIColor*)secondaryTextColor{
    return [GCViewConfig defaultColor:gcSkinDefaultColorSecondaryText];
}

- (UIColor*)weekdayTextColor{
    return [GCViewConfig colorForCalendarElement:gcSkinCalendarElementWeekdayTextColor];
}
- (UIColor*)dayCurrentMonthTextColor{
    return [GCViewConfig colorForCalendarElement:gcSkinCalendarElementDayCurrentMonthTextColor];
}
- (UIColor*)dayAdjacentMonthTextColor{
     return [GCViewConfig colorForCalendarElement:gcSkinCalendarElementDayAdjacentMonthTextColor];
}
-(UIColor*)daySelectedTextColor{
    return [GCViewConfig colorForCalendarElement:gcSkinCalendarElementDaySelectedTextColor];
}

- (UIColor*)separatorColor{
    return [GCViewConfig colorForCalendarElement:gcSkinCalendarElementSeparatorColor];
}

-(UIColor*)tileColor{
    return [GCViewConfig colorForCalendarElement:gcSkinCalendarElementTileColor];
}
-(UIColor*)tileSelectedColor{
    //0x1843c7
    return [GCViewConfig colorForCalendarElement:gcSkinCalendarElementTileSelectedColor];
}
-(UIColor*)tileTodayColor{
    //0x7788a2
    return [GCViewConfig colorForCalendarElement:gcSkinCalendarElementTileTodayColor];
}
-(UIColor*)tileTodaySelectedColor{
    //0x3b7dde
    return [GCViewConfig colorForCalendarElement:gcSkinCalendarElementTileTodaySelectedColor];
}

-(NSArray*)leftButtonItems{
    if( [self.activityTypeButton setupBarButtonItem:nil] ){
        return @[ self.activityTypeButton.activityTypeButtonItem ];
    }else{
        return @[];
    }
}
-(NSArray*)rightButtonItems{

    UIImage * img = [GCViewIcons navigationIconFor:gcIconNavTags];

    UIImage * toggle = _tableDisplay == gcCalendarTableDisplaySummary ? [GCViewIcons navigationIconFor:gcIconNavAggregated]
        : [GCViewIcons navigationIconFor:gcIconNavDetails];

    return @[
             [[[UIBarButtonItem alloc] initWithImage:img
                                               style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(toggleDisplay)] autorelease],
             [[[UIBarButtonItem alloc] initWithImage:toggle
                                               style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(toggleTableDisplay)] autorelease],
             ];
}

- (void)loadItemsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate{
    self.currentDate = fromDate;
    NSMutableArray * rv = [ NSMutableArray arrayWithCapacity:10];

    for (GCActivity * act in _activities) {
        BOOL inside  = [act.date compare:toDate] == NSOrderedAscending;
        BOOL toolate = [act.date compare:fromDate] == NSOrderedAscending;
        if (toolate) {
            break;
        }
        if (inside) {
            [rv addObject:act];
        }
    }
    self.selectedActivities = rv;

}
- (void)removeAllItems{

}
#pragma mark - Kal data source Drawing

- (BOOL)drawBackgroundInRect:(CGRect)rect forDate:(NSDate*)adate selected:(BOOL)asel{
    GCCalendarDataDateMarkers * markers = _dateMarkerCache[adate];
    if (markers && GC_IS_PERCENT(_display)) {

        GCActivity * dummy = [[GCActivity alloc] init];
        
        BOOL edgeOnly = false;
        
        __block double maxValue = 0.;

        __block CGFloat angleFrom = M_PI_2 * -1.0;
        __block CGFloat angleTo = angleFrom ;
        CGFloat angleMax  = angleFrom + (M_PI * 2.);

        CGPoint center = CGPointMake(rect.origin.x + rect.size.width/2., rect.origin.y+rect.size.height/2.);
        CGFloat radius = MIN(rect.size.width/2., rect.size.height/2.)-5;
        UIBezierPath * arc = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:angleFrom endAngle:angleMax clockwise:YES];
        arc.lineWidth = 6.;
        [[[UIColor lightGrayColor] colorWithAlphaComponent:0.2] setStroke];
        [arc stroke];
        
        // Highlight the max
        GCCalendarDataMarkerInfo * info = markers.infoTotals;
        BOOL isMax = false;
        if (_display == gcCalendarDayDisplayDistancePercent) {
            isMax = [info.sumDistance compare:self.maxInfo.sumDistance withTolerance:1.e-5] == NSOrderedSame;
        }else{
            isMax = [info.sumDuration compare:self.maxInfo.sumDuration withTolerance:1.e-5] == NSOrderedSame;
        }
        if (isMax) {
            if( edgeOnly ){
                [[[UIColor lightGrayColor] colorWithAlphaComponent:0.4] setFill];
                [arc fill];
            }else{
                [[[UIColor blackColor] colorWithAlphaComponent:0.4] setStroke];
                arc.lineWidth = 6.;
                [arc stroke];

            }
            
        }

        void (^drawArc)(double value) = ^(double value){
            angleTo = angleFrom + (value / maxValue) * ( 2.* M_PI);

            UIBezierPath * onearc = nil;
            if( edgeOnly ){
                onearc = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:angleFrom endAngle:angleTo clockwise:YES];
                onearc.lineCapStyle = kCGLineCapRound;
                onearc.lineWidth = 3.;
            }else{
                onearc = [UIBezierPath bezierPath];
                [onearc moveToPoint:center];
                [onearc addArcWithCenter:center radius:radius startAngle:angleFrom endAngle:angleTo clockwise:YES];
                
                [onearc fill];
            }
            [onearc stroke];
            angleFrom = angleTo;
        };

        maxValue = _display == gcCalendarDisplayDistancePercent ? _maxInfo.sumDistance.value : _maxInfo.sumDuration.value;
        for (NSString * type in markers.orderedActivityTypes) {
            [dummy changeActivityType:[GCActivityType activityTypeForKey:type]];
            [[GCViewConfig cellBackgroundDarkerForActivity:dummy] setStroke];
            [[GCViewConfig cellBackgroundLighterForActivity:dummy] setFill];
            
            GCCalendarDataMarkerInfo * info = [markers inforForType:type];
            drawArc( _display == gcCalendarDisplayDistancePercent ? info.sumDistance.value : info.sumDuration.value);
        }


        [dummy release];
    }
    return true;
}
- (BOOL)drawMarkerInRect:(CGRect)rect forDate:(NSDate*)adate selected:(BOOL)selected{

    GCCalendarDataDateMarkers * markers = _dateMarkerCache[adate];
    if (markers) {
        if (_display == gcCalendarDisplayMarker) {
            GCActivity * dummy = [[GCActivity alloc] init];

            CGContextRef ctx = UIGraphicsGetCurrentContext();
            NSUInteger total = markers.totalCount;

            CGFloat actPointSize = MIN(rect.size.width / total,10.);
            if (actPointSize < 5.) {
                actPointSize = 5.;
                total = floor(rect.size.width/5.);
            }

            NSArray * types = [markers orderedActivityTypes];

            CGRect current = CGRectMake(rect.origin.x, rect.origin.y, actPointSize-2.5, rect.size.height);
            CGFloat markerIdx = 0.;
            CGFloat totalWidth = actPointSize * total;
            CGFloat extraWidth = (rect.size.width-totalWidth);
            CGFloat x_base = rect.origin.x+MAX(extraWidth/2.,0.);
            CGContextSetStrokeColorWithColor(ctx, [UIColor darkGrayColor].CGColor);
            CGContextSetStrokeColorWithColor(ctx, [UIColor clearColor].CGColor);

            for (NSString * type in types) {
                GCCalendarDataMarkerInfo * info = [markers inforForType:type];
                [dummy changeActivityType:[GCActivityType activityTypeForKey:type]];
                for (size_t i = 0; i < info.count; i++) {
                    current.origin.x = x_base + markerIdx * actPointSize;
                    if (markerIdx < total) {
                        CGContextSetFillColorWithColor(ctx, [GCViewConfig cellBackgroundDarkerForActivity:dummy].CGColor);
                        CGContextFillRect(ctx, current);
                        CGContextStrokeRect(ctx, current);
                    }
                    markerIdx += 1.;
                }
            }

            [dummy release];
        }else if( !GC_IS_PERCENT(_display) ){


            GCCalendarDataMarkerInfo * info = markers.infoTotals;
            NSString * d = nil;
            if (_display == gcCalendarDisplayDistance) {

                /*
                GCUnit * km = [GCFields fieldUnit:@"SumDistance" activityType:GC_TYPE_RUNNING];
                if (!km) {
                    km = [ GCUnit unitForKey:@"kilometer"];
                }
                km = [km unitForGlobalSystem];
                double val = [km convertDouble:info.distance fromUnit:[GCUnit unitForKey:STOREUNIT_DISTANCE]];
                 */
                d = [[info.sumDistance convertToGlobalSystem] formatDouble];
            }else if(_display == gcCalendarDisplayDuration){
                GCUnit * min=[GCUnit unitForKey:@"minute"];
                d = [[info.sumDuration convertToUnit:min] formatDoubleNoUnits];
            }else{
                // Steps or speed
                if (info.sumSteps) {
                    d = [info.sumSteps formatDouble];
                }else{
                    double distanceMeters = [info.sumDistance convertToUnitName:@"meter"].value;
                    double durationSeconds =[info.sumDuration convertToUnitName:@"second"].value;
                    double sp = distanceMeters/durationSeconds;//mps
                    GCUnit * mps = [GCUnit unitForKey:@"mps"];
                    GCUnit * disp = [markers displaySpeedUnit];
                    disp = [disp unitForGlobalSystem];
                    double val = [disp convertDouble:sp fromUnit:mps];
                    if (isnan(val)||isinf(val)) {
                        d = nil;
                    }else{
                        d = [disp formatDouble:val];
                    }
                }
            }

            if( d ){
                CGContextRef ctx = UIGraphicsGetCurrentContext();
                CGFloat fontSize = 9.f;
                UIFont *font = [GCViewConfig systemFontOfSize:fontSize];
                UIColor * color = selected ? self.daySelectedTextColor : [markers displayTextColor];
                
                CGContextSaveGState(ctx);
                
                [color setFill];
                [color setStroke];
                NSDictionary * attr = @{NSFontAttributeName:font,NSForegroundColorAttributeName:color};
                CGSize txtSize = [d sizeWithAttributes:attr];
                CGFloat txtX = roundf((rect.size.width - txtSize.width)*0.5f);
                if (txtX<0.) {
                    txtX = 0.;
                }
                [d drawAtPoint:CGPointMake(txtX, rect.origin.y) withAttributes:attr];
                CGContextRestoreGState(ctx);
            }
        }
    }else{
        return false;
    }
    return true;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (_tableDisplay==gcCalendarTableDisplayActivities) {
        return _selectedActivities.count;
    }else{
        return GC_SUMMARY_END;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GCCellGrid * cell = [GCCellGrid gridCell:tableView];
    cell.delegate = self;
    if (_tableDisplay==gcCalendarTableDisplayActivities) {
        if( indexPath.row < _selectedActivities.count ){
            GCActivity * activity = _selectedActivities[indexPath.row];
            [cell setupSummaryFromActivity:activity width:tableView.frame.size.width status:gcViewActivityStatusNone];
        }
    }else{

        NSDate * bucket = nil;

        if (_selectedActivities.count) {
            GCActivity * activity = _selectedActivities[0];
            bucket = activity.date;
        }else{
            bucket = self.currentDate;
        }
        GCHistoryAggregatedDataHolder * holder = nil;
        NSCalendarUnit calUnit = NSCalendarUnitWeekOfYear;

        if (indexPath.row == GC_SUMMARY_MONTHLY) {
            holder = [self.monthlyStats dataForDate:bucket];
            calUnit = NSCalendarUnitMonth;
        }else if (indexPath.row==GC_SUMMARY_WEEKLY){
            holder = [self.weeklyStats dataForDate:bucket];
            calUnit = NSCalendarUnitWeekOfYear;
        }
        if (holder) {
            
            GCStatsMultiFieldConfig * multiFieldConfig = [GCStatsMultiFieldConfig fieldListConfigFrom:nil];
            multiFieldConfig.calendarConfig.calendarUnit = calUnit;
            
            [cell setupFromHistoryAggregatedData:holder
                                           index:indexPath.row
                                multiFieldConfig:multiFieldConfig
                                 andActivityType:holder.activityType?:GC_TYPE_ALL
                                           width:tableView.frame.size.width];
        }else{
            [cell setupForRows:0 andCols:0];
        }
    }
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 58.;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_tableDisplay==gcCalendarTableDisplayActivities) {
        if (indexPath.row < _selectedActivities.count) {
            [GCAppGlobal focusOnActivityId:[_selectedActivities[indexPath.row] activityId]];
        }
    }else{
        NSDate * bucket = nil;

        if (_selectedActivities.count) {
            GCActivity * activity = _selectedActivities[0];
            bucket = activity.date;
        }else{
            bucket = self.currentDate;
        }
        GCStatsCalendarAggregationConfig * calendarConfig = nil;
        
        if (indexPath.row == GC_SUMMARY_MONTHLY) {
            calendarConfig = [GCStatsCalendarAggregationConfig globalConfigFor:NSCalendarUnitMonth];
        }else{
            calendarConfig = [GCStatsCalendarAggregationConfig globalConfigFor:NSCalendarUnitWeekOfYear];
        }
        NSString * filter = [GCViewConfig filterFor:calendarConfig date:bucket andActivityType:GC_TYPE_ALL];
        [GCAppGlobal focusOnListWithFilter:filter];
    }
}

-(void)toggleDisplay{
    _display++;
    if (_display == gcCalendarDisplayEnd) {
        _display = gcCalendarDisplayMarker;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:KalDataSourceChangedNotification  object:self];
}

-(void)toggleTableDisplay{
    _tableDisplay++;
    if (_tableDisplay==gcCalendarTableDisplayEnd) {
        _tableDisplay = gcCalendarTableDisplayActivities;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:KalDataSourceChangedNotification  object:self];
}

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    if ([theParent isKindOfClass:[GCActivitiesOrganizer class]] && theInfo.stringInfo == nil) {

        [[NSNotificationCenter defaultCenter] postNotificationName:KalDataSourceChangedNotification  object:self];
    }
}


#pragma mark - GCCellGridDelegate

-(void)cellGrid:(GCCellGrid*)cell didSelectRightButtonAt:(NSIndexPath*)indexPath{
    self.organizer = [GCAppGlobal organizer];
    self.activityForAction = _selectedActivities[indexPath.row];

    NSMutableArray * indexPaths = [NSMutableArray arrayWithObject:indexPath];
    NSUInteger idx = [self.organizer activityIndexForFilteredIndex:indexPath.row];
    if (self.organizer.hasCompareActivity && idx == self.organizer.selectedCompareActivityIndex) {
        self.organizer.hasCompareActivity = false;
    }else{
        if (self.organizer.selectedCompareActivityIndex < self.organizer.countOfActivities &&
            self.organizer.selectedCompareActivityIndex != idx) {
            NSUInteger toclear = [self.organizer filteredIndexForActivityIndex:self.organizer.selectedCompareActivityIndex];
            if (toclear!=NSNotFound) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:toclear inSection:indexPath.section]];
            }
        }
        self.organizer.selectedCompareActivityIndex = idx;
        self.organizer.hasCompareActivity = true;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KalDataSourceChangedNotification  object:self];
    
}

-(void)cellGrid:(GCCellGrid*)cell didSelectLeftButtonAt:(NSIndexPath*)indexPath{
    
    self.activityForAction = _selectedActivities[indexPath.row];
    
    if( self.activityForAction.skipAlways) {
        self.activityForAction.skipAlways = false;
    }else{
        self.activityForAction.skipAlways = true;
    }
    if( self.activityForAction.db ){
        [self.activityForAction saveToDb:self.activityForAction.db];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:KalDataSourceChangedNotification  object:self];
}

@end
