// This file is auto generated, Do not edit
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
  if x.sport != FIT_SPORT_INVALID  {
    let val : Double = Double(x.sport)
    rv[ "sport" ] = val
  }
  if x.sub_sport != FIT_SUB_SPORT_INVALID  {
    let val : Double = Double(x.sub_sport)
    rv[ "sub_sport" ] = val
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
  if x.rear_gear_num != FIT_UINT8Z_INVALID  {
    let val : Double = Double(x.rear_gear_num)
    rv[ "rear_gear_num" ] = val
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
  return rv
}
func rzfit_device_file_value_dict( ptr : UnsafePointer<FIT_DEVICE_FILE>) -> [String:Double] {
  return [:]
}
func rzfit_device_file_enum_dict( ptr : UnsafePointer<FIT_DEVICE_FILE>) -> [String:String] {
  return [:]
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
  if x.stroke_type != FIT_STROKE_TYPE_INVALID  {
    let val : Double = Double(x.stroke_type)
    rv[ "stroke_type" ] = val
  }
  if x.zone != FIT_UINT8_INVALID  {
    let val : Double = Double(x.zone)
    rv[ "zone" ] = val
  }
  if x.fractional_cadence != FIT_UINT8_INVALID  {
    let val : Double = (Double(x.fractional_cadence))/Double(128)
    rv[ "fractional_cadence" ] = val
  }
  if x.device_index != FIT_DEVICE_INDEX_INVALID  {
    let val : Double = Double(x.device_index)
    rv[ "device_index" ] = val
  }
  return rv
}
func rzfit_record_mesg_enum_dict( ptr : UnsafePointer<FIT_RECORD_MESG>) -> [String:String] {
  var rv : [String:String] = [:]
  let x : FIT_RECORD_MESG = ptr.pointee
  if( x.activity_type != FIT_ACTIVITY_TYPE_INVALID ) {
    rv[ "activity_type" ] = rzfit_activity_type_string(input: x.activity_type)
  }
  return rv
}
func rzfit_hrv_mesg_value_dict( ptr : UnsafePointer<FIT_HRV_MESG>) -> [String:Double] {
  var rv : [String:Double] = [:]
  let x : FIT_HRV_MESG = ptr.pointee
  if x.time[0] != FIT_UINT16_INVALID  {
    let val : Double = (Double(x.time[0]))/Double(1000)
    rv[ "time" ] = val
  }
  return rv
}
func rzfit_hrv_mesg_enum_dict( ptr : UnsafePointer<FIT_HRV_MESG>) -> [String:String] {
  return [:]
}
func rzfit_unit_for_field( field : String ) -> String? {
  switch field {
  case "ball_speed": return "m/s"
  case "right_torque_effectiveness": return "percent"
  case "custom_wheelsize": return "m"
  case "grade": return "%"
  case "saturated_hemoglobin_percent": return "%"
  case "total_hemoglobin_conc": return "g/dL"
  case "speed": return "m/s"
  case "right_pedal_smoothness": return "percent"
  case "temperature": return "C"
  case "total_hemoglobin_conc_max": return "g/dL"
  case "total_hemoglobin_conc_min": return "g/dL"
  case "altitude": return "m"
  case "accumulated_power": return "watts"
  case "odometer": return "m"
  case "power": return "watts"
  case "fractional_cadence": return "rpm"
  case "bike_weight": return "kg"
  case "vertical_oscillation": return "mm"
  case "stance_time": return "ms"
  case "vertical_speed": return "m/s"
  case "cycle_length": return "m"
  case "left_torque_effectiveness": return "percent"
  case "position_long": return "semicircles"
  case "cadence256": return "rpm"
  case "stance_time_percent": return "percent"
  case "timestamp": return "s"
  case "time_from_course": return "s"
  case "left_pedal_smoothness": return "percent"
  case "position_lat": return "semicircles"
  case "saturated_hemoglobin_percent_min": return "%"
  case "power_cal_factor": return "%"
  case "saturated_hemoglobin_percent_max": return "%"
  case "speed_1s": return "m/s"
  case "total_cycles": return "cycles"
  case "combined_pedal_smoothness": return "percent"
  case "time128": return "s"
  case "auto_wheelsize": return "m"
  case "compressed_accumulated_power": return "watts"
  case "calories": return "kcal"
  case "enhanced_speed": return "m/s"
  case "heart_rate": return "bpm"
  case "gps_accuracy": return "m"
  case "cadence": return "rpm"
  case "time": return "s"
  case "cycles": return "cycles"
  case "enhanced_altitude": return "m"
  case "distance": return "m"
  default: return nil
  }
}
