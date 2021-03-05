//
//  GCActivity+Import.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 24/11/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import Foundation
import CoreLocation
import FitFileParser

extension GCActivity {

    @objc convenience init?(withId activityId:String, fitFileData:Data, fitFilePath:String, startTime: Date?){
        if let fit = FitFile(data: fitFileData, fileURL: URL(fileURLWithPath: fitFilePath)) {
            self.init(withId: activityId, fitFile: fit, startTime: startTime)
        }else{
            return nil
        }
    }

    @objc convenience init?(withId activityId:String, fitFilePath:String, startTime: Date?){
        if let fit = FitFile(file: URL(fileURLWithPath: fitFilePath)) {
            self.init(withId: activityId, fitFile: fit, startTime: startTime)
        }else{
            return nil
        }
    }
    
    convenience init?(withId activityId:String, fitFile:FitFile, startTime: Date?){
        self.init(id: activityId)
        let interp  = FITFitFileInterpret(fitFile: fitFile)
        
        var messages = fitFile.messages(forMessageType: FitMessageType.session)

        // First if more than one session isolate the session relevant for startTime
        var messageIndex = 0;
        
        var sessionStart : Date?
        var sessionEnd   : Date?

        var pool_length : Double = 0.0
        
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
                message.purgeCache()
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
            self.changeActivityType(type)
            //self.activityType = type.key
            //self.activityTypeDetail = type
            
            let stats = interp.summaryValueFromStatsForMessage(messageType: FitMessageType.session, interval: nil)
            
            self.mergeSummaryData(stats)
            
        }else if messageIndex < messages.count {
            interp.update(sessionIndex: messageIndex)
            
            let type  = interp.activityType
            self.changeActivityType(type)
            //self.activityType = type.topSubRoot().key
            //self.activityTypeDetail = type
            let usemessage = messages[messageIndex]
            
            if let pool_length_value = usemessage.interpretedField(key: "pool_length"),
                let one_length = pool_length_value.valueUnit?.value
            {
                pool_length = one_length
            }
            
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
        }else{
            // no session message
            return nil;
        }

        let events = fitFile.messages(forMessageType: FitMessageType.event)
        var timers : [Date:gcTrackEventType] = [:];
        for event in events {
            if let time = event.time(field: "timestamp") {
                var eventtype : gcTrackEventType = []
                switch event.name(field: "event_type") {
                case "stop_all": eventtype = gcTrackEventType.stopAll
                case "start":eventtype = gcTrackEventType.start
                case "stop": eventtype = gcTrackEventType.stop
                case "marker": eventtype = gcTrackEventType.marker
                default: eventtype = []
                }

                timers[time] = eventtype
            }
            event.purgeCache()
        }

        messages = fitFile.messages(forMessageType: FitMessageType.record)
        
        var trackpoints : [GCTrackPoint] = []
        for item in messages{
            if  let timestamp = item.time(field: "timestamp") {
                if let checkStart = sessionStart, let checkEnd = sessionEnd {
                    if timestamp < checkStart || timestamp > checkEnd {
                        continue
                    }
                }
                autoreleasepool {
                    let values = interp.summaryValues(fitMessage: item)
                    var coord = CLLocationCoordinate2DMake(0, 0)
                    
                    if let icoord = item.coordinate(field: "position") {
                        coord = icoord
                    }
                    if let point = GCTrackPoint(coordinate2D: coord, at: timestamp, for: values, in: self) {
                        if let timer = timers[timestamp] {
                            point.recordTrackEventType(timer, in: self)
                        }
                        
                        trackpoints.append(point)
                        self.trackFlags |= point.trackFlags
                    }
                    item.purgeCache()
                }
            }
        }
        

        var swim : Bool = false;
        
        messages = fitFile.messages(forMessageType: FitMessageType.length)
        var swimpoints : [GCTrackPoint] = []
        if messages.count > 0 {
            swim = true
            var distanceInMeters = 0.0;
            let distField = GCField(for: gcFieldFlag.sumDistance, andActivityType: GC_TYPE_SWIMMING)
            for item in messages {
                if let timestamp = item.time( field: "start_time") {
                    if let checkStart = sessionStart, let checkEnd = sessionEnd {
                        if timestamp < checkStart || timestamp > checkEnd {
                            continue;
                        }
                    }
                    
                    var values = interp.summaryValues(fitMessage: item)
                    let stroke = interp.strokeType(message: item) ?? gcSwimStrokeType.mixed
                    let active = interp.swimActive(message: item)
                    // add pool length before of after adding the point?
                    if active {
                        distanceInMeters += pool_length
                    }
                    if let distField = distField {
                        values[ distField ] =
                            GCActivitySummaryValue(for: distField, value: GCNumberWithUnit(GCUnit.meter(), andValue: distanceInMeters))
                    }
                    if let pointswim = GCTrackPoint(at: timestamp,
                                                        stroke:stroke,
                                                        active:active,
                                                        with:values,
                                                        in:self){
                        swimpoints.append(pointswim)
                    }
                }
                item.purgeCache()
            }
        }

        messages = fitFile.messages(forMessageType: FitMessageType.lap)
        var laps : [GCLap] = []
        var lapsSwim : [GCLap] = []
        
        for item in messages {
            if let timestamp = item.time( field: "start_time") {
                if let checkStart = sessionStart, let checkEnd = sessionEnd {
                    if timestamp < checkStart || timestamp > checkEnd {
                        continue;
                    }
                }
                autoreleasepool {
                    let values = interp.summaryValues(fitMessage: item)
                    
                    if swim {
                        let stroke = interp.strokeType(message: item) ?? gcSwimStrokeType.mixed
                        let active = interp.swimActive(message: item)
                        if let lap = GCLap(at: timestamp, stroke: stroke, active: active, with: values, in: self){
                            lapsSwim.append(lap)
                        }
                    }else{
                        let start = item.coordinate(field: "start_position") ?? CLLocationCoordinate2DMake(0, 0)
                        if let lap = GCLap(summaryValues: values, starting: timestamp, at: start, for: self) {
                            laps.append(lap)
                        }
                    }
                    item.purgeCache()
                }
            }
        }
        #if targetEnvironment(simulator)
        interp.reportAlternates()
        #endif

        // Don't save to db
        if swim {
            self.garminSwimAlgorithm = true
            self.update(withTrackpoints:swimpoints,andLaps:lapsSwim)
        }else{
            self.update(withTrackpoints:trackpoints,andLaps:laps)
        }
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
