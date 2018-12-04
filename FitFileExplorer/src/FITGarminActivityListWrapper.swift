//  MIT License
//
//  Created on 22/11/2018 for FitFileExplorer
//
//  Copyright (c) 2018 Brice Rosenzweig
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

extension FITGarminActivityListWrapper : Sequence {
    
    public func makeIterator() -> NSFastEnumerationIterator {
        return NSFastEnumerationIterator(self)
    }
    
    func buildColumnView() -> [String:FITTimeSerieColumn] {
        var rv : [String:FITTimeSerieColumn] = [:]
        
        for one : FITGarminActivityWrapper in self.list {
            for iter in one.summary {
                
                var col = rv[iter.key]
                if col == nil {
                    col = FITTimeSerieColumn()
                    rv[iter.key] = col
                }
                col?.add(number: iter.value, forDate: one.time)
            }
            
        }
        return rv
    }
    
    func saveRowView(db : FMDatabase){

        var units : [String:GCUnit] = [:]
        for one in self.list {
            for iter in one.summary {
                var currentUnit = units[iter.key]
                if currentUnit == nil {
                    currentUnit = iter.value.unit
                }
                currentUnit = currentUnit?.commonUnit(iter.value.unit)
                units[iter.key] = currentUnit
                
            }
        }
        
        db.executeUpdate("DROP TABLE IF EXISTS units", withArgumentsIn: [])
        db.executeUpdate("CREATE TABLE units (columnName TEXT, unit TEXT)", withArgumentsIn: [])

        for (column,unit) in units {
            db.executeUpdate("INSERT INTO units (columnName,unit) VALUES (?,?)", withArgumentsIn:[column,unit])
        }

        var valuekeys : [String] = Array(units.keys)
        
        func sortKey(l:String,r:String) -> Bool {
            if let fl = GCField(forKey: l, andActivityType: GC_TYPE_ALL)?.sortOrder(),
                let fr = GCField(forKey: r, andActivityType: GC_TYPE_ALL)?.sortOrder() {
                return fl < fr;
            }else{
                return l < r;
            }
        }
        let orderedkeys = valuekeys.sorted(by: sortKey )
        let columndefs =  orderedkeys.map({ "\($0) REAL" }).joined(separator: ", ")
        let columnlist = orderedkeys.joined(separator: ", ")
        let columnvalues = orderedkeys.map({":\($0)"}).joined(separator: ", ")
        
        db.executeUpdate("DROP TABLE IF EXistS rows", withArgumentsIn: [])
        db.executeUpdate("CREATE TABLE  rows (activityId TEXT,activityType TEXT,date REAL, \(columndefs))", withArgumentsIn: [])

        for one in self.list {
            
            let sql = "INSERT INTO rows (activityId,activityType,date,\(columnlist)) VALUES('\(one.activityId)','\(one.activityType)',:date,\(columnvalues))"
            
            var values : [String:Any] = ["date":one.time]
            for key in orderedkeys{
                if let val = one[key],
                    let unit = units[key]{
                    values[key] = val.convert(to: unit).value
                }else{
                    values[key] = NSNull()
                }
            }
            
            db.executeUpdate(sql, withParameterDictionary: values)
        }
        
    }
    
    func saveColumnView(db :FMDatabase){
        let colview = self.buildColumnView()
        if( !db.tableExists("definition_columns")){
            db.executeUpdate("CREATE TABLE definition_columns (columnName TEXT,unit TEXT)", withArgumentsIn: [])
        }

        if( !db.tableExists("index_activityId")){
            db.executeUpdate("CREATE TABLE definition_columns (activityId TEXT,activityType TEXT,time REAL)", withArgumentsIn: [])
        }

        for one in colview {
            let columnTable = "column_" + one.key
            
            if( !db.tableExists(columnTable)){
                db.executeUpdate("CREATE TABLE \(columnTable) (time REAL,value REAL)", withArgumentsIn: [])
            }
            
            
        }
    }
}
