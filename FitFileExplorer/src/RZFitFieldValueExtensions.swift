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
import RZUtils

extension RZFitFieldValue {
    
    var numberWithUnit : GCNumberWithUnit? {
        get {
            var rv : GCNumberWithUnit? = nil
            if let numunit = self.valueUnit {
                if let unit = GCUnit(forFitUnit: numunit.unit) {
                    rv = GCNumberWithUnit(unit: unit, andValue: numunit.value)
                }
            }else if let num = self.value {
                rv = GCNumberWithUnit(unit: GCUnit.dimensionless(), andValue: num)
            }
            return rv
        }
    }

    func displayString() -> String {
        if let coordinate = coordinate {
            return "(\(coordinate.latitude),\(coordinate.longitude))"
        }else if let nu = self.numberWithUnit {
            return nu.formatDouble()
        }else if let name = name {
            return name
        }else if let time = time {
            return "\(time)"
        }else if let value = value {
            return "\(value)"
        }else{
            return "RZFitField(Error)"
        }
    }

    convenience init?(fieldValue : FITFitFieldValue) {
        if let val = fieldValue.numberWithUnit {
            self.init(withValue: val.value, andUnit: val.unit.key)
        }else if let dat = fieldValue.dateValue {
            self.init(withTime: dat)
        }else if let v = fieldValue.enumValue {
            self.init(withName: v)
        }else if let l = fieldValue.locationValue {
            self.init(latitude: l.coordinate.latitude, longitude: l.coordinate.longitude)
        }else if let s = fieldValue.stringValue {
            self.init(withName: s)
        }else{
            return nil
        }
    }
    
}
