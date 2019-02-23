//
//  GCActivity+Import.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 24/11/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import Foundation
import CoreLocation
import RZFitFile
import RZFitFileTypes

extension GCActivity {
    
    @objc convenience init?(withId activityId:String, fitFilePath:String){
        if let fit = RZFitFile(file: URL(fileURLWithPath: fitFilePath)) {
            self.init(withId: activityId, fitFile: fit)
        }else{
            return nil
        }
    }
    
    convenience init(withId activityId:String, fitFile:RZFitFile){
        self.init(id: activityId)
        let interp  = FITFitFileInterpret(fitFile: fitFile)
        
        let type  = interp.activityType
        self.activityType = type.topSubRoot().key
        self.activityTypeDetail = type
        self.activityName = ""
        self.location = ""
        
        var messages = fitFile.messages(forMessageType: FIT_MESG_NUM_SESSION)
        if messages.count > 0{
            if let firstmessage = messages.first {
                var sumValues = interp.summaryValues(fitMessage: firstmessage)
                let toremove = sumValues.filter {
                    $1.uom == "datetime"
                }
                for (key,_) in toremove{
                    sumValues.removeValue(forKey: key)
                }
                self.mergeSummaryData(sumValues)
                
                if let start = firstmessage.time(field: "StartTime"){
                    self.date = start
                }
            }
        }
        
        messages = fitFile.messages(forMessageType: FIT_MESG_NUM_RECORD)
        var trackpoints : [GCTrackPoint] = []
        for item in messages{
            if  let timestamp = item.time(field: "timestamp") {
                let values = interp.summaryValues(fitMessage: item)
                var coord = CLLocationCoordinate2DMake(0, 0)
                
                if let icoord = item.coordinate(field: "position") {
                    coord = icoord
                }
                if let point = GCTrackPoint(coordinate2D: coord, at: timestamp, for: values, in: self) {
                    trackpoints.append(point)
                    self.trackFlags |= point.trackFlags
                }
            }
        }
        // Don't save to db
        self.trackpoints = trackpoints
        self.updateSummary(fromTrackpoints: trackpoints, missingOnly: true)
    }

     func mergeFrom(other : GCActivity){
        let fields = self.availableTrackFields()
        let otherFields = other.self.availableTrackFields()
        
        if let to = self.trackpoints, let from = other.trackpoints {
            var i = from.makeIterator()
            if var merge = i.next() {
                var tryMore = true
                var count = 0

                for point in to {
                    
                    while( tryMore && merge.time < point.time){
                        if let more = i.next() {
                            merge = more
                        }else{
                            tryMore = false
                        }
                    }
                    if( merge.time == point.time){
                        count+=1
                    }
                }
                //RZSLog.info("\(count)/\(to.count) \(from.count)")
            }
        }
    }
}
