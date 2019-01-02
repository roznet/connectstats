// This file is auto generated, Do not edit
func rzfit_dive_alarm_type_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_DIVE_ALARM_TYPE_DEPTH: return "depth";
    case FIT_DIVE_ALARM_TYPE_TIME: return "time";
    default: return nil
  }
}
func rzfit_watchface_mode_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_WATCHFACE_MODE_DIGITAL: return "digital";
    case FIT_WATCHFACE_MODE_ANALOG: return "analog";
    case FIT_WATCHFACE_MODE_CONNECT_IQ: return "connect_iq";
    case FIT_WATCHFACE_MODE_DISABLED: return "disabled";
    default: return nil
  }
}
func rzfit_cardio_exercise_name_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_CARDIO_EXERCISE_NAME_BOB_AND_WEAVE_CIRCLE: return "bob_and_weave_circle";
    case FIT_CARDIO_EXERCISE_NAME_WEIGHTED_BOB_AND_WEAVE_CIRCLE: return "weighted_bob_and_weave_circle";
    case FIT_CARDIO_EXERCISE_NAME_CARDIO_CORE_CRAWL: return "cardio_core_crawl";
    case FIT_CARDIO_EXERCISE_NAME_WEIGHTED_CARDIO_CORE_CRAWL: return "weighted_cardio_core_crawl";
    case FIT_CARDIO_EXERCISE_NAME_DOUBLE_UNDER: return "double_under";
    case FIT_CARDIO_EXERCISE_NAME_WEIGHTED_DOUBLE_UNDER: return "weighted_double_under";
    case FIT_CARDIO_EXERCISE_NAME_JUMP_ROPE: return "jump_rope";
    case FIT_CARDIO_EXERCISE_NAME_WEIGHTED_JUMP_ROPE: return "weighted_jump_rope";
    case FIT_CARDIO_EXERCISE_NAME_JUMP_ROPE_CROSSOVER: return "jump_rope_crossover";
    case FIT_CARDIO_EXERCISE_NAME_WEIGHTED_JUMP_ROPE_CROSSOVER: return "weighted_jump_rope_crossover";
    case FIT_CARDIO_EXERCISE_NAME_JUMP_ROPE_JOG: return "jump_rope_jog";
    case FIT_CARDIO_EXERCISE_NAME_WEIGHTED_JUMP_ROPE_JOG: return "weighted_jump_rope_jog";
    case FIT_CARDIO_EXERCISE_NAME_JUMPING_JACKS: return "jumping_jacks";
    case FIT_CARDIO_EXERCISE_NAME_WEIGHTED_JUMPING_JACKS: return "weighted_jumping_jacks";
    case FIT_CARDIO_EXERCISE_NAME_SKI_MOGULS: return "ski_moguls";
    case FIT_CARDIO_EXERCISE_NAME_WEIGHTED_SKI_MOGULS: return "weighted_ski_moguls";
    case FIT_CARDIO_EXERCISE_NAME_SPLIT_JACKS: return "split_jacks";
    case FIT_CARDIO_EXERCISE_NAME_WEIGHTED_SPLIT_JACKS: return "weighted_split_jacks";
    case FIT_CARDIO_EXERCISE_NAME_SQUAT_JACKS: return "squat_jacks";
    case FIT_CARDIO_EXERCISE_NAME_WEIGHTED_SQUAT_JACKS: return "weighted_squat_jacks";
    case FIT_CARDIO_EXERCISE_NAME_TRIPLE_UNDER: return "triple_under";
    case FIT_CARDIO_EXERCISE_NAME_WEIGHTED_TRIPLE_UNDER: return "weighted_triple_under";
    default: return nil
  }
}
func rzfit_comm_timeout_type_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_COMM_TIMEOUT_TYPE_WILDCARD_PAIRING_TIMEOUT: return "wildcard_pairing_timeout";
    case FIT_COMM_TIMEOUT_TYPE_PAIRING_TIMEOUT: return "pairing_timeout";
    case FIT_COMM_TIMEOUT_TYPE_CONNECTION_LOST: return "connection_lost";
    case FIT_COMM_TIMEOUT_TYPE_CONNECTION_TIMEOUT: return "connection_timeout";
    default: return nil
  }
}
func rzfit_exd_qualifiers_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_EXD_QUALIFIERS_NO_QUALIFIER: return "no_qualifier";
    case FIT_EXD_QUALIFIERS_INSTANTANEOUS: return "instantaneous";
    case FIT_EXD_QUALIFIERS_AVERAGE: return "average";
    case FIT_EXD_QUALIFIERS_LAP: return "lap";
    case FIT_EXD_QUALIFIERS_MAXIMUM: return "maximum";
    case FIT_EXD_QUALIFIERS_MAXIMUM_AVERAGE: return "maximum_average";
    case FIT_EXD_QUALIFIERS_MAXIMUM_LAP: return "maximum_lap";
    case FIT_EXD_QUALIFIERS_LAST_LAP: return "last_lap";
    case FIT_EXD_QUALIFIERS_AVERAGE_LAP: return "average_lap";
    case FIT_EXD_QUALIFIERS_TO_DESTINATION: return "to_destination";
    case FIT_EXD_QUALIFIERS_TO_GO: return "to_go";
    case FIT_EXD_QUALIFIERS_TO_NEXT: return "to_next";
    case FIT_EXD_QUALIFIERS_NEXT_COURSE_POINT: return "next_course_point";
    case FIT_EXD_QUALIFIERS_TOTAL: return "total";
    case FIT_EXD_QUALIFIERS_THREE_SECOND_AVERAGE: return "three_second_average";
    case FIT_EXD_QUALIFIERS_TEN_SECOND_AVERAGE: return "ten_second_average";
    case FIT_EXD_QUALIFIERS_THIRTY_SECOND_AVERAGE: return "thirty_second_average";
    case FIT_EXD_QUALIFIERS_PERCENT_MAXIMUM: return "percent_maximum";
    case FIT_EXD_QUALIFIERS_PERCENT_MAXIMUM_AVERAGE: return "percent_maximum_average";
    case FIT_EXD_QUALIFIERS_LAP_PERCENT_MAXIMUM: return "lap_percent_maximum";
    case FIT_EXD_QUALIFIERS_ELAPSED: return "elapsed";
    case FIT_EXD_QUALIFIERS_SUNRISE: return "sunrise";
    case FIT_EXD_QUALIFIERS_SUNSET: return "sunset";
    case FIT_EXD_QUALIFIERS_COMPARED_TO_VIRTUAL_PARTNER: return "compared_to_virtual_partner";
    case FIT_EXD_QUALIFIERS_MAXIMUM_24H: return "maximum_24h";
    case FIT_EXD_QUALIFIERS_MINIMUM_24H: return "minimum_24h";
    case FIT_EXD_QUALIFIERS_MINIMUM: return "minimum";
    case FIT_EXD_QUALIFIERS_FIRST: return "first";
    case FIT_EXD_QUALIFIERS_SECOND: return "second";
    case FIT_EXD_QUALIFIERS_THIRD: return "third";
    case FIT_EXD_QUALIFIERS_SHIFTER: return "shifter";
    case FIT_EXD_QUALIFIERS_LAST_SPORT: return "last_sport";
    case FIT_EXD_QUALIFIERS_MOVING: return "moving";
    case FIT_EXD_QUALIFIERS_STOPPED: return "stopped";
    case FIT_EXD_QUALIFIERS_ESTIMATED_TOTAL: return "estimated_total";
    case FIT_EXD_QUALIFIERS_ZONE_9: return "zone_9";
    case FIT_EXD_QUALIFIERS_ZONE_8: return "zone_8";
    case FIT_EXD_QUALIFIERS_ZONE_7: return "zone_7";
    case FIT_EXD_QUALIFIERS_ZONE_6: return "zone_6";
    case FIT_EXD_QUALIFIERS_ZONE_5: return "zone_5";
    case FIT_EXD_QUALIFIERS_ZONE_4: return "zone_4";
    case FIT_EXD_QUALIFIERS_ZONE_3: return "zone_3";
    case FIT_EXD_QUALIFIERS_ZONE_2: return "zone_2";
    case FIT_EXD_QUALIFIERS_ZONE_1: return "zone_1";
    default: return nil
  }
}
func rzfit_hip_swing_exercise_name_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_HIP_SWING_EXERCISE_NAME_SINGLE_ARM_KETTLEBELL_SWING: return "single_arm_kettlebell_swing";
    case FIT_HIP_SWING_EXERCISE_NAME_SINGLE_ARM_DUMBBELL_SWING: return "single_arm_dumbbell_swing";
    case FIT_HIP_SWING_EXERCISE_NAME_STEP_OUT_SWING: return "step_out_swing";
    default: return nil
  }
}
func rzfit_date_mode_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_DATE_MODE_DAY_MONTH: return "day_month";
    case FIT_DATE_MODE_MONTH_DAY: return "month_day";
    default: return nil
  }
}
func rzfit_wkt_step_target_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_WKT_STEP_TARGET_SPEED: return "speed";
    case FIT_WKT_STEP_TARGET_HEART_RATE: return "heart_rate";
    case FIT_WKT_STEP_TARGET_OPEN: return "open";
    case FIT_WKT_STEP_TARGET_CADENCE: return "cadence";
    case FIT_WKT_STEP_TARGET_POWER: return "power";
    case FIT_WKT_STEP_TARGET_GRADE: return "grade";
    case FIT_WKT_STEP_TARGET_RESISTANCE: return "resistance";
    case FIT_WKT_STEP_TARGET_POWER_3S: return "power_3s";
    case FIT_WKT_STEP_TARGET_POWER_10S: return "power_10s";
    case FIT_WKT_STEP_TARGET_POWER_30S: return "power_30s";
    case FIT_WKT_STEP_TARGET_POWER_LAP: return "power_lap";
    case FIT_WKT_STEP_TARGET_SWIM_STROKE: return "swim_stroke";
    case FIT_WKT_STEP_TARGET_SPEED_LAP: return "speed_lap";
    case FIT_WKT_STEP_TARGET_HEART_RATE_LAP: return "heart_rate_lap";
    default: return nil
  }
}
func rzfit_analog_watchface_layout_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_ANALOG_WATCHFACE_LAYOUT_MINIMAL: return "minimal";
    case FIT_ANALOG_WATCHFACE_LAYOUT_TRADITIONAL: return "traditional";
    case FIT_ANALOG_WATCHFACE_LAYOUT_MODERN: return "modern";
    default: return nil
  }
}
func rzfit_goal_source_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_GOAL_SOURCE_AUTO: return "auto";
    case FIT_GOAL_SOURCE_COMMUNITY: return "community";
    case FIT_GOAL_SOURCE_USER: return "user";
    default: return nil
  }
}
func rzfit_dive_backlight_mode_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_DIVE_BACKLIGHT_MODE_AT_DEPTH: return "at_depth";
    case FIT_DIVE_BACKLIGHT_MODE_ALWAYS_ON: return "always_on";
    default: return nil
  }
}
func rzfit_dive_gas_status_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_DIVE_GAS_STATUS_DISABLED: return "disabled";
    case FIT_DIVE_GAS_STATUS_ENABLED: return "enabled";
    case FIT_DIVE_GAS_STATUS_BACKUP_ONLY: return "backup_only";
    default: return nil
  }
}

func rzfit_activity_subtype_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_ACTIVITY_SUBTYPE_GENERIC: return "generic";
    case FIT_ACTIVITY_SUBTYPE_TREADMILL: return "treadmill";
    case FIT_ACTIVITY_SUBTYPE_STREET: return "street";
    case FIT_ACTIVITY_SUBTYPE_TRAIL: return "trail";
    case FIT_ACTIVITY_SUBTYPE_TRACK: return "track";
    case FIT_ACTIVITY_SUBTYPE_SPIN: return "spin";
    case FIT_ACTIVITY_SUBTYPE_INDOOR_CYCLING: return "indoor_cycling";
    case FIT_ACTIVITY_SUBTYPE_ROAD: return "road";
    case FIT_ACTIVITY_SUBTYPE_MOUNTAIN: return "mountain";
    case FIT_ACTIVITY_SUBTYPE_DOWNHILL: return "downhill";
    case FIT_ACTIVITY_SUBTYPE_RECUMBENT: return "recumbent";
    case FIT_ACTIVITY_SUBTYPE_CYCLOCROSS: return "cyclocross";
    case FIT_ACTIVITY_SUBTYPE_HAND_CYCLING: return "hand_cycling";
    case FIT_ACTIVITY_SUBTYPE_TRACK_CYCLING: return "track_cycling";
    case FIT_ACTIVITY_SUBTYPE_INDOOR_ROWING: return "indoor_rowing";
    case FIT_ACTIVITY_SUBTYPE_ELLIPTICAL: return "elliptical";
    case FIT_ACTIVITY_SUBTYPE_STAIR_CLIMBING: return "stair_climbing";
    case FIT_ACTIVITY_SUBTYPE_LAP_SWIMMING: return "lap_swimming";
    case FIT_ACTIVITY_SUBTYPE_OPEN_WATER: return "open_water";
    case FIT_ACTIVITY_SUBTYPE_ALL: return "all";
    default: return nil
  }
}
func rzfit_run_exercise_name_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_RUN_EXERCISE_NAME_RUN: return "run";
    case FIT_RUN_EXERCISE_NAME_WALK: return "walk";
    case FIT_RUN_EXERCISE_NAME_JOG: return "jog";
    case FIT_RUN_EXERCISE_NAME_SPRINT: return "sprint";
    default: return nil
  }
}

func rzfit_tone_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_TONE_OFF: return "off";
    case FIT_TONE_TONE: return "tone";
    case FIT_TONE_VIBRATE: return "vibrate";
    case FIT_TONE_TONE_AND_VIBRATE: return "tone_and_vibrate";
    default: return nil
  }
}
func rzfit_fitness_equipment_state_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_FITNESS_EQUIPMENT_STATE_READY: return "ready";
    case FIT_FITNESS_EQUIPMENT_STATE_IN_USE: return "in_use";
    case FIT_FITNESS_EQUIPMENT_STATE_PAUSED: return "paused";
    case FIT_FITNESS_EQUIPMENT_STATE_UNKNOWN: return "unknown";
    default: return nil
  }
}
func rzfit_core_exercise_name_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_CORE_EXERCISE_NAME_ABS_JABS: return "abs_jabs";
    case FIT_CORE_EXERCISE_NAME_WEIGHTED_ABS_JABS: return "weighted_abs_jabs";
    case FIT_CORE_EXERCISE_NAME_ALTERNATING_PLATE_REACH: return "alternating_plate_reach";
    case FIT_CORE_EXERCISE_NAME_BARBELL_ROLLOUT: return "barbell_rollout";
    case FIT_CORE_EXERCISE_NAME_WEIGHTED_BARBELL_ROLLOUT: return "weighted_barbell_rollout";
    case FIT_CORE_EXERCISE_NAME_BODY_BAR_OBLIQUE_TWIST: return "body_bar_oblique_twist";
    case FIT_CORE_EXERCISE_NAME_CABLE_CORE_PRESS: return "cable_core_press";
    case FIT_CORE_EXERCISE_NAME_CABLE_SIDE_BEND: return "cable_side_bend";
    case FIT_CORE_EXERCISE_NAME_SIDE_BEND: return "side_bend";
    case FIT_CORE_EXERCISE_NAME_WEIGHTED_SIDE_BEND: return "weighted_side_bend";
    case FIT_CORE_EXERCISE_NAME_CRESCENT_CIRCLE: return "crescent_circle";
    case FIT_CORE_EXERCISE_NAME_WEIGHTED_CRESCENT_CIRCLE: return "weighted_crescent_circle";
    case FIT_CORE_EXERCISE_NAME_CYCLING_RUSSIAN_TWIST: return "cycling_russian_twist";
    case FIT_CORE_EXERCISE_NAME_WEIGHTED_CYCLING_RUSSIAN_TWIST: return "weighted_cycling_russian_twist";
    case FIT_CORE_EXERCISE_NAME_ELEVATED_FEET_RUSSIAN_TWIST: return "elevated_feet_russian_twist";
    case FIT_CORE_EXERCISE_NAME_WEIGHTED_ELEVATED_FEET_RUSSIAN_TWIST: return "weighted_elevated_feet_russian_twist";
    case FIT_CORE_EXERCISE_NAME_HALF_TURKISH_GET_UP: return "half_turkish_get_up";
    case FIT_CORE_EXERCISE_NAME_KETTLEBELL_WINDMILL: return "kettlebell_windmill";
    case FIT_CORE_EXERCISE_NAME_KNEELING_AB_WHEEL: return "kneeling_ab_wheel";
    case FIT_CORE_EXERCISE_NAME_WEIGHTED_KNEELING_AB_WHEEL: return "weighted_kneeling_ab_wheel";
    case FIT_CORE_EXERCISE_NAME_MODIFIED_FRONT_LEVER: return "modified_front_lever";
    case FIT_CORE_EXERCISE_NAME_OPEN_KNEE_TUCKS: return "open_knee_tucks";
    case FIT_CORE_EXERCISE_NAME_WEIGHTED_OPEN_KNEE_TUCKS: return "weighted_open_knee_tucks";
    case FIT_CORE_EXERCISE_NAME_SIDE_ABS_LEG_LIFT: return "side_abs_leg_lift";
    case FIT_CORE_EXERCISE_NAME_WEIGHTED_SIDE_ABS_LEG_LIFT: return "weighted_side_abs_leg_lift";
    case FIT_CORE_EXERCISE_NAME_SWISS_BALL_JACKKNIFE: return "swiss_ball_jackknife";
    case FIT_CORE_EXERCISE_NAME_WEIGHTED_SWISS_BALL_JACKKNIFE: return "weighted_swiss_ball_jackknife";
    case FIT_CORE_EXERCISE_NAME_SWISS_BALL_PIKE: return "swiss_ball_pike";
    case FIT_CORE_EXERCISE_NAME_WEIGHTED_SWISS_BALL_PIKE: return "weighted_swiss_ball_pike";
    case FIT_CORE_EXERCISE_NAME_SWISS_BALL_ROLLOUT: return "swiss_ball_rollout";
    case FIT_CORE_EXERCISE_NAME_WEIGHTED_SWISS_BALL_ROLLOUT: return "weighted_swiss_ball_rollout";
    case FIT_CORE_EXERCISE_NAME_TRIANGLE_HIP_PRESS: return "triangle_hip_press";
    case FIT_CORE_EXERCISE_NAME_WEIGHTED_TRIANGLE_HIP_PRESS: return "weighted_triangle_hip_press";
    case FIT_CORE_EXERCISE_NAME_TRX_SUSPENDED_JACKKNIFE: return "trx_suspended_jackknife";
    case FIT_CORE_EXERCISE_NAME_WEIGHTED_TRX_SUSPENDED_JACKKNIFE: return "weighted_trx_suspended_jackknife";
    case FIT_CORE_EXERCISE_NAME_U_BOAT: return "u_boat";
    case FIT_CORE_EXERCISE_NAME_WEIGHTED_U_BOAT: return "weighted_u_boat";
    case FIT_CORE_EXERCISE_NAME_WINDMILL_SWITCHES: return "windmill_switches";
    case FIT_CORE_EXERCISE_NAME_WEIGHTED_WINDMILL_SWITCHES: return "weighted_windmill_switches";
    case FIT_CORE_EXERCISE_NAME_ALTERNATING_SLIDE_OUT: return "alternating_slide_out";
    case FIT_CORE_EXERCISE_NAME_WEIGHTED_ALTERNATING_SLIDE_OUT: return "weighted_alternating_slide_out";
    case FIT_CORE_EXERCISE_NAME_GHD_BACK_EXTENSIONS: return "ghd_back_extensions";
    case FIT_CORE_EXERCISE_NAME_WEIGHTED_GHD_BACK_EXTENSIONS: return "weighted_ghd_back_extensions";
    case FIT_CORE_EXERCISE_NAME_OVERHEAD_WALK: return "overhead_walk";
    case FIT_CORE_EXERCISE_NAME_INCHWORM: return "inchworm";
    case FIT_CORE_EXERCISE_NAME_WEIGHTED_MODIFIED_FRONT_LEVER: return "weighted_modified_front_lever";
    case FIT_CORE_EXERCISE_NAME_RUSSIAN_TWIST: return "russian_twist";
    case FIT_CORE_EXERCISE_NAME_ABDOMINAL_LEG_ROTATIONS: return "abdominal_leg_rotations";
    case FIT_CORE_EXERCISE_NAME_ARM_AND_LEG_EXTENSION_ON_KNEES: return "arm_and_leg_extension_on_knees";
    case FIT_CORE_EXERCISE_NAME_BICYCLE: return "bicycle";
    case FIT_CORE_EXERCISE_NAME_BICEP_CURL_WITH_LEG_EXTENSION: return "bicep_curl_with_leg_extension";
    case FIT_CORE_EXERCISE_NAME_CAT_COW: return "cat_cow";
    case FIT_CORE_EXERCISE_NAME_CORKSCREW: return "corkscrew";
    case FIT_CORE_EXERCISE_NAME_CRISS_CROSS: return "criss_cross";
    case FIT_CORE_EXERCISE_NAME_CRISS_CROSS_WITH_BALL: return "criss_cross_with_ball";
    case FIT_CORE_EXERCISE_NAME_DOUBLE_LEG_STRETCH: return "double_leg_stretch";
    case FIT_CORE_EXERCISE_NAME_KNEE_FOLDS: return "knee_folds";
    case FIT_CORE_EXERCISE_NAME_LOWER_LIFT: return "lower_lift";
    case FIT_CORE_EXERCISE_NAME_NECK_PULL: return "neck_pull";
    case FIT_CORE_EXERCISE_NAME_PELVIC_CLOCKS: return "pelvic_clocks";
    case FIT_CORE_EXERCISE_NAME_ROLL_OVER: return "roll_over";
    case FIT_CORE_EXERCISE_NAME_ROLL_UP: return "roll_up";
    case FIT_CORE_EXERCISE_NAME_ROLLING: return "rolling";
    case FIT_CORE_EXERCISE_NAME_ROWING_1: return "rowing_1";
    case FIT_CORE_EXERCISE_NAME_ROWING_2: return "rowing_2";
    case FIT_CORE_EXERCISE_NAME_SCISSORS: return "scissors";
    case FIT_CORE_EXERCISE_NAME_SINGLE_LEG_CIRCLES: return "single_leg_circles";
    case FIT_CORE_EXERCISE_NAME_SINGLE_LEG_STRETCH: return "single_leg_stretch";
    case FIT_CORE_EXERCISE_NAME_SNAKE_TWIST_1_AND_2: return "snake_twist_1_and_2";
    case FIT_CORE_EXERCISE_NAME_SWAN: return "swan";
    case FIT_CORE_EXERCISE_NAME_SWIMMING: return "swimming";
    case FIT_CORE_EXERCISE_NAME_TEASER: return "teaser";
    case FIT_CORE_EXERCISE_NAME_THE_HUNDRED: return "the_hundred";
    default: return nil
  }
}
func rzfit_activity_level_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_ACTIVITY_LEVEL_LOW: return "low";
    case FIT_ACTIVITY_LEVEL_MEDIUM: return "medium";
    case FIT_ACTIVITY_LEVEL_HIGH: return "high";
    default: return nil
  }
}

func rzfit_bike_light_beam_angle_mode_string(input : FIT_UINT8) -> String? 
{
  switch  input {
    case FIT_BIKE_LIGHT_BEAM_ANGLE_MODE_MANUAL: return "manual";
    case FIT_BIKE_LIGHT_BEAM_ANGLE_MODE_AUTO: return "auto";
    default: return nil
  }
}
func rzfit_turn_type_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_TURN_TYPE_ARRIVING_IDX: return "arriving_idx";
    case FIT_TURN_TYPE_ARRIVING_LEFT_IDX: return "arriving_left_idx";
    case FIT_TURN_TYPE_ARRIVING_RIGHT_IDX: return "arriving_right_idx";
    case FIT_TURN_TYPE_ARRIVING_VIA_IDX: return "arriving_via_idx";
    case FIT_TURN_TYPE_ARRIVING_VIA_LEFT_IDX: return "arriving_via_left_idx";
    case FIT_TURN_TYPE_ARRIVING_VIA_RIGHT_IDX: return "arriving_via_right_idx";
    case FIT_TURN_TYPE_BEAR_KEEP_LEFT_IDX: return "bear_keep_left_idx";
    case FIT_TURN_TYPE_BEAR_KEEP_RIGHT_IDX: return "bear_keep_right_idx";
    case FIT_TURN_TYPE_CONTINUE_IDX: return "continue_idx";
    case FIT_TURN_TYPE_EXIT_LEFT_IDX: return "exit_left_idx";
    case FIT_TURN_TYPE_EXIT_RIGHT_IDX: return "exit_right_idx";
    case FIT_TURN_TYPE_FERRY_IDX: return "ferry_idx";
    case FIT_TURN_TYPE_ROUNDABOUT_45_IDX: return "roundabout_45_idx";
    case FIT_TURN_TYPE_ROUNDABOUT_90_IDX: return "roundabout_90_idx";
    case FIT_TURN_TYPE_ROUNDABOUT_135_IDX: return "roundabout_135_idx";
    case FIT_TURN_TYPE_ROUNDABOUT_180_IDX: return "roundabout_180_idx";
    case FIT_TURN_TYPE_ROUNDABOUT_225_IDX: return "roundabout_225_idx";
    case FIT_TURN_TYPE_ROUNDABOUT_270_IDX: return "roundabout_270_idx";
    case FIT_TURN_TYPE_ROUNDABOUT_315_IDX: return "roundabout_315_idx";
    case FIT_TURN_TYPE_ROUNDABOUT_360_IDX: return "roundabout_360_idx";
    case FIT_TURN_TYPE_ROUNDABOUT_NEG_45_IDX: return "roundabout_neg_45_idx";
    case FIT_TURN_TYPE_ROUNDABOUT_NEG_90_IDX: return "roundabout_neg_90_idx";
    case FIT_TURN_TYPE_ROUNDABOUT_NEG_135_IDX: return "roundabout_neg_135_idx";
    case FIT_TURN_TYPE_ROUNDABOUT_NEG_180_IDX: return "roundabout_neg_180_idx";
    case FIT_TURN_TYPE_ROUNDABOUT_NEG_225_IDX: return "roundabout_neg_225_idx";
    case FIT_TURN_TYPE_ROUNDABOUT_NEG_270_IDX: return "roundabout_neg_270_idx";
    case FIT_TURN_TYPE_ROUNDABOUT_NEG_315_IDX: return "roundabout_neg_315_idx";
    case FIT_TURN_TYPE_ROUNDABOUT_NEG_360_IDX: return "roundabout_neg_360_idx";
    case FIT_TURN_TYPE_ROUNDABOUT_GENERIC_IDX: return "roundabout_generic_idx";
    case FIT_TURN_TYPE_ROUNDABOUT_NEG_GENERIC_IDX: return "roundabout_neg_generic_idx";
    case FIT_TURN_TYPE_SHARP_TURN_LEFT_IDX: return "sharp_turn_left_idx";
    case FIT_TURN_TYPE_SHARP_TURN_RIGHT_IDX: return "sharp_turn_right_idx";
    case FIT_TURN_TYPE_TURN_LEFT_IDX: return "turn_left_idx";
    case FIT_TURN_TYPE_TURN_RIGHT_IDX: return "turn_right_idx";
    case FIT_TURN_TYPE_UTURN_LEFT_IDX: return "uturn_left_idx";
    case FIT_TURN_TYPE_UTURN_RIGHT_IDX: return "uturn_right_idx";
    case FIT_TURN_TYPE_ICON_INV_IDX: return "icon_inv_idx";
    case FIT_TURN_TYPE_ICON_IDX_CNT: return "icon_idx_cnt";
    default: return nil
  }
}
func rzfit_camera_orientation_type_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_CAMERA_ORIENTATION_TYPE_CAMERA_ORIENTATION_0: return "camera_orientation_0";
    case FIT_CAMERA_ORIENTATION_TYPE_CAMERA_ORIENTATION_90: return "camera_orientation_90";
    case FIT_CAMERA_ORIENTATION_TYPE_CAMERA_ORIENTATION_180: return "camera_orientation_180";
    case FIT_CAMERA_ORIENTATION_TYPE_CAMERA_ORIENTATION_270: return "camera_orientation_270";
    default: return nil
  }
}
func rzfit_digital_watchface_layout_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_DIGITAL_WATCHFACE_LAYOUT_TRADITIONAL: return "traditional";
    case FIT_DIGITAL_WATCHFACE_LAYOUT_MODERN: return "modern";
    case FIT_DIGITAL_WATCHFACE_LAYOUT_BOLD: return "bold";
    default: return nil
  }
}
func rzfit_row_exercise_name_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_ROW_EXERCISE_NAME_BARBELL_STRAIGHT_LEG_DEADLIFT_TO_ROW: return "barbell_straight_leg_deadlift_to_row";
    case FIT_ROW_EXERCISE_NAME_CABLE_ROW_STANDING: return "cable_row_standing";
    case FIT_ROW_EXERCISE_NAME_DUMBBELL_ROW: return "dumbbell_row";
    case FIT_ROW_EXERCISE_NAME_ELEVATED_FEET_INVERTED_ROW: return "elevated_feet_inverted_row";
    case FIT_ROW_EXERCISE_NAME_WEIGHTED_ELEVATED_FEET_INVERTED_ROW: return "weighted_elevated_feet_inverted_row";
    case FIT_ROW_EXERCISE_NAME_FACE_PULL: return "face_pull";
    case FIT_ROW_EXERCISE_NAME_FACE_PULL_WITH_EXTERNAL_ROTATION: return "face_pull_with_external_rotation";
    case FIT_ROW_EXERCISE_NAME_INVERTED_ROW_WITH_FEET_ON_SWISS_BALL: return "inverted_row_with_feet_on_swiss_ball";
    case FIT_ROW_EXERCISE_NAME_WEIGHTED_INVERTED_ROW_WITH_FEET_ON_SWISS_BALL: return "weighted_inverted_row_with_feet_on_swiss_ball";
    case FIT_ROW_EXERCISE_NAME_KETTLEBELL_ROW: return "kettlebell_row";
    case FIT_ROW_EXERCISE_NAME_MODIFIED_INVERTED_ROW: return "modified_inverted_row";
    case FIT_ROW_EXERCISE_NAME_WEIGHTED_MODIFIED_INVERTED_ROW: return "weighted_modified_inverted_row";
    case FIT_ROW_EXERCISE_NAME_NEUTRAL_GRIP_ALTERNATING_DUMBBELL_ROW: return "neutral_grip_alternating_dumbbell_row";
    case FIT_ROW_EXERCISE_NAME_ONE_ARM_BENT_OVER_ROW: return "one_arm_bent_over_row";
    case FIT_ROW_EXERCISE_NAME_ONE_LEGGED_DUMBBELL_ROW: return "one_legged_dumbbell_row";
    case FIT_ROW_EXERCISE_NAME_RENEGADE_ROW: return "renegade_row";
    case FIT_ROW_EXERCISE_NAME_REVERSE_GRIP_BARBELL_ROW: return "reverse_grip_barbell_row";
    case FIT_ROW_EXERCISE_NAME_ROPE_HANDLE_CABLE_ROW: return "rope_handle_cable_row";
    case FIT_ROW_EXERCISE_NAME_SEATED_CABLE_ROW: return "seated_cable_row";
    case FIT_ROW_EXERCISE_NAME_SEATED_DUMBBELL_ROW: return "seated_dumbbell_row";
    case FIT_ROW_EXERCISE_NAME_SINGLE_ARM_CABLE_ROW: return "single_arm_cable_row";
    case FIT_ROW_EXERCISE_NAME_SINGLE_ARM_CABLE_ROW_AND_ROTATION: return "single_arm_cable_row_and_rotation";
    case FIT_ROW_EXERCISE_NAME_SINGLE_ARM_INVERTED_ROW: return "single_arm_inverted_row";
    case FIT_ROW_EXERCISE_NAME_WEIGHTED_SINGLE_ARM_INVERTED_ROW: return "weighted_single_arm_inverted_row";
    case FIT_ROW_EXERCISE_NAME_SINGLE_ARM_NEUTRAL_GRIP_DUMBBELL_ROW: return "single_arm_neutral_grip_dumbbell_row";
    case FIT_ROW_EXERCISE_NAME_SINGLE_ARM_NEUTRAL_GRIP_DUMBBELL_ROW_AND_ROTATION: return "single_arm_neutral_grip_dumbbell_row_and_rotation";
    case FIT_ROW_EXERCISE_NAME_SUSPENDED_INVERTED_ROW: return "suspended_inverted_row";
    case FIT_ROW_EXERCISE_NAME_WEIGHTED_SUSPENDED_INVERTED_ROW: return "weighted_suspended_inverted_row";
    case FIT_ROW_EXERCISE_NAME_T_BAR_ROW: return "t_bar_row";
    case FIT_ROW_EXERCISE_NAME_TOWEL_GRIP_INVERTED_ROW: return "towel_grip_inverted_row";
    case FIT_ROW_EXERCISE_NAME_WEIGHTED_TOWEL_GRIP_INVERTED_ROW: return "weighted_towel_grip_inverted_row";
    case FIT_ROW_EXERCISE_NAME_UNDERHAND_GRIP_CABLE_ROW: return "underhand_grip_cable_row";
    case FIT_ROW_EXERCISE_NAME_V_GRIP_CABLE_ROW: return "v_grip_cable_row";
    case FIT_ROW_EXERCISE_NAME_WIDE_GRIP_SEATED_CABLE_ROW: return "wide_grip_seated_cable_row";
    default: return nil
  }
}
func rzfit_tissue_model_type_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_TISSUE_MODEL_TYPE_ZHL_16C: return "zhl_16c";
    default: return nil
  }
}

func rzfit_source_type_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_SOURCE_TYPE_ANT: return "ant";
    case FIT_SOURCE_TYPE_ANTPLUS: return "antplus";
    case FIT_SOURCE_TYPE_BLUETOOTH: return "bluetooth";
    case FIT_SOURCE_TYPE_BLUETOOTH_LOW_ENERGY: return "bluetooth_low_energy";
    case FIT_SOURCE_TYPE_WIFI: return "wifi";
    case FIT_SOURCE_TYPE_LOCAL: return "local";
    default: return nil
  }
}
func rzfit_carry_exercise_name_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_CARRY_EXERCISE_NAME_BAR_HOLDS: return "bar_holds";
    case FIT_CARRY_EXERCISE_NAME_FARMERS_WALK: return "farmers_walk";
    case FIT_CARRY_EXERCISE_NAME_FARMERS_WALK_ON_TOES: return "farmers_walk_on_toes";
    case FIT_CARRY_EXERCISE_NAME_HEX_DUMBBELL_HOLD: return "hex_dumbbell_hold";
    case FIT_CARRY_EXERCISE_NAME_OVERHEAD_CARRY: return "overhead_carry";
    default: return nil
  }
}
func rzfit_sub_sport_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_SUB_SPORT_GENERIC: return "generic";
    case FIT_SUB_SPORT_TREADMILL: return "treadmill";
    case FIT_SUB_SPORT_STREET: return "street";
    case FIT_SUB_SPORT_TRAIL: return "trail";
    case FIT_SUB_SPORT_TRACK: return "track";
    case FIT_SUB_SPORT_SPIN: return "spin";
    case FIT_SUB_SPORT_INDOOR_CYCLING: return "indoor_cycling";
    case FIT_SUB_SPORT_ROAD: return "road";
    case FIT_SUB_SPORT_MOUNTAIN: return "mountain";
    case FIT_SUB_SPORT_DOWNHILL: return "downhill";
    case FIT_SUB_SPORT_RECUMBENT: return "recumbent";
    case FIT_SUB_SPORT_CYCLOCROSS: return "cyclocross";
    case FIT_SUB_SPORT_HAND_CYCLING: return "hand_cycling";
    case FIT_SUB_SPORT_TRACK_CYCLING: return "track_cycling";
    case FIT_SUB_SPORT_INDOOR_ROWING: return "indoor_rowing";
    case FIT_SUB_SPORT_ELLIPTICAL: return "elliptical";
    case FIT_SUB_SPORT_STAIR_CLIMBING: return "stair_climbing";
    case FIT_SUB_SPORT_LAP_SWIMMING: return "lap_swimming";
    case FIT_SUB_SPORT_OPEN_WATER: return "open_water";
    case FIT_SUB_SPORT_FLEXIBILITY_TRAINING: return "flexibility_training";
    case FIT_SUB_SPORT_STRENGTH_TRAINING: return "strength_training";
    case FIT_SUB_SPORT_WARM_UP: return "warm_up";
    case FIT_SUB_SPORT_MATCH: return "match";
    case FIT_SUB_SPORT_EXERCISE: return "exercise";
    case FIT_SUB_SPORT_CHALLENGE: return "challenge";
    case FIT_SUB_SPORT_INDOOR_SKIING: return "indoor_skiing";
    case FIT_SUB_SPORT_CARDIO_TRAINING: return "cardio_training";
    case FIT_SUB_SPORT_INDOOR_WALKING: return "indoor_walking";
    case FIT_SUB_SPORT_E_BIKE_FITNESS: return "e_bike_fitness";
    case FIT_SUB_SPORT_BMX: return "bmx";
    case FIT_SUB_SPORT_CASUAL_WALKING: return "casual_walking";
    case FIT_SUB_SPORT_SPEED_WALKING: return "speed_walking";
    case FIT_SUB_SPORT_BIKE_TO_RUN_TRANSITION: return "bike_to_run_transition";
    case FIT_SUB_SPORT_RUN_TO_BIKE_TRANSITION: return "run_to_bike_transition";
    case FIT_SUB_SPORT_SWIM_TO_BIKE_TRANSITION: return "swim_to_bike_transition";
    case FIT_SUB_SPORT_ATV: return "atv";
    case FIT_SUB_SPORT_MOTOCROSS: return "motocross";
    case FIT_SUB_SPORT_BACKCOUNTRY: return "backcountry";
    case FIT_SUB_SPORT_RESORT: return "resort";
    case FIT_SUB_SPORT_RC_DRONE: return "rc_drone";
    case FIT_SUB_SPORT_WINGSUIT: return "wingsuit";
    case FIT_SUB_SPORT_WHITEWATER: return "whitewater";
    case FIT_SUB_SPORT_SKATE_SKIING: return "skate_skiing";
    case FIT_SUB_SPORT_YOGA: return "yoga";
    case FIT_SUB_SPORT_PILATES: return "pilates";
    case FIT_SUB_SPORT_INDOOR_RUNNING: return "indoor_running";
    case FIT_SUB_SPORT_GRAVEL_CYCLING: return "gravel_cycling";
    case FIT_SUB_SPORT_E_BIKE_MOUNTAIN: return "e_bike_mountain";
    case FIT_SUB_SPORT_COMMUTING: return "commuting";
    case FIT_SUB_SPORT_MIXED_SURFACE: return "mixed_surface";
    case FIT_SUB_SPORT_NAVIGATE: return "navigate";
    case FIT_SUB_SPORT_TRACK_ME: return "track_me";
    case FIT_SUB_SPORT_MAP: return "map";
    case FIT_SUB_SPORT_SINGLE_GAS_DIVING: return "single_gas_diving";
    case FIT_SUB_SPORT_MULTI_GAS_DIVING: return "multi_gas_diving";
    case FIT_SUB_SPORT_GAUGE_DIVING: return "gauge_diving";
    case FIT_SUB_SPORT_APNEA_DIVING: return "apnea_diving";
    case FIT_SUB_SPORT_APNEA_HUNTING: return "apnea_hunting";
    case FIT_SUB_SPORT_VIRTUAL_ACTIVITY: return "virtual_activity";
    case FIT_SUB_SPORT_OBSTACLE: return "obstacle";
    case FIT_SUB_SPORT_ALL: return "all";
    default: return nil
  }
}
func rzfit_exd_data_units_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_EXD_DATA_UNITS_NO_UNITS: return "no_units";
    case FIT_EXD_DATA_UNITS_LAPS: return "laps";
    case FIT_EXD_DATA_UNITS_MILES_PER_HOUR: return "miles_per_hour";
    case FIT_EXD_DATA_UNITS_KILOMETERS_PER_HOUR: return "kilometers_per_hour";
    case FIT_EXD_DATA_UNITS_FEET_PER_HOUR: return "feet_per_hour";
    case FIT_EXD_DATA_UNITS_METERS_PER_HOUR: return "meters_per_hour";
    case FIT_EXD_DATA_UNITS_DEGREES_CELSIUS: return "degrees_celsius";
    case FIT_EXD_DATA_UNITS_DEGREES_FARENHEIT: return "degrees_farenheit";
    case FIT_EXD_DATA_UNITS_ZONE: return "zone";
    case FIT_EXD_DATA_UNITS_GEAR: return "gear";
    case FIT_EXD_DATA_UNITS_RPM: return "rpm";
    case FIT_EXD_DATA_UNITS_BPM: return "bpm";
    case FIT_EXD_DATA_UNITS_DEGREES: return "degrees";
    case FIT_EXD_DATA_UNITS_MILLIMETERS: return "millimeters";
    case FIT_EXD_DATA_UNITS_METERS: return "meters";
    case FIT_EXD_DATA_UNITS_KILOMETERS: return "kilometers";
    case FIT_EXD_DATA_UNITS_FEET: return "feet";
    case FIT_EXD_DATA_UNITS_YARDS: return "yards";
    case FIT_EXD_DATA_UNITS_KILOFEET: return "kilofeet";
    case FIT_EXD_DATA_UNITS_MILES: return "miles";
    case FIT_EXD_DATA_UNITS_TIME: return "time";
    case FIT_EXD_DATA_UNITS_ENUM_TURN_TYPE: return "enum_turn_type";
    case FIT_EXD_DATA_UNITS_PERCENT: return "percent";
    case FIT_EXD_DATA_UNITS_WATTS: return "watts";
    case FIT_EXD_DATA_UNITS_WATTS_PER_KILOGRAM: return "watts_per_kilogram";
    case FIT_EXD_DATA_UNITS_ENUM_BATTERY_STATUS: return "enum_battery_status";
    case FIT_EXD_DATA_UNITS_ENUM_BIKE_LIGHT_BEAM_ANGLE_MODE: return "enum_bike_light_beam_angle_mode";
    case FIT_EXD_DATA_UNITS_ENUM_BIKE_LIGHT_BATTERY_STATUS: return "enum_bike_light_battery_status";
    case FIT_EXD_DATA_UNITS_ENUM_BIKE_LIGHT_NETWORK_CONFIG_TYPE: return "enum_bike_light_network_config_type";
    case FIT_EXD_DATA_UNITS_LIGHTS: return "lights";
    case FIT_EXD_DATA_UNITS_SECONDS: return "seconds";
    case FIT_EXD_DATA_UNITS_MINUTES: return "minutes";
    case FIT_EXD_DATA_UNITS_HOURS: return "hours";
    case FIT_EXD_DATA_UNITS_CALORIES: return "calories";
    case FIT_EXD_DATA_UNITS_KILOJOULES: return "kilojoules";
    case FIT_EXD_DATA_UNITS_MILLISECONDS: return "milliseconds";
    case FIT_EXD_DATA_UNITS_SECOND_PER_MILE: return "second_per_mile";
    case FIT_EXD_DATA_UNITS_SECOND_PER_KILOMETER: return "second_per_kilometer";
    case FIT_EXD_DATA_UNITS_CENTIMETER: return "centimeter";
    case FIT_EXD_DATA_UNITS_ENUM_COURSE_POINT: return "enum_course_point";
    case FIT_EXD_DATA_UNITS_BRADIANS: return "bradians";
    case FIT_EXD_DATA_UNITS_ENUM_SPORT: return "enum_sport";
    case FIT_EXD_DATA_UNITS_INCHES_HG: return "inches_hg";
    case FIT_EXD_DATA_UNITS_MM_HG: return "mm_hg";
    case FIT_EXD_DATA_UNITS_MBARS: return "mbars";
    case FIT_EXD_DATA_UNITS_HECTO_PASCALS: return "hecto_pascals";
    case FIT_EXD_DATA_UNITS_FEET_PER_MIN: return "feet_per_min";
    case FIT_EXD_DATA_UNITS_METERS_PER_MIN: return "meters_per_min";
    case FIT_EXD_DATA_UNITS_METERS_PER_SEC: return "meters_per_sec";
    case FIT_EXD_DATA_UNITS_EIGHT_CARDINAL: return "eight_cardinal";
    default: return nil
  }
}
func rzfit_time_zone_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_TIME_ZONE_ALMATY: return "almaty";
    case FIT_TIME_ZONE_BANGKOK: return "bangkok";
    case FIT_TIME_ZONE_BOMBAY: return "bombay";
    case FIT_TIME_ZONE_BRASILIA: return "brasilia";
    case FIT_TIME_ZONE_CAIRO: return "cairo";
    case FIT_TIME_ZONE_CAPE_VERDE_IS: return "cape_verde_is";
    case FIT_TIME_ZONE_DARWIN: return "darwin";
    case FIT_TIME_ZONE_ENIWETOK: return "eniwetok";
    case FIT_TIME_ZONE_FIJI: return "fiji";
    case FIT_TIME_ZONE_HONG_KONG: return "hong_kong";
    case FIT_TIME_ZONE_ISLAMABAD: return "islamabad";
    case FIT_TIME_ZONE_KABUL: return "kabul";
    case FIT_TIME_ZONE_MAGADAN: return "magadan";
    case FIT_TIME_ZONE_MID_ATLANTIC: return "mid_atlantic";
    case FIT_TIME_ZONE_MOSCOW: return "moscow";
    case FIT_TIME_ZONE_MUSCAT: return "muscat";
    case FIT_TIME_ZONE_NEWFOUNDLAND: return "newfoundland";
    case FIT_TIME_ZONE_SAMOA: return "samoa";
    case FIT_TIME_ZONE_SYDNEY: return "sydney";
    case FIT_TIME_ZONE_TEHRAN: return "tehran";
    case FIT_TIME_ZONE_TOKYO: return "tokyo";
    case FIT_TIME_ZONE_US_ALASKA: return "us_alaska";
    case FIT_TIME_ZONE_US_ATLANTIC: return "us_atlantic";
    case FIT_TIME_ZONE_US_CENTRAL: return "us_central";
    case FIT_TIME_ZONE_US_EASTERN: return "us_eastern";
    case FIT_TIME_ZONE_US_HAWAII: return "us_hawaii";
    case FIT_TIME_ZONE_US_MOUNTAIN: return "us_mountain";
    case FIT_TIME_ZONE_US_PACIFIC: return "us_pacific";
    case FIT_TIME_ZONE_OTHER: return "other";
    case FIT_TIME_ZONE_AUCKLAND: return "auckland";
    case FIT_TIME_ZONE_KATHMANDU: return "kathmandu";
    case FIT_TIME_ZONE_EUROPE_WESTERN_WET: return "europe_western_wet";
    case FIT_TIME_ZONE_EUROPE_CENTRAL_CET: return "europe_central_cet";
    case FIT_TIME_ZONE_EUROPE_EASTERN_EET: return "europe_eastern_eet";
    case FIT_TIME_ZONE_JAKARTA: return "jakarta";
    case FIT_TIME_ZONE_PERTH: return "perth";
    case FIT_TIME_ZONE_ADELAIDE: return "adelaide";
    case FIT_TIME_ZONE_BRISBANE: return "brisbane";
    case FIT_TIME_ZONE_TASMANIA: return "tasmania";
    case FIT_TIME_ZONE_ICELAND: return "iceland";
    case FIT_TIME_ZONE_AMSTERDAM: return "amsterdam";
    case FIT_TIME_ZONE_ATHENS: return "athens";
    case FIT_TIME_ZONE_BARCELONA: return "barcelona";
    case FIT_TIME_ZONE_BERLIN: return "berlin";
    case FIT_TIME_ZONE_BRUSSELS: return "brussels";
    case FIT_TIME_ZONE_BUDAPEST: return "budapest";
    case FIT_TIME_ZONE_COPENHAGEN: return "copenhagen";
    case FIT_TIME_ZONE_DUBLIN: return "dublin";
    case FIT_TIME_ZONE_HELSINKI: return "helsinki";
    case FIT_TIME_ZONE_LISBON: return "lisbon";
    case FIT_TIME_ZONE_LONDON: return "london";
    case FIT_TIME_ZONE_MADRID: return "madrid";
    case FIT_TIME_ZONE_MUNICH: return "munich";
    case FIT_TIME_ZONE_OSLO: return "oslo";
    case FIT_TIME_ZONE_PARIS: return "paris";
    case FIT_TIME_ZONE_PRAGUE: return "prague";
    case FIT_TIME_ZONE_REYKJAVIK: return "reykjavik";
    case FIT_TIME_ZONE_ROME: return "rome";
    case FIT_TIME_ZONE_STOCKHOLM: return "stockholm";
    case FIT_TIME_ZONE_VIENNA: return "vienna";
    case FIT_TIME_ZONE_WARSAW: return "warsaw";
    case FIT_TIME_ZONE_ZURICH: return "zurich";
    case FIT_TIME_ZONE_QUEBEC: return "quebec";
    case FIT_TIME_ZONE_ONTARIO: return "ontario";
    case FIT_TIME_ZONE_MANITOBA: return "manitoba";
    case FIT_TIME_ZONE_SASKATCHEWAN: return "saskatchewan";
    case FIT_TIME_ZONE_ALBERTA: return "alberta";
    case FIT_TIME_ZONE_BRITISH_COLUMBIA: return "british_columbia";
    case FIT_TIME_ZONE_BOISE: return "boise";
    case FIT_TIME_ZONE_BOSTON: return "boston";
    case FIT_TIME_ZONE_CHICAGO: return "chicago";
    case FIT_TIME_ZONE_DALLAS: return "dallas";
    case FIT_TIME_ZONE_DENVER: return "denver";
    case FIT_TIME_ZONE_KANSAS_CITY: return "kansas_city";
    case FIT_TIME_ZONE_LAS_VEGAS: return "las_vegas";
    case FIT_TIME_ZONE_LOS_ANGELES: return "los_angeles";
    case FIT_TIME_ZONE_MIAMI: return "miami";
    case FIT_TIME_ZONE_MINNEAPOLIS: return "minneapolis";
    case FIT_TIME_ZONE_NEW_YORK: return "new_york";
    case FIT_TIME_ZONE_NEW_ORLEANS: return "new_orleans";
    case FIT_TIME_ZONE_PHOENIX: return "phoenix";
    case FIT_TIME_ZONE_SANTA_FE: return "santa_fe";
    case FIT_TIME_ZONE_SEATTLE: return "seattle";
    case FIT_TIME_ZONE_WASHINGTON_DC: return "washington_dc";
    case FIT_TIME_ZONE_US_ARIZONA: return "us_arizona";
    case FIT_TIME_ZONE_CHITA: return "chita";
    case FIT_TIME_ZONE_EKATERINBURG: return "ekaterinburg";
    case FIT_TIME_ZONE_IRKUTSK: return "irkutsk";
    case FIT_TIME_ZONE_KALININGRAD: return "kaliningrad";
    case FIT_TIME_ZONE_KRASNOYARSK: return "krasnoyarsk";
    case FIT_TIME_ZONE_NOVOSIBIRSK: return "novosibirsk";
    case FIT_TIME_ZONE_PETROPAVLOVSK_KAMCHATSKIY: return "petropavlovsk_kamchatskiy";
    case FIT_TIME_ZONE_SAMARA: return "samara";
    case FIT_TIME_ZONE_VLADIVOSTOK: return "vladivostok";
    case FIT_TIME_ZONE_MEXICO_CENTRAL: return "mexico_central";
    case FIT_TIME_ZONE_MEXICO_MOUNTAIN: return "mexico_mountain";
    case FIT_TIME_ZONE_MEXICO_PACIFIC: return "mexico_pacific";
    case FIT_TIME_ZONE_CAPE_TOWN: return "cape_town";
    case FIT_TIME_ZONE_WINKHOEK: return "winkhoek";
    case FIT_TIME_ZONE_LAGOS: return "lagos";
    case FIT_TIME_ZONE_RIYAHD: return "riyahd";
    case FIT_TIME_ZONE_VENEZUELA: return "venezuela";
    case FIT_TIME_ZONE_AUSTRALIA_LH: return "australia_lh";
    case FIT_TIME_ZONE_SANTIAGO: return "santiago";
    case FIT_TIME_ZONE_MANUAL: return "manual";
    case FIT_TIME_ZONE_AUTOMATIC: return "automatic";
    default: return nil
  }
}

func rzfit_bench_press_exercise_name_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_BENCH_PRESS_EXERCISE_NAME_ALTERNATING_DUMBBELL_CHEST_PRESS_ON_SWISS_BALL: return "alternating_dumbbell_chest_press_on_swiss_ball";
    case FIT_BENCH_PRESS_EXERCISE_NAME_BARBELL_BENCH_PRESS: return "barbell_bench_press";
    case FIT_BENCH_PRESS_EXERCISE_NAME_BARBELL_BOARD_BENCH_PRESS: return "barbell_board_bench_press";
    case FIT_BENCH_PRESS_EXERCISE_NAME_BARBELL_FLOOR_PRESS: return "barbell_floor_press";
    case FIT_BENCH_PRESS_EXERCISE_NAME_CLOSE_GRIP_BARBELL_BENCH_PRESS: return "close_grip_barbell_bench_press";
    case FIT_BENCH_PRESS_EXERCISE_NAME_DECLINE_DUMBBELL_BENCH_PRESS: return "decline_dumbbell_bench_press";
    case FIT_BENCH_PRESS_EXERCISE_NAME_DUMBBELL_BENCH_PRESS: return "dumbbell_bench_press";
    case FIT_BENCH_PRESS_EXERCISE_NAME_DUMBBELL_FLOOR_PRESS: return "dumbbell_floor_press";
    case FIT_BENCH_PRESS_EXERCISE_NAME_INCLINE_BARBELL_BENCH_PRESS: return "incline_barbell_bench_press";
    case FIT_BENCH_PRESS_EXERCISE_NAME_INCLINE_DUMBBELL_BENCH_PRESS: return "incline_dumbbell_bench_press";
    case FIT_BENCH_PRESS_EXERCISE_NAME_INCLINE_SMITH_MACHINE_BENCH_PRESS: return "incline_smith_machine_bench_press";
    case FIT_BENCH_PRESS_EXERCISE_NAME_ISOMETRIC_BARBELL_BENCH_PRESS: return "isometric_barbell_bench_press";
    case FIT_BENCH_PRESS_EXERCISE_NAME_KETTLEBELL_CHEST_PRESS: return "kettlebell_chest_press";
    case FIT_BENCH_PRESS_EXERCISE_NAME_NEUTRAL_GRIP_DUMBBELL_BENCH_PRESS: return "neutral_grip_dumbbell_bench_press";
    case FIT_BENCH_PRESS_EXERCISE_NAME_NEUTRAL_GRIP_DUMBBELL_INCLINE_BENCH_PRESS: return "neutral_grip_dumbbell_incline_bench_press";
    case FIT_BENCH_PRESS_EXERCISE_NAME_ONE_ARM_FLOOR_PRESS: return "one_arm_floor_press";
    case FIT_BENCH_PRESS_EXERCISE_NAME_WEIGHTED_ONE_ARM_FLOOR_PRESS: return "weighted_one_arm_floor_press";
    case FIT_BENCH_PRESS_EXERCISE_NAME_PARTIAL_LOCKOUT: return "partial_lockout";
    case FIT_BENCH_PRESS_EXERCISE_NAME_REVERSE_GRIP_BARBELL_BENCH_PRESS: return "reverse_grip_barbell_bench_press";
    case FIT_BENCH_PRESS_EXERCISE_NAME_REVERSE_GRIP_INCLINE_BENCH_PRESS: return "reverse_grip_incline_bench_press";
    case FIT_BENCH_PRESS_EXERCISE_NAME_SINGLE_ARM_CABLE_CHEST_PRESS: return "single_arm_cable_chest_press";
    case FIT_BENCH_PRESS_EXERCISE_NAME_SINGLE_ARM_DUMBBELL_BENCH_PRESS: return "single_arm_dumbbell_bench_press";
    case FIT_BENCH_PRESS_EXERCISE_NAME_SMITH_MACHINE_BENCH_PRESS: return "smith_machine_bench_press";
    case FIT_BENCH_PRESS_EXERCISE_NAME_SWISS_BALL_DUMBBELL_CHEST_PRESS: return "swiss_ball_dumbbell_chest_press";
    case FIT_BENCH_PRESS_EXERCISE_NAME_TRIPLE_STOP_BARBELL_BENCH_PRESS: return "triple_stop_barbell_bench_press";
    case FIT_BENCH_PRESS_EXERCISE_NAME_WIDE_GRIP_BARBELL_BENCH_PRESS: return "wide_grip_barbell_bench_press";
    case FIT_BENCH_PRESS_EXERCISE_NAME_ALTERNATING_DUMBBELL_CHEST_PRESS: return "alternating_dumbbell_chest_press";
    default: return nil
  }
}
func rzfit_segment_selection_type_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_SEGMENT_SELECTION_TYPE_STARRED: return "starred";
    case FIT_SEGMENT_SELECTION_TYPE_SUGGESTED: return "suggested";
    default: return nil
  }
}

func rzfit_segment_leaderboard_type_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_SEGMENT_LEADERBOARD_TYPE_OVERALL: return "overall";
    case FIT_SEGMENT_LEADERBOARD_TYPE_PERSONAL_BEST: return "personal_best";
    case FIT_SEGMENT_LEADERBOARD_TYPE_CONNECTIONS: return "connections";
    case FIT_SEGMENT_LEADERBOARD_TYPE_GROUP: return "group";
    case FIT_SEGMENT_LEADERBOARD_TYPE_CHALLENGER: return "challenger";
    case FIT_SEGMENT_LEADERBOARD_TYPE_KOM: return "kom";
    case FIT_SEGMENT_LEADERBOARD_TYPE_QOM: return "qom";
    case FIT_SEGMENT_LEADERBOARD_TYPE_PR: return "pr";
    case FIT_SEGMENT_LEADERBOARD_TYPE_GOAL: return "goal";
    case FIT_SEGMENT_LEADERBOARD_TYPE_RIVAL: return "rival";
    case FIT_SEGMENT_LEADERBOARD_TYPE_CLUB_LEADER: return "club_leader";
    default: return nil
  }
}
func rzfit_ant_network_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_ANT_NETWORK_PUBLIC: return "public";
    case FIT_ANT_NETWORK_ANTPLUS: return "antplus";
    case FIT_ANT_NETWORK_ANTFS: return "antfs";
    case FIT_ANT_NETWORK_PRIVATE: return "private";
    default: return nil
  }
}
func rzfit_schedule_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_SCHEDULE_WORKOUT: return "workout";
    case FIT_SCHEDULE_COURSE: return "course";
    default: return nil
  }
}
func rzfit_workout_equipment_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_WORKOUT_EQUIPMENT_NONE: return "none";
    case FIT_WORKOUT_EQUIPMENT_SWIM_FINS: return "swim_fins";
    case FIT_WORKOUT_EQUIPMENT_SWIM_KICKBOARD: return "swim_kickboard";
    case FIT_WORKOUT_EQUIPMENT_SWIM_PADDLES: return "swim_paddles";
    case FIT_WORKOUT_EQUIPMENT_SWIM_PULL_BUOY: return "swim_pull_buoy";
    case FIT_WORKOUT_EQUIPMENT_SWIM_SNORKEL: return "swim_snorkel";
    default: return nil
  }
}
func rzfit_fit_base_unit_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_FIT_BASE_UNIT_OTHER: return "other";
    case FIT_FIT_BASE_UNIT_KILOGRAM: return "kilogram";
    case FIT_FIT_BASE_UNIT_POUND: return "pound";
    default: return nil
  }
}







func rzfit_lap_trigger_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_LAP_TRIGGER_MANUAL: return "manual";
    case FIT_LAP_TRIGGER_TIME: return "time";
    case FIT_LAP_TRIGGER_DISTANCE: return "distance";
    case FIT_LAP_TRIGGER_POSITION_START: return "position_start";
    case FIT_LAP_TRIGGER_POSITION_LAP: return "position_lap";
    case FIT_LAP_TRIGGER_POSITION_WAYPOINT: return "position_waypoint";
    case FIT_LAP_TRIGGER_POSITION_MARKED: return "position_marked";
    case FIT_LAP_TRIGGER_SESSION_END: return "session_end";
    case FIT_LAP_TRIGGER_FITNESS_EQUIPMENT: return "fitness_equipment";
    default: return nil
  }
}
func rzfit_weather_severity_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_WEATHER_SEVERITY_UNKNOWN: return "unknown";
    case FIT_WEATHER_SEVERITY_WARNING: return "warning";
    case FIT_WEATHER_SEVERITY_WATCH: return "watch";
    case FIT_WEATHER_SEVERITY_ADVISORY: return "advisory";
    case FIT_WEATHER_SEVERITY_STATEMENT: return "statement";
    default: return nil
  }
}
func rzfit_auto_sync_frequency_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_AUTO_SYNC_FREQUENCY_NEVER: return "never";
    case FIT_AUTO_SYNC_FREQUENCY_OCCASIONALLY: return "occasionally";
    case FIT_AUTO_SYNC_FREQUENCY_FREQUENT: return "frequent";
    case FIT_AUTO_SYNC_FREQUENCY_ONCE_A_DAY: return "once_a_day";
    case FIT_AUTO_SYNC_FREQUENCY_REMOTE: return "remote";
    default: return nil
  }
}
func rzfit_shoulder_stability_exercise_name_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_SHOULDER_STABILITY_EXERCISE_NAME_90_DEGREE_CABLE_EXTERNAL_ROTATION: return "90_degree_cable_external_rotation";
    case FIT_SHOULDER_STABILITY_EXERCISE_NAME_BAND_EXTERNAL_ROTATION: return "band_external_rotation";
    case FIT_SHOULDER_STABILITY_EXERCISE_NAME_BAND_INTERNAL_ROTATION: return "band_internal_rotation";
    case FIT_SHOULDER_STABILITY_EXERCISE_NAME_BENT_ARM_LATERAL_RAISE_AND_EXTERNAL_ROTATION: return "bent_arm_lateral_raise_and_external_rotation";
    case FIT_SHOULDER_STABILITY_EXERCISE_NAME_CABLE_EXTERNAL_ROTATION: return "cable_external_rotation";
    case FIT_SHOULDER_STABILITY_EXERCISE_NAME_DUMBBELL_FACE_PULL_WITH_EXTERNAL_ROTATION: return "dumbbell_face_pull_with_external_rotation";
    case FIT_SHOULDER_STABILITY_EXERCISE_NAME_FLOOR_I_RAISE: return "floor_i_raise";
    case FIT_SHOULDER_STABILITY_EXERCISE_NAME_WEIGHTED_FLOOR_I_RAISE: return "weighted_floor_i_raise";
    case FIT_SHOULDER_STABILITY_EXERCISE_NAME_FLOOR_T_RAISE: return "floor_t_raise";
    case FIT_SHOULDER_STABILITY_EXERCISE_NAME_WEIGHTED_FLOOR_T_RAISE: return "weighted_floor_t_raise";
    case FIT_SHOULDER_STABILITY_EXERCISE_NAME_FLOOR_Y_RAISE: return "floor_y_raise";
    case FIT_SHOULDER_STABILITY_EXERCISE_NAME_WEIGHTED_FLOOR_Y_RAISE: return "weighted_floor_y_raise";
    case FIT_SHOULDER_STABILITY_EXERCISE_NAME_INCLINE_I_RAISE: return "incline_i_raise";
    case FIT_SHOULDER_STABILITY_EXERCISE_NAME_WEIGHTED_INCLINE_I_RAISE: return "weighted_incline_i_raise";
    case FIT_SHOULDER_STABILITY_EXERCISE_NAME_INCLINE_L_RAISE: return "incline_l_raise";
    case FIT_SHOULDER_STABILITY_EXERCISE_NAME_WEIGHTED_INCLINE_L_RAISE: return "weighted_incline_l_raise";
    case FIT_SHOULDER_STABILITY_EXERCISE_NAME_INCLINE_T_RAISE: return "incline_t_raise";
    case FIT_SHOULDER_STABILITY_EXERCISE_NAME_WEIGHTED_INCLINE_T_RAISE: return "weighted_incline_t_raise";
    case FIT_SHOULDER_STABILITY_EXERCISE_NAME_INCLINE_W_RAISE: return "incline_w_raise";
    case FIT_SHOULDER_STABILITY_EXERCISE_NAME_WEIGHTED_INCLINE_W_RAISE: return "weighted_incline_w_raise";
    case FIT_SHOULDER_STABILITY_EXERCISE_NAME_INCLINE_Y_RAISE: return "incline_y_raise";
    case FIT_SHOULDER_STABILITY_EXERCISE_NAME_WEIGHTED_INCLINE_Y_RAISE: return "weighted_incline_y_raise";
    case FIT_SHOULDER_STABILITY_EXERCISE_NAME_LYING_EXTERNAL_ROTATION: return "lying_external_rotation";
    case FIT_SHOULDER_STABILITY_EXERCISE_NAME_SEATED_DUMBBELL_EXTERNAL_ROTATION: return "seated_dumbbell_external_rotation";
    case FIT_SHOULDER_STABILITY_EXERCISE_NAME_STANDING_L_RAISE: return "standing_l_raise";
    case FIT_SHOULDER_STABILITY_EXERCISE_NAME_SWISS_BALL_I_RAISE: return "swiss_ball_i_raise";
    case FIT_SHOULDER_STABILITY_EXERCISE_NAME_WEIGHTED_SWISS_BALL_I_RAISE: return "weighted_swiss_ball_i_raise";
    case FIT_SHOULDER_STABILITY_EXERCISE_NAME_SWISS_BALL_T_RAISE: return "swiss_ball_t_raise";
    case FIT_SHOULDER_STABILITY_EXERCISE_NAME_WEIGHTED_SWISS_BALL_T_RAISE: return "weighted_swiss_ball_t_raise";
    case FIT_SHOULDER_STABILITY_EXERCISE_NAME_SWISS_BALL_W_RAISE: return "swiss_ball_w_raise";
    case FIT_SHOULDER_STABILITY_EXERCISE_NAME_WEIGHTED_SWISS_BALL_W_RAISE: return "weighted_swiss_ball_w_raise";
    case FIT_SHOULDER_STABILITY_EXERCISE_NAME_SWISS_BALL_Y_RAISE: return "swiss_ball_y_raise";
    case FIT_SHOULDER_STABILITY_EXERCISE_NAME_WEIGHTED_SWISS_BALL_Y_RAISE: return "weighted_swiss_ball_y_raise";
    default: return nil
  }
}
func rzfit_camera_event_type_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_CAMERA_EVENT_TYPE_VIDEO_START: return "video_start";
    case FIT_CAMERA_EVENT_TYPE_VIDEO_SPLIT: return "video_split";
    case FIT_CAMERA_EVENT_TYPE_VIDEO_END: return "video_end";
    case FIT_CAMERA_EVENT_TYPE_PHOTO_TAKEN: return "photo_taken";
    case FIT_CAMERA_EVENT_TYPE_VIDEO_SECOND_STREAM_START: return "video_second_stream_start";
    case FIT_CAMERA_EVENT_TYPE_VIDEO_SECOND_STREAM_SPLIT: return "video_second_stream_split";
    case FIT_CAMERA_EVENT_TYPE_VIDEO_SECOND_STREAM_END: return "video_second_stream_end";
    case FIT_CAMERA_EVENT_TYPE_VIDEO_SPLIT_START: return "video_split_start";
    case FIT_CAMERA_EVENT_TYPE_VIDEO_SECOND_STREAM_SPLIT_START: return "video_second_stream_split_start";
    case FIT_CAMERA_EVENT_TYPE_VIDEO_PAUSE: return "video_pause";
    case FIT_CAMERA_EVENT_TYPE_VIDEO_SECOND_STREAM_PAUSE: return "video_second_stream_pause";
    case FIT_CAMERA_EVENT_TYPE_VIDEO_RESUME: return "video_resume";
    case FIT_CAMERA_EVENT_TYPE_VIDEO_SECOND_STREAM_RESUME: return "video_second_stream_resume";
    default: return nil
  }
}
func rzfit_length_type_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_LENGTH_TYPE_IDLE: return "idle";
    case FIT_LENGTH_TYPE_ACTIVE: return "active";
    default: return nil
  }
}
func rzfit_day_of_week_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_DAY_OF_WEEK_SUNDAY: return "sunday";
    case FIT_DAY_OF_WEEK_MONDAY: return "monday";
    case FIT_DAY_OF_WEEK_TUESDAY: return "tuesday";
    case FIT_DAY_OF_WEEK_WEDNESDAY: return "wednesday";
    case FIT_DAY_OF_WEEK_THURSDAY: return "thursday";
    case FIT_DAY_OF_WEEK_FRIDAY: return "friday";
    case FIT_DAY_OF_WEEK_SATURDAY: return "saturday";
    default: return nil
  }
}
func rzfit_warm_up_exercise_name_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_WARM_UP_EXERCISE_NAME_QUADRUPED_ROCKING: return "quadruped_rocking";
    case FIT_WARM_UP_EXERCISE_NAME_NECK_TILTS: return "neck_tilts";
    case FIT_WARM_UP_EXERCISE_NAME_ANKLE_CIRCLES: return "ankle_circles";
    case FIT_WARM_UP_EXERCISE_NAME_ANKLE_DORSIFLEXION_WITH_BAND: return "ankle_dorsiflexion_with_band";
    case FIT_WARM_UP_EXERCISE_NAME_ANKLE_INTERNAL_ROTATION: return "ankle_internal_rotation";
    case FIT_WARM_UP_EXERCISE_NAME_ARM_CIRCLES: return "arm_circles";
    case FIT_WARM_UP_EXERCISE_NAME_BENT_OVER_REACH_TO_SKY: return "bent_over_reach_to_sky";
    case FIT_WARM_UP_EXERCISE_NAME_CAT_CAMEL: return "cat_camel";
    case FIT_WARM_UP_EXERCISE_NAME_ELBOW_TO_FOOT_LUNGE: return "elbow_to_foot_lunge";
    case FIT_WARM_UP_EXERCISE_NAME_FORWARD_AND_BACKWARD_LEG_SWINGS: return "forward_and_backward_leg_swings";
    case FIT_WARM_UP_EXERCISE_NAME_GROINERS: return "groiners";
    case FIT_WARM_UP_EXERCISE_NAME_INVERTED_HAMSTRING_STRETCH: return "inverted_hamstring_stretch";
    case FIT_WARM_UP_EXERCISE_NAME_LATERAL_DUCK_UNDER: return "lateral_duck_under";
    case FIT_WARM_UP_EXERCISE_NAME_NECK_ROTATIONS: return "neck_rotations";
    case FIT_WARM_UP_EXERCISE_NAME_OPPOSITE_ARM_AND_LEG_BALANCE: return "opposite_arm_and_leg_balance";
    case FIT_WARM_UP_EXERCISE_NAME_REACH_ROLL_AND_LIFT: return "reach_roll_and_lift";
    case FIT_WARM_UP_EXERCISE_NAME_SCORPION: return "scorpion";
    case FIT_WARM_UP_EXERCISE_NAME_SHOULDER_CIRCLES: return "shoulder_circles";
    case FIT_WARM_UP_EXERCISE_NAME_SIDE_TO_SIDE_LEG_SWINGS: return "side_to_side_leg_swings";
    case FIT_WARM_UP_EXERCISE_NAME_SLEEPER_STRETCH: return "sleeper_stretch";
    case FIT_WARM_UP_EXERCISE_NAME_SLIDE_OUT: return "slide_out";
    case FIT_WARM_UP_EXERCISE_NAME_SWISS_BALL_HIP_CROSSOVER: return "swiss_ball_hip_crossover";
    case FIT_WARM_UP_EXERCISE_NAME_SWISS_BALL_REACH_ROLL_AND_LIFT: return "swiss_ball_reach_roll_and_lift";
    case FIT_WARM_UP_EXERCISE_NAME_SWISS_BALL_WINDSHIELD_WIPERS: return "swiss_ball_windshield_wipers";
    case FIT_WARM_UP_EXERCISE_NAME_THORACIC_ROTATION: return "thoracic_rotation";
    case FIT_WARM_UP_EXERCISE_NAME_WALKING_HIGH_KICKS: return "walking_high_kicks";
    case FIT_WARM_UP_EXERCISE_NAME_WALKING_HIGH_KNEES: return "walking_high_knees";
    case FIT_WARM_UP_EXERCISE_NAME_WALKING_KNEE_HUGS: return "walking_knee_hugs";
    case FIT_WARM_UP_EXERCISE_NAME_WALKING_LEG_CRADLES: return "walking_leg_cradles";
    case FIT_WARM_UP_EXERCISE_NAME_WALKOUT: return "walkout";
    case FIT_WARM_UP_EXERCISE_NAME_WALKOUT_FROM_PUSH_UP_POSITION: return "walkout_from_push_up_position";
    default: return nil
  }
}
func rzfit_calf_raise_exercise_name_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_CALF_RAISE_EXERCISE_NAME_3_WAY_CALF_RAISE: return "3_way_calf_raise";
    case FIT_CALF_RAISE_EXERCISE_NAME_3_WAY_WEIGHTED_CALF_RAISE: return "3_way_weighted_calf_raise";
    case FIT_CALF_RAISE_EXERCISE_NAME_3_WAY_SINGLE_LEG_CALF_RAISE: return "3_way_single_leg_calf_raise";
    case FIT_CALF_RAISE_EXERCISE_NAME_3_WAY_WEIGHTED_SINGLE_LEG_CALF_RAISE: return "3_way_weighted_single_leg_calf_raise";
    case FIT_CALF_RAISE_EXERCISE_NAME_DONKEY_CALF_RAISE: return "donkey_calf_raise";
    case FIT_CALF_RAISE_EXERCISE_NAME_WEIGHTED_DONKEY_CALF_RAISE: return "weighted_donkey_calf_raise";
    case FIT_CALF_RAISE_EXERCISE_NAME_SEATED_CALF_RAISE: return "seated_calf_raise";
    case FIT_CALF_RAISE_EXERCISE_NAME_WEIGHTED_SEATED_CALF_RAISE: return "weighted_seated_calf_raise";
    case FIT_CALF_RAISE_EXERCISE_NAME_SEATED_DUMBBELL_TOE_RAISE: return "seated_dumbbell_toe_raise";
    case FIT_CALF_RAISE_EXERCISE_NAME_SINGLE_LEG_BENT_KNEE_CALF_RAISE: return "single_leg_bent_knee_calf_raise";
    case FIT_CALF_RAISE_EXERCISE_NAME_WEIGHTED_SINGLE_LEG_BENT_KNEE_CALF_RAISE: return "weighted_single_leg_bent_knee_calf_raise";
    case FIT_CALF_RAISE_EXERCISE_NAME_SINGLE_LEG_DECLINE_PUSH_UP: return "single_leg_decline_push_up";
    case FIT_CALF_RAISE_EXERCISE_NAME_SINGLE_LEG_DONKEY_CALF_RAISE: return "single_leg_donkey_calf_raise";
    case FIT_CALF_RAISE_EXERCISE_NAME_WEIGHTED_SINGLE_LEG_DONKEY_CALF_RAISE: return "weighted_single_leg_donkey_calf_raise";
    case FIT_CALF_RAISE_EXERCISE_NAME_SINGLE_LEG_HIP_RAISE_WITH_KNEE_HOLD: return "single_leg_hip_raise_with_knee_hold";
    case FIT_CALF_RAISE_EXERCISE_NAME_SINGLE_LEG_STANDING_CALF_RAISE: return "single_leg_standing_calf_raise";
    case FIT_CALF_RAISE_EXERCISE_NAME_SINGLE_LEG_STANDING_DUMBBELL_CALF_RAISE: return "single_leg_standing_dumbbell_calf_raise";
    case FIT_CALF_RAISE_EXERCISE_NAME_STANDING_BARBELL_CALF_RAISE: return "standing_barbell_calf_raise";
    case FIT_CALF_RAISE_EXERCISE_NAME_STANDING_CALF_RAISE: return "standing_calf_raise";
    case FIT_CALF_RAISE_EXERCISE_NAME_WEIGHTED_STANDING_CALF_RAISE: return "weighted_standing_calf_raise";
    case FIT_CALF_RAISE_EXERCISE_NAME_STANDING_DUMBBELL_CALF_RAISE: return "standing_dumbbell_calf_raise";
    default: return nil
  }
}
func rzfit_shoulder_press_exercise_name_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_SHOULDER_PRESS_EXERCISE_NAME_ALTERNATING_DUMBBELL_SHOULDER_PRESS: return "alternating_dumbbell_shoulder_press";
    case FIT_SHOULDER_PRESS_EXERCISE_NAME_ARNOLD_PRESS: return "arnold_press";
    case FIT_SHOULDER_PRESS_EXERCISE_NAME_BARBELL_FRONT_SQUAT_TO_PUSH_PRESS: return "barbell_front_squat_to_push_press";
    case FIT_SHOULDER_PRESS_EXERCISE_NAME_BARBELL_PUSH_PRESS: return "barbell_push_press";
    case FIT_SHOULDER_PRESS_EXERCISE_NAME_BARBELL_SHOULDER_PRESS: return "barbell_shoulder_press";
    case FIT_SHOULDER_PRESS_EXERCISE_NAME_DEAD_CURL_PRESS: return "dead_curl_press";
    case FIT_SHOULDER_PRESS_EXERCISE_NAME_DUMBBELL_ALTERNATING_SHOULDER_PRESS_AND_TWIST: return "dumbbell_alternating_shoulder_press_and_twist";
    case FIT_SHOULDER_PRESS_EXERCISE_NAME_DUMBBELL_HAMMER_CURL_TO_LUNGE_TO_PRESS: return "dumbbell_hammer_curl_to_lunge_to_press";
    case FIT_SHOULDER_PRESS_EXERCISE_NAME_DUMBBELL_PUSH_PRESS: return "dumbbell_push_press";
    case FIT_SHOULDER_PRESS_EXERCISE_NAME_FLOOR_INVERTED_SHOULDER_PRESS: return "floor_inverted_shoulder_press";
    case FIT_SHOULDER_PRESS_EXERCISE_NAME_WEIGHTED_FLOOR_INVERTED_SHOULDER_PRESS: return "weighted_floor_inverted_shoulder_press";
    case FIT_SHOULDER_PRESS_EXERCISE_NAME_INVERTED_SHOULDER_PRESS: return "inverted_shoulder_press";
    case FIT_SHOULDER_PRESS_EXERCISE_NAME_WEIGHTED_INVERTED_SHOULDER_PRESS: return "weighted_inverted_shoulder_press";
    case FIT_SHOULDER_PRESS_EXERCISE_NAME_ONE_ARM_PUSH_PRESS: return "one_arm_push_press";
    case FIT_SHOULDER_PRESS_EXERCISE_NAME_OVERHEAD_BARBELL_PRESS: return "overhead_barbell_press";
    case FIT_SHOULDER_PRESS_EXERCISE_NAME_OVERHEAD_DUMBBELL_PRESS: return "overhead_dumbbell_press";
    case FIT_SHOULDER_PRESS_EXERCISE_NAME_SEATED_BARBELL_SHOULDER_PRESS: return "seated_barbell_shoulder_press";
    case FIT_SHOULDER_PRESS_EXERCISE_NAME_SEATED_DUMBBELL_SHOULDER_PRESS: return "seated_dumbbell_shoulder_press";
    case FIT_SHOULDER_PRESS_EXERCISE_NAME_SINGLE_ARM_DUMBBELL_SHOULDER_PRESS: return "single_arm_dumbbell_shoulder_press";
    case FIT_SHOULDER_PRESS_EXERCISE_NAME_SINGLE_ARM_STEP_UP_AND_PRESS: return "single_arm_step_up_and_press";
    case FIT_SHOULDER_PRESS_EXERCISE_NAME_SMITH_MACHINE_OVERHEAD_PRESS: return "smith_machine_overhead_press";
    case FIT_SHOULDER_PRESS_EXERCISE_NAME_SPLIT_STANCE_HAMMER_CURL_TO_PRESS: return "split_stance_hammer_curl_to_press";
    case FIT_SHOULDER_PRESS_EXERCISE_NAME_SWISS_BALL_DUMBBELL_SHOULDER_PRESS: return "swiss_ball_dumbbell_shoulder_press";
    case FIT_SHOULDER_PRESS_EXERCISE_NAME_WEIGHT_PLATE_FRONT_RAISE: return "weight_plate_front_raise";
    default: return nil
  }
}
func rzfit_plank_exercise_name_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_PLANK_EXERCISE_NAME_45_DEGREE_PLANK: return "45_degree_plank";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_45_DEGREE_PLANK: return "weighted_45_degree_plank";
    case FIT_PLANK_EXERCISE_NAME_90_DEGREE_STATIC_HOLD: return "90_degree_static_hold";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_90_DEGREE_STATIC_HOLD: return "weighted_90_degree_static_hold";
    case FIT_PLANK_EXERCISE_NAME_BEAR_CRAWL: return "bear_crawl";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_BEAR_CRAWL: return "weighted_bear_crawl";
    case FIT_PLANK_EXERCISE_NAME_CROSS_BODY_MOUNTAIN_CLIMBER: return "cross_body_mountain_climber";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_CROSS_BODY_MOUNTAIN_CLIMBER: return "weighted_cross_body_mountain_climber";
    case FIT_PLANK_EXERCISE_NAME_ELBOW_PLANK_PIKE_JACKS: return "elbow_plank_pike_jacks";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_ELBOW_PLANK_PIKE_JACKS: return "weighted_elbow_plank_pike_jacks";
    case FIT_PLANK_EXERCISE_NAME_ELEVATED_FEET_PLANK: return "elevated_feet_plank";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_ELEVATED_FEET_PLANK: return "weighted_elevated_feet_plank";
    case FIT_PLANK_EXERCISE_NAME_ELEVATOR_ABS: return "elevator_abs";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_ELEVATOR_ABS: return "weighted_elevator_abs";
    case FIT_PLANK_EXERCISE_NAME_EXTENDED_PLANK: return "extended_plank";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_EXTENDED_PLANK: return "weighted_extended_plank";
    case FIT_PLANK_EXERCISE_NAME_FULL_PLANK_PASSE_TWIST: return "full_plank_passe_twist";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_FULL_PLANK_PASSE_TWIST: return "weighted_full_plank_passe_twist";
    case FIT_PLANK_EXERCISE_NAME_INCHING_ELBOW_PLANK: return "inching_elbow_plank";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_INCHING_ELBOW_PLANK: return "weighted_inching_elbow_plank";
    case FIT_PLANK_EXERCISE_NAME_INCHWORM_TO_SIDE_PLANK: return "inchworm_to_side_plank";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_INCHWORM_TO_SIDE_PLANK: return "weighted_inchworm_to_side_plank";
    case FIT_PLANK_EXERCISE_NAME_KNEELING_PLANK: return "kneeling_plank";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_KNEELING_PLANK: return "weighted_kneeling_plank";
    case FIT_PLANK_EXERCISE_NAME_KNEELING_SIDE_PLANK_WITH_LEG_LIFT: return "kneeling_side_plank_with_leg_lift";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_KNEELING_SIDE_PLANK_WITH_LEG_LIFT: return "weighted_kneeling_side_plank_with_leg_lift";
    case FIT_PLANK_EXERCISE_NAME_LATERAL_ROLL: return "lateral_roll";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_LATERAL_ROLL: return "weighted_lateral_roll";
    case FIT_PLANK_EXERCISE_NAME_LYING_REVERSE_PLANK: return "lying_reverse_plank";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_LYING_REVERSE_PLANK: return "weighted_lying_reverse_plank";
    case FIT_PLANK_EXERCISE_NAME_MEDICINE_BALL_MOUNTAIN_CLIMBER: return "medicine_ball_mountain_climber";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_MEDICINE_BALL_MOUNTAIN_CLIMBER: return "weighted_medicine_ball_mountain_climber";
    case FIT_PLANK_EXERCISE_NAME_MODIFIED_MOUNTAIN_CLIMBER_AND_EXTENSION: return "modified_mountain_climber_and_extension";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_MODIFIED_MOUNTAIN_CLIMBER_AND_EXTENSION: return "weighted_modified_mountain_climber_and_extension";
    case FIT_PLANK_EXERCISE_NAME_MOUNTAIN_CLIMBER: return "mountain_climber";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_MOUNTAIN_CLIMBER: return "weighted_mountain_climber";
    case FIT_PLANK_EXERCISE_NAME_MOUNTAIN_CLIMBER_ON_SLIDING_DISCS: return "mountain_climber_on_sliding_discs";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_MOUNTAIN_CLIMBER_ON_SLIDING_DISCS: return "weighted_mountain_climber_on_sliding_discs";
    case FIT_PLANK_EXERCISE_NAME_MOUNTAIN_CLIMBER_WITH_FEET_ON_BOSU_BALL: return "mountain_climber_with_feet_on_bosu_ball";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_MOUNTAIN_CLIMBER_WITH_FEET_ON_BOSU_BALL: return "weighted_mountain_climber_with_feet_on_bosu_ball";
    case FIT_PLANK_EXERCISE_NAME_MOUNTAIN_CLIMBER_WITH_HANDS_ON_BENCH: return "mountain_climber_with_hands_on_bench";
    case FIT_PLANK_EXERCISE_NAME_MOUNTAIN_CLIMBER_WITH_HANDS_ON_SWISS_BALL: return "mountain_climber_with_hands_on_swiss_ball";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_MOUNTAIN_CLIMBER_WITH_HANDS_ON_SWISS_BALL: return "weighted_mountain_climber_with_hands_on_swiss_ball";
    case FIT_PLANK_EXERCISE_NAME_PLANK: return "plank";
    case FIT_PLANK_EXERCISE_NAME_PLANK_JACKS_WITH_FEET_ON_SLIDING_DISCS: return "plank_jacks_with_feet_on_sliding_discs";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_PLANK_JACKS_WITH_FEET_ON_SLIDING_DISCS: return "weighted_plank_jacks_with_feet_on_sliding_discs";
    case FIT_PLANK_EXERCISE_NAME_PLANK_KNEE_TWIST: return "plank_knee_twist";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_PLANK_KNEE_TWIST: return "weighted_plank_knee_twist";
    case FIT_PLANK_EXERCISE_NAME_PLANK_PIKE_JUMPS: return "plank_pike_jumps";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_PLANK_PIKE_JUMPS: return "weighted_plank_pike_jumps";
    case FIT_PLANK_EXERCISE_NAME_PLANK_PIKES: return "plank_pikes";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_PLANK_PIKES: return "weighted_plank_pikes";
    case FIT_PLANK_EXERCISE_NAME_PLANK_TO_STAND_UP: return "plank_to_stand_up";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_PLANK_TO_STAND_UP: return "weighted_plank_to_stand_up";
    case FIT_PLANK_EXERCISE_NAME_PLANK_WITH_ARM_RAISE: return "plank_with_arm_raise";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_PLANK_WITH_ARM_RAISE: return "weighted_plank_with_arm_raise";
    case FIT_PLANK_EXERCISE_NAME_PLANK_WITH_KNEE_TO_ELBOW: return "plank_with_knee_to_elbow";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_PLANK_WITH_KNEE_TO_ELBOW: return "weighted_plank_with_knee_to_elbow";
    case FIT_PLANK_EXERCISE_NAME_PLANK_WITH_OBLIQUE_CRUNCH: return "plank_with_oblique_crunch";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_PLANK_WITH_OBLIQUE_CRUNCH: return "weighted_plank_with_oblique_crunch";
    case FIT_PLANK_EXERCISE_NAME_PLYOMETRIC_SIDE_PLANK: return "plyometric_side_plank";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_PLYOMETRIC_SIDE_PLANK: return "weighted_plyometric_side_plank";
    case FIT_PLANK_EXERCISE_NAME_ROLLING_SIDE_PLANK: return "rolling_side_plank";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_ROLLING_SIDE_PLANK: return "weighted_rolling_side_plank";
    case FIT_PLANK_EXERCISE_NAME_SIDE_KICK_PLANK: return "side_kick_plank";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_SIDE_KICK_PLANK: return "weighted_side_kick_plank";
    case FIT_PLANK_EXERCISE_NAME_SIDE_PLANK: return "side_plank";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_SIDE_PLANK: return "weighted_side_plank";
    case FIT_PLANK_EXERCISE_NAME_SIDE_PLANK_AND_ROW: return "side_plank_and_row";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_SIDE_PLANK_AND_ROW: return "weighted_side_plank_and_row";
    case FIT_PLANK_EXERCISE_NAME_SIDE_PLANK_LIFT: return "side_plank_lift";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_SIDE_PLANK_LIFT: return "weighted_side_plank_lift";
    case FIT_PLANK_EXERCISE_NAME_SIDE_PLANK_WITH_ELBOW_ON_BOSU_BALL: return "side_plank_with_elbow_on_bosu_ball";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_SIDE_PLANK_WITH_ELBOW_ON_BOSU_BALL: return "weighted_side_plank_with_elbow_on_bosu_ball";
    case FIT_PLANK_EXERCISE_NAME_SIDE_PLANK_WITH_FEET_ON_BENCH: return "side_plank_with_feet_on_bench";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_SIDE_PLANK_WITH_FEET_ON_BENCH: return "weighted_side_plank_with_feet_on_bench";
    case FIT_PLANK_EXERCISE_NAME_SIDE_PLANK_WITH_KNEE_CIRCLE: return "side_plank_with_knee_circle";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_SIDE_PLANK_WITH_KNEE_CIRCLE: return "weighted_side_plank_with_knee_circle";
    case FIT_PLANK_EXERCISE_NAME_SIDE_PLANK_WITH_KNEE_TUCK: return "side_plank_with_knee_tuck";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_SIDE_PLANK_WITH_KNEE_TUCK: return "weighted_side_plank_with_knee_tuck";
    case FIT_PLANK_EXERCISE_NAME_SIDE_PLANK_WITH_LEG_LIFT: return "side_plank_with_leg_lift";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_SIDE_PLANK_WITH_LEG_LIFT: return "weighted_side_plank_with_leg_lift";
    case FIT_PLANK_EXERCISE_NAME_SIDE_PLANK_WITH_REACH_UNDER: return "side_plank_with_reach_under";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_SIDE_PLANK_WITH_REACH_UNDER: return "weighted_side_plank_with_reach_under";
    case FIT_PLANK_EXERCISE_NAME_SINGLE_LEG_ELEVATED_FEET_PLANK: return "single_leg_elevated_feet_plank";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_SINGLE_LEG_ELEVATED_FEET_PLANK: return "weighted_single_leg_elevated_feet_plank";
    case FIT_PLANK_EXERCISE_NAME_SINGLE_LEG_FLEX_AND_EXTEND: return "single_leg_flex_and_extend";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_SINGLE_LEG_FLEX_AND_EXTEND: return "weighted_single_leg_flex_and_extend";
    case FIT_PLANK_EXERCISE_NAME_SINGLE_LEG_SIDE_PLANK: return "single_leg_side_plank";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_SINGLE_LEG_SIDE_PLANK: return "weighted_single_leg_side_plank";
    case FIT_PLANK_EXERCISE_NAME_SPIDERMAN_PLANK: return "spiderman_plank";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_SPIDERMAN_PLANK: return "weighted_spiderman_plank";
    case FIT_PLANK_EXERCISE_NAME_STRAIGHT_ARM_PLANK: return "straight_arm_plank";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_STRAIGHT_ARM_PLANK: return "weighted_straight_arm_plank";
    case FIT_PLANK_EXERCISE_NAME_STRAIGHT_ARM_PLANK_WITH_SHOULDER_TOUCH: return "straight_arm_plank_with_shoulder_touch";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_STRAIGHT_ARM_PLANK_WITH_SHOULDER_TOUCH: return "weighted_straight_arm_plank_with_shoulder_touch";
    case FIT_PLANK_EXERCISE_NAME_SWISS_BALL_PLANK: return "swiss_ball_plank";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_SWISS_BALL_PLANK: return "weighted_swiss_ball_plank";
    case FIT_PLANK_EXERCISE_NAME_SWISS_BALL_PLANK_LEG_LIFT: return "swiss_ball_plank_leg_lift";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_SWISS_BALL_PLANK_LEG_LIFT: return "weighted_swiss_ball_plank_leg_lift";
    case FIT_PLANK_EXERCISE_NAME_SWISS_BALL_PLANK_LEG_LIFT_AND_HOLD: return "swiss_ball_plank_leg_lift_and_hold";
    case FIT_PLANK_EXERCISE_NAME_SWISS_BALL_PLANK_WITH_FEET_ON_BENCH: return "swiss_ball_plank_with_feet_on_bench";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_SWISS_BALL_PLANK_WITH_FEET_ON_BENCH: return "weighted_swiss_ball_plank_with_feet_on_bench";
    case FIT_PLANK_EXERCISE_NAME_SWISS_BALL_PRONE_JACKKNIFE: return "swiss_ball_prone_jackknife";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_SWISS_BALL_PRONE_JACKKNIFE: return "weighted_swiss_ball_prone_jackknife";
    case FIT_PLANK_EXERCISE_NAME_SWISS_BALL_SIDE_PLANK: return "swiss_ball_side_plank";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_SWISS_BALL_SIDE_PLANK: return "weighted_swiss_ball_side_plank";
    case FIT_PLANK_EXERCISE_NAME_THREE_WAY_PLANK: return "three_way_plank";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_THREE_WAY_PLANK: return "weighted_three_way_plank";
    case FIT_PLANK_EXERCISE_NAME_TOWEL_PLANK_AND_KNEE_IN: return "towel_plank_and_knee_in";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_TOWEL_PLANK_AND_KNEE_IN: return "weighted_towel_plank_and_knee_in";
    case FIT_PLANK_EXERCISE_NAME_T_STABILIZATION: return "t_stabilization";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_T_STABILIZATION: return "weighted_t_stabilization";
    case FIT_PLANK_EXERCISE_NAME_TURKISH_GET_UP_TO_SIDE_PLANK: return "turkish_get_up_to_side_plank";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_TURKISH_GET_UP_TO_SIDE_PLANK: return "weighted_turkish_get_up_to_side_plank";
    case FIT_PLANK_EXERCISE_NAME_TWO_POINT_PLANK: return "two_point_plank";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_TWO_POINT_PLANK: return "weighted_two_point_plank";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_PLANK: return "weighted_plank";
    case FIT_PLANK_EXERCISE_NAME_WIDE_STANCE_PLANK_WITH_DIAGONAL_ARM_LIFT: return "wide_stance_plank_with_diagonal_arm_lift";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_WIDE_STANCE_PLANK_WITH_DIAGONAL_ARM_LIFT: return "weighted_wide_stance_plank_with_diagonal_arm_lift";
    case FIT_PLANK_EXERCISE_NAME_WIDE_STANCE_PLANK_WITH_DIAGONAL_LEG_LIFT: return "wide_stance_plank_with_diagonal_leg_lift";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_WIDE_STANCE_PLANK_WITH_DIAGONAL_LEG_LIFT: return "weighted_wide_stance_plank_with_diagonal_leg_lift";
    case FIT_PLANK_EXERCISE_NAME_WIDE_STANCE_PLANK_WITH_LEG_LIFT: return "wide_stance_plank_with_leg_lift";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_WIDE_STANCE_PLANK_WITH_LEG_LIFT: return "weighted_wide_stance_plank_with_leg_lift";
    case FIT_PLANK_EXERCISE_NAME_WIDE_STANCE_PLANK_WITH_OPPOSITE_ARM_AND_LEG_LIFT: return "wide_stance_plank_with_opposite_arm_and_leg_lift";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_MOUNTAIN_CLIMBER_WITH_HANDS_ON_BENCH: return "weighted_mountain_climber_with_hands_on_bench";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_SWISS_BALL_PLANK_LEG_LIFT_AND_HOLD: return "weighted_swiss_ball_plank_leg_lift_and_hold";
    case FIT_PLANK_EXERCISE_NAME_WEIGHTED_WIDE_STANCE_PLANK_WITH_OPPOSITE_ARM_AND_LEG_LIFT: return "weighted_wide_stance_plank_with_opposite_arm_and_leg_lift";
    case FIT_PLANK_EXERCISE_NAME_PLANK_WITH_FEET_ON_SWISS_BALL: return "plank_with_feet_on_swiss_ball";
    case FIT_PLANK_EXERCISE_NAME_SIDE_PLANK_TO_PLANK_WITH_REACH_UNDER: return "side_plank_to_plank_with_reach_under";
    case FIT_PLANK_EXERCISE_NAME_BRIDGE_WITH_GLUTE_LOWER_LIFT: return "bridge_with_glute_lower_lift";
    case FIT_PLANK_EXERCISE_NAME_BRIDGE_ONE_LEG_BRIDGE: return "bridge_one_leg_bridge";
    case FIT_PLANK_EXERCISE_NAME_PLANK_WITH_ARM_VARIATIONS: return "plank_with_arm_variations";
    case FIT_PLANK_EXERCISE_NAME_PLANK_WITH_LEG_LIFT: return "plank_with_leg_lift";
    case FIT_PLANK_EXERCISE_NAME_REVERSE_PLANK_WITH_LEG_PULL: return "reverse_plank_with_leg_pull";
    default: return nil
  }
}
func rzfit_goal_recurrence_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_GOAL_RECURRENCE_OFF: return "off";
    case FIT_GOAL_RECURRENCE_DAILY: return "daily";
    case FIT_GOAL_RECURRENCE_WEEKLY: return "weekly";
    case FIT_GOAL_RECURRENCE_MONTHLY: return "monthly";
    case FIT_GOAL_RECURRENCE_YEARLY: return "yearly";
    case FIT_GOAL_RECURRENCE_CUSTOM: return "custom";
    default: return nil
  }
}
func rzfit_chop_exercise_name_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_CHOP_EXERCISE_NAME_CABLE_PULL_THROUGH: return "cable_pull_through";
    case FIT_CHOP_EXERCISE_NAME_CABLE_ROTATIONAL_LIFT: return "cable_rotational_lift";
    case FIT_CHOP_EXERCISE_NAME_CABLE_WOODCHOP: return "cable_woodchop";
    case FIT_CHOP_EXERCISE_NAME_CROSS_CHOP_TO_KNEE: return "cross_chop_to_knee";
    case FIT_CHOP_EXERCISE_NAME_WEIGHTED_CROSS_CHOP_TO_KNEE: return "weighted_cross_chop_to_knee";
    case FIT_CHOP_EXERCISE_NAME_DUMBBELL_CHOP: return "dumbbell_chop";
    case FIT_CHOP_EXERCISE_NAME_HALF_KNEELING_ROTATION: return "half_kneeling_rotation";
    case FIT_CHOP_EXERCISE_NAME_WEIGHTED_HALF_KNEELING_ROTATION: return "weighted_half_kneeling_rotation";
    case FIT_CHOP_EXERCISE_NAME_HALF_KNEELING_ROTATIONAL_CHOP: return "half_kneeling_rotational_chop";
    case FIT_CHOP_EXERCISE_NAME_HALF_KNEELING_ROTATIONAL_REVERSE_CHOP: return "half_kneeling_rotational_reverse_chop";
    case FIT_CHOP_EXERCISE_NAME_HALF_KNEELING_STABILITY_CHOP: return "half_kneeling_stability_chop";
    case FIT_CHOP_EXERCISE_NAME_HALF_KNEELING_STABILITY_REVERSE_CHOP: return "half_kneeling_stability_reverse_chop";
    case FIT_CHOP_EXERCISE_NAME_KNEELING_ROTATIONAL_CHOP: return "kneeling_rotational_chop";
    case FIT_CHOP_EXERCISE_NAME_KNEELING_ROTATIONAL_REVERSE_CHOP: return "kneeling_rotational_reverse_chop";
    case FIT_CHOP_EXERCISE_NAME_KNEELING_STABILITY_CHOP: return "kneeling_stability_chop";
    case FIT_CHOP_EXERCISE_NAME_KNEELING_WOODCHOPPER: return "kneeling_woodchopper";
    case FIT_CHOP_EXERCISE_NAME_MEDICINE_BALL_WOOD_CHOPS: return "medicine_ball_wood_chops";
    case FIT_CHOP_EXERCISE_NAME_POWER_SQUAT_CHOPS: return "power_squat_chops";
    case FIT_CHOP_EXERCISE_NAME_WEIGHTED_POWER_SQUAT_CHOPS: return "weighted_power_squat_chops";
    case FIT_CHOP_EXERCISE_NAME_STANDING_ROTATIONAL_CHOP: return "standing_rotational_chop";
    case FIT_CHOP_EXERCISE_NAME_STANDING_SPLIT_ROTATIONAL_CHOP: return "standing_split_rotational_chop";
    case FIT_CHOP_EXERCISE_NAME_STANDING_SPLIT_ROTATIONAL_REVERSE_CHOP: return "standing_split_rotational_reverse_chop";
    case FIT_CHOP_EXERCISE_NAME_STANDING_STABILITY_REVERSE_CHOP: return "standing_stability_reverse_chop";
    default: return nil
  }
}
func rzfit_mesg_count_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_MESG_COUNT_NUM_PER_FILE: return "num_per_file";
    case FIT_MESG_COUNT_MAX_PER_FILE: return "max_per_file";
    case FIT_MESG_COUNT_MAX_PER_FILE_TYPE: return "max_per_file_type";
    default: return nil
  }
}
func rzfit_antplus_device_type_string(input : FIT_UINT8) -> String? 
{
  switch  input {
    case FIT_ANTPLUS_DEVICE_TYPE_ANTFS: return "antfs";
    case FIT_ANTPLUS_DEVICE_TYPE_BIKE_POWER: return "bike_power";
    case FIT_ANTPLUS_DEVICE_TYPE_ENVIRONMENT_SENSOR_LEGACY: return "environment_sensor_legacy";
    case FIT_ANTPLUS_DEVICE_TYPE_MULTI_SPORT_SPEED_DISTANCE: return "multi_sport_speed_distance";
    case FIT_ANTPLUS_DEVICE_TYPE_CONTROL: return "control";
    case FIT_ANTPLUS_DEVICE_TYPE_FITNESS_EQUIPMENT: return "fitness_equipment";
    case FIT_ANTPLUS_DEVICE_TYPE_BLOOD_PRESSURE: return "blood_pressure";
    case FIT_ANTPLUS_DEVICE_TYPE_GEOCACHE_NODE: return "geocache_node";
    case FIT_ANTPLUS_DEVICE_TYPE_LIGHT_ELECTRIC_VEHICLE: return "light_electric_vehicle";
    case FIT_ANTPLUS_DEVICE_TYPE_ENV_SENSOR: return "env_sensor";
    case FIT_ANTPLUS_DEVICE_TYPE_RACQUET: return "racquet";
    case FIT_ANTPLUS_DEVICE_TYPE_CONTROL_HUB: return "control_hub";
    case FIT_ANTPLUS_DEVICE_TYPE_MUSCLE_OXYGEN: return "muscle_oxygen";
    case FIT_ANTPLUS_DEVICE_TYPE_BIKE_LIGHT_MAIN: return "bike_light_main";
    case FIT_ANTPLUS_DEVICE_TYPE_BIKE_LIGHT_SHARED: return "bike_light_shared";
    case FIT_ANTPLUS_DEVICE_TYPE_EXD: return "exd";
    case FIT_ANTPLUS_DEVICE_TYPE_BIKE_RADAR: return "bike_radar";
    case FIT_ANTPLUS_DEVICE_TYPE_BIKE_AERO: return "bike_aero";
    case FIT_ANTPLUS_DEVICE_TYPE_WEIGHT_SCALE: return "weight_scale";
    case FIT_ANTPLUS_DEVICE_TYPE_HEART_RATE: return "heart_rate";
    case FIT_ANTPLUS_DEVICE_TYPE_BIKE_SPEED_CADENCE: return "bike_speed_cadence";
    case FIT_ANTPLUS_DEVICE_TYPE_BIKE_CADENCE: return "bike_cadence";
    case FIT_ANTPLUS_DEVICE_TYPE_BIKE_SPEED: return "bike_speed";
    case FIT_ANTPLUS_DEVICE_TYPE_STRIDE_SPEED_DISTANCE: return "stride_speed_distance";
    default: return nil
  }
}
func rzfit_lunge_exercise_name_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_LUNGE_EXERCISE_NAME_OVERHEAD_LUNGE: return "overhead_lunge";
    case FIT_LUNGE_EXERCISE_NAME_LUNGE_MATRIX: return "lunge_matrix";
    case FIT_LUNGE_EXERCISE_NAME_WEIGHTED_LUNGE_MATRIX: return "weighted_lunge_matrix";
    case FIT_LUNGE_EXERCISE_NAME_ALTERNATING_BARBELL_FORWARD_LUNGE: return "alternating_barbell_forward_lunge";
    case FIT_LUNGE_EXERCISE_NAME_ALTERNATING_DUMBBELL_LUNGE_WITH_REACH: return "alternating_dumbbell_lunge_with_reach";
    case FIT_LUNGE_EXERCISE_NAME_BACK_FOOT_ELEVATED_DUMBBELL_SPLIT_SQUAT: return "back_foot_elevated_dumbbell_split_squat";
    case FIT_LUNGE_EXERCISE_NAME_BARBELL_BOX_LUNGE: return "barbell_box_lunge";
    case FIT_LUNGE_EXERCISE_NAME_BARBELL_BULGARIAN_SPLIT_SQUAT: return "barbell_bulgarian_split_squat";
    case FIT_LUNGE_EXERCISE_NAME_BARBELL_CROSSOVER_LUNGE: return "barbell_crossover_lunge";
    case FIT_LUNGE_EXERCISE_NAME_BARBELL_FRONT_SPLIT_SQUAT: return "barbell_front_split_squat";
    case FIT_LUNGE_EXERCISE_NAME_BARBELL_LUNGE: return "barbell_lunge";
    case FIT_LUNGE_EXERCISE_NAME_BARBELL_REVERSE_LUNGE: return "barbell_reverse_lunge";
    case FIT_LUNGE_EXERCISE_NAME_BARBELL_SIDE_LUNGE: return "barbell_side_lunge";
    case FIT_LUNGE_EXERCISE_NAME_BARBELL_SPLIT_SQUAT: return "barbell_split_squat";
    case FIT_LUNGE_EXERCISE_NAME_CORE_CONTROL_REAR_LUNGE: return "core_control_rear_lunge";
    case FIT_LUNGE_EXERCISE_NAME_DIAGONAL_LUNGE: return "diagonal_lunge";
    case FIT_LUNGE_EXERCISE_NAME_DROP_LUNGE: return "drop_lunge";
    case FIT_LUNGE_EXERCISE_NAME_DUMBBELL_BOX_LUNGE: return "dumbbell_box_lunge";
    case FIT_LUNGE_EXERCISE_NAME_DUMBBELL_BULGARIAN_SPLIT_SQUAT: return "dumbbell_bulgarian_split_squat";
    case FIT_LUNGE_EXERCISE_NAME_DUMBBELL_CROSSOVER_LUNGE: return "dumbbell_crossover_lunge";
    case FIT_LUNGE_EXERCISE_NAME_DUMBBELL_DIAGONAL_LUNGE: return "dumbbell_diagonal_lunge";
    case FIT_LUNGE_EXERCISE_NAME_DUMBBELL_LUNGE: return "dumbbell_lunge";
    case FIT_LUNGE_EXERCISE_NAME_DUMBBELL_LUNGE_AND_ROTATION: return "dumbbell_lunge_and_rotation";
    case FIT_LUNGE_EXERCISE_NAME_DUMBBELL_OVERHEAD_BULGARIAN_SPLIT_SQUAT: return "dumbbell_overhead_bulgarian_split_squat";
    case FIT_LUNGE_EXERCISE_NAME_DUMBBELL_REVERSE_LUNGE_TO_HIGH_KNEE_AND_PRESS: return "dumbbell_reverse_lunge_to_high_knee_and_press";
    case FIT_LUNGE_EXERCISE_NAME_DUMBBELL_SIDE_LUNGE: return "dumbbell_side_lunge";
    case FIT_LUNGE_EXERCISE_NAME_ELEVATED_FRONT_FOOT_BARBELL_SPLIT_SQUAT: return "elevated_front_foot_barbell_split_squat";
    case FIT_LUNGE_EXERCISE_NAME_FRONT_FOOT_ELEVATED_DUMBBELL_SPLIT_SQUAT: return "front_foot_elevated_dumbbell_split_squat";
    case FIT_LUNGE_EXERCISE_NAME_GUNSLINGER_LUNGE: return "gunslinger_lunge";
    case FIT_LUNGE_EXERCISE_NAME_LAWNMOWER_LUNGE: return "lawnmower_lunge";
    case FIT_LUNGE_EXERCISE_NAME_LOW_LUNGE_WITH_ISOMETRIC_ADDUCTION: return "low_lunge_with_isometric_adduction";
    case FIT_LUNGE_EXERCISE_NAME_LOW_SIDE_TO_SIDE_LUNGE: return "low_side_to_side_lunge";
    case FIT_LUNGE_EXERCISE_NAME_LUNGE: return "lunge";
    case FIT_LUNGE_EXERCISE_NAME_WEIGHTED_LUNGE: return "weighted_lunge";
    case FIT_LUNGE_EXERCISE_NAME_LUNGE_WITH_ARM_REACH: return "lunge_with_arm_reach";
    case FIT_LUNGE_EXERCISE_NAME_LUNGE_WITH_DIAGONAL_REACH: return "lunge_with_diagonal_reach";
    case FIT_LUNGE_EXERCISE_NAME_LUNGE_WITH_SIDE_BEND: return "lunge_with_side_bend";
    case FIT_LUNGE_EXERCISE_NAME_OFFSET_DUMBBELL_LUNGE: return "offset_dumbbell_lunge";
    case FIT_LUNGE_EXERCISE_NAME_OFFSET_DUMBBELL_REVERSE_LUNGE: return "offset_dumbbell_reverse_lunge";
    case FIT_LUNGE_EXERCISE_NAME_OVERHEAD_BULGARIAN_SPLIT_SQUAT: return "overhead_bulgarian_split_squat";
    case FIT_LUNGE_EXERCISE_NAME_OVERHEAD_DUMBBELL_REVERSE_LUNGE: return "overhead_dumbbell_reverse_lunge";
    case FIT_LUNGE_EXERCISE_NAME_OVERHEAD_DUMBBELL_SPLIT_SQUAT: return "overhead_dumbbell_split_squat";
    case FIT_LUNGE_EXERCISE_NAME_OVERHEAD_LUNGE_WITH_ROTATION: return "overhead_lunge_with_rotation";
    case FIT_LUNGE_EXERCISE_NAME_REVERSE_BARBELL_BOX_LUNGE: return "reverse_barbell_box_lunge";
    case FIT_LUNGE_EXERCISE_NAME_REVERSE_BOX_LUNGE: return "reverse_box_lunge";
    case FIT_LUNGE_EXERCISE_NAME_REVERSE_DUMBBELL_BOX_LUNGE: return "reverse_dumbbell_box_lunge";
    case FIT_LUNGE_EXERCISE_NAME_REVERSE_DUMBBELL_CROSSOVER_LUNGE: return "reverse_dumbbell_crossover_lunge";
    case FIT_LUNGE_EXERCISE_NAME_REVERSE_DUMBBELL_DIAGONAL_LUNGE: return "reverse_dumbbell_diagonal_lunge";
    case FIT_LUNGE_EXERCISE_NAME_REVERSE_LUNGE_WITH_REACH_BACK: return "reverse_lunge_with_reach_back";
    case FIT_LUNGE_EXERCISE_NAME_WEIGHTED_REVERSE_LUNGE_WITH_REACH_BACK: return "weighted_reverse_lunge_with_reach_back";
    case FIT_LUNGE_EXERCISE_NAME_REVERSE_LUNGE_WITH_TWIST_AND_OVERHEAD_REACH: return "reverse_lunge_with_twist_and_overhead_reach";
    case FIT_LUNGE_EXERCISE_NAME_WEIGHTED_REVERSE_LUNGE_WITH_TWIST_AND_OVERHEAD_REACH: return "weighted_reverse_lunge_with_twist_and_overhead_reach";
    case FIT_LUNGE_EXERCISE_NAME_REVERSE_SLIDING_BOX_LUNGE: return "reverse_sliding_box_lunge";
    case FIT_LUNGE_EXERCISE_NAME_WEIGHTED_REVERSE_SLIDING_BOX_LUNGE: return "weighted_reverse_sliding_box_lunge";
    case FIT_LUNGE_EXERCISE_NAME_REVERSE_SLIDING_LUNGE: return "reverse_sliding_lunge";
    case FIT_LUNGE_EXERCISE_NAME_WEIGHTED_REVERSE_SLIDING_LUNGE: return "weighted_reverse_sliding_lunge";
    case FIT_LUNGE_EXERCISE_NAME_RUNNERS_LUNGE_TO_BALANCE: return "runners_lunge_to_balance";
    case FIT_LUNGE_EXERCISE_NAME_WEIGHTED_RUNNERS_LUNGE_TO_BALANCE: return "weighted_runners_lunge_to_balance";
    case FIT_LUNGE_EXERCISE_NAME_SHIFTING_SIDE_LUNGE: return "shifting_side_lunge";
    case FIT_LUNGE_EXERCISE_NAME_SIDE_AND_CROSSOVER_LUNGE: return "side_and_crossover_lunge";
    case FIT_LUNGE_EXERCISE_NAME_WEIGHTED_SIDE_AND_CROSSOVER_LUNGE: return "weighted_side_and_crossover_lunge";
    case FIT_LUNGE_EXERCISE_NAME_SIDE_LUNGE: return "side_lunge";
    case FIT_LUNGE_EXERCISE_NAME_WEIGHTED_SIDE_LUNGE: return "weighted_side_lunge";
    case FIT_LUNGE_EXERCISE_NAME_SIDE_LUNGE_AND_PRESS: return "side_lunge_and_press";
    case FIT_LUNGE_EXERCISE_NAME_SIDE_LUNGE_JUMP_OFF: return "side_lunge_jump_off";
    case FIT_LUNGE_EXERCISE_NAME_SIDE_LUNGE_SWEEP: return "side_lunge_sweep";
    case FIT_LUNGE_EXERCISE_NAME_WEIGHTED_SIDE_LUNGE_SWEEP: return "weighted_side_lunge_sweep";
    case FIT_LUNGE_EXERCISE_NAME_SIDE_LUNGE_TO_CROSSOVER_TAP: return "side_lunge_to_crossover_tap";
    case FIT_LUNGE_EXERCISE_NAME_WEIGHTED_SIDE_LUNGE_TO_CROSSOVER_TAP: return "weighted_side_lunge_to_crossover_tap";
    case FIT_LUNGE_EXERCISE_NAME_SIDE_TO_SIDE_LUNGE_CHOPS: return "side_to_side_lunge_chops";
    case FIT_LUNGE_EXERCISE_NAME_WEIGHTED_SIDE_TO_SIDE_LUNGE_CHOPS: return "weighted_side_to_side_lunge_chops";
    case FIT_LUNGE_EXERCISE_NAME_SIFF_JUMP_LUNGE: return "siff_jump_lunge";
    case FIT_LUNGE_EXERCISE_NAME_WEIGHTED_SIFF_JUMP_LUNGE: return "weighted_siff_jump_lunge";
    case FIT_LUNGE_EXERCISE_NAME_SINGLE_ARM_REVERSE_LUNGE_AND_PRESS: return "single_arm_reverse_lunge_and_press";
    case FIT_LUNGE_EXERCISE_NAME_SLIDING_LATERAL_LUNGE: return "sliding_lateral_lunge";
    case FIT_LUNGE_EXERCISE_NAME_WEIGHTED_SLIDING_LATERAL_LUNGE: return "weighted_sliding_lateral_lunge";
    case FIT_LUNGE_EXERCISE_NAME_WALKING_BARBELL_LUNGE: return "walking_barbell_lunge";
    case FIT_LUNGE_EXERCISE_NAME_WALKING_DUMBBELL_LUNGE: return "walking_dumbbell_lunge";
    case FIT_LUNGE_EXERCISE_NAME_WALKING_LUNGE: return "walking_lunge";
    case FIT_LUNGE_EXERCISE_NAME_WEIGHTED_WALKING_LUNGE: return "weighted_walking_lunge";
    case FIT_LUNGE_EXERCISE_NAME_WIDE_GRIP_OVERHEAD_BARBELL_SPLIT_SQUAT: return "wide_grip_overhead_barbell_split_squat";
    default: return nil
  }
}
func rzfit_exd_layout_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_EXD_LAYOUT_FULL_SCREEN: return "full_screen";
    case FIT_EXD_LAYOUT_HALF_VERTICAL: return "half_vertical";
    case FIT_EXD_LAYOUT_HALF_HORIZONTAL: return "half_horizontal";
    case FIT_EXD_LAYOUT_HALF_VERTICAL_RIGHT_SPLIT: return "half_vertical_right_split";
    case FIT_EXD_LAYOUT_HALF_HORIZONTAL_BOTTOM_SPLIT: return "half_horizontal_bottom_split";
    case FIT_EXD_LAYOUT_FULL_QUARTER_SPLIT: return "full_quarter_split";
    case FIT_EXD_LAYOUT_HALF_VERTICAL_LEFT_SPLIT: return "half_vertical_left_split";
    case FIT_EXD_LAYOUT_HALF_HORIZONTAL_TOP_SPLIT: return "half_horizontal_top_split";
    default: return nil
  }
}
func rzfit_event_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_EVENT_TIMER: return "timer";
    case FIT_EVENT_WORKOUT: return "workout";
    case FIT_EVENT_WORKOUT_STEP: return "workout_step";
    case FIT_EVENT_POWER_DOWN: return "power_down";
    case FIT_EVENT_POWER_UP: return "power_up";
    case FIT_EVENT_OFF_COURSE: return "off_course";
    case FIT_EVENT_SESSION: return "session";
    case FIT_EVENT_LAP: return "lap";
    case FIT_EVENT_COURSE_POINT: return "course_point";
    case FIT_EVENT_BATTERY: return "battery";
    case FIT_EVENT_VIRTUAL_PARTNER_PACE: return "virtual_partner_pace";
    case FIT_EVENT_HR_HIGH_ALERT: return "hr_high_alert";
    case FIT_EVENT_HR_LOW_ALERT: return "hr_low_alert";
    case FIT_EVENT_SPEED_HIGH_ALERT: return "speed_high_alert";
    case FIT_EVENT_SPEED_LOW_ALERT: return "speed_low_alert";
    case FIT_EVENT_CAD_HIGH_ALERT: return "cad_high_alert";
    case FIT_EVENT_CAD_LOW_ALERT: return "cad_low_alert";
    case FIT_EVENT_POWER_HIGH_ALERT: return "power_high_alert";
    case FIT_EVENT_POWER_LOW_ALERT: return "power_low_alert";
    case FIT_EVENT_RECOVERY_HR: return "recovery_hr";
    case FIT_EVENT_BATTERY_LOW: return "battery_low";
    case FIT_EVENT_TIME_DURATION_ALERT: return "time_duration_alert";
    case FIT_EVENT_DISTANCE_DURATION_ALERT: return "distance_duration_alert";
    case FIT_EVENT_CALORIE_DURATION_ALERT: return "calorie_duration_alert";
    case FIT_EVENT_ACTIVITY: return "activity";
    case FIT_EVENT_FITNESS_EQUIPMENT: return "fitness_equipment";
    case FIT_EVENT_LENGTH: return "length";
    case FIT_EVENT_USER_MARKER: return "user_marker";
    case FIT_EVENT_SPORT_POINT: return "sport_point";
    case FIT_EVENT_CALIBRATION: return "calibration";
    case FIT_EVENT_FRONT_GEAR_CHANGE: return "front_gear_change";
    case FIT_EVENT_REAR_GEAR_CHANGE: return "rear_gear_change";
    case FIT_EVENT_RIDER_POSITION_CHANGE: return "rider_position_change";
    case FIT_EVENT_ELEV_HIGH_ALERT: return "elev_high_alert";
    case FIT_EVENT_ELEV_LOW_ALERT: return "elev_low_alert";
    case FIT_EVENT_COMM_TIMEOUT: return "comm_timeout";
    default: return nil
  }
}
func rzfit_lateral_raise_exercise_name_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_LATERAL_RAISE_EXERCISE_NAME_45_DEGREE_CABLE_EXTERNAL_ROTATION: return "45_degree_cable_external_rotation";
    case FIT_LATERAL_RAISE_EXERCISE_NAME_ALTERNATING_LATERAL_RAISE_WITH_STATIC_HOLD: return "alternating_lateral_raise_with_static_hold";
    case FIT_LATERAL_RAISE_EXERCISE_NAME_BAR_MUSCLE_UP: return "bar_muscle_up";
    case FIT_LATERAL_RAISE_EXERCISE_NAME_BENT_OVER_LATERAL_RAISE: return "bent_over_lateral_raise";
    case FIT_LATERAL_RAISE_EXERCISE_NAME_CABLE_DIAGONAL_RAISE: return "cable_diagonal_raise";
    case FIT_LATERAL_RAISE_EXERCISE_NAME_CABLE_FRONT_RAISE: return "cable_front_raise";
    case FIT_LATERAL_RAISE_EXERCISE_NAME_CALORIE_ROW: return "calorie_row";
    case FIT_LATERAL_RAISE_EXERCISE_NAME_COMBO_SHOULDER_RAISE: return "combo_shoulder_raise";
    case FIT_LATERAL_RAISE_EXERCISE_NAME_DUMBBELL_DIAGONAL_RAISE: return "dumbbell_diagonal_raise";
    case FIT_LATERAL_RAISE_EXERCISE_NAME_DUMBBELL_V_RAISE: return "dumbbell_v_raise";
    case FIT_LATERAL_RAISE_EXERCISE_NAME_FRONT_RAISE: return "front_raise";
    case FIT_LATERAL_RAISE_EXERCISE_NAME_LEANING_DUMBBELL_LATERAL_RAISE: return "leaning_dumbbell_lateral_raise";
    case FIT_LATERAL_RAISE_EXERCISE_NAME_LYING_DUMBBELL_RAISE: return "lying_dumbbell_raise";
    case FIT_LATERAL_RAISE_EXERCISE_NAME_MUSCLE_UP: return "muscle_up";
    case FIT_LATERAL_RAISE_EXERCISE_NAME_ONE_ARM_CABLE_LATERAL_RAISE: return "one_arm_cable_lateral_raise";
    case FIT_LATERAL_RAISE_EXERCISE_NAME_OVERHAND_GRIP_REAR_LATERAL_RAISE: return "overhand_grip_rear_lateral_raise";
    case FIT_LATERAL_RAISE_EXERCISE_NAME_PLATE_RAISES: return "plate_raises";
    case FIT_LATERAL_RAISE_EXERCISE_NAME_RING_DIP: return "ring_dip";
    case FIT_LATERAL_RAISE_EXERCISE_NAME_WEIGHTED_RING_DIP: return "weighted_ring_dip";
    case FIT_LATERAL_RAISE_EXERCISE_NAME_RING_MUSCLE_UP: return "ring_muscle_up";
    case FIT_LATERAL_RAISE_EXERCISE_NAME_WEIGHTED_RING_MUSCLE_UP: return "weighted_ring_muscle_up";
    case FIT_LATERAL_RAISE_EXERCISE_NAME_ROPE_CLIMB: return "rope_climb";
    case FIT_LATERAL_RAISE_EXERCISE_NAME_WEIGHTED_ROPE_CLIMB: return "weighted_rope_climb";
    case FIT_LATERAL_RAISE_EXERCISE_NAME_SCAPTION: return "scaption";
    case FIT_LATERAL_RAISE_EXERCISE_NAME_SEATED_LATERAL_RAISE: return "seated_lateral_raise";
    case FIT_LATERAL_RAISE_EXERCISE_NAME_SEATED_REAR_LATERAL_RAISE: return "seated_rear_lateral_raise";
    case FIT_LATERAL_RAISE_EXERCISE_NAME_SIDE_LYING_LATERAL_RAISE: return "side_lying_lateral_raise";
    case FIT_LATERAL_RAISE_EXERCISE_NAME_STANDING_LIFT: return "standing_lift";
    case FIT_LATERAL_RAISE_EXERCISE_NAME_SUSPENDED_ROW: return "suspended_row";
    case FIT_LATERAL_RAISE_EXERCISE_NAME_UNDERHAND_GRIP_REAR_LATERAL_RAISE: return "underhand_grip_rear_lateral_raise";
    case FIT_LATERAL_RAISE_EXERCISE_NAME_WALL_SLIDE: return "wall_slide";
    case FIT_LATERAL_RAISE_EXERCISE_NAME_WEIGHTED_WALL_SLIDE: return "weighted_wall_slide";
    case FIT_LATERAL_RAISE_EXERCISE_NAME_ARM_CIRCLES: return "arm_circles";
    case FIT_LATERAL_RAISE_EXERCISE_NAME_SHAVING_THE_HEAD: return "shaving_the_head";
    default: return nil
  }
}
func rzfit_pwr_zone_calc_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_PWR_ZONE_CALC_CUSTOM: return "custom";
    case FIT_PWR_ZONE_CALC_PERCENT_FTP: return "percent_ftp";
    default: return nil
  }
}
func rzfit_water_type_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_WATER_TYPE_FRESH: return "fresh";
    case FIT_WATER_TYPE_SALT: return "salt";
    case FIT_WATER_TYPE_EN13319: return "en13319";
    case FIT_WATER_TYPE_CUSTOM: return "custom";
    default: return nil
  }
}
func rzfit_workout_hr_string(input : FIT_UINT32) -> String? 
{
  switch  input {
    case FIT_WORKOUT_HR_BPM_OFFSET: return "bpm_offset";
    default: return nil
  }
}
func rzfit_display_measure_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_DISPLAY_MEASURE_METRIC: return "metric";
    case FIT_DISPLAY_MEASURE_STATUTE: return "statute";
    case FIT_DISPLAY_MEASURE_NAUTICAL: return "nautical";
    default: return nil
  }
}
func rzfit_set_type_string(input : FIT_UINT8) -> String? 
{
  switch  input {
    case FIT_SET_TYPE_REST: return "rest";
    case FIT_SET_TYPE_ACTIVE: return "active";
    default: return nil
  }
}
func rzfit_power_phase_type_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_POWER_PHASE_TYPE_POWER_PHASE_START_ANGLE: return "power_phase_start_angle";
    case FIT_POWER_PHASE_TYPE_POWER_PHASE_END_ANGLE: return "power_phase_end_angle";
    case FIT_POWER_PHASE_TYPE_POWER_PHASE_ARC_LENGTH: return "power_phase_arc_length";
    case FIT_POWER_PHASE_TYPE_POWER_PHASE_CENTER: return "power_phase_center";
    default: return nil
  }
}
func rzfit_hip_stability_exercise_name_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_HIP_STABILITY_EXERCISE_NAME_BAND_SIDE_LYING_LEG_RAISE: return "band_side_lying_leg_raise";
    case FIT_HIP_STABILITY_EXERCISE_NAME_DEAD_BUG: return "dead_bug";
    case FIT_HIP_STABILITY_EXERCISE_NAME_WEIGHTED_DEAD_BUG: return "weighted_dead_bug";
    case FIT_HIP_STABILITY_EXERCISE_NAME_EXTERNAL_HIP_RAISE: return "external_hip_raise";
    case FIT_HIP_STABILITY_EXERCISE_NAME_WEIGHTED_EXTERNAL_HIP_RAISE: return "weighted_external_hip_raise";
    case FIT_HIP_STABILITY_EXERCISE_NAME_FIRE_HYDRANT_KICKS: return "fire_hydrant_kicks";
    case FIT_HIP_STABILITY_EXERCISE_NAME_WEIGHTED_FIRE_HYDRANT_KICKS: return "weighted_fire_hydrant_kicks";
    case FIT_HIP_STABILITY_EXERCISE_NAME_HIP_CIRCLES: return "hip_circles";
    case FIT_HIP_STABILITY_EXERCISE_NAME_WEIGHTED_HIP_CIRCLES: return "weighted_hip_circles";
    case FIT_HIP_STABILITY_EXERCISE_NAME_INNER_THIGH_LIFT: return "inner_thigh_lift";
    case FIT_HIP_STABILITY_EXERCISE_NAME_WEIGHTED_INNER_THIGH_LIFT: return "weighted_inner_thigh_lift";
    case FIT_HIP_STABILITY_EXERCISE_NAME_LATERAL_WALKS_WITH_BAND_AT_ANKLES: return "lateral_walks_with_band_at_ankles";
    case FIT_HIP_STABILITY_EXERCISE_NAME_PRETZEL_SIDE_KICK: return "pretzel_side_kick";
    case FIT_HIP_STABILITY_EXERCISE_NAME_WEIGHTED_PRETZEL_SIDE_KICK: return "weighted_pretzel_side_kick";
    case FIT_HIP_STABILITY_EXERCISE_NAME_PRONE_HIP_INTERNAL_ROTATION: return "prone_hip_internal_rotation";
    case FIT_HIP_STABILITY_EXERCISE_NAME_WEIGHTED_PRONE_HIP_INTERNAL_ROTATION: return "weighted_prone_hip_internal_rotation";
    case FIT_HIP_STABILITY_EXERCISE_NAME_QUADRUPED: return "quadruped";
    case FIT_HIP_STABILITY_EXERCISE_NAME_QUADRUPED_HIP_EXTENSION: return "quadruped_hip_extension";
    case FIT_HIP_STABILITY_EXERCISE_NAME_WEIGHTED_QUADRUPED_HIP_EXTENSION: return "weighted_quadruped_hip_extension";
    case FIT_HIP_STABILITY_EXERCISE_NAME_QUADRUPED_WITH_LEG_LIFT: return "quadruped_with_leg_lift";
    case FIT_HIP_STABILITY_EXERCISE_NAME_WEIGHTED_QUADRUPED_WITH_LEG_LIFT: return "weighted_quadruped_with_leg_lift";
    case FIT_HIP_STABILITY_EXERCISE_NAME_SIDE_LYING_LEG_RAISE: return "side_lying_leg_raise";
    case FIT_HIP_STABILITY_EXERCISE_NAME_WEIGHTED_SIDE_LYING_LEG_RAISE: return "weighted_side_lying_leg_raise";
    case FIT_HIP_STABILITY_EXERCISE_NAME_SLIDING_HIP_ADDUCTION: return "sliding_hip_adduction";
    case FIT_HIP_STABILITY_EXERCISE_NAME_WEIGHTED_SLIDING_HIP_ADDUCTION: return "weighted_sliding_hip_adduction";
    case FIT_HIP_STABILITY_EXERCISE_NAME_STANDING_ADDUCTION: return "standing_adduction";
    case FIT_HIP_STABILITY_EXERCISE_NAME_WEIGHTED_STANDING_ADDUCTION: return "weighted_standing_adduction";
    case FIT_HIP_STABILITY_EXERCISE_NAME_STANDING_CABLE_HIP_ABDUCTION: return "standing_cable_hip_abduction";
    case FIT_HIP_STABILITY_EXERCISE_NAME_STANDING_HIP_ABDUCTION: return "standing_hip_abduction";
    case FIT_HIP_STABILITY_EXERCISE_NAME_WEIGHTED_STANDING_HIP_ABDUCTION: return "weighted_standing_hip_abduction";
    case FIT_HIP_STABILITY_EXERCISE_NAME_STANDING_REAR_LEG_RAISE: return "standing_rear_leg_raise";
    case FIT_HIP_STABILITY_EXERCISE_NAME_WEIGHTED_STANDING_REAR_LEG_RAISE: return "weighted_standing_rear_leg_raise";
    case FIT_HIP_STABILITY_EXERCISE_NAME_SUPINE_HIP_INTERNAL_ROTATION: return "supine_hip_internal_rotation";
    case FIT_HIP_STABILITY_EXERCISE_NAME_WEIGHTED_SUPINE_HIP_INTERNAL_ROTATION: return "weighted_supine_hip_internal_rotation";
    default: return nil
  }
}
func rzfit_leg_curl_exercise_name_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_LEG_CURL_EXERCISE_NAME_LEG_CURL: return "leg_curl";
    case FIT_LEG_CURL_EXERCISE_NAME_WEIGHTED_LEG_CURL: return "weighted_leg_curl";
    case FIT_LEG_CURL_EXERCISE_NAME_GOOD_MORNING: return "good_morning";
    case FIT_LEG_CURL_EXERCISE_NAME_SEATED_BARBELL_GOOD_MORNING: return "seated_barbell_good_morning";
    case FIT_LEG_CURL_EXERCISE_NAME_SINGLE_LEG_BARBELL_GOOD_MORNING: return "single_leg_barbell_good_morning";
    case FIT_LEG_CURL_EXERCISE_NAME_SINGLE_LEG_SLIDING_LEG_CURL: return "single_leg_sliding_leg_curl";
    case FIT_LEG_CURL_EXERCISE_NAME_SLIDING_LEG_CURL: return "sliding_leg_curl";
    case FIT_LEG_CURL_EXERCISE_NAME_SPLIT_BARBELL_GOOD_MORNING: return "split_barbell_good_morning";
    case FIT_LEG_CURL_EXERCISE_NAME_SPLIT_STANCE_EXTENSION: return "split_stance_extension";
    case FIT_LEG_CURL_EXERCISE_NAME_STAGGERED_STANCE_GOOD_MORNING: return "staggered_stance_good_morning";
    case FIT_LEG_CURL_EXERCISE_NAME_SWISS_BALL_HIP_RAISE_AND_LEG_CURL: return "swiss_ball_hip_raise_and_leg_curl";
    case FIT_LEG_CURL_EXERCISE_NAME_ZERCHER_GOOD_MORNING: return "zercher_good_morning";
    default: return nil
  }
}
func rzfit_autolap_trigger_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_AUTOLAP_TRIGGER_TIME: return "time";
    case FIT_AUTOLAP_TRIGGER_DISTANCE: return "distance";
    case FIT_AUTOLAP_TRIGGER_POSITION_START: return "position_start";
    case FIT_AUTOLAP_TRIGGER_POSITION_LAP: return "position_lap";
    case FIT_AUTOLAP_TRIGGER_POSITION_WAYPOINT: return "position_waypoint";
    case FIT_AUTOLAP_TRIGGER_POSITION_MARKED: return "position_marked";
    case FIT_AUTOLAP_TRIGGER_OFF: return "off";
    default: return nil
  }
}
func rzfit_fit_base_type_string(input : FIT_UINT8) -> String? 
{
  switch  input {
    case FIT_FIT_BASE_TYPE_ENUM: return "enum";
    case FIT_FIT_BASE_TYPE_SINT8: return "sint8";
    case FIT_FIT_BASE_TYPE_UINT8: return "uint8";
    case FIT_FIT_BASE_TYPE_SINT16: return "sint16";
    case FIT_FIT_BASE_TYPE_UINT16: return "uint16";
    case FIT_FIT_BASE_TYPE_SINT32: return "sint32";
    case FIT_FIT_BASE_TYPE_UINT32: return "uint32";
    case FIT_FIT_BASE_TYPE_STRING: return "string";
    case FIT_FIT_BASE_TYPE_FLOAT32: return "float32";
    case FIT_FIT_BASE_TYPE_FLOAT64: return "float64";
    case FIT_FIT_BASE_TYPE_UINT8Z: return "uint8z";
    case FIT_FIT_BASE_TYPE_UINT16Z: return "uint16z";
    case FIT_FIT_BASE_TYPE_UINT32Z: return "uint32z";
    case FIT_FIT_BASE_TYPE_BYTE: return "byte";
    case FIT_FIT_BASE_TYPE_SINT64: return "sint64";
    case FIT_FIT_BASE_TYPE_UINT64: return "uint64";
    case FIT_FIT_BASE_TYPE_UINT64Z: return "uint64z";
    default: return nil
  }
}
func rzfit_hip_raise_exercise_name_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_HIP_RAISE_EXERCISE_NAME_BARBELL_HIP_THRUST_ON_FLOOR: return "barbell_hip_thrust_on_floor";
    case FIT_HIP_RAISE_EXERCISE_NAME_BARBELL_HIP_THRUST_WITH_BENCH: return "barbell_hip_thrust_with_bench";
    case FIT_HIP_RAISE_EXERCISE_NAME_BENT_KNEE_SWISS_BALL_REVERSE_HIP_RAISE: return "bent_knee_swiss_ball_reverse_hip_raise";
    case FIT_HIP_RAISE_EXERCISE_NAME_WEIGHTED_BENT_KNEE_SWISS_BALL_REVERSE_HIP_RAISE: return "weighted_bent_knee_swiss_ball_reverse_hip_raise";
    case FIT_HIP_RAISE_EXERCISE_NAME_BRIDGE_WITH_LEG_EXTENSION: return "bridge_with_leg_extension";
    case FIT_HIP_RAISE_EXERCISE_NAME_WEIGHTED_BRIDGE_WITH_LEG_EXTENSION: return "weighted_bridge_with_leg_extension";
    case FIT_HIP_RAISE_EXERCISE_NAME_CLAM_BRIDGE: return "clam_bridge";
    case FIT_HIP_RAISE_EXERCISE_NAME_FRONT_KICK_TABLETOP: return "front_kick_tabletop";
    case FIT_HIP_RAISE_EXERCISE_NAME_WEIGHTED_FRONT_KICK_TABLETOP: return "weighted_front_kick_tabletop";
    case FIT_HIP_RAISE_EXERCISE_NAME_HIP_EXTENSION_AND_CROSS: return "hip_extension_and_cross";
    case FIT_HIP_RAISE_EXERCISE_NAME_WEIGHTED_HIP_EXTENSION_AND_CROSS: return "weighted_hip_extension_and_cross";
    case FIT_HIP_RAISE_EXERCISE_NAME_HIP_RAISE: return "hip_raise";
    case FIT_HIP_RAISE_EXERCISE_NAME_WEIGHTED_HIP_RAISE: return "weighted_hip_raise";
    case FIT_HIP_RAISE_EXERCISE_NAME_HIP_RAISE_WITH_FEET_ON_SWISS_BALL: return "hip_raise_with_feet_on_swiss_ball";
    case FIT_HIP_RAISE_EXERCISE_NAME_WEIGHTED_HIP_RAISE_WITH_FEET_ON_SWISS_BALL: return "weighted_hip_raise_with_feet_on_swiss_ball";
    case FIT_HIP_RAISE_EXERCISE_NAME_HIP_RAISE_WITH_HEAD_ON_BOSU_BALL: return "hip_raise_with_head_on_bosu_ball";
    case FIT_HIP_RAISE_EXERCISE_NAME_WEIGHTED_HIP_RAISE_WITH_HEAD_ON_BOSU_BALL: return "weighted_hip_raise_with_head_on_bosu_ball";
    case FIT_HIP_RAISE_EXERCISE_NAME_HIP_RAISE_WITH_HEAD_ON_SWISS_BALL: return "hip_raise_with_head_on_swiss_ball";
    case FIT_HIP_RAISE_EXERCISE_NAME_WEIGHTED_HIP_RAISE_WITH_HEAD_ON_SWISS_BALL: return "weighted_hip_raise_with_head_on_swiss_ball";
    case FIT_HIP_RAISE_EXERCISE_NAME_HIP_RAISE_WITH_KNEE_SQUEEZE: return "hip_raise_with_knee_squeeze";
    case FIT_HIP_RAISE_EXERCISE_NAME_WEIGHTED_HIP_RAISE_WITH_KNEE_SQUEEZE: return "weighted_hip_raise_with_knee_squeeze";
    case FIT_HIP_RAISE_EXERCISE_NAME_INCLINE_REAR_LEG_EXTENSION: return "incline_rear_leg_extension";
    case FIT_HIP_RAISE_EXERCISE_NAME_WEIGHTED_INCLINE_REAR_LEG_EXTENSION: return "weighted_incline_rear_leg_extension";
    case FIT_HIP_RAISE_EXERCISE_NAME_KETTLEBELL_SWING: return "kettlebell_swing";
    case FIT_HIP_RAISE_EXERCISE_NAME_MARCHING_HIP_RAISE: return "marching_hip_raise";
    case FIT_HIP_RAISE_EXERCISE_NAME_WEIGHTED_MARCHING_HIP_RAISE: return "weighted_marching_hip_raise";
    case FIT_HIP_RAISE_EXERCISE_NAME_MARCHING_HIP_RAISE_WITH_FEET_ON_A_SWISS_BALL: return "marching_hip_raise_with_feet_on_a_swiss_ball";
    case FIT_HIP_RAISE_EXERCISE_NAME_WEIGHTED_MARCHING_HIP_RAISE_WITH_FEET_ON_A_SWISS_BALL: return "weighted_marching_hip_raise_with_feet_on_a_swiss_ball";
    case FIT_HIP_RAISE_EXERCISE_NAME_REVERSE_HIP_RAISE: return "reverse_hip_raise";
    case FIT_HIP_RAISE_EXERCISE_NAME_WEIGHTED_REVERSE_HIP_RAISE: return "weighted_reverse_hip_raise";
    case FIT_HIP_RAISE_EXERCISE_NAME_SINGLE_LEG_HIP_RAISE: return "single_leg_hip_raise";
    case FIT_HIP_RAISE_EXERCISE_NAME_WEIGHTED_SINGLE_LEG_HIP_RAISE: return "weighted_single_leg_hip_raise";
    case FIT_HIP_RAISE_EXERCISE_NAME_SINGLE_LEG_HIP_RAISE_WITH_FOOT_ON_BENCH: return "single_leg_hip_raise_with_foot_on_bench";
    case FIT_HIP_RAISE_EXERCISE_NAME_WEIGHTED_SINGLE_LEG_HIP_RAISE_WITH_FOOT_ON_BENCH: return "weighted_single_leg_hip_raise_with_foot_on_bench";
    case FIT_HIP_RAISE_EXERCISE_NAME_SINGLE_LEG_HIP_RAISE_WITH_FOOT_ON_BOSU_BALL: return "single_leg_hip_raise_with_foot_on_bosu_ball";
    case FIT_HIP_RAISE_EXERCISE_NAME_WEIGHTED_SINGLE_LEG_HIP_RAISE_WITH_FOOT_ON_BOSU_BALL: return "weighted_single_leg_hip_raise_with_foot_on_bosu_ball";
    case FIT_HIP_RAISE_EXERCISE_NAME_SINGLE_LEG_HIP_RAISE_WITH_FOOT_ON_FOAM_ROLLER: return "single_leg_hip_raise_with_foot_on_foam_roller";
    case FIT_HIP_RAISE_EXERCISE_NAME_WEIGHTED_SINGLE_LEG_HIP_RAISE_WITH_FOOT_ON_FOAM_ROLLER: return "weighted_single_leg_hip_raise_with_foot_on_foam_roller";
    case FIT_HIP_RAISE_EXERCISE_NAME_SINGLE_LEG_HIP_RAISE_WITH_FOOT_ON_MEDICINE_BALL: return "single_leg_hip_raise_with_foot_on_medicine_ball";
    case FIT_HIP_RAISE_EXERCISE_NAME_WEIGHTED_SINGLE_LEG_HIP_RAISE_WITH_FOOT_ON_MEDICINE_BALL: return "weighted_single_leg_hip_raise_with_foot_on_medicine_ball";
    case FIT_HIP_RAISE_EXERCISE_NAME_SINGLE_LEG_HIP_RAISE_WITH_HEAD_ON_BOSU_BALL: return "single_leg_hip_raise_with_head_on_bosu_ball";
    case FIT_HIP_RAISE_EXERCISE_NAME_WEIGHTED_SINGLE_LEG_HIP_RAISE_WITH_HEAD_ON_BOSU_BALL: return "weighted_single_leg_hip_raise_with_head_on_bosu_ball";
    case FIT_HIP_RAISE_EXERCISE_NAME_WEIGHTED_CLAM_BRIDGE: return "weighted_clam_bridge";
    case FIT_HIP_RAISE_EXERCISE_NAME_SINGLE_LEG_SWISS_BALL_HIP_RAISE_AND_LEG_CURL: return "single_leg_swiss_ball_hip_raise_and_leg_curl";
    case FIT_HIP_RAISE_EXERCISE_NAME_CLAMS: return "clams";
    case FIT_HIP_RAISE_EXERCISE_NAME_INNER_THIGH_CIRCLES: return "inner_thigh_circles";
    case FIT_HIP_RAISE_EXERCISE_NAME_INNER_THIGH_SIDE_LIFT: return "inner_thigh_side_lift";
    case FIT_HIP_RAISE_EXERCISE_NAME_LEG_CIRCLES: return "leg_circles";
    case FIT_HIP_RAISE_EXERCISE_NAME_LEG_LIFT: return "leg_lift";
    case FIT_HIP_RAISE_EXERCISE_NAME_LEG_LIFT_IN_EXTERNAL_ROTATION: return "leg_lift_in_external_rotation";
    default: return nil
  }
}
func rzfit_language_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_LANGUAGE_ENGLISH: return "english";
    case FIT_LANGUAGE_FRENCH: return "french";
    case FIT_LANGUAGE_ITALIAN: return "italian";
    case FIT_LANGUAGE_GERMAN: return "german";
    case FIT_LANGUAGE_SPANISH: return "spanish";
    case FIT_LANGUAGE_CROATIAN: return "croatian";
    case FIT_LANGUAGE_CZECH: return "czech";
    case FIT_LANGUAGE_DANISH: return "danish";
    case FIT_LANGUAGE_DUTCH: return "dutch";
    case FIT_LANGUAGE_FINNISH: return "finnish";
    case FIT_LANGUAGE_GREEK: return "greek";
    case FIT_LANGUAGE_HUNGARIAN: return "hungarian";
    case FIT_LANGUAGE_NORWEGIAN: return "norwegian";
    case FIT_LANGUAGE_POLISH: return "polish";
    case FIT_LANGUAGE_PORTUGUESE: return "portuguese";
    case FIT_LANGUAGE_SLOVAKIAN: return "slovakian";
    case FIT_LANGUAGE_SLOVENIAN: return "slovenian";
    case FIT_LANGUAGE_SWEDISH: return "swedish";
    case FIT_LANGUAGE_RUSSIAN: return "russian";
    case FIT_LANGUAGE_TURKISH: return "turkish";
    case FIT_LANGUAGE_LATVIAN: return "latvian";
    case FIT_LANGUAGE_UKRAINIAN: return "ukrainian";
    case FIT_LANGUAGE_ARABIC: return "arabic";
    case FIT_LANGUAGE_FARSI: return "farsi";
    case FIT_LANGUAGE_BULGARIAN: return "bulgarian";
    case FIT_LANGUAGE_ROMANIAN: return "romanian";
    case FIT_LANGUAGE_CHINESE: return "chinese";
    case FIT_LANGUAGE_JAPANESE: return "japanese";
    case FIT_LANGUAGE_KOREAN: return "korean";
    case FIT_LANGUAGE_TAIWANESE: return "taiwanese";
    case FIT_LANGUAGE_THAI: return "thai";
    case FIT_LANGUAGE_HEBREW: return "hebrew";
    case FIT_LANGUAGE_BRAZILIAN_PORTUGUESE: return "brazilian_portuguese";
    case FIT_LANGUAGE_INDONESIAN: return "indonesian";
    case FIT_LANGUAGE_MALAYSIAN: return "malaysian";
    case FIT_LANGUAGE_VIETNAMESE: return "vietnamese";
    case FIT_LANGUAGE_BURMESE: return "burmese";
    case FIT_LANGUAGE_MONGOLIAN: return "mongolian";
    case FIT_LANGUAGE_CUSTOM: return "custom";
    default: return nil
  }
}

func rzfit_backlight_timeout_string(input : FIT_UINT8) -> String? 
{
  switch  input {
    case FIT_BACKLIGHT_TIMEOUT_INFINITE: return "infinite";
    default: return nil
  }
}
func rzfit_exd_display_type_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_EXD_DISPLAY_TYPE_NUMERICAL: return "numerical";
    case FIT_EXD_DISPLAY_TYPE_SIMPLE: return "simple";
    case FIT_EXD_DISPLAY_TYPE_GRAPH: return "graph";
    case FIT_EXD_DISPLAY_TYPE_BAR: return "bar";
    case FIT_EXD_DISPLAY_TYPE_CIRCLE_GRAPH: return "circle_graph";
    case FIT_EXD_DISPLAY_TYPE_VIRTUAL_PARTNER: return "virtual_partner";
    case FIT_EXD_DISPLAY_TYPE_BALANCE: return "balance";
    case FIT_EXD_DISPLAY_TYPE_STRING_LIST: return "string_list";
    case FIT_EXD_DISPLAY_TYPE_STRING: return "string";
    case FIT_EXD_DISPLAY_TYPE_SIMPLE_DYNAMIC_ICON: return "simple_dynamic_icon";
    case FIT_EXD_DISPLAY_TYPE_GAUGE: return "gauge";
    default: return nil
  }
}
func rzfit_display_heart_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_DISPLAY_HEART_BPM: return "bpm";
    case FIT_DISPLAY_HEART_MAX: return "max";
    case FIT_DISPLAY_HEART_RESERVE: return "reserve";
    default: return nil
  }
}
func rzfit_exercise_category_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_EXERCISE_CATEGORY_BENCH_PRESS: return "bench_press";
    case FIT_EXERCISE_CATEGORY_CALF_RAISE: return "calf_raise";
    case FIT_EXERCISE_CATEGORY_CARDIO: return "cardio";
    case FIT_EXERCISE_CATEGORY_CARRY: return "carry";
    case FIT_EXERCISE_CATEGORY_CHOP: return "chop";
    case FIT_EXERCISE_CATEGORY_CORE: return "core";
    case FIT_EXERCISE_CATEGORY_CRUNCH: return "crunch";
    case FIT_EXERCISE_CATEGORY_CURL: return "curl";
    case FIT_EXERCISE_CATEGORY_DEADLIFT: return "deadlift";
    case FIT_EXERCISE_CATEGORY_FLYE: return "flye";
    case FIT_EXERCISE_CATEGORY_HIP_RAISE: return "hip_raise";
    case FIT_EXERCISE_CATEGORY_HIP_STABILITY: return "hip_stability";
    case FIT_EXERCISE_CATEGORY_HIP_SWING: return "hip_swing";
    case FIT_EXERCISE_CATEGORY_HYPEREXTENSION: return "hyperextension";
    case FIT_EXERCISE_CATEGORY_LATERAL_RAISE: return "lateral_raise";
    case FIT_EXERCISE_CATEGORY_LEG_CURL: return "leg_curl";
    case FIT_EXERCISE_CATEGORY_LEG_RAISE: return "leg_raise";
    case FIT_EXERCISE_CATEGORY_LUNGE: return "lunge";
    case FIT_EXERCISE_CATEGORY_OLYMPIC_LIFT: return "olympic_lift";
    case FIT_EXERCISE_CATEGORY_PLANK: return "plank";
    case FIT_EXERCISE_CATEGORY_PLYO: return "plyo";
    case FIT_EXERCISE_CATEGORY_PULL_UP: return "pull_up";
    case FIT_EXERCISE_CATEGORY_PUSH_UP: return "push_up";
    case FIT_EXERCISE_CATEGORY_ROW: return "row";
    case FIT_EXERCISE_CATEGORY_SHOULDER_PRESS: return "shoulder_press";
    case FIT_EXERCISE_CATEGORY_SHOULDER_STABILITY: return "shoulder_stability";
    case FIT_EXERCISE_CATEGORY_SHRUG: return "shrug";
    case FIT_EXERCISE_CATEGORY_SIT_UP: return "sit_up";
    case FIT_EXERCISE_CATEGORY_SQUAT: return "squat";
    case FIT_EXERCISE_CATEGORY_TOTAL_BODY: return "total_body";
    case FIT_EXERCISE_CATEGORY_TRICEPS_EXTENSION: return "triceps_extension";
    case FIT_EXERCISE_CATEGORY_WARM_UP: return "warm_up";
    case FIT_EXERCISE_CATEGORY_RUN: return "run";
    case FIT_EXERCISE_CATEGORY_UNKNOWN: return "unknown";
    default: return nil
  }
}
func rzfit_course_point_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_COURSE_POINT_GENERIC: return "generic";
    case FIT_COURSE_POINT_SUMMIT: return "summit";
    case FIT_COURSE_POINT_VALLEY: return "valley";
    case FIT_COURSE_POINT_WATER: return "water";
    case FIT_COURSE_POINT_FOOD: return "food";
    case FIT_COURSE_POINT_DANGER: return "danger";
    case FIT_COURSE_POINT_LEFT: return "left";
    case FIT_COURSE_POINT_RIGHT: return "right";
    case FIT_COURSE_POINT_STRAIGHT: return "straight";
    case FIT_COURSE_POINT_FIRST_AID: return "first_aid";
    case FIT_COURSE_POINT_FOURTH_CATEGORY: return "fourth_category";
    case FIT_COURSE_POINT_THIRD_CATEGORY: return "third_category";
    case FIT_COURSE_POINT_SECOND_CATEGORY: return "second_category";
    case FIT_COURSE_POINT_FIRST_CATEGORY: return "first_category";
    case FIT_COURSE_POINT_HORS_CATEGORY: return "hors_category";
    case FIT_COURSE_POINT_SPRINT: return "sprint";
    case FIT_COURSE_POINT_LEFT_FORK: return "left_fork";
    case FIT_COURSE_POINT_RIGHT_FORK: return "right_fork";
    case FIT_COURSE_POINT_MIDDLE_FORK: return "middle_fork";
    case FIT_COURSE_POINT_SLIGHT_LEFT: return "slight_left";
    case FIT_COURSE_POINT_SHARP_LEFT: return "sharp_left";
    case FIT_COURSE_POINT_SLIGHT_RIGHT: return "slight_right";
    case FIT_COURSE_POINT_SHARP_RIGHT: return "sharp_right";
    case FIT_COURSE_POINT_U_TURN: return "u_turn";
    case FIT_COURSE_POINT_SEGMENT_START: return "segment_start";
    case FIT_COURSE_POINT_SEGMENT_END: return "segment_end";
    default: return nil
  }
}
func rzfit_swim_stroke_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_SWIM_STROKE_FREESTYLE: return "freestyle";
    case FIT_SWIM_STROKE_BACKSTROKE: return "backstroke";
    case FIT_SWIM_STROKE_BREASTSTROKE: return "breaststroke";
    case FIT_SWIM_STROKE_BUTTERFLY: return "butterfly";
    case FIT_SWIM_STROKE_DRILL: return "drill";
    case FIT_SWIM_STROKE_MIXED: return "mixed";
    case FIT_SWIM_STROKE_IM: return "im";
    default: return nil
  }
}
func rzfit_intensity_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_INTENSITY_ACTIVE: return "active";
    case FIT_INTENSITY_REST: return "rest";
    case FIT_INTENSITY_WARMUP: return "warmup";
    case FIT_INTENSITY_COOLDOWN: return "cooldown";
    default: return nil
  }
}

func rzfit_segment_delete_status_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_SEGMENT_DELETE_STATUS_DO_NOT_DELETE: return "do_not_delete";
    case FIT_SEGMENT_DELETE_STATUS_DELETE_ONE: return "delete_one";
    case FIT_SEGMENT_DELETE_STATUS_DELETE_ALL: return "delete_all";
    default: return nil
  }
}
func rzfit_display_power_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_DISPLAY_POWER_WATTS: return "watts";
    case FIT_DISPLAY_POWER_PERCENT_FTP: return "percent_ftp";
    default: return nil
  }
}
func rzfit_switch_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_SWITCH_OFF: return "off";
    case FIT_SWITCH_ON: return "on";
    case FIT_SWITCH_AUTO: return "auto";
    default: return nil
  }
}
func rzfit_activity_type_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_ACTIVITY_TYPE_GENERIC: return "generic";
    case FIT_ACTIVITY_TYPE_RUNNING: return "running";
    case FIT_ACTIVITY_TYPE_CYCLING: return "cycling";
    case FIT_ACTIVITY_TYPE_TRANSITION: return "transition";
    case FIT_ACTIVITY_TYPE_FITNESS_EQUIPMENT: return "fitness_equipment";
    case FIT_ACTIVITY_TYPE_SWIMMING: return "swimming";
    case FIT_ACTIVITY_TYPE_WALKING: return "walking";
    case FIT_ACTIVITY_TYPE_SEDENTARY: return "sedentary";
    case FIT_ACTIVITY_TYPE_ALL: return "all";
    default: return nil
  }
}
func rzfit_hyperextension_exercise_name_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_HYPEREXTENSION_EXERCISE_NAME_BACK_EXTENSION_WITH_OPPOSITE_ARM_AND_LEG_REACH: return "back_extension_with_opposite_arm_and_leg_reach";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_WEIGHTED_BACK_EXTENSION_WITH_OPPOSITE_ARM_AND_LEG_REACH: return "weighted_back_extension_with_opposite_arm_and_leg_reach";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_BASE_ROTATIONS: return "base_rotations";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_WEIGHTED_BASE_ROTATIONS: return "weighted_base_rotations";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_BENT_KNEE_REVERSE_HYPEREXTENSION: return "bent_knee_reverse_hyperextension";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_WEIGHTED_BENT_KNEE_REVERSE_HYPEREXTENSION: return "weighted_bent_knee_reverse_hyperextension";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_HOLLOW_HOLD_AND_ROLL: return "hollow_hold_and_roll";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_WEIGHTED_HOLLOW_HOLD_AND_ROLL: return "weighted_hollow_hold_and_roll";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_KICKS: return "kicks";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_WEIGHTED_KICKS: return "weighted_kicks";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_KNEE_RAISES: return "knee_raises";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_WEIGHTED_KNEE_RAISES: return "weighted_knee_raises";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_KNEELING_SUPERMAN: return "kneeling_superman";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_WEIGHTED_KNEELING_SUPERMAN: return "weighted_kneeling_superman";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_LAT_PULL_DOWN_WITH_ROW: return "lat_pull_down_with_row";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_MEDICINE_BALL_DEADLIFT_TO_REACH: return "medicine_ball_deadlift_to_reach";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_ONE_ARM_ONE_LEG_ROW: return "one_arm_one_leg_row";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_ONE_ARM_ROW_WITH_BAND: return "one_arm_row_with_band";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_OVERHEAD_LUNGE_WITH_MEDICINE_BALL: return "overhead_lunge_with_medicine_ball";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_PLANK_KNEE_TUCKS: return "plank_knee_tucks";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_WEIGHTED_PLANK_KNEE_TUCKS: return "weighted_plank_knee_tucks";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_SIDE_STEP: return "side_step";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_WEIGHTED_SIDE_STEP: return "weighted_side_step";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_SINGLE_LEG_BACK_EXTENSION: return "single_leg_back_extension";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_WEIGHTED_SINGLE_LEG_BACK_EXTENSION: return "weighted_single_leg_back_extension";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_SPINE_EXTENSION: return "spine_extension";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_WEIGHTED_SPINE_EXTENSION: return "weighted_spine_extension";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_STATIC_BACK_EXTENSION: return "static_back_extension";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_WEIGHTED_STATIC_BACK_EXTENSION: return "weighted_static_back_extension";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_SUPERMAN_FROM_FLOOR: return "superman_from_floor";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_WEIGHTED_SUPERMAN_FROM_FLOOR: return "weighted_superman_from_floor";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_SWISS_BALL_BACK_EXTENSION: return "swiss_ball_back_extension";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_WEIGHTED_SWISS_BALL_BACK_EXTENSION: return "weighted_swiss_ball_back_extension";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_SWISS_BALL_HYPEREXTENSION: return "swiss_ball_hyperextension";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_WEIGHTED_SWISS_BALL_HYPEREXTENSION: return "weighted_swiss_ball_hyperextension";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_SWISS_BALL_OPPOSITE_ARM_AND_LEG_LIFT: return "swiss_ball_opposite_arm_and_leg_lift";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_WEIGHTED_SWISS_BALL_OPPOSITE_ARM_AND_LEG_LIFT: return "weighted_swiss_ball_opposite_arm_and_leg_lift";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_SUPERMAN_ON_SWISS_BALL: return "superman_on_swiss_ball";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_COBRA: return "cobra";
    case FIT_HYPEREXTENSION_EXERCISE_NAME_SUPINE_FLOOR_BARRE: return "supine_floor_barre";
    default: return nil
  }
}
func rzfit_goal_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_GOAL_TIME: return "time";
    case FIT_GOAL_DISTANCE: return "distance";
    case FIT_GOAL_CALORIES: return "calories";
    case FIT_GOAL_FREQUENCY: return "frequency";
    case FIT_GOAL_STEPS: return "steps";
    case FIT_GOAL_ASCENT: return "ascent";
    case FIT_GOAL_ACTIVE_MINUTES: return "active_minutes";
    default: return nil
  }
}
func rzfit_battery_status_string(input : FIT_UINT8) -> String? 
{
  switch  input {
    case FIT_BATTERY_STATUS_NEW: return "new";
    case FIT_BATTERY_STATUS_GOOD: return "good";
    case FIT_BATTERY_STATUS_OK: return "ok";
    case FIT_BATTERY_STATUS_LOW: return "low";
    case FIT_BATTERY_STATUS_CRITICAL: return "critical";
    case FIT_BATTERY_STATUS_CHARGING: return "charging";
    case FIT_BATTERY_STATUS_UNKNOWN: return "unknown";
    default: return nil
  }
}
func rzfit_hr_zone_calc_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_HR_ZONE_CALC_CUSTOM: return "custom";
    case FIT_HR_ZONE_CALC_PERCENT_MAX_HR: return "percent_max_hr";
    case FIT_HR_ZONE_CALC_PERCENT_HRR: return "percent_hrr";
    default: return nil
  }
}
func rzfit_crunch_exercise_name_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_CRUNCH_EXERCISE_NAME_BICYCLE_CRUNCH: return "bicycle_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_CABLE_CRUNCH: return "cable_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_CIRCULAR_ARM_CRUNCH: return "circular_arm_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_CROSSED_ARMS_CRUNCH: return "crossed_arms_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_WEIGHTED_CROSSED_ARMS_CRUNCH: return "weighted_crossed_arms_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_CROSS_LEG_REVERSE_CRUNCH: return "cross_leg_reverse_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_WEIGHTED_CROSS_LEG_REVERSE_CRUNCH: return "weighted_cross_leg_reverse_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_CRUNCH_CHOP: return "crunch_chop";
    case FIT_CRUNCH_EXERCISE_NAME_WEIGHTED_CRUNCH_CHOP: return "weighted_crunch_chop";
    case FIT_CRUNCH_EXERCISE_NAME_DOUBLE_CRUNCH: return "double_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_WEIGHTED_DOUBLE_CRUNCH: return "weighted_double_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_ELBOW_TO_KNEE_CRUNCH: return "elbow_to_knee_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_WEIGHTED_ELBOW_TO_KNEE_CRUNCH: return "weighted_elbow_to_knee_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_FLUTTER_KICKS: return "flutter_kicks";
    case FIT_CRUNCH_EXERCISE_NAME_WEIGHTED_FLUTTER_KICKS: return "weighted_flutter_kicks";
    case FIT_CRUNCH_EXERCISE_NAME_FOAM_ROLLER_REVERSE_CRUNCH_ON_BENCH: return "foam_roller_reverse_crunch_on_bench";
    case FIT_CRUNCH_EXERCISE_NAME_WEIGHTED_FOAM_ROLLER_REVERSE_CRUNCH_ON_BENCH: return "weighted_foam_roller_reverse_crunch_on_bench";
    case FIT_CRUNCH_EXERCISE_NAME_FOAM_ROLLER_REVERSE_CRUNCH_WITH_DUMBBELL: return "foam_roller_reverse_crunch_with_dumbbell";
    case FIT_CRUNCH_EXERCISE_NAME_FOAM_ROLLER_REVERSE_CRUNCH_WITH_MEDICINE_BALL: return "foam_roller_reverse_crunch_with_medicine_ball";
    case FIT_CRUNCH_EXERCISE_NAME_FROG_PRESS: return "frog_press";
    case FIT_CRUNCH_EXERCISE_NAME_HANGING_KNEE_RAISE_OBLIQUE_CRUNCH: return "hanging_knee_raise_oblique_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_WEIGHTED_HANGING_KNEE_RAISE_OBLIQUE_CRUNCH: return "weighted_hanging_knee_raise_oblique_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_HIP_CROSSOVER: return "hip_crossover";
    case FIT_CRUNCH_EXERCISE_NAME_WEIGHTED_HIP_CROSSOVER: return "weighted_hip_crossover";
    case FIT_CRUNCH_EXERCISE_NAME_HOLLOW_ROCK: return "hollow_rock";
    case FIT_CRUNCH_EXERCISE_NAME_WEIGHTED_HOLLOW_ROCK: return "weighted_hollow_rock";
    case FIT_CRUNCH_EXERCISE_NAME_INCLINE_REVERSE_CRUNCH: return "incline_reverse_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_WEIGHTED_INCLINE_REVERSE_CRUNCH: return "weighted_incline_reverse_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_KNEELING_CABLE_CRUNCH: return "kneeling_cable_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_KNEELING_CROSS_CRUNCH: return "kneeling_cross_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_WEIGHTED_KNEELING_CROSS_CRUNCH: return "weighted_kneeling_cross_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_KNEELING_OBLIQUE_CABLE_CRUNCH: return "kneeling_oblique_cable_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_KNEES_TO_ELBOW: return "knees_to_elbow";
    case FIT_CRUNCH_EXERCISE_NAME_LEG_EXTENSIONS: return "leg_extensions";
    case FIT_CRUNCH_EXERCISE_NAME_WEIGHTED_LEG_EXTENSIONS: return "weighted_leg_extensions";
    case FIT_CRUNCH_EXERCISE_NAME_LEG_LEVERS: return "leg_levers";
    case FIT_CRUNCH_EXERCISE_NAME_MCGILL_CURL_UP: return "mcgill_curl_up";
    case FIT_CRUNCH_EXERCISE_NAME_WEIGHTED_MCGILL_CURL_UP: return "weighted_mcgill_curl_up";
    case FIT_CRUNCH_EXERCISE_NAME_MODIFIED_PILATES_ROLL_UP_WITH_BALL: return "modified_pilates_roll_up_with_ball";
    case FIT_CRUNCH_EXERCISE_NAME_WEIGHTED_MODIFIED_PILATES_ROLL_UP_WITH_BALL: return "weighted_modified_pilates_roll_up_with_ball";
    case FIT_CRUNCH_EXERCISE_NAME_PILATES_CRUNCH: return "pilates_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_WEIGHTED_PILATES_CRUNCH: return "weighted_pilates_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_PILATES_ROLL_UP_WITH_BALL: return "pilates_roll_up_with_ball";
    case FIT_CRUNCH_EXERCISE_NAME_WEIGHTED_PILATES_ROLL_UP_WITH_BALL: return "weighted_pilates_roll_up_with_ball";
    case FIT_CRUNCH_EXERCISE_NAME_RAISED_LEGS_CRUNCH: return "raised_legs_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_WEIGHTED_RAISED_LEGS_CRUNCH: return "weighted_raised_legs_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_REVERSE_CRUNCH: return "reverse_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_WEIGHTED_REVERSE_CRUNCH: return "weighted_reverse_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_REVERSE_CRUNCH_ON_A_BENCH: return "reverse_crunch_on_a_bench";
    case FIT_CRUNCH_EXERCISE_NAME_WEIGHTED_REVERSE_CRUNCH_ON_A_BENCH: return "weighted_reverse_crunch_on_a_bench";
    case FIT_CRUNCH_EXERCISE_NAME_REVERSE_CURL_AND_LIFT: return "reverse_curl_and_lift";
    case FIT_CRUNCH_EXERCISE_NAME_WEIGHTED_REVERSE_CURL_AND_LIFT: return "weighted_reverse_curl_and_lift";
    case FIT_CRUNCH_EXERCISE_NAME_ROTATIONAL_LIFT: return "rotational_lift";
    case FIT_CRUNCH_EXERCISE_NAME_WEIGHTED_ROTATIONAL_LIFT: return "weighted_rotational_lift";
    case FIT_CRUNCH_EXERCISE_NAME_SEATED_ALTERNATING_REVERSE_CRUNCH: return "seated_alternating_reverse_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_WEIGHTED_SEATED_ALTERNATING_REVERSE_CRUNCH: return "weighted_seated_alternating_reverse_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_SEATED_LEG_U: return "seated_leg_u";
    case FIT_CRUNCH_EXERCISE_NAME_WEIGHTED_SEATED_LEG_U: return "weighted_seated_leg_u";
    case FIT_CRUNCH_EXERCISE_NAME_SIDE_TO_SIDE_CRUNCH_AND_WEAVE: return "side_to_side_crunch_and_weave";
    case FIT_CRUNCH_EXERCISE_NAME_WEIGHTED_SIDE_TO_SIDE_CRUNCH_AND_WEAVE: return "weighted_side_to_side_crunch_and_weave";
    case FIT_CRUNCH_EXERCISE_NAME_SINGLE_LEG_REVERSE_CRUNCH: return "single_leg_reverse_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_WEIGHTED_SINGLE_LEG_REVERSE_CRUNCH: return "weighted_single_leg_reverse_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_SKATER_CRUNCH_CROSS: return "skater_crunch_cross";
    case FIT_CRUNCH_EXERCISE_NAME_WEIGHTED_SKATER_CRUNCH_CROSS: return "weighted_skater_crunch_cross";
    case FIT_CRUNCH_EXERCISE_NAME_STANDING_CABLE_CRUNCH: return "standing_cable_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_STANDING_SIDE_CRUNCH: return "standing_side_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_STEP_CLIMB: return "step_climb";
    case FIT_CRUNCH_EXERCISE_NAME_WEIGHTED_STEP_CLIMB: return "weighted_step_climb";
    case FIT_CRUNCH_EXERCISE_NAME_SWISS_BALL_CRUNCH: return "swiss_ball_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_SWISS_BALL_REVERSE_CRUNCH: return "swiss_ball_reverse_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_WEIGHTED_SWISS_BALL_REVERSE_CRUNCH: return "weighted_swiss_ball_reverse_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_SWISS_BALL_RUSSIAN_TWIST: return "swiss_ball_russian_twist";
    case FIT_CRUNCH_EXERCISE_NAME_WEIGHTED_SWISS_BALL_RUSSIAN_TWIST: return "weighted_swiss_ball_russian_twist";
    case FIT_CRUNCH_EXERCISE_NAME_SWISS_BALL_SIDE_CRUNCH: return "swiss_ball_side_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_WEIGHTED_SWISS_BALL_SIDE_CRUNCH: return "weighted_swiss_ball_side_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_THORACIC_CRUNCHES_ON_FOAM_ROLLER: return "thoracic_crunches_on_foam_roller";
    case FIT_CRUNCH_EXERCISE_NAME_WEIGHTED_THORACIC_CRUNCHES_ON_FOAM_ROLLER: return "weighted_thoracic_crunches_on_foam_roller";
    case FIT_CRUNCH_EXERCISE_NAME_TRICEPS_CRUNCH: return "triceps_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_WEIGHTED_BICYCLE_CRUNCH: return "weighted_bicycle_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_WEIGHTED_CRUNCH: return "weighted_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_WEIGHTED_SWISS_BALL_CRUNCH: return "weighted_swiss_ball_crunch";
    case FIT_CRUNCH_EXERCISE_NAME_TOES_TO_BAR: return "toes_to_bar";
    case FIT_CRUNCH_EXERCISE_NAME_WEIGHTED_TOES_TO_BAR: return "weighted_toes_to_bar";
    case FIT_CRUNCH_EXERCISE_NAME_CRUNCH: return "crunch";
    case FIT_CRUNCH_EXERCISE_NAME_STRAIGHT_LEG_CRUNCH_WITH_BALL: return "straight_leg_crunch_with_ball";
    default: return nil
  }
}
func rzfit_sport_event_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_SPORT_EVENT_UNCATEGORIZED: return "uncategorized";
    case FIT_SPORT_EVENT_GEOCACHING: return "geocaching";
    case FIT_SPORT_EVENT_FITNESS: return "fitness";
    case FIT_SPORT_EVENT_RECREATION: return "recreation";
    case FIT_SPORT_EVENT_RACE: return "race";
    case FIT_SPORT_EVENT_SPECIAL_EVENT: return "special_event";
    case FIT_SPORT_EVENT_TRAINING: return "training";
    case FIT_SPORT_EVENT_TRANSPORTATION: return "transportation";
    case FIT_SPORT_EVENT_TOURING: return "touring";
    default: return nil
  }
}
func rzfit_activity_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_ACTIVITY_MANUAL: return "manual";
    case FIT_ACTIVITY_AUTO_MULTI_SPORT: return "auto_multi_sport";
    default: return nil
  }
}
func rzfit_curl_exercise_name_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_CURL_EXERCISE_NAME_ALTERNATING_DUMBBELL_BICEPS_CURL: return "alternating_dumbbell_biceps_curl";
    case FIT_CURL_EXERCISE_NAME_ALTERNATING_DUMBBELL_BICEPS_CURL_ON_SWISS_BALL: return "alternating_dumbbell_biceps_curl_on_swiss_ball";
    case FIT_CURL_EXERCISE_NAME_ALTERNATING_INCLINE_DUMBBELL_BICEPS_CURL: return "alternating_incline_dumbbell_biceps_curl";
    case FIT_CURL_EXERCISE_NAME_BARBELL_BICEPS_CURL: return "barbell_biceps_curl";
    case FIT_CURL_EXERCISE_NAME_BARBELL_REVERSE_WRIST_CURL: return "barbell_reverse_wrist_curl";
    case FIT_CURL_EXERCISE_NAME_BARBELL_WRIST_CURL: return "barbell_wrist_curl";
    case FIT_CURL_EXERCISE_NAME_BEHIND_THE_BACK_BARBELL_REVERSE_WRIST_CURL: return "behind_the_back_barbell_reverse_wrist_curl";
    case FIT_CURL_EXERCISE_NAME_BEHIND_THE_BACK_ONE_ARM_CABLE_CURL: return "behind_the_back_one_arm_cable_curl";
    case FIT_CURL_EXERCISE_NAME_CABLE_BICEPS_CURL: return "cable_biceps_curl";
    case FIT_CURL_EXERCISE_NAME_CABLE_HAMMER_CURL: return "cable_hammer_curl";
    case FIT_CURL_EXERCISE_NAME_CHEATING_BARBELL_BICEPS_CURL: return "cheating_barbell_biceps_curl";
    case FIT_CURL_EXERCISE_NAME_CLOSE_GRIP_EZ_BAR_BICEPS_CURL: return "close_grip_ez_bar_biceps_curl";
    case FIT_CURL_EXERCISE_NAME_CROSS_BODY_DUMBBELL_HAMMER_CURL: return "cross_body_dumbbell_hammer_curl";
    case FIT_CURL_EXERCISE_NAME_DEAD_HANG_BICEPS_CURL: return "dead_hang_biceps_curl";
    case FIT_CURL_EXERCISE_NAME_DECLINE_HAMMER_CURL: return "decline_hammer_curl";
    case FIT_CURL_EXERCISE_NAME_DUMBBELL_BICEPS_CURL_WITH_STATIC_HOLD: return "dumbbell_biceps_curl_with_static_hold";
    case FIT_CURL_EXERCISE_NAME_DUMBBELL_HAMMER_CURL: return "dumbbell_hammer_curl";
    case FIT_CURL_EXERCISE_NAME_DUMBBELL_REVERSE_WRIST_CURL: return "dumbbell_reverse_wrist_curl";
    case FIT_CURL_EXERCISE_NAME_DUMBBELL_WRIST_CURL: return "dumbbell_wrist_curl";
    case FIT_CURL_EXERCISE_NAME_EZ_BAR_PREACHER_CURL: return "ez_bar_preacher_curl";
    case FIT_CURL_EXERCISE_NAME_FORWARD_BEND_BICEPS_CURL: return "forward_bend_biceps_curl";
    case FIT_CURL_EXERCISE_NAME_HAMMER_CURL_TO_PRESS: return "hammer_curl_to_press";
    case FIT_CURL_EXERCISE_NAME_INCLINE_DUMBBELL_BICEPS_CURL: return "incline_dumbbell_biceps_curl";
    case FIT_CURL_EXERCISE_NAME_INCLINE_OFFSET_THUMB_DUMBBELL_CURL: return "incline_offset_thumb_dumbbell_curl";
    case FIT_CURL_EXERCISE_NAME_KETTLEBELL_BICEPS_CURL: return "kettlebell_biceps_curl";
    case FIT_CURL_EXERCISE_NAME_LYING_CONCENTRATION_CABLE_CURL: return "lying_concentration_cable_curl";
    case FIT_CURL_EXERCISE_NAME_ONE_ARM_PREACHER_CURL: return "one_arm_preacher_curl";
    case FIT_CURL_EXERCISE_NAME_PLATE_PINCH_CURL: return "plate_pinch_curl";
    case FIT_CURL_EXERCISE_NAME_PREACHER_CURL_WITH_CABLE: return "preacher_curl_with_cable";
    case FIT_CURL_EXERCISE_NAME_REVERSE_EZ_BAR_CURL: return "reverse_ez_bar_curl";
    case FIT_CURL_EXERCISE_NAME_REVERSE_GRIP_WRIST_CURL: return "reverse_grip_wrist_curl";
    case FIT_CURL_EXERCISE_NAME_REVERSE_GRIP_BARBELL_BICEPS_CURL: return "reverse_grip_barbell_biceps_curl";
    case FIT_CURL_EXERCISE_NAME_SEATED_ALTERNATING_DUMBBELL_BICEPS_CURL: return "seated_alternating_dumbbell_biceps_curl";
    case FIT_CURL_EXERCISE_NAME_SEATED_DUMBBELL_BICEPS_CURL: return "seated_dumbbell_biceps_curl";
    case FIT_CURL_EXERCISE_NAME_SEATED_REVERSE_DUMBBELL_CURL: return "seated_reverse_dumbbell_curl";
    case FIT_CURL_EXERCISE_NAME_SPLIT_STANCE_OFFSET_PINKY_DUMBBELL_CURL: return "split_stance_offset_pinky_dumbbell_curl";
    case FIT_CURL_EXERCISE_NAME_STANDING_ALTERNATING_DUMBBELL_CURLS: return "standing_alternating_dumbbell_curls";
    case FIT_CURL_EXERCISE_NAME_STANDING_DUMBBELL_BICEPS_CURL: return "standing_dumbbell_biceps_curl";
    case FIT_CURL_EXERCISE_NAME_STANDING_EZ_BAR_BICEPS_CURL: return "standing_ez_bar_biceps_curl";
    case FIT_CURL_EXERCISE_NAME_STATIC_CURL: return "static_curl";
    case FIT_CURL_EXERCISE_NAME_SWISS_BALL_DUMBBELL_OVERHEAD_TRICEPS_EXTENSION: return "swiss_ball_dumbbell_overhead_triceps_extension";
    case FIT_CURL_EXERCISE_NAME_SWISS_BALL_EZ_BAR_PREACHER_CURL: return "swiss_ball_ez_bar_preacher_curl";
    case FIT_CURL_EXERCISE_NAME_TWISTING_STANDING_DUMBBELL_BICEPS_CURL: return "twisting_standing_dumbbell_biceps_curl";
    case FIT_CURL_EXERCISE_NAME_WIDE_GRIP_EZ_BAR_BICEPS_CURL: return "wide_grip_ez_bar_biceps_curl";
    default: return nil
  }
}
func rzfit_body_location_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_BODY_LOCATION_LEFT_LEG: return "left_leg";
    case FIT_BODY_LOCATION_LEFT_CALF: return "left_calf";
    case FIT_BODY_LOCATION_LEFT_SHIN: return "left_shin";
    case FIT_BODY_LOCATION_LEFT_HAMSTRING: return "left_hamstring";
    case FIT_BODY_LOCATION_LEFT_QUAD: return "left_quad";
    case FIT_BODY_LOCATION_LEFT_GLUTE: return "left_glute";
    case FIT_BODY_LOCATION_RIGHT_LEG: return "right_leg";
    case FIT_BODY_LOCATION_RIGHT_CALF: return "right_calf";
    case FIT_BODY_LOCATION_RIGHT_SHIN: return "right_shin";
    case FIT_BODY_LOCATION_RIGHT_HAMSTRING: return "right_hamstring";
    case FIT_BODY_LOCATION_RIGHT_QUAD: return "right_quad";
    case FIT_BODY_LOCATION_RIGHT_GLUTE: return "right_glute";
    case FIT_BODY_LOCATION_TORSO_BACK: return "torso_back";
    case FIT_BODY_LOCATION_LEFT_LOWER_BACK: return "left_lower_back";
    case FIT_BODY_LOCATION_LEFT_UPPER_BACK: return "left_upper_back";
    case FIT_BODY_LOCATION_RIGHT_LOWER_BACK: return "right_lower_back";
    case FIT_BODY_LOCATION_RIGHT_UPPER_BACK: return "right_upper_back";
    case FIT_BODY_LOCATION_TORSO_FRONT: return "torso_front";
    case FIT_BODY_LOCATION_LEFT_ABDOMEN: return "left_abdomen";
    case FIT_BODY_LOCATION_LEFT_CHEST: return "left_chest";
    case FIT_BODY_LOCATION_RIGHT_ABDOMEN: return "right_abdomen";
    case FIT_BODY_LOCATION_RIGHT_CHEST: return "right_chest";
    case FIT_BODY_LOCATION_LEFT_ARM: return "left_arm";
    case FIT_BODY_LOCATION_LEFT_SHOULDER: return "left_shoulder";
    case FIT_BODY_LOCATION_LEFT_BICEP: return "left_bicep";
    case FIT_BODY_LOCATION_LEFT_TRICEP: return "left_tricep";
    case FIT_BODY_LOCATION_LEFT_BRACHIORADIALIS: return "left_brachioradialis";
    case FIT_BODY_LOCATION_LEFT_FOREARM_EXTENSORS: return "left_forearm_extensors";
    case FIT_BODY_LOCATION_RIGHT_ARM: return "right_arm";
    case FIT_BODY_LOCATION_RIGHT_SHOULDER: return "right_shoulder";
    case FIT_BODY_LOCATION_RIGHT_BICEP: return "right_bicep";
    case FIT_BODY_LOCATION_RIGHT_TRICEP: return "right_tricep";
    case FIT_BODY_LOCATION_RIGHT_BRACHIORADIALIS: return "right_brachioradialis";
    case FIT_BODY_LOCATION_RIGHT_FOREARM_EXTENSORS: return "right_forearm_extensors";
    case FIT_BODY_LOCATION_NECK: return "neck";
    case FIT_BODY_LOCATION_THROAT: return "throat";
    case FIT_BODY_LOCATION_WAIST_MID_BACK: return "waist_mid_back";
    case FIT_BODY_LOCATION_WAIST_FRONT: return "waist_front";
    case FIT_BODY_LOCATION_WAIST_LEFT: return "waist_left";
    case FIT_BODY_LOCATION_WAIST_RIGHT: return "waist_right";
    default: return nil
  }
}

func rzfit_weather_status_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_WEATHER_STATUS_CLEAR: return "clear";
    case FIT_WEATHER_STATUS_PARTLY_CLOUDY: return "partly_cloudy";
    case FIT_WEATHER_STATUS_MOSTLY_CLOUDY: return "mostly_cloudy";
    case FIT_WEATHER_STATUS_RAIN: return "rain";
    case FIT_WEATHER_STATUS_SNOW: return "snow";
    case FIT_WEATHER_STATUS_WINDY: return "windy";
    case FIT_WEATHER_STATUS_THUNDERSTORMS: return "thunderstorms";
    case FIT_WEATHER_STATUS_WINTRY_MIX: return "wintry_mix";
    case FIT_WEATHER_STATUS_FOG: return "fog";
    case FIT_WEATHER_STATUS_HAZY: return "hazy";
    case FIT_WEATHER_STATUS_HAIL: return "hail";
    case FIT_WEATHER_STATUS_SCATTERED_SHOWERS: return "scattered_showers";
    case FIT_WEATHER_STATUS_SCATTERED_THUNDERSTORMS: return "scattered_thunderstorms";
    case FIT_WEATHER_STATUS_UNKNOWN_PRECIPITATION: return "unknown_precipitation";
    case FIT_WEATHER_STATUS_LIGHT_RAIN: return "light_rain";
    case FIT_WEATHER_STATUS_HEAVY_RAIN: return "heavy_rain";
    case FIT_WEATHER_STATUS_LIGHT_SNOW: return "light_snow";
    case FIT_WEATHER_STATUS_HEAVY_SNOW: return "heavy_snow";
    case FIT_WEATHER_STATUS_LIGHT_RAIN_SNOW: return "light_rain_snow";
    case FIT_WEATHER_STATUS_HEAVY_RAIN_SNOW: return "heavy_rain_snow";
    case FIT_WEATHER_STATUS_CLOUDY: return "cloudy";
    default: return nil
  }
}
func rzfit_weather_report_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_WEATHER_REPORT_CURRENT: return "current";
    case FIT_WEATHER_REPORT_FORECAST: return "forecast";
    case FIT_WEATHER_REPORT_HOURLY_FORECAST: return "hourly_forecast";
    case FIT_WEATHER_REPORT_DAILY_FORECAST: return "daily_forecast";
    default: return nil
  }
}
func rzfit_activity_class_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_ACTIVITY_CLASS_LEVEL_MAX: return "level_max";
    default: return nil
  }
}
func rzfit_weather_severe_type_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_WEATHER_SEVERE_TYPE_UNSPECIFIED: return "unspecified";
    case FIT_WEATHER_SEVERE_TYPE_TORNADO: return "tornado";
    case FIT_WEATHER_SEVERE_TYPE_TSUNAMI: return "tsunami";
    case FIT_WEATHER_SEVERE_TYPE_HURRICANE: return "hurricane";
    case FIT_WEATHER_SEVERE_TYPE_EXTREME_WIND: return "extreme_wind";
    case FIT_WEATHER_SEVERE_TYPE_TYPHOON: return "typhoon";
    case FIT_WEATHER_SEVERE_TYPE_INLAND_HURRICANE: return "inland_hurricane";
    case FIT_WEATHER_SEVERE_TYPE_HURRICANE_FORCE_WIND: return "hurricane_force_wind";
    case FIT_WEATHER_SEVERE_TYPE_WATERSPOUT: return "waterspout";
    case FIT_WEATHER_SEVERE_TYPE_SEVERE_THUNDERSTORM: return "severe_thunderstorm";
    case FIT_WEATHER_SEVERE_TYPE_WRECKHOUSE_WINDS: return "wreckhouse_winds";
    case FIT_WEATHER_SEVERE_TYPE_LES_SUETES_WIND: return "les_suetes_wind";
    case FIT_WEATHER_SEVERE_TYPE_AVALANCHE: return "avalanche";
    case FIT_WEATHER_SEVERE_TYPE_FLASH_FLOOD: return "flash_flood";
    case FIT_WEATHER_SEVERE_TYPE_TROPICAL_STORM: return "tropical_storm";
    case FIT_WEATHER_SEVERE_TYPE_INLAND_TROPICAL_STORM: return "inland_tropical_storm";
    case FIT_WEATHER_SEVERE_TYPE_BLIZZARD: return "blizzard";
    case FIT_WEATHER_SEVERE_TYPE_ICE_STORM: return "ice_storm";
    case FIT_WEATHER_SEVERE_TYPE_FREEZING_RAIN: return "freezing_rain";
    case FIT_WEATHER_SEVERE_TYPE_DEBRIS_FLOW: return "debris_flow";
    case FIT_WEATHER_SEVERE_TYPE_FLASH_FREEZE: return "flash_freeze";
    case FIT_WEATHER_SEVERE_TYPE_DUST_STORM: return "dust_storm";
    case FIT_WEATHER_SEVERE_TYPE_HIGH_WIND: return "high_wind";
    case FIT_WEATHER_SEVERE_TYPE_WINTER_STORM: return "winter_storm";
    case FIT_WEATHER_SEVERE_TYPE_HEAVY_FREEZING_SPRAY: return "heavy_freezing_spray";
    case FIT_WEATHER_SEVERE_TYPE_EXTREME_COLD: return "extreme_cold";
    case FIT_WEATHER_SEVERE_TYPE_WIND_CHILL: return "wind_chill";
    case FIT_WEATHER_SEVERE_TYPE_COLD_WAVE: return "cold_wave";
    case FIT_WEATHER_SEVERE_TYPE_HEAVY_SNOW_ALERT: return "heavy_snow_alert";
    case FIT_WEATHER_SEVERE_TYPE_LAKE_EFFECT_BLOWING_SNOW: return "lake_effect_blowing_snow";
    case FIT_WEATHER_SEVERE_TYPE_SNOW_SQUALL: return "snow_squall";
    case FIT_WEATHER_SEVERE_TYPE_LAKE_EFFECT_SNOW: return "lake_effect_snow";
    case FIT_WEATHER_SEVERE_TYPE_WINTER_WEATHER: return "winter_weather";
    case FIT_WEATHER_SEVERE_TYPE_SLEET: return "sleet";
    case FIT_WEATHER_SEVERE_TYPE_SNOWFALL: return "snowfall";
    case FIT_WEATHER_SEVERE_TYPE_SNOW_AND_BLOWING_SNOW: return "snow_and_blowing_snow";
    case FIT_WEATHER_SEVERE_TYPE_BLOWING_SNOW: return "blowing_snow";
    case FIT_WEATHER_SEVERE_TYPE_SNOW_ALERT: return "snow_alert";
    case FIT_WEATHER_SEVERE_TYPE_ARCTIC_OUTFLOW: return "arctic_outflow";
    case FIT_WEATHER_SEVERE_TYPE_FREEZING_DRIZZLE: return "freezing_drizzle";
    case FIT_WEATHER_SEVERE_TYPE_STORM: return "storm";
    case FIT_WEATHER_SEVERE_TYPE_STORM_SURGE: return "storm_surge";
    case FIT_WEATHER_SEVERE_TYPE_RAINFALL: return "rainfall";
    case FIT_WEATHER_SEVERE_TYPE_AREAL_FLOOD: return "areal_flood";
    case FIT_WEATHER_SEVERE_TYPE_COASTAL_FLOOD: return "coastal_flood";
    case FIT_WEATHER_SEVERE_TYPE_LAKESHORE_FLOOD: return "lakeshore_flood";
    case FIT_WEATHER_SEVERE_TYPE_EXCESSIVE_HEAT: return "excessive_heat";
    case FIT_WEATHER_SEVERE_TYPE_HEAT: return "heat";
    case FIT_WEATHER_SEVERE_TYPE_WEATHER: return "weather";
    case FIT_WEATHER_SEVERE_TYPE_HIGH_HEAT_AND_HUMIDITY: return "high_heat_and_humidity";
    case FIT_WEATHER_SEVERE_TYPE_HUMIDEX_AND_HEALTH: return "humidex_and_health";
    case FIT_WEATHER_SEVERE_TYPE_HUMIDEX: return "humidex";
    case FIT_WEATHER_SEVERE_TYPE_GALE: return "gale";
    case FIT_WEATHER_SEVERE_TYPE_FREEZING_SPRAY: return "freezing_spray";
    case FIT_WEATHER_SEVERE_TYPE_SPECIAL_MARINE: return "special_marine";
    case FIT_WEATHER_SEVERE_TYPE_SQUALL: return "squall";
    case FIT_WEATHER_SEVERE_TYPE_STRONG_WIND: return "strong_wind";
    case FIT_WEATHER_SEVERE_TYPE_LAKE_WIND: return "lake_wind";
    case FIT_WEATHER_SEVERE_TYPE_MARINE_WEATHER: return "marine_weather";
    case FIT_WEATHER_SEVERE_TYPE_WIND: return "wind";
    case FIT_WEATHER_SEVERE_TYPE_SMALL_CRAFT_HAZARDOUS_SEAS: return "small_craft_hazardous_seas";
    case FIT_WEATHER_SEVERE_TYPE_HAZARDOUS_SEAS: return "hazardous_seas";
    case FIT_WEATHER_SEVERE_TYPE_SMALL_CRAFT: return "small_craft";
    case FIT_WEATHER_SEVERE_TYPE_SMALL_CRAFT_WINDS: return "small_craft_winds";
    case FIT_WEATHER_SEVERE_TYPE_SMALL_CRAFT_ROUGH_BAR: return "small_craft_rough_bar";
    case FIT_WEATHER_SEVERE_TYPE_HIGH_WATER_LEVEL: return "high_water_level";
    case FIT_WEATHER_SEVERE_TYPE_ASHFALL: return "ashfall";
    case FIT_WEATHER_SEVERE_TYPE_FREEZING_FOG: return "freezing_fog";
    case FIT_WEATHER_SEVERE_TYPE_DENSE_FOG: return "dense_fog";
    case FIT_WEATHER_SEVERE_TYPE_DENSE_SMOKE: return "dense_smoke";
    case FIT_WEATHER_SEVERE_TYPE_BLOWING_DUST: return "blowing_dust";
    case FIT_WEATHER_SEVERE_TYPE_HARD_FREEZE: return "hard_freeze";
    case FIT_WEATHER_SEVERE_TYPE_FREEZE: return "freeze";
    case FIT_WEATHER_SEVERE_TYPE_FROST: return "frost";
    case FIT_WEATHER_SEVERE_TYPE_FIRE_WEATHER: return "fire_weather";
    case FIT_WEATHER_SEVERE_TYPE_FLOOD: return "flood";
    case FIT_WEATHER_SEVERE_TYPE_RIP_TIDE: return "rip_tide";
    case FIT_WEATHER_SEVERE_TYPE_HIGH_SURF: return "high_surf";
    case FIT_WEATHER_SEVERE_TYPE_SMOG: return "smog";
    case FIT_WEATHER_SEVERE_TYPE_AIR_QUALITY: return "air_quality";
    case FIT_WEATHER_SEVERE_TYPE_BRISK_WIND: return "brisk_wind";
    case FIT_WEATHER_SEVERE_TYPE_AIR_STAGNATION: return "air_stagnation";
    case FIT_WEATHER_SEVERE_TYPE_LOW_WATER: return "low_water";
    case FIT_WEATHER_SEVERE_TYPE_HYDROLOGICAL: return "hydrological";
    case FIT_WEATHER_SEVERE_TYPE_SPECIAL_WEATHER: return "special_weather";
    default: return nil
  }
}

func rzfit_manufacturer_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_MANUFACTURER_GARMIN: return "garmin";
    case FIT_MANUFACTURER_GARMIN_FR405_ANTFS: return "garmin_fr405_antfs";
    case FIT_MANUFACTURER_ZEPHYR: return "zephyr";
    case FIT_MANUFACTURER_DAYTON: return "dayton";
    case FIT_MANUFACTURER_IDT: return "idt";
    case FIT_MANUFACTURER_SRM: return "srm";
    case FIT_MANUFACTURER_QUARQ: return "quarq";
    case FIT_MANUFACTURER_IBIKE: return "ibike";
    case FIT_MANUFACTURER_SARIS: return "saris";
    case FIT_MANUFACTURER_SPARK_HK: return "spark_hk";
    case FIT_MANUFACTURER_TANITA: return "tanita";
    case FIT_MANUFACTURER_ECHOWELL: return "echowell";
    case FIT_MANUFACTURER_DYNASTREAM_OEM: return "dynastream_oem";
    case FIT_MANUFACTURER_NAUTILUS: return "nautilus";
    case FIT_MANUFACTURER_DYNASTREAM: return "dynastream";
    case FIT_MANUFACTURER_TIMEX: return "timex";
    case FIT_MANUFACTURER_METRIGEAR: return "metrigear";
    case FIT_MANUFACTURER_XELIC: return "xelic";
    case FIT_MANUFACTURER_BEURER: return "beurer";
    case FIT_MANUFACTURER_CARDIOSPORT: return "cardiosport";
    case FIT_MANUFACTURER_A_AND_D: return "a_and_d";
    case FIT_MANUFACTURER_HMM: return "hmm";
    case FIT_MANUFACTURER_SUUNTO: return "suunto";
    case FIT_MANUFACTURER_THITA_ELEKTRONIK: return "thita_elektronik";
    case FIT_MANUFACTURER_GPULSE: return "gpulse";
    case FIT_MANUFACTURER_CLEAN_MOBILE: return "clean_mobile";
    case FIT_MANUFACTURER_PEDAL_BRAIN: return "pedal_brain";
    case FIT_MANUFACTURER_PEAKSWARE: return "peaksware";
    case FIT_MANUFACTURER_SAXONAR: return "saxonar";
    case FIT_MANUFACTURER_LEMOND_FITNESS: return "lemond_fitness";
    case FIT_MANUFACTURER_DEXCOM: return "dexcom";
    case FIT_MANUFACTURER_WAHOO_FITNESS: return "wahoo_fitness";
    case FIT_MANUFACTURER_OCTANE_FITNESS: return "octane_fitness";
    case FIT_MANUFACTURER_ARCHINOETICS: return "archinoetics";
    case FIT_MANUFACTURER_THE_HURT_BOX: return "the_hurt_box";
    case FIT_MANUFACTURER_CITIZEN_SYSTEMS: return "citizen_systems";
    case FIT_MANUFACTURER_MAGELLAN: return "magellan";
    case FIT_MANUFACTURER_OSYNCE: return "osynce";
    case FIT_MANUFACTURER_HOLUX: return "holux";
    case FIT_MANUFACTURER_CONCEPT2: return "concept2";
    case FIT_MANUFACTURER_ONE_GIANT_LEAP: return "one_giant_leap";
    case FIT_MANUFACTURER_ACE_SENSOR: return "ace_sensor";
    case FIT_MANUFACTURER_BRIM_BROTHERS: return "brim_brothers";
    case FIT_MANUFACTURER_XPLOVA: return "xplova";
    case FIT_MANUFACTURER_PERCEPTION_DIGITAL: return "perception_digital";
    case FIT_MANUFACTURER_BF1SYSTEMS: return "bf1systems";
    case FIT_MANUFACTURER_PIONEER: return "pioneer";
    case FIT_MANUFACTURER_SPANTEC: return "spantec";
    case FIT_MANUFACTURER_METALOGICS: return "metalogics";
    case FIT_MANUFACTURER_4IIIIS: return "4iiiis";
    case FIT_MANUFACTURER_SEIKO_EPSON: return "seiko_epson";
    case FIT_MANUFACTURER_SEIKO_EPSON_OEM: return "seiko_epson_oem";
    case FIT_MANUFACTURER_IFOR_POWELL: return "ifor_powell";
    case FIT_MANUFACTURER_MAXWELL_GUIDER: return "maxwell_guider";
    case FIT_MANUFACTURER_STAR_TRAC: return "star_trac";
    case FIT_MANUFACTURER_BREAKAWAY: return "breakaway";
    case FIT_MANUFACTURER_ALATECH_TECHNOLOGY_LTD: return "alatech_technology_ltd";
    case FIT_MANUFACTURER_MIO_TECHNOLOGY_EUROPE: return "mio_technology_europe";
    case FIT_MANUFACTURER_ROTOR: return "rotor";
    case FIT_MANUFACTURER_GEONAUTE: return "geonaute";
    case FIT_MANUFACTURER_ID_BIKE: return "id_bike";
    case FIT_MANUFACTURER_SPECIALIZED: return "specialized";
    case FIT_MANUFACTURER_WTEK: return "wtek";
    case FIT_MANUFACTURER_PHYSICAL_ENTERPRISES: return "physical_enterprises";
    case FIT_MANUFACTURER_NORTH_POLE_ENGINEERING: return "north_pole_engineering";
    case FIT_MANUFACTURER_BKOOL: return "bkool";
    case FIT_MANUFACTURER_CATEYE: return "cateye";
    case FIT_MANUFACTURER_STAGES_CYCLING: return "stages_cycling";
    case FIT_MANUFACTURER_SIGMASPORT: return "sigmasport";
    case FIT_MANUFACTURER_TOMTOM: return "tomtom";
    case FIT_MANUFACTURER_PERIPEDAL: return "peripedal";
    case FIT_MANUFACTURER_WATTBIKE: return "wattbike";
    case FIT_MANUFACTURER_MOXY: return "moxy";
    case FIT_MANUFACTURER_CICLOSPORT: return "ciclosport";
    case FIT_MANUFACTURER_POWERBAHN: return "powerbahn";
    case FIT_MANUFACTURER_ACORN_PROJECTS_APS: return "acorn_projects_aps";
    case FIT_MANUFACTURER_LIFEBEAM: return "lifebeam";
    case FIT_MANUFACTURER_BONTRAGER: return "bontrager";
    case FIT_MANUFACTURER_WELLGO: return "wellgo";
    case FIT_MANUFACTURER_SCOSCHE: return "scosche";
    case FIT_MANUFACTURER_MAGURA: return "magura";
    case FIT_MANUFACTURER_WOODWAY: return "woodway";
    case FIT_MANUFACTURER_ELITE: return "elite";
    case FIT_MANUFACTURER_NIELSEN_KELLERMAN: return "nielsen_kellerman";
    case FIT_MANUFACTURER_DK_CITY: return "dk_city";
    case FIT_MANUFACTURER_TACX: return "tacx";
    case FIT_MANUFACTURER_DIRECTION_TECHNOLOGY: return "direction_technology";
    case FIT_MANUFACTURER_MAGTONIC: return "magtonic";
    case FIT_MANUFACTURER_1PARTCARBON: return "1partcarbon";
    case FIT_MANUFACTURER_INSIDE_RIDE_TECHNOLOGIES: return "inside_ride_technologies";
    case FIT_MANUFACTURER_SOUND_OF_MOTION: return "sound_of_motion";
    case FIT_MANUFACTURER_STRYD: return "stryd";
    case FIT_MANUFACTURER_ICG: return "icg";
    case FIT_MANUFACTURER_MIPULSE: return "mipulse";
    case FIT_MANUFACTURER_BSX_ATHLETICS: return "bsx_athletics";
    case FIT_MANUFACTURER_LOOK: return "look";
    case FIT_MANUFACTURER_CAMPAGNOLO_SRL: return "campagnolo_srl";
    case FIT_MANUFACTURER_BODY_BIKE_SMART: return "body_bike_smart";
    case FIT_MANUFACTURER_PRAXISWORKS: return "praxisworks";
    case FIT_MANUFACTURER_LIMITS_TECHNOLOGY: return "limits_technology";
    case FIT_MANUFACTURER_TOPACTION_TECHNOLOGY: return "topaction_technology";
    case FIT_MANUFACTURER_COSINUSS: return "cosinuss";
    case FIT_MANUFACTURER_FITCARE: return "fitcare";
    case FIT_MANUFACTURER_MAGENE: return "magene";
    case FIT_MANUFACTURER_GIANT_MANUFACTURING_CO: return "giant_manufacturing_co";
    case FIT_MANUFACTURER_TIGRASPORT: return "tigrasport";
    case FIT_MANUFACTURER_SALUTRON: return "salutron";
    case FIT_MANUFACTURER_TECHNOGYM: return "technogym";
    case FIT_MANUFACTURER_BRYTON_SENSORS: return "bryton_sensors";
    case FIT_MANUFACTURER_LATITUDE_LIMITED: return "latitude_limited";
    case FIT_MANUFACTURER_SOARING_TECHNOLOGY: return "soaring_technology";
    case FIT_MANUFACTURER_IGPSPORT: return "igpsport";
    case FIT_MANUFACTURER_THINKRIDER: return "thinkrider";
    case FIT_MANUFACTURER_GOPHER_SPORT: return "gopher_sport";
    case FIT_MANUFACTURER_WATERROWER: return "waterrower";
    case FIT_MANUFACTURER_ORANGETHEORY: return "orangetheory";
    case FIT_MANUFACTURER_INPEAK: return "inpeak";
    case FIT_MANUFACTURER_KINETIC: return "kinetic";
    case FIT_MANUFACTURER_JOHNSON_HEALTH_TECH: return "johnson_health_tech";
    case FIT_MANUFACTURER_POLAR_ELECTRO: return "polar_electro";
    case FIT_MANUFACTURER_SEESENSE: return "seesense";
    case FIT_MANUFACTURER_NCI_TECHNOLOGY: return "nci_technology";
    case FIT_MANUFACTURER_DEVELOPMENT: return "development";
    case FIT_MANUFACTURER_HEALTHANDLIFE: return "healthandlife";
    case FIT_MANUFACTURER_LEZYNE: return "lezyne";
    case FIT_MANUFACTURER_SCRIBE_LABS: return "scribe_labs";
    case FIT_MANUFACTURER_ZWIFT: return "zwift";
    case FIT_MANUFACTURER_WATTEAM: return "watteam";
    case FIT_MANUFACTURER_RECON: return "recon";
    case FIT_MANUFACTURER_FAVERO_ELECTRONICS: return "favero_electronics";
    case FIT_MANUFACTURER_DYNOVELO: return "dynovelo";
    case FIT_MANUFACTURER_STRAVA: return "strava";
    case FIT_MANUFACTURER_PRECOR: return "precor";
    case FIT_MANUFACTURER_BRYTON: return "bryton";
    case FIT_MANUFACTURER_SRAM: return "sram";
    case FIT_MANUFACTURER_NAVMAN: return "navman";
    case FIT_MANUFACTURER_COBI: return "cobi";
    case FIT_MANUFACTURER_SPIVI: return "spivi";
    case FIT_MANUFACTURER_MIO_MAGELLAN: return "mio_magellan";
    case FIT_MANUFACTURER_EVESPORTS: return "evesports";
    case FIT_MANUFACTURER_SENSITIVUS_GAUGE: return "sensitivus_gauge";
    case FIT_MANUFACTURER_PODOON: return "podoon";
    case FIT_MANUFACTURER_LIFE_TIME_FITNESS: return "life_time_fitness";
    case FIT_MANUFACTURER_FALCO_E_MOTORS: return "falco_e_motors";
    case FIT_MANUFACTURER_MINOURA: return "minoura";
    case FIT_MANUFACTURER_CYCLIQ: return "cycliq";
    case FIT_MANUFACTURER_LUXOTTICA: return "luxottica";
    case FIT_MANUFACTURER_TRAINER_ROAD: return "trainer_road";
    case FIT_MANUFACTURER_THE_SUFFERFEST: return "the_sufferfest";
    case FIT_MANUFACTURER_FULLSPEEDAHEAD: return "fullspeedahead";
    case FIT_MANUFACTURER_VIRTUALTRAINING: return "virtualtraining";
    case FIT_MANUFACTURER_FEEDBACKSPORTS: return "feedbacksports";
    case FIT_MANUFACTURER_OMATA: return "omata";
    case FIT_MANUFACTURER_VDO: return "vdo";
    case FIT_MANUFACTURER_MAGNETICDAYS: return "magneticdays";
    case FIT_MANUFACTURER_HAMMERHEAD: return "hammerhead";
    case FIT_MANUFACTURER_KINETIC_BY_KURT: return "kinetic_by_kurt";
    case FIT_MANUFACTURER_SHAPELOG: return "shapelog";
    case FIT_MANUFACTURER_DABUZIDUO: return "dabuziduo";
    case FIT_MANUFACTURER_JETBLACK: return "jetblack";
    case FIT_MANUFACTURER_COROS: return "coros";
    case FIT_MANUFACTURER_VIRTUGO: return "virtugo";
    case FIT_MANUFACTURER_VELOSENSE: return "velosense";
    case FIT_MANUFACTURER_ACTIGRAPHCORP: return "actigraphcorp";
    default: return nil
  }
}
func rzfit_total_body_exercise_name_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_TOTAL_BODY_EXERCISE_NAME_BURPEE: return "burpee";
    case FIT_TOTAL_BODY_EXERCISE_NAME_WEIGHTED_BURPEE: return "weighted_burpee";
    case FIT_TOTAL_BODY_EXERCISE_NAME_BURPEE_BOX_JUMP: return "burpee_box_jump";
    case FIT_TOTAL_BODY_EXERCISE_NAME_WEIGHTED_BURPEE_BOX_JUMP: return "weighted_burpee_box_jump";
    case FIT_TOTAL_BODY_EXERCISE_NAME_HIGH_PULL_BURPEE: return "high_pull_burpee";
    case FIT_TOTAL_BODY_EXERCISE_NAME_MAN_MAKERS: return "man_makers";
    case FIT_TOTAL_BODY_EXERCISE_NAME_ONE_ARM_BURPEE: return "one_arm_burpee";
    case FIT_TOTAL_BODY_EXERCISE_NAME_SQUAT_THRUSTS: return "squat_thrusts";
    case FIT_TOTAL_BODY_EXERCISE_NAME_WEIGHTED_SQUAT_THRUSTS: return "weighted_squat_thrusts";
    case FIT_TOTAL_BODY_EXERCISE_NAME_SQUAT_PLANK_PUSH_UP: return "squat_plank_push_up";
    case FIT_TOTAL_BODY_EXERCISE_NAME_WEIGHTED_SQUAT_PLANK_PUSH_UP: return "weighted_squat_plank_push_up";
    case FIT_TOTAL_BODY_EXERCISE_NAME_STANDING_T_ROTATION_BALANCE: return "standing_t_rotation_balance";
    case FIT_TOTAL_BODY_EXERCISE_NAME_WEIGHTED_STANDING_T_ROTATION_BALANCE: return "weighted_standing_t_rotation_balance";
    default: return nil
  }
}

func rzfit_leg_raise_exercise_name_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_LEG_RAISE_EXERCISE_NAME_HANGING_KNEE_RAISE: return "hanging_knee_raise";
    case FIT_LEG_RAISE_EXERCISE_NAME_HANGING_LEG_RAISE: return "hanging_leg_raise";
    case FIT_LEG_RAISE_EXERCISE_NAME_WEIGHTED_HANGING_LEG_RAISE: return "weighted_hanging_leg_raise";
    case FIT_LEG_RAISE_EXERCISE_NAME_HANGING_SINGLE_LEG_RAISE: return "hanging_single_leg_raise";
    case FIT_LEG_RAISE_EXERCISE_NAME_WEIGHTED_HANGING_SINGLE_LEG_RAISE: return "weighted_hanging_single_leg_raise";
    case FIT_LEG_RAISE_EXERCISE_NAME_KETTLEBELL_LEG_RAISES: return "kettlebell_leg_raises";
    case FIT_LEG_RAISE_EXERCISE_NAME_LEG_LOWERING_DRILL: return "leg_lowering_drill";
    case FIT_LEG_RAISE_EXERCISE_NAME_WEIGHTED_LEG_LOWERING_DRILL: return "weighted_leg_lowering_drill";
    case FIT_LEG_RAISE_EXERCISE_NAME_LYING_STRAIGHT_LEG_RAISE: return "lying_straight_leg_raise";
    case FIT_LEG_RAISE_EXERCISE_NAME_WEIGHTED_LYING_STRAIGHT_LEG_RAISE: return "weighted_lying_straight_leg_raise";
    case FIT_LEG_RAISE_EXERCISE_NAME_MEDICINE_BALL_LEG_DROPS: return "medicine_ball_leg_drops";
    case FIT_LEG_RAISE_EXERCISE_NAME_QUADRUPED_LEG_RAISE: return "quadruped_leg_raise";
    case FIT_LEG_RAISE_EXERCISE_NAME_WEIGHTED_QUADRUPED_LEG_RAISE: return "weighted_quadruped_leg_raise";
    case FIT_LEG_RAISE_EXERCISE_NAME_REVERSE_LEG_RAISE: return "reverse_leg_raise";
    case FIT_LEG_RAISE_EXERCISE_NAME_WEIGHTED_REVERSE_LEG_RAISE: return "weighted_reverse_leg_raise";
    case FIT_LEG_RAISE_EXERCISE_NAME_REVERSE_LEG_RAISE_ON_SWISS_BALL: return "reverse_leg_raise_on_swiss_ball";
    case FIT_LEG_RAISE_EXERCISE_NAME_WEIGHTED_REVERSE_LEG_RAISE_ON_SWISS_BALL: return "weighted_reverse_leg_raise_on_swiss_ball";
    case FIT_LEG_RAISE_EXERCISE_NAME_SINGLE_LEG_LOWERING_DRILL: return "single_leg_lowering_drill";
    case FIT_LEG_RAISE_EXERCISE_NAME_WEIGHTED_SINGLE_LEG_LOWERING_DRILL: return "weighted_single_leg_lowering_drill";
    case FIT_LEG_RAISE_EXERCISE_NAME_WEIGHTED_HANGING_KNEE_RAISE: return "weighted_hanging_knee_raise";
    case FIT_LEG_RAISE_EXERCISE_NAME_LATERAL_STEPOVER: return "lateral_stepover";
    case FIT_LEG_RAISE_EXERCISE_NAME_WEIGHTED_LATERAL_STEPOVER: return "weighted_lateral_stepover";
    default: return nil
  }
}
func rzfit_display_orientation_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_DISPLAY_ORIENTATION_AUTO: return "auto";
    case FIT_DISPLAY_ORIENTATION_PORTRAIT: return "portrait";
    case FIT_DISPLAY_ORIENTATION_LANDSCAPE: return "landscape";
    case FIT_DISPLAY_ORIENTATION_PORTRAIT_FLIPPED: return "portrait_flipped";
    case FIT_DISPLAY_ORIENTATION_LANDSCAPE_FLIPPED: return "landscape_flipped";
    default: return nil
  }
}
func rzfit_sit_up_exercise_name_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_SIT_UP_EXERCISE_NAME_ALTERNATING_SIT_UP: return "alternating_sit_up";
    case FIT_SIT_UP_EXERCISE_NAME_WEIGHTED_ALTERNATING_SIT_UP: return "weighted_alternating_sit_up";
    case FIT_SIT_UP_EXERCISE_NAME_BENT_KNEE_V_UP: return "bent_knee_v_up";
    case FIT_SIT_UP_EXERCISE_NAME_WEIGHTED_BENT_KNEE_V_UP: return "weighted_bent_knee_v_up";
    case FIT_SIT_UP_EXERCISE_NAME_BUTTERFLY_SIT_UP: return "butterfly_sit_up";
    case FIT_SIT_UP_EXERCISE_NAME_WEIGHTED_BUTTERFLY_SITUP: return "weighted_butterfly_situp";
    case FIT_SIT_UP_EXERCISE_NAME_CROSS_PUNCH_ROLL_UP: return "cross_punch_roll_up";
    case FIT_SIT_UP_EXERCISE_NAME_WEIGHTED_CROSS_PUNCH_ROLL_UP: return "weighted_cross_punch_roll_up";
    case FIT_SIT_UP_EXERCISE_NAME_CROSSED_ARMS_SIT_UP: return "crossed_arms_sit_up";
    case FIT_SIT_UP_EXERCISE_NAME_WEIGHTED_CROSSED_ARMS_SIT_UP: return "weighted_crossed_arms_sit_up";
    case FIT_SIT_UP_EXERCISE_NAME_GET_UP_SIT_UP: return "get_up_sit_up";
    case FIT_SIT_UP_EXERCISE_NAME_WEIGHTED_GET_UP_SIT_UP: return "weighted_get_up_sit_up";
    case FIT_SIT_UP_EXERCISE_NAME_HOVERING_SIT_UP: return "hovering_sit_up";
    case FIT_SIT_UP_EXERCISE_NAME_WEIGHTED_HOVERING_SIT_UP: return "weighted_hovering_sit_up";
    case FIT_SIT_UP_EXERCISE_NAME_KETTLEBELL_SIT_UP: return "kettlebell_sit_up";
    case FIT_SIT_UP_EXERCISE_NAME_MEDICINE_BALL_ALTERNATING_V_UP: return "medicine_ball_alternating_v_up";
    case FIT_SIT_UP_EXERCISE_NAME_MEDICINE_BALL_SIT_UP: return "medicine_ball_sit_up";
    case FIT_SIT_UP_EXERCISE_NAME_MEDICINE_BALL_V_UP: return "medicine_ball_v_up";
    case FIT_SIT_UP_EXERCISE_NAME_MODIFIED_SIT_UP: return "modified_sit_up";
    case FIT_SIT_UP_EXERCISE_NAME_NEGATIVE_SIT_UP: return "negative_sit_up";
    case FIT_SIT_UP_EXERCISE_NAME_ONE_ARM_FULL_SIT_UP: return "one_arm_full_sit_up";
    case FIT_SIT_UP_EXERCISE_NAME_RECLINING_CIRCLE: return "reclining_circle";
    case FIT_SIT_UP_EXERCISE_NAME_WEIGHTED_RECLINING_CIRCLE: return "weighted_reclining_circle";
    case FIT_SIT_UP_EXERCISE_NAME_REVERSE_CURL_UP: return "reverse_curl_up";
    case FIT_SIT_UP_EXERCISE_NAME_WEIGHTED_REVERSE_CURL_UP: return "weighted_reverse_curl_up";
    case FIT_SIT_UP_EXERCISE_NAME_SINGLE_LEG_SWISS_BALL_JACKKNIFE: return "single_leg_swiss_ball_jackknife";
    case FIT_SIT_UP_EXERCISE_NAME_WEIGHTED_SINGLE_LEG_SWISS_BALL_JACKKNIFE: return "weighted_single_leg_swiss_ball_jackknife";
    case FIT_SIT_UP_EXERCISE_NAME_THE_TEASER: return "the_teaser";
    case FIT_SIT_UP_EXERCISE_NAME_THE_TEASER_WEIGHTED: return "the_teaser_weighted";
    case FIT_SIT_UP_EXERCISE_NAME_THREE_PART_ROLL_DOWN: return "three_part_roll_down";
    case FIT_SIT_UP_EXERCISE_NAME_WEIGHTED_THREE_PART_ROLL_DOWN: return "weighted_three_part_roll_down";
    case FIT_SIT_UP_EXERCISE_NAME_V_UP: return "v_up";
    case FIT_SIT_UP_EXERCISE_NAME_WEIGHTED_V_UP: return "weighted_v_up";
    case FIT_SIT_UP_EXERCISE_NAME_WEIGHTED_RUSSIAN_TWIST_ON_SWISS_BALL: return "weighted_russian_twist_on_swiss_ball";
    case FIT_SIT_UP_EXERCISE_NAME_WEIGHTED_SIT_UP: return "weighted_sit_up";
    case FIT_SIT_UP_EXERCISE_NAME_X_ABS: return "x_abs";
    case FIT_SIT_UP_EXERCISE_NAME_WEIGHTED_X_ABS: return "weighted_x_abs";
    case FIT_SIT_UP_EXERCISE_NAME_SIT_UP: return "sit_up";
    default: return nil
  }
}
func rzfit_sensor_type_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_SENSOR_TYPE_ACCELEROMETER: return "accelerometer";
    case FIT_SENSOR_TYPE_GYROSCOPE: return "gyroscope";
    case FIT_SENSOR_TYPE_COMPASS: return "compass";
    case FIT_SENSOR_TYPE_BAROMETER: return "barometer";
    default: return nil
  }
}
func rzfit_flye_exercise_name_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_FLYE_EXERCISE_NAME_CABLE_CROSSOVER: return "cable_crossover";
    case FIT_FLYE_EXERCISE_NAME_DECLINE_DUMBBELL_FLYE: return "decline_dumbbell_flye";
    case FIT_FLYE_EXERCISE_NAME_DUMBBELL_FLYE: return "dumbbell_flye";
    case FIT_FLYE_EXERCISE_NAME_INCLINE_DUMBBELL_FLYE: return "incline_dumbbell_flye";
    case FIT_FLYE_EXERCISE_NAME_KETTLEBELL_FLYE: return "kettlebell_flye";
    case FIT_FLYE_EXERCISE_NAME_KNEELING_REAR_FLYE: return "kneeling_rear_flye";
    case FIT_FLYE_EXERCISE_NAME_SINGLE_ARM_STANDING_CABLE_REVERSE_FLYE: return "single_arm_standing_cable_reverse_flye";
    case FIT_FLYE_EXERCISE_NAME_SWISS_BALL_DUMBBELL_FLYE: return "swiss_ball_dumbbell_flye";
    case FIT_FLYE_EXERCISE_NAME_ARM_ROTATIONS: return "arm_rotations";
    case FIT_FLYE_EXERCISE_NAME_HUG_A_TREE: return "hug_a_tree";
    default: return nil
  }
}

func rzfit_event_type_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_EVENT_TYPE_START: return "start";
    case FIT_EVENT_TYPE_STOP: return "stop";
    case FIT_EVENT_TYPE_CONSECUTIVE_DEPRECIATED: return "consecutive_depreciated";
    case FIT_EVENT_TYPE_MARKER: return "marker";
    case FIT_EVENT_TYPE_STOP_ALL: return "stop_all";
    case FIT_EVENT_TYPE_BEGIN_DEPRECIATED: return "begin_depreciated";
    case FIT_EVENT_TYPE_END_DEPRECIATED: return "end_depreciated";
    case FIT_EVENT_TYPE_END_ALL_DEPRECIATED: return "end_all_depreciated";
    case FIT_EVENT_TYPE_STOP_DISABLE: return "stop_disable";
    case FIT_EVENT_TYPE_STOP_DISABLE_ALL: return "stop_disable_all";
    default: return nil
  }
}
func rzfit_triceps_extension_exercise_name_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_BENCH_DIP: return "bench_dip";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_WEIGHTED_BENCH_DIP: return "weighted_bench_dip";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_BODY_WEIGHT_DIP: return "body_weight_dip";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_CABLE_KICKBACK: return "cable_kickback";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_CABLE_LYING_TRICEPS_EXTENSION: return "cable_lying_triceps_extension";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_CABLE_OVERHEAD_TRICEPS_EXTENSION: return "cable_overhead_triceps_extension";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_DUMBBELL_KICKBACK: return "dumbbell_kickback";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_DUMBBELL_LYING_TRICEPS_EXTENSION: return "dumbbell_lying_triceps_extension";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_EZ_BAR_OVERHEAD_TRICEPS_EXTENSION: return "ez_bar_overhead_triceps_extension";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_INCLINE_DIP: return "incline_dip";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_WEIGHTED_INCLINE_DIP: return "weighted_incline_dip";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_INCLINE_EZ_BAR_LYING_TRICEPS_EXTENSION: return "incline_ez_bar_lying_triceps_extension";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_LYING_DUMBBELL_PULLOVER_TO_EXTENSION: return "lying_dumbbell_pullover_to_extension";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_LYING_EZ_BAR_TRICEPS_EXTENSION: return "lying_ez_bar_triceps_extension";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_LYING_TRICEPS_EXTENSION_TO_CLOSE_GRIP_BENCH_PRESS: return "lying_triceps_extension_to_close_grip_bench_press";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_OVERHEAD_DUMBBELL_TRICEPS_EXTENSION: return "overhead_dumbbell_triceps_extension";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_RECLINING_TRICEPS_PRESS: return "reclining_triceps_press";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_REVERSE_GRIP_PRESSDOWN: return "reverse_grip_pressdown";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_REVERSE_GRIP_TRICEPS_PRESSDOWN: return "reverse_grip_triceps_pressdown";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_ROPE_PRESSDOWN: return "rope_pressdown";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_SEATED_BARBELL_OVERHEAD_TRICEPS_EXTENSION: return "seated_barbell_overhead_triceps_extension";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_SEATED_DUMBBELL_OVERHEAD_TRICEPS_EXTENSION: return "seated_dumbbell_overhead_triceps_extension";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_SEATED_EZ_BAR_OVERHEAD_TRICEPS_EXTENSION: return "seated_ez_bar_overhead_triceps_extension";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_SEATED_SINGLE_ARM_OVERHEAD_DUMBBELL_EXTENSION: return "seated_single_arm_overhead_dumbbell_extension";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_SINGLE_ARM_DUMBBELL_OVERHEAD_TRICEPS_EXTENSION: return "single_arm_dumbbell_overhead_triceps_extension";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_SINGLE_DUMBBELL_SEATED_OVERHEAD_TRICEPS_EXTENSION: return "single_dumbbell_seated_overhead_triceps_extension";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_SINGLE_LEG_BENCH_DIP_AND_KICK: return "single_leg_bench_dip_and_kick";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_WEIGHTED_SINGLE_LEG_BENCH_DIP_AND_KICK: return "weighted_single_leg_bench_dip_and_kick";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_SINGLE_LEG_DIP: return "single_leg_dip";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_WEIGHTED_SINGLE_LEG_DIP: return "weighted_single_leg_dip";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_STATIC_LYING_TRICEPS_EXTENSION: return "static_lying_triceps_extension";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_SUSPENDED_DIP: return "suspended_dip";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_WEIGHTED_SUSPENDED_DIP: return "weighted_suspended_dip";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_SWISS_BALL_DUMBBELL_LYING_TRICEPS_EXTENSION: return "swiss_ball_dumbbell_lying_triceps_extension";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_SWISS_BALL_EZ_BAR_LYING_TRICEPS_EXTENSION: return "swiss_ball_ez_bar_lying_triceps_extension";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_SWISS_BALL_EZ_BAR_OVERHEAD_TRICEPS_EXTENSION: return "swiss_ball_ez_bar_overhead_triceps_extension";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_TABLETOP_DIP: return "tabletop_dip";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_WEIGHTED_TABLETOP_DIP: return "weighted_tabletop_dip";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_TRICEPS_EXTENSION_ON_FLOOR: return "triceps_extension_on_floor";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_TRICEPS_PRESSDOWN: return "triceps_pressdown";
    case FIT_TRICEPS_EXTENSION_EXERCISE_NAME_WEIGHTED_DIP: return "weighted_dip";
    default: return nil
  }
}

func rzfit_timer_trigger_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_TIMER_TRIGGER_MANUAL: return "manual";
    case FIT_TIMER_TRIGGER_AUTO: return "auto";
    case FIT_TIMER_TRIGGER_FITNESS_EQUIPMENT: return "fitness_equipment";
    default: return nil
  }
}
func rzfit_shrug_exercise_name_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_SHRUG_EXERCISE_NAME_BARBELL_JUMP_SHRUG: return "barbell_jump_shrug";
    case FIT_SHRUG_EXERCISE_NAME_BARBELL_SHRUG: return "barbell_shrug";
    case FIT_SHRUG_EXERCISE_NAME_BARBELL_UPRIGHT_ROW: return "barbell_upright_row";
    case FIT_SHRUG_EXERCISE_NAME_BEHIND_THE_BACK_SMITH_MACHINE_SHRUG: return "behind_the_back_smith_machine_shrug";
    case FIT_SHRUG_EXERCISE_NAME_DUMBBELL_JUMP_SHRUG: return "dumbbell_jump_shrug";
    case FIT_SHRUG_EXERCISE_NAME_DUMBBELL_SHRUG: return "dumbbell_shrug";
    case FIT_SHRUG_EXERCISE_NAME_DUMBBELL_UPRIGHT_ROW: return "dumbbell_upright_row";
    case FIT_SHRUG_EXERCISE_NAME_INCLINE_DUMBBELL_SHRUG: return "incline_dumbbell_shrug";
    case FIT_SHRUG_EXERCISE_NAME_OVERHEAD_BARBELL_SHRUG: return "overhead_barbell_shrug";
    case FIT_SHRUG_EXERCISE_NAME_OVERHEAD_DUMBBELL_SHRUG: return "overhead_dumbbell_shrug";
    case FIT_SHRUG_EXERCISE_NAME_SCAPTION_AND_SHRUG: return "scaption_and_shrug";
    case FIT_SHRUG_EXERCISE_NAME_SCAPULAR_RETRACTION: return "scapular_retraction";
    case FIT_SHRUG_EXERCISE_NAME_SERRATUS_CHAIR_SHRUG: return "serratus_chair_shrug";
    case FIT_SHRUG_EXERCISE_NAME_WEIGHTED_SERRATUS_CHAIR_SHRUG: return "weighted_serratus_chair_shrug";
    case FIT_SHRUG_EXERCISE_NAME_SERRATUS_SHRUG: return "serratus_shrug";
    case FIT_SHRUG_EXERCISE_NAME_WEIGHTED_SERRATUS_SHRUG: return "weighted_serratus_shrug";
    case FIT_SHRUG_EXERCISE_NAME_WIDE_GRIP_JUMP_SHRUG: return "wide_grip_jump_shrug";
    default: return nil
  }
}

func rzfit_squat_exercise_name_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_SQUAT_EXERCISE_NAME_LEG_PRESS: return "leg_press";
    case FIT_SQUAT_EXERCISE_NAME_BACK_SQUAT_WITH_BODY_BAR: return "back_squat_with_body_bar";
    case FIT_SQUAT_EXERCISE_NAME_BACK_SQUATS: return "back_squats";
    case FIT_SQUAT_EXERCISE_NAME_WEIGHTED_BACK_SQUATS: return "weighted_back_squats";
    case FIT_SQUAT_EXERCISE_NAME_BALANCING_SQUAT: return "balancing_squat";
    case FIT_SQUAT_EXERCISE_NAME_WEIGHTED_BALANCING_SQUAT: return "weighted_balancing_squat";
    case FIT_SQUAT_EXERCISE_NAME_BARBELL_BACK_SQUAT: return "barbell_back_squat";
    case FIT_SQUAT_EXERCISE_NAME_BARBELL_BOX_SQUAT: return "barbell_box_squat";
    case FIT_SQUAT_EXERCISE_NAME_BARBELL_FRONT_SQUAT: return "barbell_front_squat";
    case FIT_SQUAT_EXERCISE_NAME_BARBELL_HACK_SQUAT: return "barbell_hack_squat";
    case FIT_SQUAT_EXERCISE_NAME_BARBELL_HANG_SQUAT_SNATCH: return "barbell_hang_squat_snatch";
    case FIT_SQUAT_EXERCISE_NAME_BARBELL_LATERAL_STEP_UP: return "barbell_lateral_step_up";
    case FIT_SQUAT_EXERCISE_NAME_BARBELL_QUARTER_SQUAT: return "barbell_quarter_squat";
    case FIT_SQUAT_EXERCISE_NAME_BARBELL_SIFF_SQUAT: return "barbell_siff_squat";
    case FIT_SQUAT_EXERCISE_NAME_BARBELL_SQUAT_SNATCH: return "barbell_squat_snatch";
    case FIT_SQUAT_EXERCISE_NAME_BARBELL_SQUAT_WITH_HEELS_RAISED: return "barbell_squat_with_heels_raised";
    case FIT_SQUAT_EXERCISE_NAME_BARBELL_STEPOVER: return "barbell_stepover";
    case FIT_SQUAT_EXERCISE_NAME_BARBELL_STEP_UP: return "barbell_step_up";
    case FIT_SQUAT_EXERCISE_NAME_BENCH_SQUAT_WITH_ROTATIONAL_CHOP: return "bench_squat_with_rotational_chop";
    case FIT_SQUAT_EXERCISE_NAME_WEIGHTED_BENCH_SQUAT_WITH_ROTATIONAL_CHOP: return "weighted_bench_squat_with_rotational_chop";
    case FIT_SQUAT_EXERCISE_NAME_BODY_WEIGHT_WALL_SQUAT: return "body_weight_wall_squat";
    case FIT_SQUAT_EXERCISE_NAME_WEIGHTED_WALL_SQUAT: return "weighted_wall_squat";
    case FIT_SQUAT_EXERCISE_NAME_BOX_STEP_SQUAT: return "box_step_squat";
    case FIT_SQUAT_EXERCISE_NAME_WEIGHTED_BOX_STEP_SQUAT: return "weighted_box_step_squat";
    case FIT_SQUAT_EXERCISE_NAME_BRACED_SQUAT: return "braced_squat";
    case FIT_SQUAT_EXERCISE_NAME_CROSSED_ARM_BARBELL_FRONT_SQUAT: return "crossed_arm_barbell_front_squat";
    case FIT_SQUAT_EXERCISE_NAME_CROSSOVER_DUMBBELL_STEP_UP: return "crossover_dumbbell_step_up";
    case FIT_SQUAT_EXERCISE_NAME_DUMBBELL_FRONT_SQUAT: return "dumbbell_front_squat";
    case FIT_SQUAT_EXERCISE_NAME_DUMBBELL_SPLIT_SQUAT: return "dumbbell_split_squat";
    case FIT_SQUAT_EXERCISE_NAME_DUMBBELL_SQUAT: return "dumbbell_squat";
    case FIT_SQUAT_EXERCISE_NAME_DUMBBELL_SQUAT_CLEAN: return "dumbbell_squat_clean";
    case FIT_SQUAT_EXERCISE_NAME_DUMBBELL_STEPOVER: return "dumbbell_stepover";
    case FIT_SQUAT_EXERCISE_NAME_DUMBBELL_STEP_UP: return "dumbbell_step_up";
    case FIT_SQUAT_EXERCISE_NAME_ELEVATED_SINGLE_LEG_SQUAT: return "elevated_single_leg_squat";
    case FIT_SQUAT_EXERCISE_NAME_WEIGHTED_ELEVATED_SINGLE_LEG_SQUAT: return "weighted_elevated_single_leg_squat";
    case FIT_SQUAT_EXERCISE_NAME_FIGURE_FOUR_SQUATS: return "figure_four_squats";
    case FIT_SQUAT_EXERCISE_NAME_WEIGHTED_FIGURE_FOUR_SQUATS: return "weighted_figure_four_squats";
    case FIT_SQUAT_EXERCISE_NAME_GOBLET_SQUAT: return "goblet_squat";
    case FIT_SQUAT_EXERCISE_NAME_KETTLEBELL_SQUAT: return "kettlebell_squat";
    case FIT_SQUAT_EXERCISE_NAME_KETTLEBELL_SWING_OVERHEAD: return "kettlebell_swing_overhead";
    case FIT_SQUAT_EXERCISE_NAME_KETTLEBELL_SWING_WITH_FLIP_TO_SQUAT: return "kettlebell_swing_with_flip_to_squat";
    case FIT_SQUAT_EXERCISE_NAME_LATERAL_DUMBBELL_STEP_UP: return "lateral_dumbbell_step_up";
    case FIT_SQUAT_EXERCISE_NAME_ONE_LEGGED_SQUAT: return "one_legged_squat";
    case FIT_SQUAT_EXERCISE_NAME_OVERHEAD_DUMBBELL_SQUAT: return "overhead_dumbbell_squat";
    case FIT_SQUAT_EXERCISE_NAME_OVERHEAD_SQUAT: return "overhead_squat";
    case FIT_SQUAT_EXERCISE_NAME_PARTIAL_SINGLE_LEG_SQUAT: return "partial_single_leg_squat";
    case FIT_SQUAT_EXERCISE_NAME_WEIGHTED_PARTIAL_SINGLE_LEG_SQUAT: return "weighted_partial_single_leg_squat";
    case FIT_SQUAT_EXERCISE_NAME_PISTOL_SQUAT: return "pistol_squat";
    case FIT_SQUAT_EXERCISE_NAME_WEIGHTED_PISTOL_SQUAT: return "weighted_pistol_squat";
    case FIT_SQUAT_EXERCISE_NAME_PLIE_SLIDES: return "plie_slides";
    case FIT_SQUAT_EXERCISE_NAME_WEIGHTED_PLIE_SLIDES: return "weighted_plie_slides";
    case FIT_SQUAT_EXERCISE_NAME_PLIE_SQUAT: return "plie_squat";
    case FIT_SQUAT_EXERCISE_NAME_WEIGHTED_PLIE_SQUAT: return "weighted_plie_squat";
    case FIT_SQUAT_EXERCISE_NAME_PRISONER_SQUAT: return "prisoner_squat";
    case FIT_SQUAT_EXERCISE_NAME_WEIGHTED_PRISONER_SQUAT: return "weighted_prisoner_squat";
    case FIT_SQUAT_EXERCISE_NAME_SINGLE_LEG_BENCH_GET_UP: return "single_leg_bench_get_up";
    case FIT_SQUAT_EXERCISE_NAME_WEIGHTED_SINGLE_LEG_BENCH_GET_UP: return "weighted_single_leg_bench_get_up";
    case FIT_SQUAT_EXERCISE_NAME_SINGLE_LEG_BENCH_SQUAT: return "single_leg_bench_squat";
    case FIT_SQUAT_EXERCISE_NAME_WEIGHTED_SINGLE_LEG_BENCH_SQUAT: return "weighted_single_leg_bench_squat";
    case FIT_SQUAT_EXERCISE_NAME_SINGLE_LEG_SQUAT_ON_SWISS_BALL: return "single_leg_squat_on_swiss_ball";
    case FIT_SQUAT_EXERCISE_NAME_WEIGHTED_SINGLE_LEG_SQUAT_ON_SWISS_BALL: return "weighted_single_leg_squat_on_swiss_ball";
    case FIT_SQUAT_EXERCISE_NAME_SQUAT: return "squat";
    case FIT_SQUAT_EXERCISE_NAME_WEIGHTED_SQUAT: return "weighted_squat";
    case FIT_SQUAT_EXERCISE_NAME_SQUATS_WITH_BAND: return "squats_with_band";
    case FIT_SQUAT_EXERCISE_NAME_STAGGERED_SQUAT: return "staggered_squat";
    case FIT_SQUAT_EXERCISE_NAME_WEIGHTED_STAGGERED_SQUAT: return "weighted_staggered_squat";
    case FIT_SQUAT_EXERCISE_NAME_STEP_UP: return "step_up";
    case FIT_SQUAT_EXERCISE_NAME_WEIGHTED_STEP_UP: return "weighted_step_up";
    case FIT_SQUAT_EXERCISE_NAME_SUITCASE_SQUATS: return "suitcase_squats";
    case FIT_SQUAT_EXERCISE_NAME_SUMO_SQUAT: return "sumo_squat";
    case FIT_SQUAT_EXERCISE_NAME_SUMO_SQUAT_SLIDE_IN: return "sumo_squat_slide_in";
    case FIT_SQUAT_EXERCISE_NAME_WEIGHTED_SUMO_SQUAT_SLIDE_IN: return "weighted_sumo_squat_slide_in";
    case FIT_SQUAT_EXERCISE_NAME_SUMO_SQUAT_TO_HIGH_PULL: return "sumo_squat_to_high_pull";
    case FIT_SQUAT_EXERCISE_NAME_SUMO_SQUAT_TO_STAND: return "sumo_squat_to_stand";
    case FIT_SQUAT_EXERCISE_NAME_WEIGHTED_SUMO_SQUAT_TO_STAND: return "weighted_sumo_squat_to_stand";
    case FIT_SQUAT_EXERCISE_NAME_SUMO_SQUAT_WITH_ROTATION: return "sumo_squat_with_rotation";
    case FIT_SQUAT_EXERCISE_NAME_WEIGHTED_SUMO_SQUAT_WITH_ROTATION: return "weighted_sumo_squat_with_rotation";
    case FIT_SQUAT_EXERCISE_NAME_SWISS_BALL_BODY_WEIGHT_WALL_SQUAT: return "swiss_ball_body_weight_wall_squat";
    case FIT_SQUAT_EXERCISE_NAME_WEIGHTED_SWISS_BALL_WALL_SQUAT: return "weighted_swiss_ball_wall_squat";
    case FIT_SQUAT_EXERCISE_NAME_THRUSTERS: return "thrusters";
    case FIT_SQUAT_EXERCISE_NAME_UNEVEN_SQUAT: return "uneven_squat";
    case FIT_SQUAT_EXERCISE_NAME_WEIGHTED_UNEVEN_SQUAT: return "weighted_uneven_squat";
    case FIT_SQUAT_EXERCISE_NAME_WAIST_SLIMMING_SQUAT: return "waist_slimming_squat";
    case FIT_SQUAT_EXERCISE_NAME_WALL_BALL: return "wall_ball";
    case FIT_SQUAT_EXERCISE_NAME_WIDE_STANCE_BARBELL_SQUAT: return "wide_stance_barbell_squat";
    case FIT_SQUAT_EXERCISE_NAME_WIDE_STANCE_GOBLET_SQUAT: return "wide_stance_goblet_squat";
    case FIT_SQUAT_EXERCISE_NAME_ZERCHER_SQUAT: return "zercher_squat";
    case FIT_SQUAT_EXERCISE_NAME_KBS_OVERHEAD: return "kbs_overhead";
    case FIT_SQUAT_EXERCISE_NAME_SQUAT_AND_SIDE_KICK: return "squat_and_side_kick";
    case FIT_SQUAT_EXERCISE_NAME_SQUAT_JUMPS_IN_N_OUT: return "squat_jumps_in_n_out";
    case FIT_SQUAT_EXERCISE_NAME_PILATES_PLIE_SQUATS_PARALLEL_TURNED_OUT_FLAT_AND_HEELS: return "pilates_plie_squats_parallel_turned_out_flat_and_heels";
    case FIT_SQUAT_EXERCISE_NAME_RELEVE_STRAIGHT_LEG_AND_KNEE_BENT_WITH_ONE_LEG_VARIATION: return "releve_straight_leg_and_knee_bent_with_one_leg_variation";
    default: return nil
  }
}

func rzfit_mesg_num_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_MESG_NUM_FILE_ID: return "file_id";
    case FIT_MESG_NUM_CAPABILITIES: return "capabilities";
    case FIT_MESG_NUM_DEVICE_SETTINGS: return "device_settings";
    case FIT_MESG_NUM_USER_PROFILE: return "user_profile";
    case FIT_MESG_NUM_HRM_PROFILE: return "hrm_profile";
    case FIT_MESG_NUM_SDM_PROFILE: return "sdm_profile";
    case FIT_MESG_NUM_BIKE_PROFILE: return "bike_profile";
    case FIT_MESG_NUM_ZONES_TARGET: return "zones_target";
    case FIT_MESG_NUM_HR_ZONE: return "hr_zone";
    case FIT_MESG_NUM_POWER_ZONE: return "power_zone";
    case FIT_MESG_NUM_MET_ZONE: return "met_zone";
    case FIT_MESG_NUM_SPORT: return "sport";
    case FIT_MESG_NUM_GOAL: return "goal";
    case FIT_MESG_NUM_SESSION: return "session";
    case FIT_MESG_NUM_LAP: return "lap";
    case FIT_MESG_NUM_RECORD: return "record";
    case FIT_MESG_NUM_EVENT: return "event";
    case FIT_MESG_NUM_DEVICE_INFO: return "device_info";
    case FIT_MESG_NUM_WORKOUT: return "workout";
    case FIT_MESG_NUM_WORKOUT_STEP: return "workout_step";
    case FIT_MESG_NUM_SCHEDULE: return "schedule";
    case FIT_MESG_NUM_WEIGHT_SCALE: return "weight_scale";
    case FIT_MESG_NUM_COURSE: return "course";
    case FIT_MESG_NUM_COURSE_POINT: return "course_point";
    case FIT_MESG_NUM_TOTALS: return "totals";
    case FIT_MESG_NUM_ACTIVITY: return "activity";
    case FIT_MESG_NUM_SOFTWARE: return "software";
    case FIT_MESG_NUM_FILE_CAPABILITIES: return "file_capabilities";
    case FIT_MESG_NUM_MESG_CAPABILITIES: return "mesg_capabilities";
    case FIT_MESG_NUM_FIELD_CAPABILITIES: return "field_capabilities";
    case FIT_MESG_NUM_FILE_CREATOR: return "file_creator";
    case FIT_MESG_NUM_BLOOD_PRESSURE: return "blood_pressure";
    case FIT_MESG_NUM_SPEED_ZONE: return "speed_zone";
    case FIT_MESG_NUM_MONITORING: return "monitoring";
    case FIT_MESG_NUM_TRAINING_FILE: return "training_file";
    case FIT_MESG_NUM_HRV: return "hrv";
    case FIT_MESG_NUM_ANT_RX: return "ant_rx";
    case FIT_MESG_NUM_ANT_TX: return "ant_tx";
    case FIT_MESG_NUM_ANT_CHANNEL_ID: return "ant_channel_id";
    case FIT_MESG_NUM_LENGTH: return "length";
    case FIT_MESG_NUM_MONITORING_INFO: return "monitoring_info";
    case FIT_MESG_NUM_PAD: return "pad";
    case FIT_MESG_NUM_SLAVE_DEVICE: return "slave_device";
    case FIT_MESG_NUM_CONNECTIVITY: return "connectivity";
    case FIT_MESG_NUM_WEATHER_CONDITIONS: return "weather_conditions";
    case FIT_MESG_NUM_WEATHER_ALERT: return "weather_alert";
    case FIT_MESG_NUM_CADENCE_ZONE: return "cadence_zone";
    case FIT_MESG_NUM_HR: return "hr";
    case FIT_MESG_NUM_SEGMENT_LAP: return "segment_lap";
    case FIT_MESG_NUM_MEMO_GLOB: return "memo_glob";
    case FIT_MESG_NUM_SEGMENT_ID: return "segment_id";
    case FIT_MESG_NUM_SEGMENT_LEADERBOARD_ENTRY: return "segment_leaderboard_entry";
    case FIT_MESG_NUM_SEGMENT_POINT: return "segment_point";
    case FIT_MESG_NUM_SEGMENT_FILE: return "segment_file";
    case FIT_MESG_NUM_WORKOUT_SESSION: return "workout_session";
    case FIT_MESG_NUM_WATCHFACE_SETTINGS: return "watchface_settings";
    case FIT_MESG_NUM_GPS_METADATA: return "gps_metadata";
    case FIT_MESG_NUM_CAMERA_EVENT: return "camera_event";
    case FIT_MESG_NUM_TIMESTAMP_CORRELATION: return "timestamp_correlation";
    case FIT_MESG_NUM_GYROSCOPE_DATA: return "gyroscope_data";
    case FIT_MESG_NUM_ACCELEROMETER_DATA: return "accelerometer_data";
    case FIT_MESG_NUM_THREE_D_SENSOR_CALIBRATION: return "three_d_sensor_calibration";
    case FIT_MESG_NUM_VIDEO_FRAME: return "video_frame";
    case FIT_MESG_NUM_OBDII_DATA: return "obdii_data";
    case FIT_MESG_NUM_NMEA_SENTENCE: return "nmea_sentence";
    case FIT_MESG_NUM_AVIATION_ATTITUDE: return "aviation_attitude";
    case FIT_MESG_NUM_VIDEO: return "video";
    case FIT_MESG_NUM_VIDEO_TITLE: return "video_title";
    case FIT_MESG_NUM_VIDEO_DESCRIPTION: return "video_description";
    case FIT_MESG_NUM_VIDEO_CLIP: return "video_clip";
    case FIT_MESG_NUM_OHR_SETTINGS: return "ohr_settings";
    case FIT_MESG_NUM_EXD_SCREEN_CONFIGURATION: return "exd_screen_configuration";
    case FIT_MESG_NUM_EXD_DATA_FIELD_CONFIGURATION: return "exd_data_field_configuration";
    case FIT_MESG_NUM_EXD_DATA_CONCEPT_CONFIGURATION: return "exd_data_concept_configuration";
    case FIT_MESG_NUM_FIELD_DESCRIPTION: return "field_description";
    case FIT_MESG_NUM_DEVELOPER_DATA_ID: return "developer_data_id";
    case FIT_MESG_NUM_MAGNETOMETER_DATA: return "magnetometer_data";
    case FIT_MESG_NUM_BAROMETER_DATA: return "barometer_data";
    case FIT_MESG_NUM_ONE_D_SENSOR_CALIBRATION: return "one_d_sensor_calibration";
    case FIT_MESG_NUM_SET: return "set";
    case FIT_MESG_NUM_STRESS_LEVEL: return "stress_level";
    case FIT_MESG_NUM_DIVE_SETTINGS: return "dive_settings";
    case FIT_MESG_NUM_DIVE_GAS: return "dive_gas";
    case FIT_MESG_NUM_DIVE_ALARM: return "dive_alarm";
    case FIT_MESG_NUM_EXERCISE_TITLE: return "exercise_title";
    case FIT_MESG_NUM_DIVE_SUMMARY: return "dive_summary";
    default: return nil
  }
}
func rzfit_hr_type_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_HR_TYPE_NORMAL: return "normal";
    case FIT_HR_TYPE_IRREGULAR: return "irregular";
    default: return nil
  }
}
func rzfit_stroke_type_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_STROKE_TYPE_NO_EVENT: return "no_event";
    case FIT_STROKE_TYPE_OTHER: return "other";
    case FIT_STROKE_TYPE_SERVE: return "serve";
    case FIT_STROKE_TYPE_FOREHAND: return "forehand";
    case FIT_STROKE_TYPE_BACKHAND: return "backhand";
    case FIT_STROKE_TYPE_SMASH: return "smash";
    default: return nil
  }
}
func rzfit_gender_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_GENDER_FEMALE: return "female";
    case FIT_GENDER_MALE: return "male";
    default: return nil
  }
}
func rzfit_olympic_lift_exercise_name_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_OLYMPIC_LIFT_EXERCISE_NAME_BARBELL_HANG_POWER_CLEAN: return "barbell_hang_power_clean";
    case FIT_OLYMPIC_LIFT_EXERCISE_NAME_BARBELL_HANG_SQUAT_CLEAN: return "barbell_hang_squat_clean";
    case FIT_OLYMPIC_LIFT_EXERCISE_NAME_BARBELL_POWER_CLEAN: return "barbell_power_clean";
    case FIT_OLYMPIC_LIFT_EXERCISE_NAME_BARBELL_POWER_SNATCH: return "barbell_power_snatch";
    case FIT_OLYMPIC_LIFT_EXERCISE_NAME_BARBELL_SQUAT_CLEAN: return "barbell_squat_clean";
    case FIT_OLYMPIC_LIFT_EXERCISE_NAME_CLEAN_AND_JERK: return "clean_and_jerk";
    case FIT_OLYMPIC_LIFT_EXERCISE_NAME_BARBELL_HANG_POWER_SNATCH: return "barbell_hang_power_snatch";
    case FIT_OLYMPIC_LIFT_EXERCISE_NAME_BARBELL_HANG_PULL: return "barbell_hang_pull";
    case FIT_OLYMPIC_LIFT_EXERCISE_NAME_BARBELL_HIGH_PULL: return "barbell_high_pull";
    case FIT_OLYMPIC_LIFT_EXERCISE_NAME_BARBELL_SNATCH: return "barbell_snatch";
    case FIT_OLYMPIC_LIFT_EXERCISE_NAME_BARBELL_SPLIT_JERK: return "barbell_split_jerk";
    case FIT_OLYMPIC_LIFT_EXERCISE_NAME_CLEAN: return "clean";
    case FIT_OLYMPIC_LIFT_EXERCISE_NAME_DUMBBELL_CLEAN: return "dumbbell_clean";
    case FIT_OLYMPIC_LIFT_EXERCISE_NAME_DUMBBELL_HANG_PULL: return "dumbbell_hang_pull";
    case FIT_OLYMPIC_LIFT_EXERCISE_NAME_ONE_HAND_DUMBBELL_SPLIT_SNATCH: return "one_hand_dumbbell_split_snatch";
    case FIT_OLYMPIC_LIFT_EXERCISE_NAME_PUSH_JERK: return "push_jerk";
    case FIT_OLYMPIC_LIFT_EXERCISE_NAME_SINGLE_ARM_DUMBBELL_SNATCH: return "single_arm_dumbbell_snatch";
    case FIT_OLYMPIC_LIFT_EXERCISE_NAME_SINGLE_ARM_HANG_SNATCH: return "single_arm_hang_snatch";
    case FIT_OLYMPIC_LIFT_EXERCISE_NAME_SINGLE_ARM_KETTLEBELL_SNATCH: return "single_arm_kettlebell_snatch";
    case FIT_OLYMPIC_LIFT_EXERCISE_NAME_SPLIT_JERK: return "split_jerk";
    case FIT_OLYMPIC_LIFT_EXERCISE_NAME_SQUAT_CLEAN_AND_JERK: return "squat_clean_and_jerk";
    default: return nil
  }
}
func rzfit_plyo_exercise_name_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_PLYO_EXERCISE_NAME_ALTERNATING_JUMP_LUNGE: return "alternating_jump_lunge";
    case FIT_PLYO_EXERCISE_NAME_WEIGHTED_ALTERNATING_JUMP_LUNGE: return "weighted_alternating_jump_lunge";
    case FIT_PLYO_EXERCISE_NAME_BARBELL_JUMP_SQUAT: return "barbell_jump_squat";
    case FIT_PLYO_EXERCISE_NAME_BODY_WEIGHT_JUMP_SQUAT: return "body_weight_jump_squat";
    case FIT_PLYO_EXERCISE_NAME_WEIGHTED_JUMP_SQUAT: return "weighted_jump_squat";
    case FIT_PLYO_EXERCISE_NAME_CROSS_KNEE_STRIKE: return "cross_knee_strike";
    case FIT_PLYO_EXERCISE_NAME_WEIGHTED_CROSS_KNEE_STRIKE: return "weighted_cross_knee_strike";
    case FIT_PLYO_EXERCISE_NAME_DEPTH_JUMP: return "depth_jump";
    case FIT_PLYO_EXERCISE_NAME_WEIGHTED_DEPTH_JUMP: return "weighted_depth_jump";
    case FIT_PLYO_EXERCISE_NAME_DUMBBELL_JUMP_SQUAT: return "dumbbell_jump_squat";
    case FIT_PLYO_EXERCISE_NAME_DUMBBELL_SPLIT_JUMP: return "dumbbell_split_jump";
    case FIT_PLYO_EXERCISE_NAME_FRONT_KNEE_STRIKE: return "front_knee_strike";
    case FIT_PLYO_EXERCISE_NAME_WEIGHTED_FRONT_KNEE_STRIKE: return "weighted_front_knee_strike";
    case FIT_PLYO_EXERCISE_NAME_HIGH_BOX_JUMP: return "high_box_jump";
    case FIT_PLYO_EXERCISE_NAME_WEIGHTED_HIGH_BOX_JUMP: return "weighted_high_box_jump";
    case FIT_PLYO_EXERCISE_NAME_ISOMETRIC_EXPLOSIVE_BODY_WEIGHT_JUMP_SQUAT: return "isometric_explosive_body_weight_jump_squat";
    case FIT_PLYO_EXERCISE_NAME_WEIGHTED_ISOMETRIC_EXPLOSIVE_JUMP_SQUAT: return "weighted_isometric_explosive_jump_squat";
    case FIT_PLYO_EXERCISE_NAME_LATERAL_LEAP_AND_HOP: return "lateral_leap_and_hop";
    case FIT_PLYO_EXERCISE_NAME_WEIGHTED_LATERAL_LEAP_AND_HOP: return "weighted_lateral_leap_and_hop";
    case FIT_PLYO_EXERCISE_NAME_LATERAL_PLYO_SQUATS: return "lateral_plyo_squats";
    case FIT_PLYO_EXERCISE_NAME_WEIGHTED_LATERAL_PLYO_SQUATS: return "weighted_lateral_plyo_squats";
    case FIT_PLYO_EXERCISE_NAME_LATERAL_SLIDE: return "lateral_slide";
    case FIT_PLYO_EXERCISE_NAME_WEIGHTED_LATERAL_SLIDE: return "weighted_lateral_slide";
    case FIT_PLYO_EXERCISE_NAME_MEDICINE_BALL_OVERHEAD_THROWS: return "medicine_ball_overhead_throws";
    case FIT_PLYO_EXERCISE_NAME_MEDICINE_BALL_SIDE_THROW: return "medicine_ball_side_throw";
    case FIT_PLYO_EXERCISE_NAME_MEDICINE_BALL_SLAM: return "medicine_ball_slam";
    case FIT_PLYO_EXERCISE_NAME_SIDE_TO_SIDE_MEDICINE_BALL_THROWS: return "side_to_side_medicine_ball_throws";
    case FIT_PLYO_EXERCISE_NAME_SIDE_TO_SIDE_SHUFFLE_JUMP: return "side_to_side_shuffle_jump";
    case FIT_PLYO_EXERCISE_NAME_WEIGHTED_SIDE_TO_SIDE_SHUFFLE_JUMP: return "weighted_side_to_side_shuffle_jump";
    case FIT_PLYO_EXERCISE_NAME_SQUAT_JUMP_ONTO_BOX: return "squat_jump_onto_box";
    case FIT_PLYO_EXERCISE_NAME_WEIGHTED_SQUAT_JUMP_ONTO_BOX: return "weighted_squat_jump_onto_box";
    case FIT_PLYO_EXERCISE_NAME_SQUAT_JUMPS_IN_AND_OUT: return "squat_jumps_in_and_out";
    case FIT_PLYO_EXERCISE_NAME_WEIGHTED_SQUAT_JUMPS_IN_AND_OUT: return "weighted_squat_jumps_in_and_out";
    default: return nil
  }
}
func rzfit_garmin_product_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_GARMIN_PRODUCT_HRM1: return "hrm1";
    case FIT_GARMIN_PRODUCT_AXH01: return "axh01";
    case FIT_GARMIN_PRODUCT_AXB01: return "axb01";
    case FIT_GARMIN_PRODUCT_AXB02: return "axb02";
    case FIT_GARMIN_PRODUCT_HRM2SS: return "hrm2ss";
    case FIT_GARMIN_PRODUCT_DSI_ALF02: return "dsi_alf02";
    case FIT_GARMIN_PRODUCT_HRM3SS: return "hrm3ss";
    case FIT_GARMIN_PRODUCT_HRM_RUN_SINGLE_BYTE_PRODUCT_ID: return "hrm_run_single_byte_product_id";
    case FIT_GARMIN_PRODUCT_BSM: return "bsm";
    case FIT_GARMIN_PRODUCT_BCM: return "bcm";
    case FIT_GARMIN_PRODUCT_AXS01: return "axs01";
    case FIT_GARMIN_PRODUCT_HRM_TRI_SINGLE_BYTE_PRODUCT_ID: return "hrm_tri_single_byte_product_id";
    case FIT_GARMIN_PRODUCT_FR225_SINGLE_BYTE_PRODUCT_ID: return "fr225_single_byte_product_id";
    case FIT_GARMIN_PRODUCT_FR301_CHINA: return "fr301_china";
    case FIT_GARMIN_PRODUCT_FR301_JAPAN: return "fr301_japan";
    case FIT_GARMIN_PRODUCT_FR301_KOREA: return "fr301_korea";
    case FIT_GARMIN_PRODUCT_FR301_TAIWAN: return "fr301_taiwan";
    case FIT_GARMIN_PRODUCT_FR405: return "fr405";
    case FIT_GARMIN_PRODUCT_FR50: return "fr50";
    case FIT_GARMIN_PRODUCT_FR405_JAPAN: return "fr405_japan";
    case FIT_GARMIN_PRODUCT_FR60: return "fr60";
    case FIT_GARMIN_PRODUCT_DSI_ALF01: return "dsi_alf01";
    case FIT_GARMIN_PRODUCT_FR310XT: return "fr310xt";
    case FIT_GARMIN_PRODUCT_EDGE500: return "edge500";
    case FIT_GARMIN_PRODUCT_FR110: return "fr110";
    case FIT_GARMIN_PRODUCT_EDGE800: return "edge800";
    case FIT_GARMIN_PRODUCT_EDGE500_TAIWAN: return "edge500_taiwan";
    case FIT_GARMIN_PRODUCT_EDGE500_JAPAN: return "edge500_japan";
    case FIT_GARMIN_PRODUCT_CHIRP: return "chirp";
    case FIT_GARMIN_PRODUCT_FR110_JAPAN: return "fr110_japan";
    case FIT_GARMIN_PRODUCT_EDGE200: return "edge200";
    case FIT_GARMIN_PRODUCT_FR910XT: return "fr910xt";
    case FIT_GARMIN_PRODUCT_EDGE800_TAIWAN: return "edge800_taiwan";
    case FIT_GARMIN_PRODUCT_EDGE800_JAPAN: return "edge800_japan";
    case FIT_GARMIN_PRODUCT_ALF04: return "alf04";
    case FIT_GARMIN_PRODUCT_FR610: return "fr610";
    case FIT_GARMIN_PRODUCT_FR210_JAPAN: return "fr210_japan";
    case FIT_GARMIN_PRODUCT_VECTOR_SS: return "vector_ss";
    case FIT_GARMIN_PRODUCT_VECTOR_CP: return "vector_cp";
    case FIT_GARMIN_PRODUCT_EDGE800_CHINA: return "edge800_china";
    case FIT_GARMIN_PRODUCT_EDGE500_CHINA: return "edge500_china";
    case FIT_GARMIN_PRODUCT_FR610_JAPAN: return "fr610_japan";
    case FIT_GARMIN_PRODUCT_EDGE500_KOREA: return "edge500_korea";
    case FIT_GARMIN_PRODUCT_FR70: return "fr70";
    case FIT_GARMIN_PRODUCT_FR310XT_4T: return "fr310xt_4t";
    case FIT_GARMIN_PRODUCT_AMX: return "amx";
    case FIT_GARMIN_PRODUCT_FR10: return "fr10";
    case FIT_GARMIN_PRODUCT_EDGE800_KOREA: return "edge800_korea";
    case FIT_GARMIN_PRODUCT_SWIM: return "swim";
    case FIT_GARMIN_PRODUCT_FR910XT_CHINA: return "fr910xt_china";
    case FIT_GARMIN_PRODUCT_FENIX: return "fenix";
    case FIT_GARMIN_PRODUCT_EDGE200_TAIWAN: return "edge200_taiwan";
    case FIT_GARMIN_PRODUCT_EDGE510: return "edge510";
    case FIT_GARMIN_PRODUCT_EDGE810: return "edge810";
    case FIT_GARMIN_PRODUCT_TEMPE: return "tempe";
    case FIT_GARMIN_PRODUCT_FR910XT_JAPAN: return "fr910xt_japan";
    case FIT_GARMIN_PRODUCT_FR620: return "fr620";
    case FIT_GARMIN_PRODUCT_FR220: return "fr220";
    case FIT_GARMIN_PRODUCT_FR910XT_KOREA: return "fr910xt_korea";
    case FIT_GARMIN_PRODUCT_FR10_JAPAN: return "fr10_japan";
    case FIT_GARMIN_PRODUCT_EDGE810_JAPAN: return "edge810_japan";
    case FIT_GARMIN_PRODUCT_VIRB_ELITE: return "virb_elite";
    case FIT_GARMIN_PRODUCT_EDGE_TOURING: return "edge_touring";
    case FIT_GARMIN_PRODUCT_EDGE510_JAPAN: return "edge510_japan";
    case FIT_GARMIN_PRODUCT_HRM_TRI: return "hrm_tri";
    case FIT_GARMIN_PRODUCT_HRM_RUN: return "hrm_run";
    case FIT_GARMIN_PRODUCT_FR920XT: return "fr920xt";
    case FIT_GARMIN_PRODUCT_EDGE510_ASIA: return "edge510_asia";
    case FIT_GARMIN_PRODUCT_EDGE810_CHINA: return "edge810_china";
    case FIT_GARMIN_PRODUCT_EDGE810_TAIWAN: return "edge810_taiwan";
    case FIT_GARMIN_PRODUCT_EDGE1000: return "edge1000";
    case FIT_GARMIN_PRODUCT_VIVO_FIT: return "vivo_fit";
    case FIT_GARMIN_PRODUCT_VIRB_REMOTE: return "virb_remote";
    case FIT_GARMIN_PRODUCT_VIVO_KI: return "vivo_ki";
    case FIT_GARMIN_PRODUCT_FR15: return "fr15";
    case FIT_GARMIN_PRODUCT_VIVO_ACTIVE: return "vivo_active";
    case FIT_GARMIN_PRODUCT_EDGE510_KOREA: return "edge510_korea";
    case FIT_GARMIN_PRODUCT_FR620_JAPAN: return "fr620_japan";
    case FIT_GARMIN_PRODUCT_FR620_CHINA: return "fr620_china";
    case FIT_GARMIN_PRODUCT_FR220_JAPAN: return "fr220_japan";
    case FIT_GARMIN_PRODUCT_FR220_CHINA: return "fr220_china";
    case FIT_GARMIN_PRODUCT_APPROACH_S6: return "approach_s6";
    case FIT_GARMIN_PRODUCT_VIVO_SMART: return "vivo_smart";
    case FIT_GARMIN_PRODUCT_FENIX2: return "fenix2";
    case FIT_GARMIN_PRODUCT_EPIX: return "epix";
    case FIT_GARMIN_PRODUCT_FENIX3: return "fenix3";
    case FIT_GARMIN_PRODUCT_EDGE1000_TAIWAN: return "edge1000_taiwan";
    case FIT_GARMIN_PRODUCT_EDGE1000_JAPAN: return "edge1000_japan";
    case FIT_GARMIN_PRODUCT_FR15_JAPAN: return "fr15_japan";
    case FIT_GARMIN_PRODUCT_EDGE520: return "edge520";
    case FIT_GARMIN_PRODUCT_EDGE1000_CHINA: return "edge1000_china";
    case FIT_GARMIN_PRODUCT_FR620_RUSSIA: return "fr620_russia";
    case FIT_GARMIN_PRODUCT_FR220_RUSSIA: return "fr220_russia";
    case FIT_GARMIN_PRODUCT_VECTOR_S: return "vector_s";
    case FIT_GARMIN_PRODUCT_EDGE1000_KOREA: return "edge1000_korea";
    case FIT_GARMIN_PRODUCT_FR920XT_TAIWAN: return "fr920xt_taiwan";
    case FIT_GARMIN_PRODUCT_FR920XT_CHINA: return "fr920xt_china";
    case FIT_GARMIN_PRODUCT_FR920XT_JAPAN: return "fr920xt_japan";
    case FIT_GARMIN_PRODUCT_VIRBX: return "virbx";
    case FIT_GARMIN_PRODUCT_VIVO_SMART_APAC: return "vivo_smart_apac";
    case FIT_GARMIN_PRODUCT_ETREX_TOUCH: return "etrex_touch";
    case FIT_GARMIN_PRODUCT_EDGE25: return "edge25";
    case FIT_GARMIN_PRODUCT_FR25: return "fr25";
    case FIT_GARMIN_PRODUCT_VIVO_FIT2: return "vivo_fit2";
    case FIT_GARMIN_PRODUCT_FR225: return "fr225";
    case FIT_GARMIN_PRODUCT_FR630: return "fr630";
    case FIT_GARMIN_PRODUCT_FR230: return "fr230";
    case FIT_GARMIN_PRODUCT_VIVO_ACTIVE_APAC: return "vivo_active_apac";
    case FIT_GARMIN_PRODUCT_VECTOR_2: return "vector_2";
    case FIT_GARMIN_PRODUCT_VECTOR_2S: return "vector_2s";
    case FIT_GARMIN_PRODUCT_VIRBXE: return "virbxe";
    case FIT_GARMIN_PRODUCT_FR620_TAIWAN: return "fr620_taiwan";
    case FIT_GARMIN_PRODUCT_FR220_TAIWAN: return "fr220_taiwan";
    case FIT_GARMIN_PRODUCT_TRUSWING: return "truswing";
    case FIT_GARMIN_PRODUCT_FENIX3_CHINA: return "fenix3_china";
    case FIT_GARMIN_PRODUCT_FENIX3_TWN: return "fenix3_twn";
    case FIT_GARMIN_PRODUCT_VARIA_HEADLIGHT: return "varia_headlight";
    case FIT_GARMIN_PRODUCT_VARIA_TAILLIGHT_OLD: return "varia_taillight_old";
    case FIT_GARMIN_PRODUCT_EDGE_EXPLORE_1000: return "edge_explore_1000";
    case FIT_GARMIN_PRODUCT_FR225_ASIA: return "fr225_asia";
    case FIT_GARMIN_PRODUCT_VARIA_RADAR_TAILLIGHT: return "varia_radar_taillight";
    case FIT_GARMIN_PRODUCT_VARIA_RADAR_DISPLAY: return "varia_radar_display";
    case FIT_GARMIN_PRODUCT_EDGE20: return "edge20";
    case FIT_GARMIN_PRODUCT_D2_BRAVO: return "d2_bravo";
    case FIT_GARMIN_PRODUCT_APPROACH_S20: return "approach_s20";
    case FIT_GARMIN_PRODUCT_VARIA_REMOTE: return "varia_remote";
    case FIT_GARMIN_PRODUCT_HRM4_RUN: return "hrm4_run";
    case FIT_GARMIN_PRODUCT_VIVO_ACTIVE_HR: return "vivo_active_hr";
    case FIT_GARMIN_PRODUCT_VIVO_SMART_GPS_HR: return "vivo_smart_gps_hr";
    case FIT_GARMIN_PRODUCT_VIVO_SMART_HR: return "vivo_smart_hr";
    case FIT_GARMIN_PRODUCT_VIVO_MOVE: return "vivo_move";
    case FIT_GARMIN_PRODUCT_VARIA_VISION: return "varia_vision";
    case FIT_GARMIN_PRODUCT_VIVO_FIT3: return "vivo_fit3";
    case FIT_GARMIN_PRODUCT_FENIX3_HR: return "fenix3_hr";
    case FIT_GARMIN_PRODUCT_VIRB_ULTRA_30: return "virb_ultra_30";
    case FIT_GARMIN_PRODUCT_INDEX_SMART_SCALE: return "index_smart_scale";
    case FIT_GARMIN_PRODUCT_FR235: return "fr235";
    case FIT_GARMIN_PRODUCT_FENIX3_CHRONOS: return "fenix3_chronos";
    case FIT_GARMIN_PRODUCT_OREGON7XX: return "oregon7xx";
    case FIT_GARMIN_PRODUCT_RINO7XX: return "rino7xx";
    case FIT_GARMIN_PRODUCT_NAUTIX: return "nautix";
    case FIT_GARMIN_PRODUCT_EDGE_820: return "edge_820";
    case FIT_GARMIN_PRODUCT_EDGE_EXPLORE_820: return "edge_explore_820";
    case FIT_GARMIN_PRODUCT_FENIX5S: return "fenix5s";
    case FIT_GARMIN_PRODUCT_D2_BRAVO_TITANIUM: return "d2_bravo_titanium";
    case FIT_GARMIN_PRODUCT_VARIA_UT800: return "varia_ut800";
    case FIT_GARMIN_PRODUCT_RUNNING_DYNAMICS_POD: return "running_dynamics_pod";
    case FIT_GARMIN_PRODUCT_FENIX5X: return "fenix5x";
    case FIT_GARMIN_PRODUCT_VIVO_FIT_JR: return "vivo_fit_jr";
    case FIT_GARMIN_PRODUCT_FR935: return "fr935";
    case FIT_GARMIN_PRODUCT_FENIX5: return "fenix5";
    case FIT_GARMIN_PRODUCT_SDM4: return "sdm4";
    case FIT_GARMIN_PRODUCT_EDGE_REMOTE: return "edge_remote";
    case FIT_GARMIN_PRODUCT_TRAINING_CENTER: return "training_center";
    case FIT_GARMIN_PRODUCT_CONNECTIQ_SIMULATOR: return "connectiq_simulator";
    case FIT_GARMIN_PRODUCT_ANDROID_ANTPLUS_PLUGIN: return "android_antplus_plugin";
    case FIT_GARMIN_PRODUCT_CONNECT: return "connect";
    default: return nil
  }
}
func rzfit_segment_lap_status_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_SEGMENT_LAP_STATUS_END: return "end";
    case FIT_SEGMENT_LAP_STATUS_FAIL: return "fail";
    default: return nil
  }
}
func rzfit_sport_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_SPORT_GENERIC: return "generic";
    case FIT_SPORT_RUNNING: return "running";
    case FIT_SPORT_CYCLING: return "cycling";
    case FIT_SPORT_TRANSITION: return "transition";
    case FIT_SPORT_FITNESS_EQUIPMENT: return "fitness_equipment";
    case FIT_SPORT_SWIMMING: return "swimming";
    case FIT_SPORT_BASKETBALL: return "basketball";
    case FIT_SPORT_SOCCER: return "soccer";
    case FIT_SPORT_TENNIS: return "tennis";
    case FIT_SPORT_AMERICAN_FOOTBALL: return "american_football";
    case FIT_SPORT_TRAINING: return "training";
    case FIT_SPORT_WALKING: return "walking";
    case FIT_SPORT_CROSS_COUNTRY_SKIING: return "cross_country_skiing";
    case FIT_SPORT_ALPINE_SKIING: return "alpine_skiing";
    case FIT_SPORT_SNOWBOARDING: return "snowboarding";
    case FIT_SPORT_ROWING: return "rowing";
    case FIT_SPORT_MOUNTAINEERING: return "mountaineering";
    case FIT_SPORT_HIKING: return "hiking";
    case FIT_SPORT_MULTISPORT: return "multisport";
    case FIT_SPORT_PADDLING: return "paddling";
    case FIT_SPORT_FLYING: return "flying";
    case FIT_SPORT_E_BIKING: return "e_biking";
    case FIT_SPORT_MOTORCYCLING: return "motorcycling";
    case FIT_SPORT_BOATING: return "boating";
    case FIT_SPORT_DRIVING: return "driving";
    case FIT_SPORT_GOLF: return "golf";
    case FIT_SPORT_HANG_GLIDING: return "hang_gliding";
    case FIT_SPORT_HORSEBACK_RIDING: return "horseback_riding";
    case FIT_SPORT_HUNTING: return "hunting";
    case FIT_SPORT_FISHING: return "fishing";
    case FIT_SPORT_INLINE_SKATING: return "inline_skating";
    case FIT_SPORT_ROCK_CLIMBING: return "rock_climbing";
    case FIT_SPORT_SAILING: return "sailing";
    case FIT_SPORT_ICE_SKATING: return "ice_skating";
    case FIT_SPORT_SKY_DIVING: return "sky_diving";
    case FIT_SPORT_SNOWSHOEING: return "snowshoeing";
    case FIT_SPORT_SNOWMOBILING: return "snowmobiling";
    case FIT_SPORT_STAND_UP_PADDLEBOARDING: return "stand_up_paddleboarding";
    case FIT_SPORT_SURFING: return "surfing";
    case FIT_SPORT_WAKEBOARDING: return "wakeboarding";
    case FIT_SPORT_WATER_SKIING: return "water_skiing";
    case FIT_SPORT_KAYAKING: return "kayaking";
    case FIT_SPORT_RAFTING: return "rafting";
    case FIT_SPORT_WINDSURFING: return "windsurfing";
    case FIT_SPORT_KITESURFING: return "kitesurfing";
    case FIT_SPORT_TACTICAL: return "tactical";
    case FIT_SPORT_JUMPMASTER: return "jumpmaster";
    case FIT_SPORT_BOXING: return "boxing";
    case FIT_SPORT_FLOOR_CLIMBING: return "floor_climbing";
    case FIT_SPORT_ALL: return "all";
    default: return nil
  }
}
func rzfit_pull_up_exercise_name_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_PULL_UP_EXERCISE_NAME_BANDED_PULL_UPS: return "banded_pull_ups";
    case FIT_PULL_UP_EXERCISE_NAME_30_DEGREE_LAT_PULLDOWN: return "30_degree_lat_pulldown";
    case FIT_PULL_UP_EXERCISE_NAME_BAND_ASSISTED_CHIN_UP: return "band_assisted_chin_up";
    case FIT_PULL_UP_EXERCISE_NAME_CLOSE_GRIP_CHIN_UP: return "close_grip_chin_up";
    case FIT_PULL_UP_EXERCISE_NAME_WEIGHTED_CLOSE_GRIP_CHIN_UP: return "weighted_close_grip_chin_up";
    case FIT_PULL_UP_EXERCISE_NAME_CLOSE_GRIP_LAT_PULLDOWN: return "close_grip_lat_pulldown";
    case FIT_PULL_UP_EXERCISE_NAME_CROSSOVER_CHIN_UP: return "crossover_chin_up";
    case FIT_PULL_UP_EXERCISE_NAME_WEIGHTED_CROSSOVER_CHIN_UP: return "weighted_crossover_chin_up";
    case FIT_PULL_UP_EXERCISE_NAME_EZ_BAR_PULLOVER: return "ez_bar_pullover";
    case FIT_PULL_UP_EXERCISE_NAME_HANGING_HURDLE: return "hanging_hurdle";
    case FIT_PULL_UP_EXERCISE_NAME_WEIGHTED_HANGING_HURDLE: return "weighted_hanging_hurdle";
    case FIT_PULL_UP_EXERCISE_NAME_KNEELING_LAT_PULLDOWN: return "kneeling_lat_pulldown";
    case FIT_PULL_UP_EXERCISE_NAME_KNEELING_UNDERHAND_GRIP_LAT_PULLDOWN: return "kneeling_underhand_grip_lat_pulldown";
    case FIT_PULL_UP_EXERCISE_NAME_LAT_PULLDOWN: return "lat_pulldown";
    case FIT_PULL_UP_EXERCISE_NAME_MIXED_GRIP_CHIN_UP: return "mixed_grip_chin_up";
    case FIT_PULL_UP_EXERCISE_NAME_WEIGHTED_MIXED_GRIP_CHIN_UP: return "weighted_mixed_grip_chin_up";
    case FIT_PULL_UP_EXERCISE_NAME_MIXED_GRIP_PULL_UP: return "mixed_grip_pull_up";
    case FIT_PULL_UP_EXERCISE_NAME_WEIGHTED_MIXED_GRIP_PULL_UP: return "weighted_mixed_grip_pull_up";
    case FIT_PULL_UP_EXERCISE_NAME_REVERSE_GRIP_PULLDOWN: return "reverse_grip_pulldown";
    case FIT_PULL_UP_EXERCISE_NAME_STANDING_CABLE_PULLOVER: return "standing_cable_pullover";
    case FIT_PULL_UP_EXERCISE_NAME_STRAIGHT_ARM_PULLDOWN: return "straight_arm_pulldown";
    case FIT_PULL_UP_EXERCISE_NAME_SWISS_BALL_EZ_BAR_PULLOVER: return "swiss_ball_ez_bar_pullover";
    case FIT_PULL_UP_EXERCISE_NAME_TOWEL_PULL_UP: return "towel_pull_up";
    case FIT_PULL_UP_EXERCISE_NAME_WEIGHTED_TOWEL_PULL_UP: return "weighted_towel_pull_up";
    case FIT_PULL_UP_EXERCISE_NAME_WEIGHTED_PULL_UP: return "weighted_pull_up";
    case FIT_PULL_UP_EXERCISE_NAME_WIDE_GRIP_LAT_PULLDOWN: return "wide_grip_lat_pulldown";
    case FIT_PULL_UP_EXERCISE_NAME_WIDE_GRIP_PULL_UP: return "wide_grip_pull_up";
    case FIT_PULL_UP_EXERCISE_NAME_WEIGHTED_WIDE_GRIP_PULL_UP: return "weighted_wide_grip_pull_up";
    case FIT_PULL_UP_EXERCISE_NAME_BURPEE_PULL_UP: return "burpee_pull_up";
    case FIT_PULL_UP_EXERCISE_NAME_WEIGHTED_BURPEE_PULL_UP: return "weighted_burpee_pull_up";
    case FIT_PULL_UP_EXERCISE_NAME_JUMPING_PULL_UPS: return "jumping_pull_ups";
    case FIT_PULL_UP_EXERCISE_NAME_WEIGHTED_JUMPING_PULL_UPS: return "weighted_jumping_pull_ups";
    case FIT_PULL_UP_EXERCISE_NAME_KIPPING_PULL_UP: return "kipping_pull_up";
    case FIT_PULL_UP_EXERCISE_NAME_WEIGHTED_KIPPING_PULL_UP: return "weighted_kipping_pull_up";
    case FIT_PULL_UP_EXERCISE_NAME_L_PULL_UP: return "l_pull_up";
    case FIT_PULL_UP_EXERCISE_NAME_WEIGHTED_L_PULL_UP: return "weighted_l_pull_up";
    case FIT_PULL_UP_EXERCISE_NAME_SUSPENDED_CHIN_UP: return "suspended_chin_up";
    case FIT_PULL_UP_EXERCISE_NAME_WEIGHTED_SUSPENDED_CHIN_UP: return "weighted_suspended_chin_up";
    case FIT_PULL_UP_EXERCISE_NAME_PULL_UP: return "pull_up";
    default: return nil
  }
}
func rzfit_attitude_stage_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_ATTITUDE_STAGE_FAILED: return "failed";
    case FIT_ATTITUDE_STAGE_ALIGNING: return "aligning";
    case FIT_ATTITUDE_STAGE_DEGRADED: return "degraded";
    case FIT_ATTITUDE_STAGE_VALID: return "valid";
    default: return nil
  }
}
func rzfit_rider_position_type_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_RIDER_POSITION_TYPE_SEATED: return "seated";
    case FIT_RIDER_POSITION_TYPE_STANDING: return "standing";
    case FIT_RIDER_POSITION_TYPE_TRANSITION_TO_SEATED: return "transition_to_seated";
    case FIT_RIDER_POSITION_TYPE_TRANSITION_TO_STANDING: return "transition_to_standing";
    default: return nil
  }
}
func rzfit_bike_light_network_config_type_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_BIKE_LIGHT_NETWORK_CONFIG_TYPE_AUTO: return "auto";
    case FIT_BIKE_LIGHT_NETWORK_CONFIG_TYPE_INDIVIDUAL: return "individual";
    case FIT_BIKE_LIGHT_NETWORK_CONFIG_TYPE_HIGH_VISIBILITY: return "high_visibility";
    case FIT_BIKE_LIGHT_NETWORK_CONFIG_TYPE_TRAIL: return "trail";
    default: return nil
  }
}
func rzfit_exd_descriptors_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_EXD_DESCRIPTORS_BIKE_LIGHT_BATTERY_STATUS: return "bike_light_battery_status";
    case FIT_EXD_DESCRIPTORS_BEAM_ANGLE_STATUS: return "beam_angle_status";
    case FIT_EXD_DESCRIPTORS_BATERY_LEVEL: return "batery_level";
    case FIT_EXD_DESCRIPTORS_LIGHT_NETWORK_MODE: return "light_network_mode";
    case FIT_EXD_DESCRIPTORS_NUMBER_LIGHTS_CONNECTED: return "number_lights_connected";
    case FIT_EXD_DESCRIPTORS_CADENCE: return "cadence";
    case FIT_EXD_DESCRIPTORS_DISTANCE: return "distance";
    case FIT_EXD_DESCRIPTORS_ESTIMATED_TIME_OF_ARRIVAL: return "estimated_time_of_arrival";
    case FIT_EXD_DESCRIPTORS_HEADING: return "heading";
    case FIT_EXD_DESCRIPTORS_TIME: return "time";
    case FIT_EXD_DESCRIPTORS_BATTERY_LEVEL: return "battery_level";
    case FIT_EXD_DESCRIPTORS_TRAINER_RESISTANCE: return "trainer_resistance";
    case FIT_EXD_DESCRIPTORS_TRAINER_TARGET_POWER: return "trainer_target_power";
    case FIT_EXD_DESCRIPTORS_TIME_SEATED: return "time_seated";
    case FIT_EXD_DESCRIPTORS_TIME_STANDING: return "time_standing";
    case FIT_EXD_DESCRIPTORS_ELEVATION: return "elevation";
    case FIT_EXD_DESCRIPTORS_GRADE: return "grade";
    case FIT_EXD_DESCRIPTORS_ASCENT: return "ascent";
    case FIT_EXD_DESCRIPTORS_DESCENT: return "descent";
    case FIT_EXD_DESCRIPTORS_VERTICAL_SPEED: return "vertical_speed";
    case FIT_EXD_DESCRIPTORS_DI2_BATTERY_LEVEL: return "di2_battery_level";
    case FIT_EXD_DESCRIPTORS_FRONT_GEAR: return "front_gear";
    case FIT_EXD_DESCRIPTORS_REAR_GEAR: return "rear_gear";
    case FIT_EXD_DESCRIPTORS_GEAR_RATIO: return "gear_ratio";
    case FIT_EXD_DESCRIPTORS_HEART_RATE: return "heart_rate";
    case FIT_EXD_DESCRIPTORS_HEART_RATE_ZONE: return "heart_rate_zone";
    case FIT_EXD_DESCRIPTORS_TIME_IN_HEART_RATE_ZONE: return "time_in_heart_rate_zone";
    case FIT_EXD_DESCRIPTORS_HEART_RATE_RESERVE: return "heart_rate_reserve";
    case FIT_EXD_DESCRIPTORS_CALORIES: return "calories";
    case FIT_EXD_DESCRIPTORS_GPS_ACCURACY: return "gps_accuracy";
    case FIT_EXD_DESCRIPTORS_GPS_SIGNAL_STRENGTH: return "gps_signal_strength";
    case FIT_EXD_DESCRIPTORS_TEMPERATURE: return "temperature";
    case FIT_EXD_DESCRIPTORS_TIME_OF_DAY: return "time_of_day";
    case FIT_EXD_DESCRIPTORS_BALANCE: return "balance";
    case FIT_EXD_DESCRIPTORS_PEDAL_SMOOTHNESS: return "pedal_smoothness";
    case FIT_EXD_DESCRIPTORS_POWER: return "power";
    case FIT_EXD_DESCRIPTORS_FUNCTIONAL_THRESHOLD_POWER: return "functional_threshold_power";
    case FIT_EXD_DESCRIPTORS_INTENSITY_FACTOR: return "intensity_factor";
    case FIT_EXD_DESCRIPTORS_WORK: return "work";
    case FIT_EXD_DESCRIPTORS_POWER_RATIO: return "power_ratio";
    case FIT_EXD_DESCRIPTORS_NORMALIZED_POWER: return "normalized_power";
    case FIT_EXD_DESCRIPTORS_TRAINING_STRESS_SCORE: return "training_stress_score";
    case FIT_EXD_DESCRIPTORS_TIME_ON_ZONE: return "time_on_zone";
    case FIT_EXD_DESCRIPTORS_SPEED: return "speed";
    case FIT_EXD_DESCRIPTORS_LAPS: return "laps";
    case FIT_EXD_DESCRIPTORS_REPS: return "reps";
    case FIT_EXD_DESCRIPTORS_WORKOUT_STEP: return "workout_step";
    case FIT_EXD_DESCRIPTORS_COURSE_DISTANCE: return "course_distance";
    case FIT_EXD_DESCRIPTORS_NAVIGATION_DISTANCE: return "navigation_distance";
    case FIT_EXD_DESCRIPTORS_COURSE_ESTIMATED_TIME_OF_ARRIVAL: return "course_estimated_time_of_arrival";
    case FIT_EXD_DESCRIPTORS_NAVIGATION_ESTIMATED_TIME_OF_ARRIVAL: return "navigation_estimated_time_of_arrival";
    case FIT_EXD_DESCRIPTORS_COURSE_TIME: return "course_time";
    case FIT_EXD_DESCRIPTORS_NAVIGATION_TIME: return "navigation_time";
    case FIT_EXD_DESCRIPTORS_COURSE_HEADING: return "course_heading";
    case FIT_EXD_DESCRIPTORS_NAVIGATION_HEADING: return "navigation_heading";
    case FIT_EXD_DESCRIPTORS_POWER_ZONE: return "power_zone";
    case FIT_EXD_DESCRIPTORS_TORQUE_EFFECTIVENESS: return "torque_effectiveness";
    case FIT_EXD_DESCRIPTORS_TIMER_TIME: return "timer_time";
    case FIT_EXD_DESCRIPTORS_POWER_WEIGHT_RATIO: return "power_weight_ratio";
    case FIT_EXD_DESCRIPTORS_LEFT_PLATFORM_CENTER_OFFSET: return "left_platform_center_offset";
    case FIT_EXD_DESCRIPTORS_RIGHT_PLATFORM_CENTER_OFFSET: return "right_platform_center_offset";
    case FIT_EXD_DESCRIPTORS_LEFT_POWER_PHASE_START_ANGLE: return "left_power_phase_start_angle";
    case FIT_EXD_DESCRIPTORS_RIGHT_POWER_PHASE_START_ANGLE: return "right_power_phase_start_angle";
    case FIT_EXD_DESCRIPTORS_LEFT_POWER_PHASE_FINISH_ANGLE: return "left_power_phase_finish_angle";
    case FIT_EXD_DESCRIPTORS_RIGHT_POWER_PHASE_FINISH_ANGLE: return "right_power_phase_finish_angle";
    case FIT_EXD_DESCRIPTORS_GEARS: return "gears";
    case FIT_EXD_DESCRIPTORS_PACE: return "pace";
    case FIT_EXD_DESCRIPTORS_TRAINING_EFFECT: return "training_effect";
    case FIT_EXD_DESCRIPTORS_VERTICAL_OSCILLATION: return "vertical_oscillation";
    case FIT_EXD_DESCRIPTORS_VERTICAL_RATIO: return "vertical_ratio";
    case FIT_EXD_DESCRIPTORS_GROUND_CONTACT_TIME: return "ground_contact_time";
    case FIT_EXD_DESCRIPTORS_LEFT_GROUND_CONTACT_TIME_BALANCE: return "left_ground_contact_time_balance";
    case FIT_EXD_DESCRIPTORS_RIGHT_GROUND_CONTACT_TIME_BALANCE: return "right_ground_contact_time_balance";
    case FIT_EXD_DESCRIPTORS_STRIDE_LENGTH: return "stride_length";
    case FIT_EXD_DESCRIPTORS_RUNNING_CADENCE: return "running_cadence";
    case FIT_EXD_DESCRIPTORS_PERFORMANCE_CONDITION: return "performance_condition";
    case FIT_EXD_DESCRIPTORS_COURSE_TYPE: return "course_type";
    case FIT_EXD_DESCRIPTORS_TIME_IN_POWER_ZONE: return "time_in_power_zone";
    case FIT_EXD_DESCRIPTORS_NAVIGATION_TURN: return "navigation_turn";
    case FIT_EXD_DESCRIPTORS_COURSE_LOCATION: return "course_location";
    case FIT_EXD_DESCRIPTORS_NAVIGATION_LOCATION: return "navigation_location";
    case FIT_EXD_DESCRIPTORS_COMPASS: return "compass";
    case FIT_EXD_DESCRIPTORS_GEAR_COMBO: return "gear_combo";
    case FIT_EXD_DESCRIPTORS_MUSCLE_OXYGEN: return "muscle_oxygen";
    case FIT_EXD_DESCRIPTORS_ICON: return "icon";
    case FIT_EXD_DESCRIPTORS_COMPASS_HEADING: return "compass_heading";
    case FIT_EXD_DESCRIPTORS_GPS_HEADING: return "gps_heading";
    case FIT_EXD_DESCRIPTORS_GPS_ELEVATION: return "gps_elevation";
    case FIT_EXD_DESCRIPTORS_ANAEROBIC_TRAINING_EFFECT: return "anaerobic_training_effect";
    case FIT_EXD_DESCRIPTORS_COURSE: return "course";
    case FIT_EXD_DESCRIPTORS_OFF_COURSE: return "off_course";
    case FIT_EXD_DESCRIPTORS_GLIDE_RATIO: return "glide_ratio";
    case FIT_EXD_DESCRIPTORS_VERTICAL_DISTANCE: return "vertical_distance";
    case FIT_EXD_DESCRIPTORS_VMG: return "vmg";
    case FIT_EXD_DESCRIPTORS_AMBIENT_PRESSURE: return "ambient_pressure";
    case FIT_EXD_DESCRIPTORS_PRESSURE: return "pressure";
    case FIT_EXD_DESCRIPTORS_VAM: return "vam";
    default: return nil
  }
}
func rzfit_bp_status_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_BP_STATUS_NO_ERROR: return "no_error";
    case FIT_BP_STATUS_ERROR_INCOMPLETE_DATA: return "error_incomplete_data";
    case FIT_BP_STATUS_ERROR_NO_MEASUREMENT: return "error_no_measurement";
    case FIT_BP_STATUS_ERROR_DATA_OUT_OF_RANGE: return "error_data_out_of_range";
    case FIT_BP_STATUS_ERROR_IRREGULAR_HEART_RATE: return "error_irregular_heart_rate";
    default: return nil
  }
}
func rzfit_push_up_exercise_name_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_PUSH_UP_EXERCISE_NAME_CHEST_PRESS_WITH_BAND: return "chest_press_with_band";
    case FIT_PUSH_UP_EXERCISE_NAME_ALTERNATING_STAGGERED_PUSH_UP: return "alternating_staggered_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_WEIGHTED_ALTERNATING_STAGGERED_PUSH_UP: return "weighted_alternating_staggered_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_ALTERNATING_HANDS_MEDICINE_BALL_PUSH_UP: return "alternating_hands_medicine_ball_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_WEIGHTED_ALTERNATING_HANDS_MEDICINE_BALL_PUSH_UP: return "weighted_alternating_hands_medicine_ball_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_BOSU_BALL_PUSH_UP: return "bosu_ball_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_WEIGHTED_BOSU_BALL_PUSH_UP: return "weighted_bosu_ball_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_CLAPPING_PUSH_UP: return "clapping_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_WEIGHTED_CLAPPING_PUSH_UP: return "weighted_clapping_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_CLOSE_GRIP_MEDICINE_BALL_PUSH_UP: return "close_grip_medicine_ball_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_WEIGHTED_CLOSE_GRIP_MEDICINE_BALL_PUSH_UP: return "weighted_close_grip_medicine_ball_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_CLOSE_HANDS_PUSH_UP: return "close_hands_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_WEIGHTED_CLOSE_HANDS_PUSH_UP: return "weighted_close_hands_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_DECLINE_PUSH_UP: return "decline_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_WEIGHTED_DECLINE_PUSH_UP: return "weighted_decline_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_DIAMOND_PUSH_UP: return "diamond_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_WEIGHTED_DIAMOND_PUSH_UP: return "weighted_diamond_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_EXPLOSIVE_CROSSOVER_PUSH_UP: return "explosive_crossover_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_WEIGHTED_EXPLOSIVE_CROSSOVER_PUSH_UP: return "weighted_explosive_crossover_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_EXPLOSIVE_PUSH_UP: return "explosive_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_WEIGHTED_EXPLOSIVE_PUSH_UP: return "weighted_explosive_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_FEET_ELEVATED_SIDE_TO_SIDE_PUSH_UP: return "feet_elevated_side_to_side_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_WEIGHTED_FEET_ELEVATED_SIDE_TO_SIDE_PUSH_UP: return "weighted_feet_elevated_side_to_side_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_HAND_RELEASE_PUSH_UP: return "hand_release_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_WEIGHTED_HAND_RELEASE_PUSH_UP: return "weighted_hand_release_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_HANDSTAND_PUSH_UP: return "handstand_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_WEIGHTED_HANDSTAND_PUSH_UP: return "weighted_handstand_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_INCLINE_PUSH_UP: return "incline_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_WEIGHTED_INCLINE_PUSH_UP: return "weighted_incline_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_ISOMETRIC_EXPLOSIVE_PUSH_UP: return "isometric_explosive_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_WEIGHTED_ISOMETRIC_EXPLOSIVE_PUSH_UP: return "weighted_isometric_explosive_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_JUDO_PUSH_UP: return "judo_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_WEIGHTED_JUDO_PUSH_UP: return "weighted_judo_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_KNEELING_PUSH_UP: return "kneeling_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_WEIGHTED_KNEELING_PUSH_UP: return "weighted_kneeling_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_MEDICINE_BALL_CHEST_PASS: return "medicine_ball_chest_pass";
    case FIT_PUSH_UP_EXERCISE_NAME_MEDICINE_BALL_PUSH_UP: return "medicine_ball_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_WEIGHTED_MEDICINE_BALL_PUSH_UP: return "weighted_medicine_ball_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_ONE_ARM_PUSH_UP: return "one_arm_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_WEIGHTED_ONE_ARM_PUSH_UP: return "weighted_one_arm_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_WEIGHTED_PUSH_UP: return "weighted_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_PUSH_UP_AND_ROW: return "push_up_and_row";
    case FIT_PUSH_UP_EXERCISE_NAME_WEIGHTED_PUSH_UP_AND_ROW: return "weighted_push_up_and_row";
    case FIT_PUSH_UP_EXERCISE_NAME_PUSH_UP_PLUS: return "push_up_plus";
    case FIT_PUSH_UP_EXERCISE_NAME_WEIGHTED_PUSH_UP_PLUS: return "weighted_push_up_plus";
    case FIT_PUSH_UP_EXERCISE_NAME_PUSH_UP_WITH_FEET_ON_SWISS_BALL: return "push_up_with_feet_on_swiss_ball";
    case FIT_PUSH_UP_EXERCISE_NAME_WEIGHTED_PUSH_UP_WITH_FEET_ON_SWISS_BALL: return "weighted_push_up_with_feet_on_swiss_ball";
    case FIT_PUSH_UP_EXERCISE_NAME_PUSH_UP_WITH_ONE_HAND_ON_MEDICINE_BALL: return "push_up_with_one_hand_on_medicine_ball";
    case FIT_PUSH_UP_EXERCISE_NAME_WEIGHTED_PUSH_UP_WITH_ONE_HAND_ON_MEDICINE_BALL: return "weighted_push_up_with_one_hand_on_medicine_ball";
    case FIT_PUSH_UP_EXERCISE_NAME_SHOULDER_PUSH_UP: return "shoulder_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_WEIGHTED_SHOULDER_PUSH_UP: return "weighted_shoulder_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_SINGLE_ARM_MEDICINE_BALL_PUSH_UP: return "single_arm_medicine_ball_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_WEIGHTED_SINGLE_ARM_MEDICINE_BALL_PUSH_UP: return "weighted_single_arm_medicine_ball_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_SPIDERMAN_PUSH_UP: return "spiderman_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_WEIGHTED_SPIDERMAN_PUSH_UP: return "weighted_spiderman_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_STACKED_FEET_PUSH_UP: return "stacked_feet_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_WEIGHTED_STACKED_FEET_PUSH_UP: return "weighted_stacked_feet_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_STAGGERED_HANDS_PUSH_UP: return "staggered_hands_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_WEIGHTED_STAGGERED_HANDS_PUSH_UP: return "weighted_staggered_hands_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_SUSPENDED_PUSH_UP: return "suspended_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_WEIGHTED_SUSPENDED_PUSH_UP: return "weighted_suspended_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_SWISS_BALL_PUSH_UP: return "swiss_ball_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_WEIGHTED_SWISS_BALL_PUSH_UP: return "weighted_swiss_ball_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_SWISS_BALL_PUSH_UP_PLUS: return "swiss_ball_push_up_plus";
    case FIT_PUSH_UP_EXERCISE_NAME_WEIGHTED_SWISS_BALL_PUSH_UP_PLUS: return "weighted_swiss_ball_push_up_plus";
    case FIT_PUSH_UP_EXERCISE_NAME_T_PUSH_UP: return "t_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_WEIGHTED_T_PUSH_UP: return "weighted_t_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_TRIPLE_STOP_PUSH_UP: return "triple_stop_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_WEIGHTED_TRIPLE_STOP_PUSH_UP: return "weighted_triple_stop_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_WIDE_HANDS_PUSH_UP: return "wide_hands_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_WEIGHTED_WIDE_HANDS_PUSH_UP: return "weighted_wide_hands_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_PARALLETTE_HANDSTAND_PUSH_UP: return "parallette_handstand_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_WEIGHTED_PARALLETTE_HANDSTAND_PUSH_UP: return "weighted_parallette_handstand_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_RING_HANDSTAND_PUSH_UP: return "ring_handstand_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_WEIGHTED_RING_HANDSTAND_PUSH_UP: return "weighted_ring_handstand_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_RING_PUSH_UP: return "ring_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_WEIGHTED_RING_PUSH_UP: return "weighted_ring_push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_PUSH_UP: return "push_up";
    case FIT_PUSH_UP_EXERCISE_NAME_PILATES_PUSHUP: return "pilates_pushup";
    default: return nil
  }
}
func rzfit_autoscroll_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_AUTOSCROLL_NONE: return "none";
    case FIT_AUTOSCROLL_SLOW: return "slow";
    case FIT_AUTOSCROLL_MEDIUM: return "medium";
    case FIT_AUTOSCROLL_FAST: return "fast";
    default: return nil
  }
}
func rzfit_time_mode_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_TIME_MODE_HOUR12: return "hour12";
    case FIT_TIME_MODE_HOUR24: return "hour24";
    case FIT_TIME_MODE_MILITARY: return "military";
    case FIT_TIME_MODE_HOUR_12_WITH_SECONDS: return "hour_12_with_seconds";
    case FIT_TIME_MODE_HOUR_24_WITH_SECONDS: return "hour_24_with_seconds";
    case FIT_TIME_MODE_UTC: return "utc";
    default: return nil
  }
}
func rzfit_workout_power_string(input : FIT_UINT32) -> String? 
{
  switch  input {
    case FIT_WORKOUT_POWER_WATTS_OFFSET: return "watts_offset";
    default: return nil
  }
}
func rzfit_wkt_step_duration_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_WKT_STEP_DURATION_TIME: return "time";
    case FIT_WKT_STEP_DURATION_DISTANCE: return "distance";
    case FIT_WKT_STEP_DURATION_HR_LESS_THAN: return "hr_less_than";
    case FIT_WKT_STEP_DURATION_HR_GREATER_THAN: return "hr_greater_than";
    case FIT_WKT_STEP_DURATION_CALORIES: return "calories";
    case FIT_WKT_STEP_DURATION_OPEN: return "open";
    case FIT_WKT_STEP_DURATION_REPEAT_UNTIL_STEPS_CMPLT: return "repeat_until_steps_cmplt";
    case FIT_WKT_STEP_DURATION_REPEAT_UNTIL_TIME: return "repeat_until_time";
    case FIT_WKT_STEP_DURATION_REPEAT_UNTIL_DISTANCE: return "repeat_until_distance";
    case FIT_WKT_STEP_DURATION_REPEAT_UNTIL_CALORIES: return "repeat_until_calories";
    case FIT_WKT_STEP_DURATION_REPEAT_UNTIL_HR_LESS_THAN: return "repeat_until_hr_less_than";
    case FIT_WKT_STEP_DURATION_REPEAT_UNTIL_HR_GREATER_THAN: return "repeat_until_hr_greater_than";
    case FIT_WKT_STEP_DURATION_REPEAT_UNTIL_POWER_LESS_THAN: return "repeat_until_power_less_than";
    case FIT_WKT_STEP_DURATION_REPEAT_UNTIL_POWER_GREATER_THAN: return "repeat_until_power_greater_than";
    case FIT_WKT_STEP_DURATION_POWER_LESS_THAN: return "power_less_than";
    case FIT_WKT_STEP_DURATION_POWER_GREATER_THAN: return "power_greater_than";
    case FIT_WKT_STEP_DURATION_TRAINING_PEAKS_TSS: return "training_peaks_tss";
    case FIT_WKT_STEP_DURATION_REPEAT_UNTIL_POWER_LAST_LAP_LESS_THAN: return "repeat_until_power_last_lap_less_than";
    case FIT_WKT_STEP_DURATION_REPEAT_UNTIL_MAX_POWER_LAST_LAP_LESS_THAN: return "repeat_until_max_power_last_lap_less_than";
    case FIT_WKT_STEP_DURATION_POWER_3S_LESS_THAN: return "power_3s_less_than";
    case FIT_WKT_STEP_DURATION_POWER_10S_LESS_THAN: return "power_10s_less_than";
    case FIT_WKT_STEP_DURATION_POWER_30S_LESS_THAN: return "power_30s_less_than";
    case FIT_WKT_STEP_DURATION_POWER_3S_GREATER_THAN: return "power_3s_greater_than";
    case FIT_WKT_STEP_DURATION_POWER_10S_GREATER_THAN: return "power_10s_greater_than";
    case FIT_WKT_STEP_DURATION_POWER_30S_GREATER_THAN: return "power_30s_greater_than";
    case FIT_WKT_STEP_DURATION_POWER_LAP_LESS_THAN: return "power_lap_less_than";
    case FIT_WKT_STEP_DURATION_POWER_LAP_GREATER_THAN: return "power_lap_greater_than";
    case FIT_WKT_STEP_DURATION_REPEAT_UNTIL_TRAINING_PEAKS_TSS: return "repeat_until_training_peaks_tss";
    case FIT_WKT_STEP_DURATION_REPETITION_TIME: return "repetition_time";
    case FIT_WKT_STEP_DURATION_REPS: return "reps";
    default: return nil
  }
}
func rzfit_backlight_mode_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_BACKLIGHT_MODE_OFF: return "off";
    case FIT_BACKLIGHT_MODE_MANUAL: return "manual";
    case FIT_BACKLIGHT_MODE_KEY_AND_MESSAGES: return "key_and_messages";
    case FIT_BACKLIGHT_MODE_AUTO_BRIGHTNESS: return "auto_brightness";
    case FIT_BACKLIGHT_MODE_SMART_NOTIFICATIONS: return "smart_notifications";
    case FIT_BACKLIGHT_MODE_KEY_AND_MESSAGES_NIGHT: return "key_and_messages_night";
    case FIT_BACKLIGHT_MODE_KEY_AND_MESSAGES_AND_SMART_NOTIFICATIONS: return "key_and_messages_and_smart_notifications";
    default: return nil
  }
}
func rzfit_side_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_SIDE_RIGHT: return "right";
    case FIT_SIDE_LEFT: return "left";
    default: return nil
  }
}
func rzfit_deadlift_exercise_name_string(input : FIT_UINT16) -> String? 
{
  switch  input {
    case FIT_DEADLIFT_EXERCISE_NAME_BARBELL_DEADLIFT: return "barbell_deadlift";
    case FIT_DEADLIFT_EXERCISE_NAME_BARBELL_STRAIGHT_LEG_DEADLIFT: return "barbell_straight_leg_deadlift";
    case FIT_DEADLIFT_EXERCISE_NAME_DUMBBELL_DEADLIFT: return "dumbbell_deadlift";
    case FIT_DEADLIFT_EXERCISE_NAME_DUMBBELL_SINGLE_LEG_DEADLIFT_TO_ROW: return "dumbbell_single_leg_deadlift_to_row";
    case FIT_DEADLIFT_EXERCISE_NAME_DUMBBELL_STRAIGHT_LEG_DEADLIFT: return "dumbbell_straight_leg_deadlift";
    case FIT_DEADLIFT_EXERCISE_NAME_KETTLEBELL_FLOOR_TO_SHELF: return "kettlebell_floor_to_shelf";
    case FIT_DEADLIFT_EXERCISE_NAME_ONE_ARM_ONE_LEG_DEADLIFT: return "one_arm_one_leg_deadlift";
    case FIT_DEADLIFT_EXERCISE_NAME_RACK_PULL: return "rack_pull";
    case FIT_DEADLIFT_EXERCISE_NAME_ROTATIONAL_DUMBBELL_STRAIGHT_LEG_DEADLIFT: return "rotational_dumbbell_straight_leg_deadlift";
    case FIT_DEADLIFT_EXERCISE_NAME_SINGLE_ARM_DEADLIFT: return "single_arm_deadlift";
    case FIT_DEADLIFT_EXERCISE_NAME_SINGLE_LEG_BARBELL_DEADLIFT: return "single_leg_barbell_deadlift";
    case FIT_DEADLIFT_EXERCISE_NAME_SINGLE_LEG_BARBELL_STRAIGHT_LEG_DEADLIFT: return "single_leg_barbell_straight_leg_deadlift";
    case FIT_DEADLIFT_EXERCISE_NAME_SINGLE_LEG_DEADLIFT_WITH_BARBELL: return "single_leg_deadlift_with_barbell";
    case FIT_DEADLIFT_EXERCISE_NAME_SINGLE_LEG_RDL_CIRCUIT: return "single_leg_rdl_circuit";
    case FIT_DEADLIFT_EXERCISE_NAME_SINGLE_LEG_ROMANIAN_DEADLIFT_WITH_DUMBBELL: return "single_leg_romanian_deadlift_with_dumbbell";
    case FIT_DEADLIFT_EXERCISE_NAME_SUMO_DEADLIFT: return "sumo_deadlift";
    case FIT_DEADLIFT_EXERCISE_NAME_SUMO_DEADLIFT_HIGH_PULL: return "sumo_deadlift_high_pull";
    case FIT_DEADLIFT_EXERCISE_NAME_TRAP_BAR_DEADLIFT: return "trap_bar_deadlift";
    case FIT_DEADLIFT_EXERCISE_NAME_WIDE_GRIP_BARBELL_DEADLIFT: return "wide_grip_barbell_deadlift";
    default: return nil
  }
}
func rzfit_device_index_string(input : FIT_UINT8) -> String? 
{
  switch  input {
    case FIT_DEVICE_INDEX_CREATOR: return "creator";
    default: return nil
  }
}
func rzfit_file_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_FILE_DEVICE: return "device";
    case FIT_FILE_SETTINGS: return "settings";
    case FIT_FILE_SPORT: return "sport";
    case FIT_FILE_ACTIVITY: return "activity";
    case FIT_FILE_WORKOUT: return "workout";
    case FIT_FILE_COURSE: return "course";
    case FIT_FILE_SCHEDULES: return "schedules";
    case FIT_FILE_WEIGHT: return "weight";
    case FIT_FILE_TOTALS: return "totals";
    case FIT_FILE_GOALS: return "goals";
    case FIT_FILE_BLOOD_PRESSURE: return "blood_pressure";
    case FIT_FILE_MONITORING_A: return "monitoring_a";
    case FIT_FILE_ACTIVITY_SUMMARY: return "activity_summary";
    case FIT_FILE_MONITORING_DAILY: return "monitoring_daily";
    case FIT_FILE_MONITORING_B: return "monitoring_b";
    case FIT_FILE_SEGMENT: return "segment";
    case FIT_FILE_SEGMENT_LIST: return "segment_list";
    case FIT_FILE_EXD_CONFIGURATION: return "exd_configuration";
    default: return nil
  }
}





func rzfit_display_position_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_DISPLAY_POSITION_DEGREE: return "degree";
    case FIT_DISPLAY_POSITION_DEGREE_MINUTE: return "degree_minute";
    case FIT_DISPLAY_POSITION_DEGREE_MINUTE_SECOND: return "degree_minute_second";
    case FIT_DISPLAY_POSITION_AUSTRIAN_GRID: return "austrian_grid";
    case FIT_DISPLAY_POSITION_BRITISH_GRID: return "british_grid";
    case FIT_DISPLAY_POSITION_DUTCH_GRID: return "dutch_grid";
    case FIT_DISPLAY_POSITION_HUNGARIAN_GRID: return "hungarian_grid";
    case FIT_DISPLAY_POSITION_FINNISH_GRID: return "finnish_grid";
    case FIT_DISPLAY_POSITION_GERMAN_GRID: return "german_grid";
    case FIT_DISPLAY_POSITION_ICELANDIC_GRID: return "icelandic_grid";
    case FIT_DISPLAY_POSITION_INDONESIAN_EQUATORIAL: return "indonesian_equatorial";
    case FIT_DISPLAY_POSITION_INDONESIAN_IRIAN: return "indonesian_irian";
    case FIT_DISPLAY_POSITION_INDONESIAN_SOUTHERN: return "indonesian_southern";
    case FIT_DISPLAY_POSITION_INDIA_ZONE_0: return "india_zone_0";
    case FIT_DISPLAY_POSITION_INDIA_ZONE_IA: return "india_zone_ia";
    case FIT_DISPLAY_POSITION_INDIA_ZONE_IB: return "india_zone_ib";
    case FIT_DISPLAY_POSITION_INDIA_ZONE_IIA: return "india_zone_iia";
    case FIT_DISPLAY_POSITION_INDIA_ZONE_IIB: return "india_zone_iib";
    case FIT_DISPLAY_POSITION_INDIA_ZONE_IIIA: return "india_zone_iiia";
    case FIT_DISPLAY_POSITION_INDIA_ZONE_IIIB: return "india_zone_iiib";
    case FIT_DISPLAY_POSITION_INDIA_ZONE_IVA: return "india_zone_iva";
    case FIT_DISPLAY_POSITION_INDIA_ZONE_IVB: return "india_zone_ivb";
    case FIT_DISPLAY_POSITION_IRISH_TRANSVERSE: return "irish_transverse";
    case FIT_DISPLAY_POSITION_IRISH_GRID: return "irish_grid";
    case FIT_DISPLAY_POSITION_LORAN: return "loran";
    case FIT_DISPLAY_POSITION_MAIDENHEAD_GRID: return "maidenhead_grid";
    case FIT_DISPLAY_POSITION_MGRS_GRID: return "mgrs_grid";
    case FIT_DISPLAY_POSITION_NEW_ZEALAND_GRID: return "new_zealand_grid";
    case FIT_DISPLAY_POSITION_NEW_ZEALAND_TRANSVERSE: return "new_zealand_transverse";
    case FIT_DISPLAY_POSITION_QATAR_GRID: return "qatar_grid";
    case FIT_DISPLAY_POSITION_MODIFIED_SWEDISH_GRID: return "modified_swedish_grid";
    case FIT_DISPLAY_POSITION_SWEDISH_GRID: return "swedish_grid";
    case FIT_DISPLAY_POSITION_SOUTH_AFRICAN_GRID: return "south_african_grid";
    case FIT_DISPLAY_POSITION_SWISS_GRID: return "swiss_grid";
    case FIT_DISPLAY_POSITION_TAIWAN_GRID: return "taiwan_grid";
    case FIT_DISPLAY_POSITION_UNITED_STATES_GRID: return "united_states_grid";
    case FIT_DISPLAY_POSITION_UTM_UPS_GRID: return "utm_ups_grid";
    case FIT_DISPLAY_POSITION_WEST_MALAYAN: return "west_malayan";
    case FIT_DISPLAY_POSITION_BORNEO_RSO: return "borneo_rso";
    case FIT_DISPLAY_POSITION_ESTONIAN_GRID: return "estonian_grid";
    case FIT_DISPLAY_POSITION_LATVIAN_GRID: return "latvian_grid";
    case FIT_DISPLAY_POSITION_SWEDISH_REF_99_GRID: return "swedish_ref_99_grid";
    default: return nil
  }
}
func rzfit_session_trigger_string(input : FIT_ENUM) -> String? 
{
  switch  input {
    case FIT_SESSION_TRIGGER_ACTIVITY_END: return "activity_end";
    case FIT_SESSION_TRIGGER_MANUAL: return "manual";
    case FIT_SESSION_TRIGGER_AUTO_MULTI_SPORT: return "auto_multi_sport";
    case FIT_SESSION_TRIGGER_FITNESS_EQUIPMENT: return "fitness_equipment";
    default: return nil
  }
}
func rzfit_checksum_string(input : FIT_UINT8) -> String? 
{
  switch  input {
    case FIT_CHECKSUM_CLEAR: return "clear";
    case FIT_CHECKSUM_OK: return "ok";
    default: return nil
  }
}


func rzfit_video_title_mesg_def_value_dict( ptr : UnsafePointer<FIT_VIDEO_TITLE_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_VIDEO_TITLE_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_video_title_mesg_def_enum_dict( ptr : UnsafePointer<FIT_VIDEO_TITLE_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_VIDEO_TITLE_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_exd_data_concept_configuration_mesg_def_value_dict( ptr : UnsafePointer<FIT_EXD_DATA_CONCEPT_CONFIGURATION_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_EXD_DATA_CONCEPT_CONFIGURATION_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_exd_data_concept_configuration_mesg_def_enum_dict( ptr : UnsafePointer<FIT_EXD_DATA_CONCEPT_CONFIGURATION_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_EXD_DATA_CONCEPT_CONFIGURATION_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_hr_zone_mesg_def_value_dict( ptr : UnsafePointer<FIT_HR_ZONE_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_HR_ZONE_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_hr_zone_mesg_def_enum_dict( ptr : UnsafePointer<FIT_HR_ZONE_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_HR_ZONE_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_goal_mesg_def_value_dict( ptr : UnsafePointer<FIT_GOAL_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_GOAL_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_goal_mesg_def_enum_dict( ptr : UnsafePointer<FIT_GOAL_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_GOAL_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_exd_data_field_configuration_mesg_value_dict( ptr : UnsafePointer<FIT_EXD_DATA_FIELD_CONFIGURATION_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_EXD_DATA_FIELD_CONFIGURATION_MESG = ptr.pointee
  if x.screen_index != FIT_UINT8_INVALID  {
    let val : Double = Double(x.screen_index)
    rv[ "screen_index" ] = val
  }
  if x.concept_field != FIT_BYTE_INVALID  {
    let val : Double = Double(x.concept_field)
    rv[ "concept_field" ] = val
  }
  if x.field_id != FIT_UINT8_INVALID  {
    let val : Double = Double(x.field_id)
    rv[ "field_id" ] = val
  }
  if x.concept_count != FIT_UINT8_INVALID  {
    let val : Double = Double(x.concept_count)
    rv[ "concept_count" ] = val
  }
  if x.title != FIT_STRING_INVALID  {
    let val : Double = Double(x.title)
    rv[ "title" ] = val
  }
  return rv
}
func rzfit_exd_data_field_configuration_mesg_enum_dict( ptr : UnsafePointer<FIT_EXD_DATA_FIELD_CONFIGURATION_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  var x : FIT_EXD_DATA_FIELD_CONFIGURATION_MESG = ptr.pointee
  if( x.display_type != FIT_EXD_DISPLAY_TYPE_INVALID ) {
    rv[ "display_type" ] = rzfit_exd_display_type_string(input: x.display_type)
  }
  rv[ "title" ] = withUnsafeBytes(of: &x.title) { (rawPtr) -> String in
    let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
    return String(cString: ptr)
  }
  return rv
}
func rzfit_mesg_capabilities_mesg_def_value_dict( ptr : UnsafePointer<FIT_MESG_CAPABILITIES_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_MESG_CAPABILITIES_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_mesg_capabilities_mesg_def_enum_dict( ptr : UnsafePointer<FIT_MESG_CAPABILITIES_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_MESG_CAPABILITIES_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_set_mesg_value_dict( ptr : UnsafePointer<FIT_SET_MESG>) -> [String:Double] {
  return [:]
}
func rzfit_set_mesg_enum_dict( ptr : UnsafePointer<FIT_SET_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_SET_MESG = ptr.pointee
  if( x.weight_display_unit != FIT_FIT_BASE_UNIT_INVALID ) {
    rv[ "weight_display_unit" ] = rzfit_fit_base_unit_string(input: x.weight_display_unit)
  }
  return rv
}
func rzfit_file_creator_mesg_def_value_dict( ptr : UnsafePointer<FIT_FILE_CREATOR_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_FILE_CREATOR_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_file_creator_mesg_def_enum_dict( ptr : UnsafePointer<FIT_FILE_CREATOR_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_FILE_CREATOR_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_speed_zone_mesg_def_value_dict( ptr : UnsafePointer<FIT_SPEED_ZONE_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_SPEED_ZONE_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_speed_zone_mesg_def_enum_dict( ptr : UnsafePointer<FIT_SPEED_ZONE_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_SPEED_ZONE_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_cadence_zone_mesg_def_value_dict( ptr : UnsafePointer<FIT_CADENCE_ZONE_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_CADENCE_ZONE_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_cadence_zone_mesg_def_enum_dict( ptr : UnsafePointer<FIT_CADENCE_ZONE_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_CADENCE_ZONE_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_bike_profile_mesg_value_dict( ptr : UnsafePointer<FIT_BIKE_PROFILE_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_BIKE_PROFILE_MESG = ptr.pointee
  if x.odometer != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.odometer))/Double(100)
    rv[ "odometer" ] = val
  }
  if x.message_index != FIT_MESSAGE_INDEX_INVALID  {
    let val : Double = Double(x.message_index)
    rv[ "message_index" ] = val
  }
  if x.bike_spd_ant_id != FIT_UINT16Z_INVALID  {
    let val : Double = Double(x.bike_spd_ant_id)
    rv[ "bike_spd_ant_id" ] = val
  }
  if x.bike_cad_ant_id != FIT_UINT16Z_INVALID  {
    let val : Double = Double(x.bike_cad_ant_id)
    rv[ "bike_cad_ant_id" ] = val
  }
  if x.bike_spdcad_ant_id != FIT_UINT16Z_INVALID  {
    let val : Double = Double(x.bike_spdcad_ant_id)
    rv[ "bike_spdcad_ant_id" ] = val
  }
  if x.bike_power_ant_id != FIT_UINT16Z_INVALID  {
    let val : Double = Double(x.bike_power_ant_id)
    rv[ "bike_power_ant_id" ] = val
  }
  if x.custom_wheelsize != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.custom_wheelsize))/Double(1000)
    rv[ "custom_wheelsize" ] = val
  }
  if x.auto_wheelsize != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.auto_wheelsize))/Double(1000)
    rv[ "auto_wheelsize" ] = val
  }
  if x.bike_weight != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.bike_weight))/Double(10)
    rv[ "bike_weight" ] = val
  }
  if x.power_cal_factor != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.power_cal_factor))/Double(10)
    rv[ "power_cal_factor" ] = val
  }
  if x.auto_wheel_cal != FIT_BOOL_INVALID  {
    let val : Double = Double(x.auto_wheel_cal)
    rv[ "auto_wheel_cal" ] = val
  }
  if x.auto_power_zero != FIT_BOOL_INVALID  {
    let val : Double = Double(x.auto_power_zero)
    rv[ "auto_power_zero" ] = val
  }
  if x.id != FIT_UINT8_INVALID  {
    let val : Double = Double(x.id)
    rv[ "id" ] = val
  }
  if x.spd_enabled != FIT_BOOL_INVALID  {
    let val : Double = Double(x.spd_enabled)
    rv[ "spd_enabled" ] = val
  }
  if x.cad_enabled != FIT_BOOL_INVALID  {
    let val : Double = Double(x.cad_enabled)
    rv[ "cad_enabled" ] = val
  }
  if x.spdcad_enabled != FIT_BOOL_INVALID  {
    let val : Double = Double(x.spdcad_enabled)
    rv[ "spdcad_enabled" ] = val
  }
  if x.power_enabled != FIT_BOOL_INVALID  {
    let val : Double = Double(x.power_enabled)
    rv[ "power_enabled" ] = val
  }
  if x.crank_length != FIT_UINT8_INVALID  {
    let val : Double = Double(x.crank_length)
    rv[ "crank_length" ] = val
  }
  if x.enabled != FIT_BOOL_INVALID  {
    let val : Double = Double(x.enabled)
    rv[ "enabled" ] = val
  }
  if x.bike_spd_ant_id_trans_type != FIT_UINT8Z_INVALID  {
    let val : Double = Double(x.bike_spd_ant_id_trans_type)
    rv[ "bike_spd_ant_id_trans_type" ] = val
  }
  if x.bike_cad_ant_id_trans_type != FIT_UINT8Z_INVALID  {
    let val : Double = Double(x.bike_cad_ant_id_trans_type)
    rv[ "bike_cad_ant_id_trans_type" ] = val
  }
  if x.bike_spdcad_ant_id_trans_type != FIT_UINT8Z_INVALID  {
    let val : Double = Double(x.bike_spdcad_ant_id_trans_type)
    rv[ "bike_spdcad_ant_id_trans_type" ] = val
  }
  if x.bike_power_ant_id_trans_type != FIT_UINT8Z_INVALID  {
    let val : Double = Double(x.bike_power_ant_id_trans_type)
    rv[ "bike_power_ant_id_trans_type" ] = val
  }
  if x.odometer_rollover != FIT_UINT8_INVALID  {
    let val : Double = Double(x.odometer_rollover)
    rv[ "odometer_rollover" ] = val
  }
  if x.front_gear_num != FIT_UINT8Z_INVALID  {
    let val : Double = Double(x.front_gear_num)
    rv[ "front_gear_num" ] = val
  }
  if x.front_gear != FIT_UINT8Z_INVALID  {
    let val : Double = Double(x.front_gear)
    rv[ "front_gear" ] = val
  }
  if x.rear_gear_num != FIT_UINT8Z_INVALID  {
    let val : Double = Double(x.rear_gear_num)
    rv[ "rear_gear_num" ] = val
  }
  if x.rear_gear != FIT_UINT8Z_INVALID  {
    let val : Double = Double(x.rear_gear)
    rv[ "rear_gear" ] = val
  }
  if x.shimano_di2_enabled != FIT_BOOL_INVALID  {
    let val : Double = Double(x.shimano_di2_enabled)
    rv[ "shimano_di2_enabled" ] = val
  }
  return rv
}
func rzfit_bike_profile_mesg_enum_dict( ptr : UnsafePointer<FIT_BIKE_PROFILE_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  var x : FIT_BIKE_PROFILE_MESG = ptr.pointee
  rv[ "name" ] = withUnsafeBytes(of: &x.name) { (rawPtr) -> String in
    let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
    return String(cString: ptr)
  }
  if( x.sport != FIT_SPORT_INVALID ) {
    rv[ "sport" ] = rzfit_sport_string(input: x.sport)
  }
  if( x.sub_sport != FIT_SUB_SPORT_INVALID ) {
    rv[ "sub_sport" ] = rzfit_sub_sport_string(input: x.sub_sport)
  }
  return rv
}
func rzfit_segment_file_mesg_value_dict( ptr : UnsafePointer<FIT_SEGMENT_FILE_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_SEGMENT_FILE_MESG = ptr.pointee
  if x.user_profile_primary_key != FIT_UINT32_INVALID  {
    let val : Double = Double(x.user_profile_primary_key)
    rv[ "user_profile_primary_key" ] = val
  }
  if x.leader_group_primary_key != FIT_UINT32_INVALID  {
    let val : Double = Double(x.leader_group_primary_key)
    rv[ "leader_group_primary_key" ] = val
  }
  if x.leader_activity_id != FIT_UINT32_INVALID  {
    let val : Double = Double(x.leader_activity_id)
    rv[ "leader_activity_id" ] = val
  }
  if x.message_index != FIT_MESSAGE_INDEX_INVALID  {
    let val : Double = Double(x.message_index)
    rv[ "message_index" ] = val
  }
  if x.file_uuid != FIT_STRING_INVALID  {
    let val : Double = Double(x.file_uuid)
    rv[ "file_uuid" ] = val
  }
  if x.enabled != FIT_BOOL_INVALID  {
    let val : Double = Double(x.enabled)
    rv[ "enabled" ] = val
  }
  if x.leader_type != FIT_SEGMENT_LEADERBOARD_TYPE_INVALID  {
    let val : Double = Double(x.leader_type)
    rv[ "leader_type" ] = val
  }
  return rv
}
func rzfit_segment_file_mesg_enum_dict( ptr : UnsafePointer<FIT_SEGMENT_FILE_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  var x : FIT_SEGMENT_FILE_MESG = ptr.pointee
  rv[ "file_uuid" ] = withUnsafeBytes(of: &x.file_uuid) { (rawPtr) -> String in
    let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
    return String(cString: ptr)
  }
  return rv
}
func rzfit_zones_target_mesg_def_value_dict( ptr : UnsafePointer<FIT_ZONES_TARGET_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_ZONES_TARGET_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_zones_target_mesg_def_enum_dict( ptr : UnsafePointer<FIT_ZONES_TARGET_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_ZONES_TARGET_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_training_file_mesg_def_value_dict( ptr : UnsafePointer<FIT_TRAINING_FILE_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_TRAINING_FILE_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_training_file_mesg_def_enum_dict( ptr : UnsafePointer<FIT_TRAINING_FILE_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_TRAINING_FILE_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_weather_conditions_mesg_def_value_dict( ptr : UnsafePointer<FIT_WEATHER_CONDITIONS_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_WEATHER_CONDITIONS_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_weather_conditions_mesg_def_enum_dict( ptr : UnsafePointer<FIT_WEATHER_CONDITIONS_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_WEATHER_CONDITIONS_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_developer_data_id_mesg_value_dict( ptr : UnsafePointer<FIT_DEVELOPER_DATA_ID_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_DEVELOPER_DATA_ID_MESG = ptr.pointee
  if x.application_version != FIT_UINT32_INVALID  {
    let val : Double = Double(x.application_version)
    rv[ "application_version" ] = val
  }
  if x.developer_data_index != FIT_UINT8_INVALID  {
    let val : Double = Double(x.developer_data_index)
    rv[ "developer_data_index" ] = val
  }
  return rv
}
func rzfit_developer_data_id_mesg_enum_dict( ptr : UnsafePointer<FIT_DEVELOPER_DATA_ID_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_DEVELOPER_DATA_ID_MESG = ptr.pointee
  if( x.manufacturer_id != FIT_MANUFACTURER_INVALID ) {
    rv[ "manufacturer_id" ] = rzfit_manufacturer_string(input: x.manufacturer_id)
  }
  return rv
}
func rzfit_file_id_mesg_value_dict( ptr : UnsafePointer<FIT_FILE_ID_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_FILE_ID_MESG = ptr.pointee
  if x.serial_number != FIT_UINT32Z_INVALID  {
    let val : Double = Double(x.serial_number)
    rv[ "serial_number" ] = val
  }
  if x.time_created != FIT_DATE_TIME_INVALID  {
    let val : Double = Double(x.time_created)
    rv[ "time_created" ] = val
  }
  if x.product != FIT_UINT16_INVALID  {
    let val : Double = Double(x.product)
    rv[ "product" ] = val
  }
  if x.number != FIT_UINT16_INVALID  {
    let val : Double = Double(x.number)
    rv[ "number" ] = val
  }
  return rv
}
func rzfit_file_id_mesg_enum_dict( ptr : UnsafePointer<FIT_FILE_ID_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  var x : FIT_FILE_ID_MESG = ptr.pointee
  rv[ "product_name" ] = withUnsafeBytes(of: &x.product_name) { (rawPtr) -> String in
    let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
    return String(cString: ptr)
  }
  if( x.manufacturer != FIT_MANUFACTURER_INVALID ) {
    rv[ "manufacturer" ] = rzfit_manufacturer_string(input: x.manufacturer)
  }
  if( x.type != FIT_FILE_INVALID ) {
    rv[ "type" ] = rzfit_file_string(input: x.type)
  }
  return rv
}
func rzfit_sport_mesg_value_dict( ptr : UnsafePointer<FIT_SPORT_MESG>) -> [String:Double] {
  return [:]
}
func rzfit_sport_mesg_enum_dict( ptr : UnsafePointer<FIT_SPORT_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  var x : FIT_SPORT_MESG = ptr.pointee
  rv[ "name" ] = withUnsafeBytes(of: &x.name) { (rawPtr) -> String in
    let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
    return String(cString: ptr)
  }
  if( x.sport != FIT_SPORT_INVALID ) {
    rv[ "sport" ] = rzfit_sport_string(input: x.sport)
  }
  if( x.sub_sport != FIT_SUB_SPORT_INVALID ) {
    rv[ "sub_sport" ] = rzfit_sub_sport_string(input: x.sub_sport)
  }
  return rv
}
func rzfit_file_capabilities_mesg_def_value_dict( ptr : UnsafePointer<FIT_FILE_CAPABILITIES_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_FILE_CAPABILITIES_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_file_capabilities_mesg_def_enum_dict( ptr : UnsafePointer<FIT_FILE_CAPABILITIES_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_FILE_CAPABILITIES_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_slave_device_mesg_value_dict( ptr : UnsafePointer<FIT_SLAVE_DEVICE_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_SLAVE_DEVICE_MESG = ptr.pointee
  if x.product != FIT_UINT16_INVALID  {
    let val : Double = Double(x.product)
    rv[ "product" ] = val
  }
  return rv
}
func rzfit_slave_device_mesg_enum_dict( ptr : UnsafePointer<FIT_SLAVE_DEVICE_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_SLAVE_DEVICE_MESG = ptr.pointee
  if( x.manufacturer != FIT_MANUFACTURER_INVALID ) {
    rv[ "manufacturer" ] = rzfit_manufacturer_string(input: x.manufacturer)
  }
  return rv
}
func rzfit_schedule_mesg_def_value_dict( ptr : UnsafePointer<FIT_SCHEDULE_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_SCHEDULE_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_schedule_mesg_def_enum_dict( ptr : UnsafePointer<FIT_SCHEDULE_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_SCHEDULE_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_video_title_mesg_value_dict( ptr : UnsafePointer<FIT_VIDEO_TITLE_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_VIDEO_TITLE_MESG = ptr.pointee
  if x.message_index != FIT_MESSAGE_INDEX_INVALID  {
    let val : Double = Double(x.message_index)
    rv[ "message_index" ] = val
  }
  if x.message_count != FIT_UINT16_INVALID  {
    let val : Double = Double(x.message_count)
    rv[ "message_count" ] = val
  }
  return rv
}
func rzfit_video_title_mesg_enum_dict( ptr : UnsafePointer<FIT_VIDEO_TITLE_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  var x : FIT_VIDEO_TITLE_MESG = ptr.pointee
  rv[ "text" ] = withUnsafeBytes(of: &x.text) { (rawPtr) -> String in
    let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
    return String(cString: ptr)
  }
  return rv
}
func rzfit_file_creator_mesg_value_dict( ptr : UnsafePointer<FIT_FILE_CREATOR_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_FILE_CREATOR_MESG = ptr.pointee
  if x.software_version != FIT_UINT16_INVALID  {
    let val : Double = Double(x.software_version)
    rv[ "software_version" ] = val
  }
  if x.hardware_version != FIT_UINT8_INVALID  {
    let val : Double = Double(x.hardware_version)
    rv[ "hardware_version" ] = val
  }
  return rv
}
func rzfit_file_creator_mesg_enum_dict( ptr : UnsafePointer<FIT_FILE_CREATOR_MESG>) -> [String:String] {
  return [:]
}
func rzfit_course_mesg_def_value_dict( ptr : UnsafePointer<FIT_COURSE_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_COURSE_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_course_mesg_def_enum_dict( ptr : UnsafePointer<FIT_COURSE_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_COURSE_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_field_capabilities_mesg_def_value_dict( ptr : UnsafePointer<FIT_FIELD_CAPABILITIES_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_FIELD_CAPABILITIES_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_field_capabilities_mesg_def_enum_dict( ptr : UnsafePointer<FIT_FIELD_CAPABILITIES_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_FIELD_CAPABILITIES_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_length_mesg_value_dict( ptr : UnsafePointer<FIT_LENGTH_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_LENGTH_MESG = ptr.pointee
  if x.timestamp != FIT_DATE_TIME_INVALID  {
    let val : Double = Double(x.timestamp)
    rv[ "timestamp" ] = val
  }
  if x.start_time != FIT_DATE_TIME_INVALID  {
    let val : Double = Double(x.start_time)
    rv[ "start_time" ] = val
  }
  if x.total_elapsed_time != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.total_elapsed_time))/Double(1000)
    rv[ "total_elapsed_time" ] = val
  }
  if x.total_timer_time != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.total_timer_time))/Double(1000)
    rv[ "total_timer_time" ] = val
  }
  if x.message_index != FIT_MESSAGE_INDEX_INVALID  {
    let val : Double = Double(x.message_index)
    rv[ "message_index" ] = val
  }
  if x.total_strokes != FIT_UINT16_INVALID  {
    let val : Double = Double(x.total_strokes)
    rv[ "total_strokes" ] = val
  }
  if x.avg_speed != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.avg_speed))/Double(1000)
    rv[ "avg_speed" ] = val
  }
  if x.total_calories != FIT_UINT16_INVALID  {
    let val : Double = Double(x.total_calories)
    rv[ "total_calories" ] = val
  }
  if x.player_score != FIT_UINT16_INVALID  {
    let val : Double = Double(x.player_score)
    rv[ "player_score" ] = val
  }
  if x.opponent_score != FIT_UINT16_INVALID  {
    let val : Double = Double(x.opponent_score)
    rv[ "opponent_score" ] = val
  }
  if x.stroke_count != FIT_UINT16_INVALID  {
    let val : Double = Double(x.stroke_count)
    rv[ "stroke_count" ] = val
  }
  if x.zone_count != FIT_UINT16_INVALID  {
    let val : Double = Double(x.zone_count)
    rv[ "zone_count" ] = val
  }
  if x.avg_swimming_cadence != FIT_UINT8_INVALID  {
    let val : Double = Double(x.avg_swimming_cadence)
    rv[ "avg_swimming_cadence" ] = val
  }
  if x.event_group != FIT_UINT8_INVALID  {
    let val : Double = Double(x.event_group)
    rv[ "event_group" ] = val
  }
  return rv
}
func rzfit_length_mesg_enum_dict( ptr : UnsafePointer<FIT_LENGTH_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_LENGTH_MESG = ptr.pointee
  if( x.event != FIT_EVENT_INVALID ) {
    rv[ "event" ] = rzfit_event_string(input: x.event)
  }
  if( x.event_type != FIT_EVENT_TYPE_INVALID ) {
    rv[ "event_type" ] = rzfit_event_type_string(input: x.event_type)
  }
  if( x.swim_stroke != FIT_SWIM_STROKE_INVALID ) {
    rv[ "swim_stroke" ] = rzfit_swim_stroke_string(input: x.swim_stroke)
  }
  if( x.length_type != FIT_LENGTH_TYPE_INVALID ) {
    rv[ "length_type" ] = rzfit_length_type_string(input: x.length_type)
  }
  return rv
}
func rzfit_exercise_title_mesg_def_value_dict( ptr : UnsafePointer<FIT_EXERCISE_TITLE_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_EXERCISE_TITLE_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_exercise_title_mesg_def_enum_dict( ptr : UnsafePointer<FIT_EXERCISE_TITLE_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_EXERCISE_TITLE_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_monitoring_mesg_def_value_dict( ptr : UnsafePointer<FIT_MONITORING_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_MONITORING_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_monitoring_mesg_def_enum_dict( ptr : UnsafePointer<FIT_MONITORING_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_MONITORING_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_device_info_mesg_value_dict( ptr : UnsafePointer<FIT_DEVICE_INFO_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_DEVICE_INFO_MESG = ptr.pointee
  if x.timestamp != FIT_DATE_TIME_INVALID  {
    let val : Double = Double(x.timestamp)
    rv[ "timestamp" ] = val
  }
  if x.serial_number != FIT_UINT32Z_INVALID  {
    let val : Double = Double(x.serial_number)
    rv[ "serial_number" ] = val
  }
  if x.cum_operating_time != FIT_UINT32_INVALID  {
    let val : Double = Double(x.cum_operating_time)
    rv[ "cum_operating_time" ] = val
  }
  if x.product != FIT_UINT16_INVALID  {
    let val : Double = Double(x.product)
    rv[ "product" ] = val
  }
  if x.software_version != FIT_UINT16_INVALID  {
    let val : Double = Double(x.software_version)
    rv[ "software_version" ] = val
  }
  if x.battery_voltage != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.battery_voltage))/Double(256)
    rv[ "battery_voltage" ] = val
  }
  if x.ant_device_number != FIT_UINT16Z_INVALID  {
    let val : Double = Double(x.ant_device_number)
    rv[ "ant_device_number" ] = val
  }
  if x.device_type != FIT_UINT8_INVALID  {
    let val : Double = Double(x.device_type)
    rv[ "device_type" ] = val
  }
  if x.hardware_version != FIT_UINT8_INVALID  {
    let val : Double = Double(x.hardware_version)
    rv[ "hardware_version" ] = val
  }
  if x.descriptor != FIT_STRING_INVALID  {
    let val : Double = Double(x.descriptor)
    rv[ "descriptor" ] = val
  }
  if x.ant_transmission_type != FIT_UINT8Z_INVALID  {
    let val : Double = Double(x.ant_transmission_type)
    rv[ "ant_transmission_type" ] = val
  }
  return rv
}
func rzfit_device_info_mesg_enum_dict( ptr : UnsafePointer<FIT_DEVICE_INFO_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  var x : FIT_DEVICE_INFO_MESG = ptr.pointee
  rv[ "product_name" ] = withUnsafeBytes(of: &x.product_name) { (rawPtr) -> String in
    let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
    return String(cString: ptr)
  }
  if( x.manufacturer != FIT_MANUFACTURER_INVALID ) {
    rv[ "manufacturer" ] = rzfit_manufacturer_string(input: x.manufacturer)
  }
  if( x.device_index != FIT_DEVICE_INDEX_INVALID ) {
    rv[ "device_index" ] = rzfit_device_index_string(input: x.device_index)
  }
  if( x.battery_status != FIT_BATTERY_STATUS_INVALID ) {
    rv[ "battery_status" ] = rzfit_battery_status_string(input: x.battery_status)
  }
  if( x.sensor_position != FIT_BODY_LOCATION_INVALID ) {
    rv[ "sensor_position" ] = rzfit_body_location_string(input: x.sensor_position)
  }
  rv[ "descriptor" ] = withUnsafeBytes(of: &x.descriptor) { (rawPtr) -> String in
    let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
    return String(cString: ptr)
  }
  if( x.ant_network != FIT_ANT_NETWORK_INVALID ) {
    rv[ "ant_network" ] = rzfit_ant_network_string(input: x.ant_network)
  }
  if( x.source_type != FIT_SOURCE_TYPE_INVALID ) {
    rv[ "source_type" ] = rzfit_source_type_string(input: x.source_type)
  }
  return rv
}
func rzfit_sport_mesg_def_value_dict( ptr : UnsafePointer<FIT_SPORT_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_SPORT_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_sport_mesg_def_enum_dict( ptr : UnsafePointer<FIT_SPORT_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_SPORT_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_file_id_mesg_def_value_dict( ptr : UnsafePointer<FIT_FILE_ID_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_FILE_ID_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_file_id_mesg_def_enum_dict( ptr : UnsafePointer<FIT_FILE_ID_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_FILE_ID_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_file_capabilities_mesg_value_dict( ptr : UnsafePointer<FIT_FILE_CAPABILITIES_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_FILE_CAPABILITIES_MESG = ptr.pointee
  if x.max_size != FIT_UINT32_INVALID  {
    let val : Double = Double(x.max_size)
    rv[ "max_size" ] = val
  }
  if x.message_index != FIT_MESSAGE_INDEX_INVALID  {
    let val : Double = Double(x.message_index)
    rv[ "message_index" ] = val
  }
  if x.max_count != FIT_UINT16_INVALID  {
    let val : Double = Double(x.max_count)
    rv[ "max_count" ] = val
  }
  if x.flags != FIT_FILE_FLAGS_INVALID  {
    let val : Double = Double(x.flags)
    rv[ "flags" ] = val
  }
  return rv
}
func rzfit_file_capabilities_mesg_enum_dict( ptr : UnsafePointer<FIT_FILE_CAPABILITIES_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  var x : FIT_FILE_CAPABILITIES_MESG = ptr.pointee
  rv[ "directory" ] = withUnsafeBytes(of: &x.directory) { (rawPtr) -> String in
    let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
    return String(cString: ptr)
  }
  if( x.type != FIT_FILE_INVALID ) {
    rv[ "type" ] = rzfit_file_string(input: x.type)
  }
  return rv
}
func rzfit_segment_leaderboard_entry_mesg_value_dict( ptr : UnsafePointer<FIT_SEGMENT_LEADERBOARD_ENTRY_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_SEGMENT_LEADERBOARD_ENTRY_MESG = ptr.pointee
  if x.group_primary_key != FIT_UINT32_INVALID  {
    let val : Double = Double(x.group_primary_key)
    rv[ "group_primary_key" ] = val
  }
  if x.activity_id != FIT_UINT32_INVALID  {
    let val : Double = Double(x.activity_id)
    rv[ "activity_id" ] = val
  }
  if x.segment_time != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.segment_time))/Double(1000)
    rv[ "segment_time" ] = val
  }
  if x.message_index != FIT_MESSAGE_INDEX_INVALID  {
    let val : Double = Double(x.message_index)
    rv[ "message_index" ] = val
  }
  if x.name != FIT_STRING_INVALID  {
    let val : Double = Double(x.name)
    rv[ "name" ] = val
  }
  return rv
}
func rzfit_segment_leaderboard_entry_mesg_enum_dict( ptr : UnsafePointer<FIT_SEGMENT_LEADERBOARD_ENTRY_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  var x : FIT_SEGMENT_LEADERBOARD_ENTRY_MESG = ptr.pointee
  rv[ "name" ] = withUnsafeBytes(of: &x.name) { (rawPtr) -> String in
    let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
    return String(cString: ptr)
  }
  if( x.type != FIT_SEGMENT_LEADERBOARD_TYPE_INVALID ) {
    rv[ "type" ] = rzfit_segment_leaderboard_type_string(input: x.type)
  }
  return rv
}
func rzfit_segment_id_mesg_value_dict( ptr : UnsafePointer<FIT_SEGMENT_ID_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_SEGMENT_ID_MESG = ptr.pointee
  if x.user_profile_primary_key != FIT_UINT32_INVALID  {
    let val : Double = Double(x.user_profile_primary_key)
    rv[ "user_profile_primary_key" ] = val
  }
  if x.device_id != FIT_UINT32_INVALID  {
    let val : Double = Double(x.device_id)
    rv[ "device_id" ] = val
  }
  if x.name != FIT_STRING_INVALID  {
    let val : Double = Double(x.name)
    rv[ "name" ] = val
  }
  if x.uuid != FIT_STRING_INVALID  {
    let val : Double = Double(x.uuid)
    rv[ "uuid" ] = val
  }
  if x.enabled != FIT_BOOL_INVALID  {
    let val : Double = Double(x.enabled)
    rv[ "enabled" ] = val
  }
  if x.default_race_leader != FIT_UINT8_INVALID  {
    let val : Double = Double(x.default_race_leader)
    rv[ "default_race_leader" ] = val
  }
  return rv
}
func rzfit_segment_id_mesg_enum_dict( ptr : UnsafePointer<FIT_SEGMENT_ID_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  var x : FIT_SEGMENT_ID_MESG = ptr.pointee
  rv[ "name" ] = withUnsafeBytes(of: &x.name) { (rawPtr) -> String in
    let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
    return String(cString: ptr)
  }
  rv[ "uuid" ] = withUnsafeBytes(of: &x.uuid) { (rawPtr) -> String in
    let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
    return String(cString: ptr)
  }
  if( x.sport != FIT_SPORT_INVALID ) {
    rv[ "sport" ] = rzfit_sport_string(input: x.sport)
  }
  if( x.delete_status != FIT_SEGMENT_DELETE_STATUS_INVALID ) {
    rv[ "delete_status" ] = rzfit_segment_delete_status_string(input: x.delete_status)
  }
  if( x.selection_type != FIT_SEGMENT_SELECTION_TYPE_INVALID ) {
    rv[ "selection_type" ] = rzfit_segment_selection_type_string(input: x.selection_type)
  }
  return rv
}
func rzfit_video_description_mesg_value_dict( ptr : UnsafePointer<FIT_VIDEO_DESCRIPTION_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_VIDEO_DESCRIPTION_MESG = ptr.pointee
  if x.message_index != FIT_MESSAGE_INDEX_INVALID  {
    let val : Double = Double(x.message_index)
    rv[ "message_index" ] = val
  }
  if x.message_count != FIT_UINT16_INVALID  {
    let val : Double = Double(x.message_count)
    rv[ "message_count" ] = val
  }
  return rv
}
func rzfit_video_description_mesg_enum_dict( ptr : UnsafePointer<FIT_VIDEO_DESCRIPTION_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  var x : FIT_VIDEO_DESCRIPTION_MESG = ptr.pointee
  rv[ "text" ] = withUnsafeBytes(of: &x.text) { (rawPtr) -> String in
    let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
    return String(cString: ptr)
  }
  return rv
}
func rzfit_field_capabilities_mesg_value_dict( ptr : UnsafePointer<FIT_FIELD_CAPABILITIES_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_FIELD_CAPABILITIES_MESG = ptr.pointee
  if x.message_index != FIT_MESSAGE_INDEX_INVALID  {
    let val : Double = Double(x.message_index)
    rv[ "message_index" ] = val
  }
  if x.count != FIT_UINT16_INVALID  {
    let val : Double = Double(x.count)
    rv[ "count" ] = val
  }
  if x.field_num != FIT_UINT8_INVALID  {
    let val : Double = Double(x.field_num)
    rv[ "field_num" ] = val
  }
  return rv
}
func rzfit_field_capabilities_mesg_enum_dict( ptr : UnsafePointer<FIT_FIELD_CAPABILITIES_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_FIELD_CAPABILITIES_MESG = ptr.pointee
  if( x.mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "mesg_num" ] = rzfit_mesg_num_string(input: x.mesg_num)
  }
  if( x.file != FIT_FILE_INVALID ) {
    rv[ "file" ] = rzfit_file_string(input: x.file)
  }
  return rv
}
func rzfit_device_file_value_dict( ptr : UnsafePointer<FIT_DEVICE_FILE>) -> [String:Double] {
  return [:]
}
func rzfit_device_file_enum_dict( ptr : UnsafePointer<FIT_DEVICE_FILE>) -> [String:String] {
  return [:]
}
func rzfit_course_point_mesg_value_dict( ptr : UnsafePointer<FIT_COURSE_POINT_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_COURSE_POINT_MESG = ptr.pointee
  if x.timestamp != FIT_DATE_TIME_INVALID  {
    let val : Double = Double(x.timestamp)
    rv[ "timestamp" ] = val
  }
  if x.position_lat != FIT_SINT32_INVALID  {
    let val : Double = Double(x.position_lat)
    rv[ "position_lat" ] = val
  }
  if x.position_long != FIT_SINT32_INVALID  {
    let val : Double = Double(x.position_long)
    rv[ "position_long" ] = val
  }
  if x.distance != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.distance))/Double(100)
    rv[ "distance" ] = val
  }
  if x.message_index != FIT_MESSAGE_INDEX_INVALID  {
    let val : Double = Double(x.message_index)
    rv[ "message_index" ] = val
  }
  if x.favorite != FIT_BOOL_INVALID  {
    let val : Double = Double(x.favorite)
    rv[ "favorite" ] = val
  }
  return rv
}
func rzfit_course_point_mesg_enum_dict( ptr : UnsafePointer<FIT_COURSE_POINT_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  var x : FIT_COURSE_POINT_MESG = ptr.pointee
  rv[ "name" ] = withUnsafeBytes(of: &x.name) { (rawPtr) -> String in
    let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
    return String(cString: ptr)
  }
  if( x.type != FIT_COURSE_POINT_INVALID ) {
    rv[ "type" ] = rzfit_course_point_string(input: x.type)
  }
  return rv
}
func rzfit_event_mesg_def_value_dict( ptr : UnsafePointer<FIT_EVENT_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_EVENT_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_event_mesg_def_enum_dict( ptr : UnsafePointer<FIT_EVENT_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_EVENT_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_course_point_mesg_def_value_dict( ptr : UnsafePointer<FIT_COURSE_POINT_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_COURSE_POINT_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_course_point_mesg_def_enum_dict( ptr : UnsafePointer<FIT_COURSE_POINT_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_COURSE_POINT_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_record_mesg_def_value_dict( ptr : UnsafePointer<FIT_RECORD_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_RECORD_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_record_mesg_def_enum_dict( ptr : UnsafePointer<FIT_RECORD_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_RECORD_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_hr_mesg_value_dict( ptr : UnsafePointer<FIT_HR_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_HR_MESG = ptr.pointee
  if x.timestamp != FIT_DATE_TIME_INVALID  {
    let val : Double = Double(x.timestamp)
    rv[ "timestamp" ] = val
  }
  if x.event_timestamp != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.event_timestamp))/Double(1024)
    rv[ "event_timestamp" ] = val
  }
  if x.fractional_timestamp != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.fractional_timestamp))/Double(32768)
    rv[ "fractional_timestamp" ] = val
  }
  if x.time256 != FIT_UINT8_INVALID  {
    let val : Double = (Double(x.time256))/Double(256)
    rv[ "time256" ] = val
  }
  if x.filtered_bpm != FIT_UINT8_INVALID  {
    let val : Double = Double(x.filtered_bpm)
    rv[ "filtered_bpm" ] = val
  }
  if x.event_timestamp_12 != FIT_BYTE_INVALID  {
    let val : Double = Double(x.event_timestamp_12)
    rv[ "event_timestamp_12" ] = val
  }
  return rv
}
func rzfit_hr_mesg_enum_dict( ptr : UnsafePointer<FIT_HR_MESG>) -> [String:String] {
  return [:]
}
func rzfit_video_description_mesg_def_value_dict( ptr : UnsafePointer<FIT_VIDEO_DESCRIPTION_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_VIDEO_DESCRIPTION_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_video_description_mesg_def_enum_dict( ptr : UnsafePointer<FIT_VIDEO_DESCRIPTION_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_VIDEO_DESCRIPTION_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_monitoring_info_mesg_value_dict( ptr : UnsafePointer<FIT_MONITORING_INFO_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_MONITORING_INFO_MESG = ptr.pointee
  if x.timestamp != FIT_DATE_TIME_INVALID  {
    let val : Double = Double(x.timestamp)
    rv[ "timestamp" ] = val
  }
  if x.local_timestamp != FIT_LOCAL_DATE_TIME_INVALID  {
    let val : Double = Double(x.local_timestamp)
    rv[ "local_timestamp" ] = val
  }
  return rv
}
func rzfit_monitoring_info_mesg_enum_dict( ptr : UnsafePointer<FIT_MONITORING_INFO_MESG>) -> [String:String] {
  return [:]
}
func rzfit_goal_mesg_value_dict( ptr : UnsafePointer<FIT_GOAL_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_GOAL_MESG = ptr.pointee
  if x.start_date != FIT_DATE_TIME_INVALID  {
    let val : Double = Double(x.start_date)
    rv[ "start_date" ] = val
  }
  if x.end_date != FIT_DATE_TIME_INVALID  {
    let val : Double = Double(x.end_date)
    rv[ "end_date" ] = val
  }
  if x.value != FIT_UINT32_INVALID  {
    let val : Double = Double(x.value)
    rv[ "value" ] = val
  }
  if x.target_value != FIT_UINT32_INVALID  {
    let val : Double = Double(x.target_value)
    rv[ "target_value" ] = val
  }
  if x.message_index != FIT_MESSAGE_INDEX_INVALID  {
    let val : Double = Double(x.message_index)
    rv[ "message_index" ] = val
  }
  if x.recurrence_value != FIT_UINT16_INVALID  {
    let val : Double = Double(x.recurrence_value)
    rv[ "recurrence_value" ] = val
  }
  if x.repeat != FIT_BOOL_INVALID  {
    let val : Double = Double(x.repeat)
    rv[ "repeat" ] = val
  }
  if x.enabled != FIT_BOOL_INVALID  {
    let val : Double = Double(x.enabled)
    rv[ "enabled" ] = val
  }
  return rv
}
func rzfit_goal_mesg_enum_dict( ptr : UnsafePointer<FIT_GOAL_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_GOAL_MESG = ptr.pointee
  if( x.sport != FIT_SPORT_INVALID ) {
    rv[ "sport" ] = rzfit_sport_string(input: x.sport)
  }
  if( x.sub_sport != FIT_SUB_SPORT_INVALID ) {
    rv[ "sub_sport" ] = rzfit_sub_sport_string(input: x.sub_sport)
  }
  if( x.type != FIT_GOAL_INVALID ) {
    rv[ "type" ] = rzfit_goal_string(input: x.type)
  }
  if( x.recurrence != FIT_GOAL_RECURRENCE_INVALID ) {
    rv[ "recurrence" ] = rzfit_goal_recurrence_string(input: x.recurrence)
  }
  if( x.source != FIT_GOAL_SOURCE_INVALID ) {
    rv[ "source" ] = rzfit_goal_source_string(input: x.source)
  }
  return rv
}
func rzfit_totals_mesg_def_value_dict( ptr : UnsafePointer<FIT_TOTALS_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_TOTALS_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_totals_mesg_def_enum_dict( ptr : UnsafePointer<FIT_TOTALS_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_TOTALS_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_blood_pressure_mesg_def_value_dict( ptr : UnsafePointer<FIT_BLOOD_PRESSURE_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_BLOOD_PRESSURE_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_blood_pressure_mesg_def_enum_dict( ptr : UnsafePointer<FIT_BLOOD_PRESSURE_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_BLOOD_PRESSURE_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_weather_conditions_mesg_value_dict( ptr : UnsafePointer<FIT_WEATHER_CONDITIONS_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_WEATHER_CONDITIONS_MESG = ptr.pointee
  if x.timestamp != FIT_DATE_TIME_INVALID  {
    let val : Double = Double(x.timestamp)
    rv[ "timestamp" ] = val
  }
  if x.observed_at_time != FIT_DATE_TIME_INVALID  {
    let val : Double = Double(x.observed_at_time)
    rv[ "observed_at_time" ] = val
  }
  if x.observed_location_lat != FIT_SINT32_INVALID  {
    let val : Double = Double(x.observed_location_lat)
    rv[ "observed_location_lat" ] = val
  }
  if x.observed_location_long != FIT_SINT32_INVALID  {
    let val : Double = Double(x.observed_location_long)
    rv[ "observed_location_long" ] = val
  }
  if x.wind_direction != FIT_UINT16_INVALID  {
    let val : Double = Double(x.wind_direction)
    rv[ "wind_direction" ] = val
  }
  if x.wind_speed != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.wind_speed))/Double(1000)
    rv[ "wind_speed" ] = val
  }
  if x.temperature != FIT_SINT8_INVALID  {
    let val : Double = Double(x.temperature)
    rv[ "temperature" ] = val
  }
  if x.precipitation_probability != FIT_UINT8_INVALID  {
    let val : Double = Double(x.precipitation_probability)
    rv[ "precipitation_probability" ] = val
  }
  if x.temperature_feels_like != FIT_SINT8_INVALID  {
    let val : Double = Double(x.temperature_feels_like)
    rv[ "temperature_feels_like" ] = val
  }
  if x.relative_humidity != FIT_UINT8_INVALID  {
    let val : Double = Double(x.relative_humidity)
    rv[ "relative_humidity" ] = val
  }
  if x.high_temperature != FIT_SINT8_INVALID  {
    let val : Double = Double(x.high_temperature)
    rv[ "high_temperature" ] = val
  }
  if x.low_temperature != FIT_SINT8_INVALID  {
    let val : Double = Double(x.low_temperature)
    rv[ "low_temperature" ] = val
  }
  return rv
}
func rzfit_weather_conditions_mesg_enum_dict( ptr : UnsafePointer<FIT_WEATHER_CONDITIONS_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  var x : FIT_WEATHER_CONDITIONS_MESG = ptr.pointee
  rv[ "location" ] = withUnsafeBytes(of: &x.location) { (rawPtr) -> String in
    let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
    return String(cString: ptr)
  }
  if( x.weather_report != FIT_WEATHER_REPORT_INVALID ) {
    rv[ "weather_report" ] = rzfit_weather_report_string(input: x.weather_report)
  }
  if( x.condition != FIT_WEATHER_STATUS_INVALID ) {
    rv[ "condition" ] = rzfit_weather_status_string(input: x.condition)
  }
  if( x.day_of_week != FIT_DAY_OF_WEEK_INVALID ) {
    rv[ "day_of_week" ] = rzfit_day_of_week_string(input: x.day_of_week)
  }
  return rv
}
func rzfit_capabilities_mesg_def_value_dict( ptr : UnsafePointer<FIT_CAPABILITIES_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_CAPABILITIES_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_capabilities_mesg_def_enum_dict( ptr : UnsafePointer<FIT_CAPABILITIES_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_CAPABILITIES_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_sdm_profile_mesg_def_value_dict( ptr : UnsafePointer<FIT_SDM_PROFILE_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_SDM_PROFILE_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_sdm_profile_mesg_def_enum_dict( ptr : UnsafePointer<FIT_SDM_PROFILE_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_SDM_PROFILE_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_software_mesg_def_value_dict( ptr : UnsafePointer<FIT_SOFTWARE_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_SOFTWARE_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_software_mesg_def_enum_dict( ptr : UnsafePointer<FIT_SOFTWARE_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_SOFTWARE_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_activity_mesg_def_value_dict( ptr : UnsafePointer<FIT_ACTIVITY_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_ACTIVITY_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_activity_mesg_def_enum_dict( ptr : UnsafePointer<FIT_ACTIVITY_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_ACTIVITY_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_ant_rx_mesg_def_value_dict( ptr : UnsafePointer<FIT_ANT_RX_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_ANT_RX_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_ant_rx_mesg_def_enum_dict( ptr : UnsafePointer<FIT_ANT_RX_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_ANT_RX_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_capabilities_mesg_value_dict( ptr : UnsafePointer<FIT_CAPABILITIES_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_CAPABILITIES_MESG = ptr.pointee
  if x.workouts_supported != FIT_WORKOUT_CAPABILITIES_INVALID  {
    let val : Double = Double(x.workouts_supported)
    rv[ "workouts_supported" ] = val
  }
  if x.connectivity_supported != FIT_CONNECTIVITY_CAPABILITIES_INVALID  {
    let val : Double = Double(x.connectivity_supported)
    rv[ "connectivity_supported" ] = val
  }
  if x.sports != FIT_SPORT_BITS_0_INVALID  {
    let val : Double = Double(x.sports)
    rv[ "sports" ] = val
  }
  return rv
}
func rzfit_capabilities_mesg_enum_dict( ptr : UnsafePointer<FIT_CAPABILITIES_MESG>) -> [String:String] {
  return [:]
}
func rzfit_software_mesg_value_dict( ptr : UnsafePointer<FIT_SOFTWARE_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_SOFTWARE_MESG = ptr.pointee
  if x.message_index != FIT_MESSAGE_INDEX_INVALID  {
    let val : Double = Double(x.message_index)
    rv[ "message_index" ] = val
  }
  if x.version != FIT_UINT16_INVALID  {
    let val : Double = Double(x.version)
    rv[ "version" ] = val
  }
  return rv
}
func rzfit_software_mesg_enum_dict( ptr : UnsafePointer<FIT_SOFTWARE_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  var x : FIT_SOFTWARE_MESG = ptr.pointee
  rv[ "part_number" ] = withUnsafeBytes(of: &x.part_number) { (rawPtr) -> String in
    let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
    return String(cString: ptr)
  }
  return rv
}
func rzfit_hrv_mesg_value_dict( ptr : UnsafePointer<FIT_HRV_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_HRV_MESG = ptr.pointee
  if x.time != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.time))/Double(1000)
    rv[ "time" ] = val
  }
  return rv
}
func rzfit_hrv_mesg_enum_dict( ptr : UnsafePointer<FIT_HRV_MESG>) -> [String:String] {
  return [:]
}
func rzfit_device_info_mesg_def_value_dict( ptr : UnsafePointer<FIT_DEVICE_INFO_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_DEVICE_INFO_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_device_info_mesg_def_enum_dict( ptr : UnsafePointer<FIT_DEVICE_INFO_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_DEVICE_INFO_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_monitoring_info_mesg_def_value_dict( ptr : UnsafePointer<FIT_MONITORING_INFO_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_MONITORING_INFO_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_monitoring_info_mesg_def_enum_dict( ptr : UnsafePointer<FIT_MONITORING_INFO_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_MONITORING_INFO_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_workout_session_mesg_def_value_dict( ptr : UnsafePointer<FIT_WORKOUT_SESSION_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_WORKOUT_SESSION_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_workout_session_mesg_def_enum_dict( ptr : UnsafePointer<FIT_WORKOUT_SESSION_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_WORKOUT_SESSION_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_length_mesg_def_value_dict( ptr : UnsafePointer<FIT_LENGTH_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_LENGTH_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_length_mesg_def_enum_dict( ptr : UnsafePointer<FIT_LENGTH_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_LENGTH_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_ant_rx_mesg_value_dict( ptr : UnsafePointer<FIT_ANT_RX_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_ANT_RX_MESG = ptr.pointee
  if x.timestamp != FIT_DATE_TIME_INVALID  {
    let val : Double = Double(x.timestamp)
    rv[ "timestamp" ] = val
  }
  if x.fractional_timestamp != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.fractional_timestamp))/Double(32768)
    rv[ "fractional_timestamp" ] = val
  }
  if x.mesg_id != FIT_BYTE_INVALID  {
    let val : Double = Double(x.mesg_id)
    rv[ "mesg_id" ] = val
  }
  if x.channel_number != FIT_UINT8_INVALID  {
    let val : Double = Double(x.channel_number)
    rv[ "channel_number" ] = val
  }
  return rv
}
func rzfit_ant_rx_mesg_enum_dict( ptr : UnsafePointer<FIT_ANT_RX_MESG>) -> [String:String] {
  return [:]
}
func rzfit_mesg_convert_value_dict( ptr : UnsafePointer<FIT_MESG_CONVERT>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_MESG_CONVERT = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_mesg_convert_enum_dict( ptr : UnsafePointer<FIT_MESG_CONVERT>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_MESG_CONVERT = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_device_settings_mesg_value_dict( ptr : UnsafePointer<FIT_DEVICE_SETTINGS_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_DEVICE_SETTINGS_MESG = ptr.pointee
  if x.utc_offset != FIT_UINT32_INVALID  {
    let val : Double = Double(x.utc_offset)
    rv[ "utc_offset" ] = val
  }
  if x.clock_time != FIT_DATE_TIME_INVALID  {
    let val : Double = Double(x.clock_time)
    rv[ "clock_time" ] = val
  }
  if x.pages_enabled != FIT_UINT16_INVALID  {
    let val : Double = Double(x.pages_enabled)
    rv[ "pages_enabled" ] = val
  }
  if x.default_page != FIT_UINT16_INVALID  {
    let val : Double = Double(x.default_page)
    rv[ "default_page" ] = val
  }
  if x.autosync_min_steps != FIT_UINT16_INVALID  {
    let val : Double = Double(x.autosync_min_steps)
    rv[ "autosync_min_steps" ] = val
  }
  if x.autosync_min_time != FIT_UINT16_INVALID  {
    let val : Double = Double(x.autosync_min_time)
    rv[ "autosync_min_time" ] = val
  }
  if x.active_time_zone != FIT_UINT8_INVALID  {
    let val : Double = Double(x.active_time_zone)
    rv[ "active_time_zone" ] = val
  }
  if x.activity_tracker_enabled != FIT_BOOL_INVALID  {
    let val : Double = Double(x.activity_tracker_enabled)
    rv[ "activity_tracker_enabled" ] = val
  }
  if x.move_alert_enabled != FIT_BOOL_INVALID  {
    let val : Double = Double(x.move_alert_enabled)
    rv[ "move_alert_enabled" ] = val
  }
  return rv
}
func rzfit_device_settings_mesg_enum_dict( ptr : UnsafePointer<FIT_DEVICE_SETTINGS_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_DEVICE_SETTINGS_MESG = ptr.pointee
  if( x.backlight_mode != FIT_BACKLIGHT_MODE_INVALID ) {
    rv[ "backlight_mode" ] = rzfit_backlight_mode_string(input: x.backlight_mode)
  }
  if( x.date_mode != FIT_DATE_MODE_INVALID ) {
    rv[ "date_mode" ] = rzfit_date_mode_string(input: x.date_mode)
  }
  if( x.display_orientation != FIT_DISPLAY_ORIENTATION_INVALID ) {
    rv[ "display_orientation" ] = rzfit_display_orientation_string(input: x.display_orientation)
  }
  if( x.mounting_side != FIT_SIDE_INVALID ) {
    rv[ "mounting_side" ] = rzfit_side_string(input: x.mounting_side)
  }
  return rv
}
func rzfit_totals_mesg_value_dict( ptr : UnsafePointer<FIT_TOTALS_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_TOTALS_MESG = ptr.pointee
  if x.timestamp != FIT_DATE_TIME_INVALID  {
    let val : Double = Double(x.timestamp)
    rv[ "timestamp" ] = val
  }
  if x.timer_time != FIT_UINT32_INVALID  {
    let val : Double = Double(x.timer_time)
    rv[ "timer_time" ] = val
  }
  if x.distance != FIT_UINT32_INVALID  {
    let val : Double = Double(x.distance)
    rv[ "distance" ] = val
  }
  if x.calories != FIT_UINT32_INVALID  {
    let val : Double = Double(x.calories)
    rv[ "calories" ] = val
  }
  if x.elapsed_time != FIT_UINT32_INVALID  {
    let val : Double = Double(x.elapsed_time)
    rv[ "elapsed_time" ] = val
  }
  if x.active_time != FIT_UINT32_INVALID  {
    let val : Double = Double(x.active_time)
    rv[ "active_time" ] = val
  }
  if x.message_index != FIT_MESSAGE_INDEX_INVALID  {
    let val : Double = Double(x.message_index)
    rv[ "message_index" ] = val
  }
  if x.sessions != FIT_UINT16_INVALID  {
    let val : Double = Double(x.sessions)
    rv[ "sessions" ] = val
  }
  return rv
}
func rzfit_totals_mesg_enum_dict( ptr : UnsafePointer<FIT_TOTALS_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_TOTALS_MESG = ptr.pointee
  if( x.sport != FIT_SPORT_INVALID ) {
    rv[ "sport" ] = rzfit_sport_string(input: x.sport)
  }
  return rv
}
func rzfit_cadence_zone_mesg_value_dict( ptr : UnsafePointer<FIT_CADENCE_ZONE_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_CADENCE_ZONE_MESG = ptr.pointee
  if x.message_index != FIT_MESSAGE_INDEX_INVALID  {
    let val : Double = Double(x.message_index)
    rv[ "message_index" ] = val
  }
  if x.high_value != FIT_UINT8_INVALID  {
    let val : Double = Double(x.high_value)
    rv[ "high_value" ] = val
  }
  return rv
}
func rzfit_cadence_zone_mesg_enum_dict( ptr : UnsafePointer<FIT_CADENCE_ZONE_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  var x : FIT_CADENCE_ZONE_MESG = ptr.pointee
  rv[ "name" ] = withUnsafeBytes(of: &x.name) { (rawPtr) -> String in
    let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
    return String(cString: ptr)
  }
  return rv
}
func rzfit_course_mesg_value_dict( ptr : UnsafePointer<FIT_COURSE_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_COURSE_MESG = ptr.pointee
  if x.capabilities != FIT_COURSE_CAPABILITIES_INVALID  {
    let val : Double = Double(x.capabilities)
    rv[ "capabilities" ] = val
  }
  return rv
}
func rzfit_course_mesg_enum_dict( ptr : UnsafePointer<FIT_COURSE_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  var x : FIT_COURSE_MESG = ptr.pointee
  rv[ "name" ] = withUnsafeBytes(of: &x.name) { (rawPtr) -> String in
    let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
    return String(cString: ptr)
  }
  if( x.sport != FIT_SPORT_INVALID ) {
    rv[ "sport" ] = rzfit_sport_string(input: x.sport)
  }
  if( x.sub_sport != FIT_SUB_SPORT_INVALID ) {
    rv[ "sub_sport" ] = rzfit_sub_sport_string(input: x.sub_sport)
  }
  return rv
}
func rzfit_segment_point_mesg_def_value_dict( ptr : UnsafePointer<FIT_SEGMENT_POINT_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_SEGMENT_POINT_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_segment_point_mesg_def_enum_dict( ptr : UnsafePointer<FIT_SEGMENT_POINT_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_SEGMENT_POINT_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_user_profile_mesg_def_value_dict( ptr : UnsafePointer<FIT_USER_PROFILE_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_USER_PROFILE_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_user_profile_mesg_def_enum_dict( ptr : UnsafePointer<FIT_USER_PROFILE_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_USER_PROFILE_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_lap_mesg_value_dict( ptr : UnsafePointer<FIT_LAP_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_LAP_MESG = ptr.pointee
  if x.timestamp != FIT_DATE_TIME_INVALID  {
    let val : Double = Double(x.timestamp)
    rv[ "timestamp" ] = val
  }
  if x.start_time != FIT_DATE_TIME_INVALID  {
    let val : Double = Double(x.start_time)
    rv[ "start_time" ] = val
  }
  if x.start_position_lat != FIT_SINT32_INVALID  {
    let val : Double = Double(x.start_position_lat)
    rv[ "start_position_lat" ] = val
  }
  if x.start_position_long != FIT_SINT32_INVALID  {
    let val : Double = Double(x.start_position_long)
    rv[ "start_position_long" ] = val
  }
  if x.end_position_lat != FIT_SINT32_INVALID  {
    let val : Double = Double(x.end_position_lat)
    rv[ "end_position_lat" ] = val
  }
  if x.end_position_long != FIT_SINT32_INVALID  {
    let val : Double = Double(x.end_position_long)
    rv[ "end_position_long" ] = val
  }
  if x.total_elapsed_time != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.total_elapsed_time))/Double(1000)
    rv[ "total_elapsed_time" ] = val
  }
  if x.total_timer_time != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.total_timer_time))/Double(1000)
    rv[ "total_timer_time" ] = val
  }
  if x.total_distance != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.total_distance))/Double(100)
    rv[ "total_distance" ] = val
  }
  if x.total_cycles != FIT_UINT32_INVALID  {
    let val : Double = Double(x.total_cycles)
    rv[ "total_cycles" ] = val
  }
  if x.total_work != FIT_UINT32_INVALID  {
    let val : Double = Double(x.total_work)
    rv[ "total_work" ] = val
  }
  if x.total_moving_time != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.total_moving_time))/Double(1000)
    rv[ "total_moving_time" ] = val
  }
  if x.time_in_hr_zone != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.time_in_hr_zone))/Double(1000)
    rv[ "time_in_hr_zone" ] = val
  }
  if x.time_in_speed_zone != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.time_in_speed_zone))/Double(1000)
    rv[ "time_in_speed_zone" ] = val
  }
  if x.time_in_cadence_zone != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.time_in_cadence_zone))/Double(1000)
    rv[ "time_in_cadence_zone" ] = val
  }
  if x.time_in_power_zone != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.time_in_power_zone))/Double(1000)
    rv[ "time_in_power_zone" ] = val
  }
  if x.enhanced_avg_speed != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.enhanced_avg_speed))/Double(1000)
    rv[ "enhanced_avg_speed" ] = val
  }
  if x.enhanced_max_speed != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.enhanced_max_speed))/Double(1000)
    rv[ "enhanced_max_speed" ] = val
  }
  if x.enhanced_avg_altitude != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.enhanced_avg_altitude)-Double(500))/Double(5)
    rv[ "enhanced_avg_altitude" ] = val
  }
  if x.enhanced_min_altitude != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.enhanced_min_altitude)-Double(500))/Double(5)
    rv[ "enhanced_min_altitude" ] = val
  }
  if x.enhanced_max_altitude != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.enhanced_max_altitude)-Double(500))/Double(5)
    rv[ "enhanced_max_altitude" ] = val
  }
  if x.message_index != FIT_MESSAGE_INDEX_INVALID  {
    let val : Double = Double(x.message_index)
    rv[ "message_index" ] = val
  }
  if x.total_calories != FIT_UINT16_INVALID  {
    let val : Double = Double(x.total_calories)
    rv[ "total_calories" ] = val
  }
  if x.total_fat_calories != FIT_UINT16_INVALID  {
    let val : Double = Double(x.total_fat_calories)
    rv[ "total_fat_calories" ] = val
  }
  if x.avg_speed != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.avg_speed))/Double(1000)
    rv[ "avg_speed" ] = val
  }
  if x.max_speed != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.max_speed))/Double(1000)
    rv[ "max_speed" ] = val
  }
  if x.avg_power != FIT_UINT16_INVALID  {
    let val : Double = Double(x.avg_power)
    rv[ "avg_power" ] = val
  }
  if x.max_power != FIT_UINT16_INVALID  {
    let val : Double = Double(x.max_power)
    rv[ "max_power" ] = val
  }
  if x.total_ascent != FIT_UINT16_INVALID  {
    let val : Double = Double(x.total_ascent)
    rv[ "total_ascent" ] = val
  }
  if x.total_descent != FIT_UINT16_INVALID  {
    let val : Double = Double(x.total_descent)
    rv[ "total_descent" ] = val
  }
  if x.num_lengths != FIT_UINT16_INVALID  {
    let val : Double = Double(x.num_lengths)
    rv[ "num_lengths" ] = val
  }
  if x.normalized_power != FIT_UINT16_INVALID  {
    let val : Double = Double(x.normalized_power)
    rv[ "normalized_power" ] = val
  }
  if x.left_right_balance != FIT_LEFT_RIGHT_BALANCE_100_INVALID  {
    let val : Double = Double(x.left_right_balance)
    rv[ "left_right_balance" ] = val
  }
  if x.first_length_index != FIT_UINT16_INVALID  {
    let val : Double = Double(x.first_length_index)
    rv[ "first_length_index" ] = val
  }
  if x.avg_stroke_distance != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.avg_stroke_distance))/Double(100)
    rv[ "avg_stroke_distance" ] = val
  }
  if x.num_active_lengths != FIT_UINT16_INVALID  {
    let val : Double = Double(x.num_active_lengths)
    rv[ "num_active_lengths" ] = val
  }
  if x.avg_altitude != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.avg_altitude)-Double(500))/Double(5)
    rv[ "avg_altitude" ] = val
  }
  if x.max_altitude != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.max_altitude)-Double(500))/Double(5)
    rv[ "max_altitude" ] = val
  }
  if x.avg_grade != FIT_SINT16_INVALID  {
    let val : Double = (Double(x.avg_grade))/Double(100)
    rv[ "avg_grade" ] = val
  }
  if x.avg_pos_grade != FIT_SINT16_INVALID  {
    let val : Double = (Double(x.avg_pos_grade))/Double(100)
    rv[ "avg_pos_grade" ] = val
  }
  if x.avg_neg_grade != FIT_SINT16_INVALID  {
    let val : Double = (Double(x.avg_neg_grade))/Double(100)
    rv[ "avg_neg_grade" ] = val
  }
  if x.max_pos_grade != FIT_SINT16_INVALID  {
    let val : Double = (Double(x.max_pos_grade))/Double(100)
    rv[ "max_pos_grade" ] = val
  }
  if x.max_neg_grade != FIT_SINT16_INVALID  {
    let val : Double = (Double(x.max_neg_grade))/Double(100)
    rv[ "max_neg_grade" ] = val
  }
  if x.avg_pos_vertical_speed != FIT_SINT16_INVALID  {
    let val : Double = (Double(x.avg_pos_vertical_speed))/Double(1000)
    rv[ "avg_pos_vertical_speed" ] = val
  }
  if x.avg_neg_vertical_speed != FIT_SINT16_INVALID  {
    let val : Double = (Double(x.avg_neg_vertical_speed))/Double(1000)
    rv[ "avg_neg_vertical_speed" ] = val
  }
  if x.max_pos_vertical_speed != FIT_SINT16_INVALID  {
    let val : Double = (Double(x.max_pos_vertical_speed))/Double(1000)
    rv[ "max_pos_vertical_speed" ] = val
  }
  if x.max_neg_vertical_speed != FIT_SINT16_INVALID  {
    let val : Double = (Double(x.max_neg_vertical_speed))/Double(1000)
    rv[ "max_neg_vertical_speed" ] = val
  }
  if x.repetition_num != FIT_UINT16_INVALID  {
    let val : Double = Double(x.repetition_num)
    rv[ "repetition_num" ] = val
  }
  if x.min_altitude != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.min_altitude)-Double(500))/Double(5)
    rv[ "min_altitude" ] = val
  }
  if x.wkt_step_index != FIT_MESSAGE_INDEX_INVALID  {
    let val : Double = Double(x.wkt_step_index)
    rv[ "wkt_step_index" ] = val
  }
  if x.opponent_score != FIT_UINT16_INVALID  {
    let val : Double = Double(x.opponent_score)
    rv[ "opponent_score" ] = val
  }
  if x.stroke_count != FIT_UINT16_INVALID  {
    let val : Double = Double(x.stroke_count)
    rv[ "stroke_count" ] = val
  }
  if x.zone_count != FIT_UINT16_INVALID  {
    let val : Double = Double(x.zone_count)
    rv[ "zone_count" ] = val
  }
  if x.avg_vertical_oscillation != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.avg_vertical_oscillation))/Double(10)
    rv[ "avg_vertical_oscillation" ] = val
  }
  if x.avg_stance_time_percent != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.avg_stance_time_percent))/Double(100)
    rv[ "avg_stance_time_percent" ] = val
  }
  if x.avg_stance_time != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.avg_stance_time))/Double(10)
    rv[ "avg_stance_time" ] = val
  }
  if x.player_score != FIT_UINT16_INVALID  {
    let val : Double = Double(x.player_score)
    rv[ "player_score" ] = val
  }
  if x.avg_total_hemoglobin_conc != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.avg_total_hemoglobin_conc))/Double(100)
    rv[ "avg_total_hemoglobin_conc" ] = val
  }
  if x.min_total_hemoglobin_conc != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.min_total_hemoglobin_conc))/Double(100)
    rv[ "min_total_hemoglobin_conc" ] = val
  }
  if x.max_total_hemoglobin_conc != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.max_total_hemoglobin_conc))/Double(100)
    rv[ "max_total_hemoglobin_conc" ] = val
  }
  if x.avg_saturated_hemoglobin_percent != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.avg_saturated_hemoglobin_percent))/Double(10)
    rv[ "avg_saturated_hemoglobin_percent" ] = val
  }
  if x.min_saturated_hemoglobin_percent != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.min_saturated_hemoglobin_percent))/Double(10)
    rv[ "min_saturated_hemoglobin_percent" ] = val
  }
  if x.max_saturated_hemoglobin_percent != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.max_saturated_hemoglobin_percent))/Double(10)
    rv[ "max_saturated_hemoglobin_percent" ] = val
  }
  if x.avg_vam != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.avg_vam))/Double(1000)
    rv[ "avg_vam" ] = val
  }
  if x.avg_heart_rate != FIT_UINT8_INVALID  {
    let val : Double = Double(x.avg_heart_rate)
    rv[ "avg_heart_rate" ] = val
  }
  if x.max_heart_rate != FIT_UINT8_INVALID  {
    let val : Double = Double(x.max_heart_rate)
    rv[ "max_heart_rate" ] = val
  }
  if x.avg_cadence != FIT_UINT8_INVALID  {
    let val : Double = Double(x.avg_cadence)
    rv[ "avg_cadence" ] = val
  }
  if x.max_cadence != FIT_UINT8_INVALID  {
    let val : Double = Double(x.max_cadence)
    rv[ "max_cadence" ] = val
  }
  if x.event_group != FIT_UINT8_INVALID  {
    let val : Double = Double(x.event_group)
    rv[ "event_group" ] = val
  }
  if x.gps_accuracy != FIT_UINT8_INVALID  {
    let val : Double = Double(x.gps_accuracy)
    rv[ "gps_accuracy" ] = val
  }
  if x.avg_temperature != FIT_SINT8_INVALID  {
    let val : Double = Double(x.avg_temperature)
    rv[ "avg_temperature" ] = val
  }
  if x.max_temperature != FIT_SINT8_INVALID  {
    let val : Double = Double(x.max_temperature)
    rv[ "max_temperature" ] = val
  }
  if x.min_heart_rate != FIT_UINT8_INVALID  {
    let val : Double = Double(x.min_heart_rate)
    rv[ "min_heart_rate" ] = val
  }
  if x.avg_fractional_cadence != FIT_UINT8_INVALID  {
    let val : Double = (Double(x.avg_fractional_cadence))/Double(128)
    rv[ "avg_fractional_cadence" ] = val
  }
  if x.max_fractional_cadence != FIT_UINT8_INVALID  {
    let val : Double = (Double(x.max_fractional_cadence))/Double(128)
    rv[ "max_fractional_cadence" ] = val
  }
  if x.total_fractional_cycles != FIT_UINT8_INVALID  {
    let val : Double = (Double(x.total_fractional_cycles))/Double(128)
    rv[ "total_fractional_cycles" ] = val
  }
  return rv
}
func rzfit_lap_mesg_enum_dict( ptr : UnsafePointer<FIT_LAP_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_LAP_MESG = ptr.pointee
  if( x.event != FIT_EVENT_INVALID ) {
    rv[ "event" ] = rzfit_event_string(input: x.event)
  }
  if( x.event_type != FIT_EVENT_TYPE_INVALID ) {
    rv[ "event_type" ] = rzfit_event_type_string(input: x.event_type)
  }
  if( x.intensity != FIT_INTENSITY_INVALID ) {
    rv[ "intensity" ] = rzfit_intensity_string(input: x.intensity)
  }
  if( x.lap_trigger != FIT_LAP_TRIGGER_INVALID ) {
    rv[ "lap_trigger" ] = rzfit_lap_trigger_string(input: x.lap_trigger)
  }
  if( x.sport != FIT_SPORT_INVALID ) {
    rv[ "sport" ] = rzfit_sport_string(input: x.sport)
  }
  if( x.swim_stroke != FIT_SWIM_STROKE_INVALID ) {
    rv[ "swim_stroke" ] = rzfit_swim_stroke_string(input: x.swim_stroke)
  }
  if( x.sub_sport != FIT_SUB_SPORT_INVALID ) {
    rv[ "sub_sport" ] = rzfit_sub_sport_string(input: x.sub_sport)
  }
  return rv
}
func rzfit_hrv_mesg_def_value_dict( ptr : UnsafePointer<FIT_HRV_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_HRV_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_hrv_mesg_def_enum_dict( ptr : UnsafePointer<FIT_HRV_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_HRV_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_weight_scale_mesg_value_dict( ptr : UnsafePointer<FIT_WEIGHT_SCALE_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_WEIGHT_SCALE_MESG = ptr.pointee
  if x.timestamp != FIT_DATE_TIME_INVALID  {
    let val : Double = Double(x.timestamp)
    rv[ "timestamp" ] = val
  }
  if x.weight != FIT_WEIGHT_INVALID  {
    let val : Double = (Double(x.weight))/Double(100)
    rv[ "weight" ] = val
  }
  if x.percent_fat != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.percent_fat))/Double(100)
    rv[ "percent_fat" ] = val
  }
  if x.percent_hydration != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.percent_hydration))/Double(100)
    rv[ "percent_hydration" ] = val
  }
  if x.visceral_fat_mass != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.visceral_fat_mass))/Double(100)
    rv[ "visceral_fat_mass" ] = val
  }
  if x.bone_mass != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.bone_mass))/Double(100)
    rv[ "bone_mass" ] = val
  }
  if x.muscle_mass != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.muscle_mass))/Double(100)
    rv[ "muscle_mass" ] = val
  }
  if x.basal_met != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.basal_met))/Double(4)
    rv[ "basal_met" ] = val
  }
  if x.active_met != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.active_met))/Double(4)
    rv[ "active_met" ] = val
  }
  if x.user_profile_index != FIT_MESSAGE_INDEX_INVALID  {
    let val : Double = Double(x.user_profile_index)
    rv[ "user_profile_index" ] = val
  }
  if x.physique_rating != FIT_UINT8_INVALID  {
    let val : Double = Double(x.physique_rating)
    rv[ "physique_rating" ] = val
  }
  if x.metabolic_age != FIT_UINT8_INVALID  {
    let val : Double = Double(x.metabolic_age)
    rv[ "metabolic_age" ] = val
  }
  if x.visceral_fat_rating != FIT_UINT8_INVALID  {
    let val : Double = Double(x.visceral_fat_rating)
    rv[ "visceral_fat_rating" ] = val
  }
  return rv
}
func rzfit_weight_scale_mesg_enum_dict( ptr : UnsafePointer<FIT_WEIGHT_SCALE_MESG>) -> [String:String] {
  return [:]
}
func rzfit_exercise_title_mesg_value_dict( ptr : UnsafePointer<FIT_EXERCISE_TITLE_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_EXERCISE_TITLE_MESG = ptr.pointee
  if x.message_index != FIT_MESSAGE_INDEX_INVALID  {
    let val : Double = Double(x.message_index)
    rv[ "message_index" ] = val
  }
  if x.exercise_name != FIT_UINT16_INVALID  {
    let val : Double = Double(x.exercise_name)
    rv[ "exercise_name" ] = val
  }
  return rv
}
func rzfit_exercise_title_mesg_enum_dict( ptr : UnsafePointer<FIT_EXERCISE_TITLE_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  var x : FIT_EXERCISE_TITLE_MESG = ptr.pointee
  rv[ "wkt_step_name" ] = withUnsafeBytes(of: &x.wkt_step_name) { (rawPtr) -> String in
    let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
    return String(cString: ptr)
  }
  if( x.exercise_category != FIT_EXERCISE_CATEGORY_INVALID ) {
    rv[ "exercise_category" ] = rzfit_exercise_category_string(input: x.exercise_category)
  }
  return rv
}
func rzfit_nmea_sentence_mesg_def_value_dict( ptr : UnsafePointer<FIT_NMEA_SENTENCE_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_NMEA_SENTENCE_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_nmea_sentence_mesg_def_enum_dict( ptr : UnsafePointer<FIT_NMEA_SENTENCE_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_NMEA_SENTENCE_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_device_settings_mesg_def_value_dict( ptr : UnsafePointer<FIT_DEVICE_SETTINGS_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_DEVICE_SETTINGS_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_device_settings_mesg_def_enum_dict( ptr : UnsafePointer<FIT_DEVICE_SETTINGS_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_DEVICE_SETTINGS_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_hr_mesg_def_value_dict( ptr : UnsafePointer<FIT_HR_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_HR_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_hr_mesg_def_enum_dict( ptr : UnsafePointer<FIT_HR_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_HR_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_workout_session_mesg_value_dict( ptr : UnsafePointer<FIT_WORKOUT_SESSION_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_WORKOUT_SESSION_MESG = ptr.pointee
  if x.message_index != FIT_MESSAGE_INDEX_INVALID  {
    let val : Double = Double(x.message_index)
    rv[ "message_index" ] = val
  }
  if x.num_valid_steps != FIT_UINT16_INVALID  {
    let val : Double = Double(x.num_valid_steps)
    rv[ "num_valid_steps" ] = val
  }
  if x.first_step_index != FIT_UINT16_INVALID  {
    let val : Double = Double(x.first_step_index)
    rv[ "first_step_index" ] = val
  }
  if x.pool_length != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.pool_length))/Double(100)
    rv[ "pool_length" ] = val
  }
  return rv
}
func rzfit_workout_session_mesg_enum_dict( ptr : UnsafePointer<FIT_WORKOUT_SESSION_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_WORKOUT_SESSION_MESG = ptr.pointee
  if( x.sport != FIT_SPORT_INVALID ) {
    rv[ "sport" ] = rzfit_sport_string(input: x.sport)
  }
  if( x.sub_sport != FIT_SUB_SPORT_INVALID ) {
    rv[ "sub_sport" ] = rzfit_sub_sport_string(input: x.sub_sport)
  }
  if( x.pool_length_unit != FIT_DISPLAY_MEASURE_INVALID ) {
    rv[ "pool_length_unit" ] = rzfit_display_measure_string(input: x.pool_length_unit)
  }
  return rv
}
func rzfit_dive_settings_mesg_def_value_dict( ptr : UnsafePointer<FIT_DIVE_SETTINGS_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_DIVE_SETTINGS_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_dive_settings_mesg_def_enum_dict( ptr : UnsafePointer<FIT_DIVE_SETTINGS_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_DIVE_SETTINGS_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_monitoring_mesg_value_dict( ptr : UnsafePointer<FIT_MONITORING_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_MONITORING_MESG = ptr.pointee
  if x.timestamp != FIT_DATE_TIME_INVALID  {
    let val : Double = Double(x.timestamp)
    rv[ "timestamp" ] = val
  }
  if x.distance != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.distance))/Double(100)
    rv[ "distance" ] = val
  }
  if x.cycles != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.cycles))/Double(2)
    rv[ "cycles" ] = val
  }
  if x.active_time != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.active_time))/Double(1000)
    rv[ "active_time" ] = val
  }
  if x.local_timestamp != FIT_LOCAL_DATE_TIME_INVALID  {
    let val : Double = Double(x.local_timestamp)
    rv[ "local_timestamp" ] = val
  }
  if x.calories != FIT_UINT16_INVALID  {
    let val : Double = Double(x.calories)
    rv[ "calories" ] = val
  }
  if x.distance_16 != FIT_UINT16_INVALID  {
    let val : Double = Double(x.distance_16)
    rv[ "distance_16" ] = val
  }
  if x.cycles_16 != FIT_UINT16_INVALID  {
    let val : Double = Double(x.cycles_16)
    rv[ "cycles_16" ] = val
  }
  if x.active_time_16 != FIT_UINT16_INVALID  {
    let val : Double = Double(x.active_time_16)
    rv[ "active_time_16" ] = val
  }
  return rv
}
func rzfit_monitoring_mesg_enum_dict( ptr : UnsafePointer<FIT_MONITORING_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_MONITORING_MESG = ptr.pointee
  if( x.device_index != FIT_DEVICE_INDEX_INVALID ) {
    rv[ "device_index" ] = rzfit_device_index_string(input: x.device_index)
  }
  if( x.activity_type != FIT_ACTIVITY_TYPE_INVALID ) {
    rv[ "activity_type" ] = rzfit_activity_type_string(input: x.activity_type)
  }
  if( x.activity_subtype != FIT_ACTIVITY_SUBTYPE_INVALID ) {
    rv[ "activity_subtype" ] = rzfit_activity_subtype_string(input: x.activity_subtype)
  }
  return rv
}
func rzfit_user_profile_mesg_value_dict( ptr : UnsafePointer<FIT_USER_PROFILE_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_USER_PROFILE_MESG = ptr.pointee
  if x.message_index != FIT_MESSAGE_INDEX_INVALID  {
    let val : Double = Double(x.message_index)
    rv[ "message_index" ] = val
  }
  if x.weight != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.weight))/Double(10)
    rv[ "weight" ] = val
  }
  if x.local_id != FIT_USER_LOCAL_ID_INVALID  {
    let val : Double = Double(x.local_id)
    rv[ "local_id" ] = val
  }
  if x.user_running_step_length != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.user_running_step_length))/Double(1000)
    rv[ "user_running_step_length" ] = val
  }
  if x.user_walking_step_length != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.user_walking_step_length))/Double(1000)
    rv[ "user_walking_step_length" ] = val
  }
  if x.age != FIT_UINT8_INVALID  {
    let val : Double = Double(x.age)
    rv[ "age" ] = val
  }
  if x.height != FIT_UINT8_INVALID  {
    let val : Double = (Double(x.height))/Double(100)
    rv[ "height" ] = val
  }
  if x.resting_heart_rate != FIT_UINT8_INVALID  {
    let val : Double = Double(x.resting_heart_rate)
    rv[ "resting_heart_rate" ] = val
  }
  if x.default_max_running_heart_rate != FIT_UINT8_INVALID  {
    let val : Double = Double(x.default_max_running_heart_rate)
    rv[ "default_max_running_heart_rate" ] = val
  }
  if x.default_max_biking_heart_rate != FIT_UINT8_INVALID  {
    let val : Double = Double(x.default_max_biking_heart_rate)
    rv[ "default_max_biking_heart_rate" ] = val
  }
  if x.default_max_heart_rate != FIT_UINT8_INVALID  {
    let val : Double = Double(x.default_max_heart_rate)
    rv[ "default_max_heart_rate" ] = val
  }
  return rv
}
func rzfit_user_profile_mesg_enum_dict( ptr : UnsafePointer<FIT_USER_PROFILE_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  var x : FIT_USER_PROFILE_MESG = ptr.pointee
  rv[ "friendly_name" ] = withUnsafeBytes(of: &x.friendly_name) { (rawPtr) -> String in
    let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
    return String(cString: ptr)
  }
  if( x.gender != FIT_GENDER_INVALID ) {
    rv[ "gender" ] = rzfit_gender_string(input: x.gender)
  }
  if( x.language != FIT_LANGUAGE_INVALID ) {
    rv[ "language" ] = rzfit_language_string(input: x.language)
  }
  if( x.elev_setting != FIT_DISPLAY_MEASURE_INVALID ) {
    rv[ "elev_setting" ] = rzfit_display_measure_string(input: x.elev_setting)
  }
  if( x.weight_setting != FIT_DISPLAY_MEASURE_INVALID ) {
    rv[ "weight_setting" ] = rzfit_display_measure_string(input: x.weight_setting)
  }
  if( x.hr_setting != FIT_DISPLAY_HEART_INVALID ) {
    rv[ "hr_setting" ] = rzfit_display_heart_string(input: x.hr_setting)
  }
  if( x.speed_setting != FIT_DISPLAY_MEASURE_INVALID ) {
    rv[ "speed_setting" ] = rzfit_display_measure_string(input: x.speed_setting)
  }
  if( x.dist_setting != FIT_DISPLAY_MEASURE_INVALID ) {
    rv[ "dist_setting" ] = rzfit_display_measure_string(input: x.dist_setting)
  }
  if( x.power_setting != FIT_DISPLAY_POWER_INVALID ) {
    rv[ "power_setting" ] = rzfit_display_power_string(input: x.power_setting)
  }
  if( x.activity_class != FIT_ACTIVITY_CLASS_INVALID ) {
    rv[ "activity_class" ] = rzfit_activity_class_string(input: x.activity_class)
  }
  if( x.position_setting != FIT_DISPLAY_POSITION_INVALID ) {
    rv[ "position_setting" ] = rzfit_display_position_string(input: x.position_setting)
  }
  if( x.temperature_setting != FIT_DISPLAY_MEASURE_INVALID ) {
    rv[ "temperature_setting" ] = rzfit_display_measure_string(input: x.temperature_setting)
  }
  if( x.height_setting != FIT_DISPLAY_MEASURE_INVALID ) {
    rv[ "height_setting" ] = rzfit_display_measure_string(input: x.height_setting)
  }
  return rv
}
func rzfit_record_mesg_value_dict( ptr : UnsafePointer<FIT_RECORD_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_RECORD_MESG = ptr.pointee
  if x.timestamp != FIT_DATE_TIME_INVALID  {
    let val : Double = Double(x.timestamp)
    rv[ "timestamp" ] = val
  }
  if x.position_lat != FIT_SINT32_INVALID  {
    let val : Double = Double(x.position_lat)
    rv[ "position_lat" ] = val
  }
  if x.position_long != FIT_SINT32_INVALID  {
    let val : Double = Double(x.position_long)
    rv[ "position_long" ] = val
  }
  if x.distance != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.distance))/Double(100)
    rv[ "distance" ] = val
  }
  if x.time_from_course != FIT_SINT32_INVALID  {
    let val : Double = (Double(x.time_from_course))/Double(1000)
    rv[ "time_from_course" ] = val
  }
  if x.total_cycles != FIT_UINT32_INVALID  {
    let val : Double = Double(x.total_cycles)
    rv[ "total_cycles" ] = val
  }
  if x.accumulated_power != FIT_UINT32_INVALID  {
    let val : Double = Double(x.accumulated_power)
    rv[ "accumulated_power" ] = val
  }
  if x.enhanced_speed != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.enhanced_speed))/Double(1000)
    rv[ "enhanced_speed" ] = val
  }
  if x.enhanced_altitude != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.enhanced_altitude)-Double(500))/Double(5)
    rv[ "enhanced_altitude" ] = val
  }
  if x.altitude != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.altitude)-Double(500))/Double(5)
    rv[ "altitude" ] = val
  }
  if x.speed != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.speed))/Double(1000)
    rv[ "speed" ] = val
  }
  if x.power != FIT_UINT16_INVALID  {
    let val : Double = Double(x.power)
    rv[ "power" ] = val
  }
  if x.grade != FIT_SINT16_INVALID  {
    let val : Double = (Double(x.grade))/Double(100)
    rv[ "grade" ] = val
  }
  if x.compressed_accumulated_power != FIT_UINT16_INVALID  {
    let val : Double = Double(x.compressed_accumulated_power)
    rv[ "compressed_accumulated_power" ] = val
  }
  if x.vertical_speed != FIT_SINT16_INVALID  {
    let val : Double = (Double(x.vertical_speed))/Double(1000)
    rv[ "vertical_speed" ] = val
  }
  if x.calories != FIT_UINT16_INVALID  {
    let val : Double = Double(x.calories)
    rv[ "calories" ] = val
  }
  if x.vertical_oscillation != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.vertical_oscillation))/Double(10)
    rv[ "vertical_oscillation" ] = val
  }
  if x.stance_time_percent != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.stance_time_percent))/Double(100)
    rv[ "stance_time_percent" ] = val
  }
  if x.stance_time != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.stance_time))/Double(10)
    rv[ "stance_time" ] = val
  }
  if x.ball_speed != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.ball_speed))/Double(100)
    rv[ "ball_speed" ] = val
  }
  if x.cadence256 != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.cadence256))/Double(256)
    rv[ "cadence256" ] = val
  }
  if x.total_hemoglobin_conc != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.total_hemoglobin_conc))/Double(100)
    rv[ "total_hemoglobin_conc" ] = val
  }
  if x.total_hemoglobin_conc_min != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.total_hemoglobin_conc_min))/Double(100)
    rv[ "total_hemoglobin_conc_min" ] = val
  }
  if x.total_hemoglobin_conc_max != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.total_hemoglobin_conc_max))/Double(100)
    rv[ "total_hemoglobin_conc_max" ] = val
  }
  if x.saturated_hemoglobin_percent != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.saturated_hemoglobin_percent))/Double(10)
    rv[ "saturated_hemoglobin_percent" ] = val
  }
  if x.saturated_hemoglobin_percent_min != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.saturated_hemoglobin_percent_min))/Double(10)
    rv[ "saturated_hemoglobin_percent_min" ] = val
  }
  if x.saturated_hemoglobin_percent_max != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.saturated_hemoglobin_percent_max))/Double(10)
    rv[ "saturated_hemoglobin_percent_max" ] = val
  }
  if x.heart_rate != FIT_UINT8_INVALID  {
    let val : Double = Double(x.heart_rate)
    rv[ "heart_rate" ] = val
  }
  if x.cadence != FIT_UINT8_INVALID  {
    let val : Double = Double(x.cadence)
    rv[ "cadence" ] = val
  }
  if x.resistance != FIT_UINT8_INVALID  {
    let val : Double = Double(x.resistance)
    rv[ "resistance" ] = val
  }
  if x.cycle_length != FIT_UINT8_INVALID  {
    let val : Double = (Double(x.cycle_length))/Double(100)
    rv[ "cycle_length" ] = val
  }
  if x.temperature != FIT_SINT8_INVALID  {
    let val : Double = Double(x.temperature)
    rv[ "temperature" ] = val
  }
  if x.cycles != FIT_UINT8_INVALID  {
    let val : Double = Double(x.cycles)
    rv[ "cycles" ] = val
  }
  if x.left_right_balance != FIT_LEFT_RIGHT_BALANCE_INVALID  {
    let val : Double = Double(x.left_right_balance)
    rv[ "left_right_balance" ] = val
  }
  if x.gps_accuracy != FIT_UINT8_INVALID  {
    let val : Double = Double(x.gps_accuracy)
    rv[ "gps_accuracy" ] = val
  }
  if x.left_torque_effectiveness != FIT_UINT8_INVALID  {
    let val : Double = (Double(x.left_torque_effectiveness))/Double(2)
    rv[ "left_torque_effectiveness" ] = val
  }
  if x.right_torque_effectiveness != FIT_UINT8_INVALID  {
    let val : Double = (Double(x.right_torque_effectiveness))/Double(2)
    rv[ "right_torque_effectiveness" ] = val
  }
  if x.left_pedal_smoothness != FIT_UINT8_INVALID  {
    let val : Double = (Double(x.left_pedal_smoothness))/Double(2)
    rv[ "left_pedal_smoothness" ] = val
  }
  if x.right_pedal_smoothness != FIT_UINT8_INVALID  {
    let val : Double = (Double(x.right_pedal_smoothness))/Double(2)
    rv[ "right_pedal_smoothness" ] = val
  }
  if x.combined_pedal_smoothness != FIT_UINT8_INVALID  {
    let val : Double = (Double(x.combined_pedal_smoothness))/Double(2)
    rv[ "combined_pedal_smoothness" ] = val
  }
  if x.time128 != FIT_UINT8_INVALID  {
    let val : Double = (Double(x.time128))/Double(128)
    rv[ "time128" ] = val
  }
  if x.zone != FIT_UINT8_INVALID  {
    let val : Double = Double(x.zone)
    rv[ "zone" ] = val
  }
  if x.fractional_cadence != FIT_UINT8_INVALID  {
    let val : Double = (Double(x.fractional_cadence))/Double(128)
    rv[ "fractional_cadence" ] = val
  }
  return rv
}
func rzfit_record_mesg_enum_dict( ptr : UnsafePointer<FIT_RECORD_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_RECORD_MESG = ptr.pointee
  if( x.activity_type != FIT_ACTIVITY_TYPE_INVALID ) {
    rv[ "activity_type" ] = rzfit_activity_type_string(input: x.activity_type)
  }
  if( x.stroke_type != FIT_STROKE_TYPE_INVALID ) {
    rv[ "stroke_type" ] = rzfit_stroke_type_string(input: x.stroke_type)
  }
  if( x.device_index != FIT_DEVICE_INDEX_INVALID ) {
    rv[ "device_index" ] = rzfit_device_index_string(input: x.device_index)
  }
  return rv
}
func rzfit_connectivity_mesg_value_dict( ptr : UnsafePointer<FIT_CONNECTIVITY_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_CONNECTIVITY_MESG = ptr.pointee
  if x.bluetooth_enabled != FIT_BOOL_INVALID  {
    let val : Double = Double(x.bluetooth_enabled)
    rv[ "bluetooth_enabled" ] = val
  }
  if x.bluetooth_le_enabled != FIT_BOOL_INVALID  {
    let val : Double = Double(x.bluetooth_le_enabled)
    rv[ "bluetooth_le_enabled" ] = val
  }
  if x.ant_enabled != FIT_BOOL_INVALID  {
    let val : Double = Double(x.ant_enabled)
    rv[ "ant_enabled" ] = val
  }
  if x.live_tracking_enabled != FIT_BOOL_INVALID  {
    let val : Double = Double(x.live_tracking_enabled)
    rv[ "live_tracking_enabled" ] = val
  }
  if x.weather_conditions_enabled != FIT_BOOL_INVALID  {
    let val : Double = Double(x.weather_conditions_enabled)
    rv[ "weather_conditions_enabled" ] = val
  }
  if x.weather_alerts_enabled != FIT_BOOL_INVALID  {
    let val : Double = Double(x.weather_alerts_enabled)
    rv[ "weather_alerts_enabled" ] = val
  }
  if x.auto_activity_upload_enabled != FIT_BOOL_INVALID  {
    let val : Double = Double(x.auto_activity_upload_enabled)
    rv[ "auto_activity_upload_enabled" ] = val
  }
  if x.course_download_enabled != FIT_BOOL_INVALID  {
    let val : Double = Double(x.course_download_enabled)
    rv[ "course_download_enabled" ] = val
  }
  if x.workout_download_enabled != FIT_BOOL_INVALID  {
    let val : Double = Double(x.workout_download_enabled)
    rv[ "workout_download_enabled" ] = val
  }
  if x.gps_ephemeris_download_enabled != FIT_BOOL_INVALID  {
    let val : Double = Double(x.gps_ephemeris_download_enabled)
    rv[ "gps_ephemeris_download_enabled" ] = val
  }
  if x.incident_detection_enabled != FIT_BOOL_INVALID  {
    let val : Double = Double(x.incident_detection_enabled)
    rv[ "incident_detection_enabled" ] = val
  }
  if x.grouptrack_enabled != FIT_BOOL_INVALID  {
    let val : Double = Double(x.grouptrack_enabled)
    rv[ "grouptrack_enabled" ] = val
  }
  return rv
}
func rzfit_connectivity_mesg_enum_dict( ptr : UnsafePointer<FIT_CONNECTIVITY_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  var x : FIT_CONNECTIVITY_MESG = ptr.pointee
  rv[ "name" ] = withUnsafeBytes(of: &x.name) { (rawPtr) -> String in
    let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
    return String(cString: ptr)
  }
  return rv
}
func rzfit_field_description_mesg_value_dict( ptr : UnsafePointer<FIT_FIELD_DESCRIPTION_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_FIELD_DESCRIPTION_MESG = ptr.pointee
  if x.developer_data_index != FIT_UINT8_INVALID  {
    let val : Double = Double(x.developer_data_index)
    rv[ "developer_data_index" ] = val
  }
  if x.field_definition_number != FIT_UINT8_INVALID  {
    let val : Double = Double(x.field_definition_number)
    rv[ "field_definition_number" ] = val
  }
  if x.scale != FIT_UINT8_INVALID  {
    let val : Double = Double(x.scale)
    rv[ "scale" ] = val
  }
  if x.offset != FIT_SINT8_INVALID  {
    let val : Double = Double(x.offset)
    rv[ "offset" ] = val
  }
  if x.native_field_num != FIT_UINT8_INVALID  {
    let val : Double = Double(x.native_field_num)
    rv[ "native_field_num" ] = val
  }
  return rv
}
func rzfit_field_description_mesg_enum_dict( ptr : UnsafePointer<FIT_FIELD_DESCRIPTION_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  var x : FIT_FIELD_DESCRIPTION_MESG = ptr.pointee
  rv[ "field_name" ] = withUnsafeBytes(of: &x.field_name) { (rawPtr) -> String in
    let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
    return String(cString: ptr)
  }
  rv[ "units" ] = withUnsafeBytes(of: &x.units) { (rawPtr) -> String in
    let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
    return String(cString: ptr)
  }
  if( x.fit_base_unit_id != FIT_FIT_BASE_UNIT_INVALID ) {
    rv[ "fit_base_unit_id" ] = rzfit_fit_base_unit_string(input: x.fit_base_unit_id)
  }
  if( x.native_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "native_mesg_num" ] = rzfit_mesg_num_string(input: x.native_mesg_num)
  }
  if( x.fit_base_type_id != FIT_FIT_BASE_TYPE_INVALID ) {
    rv[ "fit_base_type_id" ] = rzfit_fit_base_type_string(input: x.fit_base_type_id)
  }
  return rv
}
func rzfit_ant_tx_mesg_value_dict( ptr : UnsafePointer<FIT_ANT_TX_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_ANT_TX_MESG = ptr.pointee
  if x.timestamp != FIT_DATE_TIME_INVALID  {
    let val : Double = Double(x.timestamp)
    rv[ "timestamp" ] = val
  }
  if x.fractional_timestamp != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.fractional_timestamp))/Double(32768)
    rv[ "fractional_timestamp" ] = val
  }
  if x.mesg_id != FIT_BYTE_INVALID  {
    let val : Double = Double(x.mesg_id)
    rv[ "mesg_id" ] = val
  }
  if x.channel_number != FIT_UINT8_INVALID  {
    let val : Double = Double(x.channel_number)
    rv[ "channel_number" ] = val
  }
  return rv
}
func rzfit_ant_tx_mesg_enum_dict( ptr : UnsafePointer<FIT_ANT_TX_MESG>) -> [String:String] {
  return [:]
}
func rzfit_segment_id_mesg_def_value_dict( ptr : UnsafePointer<FIT_SEGMENT_ID_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_SEGMENT_ID_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_segment_id_mesg_def_enum_dict( ptr : UnsafePointer<FIT_SEGMENT_ID_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_SEGMENT_ID_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_segment_leaderboard_entry_mesg_def_value_dict( ptr : UnsafePointer<FIT_SEGMENT_LEADERBOARD_ENTRY_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_SEGMENT_LEADERBOARD_ENTRY_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_segment_leaderboard_entry_mesg_def_enum_dict( ptr : UnsafePointer<FIT_SEGMENT_LEADERBOARD_ENTRY_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_SEGMENT_LEADERBOARD_ENTRY_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_nmea_sentence_mesg_value_dict( ptr : UnsafePointer<FIT_NMEA_SENTENCE_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_NMEA_SENTENCE_MESG = ptr.pointee
  if x.timestamp != FIT_DATE_TIME_INVALID  {
    let val : Double = Double(x.timestamp)
    rv[ "timestamp" ] = val
  }
  if x.timestamp_ms != FIT_UINT16_INVALID  {
    let val : Double = Double(x.timestamp_ms)
    rv[ "timestamp_ms" ] = val
  }
  return rv
}
func rzfit_nmea_sentence_mesg_enum_dict( ptr : UnsafePointer<FIT_NMEA_SENTENCE_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  var x : FIT_NMEA_SENTENCE_MESG = ptr.pointee
  rv[ "sentence" ] = withUnsafeBytes(of: &x.sentence) { (rawPtr) -> String in
    let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
    return String(cString: ptr)
  }
  return rv
}
func rzfit_workout_step_mesg_value_dict( ptr : UnsafePointer<FIT_WORKOUT_STEP_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_WORKOUT_STEP_MESG = ptr.pointee
  if x.duration_value != FIT_UINT32_INVALID  {
    let val : Double = Double(x.duration_value)
    rv[ "duration_value" ] = val
  }
  if x.target_value != FIT_UINT32_INVALID  {
    let val : Double = Double(x.target_value)
    rv[ "target_value" ] = val
  }
  if x.custom_target_value_low != FIT_UINT32_INVALID  {
    let val : Double = Double(x.custom_target_value_low)
    rv[ "custom_target_value_low" ] = val
  }
  if x.custom_target_value_high != FIT_UINT32_INVALID  {
    let val : Double = Double(x.custom_target_value_high)
    rv[ "custom_target_value_high" ] = val
  }
  if x.message_index != FIT_MESSAGE_INDEX_INVALID  {
    let val : Double = Double(x.message_index)
    rv[ "message_index" ] = val
  }
  return rv
}
func rzfit_workout_step_mesg_enum_dict( ptr : UnsafePointer<FIT_WORKOUT_STEP_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  var x : FIT_WORKOUT_STEP_MESG = ptr.pointee
  rv[ "wkt_step_name" ] = withUnsafeBytes(of: &x.wkt_step_name) { (rawPtr) -> String in
    let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
    return String(cString: ptr)
  }
  if( x.exercise_category != FIT_EXERCISE_CATEGORY_INVALID ) {
    rv[ "exercise_category" ] = rzfit_exercise_category_string(input: x.exercise_category)
  }
  if( x.duration_type != FIT_WKT_STEP_DURATION_INVALID ) {
    rv[ "duration_type" ] = rzfit_wkt_step_duration_string(input: x.duration_type)
  }
  if( x.target_type != FIT_WKT_STEP_TARGET_INVALID ) {
    rv[ "target_type" ] = rzfit_wkt_step_target_string(input: x.target_type)
  }
  if( x.intensity != FIT_INTENSITY_INVALID ) {
    rv[ "intensity" ] = rzfit_intensity_string(input: x.intensity)
  }
  rv[ "notes" ] = withUnsafeBytes(of: &x.notes) { (rawPtr) -> String in
    let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
    return String(cString: ptr)
  }
  if( x.equipment != FIT_WORKOUT_EQUIPMENT_INVALID ) {
    rv[ "equipment" ] = rzfit_workout_equipment_string(input: x.equipment)
  }
  return rv
}
func rzfit_session_mesg_value_dict( ptr : UnsafePointer<FIT_SESSION_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_SESSION_MESG = ptr.pointee
  if x.timestamp != FIT_DATE_TIME_INVALID  {
    let val : Double = Double(x.timestamp)
    rv[ "timestamp" ] = val
  }
  if x.start_time != FIT_DATE_TIME_INVALID  {
    let val : Double = Double(x.start_time)
    rv[ "start_time" ] = val
  }
  if x.start_position_lat != FIT_SINT32_INVALID  {
    let val : Double = Double(x.start_position_lat)
    rv[ "start_position_lat" ] = val
  }
  if x.start_position_long != FIT_SINT32_INVALID  {
    let val : Double = Double(x.start_position_long)
    rv[ "start_position_long" ] = val
  }
  if x.total_elapsed_time != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.total_elapsed_time))/Double(1000)
    rv[ "total_elapsed_time" ] = val
  }
  if x.total_timer_time != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.total_timer_time))/Double(1000)
    rv[ "total_timer_time" ] = val
  }
  if x.total_distance != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.total_distance))/Double(100)
    rv[ "total_distance" ] = val
  }
  if x.total_cycles != FIT_UINT32_INVALID  {
    let val : Double = Double(x.total_cycles)
    rv[ "total_cycles" ] = val
  }
  if x.nec_lat != FIT_SINT32_INVALID  {
    let val : Double = Double(x.nec_lat)
    rv[ "nec_lat" ] = val
  }
  if x.nec_long != FIT_SINT32_INVALID  {
    let val : Double = Double(x.nec_long)
    rv[ "nec_long" ] = val
  }
  if x.swc_lat != FIT_SINT32_INVALID  {
    let val : Double = Double(x.swc_lat)
    rv[ "swc_lat" ] = val
  }
  if x.swc_long != FIT_SINT32_INVALID  {
    let val : Double = Double(x.swc_long)
    rv[ "swc_long" ] = val
  }
  if x.avg_stroke_count != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.avg_stroke_count))/Double(10)
    rv[ "avg_stroke_count" ] = val
  }
  if x.total_work != FIT_UINT32_INVALID  {
    let val : Double = Double(x.total_work)
    rv[ "total_work" ] = val
  }
  if x.total_moving_time != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.total_moving_time))/Double(1000)
    rv[ "total_moving_time" ] = val
  }
  if x.time_in_hr_zone != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.time_in_hr_zone))/Double(1000)
    rv[ "time_in_hr_zone" ] = val
  }
  if x.time_in_speed_zone != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.time_in_speed_zone))/Double(1000)
    rv[ "time_in_speed_zone" ] = val
  }
  if x.time_in_cadence_zone != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.time_in_cadence_zone))/Double(1000)
    rv[ "time_in_cadence_zone" ] = val
  }
  if x.time_in_power_zone != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.time_in_power_zone))/Double(1000)
    rv[ "time_in_power_zone" ] = val
  }
  if x.avg_lap_time != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.avg_lap_time))/Double(1000)
    rv[ "avg_lap_time" ] = val
  }
  if x.enhanced_avg_speed != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.enhanced_avg_speed))/Double(1000)
    rv[ "enhanced_avg_speed" ] = val
  }
  if x.enhanced_max_speed != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.enhanced_max_speed))/Double(1000)
    rv[ "enhanced_max_speed" ] = val
  }
  if x.enhanced_avg_altitude != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.enhanced_avg_altitude)-Double(500))/Double(5)
    rv[ "enhanced_avg_altitude" ] = val
  }
  if x.enhanced_min_altitude != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.enhanced_min_altitude)-Double(500))/Double(5)
    rv[ "enhanced_min_altitude" ] = val
  }
  if x.enhanced_max_altitude != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.enhanced_max_altitude)-Double(500))/Double(5)
    rv[ "enhanced_max_altitude" ] = val
  }
  if x.message_index != FIT_MESSAGE_INDEX_INVALID  {
    let val : Double = Double(x.message_index)
    rv[ "message_index" ] = val
  }
  if x.total_calories != FIT_UINT16_INVALID  {
    let val : Double = Double(x.total_calories)
    rv[ "total_calories" ] = val
  }
  if x.total_fat_calories != FIT_UINT16_INVALID  {
    let val : Double = Double(x.total_fat_calories)
    rv[ "total_fat_calories" ] = val
  }
  if x.avg_speed != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.avg_speed))/Double(1000)
    rv[ "avg_speed" ] = val
  }
  if x.max_speed != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.max_speed))/Double(1000)
    rv[ "max_speed" ] = val
  }
  if x.avg_power != FIT_UINT16_INVALID  {
    let val : Double = Double(x.avg_power)
    rv[ "avg_power" ] = val
  }
  if x.max_power != FIT_UINT16_INVALID  {
    let val : Double = Double(x.max_power)
    rv[ "max_power" ] = val
  }
  if x.total_ascent != FIT_UINT16_INVALID  {
    let val : Double = Double(x.total_ascent)
    rv[ "total_ascent" ] = val
  }
  if x.total_descent != FIT_UINT16_INVALID  {
    let val : Double = Double(x.total_descent)
    rv[ "total_descent" ] = val
  }
  if x.first_lap_index != FIT_UINT16_INVALID  {
    let val : Double = Double(x.first_lap_index)
    rv[ "first_lap_index" ] = val
  }
  if x.num_laps != FIT_UINT16_INVALID  {
    let val : Double = Double(x.num_laps)
    rv[ "num_laps" ] = val
  }
  if x.normalized_power != FIT_UINT16_INVALID  {
    let val : Double = Double(x.normalized_power)
    rv[ "normalized_power" ] = val
  }
  if x.training_stress_score != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.training_stress_score))/Double(10)
    rv[ "training_stress_score" ] = val
  }
  if x.intensity_factor != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.intensity_factor))/Double(1000)
    rv[ "intensity_factor" ] = val
  }
  if x.left_right_balance != FIT_LEFT_RIGHT_BALANCE_100_INVALID  {
    let val : Double = Double(x.left_right_balance)
    rv[ "left_right_balance" ] = val
  }
  if x.avg_stroke_distance != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.avg_stroke_distance))/Double(100)
    rv[ "avg_stroke_distance" ] = val
  }
  if x.pool_length != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.pool_length))/Double(100)
    rv[ "pool_length" ] = val
  }
  if x.threshold_power != FIT_UINT16_INVALID  {
    let val : Double = Double(x.threshold_power)
    rv[ "threshold_power" ] = val
  }
  if x.num_active_lengths != FIT_UINT16_INVALID  {
    let val : Double = Double(x.num_active_lengths)
    rv[ "num_active_lengths" ] = val
  }
  if x.avg_altitude != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.avg_altitude)-Double(500))/Double(5)
    rv[ "avg_altitude" ] = val
  }
  if x.max_altitude != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.max_altitude)-Double(500))/Double(5)
    rv[ "max_altitude" ] = val
  }
  if x.avg_grade != FIT_SINT16_INVALID  {
    let val : Double = (Double(x.avg_grade))/Double(100)
    rv[ "avg_grade" ] = val
  }
  if x.avg_pos_grade != FIT_SINT16_INVALID  {
    let val : Double = (Double(x.avg_pos_grade))/Double(100)
    rv[ "avg_pos_grade" ] = val
  }
  if x.avg_neg_grade != FIT_SINT16_INVALID  {
    let val : Double = (Double(x.avg_neg_grade))/Double(100)
    rv[ "avg_neg_grade" ] = val
  }
  if x.max_pos_grade != FIT_SINT16_INVALID  {
    let val : Double = (Double(x.max_pos_grade))/Double(100)
    rv[ "max_pos_grade" ] = val
  }
  if x.max_neg_grade != FIT_SINT16_INVALID  {
    let val : Double = (Double(x.max_neg_grade))/Double(100)
    rv[ "max_neg_grade" ] = val
  }
  if x.avg_pos_vertical_speed != FIT_SINT16_INVALID  {
    let val : Double = (Double(x.avg_pos_vertical_speed))/Double(1000)
    rv[ "avg_pos_vertical_speed" ] = val
  }
  if x.avg_neg_vertical_speed != FIT_SINT16_INVALID  {
    let val : Double = (Double(x.avg_neg_vertical_speed))/Double(1000)
    rv[ "avg_neg_vertical_speed" ] = val
  }
  if x.max_pos_vertical_speed != FIT_SINT16_INVALID  {
    let val : Double = (Double(x.max_pos_vertical_speed))/Double(1000)
    rv[ "max_pos_vertical_speed" ] = val
  }
  if x.max_neg_vertical_speed != FIT_SINT16_INVALID  {
    let val : Double = (Double(x.max_neg_vertical_speed))/Double(1000)
    rv[ "max_neg_vertical_speed" ] = val
  }
  if x.best_lap_index != FIT_UINT16_INVALID  {
    let val : Double = Double(x.best_lap_index)
    rv[ "best_lap_index" ] = val
  }
  if x.min_altitude != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.min_altitude)-Double(500))/Double(5)
    rv[ "min_altitude" ] = val
  }
  if x.player_score != FIT_UINT16_INVALID  {
    let val : Double = Double(x.player_score)
    rv[ "player_score" ] = val
  }
  if x.opponent_score != FIT_UINT16_INVALID  {
    let val : Double = Double(x.opponent_score)
    rv[ "opponent_score" ] = val
  }
  if x.stroke_count != FIT_UINT16_INVALID  {
    let val : Double = Double(x.stroke_count)
    rv[ "stroke_count" ] = val
  }
  if x.zone_count != FIT_UINT16_INVALID  {
    let val : Double = Double(x.zone_count)
    rv[ "zone_count" ] = val
  }
  if x.max_ball_speed != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.max_ball_speed))/Double(100)
    rv[ "max_ball_speed" ] = val
  }
  if x.avg_ball_speed != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.avg_ball_speed))/Double(100)
    rv[ "avg_ball_speed" ] = val
  }
  if x.avg_vertical_oscillation != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.avg_vertical_oscillation))/Double(10)
    rv[ "avg_vertical_oscillation" ] = val
  }
  if x.avg_stance_time_percent != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.avg_stance_time_percent))/Double(100)
    rv[ "avg_stance_time_percent" ] = val
  }
  if x.avg_stance_time != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.avg_stance_time))/Double(10)
    rv[ "avg_stance_time" ] = val
  }
  if x.avg_vam != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.avg_vam))/Double(1000)
    rv[ "avg_vam" ] = val
  }
  if x.avg_heart_rate != FIT_UINT8_INVALID  {
    let val : Double = Double(x.avg_heart_rate)
    rv[ "avg_heart_rate" ] = val
  }
  if x.max_heart_rate != FIT_UINT8_INVALID  {
    let val : Double = Double(x.max_heart_rate)
    rv[ "max_heart_rate" ] = val
  }
  if x.avg_cadence != FIT_UINT8_INVALID  {
    let val : Double = Double(x.avg_cadence)
    rv[ "avg_cadence" ] = val
  }
  if x.max_cadence != FIT_UINT8_INVALID  {
    let val : Double = Double(x.max_cadence)
    rv[ "max_cadence" ] = val
  }
  if x.total_training_effect != FIT_UINT8_INVALID  {
    let val : Double = Double(x.total_training_effect)
    rv[ "total_training_effect" ] = val
  }
  if x.event_group != FIT_UINT8_INVALID  {
    let val : Double = Double(x.event_group)
    rv[ "event_group" ] = val
  }
  if x.gps_accuracy != FIT_UINT8_INVALID  {
    let val : Double = Double(x.gps_accuracy)
    rv[ "gps_accuracy" ] = val
  }
  if x.avg_temperature != FIT_SINT8_INVALID  {
    let val : Double = Double(x.avg_temperature)
    rv[ "avg_temperature" ] = val
  }
  if x.max_temperature != FIT_SINT8_INVALID  {
    let val : Double = Double(x.max_temperature)
    rv[ "max_temperature" ] = val
  }
  if x.min_heart_rate != FIT_UINT8_INVALID  {
    let val : Double = Double(x.min_heart_rate)
    rv[ "min_heart_rate" ] = val
  }
  if x.opponent_name != FIT_STRING_INVALID  {
    let val : Double = Double(x.opponent_name)
    rv[ "opponent_name" ] = val
  }
  if x.avg_fractional_cadence != FIT_UINT8_INVALID  {
    let val : Double = (Double(x.avg_fractional_cadence))/Double(128)
    rv[ "avg_fractional_cadence" ] = val
  }
  if x.max_fractional_cadence != FIT_UINT8_INVALID  {
    let val : Double = (Double(x.max_fractional_cadence))/Double(128)
    rv[ "max_fractional_cadence" ] = val
  }
  if x.total_fractional_cycles != FIT_UINT8_INVALID  {
    let val : Double = (Double(x.total_fractional_cycles))/Double(128)
    rv[ "total_fractional_cycles" ] = val
  }
  if x.sport_index != FIT_UINT8_INVALID  {
    let val : Double = Double(x.sport_index)
    rv[ "sport_index" ] = val
  }
  if x.total_anaerobic_training_effect != FIT_UINT8_INVALID  {
    let val : Double = Double(x.total_anaerobic_training_effect)
    rv[ "total_anaerobic_training_effect" ] = val
  }
  return rv
}
func rzfit_session_mesg_enum_dict( ptr : UnsafePointer<FIT_SESSION_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  var x : FIT_SESSION_MESG = ptr.pointee
  if( x.event != FIT_EVENT_INVALID ) {
    rv[ "event" ] = rzfit_event_string(input: x.event)
  }
  if( x.event_type != FIT_EVENT_TYPE_INVALID ) {
    rv[ "event_type" ] = rzfit_event_type_string(input: x.event_type)
  }
  if( x.sport != FIT_SPORT_INVALID ) {
    rv[ "sport" ] = rzfit_sport_string(input: x.sport)
  }
  if( x.sub_sport != FIT_SUB_SPORT_INVALID ) {
    rv[ "sub_sport" ] = rzfit_sub_sport_string(input: x.sub_sport)
  }
  if( x.trigger != FIT_SESSION_TRIGGER_INVALID ) {
    rv[ "trigger" ] = rzfit_session_trigger_string(input: x.trigger)
  }
  if( x.swim_stroke != FIT_SWIM_STROKE_INVALID ) {
    rv[ "swim_stroke" ] = rzfit_swim_stroke_string(input: x.swim_stroke)
  }
  if( x.pool_length_unit != FIT_DISPLAY_MEASURE_INVALID ) {
    rv[ "pool_length_unit" ] = rzfit_display_measure_string(input: x.pool_length_unit)
  }
  rv[ "opponent_name" ] = withUnsafeBytes(of: &x.opponent_name) { (rawPtr) -> String in
    let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
    return String(cString: ptr)
  }
  return rv
}
func rzfit_workout_mesg_value_dict( ptr : UnsafePointer<FIT_WORKOUT_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_WORKOUT_MESG = ptr.pointee
  if x.capabilities != FIT_WORKOUT_CAPABILITIES_INVALID  {
    let val : Double = Double(x.capabilities)
    rv[ "capabilities" ] = val
  }
  if x.num_valid_steps != FIT_UINT16_INVALID  {
    let val : Double = Double(x.num_valid_steps)
    rv[ "num_valid_steps" ] = val
  }
  if x.pool_length != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.pool_length))/Double(100)
    rv[ "pool_length" ] = val
  }
  return rv
}
func rzfit_workout_mesg_enum_dict( ptr : UnsafePointer<FIT_WORKOUT_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  var x : FIT_WORKOUT_MESG = ptr.pointee
  rv[ "wkt_name" ] = withUnsafeBytes(of: &x.wkt_name) { (rawPtr) -> String in
    let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
    return String(cString: ptr)
  }
  if( x.sport != FIT_SPORT_INVALID ) {
    rv[ "sport" ] = rzfit_sport_string(input: x.sport)
  }
  if( x.sub_sport != FIT_SUB_SPORT_INVALID ) {
    rv[ "sub_sport" ] = rzfit_sub_sport_string(input: x.sub_sport)
  }
  if( x.pool_length_unit != FIT_DISPLAY_MEASURE_INVALID ) {
    rv[ "pool_length_unit" ] = rzfit_display_measure_string(input: x.pool_length_unit)
  }
  return rv
}
func rzfit_hr_zone_mesg_value_dict( ptr : UnsafePointer<FIT_HR_ZONE_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_HR_ZONE_MESG = ptr.pointee
  if x.message_index != FIT_MESSAGE_INDEX_INVALID  {
    let val : Double = Double(x.message_index)
    rv[ "message_index" ] = val
  }
  if x.high_bpm != FIT_UINT8_INVALID  {
    let val : Double = Double(x.high_bpm)
    rv[ "high_bpm" ] = val
  }
  return rv
}
func rzfit_hr_zone_mesg_enum_dict( ptr : UnsafePointer<FIT_HR_ZONE_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  var x : FIT_HR_ZONE_MESG = ptr.pointee
  rv[ "name" ] = withUnsafeBytes(of: &x.name) { (rawPtr) -> String in
    let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
    return String(cString: ptr)
  }
  return rv
}
func rzfit_power_zone_mesg_def_value_dict( ptr : UnsafePointer<FIT_POWER_ZONE_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_POWER_ZONE_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_power_zone_mesg_def_enum_dict( ptr : UnsafePointer<FIT_POWER_ZONE_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_POWER_ZONE_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_exd_data_field_configuration_mesg_def_value_dict( ptr : UnsafePointer<FIT_EXD_DATA_FIELD_CONFIGURATION_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_EXD_DATA_FIELD_CONFIGURATION_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_exd_data_field_configuration_mesg_def_enum_dict( ptr : UnsafePointer<FIT_EXD_DATA_FIELD_CONFIGURATION_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_EXD_DATA_FIELD_CONFIGURATION_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_slave_device_mesg_def_value_dict( ptr : UnsafePointer<FIT_SLAVE_DEVICE_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_SLAVE_DEVICE_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_slave_device_mesg_def_enum_dict( ptr : UnsafePointer<FIT_SLAVE_DEVICE_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_SLAVE_DEVICE_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_blood_pressure_mesg_value_dict( ptr : UnsafePointer<FIT_BLOOD_PRESSURE_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_BLOOD_PRESSURE_MESG = ptr.pointee
  if x.timestamp != FIT_DATE_TIME_INVALID  {
    let val : Double = Double(x.timestamp)
    rv[ "timestamp" ] = val
  }
  if x.systolic_pressure != FIT_UINT16_INVALID  {
    let val : Double = Double(x.systolic_pressure)
    rv[ "systolic_pressure" ] = val
  }
  if x.diastolic_pressure != FIT_UINT16_INVALID  {
    let val : Double = Double(x.diastolic_pressure)
    rv[ "diastolic_pressure" ] = val
  }
  if x.mean_arterial_pressure != FIT_UINT16_INVALID  {
    let val : Double = Double(x.mean_arterial_pressure)
    rv[ "mean_arterial_pressure" ] = val
  }
  if x.map_3_sample_mean != FIT_UINT16_INVALID  {
    let val : Double = Double(x.map_3_sample_mean)
    rv[ "map_3_sample_mean" ] = val
  }
  if x.map_morning_values != FIT_UINT16_INVALID  {
    let val : Double = Double(x.map_morning_values)
    rv[ "map_morning_values" ] = val
  }
  if x.map_evening_values != FIT_UINT16_INVALID  {
    let val : Double = Double(x.map_evening_values)
    rv[ "map_evening_values" ] = val
  }
  if x.user_profile_index != FIT_MESSAGE_INDEX_INVALID  {
    let val : Double = Double(x.user_profile_index)
    rv[ "user_profile_index" ] = val
  }
  if x.heart_rate != FIT_UINT8_INVALID  {
    let val : Double = Double(x.heart_rate)
    rv[ "heart_rate" ] = val
  }
  return rv
}
func rzfit_blood_pressure_mesg_enum_dict( ptr : UnsafePointer<FIT_BLOOD_PRESSURE_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_BLOOD_PRESSURE_MESG = ptr.pointee
  if( x.heart_rate_type != FIT_HR_TYPE_INVALID ) {
    rv[ "heart_rate_type" ] = rzfit_hr_type_string(input: x.heart_rate_type)
  }
  if( x.status != FIT_BP_STATUS_INVALID ) {
    rv[ "status" ] = rzfit_bp_status_string(input: x.status)
  }
  return rv
}
func rzfit_met_zone_mesg_value_dict( ptr : UnsafePointer<FIT_MET_ZONE_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_MET_ZONE_MESG = ptr.pointee
  if x.message_index != FIT_MESSAGE_INDEX_INVALID  {
    let val : Double = Double(x.message_index)
    rv[ "message_index" ] = val
  }
  if x.calories != FIT_UINT16_INVALID  {
    let val : Double = Double(x.calories)
    rv[ "calories" ] = val
  }
  if x.high_bpm != FIT_UINT8_INVALID  {
    let val : Double = Double(x.high_bpm)
    rv[ "high_bpm" ] = val
  }
  if x.fat_calories != FIT_UINT8_INVALID  {
    let val : Double = Double(x.fat_calories)
    rv[ "fat_calories" ] = val
  }
  return rv
}
func rzfit_met_zone_mesg_enum_dict( ptr : UnsafePointer<FIT_MET_ZONE_MESG>) -> [String:String] {
  return [:]
}
func rzfit_segment_file_mesg_def_value_dict( ptr : UnsafePointer<FIT_SEGMENT_FILE_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_SEGMENT_FILE_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_segment_file_mesg_def_enum_dict( ptr : UnsafePointer<FIT_SEGMENT_FILE_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_SEGMENT_FILE_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_aviation_attitude_mesg_value_dict( ptr : UnsafePointer<FIT_AVIATION_ATTITUDE_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_AVIATION_ATTITUDE_MESG = ptr.pointee
  if x.timestamp != FIT_DATE_TIME_INVALID  {
    let val : Double = Double(x.timestamp)
    rv[ "timestamp" ] = val
  }
  if x.system_time != FIT_UINT32_INVALID  {
    let val : Double = Double(x.system_time)
    rv[ "system_time" ] = val
  }
  if x.timestamp_ms != FIT_UINT16_INVALID  {
    let val : Double = Double(x.timestamp_ms)
    rv[ "timestamp_ms" ] = val
  }
  if x.pitch != FIT_SINT16_INVALID  {
    let val : Double = Double(x.pitch)
    rv[ "pitch" ] = val
  }
  if x.roll != FIT_SINT16_INVALID  {
    let val : Double = Double(x.roll)
    rv[ "roll" ] = val
  }
  if x.accel_lateral != FIT_SINT16_INVALID  {
    let val : Double = (Double(x.accel_lateral))/Double(100)
    rv[ "accel_lateral" ] = val
  }
  if x.accel_normal != FIT_SINT16_INVALID  {
    let val : Double = (Double(x.accel_normal))/Double(100)
    rv[ "accel_normal" ] = val
  }
  if x.turn_rate != FIT_SINT16_INVALID  {
    let val : Double = (Double(x.turn_rate))/Double(1024)
    rv[ "turn_rate" ] = val
  }
  if x.track != FIT_UINT16_INVALID  {
    let val : Double = Double(x.track)
    rv[ "track" ] = val
  }
  if x.validity != FIT_ATTITUDE_VALIDITY_INVALID  {
    let val : Double = Double(x.validity)
    rv[ "validity" ] = val
  }
  if x.stage != FIT_ATTITUDE_STAGE_INVALID  {
    let val : Double = Double(x.stage)
    rv[ "stage" ] = val
  }
  if x.attitude_stage_complete != FIT_UINT8_INVALID  {
    let val : Double = Double(x.attitude_stage_complete)
    rv[ "attitude_stage_complete" ] = val
  }
  return rv
}
func rzfit_aviation_attitude_mesg_enum_dict( ptr : UnsafePointer<FIT_AVIATION_ATTITUDE_MESG>) -> [String:String] {
  return [:]
}
func rzfit_hrm_profile_mesg_value_dict( ptr : UnsafePointer<FIT_HRM_PROFILE_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_HRM_PROFILE_MESG = ptr.pointee
  if x.message_index != FIT_MESSAGE_INDEX_INVALID  {
    let val : Double = Double(x.message_index)
    rv[ "message_index" ] = val
  }
  if x.hrm_ant_id != FIT_UINT16Z_INVALID  {
    let val : Double = Double(x.hrm_ant_id)
    rv[ "hrm_ant_id" ] = val
  }
  if x.enabled != FIT_BOOL_INVALID  {
    let val : Double = Double(x.enabled)
    rv[ "enabled" ] = val
  }
  if x.log_hrv != FIT_BOOL_INVALID  {
    let val : Double = Double(x.log_hrv)
    rv[ "log_hrv" ] = val
  }
  if x.hrm_ant_id_trans_type != FIT_UINT8Z_INVALID  {
    let val : Double = Double(x.hrm_ant_id_trans_type)
    rv[ "hrm_ant_id_trans_type" ] = val
  }
  return rv
}
func rzfit_hrm_profile_mesg_enum_dict( ptr : UnsafePointer<FIT_HRM_PROFILE_MESG>) -> [String:String] {
  return [:]
}
func rzfit_bike_profile_mesg_def_value_dict( ptr : UnsafePointer<FIT_BIKE_PROFILE_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_BIKE_PROFILE_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_bike_profile_mesg_def_enum_dict( ptr : UnsafePointer<FIT_BIKE_PROFILE_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_BIKE_PROFILE_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_zones_target_mesg_value_dict( ptr : UnsafePointer<FIT_ZONES_TARGET_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_ZONES_TARGET_MESG = ptr.pointee
  if x.functional_threshold_power != FIT_UINT16_INVALID  {
    let val : Double = Double(x.functional_threshold_power)
    rv[ "functional_threshold_power" ] = val
  }
  if x.max_heart_rate != FIT_UINT8_INVALID  {
    let val : Double = Double(x.max_heart_rate)
    rv[ "max_heart_rate" ] = val
  }
  if x.threshold_heart_rate != FIT_UINT8_INVALID  {
    let val : Double = Double(x.threshold_heart_rate)
    rv[ "threshold_heart_rate" ] = val
  }
  return rv
}
func rzfit_zones_target_mesg_enum_dict( ptr : UnsafePointer<FIT_ZONES_TARGET_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_ZONES_TARGET_MESG = ptr.pointee
  if( x.hr_calc_type != FIT_HR_ZONE_CALC_INVALID ) {
    rv[ "hr_calc_type" ] = rzfit_hr_zone_calc_string(input: x.hr_calc_type)
  }
  if( x.pwr_calc_type != FIT_PWR_ZONE_CALC_INVALID ) {
    rv[ "pwr_calc_type" ] = rzfit_pwr_zone_calc_string(input: x.pwr_calc_type)
  }
  return rv
}
func rzfit_exd_data_concept_configuration_mesg_value_dict( ptr : UnsafePointer<FIT_EXD_DATA_CONCEPT_CONFIGURATION_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_EXD_DATA_CONCEPT_CONFIGURATION_MESG = ptr.pointee
  if x.screen_index != FIT_UINT8_INVALID  {
    let val : Double = Double(x.screen_index)
    rv[ "screen_index" ] = val
  }
  if x.concept_field != FIT_BYTE_INVALID  {
    let val : Double = Double(x.concept_field)
    rv[ "concept_field" ] = val
  }
  if x.field_id != FIT_UINT8_INVALID  {
    let val : Double = Double(x.field_id)
    rv[ "field_id" ] = val
  }
  if x.concept_index != FIT_UINT8_INVALID  {
    let val : Double = Double(x.concept_index)
    rv[ "concept_index" ] = val
  }
  if x.data_page != FIT_UINT8_INVALID  {
    let val : Double = Double(x.data_page)
    rv[ "data_page" ] = val
  }
  if x.concept_key != FIT_UINT8_INVALID  {
    let val : Double = Double(x.concept_key)
    rv[ "concept_key" ] = val
  }
  if x.scaling != FIT_UINT8_INVALID  {
    let val : Double = Double(x.scaling)
    rv[ "scaling" ] = val
  }
  if x.is_signed != FIT_BOOL_INVALID  {
    let val : Double = Double(x.is_signed)
    rv[ "is_signed" ] = val
  }
  return rv
}
func rzfit_exd_data_concept_configuration_mesg_enum_dict( ptr : UnsafePointer<FIT_EXD_DATA_CONCEPT_CONFIGURATION_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_EXD_DATA_CONCEPT_CONFIGURATION_MESG = ptr.pointee
  if( x.data_units != FIT_EXD_DATA_UNITS_INVALID ) {
    rv[ "data_units" ] = rzfit_exd_data_units_string(input: x.data_units)
  }
  if( x.qualifier != FIT_EXD_QUALIFIERS_INVALID ) {
    rv[ "qualifier" ] = rzfit_exd_qualifiers_string(input: x.qualifier)
  }
  if( x.descriptor != FIT_EXD_DESCRIPTORS_INVALID ) {
    rv[ "descriptor" ] = rzfit_exd_descriptors_string(input: x.descriptor)
  }
  return rv
}
func rzfit_workout_step_mesg_def_value_dict( ptr : UnsafePointer<FIT_WORKOUT_STEP_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_WORKOUT_STEP_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_workout_step_mesg_def_enum_dict( ptr : UnsafePointer<FIT_WORKOUT_STEP_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_WORKOUT_STEP_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_segment_point_mesg_value_dict( ptr : UnsafePointer<FIT_SEGMENT_POINT_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_SEGMENT_POINT_MESG = ptr.pointee
  if x.position_lat != FIT_SINT32_INVALID  {
    let val : Double = Double(x.position_lat)
    rv[ "position_lat" ] = val
  }
  if x.position_long != FIT_SINT32_INVALID  {
    let val : Double = Double(x.position_long)
    rv[ "position_long" ] = val
  }
  if x.distance != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.distance))/Double(100)
    rv[ "distance" ] = val
  }
  if x.leader_time != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.leader_time))/Double(1000)
    rv[ "leader_time" ] = val
  }
  if x.message_index != FIT_MESSAGE_INDEX_INVALID  {
    let val : Double = Double(x.message_index)
    rv[ "message_index" ] = val
  }
  if x.altitude != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.altitude)-Double(500))/Double(5)
    rv[ "altitude" ] = val
  }
  return rv
}
func rzfit_segment_point_mesg_enum_dict( ptr : UnsafePointer<FIT_SEGMENT_POINT_MESG>) -> [String:String] {
  return [:]
}
func rzfit_exd_screen_configuration_mesg_value_dict( ptr : UnsafePointer<FIT_EXD_SCREEN_CONFIGURATION_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_EXD_SCREEN_CONFIGURATION_MESG = ptr.pointee
  if x.screen_index != FIT_UINT8_INVALID  {
    let val : Double = Double(x.screen_index)
    rv[ "screen_index" ] = val
  }
  if x.field_count != FIT_UINT8_INVALID  {
    let val : Double = Double(x.field_count)
    rv[ "field_count" ] = val
  }
  if x.screen_enabled != FIT_BOOL_INVALID  {
    let val : Double = Double(x.screen_enabled)
    rv[ "screen_enabled" ] = val
  }
  return rv
}
func rzfit_exd_screen_configuration_mesg_enum_dict( ptr : UnsafePointer<FIT_EXD_SCREEN_CONFIGURATION_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_EXD_SCREEN_CONFIGURATION_MESG = ptr.pointee
  if( x.layout != FIT_EXD_LAYOUT_INVALID ) {
    rv[ "layout" ] = rzfit_exd_layout_string(input: x.layout)
  }
  return rv
}
func rzfit_field_convert_value_dict( ptr : UnsafePointer<FIT_FIELD_CONVERT>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_FIELD_CONVERT = ptr.pointee
  if x.base_type != FIT_UINT8_INVALID  {
    let val : Double = Double(x.base_type)
    rv[ "base_type" ] = val
  }
  if x.offset_in != FIT_UINT8_INVALID  {
    let val : Double = Double(x.offset_in)
    rv[ "offset_in" ] = val
  }
  if x.offset_local != FIT_UINT8_INVALID  {
    let val : Double = Double(x.offset_local)
    rv[ "offset_local" ] = val
  }
  if x.size != FIT_UINT8_INVALID  {
    let val : Double = Double(x.size)
    rv[ "size" ] = val
  }
  if x.num != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num)
    rv[ "num" ] = val
  }
  return rv
}
func rzfit_field_convert_enum_dict( ptr : UnsafePointer<FIT_FIELD_CONVERT>) -> [String:String] {
  return [:]
}
func rzfit_activity_mesg_value_dict( ptr : UnsafePointer<FIT_ACTIVITY_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_ACTIVITY_MESG = ptr.pointee
  if x.timestamp != FIT_DATE_TIME_INVALID  {
    let val : Double = Double(x.timestamp)
    rv[ "timestamp" ] = val
  }
  if x.total_timer_time != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.total_timer_time))/Double(1000)
    rv[ "total_timer_time" ] = val
  }
  if x.local_timestamp != FIT_LOCAL_DATE_TIME_INVALID  {
    let val : Double = Double(x.local_timestamp)
    rv[ "local_timestamp" ] = val
  }
  if x.num_sessions != FIT_UINT16_INVALID  {
    let val : Double = Double(x.num_sessions)
    rv[ "num_sessions" ] = val
  }
  if x.event_group != FIT_UINT8_INVALID  {
    let val : Double = Double(x.event_group)
    rv[ "event_group" ] = val
  }
  return rv
}
func rzfit_activity_mesg_enum_dict( ptr : UnsafePointer<FIT_ACTIVITY_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_ACTIVITY_MESG = ptr.pointee
  if( x.type != FIT_ACTIVITY_INVALID ) {
    rv[ "type" ] = rzfit_activity_string(input: x.type)
  }
  if( x.event != FIT_EVENT_INVALID ) {
    rv[ "event" ] = rzfit_event_string(input: x.event)
  }
  if( x.event_type != FIT_EVENT_TYPE_INVALID ) {
    rv[ "event_type" ] = rzfit_event_type_string(input: x.event_type)
  }
  return rv
}
func rzfit_hrm_profile_mesg_def_value_dict( ptr : UnsafePointer<FIT_HRM_PROFILE_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_HRM_PROFILE_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_hrm_profile_mesg_def_enum_dict( ptr : UnsafePointer<FIT_HRM_PROFILE_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_HRM_PROFILE_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_met_zone_mesg_def_value_dict( ptr : UnsafePointer<FIT_MET_ZONE_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_MET_ZONE_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_met_zone_mesg_def_enum_dict( ptr : UnsafePointer<FIT_MET_ZONE_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_MET_ZONE_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_set_mesg_def_value_dict( ptr : UnsafePointer<FIT_SET_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_SET_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_set_mesg_def_enum_dict( ptr : UnsafePointer<FIT_SET_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_SET_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_lap_mesg_def_value_dict( ptr : UnsafePointer<FIT_LAP_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_LAP_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_lap_mesg_def_enum_dict( ptr : UnsafePointer<FIT_LAP_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_LAP_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_dive_settings_mesg_value_dict( ptr : UnsafePointer<FIT_DIVE_SETTINGS_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_DIVE_SETTINGS_MESG = ptr.pointee
  if x.heart_rate_source != FIT_UINT8_INVALID  {
    let val : Double = Double(x.heart_rate_source)
    rv[ "heart_rate_source" ] = val
  }
  return rv
}
func rzfit_dive_settings_mesg_enum_dict( ptr : UnsafePointer<FIT_DIVE_SETTINGS_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  var x : FIT_DIVE_SETTINGS_MESG = ptr.pointee
  rv[ "name" ] = withUnsafeBytes(of: &x.name) { (rawPtr) -> String in
    let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
    return String(cString: ptr)
  }
  return rv
}
func rzfit_workout_mesg_def_value_dict( ptr : UnsafePointer<FIT_WORKOUT_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_WORKOUT_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_workout_mesg_def_enum_dict( ptr : UnsafePointer<FIT_WORKOUT_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_WORKOUT_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_training_file_mesg_value_dict( ptr : UnsafePointer<FIT_TRAINING_FILE_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_TRAINING_FILE_MESG = ptr.pointee
  if x.timestamp != FIT_DATE_TIME_INVALID  {
    let val : Double = Double(x.timestamp)
    rv[ "timestamp" ] = val
  }
  if x.serial_number != FIT_UINT32Z_INVALID  {
    let val : Double = Double(x.serial_number)
    rv[ "serial_number" ] = val
  }
  if x.time_created != FIT_DATE_TIME_INVALID  {
    let val : Double = Double(x.time_created)
    rv[ "time_created" ] = val
  }
  if x.product != FIT_UINT16_INVALID  {
    let val : Double = Double(x.product)
    rv[ "product" ] = val
  }
  return rv
}
func rzfit_training_file_mesg_enum_dict( ptr : UnsafePointer<FIT_TRAINING_FILE_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_TRAINING_FILE_MESG = ptr.pointee
  if( x.manufacturer != FIT_MANUFACTURER_INVALID ) {
    rv[ "manufacturer" ] = rzfit_manufacturer_string(input: x.manufacturer)
  }
  if( x.type != FIT_FILE_INVALID ) {
    rv[ "type" ] = rzfit_file_string(input: x.type)
  }
  return rv
}
func rzfit_developer_data_id_mesg_def_value_dict( ptr : UnsafePointer<FIT_DEVELOPER_DATA_ID_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_DEVELOPER_DATA_ID_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_developer_data_id_mesg_def_enum_dict( ptr : UnsafePointer<FIT_DEVELOPER_DATA_ID_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_DEVELOPER_DATA_ID_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_sdm_profile_mesg_value_dict( ptr : UnsafePointer<FIT_SDM_PROFILE_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_SDM_PROFILE_MESG = ptr.pointee
  if x.odometer != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.odometer))/Double(100)
    rv[ "odometer" ] = val
  }
  if x.message_index != FIT_MESSAGE_INDEX_INVALID  {
    let val : Double = Double(x.message_index)
    rv[ "message_index" ] = val
  }
  if x.sdm_ant_id != FIT_UINT16Z_INVALID  {
    let val : Double = Double(x.sdm_ant_id)
    rv[ "sdm_ant_id" ] = val
  }
  if x.sdm_cal_factor != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.sdm_cal_factor))/Double(10)
    rv[ "sdm_cal_factor" ] = val
  }
  if x.enabled != FIT_BOOL_INVALID  {
    let val : Double = Double(x.enabled)
    rv[ "enabled" ] = val
  }
  if x.speed_source != FIT_BOOL_INVALID  {
    let val : Double = Double(x.speed_source)
    rv[ "speed_source" ] = val
  }
  if x.sdm_ant_id_trans_type != FIT_UINT8Z_INVALID  {
    let val : Double = Double(x.sdm_ant_id_trans_type)
    rv[ "sdm_ant_id_trans_type" ] = val
  }
  if x.odometer_rollover != FIT_UINT8_INVALID  {
    let val : Double = Double(x.odometer_rollover)
    rv[ "odometer_rollover" ] = val
  }
  return rv
}
func rzfit_sdm_profile_mesg_enum_dict( ptr : UnsafePointer<FIT_SDM_PROFILE_MESG>) -> [String:String] {
  return [:]
}
func rzfit_event_mesg_value_dict( ptr : UnsafePointer<FIT_EVENT_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_EVENT_MESG = ptr.pointee
  if x.timestamp != FIT_DATE_TIME_INVALID  {
    let val : Double = Double(x.timestamp)
    rv[ "timestamp" ] = val
  }
  if x.data != FIT_UINT32_INVALID  {
    let val : Double = Double(x.data)
    rv[ "data" ] = val
  }
  if x.data16 != FIT_UINT16_INVALID  {
    let val : Double = Double(x.data16)
    rv[ "data16" ] = val
  }
  if x.score != FIT_UINT16_INVALID  {
    let val : Double = Double(x.score)
    rv[ "score" ] = val
  }
  if x.opponent_score != FIT_UINT16_INVALID  {
    let val : Double = Double(x.opponent_score)
    rv[ "opponent_score" ] = val
  }
  if x.event_group != FIT_UINT8_INVALID  {
    let val : Double = Double(x.event_group)
    rv[ "event_group" ] = val
  }
  if x.front_gear_num != FIT_UINT8Z_INVALID  {
    let val : Double = Double(x.front_gear_num)
    rv[ "front_gear_num" ] = val
  }
  if x.front_gear != FIT_UINT8Z_INVALID  {
    let val : Double = Double(x.front_gear)
    rv[ "front_gear" ] = val
  }
  if x.rear_gear_num != FIT_UINT8Z_INVALID  {
    let val : Double = Double(x.rear_gear_num)
    rv[ "rear_gear_num" ] = val
  }
  if x.rear_gear != FIT_UINT8Z_INVALID  {
    let val : Double = Double(x.rear_gear)
    rv[ "rear_gear" ] = val
  }
  return rv
}
func rzfit_event_mesg_enum_dict( ptr : UnsafePointer<FIT_EVENT_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_EVENT_MESG = ptr.pointee
  if( x.event != FIT_EVENT_INVALID ) {
    rv[ "event" ] = rzfit_event_string(input: x.event)
  }
  if( x.event_type != FIT_EVENT_TYPE_INVALID ) {
    rv[ "event_type" ] = rzfit_event_type_string(input: x.event_type)
  }
  return rv
}
func rzfit_segment_lap_mesg_def_value_dict( ptr : UnsafePointer<FIT_SEGMENT_LAP_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_SEGMENT_LAP_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_segment_lap_mesg_def_enum_dict( ptr : UnsafePointer<FIT_SEGMENT_LAP_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_SEGMENT_LAP_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_weather_alert_mesg_value_dict( ptr : UnsafePointer<FIT_WEATHER_ALERT_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_WEATHER_ALERT_MESG = ptr.pointee
  if x.timestamp != FIT_DATE_TIME_INVALID  {
    let val : Double = Double(x.timestamp)
    rv[ "timestamp" ] = val
  }
  if x.issue_time != FIT_DATE_TIME_INVALID  {
    let val : Double = Double(x.issue_time)
    rv[ "issue_time" ] = val
  }
  if x.expire_time != FIT_DATE_TIME_INVALID  {
    let val : Double = Double(x.expire_time)
    rv[ "expire_time" ] = val
  }
  return rv
}
func rzfit_weather_alert_mesg_enum_dict( ptr : UnsafePointer<FIT_WEATHER_ALERT_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  var x : FIT_WEATHER_ALERT_MESG = ptr.pointee
  rv[ "report_id" ] = withUnsafeBytes(of: &x.report_id) { (rawPtr) -> String in
    let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
    return String(cString: ptr)
  }
  if( x.severity != FIT_WEATHER_SEVERITY_INVALID ) {
    rv[ "severity" ] = rzfit_weather_severity_string(input: x.severity)
  }
  if( x.type != FIT_WEATHER_SEVERE_TYPE_INVALID ) {
    rv[ "type" ] = rzfit_weather_severe_type_string(input: x.type)
  }
  return rv
}
func rzfit_exd_screen_configuration_mesg_def_value_dict( ptr : UnsafePointer<FIT_EXD_SCREEN_CONFIGURATION_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_EXD_SCREEN_CONFIGURATION_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_exd_screen_configuration_mesg_def_enum_dict( ptr : UnsafePointer<FIT_EXD_SCREEN_CONFIGURATION_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_EXD_SCREEN_CONFIGURATION_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_schedule_mesg_value_dict( ptr : UnsafePointer<FIT_SCHEDULE_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_SCHEDULE_MESG = ptr.pointee
  if x.serial_number != FIT_UINT32Z_INVALID  {
    let val : Double = Double(x.serial_number)
    rv[ "serial_number" ] = val
  }
  if x.time_created != FIT_DATE_TIME_INVALID  {
    let val : Double = Double(x.time_created)
    rv[ "time_created" ] = val
  }
  if x.scheduled_time != FIT_LOCAL_DATE_TIME_INVALID  {
    let val : Double = Double(x.scheduled_time)
    rv[ "scheduled_time" ] = val
  }
  if x.product != FIT_UINT16_INVALID  {
    let val : Double = Double(x.product)
    rv[ "product" ] = val
  }
  if x.completed != FIT_BOOL_INVALID  {
    let val : Double = Double(x.completed)
    rv[ "completed" ] = val
  }
  return rv
}
func rzfit_schedule_mesg_enum_dict( ptr : UnsafePointer<FIT_SCHEDULE_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_SCHEDULE_MESG = ptr.pointee
  if( x.manufacturer != FIT_MANUFACTURER_INVALID ) {
    rv[ "manufacturer" ] = rzfit_manufacturer_string(input: x.manufacturer)
  }
  if( x.type != FIT_SCHEDULE_INVALID ) {
    rv[ "type" ] = rzfit_schedule_string(input: x.type)
  }
  return rv
}
func rzfit_session_mesg_def_value_dict( ptr : UnsafePointer<FIT_SESSION_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_SESSION_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_session_mesg_def_enum_dict( ptr : UnsafePointer<FIT_SESSION_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_SESSION_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_weather_alert_mesg_def_value_dict( ptr : UnsafePointer<FIT_WEATHER_ALERT_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_WEATHER_ALERT_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_weather_alert_mesg_def_enum_dict( ptr : UnsafePointer<FIT_WEATHER_ALERT_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_WEATHER_ALERT_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_field_description_mesg_def_value_dict( ptr : UnsafePointer<FIT_FIELD_DESCRIPTION_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_FIELD_DESCRIPTION_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_field_description_mesg_def_enum_dict( ptr : UnsafePointer<FIT_FIELD_DESCRIPTION_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_FIELD_DESCRIPTION_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_weight_scale_mesg_def_value_dict( ptr : UnsafePointer<FIT_WEIGHT_SCALE_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_WEIGHT_SCALE_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_weight_scale_mesg_def_enum_dict( ptr : UnsafePointer<FIT_WEIGHT_SCALE_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_WEIGHT_SCALE_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_connectivity_mesg_def_value_dict( ptr : UnsafePointer<FIT_CONNECTIVITY_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_CONNECTIVITY_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_connectivity_mesg_def_enum_dict( ptr : UnsafePointer<FIT_CONNECTIVITY_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_CONNECTIVITY_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_ant_tx_mesg_def_value_dict( ptr : UnsafePointer<FIT_ANT_TX_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_ANT_TX_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_ant_tx_mesg_def_enum_dict( ptr : UnsafePointer<FIT_ANT_TX_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_ANT_TX_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_speed_zone_mesg_value_dict( ptr : UnsafePointer<FIT_SPEED_ZONE_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_SPEED_ZONE_MESG = ptr.pointee
  if x.message_index != FIT_MESSAGE_INDEX_INVALID  {
    let val : Double = Double(x.message_index)
    rv[ "message_index" ] = val
  }
  if x.high_value != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.high_value))/Double(1000)
    rv[ "high_value" ] = val
  }
  return rv
}
func rzfit_speed_zone_mesg_enum_dict( ptr : UnsafePointer<FIT_SPEED_ZONE_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  var x : FIT_SPEED_ZONE_MESG = ptr.pointee
  rv[ "name" ] = withUnsafeBytes(of: &x.name) { (rawPtr) -> String in
    let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
    return String(cString: ptr)
  }
  return rv
}
func rzfit_segment_lap_mesg_value_dict( ptr : UnsafePointer<FIT_SEGMENT_LAP_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_SEGMENT_LAP_MESG = ptr.pointee
  if x.timestamp != FIT_DATE_TIME_INVALID  {
    let val : Double = Double(x.timestamp)
    rv[ "timestamp" ] = val
  }
  if x.start_time != FIT_DATE_TIME_INVALID  {
    let val : Double = Double(x.start_time)
    rv[ "start_time" ] = val
  }
  if x.start_position_lat != FIT_SINT32_INVALID  {
    let val : Double = Double(x.start_position_lat)
    rv[ "start_position_lat" ] = val
  }
  if x.start_position_long != FIT_SINT32_INVALID  {
    let val : Double = Double(x.start_position_long)
    rv[ "start_position_long" ] = val
  }
  if x.end_position_lat != FIT_SINT32_INVALID  {
    let val : Double = Double(x.end_position_lat)
    rv[ "end_position_lat" ] = val
  }
  if x.end_position_long != FIT_SINT32_INVALID  {
    let val : Double = Double(x.end_position_long)
    rv[ "end_position_long" ] = val
  }
  if x.total_elapsed_time != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.total_elapsed_time))/Double(1000)
    rv[ "total_elapsed_time" ] = val
  }
  if x.total_timer_time != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.total_timer_time))/Double(1000)
    rv[ "total_timer_time" ] = val
  }
  if x.total_distance != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.total_distance))/Double(100)
    rv[ "total_distance" ] = val
  }
  if x.total_cycles != FIT_UINT32_INVALID  {
    let val : Double = Double(x.total_cycles)
    rv[ "total_cycles" ] = val
  }
  if x.nec_lat != FIT_SINT32_INVALID  {
    let val : Double = Double(x.nec_lat)
    rv[ "nec_lat" ] = val
  }
  if x.nec_long != FIT_SINT32_INVALID  {
    let val : Double = Double(x.nec_long)
    rv[ "nec_long" ] = val
  }
  if x.swc_lat != FIT_SINT32_INVALID  {
    let val : Double = Double(x.swc_lat)
    rv[ "swc_lat" ] = val
  }
  if x.swc_long != FIT_SINT32_INVALID  {
    let val : Double = Double(x.swc_long)
    rv[ "swc_long" ] = val
  }
  if x.total_work != FIT_UINT32_INVALID  {
    let val : Double = Double(x.total_work)
    rv[ "total_work" ] = val
  }
  if x.total_moving_time != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.total_moving_time))/Double(1000)
    rv[ "total_moving_time" ] = val
  }
  if x.time_in_hr_zone != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.time_in_hr_zone))/Double(1000)
    rv[ "time_in_hr_zone" ] = val
  }
  if x.time_in_speed_zone != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.time_in_speed_zone))/Double(1000)
    rv[ "time_in_speed_zone" ] = val
  }
  if x.time_in_cadence_zone != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.time_in_cadence_zone))/Double(1000)
    rv[ "time_in_cadence_zone" ] = val
  }
  if x.time_in_power_zone != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.time_in_power_zone))/Double(1000)
    rv[ "time_in_power_zone" ] = val
  }
  if x.active_time != FIT_UINT32_INVALID  {
    let val : Double = (Double(x.active_time))/Double(1000)
    rv[ "active_time" ] = val
  }
  if x.message_index != FIT_MESSAGE_INDEX_INVALID  {
    let val : Double = Double(x.message_index)
    rv[ "message_index" ] = val
  }
  if x.total_calories != FIT_UINT16_INVALID  {
    let val : Double = Double(x.total_calories)
    rv[ "total_calories" ] = val
  }
  if x.total_fat_calories != FIT_UINT16_INVALID  {
    let val : Double = Double(x.total_fat_calories)
    rv[ "total_fat_calories" ] = val
  }
  if x.avg_speed != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.avg_speed))/Double(1000)
    rv[ "avg_speed" ] = val
  }
  if x.max_speed != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.max_speed))/Double(1000)
    rv[ "max_speed" ] = val
  }
  if x.avg_power != FIT_UINT16_INVALID  {
    let val : Double = Double(x.avg_power)
    rv[ "avg_power" ] = val
  }
  if x.max_power != FIT_UINT16_INVALID  {
    let val : Double = Double(x.max_power)
    rv[ "max_power" ] = val
  }
  if x.total_ascent != FIT_UINT16_INVALID  {
    let val : Double = Double(x.total_ascent)
    rv[ "total_ascent" ] = val
  }
  if x.total_descent != FIT_UINT16_INVALID  {
    let val : Double = Double(x.total_descent)
    rv[ "total_descent" ] = val
  }
  if x.normalized_power != FIT_UINT16_INVALID  {
    let val : Double = Double(x.normalized_power)
    rv[ "normalized_power" ] = val
  }
  if x.left_right_balance != FIT_LEFT_RIGHT_BALANCE_100_INVALID  {
    let val : Double = Double(x.left_right_balance)
    rv[ "left_right_balance" ] = val
  }
  if x.avg_altitude != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.avg_altitude)-Double(500))/Double(5)
    rv[ "avg_altitude" ] = val
  }
  if x.max_altitude != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.max_altitude)-Double(500))/Double(5)
    rv[ "max_altitude" ] = val
  }
  if x.avg_grade != FIT_SINT16_INVALID  {
    let val : Double = (Double(x.avg_grade))/Double(100)
    rv[ "avg_grade" ] = val
  }
  if x.avg_pos_grade != FIT_SINT16_INVALID  {
    let val : Double = (Double(x.avg_pos_grade))/Double(100)
    rv[ "avg_pos_grade" ] = val
  }
  if x.avg_neg_grade != FIT_SINT16_INVALID  {
    let val : Double = (Double(x.avg_neg_grade))/Double(100)
    rv[ "avg_neg_grade" ] = val
  }
  if x.max_pos_grade != FIT_SINT16_INVALID  {
    let val : Double = (Double(x.max_pos_grade))/Double(100)
    rv[ "max_pos_grade" ] = val
  }
  if x.max_neg_grade != FIT_SINT16_INVALID  {
    let val : Double = (Double(x.max_neg_grade))/Double(100)
    rv[ "max_neg_grade" ] = val
  }
  if x.avg_pos_vertical_speed != FIT_SINT16_INVALID  {
    let val : Double = (Double(x.avg_pos_vertical_speed))/Double(1000)
    rv[ "avg_pos_vertical_speed" ] = val
  }
  if x.avg_neg_vertical_speed != FIT_SINT16_INVALID  {
    let val : Double = (Double(x.avg_neg_vertical_speed))/Double(1000)
    rv[ "avg_neg_vertical_speed" ] = val
  }
  if x.max_pos_vertical_speed != FIT_SINT16_INVALID  {
    let val : Double = (Double(x.max_pos_vertical_speed))/Double(1000)
    rv[ "max_pos_vertical_speed" ] = val
  }
  if x.max_neg_vertical_speed != FIT_SINT16_INVALID  {
    let val : Double = (Double(x.max_neg_vertical_speed))/Double(1000)
    rv[ "max_neg_vertical_speed" ] = val
  }
  if x.repetition_num != FIT_UINT16_INVALID  {
    let val : Double = Double(x.repetition_num)
    rv[ "repetition_num" ] = val
  }
  if x.min_altitude != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.min_altitude)-Double(500))/Double(5)
    rv[ "min_altitude" ] = val
  }
  if x.wkt_step_index != FIT_MESSAGE_INDEX_INVALID  {
    let val : Double = Double(x.wkt_step_index)
    rv[ "wkt_step_index" ] = val
  }
  if x.front_gear_shift_count != FIT_UINT16_INVALID  {
    let val : Double = Double(x.front_gear_shift_count)
    rv[ "front_gear_shift_count" ] = val
  }
  if x.rear_gear_shift_count != FIT_UINT16_INVALID  {
    let val : Double = Double(x.rear_gear_shift_count)
    rv[ "rear_gear_shift_count" ] = val
  }
  if x.avg_heart_rate != FIT_UINT8_INVALID  {
    let val : Double = Double(x.avg_heart_rate)
    rv[ "avg_heart_rate" ] = val
  }
  if x.max_heart_rate != FIT_UINT8_INVALID  {
    let val : Double = Double(x.max_heart_rate)
    rv[ "max_heart_rate" ] = val
  }
  if x.avg_cadence != FIT_UINT8_INVALID  {
    let val : Double = Double(x.avg_cadence)
    rv[ "avg_cadence" ] = val
  }
  if x.max_cadence != FIT_UINT8_INVALID  {
    let val : Double = Double(x.max_cadence)
    rv[ "max_cadence" ] = val
  }
  if x.event_group != FIT_UINT8_INVALID  {
    let val : Double = Double(x.event_group)
    rv[ "event_group" ] = val
  }
  if x.gps_accuracy != FIT_UINT8_INVALID  {
    let val : Double = Double(x.gps_accuracy)
    rv[ "gps_accuracy" ] = val
  }
  if x.avg_temperature != FIT_SINT8_INVALID  {
    let val : Double = Double(x.avg_temperature)
    rv[ "avg_temperature" ] = val
  }
  if x.max_temperature != FIT_SINT8_INVALID  {
    let val : Double = Double(x.max_temperature)
    rv[ "max_temperature" ] = val
  }
  if x.min_heart_rate != FIT_UINT8_INVALID  {
    let val : Double = Double(x.min_heart_rate)
    rv[ "min_heart_rate" ] = val
  }
  if x.avg_left_torque_effectiveness != FIT_UINT8_INVALID  {
    let val : Double = (Double(x.avg_left_torque_effectiveness))/Double(2)
    rv[ "avg_left_torque_effectiveness" ] = val
  }
  if x.avg_right_torque_effectiveness != FIT_UINT8_INVALID  {
    let val : Double = (Double(x.avg_right_torque_effectiveness))/Double(2)
    rv[ "avg_right_torque_effectiveness" ] = val
  }
  if x.avg_left_pedal_smoothness != FIT_UINT8_INVALID  {
    let val : Double = (Double(x.avg_left_pedal_smoothness))/Double(2)
    rv[ "avg_left_pedal_smoothness" ] = val
  }
  if x.avg_right_pedal_smoothness != FIT_UINT8_INVALID  {
    let val : Double = (Double(x.avg_right_pedal_smoothness))/Double(2)
    rv[ "avg_right_pedal_smoothness" ] = val
  }
  if x.avg_combined_pedal_smoothness != FIT_UINT8_INVALID  {
    let val : Double = (Double(x.avg_combined_pedal_smoothness))/Double(2)
    rv[ "avg_combined_pedal_smoothness" ] = val
  }
  if x.avg_fractional_cadence != FIT_UINT8_INVALID  {
    let val : Double = (Double(x.avg_fractional_cadence))/Double(128)
    rv[ "avg_fractional_cadence" ] = val
  }
  if x.max_fractional_cadence != FIT_UINT8_INVALID  {
    let val : Double = (Double(x.max_fractional_cadence))/Double(128)
    rv[ "max_fractional_cadence" ] = val
  }
  if x.total_fractional_cycles != FIT_UINT8_INVALID  {
    let val : Double = (Double(x.total_fractional_cycles))/Double(128)
    rv[ "total_fractional_cycles" ] = val
  }
  return rv
}
func rzfit_segment_lap_mesg_enum_dict( ptr : UnsafePointer<FIT_SEGMENT_LAP_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  var x : FIT_SEGMENT_LAP_MESG = ptr.pointee
  rv[ "name" ] = withUnsafeBytes(of: &x.name) { (rawPtr) -> String in
    let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
    return String(cString: ptr)
  }
  if( x.event != FIT_EVENT_INVALID ) {
    rv[ "event" ] = rzfit_event_string(input: x.event)
  }
  if( x.event_type != FIT_EVENT_TYPE_INVALID ) {
    rv[ "event_type" ] = rzfit_event_type_string(input: x.event_type)
  }
  if( x.sport != FIT_SPORT_INVALID ) {
    rv[ "sport" ] = rzfit_sport_string(input: x.sport)
  }
  if( x.sub_sport != FIT_SUB_SPORT_INVALID ) {
    rv[ "sub_sport" ] = rzfit_sub_sport_string(input: x.sub_sport)
  }
  if( x.sport_event != FIT_SPORT_EVENT_INVALID ) {
    rv[ "sport_event" ] = rzfit_sport_event_string(input: x.sport_event)
  }
  if( x.status != FIT_SEGMENT_LAP_STATUS_INVALID ) {
    rv[ "status" ] = rzfit_segment_lap_status_string(input: x.status)
  }
  rv[ "uuid" ] = withUnsafeBytes(of: &x.uuid) { (rawPtr) -> String in
    let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
    return String(cString: ptr)
  }
  return rv
}
func rzfit_power_zone_mesg_value_dict( ptr : UnsafePointer<FIT_POWER_ZONE_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_POWER_ZONE_MESG = ptr.pointee
  if x.message_index != FIT_MESSAGE_INDEX_INVALID  {
    let val : Double = Double(x.message_index)
    rv[ "message_index" ] = val
  }
  if x.high_value != FIT_UINT16_INVALID  {
    let val : Double = Double(x.high_value)
    rv[ "high_value" ] = val
  }
  return rv
}
func rzfit_power_zone_mesg_enum_dict( ptr : UnsafePointer<FIT_POWER_ZONE_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  var x : FIT_POWER_ZONE_MESG = ptr.pointee
  rv[ "name" ] = withUnsafeBytes(of: &x.name) { (rawPtr) -> String in
    let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
    return String(cString: ptr)
  }
  return rv
}
func rzfit_aviation_attitude_mesg_def_value_dict( ptr : UnsafePointer<FIT_AVIATION_ATTITUDE_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_AVIATION_ATTITUDE_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_aviation_attitude_mesg_def_enum_dict( ptr : UnsafePointer<FIT_AVIATION_ATTITUDE_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_AVIATION_ATTITUDE_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_mesg_capabilities_mesg_value_dict( ptr : UnsafePointer<FIT_MESG_CAPABILITIES_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_MESG_CAPABILITIES_MESG = ptr.pointee
  if x.message_index != FIT_MESSAGE_INDEX_INVALID  {
    let val : Double = Double(x.message_index)
    rv[ "message_index" ] = val
  }
  if x.count != FIT_UINT16_INVALID  {
    let val : Double = Double(x.count)
    rv[ "count" ] = val
  }
  return rv
}
func rzfit_mesg_capabilities_mesg_enum_dict( ptr : UnsafePointer<FIT_MESG_CAPABILITIES_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_MESG_CAPABILITIES_MESG = ptr.pointee
  if( x.mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "mesg_num" ] = rzfit_mesg_num_string(input: x.mesg_num)
  }
  if( x.file != FIT_FILE_INVALID ) {
    rv[ "file" ] = rzfit_file_string(input: x.file)
  }
  if( x.count_type != FIT_MESG_COUNT_INVALID ) {
    rv[ "count_type" ] = rzfit_mesg_count_string(input: x.count_type)
  }
  return rv
}
func rzfit_pad_mesg_def_value_dict( ptr : UnsafePointer<FIT_PAD_MESG_DEF>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_PAD_MESG_DEF = ptr.pointee
  if x.reserved_1 != FIT_UINT8_INVALID  {
    let val : Double = Double(x.reserved_1)
    rv[ "reserved_1" ] = val
  }
  if x.arch != FIT_UINT8_INVALID  {
    let val : Double = Double(x.arch)
    rv[ "arch" ] = val
  }
  if x.num_fields != FIT_UINT8_INVALID  {
    let val : Double = Double(x.num_fields)
    rv[ "num_fields" ] = val
  }
  return rv
}
func rzfit_pad_mesg_def_enum_dict( ptr : UnsafePointer<FIT_PAD_MESG_DEF>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_PAD_MESG_DEF = ptr.pointee
  if( x.global_mesg_num != FIT_MESG_NUM_INVALID ) {
    rv[ "global_mesg_num" ] = rzfit_mesg_num_string(input: x.global_mesg_num)
  }
  return rv
}
func rzfit_build_mesg(num : FIT_MESG_NUM, uptr : UnsafePointer<UInt8>) -> RZFitMessage?{
    var rv : RZFitMessage? = nil
    switch num {
  case FIT_MESG_NUM_FILE_ID:
    uptr.withMemoryRebound(to: FIT_FILE_ID_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_FILE_ID,
                         mesg_values: rzfit_file_id_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_file_id_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_CAPABILITIES:
    uptr.withMemoryRebound(to: FIT_CAPABILITIES_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_CAPABILITIES,
                         mesg_values: rzfit_capabilities_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_capabilities_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_DEVICE_SETTINGS:
    uptr.withMemoryRebound(to: FIT_DEVICE_SETTINGS_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_DEVICE_SETTINGS,
                         mesg_values: rzfit_device_settings_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_device_settings_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_USER_PROFILE:
    uptr.withMemoryRebound(to: FIT_USER_PROFILE_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_USER_PROFILE,
                         mesg_values: rzfit_user_profile_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_user_profile_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_HRM_PROFILE:
    uptr.withMemoryRebound(to: FIT_HRM_PROFILE_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_HRM_PROFILE,
                         mesg_values: rzfit_hrm_profile_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_hrm_profile_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_SDM_PROFILE:
    uptr.withMemoryRebound(to: FIT_SDM_PROFILE_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_SDM_PROFILE,
                         mesg_values: rzfit_sdm_profile_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_sdm_profile_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_BIKE_PROFILE:
    uptr.withMemoryRebound(to: FIT_BIKE_PROFILE_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_BIKE_PROFILE,
                         mesg_values: rzfit_bike_profile_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_bike_profile_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_ZONES_TARGET:
    uptr.withMemoryRebound(to: FIT_ZONES_TARGET_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_ZONES_TARGET,
                         mesg_values: rzfit_zones_target_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_zones_target_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_HR_ZONE:
    uptr.withMemoryRebound(to: FIT_HR_ZONE_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_HR_ZONE,
                         mesg_values: rzfit_hr_zone_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_hr_zone_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_POWER_ZONE:
    uptr.withMemoryRebound(to: FIT_POWER_ZONE_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_POWER_ZONE,
                         mesg_values: rzfit_power_zone_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_power_zone_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_MET_ZONE:
    uptr.withMemoryRebound(to: FIT_MET_ZONE_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_MET_ZONE,
                         mesg_values: rzfit_met_zone_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_met_zone_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_SPORT:
    uptr.withMemoryRebound(to: FIT_SPORT_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_SPORT,
                         mesg_values: rzfit_sport_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_sport_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_GOAL:
    uptr.withMemoryRebound(to: FIT_GOAL_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_GOAL,
                         mesg_values: rzfit_goal_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_goal_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_SESSION:
    uptr.withMemoryRebound(to: FIT_SESSION_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_SESSION,
                         mesg_values: rzfit_session_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_session_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_LAP:
    uptr.withMemoryRebound(to: FIT_LAP_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_LAP,
                         mesg_values: rzfit_lap_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_lap_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_RECORD:
    uptr.withMemoryRebound(to: FIT_RECORD_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_RECORD,
                         mesg_values: rzfit_record_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_record_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_EVENT:
    uptr.withMemoryRebound(to: FIT_EVENT_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_EVENT,
                         mesg_values: rzfit_event_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_event_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_DEVICE_INFO:
    uptr.withMemoryRebound(to: FIT_DEVICE_INFO_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_DEVICE_INFO,
                         mesg_values: rzfit_device_info_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_device_info_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_WORKOUT:
    uptr.withMemoryRebound(to: FIT_WORKOUT_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_WORKOUT,
                         mesg_values: rzfit_workout_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_workout_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_WORKOUT_STEP:
    uptr.withMemoryRebound(to: FIT_WORKOUT_STEP_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_WORKOUT_STEP,
                         mesg_values: rzfit_workout_step_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_workout_step_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_SCHEDULE:
    uptr.withMemoryRebound(to: FIT_SCHEDULE_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_SCHEDULE,
                         mesg_values: rzfit_schedule_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_schedule_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_WEIGHT_SCALE:
    uptr.withMemoryRebound(to: FIT_WEIGHT_SCALE_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_WEIGHT_SCALE,
                         mesg_values: rzfit_weight_scale_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_weight_scale_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_COURSE:
    uptr.withMemoryRebound(to: FIT_COURSE_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_COURSE,
                         mesg_values: rzfit_course_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_course_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_COURSE_POINT:
    uptr.withMemoryRebound(to: FIT_COURSE_POINT_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_COURSE_POINT,
                         mesg_values: rzfit_course_point_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_course_point_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_TOTALS:
    uptr.withMemoryRebound(to: FIT_TOTALS_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_TOTALS,
                         mesg_values: rzfit_totals_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_totals_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_ACTIVITY:
    uptr.withMemoryRebound(to: FIT_ACTIVITY_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_ACTIVITY,
                         mesg_values: rzfit_activity_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_activity_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_SOFTWARE:
    uptr.withMemoryRebound(to: FIT_SOFTWARE_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_SOFTWARE,
                         mesg_values: rzfit_software_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_software_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_FILE_CAPABILITIES:
    uptr.withMemoryRebound(to: FIT_FILE_CAPABILITIES_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_FILE_CAPABILITIES,
                         mesg_values: rzfit_file_capabilities_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_file_capabilities_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_MESG_CAPABILITIES:
    uptr.withMemoryRebound(to: FIT_MESG_CAPABILITIES_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_MESG_CAPABILITIES,
                         mesg_values: rzfit_mesg_capabilities_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_mesg_capabilities_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_FIELD_CAPABILITIES:
    uptr.withMemoryRebound(to: FIT_FIELD_CAPABILITIES_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_FIELD_CAPABILITIES,
                         mesg_values: rzfit_field_capabilities_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_field_capabilities_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_FILE_CREATOR:
    uptr.withMemoryRebound(to: FIT_FILE_CREATOR_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_FILE_CREATOR,
                         mesg_values: rzfit_file_creator_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_file_creator_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_BLOOD_PRESSURE:
    uptr.withMemoryRebound(to: FIT_BLOOD_PRESSURE_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_BLOOD_PRESSURE,
                         mesg_values: rzfit_blood_pressure_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_blood_pressure_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_SPEED_ZONE:
    uptr.withMemoryRebound(to: FIT_SPEED_ZONE_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_SPEED_ZONE,
                         mesg_values: rzfit_speed_zone_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_speed_zone_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_MONITORING:
    uptr.withMemoryRebound(to: FIT_MONITORING_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_MONITORING,
                         mesg_values: rzfit_monitoring_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_monitoring_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_TRAINING_FILE:
    uptr.withMemoryRebound(to: FIT_TRAINING_FILE_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_TRAINING_FILE,
                         mesg_values: rzfit_training_file_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_training_file_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_HRV:
    uptr.withMemoryRebound(to: FIT_HRV_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_HRV,
                         mesg_values: rzfit_hrv_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_hrv_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_ANT_RX:
    uptr.withMemoryRebound(to: FIT_ANT_RX_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_ANT_RX,
                         mesg_values: rzfit_ant_rx_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_ant_rx_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_ANT_TX:
    uptr.withMemoryRebound(to: FIT_ANT_TX_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_ANT_TX,
                         mesg_values: rzfit_ant_tx_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_ant_tx_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_LENGTH:
    uptr.withMemoryRebound(to: FIT_LENGTH_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_LENGTH,
                         mesg_values: rzfit_length_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_length_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_MONITORING_INFO:
    uptr.withMemoryRebound(to: FIT_MONITORING_INFO_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_MONITORING_INFO,
                         mesg_values: rzfit_monitoring_info_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_monitoring_info_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_SLAVE_DEVICE:
    uptr.withMemoryRebound(to: FIT_SLAVE_DEVICE_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_SLAVE_DEVICE,
                         mesg_values: rzfit_slave_device_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_slave_device_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_CONNECTIVITY:
    uptr.withMemoryRebound(to: FIT_CONNECTIVITY_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_CONNECTIVITY,
                         mesg_values: rzfit_connectivity_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_connectivity_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_WEATHER_CONDITIONS:
    uptr.withMemoryRebound(to: FIT_WEATHER_CONDITIONS_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_WEATHER_CONDITIONS,
                         mesg_values: rzfit_weather_conditions_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_weather_conditions_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_WEATHER_ALERT:
    uptr.withMemoryRebound(to: FIT_WEATHER_ALERT_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_WEATHER_ALERT,
                         mesg_values: rzfit_weather_alert_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_weather_alert_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_CADENCE_ZONE:
    uptr.withMemoryRebound(to: FIT_CADENCE_ZONE_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_CADENCE_ZONE,
                         mesg_values: rzfit_cadence_zone_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_cadence_zone_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_HR:
    uptr.withMemoryRebound(to: FIT_HR_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_HR,
                         mesg_values: rzfit_hr_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_hr_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_SEGMENT_LAP:
    uptr.withMemoryRebound(to: FIT_SEGMENT_LAP_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_SEGMENT_LAP,
                         mesg_values: rzfit_segment_lap_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_segment_lap_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_SEGMENT_ID:
    uptr.withMemoryRebound(to: FIT_SEGMENT_ID_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_SEGMENT_ID,
                         mesg_values: rzfit_segment_id_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_segment_id_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_SEGMENT_LEADERBOARD_ENTRY:
    uptr.withMemoryRebound(to: FIT_SEGMENT_LEADERBOARD_ENTRY_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_SEGMENT_LEADERBOARD_ENTRY,
                         mesg_values: rzfit_segment_leaderboard_entry_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_segment_leaderboard_entry_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_SEGMENT_POINT:
    uptr.withMemoryRebound(to: FIT_SEGMENT_POINT_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_SEGMENT_POINT,
                         mesg_values: rzfit_segment_point_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_segment_point_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_SEGMENT_FILE:
    uptr.withMemoryRebound(to: FIT_SEGMENT_FILE_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_SEGMENT_FILE,
                         mesg_values: rzfit_segment_file_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_segment_file_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_WORKOUT_SESSION:
    uptr.withMemoryRebound(to: FIT_WORKOUT_SESSION_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_WORKOUT_SESSION,
                         mesg_values: rzfit_workout_session_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_workout_session_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_NMEA_SENTENCE:
    uptr.withMemoryRebound(to: FIT_NMEA_SENTENCE_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_NMEA_SENTENCE,
                         mesg_values: rzfit_nmea_sentence_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_nmea_sentence_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_AVIATION_ATTITUDE:
    uptr.withMemoryRebound(to: FIT_AVIATION_ATTITUDE_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_AVIATION_ATTITUDE,
                         mesg_values: rzfit_aviation_attitude_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_aviation_attitude_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_VIDEO_TITLE:
    uptr.withMemoryRebound(to: FIT_VIDEO_TITLE_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_VIDEO_TITLE,
                         mesg_values: rzfit_video_title_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_video_title_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_VIDEO_DESCRIPTION:
    uptr.withMemoryRebound(to: FIT_VIDEO_DESCRIPTION_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_VIDEO_DESCRIPTION,
                         mesg_values: rzfit_video_description_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_video_description_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_EXD_SCREEN_CONFIGURATION:
    uptr.withMemoryRebound(to: FIT_EXD_SCREEN_CONFIGURATION_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_EXD_SCREEN_CONFIGURATION,
                         mesg_values: rzfit_exd_screen_configuration_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_exd_screen_configuration_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_EXD_DATA_FIELD_CONFIGURATION:
    uptr.withMemoryRebound(to: FIT_EXD_DATA_FIELD_CONFIGURATION_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_EXD_DATA_FIELD_CONFIGURATION,
                         mesg_values: rzfit_exd_data_field_configuration_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_exd_data_field_configuration_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_EXD_DATA_CONCEPT_CONFIGURATION:
    uptr.withMemoryRebound(to: FIT_EXD_DATA_CONCEPT_CONFIGURATION_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_EXD_DATA_CONCEPT_CONFIGURATION,
                         mesg_values: rzfit_exd_data_concept_configuration_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_exd_data_concept_configuration_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_FIELD_DESCRIPTION:
    uptr.withMemoryRebound(to: FIT_FIELD_DESCRIPTION_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_FIELD_DESCRIPTION,
                         mesg_values: rzfit_field_description_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_field_description_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_DEVELOPER_DATA_ID:
    uptr.withMemoryRebound(to: FIT_DEVELOPER_DATA_ID_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_DEVELOPER_DATA_ID,
                         mesg_values: rzfit_developer_data_id_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_developer_data_id_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_SET:
    uptr.withMemoryRebound(to: FIT_SET_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_SET,
                         mesg_values: rzfit_set_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_set_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_DIVE_SETTINGS:
    uptr.withMemoryRebound(to: FIT_DIVE_SETTINGS_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_DIVE_SETTINGS,
                         mesg_values: rzfit_dive_settings_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_dive_settings_mesg_enum_dict(ptr: $0))
    }
  case FIT_MESG_NUM_EXERCISE_TITLE:
    uptr.withMemoryRebound(to: FIT_EXERCISE_TITLE_MESG.self, capacity: 1) {
      rv = RZFitMessage( mesg_num:    FIT_MESG_NUM_EXERCISE_TITLE,
                         mesg_values: rzfit_exercise_title_mesg_value_dict(ptr: $0),
                         mesg_enums:  rzfit_exercise_title_mesg_enum_dict(ptr: $0))
    }
    default:
       rv = RZFitMessage( mesg_num: num, mesg_values: [:], mesg_enums: [:])
    }
    return rv
}
func rzfit_string_to_mesg(mesg : String) -> FIT_MESG_NUM? {
  var rv : FIT_MESG_NUM? = nil
  switch mesg {
  case "file_id": rv = FIT_MESG_NUM_FILE_ID;
  case "capabilities": rv = FIT_MESG_NUM_CAPABILITIES;
  case "device_settings": rv = FIT_MESG_NUM_DEVICE_SETTINGS;
  case "user_profile": rv = FIT_MESG_NUM_USER_PROFILE;
  case "hrm_profile": rv = FIT_MESG_NUM_HRM_PROFILE;
  case "sdm_profile": rv = FIT_MESG_NUM_SDM_PROFILE;
  case "bike_profile": rv = FIT_MESG_NUM_BIKE_PROFILE;
  case "zones_target": rv = FIT_MESG_NUM_ZONES_TARGET;
  case "hr_zone": rv = FIT_MESG_NUM_HR_ZONE;
  case "power_zone": rv = FIT_MESG_NUM_POWER_ZONE;
  case "met_zone": rv = FIT_MESG_NUM_MET_ZONE;
  case "sport": rv = FIT_MESG_NUM_SPORT;
  case "goal": rv = FIT_MESG_NUM_GOAL;
  case "session": rv = FIT_MESG_NUM_SESSION;
  case "lap": rv = FIT_MESG_NUM_LAP;
  case "record": rv = FIT_MESG_NUM_RECORD;
  case "event": rv = FIT_MESG_NUM_EVENT;
  case "device_info": rv = FIT_MESG_NUM_DEVICE_INFO;
  case "workout": rv = FIT_MESG_NUM_WORKOUT;
  case "workout_step": rv = FIT_MESG_NUM_WORKOUT_STEP;
  case "schedule": rv = FIT_MESG_NUM_SCHEDULE;
  case "weight_scale": rv = FIT_MESG_NUM_WEIGHT_SCALE;
  case "course": rv = FIT_MESG_NUM_COURSE;
  case "course_point": rv = FIT_MESG_NUM_COURSE_POINT;
  case "totals": rv = FIT_MESG_NUM_TOTALS;
  case "activity": rv = FIT_MESG_NUM_ACTIVITY;
  case "software": rv = FIT_MESG_NUM_SOFTWARE;
  case "file_capabilities": rv = FIT_MESG_NUM_FILE_CAPABILITIES;
  case "mesg_capabilities": rv = FIT_MESG_NUM_MESG_CAPABILITIES;
  case "field_capabilities": rv = FIT_MESG_NUM_FIELD_CAPABILITIES;
  case "file_creator": rv = FIT_MESG_NUM_FILE_CREATOR;
  case "blood_pressure": rv = FIT_MESG_NUM_BLOOD_PRESSURE;
  case "speed_zone": rv = FIT_MESG_NUM_SPEED_ZONE;
  case "monitoring": rv = FIT_MESG_NUM_MONITORING;
  case "training_file": rv = FIT_MESG_NUM_TRAINING_FILE;
  case "hrv": rv = FIT_MESG_NUM_HRV;
  case "ant_rx": rv = FIT_MESG_NUM_ANT_RX;
  case "ant_tx": rv = FIT_MESG_NUM_ANT_TX;
  case "ant_channel_id": rv = FIT_MESG_NUM_ANT_CHANNEL_ID;
  case "length": rv = FIT_MESG_NUM_LENGTH;
  case "monitoring_info": rv = FIT_MESG_NUM_MONITORING_INFO;
  case "pad": rv = FIT_MESG_NUM_PAD;
  case "slave_device": rv = FIT_MESG_NUM_SLAVE_DEVICE;
  case "connectivity": rv = FIT_MESG_NUM_CONNECTIVITY;
  case "weather_conditions": rv = FIT_MESG_NUM_WEATHER_CONDITIONS;
  case "weather_alert": rv = FIT_MESG_NUM_WEATHER_ALERT;
  case "cadence_zone": rv = FIT_MESG_NUM_CADENCE_ZONE;
  case "hr": rv = FIT_MESG_NUM_HR;
  case "segment_lap": rv = FIT_MESG_NUM_SEGMENT_LAP;
  case "memo_glob": rv = FIT_MESG_NUM_MEMO_GLOB;
  case "segment_id": rv = FIT_MESG_NUM_SEGMENT_ID;
  case "segment_leaderboard_entry": rv = FIT_MESG_NUM_SEGMENT_LEADERBOARD_ENTRY;
  case "segment_point": rv = FIT_MESG_NUM_SEGMENT_POINT;
  case "segment_file": rv = FIT_MESG_NUM_SEGMENT_FILE;
  case "workout_session": rv = FIT_MESG_NUM_WORKOUT_SESSION;
  case "watchface_settings": rv = FIT_MESG_NUM_WATCHFACE_SETTINGS;
  case "gps_metadata": rv = FIT_MESG_NUM_GPS_METADATA;
  case "camera_event": rv = FIT_MESG_NUM_CAMERA_EVENT;
  case "timestamp_correlation": rv = FIT_MESG_NUM_TIMESTAMP_CORRELATION;
  case "gyroscope_data": rv = FIT_MESG_NUM_GYROSCOPE_DATA;
  case "accelerometer_data": rv = FIT_MESG_NUM_ACCELEROMETER_DATA;
  case "three_d_sensor_calibration": rv = FIT_MESG_NUM_THREE_D_SENSOR_CALIBRATION;
  case "video_frame": rv = FIT_MESG_NUM_VIDEO_FRAME;
  case "obdii_data": rv = FIT_MESG_NUM_OBDII_DATA;
  case "nmea_sentence": rv = FIT_MESG_NUM_NMEA_SENTENCE;
  case "aviation_attitude": rv = FIT_MESG_NUM_AVIATION_ATTITUDE;
  case "video": rv = FIT_MESG_NUM_VIDEO;
  case "video_title": rv = FIT_MESG_NUM_VIDEO_TITLE;
  case "video_description": rv = FIT_MESG_NUM_VIDEO_DESCRIPTION;
  case "video_clip": rv = FIT_MESG_NUM_VIDEO_CLIP;
  case "ohr_settings": rv = FIT_MESG_NUM_OHR_SETTINGS;
  case "exd_screen_configuration": rv = FIT_MESG_NUM_EXD_SCREEN_CONFIGURATION;
  case "exd_data_field_configuration": rv = FIT_MESG_NUM_EXD_DATA_FIELD_CONFIGURATION;
  case "exd_data_concept_configuration": rv = FIT_MESG_NUM_EXD_DATA_CONCEPT_CONFIGURATION;
  case "field_description": rv = FIT_MESG_NUM_FIELD_DESCRIPTION;
  case "developer_data_id": rv = FIT_MESG_NUM_DEVELOPER_DATA_ID;
  case "magnetometer_data": rv = FIT_MESG_NUM_MAGNETOMETER_DATA;
  case "barometer_data": rv = FIT_MESG_NUM_BAROMETER_DATA;
  case "one_d_sensor_calibration": rv = FIT_MESG_NUM_ONE_D_SENSOR_CALIBRATION;
  case "set": rv = FIT_MESG_NUM_SET;
  case "stress_level": rv = FIT_MESG_NUM_STRESS_LEVEL;
  case "dive_settings": rv = FIT_MESG_NUM_DIVE_SETTINGS;
  case "dive_gas": rv = FIT_MESG_NUM_DIVE_GAS;
  case "dive_alarm": rv = FIT_MESG_NUM_DIVE_ALARM;
  case "exercise_title": rv = FIT_MESG_NUM_EXERCISE_TITLE;
  case "dive_summary": rv = FIT_MESG_NUM_DIVE_SUMMARY;
  default:
    rv = nil
  }
  return rv
}
func rzfit_unit_for_field( field : String ) -> String? {
  switch field {
  case "systolic_pressure": return "mmHg"
  case "max_cadence": return "rpm"
  case "custom_wheelsize": return "m"
  case "max_pos_vertical_speed": return "m/s"
  case "bone_mass": return "kg"
  case "high_temperature": return "C"
  case "total_work": return "J"
  case "avg_left_torque_effectiveness": return "percent"
  case "time_in_power_zone": return "s"
  case "avg_pos_grade": return "%"
  case "max_neg_vertical_speed": return "m/s"
  case "low_temperature": return "C"
  case "elapsed_time": return "s"
  case "avg_left_pedal_smoothness": return "percent"
  case "saturated_hemoglobin_percent_max": return "%"
  case "zone_count": return "counts"
  case "cum_operating_time": return "s"
  case "avg_lap_time": return "s"
  case "percent_hydration": return "%"
  case "min_heart_rate": return "bpm"
  case "autosync_min_time": return "minutes"
  case "map_3_sample_mean": return "mmHg"
  case "stance_time": return "ms"
  case "total_cycles": return "cycles"
  case "avg_total_hemoglobin_conc": return "g/dL"
  case "enhanced_min_altitude": return "m"
  case "avg_pos_vertical_speed": return "m/s"
  case "distance": return "m"
  case "timestamp": return "s"
  case "timer_time": return "s"
  case "start_position_lat": return "semicircles"
  case "saturated_hemoglobin_percent_min": return "%"
  case "cadence": return "rpm"
  case "avg_fractional_cadence": return "rpm"
  case "total_elapsed_time": return "s"
  case "diastolic_pressure": return "mmHg"
  case "intensity_factor": return "if"
  case "wind_speed": return "m/s"
  case "avg_vertical_oscillation": return "mm"
  case "system_time": return "ms"
  case "power_cal_factor": return "%"
  case "training_stress_score": return "tss"
  case "temperature_feels_like": return "C"
  case "enhanced_speed": return "m/s"
  case "avg_grade": return "%"
  case "max_heart_rate": return "bpm"
  case "active_met": return "kcal/day"
  case "avg_speed": return "m/s"
  case "nec_lat": return "semicircles"
  case "max_ball_speed": return "m/s"
  case "total_fat_calories": return "kcal"
  case "ball_speed": return "m/s"
  case "avg_vam": return "m/s"
  case "muscle_mass": return "kg"
  case "weight": return "kg"
  case "filtered_bpm": return "bpm"
  case "total_timer_time": return "s"
  case "wind_direction": return "degrees"
  case "avg_power": return "watts"
  case "avg_heart_rate": return "bpm"
  case "default_max_biking_heart_rate": return "bpm"
  case "enhanced_avg_altitude": return "m"
  case "enhanced_avg_speed": return "m/s"
  case "avg_combined_pedal_smoothness": return "percent"
  case "pool_length": return "m"
  case "num_active_lengths": return "lengths"
  case "total_calories": return "kcal"
  case "speed": return "m/s"
  case "nec_long": return "semicircles"
  case "max_pos_grade": return "%"
  case "accel_lateral": return "m/s^2"
  case "percent_fat": return "%"
  case "time_in_hr_zone": return "s"
  case "avg_stroke_distance": return "m"
  case "cadence256": return "rpm"
  case "observed_location_lat": return "semicircles"
  case "swc_lat": return "semicircles"
  case "max_speed": return "m/s"
  case "min_altitude": return "m"
  case "max_total_hemoglobin_conc": return "g/dL"
  case "total_hemoglobin_conc": return "g/dL"
  case "min_total_hemoglobin_conc": return "g/dL"
  case "map_morning_values": return "mmHg"
  case "turn_rate": return "radians/second"
  case "cycles": return "cycles"
  case "auto_wheelsize": return "m"
  case "compressed_accumulated_power": return "watts"
  case "time_in_cadence_zone": return "s"
  case "fractional_timestamp": return "s"
  case "stroke_count": return "counts"
  case "avg_swimming_cadence": return "strokes/min"
  case "autosync_min_steps": return "steps"
  case "gps_accuracy": return "m"
  case "total_fractional_cycles": return "cycles"
  case "metabolic_age": return "years"
  case "active_time": return "s"
  case "local_timestamp": return "s"
  case "observed_location_long": return "semicircles"
  case "grade": return "%"
  case "saturated_hemoglobin_percent": return "%"
  case "max_fractional_cadence": return "rpm"
  case "height": return "m"
  case "end_position_long": return "semicircles"
  case "max_saturated_hemoglobin_percent": return "%"
  case "avg_neg_vertical_speed": return "m/s"
  case "temperature": return "C"
  case "altitude": return "m"
  case "max_altitude": return "m"
  case "odometer": return "m"
  case "fractional_cadence": return "rpm"
  case "resting_heart_rate": return "bpm"
  case "default_max_running_heart_rate": return "bpm"
  case "bike_weight": return "kg"
  case "accel_normal": return "m/s^2"
  case "basal_met": return "kcal/day"
  case "segment_time": return "s"
  case "left_torque_effectiveness": return "percent"
  case "visceral_fat_mass": return "kg"
  case "swc_long": return "semicircles"
  case "time128": return "s"
  case "time_from_course": return "s"
  case "left_pedal_smoothness": return "percent"
  case "avg_stroke_count": return "strokes/lap"
  case "total_strokes": return "strokes"
  case "position_lat": return "semicircles"
  case "total_distance": return "m"
  case "default_max_heart_rate": return "bpm"
  case "mean_arterial_pressure": return "mmHg"
  case "speed_1s": return "m/s"
  case "attitude_stage_complete": return "%"
  case "total_descent": return "m"
  case "stance_time_percent": return "percent"
  case "avg_stance_time_percent": return "percent"
  case "avg_temperature": return "C"
  case "enhanced_max_speed": return "m/s"
  case "max_power": return "watts"
  case "min_saturated_hemoglobin_percent": return "%"
  case "time_offset": return "s"
  case "avg_ball_speed": return "m/s"
  case "avg_cadence": return "rpm"
  case "avg_neg_grade": return "%"
  case "calories": return "kcal"
  case "max_temperature": return "C"
  case "avg_right_pedal_smoothness": return "percent"
  case "avg_stance_time": return "ms"
  case "high_bpm": return "bpm"
  case "high_value": return "watts"
  case "avg_right_torque_effectiveness": return "percent"
  case "start_position_long": return "semicircles"
  case "swim_stroke": return "swim_stroke"
  case "time_zone_offset": return "hr"
  case "right_pedal_smoothness": return "percent"
  case "combined_pedal_smoothness": return "percent"
  case "total_hemoglobin_conc_max": return "g/dL"
  case "total_hemoglobin_conc_min": return "g/dL"
  case "enhanced_altitude": return "m"
  case "battery_voltage": return "V"
  case "active_time_16": return "s"
  case "timestamp_ms": return "ms"
  case "power": return "watts"
  case "right_torque_effectiveness": return "percent"
  case "heart_rate": return "bpm"
  case "vertical_oscillation": return "mm"
  case "vertical_speed": return "m/s"
  case "avg_altitude": return "m"
  case "position_long": return "semicircles"
  case "num_lengths": return "lengths"
  case "sdm_cal_factor": return "%"
  case "map_evening_values": return "mmHg"
  case "enhanced_max_altitude": return "m"
  case "leader_time": return "s"
  case "total_moving_time": return "s"
  case "user_running_step_length": return "m"
  case "normalized_power": return "watts"
  case "max_size": return "bytes"
  case "cycle_length": return "m"
  case "user_walking_step_length": return "m"
  case "max_neg_grade": return "%"
  case "age": return "years"
  case "avg_saturated_hemoglobin_percent": return "%"
  case "time256": return "s"
  case "event_timestamp": return "s"
  case "threshold_power": return "watts"
  case "total_ascent": return "m"
  case "accumulated_power": return "watts"
  case "time_in_speed_zone": return "s"
  case "time": return "s"
  case "end_position_lat": return "semicircles"
  default: return nil
  }
}
