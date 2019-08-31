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

#import "GCViewConfigSkin.h"
#import "GCFields.h"
#import "GCActivity.h"

NSString * kGCSkinKeyActivityCellLighterBackgroundColor = @"ActivityCellLighterBackgroundColor";
NSString * kGCSkinKeyActivityCellDarkerBackgroundColor = @"ActivityCellDarkerBackgroundColor";
NSString * kGCSkinKeyActivityCellIconColor = @"ActivityCellIconColor";
NSString * kGCSkinKeyFieldColors = @"FieldColors";
NSString * kGCSkinKeyFieldFillColor = @"FieldFillColor";
NSString * kGCSkinKeyMissingActivityTypeColor = @"ActivityMissingActivityTypeColor";
NSString * kGCSkinKeyTextColorForActivity = @"TextColorForActivity";

NSString * kGCSkinKeyCategoryBackground = @"CategoryBackground";

NSString * kGCSkinKeySwimStrokeColor = @"SwimStrokeColor";
NSString * kGCSkinKeyGoalPercentTextColor = @"GoalPercentTextColor";
NSString * kGCSkinKeyGoalPercentBackgroundColor = @"GoalPercentBackgroundColor";

NSString * kGCSkinKeyGraphColor = @"GraphColor";
NSString * kGCSkinKeyListOfColorsForMultiplots = @"ListOfColorsForMultiplots";
NSString * kGCSkinKeyCalendarColors = @"CalendarColors";
NSString * kgcSkinDefaultColors = @"DefaultColors";

NSString * kGCSkinKeyBoolValues = @"BoolValues";

NS_INLINE NSArray * gcArrayForDefinitionValue(id input){
    if ([input isKindOfClass:[NSArray class]]) {
        return input;
    }else if([input isKindOfClass:[UIColor class]]){
        return @[ input ];
    }else{
        return nil;
    }
}

NS_INLINE UIColor * gcColorForDefinitionValue(id input){
    if ([input isKindOfClass:[UIColor class]]) {
        return input;
    }else if ([input isKindOfClass:[NSArray class]]){
        return input[0];
    }else{
        return nil;
    }
}

@interface GCViewConfigSkin ()
@property (nonatomic,retain) NSDictionary * defs;
@property (nonatomic,retain) NSString * skinName;
@end

@implementation GCViewConfigSkin

-(void)dealloc{
    [_skinName release];
    [_defs release];
    
    [super dealloc];
}

+(NSArray<NSString*>*)availableSkinNames{
    return @[
             @"Original",
             @"Dark",
             @"Dynamic"
             ];
}
+(GCViewConfigSkin*)skinForName:(NSString*)name{
    if( ![[GCViewConfigSkin availableSkinNames] containsObject:name] ){
        return nil;
    }
    
    if( [name isEqualToString:@"Original"] ){
        return [self defaultSkin];
    }else if ([name isEqualToString:@"Dark"] ){
        return [self darkSkin];
    }else if( [name isEqualToString:@"Dynamic"]){
        return [self dynamicSkinFromLight:[self defaultSkin] andDark:[self darkSkin]];
    }else{
        return [self skinForThemeName:name];
    }
}


+(GCViewConfigSkin*)defaultSkin{
    GCViewConfigSkin * rv = [[[GCViewConfigSkin alloc]init]autorelease];
    if (rv) {
        rv.skinName = @"Original";
        double alp = 0.4;
        
        rv.defs = @{
                    kGCSkinKeyBoolValues:
                        @{
                            @(gcSkinBoolRoundedActivityIcons): @(true)
                            
                            },
                    kGCSkinKeySwimStrokeColor:
                        @{
                            @(gcSwimStrokeFree): [UIColor colorWithRed:0xC4/255. green:0x3D/255. blue:0xBF/255. alpha:0.8],
                            @(gcSwimStrokeBack): [UIColor colorWithRed:0x1F/255. green:0x8E/255. blue:0xF0/255. alpha:0.8],
                            @(gcSwimStrokeBreast): [UIColor colorWithRed:0x95/255. green:0xDE/255. blue:0x2B/255. alpha:0.8],
                            @(gcSwimStrokeButterfly): [UIColor colorWithRed:0xD5/255. green:0x76/255. blue:0xD1/255. alpha:0.8],
                            @(gcSwimStrokeOther): [UIColor colorWithRed:0x61/255. green:0xAF/255. blue:0xF3/255. alpha:0.8],
                            @(gcSwimStrokeMixed): [UIColor colorWithRed:0x61/255. green:0xAF/255. blue:0xF3/255. alpha:0.8]
                            },
                    kGCSkinKeyCategoryBackground:
                        @{
                            @"distance":   [UIColor colorWithHexValue:0x85E085 andAlpha:alp],
                            @"training":   [UIColor colorWithHexValue:0x5CE6B8 andAlpha:alp],
                            @"temperature":[UIColor colorWithHexValue:0xDBDBFF andAlpha:alp],
                            @"health":     [UIColor colorWithHexValue:0xCCCC00 andAlpha:alp],
                            @"other":      [UIColor colorWithHexValue:0x0033CC andAlpha:alp],
                            @"ignore":     [UIColor colorWithHexValue:0x000000 andAlpha:alp],
                            @"tennis":     [UIColor colorWithHexValue:0x99FF33 andAlpha:alp],
                            @"backhands":  [UIColor colorWithHexValue:0x33CCCC andAlpha:alp],
                            @"forehands":  [UIColor colorWithHexValue:0xFFCC99 andAlpha:alp],
                            @"serves":     [UIColor colorWithHexValue:0x66FF66 andAlpha:alp],
                            @"precision":  [UIColor colorWithHexValue:0xDCEEFF andAlpha:alp],

                            @"bike":       [UIColor colorWithHexValue:0xFFDADA andAlpha:alp],
                            @"swim":       [UIColor colorWithHexValue:0x80E6FF andAlpha:alp],
                            @"run":        [UIColor colorWithHexValue:0xDCEEFF andAlpha:alp],

                            @"duration":   [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:alp],
                            @"pace":       [UIColor colorWithRed:0.0 green:0. blue:1. alpha:alp],

                            @"heartrate":  [UIColor colorWithRed:1. green:0.0 blue:0.0 alpha:0.3],
                            @"cadence":    [UIColor colorWithRed:0.5 green:0.5 blue:0.2 alpha:0.3],
                            @"speed":      [UIColor colorWithRed:0.0 green:0. blue:1. alpha:0.3],
                            @"power":      [UIColor colorWithRed:190./255. green:240./255. blue:50./255. alpha:0.3],
                            @"elevation":  [UIColor colorWithRed:0.0 green:0.8 blue:0. alpha:0.3]
                            },
                    kgcSkinDefaultColors: @{
                            @(gcSkinDefaultColorGroupedTable): [UIColor colorWithHexValue:0xF6F3F1 andAlpha:1.],
                            @(gcSkinDefaultColorPrimaryText):[UIColor colorWithHexValue:0x000000 andAlpha:1.f],
                            @(gcSkinDefaultColorSecondaryText):[UIColor colorWithHexValue:0x555555 andAlpha:1.f],
                            @(gcSkinDefaultColorTertiaryText):[UIColor colorWithHexValue:0xAAAAAA andAlpha:1.f],
                            @(gcSkinDefaultColorHighlightedText):[UIColor colorWithHexValue:0x3583f3 andAlpha:1.f],
                            @(gcSkinDefaultColorBackground):[UIColor colorWithHexValue:0xFFFFFF andAlpha:1.f],
                            @(gcSkinDefaultColorBackgroundEven):[UIColor colorWithHexValue:0xE7EDF5 andAlpha:1.f],
                            @(gcSkinDefaultColorBackgroundOdd):[UIColor colorWithHexValue:0xF6F3F1 andAlpha:1.f],
                            
                            },
                    kGCSkinKeyGraphColor:
                        @{
                            @(gcSkinGraphColorBackground):[UIColor colorWithHexValue:0xFFFFFF andAlpha:1.f],
                            @(gcSkinGraphColorForeground):[UIColor colorWithHexValue:0x000000 andAlpha:1.f],
                            @(gcSkinGraphColorAxis):[UIColor blueColor],
                            @(gcSkinGraphColorLineGraph):[UIColor blackColor],
                            @(gcSkinGraphColorBarGraph): [UIColor colorWithHexValue:0x3583f3 andAlpha:0.8],
                            @(gcSkinGraphColorRegressionLine):[UIColor blueColor],
                            @(gcSkinGraphColorLapOverlay): [UIColor colorWithRed:0. green:0.11 blue:1. alpha:0.2],
                            @(gcSkinGraphColorRegressionLineSecondary):[UIColor redColor],
                            },

                    kGCSkinKeyActivityCellIconColor:
                        [UIColor whiteColor],
                    kGCSkinKeyMissingActivityTypeColor:
                        [UIColor colorWithHexValue:0xD2D2D2 andAlpha:1.],
                    kGCSkinKeyTextColorForActivity:
                        @{GC_TYPE_SWIMMING:[UIColor orangeColor],
                          GC_TYPE_RUNNING:[UIColor blueColor],
                          GC_TYPE_CYCLING:[UIColor redColor],
                          GC_TYPE_ALL:[UIColor blackColor],
                          GC_TYPE_OTHER:[UIColor darkGrayColor],
                          GC_TYPE_HIKING:   [UIColor colorWithHexValue:0xC8A26A andAlpha:1.],
                          GC_TYPE_FITNESS:  [UIColor colorWithHexValue:0xF169EF andAlpha:1.],
                          GC_TYPE_TENNIS:   [UIColor colorWithHexValue:0x96CC00 andAlpha:1.],
                          GC_TYPE_MULTISPORT:[UIColor colorWithHexValue:0xA6BB82 andAlpha:1.],
                          GC_TYPE_SKI_BACK: [UIColor colorWithHexValue:0xa2d7b5 andAlpha:1.0],
                          GC_TYPE_SKI_DOWN: [UIColor colorWithHexValue:0xbdc3c7 andAlpha:1.0]
                          },
                    

                    kGCSkinKeyActivityCellLighterBackgroundColor:
                        @{GC_TYPE_SWIMMING: [UIColor colorWithHexValue:0xFFE4A9 andAlpha:1.],
                          GC_TYPE_CYCLING:  [UIColor colorWithHexValue:0xFFDADA andAlpha:1.],
                          GC_TYPE_RUNNING:  [UIColor colorWithHexValue:0xDCEEFF andAlpha:1.],
                          GC_TYPE_HIKING:   [UIColor colorWithHexValue:0xE8C89E andAlpha:1.],
                          GC_TYPE_FITNESS:  [UIColor colorWithHexValue:0xCAA4E8 andAlpha:1.],
                          GC_TYPE_TENNIS:   [UIColor colorWithHexValue:0x22B5B0 andAlpha:1.],
                          GC_TYPE_MULTISPORT:[UIColor colorWithHexValue:0xA6BB82 andAlpha:1.],
                          GC_TYPE_OTHER:[UIColor colorWithHexValue:0xD2D2D2 andAlpha:1.],
                          GC_TYPE_SKI_BACK: [UIColor colorWithHexValue:0xa2d7b5 andAlpha:1.0],
                          GC_TYPE_SKI_DOWN: [UIColor colorWithHexValue:0xecf0f1 andAlpha:1.0]

                          },
                    kGCSkinKeyActivityCellDarkerBackgroundColor:
                        @{GC_TYPE_SWIMMING: [UIColor colorWithHexValue:0xFFD466 andAlpha:1.],
                          GC_TYPE_CYCLING:  [UIColor colorWithHexValue:0xFFA0A0 andAlpha:1.],
                          GC_TYPE_RUNNING:  [UIColor colorWithHexValue:0x98D3FF andAlpha:1.],
                          GC_TYPE_HIKING:   [UIColor colorWithHexValue:0xC8A26A andAlpha:1.],
                          GC_TYPE_FITNESS:  [UIColor colorWithHexValue:0xF169EF andAlpha:1.],
                          GC_TYPE_TENNIS:   [UIColor colorWithHexValue:0x96CC00 andAlpha:1.],
                          GC_TYPE_MULTISPORT:[UIColor colorWithHexValue:0xA6BB82 andAlpha:1.],
                          GC_TYPE_OTHER:[UIColor colorWithHexValue:0xA6BB82 andAlpha:1.],
                          GC_TYPE_SKI_BACK: [UIColor colorWithHexValue:0xa2d7b5 andAlpha:1.0],
                          GC_TYPE_SKI_DOWN: [UIColor colorWithHexValue:0xbdc3c7 andAlpha:1.0]
                          },
                    kGCSkinKeyFieldFillColor:
                        @{
                            @(gcFieldFlagWeightedMeanHeartRate): [UIColor colorWithRed:1. green:0.0 blue:0.0 alpha:0.3],
                            @(gcFieldFlagWeightedMeanSpeed): [UIColor colorWithRed:0.0 green:0. blue:1. alpha:0.3],
                            @(gcFieldFlagAltitudeMeters): [UIColor colorWithRed:0.0 green:0.8 blue:0. alpha:0.3],
                            @(gcFieldFlagGroundContactTime): [UIColor colorWithRed:75./255. green:75./255. blue:200./255. alpha:.3],
                            @(gcFieldFlagVerticalOscillation): [UIColor colorWithRed:75./255. green:75./255. blue:200./255. alpha:.3],
                            @(gcFieldFlagCadence): [UIColor colorWithRed:0.5 green:0.5 blue:0.2 alpha:0.3],
                            @(gcFieldFlagPower): [UIColor colorWithRed:190./255. green:240./255. blue:50./255. alpha:0.3],
                            @(gcFieldFlagNone): [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.3],
                            },
                    kGCSkinKeyFieldColors:
                        @{
                            @(gcFieldFlagWeightedMeanHeartRate): @[ [UIColor colorWithRed:1. green:0.0 blue:0.0 alpha:0.3],
                                                                    [UIColor colorWithRed:0.576 green:0.078 blue:0.094 alpha:0.80]
                                                                    ],
                            @(gcFieldFlagWeightedMeanSpeed): @[ [UIColor colorWithHexValue:0xDCEEFF andAlpha:0.7],
                                                                [UIColor colorWithRed:0.0 green:0. blue:1. alpha:0.9]
                                                                ],
                            @(gcFieldFlagPower): @[ [UIColor colorWithRed:0.796 green:0.933 blue:0.980 alpha:0.60],
                                                    [UIColor colorWithRed:0.031 green:0.263 blue:0.345 alpha:0.90] ],
                            @(gcFieldFlagNone): @[ [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.3],
                                                   [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.3]],


                            },
                    kGCSkinKeyGoalPercentBackgroundColor:
                        @[ @(0.),  [UIColor colorWithHexValue:0xFF6666 andAlpha:1.], // Red
                           @(0.5), [UIColor colorWithHexValue:0xFF9999 andAlpha:1.], // Bean Red
                           @(1.0), [UIColor colorWithHexValue:0xF5FFEB andAlpha:1.], // Bronze
                           @(1.5), [UIColor colorWithHexValue:0xE0FFC2 andAlpha:1.], // Silver
                           @(2.0), [UIColor colorWithHexValue:0xCCFF99 andAlpha:1.], // Bright Gold

                           ],
                    kGCSkinKeyGoalPercentTextColor:
                        @[ @(0.),  [UIColor colorWithHexValue:0xCC2900 andAlpha:1.], // Red
                           @(0.5), [UIColor colorWithHexValue:0xFF704D andAlpha:1.], // Bean Red
                           @(1.0), [UIColor colorWithHexValue:0x6B8E23 andAlpha:1.], // Bronze
                           @(1.5), [UIColor colorWithHexValue:0x228B22 andAlpha:1.], // Silver
                           @(2.0), [UIColor colorWithHexValue:0xB8860B andAlpha:1.], // Bright Gold

                           ],
                    kGCSkinKeyGraphColor:
                        [UIColor colorWithRed:0. green:0.11 blue:1. alpha:0.8],

                    kGCSkinKeyListOfColorsForMultiplots:
                        @[
                            [UIColor blackColor],
                            [UIColor blueColor],
                            [UIColor redColor],
                            [UIColor colorWithHexValue:0x000800 andAlpha:1.],
                            [UIColor darkGrayColor],
                            [UIColor orangeColor],
                            [UIColor purpleColor],
                            ],
                    kGCSkinKeyCalendarColors:
                        @{
                            @(gcSkinCalendarElementWeekdayTextColor):          [UIColor colorWithRed:0.3f green:0.3f blue:0.3f alpha:1.f],
                            @(gcSkinCalendarElementDayCurrentMonthTextColor):  [UIColor blackColor],
                            @(gcSkinCalendarElementDayAdjacentMonthTextColor): [UIColor darkGrayColor],
                            @(gcSkinCalendarElementDaySelectedTextColor):      [UIColor whiteColor],
                            @(gcSkinCalendarElementSeparatorColor):            [UIColor colorWithRed:0.63f green:0.65f blue:0.68f alpha:1.f],
                            @(gcSkinCalendarElementTileColor):                 [UIColor colorWithHexValue:0xEBEBEB andAlpha:1.f],
                            @(gcSkinCalendarElementTileSelectedColor):         [UIColor colorWithHexValue:0x1843c7 andAlpha:1.f],
                            @(gcSkinCalendarElementTileTodayColor):            [UIColor colorWithHexValue:0x7788a2 andAlpha:1.f],
                            @(gcSkinCalendarElementTileTodaySelectedColor):    [UIColor colorWithHexValue:0x3b7dde andAlpha:1.f]
                            
                            }
                    };
    }
    return rv;
}

/*
 Good dark colors
 [UIColor colorWithHexValue:0xa49ff1 andAlpha:1.0], // Blueish Character
 [UIColor colorWithHexValue:0xacd581 andAlpha:1.0], // greenish type name
 [UIColor colorWithHexValue:0xf082b1 andAlpha:1.0], // pinkish keyword
 [UIColor colorWithHexValue:0x818c96 andAlpha:1.0], // comments
 [UIColor colorWithHexValue:0xf4a45f andAlpha:1.0], // preprocessor
 [UIColor colorWithHexValue:0x9ba6b2 andAlpha:1.0], // doc markup light blueish
*/

+(GCViewConfigSkin*)darkSkin{
    GCViewConfigSkin * rv = [[[GCViewConfigSkin alloc]init]autorelease];
    if (rv) {
        rv.skinName = @"Dark";
        double alp = 0.4;
        
        rv.defs = @{
                    kGCSkinKeyBoolValues:
                        @{
                            @(gcSkinBoolRoundedActivityIcons): @(false)
                            
                            },

                    kGCSkinKeySwimStrokeColor:
                        @{
                            @(gcSwimStrokeFree): [UIColor colorWithRed:0xC4/255. green:0x3D/255. blue:0xBF/255. alpha:0.8],
                            @(gcSwimStrokeBack): [UIColor colorWithRed:0x1F/255. green:0x8E/255. blue:0xF0/255. alpha:0.8],
                            @(gcSwimStrokeBreast): [UIColor colorWithRed:0x95/255. green:0xDE/255. blue:0x2B/255. alpha:0.8],
                            @(gcSwimStrokeButterfly): [UIColor colorWithRed:0xD5/255. green:0x76/255. blue:0xD1/255. alpha:0.8],
                            @(gcSwimStrokeOther): [UIColor colorWithRed:0x61/255. green:0xAF/255. blue:0xF3/255. alpha:0.8],
                            @(gcSwimStrokeMixed): [UIColor colorWithRed:0x61/255. green:0xAF/255. blue:0xF3/255. alpha:0.8]
                            },
                    kGCSkinKeyCategoryBackground:
                        @{
                            @"distance":   [UIColor colorWithHexValue:0x85E085 andAlpha:alp],
                            @"training":   [UIColor colorWithHexValue:0x5CE6B8 andAlpha:alp],
                            @"temperature":[UIColor colorWithHexValue:0xDBDBFF andAlpha:alp],
                            @"health":     [UIColor colorWithHexValue:0xCCCC00 andAlpha:alp],
                            @"other":      [UIColor colorWithHexValue:0x0033CC andAlpha:alp],
                            @"ignore":     [UIColor colorWithHexValue:0x000000 andAlpha:alp],
                            @"tennis":     [UIColor colorWithHexValue:0x99FF33 andAlpha:alp],
                            @"backhands":  [UIColor colorWithHexValue:0x33CCCC andAlpha:alp],
                            @"forehands":  [UIColor colorWithHexValue:0xFFCC99 andAlpha:alp],
                            @"serves":     [UIColor colorWithHexValue:0x66FF66 andAlpha:alp],
                            @"precision":  [UIColor colorWithHexValue:0xDCEEFF andAlpha:alp],
                            
                            @"bike":       [UIColor colorWithHexValue:0xFFDADA andAlpha:alp],
                            @"swim":       [UIColor colorWithHexValue:0x80E6FF andAlpha:alp],
                            @"run":        [UIColor colorWithHexValue:0xDCEEFF andAlpha:alp],
                            
                            @"duration":   [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:alp],
                            @"pace":       [UIColor colorWithRed:0.0 green:0. blue:1. alpha:alp],
                            
                            @"heartrate":  [UIColor colorWithRed:1. green:0.0 blue:0.0 alpha:0.3],
                            @"cadence":    [UIColor colorWithRed:0.5 green:0.5 blue:0.2 alpha:0.3],
                            @"speed":      [UIColor colorWithRed:0.0 green:0. blue:1. alpha:0.3],
                            @"power":      [UIColor colorWithRed:190./255. green:240./255. blue:50./255. alpha:0.3],
                            @"elevation":  [UIColor colorWithRed:0.0 green:0.8 blue:0. alpha:0.3]
                            },
                    kgcSkinDefaultColors: @{
                            @(gcSkinDefaultColorGroupedTable): [UIColor colorWithHexValue:0xF6F3F1 andAlpha:1.],
                            @(gcSkinDefaultColorPrimaryText):[UIColor colorWithHexValue:0xFFFFFF andAlpha:1.f],
                            @(gcSkinDefaultColorSecondaryText):[UIColor colorWithHexValue:0xAAAAAA andAlpha:1.f],
                            @(gcSkinDefaultColorTertiaryText):[UIColor colorWithHexValue:0x555555 andAlpha:1.f],
                            @(gcSkinDefaultColorHighlightedText):[UIColor colorWithHexValue:0x3583f3 andAlpha:1.f], // blueish
                            @(gcSkinDefaultColorBackground):[UIColor colorWithHexValue:0x404145 andAlpha:1.f],
                            @(gcSkinDefaultColorBackgroundEven):[UIColor colorWithHexValue:0x313233 andAlpha:1.f],
                            @(gcSkinDefaultColorBackgroundOdd):[UIColor colorWithHexValue:0x212223 andAlpha:1.f],
                            },
                    kGCSkinKeyGraphColor:
                        @{
                            @(gcSkinGraphColorBackground):[UIColor colorWithHexValue:0x404145 andAlpha:1.f],
                            @(gcSkinGraphColorForeground):[UIColor colorWithHexValue:0xFFFFFF andAlpha:1.f],
                            @(gcSkinGraphColorAxis):[UIColor colorWithHexValue:0xAAAAAA andAlpha:1.0],
                            @(gcSkinGraphColorBarGraph): [UIColor colorWithHexValue:0x9ba6b2 andAlpha:0.8],
                            @(gcSkinGraphColorLineGraph):[UIColor colorWithHexValue:0xacd581 andAlpha:1.0],
                            @(gcSkinGraphColorRegressionLine):[UIColor colorWithHexValue:0xacd581 andAlpha:1.0], // greenish type name,
                            @(gcSkinGraphColorLapOverlay): [UIColor colorWithHexValue:0x9ba6b2 andAlpha:0.2],
                            @(gcSkinGraphColorRegressionLineSecondary): [UIColor colorWithHexValue:0x9ba6b2 andAlpha:1.0],
                            },

                    kGCSkinKeyActivityCellIconColor:
                        [UIColor colorWithHexValue:0x555555 andAlpha:1.f],
                    kGCSkinKeyMissingActivityTypeColor:
                        [UIColor colorWithHexValue:0xD2D2D2 andAlpha:1.],
                    kGCSkinKeyTextColorForActivity:
                        @{GC_TYPE_SWIMMING: [UIColor colorWithHexValue:0xFFD466 andAlpha:1.],
                          GC_TYPE_CYCLING:  [UIColor colorWithHexValue:0xFFA0A0 andAlpha:1.],
                          GC_TYPE_RUNNING:  [UIColor colorWithHexValue:0x98D3FF andAlpha:1.],
                          GC_TYPE_HIKING:   [UIColor colorWithHexValue:0xC8A26A andAlpha:1.],
                          GC_TYPE_FITNESS:  [UIColor colorWithHexValue:0xF169EF andAlpha:1.],
                          GC_TYPE_TENNIS:   [UIColor colorWithHexValue:0x96CC00 andAlpha:1.],
                          GC_TYPE_MULTISPORT:[UIColor colorWithHexValue:0xA6BB82 andAlpha:1.],
                          GC_TYPE_OTHER:[UIColor colorWithHexValue:0xA6BB82 andAlpha:1.],
                          GC_TYPE_SKI_BACK: [UIColor colorWithHexValue:0xa2d7b5 andAlpha:1.0],
                          GC_TYPE_ALL:[UIColor colorWithHexValue:0xFFFFFF andAlpha:1.f],
                          GC_TYPE_SKI_DOWN: [UIColor colorWithHexValue:0xbdc3c7 andAlpha:1.0]
                          },
                    kGCSkinKeyActivityCellLighterBackgroundColor:
                        @{GC_TYPE_SWIMMING: [UIColor colorWithHexValue:0x404145 andAlpha:1.],
                          GC_TYPE_CYCLING:  [UIColor colorWithHexValue:0x404145 andAlpha:1.],
                          GC_TYPE_RUNNING:  [UIColor colorWithHexValue:0x404145 andAlpha:1.],
                          GC_TYPE_HIKING:   [UIColor colorWithHexValue:0x404145 andAlpha:1.],
                          GC_TYPE_FITNESS:  [UIColor colorWithHexValue:0x404145 andAlpha:1.],
                          GC_TYPE_TENNIS:   [UIColor colorWithHexValue:0x404145 andAlpha:1.],
                          GC_TYPE_MULTISPORT:[UIColor colorWithHexValue:0x404145 andAlpha:1.],
                          GC_TYPE_OTHER:[UIColor colorWithHexValue:0x404145 andAlpha:1.],
                          GC_TYPE_SKI_BACK: [UIColor colorWithHexValue:0x404145 andAlpha:1.0],
                          GC_TYPE_SKI_DOWN: [UIColor colorWithHexValue:0x404145 andAlpha:1.0]
                          
                          },
                    
                    kGCSkinKeyActivityCellDarkerBackgroundColor:
                        @{GC_TYPE_SWIMMING: [UIColor colorWithHexValue:0xFFD466 andAlpha:1.],
                          GC_TYPE_CYCLING:  [UIColor colorWithHexValue:0xFFA0A0 andAlpha:1.],
                          GC_TYPE_RUNNING:  [UIColor colorWithHexValue:0x98D3FF andAlpha:1.],
                          GC_TYPE_HIKING:   [UIColor colorWithHexValue:0xC8A26A andAlpha:1.],
                          GC_TYPE_FITNESS:  [UIColor colorWithHexValue:0xF169EF andAlpha:1.],
                          GC_TYPE_TENNIS:   [UIColor colorWithHexValue:0x96CC00 andAlpha:1.],
                          GC_TYPE_MULTISPORT:[UIColor colorWithHexValue:0xA6BB82 andAlpha:1.],
                          GC_TYPE_OTHER:[UIColor colorWithHexValue:0xA6BB82 andAlpha:1.],
                          GC_TYPE_SKI_BACK: [UIColor colorWithHexValue:0xa2d7b5 andAlpha:1.0],
                          GC_TYPE_SKI_DOWN: [UIColor colorWithHexValue:0xbdc3c7 andAlpha:1.0]
                          },
                    kGCSkinKeyFieldFillColor:
                        @{
                            @(gcFieldFlagWeightedMeanHeartRate): [UIColor colorWithRed:1. green:0.0 blue:0.0 alpha:0.3],
                            @(gcFieldFlagWeightedMeanSpeed): [UIColor colorWithRed:0.0 green:0. blue:1. alpha:0.3],
                            @(gcFieldFlagAltitudeMeters): [UIColor colorWithRed:0.0 green:0.8 blue:0. alpha:0.3],
                            @(gcFieldFlagGroundContactTime): [UIColor colorWithRed:75./255. green:75./255. blue:200./255. alpha:.3],
                            @(gcFieldFlagVerticalOscillation): [UIColor colorWithRed:75./255. green:75./255. blue:200./255. alpha:.3],
                            @(gcFieldFlagCadence): [UIColor colorWithRed:0.5 green:0.5 blue:0.2 alpha:0.3],
                            @(gcFieldFlagPower): [UIColor colorWithRed:190./255. green:240./255. blue:50./255. alpha:0.3],
                            @(gcFieldFlagNone): [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.3],
                            },
                    kGCSkinKeyFieldColors:
                        @{
                            @(gcFieldFlagWeightedMeanHeartRate): @[ [UIColor colorWithRed:1. green:0.0 blue:0.0 alpha:0.3],
                                                                    [UIColor colorWithRed:0.576 green:0.078 blue:0.094 alpha:0.80]
                                                                    ],
                            @(gcFieldFlagWeightedMeanSpeed): @[ [UIColor colorWithHexValue:0xDCEEFF andAlpha:0.7],
                                                                [UIColor colorWithRed:0.0 green:0. blue:1. alpha:0.9]
                                                                ],
                            @(gcFieldFlagPower): @[ [UIColor colorWithRed:0.796 green:0.933 blue:0.980 alpha:0.60],
                                                    [UIColor colorWithRed:0.031 green:0.263 blue:0.345 alpha:0.90] ],
                            @(gcFieldFlagNone): @[ [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.3],
                                                   [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.3]],
                            
                            
                            },
                    kGCSkinKeyGoalPercentBackgroundColor:
                        @[ @(0.),  [UIColor colorWithHexValue:0xFF6666 andAlpha:1.], // Red
                           @(0.5), [UIColor colorWithHexValue:0xFF9999 andAlpha:1.], // Bean Red
                           @(1.0), [UIColor colorWithHexValue:0xF5FFEB andAlpha:1.], // Bronze
                           @(1.5), [UIColor colorWithHexValue:0xE0FFC2 andAlpha:1.], // Silver
                           @(2.0), [UIColor colorWithHexValue:0xCCFF99 andAlpha:1.], // Bright Gold
                           
                           ],
                    kGCSkinKeyGoalPercentTextColor:
                        @[ @(0.),  [UIColor colorWithHexValue:0xCC2900 andAlpha:1.], // Red
                           @(0.5), [UIColor colorWithHexValue:0xFF704D andAlpha:1.], // Bean Red
                           @(1.0), [UIColor colorWithHexValue:0x6B8E23 andAlpha:1.], // Bronze
                           @(1.5), [UIColor colorWithHexValue:0x228B22 andAlpha:1.], // Silver
                           @(2.0), [UIColor colorWithHexValue:0xB8860B andAlpha:1.], // Bright Gold
                           
                           ],
                    
                    kGCSkinKeyListOfColorsForMultiplots:
                        @[
                            [UIColor whiteColor],
                            [UIColor colorWithHexValue:0xf082b1 andAlpha:1.0],
                            [UIColor colorWithHexValue:0xa49ff1 andAlpha:1.0],
                            [UIColor colorWithHexValue:0xacd581 andAlpha:1.0],
                            [UIColor colorWithHexValue:0x818c96 andAlpha:1.0],
                            [UIColor colorWithHexValue:0xf4a45f andAlpha:1.0],
                            [UIColor colorWithHexValue:0x9ba6b2 andAlpha:1.0],
                            ],
                    kGCSkinKeyCalendarColors:
                        @{
                            @(gcSkinCalendarElementWeekdayTextColor):          [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1.f],
                            @(gcSkinCalendarElementDayCurrentMonthTextColor):  [UIColor whiteColor],
                            @(gcSkinCalendarElementDayAdjacentMonthTextColor): [UIColor darkGrayColor],
                            @(gcSkinCalendarElementDaySelectedTextColor):      [UIColor blackColor],
                            @(gcSkinCalendarElementSeparatorColor):            [UIColor colorWithRed:0.63f green:0.65f blue:0.68f alpha:1.f],
                            @(gcSkinCalendarElementTileColor):                 [UIColor colorWithHexValue:0x292a30 andAlpha:1.f],
                            @(gcSkinCalendarElementTileSelectedColor):         [UIColor colorWithHexValue:0xF2F3F1 andAlpha:1.f],
                            @(gcSkinCalendarElementTileTodayColor):            [UIColor colorWithHexValue:0x7788a2 andAlpha:1.f],
                            @(gcSkinCalendarElementTileTodaySelectedColor):    [UIColor colorWithHexValue:0x3b7dde andAlpha:1.f]
                            
                            }
                    };
    }
    return rv;
}


+(NSArray*)dynamicMergeLightArray:(NSArray*)lightArray andDarkArray:(NSArray*)darkArray forKey:(NSObject<NSCopying>*)skinKey{
    NSMutableArray * rv = [NSMutableArray array];
    
    for( NSUInteger i=0;i<lightArray.count;i++){
        id lightVal = lightArray[i];
        
        if( i < darkArray.count){
            id darkVal = darkArray[i];
            
            id res = [self dynamicBuildFromLightObj:lightVal andDarkObj:darkVal forKey:skinKey];
            if( res ){
                [rv addObject:res];
            }else{
                RZLog( RZLogInfo, @"Inconsistency for dynamic merge %@: [%@] = %@!=%@", skinKey, @(i), lightVal, darkVal);
            }
        }
    }
    return rv;
}
+(NSDictionary*)dynamicMergeLightDict:(NSDictionary*)lightDict andDarkDict:(NSDictionary*)darkDict forKey:(NSObject<NSCopying>*)skinKey{
    NSMutableDictionary * rv = [NSMutableDictionary dictionary];
    
    for( NSObject<NSCopying>*key in lightDict){
        id lightVal = lightDict[key];
        id darkVal = darkDict[key];
        
        id res = [self dynamicBuildFromLightObj:lightVal andDarkObj:darkVal forKey:skinKey?:key];
        if( res ){
            rv[key] = res;
        }else{
            RZLog( RZLogInfo, @"Inconsistency for %@: [%@] = %@!=%@", skinKey, key, lightVal, darkVal);
            rv[key] = lightVal;
        }
    }
    for( NSObject<NSCopying>*key in darkDict){
        if( lightDict[key]==nil){
            RZLog( RZLogInfo, @"Inconsistency for %@: [%@] = nil!=%@", skinKey, key, darkDict[key]);
        }
    }
    return rv;
}

+(NSDictionary*)dynamicColorForLight:(UIColor*)lightColor andDark:(UIColor*)darkColor{
    //If iOS13: Dynamic color

    return
    @{ @"colors": @[
               @{
                   @"idiom": @"universal",
                   @"color": [lightColor rgbComponentColorSetJsonFormat]
               },
               @{
                   @"idiom": @"universal",
                   @"appearances": @[
                                   @{
                                       @"appearance": @"luminosity",
                                       @"value": @"dark"
                                   }
                                   ],
                   @"color": [darkColor rgbComponentColorSetJsonFormat]
               }
               ]
      
      };
}

+(id)dynamicBuildFromLightObj:(id)lightObj andDarkObj:(id)darkObj forKey:(NSObject<NSCopying>*)skinKey{
    if( [lightObj isKindOfClass:[NSDictionary class]] && [darkObj isKindOfClass:[NSDictionary class]]){
        NSDictionary * lightDict = (NSDictionary *)lightObj;
        NSDictionary * darkDict = (NSDictionary *)darkObj;
        
        return [self dynamicMergeLightDict:lightDict andDarkDict:darkDict forKey:skinKey];
    }else if( [lightObj isKindOfClass:[NSArray class]] && [darkObj isKindOfClass:[NSArray class]] ){
        NSArray * lightArray = (NSArray*)lightObj;
        NSArray * darkArray = (NSArray*)darkObj;
        
        return [self dynamicMergeLightArray:lightArray andDarkArray:darkArray forKey:skinKey];
    }else if ([lightObj isKindOfClass:[UIColor class]] && [darkObj isKindOfClass:[UIColor class]]){
        UIColor * lightColor = (UIColor*)lightObj;
        UIColor * darkColor = (UIColor*)darkObj;
        
        return [self dynamicColorForLight:lightColor andDark:darkColor];
    }else if ([lightObj isKindOfClass:[NSNumber class]] && [darkObj isKindOfClass:[NSNumber class]]){
        return @{ @"light": lightObj, @"dark": darkObj };
    }else{
        RZLog(RZLogError, @"Don't know how to process [%@] : %@ and %@", skinKey, lightObj, darkObj);
        return nil;
    }
}

+(GCViewConfigSkin*)dynamicSkinFromLight:(GCViewConfigSkin*)light andDark:(GCViewConfigSkin*)dark{
    GCViewConfigSkin * rv = [[[GCViewConfigSkin alloc]init]autorelease];
    if (rv) {
        rv.skinName = @"Dynamic";
        rv.defs = [self dynamicBuildFromLightObj:light.defs andDarkObj:dark.defs forKey:nil];
    }
    
    return rv;
}

+(UIColor*)colorForTheme:(NSString*)theme path:(NSArray*)path{
    NSString * name = [NSString stringWithFormat:@"%@-%@", theme, [path componentsJoinedByString:@"-"]];
    UIColor * rv = [UIColor colorNamed:name];
    return rv;
}

+(GCViewConfigSkin*)skinForThemeName:(NSString*)theme{
    GCViewConfigSkin * rv = [[[GCViewConfigSkin alloc]init]autorelease];
    if (rv) {
        double alp = 0.4;
        rv.skinName = theme;
        rv.defs = @{
                    kGCSkinKeyBoolValues:
                        @{
                            @(gcSkinBoolRoundedActivityIcons): @(true)
                            
                            },

                    kgcSkinDefaultColors: @{
                            @(gcSkinDefaultColorGroupedTable): [GCViewConfigSkin colorForTheme:theme path:@[ @"groupedtable" ]],
                            @(gcSkinDefaultColorPrimaryText):[GCViewConfigSkin colorForTheme:theme path:@[ @"primarytext" ]],
                            @(gcSkinDefaultColorSecondaryText):[GCViewConfigSkin colorForTheme:theme path:@[ @"secondarytext" ]],
                            @(gcSkinDefaultColorTertiaryText):[GCViewConfigSkin colorForTheme:theme path:@[ @"tertiarytext" ]],
                            @(gcSkinDefaultColorHighlightedText):[GCViewConfigSkin colorForTheme:theme path:@[ @"highlightedtext" ]],
                            @(gcSkinDefaultColorBackground):[GCViewConfigSkin colorForTheme:theme path:@[ @"background" ]],
                            @(gcSkinDefaultColorBackgroundEven):[GCViewConfigSkin colorForTheme:theme path:@[ @"backgroundodd" ]],
                            @(gcSkinDefaultColorBackgroundEven):[GCViewConfigSkin colorForTheme:theme path:@[ @"backgroundeven" ]]
                            },

                    kGCSkinKeySwimStrokeColor:
                        @{
                            @(gcSwimStrokeFree):        [GCViewConfigSkin colorForTheme:theme path:@[ kGCSkinKeySwimStrokeColor, @"gcSwimStrokeFree"]],
                            @(gcSwimStrokeBack):        [GCViewConfigSkin colorForTheme:theme path:@[ kGCSkinKeySwimStrokeColor, @"gcSwimStrokeBack"]],
                            @(gcSwimStrokeBreast):      [GCViewConfigSkin colorForTheme:theme path:@[ kGCSkinKeySwimStrokeColor, @"gcSwimStrokeBreast"]],
                            @(gcSwimStrokeButterfly):   [GCViewConfigSkin colorForTheme:theme path:@[ kGCSkinKeySwimStrokeColor, @"gcSwimStrokeButterfly"]],
                            @(gcSwimStrokeOther):       [GCViewConfigSkin colorForTheme:theme path:@[ kGCSkinKeySwimStrokeColor, @"gcSwimStrokeOther"]],
                            @(gcSwimStrokeMixed):       [GCViewConfigSkin colorForTheme:theme path:@[ kGCSkinKeySwimStrokeColor, @"gcSwimStrokeMixed"]],
                            },
                    kGCSkinKeyCategoryBackground:
                        @{
                            //@"distance":    [GCViewConfigSkin colorForTheme:theme path:@[ kGCSkinKeyCategoryBackground, @"distance"] ],
                            @"distance":   [UIColor colorWithHexValue:0x85E085 andAlpha:alp],
                            @"training":   [UIColor colorWithHexValue:0x5CE6B8 andAlpha:alp],
                            @"temperature":[UIColor colorWithHexValue:0xDBDBFF andAlpha:alp],
                            @"health":     [UIColor colorWithHexValue:0xCCCC00 andAlpha:alp],
                            @"other":      [UIColor colorWithHexValue:0x0033CC andAlpha:alp],
                            @"ignore":     [UIColor colorWithHexValue:0x000000 andAlpha:alp],
                            @"tennis":     [UIColor colorWithHexValue:0x99FF33 andAlpha:alp],
                            @"backhands":  [UIColor colorWithHexValue:0x33CCCC andAlpha:alp],
                            @"forehands":  [UIColor colorWithHexValue:0xFFCC99 andAlpha:alp],
                            @"serves":     [UIColor colorWithHexValue:0x66FF66 andAlpha:alp],
                            @"precision":  [UIColor colorWithHexValue:0xDCEEFF andAlpha:alp],
                            
                            @"bike":       [UIColor colorWithHexValue:0xFFDADA andAlpha:alp],
                            @"swim":       [UIColor colorWithHexValue:0x80E6FF andAlpha:alp],
                            @"run":        [UIColor colorWithHexValue:0xDCEEFF andAlpha:alp],
                            
                            @"duration":   [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:alp],
                            @"pace":       [UIColor colorWithRed:0.0 green:0. blue:1. alpha:alp],
                            
                            @"heartrate":  [UIColor colorWithRed:1. green:0.0 blue:0.0 alpha:0.3],
                            @"cadence":    [UIColor colorWithRed:0.5 green:0.5 blue:0.2 alpha:0.3],
                            @"speed":      [UIColor colorWithRed:0.0 green:0. blue:1. alpha:0.3],
                            @"power":      [UIColor colorWithRed:190./255. green:240./255. blue:50./255. alpha:0.3],
                            @"elevation":  [UIColor colorWithRed:0.0 green:0.8 blue:0. alpha:0.3]
                            },
                    kGCSkinKeyGraphColor:
                        @{
                            @(gcSkinGraphColorBackground):[UIColor colorWithHexValue:0x404145 andAlpha:1.f],
                            @(gcSkinGraphColorForeground):[UIColor colorWithHexValue:0x000000 andAlpha:1.f],
                            @(gcSkinGraphColorAxis):[UIColor blueColor],
                            @(gcSkinGraphColorBarGraph): [UIColor colorWithHexValue:0x3583f3 andAlpha:0.8],
                            @(gcSkinGraphColorRegressionLine):[UIColor blueColor],
                            @(gcSkinGraphColorRegressionLineSecondary):[UIColor redColor],
                            },

                    kGCSkinKeyActivityCellIconColor:
                        [UIColor whiteColor],
                    kGCSkinKeyMissingActivityTypeColor:
                        [UIColor colorWithHexValue:0xD2D2D2 andAlpha:1.],
                    kGCSkinKeyTextColorForActivity:
                        @{GC_TYPE_SWIMMING:[UIColor colorWithHexValue:0xFF7F00 andAlpha:1.], // orange
                          GC_TYPE_RUNNING:[UIColor colorWithHexValue:0x0000FF andAlpha:1.],    //blue
                          GC_TYPE_CYCLING:[UIColor colorWithHexValue:0xFF0000 andAlpha:1.],     //red
                          GC_TYPE_ALL:[UIColor colorWithHexValue:0x000000 andAlpha:1.],       //black
                          GC_TYPE_OTHER:[UIColor colorWithHexValue:0x555555 andAlpha:1.],  //darkGray
                          },
                    kGCSkinKeyActivityCellLighterBackgroundColor:
                        @{GC_TYPE_SWIMMING: [GCViewConfigSkin colorForTheme:theme path:@[kGCSkinKeyActivityCellLighterBackgroundColor, GC_TYPE_SWIMMING]],
                          GC_TYPE_CYCLING:  [GCViewConfigSkin colorForTheme:theme path:@[kGCSkinKeyActivityCellLighterBackgroundColor, GC_TYPE_CYCLING]],
                          GC_TYPE_RUNNING:  [GCViewConfigSkin colorForTheme:theme path:@[kGCSkinKeyActivityCellLighterBackgroundColor, GC_TYPE_RUNNING]],
                          GC_TYPE_HIKING:   [GCViewConfigSkin colorForTheme:theme path:@[kGCSkinKeyActivityCellLighterBackgroundColor, GC_TYPE_HIKING]],
                          GC_TYPE_FITNESS:  [GCViewConfigSkin colorForTheme:theme path:@[kGCSkinKeyActivityCellLighterBackgroundColor, GC_TYPE_FITNESS]],
                          GC_TYPE_TENNIS:   [GCViewConfigSkin colorForTheme:theme path:@[kGCSkinKeyActivityCellLighterBackgroundColor, GC_TYPE_TENNIS]],
                          GC_TYPE_MULTISPORT:[GCViewConfigSkin colorForTheme:theme path:@[kGCSkinKeyActivityCellLighterBackgroundColor, GC_TYPE_MULTISPORT]],
                          GC_TYPE_OTHER:    [GCViewConfigSkin colorForTheme:theme path:@[kGCSkinKeyActivityCellLighterBackgroundColor, GC_TYPE_OTHER]],
                          GC_TYPE_SKI_BACK: [GCViewConfigSkin colorForTheme:theme path:@[kGCSkinKeyActivityCellLighterBackgroundColor, GC_TYPE_SKI_BACK]],
                          GC_TYPE_SKI_DOWN: [GCViewConfigSkin colorForTheme:theme path:@[kGCSkinKeyActivityCellLighterBackgroundColor, GC_TYPE_SKI_DOWN]],

                          },
                    kGCSkinKeyActivityCellDarkerBackgroundColor:
                        @{GC_TYPE_SWIMMING: [GCViewConfigSkin colorForTheme:theme path:@[kGCSkinKeyActivityCellDarkerBackgroundColor, GC_TYPE_SWIMMING]],
                          GC_TYPE_CYCLING:  [GCViewConfigSkin colorForTheme:theme path:@[kGCSkinKeyActivityCellDarkerBackgroundColor, GC_TYPE_CYCLING]],
                          GC_TYPE_RUNNING:  [GCViewConfigSkin colorForTheme:theme path:@[kGCSkinKeyActivityCellDarkerBackgroundColor, GC_TYPE_RUNNING]],
                          GC_TYPE_HIKING:   [GCViewConfigSkin colorForTheme:theme path:@[kGCSkinKeyActivityCellDarkerBackgroundColor, GC_TYPE_HIKING]],
                          GC_TYPE_FITNESS:  [GCViewConfigSkin colorForTheme:theme path:@[kGCSkinKeyActivityCellDarkerBackgroundColor, GC_TYPE_FITNESS]],
                          GC_TYPE_TENNIS:   [GCViewConfigSkin colorForTheme:theme path:@[kGCSkinKeyActivityCellDarkerBackgroundColor, GC_TYPE_TENNIS]],
                          GC_TYPE_MULTISPORT:[GCViewConfigSkin colorForTheme:theme path:@[kGCSkinKeyActivityCellDarkerBackgroundColor, GC_TYPE_MULTISPORT]],
                          GC_TYPE_OTHER:    [GCViewConfigSkin colorForTheme:theme path:@[kGCSkinKeyActivityCellDarkerBackgroundColor, GC_TYPE_OTHER]],
                          GC_TYPE_SKI_BACK: [GCViewConfigSkin colorForTheme:theme path:@[kGCSkinKeyActivityCellDarkerBackgroundColor, GC_TYPE_SKI_BACK]],
                          GC_TYPE_SKI_DOWN: [GCViewConfigSkin colorForTheme:theme path:@[kGCSkinKeyActivityCellDarkerBackgroundColor, GC_TYPE_SKI_DOWN]],
                          },
                    kGCSkinKeyFieldFillColor:
                        @{
                            @(gcFieldFlagWeightedMeanHeartRate): [UIColor colorWithRed:1. green:0.0 blue:0.0 alpha:0.3],
                            @(gcFieldFlagWeightedMeanSpeed): [UIColor colorWithRed:0.0 green:0. blue:1. alpha:0.3],
                            @(gcFieldFlagAltitudeMeters): [UIColor colorWithRed:0.0 green:0.8 blue:0. alpha:0.3],
                            @(gcFieldFlagGroundContactTime): [UIColor colorWithRed:75./255. green:75./255. blue:200./255. alpha:.3],
                            @(gcFieldFlagVerticalOscillation): [UIColor colorWithRed:75./255. green:75./255. blue:200./255. alpha:.3],
                            @(gcFieldFlagCadence): [UIColor colorWithRed:0.5 green:0.5 blue:0.2 alpha:0.3],
                            @(gcFieldFlagPower): [UIColor colorWithRed:190./255. green:240./255. blue:50./255. alpha:0.3],
                            @(gcFieldFlagNone): [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.3],
                            },
                    kGCSkinKeyFieldColors:
                        @{
                            @(gcFieldFlagWeightedMeanHeartRate): @[ [UIColor colorWithRed:1. green:0.0 blue:0.0 alpha:0.3],
                                                                    [UIColor colorWithRed:0.576 green:0.078 blue:0.094 alpha:0.80]
                                                                    ],
                            @(gcFieldFlagWeightedMeanSpeed): @[ [UIColor colorWithHexValue:0xDCEEFF andAlpha:0.7],
                                                                [UIColor colorWithRed:0.0 green:0. blue:1. alpha:0.9]
                                                                ],
                            @(gcFieldFlagPower): @[ [UIColor colorWithRed:0.796 green:0.933 blue:0.980 alpha:0.60],
                                                    [UIColor colorWithRed:0.031 green:0.263 blue:0.345 alpha:0.90] ],
                            @(gcFieldFlagNone): @[ [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.3],
                                                   [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.3]],
                            
                            
                            },
                    kGCSkinKeyGoalPercentBackgroundColor:
                        @[ @(0.),  [UIColor colorWithHexValue:0xFF6666 andAlpha:1.], // Red
                           @(0.5), [UIColor colorWithHexValue:0xFF9999 andAlpha:1.], // Bean Red
                           @(1.0), [UIColor colorWithHexValue:0xF5FFEB andAlpha:1.], // Bronze
                           @(1.5), [UIColor colorWithHexValue:0xE0FFC2 andAlpha:1.], // Silver
                           @(2.0), [UIColor colorWithHexValue:0xCCFF99 andAlpha:1.], // Bright Gold
                           
                           ],
                    kGCSkinKeyGoalPercentTextColor:
                        @[ @(0.),  [UIColor colorWithHexValue:0xCC2900 andAlpha:1.], // Red
                           @(0.5), [UIColor colorWithHexValue:0xFF704D andAlpha:1.], // Bean Red
                           @(1.0), [UIColor colorWithHexValue:0x6B8E23 andAlpha:1.], // Bronze
                           @(1.5), [UIColor colorWithHexValue:0x228B22 andAlpha:1.], // Silver
                           @(2.0), [UIColor colorWithHexValue:0xB8860B andAlpha:1.], // Bright Gold
                           
                           ],
                    kGCSkinKeyGraphColor:
                        [UIColor colorWithRed:0. green:0.11 blue:1. alpha:0.8],
                    
                    kGCSkinKeyListOfColorsForMultiplots:
                        @[
                            [UIColor blackColor],
                            [UIColor blueColor],
                            [UIColor redColor],
                            [UIColor colorWithHexValue:0x000800 andAlpha:1.],
                            [UIColor darkGrayColor],
                            [UIColor orangeColor]
                            ],
                    
                    kGCSkinKeyCalendarColors:
                        @{
                            @(gcSkinCalendarElementWeekdayTextColor): [GCViewConfigSkin colorForTheme:theme path:@[kGCSkinKeyCalendarColors,@(gcSkinCalendarElementWeekdayTextColor)]],
                            @(gcSkinCalendarElementDayCurrentMonthTextColor): [GCViewConfigSkin colorForTheme:theme path:@[kGCSkinKeyCalendarColors,@(gcSkinCalendarElementDayCurrentMonthTextColor)]],
                            @(gcSkinCalendarElementDayAdjacentMonthTextColor): [GCViewConfigSkin colorForTheme:theme path:@[kGCSkinKeyCalendarColors,@(gcSkinCalendarElementDayAdjacentMonthTextColor)]],
                            @(gcSkinCalendarElementDaySelectedTextColor): [GCViewConfigSkin colorForTheme:theme path:@[kGCSkinKeyCalendarColors,@(gcSkinCalendarElementDaySelectedTextColor)]],
                            @(gcSkinCalendarElementSeparatorColor): [GCViewConfigSkin colorForTheme:theme path:@[kGCSkinKeyCalendarColors,@(gcSkinCalendarElementSeparatorColor)]],
                            @(gcSkinCalendarElementTileColor): [GCViewConfigSkin colorForTheme:theme path:@[kGCSkinKeyCalendarColors,@(gcSkinCalendarElementTileColor)]],
                            @(gcSkinCalendarElementTileSelectedColor): [GCViewConfigSkin colorForTheme:theme path:@[kGCSkinKeyCalendarColors,@(gcSkinCalendarElementTileSelectedColor)]],
                            @(gcSkinCalendarElementTileTodayColor): [GCViewConfigSkin colorForTheme:theme path:@[kGCSkinKeyCalendarColors,@(gcSkinCalendarElementTileTodayColor)]],
                            @(gcSkinCalendarElementTileTodaySelectedColor): [GCViewConfigSkin colorForTheme:theme path:@[kGCSkinKeyCalendarColors,@(gcSkinCalendarElementTileTodaySelectedColor)]],

                            }
                    };
    }
    return rv;
}


-(BOOL)boolFor:(gcSkinBool)which{
    NSNumber * val = self.defs[kGCSkinKeyBoolValues][@(which)];
    if( val ){
        return val.boolValue;
    }else{
        return false;
    }
}
-(UIColor*)colorForKey:(NSString*)key{
    return gcColorForDefinitionValue(self.defs[key]);
}
-(NSArray*)colorArrayForKey:(NSString*)key{
    return gcArrayForDefinitionValue(self.defs[key]);
}

-(UIColor*)colorForKey:(NSString *)key andActivity:(id)aAct{
    NSDictionary * dict = self.defs[key];
    UIColor * rv = nil;
    if (dict) {
        GCActivity * activity = [aAct isKindOfClass:[GCActivity class]] ? (GCActivity*)aAct :  nil;

        if (activity) {
            rv = activity.activityTypeDetail.key ? dict[activity.activityTypeDetail.key] : nil;
            if (!rv) {
                rv = dict[ activity.activityType];
            }
        }
        else{
            rv = aAct ? dict[aAct] : nil;
        }
        if (!rv) {
            rv = dict[GC_TYPE_OTHER];
        }

        if (!rv) {
            rv = [self colorForKey:kGCSkinKeyMissingActivityTypeColor];
        }
    }

    return gcColorForDefinitionValue(rv);

}

-(UIColor*)colorForKey:(NSString *)key andSubkey:(id)subkey{
    NSDictionary * dict = self.defs[key];
    UIColor * rv = nil;

    if (dict) {
        id def = dict[subkey];
        if (def) {
            rv = gcColorForDefinitionValue(def);
        }
    }
    return rv;

}

-(UIColor*)colorForKey:(NSString*)key andValue:(double)val{
    NSArray * steps = self.defs[key];
    UIColor * rv = nil;
    if ([steps isKindOfClass:[NSArray class]] && steps.count > 1) {
        rv = steps[1]; // start with first color
        for( NSUInteger i=0; i<steps.count; i+=2) {
            NSNumber * threshold = steps[i];
            if ([threshold isKindOfClass:[NSNumber class]]) {
                if (val < threshold.doubleValue) {
                    break;
                }
                rv = steps[i+1];
            }
        }
    }

    return rv;
}


-(NSArray*)colorArrayForKey:(NSString *)key andField:(GCField*)field{
    NSDictionary * dict = self.defs[key];
    NSArray * rv = nil;

    if (dict) {
        id def = nil;
        if (field.fieldFlag != gcFieldFlagNone) {
            def = dict[@(field.fieldFlag)];
        }
        if (def == nil) {
            def = dict[ field.key];
        }
        if (def == nil) {
            def = dict[@(gcFieldFlagNone)];
        }
        rv = gcArrayForDefinitionValue(def);
    }
    return rv;

}
-(UIColor*)colorForKey:(NSString *)key andField:(GCField*)field{
    NSDictionary * dict = self.defs[key];
    UIColor * rv = nil;

    if (dict) {
        id def = nil;
        if (field.fieldFlag != gcFieldFlagNone) {
            def = dict[@(field.fieldFlag)];
        }
        if (def == nil) {
            def = dict[ field.key];
        }
        if (def == nil) {
            def = dict[@(gcFieldFlagNone)];
        }
        rv = gcColorForDefinitionValue(def);
    }
    return rv;
}


@end
