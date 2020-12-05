//
//  FITFitStatisticsWeight.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 03/06/2017.
//  Copyright © 2017 Brice Rosenzweig. All rights reserved.
//

import Foundation
import FitFileParser

extension CLLocation {
    convenience init?(withCoordinate:CLLocationCoordinate2D?){
        if let coord = withCoordinate {
            self.init(latitude: coord.latitude, longitude: coord.longitude)
        }else{
            return nil
        }
    }
}

struct FITFitStatisticsWeight {
    let count : UInt
    let distance : Double
    let time : TimeInterval
    
    init(){
        self.count = 1
        self.distance = 0.0
        self.time = 0.0
    }
    
    init(count:UInt, distance:Double, time:TimeInterval){
        self.count = count
        self.distance = distance
        self.time = time
    }
    
    init(from:FitMessage?, to:FitMessage?, withTimeField:String, withDistanceField:String) {
        if let to = to, let from = from {
            self.count = 1
            
            if let toAsLocation = CLLocation(withCoordinate: to.coordinate(field: withDistanceField)),
                let fromAsLocation = CLLocation(withCoordinate: from.coordinate(field: withDistanceField)) {
                
                self.distance = toAsLocation.distance(from: fromAsLocation)
                
            }else if let toAsNumber = to.numberWithUnit(field: withDistanceField),
                let fromAsNumber = from.numberWithUnit(field: withDistanceField) {
                self.distance = toAsNumber.convert(to: GCUnit.meter()).value - fromAsNumber.convert(to: GCUnit.meter()).value
            }else{
                self.distance = 0.0
            }
            
            if let toAsDate = to.time(field: withTimeField), let fromAsDate = from.time(field: withTimeField) {
                self.time = toAsDate.timeIntervalSince(fromAsDate)
            }else if let toAsNumber = to.numberWithUnit(field: withTimeField), let fromAsNumber = from.numberWithUnit(field: withTimeField) {
                self.time = toAsNumber.convert(to: GCUnit.second()).value - fromAsNumber.convert(to: GCUnit.second()).value
            }else{
                self.time = 0.0
            }
            
        }else{
            self.count = 1
            self.distance = 0.0
            self.time = 0.0
        }
    }
    
    func add(increment : FITFitStatisticsWeight) -> FITFitStatisticsWeight {
        return FITFitStatisticsWeight(count: self.count + increment.count, distance: self.distance + increment.distance, time: self.time + increment.time)
    }
}

