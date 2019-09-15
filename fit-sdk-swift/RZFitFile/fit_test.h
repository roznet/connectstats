
typedef FIT_UINT16 FIT_MESG_NUM;
#define FIT_MESG_NUM_INVALID                                                     FIT_UINT16_INVALID
#define FIT_MESG_NUM_FILE_ID                                                     ((FIT_MESG_NUM)0)
#define FIT_MESG_NUM_CAPABILITIES                                                ((FIT_MESG_NUM)1)
#define FIT_MESG_NUM_DEVICE_SETTINGS                                             ((FIT_MESG_NUM)2)
#define FIT_MESG_NUM_USER_PROFILE                                                ((FIT_MESG_NUM)3)
#define FIT_MESG_NUM_HRM_PROFILE                                                 ((FIT_MESG_NUM)4)
#define FIT_MESG_NUM_SDM_PROFILE                                                 ((FIT_MESG_NUM)5)
#define FIT_MESG_NUM_BIKE_PROFILE                                                ((FIT_MESG_NUM)6)
#define FIT_MESG_NUM_ZONES_TARGET                                                ((FIT_MESG_NUM)7)
#define FIT_MESG_NUM_HR_ZONE                                                     ((FIT_MESG_NUM)8)
#define FIT_MESG_NUM_POWER_ZONE                                                  ((FIT_MESG_NUM)9)
#define FIT_MESG_NUM_MET_ZONE                                                    ((FIT_MESG_NUM)10)
#define FIT_MESG_NUM_SPORT                                                       ((FIT_MESG_NUM)12)
#define FIT_MESG_NUM_GOAL                                                        ((FIT_MESG_NUM)15)
#define FIT_MESG_NUM_SESSION                                                     ((FIT_MESG_NUM)18)
#define FIT_MESG_NUM_LAP                                                         ((FIT_MESG_NUM)19)
#define FIT_MESG_NUM_RECORD                                                      ((FIT_MESG_NUM)20)
#define FIT_MESG_NUM_EVENT                                                       ((FIT_MESG_NUM)21)
#define FIT_MESG_NUM_DEVICE_INFO                                                 ((FIT_MESG_NUM)23)
#define FIT_MESG_NUM_WORKOUT                                                     ((FIT_MESG_NUM)26)
#define FIT_MESG_NUM_WORKOUT_STEP                                                ((FIT_MESG_NUM)27)
#define FIT_MESG_NUM_SCHEDULE                                                    ((FIT_MESG_NUM)28)
#define FIT_MESG_NUM_WEIGHT_SCALE                                                ((FIT_MESG_NUM)30)
#define FIT_MESG_NUM_COURSE                                                      ((FIT_MESG_NUM)31)
#define FIT_MESG_NUM_COURSE_POINT                                                ((FIT_MESG_NUM)32)
#define FIT_MESG_NUM_TOTALS                                                      ((FIT_MESG_NUM)33)
#define FIT_MESG_NUM_ACTIVITY                                                    ((FIT_MESG_NUM)34)
#define FIT_MESG_NUM_SOFTWARE                                                    ((FIT_MESG_NUM)35)
#define FIT_MESG_NUM_FILE_CAPABILITIES                                           ((FIT_MESG_NUM)37)
#define FIT_MESG_NUM_MESG_CAPABILITIES                                           ((FIT_MESG_NUM)38)
#define FIT_MESG_NUM_FIELD_CAPABILITIES                                          ((FIT_MESG_NUM)39)
#define FIT_MESG_NUM_FILE_CREATOR                                                ((FIT_MESG_NUM)49)
#define FIT_MESG_NUM_BLOOD_PRESSURE                                              ((FIT_MESG_NUM)51)
#define FIT_MESG_NUM_SPEED_ZONE                                                  ((FIT_MESG_NUM)53)
#define FIT_MESG_NUM_MONITORING                                                  ((FIT_MESG_NUM)55)
#define FIT_MESG_NUM_TRAINING_FILE                                               ((FIT_MESG_NUM)72)
#define FIT_MESG_NUM_HRV                                                         ((FIT_MESG_NUM)78)
#define FIT_MESG_NUM_ANT_RX                                                      ((FIT_MESG_NUM)80)
#define FIT_MESG_NUM_ANT_TX                                                      ((FIT_MESG_NUM)81)
#define FIT_MESG_NUM_ANT_CHANNEL_ID                                              ((FIT_MESG_NUM)82)
#define FIT_MESG_NUM_LENGTH                                                      ((FIT_MESG_NUM)101)
#define FIT_MESG_NUM_MONITORING_INFO                                             ((FIT_MESG_NUM)103)
#define FIT_MESG_NUM_PAD                                                         ((FIT_MESG_NUM)105)
#define FIT_MESG_NUM_SLAVE_DEVICE                                                ((FIT_MESG_NUM)106)
#define FIT_MESG_NUM_CONNECTIVITY                                                ((FIT_MESG_NUM)127)
#define FIT_MESG_NUM_WEATHER_CONDITIONS                                          ((FIT_MESG_NUM)128)
#define FIT_MESG_NUM_WEATHER_ALERT                                               ((FIT_MESG_NUM)129)
#define FIT_MESG_NUM_CADENCE_ZONE                                                ((FIT_MESG_NUM)131)
#define FIT_MESG_NUM_HR                                                          ((FIT_MESG_NUM)132)
#define FIT_MESG_NUM_SEGMENT_LAP                                                 ((FIT_MESG_NUM)142)
#define FIT_MESG_NUM_MEMO_GLOB                                                   ((FIT_MESG_NUM)145)
#define FIT_MESG_NUM_SEGMENT_ID                                                  ((FIT_MESG_NUM)148)
#define FIT_MESG_NUM_SEGMENT_LEADERBOARD_ENTRY                                   ((FIT_MESG_NUM)149)
#define FIT_MESG_NUM_SEGMENT_POINT                                               ((FIT_MESG_NUM)150)
#define FIT_MESG_NUM_SEGMENT_FILE                                                ((FIT_MESG_NUM)151)
#define FIT_MESG_NUM_WORKOUT_SESSION                                             ((FIT_MESG_NUM)158)
#define FIT_MESG_NUM_WATCHFACE_SETTINGS                                          ((FIT_MESG_NUM)159)
#define FIT_MESG_NUM_GPS_METADATA                                                ((FIT_MESG_NUM)160)
#define FIT_MESG_NUM_CAMERA_EVENT                                                ((FIT_MESG_NUM)161)
#define FIT_MESG_NUM_TIMESTAMP_CORRELATION                                       ((FIT_MESG_NUM)162)
#define FIT_MESG_NUM_GYROSCOPE_DATA                                              ((FIT_MESG_NUM)164)
#define FIT_MESG_NUM_ACCELEROMETER_DATA                                          ((FIT_MESG_NUM)165)
#define FIT_MESG_NUM_THREE_D_SENSOR_CALIBRATION                                  ((FIT_MESG_NUM)167)
#define FIT_MESG_NUM_VIDEO_FRAME                                                 ((FIT_MESG_NUM)169)
#define FIT_MESG_NUM_OBDII_DATA                                                  ((FIT_MESG_NUM)174)
#define FIT_MESG_NUM_NMEA_SENTENCE                                               ((FIT_MESG_NUM)177)
#define FIT_MESG_NUM_AVIATION_ATTITUDE                                           ((FIT_MESG_NUM)178)
#define FIT_MESG_NUM_VIDEO                                                       ((FIT_MESG_NUM)184)
#define FIT_MESG_NUM_VIDEO_TITLE                                                 ((FIT_MESG_NUM)185)
#define FIT_MESG_NUM_VIDEO_DESCRIPTION                                           ((FIT_MESG_NUM)186)
#define FIT_MESG_NUM_VIDEO_CLIP                                                  ((FIT_MESG_NUM)187)
#define FIT_MESG_NUM_OHR_SETTINGS                                                ((FIT_MESG_NUM)188)
#define FIT_MESG_NUM_EXD_SCREEN_CONFIGURATION                                    ((FIT_MESG_NUM)200)
#define FIT_MESG_NUM_EXD_DATA_FIELD_CONFIGURATION                                ((FIT_MESG_NUM)201)
#define FIT_MESG_NUM_EXD_DATA_CONCEPT_CONFIGURATION                              ((FIT_MESG_NUM)202)
#define FIT_MESG_NUM_FIELD_DESCRIPTION                                           ((FIT_MESG_NUM)206)
#define FIT_MESG_NUM_DEVELOPER_DATA_ID                                           ((FIT_MESG_NUM)207)
#define FIT_MESG_NUM_MAGNETOMETER_DATA                                           ((FIT_MESG_NUM)208)
#define FIT_MESG_NUM_BAROMETER_DATA                                              ((FIT_MESG_NUM)209)
#define FIT_MESG_NUM_ONE_D_SENSOR_CALIBRATION                                    ((FIT_MESG_NUM)210)
#define FIT_MESG_NUM_SET                                                         ((FIT_MESG_NUM)225)
#define FIT_MESG_NUM_STRESS_LEVEL                                                ((FIT_MESG_NUM)227)
#define FIT_MESG_NUM_DIVE_SETTINGS                                               ((FIT_MESG_NUM)258)
#define FIT_MESG_NUM_DIVE_GAS                                                    ((FIT_MESG_NUM)259)
#define FIT_MESG_NUM_DIVE_ALARM                                                  ((FIT_MESG_NUM)262)
#define FIT_MESG_NUM_EXERCISE_TITLE                                              ((FIT_MESG_NUM)264)
#define FIT_MESG_NUM_DIVE_SUMMARY                                                ((FIT_MESG_NUM)268)
#define FIT_MESG_NUM_MFG_RANGE_MIN                                               ((FIT_MESG_NUM)0xFF00) // 0xFF00 - 0xFFFE reserved for manufacturer specific messages
#define FIT_MESG_NUM_MFG_RANGE_MAX                                               ((FIT_MESG_NUM)0xFFFE) // 0xFF00 - 0xFFFE reserved for manufacturer specific messages
#define FIT_MESG_NUM_COUNT                                                       88


#define FIT_FILE_ID_MESG_SIZE                                                   35
#define FIT_FILE_ID_MESG_DEF_SIZE                                               26
#define FIT_FILE_ID_MESG_PRODUCT_NAME_COUNT                                     20

typedef struct
{
   FIT_UINT32Z serial_number; //
   FIT_DATE_TIME time_created; // Only set for files that are can be created/erased.
   FIT_STRING product_name[FIT_FILE_ID_MESG_PRODUCT_NAME_COUNT]; // Optional free form string to indicate the devices name or model
   FIT_MANUFACTURER manufacturer; //
   FIT_UINT16 product; //
   FIT_UINT16 number; // Only set for files that are not created/erased.
   FIT_FILE type; //
} FIT_FILE_ID_MESG;

typedef FIT_UINT8 FIT_FILE_ID_FIELD_NUM;

#define FIT_FILE_ID_FIELD_NUM_SERIAL_NUMBER ((FIT_FILE_ID_FIELD_NUM)3)
#define FIT_FILE_ID_FIELD_NUM_TIME_CREATED ((FIT_FILE_ID_FIELD_NUM)4)
#define FIT_FILE_ID_FIELD_NUM_PRODUCT_NAME ((FIT_FILE_ID_FIELD_NUM)8)
#define FIT_FILE_ID_FIELD_NUM_MANUFACTURER ((FIT_FILE_ID_FIELD_NUM)1)
#define FIT_FILE_ID_FIELD_NUM_PRODUCT ((FIT_FILE_ID_FIELD_NUM)2)
#define FIT_FILE_ID_FIELD_NUM_NUMBER ((FIT_FILE_ID_FIELD_NUM)5)
#define FIT_FILE_ID_FIELD_NUM_TYPE ((FIT_FILE_ID_FIELD_NUM)0)

typedef enum
{
   FIT_FILE_ID_MESG_SERIAL_NUMBER,
   FIT_FILE_ID_MESG_TIME_CREATED,
   FIT_FILE_ID_MESG_PRODUCT_NAME,
   FIT_FILE_ID_MESG_MANUFACTURER,
   FIT_FILE_ID_MESG_PRODUCT,
   FIT_FILE_ID_MESG_NUMBER,
   FIT_FILE_ID_MESG_TYPE,
   FIT_FILE_ID_MESG_FIELDS
} FIT_FILE_ID_MESG_FIELD;

typedef struct
{
   FIT_UINT8 reserved_1;
   FIT_UINT8 arch;
   FIT_MESG_NUM global_mesg_num;
   FIT_UINT8 num_fields;
   FIT_UINT8 fields[FIT_FILE_ID_MESG_FIELDS * FIT_FIELD_DEF_SIZE];
} FIT_FILE_ID_MESG_DEF;



#define FIT_RECORD_MESG_SIZE                                                    99
#define FIT_RECORD_MESG_DEF_SIZE                                                149
#define FIT_RECORD_MESG_COMPRESSED_SPEED_DISTANCE_COUNT                         3
#define FIT_RECORD_MESG_SPEED_1S_COUNT                                          5

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

typedef FIT_UINT8 FIT_RECORD_FIELD_NUM;

#define FIT_RECORD_FIELD_NUM_TIMESTAMP ((FIT_RECORD_FIELD_NUM)253)
#define FIT_RECORD_FIELD_NUM_POSITION_LAT ((FIT_RECORD_FIELD_NUM)0)
#define FIT_RECORD_FIELD_NUM_POSITION_LONG ((FIT_RECORD_FIELD_NUM)1)
#define FIT_RECORD_FIELD_NUM_DISTANCE ((FIT_RECORD_FIELD_NUM)5)
#define FIT_RECORD_FIELD_NUM_TIME_FROM_COURSE ((FIT_RECORD_FIELD_NUM)11)
#define FIT_RECORD_FIELD_NUM_TOTAL_CYCLES ((FIT_RECORD_FIELD_NUM)19)
#define FIT_RECORD_FIELD_NUM_ACCUMULATED_POWER ((FIT_RECORD_FIELD_NUM)29)
#define FIT_RECORD_FIELD_NUM_ENHANCED_SPEED ((FIT_RECORD_FIELD_NUM)73)
#define FIT_RECORD_FIELD_NUM_ENHANCED_ALTITUDE ((FIT_RECORD_FIELD_NUM)78)
#define FIT_RECORD_FIELD_NUM_ALTITUDE ((FIT_RECORD_FIELD_NUM)2)
#define FIT_RECORD_FIELD_NUM_SPEED ((FIT_RECORD_FIELD_NUM)6)
#define FIT_RECORD_FIELD_NUM_POWER ((FIT_RECORD_FIELD_NUM)7)
#define FIT_RECORD_FIELD_NUM_GRADE ((FIT_RECORD_FIELD_NUM)9)
#define FIT_RECORD_FIELD_NUM_COMPRESSED_ACCUMULATED_POWER ((FIT_RECORD_FIELD_NUM)28)
#define FIT_RECORD_FIELD_NUM_VERTICAL_SPEED ((FIT_RECORD_FIELD_NUM)32)
#define FIT_RECORD_FIELD_NUM_CALORIES ((FIT_RECORD_FIELD_NUM)33)
#define FIT_RECORD_FIELD_NUM_VERTICAL_OSCILLATION ((FIT_RECORD_FIELD_NUM)39)
#define FIT_RECORD_FIELD_NUM_STANCE_TIME_PERCENT ((FIT_RECORD_FIELD_NUM)40)
#define FIT_RECORD_FIELD_NUM_STANCE_TIME ((FIT_RECORD_FIELD_NUM)41)
#define FIT_RECORD_FIELD_NUM_BALL_SPEED ((FIT_RECORD_FIELD_NUM)51)
#define FIT_RECORD_FIELD_NUM_CADENCE256 ((FIT_RECORD_FIELD_NUM)52)
#define FIT_RECORD_FIELD_NUM_TOTAL_HEMOGLOBIN_CONC ((FIT_RECORD_FIELD_NUM)54)
#define FIT_RECORD_FIELD_NUM_TOTAL_HEMOGLOBIN_CONC_MIN ((FIT_RECORD_FIELD_NUM)55)
#define FIT_RECORD_FIELD_NUM_TOTAL_HEMOGLOBIN_CONC_MAX ((FIT_RECORD_FIELD_NUM)56)
#define FIT_RECORD_FIELD_NUM_SATURATED_HEMOGLOBIN_PERCENT ((FIT_RECORD_FIELD_NUM)57)
#define FIT_RECORD_FIELD_NUM_SATURATED_HEMOGLOBIN_PERCENT_MIN ((FIT_RECORD_FIELD_NUM)58)
#define FIT_RECORD_FIELD_NUM_SATURATED_HEMOGLOBIN_PERCENT_MAX ((FIT_RECORD_FIELD_NUM)59)
#define FIT_RECORD_FIELD_NUM_HEART_RATE ((FIT_RECORD_FIELD_NUM)3)
#define FIT_RECORD_FIELD_NUM_CADENCE ((FIT_RECORD_FIELD_NUM)4)
#define FIT_RECORD_FIELD_NUM_COMPRESSED_SPEED_DISTANCE ((FIT_RECORD_FIELD_NUM)8)
#define FIT_RECORD_FIELD_NUM_RESISTANCE ((FIT_RECORD_FIELD_NUM)10)
#define FIT_RECORD_FIELD_NUM_CYCLE_LENGTH ((FIT_RECORD_FIELD_NUM)12)
#define FIT_RECORD_FIELD_NUM_TEMPERATURE ((FIT_RECORD_FIELD_NUM)13)
#define FIT_RECORD_FIELD_NUM_SPEED_1S ((FIT_RECORD_FIELD_NUM)17)
#define FIT_RECORD_FIELD_NUM_CYCLES ((FIT_RECORD_FIELD_NUM)18)
#define FIT_RECORD_FIELD_NUM_LEFT_RIGHT_BALANCE ((FIT_RECORD_FIELD_NUM)30)
#define FIT_RECORD_FIELD_NUM_GPS_ACCURACY ((FIT_RECORD_FIELD_NUM)31)
#define FIT_RECORD_FIELD_NUM_ACTIVITY_TYPE ((FIT_RECORD_FIELD_NUM)42)
#define FIT_RECORD_FIELD_NUM_LEFT_TORQUE_EFFECTIVENESS ((FIT_RECORD_FIELD_NUM)43)
#define FIT_RECORD_FIELD_NUM_RIGHT_TORQUE_EFFECTIVENESS ((FIT_RECORD_FIELD_NUM)44)
#define FIT_RECORD_FIELD_NUM_LEFT_PEDAL_SMOOTHNESS ((FIT_RECORD_FIELD_NUM)45)
#define FIT_RECORD_FIELD_NUM_RIGHT_PEDAL_SMOOTHNESS ((FIT_RECORD_FIELD_NUM)46)
#define FIT_RECORD_FIELD_NUM_COMBINED_PEDAL_SMOOTHNESS ((FIT_RECORD_FIELD_NUM)47)
#define FIT_RECORD_FIELD_NUM_TIME128 ((FIT_RECORD_FIELD_NUM)48)
#define FIT_RECORD_FIELD_NUM_STROKE_TYPE ((FIT_RECORD_FIELD_NUM)49)
#define FIT_RECORD_FIELD_NUM_ZONE ((FIT_RECORD_FIELD_NUM)50)
#define FIT_RECORD_FIELD_NUM_FRACTIONAL_CADENCE ((FIT_RECORD_FIELD_NUM)53)
#define FIT_RECORD_FIELD_NUM_DEVICE_INDEX ((FIT_RECORD_FIELD_NUM)62)

typedef enum
{
   FIT_RECORD_MESG_TIMESTAMP,
   FIT_RECORD_MESG_POSITION_LAT,
   FIT_RECORD_MESG_POSITION_LONG,
   FIT_RECORD_MESG_DISTANCE,
   FIT_RECORD_MESG_TIME_FROM_COURSE,
   FIT_RECORD_MESG_TOTAL_CYCLES,
   FIT_RECORD_MESG_ACCUMULATED_POWER,
   FIT_RECORD_MESG_ENHANCED_SPEED,
   FIT_RECORD_MESG_ENHANCED_ALTITUDE,
   FIT_RECORD_MESG_ALTITUDE,
   FIT_RECORD_MESG_SPEED,
   FIT_RECORD_MESG_POWER,
   FIT_RECORD_MESG_GRADE,
   FIT_RECORD_MESG_COMPRESSED_ACCUMULATED_POWER,
   FIT_RECORD_MESG_VERTICAL_SPEED,
   FIT_RECORD_MESG_CALORIES,
   FIT_RECORD_MESG_VERTICAL_OSCILLATION,
   FIT_RECORD_MESG_STANCE_TIME_PERCENT,
   FIT_RECORD_MESG_STANCE_TIME,
   FIT_RECORD_MESG_BALL_SPEED,
   FIT_RECORD_MESG_CADENCE256,
   FIT_RECORD_MESG_TOTAL_HEMOGLOBIN_CONC,
   FIT_RECORD_MESG_TOTAL_HEMOGLOBIN_CONC_MIN,
   FIT_RECORD_MESG_TOTAL_HEMOGLOBIN_CONC_MAX,
   FIT_RECORD_MESG_SATURATED_HEMOGLOBIN_PERCENT,
   FIT_RECORD_MESG_SATURATED_HEMOGLOBIN_PERCENT_MIN,
   FIT_RECORD_MESG_SATURATED_HEMOGLOBIN_PERCENT_MAX,
   FIT_RECORD_MESG_HEART_RATE,
   FIT_RECORD_MESG_CADENCE,
   FIT_RECORD_MESG_COMPRESSED_SPEED_DISTANCE,
   FIT_RECORD_MESG_RESISTANCE,
   FIT_RECORD_MESG_CYCLE_LENGTH,
   FIT_RECORD_MESG_TEMPERATURE,
   FIT_RECORD_MESG_SPEED_1S,
   FIT_RECORD_MESG_CYCLES,
   FIT_RECORD_MESG_LEFT_RIGHT_BALANCE,
   FIT_RECORD_MESG_GPS_ACCURACY,
   FIT_RECORD_MESG_ACTIVITY_TYPE,
   FIT_RECORD_MESG_LEFT_TORQUE_EFFECTIVENESS,
   FIT_RECORD_MESG_RIGHT_TORQUE_EFFECTIVENESS,
   FIT_RECORD_MESG_LEFT_PEDAL_SMOOTHNESS,
   FIT_RECORD_MESG_RIGHT_PEDAL_SMOOTHNESS,
   FIT_RECORD_MESG_COMBINED_PEDAL_SMOOTHNESS,
   FIT_RECORD_MESG_TIME128,
   FIT_RECORD_MESG_STROKE_TYPE,
   FIT_RECORD_MESG_ZONE,
   FIT_RECORD_MESG_FRACTIONAL_CADENCE,
   FIT_RECORD_MESG_DEVICE_INDEX,
   FIT_RECORD_MESG_FIELDS
} FIT_RECORD_MESG_FIELD;

typedef struct
{
   FIT_UINT8 reserved_1;
   FIT_UINT8 arch;
   FIT_MESG_NUM global_mesg_num;
   FIT_UINT8 num_fields;
   FIT_UINT8 fields[FIT_RECORD_MESG_FIELDS * FIT_FIELD_DEF_SIZE];
} FIT_RECORD_MESG_DEF;

