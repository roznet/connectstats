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

class ActivitiesOrganizer {
    
    struct Notifications {
        static let listChange = Notification.Name("activitiesOrganizerListChange")
    }

    struct Repr {
        var activityList : [Activity] = []
        var activityMap :[ActivityId:Activity] = [:]
        var sample : Activity = Activity()
        var units  : [String:GCUnit] = [:]
        
        @discardableResult
        mutating func add(activity:Activity, db : FMDatabase? = nil) -> Bool {
            var rv = false
            
            if let existing = activityMap[activity.activityId] {
                rv = existing.update(with: activity)
                // only delete if existing is different, as it will then be reinserted later
                if( rv ){
                    if let db = db {
                        activity.remove(from: db)
                    }
                }
            }else{
                rv = true
                self.activityList.append(activity)
                self.activityMap[activity.activityId] = activity
            }
            
            if rv {
                sample.merge(with: activity)
                // update unit that don't exist
                for (key,val) in sample.numbers {
                    if self.units[key] == nil {
                        self.units[key] = val.unit
                    }
                }
                if let db = db {
                    sample.ensureTables(db: db)
                    activity.insert(db: db, units: self.units)
                }
            }
            return rv
        }
        
        mutating func remove(activityIds:[ActivityId], db : FMDatabase? = nil) -> Int {
            let filtered = self.activityList.filter{
                !activityIds.contains($0.activityId)
            }
            let rv = self.activityList.count - filtered.count
            if( rv != 0){
                self.activityList = filtered
                for aid in activityIds {
                    if let act = self.activityMap.removeValue(forKey: aid),
                        let db = db {
                        act.remove(from: db)
                    }
                }
            }
            return rv

        }
        
        mutating func reorder() {
            activityList.sort {
                $1.time < $0.time
            }
        }

        mutating func loadUnits(from db:FMDatabase) {
            var units : [String:GCUnit] = [:]
            if let res = db.executeQuery("SELECT * FROM units", withArgumentsIn: []){
                while res.next() {
                    if let name = res.string(forColumn: "name"),
                        let unitname = res.string(forColumn: "unit") {
                        let unit = GCUnit(forKey: unitname)
                        units[ name ] = unit
                    }
                }
            }
            self.units = units
        }
        
        @discardableResult
        mutating func rebuildSample() -> Activity {
            let rv = Activity()
            for act in self.activityList {
                rv.merge(with: act)
            }
            self.sample = rv
            return rv
        }
    }
    
    // MARK: -
    
    typealias ParseResult = (total:Int, updated:Int)
    
    private var repr : Repr
    
    var activityList : [Activity] {
        return repr.activityList
    }
    
    var db : FMDatabase? = nil
    
    var worker : DispatchQueue? = nil
    
    init() {
        self.repr = Repr()
    }
    
    init?(json:JSON){
        self.repr = Repr()

        let result = self.load(json: json)
        if( result.total == 0 ){
            return nil
        }
    }
    
    convenience init?(url: URL){
        if let jsonData = try? Data(contentsOf: url),
            let json = try? JSONDecoder().decode(JSON.self, from: jsonData){
            self.init(json: json)
        }else{
            return nil
        }
    }
    
    convenience init(db : FMDatabase) {
        self.init()
        self.db = db
        self.load(db: db)
        
    }
    
    // MARK: - Database
    
    func load(db: FMDatabase) {
        var total = 0
        if let res = db.executeQuery("SELECT COUNT(*) FROM activities", withArgumentsIn: []),
            res.next(){
            total = Int(res.int(forColumn: "COUNT(*)"))
        }
        
        if db.databasePath() == self.db?.databasePath() && total == self.repr.activityList.count {
            return
        }

        self.db = db
        var newRep = Repr()

        if( total > 0){
            
            if let res = db.executeQuery("SELECT * FROM activities", withArgumentsIn: []) {
                newRep.loadUnits(from: db)
                var counter = 0
                while res.next() {
                    if let act = Activity(res: res, units: newRep.units) {
                        newRep.add(activity: act)
                    }
                    
                    if (total > 100) && (counter == 100) {
                        self.repr = newRep
                        NotificationCenter.default.post(name: Notifications.listChange, object:self)
                    }
                    counter+=1
                }
                
                res.close()
                res.setParentDB(nil)
            }
        }
        self.repr = newRep
        NotificationCenter.default.post(name: Notifications.listChange, object:self)
    }
    
    func save(to db:FMDatabase) {
        
        self.repr.sample.ensureTables(db: db)
            
        for one in self.activityList {
            one.insert(db: db, units: self.repr.units)
        }
    }

    // MARK: - Json
    
    func load(url: URL) -> ParseResult {
        if let jsonData = try? Data(contentsOf: url),
            let json = try? JSONDecoder().decode(JSON.self, from: jsonData){
            return self.load(json: json)
        }
        return (0,0)
    }
    func load(json:JSON) -> ParseResult {
        var rv : ParseResult = (0,0)
        if let acts = json["activityList"]?.arrayValue {
            var newRepr = self.repr
            for one in acts {
                if let info = one.objectValue,
                    let act = Activity(json: info) {
                    rv.total += 1
                    if newRepr.add(activity: act, db: self.db) {
                        rv.updated += 1
                    }
                }
            }
            if( rv.updated > 0 ){
                self.repr = newRepr
                self.repr.reorder()
                NotificationCenter.default.post(name: Notifications.listChange, object:self)
            }
        }
        return rv
    }
    func save(url : URL) throws {
        if let json = try? self.json(),
            let data = try? JSONEncoder().encode(json) {
            try data.write(to: url)
        }
    }
    func json() throws -> JSON {
        let list : JSON = try JSON(activityList.map {
            try $0.json()
        })
        return try JSON( ["activityList":list])
    }
    
    // MARK: - add/remove
    
    func remove(activityIds:[ActivityId]) -> Int {
        let rv = self.repr.remove(activityIds: activityIds, db: self.db)
        
        if( rv > 0){
            NotificationCenter.default.post(name: Notifications.listChange, object:self)
        }
        return rv
        
    }
    func remove(activities:[Activity]) -> Int {
        let ids = activities.map {
            $0.activityId
        }
        return self.remove(activityIds:ids)
    }
    
    func add(activities:[Activity]) -> Int {
        var rv : Int = 0
        
        for activity in activities {
            if self.repr.add(activity: activity) {
                rv += 1
            }
        }
        
        if( rv > 0){
            NotificationCenter.default.post(name: Notifications.listChange, object:self)
        }

        return rv
    }
    
    
    // MARK: - Access
    
    func activity(activityId:ActivityId) -> Activity? {
        return self.repr.activityMap[activityId]
    }
    
    func activity(at : Int) -> Activity? {
        if at < repr.activityList.count {
            return repr.activityList[at]
        }else{
            return nil
        }
    }
    
    var count : Int {
        return repr.activityList.count
    }
    
    func lastestDate() -> Date {
        if let latest = self.activityList.first {
            return latest.time
        }else{
            return Date()
        }
    }

    func earliestDate() -> Date {
        if let earliest = self.activityList.last {
            return earliest.time
        }else{
            return Date()
        }
    }
    
    func sample() -> Activity {
        return self.repr.sample
    }

    func csv() -> [String] {
        let sample = self.sample()
        
        let cols = sample.allKeysOrdered()
        let sampleValues = sample.allValues()
        
        var csv : [String] = []
        var line : [String] = []
        for col in cols {
            if let sample = sampleValues[col] {
                line.append(contentsOf: sample.csvColumns(col: col) )
            }
        }
        csv.append( line.joined(separator: ",") )
        
        var size : Int? = nil
        for activity in self.activityList {
            line = []
            let vals = activity.allValues()
            
            for col in cols {
                if let val = vals[col] {
                    line.append(contentsOf: val.csvValues(ref: sampleValues[col]))
                }else{
                    if let sampleCols = sampleValues[col] {
                        let emptyVals : [String] = sampleCols.csvColumns(col: col).map { _ in "" }
                        line.append(contentsOf: emptyVals)
                    }else{
                        line.append(col)
                    }
                }
            }
            if size == nil {
                size = line.count
            }else{
                if size != line.count {
                    RZSLog.warning("Inconsistent csv line size for organizer \(line.count) != \(size ?? 0)")
                }
            }
            
            csv.append( line.joined( separator: ",") )
        }
        return csv
    }
    
}
