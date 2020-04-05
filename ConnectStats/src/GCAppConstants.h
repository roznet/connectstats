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
#define CONFIG_REFRESH_STARTUP          @"config_refresh_startup"
#define CONFIG_FILTER_BAD_VALUES        @"config_filter_bad_values"
#define CONFIG_FILTER_ADJUST_FOR_LAP    @"config_filter_adjust_for_lap"
#define CONFIG_FILTER_SPEED_BELOW       @"config_filter_speed_below"
#define CONFIG_FILTER_BAD_ACCEL         @"config_filter_bad_accel"
#define CONFIG_FILTER_POWER_ABOVE       @"config_filter_power_above"
#define CONFIG_LAST_LATITUDE            @"location_last_latitude"
#define CONFIG_LAST_LONGITUDE           @"location_last_longitude"
#define CONFIG_LAST_LOC_TIME            @"location_last_timestamp"
#define CONFIG_LAST_USED_VERSION        @"config_last_used_version"
#define CONFIG_CURRENT_PROFILE          @"config_current_profile"
#define CONFIG_PROFILES                 @"config_profiles"
#define CONFIG_UNIT_SYSTEM              @"config_unit_system"
#define CONFIG_STRIDE_STYLE             @"config_stride_style"
#define CONFIG_FIRST_DAY_WEEK           @"config_first_day_week"
#define CONFIG_SHARING_ADD_GE_LINK      @"config_sharing_add_ge_link"
#define CONFIG_SHARING_ADD_GC_LINK      @"config_sharing_add_gc_link"
#define CONFIG_SHARING_ADD_SNAPSHOT     @"config_sharing_add_snapshot"
#define CONFIG_SHARING_ADD_CSV          @"config_sharing_add_csv"
#define CONFIG_CONTINUE_ON_ERROR        @"config_continue_on_error"
#define CONFIG_BUG_COMMON_ID            @"config_bug_common_id"
#define CONFIG_USE_MOVING_ELAPSED       @"config_use_moving_elapsed"
#define CONFIG_USE_MAP                  @"config_use_map"
#define CONFIG_BUG_INCLUDE_DATA         @"config_bug_include_data_v2"
#define CONFIG_USE_NEW_TRACK_API        @"config_use_new_track_api"
#define CONFIG_FASTER_MAPS              @"config_faster_maps"
#define CONFIG_CRITICAL_CALC_UNIT       @"config_critical_calc_unit_v2"
#define CONFIG_REFERENCE_DATE           @"config_reference_date"
#define CONFIG_PERIOD_TYPE              @"config_period_type"
#define CONFIG_STATS_INLINE_GRAPHS      @"config_stats_inline_graphs"
#define CONFIG_MAPS_INLINE_GRADIENT     @"config_maps_inline_gradient"
#define CONFIG_GRAPH_LAP_OVERLAY        @"config_graph_lap_overlay"
#define CONFIG_STEPS_GOAL_DEFAULT       @"config_steps_goal_default"
#define CONFIG_ENABLE_DERIVED           @"config_enable_derived"
#define CONFIG_FONT_STYLE               @"config_font_style"
#define CONFIG_SHOW_DOWNLOAD_ICON       @"config_show_download_icon"
#define CONFIG_QUICK_FILTER             @"config_quick_filter"
#define CONFIG_QUICK_FILTER_TYPE        @"config_quick_filter_type"
#define CONFIG_MAIN_ACTIVITY_TYPE_ONLY  @"config_main_activity_type_only"
#define CONFIG_POWER_CURVE_LOG_SCALE    @"config_power_curve_log_scale"
#define CONFIG_LANGUAGE_SETTING         @"config_language_setting"
#define CONFIG_ZONE_GRAPH_HORIZONTAL    @"config_zone_gaph_horizontal"
#define CONFIG_ZONE_PREFERRED_SOURCE    @"config_zone_preferred_source"
#define CONFIG_WIFI_DOWNLOAD_DETAILS    @"config_wifi_download_details"
#define CONFIG_SKIN_NAME                @"config_skin_name"
#define CONFIG_VERSIONS_SEEN            @"config_versions_seen"
#define CONFIG_FEATURES_SEEN            @"config_features_seen"
#define CONFIG_LAST_REMOTE_STATUS_ID    @"config_last_remote_status_id"
#define CONFIG_ENABLE_REMOTE_STATUS     @"config_enable_remote_status"
#define CONFIG_DUPLICATE_CHECK_ON_IMPORT @"config_duplicate_check_on_import"
#define CONFIG_DUPLICATE_CHECK_ON_LOAD   @"config_duplicate_check_on_load"
#define CONFIG_ENABLE_SPEED_CALC_FIELDS  @"config_enable_speed_calc_fields"

#define CONFIG_DUPLICATE_SKIP_ON_IMPORT_OBSOLETE @"config_duplicate_skip_on_import"

#define CONFIG_WITHINGS_USERSLIST       @"config_withings_userlist"
#define CONFIG_WITHINGS_USER            @"config_withings_user"
#define CONFIG_WITHINGS_AUTO            @"config_withings_auto"
#define CONFIG_BABOLAT_ENABLE           @"config_babolat_enable"
#define CONFIG_CONNECTSTATS_ENABLE      @"config_connectstats_enable"
#define CONFIG_CONNECTSTATS_USE         @"config_connectstats_use"
#define CONFIG_CONNECTSTATS_FILLYEAR    @"config_connectstats_fillyear"
#define CONFIG_CONNECTSTATS_CONFIG      @"config_connectstats_config"
#define CONFIG_GARMIN_ENABLE            @"config_garmin_enable"
#define CONFIG_GARMIN_LOGIN_METHOD      @"config_garmin_login_method"
#define CONFIG_GARMIN_LAST_SOURCE       @"config_garmin_last_source"
#define CONFIG_GARMIN_USE_MODERN        @"config_garmin_use_modern_v3"
#define CONFIG_STRAVA_ENABLE            @"config_strava_enable"
#define CONFIG_STRAVA_SEGMENTS          @"config_strava_segments"
#define CONFIG_SHARING_STRAVA_AUTO      @"config_sharing_strava_auto"
#define CONFIG_SHARING_STRAVA_PRIVATE   @"config_sharing_strava_private"
#define CONFIG_SPORTTRACKS_ENABLE       @"config_sporttracks_enable"
#define CONFIG_HEALTHKIT_ENABLE         @"config_healthkit_enable"
#define CONFIG_HEALTHKIT_WORKOUT        @"config_healthkit_workout"
#define CONFIG_HEALTHKIT_SOURCE_CHECKED @"config_healthkit_source_checked"
#define CONFIG_FITBIT_ENABLE            @"config_fitbit_enable"
#define CONFIG_FITBIT_TOKEN             @"config_fitbit_t"
#define CONFIG_FITBIT_TOKENSECRET       @"config_fitbit_s"

#define CONFIG_CONNECTSTATS_TOKEN       @"config_connectstats_token"
#define CONFIG_CONNECTSTATS_TOKEN_ID    @"config_connectstats_token_id"
#define CONFIG_CONNECTSTATS_USER_ID     @"config_connectstats_user_id"

#define CONFIG_GARMIN_FIT_DOWNLOAD      @"config_garmin_fit_download"
#define CONFIG_GARMIN_FIT_MERGE         @"config_garmin_fit_merge"

#define CONFIG_WITHINGS_TOKEN             @"config_withings_t"
#define CONFIG_WITHINGS_TOKENSECRET       @"config_withings_s"
#define CONFIG_WITHINGS_USERID            @"config_withings_u"

#define CONFIG_ENABLE_DEBUG               @"config_enable_debug"
#define CONFIG_ENABLE_DEBUG_ON            @"enabledebug1970"
#define CONFIG_ENABLE_DEBUG_OFF           @"disabled"

#define CONFIG_STATS_START_PAGE           @"config_stats_start_page"

#define CONFIG_FILTER_DISABLED_POWER    10000.
#define CONFIG_CONNECTSTATS_NO_BACKFILL 0

// Add new to [GCSettingsBugReportViewController configCheck]?

#define PROFILE_LOGIN_NAME           @"profile_login_name"
#define PROFILE_LOGIN_PWD            @"profile_login_pwd"
#define PROFILE_DBPATH               @"profile_db_path"
#define PROFILE_NAME                 @"profile_name"
#define PROFILE_NAME_PWD_SUCCESS     @"config_name_pwd_success"
#define PROFILE_LAST_PAGE            @"config_last_page"
#define PROFILE_LAST_TOTAL_PAGES     @"config_last_total_pages"
#define PROFILE_FULL_DOWNLOAD_DONE   @"config_full_download_done"

#define PROFILE_SERVICE_STRAVA       @"profile_service_strava"
#define PROFILE_SERVICE_CONNECTSTATS @"profile_service_connectstats"
#define PROFILE_SERVICE_BABOLAT      @"profile_service_babolat"
#define PROFILE_SERVICE_WITHINGS     @"profile_service_withings"
#define PROFILE_SERVICE_GARMIN       @"profile_service_garmin"
#define PROFILE_SERVICE_SUCCESS      @"profile_service_success"
#define PROFILE_SOURCES              @"profile_sources"
#define PROFILE_CURRENT_SOURCE       @"profile_current_source"

// These get appended service name, thus trailing _
#define PROFILE_SERVICE_LOGIN        @"profile_service_login_name_"
#define PROFILE_SERVICE_PWD          @"profile_service_login_pwd_"
#define PROFILE_SERVICE_SETUP        @"profile_service_setup_"
#define PROFILE_LAST_KEYCHAIN_SAVE   @"profile_last_keychain_save_"
#define PROFILE_SERVICE_FULL_DONE    @"profile_service_full_done_"

typedef NS_ENUM(NSUInteger, gcPeriodType) {
    gcPeriodCalendar,
    gcPeriodRolling,
    gcPeriodReferenceDate
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
    gcServiceWithings,
    gcServiceBabolat,
    gcServiceGarmin,
    gcServiceSportTracks,
    gcServiceHealthKit,
    gcServiceFitBit,
    gcServiceConnectStats,
    gcServiceEnd
};

typedef NS_ENUM(NSUInteger, gcLanguageSetting){
    gcLanguageSettingAsDownloaded,
    gcLanguageSettingSystemLanguage,
    gcLanguageSettingPredefinedStart
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

