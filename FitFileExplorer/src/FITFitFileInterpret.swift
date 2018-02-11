//
//  FITFitFileInterpret.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 08/11/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import Foundation

class FITFitFileInterpret: NSObject {

    private let fitFile:FITFitFile
    
    public lazy var activityType : String = {
        if let sport = self.fitFile["sport"]?[0]?["sport"].enumValue {
            return sport
        }
        return "all"
    }()
    
    init(fitFile file:FITFitFile){
        fitFile = file
        super.init()
    }
    
    /// Extract data from a fields message into GCField and numbers, 
    /// will skip unknown fields
    ///
    /// - Parameter fitMessageFields: fields to convert
    /// - Returns: dictionary
    func summaryValues(fitMessageFields:FITFitMessageFields) -> [GCField:GCActivitySummaryValue] {
        var rv :[GCField:GCActivitySummaryValue] = [:]
        for field in fitMessageFields {
            if let key = field as? String,
                let v = self.summaryValue(fitField: fitMessageFields[key]),
                let f = fieldKey(fitField: key){
                rv[ f ] = v
            }
        }
        
        return rv
    }
    
    /// Extract a data serie for a message and a field
    ///
    /// - Parameters:
    ///   - message: Valid message in the fitFile
    ///   - fieldX: field for the x data
    ///   - fieldY: field for the y data
    /// - Returns: data serie or nil if missing field, message or wrong type
    func statsDataSerie(message :String, fieldX : String, fieldY :String) -> GCStatsDataSerieWithUnit? {
        if let messages :FITFitMessage = self.fitFile[message] {
            var xy : [Double] = []
            
            var xunit : GCUnit?
            var yunit : GCUnit?
            
            for msg in messages {
                if let message = msg as? FITFitMessageFields,
                    let fitFieldX = message[fieldX],
                    let fitFieldY = message[fieldY] {
                    
                    var validx :Double? = nil;
                    var validy :Double? = nil;
                    
                    if let datex = fitFieldX.dateValue {
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
            if( message == "lap" && fieldX == "start_time"){
                
                if let message = messages.last(), let total_time = message["total_elapsed_time"],
                    let seconds = total_time.numberWithUnit?.value,
                    let lastX = message[fieldX].dateValue?.addingTimeInterval(seconds){
                    xy.append(contentsOf: [ lastX.timeIntervalSinceReferenceDate, 0.0])
                }
            }
            
            if xy.count > 0{
                if let xunit = xunit, let yunit = yunit {
                    let serie = GCStatsDataSerie(arrayOfDouble: xy as [NSNumber])
                    return GCStatsDataSerieWithUnit(yunit, xUnit: xunit, andSerie: serie)
                }
            }
        }
        return nil
    }
    
    func coordinatePoints(message:String,field:String) -> [CLLocationCoordinate2D]?{
        var rv : [CLLocationCoordinate2D]?
        
        if let messages :FITFitMessage = self.fitFile[message] {
            var coords : [CLLocationCoordinate2D] = []
            
            for msg in messages {
                if let message = msg as? FITFitMessageFields,
                    let fitField = message[field]{
                    if let coord = fitField.locationValue {
                        coords.append(coord.coordinate)
                    }
                }
            }
            if coords.count > 0{
                rv = coords
            }
        }
        return rv
    }
    
    func summaryValue(fitField : FITFitFieldValue) -> GCActivitySummaryValue? {
        var rv : GCActivitySummaryValue?
        let key = fitField.fieldKey
        if let activityField = fieldKey(fitField: key),
            let nwu = fitField.numberWithUnit {
            
            var nu = nwu
            
            // do a couple of standard corrections
            if activityType == GC_TYPE_RUNNING && nu.unit == GCUnit.rpm() {
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
    
    func fieldKey(fitField:String) -> GCField?{
        let found = FITFitEnumMap.activityField(fromFitField: fitField, forActivityType: self.activityType)
        
        return found
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
                    let index = fromField.index(after: prefix.endIndex)
                    
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
    
    func statsForMessage(message:String, interval : (from:Date,to:Date)?) -> [String:FITFitValueStatistics]{
        let stats = FITFitFieldsStatistics(interval:interval)
        var weights = FITFitStatisticsWeight(count: 0, distance: 0, time: 0)
        var lastItem : FITFitMessageFields?
        
        if let messages :FITFitMessage = self.fitFile[message] {
            
            for item in messages {
                if let fields = item as? FITFitMessageFields{
                    let increment = FITFitStatisticsWeight(from: lastItem, to: fields, withTimeField: "timestamp", withDistanceField: "position")
                    stats.add(messageFields: fields, weight: increment)
                    weights = weights.add(increment: increment)
                    lastItem = fields
                    
                }
            }
        }
        return stats.stats
    }
}
