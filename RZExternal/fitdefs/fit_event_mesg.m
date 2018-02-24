FIT_GET_NUMUNIT_FIELD( @"Timestamp", GetTimestamp, FIT_DATE_TIME_INVALID, @"second" );
FIT_GET_ENUM_FIELD( @"Event", GetEvent, FIT_EVENT_INVALID, FIT_EVENT, @"FIT_EVENT" );
FIT_GET_ENUM_FIELD( @"EventType", GetEventType, FIT_EVENT_TYPE_INVALID, FIT_EVENT_TYPE, @"FIT_EVENT_TYPE" );
FIT_GET_NUMUNIT_FIELD( @"Data16", GetData16, FIT_UINT16_INVALID, @"dimensionless" );
FIT_GET_ENUM_FIELD( @"TimerTrigger", GetTimerTrigger, FIT_TIMER_TRIGGER_INVALID, FIT_TIMER_TRIGGER, @"FIT_TIMER_TRIGGER" );
// Unknown: FIT_MESSAGE_INDEX CoursePointIndex (unit: None)
FIT_GET_NUMUNIT_FIELD( @"BatteryLevel", GetBatteryLevel, FIT_FLOAT32_INVALID, @"dimensionless" );
FIT_GET_NUMUNIT_FIELD( @"VirtualPartnerSpeed", GetVirtualPartnerSpeed, FIT_FLOAT32_INVALID, @"mps" );
FIT_GET_NUMUNIT_FIELD( @"HrHighAlert", GetHrHighAlert, FIT_UINT8_INVALID, @"bpm" );
FIT_GET_NUMUNIT_FIELD( @"HrLowAlert", GetHrLowAlert, FIT_UINT8_INVALID, @"bpm" );
FIT_GET_NUMUNIT_FIELD( @"SpeedHighAlert", GetSpeedHighAlert, FIT_FLOAT32_INVALID, @"mps" );
FIT_GET_NUMUNIT_FIELD( @"SpeedLowAlert", GetSpeedLowAlert, FIT_FLOAT32_INVALID, @"mps" );
FIT_GET_NUMUNIT_FIELD( @"CadHighAlert", GetCadHighAlert, FIT_UINT16_INVALID, @"rpm" );
FIT_GET_NUMUNIT_FIELD( @"CadLowAlert", GetCadLowAlert, FIT_UINT16_INVALID, @"rpm" );
FIT_GET_NUMUNIT_FIELD( @"PowerHighAlert", GetPowerHighAlert, FIT_UINT16_INVALID, @"watt" );
FIT_GET_NUMUNIT_FIELD( @"PowerLowAlert", GetPowerLowAlert, FIT_UINT16_INVALID, @"watt" );
FIT_GET_NUMUNIT_FIELD( @"TimeDurationAlert", GetTimeDurationAlert, FIT_FLOAT32_INVALID, @"second" );
FIT_GET_NUMUNIT_FIELD( @"DistanceDurationAlert", GetDistanceDurationAlert, FIT_FLOAT32_INVALID, @"meter" );
FIT_GET_ENUM_FIELD( @"FitnessEquipmentState", GetFitnessEquipmentState, FIT_FITNESS_EQUIPMENT_STATE_INVALID, FIT_FITNESS_EQUIPMENT_STATE, @"FIT_FITNESS_EQUIPMENT_STATE" );
FIT_GET_ENUM_FIELD( @"RiderPosition", GetRiderPosition, FIT_RIDER_POSITION_TYPE_INVALID, FIT_RIDER_POSITION_TYPE, @"FIT_RIDER_POSITION_TYPE" );
// Unknown: FIT_COMM_TIMEOUT_TYPE CommTimeout (unit: None)
FIT_GET_NUMUNIT_FIELD( @"EventGroup", GetEventGroup, FIT_UINT8_INVALID, @"dimensionless" );
FIT_GET_NUMUNIT_FIELD( @"Score", GetScore, FIT_UINT16_INVALID, @"dimensionless" );
FIT_GET_NUMUNIT_FIELD( @"OpponentScore", GetOpponentScore, FIT_UINT16_INVALID, @"dimensionless" );
// Unknown: FIT_DEVICE_INDEX DeviceIndex (unit: None)
