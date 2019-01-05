FIT_GET_ENUM_FIELD( @"Type", GetType, FIT_FILE_INVALID, FIT_FILE, @"FIT_FILE" );
FIT_GET_ENUM_FIELD( @"Manufacturer", GetManufacturer, FIT_MANUFACTURER_INVALID, FIT_MANUFACTURER, @"FIT_MANUFACTURER" );
FIT_GET_NUMUNIT_FIELD( @"Product", GetProduct, FIT_UINT16_INVALID, @"dimensionless" );
// Unknown: FIT_FAVERO_PRODUCT FaveroProduct (unit: None)
FIT_GET_ENUM_FIELD( @"GarminProduct", GetGarminProduct, FIT_GARMIN_PRODUCT_INVALID, FIT_GARMIN_PRODUCT, @"FIT_GARMIN_PRODUCT" );
FIT_GET_NUMUNIT_FIELD( @"TimeCreated", GetTimeCreated, FIT_DATE_TIME_INVALID, @"dimensionless" );
FIT_GET_NUMUNIT_FIELD( @"Number", GetNumber, FIT_UINT16_INVALID, @"dimensionless" );
// Unknown: FIT_WSTRING ProductName (unit: None)
