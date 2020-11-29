//  MIT License
//
//  Created on 20/11/2020 for ConnectStats
//
//  Copyright (c) 2020 Brice Rosenzweig
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

extension GCCellGrid {

    @objc static func adjust(geometry : RZNumberWithUnitGeometry,
                      dataHolder : GCHistoryAggregatedDataHolder,
                      activityType : GCActivityType){
        let fields = activityType.summaryFields()
        
        for field in fields {
            if let nu = dataHolder.preferredNumber(withUnit: field){
                if nu.isValidValue() && nu.value != 0.0 {
                    geometry.adjust(for: nu, numberAttribute: GCViewConfig.attribute(rzAttribute.value), unitAttribute: GCViewConfig.attribute(rzAttribute.unit))
                }
            }
        }
    }
    
    @objc func setup(with dataHolder : GCHistoryAggregatedDataHolder,
                     index : Int,
                     multiFieldConfig : GCStatsMultiFieldConfig,
                     activityType : GCActivityType,
                     geometry : RZNumberWithUnitGeometry,
                     wide :Bool = false){
        let colCount : UInt = wide ? 5 : 3
        let rowCount : UInt = wide ? 2 : 3

        self.setup(forRows: rowCount, andCols:colCount)
        if( index % 2 == 0){
            GCViewConfig.setupGradient(forCellsEven: self)
        }else{
            GCViewConfig.setupGradient(forCellsOdd: self)
        }
        
        if let date = dataHolder.date {
            let dateFmt = multiFieldConfig.calendarConfig.formattedDate(date)
            let dateAttributed = NSAttributedString(string: dateFmt, attributes: GCViewConfig.attribute(rzAttribute.field))
            self.label(forRow: 0, andCol: 0)?.attributedText = dateAttributed
        }
        
        let fields = activityType.summaryFields()
        var row : UInt = 0
        var col : UInt = 1
        let mainCount : UInt = 2
        var fieldIdx : UInt = 0
        
        for field in fields {
            if let nu = dataHolder.preferredNumber(withUnit: field){
                if nu.isValidValue() && nu.value != 0.0 {
                    let cellView = GCCellFieldValueView(numberWithUnit: nu,
                                                        geometry: geometry,
                                                        field: nil)
                    if fieldIdx < mainCount {
                        cellView.fieldAttribute = GCViewConfig.attribute(rzAttribute.field)
                        cellView.numberAttribute = GCViewConfig.attribute(rzAttribute.value)
                        cellView.unitAttribute = GCViewConfig.attribute(rzAttribute.unit)
                    }else{
                        cellView.fieldAttribute = GCViewConfig.attribute(rzAttribute.secondaryField)
                        cellView.numberAttribute = GCViewConfig.attribute(rzAttribute.secondaryValue)
                        cellView.unitAttribute = GCViewConfig.attribute(rzAttribute.secondaryUnit)
                    }
                    self.setupView(cellView, forRow: row, andColumn: col)
                }else{
                    self.reset(forRow: row, andCol: col)
                }
            }
            col += 1
            if( col >= colCount){
                row += 1
                col = 1
            }
            fieldIdx += 1
        }
        
    }
                     
    
}
