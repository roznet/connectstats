//  MIT License
//
//  Created on 31/10/2021 for ConnectStats
//
//  Copyright (c) 2021 Brice Rosenzweig
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
import RZUtilsSwift

class GCWebRequestCache {
    
    let db : FMDatabase
    let classname : String
    
    typealias CacheCallback = (Data) -> Bool
    
    init(db : FMDatabase, classname : String){
        self.db = db
        self.classname = classname
    }
    
    func save(data : Data, filename : String){
        let cacheFile = "cache_\(self.classname)_\(filename)"
        
        do {
            try data.write(to: URL(fileURLWithPath: RZFileOrganizer.writeableFilePath(cacheFile)), options: .atomic)
            try db.executeUpdate("INSERT INTO gc_notification_cache (cache_file,request_class,received) VALUES (?,?,?)", values: [cacheFile,classname, NSDate()])
        }catch{
            RZSLog.error("Failed to cache data for \(filename) and \(classname): \(error)")
        }
    }
    
    @discardableResult
    func retrieve(cb : CacheCallback) -> Bool{
        var notificationid : Int? = nil
        var rv = false
        var cache_file : String? = nil
        if let res = db.executeQuery("SELECT notification_id,cache_file FROM gc_notification_cache WHERE processed IS NULL AND request_class = ? ORDER BY received LIMIT 1", withArgumentsIn: [classname]) {
            if ( res.next() ){
                notificationid = Int(res.longLongInt(forColumn: "notification_id"))
                if let filename = res.string(forColumn: "cache_file"),
                   let data = try? Data(contentsOf: URL(fileURLWithPath: RZFileOrganizer.writeableFilePath(filename))) {
                    cache_file = filename
                    rv = cb(data)
                }
            }
        }
        if let cache_file = cache_file {
            if( !db.executeUpdate("UPDATE gc_notification_cache SET processed = ? WHERE request_class = ? AND cache_file = ?", withArgumentsIn: [NSDate(), classname, cache_file]) ){
                RZSLog.error("failed to mark notification \(db.lastErrorMessage())")
            }
        }
        else if let notificationid = notificationid {
            if( !db.executeUpdate("UPDATE gc_notification_cache SET processed = ? WHERE notification_id = \(notificationid)", withArgumentsIn: [NSDate()]) ){
                RZSLog.error("failed to mark notification \(db.lastErrorMessage())")
            }
        }
        return rv
    }
    
    static func ensureDbStructure(db : FMDatabase) {
        if( !db.tableExists("gc_notification_cache") ){
            if( !db.executeUpdate("CREATE TABLE gc_notification_cache (notification_id INTEGER PRIMARY KEY, cache_file TEXT, request_class TEXT, notification_info TEXT, received REAL, processed REAL )", withArgumentsIn: [])){
                RZSLog.error("Failed to create notification table \(String(describing: db.lastErrorMessage))")
            }
        }
    }

}
