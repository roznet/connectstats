//
//  GCActivity+Import.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 24/11/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import Foundation
import CoreLocation

public extension GCActivity {
    @objc public convenience init(withId activityId:String, fitFile:FITFitFile){
        self.init(id: activityId)
        let interp  = FITFitFileInterpret(fitFile: fitFile)
        self.activityType = interp.activityType
        self.activityTypeDetail = self.activityType
        self.activityName = ""
        self.location = ""
        
        if let message = fitFile["session"]{
            if message.count() > 0{
                let firstmessage = message[0]!
                var sumValues = interp.summaryValues(fitMessageFields: firstmessage)
                let toremove = sumValues.filter {
                    $1.uom == "datetime"
                }
                for (key,_) in toremove{
                    sumValues.removeValue(forKey: key)
                }
                self.mergeSummaryData(sumValues)
                
                if let start = firstmessage["StartTime"]?.dateValue{
                    self.date = start
                }
            }
        }
        
        if let message = fitFile["record"]{
            var trackpoints : [GCTrackPoint] = []
            for item in message{
                if let field = item as? FITFitMessageFields,
                    let timestamp = field["timestamp"]?.dateValue{
                    let values = interp.summaryValues(fitMessageFields: field)
                    var coord = CLLocationCoordinate2DMake(0, 0)
                    
                    if let position :FITFitFieldValue = field["position"],
                        let location = position.locationValue {
                        coord = location.coordinate
                    
                    }
                    if let point = GCTrackPoint(coordinate2D: coord, at: timestamp, for: values, in: self) {
                        trackpoints.append(point)
                    }
                }
            }
            self.saveTrackpoints(trackpoints, andLaps: [])
        }

    }
}
