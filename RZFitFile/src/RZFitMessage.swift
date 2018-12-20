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
