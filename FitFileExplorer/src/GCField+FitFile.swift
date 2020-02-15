//
//  GCField+FitFile.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 08/11/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import Foundation
import RZUtilsSwift

public extension GCField {
    
    static let fitToFieldMap = ["cadence":"WeightedMeanCadence",
                                "distance":"SumDistance",
                                "speed":"WeightedMeanSpeed",
                                "temperature":"WeightedMeanAirTemperature",
                                "heart_rate": "WeightedMeanHeartRate",
                      ]

    static func field(fitKey:String, activityType:String) -> GCField? {
        var fieldKey = fitToFieldMap[fitKey]
        if fieldKey == nil{
            RZSLog.warning("Missing \(fitKey)")
            return nil
        }
        // special case for running
        if fitKey == "speed" && activityType == "running" {
            fieldKey = "WeightedMeanPace"
        }
        
        if fieldKey == "WeightedMeanCadence" {
            switch activityType {
            case GC_TYPE_RUNNING: fieldKey = "WeightedMeanRunCadence"
            case GC_TYPE_CYCLING: fieldKey = "WeightedMeanBikeCadence"
            case GC_TYPE_SWIMMING: fieldKey = "WeightedMeanSwimCadence"
            default: _
            }
        }

        return GCField(forKey: fieldKey, andActivityType: activityType)
    }
}
