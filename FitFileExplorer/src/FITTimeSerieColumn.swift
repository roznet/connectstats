//  MIT License
//
//  Created on 26/11/2018 for FitFileExplorer
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



import Cocoa

class FITTimeSerieColumn: NSObject {

    var unit : GCUnit = GCUnit.dimensionless()
    var data : [Double] = []
    var dates : [Date] = []
    
    func add(number : GCNumberWithUnit, forDate : Date){
        let converted = number
        if self.unit != converted.unit{
            if( self.data.count == 0){
                self.unit = converted.unit
            }else{
                converted.convert(to: self.unit)
            }
        }
        
        if dates.count == 0 || dates.last! < forDate {
            data.append(converted.value)
            dates.append(forDate)
        }else if( dates.first! > forDate){
            data.insert(converted.value, at: 0)
            dates.insert(forDate, at: 0)
        }
    }
}
