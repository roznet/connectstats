//
//  FITFitFileInterpret.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 08/11/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import Foundation
import RZFitFile
import RZFitFileTypes
import GenericJSON

class FITFitFileInterpret: NSObject {

    private let fitFile:RZFitFile
    
    private var sessionIndex = 0
    
    public var activityType : GCActivityType {
        get {
            let sportMsg = self.fitFile.messages(forMessageType: FIT_MESG_NUM_SPORT)
            if self.sessionIndex < sportMsg.count {
                let first = sportMsg[sessionIndex]
                if let sportKey = first.name(field: "sport"),
                    let activityType = GCAppGlobal.activityTypes()?.activityType(forFitSport: sportKey){
                    return activityType
                }
            }
            return GCActivityType.all()
        }
    }
    lazy var fitFieldMap : FITFitFieldMap = {
        return FITFitFieldMap()
    }()
    
    init(fitFile file:RZFitFile){
        fitFile = file
        super.init()
    }
    
    func update(sessionIndex : Int){
        self.sessionIndex = sessionIndex
    }
    
    func summaryValue(fitMessageType: RZFitMessageType, field:String, fitField : RZFitFieldValue) -> GCActivitySummaryValue? {
        var rv : GCActivitySummaryValue?
        let key = field
        if let activityField = fieldKey(fitMessageType: fitMessageType, fitField: key),
            let nwu = fitField.numberWithUnit {
            
            var nu = nwu
            
            // do a couple of standard corrections
            if activityType.key == GC_TYPE_RUNNING && nu.unit == GCUnit.rpm() {
                nu.unit = GCUnit.stepsPerMinute()
            }
            
            // don't keep mps
            if nu.unit == GCUnit.mps(){
                nu = nu.convert(to: GCUnit.kph())
            }
            rv = GCActivitySummaryValue(forField: activityField.key, value: nu)
        }
        
        return rv;
    }
    
    func strokeType( message : RZFitMessage ) -> gcSwimStrokeType? {
        if let stroke = message.interpretedFields()["swim_stroke"]?.name {
            switch stroke {
            case  "freestyle": return gcSwimStrokeType.free;
            case  "backstroke": return gcSwimStrokeType.back;
            case  "breaststroke": return gcSwimStrokeType.breast;
            case  "butterfly": return gcSwimStrokeType.butterfly;
            case  "drill": return gcSwimStrokeType.mixed;
            case  "mixed": return gcSwimStrokeType.mixed;
            case  "im": return gcSwimStrokeType.mixed;
            default: return nil
                
            }
        }
        return nil;
    }
    
    func swimActive( message : RZFitMessage ) -> Bool {
        if let num_active = message.interpretedFields()["num_active_lengths"]?.valueUnit?.value {
            return num_active > 0
        }else if let length_type = message.interpretedFields()["length_type"]?.name {
            return length_type == "active"
        }
        return false
    }
    func fieldKey(fitMessageType: RZFitMessageType, fitField:String) -> GCField?{
        //let found = FITFitEnumMap.activityField(fromFitField: fitField, forActivityType: self.activityType.topSubRoot().key)
        let key = self.fitFieldMap.field(messageType: fitMessageType, fitField: fitField, activityType: self.activityType.topSubRoot().key)
        
        return key
    }
    

    /// Extract data from a fields message into GCField and numbers, 
    /// will skip unknown fields
    ///
    /// - Parameter fitMessageFields: fields to convert
    /// - Returns: dictionary
    func summaryValues(fitMessage:RZFitMessage) -> [GCField:GCActivitySummaryValue] {
        var rv :[GCField:GCActivitySummaryValue] = [:]
        let fitMessageFields = fitMessage.interpretedFields()
        for (key,fitField) in fitMessageFields {
            if  let v = self.summaryValue(fitMessageType:fitMessage.messageType, field: key, fitField: fitField),
                let f = fieldKey(fitMessageType: fitMessage.messageType, fitField: key){
                rv[ f ] = v
            }
        }
        // Few special cases, if speed and not pace, add
        if self.activityType.isPaceValid() {
            if let paceField = GCField( for: gcFieldFlag.weightedMeanSpeed, andActivityType: self.activityType.topSubRoot().key),
                let speedField = GCField( forKey: "WeightedMeanSpeed", andActivityType: self.activityType.topSubRoot().key),
                let speed = rv[ speedField ]{
                if rv[paceField] == nil {
                    let nu = speed.numberWithUnit.convert(to: paceField.unit())
                    rv[paceField] = GCActivitySummaryValue(forField: paceField.key, value: nu)
                }
            }
        }
        
        return rv
    }
    
    typealias NumberPoint = (time:Date, value:GCNumberWithUnit)
    typealias GPSPoint = (time:Date, location:CLLocationCoordinate2D)
    typealias DataSerieColumns = (values:[String:[NumberPoint]], gps:[GPSPoint])
    
    func columnDataSeries(messageType: RZFitMessageType) -> DataSerieColumns {
        var units : [String:GCUnit] = [:]
        var values : [String:[NumberPoint]] = [:]
        var times : [Date] = []
        var gps : [GPSPoint] = []
        
        let messages = self.fitFile.messages(forMessageType: messageType)
        for msg in messages {
            if let time  = msg.time() {
                
                let interp = msg.interpretedFields()
                times.append(time)
                
                if let coord = interp["position"]?.coordinate {
                    gps.append( (time: time, location:coord) )
                }
                
                for (field,value) in interp {
                    if let nu = value.numberWithUnit {
                        var unit = units[field]
                        if unit == nil{
                            unit = nu.unit
                            units[field] = unit
                        }
                        var doubles = values[field]
                        if doubles == nil {
                            doubles = []
                            values[field] = doubles
                        }
                        let converted = nu.convert(to: unit!)
                        values[field]?.append( (time:time, value:converted))
                    }
                }
            }
        }
        return (values:values,gps:gps)
    }
    
    /// Extract a data serie for a message and a field
    ///
    /// - Parameters:
    ///   - message: Valid message in the fitFile
    ///   - fieldX: field for the x data
    ///   - fieldY: field for the y data
    /// - Returns: data serie or nil if missing field, message or wrong type
    func statsDataSerie(messageType :RZFitMessageType, fieldX : String, fieldY :String) -> GCStatsDataSerieWithUnit? {
        let messages = self.fitFile.messages(forMessageType: messageType)
        var xy : [Double] = []
        
        var xunit : GCUnit?
        var yunit : GCUnit?
        
        for msg in messages {
            let message = msg.interpretedFields()
            if  let fitFieldX = message[fieldX],
                let fitFieldY = message[fieldY] {
                
                var validx :Double? = nil;
                var validy :Double? = nil;
                
                if let datex = fitFieldX.time {
                    validx = datex.timeIntervalSinceReferenceDate
                    if( xunit == nil){
                        xunit = GCUnitElapsedSince(datex)
                    }
                }else if let nux = fitFieldX.numberWithUnit{
                    if xunit == nil{
                        xunit = nux.unit
                    }
                    if xunit == nux.unit{
                        validx = nux.value
                    }else{
                        let converted = nux.convert(to: xunit!)
                        validx = converted.value
                    }
                }
                
                if let nuy = fitFieldY.numberWithUnit {
                    if yunit == nil{
                        yunit = nuy.unit
                    }
                    if( yunit == nuy.unit){
                        validy = nuy.value
                    }else{
                        let converted = nuy.convert(to: yunit!)
                        validy = converted.value
                    }
                }
                
                if let x = validx, let y = validy {
                    xy.append(contentsOf: [x,y])
                }
            }
        }
        // Special case
        if( messageType == FIT_MESG_NUM_LAP && fieldX == "start_time"){
            
            if let message = messages.last?.interpretedFields(),
                let total_time = message["total_elapsed_time"],
                let seconds = total_time.numberWithUnit?.value,
                let lastX = message[fieldX]?.time?.addingTimeInterval(seconds){
                xy.append(contentsOf: [ lastX.timeIntervalSinceReferenceDate, 0.0])
            }
        }
        
        if xy.count > 0{
            if let xunit = xunit, let yunit = yunit {
                let serie = GCStatsDataSerie(arrayOfDouble: xy as [NSNumber])
                return GCStatsDataSerieWithUnit(yunit, xUnit: xunit, andSerie: serie)
            }
        }

        return nil
    }
    
    func coordinatePoints(messageType:RZFitMessageType,field:String) -> [CLLocationCoordinate2D]?{
        var rv : [CLLocationCoordinate2D]?
        
        let messages = self.fitFile.messages(forMessageType: messageType)
        var coords : [CLLocationCoordinate2D] = []
        
        for msg in messages {
            let message = msg.interpretedFields()
            if let fitField = message[field],
                let coord = fitField.coordinate{
                coords.append(coord)
            }
        }
        
        if coords.count > 0{
            rv = coords
        }
        
        return rv
    }
    
    func mapFields(from: [String], to:[String]) -> [String:[String]] {
        var rv : [String:[String]] = [:]
        let prefixes = ["total_", "avg_", "max_", "min_", "enhanced_avg", "enhanced_", "enhanced_avg_", "enhanced_max_"]
        
        for fromField in from {
            // First if exists as is, just add
            var found :[String] = []
            if to.contains( fromField ){
                found.append(fromField)
            }

            // For each prefix, see if the field with the prefix exist,
            // then if the field starts with the prefix, see if the field without exists.
            for prefix in prefixes {
                let tryField =  prefix + fromField
                if to.contains(tryField){
                    found.append(tryField);
                }
                if fromField.hasPrefix(prefix){
                    //let index = fromField.index(after: prefix.endIndex)
                    let index = prefix.endIndex
                    
                    let withoutPrefix = String(fromField[index...])  //  .substring(from: index)
                    if to.contains(withoutPrefix){
                        found.append(withoutPrefix)
                    }
                    // now check after swapping prefix
                    for toPrefix in prefixes{
                        if toPrefix != prefix{
                            let toWithPrefix = toPrefix + withoutPrefix
                            if to.contains(toWithPrefix){
                                found.append(toWithPrefix)
                            }
                        }
                    }
                }
            }
            
            rv[fromField] = found
        }
        return rv
    }
    
    func messageForTimestamp(messageType:RZFitMessageType, timestamp:Date) -> RZFitMessage?{
        var rv : RZFitMessage? = nil
        let messages = self.fitFile.messages(forMessageType: messageType)
        for msg in messages  {
            if let ts = msg.time() {
                if( ts == timestamp ){
                    rv = msg;
                    break
                }
                
                if let start = msg.time(field: "start_time") {
                    if( start <= timestamp && timestamp <= ts){
                        rv = msg
                        break;
                    }
                }
            }
        }
        
        return rv
    }
    
    func summaryValueFromStatsForMessage(messageType:RZFitMessageType, interval : (from:Date,to:Date)?) -> [GCField:GCActivitySummaryValue] {
        let stats = self.statsForMessage(messageType: messageType, interval: interval)
        
        var rv : [GCField:GCActivitySummaryValue] = [:]
        
        let multisport = GCActivityType.multisport()
        
        for (fitfield,stat) in stats {
            if fitfield.starts(with: "avg_") || fitfield.starts(with: "total_") || fitfield.starts(with: "max_") {
                
                if let field = FITFitEnumMap.activityField(fromFitField: fitfield, forActivityType: multisport.topSubRoot().key) {
                    var nu : GCNumberWithUnit?
                    if( fitfield.starts(with: "avg_")){
                        nu = stat.value(stats: FITFitValueStatistics.StatsType.avg, field: fitfield)
                    }else if( fitfield.starts(with: "total_")){
                        nu = stat.value( stats: FITFitValueStatistics.StatsType.total, field: fitfield)
                    }else if( fitfield.starts(with: "max_")){
                        nu = stat.value(stats: FITFitValueStatistics.StatsType.max, field: fitfield)
                    }
                    
                    if let nu = nu {
                        rv[field] = GCActivitySummaryValue(forField: field.key, value: nu)
                    }
                }
            }
        }
        
        return rv
    }
    
    func statsForMessage(messageType:RZFitMessageType, interval : (from:Date,to:Date)?) -> [String:FITFitValueStatistics]{
        let stats = FITFitFieldsStatistics(interval:interval)
        var weights = FITFitStatisticsWeight(count: 0, distance: 0, time: 0)
        var lastItem : RZFitMessage? = nil
        
        let messages = self.fitFile.messages(forMessageType: messageType)
        
        var distanceField = "position"
        
        if let first = messages.first {
            if first.interpretedField(key: distanceField) == nil {
                distanceField = "total_distance"
            }
        }
        
        for msg in messages {
            var cond = true
            if let interval = interval {
                cond = msg.has(dateField: "timestamp", after: interval.from, before: interval.to)
            }
            
            if cond {
                let increment = FITFitStatisticsWeight(from: lastItem, to: msg, withTimeField: "timestamp", withDistanceField: distanceField)
                stats.add(message: msg, weight: increment)
                weights = weights.add(increment: increment)
                lastItem = msg
            }
        }
        return stats.stats
    }

}
