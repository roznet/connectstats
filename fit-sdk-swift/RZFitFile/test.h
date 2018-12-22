
typedef FIT_ENUM FIT_ACTIVITY_TYPE;
#define FIT_ACTIVITY_TYPE_INVALID                                                FIT_ENUM_INVALID
#define FIT_ACTIVITY_TYPE_GENERIC                                                ((FIT_ACTIVITY_TYPE)0)
#define FIT_ACTIVITY_TYPE_RUNNING                                                ((FIT_ACTIVITY_TYPE)1)
#define FIT_ACTIVITY_TYPE_CYCLING                                                ((FIT_ACTIVITY_TYPE)2)
#define FIT_ACTIVITY_TYPE_TRANSITION                                             ((FIT_ACTIVITY_TYPE)3) // Mulitsport transition
#define FIT_ACTIVITY_TYPE_FITNESS_EQUIPMENT                                      ((FIT_ACTIVITY_TYPE)4)
#define FIT_ACTIVITY_TYPE_SWIMMING                                               ((FIT_ACTIVITY_TYPE)5)
#define FIT_ACTIVITY_TYPE_WALKING                                                ((FIT_ACTIVITY_TYPE)6)
#define FIT_ACTIVITY_TYPE_SEDENTARY                                              ((FIT_ACTIVITY_TYPE)8)
#define FIT_ACTIVITY_TYPE_ALL                                                    ((FIT_ACTIVITY_TYPE)254) // All is for goals only to include all sports.
#define FIT_ACTIVITY_TYPE_COUNT                                                  9


typedef FIT_UINT32 FIT_DATE_TIME; // seconds since UTC 00:00 Dec 31 1989
#define FIT_DATE_TIME_INVALID                                                    FIT_UINT32_INVALID
#define FIT_DATE_TIME_MIN                                                        ((FIT_DATE_TIME)0x10000000) // if date_time is < 0x10000000 then it is system time (seconds from device power on)
#define FIT_DATE_TIME_COUNT                                                      1

typedef struct
{
   FIT_DATE_TIME timestamp; // 1 * s + 0,
   FIT_SINT32 position_lat; // 1 * semicircles + 0,
   FIT_SINT32 position_long; // 1 * semicircles + 0,
   FIT_UINT32 distance; // 100 * m + 0,
   FIT_SINT32 time_from_course; // 1000 * s + 0,
   FIT_UINT32 total_cycles; // 1 * cycles + 0,
   FIT_UINT32 accumulated_power; // 1 * watts + 0,
   FIT_UINT32 enhanced_speed; // 1000 * m/s + 0,
   FIT_UINT32 enhanced_altitude; // 5 * m + 500,
   FIT_UINT16 altitude; // 5 * m + 500,
   FIT_UINT16 speed; // 1000 * m/s + 0,
   FIT_UINT16 power; // 1 * watts + 0,
   FIT_SINT16 grade; // 100 * % + 0,
   FIT_UINT16 compressed_accumulated_power; // 1 * watts + 0,
   FIT_SINT16 vertical_speed; // 1000 * m/s + 0,
   FIT_UINT16 calories; // 1 * kcal + 0,
   FIT_UINT16 vertical_oscillation; // 10 * mm + 0,
   FIT_UINT16 stance_time_percent; // 100 * percent + 0,
   FIT_UINT16 stance_time; // 10 * ms + 0,
   FIT_UINT16 ball_speed; // 100 * m/s + 0,
   FIT_UINT16 cadence256; // 256 * rpm + 0, Log cadence and fractional cadence for backwards compatability
   FIT_UINT16 total_hemoglobin_conc; // 100 * g/dL + 0, Total saturated and unsaturated hemoglobin
   FIT_UINT16 total_hemoglobin_conc_min; // 100 * g/dL + 0, Min saturated and unsaturated hemoglobin
   FIT_UINT16 total_hemoglobin_conc_max; // 100 * g/dL + 0, Max saturated and unsaturated hemoglobin
   FIT_UINT16 saturated_hemoglobin_percent; // 10 * % + 0, Percentage of hemoglobin saturated with oxygen
   FIT_UINT16 saturated_hemoglobin_percent_min; // 10 * % + 0, Min percentage of hemoglobin saturated with oxygen
   FIT_UINT16 saturated_hemoglobin_percent_max; // 10 * % + 0, Max percentage of hemoglobin saturated with oxygen
   FIT_UINT8 heart_rate; // 1 * bpm + 0,
   FIT_UINT8 cadence; // 1 * rpm + 0,
   FIT_BYTE compressed_speed_distance[FIT_RECORD_MESG_COMPRESSED_SPEED_DISTANCE_COUNT]; //
   FIT_UINT8 resistance; // Relative. 0 is none  254 is Max.
   FIT_UINT8 cycle_length; // 100 * m + 0,
   FIT_SINT8 temperature; // 1 * C + 0,
   FIT_UINT8 speed_1s[FIT_RECORD_MESG_SPEED_1S_COUNT]; // 16 * m/s + 0, Speed at 1s intervals.  Timestamp field indicates time of last array element.
   FIT_UINT8 cycles; // 1 * cycles + 0,
   FIT_LEFT_RIGHT_BALANCE left_right_balance; //
   FIT_UINT8 gps_accuracy; // 1 * m + 0,
   FIT_ACTIVITY_TYPE activity_type; //
   FIT_UINT8 left_torque_effectiveness; // 2 * percent + 0,
   FIT_UINT8 right_torque_effectiveness; // 2 * percent + 0,
   FIT_UINT8 left_pedal_smoothness; // 2 * percent + 0,
   FIT_UINT8 right_pedal_smoothness; // 2 * percent + 0,
   FIT_UINT8 combined_pedal_smoothness; // 2 * percent + 0,
   FIT_UINT8 time128; // 128 * s + 0,
   FIT_STROKE_TYPE stroke_type; //
   FIT_UINT8 zone; //
   FIT_UINT8 fractional_cadence; // 128 * rpm + 0,
   FIT_DEVICE_INDEX device_index; //
} FIT_RECORD_MESG;

typedef struct
{
   FIT_UINT8 hdr[FIT_FILE_HDR_SIZE];
   FIT_UINT8 file_id_mesg_def[FIT_HDR_SIZE + FIT_FILE_ID_MESG_DEF_SIZE];
   FIT_UINT8 file_id_mesg[FIT_DEVICE_FILE_FILE_ID_MESGS][FIT_HDR_SIZE + FIT_FILE_ID_MESG_SIZE];
   FIT_UINT8 crc[2];
} FIT_DEVICE_FILE;

typedef struct
{
   FIT_STRING name[FIT_BIKE_PROFILE_MESG_NAME_COUNT]; //
   FIT_UINT32 odometer; // 100 * m + 0,
   FIT_MESSAGE_INDEX message_index; //
   FIT_UINT16Z bike_spd_ant_id; //
   FIT_UINT16Z bike_cad_ant_id; //
   FIT_UINT16Z bike_spdcad_ant_id; //
   FIT_UINT16Z bike_power_ant_id; //
   FIT_UINT16 custom_wheelsize; // 1000 * m + 0,
   FIT_UINT16 auto_wheelsize; // 1000 * m + 0,
   FIT_UINT16 bike_weight; // 10 * kg + 0,
   FIT_UINT16 power_cal_factor; // 10 * % + 0,
   FIT_SPORT sport; //
   FIT_SUB_SPORT sub_sport; //
   FIT_BOOL auto_wheel_cal; //
   FIT_BOOL auto_power_zero; //
   FIT_UINT8 id; //
   FIT_BOOL spd_enabled; //
   FIT_BOOL cad_enabled; //
   FIT_BOOL spdcad_enabled; //
   FIT_BOOL power_enabled; //
   FIT_UINT8 crank_length; // 2 * mm + -110,
   FIT_BOOL enabled; //
   FIT_UINT8Z bike_spd_ant_id_trans_type; //
   FIT_UINT8Z bike_cad_ant_id_trans_type; //
   FIT_UINT8Z bike_spdcad_ant_id_trans_type; //
   FIT_UINT8Z bike_power_ant_id_trans_type; //
   FIT_UINT8 odometer_rollover; // Rollover counter that can be used to extend the odometer
   FIT_UINT8Z front_gear_num; // Number of front gears
   FIT_UINT8Z front_gear[FIT_BIKE_PROFILE_MESG_FRONT_GEAR_COUNT]; // Number of teeth on each gear 0 is innermost
   FIT_UINT8Z rear_gear_num; // Number of rear gears
   FIT_UINT8Z rear_gear[FIT_BIKE_PROFILE_MESG_REAR_GEAR_COUNT]; // Number of teeth on each gear 0 is innermost
   FIT_BOOL shimano_di2_enabled; //
} FIT_BIKE_PROFILE_MESG;
