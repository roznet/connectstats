//  MIT Licence
//
//  Created on 06/11/2015.
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

#import <Foundation/Foundation.h>

@class GCField;

// Activity Cells
extern NSString * kGCSkinKeyActivityCellLighterBackgroundColor;
extern NSString * kGCSkinKeyActivityCellDarkerBackgroundColor;
extern NSString * kGCSkinKeyActivityCellIconColor;

// Field for Graphs
extern NSString * kGCSkinKeyFieldFillColor;
extern NSString * kGCSkinKeyFieldColors;
extern NSString * kGCSkinKeyTextColorForActivity;
extern NSString * kGCSkinKeySwimStrokeColor;
extern NSString * kGCSkinKeyCategoryBackground;
extern NSString * kGCSkinKeyGoalPercentBackgroundColor;
extern NSString * kGCSkinKeyGoalPercentTextColor;
extern NSString * kGCSkinKeyGraphColor;
extern NSString * kGCSkinKeyListOfColorsForMultiplots;
extern NSString * kGCSkinKeyCalendarColors;

extern NSString * kgcSkinDefaultColors;

typedef NS_ENUM(NSUInteger,gcSkinDefaultColor){
    gcSkinDefaultColorBackground,
    gcSkinDefaultColorBackgroundEven, // for things like alternating background in rows
    gcSkinDefaultColorBackgroundOdd, // for things like alternating background in rows
    gcSkinDefaultColorPrimaryText, // original = black
    gcSkinDefaultColorSecondaryText, // original = darkGray
    gcSkinDefaultColorTertiaryText, // original = lightGray
    gcSkinDefaultColorHighlightedText,  // Original = blue
    gcSkinDefaultColorGroupedTable
};

typedef NS_ENUM(NSUInteger,gcSkinCalendarElement){
    gcSkinCalendarElementWeekdayTextColor,
    gcSkinCalendarElementDayCurrentMonthTextColor,
    gcSkinCalendarElementDayAdjacentMonthTextColor,
    gcSkinCalendarElementDaySelectedTextColor,
    gcSkinCalendarElementSeparatorColor,
    gcSkinCalendarElementTileColor,
    gcSkinCalendarElementTileSelectedColor,
    gcSkinCalendarElementTileTodayColor,
    gcSkinCalendarElementTileTodaySelectedColor
};

typedef NS_ENUM(NSUInteger,gcSkinGraphColor){
    gcSkinGraphColorBackground,
    gcSkinGraphColorForeground,
    gcSkinGraphColorBarGraph,
    gcSkinGraphColorLineGraph,
    gcSkinGraphColorAxis,
    gcSkinGraphColorRegressionLine, // For regression line or moving average, etc
    gcSkinGraphColorLapOverlay,
    gcSkinGraphColorRegressionLineSecondary // for secondary graph (ex fitness/performance)
};

typedef NS_ENUM(NSUInteger,gcSkinBool){
    gcSkinBoolRoundedActivityIcons
};


@interface GCViewConfigSkin : NSObject

@property (nonatomic,readonly) NSString * skinName;
@property (nonatomic,readonly) NSDictionary * defs;

+(GCViewConfigSkin*)defaultSkin;
+(GCViewConfigSkin*)darkSkin;
+(GCViewConfigSkin*)skinForThemeName:(NSString*)theme;

+(NSArray<NSString*>*)availableSkinNames;
+(GCViewConfigSkin*)skinForName:(NSString*)name;

-(NSArray*)colorArrayForKey:(NSString*)key;
-(NSArray*)colorArrayForKey:(NSString *)key andField:(GCField*)field;

-(UIColor*)colorForKey:(NSString*)key;
-(UIColor*)colorForKey:(NSString *)key andActivity:(id)aAct;
-(UIColor*)colorForKey:(NSString *)key andField:(GCField*)field;
-(UIColor*)colorForKey:(NSString *)key andSubkey:(id)subkey;
-(UIColor*)colorForKey:(NSString*)key andValue:(double)val;
-(BOOL)boolFor:(gcSkinBool)which;

@end
