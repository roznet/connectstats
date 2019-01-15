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

class ActivitiesOrganizer {
    typealias ParseResult = (total:Int, updated:Int)
    
    private var activityMap :[ActivityId:Activity]
    
    private(set) var activityList : [Activity]
    
    init() {
        activityList = []
        activityMap  = [:]
    }
    
    init?(json:JSON){
        activityList = []
        activityMap  = [:]
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
            var list : [Activity] = self.activityList
            var map  : [ActivityId:Activity] = self.activityMap
            for one in acts {
                
                if let info = one.objectValue,
                    let act = Activity(json: info) {
                    rv.total += 1
                    
                    if let existing = map[act.activityId] {
                        if( existing.update(with:act) ){
                            rv.updated += 1
                        }
                    }else{
                        list.append(act)
                        map[act.activityId] = act
                        rv.updated += 1
                    }
                }
            }
            if( rv.updated > 0 ){
                self.activityMap = map
                self.activityList = list.sorted {
                    $1.time < $0.time
                }
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
    
    func remove(activityIds:[ActivityId]) -> Int {
        let filtered = self.activityList.filter{
            !activityIds.contains($0.activityId)
        }
        let rv = self.activityList.count - filtered.count
        if( rv != 0){
            self.activityList = filtered
            for aid in activityIds {
                self.activityMap.removeValue(forKey: aid)
            }
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
            if let found = activityMap[activity.activityId] {
                if( found.update(with: activity) ){
                    rv += 1
                }
            }else{
                activityList.append(activity)
                activityMap[activity.activityId] = activity
                rv += 1
            }
        }
        
        return rv
    }
    
    private func reorder() {
        activityList.sort {
            $1.time < $0.time
        }
    }
    
    func sample() -> Activity {
        let rv = Activity()
        for act in self.activityList {
            rv.merge(with: act)
        }
        return rv
    }
    
}
