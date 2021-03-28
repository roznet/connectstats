//  MIT Licence
//
//  Created on 21/09/2012.
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

#import "GCViewConfig.h"
#import "GCAppGlobal.h"
#import "GCViewIcons.h"
#import "GCViewConfigSkin.h"
#import "GCFieldCache.h"
#import "GCStatsCalendarAggregationConfig.h"

static NSArray * _unitSystems = nil;

static GCViewConfigSkin * _skin = nil;

NS_INLINE GCViewConfigSkin * _current_skin(){
    if (_skin == nil) {
        
        NSString * skinName = [[GCAppGlobal profile] configGetString:CONFIG_SKIN_NAME defaultValue:kGCSkinNameOriginal];
        if( skinName ){
            _skin = [GCViewConfigSkin skinForName:skinName];
        }
        // if still nil (name not matching existing skin for ex)
        if( _skin == nil){
            _skin = [GCViewConfigSkin defaultSkin];
        }
        [_skin retain];
    }
    return _skin;
}

@implementation GCViewConfig

+(void)setSkin:(GCViewConfigSkin*)skin{
    [_skin release];
    _skin = skin;
    [_skin retain];
}

+(CGRect)adjustedFrame:(UIViewController*)vc{
    CGRect rv = vc.view.frame;

    return rv;
}
+(NSArray*)mapTypes{
    return @[NSLocalizedString(@"Both", @"maptype"),
             NSLocalizedString(@"Apple", @"maptype"),
             NSLocalizedString(@"Google", @"maptype")];
}

#pragma mark - Colors

+(void)setupGradient:(GCCellGrid *)aG ForThreshold:(double)pct{
    UIColor * color = [GCViewConfig colorForGoalPercent:pct];
    [aG setupBackgroundColors:@[color]];
    //aG.colors = @[ (id)color.CGColor, (id)color.CGColor ];

}

+(void)setupGradient:(GCCellGrid*)aG ForActivity:(id)aAct{
    
    [aG setupBackgroundColors:@[ [GCViewConfig cellBackgroundLighterForActivity:aAct]
                                  ]];
}
+(void)setupGradientForDetails:(GCCellGrid*)aG{
    [aG setupBackgroundColors:@[ [GCViewConfig defaultColor:gcSkinDefaultColorBackground] ]];
}
+(void)setupGradientForCellsEven:(GCCellGrid*)aG{

    [aG setupBackgroundColors: @[ [GCViewConfig defaultColor:gcSkinDefaultColorBackgroundEven] ] ];
}

+(void)setupGradientForCellsOdd:(GCCellGrid*)aG{
    [aG setupBackgroundColors: @[ [GCViewConfig defaultColor:gcSkinDefaultColorBackgroundOdd] ] ];
}

+(UIColor*)defaultColor:(gcSkinDefaultColor)which{
    return [_current_skin() colorForKey:kgcSkinDefaultColors
                              andSubkey:@(which)];
}

+(UIColor*)colorForText:(rzTextColor)which{
    switch (which) {
        case rzColorStylePrimaryText:
            return [_current_skin() colorForKey:kgcSkinDefaultColors
                                      andSubkey:@(gcSkinDefaultColorPrimaryText)];
        case rzColorStyleSecondaryText:
            return [_current_skin() colorForKey:kgcSkinDefaultColors
                                      andSubkey:@(gcSkinDefaultColorSecondaryText)];
        case rzColorStyleTertiaryText:
            return [_current_skin() colorForKey:kgcSkinDefaultColors
                                      andSubkey:@(gcSkinDefaultColorTertiaryText)];
        case rzColorStyleHighlightedText:
            return [_current_skin() colorForKey:kgcSkinDefaultColors
                                      andSubkey:@(gcSkinDefaultColorHighlightedText)];
    }
    return nil;
}

+(UIColor*)colorForRoundedBorder{
    return [_current_skin() colorForKey:kgcSkinDefaultColors andSubkey:@(gcSkinDefaultColorRoundedBorder)];
}

+(UIColor*)backgroundForGroupedTable{
    return [_current_skin() colorForKey:kgcSkinDefaultColors
                              andSubkey:@(gcSkinDefaultColorGroupedTable)];
//    return [UIColor colorWithHexValue:0xF6F3F1 andAlpha:1.];
}
+(void)setupGradient:(GCCellGrid*)aG forSwimStroke:(gcSwimStrokeType)tp{
    [aG setupBackgroundColors:@[[GCViewConfig colorForSwimStrokeType:tp],
                  [GCViewConfig colorSecondForSwimStrokeType:tp]
                  ]];
}

// http://www.w3schools.com/tags/ref_colorpicker.asp
// https://dev.moves-app.com/docs/api_activity_list#activity_table

//
+(UIColor*)textColorForActivity:(id)aAct{
    return [_current_skin() colorForKey:kGCSkinKeyTextColorForActivity andActivity:aAct];
}

// Used By Calendar
+(UIColor*)calendarColorForActivity:(id)aAct{
    return [_current_skin() colorForKey:kGCSkinKeyActivityCellDarkerBackgroundColor andActivity:aAct];
}
+(UIColor*)cellBackgroundDarkerForActivity:(id)aAct{
    if( [self activityCellMultiColor]){
        return [_current_skin() colorForKey:kGCSkinKeyActivityCellDarkerBackgroundColor andActivity:aAct];
    }else{
        return [_current_skin() colorForKey:kgcSkinDefaultColors andSubkey:@(gcSkinDefaultColorBackgroundSecondary)];
    }
}

// Used for lists
+(UIColor*)cellBackgroundLighterForActivity:(id)aAct{
    if( [self activityCellMultiColor]){
        return [_current_skin() colorForKey:kGCSkinKeyActivityCellLighterBackgroundColor andActivity:aAct];
    }else{
        return [_current_skin() colorForKey:kgcSkinDefaultColors andSubkey:@(gcSkinDefaultColorBackgroundSecondary)];
    }
}

+(UIColor*)cellIconColorForActivity:(id)aAct{
    // Expansion to depend on act?
    if( [self activityCellMultiColor]){
        return [_current_skin() colorForKey:kGCSkinKeyActivityCellIconColor];
    }else{
        return [_current_skin() colorForKey:kGCSkinKeyActivityCellDarkerBackgroundColor andActivity:aAct];
    }
}


+(NSArray<UIColor*>*)arrayOfColorsForMultiplots{
    return [_current_skin() colorArrayForKey:kGCSkinKeyListOfColorsForMultiplots];
}

+(UIColor*)colorForSwimStrokeType:(gcSwimStrokeType)strokeType{
    return [_current_skin() colorForKey:kGCSkinKeySwimStrokeColor andSubkey:@(strokeType)] ?: [UIColor colorWithRed:0x61/255. green:0xAF/255. blue:0xF3/255. alpha:0.8];
}

+(UIColor*)colorSecondForSwimStrokeType:(gcSwimStrokeType)strokeType{
    return [_current_skin() colorForKey:kGCSkinKeySwimStrokeColor andSubkey:@(strokeType)] ?: [UIColor colorWithRed:0x61/255. green:0xAF/255. blue:0xF3/255. alpha:0.8];
}

+(UIColor*)backgroundForCategory:(NSString*)category{
    return [_current_skin() colorForKey:kGCSkinKeyCategoryBackground andSubkey:category] ?: [UIColor colorWithRed:0.0 green:0.3 blue:0. alpha:0.3];
}

+(UIColor*)colorForGoalPercent:(double)pct{
    return [_current_skin() colorForKey:kGCSkinKeyGoalPercentBackgroundColor andValue:pct];
}

+(UIColor*)textColorForGoalPercent:(double)pct{
    return [_current_skin() colorForKey:kGCSkinKeyGoalPercentTextColor andValue:pct];
}

+(NSArray*)colorsForField:(GCField*)field{
    return [_current_skin() colorArrayForKey:kGCSkinKeyFieldColors andField:field] ?: @[ [UIColor colorWithRed:0.0 green:0.3 blue:0. alpha:0.3] ];
}
+(UIColor*)fillColorForField:(GCField*)field{
    return [_current_skin() colorForKey:kGCSkinKeyFieldFillColor andField:field] ?: [UIColor colorWithRed:0.0 green:0.3 blue:0. alpha:0.3];
}

+(UIColor*)colorForCalendarElement:(gcSkinCalendarElement)elem{
    return [_current_skin() colorForKey:kGCSkinKeyCalendarColors andSubkey:@(elem)];
}
+(UIColor*)colorForGraphElement:(gcSkinGraphColor)which{
    
    return [_current_skin() colorForKey:kGCSkinKeyGraphColor andSubkey:@(which)];
}
+(void)setupViewController:(UIViewController*)viewController{
    UIColor * backgroundColor = [_current_skin() colorForKey:kgcSkinDefaultColors andSubkey:@(gcSkinDefaultColorBackground)];
    UIColor * foregroundColor = [_current_skin() colorForKey:kgcSkinDefaultColors andSubkey:@(gcSkinDefaultColorHighlightedText)];
    viewController.view.backgroundColor = backgroundColor;
    // General Appearance
    [UINavigationBar appearance].barTintColor = backgroundColor;
    [UINavigationBar appearance].tintColor = foregroundColor;
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            NSForegroundColorAttributeName: [GCViewConfig defaultColor:gcSkinDefaultColorPrimaryText],
                                                            NSFontAttributeName: [GCViewConfig systemFontOfSize:20.0],
                                                            
                                                            }];
    if( viewController.tabBarController ){
        viewController.tabBarController.tabBar.barTintColor = backgroundColor;
        viewController.tabBarController.tabBar.tintColor = foregroundColor;
    }
    if( [viewController isKindOfClass:[UITableViewController class]]){
        UITableViewController * tableViewController = (UITableViewController*)viewController;
        tableViewController.tableView.backgroundColor = backgroundColor;
    }
}

#pragma mark - Font Configuration

+(nullable NSString*)fontName{
    return [_current_skin() stringFor:gcSkinStringSystemFontName];
}

+(nullable NSString*)boldFontName{
    return [_current_skin() stringFor:gcSkinStringSystemFontName];
}


#pragma mark - Bool Configuation

+(BOOL)roundedActivityIcons{
    return [_current_skin() boolFor:gcSkinBoolRoundedActivityIcons];
}

+(BOOL)is2021Style{
    return [_current_skin() boolFor:gcSkinBoolActivityCellBandedFormat];
}
+(BOOL)activityCellMultiColor{
    return [_current_skin() boolFor:gcSkinBoolActivityCellMultiColor];
}

#pragma mark - Fields

+(NSArray*)displayDayMainFieldsOrdered{
    return @[
            @"SumDistance",
            @"SumDuration",
            @"SumStep",
            @"SumFloorClimbed",
            @"SumEnergy",
            @"WeightedMeanHeartRate",
            ];
}


// for the detail page, then related field for each
+(NSArray*)displayMainFieldsOrdered{
    return @[
            @"SumDistance",
            @"SumDuration",
            @"WeightedMeanHeartRate",
            @"WeightedMeanPace",
            @"WeightedMeanSpeed",
            @"WeightedMeanStrokes",
            @"WeightedMeanSwolf",
            @"WeightedMeanPower",
            @"WeightedMeanNormalizedPower",
            @"SumIntensityFactor",
            @"WeightedMeanRunCadence",
            @"WeightedMeanSwimCadence",
            @"WeightedMeanBikeCadence",
            @"WeightedMeanVerticalOscillation",
            @"SumEnergy",
            @"WeightedMeanAirTemperature",
            @"shots"
            ];
}


//NEWTRACKFIELD avoid gcFieldFlag if possible
#define NFLAGS 9
+(gcFieldFlag)nextTrackFieldForGraph:(gcFieldFlag)curr differentFrom:(gcFieldFlag)avoid valid:(gcFieldFlag)valid{
    gcFieldFlag all[NFLAGS] = {
        gcFieldFlagSumDistance,
        gcFieldFlagSumDuration,
        gcFieldFlagWeightedMeanHeartRate,
        gcFieldFlagWeightedMeanSpeed,
        gcFieldFlagCadence,
        gcFieldFlagAltitudeMeters,
        gcFieldFlagPower,
        gcFieldFlagGroundContactTime,
        gcFieldFlagVerticalOscillation
    };
    gcFieldFlag available[NFLAGS];
    size_t n = 0;
    size_t cur_idx = NFLAGS;
    for (size_t i=0; i<NFLAGS; i++) {
        if (all[i]&valid && !(all[i]&avoid)) {
            if (curr==all[i]) {
                cur_idx = n;
            }
            available[n++] = all[i];
        }
    }
    if (curr == gcFieldFlagNone && n > 0) {
        return available[0];
    }else if( n != 0 && cur_idx < n-1){
        return available[cur_idx+1];
    }

    return gcFieldFlagNone;
}

+(NSDictionary<NSString*,NSString*>*)validFieldsDefaultMap{
    return  @{
             @"backhands"            : @"heatmap_backhands_center",
             @"backhands_flat"       : @"heatmap_backhands_center" ,
             @"backhands_lifted"     : @"heatmap_backhands_center" ,
             @"backhands_sliced"     : @"heatmap_backhands_center" ,
             @"first_serves"         : @"heatmap_serves_center",
             @"first_serves_effect"  : @"heatmap_serves_center",
             @"first_serves_flat"    : @"heatmap_serves_center",
             @"forehands"            : @"heatmap_forehands_center",
             @"forehands_flat"       : @"heatmap_forehands_center",
             @"forehands_lifted"     : @"heatmap_forehands_center",
             @"heatmap_all_center"   : @"forehands",
             @"heatmap_backhands_center":@"backhands",
             @"heatmap_forehands_center":@"forehands",
             @"heatmap_serves_center":@"serves",
             @"heatmap_smash_center" :@"serves",
             @"second_serves"        :@"heatmap_serves_center",
             @"second_serves_effect" :@"heatmap_serves_center",
             @"second_serves_flat"   :@"heatmap_serves_center",
             @"serves"               :@"heatmap_serves_center",
             @"serves_effect"        :@"heatmap_serves_center",
             @"serves_flat"          :@"heatmap_serves_center",
             @"shots"                :@"SumDuration",
             @"smash"                :@"heatmap_smash_center"
             };


}

//NEWTRACKFIELD EDIT HERE to ensure displayed in the right order
+(NSArray<GCField*>*)validChoicesForGraphIn:(NSArray<GCField*>*)choices{
    NSDictionary * valid = @{@"WeightedMeanPace":               @1,
                             @"WeightedMeanHeartRate":          @2,
                             @"WeightedMeanRunCadence":         @3,
                             @"SumDistance":                    @20,
                             @"SumDuration":                    @30,
                             @"WeightedMeanBikeCadence":        @10,
                             @"WeightedMeanPower":              @11,
                             @"WeightedMeanSwimCadence":        @12,
                             @"WeightedMeanVerticalOscillation":@13,
                             @"WeightedMeanGroundContactTime":  @14,
                             @"__healthweight":                 @150
                             };
    NSDictionary<NSString*,NSString*> * validmap = [GCViewConfig validFieldsDefaultMap];

    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:valid.count];
    for (GCField * one in choices) {
        if ([one isKindOfClass:[GCField class]]){
            if (valid[one.key] || validmap[one.key]) {
                [rv addObject:one];
            }
        }else {
            RZLog(RZLogError, @"Got invalid input %@", one);
        }
    }
    [rv sortUsingComparator:^(GCField * o1, GCField * o2){
        int i1 = [valid[o1.key] intValue];
        int i2 = [valid[o2.key] intValue];

        NSString * m1 = validmap[o1.key];
        NSString * m2 = validmap[o2.key];

        if (m1) {
            i1 = -1;
        }
        if (m2) {
            i2 = -1;
        }

        if (i1 == i2) {
            return  [o1 compare:o2];
        }
        if (i1 == 0) {
            return NSOrderedDescending;
        }else if(i2 == 0){
            return NSOrderedAscending;
        }
        return (NSComparisonResult)(i1 > i2 ? NSOrderedDescending : NSOrderedAscending);
    }];

    return rv;
}

+(GCField*)nextFieldForGraph:(GCField*)currField fieldOrder:(NSArray<GCField*>*)choices differentFrom:(GCField*)avoid{
    // special override defaults
    NSDictionary<NSString*,NSString*> * defaultMap = [GCViewConfig validFieldsDefaultMap];

    if (currField==nil && defaultMap[avoid.key]) {
        GCField * rv = [GCField fieldForKey:defaultMap[avoid.key] andActivityType:avoid.activityType];
        if ([choices containsObject:rv]) {
            return rv;
        }
    }

    NSUInteger i = 0;
    if (currField) {
        for (i=0; i<choices.count; i++) {
            if ([currField isEqualToField:choices[i]]) {
                break;
            }
        }
        if (i<choices.count-1) {
            i++;
        }else{
            i=0;
        }
    }
    NSUInteger n = 0;
    GCField * nextX = nil;

    GCField * avoid2 = nil;
    if( avoid && [avoid.key isEqualToString:@"WeightedMeanSpeed"] ){
        avoid2 = [GCField fieldForKey:@"WeightedMeanPace" andActivityType:avoid.activityType];
    }else if ( avoid && [avoid.key isEqualToString:@"WeightedMeanPace"]){
        avoid2 = [GCField fieldForKey:@"WeightedMeanSpeed" andActivityType:avoid.activityType];
    }

    while (nextX==nil && n<choices.count) {
        n++;
        GCField * candidate = choices[i];
        if ( (avoid &&[candidate isEqualToField:avoid]) || (avoid2 && [candidate isEqualToField:avoid2]) ) {
            if (i<choices.count-1) {
                i++;
            }else{
                i=0;
            }
        }else{
            nextX = candidate;
        }
    }
    return nextX;
}

#pragma mark - viewChoices and Calendar

+(gcViewChoice)nextViewChoice:(gcViewChoice)current{
    switch (current) {
        case gcViewChoiceFields:
            return gcViewChoiceCalendar;
        case gcViewChoiceCalendar:
            return gcViewChoiceSummary;
        case gcViewChoiceSummary:
            return gcViewChoiceFields;
    }
    return gcViewChoiceFields;
}

+(NSString*)viewChoiceDesc:(gcViewChoice)choice calendarConfig:(GCStatsCalendarAggregationConfig*)calendarConfig{
    switch (choice) {
        case gcViewChoiceFields:
            return NSLocalizedString(@"All", @"viewchoice");
        case gcViewChoiceCalendar:
            return calendarConfig.calendarUnitDescription;
        case gcViewChoiceSummary:
            return NSLocalizedString(@"Summary", @"viewchoice");
    }
    return NSLocalizedString(@"All", @"viewchoice");
}

+(BOOL)trackFieldValidForPlotXAxis:(gcFieldFlag)aTrackField{
    return aTrackField != gcFieldFlagNone;
}

+(BOOL)trackFieldValidForPlotYAxis:(gcFieldFlag)aTrackField{
    return gcFieldFlagSumDistance != aTrackField && gcFieldFlagSumDuration != aTrackField && aTrackField != gcFieldFlagNone;
}


#pragma mark - Other

+(GCCellEntryListViewController*)standardEntryListViewController:(NSArray*)theChoices selected:(NSUInteger)achoice{
    GCCellEntryListViewController * rv = [GCCellEntryListViewController entryListViewController:theChoices selected:achoice];
    [self setupViewController:rv];
    rv.textPrimaryColor = [self defaultColor:gcSkinDefaultColorPrimaryText];
    rv.textSecondaryColor = [self defaultColor:gcSkinDefaultColorSecondaryText];
    rv.selectedTextColor = [self defaultColor:gcSkinDefaultColorHighlightedText];
    rv.cellBackgroundColor = [self defaultColor:gcSkinDefaultColorBackground];
    return rv;
}


+(NSArray*)languageSettingChoices{
    NSMutableArray * rv = [NSMutableArray arrayWithArray:@[
                                                           NSLocalizedString(@"As Downloaded", @"Language Choice"),
                                                           NSLocalizedString(@"System", @"Language Choice"),
                                                           ]];
    [rv addObjectsFromArray:[GCFieldCache availableLanguagesNames]];
    return rv;
}
+(NSArray*)periodDescriptions{
    // Order of gcPeriodType
    return @[ NSLocalizedString(@"Calendar", @"Period Descriptions"),
              NSLocalizedString(@"Rolling",@"Period Descriptions")];
}

+(gcPeriodType)periodFromIndex:(NSUInteger)idx{
    return (gcPeriodType)idx;
}
+(NSString*)periodDescriptionFromType:(gcPeriodType)tp{
    NSArray * desc = [GCViewConfig periodDescriptions];
    if (tp < desc.count) {
        return desc[tp];
    }else{
        return NSLocalizedString(@"Unknown", @"Period Descriptions");
    }
}


+(NSArray*)weekStartDescriptions{
    return @[ @"Sunday", @"Monday" ];
}

+(NSUInteger)weekDayValue:(NSUInteger)idx{
    return idx+1;
}
+(NSUInteger)weekDayIndex:(NSUInteger)idx{
    if (idx > 0) {
        return idx-1;
    }
    return 1;
}


+(NSArray*)unitSystemDescriptions{
    if (_unitSystems == nil) {
        _unitSystems = @[NSLocalizedString(@"Default", @"Unit system name"),
                            NSLocalizedString(@"Metric", @"Unit system name"),
                            NSLocalizedString(@"Imperial", @"Unit system name")];
        [_unitSystems retain];
    }
    return _unitSystems;
}

+(UIImage*)iconForActivityType:(NSString *)activityType{
    NSArray * suffix = nil;
    suffix = @[@"-bw-ios7",@"-bw"];
    UIImage * rv = nil;
    NSString * base = activityType.lowercaseString;
    for (NSString * ext in suffix) {
        NSString * fn = [NSString stringWithFormat:@"%@%@",base,ext];
        rv = [UIImage imageNamed:fn];
        if (rv) {
            break;
        }
    }
    return rv;
}


+(gcGraphChoice)graphChoiceForField:(GCField*)field andUnit:(NSCalendarUnit)aUnit{
    BOOL canSum = [field canSum];

    if (canSum && aUnit == NSCalendarUnitYear) {
        return gcGraphChoiceCumulative;
    }
    return gcGraphChoiceBarGraph;
}

+(NSString*)filterFor:(GCStatsCalendarAggregationConfig*)calendarConfig date:(NSDate*)date andActivityType:(NSString*)activityType{
    NSString * filter = nil;
    NSDateFormatter * dateFormatter = calendarConfig.dateFormatter;
    NSString * typeStr = [activityType isEqualToString:GC_TYPE_ALL] ? @"" : [NSString stringWithFormat:@"%@ ", activityType];

    if (calendarConfig.calendarUnit != NSCalendarUnitWeekOfYear) {
        filter = [NSString stringWithFormat:@"%@%@",typeStr,[dateFormatter stringFromDate:date]];
    }else{
        filter = [NSString stringWithFormat:@"%@weekof %@",typeStr,[dateFormatter stringFromDate:date]];
    }
    return filter;
}

+ (UIImage*)mergeImage:(UIImage*)first withImage:(UIImage*)second
{
    // get size of the first image

    CGImageRef firstImageRef = first.CGImage;
    CGFloat firstWidth = CGImageGetWidth(firstImageRef)/first.scale;
    CGFloat firstHeight = CGImageGetHeight(firstImageRef)/first.scale;

    // get size of the second image
    CGImageRef secondImageRef = second.CGImage;
    CGFloat secondWidth = CGImageGetWidth(secondImageRef)/second.scale;
    CGFloat secondHeight = CGImageGetHeight(secondImageRef)/second.scale;

    // build merged size
    CGSize mergedSize = CGSizeMake(MAX(firstWidth, secondWidth), MAX(firstHeight, secondHeight));

    // capture image context ref
    UIGraphicsBeginImageContextWithOptions(mergedSize,NO,first.scale);
    //UIGraphicsBeginImageContext(mergedSize);

    //Draw images onto the context
    [first drawInRect:CGRectMake( mergedSize.width/2.-firstWidth/2.,  mergedSize.height/2.-firstHeight/2.,  firstWidth,  firstHeight)];
    [second drawInRect:CGRectMake(mergedSize.width/2.-secondWidth/2., mergedSize.height/2.-secondHeight/2., secondWidth, secondHeight)];

    // assign context to new UIImage
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

    // end context
    UIGraphicsEndImageContext();


    return newImage;
}

+(gcGarminDownloadSource)garminDownloadSource{
    if([[GCAppGlobal profile] configGetBool:CONFIG_GARMIN_ENABLE defaultValue:false] && [[GCAppGlobal profile] configGetBool:CONFIG_CONNECTSTATS_ENABLE defaultValue:false] ){
        return gcGarminDownloadSourceBoth;
    }else if( [[GCAppGlobal profile] configGetBool:CONFIG_GARMIN_ENABLE defaultValue:false] ){
        return gcGarminDownloadSourceGarminWeb;
    }else if( [[GCAppGlobal profile] configGetBool:CONFIG_CONNECTSTATS_ENABLE defaultValue:false]){
        return gcGarminDownloadSourceConnectStats;
    }else{
        return gcGarminDownloadSourceEnd;
    }
}
+(void)setGarminDownloadSource:(gcGarminDownloadSource)source{
    BOOL garminOn = false;
    BOOL connectStatsOn = false;
    switch (source) {
        case gcGarminDownloadSourceGarminWeb:
            {
                garminOn = true;
                connectStatsOn = false;
                break;
            }
        case gcGarminDownloadSourceBoth:
            {
                garminOn = true;
                connectStatsOn = true;
                break;
            }
        case gcGarminDownloadSourceConnectStats:
            {
                garminOn = false;
                connectStatsOn = true;
                break;
            }
        case gcGarminDownloadSourceEnd:
            {
                garminOn = false;
                connectStatsOn = false;
                break;
            }
    }
    [[GCAppGlobal profile] configSet:CONFIG_CONNECTSTATS_ENABLE boolVal:connectStatsOn];
    [[GCAppGlobal profile] configSet:CONFIG_GARMIN_ENABLE boolVal:garminOn];
}

+(NSArray<NSString*>*)validChoicesForGarminSource{
    BOOL debugIsEnabled = [[GCAppGlobal configGetString:CONFIG_ENABLE_DEBUG defaultValue:CONFIG_ENABLE_DEBUG_OFF] isEqualToString:CONFIG_ENABLE_DEBUG_ON];
    if (debugIsEnabled) {
        return  @[ NSLocalizedString(@"ConnectStats", @"Download Source"),
                   NSLocalizedString(@"Garmin Website", @"Download Source"),
                   NSLocalizedString(@"All", @"Download Source")
        ];
    }
    return  @[ NSLocalizedString(@"ConnectStats", @"Download Source"),
               NSLocalizedString(@"Garmin Website", @"Download Source"),
               NSLocalizedString(@"All", @"Download Source")
    ];
}

+(NSString*)describeGarminSource:(gcGarminDownloadSource)source{
    NSArray<NSString*>*choices = [self validChoicesForGarminSource];
    if( source < choices.count){
        return choices[source];
    }else{
        return NSLocalizedString( @"None", @"Download Source");
    }
}

+(NSArray*)validChoicesForConnectStatsServiceUse{
    static NSArray * rv = nil;
    if (rv==nil) {
        rv = @[ NSLocalizedString(@"Source", @"ConnectStats Use Method"),
                NSLocalizedString(@"Validate", @"ConnectStats Use Method")];
        [rv retain];
    }
    return rv;
}

+(NSArray*)validChoicesForConnectStatsConfig{
    static NSArray * rv = nil;
    
    /*
     gcWebConnectStatsConfigProductionRozNet,
     gcWebConnectStatsConfigProductionConnectStatsApp,
     gcWebConnectStatsConfigRemoteTesting,
     gcWebConnectStatsConfigLocalProdTesting,
     gcWebConnectStatsConfigLocalDevTesting,
     gcWebConnectStatsConfigEnd
     */
    if( rv==nil){
        
        rv = @[ NSLocalizedString(@"Production roznet", @"ConnectStats Config"),
                NSLocalizedString(@"Production csapp", @"ConnectStats Config"),
                NSLocalizedString(@"Remote Testing", @"ConnectStats Config"),
                NSLocalizedString(@"Local Prod Testing", @"ConnectStats Config"),
                NSLocalizedString(@"Local Dev Testing", @"ConnectStats Config"),
                ];
        [rv retain];
    }
    return rv;
}

@end
