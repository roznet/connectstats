FIT_GET_NUMUNIT_FIELD( @"Timestamp", GetTimestamp, FIT_DATE_TIME_INVALID, @"second" );
// Unknown: FIT_DEVICE_INDEX DeviceIndex (unit: None)
FIT_GET_NUMUNIT_FIELD( @"DeviceType", GetDeviceType, FIT_UINT8_INVALID, @"dimensionless" );
FIT_GET_ENUM_FIELD( @"AntplusDeviceType", GetAntplusDeviceType, FIT_ANTPLUS_DEVICE_TYPE_INVALID, FIT_ANTPLUS_DEVICE_TYPE, @"FIT_ANTPLUS_DEVICE_TYPE" );
FIT_GET_NUMUNIT_FIELD( @"AntDeviceType", GetAntDeviceType, FIT_UINT8_INVALID, @"dimensionless" );
FIT_GET_ENUM_FIELD( @"Manufacturer", GetManufacturer, FIT_MANUFACTURER_INVALID, FIT_MANUFACTURER, @"FIT_MANUFACTURER" );
FIT_GET_NUMUNIT_FIELD( @"Product", GetProduct, FIT_UINT16_INVALID, @"dimensionless" );
// Unknown: FIT_FAVERO_PRODUCT FaveroProduct (unit: None)
FIT_GET_ENUM_FIELD( @"GarminProduct", GetGarminProduct, FIT_GARMIN_PRODUCT_INVALID, FIT_GARMIN_PRODUCT, @"FIT_GARMIN_PRODUCT" );
FIT_GET_NUMUNIT_FIELD( @"SoftwareVersion", GetSoftwareVersion, FIT_FLOAT32_INVALID, @"dimensionless" );
FIT_GET_NUMUNIT_FIELD( @"HardwareVersion", GetHardwareVersion, FIT_UINT8_INVALID, @"dimensionless" );
FIT_GET_NUMUNIT_FIELD( @"BatteryVoltage", GetBatteryVoltage, FIT_FLOAT32_INVALID, @"second" );
// Unknown: FIT_BATTERY_STATUS BatteryStatus (unit: None)
FIT_GET_ENUM_FIELD( @"SensorPosition", GetSensorPosition, FIT_BODY_LOCATION_INVALID, FIT_BODY_LOCATION, @"FIT_BODY_LOCATION" );
// Unknown: FIT_WSTRING Descriptor (unit: None)
FIT_GET_ENUM_FIELD( @"AntNetwork", GetAntNetwork, FIT_ANT_NETWORK_INVALID, FIT_ANT_NETWORK, @"FIT_ANT_NETWORK" );
FIT_GET_ENUM_FIELD( @"SourceType", GetSourceType, FIT_SOURCE_TYPE_INVALID, FIT_SOURCE_TYPE, @"FIT_SOURCE_TYPE" );
// Unknown: FIT_WSTRING ProductName (unit: None)
