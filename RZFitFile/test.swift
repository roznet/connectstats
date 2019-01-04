// This file is auto generated, Do not edit
func rzfit_unit_for_field( field : String ) -> String? {
  switch field {
  default: return nil
  }
}
func rzfit_known_units( ) -> [String] {
  return [
  ]
}
func rzfit_field_num_to_field(messageType : FIT_MESG_NUM, fieldNum : FIT_UINT16 ) -> String? {
  switch messageType {
    case FIT_MESG_NUM_RECORD: return rzfit_field_num_for_record(field: fieldNum)
    case FIT_MESG_NUM_LAP: return rzfit_field_num_for_lap(field: fieldNum)
    case FIT_MESG_NUM_SESSION: return rzfit_field_num_for_session(field: fieldNum)
    default: return nil
   }
}
