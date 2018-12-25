//
//  fit_message.swift
//  fittestswift
//
//  Created by Brice Rosenzweig on 19/12/2018.
//  Copyright © 2018 Brice Rosenzweig. All rights reserved.
//

import Foundation


class RZFitMessage {
    
    let num : FIT_MESG_NUM
    let values : [String:Double]
    let enums : [String:String]
    
    init(mesg_num  : FIT_MESG_NUM, mesg_values : [String:Double], mesg_enums : [String:String]) {
        num = mesg_num
        values = mesg_values
        enums = mesg_enums
        
    }
    
    convenience init(mesg_num : FIT_MESG_NUM, withFitFields:[String:RZFitField]) {
        var ivalues : [String:Double] = [:]
        var ienums  : [String:String] = [:]
        
        for (key,field) in withFitFields {
            if let coord = field.coordinate{
                ivalues[ key + "_lat" ] = coord.latitude
                ivalues[ key + "_long" ] = coord.longitude
            }else if let d = field.value {
                ivalues[ key ] = d
            }else if let e = field.name {
                ienums[ key ] = e
            }else if let du = field.valueUnit {
                ivalues[ key ] = du.value
            }else if let da = field.time {
                // Fit file are in seconds since UTC 00:00 Dec 31 1989 = -347241600
                ivalues[ key ] = da.timeIntervalSinceReferenceDate+347241600
            }
        }
        self.init(mesg_num: mesg_num, mesg_values: ivalues, mesg_enums: ienums)
    }
    
    
    func name() -> String?{
        return rzfit_mesg_num_string(input: num)
    }
    
    func interpretFields() -> [String:RZFitField] {
        var rv :[String:RZFitField] = [:]
        
        for (key,val) in values {
            if( key.hasSuffix("_lat") ) {
    
                let lon = key.replacingOccurrences(of: "_lat", with: "_long")
                let newkey = key.replacingOccurrences(of: "_lat", with:"")
                let latitude = val * 180.0/2147483648.0 // SEMICIRCLE_TO_DEGREE
                if var longitude = values[lon] {
                    longitude = longitude * 180.0/2147483648.0 // SEMICIRCLE_TO_DEGREE
                    rv[ newkey ] = RZFitField(latitude: latitude, longitude: longitude)
                }
            }else if( key.hasSuffix( "_long") ){
                // handled by _lat
                continue
            }
            else if( key == "timestamp" || key == "start_time" || key == "local_timestamp"){
                // Fit file are in seconds since UTC 00:00 Dec 31 1989 = -347241600
                let date = Date(timeIntervalSinceReferenceDate: -347241600+val)
                rv[ key ] = RZFitField(withTime: date )
            }
            else if let unit = rzfit_unit_for_field(field: key) {
                rv[ key ]  = RZFitField(withValue: val, andUnit: unit)
            }else if( key == "product" ){
                let product_int : FIT_UINT16 = FIT_UINT16(val)
                if let mapped = rzfit_garmin_product_string(input: product_int ) {
                    rv[ key ] = RZFitField(withName:  mapped)
                }else{
                    rv[ key ] = RZFitField(withName: "\(product_int)")
                }
            }else if( key == "device_type" ){
                let device_type_int = FIT_UINT8(val)
                if let mapped = rzfit_antplus_device_type_string(input: device_type_int) {
                    rv[key] = RZFitField(withName: mapped)
                }else{
                    rv[key] = RZFitField(withName: "\(device_type_int)")
                }
            }else{
                rv[ key ] = RZFitField(withValue: val )
            }
        }
        
        for (key,val) in enums {
            rv[ key ] = RZFitField(withName: val )
        }
        
        return rv
    }
    func description() -> String {
        var rv = [ "FitMessage(" ]
        if let name = self.name() {
            rv.append(name)
        }else{
            rv.append("Unknown")
        }
        rv.append(",")
        rv.append(",\(values.count),\(enums.count))")
        
        return rv.joined(separator: "")
    }
    
    func units() -> [String:String] {
        var rv : [String:String] = [:]
        
        for field in values.keys {
            if let unit = rzfit_unit_for_field(field: field) {
                rv[field] = unit
            }
        }
        return rv
    }
}
