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

    var fitFilePath : URL? = nil
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
                self.time = self.dates["startDateGMT"] ?? Date()
            }
            else{
                return nil
            }
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
        self.fitFilePath = nil
        self.numbers.merge(with.numbers) { (_,new) in new }
        self.labels.merge(with.labels) { (_,new) in new }
        self.dates.merge(with.dates) { (_,new) in new }
        self.coordinates.merge(with.coordinates) { (_,new) in new }
        self.originalJson = [:]
    }
}
