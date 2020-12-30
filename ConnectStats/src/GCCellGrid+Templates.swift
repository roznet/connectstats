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

    @objc static func adjustAggregated(dataHolder : GCHistoryAggregatedDataHolder,
                                       activityType : GCActivityType,
                                       geometry : RZNumberWithUnitGeometry ) {
        let fields = activityType.summaryFields()
        
        for field in fields {
            if let nu = dataHolder.preferredNumber(withUnit: field){
                if nu.isValidValue() && nu.value != 0.0 {
                    geometry.adjust(for: nu, numberAttribute: GCViewConfig.attribute(rzAttribute.value), unitAttribute: GCViewConfig.attribute(rzAttribute.unit))
                }
            }
        }
    }
    
    @objc func setupAggregated(dataHolder : GCHistoryAggregatedDataHolder,
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
                     
    @objc func setupActivityDetail(fields : [GCField],
                                   activity : GCActivity,
                                   geometry : RZNumberWithUnitGeometry){
        GCViewConfig.setupGradient(forDetails: self)
        
        
        self.setup(forRows:UInt(fields.count), andCols:2)
        if let field = fields.first?.displayName() {
            let fieldFmt = NSAttributedString(string: field, attributes: GCViewConfig.attribute(rzAttribute.field) )
            self.label(forRow: 0, andCol: 0)?.attributedText = fieldFmt
        }
        
        var fieldAttr = GCViewConfig.attribute(rzAttribute.field)
        var numberAttr = GCViewConfig.attribute(rzAttribute.value)
        var unitAttr = GCViewConfig.attribute(rzAttribute.unit)
        let primaryField = fields.first
        var row : UInt = 0
        
        for field in fields {
            if let numberWithUnit = activity.numberWithUnit(for: field) {
                let cellView = GCCellFieldValueView(numberWithUnit: numberWithUnit,
                                                    geometry: geometry,
                                                    field: field,
                                                    primaryField: primaryField,
                                                    icon: .hide)
                cellView.fieldAttribute = fieldAttr
                cellView.numberAttribute = numberAttr
                cellView.unitAttribute = unitAttr
                cellView.displayField = .right
                cellView.geometry.timeAlignment = .withNumber
                self.setupView(cellView, forRow: row, andColumn: 1)
                if( row != 0){
                    //self.label(forRow: row, andCol: 0)?.attributedText = NSAttributedString(string: field.displayName(withPrimary: primaryField), attributes: fieldAttr)
                    self.config(forRow: row, andCol: 0)?.horizontalAlign = gcHorizontalAlign.right
                }
            }
            row += 1
            fieldAttr = GCViewConfig.attribute(rzAttribute.secondaryField)
            numberAttr = GCViewConfig.attribute(rzAttribute.secondaryValue)
            unitAttr = GCViewConfig.attribute(rzAttribute.secondaryUnit)

        }
        
    }
}
