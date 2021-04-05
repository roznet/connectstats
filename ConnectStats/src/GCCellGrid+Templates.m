//  MIT Licence
//
//  Created on 09/11/2012.
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

#import "GCCellGrid+Templates.h"
#import "GCFormattedField.h"
#import "GCViewConfig.h"
#import "GCHistoryAggregatedActivityStats.h"
#import "GCHistoryFieldSummaryStats.h"
#import "GCFormattedFieldText.h"
#import "GCHealthMeasure.h"
#import "GCTrackPoint+Swim.h"
#import "GCActivity+UI.h"
#import "GCViewIcons.h"
#import "GCHistoryFieldDataSerie.h"
#import "GCAppGlobal.h"
#import "GCActivity+Fields.h"
#import "GCStatsMultiFieldConfig.h"
#import "GCStatsCalendarAggregationConfig.h"
#import "GCHistoryFieldDataHolder.h"

const CGFloat kGC_WIDE_SIZE = 420.0f;

@implementation GCCellGrid (Templates)

-(void)setupForText:(NSString*)aText{
    [self setupForRows:1 andCols:1];
    [self labelForRow:0 andCol:0].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16] withString: aText];
}

#pragma mark - Activity Details Cells

-(void)setupForWeather:(GCActivity*)activity width:(CGFloat)width{
    if (activity==nil || ![activity hasWeather]) {
        return;
    }

    GCWeather * weather = activity.weather;
    if ([weather weatherCompleteForDisplay]) {
        [self setupForRows:2 andCols:2];
        NSString* temp = [NSString stringWithFormat:NSLocalizedString(@"Temperature %@", @"Weather Cell"),
                          [weather weatherDisplayField:GC_WEATHER_TEMPERATURE]];

            [self labelForRow:0 andCol:0].attributedText = [GCViewConfig attributedString:temp attribute:@selector(attribute16)];
            [self labelForRow:0 andCol:1].attributedText = [GCViewConfig attributedString:[weather weatherDisplayField:GC_WEATHER_WIND] attribute:@selector(attribute16)];
            [self labelForRow:1 andCol:0].attributedText = [GCViewConfig attributedString:weather.weatherTypeDesc?:@"" attribute:@selector(attribute14Gray)];
        UIImage * icon = [weather weatherIcon];     
        if (icon) {
            [self setIconImage:icon];
            self.iconPosition = gcIconPositionLeft;
        }else{
            [self setIconImage:nil];
            [self labelForRow:0 andCol:1].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                                     withString:[weather weatherDisplayField:GC_WEATHER_ICON]];
        }
        [GCViewConfig setupGradientForDetails:self];
    }
}

-(void)setupForAttributedStrings:(NSArray<NSAttributedString*>*)attrStrings graphIcon:(BOOL)graphIcon width:(CGFloat)width{
    NSUInteger n = attrStrings.count;
    if (width > 600.) {
        [self setupForRows:2 andCols:4];
        self.cellLayout = gcCellLayoutEven;
        [self labelForRow:0 andCol:0].attributedText = attrStrings[0];
        [self configForRow:0 andCol:0].horizontalOverflow = YES;

        CGFloat requiredWidth = 0.;
        for (int i=1; i<MIN(n,4); i++) {
            requiredWidth += attrStrings[i].size.width;
        }
        if (n > 1) {
            [self labelForRow:1 andCol:0].attributedText = attrStrings[1] ;
            [self configForRow:1 andCol:0].horizontalAlign = gcHorizontalAlignLeft;
            [self configForRow:1 andCol:0].horizontalOverflow = YES;
        }
        if (n > 2) {
            [self labelForRow:1 andCol:2].attributedText = attrStrings[2] ;
            [self configForRow:1 andCol:2].horizontalAlign = gcHorizontalAlignLeft;
            [self configForRow:1 andCol:2].horizontalOverflow = YES;

        }
        if (n > 3) {
            [self labelForRow:0 andCol:2].attributedText = attrStrings[3] ;
            [self configForRow:0 andCol:2].horizontalAlign = gcHorizontalAlignLeft;
            [self configForRow:0 andCol:2].horizontalOverflow = YES;
        }
    }else{
        [self setupForRows:2 andCols:2];
        [self labelForRow:0 andCol:0].attributedText = attrStrings[0];

        [self labelForRow:1 andCol:0].attributedText = n>1 ? attrStrings[1] : nil;
        [self labelForRow:1 andCol:1].attributedText = n>2 ? attrStrings[2] : nil;
        [self labelForRow:0 andCol:1].attributedText = n>3 ? attrStrings[3] : nil;

        // overflow if no extra columns
        [self configForRow:0 andCol:0].horizontalOverflow = n<4 ? YES : NO;
        [self configForRow:1 andCol:0].horizontalOverflow = n>2 ? NO : YES;
    }


    [GCViewConfig setupGradientForDetails:self];
    
    if(graphIcon){
        [self setIconImage:[GCViewIcons cellIconFor:gcIconCellLineChart]];
    }else{
        [self setIconImage:nil];
        UIImage * icon = [GCViewIcons cellIconFor:gcIconCellLineChart];
        CGSize size = icon.size;
        UIView * view = [[[UIView alloc] initWithFrame:CGRectMake(0., 0., size.width, size.height)] autorelease];
        view.backgroundColor = [UIColor clearColor];
        [self setIconView:view  withSize:size];

    }
}


/**
 Input can be Field or NSArray
 */
-(void)setupForField:(NSString*)input andActivity:(GCActivity *)activity width:(CGFloat)width{
    NSMutableArray<GCFormattedField*> * fields = [NSMutableArray array];
    GCFormattedField * mainF = nil;
    GCField * field = [GCField fieldForKey:input andActivityType:activity.activityType];
    if (field) {
        NSArray * related = [field relatedFields];
        
        GCNumberWithUnit * mainN = [activity numberWithUnitForField:field];
        mainF = [GCFormattedField formattedField:field forNumber:mainN forSize:16.];
        
        for (NSUInteger i=0; i<related.count; i++) {
            GCField * addField = related[i];
            GCNumberWithUnit * addNumber = [activity numberWithUnitForField:addField];
            if (addNumber) {
                GCFormattedField* theOne = [GCFormattedField formattedField:addField forNumber:addNumber forSize:14.];
                theOne.valueColor = [GCViewConfig defaultColor:gcSkinDefaultColorSecondaryText];
                theOne.labelColor = [GCViewConfig defaultColor:gcSkinDefaultColorSecondaryText];
                if ([addNumber sameUnit:mainN]) {
                    theOne.noUnits = true;
                }
                [fields addObject:theOne];
            }
        }
    }else{
        RZLog(RZLogError, @"Invalid input %@", NSStringFromClass([input class]));
        return;
    }
    NSUInteger n = fields.count;
    if (width > 600.) {
        [self setupForRows:2 andCols:4];
        self.cellLayout = gcCellLayoutEven;
        [self labelForRow:0 andCol:0].attributedText = [mainF attributedString];

        for (int i=0; i<MIN(n,4); i++) {
            [self labelForRow:1 andCol:i+1].attributedText = [fields[i] attributedString];
            [self configForRow:1 andCol:i+1].horizontalAlign = gcHorizontalAlignLeft;
        }
    }else{
        [self setupForRows:2 andCols:2];
        [self labelForRow:0 andCol:0].attributedText = [mainF attributedString];

        [self labelForRow:1 andCol:0].attributedText = n>0 ? [fields[0] attributedString] : nil;
        [self labelForRow:1 andCol:1].attributedText = n>1 ? [fields[1] attributedString] : nil;
        [self labelForRow:0 andCol:1].attributedText = n>2 ? [fields[2] attributedString] : nil;

        // overflow if no extra columns
        [self configForRow:0 andCol:0].horizontalOverflow = n>2 ? NO : YES;
        [self configForRow:1 andCol:0].horizontalOverflow = n>1 ? NO : YES;
    }


    [GCViewConfig setupGradientForDetails:self];

    // sumdistance is special as it gets remapped to altitude for graphs
    if ([activity hasTrackForField:field] && ([field validForGraph] || field.fieldFlag==gcFieldFlagSumDistance)) {
        [self setIconImage:[GCViewIcons cellIconFor:gcIconCellLineChart]];
    }else{
        [self setIconImage:nil];
    }
}

-(void)setupDetailHeader:(GCActivity*)activity{
    if (activity==nil) {
        return;
    }
    [GCViewConfig setupGradient:self ForActivity:activity];
    [self setupForRows:3 andCols:1];

    NSDictionary * locAttributes = @{NSFontAttributeName: [GCViewConfig systemFontOfSize:12.],
                                    NSForegroundColorAttributeName: [GCViewConfig defaultColor:gcSkinDefaultColorHighlightedText]};
    NSDictionary * dateAttributes = @{NSFontAttributeName: [GCViewConfig boldSystemFontOfSize:16.],
                                     NSForegroundColorAttributeName: [GCViewConfig defaultColor:gcSkinDefaultColorPrimaryText]};
    NSDictionary * nameAttributes = @{NSFontAttributeName: [GCViewConfig systemFontOfSize:14.],
                                          NSForegroundColorAttributeName: [GCViewConfig defaultColor:gcSkinDefaultColorPrimaryText]};

    NSString * dateStr =[NSDateFormatter localizedStringFromDate:activity.date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];

    NSAttributedString * name = [[[NSAttributedString alloc] initWithString:activity.activityName?:@"" attributes:nameAttributes] autorelease];
    NSAttributedString * date = [[[NSAttributedString alloc] initWithString:dateStr?:@"" attributes:dateAttributes] autorelease];
    NSAttributedString * loc  = [[[NSAttributedString alloc] initWithString:activity.location?:@"" attributes:locAttributes] autorelease];

    [self labelForRow:0 andCol:0].attributedText = name;
    [self labelForRow:1 andCol:0].attributedText = date;
    [self labelForRow:2 andCol:0].attributedText = loc;

    [self configForRow:0 andCol:0].horizontalAlign = gcHorizontalAlignLeft;
    [self configForRow:1 andCol:0].horizontalAlign = gcHorizontalAlignLeft;
    [self configForRow:2 andCol:0].horizontalAlign = gcHorizontalAlignLeft;

    [self setIconImage:[activity icon]];

}

-(void)setupForHealthMeasureSummary:(GCHealthMeasure*)measure{
    [self setupForRows:2 andCols:2];
    if (measure) {
        GCNumberWithUnit * weight = [measure.value convertToGlobalSystem];
        NSDate * date = measure.date;

        NSMutableAttributedString * t = [[[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Weight ",@"Health")
                                                                                attributes:[GCViewConfig attribute16]] autorelease];
        if (weight) {
            [t appendAttributedString:[[[NSAttributedString alloc] initWithString:[weight formatDouble] attributes:[GCViewConfig attributeBold16]] autorelease]];
        }
        [self labelForRow:0 andCol:0].attributedText = t;
        [self labelForRow:1 andCol:0].attributedText = [[[NSAttributedString alloc] initWithString:[date dateShortFormat] attributes:[GCViewConfig attribute14Gray]] autorelease];

        [GCViewConfig setupGradientForDetails:self];
    }


}
-(void)setupForExtraSummary:(GCActivity*)activity width:(CGFloat)width{
    [self setupForRows:2 andCols:2];

    NSMutableArray * keys = [NSMutableArray arrayWithCapacity:2];

    if ([activity metaValueForField:GC_META_ACTIVITYTYPE]) {
        [keys addObject:GC_META_ACTIVITYTYPE];
    }

    NSUInteger maxSize = width>kGC_WIDE_SIZE ? 50 : 30;

    NSString * eventType = [activity metaValueForField:GC_META_EVENTTYPE].display;
    if (eventType && ![eventType isEqualToString:@"Uncategorized"]) {
        [keys addObject:GC_META_EVENTTYPE];
    }

    NSString * activityDescription = [activity metaValueForField:GC_META_DESCRIPTION].display;
    if (keys.count < 3 && activityDescription && ![activityDescription isEqualToString:@""]) {
        [keys addObject:GC_META_DESCRIPTION];
    }

    if (keys.count < 3) {
        NSString * device = [activity metaValueForField:GC_META_DEVICE].display;
        if (device) {
            [keys addObject:GC_META_DEVICE];
        }
    }
    if (keys.count < 3) {
        NSString * service = [activity metaValueForField:GC_META_SERVICE].display;
        if (service) {
            [keys addObject:GC_META_SERVICE];
        }
    }

    GCFormattedFieldText * ft = nil;
    NSString * key = nil;
    NSString * val = nil;
    if (keys.count) {
        key = keys[0];
        val = [activity metaValueForField:key].display;
        ft = [GCFormattedFieldText formattedFieldText:nil value:val forSize:14.];
        [self labelForRow:0 andCol:0].attributedText = [ft attributedString];
    }
    [self configForRow:0 andCol:0].horizontalOverflow = YES;
    if (keys.count > 1) {
        key = keys[1];
        val = [activity metaValueForField:key].display;
        ft = [GCFormattedFieldText formattedFieldText:nil value:val forSize:14.];
        [self labelForRow:1 andCol:0].attributedText = [ft attributedString];
    }
    if (keys.count > 2) {
        key = keys[2];
        val = [activity metaValueForField:key].display;
        if (val.length>maxSize) {
            val = [NSString stringWithFormat:@"%@...",  [val substringToIndex:maxSize-2]];
        }
        ft = [GCFormattedFieldText formattedFieldText:[GCFields metaFieldDisplayName:key] value:val forSize:14.];
        if ([key isEqualToString:GC_META_DESCRIPTION]) {
            ft.label = nil;
        }
        [self labelForRow:1 andCol:1].attributedText = [ft attributedString];
        [self configForRow:1 andCol:0].horizontalOverflow = NO;
        [self configForRow:1 andCol:1].horizontalOverflow = NO;
    }else{
        [self configForRow:1 andCol:0].horizontalOverflow = YES;
    }


    [GCViewConfig setupGradientForDetails:self];

}

#pragma mark - Activity List Summary

-(void)setupSummaryFromDayActivity:(GCActivity *)activity width:(CGFloat)width status:(gcViewActivityStatus)status{
    GCFormattedField * distance = [GCFormattedField formattedField:nil forNumber:[activity numberWithUnitForFieldFlag:gcFieldFlagSumDistance] forSize:16.];

    GCNumberWithUnit * nu_steps = [activity numberWithUnitForFieldKey:@"SumStep"];
    GCNumberWithUnit * nu_goal  = [activity numberWithUnitForFieldKey:@"GoalSumStep"];
    GCFormattedField * steps = [GCFormattedField formattedField:nil forNumber:nu_steps forSize:14.];

    NSDictionary * dateAttributes = @{ NSFontAttributeName:[GCViewConfig boldSystemFontOfSize:16.],
                                       NSForegroundColorAttributeName:[GCViewConfig defaultColor:gcSkinDefaultColorPrimaryText]
                                       };

    NSDictionary * dateSmallAttributes = @{ NSFontAttributeName:[GCViewConfig systemFontOfSize:12.],
                                            NSForegroundColorAttributeName:[GCViewConfig defaultColor:gcSkinDefaultColorPrimaryText]
                                            };

    GCNumberWithUnit * maxHR = [activity numberWithUnitForFieldKey:@"MaxHeartRate"];
    GCNumberWithUnit * minHR = [activity numberWithUnitForFieldKey:@"MinHeartRate"];


    NSDate * date = activity.date;
    NSAttributedString * day    = [[[NSAttributedString alloc] initWithString:[date dayFormat]       attributes:dateAttributes] autorelease];
    NSAttributedString * dat    = [[[NSAttributedString alloc] initWithString:[date dateShortFormat] attributes:dateSmallAttributes] autorelease];

    double pct = 1.;
    if (nu_goal) {
        pct = nu_steps.value/nu_goal.value;
    }else{
        pct = nu_steps.value/10000.;
    }
    [GCViewConfig setupGradient:self ForThreshold:pct];

    self.enableButtons = true;
    self.leftButtonText = NSLocalizedString(@"More", @"Grid Cell Button");
    self.rightButtonText = status == gcViewActivityStatusCompare ? NSLocalizedString(@"Clear", @"Grid Cell Button") :
    NSLocalizedString(@"Mark", @"Grid Cell Button");


    [self setupForRows:3 andCols:3];
    self.marginx = 2.;
    self.marginy = 2.;
    [self labelForRow:0 andCol:1].attributedText = [distance attributedString];
    [self labelForRow:0 andCol:0].attributedText = day;
    [self labelForRow:0 andCol:2].attributedText = nil;
    [self labelForRow:1 andCol:1].attributedText = [steps attributedString];
    [self labelForRow:1 andCol:0].attributedText = dat;
    //[self labelForRow:2 andCol:0].attributedText = [duration attributedString];

    [self configForRow:1 andCol:2].verticalAlign = gcVerticalAlignBottom;
    [self configForRow:2 andCol:2].verticalAlign = gcVerticalAlignTop;
    [self configForRow:2 andCol:0].horizontalOverflow = YES;
    if (minHR) {
        [self labelForRow:2 andCol:2].attributedText = [GCViewConfig attributedString:minHR.description attribute:@selector(attribute14Gray)];
    }
    if (maxHR) {
        [self labelForRow:1 andCol:2].attributedText = [GCViewConfig attributedString:maxHR.description attribute:@selector(attribute14Gray)];
    }

    if (status==gcViewActivityStatusCompare) {
        [self setIconImage:[GCViewConfig mergeImage:[activity icon] withImage:[GCViewIcons cellIconFor:gcIconCellCheckbox]]];
    }else{
        [self setIconImage:[activity icon]];
    }
}


-(void)setupSummaryFromFitnessActivity:(GCActivity*)activity
                                  rows:(NSUInteger)nrows
                                 width:(CGFloat)width
                                status:(gcViewActivityStatus)status{

    //BOOL addImages = false;
    BOOL skipAlways = activity.skipAlways;
    //BOOL wide = width > 600.;
    
    NSMutableArray<GCField*>*fields = [NSMutableArray array];
    
    
    [fields addObjectsFromArray:@[
        [GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:activity.activityType],
        [GCField fieldForFlag:gcFieldFlagSumDuration andActivityType:activity.activityType],
        [GCField fieldForFlag:gcFieldFlagWeightedMeanHeartRate andActivityType:activity.activityType],
        [GCField fieldForFlag:gcFieldFlagWeightedMeanSpeed andActivityType:activity.activityType],
        [GCField fieldForFlag:gcFieldFlagPower andActivityType:activity.activityType],
    ]];
        
    //activity.activityTypeDetail.isPacePreferred)
    

    if ([activity.activityTypeDetail isElevationLossPreferred]) {
        [fields addObject:[GCField fieldForKey:@"LossElevation" andActivityType:activity.activityType]];
    }else{
        [fields addObject:[GCField fieldForFlag:gcFieldFlagAltitudeMeters andActivityType:activity.activityType]];
    }
    
    NSDate * date = activity.date;
    NSString * dispname = [activity displayName];
    
    NSUInteger maxLengh = 32;
    if( nrows < 4 ){
        maxLengh = 24;
    }
    
    if (dispname.length>maxLengh) {
        dispname = [NSString stringWithFormat:@"%@...", [dispname substringToIndex:maxLengh]];
    }
    if (date == nil) {
        dispname = NSLocalizedString(@"Date Error",@"Services");
        date =[NSDate date];
        RZLog(RZLogInfo, @"Invalid Date for %@", activity);
    }

    NSArray<NSAttributedString*>*dateAttributed = @[
        [NSAttributedString attributedString:[GCViewConfig attribute16] withString:[date dayFormat]],
        [NSAttributedString attributedString:[GCViewConfig attribute14] withString:[date dateShortFormat]],
        [NSAttributedString attributedString:[GCViewConfig attribute12] withString:[date timeShortFormat]],
        [NSAttributedString attributedString:[GCViewConfig attribute12Highlighted] withString:dispname?:NSLocalizedString(@"Error",@"Fitness")],
    ];

    if( skipAlways ){
        [self setupBackgroundColors:@[ [GCViewConfig defaultColor:gcSkinDefaultColorTertiaryText] ]];
        dateAttributed = @[
            [NSAttributedString attributedString:[[GCViewConfig attribute16] viewConfigAttributeDisabled] withString:[date dayFormat]],
            [NSAttributedString attributedString:[[GCViewConfig attribute14] viewConfigAttributeDisabled] withString:[date dateShortFormat]],
            [NSAttributedString attributedString:[[GCViewConfig attribute14] viewConfigAttributeDisabled] withString:[date timeShortFormat]],
            [NSAttributedString attributedString:[[GCViewConfig attribute16Highlighted] viewConfigAttributeDisabled]  withString:dispname?:NSLocalizedString(@"Error",@"Fitness")],
        ];
    }else{
        [GCViewConfig setupGradient:self ForActivity:activity];
    }
    
    self.enableButtons = true;
    self.leftButtonText = skipAlways ? NSLocalizedString(@"Use", @"Grid Cell Button") : NSLocalizedString(@"Ignore", @"Grid Cell Button");
    self.rightButtonText = status == gcViewActivityStatusCompare ? NSLocalizedString(@"Clear", @"Grid Cell Button") :
        NSLocalizedString(@"Mark", @"Grid Cell Button");

    
    
    if (width < 600.) {
        
        [self setupForRows:nrows andCols:3];
        self.marginx = 2.;
        self.marginy = 2.;
        for(NSUInteger row = 0; row < nrows; row++){
            [self labelForRow:row andCol:0].attributedText = dateAttributed[row];
        }
        // overflow the bottom line with the name
        [self configForRow:nrows-1 andCol:0].horizontalOverflow = YES;
        if( nrows < dateAttributed.count){
            // if too big put the date on the right as before
            [self labelForRow:nrows-1 andCol:0].attributedText = dateAttributed[nrows];
            [self labelForRow:0 andCol:2].attributedText = dateAttributed[nrows-1];
            NSUInteger row = 0;
            for(NSUInteger fieldIdx = 0; fieldIdx < 4; fieldIdx++){
                GCNumberWithUnit * nu = [activity numberWithUnitForField:fields[fieldIdx]];
                NSUInteger col = fieldIdx < 2 ? 1 : 2;
                NSDictionary * attr = (col == 1 || row < 1) ? [RZViewConfig attribute16] : [RZViewConfig attribute12Gray];
                if( skipAlways ){
                    attr = [attr viewConfigAttributeDisabled];
                }
                if( nu ){
                    NSAttributedString * at = [NSAttributedString attributedString:attr withString:nu.formatDouble];
                    [self labelForRow:row andCol:col].attributedText = at;
                }else{
                    [self labelForRow:row andCol:col].attributedText = nil;
                }
                row++;
                if( row >= nrows){
                    row = 1;
                }
            }
        }else{
            NSUInteger row = 0;
            for(NSUInteger fieldIdx = 0; fieldIdx < fields.count; fieldIdx++){
                GCNumberWithUnit * nu = [activity numberWithUnitForField:fields[fieldIdx]];
                NSDictionary * attr = (row == 0) ? [RZViewConfig attribute16] : [RZViewConfig attribute14Gray];
                NSUInteger col = 1 + (fieldIdx % 2);
                if( skipAlways ){
                    attr = [attr viewConfigAttributeDisabled];
                }
                NSString * formattedDouble = nu.formatDouble;
                NSAttributedString * at = formattedDouble ? [NSAttributedString attributedString:attr withString:formattedDouble] : nil;
                [self labelForRow:row andCol:col].attributedText = at;
                if( col == 2){
                    row ++;
                }
                if( row >= nrows){
                    row = 0;
                }
            }
        }
    }else{
    }
    if (status==gcViewActivityStatusCompare) {
        [self setIconImage:[GCViewConfig mergeImage:[activity icon] withImage:[GCViewIcons cellIconFor:gcIconCellCheckbox]]];
    }else{
        if ( [GCAppGlobal configGetBool:CONFIG_SHOW_DOWNLOAD_ICON defaultValue:true] && activity.trackPointsRequireDownload) {
            [self setIconImage:[GCViewConfig mergeImage:[activity icon] withImage:[GCViewIcons cellIconFor:gcIconCellCloudDownload]]];
        }else{
            [self setIconImage:[activity icon]];
        }
    }

}

-(void)setupSummaryFromActivity:(GCActivity*)activity rows:(NSUInteger)rows width:(CGFloat)width status:(gcViewActivityStatus)status{
    if ([activity.activityType isEqualToString:GC_TYPE_DAY]) {
        [self setupSummaryFromDayActivity:activity width:width status:status];
    }else{
        [self setupSummaryFromFitnessActivity:activity rows:rows width:width status:status];
    }
}

#pragma mark - Aggregated Stats

-(void)setupFromHistoryAggregatedData:(GCHistoryAggregatedDataHolder*)data
                                index:(NSUInteger)idx
                     multiFieldConfig:(GCStatsMultiFieldConfig*)multiFieldConfig
                      andActivityType:(GCActivityType*)activityType
                                width:(CGFloat)width{
    BOOL wide =false;
    if (width > kGC_WIDE_SIZE) {
        wide = true;
        [self setupForRows:2 andCols:5];
    }else{
        [self setupForRows:3 andCols:3];
    }
    if (idx %2==0) {
        [GCViewConfig setupGradientForCellsEven:self];
    }else{
        [GCViewConfig setupGradientForCellsOdd:self];
    }
    if (![data isKindOfClass:[GCHistoryAggregatedDataHolder class]]) {
        RZLog(RZLogError, @"Invalid data holder %@", NSStringFromClass([data class]));
        return;
    }

    NSDictionary * dateAttributes = [GCViewConfig attributeBold14];

    // if rolling use none that will just print the date
    NSString * dateFmt = [multiFieldConfig.calendarConfig formattedDate:data.date];
    if (!dateFmt) {
        RZLog(RZLogError, @"Got no date: idx=%d data=%@ date=%@",(int)idx,data,[data date]);
        dateFmt = NSLocalizedString(@"ERROR", @"Date");
    }
    NSAttributedString * dateStr = [[[NSAttributedString alloc] initWithString:dateFmt attributes:dateAttributes] autorelease];
    
    NSArray<GCField*> * fields = activityType.summaryFields;
    
    NSUInteger row = 0;
    NSUInteger col = 1;
    NSUInteger fieldidx = 0;
    NSUInteger colCount = wide ? 5 : 3;
    NSUInteger mainCount = 2;
    
    [self labelForRow:0 andCol:0].attributedText = dateStr;
    for (GCField * field in fields) {
        if( [data hasField:field] ){
            GCNumberWithUnit * nu = [data preferredNumberWithUnit:field];
            if( nu.isValidValue && nu.value != 0.){
                NSDictionary * attr = fieldidx < mainCount ? [GCViewConfig attributeBold14] : [GCViewConfig attribute14Gray];
                NSAttributedString * at = [NSAttributedString attributedString:attr withString:nu.formatDouble];
                
                [self labelForRow:row andCol:col].attributedText = at;
            }else{
                [self labelForRow:row andCol:col].attributedText = nil;
            }
            [self configForRow:row andCol:col].verticalAlign = gcVerticalAlignCenter;
            [self configForRow:row andCol:col].horizontalAlign = gcHorizontalAlignRight;
        }else{
            [self labelForRow:row andCol:col].attributedText = nil;
        }
        col ++;
        if( col >= colCount){
            row ++;
            col = 1;
        }

        fieldidx ++;
    }
    
    [self configForRow:0 andCol:0].verticalAlign = gcVerticalAlignCenter;
}

#pragma mark - Field Statistics

-(void)setupForFieldDataHolder:(GCHistoryFieldDataHolder*)data histStats:(gcHistoryStats)which andActivityType:(NSString *)aType{

    //gcHistoryStats which = gcHistoryStatsAll;

    GCNumberWithUnit * mainN = nil;
    if ([data.field canSum]) {
        mainN =[data sumWithUnit:which];
    }else{
        if ([data.field isWeightedAverage]) {
            mainN = [data weightedAverageWithUnit:which];
        }else{
            mainN =[data averageWithUnit:which];
        }
    }


    NSString * fieldName = [data.field displayName];
    if (fieldName==nil) {
        fieldName = data.field.key;
    }
    
    if (mainN==nil || mainN.unit==nil) {
        if (mainN != nil && mainN.unit==nil) {
            RZLog(RZLogError, @"%@ had no unit", data.field);
        }

        if( [data weightedAverageWithUnit:gcHistoryStatsAll] ){
            [self setupForRows:2 andCols:2];
            [self labelForRow:0 andCol:0].attributedText = [GCViewConfig attributedString:fieldName attribute:@selector(attribute16Gray)];
            [self configForRow:0 andCol:0].horizontalOverflow = YES;
            [self labelForRow:0 andCol:1].attributedText = [GCViewConfig attributedString:NSLocalizedString(@"No Data", @"Field Summary") attribute:@selector(attribute14Gray)];
            [GCViewConfig setupGradientForDetails:self];

        }
        return;
    }

    
    GCFormattedField * count = [GCFormattedField formattedFieldDisplay:@"Count" forNumber:[data countWithUnit:which] forSize:14.];
    GCFormattedField * extra = nil;
    if ([data.field canSum]) {
        extra = [GCFormattedField formattedFieldDisplay:@"Average" forNumber:[data averageWithUnit:which] forSize:14.];
    }else if ([data.field isMax]){
        extra = [GCFormattedField formattedFieldDisplay:@"Max" forNumber:[data maxWithUnit:which] forSize:14.];
    }
    [count setColor:[GCViewConfig defaultColor:gcSkinDefaultColorSecondaryText]];
    [extra setColor:[GCViewConfig defaultColor:gcSkinDefaultColorSecondaryText]];

    count.noDisplayField = true;
    extra.noDisplayField = true;

    [self setupForRows:2 andCols:2];
    [self labelForRow:0 andCol:0].attributedText = [GCViewConfig attributedString:fieldName attribute:@selector(attributeBold16)];
    [self configForRow:0 andCol:0].horizontalOverflow = YES;
    [self labelForRow:0 andCol:1].attributedText = [GCViewConfig attributedString:[mainN formatDouble] attribute:@selector(attributeBold16)];
    [self labelForRow:1 andCol:0].attributedText = [count attributedString];
    if (extra) {
        [self labelForRow:1 andCol:1].attributedText = [extra attributedString];
    }
    [GCViewConfig setupGradientForDetails:self];
}

-(void)setUpForSummarizedHistory:(NSDictionary*)summarizedHistory
                         atIndex:(NSUInteger)idx
                        forField:(GCField*)field
                      calendarConfig:(GCStatsCalendarAggregationConfig*)calendarConfig{
    double avg = [summarizedHistory[STATS_AVG] dataPointAtIndex:idx].y_data;
    double sum = [summarizedHistory[STATS_SUM] dataPointAtIndex:idx].y_data;
    double max = [summarizedHistory[STATS_MAX] dataPointAtIndex:idx].y_data;
    double min = [summarizedHistory[STATS_MIN] dataPointAtIndex:idx].y_data;
    double cnt = [summarizedHistory[STATS_CNT] dataPointAtIndex:idx].y_data;
    double std = [summarizedHistory[STATS_STD] dataPointAtIndex:idx].y_data;

    GCUnit * unit = [field unit];
    NSDate * date = [[summarizedHistory[STATS_AVG] dataPointAtIndex:idx] date];

    GCFormattedField * main = nil;
    GCFormattedField * extra = nil;

    GCNumberWithUnit * cntN = [GCNumberWithUnit numberWithUnitName:@"dimensionless" andValue:cnt];

    GCNumberWithUnit * avgN = [GCNumberWithUnit numberWithUnit:unit andValue:avg];
    GCNumberWithUnit * sumN = [GCNumberWithUnit numberWithUnit:unit andValue:sum];
    GCNumberWithUnit * maxN = [GCNumberWithUnit numberWithUnit:unit andValue:max];
    GCNumberWithUnit * minN = [GCNumberWithUnit numberWithUnit:unit andValue:min];
    GCNumberWithUnit * stdN = [GCNumberWithUnit numberWithUnit:unit andValue:std];


    if ([field canSum]) {
        main = [GCFormattedField formattedField:nil     forNumber:sumN forSize: 16.];
        extra =[GCFormattedField formattedFieldDisplay:@"Avg" forNumber:avgN forSize:14.];
        extra.noDisplayField = true;
    }else{
        main =[GCFormattedField formattedFieldForNumber:avgN forSize:16.];
    }

    GCFormattedField * cntF = [GCFormattedField formattedFieldDisplay:@"Count" forNumber:cntN forSize:12.];
    GCFormattedField * maxF = [GCFormattedField formattedFieldDisplay:@"Max"  forNumber:maxN forSize:12.];
    GCFormattedField * minF = [GCFormattedField formattedFieldDisplay:@"Min" forNumber:minN forSize:12.];
    GCFormattedField * stdF = [GCFormattedField formattedFieldDisplay:@"Std"  forNumber:stdN forSize:12.];

    cntF.noDisplayField = true;
    maxF.noDisplayField = true;
    minF.noDisplayField = true;
    stdF.noDisplayField = true;

    [cntF setColor:[GCViewConfig defaultColor:gcSkinDefaultColorSecondaryText]];
    [maxF setColor:[GCViewConfig defaultColor:gcSkinDefaultColorSecondaryText]];
    [minF setColor:[GCViewConfig defaultColor:gcSkinDefaultColorSecondaryText]];
    [stdF setColor:[GCViewConfig defaultColor:gcSkinDefaultColorSecondaryText]];

    NSDictionary * dateAttr = @{NSFontAttributeName: [GCViewConfig boldSystemFontOfSize:14.],
                                     NSForegroundColorAttributeName: [GCViewConfig defaultColor:gcSkinDefaultColorPrimaryText]};

    [self setupForRows:3 andCols:3];
    [self labelForRow:0 andCol:0].attributedText = [[[NSAttributedString alloc] initWithString:[date calendarUnitFormat:calendarConfig.calendarUnit] attributes:dateAttr] autorelease];

    [self labelForRow:0 andCol:2].attributedText = [main attributedString];
    [self labelForRow:1 andCol:2].attributedText = [extra attributedString];

    if (cnt > 2.) {
        [self labelForRow:2 andCol:0].attributedText = [stdF attributedString];
    }
    [self labelForRow:1 andCol:1].attributedText = [maxF attributedString];
    [self labelForRow:2 andCol:1].attributedText = [minF attributedString];
    [self labelForRow:2 andCol:2].attributedText = [cntF attributedString];
    if (idx %2==0) {
        [GCViewConfig setupGradientForCellsEven:self];
    }else{
        [GCViewConfig setupGradientForCellsOdd:self];
    }
}

-(void)setupStatsHeaders:(GCHistoryFieldDataSerie *)activityStats{
    [self setupForRows:2 andCols:1];
    
    GCFormattedFieldText * title = [GCFormattedFieldText formattedFieldText:activityStats.config.activityTypeDetail.displayName
                                                                      value:activityStats.fieldDisplayName
                                                                    forSize:16.];

    NSString * countText= [NSString stringWithFormat:NSLocalizedString(@"%lu items",@"Stats Cell"),(unsigned long)[activityStats count]];
    GCFormattedFieldText * sub = [GCFormattedFieldText formattedFieldText:@"Count"
                                                                    value:countText forSize:14.];

    sub.valueColor = [GCViewConfig defaultColor:gcSkinDefaultColorSecondaryText];
    sub.labelColor = [GCViewConfig defaultColor:gcSkinDefaultColorSecondaryText];

    [self labelForRow:0 andCol:0].attributedText = [title attributedString];
    [self labelForRow:1 andCol:0].attributedText = [sub attributedString];
    GCActivity * dummy = [[GCActivity alloc] init];

    [dummy changeActivityType:activityStats.config.activityTypeDetail];
    [GCViewConfig setupGradient:self ForActivity:dummy];
    [dummy release];
}

-(void)setupStatsAverageStdDev:(GCStatsDataSerie*)average for:(GCHistoryFieldDataSerie*)activityStats{
    [self setupForRows:2 andCols:1];

    NSString * avgText = [NSString stringWithFormat:NSLocalizedString(@"Average of %@", @"Stats Cell"), activityStats.fieldDisplayName];
    GCFormattedFieldText * avg = [GCFormattedFieldText formattedFieldText:avgText
                                                                    value:[activityStats formattedValue:[average dataPointAtIndex:0].y_data]
                                                                  forSize:16.];
    GCFormattedFieldText * std = [GCFormattedFieldText formattedFieldText:NSLocalizedString(@"Std Dev", @"Stats Cell")
                                                                    value:[activityStats formattedValue:[average dataPointAtIndex:1].y_data]
                                                                  forSize:14.];
    [self labelForRow:0 andCol:0].attributedText = [avg attributedString];
    [self labelForRow:1 andCol:0].attributedText = [std attributedString];
    [GCViewConfig setupGradientForDetails:self];
}

-(void)setupStatsQuartile:(NSUInteger)row in:(GCStatsDataSerie*)quartiles for:(GCHistoryFieldDataSerie*)activityStats{
    if ([quartiles count] < 4) {
        [self setupForRows:1 andCols:1];
        [self labelForRow:0 andCol:0].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                                 withString:NSLocalizedString(@"Not enough observations", @"Stats Cell")];
    }
    else{
        [self setupForRows:2 andCols:2];
        NSString * label = nil;
        NSString * leftLabel = nil;
        NSString * rightLabel = nil;
        NSUInteger top, left, right;
        if (row == 0) {
            label = [NSString stringWithFormat:NSLocalizedString(@"Max %@",@"Stats Cell"), activityStats.fieldDisplayName];
            leftLabel = NSLocalizedString(@"Top 25%", @"Stats Cell");
            rightLabel = NSLocalizedString(@"Top 50%", @"Stats Cell");
            top = 4;
            left = 3;
            right = 2;
        }else{
            label = [NSString stringWithFormat:NSLocalizedString(@"Min %@",@"Stats Cell"), activityStats.fieldDisplayName];
            leftLabel = NSLocalizedString(@"Bottom 25%", @"Stats Cell");
            rightLabel = NSLocalizedString(@"Bottom 50%", @"Stats Cell");
            top = 0;
            left = 1;
            right = 2;
        }
        GCFormattedFieldText * topF = [GCFormattedFieldText formattedFieldText:label
                                                                         value:[activityStats formattedValue:[quartiles dataPointAtIndex:top].y_data]
                                                                       forSize:16.];
        GCFormattedFieldText * leftF = [GCFormattedFieldText formattedFieldText:leftLabel
                                                                          value:[activityStats formattedValue:[quartiles dataPointAtIndex:left].y_data]
                                                                        forSize:14.];
        GCFormattedFieldText * rightF = [GCFormattedFieldText formattedFieldText:rightLabel
                                                                           value:[activityStats formattedValue:[quartiles dataPointAtIndex:right].y_data]
                                                                         forSize:14.];
        [self labelForRow:0 andCol:0].attributedText = [topF attributedString];
        [self labelForRow:1 andCol:0].attributedText = [leftF attributedString];
        [self labelForRow:1 andCol:1].attributedText = [rightF attributedString];
        [self configForRow:1 andCol:1].horizontalAlign = gcHorizontalAlignLeft;
    }

}


#pragma mark - Laps Data

-(void)setupForLap:(NSUInteger)idx andActivity:(GCActivity*)activity width:(CGFloat)width{
    if (activity.garminSwimAlgorithm) {
        return [self setupForSwimLap:idx andActivity:activity width:width];
    }
    BOOL wide =false;
    if (width > kGC_WIDE_SIZE) {
        wide = true;
        [self setupForRows:2 andCols:5];
    }else{
        [self setupForRows:2 andCols:3];
    }
        GCLap * lap = idx < activity.lapCount ? [activity lapNumber:idx]  :nil;
    GCNumberWithUnit * dist = [[lap numberWithUnitForField:[GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:activity.activityType] inActivity:activity]
                               convertToUnit:activity.distanceDisplayUnit];
    GCNumberWithUnit * speed= [[lap numberWithUnitForField:[GCField fieldForFlag:gcFieldFlagWeightedMeanSpeed andActivityType:activity.activityType] inActivity:activity]
                               convertToUnit:activity.speedDisplayUnit];
    GCNumberWithUnit * dur  = [lap numberWithUnitForField:[GCField fieldForFlag:gcFieldFlagSumDuration andActivityType:activity.activityType] inActivity:activity];
    GCNumberWithUnit * bpm  = nil;
    GCNumberWithUnit * cad  = nil;
    GCNumberWithUnit * pow  = nil;

    if ([activity hasTrackField:gcFieldFlagWeightedMeanHeartRate ]) {
        bpm = [lap numberWithUnitForField:[GCField fieldForFlag:gcFieldFlagWeightedMeanHeartRate andActivityType:activity.activityType] inActivity:activity];
    }
    if ([activity hasTrackField:gcFieldFlagCadence]) {
        cad =   [lap numberWithUnitForField:[GCField fieldForFlag:gcFieldFlagCadence andActivityType:activity.activityType] inActivity:activity];
    }
    if ([activity hasTrackField:gcFieldFlagPower]) {
        pow = [lap numberWithUnitForField:[GCField fieldForFlag:gcFieldFlagPower andActivityType:activity.activityType] inActivity:activity];
    }

    GCFormattedField * distF = [GCFormattedField formattedFieldForNumber:dist forSize:16.];
    GCFormattedField * speedF= [GCFormattedField formattedFieldForNumber:speed forSize:14.];
    GCFormattedField * durF= [GCFormattedField formattedFieldForNumber:dur forSize:16.];
    GCFormattedField * bpmF= bpm ? [GCFormattedField formattedFieldForNumber:bpm forSize:14.] : nil;
    GCFormattedField * cadF= cad ? [GCFormattedField formattedFieldForNumber:cad forSize:14.] : nil;
    GCFormattedField * powF= pow ? [GCFormattedField formattedFieldForNumber:pow forSize:14.] : nil;

    BOOL isSki = [activity isSkiActivity];

    if ([activity.activityType isEqualToString:GC_TYPE_SWIMMING]) {
        if (dist.value == 0.) {
            distF = [GCFormattedField formattedFieldDisplay:@"Rest" forNumber:nil forSize:14.];
            distF.noDisplayField = true;
            speedF = nil;
        }
    }else if (isSki){
        GCNumberWithUnit * elev = nil;
        if ([activity.activityTypeDetail isElevationLossPreferred]) {
            elev = [lap numberWithUnitForField:[GCField fieldForKey:@"LossElevation" andActivityType:activity.activityType] inActivity:activity];
            if (elev == nil) {
                elev = [lap numberWithUnitForField:[GCField fieldForKey:@"LossCorrectedElevation" andActivityType:activity.activityType] inActivity:activity];
            }
            if (elev == nil) {
                elev = [lap numberWithUnitForField:[GCField fieldForKey:@"LossUncorrectedElevation" andActivityType:activity.activityType]  inActivity:activity];
            }
        }else {
            elev = [lap numberWithUnitForField:[GCField fieldForKey:@"GainElevation" andActivityType:activity.activityType] inActivity:activity];
            if (elev == nil) {
                elev = [lap numberWithUnitForField:[GCField fieldForKey:@"GainCorrectedElevation" andActivityType:activity.activityType] inActivity:activity];
            }
            if (elev == nil) {
                elev = [lap numberWithUnitForField:[GCField fieldForKey:@"GainUncorrectedElevation" andActivityType:activity.activityType] inActivity:activity];
            }
        }
        if (elev) {
            bpmF = [GCFormattedField formattedFieldForNumber:elev forSize:14.];
        }
    }
    if (lap.label) {
        [self labelForRow:0 andCol:0].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                                 withString:lap.label];
    }else{
        if (isSki) {
            [self labelForRow:0 andCol:0].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                           withFormat:NSLocalizedString(@"Run %d",@"Lap Cell"),idx+1];

        }else{
            [self labelForRow:0 andCol:0].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                                     withFormat:NSLocalizedString(@"Lap %d",@"Lap Cell"),idx+1];
        }
    }
    if (wide) {
        [self labelForRow:1 andCol:0].attributedText = powF ? [powF attributedString] : [cadF attributedString];;
        [self labelForRow:1 andCol:1].attributedText = [distF attributedString];
        [self labelForRow:1 andCol:2].attributedText = [durF attributedString];
        [self labelForRow:1 andCol:3].attributedText = [speedF attributedString];
        [self labelForRow:1 andCol:4].attributedText = [bpmF attributedString];
    }else{
        [self labelForRow:0 andCol:1].attributedText = [distF attributedString];
        [self labelForRow:0 andCol:2].attributedText = [durF attributedString];
        [self labelForRow:1 andCol:0].attributedText = powF ? [powF attributedString] : [cadF attributedString];
        [self labelForRow:1 andCol:1].attributedText = [bpmF attributedString];
        [self labelForRow:1 andCol:2].attributedText = [speedF attributedString];
    }
    if (idx %2==0) {
        [GCViewConfig setupGradientForCellsEven:self];
    }else{
        [GCViewConfig setupGradientForCellsOdd:self];
    }

}

-(void)setupForLap:(GCLap*)aLap key:(id)def andActivity:(GCActivity*)activity width:(CGFloat)width{
    BOOL wide =false;
    if (width > kGC_WIDE_SIZE) {
        wide = true;
    }
    if ([def isKindOfClass:[NSString class]]) {
        NSString * key = def;
        if (wide) {
            [self setupForRows:1 andCols:4];
        }else{
            [self setupForRows:1 andCols:2];
        }
        NSString * aType = activity.activityType;
        GCField * field = [GCField fieldForKey:[GCFields fieldForLapField:key andActivityType:aType] andActivityType:aType];
        NSString * display = field.displayName;
        GCUnit * displayUnit = [activity displayUnitForField:field];

        GCNumberWithUnit * number = [[aLap numberWithUnitForField:field inActivity:activity] convertToUnit:displayUnit];;
        GCFormattedField * numberF = [GCFormattedField formattedFieldForNumber:number forSize:16.];

        [self labelForRow:0 andCol:0].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                                 withString:display ?: field.key];
        [self labelForRow:0 andCol:1].attributedText = [numberF attributedString];
        if (wide) {
            [self configForRow:0 andCol:1].horizontalAlign = gcHorizontalAlignLeft;
        }

    }else if([def isKindOfClass:[NSArray class]]){
        NSArray * group = def;
        NSString * key = group[0];
        id second = group[1];
        if (wide) {
            // 4 cols so number is not as far right form the label
            [self setupForRows:1 andCols:4];
        }else{
            [self setupForRows:2 andCols:2];
        }
        NSString * aType = activity.activityType;
        GCNumberWithUnit * number1 = nil;
        GCField * field1 = nil;
        NSString * display1 = nil;

        if ([second isKindOfClass:[NSString class]]) {
            field1 = [GCField fieldForKey:second andActivityType:aType];
            number1 = [aLap numberWithUnitForField:field1 inActivity:activity];
            display1 = field1.displayName;
        }else{
            gcFieldFlag fieldFlag = [group[1] intValue];
            field1 = [GCField fieldForFlag:fieldFlag andActivityType:aType];
            number1 = [aLap numberWithUnitForField:[GCField fieldForFlag:field1.fieldFlag andActivityType:aType] inActivity:activity];
            if (fieldFlag == gcFieldFlagSumDistance) {
                number1 = [number1 convertToUnit:activity.distanceDisplayUnit];
            }else if(fieldFlag == gcFieldFlagWeightedMeanSpeed){
                number1 = [number1 convertToUnit:activity.speedDisplayUnit];
            }
            display1 = field1.displayName;
        }
        NSString * field2   = [GCFields fieldForLapField:key andActivityType:aType];
        NSString * display2 = [GCField fieldForKey:field2 andActivityType:aType].displayName;

        GCFormattedField * numberF1 = [GCFormattedField formattedFieldForNumber:number1 forSize:16.];

        GCNumberWithUnit * number2 = [aLap numberWithUnitForField:[GCField fieldForKey:key andActivityType:aType] inActivity:activity];

        GCFormattedField * number2F = wide ?
            [GCFormattedField formattedFieldForNumber:number2 forSize:16.]:
            [GCFormattedField formattedFieldForNumber:number2 forSize:14.];
        if (!wide) {
            [number2F setColor:[GCViewConfig defaultColor:gcSkinDefaultColorSecondaryText]];
        }

        NSAttributedString * under = [[[NSAttributedString alloc] initWithString:display2 ?: field2
                                                                      attributes:wide?[GCViewConfig attribute16]:[GCViewConfig attribute14Gray]] autorelease];

        [self labelForRow:0 andCol:0].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16] withString:display1 ?: field1.key];
        [self labelForRow:0 andCol:1].attributedText = [numberF1 attributedString];
        if (wide) {
            [self configForRow:0 andCol:1].horizontalAlign = gcHorizontalAlignLeft;
            [self labelForRow:0 andCol:2].attributedText = under;
            [self configForRow:0 andCol:2].horizontalAlign = gcHorizontalAlignLeft;
            [self labelForRow:0 andCol:3].attributedText = [number2F attributedString];
            [self configForRow:0 andCol:3].horizontalAlign = gcHorizontalAlignLeft;
        }else{
            [self labelForRow:1 andCol:0].attributedText = under;
            [self labelForRow:1 andCol:1].attributedText = [number2F attributedString];
        }

    }

    [GCViewConfig setupGradientForDetails:self];

}

#pragma mark - Swim

-(void)setupForSwimLap:(NSUInteger)idx andActivity:(GCActivity*)activity width:(CGFloat)width{
    GCLap * one = activity.laps[idx];
    [self setupForSwimTrackpoint:one index:idx andActivity:activity width:width];
}

-(void)setupForSwimTrackpoint:(GCTrackPoint*)lap index:(NSUInteger)idx andActivity:(GCActivity*)activity width:(CGFloat)width{
    BOOL wide =false;
    if (width > kGC_WIDE_SIZE) {
        wide = true;
        [self setupForRows:2 andCols:5];
    }else{
        [self setupForRows:2 andCols:3];
    }
    GCNumberWithUnit * dist = [[lap numberWithUnitForField:[GCField fieldForFlag:gcFieldFlagSumDistance
                                           andActivityType:activity.activityType] inActivity:activity]
                               convertToUnit:activity.distanceDisplayUnit];
    GCNumberWithUnit * speed= [[lap numberWithUnitForField:[GCField fieldForFlag:gcFieldFlagWeightedMeanSpeed andActivityType:activity.activityType] inActivity:activity] convertToUnit:activity.speedDisplayUnit];
    GCNumberWithUnit * dur  = [lap numberWithUnitForField:[GCField fieldForFlag:gcFieldFlagSumDuration andActivityType:activity.activityType] inActivity:activity];
    GCNumberWithUnit * cad  = [lap numberWithUnitForField:[GCField fieldForFlag:gcFieldFlagCadence andActivityType:activity.activityType] inActivity:activity];
    GCNumberWithUnit * lgth = [lap numberWithUnitForField:[GCField fieldForKey:@"SumNumLengths" andActivityType:GC_TYPE_SWIMMING] inActivity:activity];

    GCFormattedField * distF = [GCFormattedField formattedFieldForNumber:dist  forSize:16.];
    GCFormattedField * speedF= [GCFormattedField formattedFieldForNumber:speed forSize:14.];
    GCFormattedField * durF  = [GCFormattedField formattedFieldForNumber:dur   forSize:16.];
    GCFormattedField * cadF  = [GCFormattedField formattedFieldForNumber:cad   forSize:14.];
    //GCFormattedField * lgthF = [GCFormattedField formattedField:nil activityType:nil forNumber:lgth forSize:14.];

    GCFormattedField * stke  = [GCFormattedField formattedFieldDisplay:[GCFields swimStrokeName:lap.directSwimStroke] forNumber:nil forSize:12];
    stke.noDisplayField = true;
    [stke setColor:[GCViewConfig defaultColor:gcSkinDefaultColorSecondaryText]];

    if (![lap active]) {
        distF = [GCFormattedField formattedFieldDisplay:@"Rest" forNumber:nil forSize:14];
        distF.noDisplayField = true;
        speedF = nil;
        cadF = nil;
        stke = nil;
    }

    if ([lap active] && lgth) {
        NSString * title = [NSString stringWithFormat:NSLocalizedString(@"Int %lu ",@"Lap Cell"), (unsigned long)(idx+1)];
        NSString * len   = [NSString stringWithFormat:@"%.0f len", lgth.value];
        NSMutableAttributedString * is = [[[NSMutableAttributedString alloc] initWithString:title attributes:[GCViewConfig attribute14]] autorelease];
        [is appendAttributedString:[[[NSAttributedString alloc] initWithString:len attributes:[GCViewConfig attribute14Gray]] autorelease]];
        [self labelForRow:0 andCol:0].attributedText = is;
    }else if (lgth){
        [self labelForRow:0 andCol:0].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                       withFormat:NSLocalizedString(@"Int %d",@"Lap Cell"), idx+1];
    }else{
        [self labelForRow:0 andCol:0].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                                 withFormat:NSLocalizedString(@"Len %d",@"Lap Cell"),idx+1];
    }
    [self labelForRow:1 andCol:0].attributedText = [stke attributedString];

    NSMutableAttributedString * as = [[[NSMutableAttributedString alloc] initWithAttributedString:[distF attributedString]] autorelease];

    if (wide) {
        [self labelForRow:1 andCol:1].attributedText = as;
        [self labelForRow:1 andCol:2].attributedText = [durF attributedString];
        [self labelForRow:1 andCol:3].attributedText = [speedF attributedString];
        [self labelForRow:1 andCol:4].attributedText = [cadF attributedString];
    }else{
        [self labelForRow:0 andCol:1].attributedText = as;
        [self labelForRow:0 andCol:2].attributedText = [durF attributedString];
        [self labelForRow:1 andCol:1].attributedText = [cadF attributedString];
        [self labelForRow:1 andCol:2].attributedText = [speedF attributedString];
    }
    if ([lap active]) {
        [GCViewConfig setupGradient:self forSwimStroke:lap.directSwimStroke];
    }else{
        [GCViewConfig setupGradientForCellsOdd:self];
    }


}

@end
