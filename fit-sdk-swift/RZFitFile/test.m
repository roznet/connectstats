// This file is auto generated, Do not edit

#include "test.h"

NSString * objc_rzfit_field_num_for_record(FIT_UINT16 field) {
  switch (field) {
    case 30: return @"left_right_balance";
    case 42: return @"activity_type";
    case 43: return @"left_torque_effectiveness";
    case 62: return @"device_index";
    case 253: return @"timestamp";
    case 48: return @"time128";
    case 49: return @"stroke_type";
    case 46: return @"right_pedal_smoothness";
    case 47: return @"combined_pedal_smoothness";
    case 44: return @"right_torque_effectiveness";
    case 45: return @"left_pedal_smoothness";
    case 28: return @"compressed_accumulated_power";
    case 29: return @"accumulated_power";
    case 40: return @"stance_time_percent";
    case 41: return @"stance_time";
    case 1: return @"position_long";
    case 0: return @"position_lat";
    case 3: return @"heart_rate";
    case 2: return @"altitude";
    case 5: return @"distance";
    case 4: return @"cadence";
    case 7: return @"power";
    case 6: return @"speed";
    case 9: return @"grade";
    case 8: return @"compressed_speed_distance";
    case 18: return @"cycles";
    case 13: return @"temperature";
    case 73: return @"enhanced_speed";
    case 78: return @"enhanced_altitude";
    case 11: return @"time_from_course";
    case 10: return @"resistance";
    case 39: return @"vertical_oscillation";
    case 12: return @"cycle_length";
    case 59: return @"saturated_hemoglobin_percent_max";
    case 58: return @"saturated_hemoglobin_percent_min";
    case 17: return @"speed_1s";
    case 55: return @"total_hemoglobin_conc_min";
    case 19: return @"total_cycles";
    case 54: return @"total_hemoglobin_conc";
    case 57: return @"saturated_hemoglobin_percent";
    case 56: return @"total_hemoglobin_conc_max";
    case 51: return @"ball_speed";
    case 50: return @"zone";
    case 53: return @"fractional_cadence";
    case 52: return @"cadence256";
    case 33: return @"calories";
    case 32: return @"vertical_speed";
    case 31: return @"gps_accuracy";
  default: return nil;
  }
}
NSString * objc_rzfit_field_num_to_field( FIT_MESG_NUM messageType, FIT_UINT16 field ) {
  switch (messageType) {
    case FIT_MESG_NUM_RECORD: return objc_rzfit_field_num_for_record(field);
    case FIT_MESG_NUM_LAP: return objc_rzfit_field_num_for_lap(field);
    case FIT_MESG_NUM_SESSION: return objc_rzfit_field_num_for_session(field);
    default: return nil;
   }
}
