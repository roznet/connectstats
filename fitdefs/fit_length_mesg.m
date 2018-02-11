// Unknown: FIT_MESSAGE_INDEX MessageIndex (unit: None)
FIT_GET_NUMUNIT_FIELD( @"Timestamp", GetTimestamp, FIT_DATE_TIME_INVALID, @"dimensionless" );
FIT_GET_ENUM_FIELD( @"Event", GetEvent, FIT_EVENT_INVALID, FIT_EVENT, @"FIT_EVENT" );
FIT_GET_ENUM_FIELD( @"EventType", GetEventType, FIT_EVENT_TYPE_INVALID, FIT_EVENT_TYPE, @"FIT_EVENT_TYPE" );
FIT_GET_NUMUNIT_FIELD( @"StartTime", GetStartTime, FIT_DATE_TIME_INVALID, @"dimensionless" );
FIT_GET_NUMUNIT_FIELD( @"SumDuration", GetTotalElapsedTime, FIT_FLOAT32_INVALID, @"second" );
FIT_GET_NUMUNIT_FIELD( @"SumElapsedDuration", GetTotalTimerTime, FIT_FLOAT32_INVALID, @"second" );
FIT_GET_NUMUNIT_FIELD( @"TotalStrokes", GetTotalStrokes, FIT_UINT16_INVALID, @"dimensionless" );
FIT_GET_NUMUNIT_FIELD( @"WeightedMeanSpeed", GetAvgSpeed, FIT_FLOAT32_INVALID, @"mps" );
FIT_GET_ENUM_FIELD( @"SwimStroke", GetSwimStroke, FIT_SWIM_STROKE_INVALID, FIT_SWIM_STROKE, @"FIT_SWIM_STROKE" );
FIT_GET_NUMUNIT_FIELD( @"AvgSwimmingCadence", GetAvgSwimmingCadence, FIT_UINT8_INVALID, @"dimensionless" );
FIT_GET_NUMUNIT_FIELD( @"EventGroup", GetEventGroup, FIT_UINT8_INVALID, @"dimensionless" );
FIT_GET_NUMUNIT_FIELD( @"SumEnergy", GetTotalCalories, FIT_UINT16_INVALID, @"kilocalorie" );
FIT_GET_ENUM_FIELD( @"LengthType", GetLengthType, FIT_LENGTH_TYPE_INVALID, FIT_LENGTH_TYPE, @"FIT_LENGTH_TYPE" );
FIT_GET_NUMUNIT_FIELD( @"PlayerScore", GetPlayerScore, FIT_UINT16_INVALID, @"dimensionless" );
FIT_GET_NUMUNIT_FIELD( @"OpponentScore", GetOpponentScore, FIT_UINT16_INVALID, @"dimensionless" );
FIT_GET_NUMUNIT_FIELD( @"NumStrokeCount", GetNumStrokeCount, FIT_UINT8_INVALID, @"dimensionless" );
FIT_GET_NUMUNIT_FIELD( @"NumZoneCount", GetNumZoneCount, FIT_UINT8_INVALID, @"dimensionless" );
