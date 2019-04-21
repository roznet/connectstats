//
//  FITFitValueStatistics.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 31/12/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import Foundation
import RZFitFile

class FITFitValueStatistics: NSObject {

    enum StatsType : String {
        case avg = "avg", total = "total", min = "min", max = "max", count = "count"
    }
    
    var distanceMeters : Double = 0
    var timeSeconds : Double = 0
    
    var sum : GCNumberWithUnit? = nil
    var count : UInt = 0
    var max : GCNumberWithUnit? = nil
    var min : GCNumberWithUnit? = nil
    
    var nonZeroSum :GCNumberWithUnit? = nil
    var nonZeroCount : UInt = 0
    
    func value(stats: StatsType, field: RZFitFieldKey?) -> GCNumberWithUnit?{
        
        switch stats {
        case StatsType.avg:
            return self.sum?.numberWithUnitMultiplied(by: 1.0/Double(self.count))
        case StatsType.total:
            if let field = field {
                if field.hasSuffix("distance"){
                    return GCNumberWithUnit(GCUnit.meter(), andValue: self.distanceMeters)
                }
                else if field.hasSuffix("time"){
                    return GCNumberWithUnit(GCUnit.second(), andValue: self.timeSeconds)
                }else{
                    return self.sum
                }
            }else {
                return self.sum
            }
        case StatsType.count:
            return GCNumberWithUnit(GCUnit.dimensionless(), andValue: Double(self.count))
        case StatsType.max:
            return self.max
        case StatsType.min:
            return self.min
        }
    }
    
    func preferredStatisticsForField(fieldKey : RZFitFieldKey) -> [StatsType] {
        if( fieldKey.hasPrefix("total")){
            return [StatsType.total,StatsType.count]
        }else if( fieldKey.hasPrefix("max") || fieldKey.hasPrefix("avg") || fieldKey.hasPrefix("min")){
            return [StatsType.avg,StatsType.count,StatsType.max,StatsType.min]
        }else{
            if let field = FITFitEnumMap.activityField(fromFitField: fieldKey, forActivityType: nil){
                if field.isWeightedAverage() || field.isMax() || field.isMin() || field.validForGraph(){
                    return [StatsType.avg,StatsType.count,StatsType.max,StatsType.min]
                }else if field.canSum() {
                    return [StatsType.total,StatsType.count]
                }
            }
        }
        // fall back
        return [StatsType.count]
    }
    
    func add(fieldValue: RZFitFieldValue, weight : FITFitStatisticsWeight){
        if let nu = fieldValue.numberWithUnit {
            self.count += 1
            self.timeSeconds += weight.time
            self.distanceMeters += weight.distance
            if sum == nil {
                self.sum = nu
            }else{
                self.sum = self.sum?.add(nu, weight: 1.0)
            }
            if max == nil {
                self.max = nu
            }else{
                self.max = self.max?.maxNumber(nu)
            }
            if min == nil {
                self.min = nu
            }else{
                self.min = self.min?.minNumber(nu)
            }
            if fabs(nu.value) > 1.0e-8  {
                nonZeroCount += 1
                if nonZeroSum == nil{
                    nonZeroSum = nu
                }else{
                    nonZeroSum = nonZeroSum?.add(nu, weight: 1.0)
                }
            }
        }
    }
    
    
}
