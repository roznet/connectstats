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
