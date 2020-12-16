//  MIT License
//
//  Created on 24/12/2018 for ConnectStats
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
import FitFileParser
import FitFileParserTypes


extension FitMessage {
        
    
    func preferredOrderFieldKeys() -> [FitFieldKey] {
        var rv : [FitFieldKey] = []
        
        rv.append(contentsOf: self.fieldKeysWithTime())
        rv.append(contentsOf: self.fieldKeysWithCoordinate())
        rv.append(contentsOf: self.fieldKeysWithName())
        rv.append(contentsOf: self.fieldKeysWithNumberWithUnit())
        
        return rv
        
    }
    
    func fieldKeysWithCoordinate() -> [FitFieldKey] {
        var rv : [FitFieldKey] = []
        let interp = self.interpretedFields()
        for (key,val) in interp {
            if val.coordinate != nil {
                rv.append(key)
            }
        }
        return rv
    }
    
    func fieldKeysWithNumberWithUnit() -> [FitFieldKey] {
        var rv : [FitFieldKey] = []
        let interp = self.interpretedFields()
        for (key,val) in interp {
            if val.numberWithUnit != nil {
                rv.append(key)
            }
        }
        return rv
    }
    func fieldKeysWithValue() -> [FitFieldKey] {
        var rv : [FitFieldKey] = []
        let interp = self.interpretedFields()
        for (key,val) in interp {
            if val.value != nil {
                rv.append(key)
            }
        }
        return rv
    }

    func fieldKeysWithTime() -> [FitFieldKey] {
        var rv : [FitFieldKey] = []
        let interp = self.interpretedFields()
        for (key,val) in interp {
            if val.time != nil {
                rv.append(key)
            }
        }
        return rv
    }

    func fieldKeysWithName() -> [FitFieldKey] {
        var rv : [FitFieldKey] = []
        let interp = self.interpretedFields()
        for (key,val) in interp {
            if val.name != nil {
                rv.append(key)
            }
        }
        return rv
    }

    func numberWithUnit(field: FitFieldKey) -> GCNumberWithUnit? {
        let interp = self.interpretedFields()
        if let val = interp[field]?.numberWithUnit {
            return val
        }
        return nil
    }
    
    
    func name(field:FitFieldKey) -> String? {
        let interp = self.interpretedFields()
        if let val = interp[field]?.name {
            return val
        }
        return nil
    }
    
    func coordinate(field : FitFieldKey? = nil) -> CLLocationCoordinate2D? {
        let interp = self.interpretedFields()
        var attempts = ["position"]
        
        if let ifield = field {
            attempts = [ifield]
        }
        for one in attempts {
            if let val = interp[one]?.coordinate {
                return val
            }
        }
        
        return nil
    }
    
    
    func time(field : FitFieldKey? = nil) -> Date? {
        let interp = self.interpretedFields()

        var attempts = ["timestamp", "start_time", "local_timestamp"]
        if let ifield = field {
            attempts = [ifield]
        }
        for one in  attempts{
            if let val = interp[one]?.time {
                return val
            }
        }
        return nil
    }
    
    func has(dateField:FitFieldKey, after:Date, before:Date) -> Bool {
        let interp = self.interpretedFields()
        
        if let val = interp[dateField]?.time {
            if val >= after && val < before{
                return true
            }
        }
        return false
    }
}
