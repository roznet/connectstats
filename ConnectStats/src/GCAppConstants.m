//  MIT License
//
//  Created on 30/01/2021 for ConnectStats
//
//  Copyright (c) 2021 Brice Rosenzweig
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



@import Foundation;
#import "GCAppConstants.h"

NSString * const CONFIG_REFRESH_STARTUP          = @"config_refresh_startup";
NSString * const CONFIG_FILTER_BAD_VALUES        = @"config_filter_bad_values";
NSString * const CONFIG_FILTER_ADJUST_FOR_LAP    = @"config_filter_adjust_for_lap";
NSString * const CONFIG_FILTER_SPEED_BELOW       = @"config_filter_speed_below";
NSString * const CONFIG_FILTER_SPEED_BELOW_SWIM  = @"config_filter_speed_below_swim";
NSString * const CONFIG_FILTER_BAD_ACCEL         = @"config_filter_bad_accel";
NSString * const CONFIG_FILTER_POWER_ABOVE       = @"config_filter_power_above";
NSString * const CONFIG_LAST_LATITUDE            = @"location_last_latitude";
NSString * const CONFIG_LAST_LONGITUDE           = @"location_last_longitude";
NSString * const CONFIG_LAST_LOC_TIME            = @"location_last_timestamp";
NSString * const CONFIG_LAST_USED_VERSION        = @"config_last_used_version";
NSString * const CONFIG_CURRENT_PROFILE          = @"config_current_profile";
NSString * const CONFIG_PROFILES                 = @"config_profiles";
NSString * const CONFIG_UNIT_SYSTEM              = @"config_unit_system";
NSString * const CONFIG_STRIDE_STYLE             = @"config_stride_style";
NSString * const CONFIG_FIRST_DAY_WEEK           = @"config_first_day_week";
NSString * const CONFIG_SHARING_ADD_GE_LINK      = @"config_sharing_add_ge_link";
NSString * const CONFIG_SHARING_ADD_GC_LINK      = @"config_sharing_add_gc_link";
NSString * const CONFIG_SHARING_ADD_SNAPSHOT     = @"config_sharing_add_snapshot";
NSString * const CONFIG_SHARING_ADD_CSV          = @"config_sharing_add_csv";
NSString * const CONFIG_CONTINUE_ON_ERROR        = @"config_continue_on_error";
NSString * const CONFIG_BUG_COMMON_ID            = @"config_bug_common_id";
NSString * const CONFIG_USE_MOVING_ELAPSED       = @"config_use_moving_elapsed";
NSString * const CONFIG_USE_MAP                  = @"config_use_map";
NSString * const CONFIG_BUG_INCLUDE_DATA         = @"config_bug_include_data_v2";
NSString * const CONFIG_USE_NEW_TRACK_API        = @"config_use_new_track_api";
NSString * const CONFIG_FASTER_MAPS              = @"config_faster_maps";
NSString * const CONFIG_CRITICAL_CALC_UNIT       = @"config_critical_calc_unit_v2";
NSString * const CONFIG_REFERENCE_DATE           = @"config_reference_date";
NSString * const CONFIG_PERIOD_TYPE              = @"config_period_type";
NSString * const CONFIG_TODATE_LAST_ACTIVITY     = @"config_period_todate_last_activity";
NSString * const CONFIG_STATS_INLINE_GRAPHS      = @"config_stats_inline_graphs";
NSString * const CONFIG_MAPS_INLINE_GRADIENT     = @"config_maps_inline_gradient";
NSString * const CONFIG_GRAPH_LAP_OVERLAY        = @"config_graph_lap_overlay";
NSString * const CONFIG_STEPS_GOAL_DEFAULT       = @"config_steps_goal_default";
NSString * const CONFIG_ENABLE_DERIVED           = @"config_enable_derived";
NSString * const CONFIG_FONT_STYLE               = @"config_font_style";
NSString * const CONFIG_SHOW_DOWNLOAD_ICON       = @"config_show_download_icon";
NSString * const CONFIG_QUICK_FILTER             = @"config_quick_filter";
NSString * const CONFIG_QUICK_FILTER_TYPE        = @"config_quick_filter_type";
NSString * const CONFIG_MAIN_ACTIVITY_TYPE_ONLY  = @"config_main_activity_type_only";
NSString * const CONFIG_POWER_CURVE_LOG_SCALE    = @"config_power_curve_log_scale";
NSString * const CONFIG_LANGUAGE_SETTING         = @"config_language_setting";
NSString * const CONFIG_ZONE_GRAPH_HORIZONTAL    = @"config_zone_gaph_horizontal";
NSString * const CONFIG_ZONE_PREFERRED_SOURCE    = @"config_zone_preferred_source";
NSString * const CONFIG_WIFI_DOWNLOAD_DETAILS    = @"config_wifi_download_details";
NSString * const CONFIG_SKIN_NAME                = @"config_skin_name";
NSString * const CONFIG_SHOW_PHOTOS              = @"config_show_photos";
NSString * const CONFIG_VERSIONS_SEEN            = @"config_versions_seen";
NSString * const CONFIG_VERSIONS_USES            = @"config_versions_uses";
NSString * const CONFIG_FEATURES_SEEN            = @"config_features_seen";
NSString * const CONFIG_CELL_EXTENDED_DISPLAY    = @"config_cell_extended_display";
NSString * const CONFIG_LAST_REMOTE_STATUS_ID    = @"config_last_remote_status_id";
NSString * const CONFIG_ENABLE_REMOTE_STATUS     = @"config_enable_remote_status";
NSString * const CONFIG_DUPLICATE_CHECK_ON_IMPORT = @"config_duplicate_check_on_import";
NSString * const CONFIG_DUPLICATE_CHECK_ON_LOAD   = @"config_duplicate_check_on_load";
NSString * const CONFIG_ENABLE_SPEED_CALC_FIELDS  = @"config_enable_speed_calc_fields";

NSString * const CONFIG_DUPLICATE_SKIP_ON_IMPORT_OBSOLETE = @"config_duplicate_skip_on_import";

NSString * const CONFIG_CONNECTSTATS_ENABLE      = @"config_connectstats_enable";
NSString * const CONFIG_CONNECTSTATS_USE         = @"config_connectstats_use";
NSString * const CONFIG_CONNECTSTATS_FILLYEAR    = @"config_connectstats_fillyear";
NSString * const CONFIG_CONNECTSTATS_CONFIG      = @"config_connectstats_config";
NSString * const CONFIG_GARMIN_ENABLE            = @"config_garmin_enable";
NSString * const CONFIG_GARMIN_LOGIN_METHOD      = @"config_garmin_login_method";
NSString * const CONFIG_GARMIN_LAST_SOURCE       = @"config_garmin_last_source";
NSString * const CONFIG_GARMIN_USE_MODERN        = @"config_garmin_use_modern_v3";
NSString * const CONFIG_STRAVA_ENABLE            = @"config_strava_enable";
NSString * const CONFIG_STRAVA_SEGMENTS          = @"config_strava_segments";
NSString * const CONFIG_SHARING_STRAVA_PRIVATE   = @"config_sharing_strava_private";
NSString * const CONFIG_HEALTHKIT_ENABLE         = @"config_healthkit_enable";
NSString * const CONFIG_HEALTHKIT_WORKOUT        = @"config_healthkit_workout";
NSString * const CONFIG_HEALTHKIT_DAILY          = @"config_healthkit_daily";
NSString * const CONFIG_HEALTHKIT_SOURCE_CHECKED = @"config_healthkit_source_checked";

NSString * const CONFIG_CONNECTSTATS_TOKEN       = @"config_connectstats_token";
NSString * const CONFIG_CONNECTSTATS_TOKEN_ID    = @"config_connectstats_token_id";
NSString * const CONFIG_CONNECTSTATS_USER_ID     = @"config_connectstats_user_id";

//NSString * const  CONFIG_NOTIFICATION_ENABLED      = @"config_notification_enabled_dev";
NSString * const  CONFIG_NOTIFICATION_PUSH_TYPE    = @"config_notification_push_type";
NSString * const  CONFIG_NOTIFICATION_DEVICE_TOKEN = @"config_notification_devicetoken";


NSString * const CONFIG_GARMIN_FIT_DOWNLOAD      = @"config_garmin_fit_download";
NSString * const CONFIG_GARMIN_FIT_MERGE         = @"config_garmin_fit_merge";

NSString * const CONFIG_ENABLE_DEBUG               = @"config_enable_debug";
NSString * const CONFIG_ENABLE_DEBUG_ON            = @"enabledebug1970";
NSString * const CONFIG_ENABLE_DEBUG_OFF           = @"disabled";

NSString * const CONFIG_STATS_START_PAGE           = @"config_stats_start_page";
NSString * const CONFIG_SYNC_WITH_PREFERRED        = @"profile_sync_with_preferred";

double CONFIG_FILTER_DISABLED_POWER  =  10000.;

// Add new to [GCSettingsBugReportViewController configCheck]?

NSString * const PROFILE_LOGIN_NAME           = @"profile_login_name";
NSString * const PROFILE_LOGIN_PWD            = @"profile_login_pwd";
NSString * const PROFILE_DBPATH               = @"profile_db_path";
NSString * const PROFILE_NAME                 = @"profile_name";
NSString * const PROFILE_NAME_PWD_SUCCESS     = @"config_name_pwd_success";

NSString * const PROFILE_LAST_PAGE_OBSOLETE            = @"config_last_page";
NSString * const PROFILE_LAST_TOTAL_PAGES_OBSOLETE     = @"config_last_total_pages";
NSString * const PROFILE_FULL_DOWNLOAD_DONE_OBSOLETE   = @"config_full_download_done";

NSString * const PROFILE_SERVICE_STRAVA       = @"profile_service_strava";
NSString * const PROFILE_SERVICE_CONNECTSTATS = @"profile_service_connectstats";
NSString * const PROFILE_SERVICE_GARMIN       = @"profile_service_garmin";
NSString * const PROFILE_SERVICE_SUCCESS      = @"profile_service_success";
NSString * const PROFILE_SOURCES              = @"profile_sources";
NSString * const PROFILE_CURRENT_SOURCE       = @"profile_current_source";

// These get appended service name, thus trailing _
NSString * const PROFILE_SERVICE_LOGIN        = @"profile_service_login_name_";
NSString * const PROFILE_SERVICE_PWD          = @"profile_service_login_pwd_";
NSString * const PROFILE_SERVICE_SETUP        = @"profile_service_setup_";
NSString * const PROFILE_LAST_KEYCHAIN_SAVE   = @"profile_last_keychain_save_";
NSString * const PROFILE_SERVICE_FULL_DONE    = @"profile_service_full_done_";
NSString * const PROFILE_SERVICE_LAST_ANCHOR  = @"profile_service_last_anchor_";


