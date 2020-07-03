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

#import <Foundation/Foundation.h>
#import "GCActivity.h"
#import <QuartzCore/QuartzCore.h>
#import "GCFields.h"
#import "GCAppConstants.h"
#import "GCViewConfigSkin.h"
#import <RZUtilsUniversal/RZUtilsUniversal.h>

typedef NS_ENUM(NSUInteger, gcViewChoice) {
    gcViewChoiceAll,
    gcViewChoiceCalendar,
    gcViewChoiceSummary
};

typedef NS_ENUM(NSUInteger, gcViewActivityStatus) {
    gcViewActivityStatusNone,
    gcViewActivityStatusCurrent,
    gcViewActivityStatusCompare
};

typedef NS_ENUM(NSUInteger, gcGraphChoice){
    gcGraphChoiceCumulative,
    gcGraphChoiceBarGraph,
    gcGraphChoiceDistribution,
    gcGraphChoiceLine
};

typedef NS_ENUM(NSUInteger, gcStatsCalChoice)  {
    gcStatsCalAll,
    gcStatsCal3M,
    gcStatsCal6M,
    gcStatsCal1Y,
    gcStatsCalToDate,
    gcStatsCalCompare,
    gcStatsCalEnd
};

typedef NS_ENUM(NSUInteger, gcMapType) {
    gcMapBoth,
    gcMapApple,
    gcMapGoogle
};

@class GCCellGrid;
@class GCStatsCalendarAggregationConfig;

@interface GCViewConfig : RZViewConfig

// SKINS and CONFIGS

+(void)setSkin:(GCViewConfigSkin*)skin;



// COLORS

+(UIColor*)cellBackgroundDarkerForActivity:(id)aAct;
+(UIColor*)cellBackgroundLighterForActivity:(id)aAct;
+(UIColor*)cellIconColorForActivity:(id)aAct;

+(UIColor*)colorForSwimStrokeType:(gcSwimStrokeType)strokeType;

// In calendar
+(UIColor*)textColorForActivity:(id)aAct;

+(UIColor*)backgroundForCategory:(NSString*)category;

+(NSArray<UIColor*>*)arrayOfColorsForMultiplots;

// General Theme
+(UIColor*)defaultColor:(gcSkinDefaultColor)which;

+(UIColor*)fillColorForField:(GCField*)field;
+(NSArray*)colorsForField:(GCField*)field;

+(UIColor*)colorForGoalPercent:(double)pct;
+(UIColor*)textColorForGoalPercent:(double)pct;

+(UIColor*)colorForCalendarElement:(gcSkinCalendarElement)elem;
+(UIColor*)colorForGraphElement:(gcSkinGraphColor)which;

+(void)setupViewController:(UIViewController*)viewController;
+(GCCellEntryListViewController*)standardEntryListViewController:(NSArray*)theChoices selected:(NSUInteger)achoice;
+(void)setupGradient:(GCCellGrid*)aG ForActivity:(id)aAct;
+(void)setupGradientForDetails:(GCCellGrid*)aG;
+(void)setupGradientForCellsEven:(GCCellGrid*)aG;
+(void)setupGradientForCellsOdd:(GCCellGrid*)aG;
+(void)setupGradient:(GCCellGrid*)aG forSwimStroke:(gcSwimStrokeType)tp;
+(void)setupGradient:(GCCellGrid*)aG ForThreshold:(double)pct;

+(BOOL)roundedActivityIcons;

// FIELDS

+(NSArray*)mapTypes;
+(NSArray*)languageSettingChoices;

+(NSArray*)displayMainFieldsOrdered;
+(NSArray*)displayDayMainFieldsOrdered;

+(BOOL)trackFieldValidForPlotXAxis:(gcFieldFlag)aTrackField;
+(BOOL)trackFieldValidForPlotYAxis:(gcFieldFlag)aTrackField;

+(GCField*)nextFieldForGraph:(GCField*)currField fieldOrder:(NSArray<GCField*>*)order differentFrom:(GCField*)avoid;
+(NSArray<GCField*>*)validChoicesForGraphIn:(NSArray<GCField*>*)choices;

+(gcFieldFlag)nextTrackFieldForGraph:(gcFieldFlag)curr differentFrom:(gcFieldFlag)avoid valid:(gcFieldFlag)valid;

+(gcViewChoice)nextViewChoice:(gcViewChoice)current;// DEPRECATED_MSG_ATTRIBUTE("do local"); 
+(NSString*)viewChoiceDesc:(gcViewChoice)choice calendarConfig:(GCStatsCalendarAggregationConfig*)calendarConfig;

+(gcGraphChoice)graphChoiceForField:(GCField*)field andUnit:(NSCalendarUnit)aUnit;
+(NSString*)filterFor:(GCStatsCalendarAggregationConfig*)calendarConfig date:(NSDate*)date andActivityType:(NSString*)activityType;


+(NSArray*)unitSystemDescriptions;

+(NSArray*)weekStartDescriptions;
+(NSUInteger)weekDayValue:(NSUInteger)idx;
+(NSUInteger)weekDayIndex:(NSUInteger)idx;

+(NSArray*)periodDescriptions;
+(NSString*)periodDescriptionFromType:(gcPeriodType)tp;
+(gcPeriodType)periodFromIndex:(NSUInteger)idx;

+(UIImage*)mergeImage:(UIImage*)first withImage:(UIImage*)second;

+(NSArray<NSString*>*)validChoicesForGarminSource;
+(gcGarminDownloadSource)garminDownloadSource;
+(void)setGarminDownloadSource:(gcGarminDownloadSource)source;
+(NSString*)describeGarminSource:(gcGarminDownloadSource)source;
+(NSArray<NSString*>*)validChoicesForConnectStatsServiceUse;
+(NSArray<NSString*>*)validChoicesForConnectStatsConfig;


@end
