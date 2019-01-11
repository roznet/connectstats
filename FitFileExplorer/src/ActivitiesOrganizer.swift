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
    
    private var activityMap :[ActivityId:Activity]
    
    private(set) var activityList : [Activity]
    
    init() {
        activityList = []
        activityMap  = [:]
    }
    
    init?(json:JSON){
        activityList = []
        activityMap  = [:]
        if( !self.loadFromJson(json: json) ){
            return nil
        }
    }
    
    func loadFromJson(json:JSON) -> Bool{
        var rv = false
        if let acts = json["activityList"]?.arrayValue {
            var list : [Activity] = []
            var map  : [ActivityId:Activity] = [:]
            for one in acts {
                if let info = one.objectValue,
                    let act = Activity(json: info) {
                    list.append(act)
                    map[act.activityId] = act
                }
            }
            self.activityMap = map
            self.activityList = list
            rv = true
        }
        return rv
    }
    func saveToJson() throws -> JSON {
        let list : JSON = try JSON(activityList.map {
            try $0.json()
        })
        return try JSON( ["activityList":list])
    }
    
    func registerActivities(activities:[Activity]) -> Int {
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
    
    
}
