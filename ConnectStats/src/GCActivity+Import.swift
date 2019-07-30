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
    
    @objc convenience init?(withId activityId:String, fitFilePath:String, startTime: Date?){
        if let fit = RZFitFile(file: URL(fileURLWithPath: fitFilePath)) {
            self.init(withId: activityId, fitFile: fit, startTime: startTime)
        }else{
            return nil
        }
    }
    
    convenience init(withId activityId:String, fitFile:RZFitFile, startTime: Date?){
        self.init(id: activityId)
        let interp  = FITFitFileInterpret(fitFile: fitFile)
        
        var messages = fitFile.messages(forMessageType: FIT_MESG_NUM_SESSION)

        // First if more than one session isolate the session relevant for startTime
        var messageIndex = 0;
        
        var sessionStart : Date?
        var sessionEnd   : Date?
        
        // If multiple session messsages and start time given, pick the matching session
        if let startTime = startTime {
            for message in messages {
                if let messageStart = message.interpretedField(key: "start_time")?.time{
                    if messageStart == startTime {
                        sessionStart = messageStart
                        sessionEnd   = message.time()
                        break;
                    }
                }
                messageIndex+=1;
            }
        }
        // if not found or no date, use first session
        if( messageIndex >= messages.count){
            messageIndex = 0;
        }
        
        self.activityName = ""
        self.location = ""

        // Multi sport and no startTime do total stats on all
        // the sessions
        if( messages.count > 1 && startTime == nil){
            let type = GCActivityType.multisport()
            self.activityType = type.key
            self.activityTypeDetail = type
            
            let stats = interp.summaryValueFromStatsForMessage(messageType: FIT_MESG_NUM_SESSION, interval: nil)
            
            self.mergeSummaryData(stats)
            
        }else if messageIndex < messages.count {
            interp.update(sessionIndex: messageIndex)
            
            let type  = interp.activityType
            self.activityType = type.topSubRoot().key
            self.activityTypeDetail = type
            
            let usemessage = messages[messageIndex]
            var sumValues = interp.summaryValues(fitMessage: usemessage)
            let toremove = sumValues.filter {
                $1.uom == "datetime"
            }
            for (key,_) in toremove{
                sumValues.removeValue(forKey: key)
            }
            self.mergeSummaryData(sumValues)
            
            if let start = usemessage.time(field: "start_time"){
                self.date = start
            }
        }
        
        messages = fitFile.messages(forMessageType: FIT_MESG_NUM_RECORD)
        var trackpoints : [GCTrackPoint] = []
        for item in messages{
            if  let timestamp = item.time(field: "timestamp") {
                if let checkStart = sessionStart, let checkEnd = sessionEnd {
                    if timestamp < checkStart || timestamp > checkEnd {
                        continue;
                    }
                }
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
        
        messages = fitFile.messages(forMessageType: FIT_MESG_NUM_LAP)
        var laps : [GCLap] = []
        
        for item in messages {
            if let timestamp = item.time( field: "start_time") {
                if let checkStart = sessionStart, let checkEnd = sessionEnd {
                    if timestamp < checkStart || timestamp > checkEnd {
                        continue;
                    }
                }

                let values = interp.summaryValues(fitMessage: item)
                // coordinate will be update from
                
                let start = item.coordinate(field: "start_position") ?? CLLocationCoordinate2DMake(0, 0)
                if let lap = GCLap(summaryValues: values, starting: timestamp, at: start, for: self) {
                    laps.append(lap)
                }
            }
        }
        
        messages = fitFile.messages(forMessageType: FIT_MESG_NUM_LENGTH)
        if messages.count > 0 {
            for item in messages {
                if let timestamp = item.time( field: "start_time") {
                    if let checkStart = sessionStart, let checkEnd = sessionEnd {
                        if timestamp < checkStart || timestamp > checkEnd {
                            continue;
                        }
                    }
                    
                }
            }
        }
        
        // Don't save to db
        self.update(withTrackpoints:trackpoints,andLaps:laps)
    }

     func mergeFrom(other : GCActivity){
        //let fields = self.availableTrackFields()
        //let otherFields = other.self.availableTrackFields()
        
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
