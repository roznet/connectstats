//  MIT License
//
//  Created on 06/01/2019 for FitFileExplorer
//
//  Copyright (c) 2019 Brice Rosenzweig
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//



import Foundation
import GenericJSON
import RZUtilsSwift

typealias ActivityId = String

class Activity {
    let activityId : ActivityId
    let activityType : GCActivityType
    let time : Date
    var activityTypeAsString : String {
        return self.activityType.topSubRoot().key
    }
    private(set) var numbers : [String:GCNumberWithUnit]
    private(set) var labels  : [String:String]
    private(set) var dates   : [String:Date]
    private(set) var coordinates : [String:CLLocationCoordinate2D]

    var fitFilePath : URL? {
        if let fp = RZFileOrganizer.writeableFilePathIfExists("\(self.activityId).fit"){
            return URL(fileURLWithPath: fp)
        }
        return nil
    }
    var downloaded : Bool {
        return fitFilePath != nil
    }

    private var originalJson : [String:JSON]
    
    init() {
        self.activityId = "__sample__"
        self.activityType = GCActivityType.all()
        self.numbers = [:]
        self.labels = [:]
        self.dates = [:]
        self.coordinates = [:]
        self.time = Date()
        self.originalJson = [:]
    }
    
    init?(json:[String:JSON]) {
        if let aId = json["activityId"]?.intValue {
            self.activityId = "\(aId)"
            
            if let interp = GarminDataInterpreter(json: json) {
                self.numbers = interp.numbers()
                self.labels  = interp.labels()
                self.dates   = interp.dates()
                self.coordinates = interp.coordinates()
                self.activityType = interp.activityType()
                self.originalJson = interp.json
                if let found =  self.dates["startTimeGMT"] {
                    self.time = found
                }else if let found = self.dates["startDateGMT"] {
                    self.time = found
                }else{
                    self.time = Date()
                }
            }
            else{
                return nil
            }
        }else{
            return nil
        }
    }
    
    init?(res:FMResultSet, units:[String:GCUnit]) {
        
        if let all = res.resultDictionary() {
            self.activityId = res.string(forColumn: "activityId")
            self.activityType = GCActivityType(forKey: res.string(forColumn: "activityType"))
            self.time = res.date(forColumn: "time")
            self.originalJson = [:]
            
            var bld_numbers : [String:GCNumberWithUnit] = [:]
            var bld_dates   : [String:Date] = [:]
            var bld_labels  : [String:String] = [:]
            var bld_coord   : [String:CLLocationCoordinate2D] = [:]
            
            for (key,obj) in all {
                if let key = key as? String {
                    if key != "activityId" && key != "activityType" && key != "time" {
                        if let num = obj as? NSNumber {
                            if key.hasSuffix("_lat") {
                                if let lon = all[ key.replacingOccurrences(of: "_lat", with: "_lon") ] as? NSNumber{
                                    let coordkey = key.replacingOccurrences(of: "_lat", with: "")
                                    bld_coord[coordkey] = CLLocationCoordinate2D(latitude: num.doubleValue, longitude: lon.doubleValue)
                                }
                            }else if( !key.hasSuffix( "_lon")){
                                if let unit = units[key] {
                                    bld_numbers[key] = GCNumberWithUnit(unit, andValue: num.doubleValue)
                                }else{
                                    // must be date
                                    bld_dates[key] = res.date(forColumn: key)
                                }
                            }
                        }else if let str = obj as? NSString {
                            bld_labels[key] = String(str)
                        }else if let dat = obj as? Date {
                            bld_dates[key] = dat
                        }else if let _ = obj as? NSNull {
                            //skip null
                        }else{
                            RZSLog.warning( "unexpected obj \(key)=\(obj)" )
                        }
                    }
                }else{
                    RZSLog.warning( "unexpected key \(key)=\(obj)" )
                }
            }
            
            self.numbers = bld_numbers
            self.coordinates = bld_coord
            self.dates = bld_dates
            self.labels = bld_labels
            
        }else{
            return nil
        }
    }

    func update(with:Activity) -> Bool {
        var rv = false
        
        // can't update if different activityId
        if self.activityId == with.activityId {
            if( self.numbers != with.numbers){
                rv = true
                self.numbers = with.numbers
            }
            if self.labels != with.labels {
                rv = true
                self.labels = with.labels
            }
            if self.dates != with.dates {
                rv = true
                self.dates = with.dates
            }
            // CLCoordinate not Equatable, copy but don't report
            self.coordinates = with.coordinates
        }
        return rv
    }
    
    func json() throws -> JSON {
        return try JSON(self.originalJson)
    }
    
    func merge(with:Activity) {
        self.numbers.merge(with.numbers) { (_,new) in new }
        self.labels.merge(with.labels) { (_,new) in new }
        self.dates.merge(with.dates) { (_,new) in new }
        self.coordinates.merge(with.coordinates) { (_,new) in new }
        self.originalJson = [:]
    }
    
    func allValues() -> [RZFitFieldKey:RZFitFieldValue] {
        var rv : [RZFitFieldKey:RZFitFieldValue] = [:]
        
        rv["activityId"] = RZFitFieldValue(withName: self.activityId)
        rv["activityType"] = RZFitFieldValue(withName: self.activityTypeAsString)
        rv["time"] = RZFitFieldValue(withTime: self.time)
        
        _ = self.labels.map { rv[$0.key] = RZFitFieldValue(withName: $0.value)}
        _ = self.numbers.map { rv[$0.key] = RZFitFieldValue(withValue: $0.value.value, andUnit: $0.value.unit.key)}
        _ = self.coordinates.map { rv[$0.key] = RZFitFieldValue(latitude: $0.value.latitude, longitude: $0.value.longitude) }
        _ = self.dates.map { rv[$0.key] = RZFitFieldValue(withTime: $0.value )}
        
        return rv
    }
    
    func allKeysOrdered() -> [RZFitFieldKey] {
        var rv : [RZFitFieldKey] = ["activityId", "activityType", "time"]
        
        _ = self.dates.map { rv.append( $0.key ) }
        _ = self.labels.map { rv.append( $0.key ) }
        _ = self.coordinates.map { rv.append( $0.key ) }
        _ = self.numbers.map { rv.append( $0.key ) }

        return rv
    }
    
}

extension Activity {
    
    func activityTableName() -> String {
        return "activities"
    }
    
    func fieldTableName() -> String {
        return "units"
    }
    
    func executeQuery( db : FMDatabase, query:String, params:[AnyHashable:Any]) -> FMResultSet? {
        let res = db.executeQuery(query, withParameterDictionary: params)
        if( res == nil){
            let msg = db.lastErrorMessage() ?? "Error without message"
            RZSLog.error("Query Failed with error \(msg), Query \(query)")
        }
        return res
    }

    @discardableResult
    func executeUpdate( db : FMDatabase, query:String, params:[AnyHashable:Any]) -> Bool {
        let rv = db.executeUpdate(query, withParameterDictionary: params)
        if( !rv ){
            let msg = db.lastErrorMessage() ?? "Error without message"
            RZSLog.error("Update Failed with error \(msg), Statement \(query)")
        }
        return rv
    }

    
    func ensureTables(db : FMDatabase) {
        let tableName = self.activityTableName()
        let fieldTableName = self.fieldTableName()
        
        if( !db.tableExists(tableName)) {
            self.executeUpdate( db: db, query: "CREATE TABLE \(tableName) (activityId TEXT PRIMARY KEY, activityType TEXT, time REAL)", params: [:])
        }
        
        if( !db.tableExists(fieldTableName)){
            self.executeUpdate(db: db, query: "CREATE TABLE \(fieldTableName) (name TEXT PRIMARY KEY, unit TEXT)", params: [:])
        }
        
        var cols : [String:String] = [:]
        if let res : FMResultSet = db.getTableSchema(tableName) {
            while (res.next()) {
                cols[ res.string(forColumn: "name") ] = res.string(forColumn: "type")
            }
        }
        
        if let res = self.executeQuery(db: db, query: "SELECT * FROM \(fieldTableName)", params: [:]) {
            while( res.next()){
                cols[ res.string(forColumn: "name")] = res.string(forColumn: "unit")
            }
        }
        
        for (key,nu) in self.numbers {
            if cols[key] == nil {
                self.executeUpdate(db: db, query: "ALTER TABLE \(tableName) ADD COLUMN \(key) REAL DEFAULT NULL", params: [:] )
                self.executeUpdate(db: db, query: "INSERT INTO \(fieldTableName) (name,unit) VALUES ('\(key)','\(nu.unit.key)')", params: [:])
            }
        }
        for (key,_) in self.dates {
            if cols[key] == nil {
                self.executeUpdate(db: db, query: "ALTER TABLE \(tableName) ADD COLUMN \(key) REAL DEFAULT NULL", params: [:])
            }
        }
        
        for (key,_) in self.labels {
            if cols[key] == nil {
                self.executeUpdate(db: db, query: "ALTER TABLE \(tableName) ADD COLUMN \(key) TEXT DEFAULT NULL", params: [:])
            }
        }
        
        for (key,_) in self.coordinates {
            for suf in ["_lat", "_lon"] {
                let sufkey = key + suf
                if cols[sufkey] == nil {
                    self.executeUpdate(db: db, query: "ALTER TABLE \(tableName) ADD COLUMN \(sufkey) REAL DEFAULT NULL", params: [:])
                }
            }
        }
    }
    
    func remove(from db : FMDatabase){
        db.executeUpdate("DELETE * FROM \(self.activityTableName) WHERE activityId = ?", withArgumentsIn: [ self.activityId ])
    }
    
    func insert(db : FMDatabase, units : [String:GCUnit]) {
        var params : [AnyHashable:Any] = [:]
        var columNames : [String] = ["activityId", "activityType", "time"]
        
        params["activityId"] = self.activityId
        params["activityType"] = self.activityType.key
        params["time"] = self.time
        
        for (key,val) in self.numbers {
            if let unit = units[key] {
                let converted = val.convert(to: unit)
                params[key] = NSNumber(value: converted.value)
                columNames.append(key)
            }
        }
        for (key,val) in self.dates {
            params[key] = val
            columNames.append( key)
        }
        
        for (key,val) in self.labels {
            params[key] = val
            columNames.append( key )
        }
        

        for (key,val) in self.coordinates {
            params[key+"_lat"] = Double(val.latitude)
            params[key+"_lon"] = Double(val.longitude)
            columNames.append( key + "_lat" )
            columNames.append( key + "_lon" )
        }
        
        let colNamesExpr = columNames.joined(separator: ",")
        let valExpr = columNames.map { ":\($0)" }.joined(separator: ",")
        
        let statement = "INSERT INTO activities (\(colNamesExpr)) VALUES (\(valExpr))"
        
        self.executeUpdate(db: db, query: statement, params: params)
    }
    
}
