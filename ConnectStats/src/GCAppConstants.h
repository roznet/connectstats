//  MIT Licence
//
//  Created on 14/10/2012.
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

#define GC_USE_FLURRY

// Add new to [GCSettingsBugReportViewController configCheck]?
extern NSString * const  CONFIG_REFRESH_STARTUP;
extern NSString * const  CONFIG_FILTER_BAD_VALUES;
extern NSString * const  CONFIG_FILTER_ADJUST_FOR_LAP;
extern NSString * const  CONFIG_FILTER_SPEED_BELOW;
extern NSString * const  CONFIG_FILTER_BAD_ACCEL;
extern NSString * const  CONFIG_FILTER_POWER_ABOVE;
extern NSString * const  CONFIG_LAST_LATITUDE;
extern NSString * const  CONFIG_LAST_LONGITUDE;
extern NSString * const  CONFIG_LAST_LOC_TIME;
extern NSString * const  CONFIG_LAST_USED_VERSION;
extern NSString * const  CONFIG_CURRENT_PROFILE;
extern NSString * const  CONFIG_PROFILES;
extern NSString * const  CONFIG_UNIT_SYSTEM;
extern NSString * const  CONFIG_STRIDE_STYLE;
extern NSString * const  CONFIG_FIRST_DAY_WEEK;
extern NSString * const  CONFIG_SHARING_ADD_GE_LINK;
extern NSString * const  CONFIG_SHARING_ADD_GC_LINK;
extern NSString * const  CONFIG_SHARING_ADD_SNAPSHOT;
extern NSString * const  CONFIG_SHARING_ADD_CSV;
extern NSString * const  CONFIG_CONTINUE_ON_ERROR;
extern NSString * const  CONFIG_BUG_COMMON_ID;
extern NSString * const  CONFIG_USE_MOVING_ELAPSED;
extern NSString * const  CONFIG_USE_MAP;
extern NSString * const  CONFIG_BUG_INCLUDE_DATA;
extern NSString * const  CONFIG_USE_NEW_TRACK_API;
extern NSString * const  CONFIG_FASTER_MAPS;
extern NSString * const  CONFIG_CRITICAL_CALC_UNIT;
extern NSString * const  CONFIG_REFERENCE_DATE;
extern NSString * const  CONFIG_PERIOD_TYPE;
extern NSString * const  CONFIG_TODATE_LAST_ACTIVITY;
extern NSString * const  CONFIG_STATS_INLINE_GRAPHS;
extern NSString * const  CONFIG_MAPS_INLINE_GRADIENT;
extern NSString * const  CONFIG_GRAPH_LAP_OVERLAY;
extern NSString * const  CONFIG_STEPS_GOAL_DEFAULT;
extern NSString * const  CONFIG_ENABLE_DERIVED;
extern NSString * const  CONFIG_FONT_STYLE;
extern NSString * const  CONFIG_SHOW_DOWNLOAD_ICON;
extern NSString * const  CONFIG_QUICK_FILTER;
extern NSString * const  CONFIG_QUICK_FILTER_TYPE;
extern NSString * const  CONFIG_MAIN_ACTIVITY_TYPE_ONLY;
extern NSString * const  CONFIG_POWER_CURVE_LOG_SCALE;
extern NSString * const  CONFIG_LANGUAGE_SETTING;
extern NSString * const  CONFIG_ZONE_GRAPH_HORIZONTAL;
extern NSString * const  CONFIG_ZONE_PREFERRED_SOURCE;
extern NSString * const  CONFIG_WIFI_DOWNLOAD_DETAILS;
extern NSString * const  CONFIG_SKIN_NAME;
extern NSString * const  CONFIG_SHOW_PHOTOS;
extern NSString * const  CONFIG_VERSIONS_SEEN;
extern NSString * const  CONFIG_VERSIONS_USES;
extern NSString * const  CONFIG_FEATURES_SEEN;
extern NSString * const  CONFIG_CELL_EXTENDED_DISPLAY;
extern NSString * const  CONFIG_LAST_REMOTE_STATUS_ID;
extern NSString * const  CONFIG_ENABLE_REMOTE_STATUS;
extern NSString * const  CONFIG_DUPLICATE_CHECK_ON_IMPORT;
extern NSString * const  CONFIG_DUPLICATE_CHECK_ON_LOAD;
extern NSString * const  CONFIG_ENABLE_SPEED_CALC_FIELDS;

extern NSString * const  CONFIG_DUPLICATE_SKIP_ON_IMPORT_OBSOLETE;

extern NSString * const  CONFIG_CONNECTSTATS_ENABLE;
extern NSString * const  CONFIG_CONNECTSTATS_USE;
extern NSString * const  CONFIG_CONNECTSTATS_FILLYEAR;
extern NSString * const  CONFIG_CONNECTSTATS_CONFIG;
extern NSString * const  CONFIG_GARMIN_ENABLE;
extern NSString * const  CONFIG_GARMIN_LOGIN_METHOD;
extern NSString * const  CONFIG_GARMIN_LAST_SOURCE;
extern NSString * const  CONFIG_GARMIN_USE_MODERN;
extern NSString * const  CONFIG_STRAVA_ENABLE;
extern NSString * const  CONFIG_STRAVA_SEGMENTS;
extern NSString * const  CONFIG_SHARING_STRAVA_AUTO;
extern NSString * const  CONFIG_SHARING_STRAVA_PRIVATE;
extern NSString * const  CONFIG_HEALTHKIT_ENABLE;
extern NSString * const  CONFIG_HEALTHKIT_WORKOUT;
extern NSString * const  CONFIG_HEALTHKIT_DAILY;
extern NSString * const  CONFIG_HEALTHKIT_SOURCE_CHECKED;

extern NSString * const  CONFIG_NOTIFICATION_ENABLED;
extern NSString * const  CONFIG_NOTIFICATION_PUSH_TYPE;
extern NSString * const  CONFIG_NOTIFICATION_DEVICE_TOKEN;

extern NSString * const  CONFIG_CONNECTSTATS_TOKEN;
extern NSString * const  CONFIG_CONNECTSTATS_TOKEN_ID;
extern NSString * const  CONFIG_CONNECTSTATS_USER_ID;

extern NSString * const  CONFIG_GARMIN_FIT_DOWNLOAD;
extern NSString * const  CONFIG_GARMIN_FIT_MERGE;

extern NSString * const  CONFIG_ENABLE_DEBUG;
extern NSString * const  CONFIG_ENABLE_DEBUG_ON;
extern NSString * const  CONFIG_ENABLE_DEBUG_OFF;

extern NSString * const  CONFIG_STATS_START_PAGE;
extern NSString * const  CONFIG_SYNC_WITH_PREFERRED;

extern double  CONFIG_FILTER_DISABLED_POWER;//    10000.

// Add new to [GCSettingsBugReportViewController configCheck]?

extern NSString * const  PROFILE_LOGIN_NAME;
extern NSString * const  PROFILE_LOGIN_PWD;
extern NSString * const  PROFILE_DBPATH;
extern NSString * const  PROFILE_NAME;
extern NSString * const  PROFILE_NAME_PWD_SUCCESS;

extern NSString * const  PROFILE_LAST_PAGE_OBSOLETE;
extern NSString * const  PROFILE_LAST_TOTAL_PAGES_OBSOLETE;
extern NSString * const  PROFILE_FULL_DOWNLOAD_DONE_OBSOLETE;

extern NSString * const  PROFILE_SERVICE_STRAVA;
extern NSString * const  PROFILE_SERVICE_CONNECTSTATS;
extern NSString * const  PROFILE_SERVICE_GARMIN;
extern NSString * const  PROFILE_SERVICE_SUCCESS;
extern NSString * const  PROFILE_SOURCES;
extern NSString * const  PROFILE_CURRENT_SOURCE;

// These get appended service name, thus trailing _
extern NSString * const  PROFILE_SERVICE_LOGIN;
extern NSString * const  PROFILE_SERVICE_PWD;
extern NSString * const  PROFILE_SERVICE_SETUP;
extern NSString * const  PROFILE_LAST_KEYCHAIN_SAVE;
extern NSString * const  PROFILE_SERVICE_FULL_DONE;
extern NSString * const  PROFILE_SERVICE_LAST_ANCHOR;


typedef NS_ENUM(NSUInteger, gcPeriodType) {
    gcPeriodCalendar,
    gcPeriodRolling,
    gcPeriodToDate
};

typedef NS_ENUM(NSUInteger, gcGarminLoginMethod) {
    gcGarminLoginMethodDirect,
    gcGarminLoginMethodWebview,
    gcGarminLoginMethodSimulator,
    GCGarminLoginMethodEnd
};

typedef NS_ENUM(NSUInteger, gcGarminDownloadSource) {
    gcGarminDownloadSourceConnectStats,
    gcGarminDownloadSourceGarminWeb,
    gcGarminDownloadSourceBoth,
    gcGarminDownloadSourceEnd
};

typedef NS_ENUM(NSUInteger, gcConnectStatsServiceUse){
    gcConnectStatsServiceUseSource,
    gcConnectStatsServiceUseValidate,
    gcConnectStatsServiceUseEnd
};

typedef NS_ENUM(NSUInteger, gcService) {
    gcServiceStrava,
    //gcServiceWithings,
    gcServiceGarmin,
    gcServiceHealthKit,
    gcServiceConnectStats,
    gcServiceEnd
};

typedef NS_ENUM(NSUInteger, gcLanguageSetting){
    gcLanguageSettingAsDownloaded,
    gcLanguageSettingSystemLanguage,
    gcLanguageSettingPredefinedStart
};

typedef NS_ENUM(NSUInteger, gcHistoryStats) {
    gcHistoryStatsAll,
    gcHistoryStatsWeek,
    gcHistoryStatsMonth,
    gcHistoryStatsYear,
    gcHistoryStatsEnd
};

typedef NS_ENUM(NSUInteger, gcNotificationPushType){
    gcNotificationPushTypeNone,
    gcNotificationPushTypeBackgroundOnly,
    gcNotificationPushTypeAll
};

typedef BOOL(^gcServiceSourceValidator)(NSString*sourceidentifier);


#define GARMINLOGIN_DEFAULT gcGarminLoginMethodDirect
#define WITHINGS_OAUTH

#define OBSOLETE_CONFIG_LOGIN_NAME  @"config_login_name"
#define OBSOLETE_CONFIG_LOGIN_PWD   @"config_login_pwd"

#define MANGLE_KEY @"!hd@943d]|%d2"


#define EVENT_NEW_PROFILE @"new_profile"
#define EVENT_SWITCH_PROFILE @"switch_profile"
#define EVENT_LOAD_ACTIVITIES @"load_activities"
#define EVENT_LIST_SEARCH @"list_search"
#define EVENT_ACTIVITY_DETAIL @"activity_detail_show"
#define EVENT_CALENDAR @"calendar"
#define EVENT_STATISTICS @"statistics"
#define EVENT_REPORT @"report"
#define EVENT_GRAPH_TRACK @"graph_track"
#define EVENT_GRAPH_HISTORY @"graph_history"
#define EVENT_MAP @"map"
#define EVENT_FULL_DOWNLOAD @"full_download"
#define EVENT_SHARING @"sharing"
#define EVENT_GOOGLE_EARTH @"google_earth"
#define EVENT_SHARING_EMAIL @"sharing_email"
#define EVENT_DEVICE @"device"
#define EVENT_RENAME @"rename_activity"
#define EVENT_CHANGE_TYPE @"change_type"
#define EVENT_UPLOAD_STRAVA @"upload_strava"
#define EVENT_AUTO_LAP @"auto_lap"
#define EVENT_WITHINGS @"withings"
#define EVENT_MULTIPLE_FAILURE @"MultipleFailureToStart"
#define EVENT_HELP @"help"

#define DEBUGSTATE_LAST_CNT @"debugstate_last_cnt"
#define DEBUGSTATE_LAST_SUM @"debugstate_last_sum"

