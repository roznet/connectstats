//
//  FITFitFieldsStatistics.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 31/12/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import Foundation

class FITFitFieldsStatistics: NSObject {
    
    var stats : [String:FITFitValueStatistics] = [:]
    var interval : (from:Date,to:Date)?
    var timestampKey : String = "timestamp"
    
    init(interval:(from:Date,to:Date)?) {
        self.interval = interval
        super.init()
    }
    
    func add(messageFields : FITFitMessageFields, weight: FITFitStatisticsWeight) {
        // if interval is setup, just skip if outside.
        if let interval = self.interval,
            let ts = messageFields[self.timestampKey]?.dateValue{
            if ts < interval.from || ts > interval.to{
                return
            }
        }

        for item in messageFields {
            if let key = item as? String,
                let value :FITFitFieldValue = messageFields[key]{
                
                if let stat = stats[value.fieldKey]{
                    stat.add(fieldValue: value, weight: weight)
                }else{
                    let stat = FITFitValueStatistics()
                    stats[value.fieldKey] = stat
                    stat.add(fieldValue: value, weight: weight)
                }
            }
        }
    }
}
