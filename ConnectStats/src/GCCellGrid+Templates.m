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
#import "GCTrackPointSwim.h"
#import "GCActivity+UI.h"
#import "GCViewIcons.h"
#import "GCHistoryFieldDataSerie.h"
#import "GCActivityTennis.h"
#import "GCActivityTennisShotValues.h"
#import "GCActivityTennisHeatmap.h"
#import "GCAppGlobal.h"
#import "GCActivity+Fields.h"

const CGFloat kGC_WIDE_SIZE = 420.0f;

@implementation GCCellGrid (Templates)

-(void)setupForText:(NSString*)aText{
    [self setupForRows:1 andCols:1];
    [self labelForRow:0 andCol:0].text = aText;

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

        if (weather.newFormat && weather.weatherStationName) {
            [self labelForRow:0 andCol:0].attributedText = [GCViewConfig attributedString:temp attribute:@selector(attribute16)];
            [self labelForRow:0 andCol:1].attributedText = [GCViewConfig attributedString:[weather weatherDisplayField:GC_WEATHER_WIND] attribute:@selector(attribute16)];
            [self labelForRow:1 andCol:0].attributedText = [GCViewConfig attributedString:weather.weatherStationName attribute:@selector(attribute14Gray)];
            GCNumberWithUnit * distance = [[weather weatherStationDistanceFromCoordinate:activity.beginCoordinate] convertToGlobalSystem];
            [self labelForRow:1 andCol:1].attributedText = [GCViewConfig attributedString:distance.description attribute:@selector(attribute14Gray)];
        }else{
            [self labelForRow:0 andCol:0].attributedText = [GCViewConfig attributedString:temp attribute:@selector(attribute16)];
            [self labelForRow:1 andCol:0].attributedText = [GCViewConfig attributedString:[weather weatherDisplayField:GC_WEATHER_WIND] attribute:@selector(attribute16)];

        }
        UIImage * icon = [weather weatherIcon];
        if (icon) {
            [self setIconImage:icon];
            self.iconPosition = gcIconPositionLeft;
        }else{
            [self setIconImage:nil];
            [self labelForRow:0 andCol:1].text = [weather weatherDisplayField:GC_WEATHER_ICON];
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
-(void)setupForField:(id)input andActivity:(GCActivity *)activity width:(CGFloat)width{
    NSMutableArray * fields = [NSMutableArray array];
    GCFormattedField * mainF = nil;
    GCField * field = nil;
    if([input isKindOfClass:[NSArray class]]){
        NSArray * inputs = input;
        if (inputs.count>0) {
            field = [GCField field:inputs[0] forActivityType:activity.activityType];
            GCNumberWithUnit * mainN = [activity numberWithUnitForField:field];
            mainF = [GCFormattedField formattedField:field.key activityType:activity.activityType forNumber:mainN forSize:16.];

            for (NSUInteger i=1; i<inputs.count; i++) {
                NSString * addField = inputs[i];
                GCNumberWithUnit * addNumber = [activity numberWithUnitForFieldKey:addField];
                if (addNumber) {
                    GCFormattedField* theOne = [GCFormattedField formattedField:addField activityType:activity.activityType forNumber:addNumber forSize:14.];
                    theOne.valueColor = [UIColor darkGrayColor];
                    theOne.labelColor = [UIColor darkGrayColor];
                    if ([addNumber sameUnit:mainN]) {
                        theOne.noUnits = true;
                    }
                    [fields addObject:theOne];
                }
            }
        }
    }else {
        field = [GCField field:input forActivityType:activity.activityType];
        if (field) {
            NSArray * related = [field relatedFields];

            GCNumberWithUnit * mainN = [activity numberWithUnitForField:field];
            mainF = [GCFormattedField formattedField:field.key activityType:activity.activityType forNumber:mainN forSize:16.];

            for (NSUInteger i=0; i<related.count; i++) {
                GCField * addField = related[i];
                GCNumberWithUnit * addNumber = [activity numberWithUnitForField:addField];
                if (addNumber) {
                    GCFormattedField* theOne = [GCFormattedField formattedField:addField.key activityType:activity.activityType forNumber:addNumber forSize:14.];
                    theOne.valueColor = [UIColor darkGrayColor];
                    theOne.labelColor = [UIColor darkGrayColor];
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
                                    NSForegroundColorAttributeName: [UIColor blueColor]};
    NSDictionary * dateAttributes = @{NSFontAttributeName: [GCViewConfig boldSystemFontOfSize:16.],
                                     NSForegroundColorAttributeName: [UIColor blackColor]};
    NSDictionary * nameAttributes = @{NSFontAttributeName: [GCViewConfig systemFontOfSize:14.],
                                          NSForegroundColorAttributeName: [UIColor blackColor]};

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
    GCFormattedField * distance = [GCFormattedField formattedField:nil activityType:nil
                                                         forNumber:[activity numberWithUnitForFieldFlag:gcFieldFlagSumDistance] forSize:16.];

    GCNumberWithUnit * nu_steps = [activity numberWithUnitForFieldKey:@"SumStep"];
    GCNumberWithUnit * nu_goal  = [activity numberWithUnitForFieldKey:@"GoalSumStep"];
    GCFormattedField * steps = [GCFormattedField formattedField:nil activityType:nil
                                                         forNumber:nu_steps forSize:14.];

    NSDictionary * dateAttributes = @{ NSFontAttributeName:[GCViewConfig boldSystemFontOfSize:16.],
                                       NSForegroundColorAttributeName:[UIColor blackColor]
                                       };

    NSDictionary * dateSmallAttributes = @{ NSFontAttributeName:[GCViewConfig systemFontOfSize:12.],
                                            NSForegroundColorAttributeName:[UIColor blackColor]
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

-(void)setupSummaryFromTennisActivity:(GCActivityTennis*)activity width:(CGFloat)width status:(gcViewActivityStatus)status{
    GCFormattedField * duration = [GCFormattedField formattedField:nil activityType:nil
                                                         forNumber:[activity numberWithUnitForFieldFlag:gcFieldFlagSumDuration] forSize:16.];

    GCNumberWithUnit * val = [activity numberWithUnitForFieldFlag:gcFieldFlagTennisShots];
    GCFormattedField * shots = [GCFormattedField formattedField:nil activityType:nil forNumber:val forSize:16.];

    NSDictionary * locAttributes = @{NSFontAttributeName: [GCViewConfig systemFontOfSize:12.],
                                     NSForegroundColorAttributeName: [UIColor blueColor]};
    NSDictionary * dateAttributes = @{NSFontAttributeName: [GCViewConfig boldSystemFontOfSize:16.],
                                      NSForegroundColorAttributeName: [UIColor blackColor]};
    NSDictionary * dateSmallAttributes = @{NSFontAttributeName: [GCViewConfig systemFontOfSize:12.],
                                           NSForegroundColorAttributeName: [UIColor blackColor]};

    NSDate * date = activity.date;
    NSString * dispname = [activity displayName];
    if (dispname.length>24) {
        dispname = [NSString stringWithFormat:@"%@...", [dispname substringToIndex:24]];
    }
    if (date == nil) {
        dispname = NSLocalizedString(@"Date Error",@"Services");
        date =[NSDate date];
        RZLog(RZLogInfo, @"Invalid Date for %@", activity);
    }
    duration.valueFont = [GCViewConfig systemFontOfSize:16.];// remove bold
    NSAttributedString * loc    = [[[NSAttributedString alloc] initWithString:dispname?:NSLocalizedString(@"Error",@"Fitness") attributes:locAttributes] autorelease];
    NSAttributedString * day    = [[[NSAttributedString alloc] initWithString:[date dayFormat]       attributes:dateAttributes] autorelease];
    NSAttributedString * dat    = [[[NSAttributedString alloc] initWithString:[date dateShortFormat] attributes:dateSmallAttributes] autorelease];
    NSAttributedString * time   = [[[NSAttributedString alloc] initWithString:[date timeShortFormat] attributes:dateSmallAttributes] autorelease];

    if (width < 600.) {
        [self setupForRows:3 andCols:3];
        self.marginx = 2.;
        self.marginy = 2.;
        [self labelForRow:0 andCol:1].attributedText = [shots attributedString];
        [self labelForRow:0 andCol:0].attributedText = day;
        [self labelForRow:0 andCol:2].attributedText = time;
        [self labelForRow:1 andCol:1].attributedText = [duration attributedString];
        [self labelForRow:1 andCol:0].attributedText = dat;
        //[self labelForRow:1 andCol:2].attributedText = showBpm ? [bpm attributedString] : nil;
        [self labelForRow:2 andCol:0].attributedText = loc;
        //[self labelForRow:2 andCol:2].attributedText = showSpeed ? [speed attributedString] : nil;

        [self configForRow:1 andCol:2].verticalAlign = gcVerticalAlignBottom;
        [self configForRow:2 andCol:2].verticalAlign = gcVerticalAlignTop;
        [self configForRow:2 andCol:0].horizontalOverflow = YES;
    }else{
        [self setupForRows:2 andCols:4];
        self.marginx = 2.;
        self.marginy = 2.;
        [self labelForRow:0 andCol:0].attributedText = day;
        [self labelForRow:0 andCol:1].attributedText = [shots attributedString];
        [self labelForRow:0 andCol:2].attributedText = [duration attributedString];
        //[self labelForRow:0 andCol:3].attributedText = showBpm ? [bpm attributedString] : nil;
        [self labelForRow:1 andCol:0].attributedText = dat;
        [self labelForRow:1 andCol:1].attributedText = time;
        [self labelForRow:1 andCol:2].attributedText = loc;
        //[self labelForRow:1 andCol:3].attributedText = showSpeed ? [speed attributedString] : nil;
    }
    if (status==gcViewActivityStatusCompare) {
        [self setIconImage:[GCViewConfig mergeImage:[activity icon] withImage:[GCViewIcons cellIconFor:gcIconCellCheckbox]]];
    }else{
        if ( [GCAppGlobal configGetBool:CONFIG_SHOW_DOWNLOAD_ICON defaultValue:false] && activity.trackPointsRequireDownload) {
            [self setIconImage:[GCViewConfig mergeImage:[activity icon] withImage:[GCViewIcons cellIconFor:gcIconCellCloudDownload]]];
        }else{
            [self setIconImage:[activity icon]];
        }
    }

}

-(void)setupSummaryFromFitnessActivity:(GCActivity*)activity width:(CGFloat)width status:(gcViewActivityStatus)status{

    GCNumberWithUnit * speednu = [activity numberWithUnitForFieldFlag:gcFieldFlagWeightedMeanSpeed];
    GCNumberWithUnit * bpmnu = [activity numberWithUnitForFieldFlag:gcFieldFlagWeightedMeanHeartRate];

    GCFormattedField * duration = [GCFormattedField formattedField:nil activityType:nil
                                                         forNumber:[activity numberWithUnitForFieldFlag:gcFieldFlagSumDuration] forSize:16.];

    GCFormattedField * distance = [GCFormattedField formattedField:nil activityType:nil
                                                         forNumber:[activity numberWithUnitForFieldFlag:gcFieldFlagSumDistance] forSize:16.];

    GCFormattedField * bpm      = [GCFormattedField formattedField:nil activityType:nil
                                                         forNumber:bpmnu forSize:12.];

    GCFormattedField * speed    = [GCFormattedField formattedField:nil activityType:nil
                                                         forNumber:speednu forSize:12.];

    BOOL skipAlways = activity.skipAlways;
    BOOL showBpm = ( bpmnu != nil && bpmnu.value!=0.);
    BOOL showSpeed = (speednu != nil && speednu.value != 0.);

    if (activity.isSkiActivity) {

        if ([activity.activityTypeDetail isEqualToString:GC_TYPE_SKI_DOWN]) {
            GCNumberWithUnit * loss = [activity numberWithUnitForFieldKey:@"LossElevation"];
            bpm = [GCFormattedField formattedField:nil activityType:nil
                                           forNumber:loss forSize:12.];
            showBpm = true;
        }else{
            GCNumberWithUnit * gain = [activity numberWithUnitForFieldKey:@"GainElevation"];
            speed = [GCFormattedField formattedField:nil activityType:nil
                                           forNumber:gain forSize:12.];
            showSpeed = true;
        }
    }

    NSDictionary * locAttributes = @{NSFontAttributeName: [GCViewConfig systemFontOfSize:12.],
                                                                              NSForegroundColorAttributeName: [UIColor blueColor]};
    NSDictionary * dateAttributes = @{NSFontAttributeName: [GCViewConfig boldSystemFontOfSize:16.],
                                                                                NSForegroundColorAttributeName: [UIColor blackColor]};
    NSDictionary * dateSmallAttributes = @{NSFontAttributeName: [GCViewConfig systemFontOfSize:12.],
                                     NSForegroundColorAttributeName: [UIColor blackColor]};

    if( skipAlways ){
        locAttributes = @{NSFontAttributeName: [GCViewConfig systemFontOfSize:12.],
                          NSForegroundColorAttributeName: [UIColor darkGrayColor]};
        dateAttributes = @{NSFontAttributeName: [GCViewConfig boldSystemFontOfSize:16.],
                                          NSForegroundColorAttributeName: [UIColor darkGrayColor]};
        dateSmallAttributes = @{NSFontAttributeName: [GCViewConfig systemFontOfSize:12.],
                                               NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    }
    NSDate * date = activity.date;
    NSString * dispname = [activity displayName];
    if (dispname.length>24) {
        dispname = [NSString stringWithFormat:@"%@...", [dispname substringToIndex:24]];
    }
    if (date == nil) {
        dispname = NSLocalizedString(@"Date Error",@"Services");
        date =[NSDate date];
        RZLog(RZLogInfo, @"Invalid Date for %@", activity);
    }
    NSAttributedString * loc    = [[[NSAttributedString alloc] initWithString:dispname?:NSLocalizedString(@"Error",@"Fitness") attributes:locAttributes] autorelease];
    NSAttributedString * day    = [[[NSAttributedString alloc] initWithString:[date dayFormat]       attributes:dateAttributes] autorelease];
    NSAttributedString * dat    = [[[NSAttributedString alloc] initWithString:[date dateShortFormat] attributes:dateSmallAttributes] autorelease];
    NSAttributedString * time   = [[[NSAttributedString alloc] initWithString:[date timeShortFormat] attributes:dateSmallAttributes] autorelease];

    if ([activity isKindOfClass:[GCActivityTennis class]]) {
        //FIX
        GCNumberWithUnit * val = [activity numberWithUnitForFieldFlag:gcFieldFlagTennisShots];
        if (val!=nil && val.value != 0.) {
            distance = [GCFormattedField formattedField:nil activityType:nil forNumber:val forSize:16.];
        }else{
            distance = nil;
        }
    }

    duration.valueFont = [GCViewConfig systemFontOfSize:16.];// remove bold

    bpm.labelColor = [UIColor darkGrayColor];
    bpm.valueColor = [UIColor darkGrayColor];
    bpm.valueFont = [GCViewConfig systemFontOfSize:12.];

    speed.labelColor = [UIColor darkGrayColor];
    speed.valueColor = [UIColor darkGrayColor];
    speed.valueFont = [GCViewConfig systemFontOfSize:12.];

    if( skipAlways ){
        [self setupBackgroundColors:@[ [UIColor lightGrayColor] ]];
        duration.valueColor = [UIColor darkGrayColor];
        distance.valueColor = [UIColor darkGrayColor];
        distance.labelColor = [UIColor darkGrayColor];
    }else{
        [GCViewConfig setupGradient:self ForActivity:activity];
    }

    self.enableButtons = true;
    self.leftButtonText = skipAlways ? NSLocalizedString(@"Use", @"Grid Cell Button") : NSLocalizedString(@"Ignore", @"Grid Cell Button");
    self.rightButtonText = status == gcViewActivityStatusCompare ? NSLocalizedString(@"Clear", @"Grid Cell Button") :
        NSLocalizedString(@"Mark", @"Grid Cell Button");

    if (width < 600.) {
        [self setupForRows:3 andCols:3];
        self.marginx = 2.;
        self.marginy = 2.;
        [self labelForRow:0 andCol:1].attributedText = [distance attributedString];
        [self labelForRow:0 andCol:0].attributedText = day;
        [self labelForRow:0 andCol:2].attributedText = time;
        [self labelForRow:1 andCol:1].attributedText = [duration attributedString];
        [self labelForRow:1 andCol:0].attributedText = dat;
        [self labelForRow:1 andCol:2].attributedText = showBpm ? [bpm attributedString] : nil;
        [self labelForRow:2 andCol:0].attributedText = loc;
        [self labelForRow:2 andCol:2].attributedText = showSpeed ? [speed attributedString] : nil;

        [self configForRow:1 andCol:2].verticalAlign = gcVerticalAlignBottom;
        [self configForRow:2 andCol:2].verticalAlign = gcVerticalAlignTop;
        [self configForRow:2 andCol:0].horizontalOverflow = YES;
    }else{
        [self setupForRows:2 andCols:4];
        self.marginx = 2.;
        self.marginy = 2.;
        [self labelForRow:0 andCol:0].attributedText = day;
        [self labelForRow:0 andCol:1].attributedText = [distance attributedString];
        [self labelForRow:0 andCol:2].attributedText = [duration attributedString];
        [self labelForRow:0 andCol:3].attributedText = showBpm ? [bpm attributedString] : nil;
        [self labelForRow:1 andCol:0].attributedText = dat;
        [self labelForRow:1 andCol:1].attributedText = time;
        [self labelForRow:1 andCol:2].attributedText = loc;
        [self labelForRow:1 andCol:3].attributedText = showSpeed ? [speed attributedString] : nil;
    }
    if (status==gcViewActivityStatusCompare) {
        [self setIconImage:[GCViewConfig mergeImage:[activity icon] withImage:[GCViewIcons cellIconFor:gcIconCellCheckbox]]];
    }else{
        if ( [GCAppGlobal configGetBool:CONFIG_SHOW_DOWNLOAD_ICON defaultValue:false] && activity.trackPointsRequireDownload) {
            [self setIconImage:[GCViewConfig mergeImage:[activity icon] withImage:[GCViewIcons cellIconFor:gcIconCellCloudDownload]]];
        }else{
            [self setIconImage:[activity icon]];
        }
    }

}

-(void)setupSummaryFromActivity:(GCActivity*)activity width:(CGFloat)width status:(gcViewActivityStatus)status{
    if ([activity.activityType isEqualToString:GC_TYPE_DAY]) {
        [self setupSummaryFromDayActivity:activity width:width status:status];
    }else if( [activity isKindOfClass:[GCActivityTennis class]]){
        [self setupSummaryFromTennisActivity:(GCActivityTennis*)activity width:width status:status];
    }else{
        [self setupSummaryFromFitnessActivity:activity width:width status:status];
    }
}

#pragma mark - Aggregated Stats

-(void)setupFromHistoryAggregatedData:(GCHistoryAggregatedDataHolder*)data
                                index:(NSUInteger)idx
                           viewChoice:(gcViewChoice)viewChoice
                      andActivityType:(NSString*)activityType
                                width:(CGFloat)width{
    BOOL wide =false;
    if (width > kGC_WIDE_SIZE) {
        wide = true;
        [self setupForRows:2 andCols:5];
    }else{
        [self setupForRows:2 andCols:3];
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

    NSString * dateFmt = [data.date calendarUnitFormat:[GCViewConfig calendarUnitForViewChoice:viewChoice]];
    if (!dateFmt) {
        RZLog(RZLogError, @"Got no date: idx=%d data=%@ date=%@",(int)idx,data,[data date]);
        dateFmt = NSLocalizedString(@"ERROR", @"Date");
    }
    NSAttributedString * dateStr = [[[NSAttributedString alloc] initWithString:dateFmt attributes:dateAttributes] autorelease];

    GCNumberWithUnit * durationN =[data numberWithUnit:gcAggregatedSumDuration statType:gcAggregatedSum andActivityType:activityType];
    GCNumberWithUnit * distanceN =[data numberWithUnit:gcAggregatedSumDistance statType:gcAggregatedSum andActivityType:activityType];

    GCNumberWithUnit * speedmps =[GCNumberWithUnit numberWithUnitName:@"mps" andValue:[distanceN convertToUnitName:@"meter"].value/durationN.value];

    GCNumberWithUnit * speedN = [speedmps convertToUnit:[GCFields fieldUnit:[GCFields fieldForFlag:gcFieldFlagWeightedMeanSpeed andActivityType:activityType] activityType:activityType]];

    GCFormattedField * main1    = nil;
    GCFormattedField * main2    = nil;
    GCFormattedField * detail1  = nil;
    GCFormattedField * detail2  = nil;

    if ([data.activityType isEqualToString:GC_TYPE_DAY]) {
        main1 = [GCFormattedField formattedField:nil
                                    activityType:nil
                                       forNumber:[data numberWithUnit:gcAggregatedSumStep statType:gcAggregatedSum andActivityType:GC_TYPE_DAY]
                                         forSize:16.];
        detail1 = [GCFormattedField formattedField:nil
                                    activityType:nil
                                       forNumber:durationN
                                         forSize:14.];
    }else if([data.activityType isEqualToString:GC_TYPE_TENNIS]){

        main1 = [GCFormattedField formattedField:nil
                                    activityType:nil
                                       forNumber:[data numberWithUnit:gcAggregatedTennisShots statType:gcAggregatedSum andActivityType:GC_TYPE_DAY]
                                         forSize:16.];
        detail1 = [GCFormattedField formattedField:nil
                                      activityType:nil
                                         forNumber:durationN
                                           forSize:14.];

    }else{
        main1 = [GCFormattedField formattedField:nil
                                    activityType:nil
                                       forNumber:durationN
                                         forSize:16.];
    }
    main2 = [GCFormattedField formattedField:nil
                                activityType:nil
                                   forNumber:distanceN
                                     forSize:16.];
    if(speedN.isValidValue){
        detail2 = [GCFormattedField formattedField:nil
                                      activityType:nil
                                         forNumber:speedN
                                           forSize:14.];
    }
    if ([data hasField:gcAggregatedWeightedHeartRate]) {
        detail1 = [GCFormattedField formattedField:nil
                                      activityType:nil
                                         forNumber:[data numberWithUnit:gcAggregatedWeightedHeartRate statType:gcAggregatedAvg andActivityType:activityType]
                                           forSize:14.];
    }else if ([data.activityType isEqualToString:GC_TYPE_TENNIS]){
        detail1 = [GCFormattedField formattedField:nil
                                      activityType:nil
                                         forNumber:[data numberWithUnit:gcAggregatedTennisPower statType:gcAggregatedAvg andActivityType:activityType]
                                           forSize:14.];
        detail2 = nil;

    }

    detail1.labelColor = [UIColor darkGrayColor];
    detail1.valueColor = [UIColor darkGrayColor];
    detail1.valueFont = [GCViewConfig systemFontOfSize:14.];
    detail1.labelFont = [GCViewConfig systemFontOfSize:12.];

    detail2.labelColor = [UIColor darkGrayColor];
    detail2.valueColor = [UIColor darkGrayColor];
    detail2.valueFont = [GCViewConfig systemFontOfSize:14.];
    detail2.labelFont = [GCViewConfig systemFontOfSize:12.];

    [self labelForRow:0 andCol:0].attributedText = dateStr;
    if (wide) {
        [self labelForRow:1 andCol:1].attributedText = [main2 attributedString];
        [self labelForRow:1 andCol:2].attributedText = [main1 attributedString];
        [self labelForRow:1 andCol:3].attributedText = [detail2 attributedString];
        [self labelForRow:1 andCol:4].attributedText = [detail1 attributedString];
    }else{
        [self labelForRow:0 andCol:1].attributedText = [main2 attributedString];
        [self labelForRow:0 andCol:2].attributedText = [main1 attributedString];
        [self labelForRow:1 andCol:1].attributedText = [detail2 attributedString];
        [self labelForRow:1 andCol:2].attributedText = [detail1 attributedString];
    }
    [self configForRow:0 andCol:0].verticalAlign = gcVerticalAlignCenter;
    if (wide) {
        [self configForRow:1 andCol:1].verticalAlign = gcVerticalAlignCenter;
        [self configForRow:1 andCol:2].verticalAlign = gcVerticalAlignCenter;
        [self configForRow:1 andCol:3].verticalAlign = gcVerticalAlignCenter;
        [self configForRow:1 andCol:4].verticalAlign = gcVerticalAlignCenter;
    }else{
        [self configForRow:0 andCol:1].verticalAlign = gcVerticalAlignCenter;
        [self configForRow:0 andCol:2].verticalAlign = gcVerticalAlignCenter;
        [self configForRow:1 andCol:1].verticalAlign = gcVerticalAlignCenter;
        [self configForRow:1 andCol:2].verticalAlign = gcVerticalAlignCenter;
    }
    if (wide) {
        [self configForRow:1 andCol:1].horizontalAlign = gcHorizontalAlignRight;
        [self configForRow:1 andCol:2].horizontalAlign = gcHorizontalAlignRight;
        [self configForRow:1 andCol:3].horizontalAlign = gcHorizontalAlignRight;
        [self configForRow:1 andCol:4].horizontalAlign = gcHorizontalAlignRight;
    }else{
        [self configForRow:0 andCol:1].horizontalAlign = gcHorizontalAlignRight;
        [self configForRow:0 andCol:2].horizontalAlign = gcHorizontalAlignRight;
        [self configForRow:1 andCol:1].horizontalAlign = gcHorizontalAlignRight;
        [self configForRow:1 andCol:2].horizontalAlign = gcHorizontalAlignRight;
    }
}

#pragma mark - Field Statistics

-(void)setupForFieldDataHolder:(GCFieldDataHolder*)data histStats:(gcHistoryStats)which andActivityType:(NSString *)aType{

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

    if (mainN==nil) {
        return;
    }
    if (mainN.unit==nil) {
        RZLog(RZLogError, @"%@ had no unit", data.field);
        return;
    }

    NSString * fieldName = [data.field displayName];
    if (fieldName==nil) {
        fieldName = data.field.key;
    }
    GCFormattedField * count = [GCFormattedField formattedField:@"Count" activityType:aType forNumber:[data countWithUnit:which] forSize:14.];
    GCFormattedField * extra = nil;
    if ([data.field canSum]) {
        extra = [GCFormattedField formattedField:@"Average" activityType:aType forNumber:[data averageWithUnit:which] forSize:14.];
    }else if ([data.field isMax]){
        extra = [GCFormattedField formattedField:@"Max" activityType:aType forNumber:[data maxWithUnit:which] forSize:14.];
    }
    [count setColor:[UIColor darkGrayColor]];
    [extra setColor:[UIColor darkGrayColor]];

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

-(void)setUpForSummarizedHistory:(NSDictionary*)summarizedHistory atIndex:(NSUInteger)idx forField:(GCField*)field
                      viewChoice:(gcViewChoice)viewChoice{
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
        main = [GCFormattedField formattedField:nil     activityType:nil forNumber:sumN forSize: 16.];
        extra =[GCFormattedField formattedField:@"Avg"  activityType:nil forNumber:avgN forSize:14.];
        extra.noDisplayField = true;
    }else{
        main =[GCFormattedField formattedField:nil activityType:nil forNumber:avgN forSize:16.];
    }

    GCFormattedField * cntF = [GCFormattedField formattedField:@"Count" activityType:nil forNumber:cntN forSize:12.];
    GCFormattedField * maxF = [GCFormattedField formattedField:@"Max" activityType:nil forNumber:maxN forSize:12.];
    GCFormattedField * minF = [GCFormattedField formattedField:@"Min" activityType:nil forNumber:minN forSize:12.];
    GCFormattedField * stdF = [GCFormattedField formattedField:@"Std" activityType:nil forNumber:stdN forSize:12.];

    cntF.noDisplayField = true;
    maxF.noDisplayField = true;
    minF.noDisplayField = true;
    stdF.noDisplayField = true;

    [cntF setColor:[UIColor darkGrayColor]];
    [maxF setColor:[UIColor darkGrayColor]];
    [minF setColor:[UIColor darkGrayColor]];
    [stdF setColor:[UIColor darkGrayColor]];

    NSDictionary * dateAttr = @{NSFontAttributeName: [GCViewConfig boldSystemFontOfSize:14.],
                                     NSForegroundColorAttributeName: [UIColor blackColor]};

    [self setupForRows:3 andCols:3];
    [self labelForRow:0 andCol:0].attributedText = [[[NSAttributedString alloc] initWithString:[date calendarUnitFormat:[GCViewConfig calendarUnitForViewChoice:viewChoice]] attributes:dateAttr] autorelease];

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
    GCFormattedFieldText * title = [GCFormattedFieldText formattedFieldText:[GCFields activityTypeDisplay:activityStats.config.activityType]
                                                                      value:activityStats.fieldDisplayName
                                                                    forSize:16.];

    NSString * countText= [NSString stringWithFormat:NSLocalizedString(@"%d items",@"Stats Cell"),[activityStats count]];
    GCFormattedFieldText * sub = [GCFormattedFieldText formattedFieldText:@"Count"
                                                                    value:countText forSize:14.];

    sub.valueColor = [UIColor darkGrayColor];
    sub.labelColor = [UIColor darkGrayColor];

    [self labelForRow:0 andCol:0].attributedText = [title attributedString];
    [self labelForRow:1 andCol:0].attributedText = [sub attributedString];
    GCActivity * dummy = [[GCActivity alloc] init];

    dummy.activityType = activityStats.config.activityType;
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
        [self labelForRow:0 andCol:0].text = NSLocalizedString(@"Not enough observations", @"Stats Cell");
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

    GCLap * lap = [activity lapNumber:idx];
    GCNumberWithUnit * dist = [[lap numberWithUnitForField:gcFieldFlagSumDistance andActivityType:activity.activityType]
                               convertToUnitName:activity.distanceDisplayUom];
    GCNumberWithUnit * speed= [[lap numberWithUnitForField:gcFieldFlagWeightedMeanSpeed andActivityType:activity.activityType]
                               convertToUnitName:activity.speedDisplayUom];
    GCNumberWithUnit * dur  = [lap numberWithUnitForField:gcFieldFlagSumDuration andActivityType:activity.activityType];
    GCNumberWithUnit * bpm  = nil;
    GCNumberWithUnit * cad  = nil;
    GCNumberWithUnit * pow  = nil;

    if ([activity hasTrackField:gcFieldFlagWeightedMeanHeartRate ]) {
        bpm = [lap numberWithUnitForField:gcFieldFlagWeightedMeanHeartRate andActivityType:activity.activityType];
    }
    if ([activity hasTrackField:gcFieldFlagCadence]) {
        cad =   [lap numberWithUnitForField:gcFieldFlagCadence andActivityType:activity.activityType];
    }
    if ([activity hasTrackField:gcFieldFlagPower]) {
        pow = [lap numberWithUnitForField:gcFieldFlagPower andActivityType:activity.activityType];
    }

    GCFormattedField * distF = [GCFormattedField formattedField:nil activityType:nil forNumber:dist forSize:16.];
    GCFormattedField * speedF= [GCFormattedField formattedField:nil activityType:nil forNumber:speed forSize:14.];
    GCFormattedField * durF= [GCFormattedField formattedField:nil activityType:nil forNumber:dur forSize:16.];
    GCFormattedField * bpmF= bpm ? [GCFormattedField formattedField:nil activityType:nil forNumber:bpm forSize:14.] : nil;
    GCFormattedField * cadF= cad ? [GCFormattedField formattedField:nil activityType:nil forNumber:cad forSize:14.] : nil;
    GCFormattedField * powF= pow ? [GCFormattedField formattedField:nil activityType:nil forNumber:pow forSize:14.] : nil;

    BOOL isSki = [activity isSkiActivity];

    if ([activity.activityType isEqualToString:GC_TYPE_SWIMMING]) {
        if (dist.value == 0.) {
            distF = [GCFormattedField formattedField:@"Rest" activityType:nil forNumber:nil forSize:14.];
            distF.noDisplayField = true;
            speedF = nil;
        }
    }else if (isSki){
        GCNumberWithUnit * elev = nil;
        if ([activity.activityTypeDetail isEqualToString:GC_TYPE_SKI_DOWN]) {
            elev = [lap numberWithUnitForExtraByField:[GCField fieldForKey:@"LossElevation" andActivityType:activity.activityType]];
            if (elev == nil) {
                elev = [lap numberWithUnitForExtraByField:[GCField fieldForKey:@"LossCorrectedElevation" andActivityType:activity.activityType]];
            }
            if (elev == nil) {
                elev = [lap numberWithUnitForExtraByField:[GCField fieldForKey:@"LossUncorrectedElevation" andActivityType:activity.activityType]];
            }
        }else {
            elev = [lap numberWithUnitForExtraByField:[GCField fieldForKey:@"GainElevation" andActivityType:activity.activityType]];
            if (elev == nil) {
                elev = [lap numberWithUnitForExtraByField:[GCField fieldForKey:@"GainCorrectedElevation" andActivityType:activity.activityType]];
            }
            if (elev == nil) {
                elev = [lap numberWithUnitForExtraByField:[GCField fieldForKey:@"GainUncorrectedElevation" andActivityType:activity.activityType]];
            }
        }
        if (elev) {
            bpmF = [GCFormattedField formattedField:nil activityType:nil forNumber:elev forSize:14.];
        }
    }
    if (lap.label) {
        [self labelForRow:0 andCol:0].text = lap.label;
    }else{
        if (isSki) {
            [self labelForRow:0 andCol:0].text = [NSString stringWithFormat:NSLocalizedString(@"Run %d",@"Lap Cell"),
                                                  idx+1];

        }else{
            [self labelForRow:0 andCol:0].text = [NSString stringWithFormat:NSLocalizedString(@"Lap %d",@"Lap Cell"),
                                                  idx+1];
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
        GCFormattedField * numberF = [GCFormattedField formattedField:nil activityType:nil forNumber:number forSize:16.];

        [self labelForRow:0 andCol:0].text = display ?: field.key;
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
            number1 = [aLap numberWithUnitForField:field1.fieldFlag andActivityType:aType];
            if (fieldFlag == gcFieldFlagSumDistance) {
                number1 = [number1 convertToUnitName:activity.distanceDisplayUom];
            }else if(fieldFlag == gcFieldFlagWeightedMeanSpeed){
                number1 = [number1 convertToUnitName:activity.speedDisplayUom];
            }
            display1 = field1.displayName;
        }
        NSString * field2   = [GCFields fieldForLapField:key andActivityType:aType];
        NSString * display2 = [GCFields fieldDisplayName:field2 activityType:aType];

        GCFormattedField * numberF1 = [GCFormattedField formattedField:nil activityType:nil forNumber:number1 forSize:16.];

        GCNumberWithUnit * number2 = [aLap numberWithUnitForExtraByField:[GCField fieldForKey:key andActivityType:aType]];

        GCFormattedField * number2F = wide ?
            [GCFormattedField formattedField:nil activityType:nil forNumber:number2 forSize:16.]:
            [GCFormattedField formattedField:nil activityType:nil forNumber:number2 forSize:14.];
        if (!wide) {
            [number2F setColor:[UIColor darkGrayColor]];
        }

        NSAttributedString * under = [[[NSAttributedString alloc] initWithString:display2 ?: field2
                                                                      attributes:wide?[GCViewConfig attribute16]:[GCViewConfig attribute14Gray]] autorelease];

        [self labelForRow:0 andCol:0].text = display1 ?: field1.key;
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
    id one = activity.laps[idx];
    if ([one isKindOfClass:[GCTrackPointSwim class]]) {
        GCTrackPointSwim * lap = one;
        [self setupForSwimTrackpoint:lap index:idx andActivity:activity width:width];
    }
}

-(void)setupForSwimTrackpoint:(GCTrackPointSwim*)lap index:(NSUInteger)idx andActivity:(GCActivity*)activity width:(CGFloat)width{
    BOOL wide =false;
    if (width > kGC_WIDE_SIZE) {
        wide = true;
        [self setupForRows:2 andCols:5];
    }else{
        [self setupForRows:2 andCols:3];
    }
    GCNumberWithUnit * dist = [[lap numberWithUnitForField:gcFieldFlagSumDistance
                                           andActivityType:activity.activityType]
                               convertToUnitName:activity.distanceDisplayUom];
    GCNumberWithUnit * speed= [[lap numberWithUnitForField:gcFieldFlagWeightedMeanSpeed andActivityType:activity.activityType] convertToUnitName:activity.speedDisplayUom];
    GCNumberWithUnit * dur  = [lap numberWithUnitForField:gcFieldFlagSumDuration andActivityType:activity.activityType];
    GCNumberWithUnit * cad  = [lap numberWithUnitForField:gcFieldFlagCadence andActivityType:activity.activityType];
    GCNumberWithUnit * lgth = [lap numberWithUnitForExtraByField:[GCField fieldForKey:@"SumNumLengths" andActivityType:GC_TYPE_SWIMMING]];

    GCFormattedField * distF = [GCFormattedField formattedField:nil activityType:nil forNumber:dist  forSize:16.];
    GCFormattedField * speedF= [GCFormattedField formattedField:nil activityType:nil forNumber:speed forSize:14.];
    GCFormattedField * durF  = [GCFormattedField formattedField:nil activityType:nil forNumber:dur   forSize:16.];
    GCFormattedField * cadF  = [GCFormattedField formattedField:nil activityType:nil forNumber:cad   forSize:14.];
    //GCFormattedField * lgthF = [GCFormattedField formattedField:nil activityType:nil forNumber:lgth forSize:14.];

    GCFormattedField * stke  = [GCFormattedField formattedField:[GCFields swimStrokeName:lap.directSwimStroke] activityType:nil forNumber:nil forSize:12];
    stke.noDisplayField = true;
    [stke setColor:[UIColor darkGrayColor]];

    if (![lap active]) {
        distF = [GCFormattedField formattedField:@"Rest" activityType:nil forNumber:nil forSize:14];
        distF.noDisplayField = true;
        speedF = nil;
        cadF = nil;
        stke = nil;
    }

    if ([lap active] && lgth) {
        NSString * title = [NSString stringWithFormat:NSLocalizedString(@"Int %d ",@"Lap Cell"), idx+1,lgth.value];
        NSString * len   = [NSString stringWithFormat:@"%.0f len", lgth.value];
        NSMutableAttributedString * is = [[[NSMutableAttributedString alloc] initWithString:title attributes:[GCViewConfig attribute14]] autorelease];
        [is appendAttributedString:[[[NSAttributedString alloc] initWithString:len attributes:[GCViewConfig attribute14Gray]] autorelease]];
        [self labelForRow:0 andCol:0].attributedText = is;
    }else if (lgth){
        [self labelForRow:0 andCol:0].text = [NSString stringWithFormat:NSLocalizedString(@"Int %d",@"Lap Cell"),
                                              idx+1];
    }else{
        [self labelForRow:0 andCol:0].text = [NSString stringWithFormat:NSLocalizedString(@"Len %d",@"Lap Cell"),
                                              idx+1];
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

#pragma mark - Tennis

-(void)setupForTennisHeatmap:(GCActivityTennis*)activity field:(NSString*)field{
    [self setupForRows:2 andCols:2];

    NSString * type = [GCActivityTennisHeatmap heatmapFieldType:field];
    NSString * typeLabel = [NSString stringWithFormat:NSLocalizedString( @"%@ Precision", @"tennis"), type];
    gcHeatmapLocation loc = [GCActivityTennisHeatmap heatmapFieldLocation:field];

    GCActivityTennisHeatmap * heatmap = [activity heatmapForType:type];

    GCNumberWithUnit * center = [heatmap valueForLocation:gcHeatmapLocationCenter];

    GCNumberWithUnit * left   = nil;
    GCNumberWithUnit * right  = nil;
    NSString * leftLabel  = nil;
    NSString * rightLabel = nil;

    if (loc == gcHeatmapLocationCenter ){
        left = [heatmap valueForLocation:gcHeatmapLocationLeft];
        right = [heatmap valueForLocation:gcHeatmapLocationRight];
        leftLabel = NSLocalizedString(@"Left", @"tennis precision");
        rightLabel  = NSLocalizedString(@"Right", @"tennis precision");
    }else{
        left = [heatmap valueForLocation:gcHeatmapLocationUp];
        right = [heatmap valueForLocation:gcHeatmapLocationDown];
        leftLabel = NSLocalizedString(@"Up", @"tennis precision");
        rightLabel  = NSLocalizedString(@"Down", @"tennis precision");

    }

    GCFormattedFieldText * heat = [GCFormattedFieldText formattedFieldText:NSLocalizedString(@"Center", @"heatmap tennis")
                                                                                         value:[center formatDouble]
                                                                                       forSize:16.];
    GCFormattedFieldText * heatLeft = [GCFormattedFieldText formattedFieldText:leftLabel
                                                                     value:[left formatDouble]
                                                                   forSize:14.];
    GCFormattedFieldText * heatRight = [GCFormattedFieldText formattedFieldText:rightLabel
                                                                     value:[right formatDouble]
                                                                   forSize:14.];
    heatRight.labelColor = [UIColor darkGrayColor];
    heatLeft.labelColor = [UIColor darkGrayColor];
    [self labelForRow:0 andCol:0].attributedText = [GCViewConfig attributedString:typeLabel attribute:@selector(attribute16)];
    [self labelForRow:0 andCol:1].attributedText = [heat attributedString];
    [self labelForRow:1 andCol:0].attributedText = [heatLeft attributedString];
    [self labelForRow:1 andCol:1].attributedText = [heatRight attributedString];

}

-(void)setupForTennisShotValue:(GCActivityTennis*)activity shotValue:(GCActivityTennisShotValues*)values{
    [self setupForRows:2 andCols:2];

    GCUnit * pct = [GCUnit unitForKey:@"percent"];
    GCUnit * sho = [GCUnit unitForKey:@"shots"];
    GCFormattedFieldText * pow = values.average_power?[GCFormattedFieldText formattedFieldText:NSLocalizedString(@"Power", @"power tennis")
                                                                    value:[pct formatDouble:(values.average_power).doubleValue]
                                                                                       forSize:16.]:nil;
    GCFormattedFieldText * maxpow = values.max_power?[GCFormattedFieldText formattedFieldText:NSLocalizedString(@"Max Power", @"power tennis")
                                                                       value:[pct formatDouble:(values.max_power).doubleValue]
                                                                                      forSize:14.]:nil;
    GCFormattedFieldText * tot = [GCFormattedFieldText formattedFieldText:values.shotType
                                                                       value:[sho formatDoubleNoUnits:(values.total).doubleValue]
                                                                     forSize:16.];
    GCFormattedFieldText * eff = values.average_effect_level ? [GCFormattedFieldText formattedFieldText:NSLocalizedString(@"Effect", @"power tennis")
                                                                    value:[pct formatDouble:(values.average_effect_level).doubleValue]
                                                                                                forSize:14.] :nil;

    [self labelForRow:0 andCol:0].attributedText = [tot attributedString];
    [self labelForRow:0 andCol:1].attributedText = [pow attributedString];
    [self labelForRow:1 andCol:0].attributedText = [eff attributedString];
    [self labelForRow:1 andCol:1].attributedText = [maxpow attributedString];

}

@end
