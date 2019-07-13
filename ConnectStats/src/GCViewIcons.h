//  MIT Licence
//
//  Created on 25/07/2013.
//
//  Copyright (c) 2013 Brice Rosenzweig.
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
#import "GCFields.h"

typedef NS_ENUM(NSUInteger, gcIconTab){
    gcIconTabCalendar,
    gcIconTabMap,
    gcIconTabStats,
    gcIconTabSettings,
    gcIconTabList,
    gcIconTabStatsIPad,
    gcIconTabDay,
    gcIconTabEnd
};

typedef NS_ENUM(NSUInteger, gcIconNav) {
    gcIconNavMarker,
    gcIconNavTags,
    gcIconNavEye,
    gcIconNavAction,
    gcIconNavRedo,
    gcIconNavSliders, // config sliders
    gcIconNavBack,
    gcIconNavForward,
    gcIconNavGear,
    gcIconNavCalendar,
    gcIconNavFullScreen,
    gcIconNavSplitScreen,
    gcIconNavGlobe,
    gcIconNavDetails,
    gcIconNavAggregated,
    gcIconNavWeekly,
    gcIconNavMonthly,
    gcIconNavQuarterly,
    gcIconNavSemiAnnually,
    gcIconNavYearly,
    gcIconNavFilter,
    gcIconNavFilterSelected,

    gcIconNavEnd
};

typedef NS_ENUM(NSUInteger, gcIconCell) {
    gcIconCellLineChart,
    gcIconCellCheckmark,
    gcIconCellRoundedPlus,
    gcIconCellCheckbox,
    gcIconCellCloudDownload,
    gcIconCellEnd
};

@interface GCViewIcons : NSObject

+(UIImage*)navigationIconFor:(gcIconNav)name;
+(UIImage*)tabBarIconFor:(gcIconTab)name;
+(UIImage*)activityTypeColoredIconFor:(NSString*)activityType;
+(UIImage*)cellIconFor:(gcIconCell)name;
+(UIImage*)activityTypeBWIconFor:(NSString*)activityType;
+(UIImageView*)activityTypeDynamicIconFor:(NSString*)activityType;
+(UIImage*)categoryIconFor:(NSString*)category;
@end
