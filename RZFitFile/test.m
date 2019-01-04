// This file is auto generated, Do not edit

#include "test.h"

NSString * objc_rzfit_field_num_to_field( FIT_MESG_NUM messageType, FIT_UINT16 field ) {
  switch (messageType) {
    case FIT_MESG_NUM_RECORD: return objc_rzfit_field_num_for_record(field);
    case FIT_MESG_NUM_LAP: return objc_rzfit_field_num_for_lap(field);
    case FIT_MESG_NUM_SESSION: return objc_rzfit_field_num_for_session(field);
    default: return nil;
   }
}
