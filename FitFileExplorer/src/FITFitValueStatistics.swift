//
//  FITFitValueStatistics.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 31/12/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import Foundation

class FITFitValueStatistics: NSObject {

    var distanceMeters : Double = 0
    var timeSeconds : Double = 0
    
    var sum : GCNumberWithUnit? = nil
    var count : UInt = 0
    var max : GCNumberWithUnit? = nil
    var min : GCNumberWithUnit? = nil
    
    var nonZeroSum :GCNumberWithUnit? = nil
    var nonZeroCount : UInt = 0
    
    func preferredStatisticsForField(fieldKey : String) -> GCNumberWithUnit? {
        var rv : GCNumberWithUnit? = nil
        if( fieldKey.hasPrefix("total")){
            rv = self.sum
            if( fieldKey.hasSuffix("distance")){
                rv = GCNumberWithUnit(GCUnit.meter(), andValue: self.distanceMeters)
            }
            if( fieldKey.hasSuffix("time")){
                rv = GCNumberWithUnit(GCUnit.second(), andValue: self.timeSeconds)
            }
        }else if( fieldKey.hasPrefix("max")){
            rv = self.max
        }else if( self.sum != nil){
            rv = self.sum?.numberWithUnitMultiplied(by: 1.0/Double(self.count))
        }
        return rv
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
