//
//  FITFitFieldsStatistics.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 31/12/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import Foundation
import RZFitFile

class FITFitFieldsStatistics: NSObject {
    
    var stats : [RZFitFieldKey:FITFitValueStatistics] = [:]
    var interval : (from:Date,to:Date)?
    var timestampKey : RZFitFieldKey = "timestamp"
    
    init(interval:(from:Date,to:Date)?) {
        self.interval = interval
        super.init()
    }
    
    func add(message : RZFitMessage, weight: FITFitStatisticsWeight) {
        // if interval is setup, just skip if outside.
        if let interval = self.interval,
            let ts = message.time(field: self.timestampKey){
            if ts < interval.from || ts > interval.to{
                return
            }
        }
        let interp = message.interpretedFields()
        
        for (key,value) in interp {
            
            if let stat = stats[key]{
                stat.add(fieldValue: value, weight: weight)
            }else{
                let stat = FITFitValueStatistics()
                stats[key] = stat
                stat.add(fieldValue: value, weight: weight)
            }
        }
    }
}
