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

    //MARK: - Aggregated Monthly/Weekly Stats Cells
    
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
                     wide :Bool = false,
                     comparisonHolder: GCHistoryAggregatedDataHolder? = nil
                     ){
        let colCount : UInt = wide ? 5 : 3
        let rowCount : UInt = wide ? 2 : 3

        self.setup(forRows: rowCount, andCols:colCount)
        if( index % 2 == 0){
            GCViewConfig.setupGradient(forCellsEven: self)
        }else{
            GCViewConfig.setupGradient(forCellsOdd: self)
        }
        
        var sign : RZNumberWithUnitGeometry.DisplaySign = .natural
        
        if let date = dataHolder.date {
            let dateFmt = multiFieldConfig.calendarConfig.formattedDate(date)
            let dateAttributed = NSAttributedString(string: dateFmt, attributes: GCViewConfig.attribute(rzAttribute.field))
            self.label(forRow: 0, andCol: 0)?.attributedText = dateAttributed
        }
        
        if let comparisonHolder = comparisonHolder,
           let comparisonDate = comparisonHolder.date {
            let dateFmt = multiFieldConfig.calendarConfig.formattedDate(comparisonDate)
            let dateAttributed = NSAttributedString(string: dateFmt, attributes: GCViewConfig.attribute(rzAttribute.secondaryField))
            let title = multiFieldConfig.calendarConfig.calendarUnit == .month ? "ΔM-1" : "ΔW-1"
            self.label(forRow: 0, andCol: 0)?.attributedText = NSAttributedString(string:title , attributes: GCViewConfig.attribute(rzAttribute.field))
            self.label(forRow: 1, andCol: 0)?.attributedText = dateAttributed
            sign = .always
        }
        
        let fields = activityType.summaryFields()
        var row : UInt = 0
        var col : UInt = 1
        let mainCount : UInt = 2
        var fieldIdx : UInt = 0
        
        for field in fields {
            if var nu = dataHolder.preferredNumber(withUnit: field){
                if nu.isValidValue() && nu.value != 0.0 {
                    if let comparisonHolder = comparisonHolder,
                       let comparisonNu  = comparisonHolder.preferredNumber(withUnit: field){
                        if comparisonNu.unit == nu.unit {
                            switch multiFieldConfig.comparisonMetric {
                            case .percent:
                                nu = GCNumberWithUnit(name: "percent", andValue:  (nu.value/comparisonNu.value - 1.0) * 100.0 )
                            case .valueDifference:
                                nu = GCNumberWithUnit(unit: nu.unit, andValue:  nu.value-comparisonNu.value )
                            default:
                                nu = GCNumberWithUnit(unit: nu.unit, andValue:  nu.value-comparisonNu.value )
                            }
                        }
                    }
                    
                    let cellView = GCCellFieldValueView(numberWithUnit: nu,
                                                        geometry: geometry,
                                                        field: field,
                                                        icon: .left)
                    cellView.sign = sign
                    cellView.displayField = .hide
                    cellView.iconInset = 4.0
                    if fieldIdx < mainCount {
                        cellView.fieldAttribute = GCViewConfig.attribute(rzAttribute.field)
                        cellView.numberAttribute = GCViewConfig.attribute(rzAttribute.value)
                        cellView.unitAttribute = GCViewConfig.attribute(rzAttribute.unit)
                    }else{
                        cellView.fieldAttribute = GCViewConfig.attribute(rzAttribute.secondaryField)
                        cellView.numberAttribute = GCViewConfig.attribute(rzAttribute.secondaryValue)
                        cellView.unitAttribute = GCViewConfig.attribute(rzAttribute.secondaryUnit)
                    }
                    
                    if comparisonHolder != nil {
                        if nu.value > 0 {
                            cellView.numberAttribute[ NSAttributedString.Key.foregroundColor] = UIColor.systemGreen
                        }else{
                            cellView.numberAttribute[ NSAttributedString.Key.foregroundColor] = UIColor.systemRed
                        }
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

    
    @objc func setupAggregatedComparison(dataHolder : GCHistoryAggregatedDataHolder,
                                         comparisonHolder: GCHistoryAggregatedDataHolder?,
                                         index : Int,
                                         multiFieldConfig : GCStatsMultiFieldConfig,
                                         activityType : GCActivityType,
                                         geometry : RZNumberWithUnitGeometry,
                                         wide :Bool = false
    ){
        let fields = activityType.summaryFields()
        
        let colCount : UInt = wide ? 5 : 3
        let rowCount : UInt = wide ? 2 : UInt(fields.count)

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
        
        if let comparisonDate = comparisonHolder?.date {
            let comparisonDateFmt = multiFieldConfig.calendarConfig.formattedDate(comparisonDate)
            let comparisonDateAttributed = NSAttributedString(string: comparisonDateFmt, attributes: GCViewConfig.attribute(rzAttribute.secondaryField))
            
            var title = "ΔM-1"
            if multiFieldConfig.calendarConfig.calendarUnit == .weekOfYear {
                title = "ΔW-1"
            }else if multiFieldConfig.calendarConfig.calendarUnit == .year {
                title = "ΔY-1"
            }
            self.label(forRow: 1, andCol: 0)?.attributedText = NSAttributedString(string:title , attributes: GCViewConfig.attribute(rzAttribute.secondaryField))
            self.label(forRow: 2, andCol: 0)?.attributedText = comparisonDateAttributed
        }
        
        var row : UInt = 0
        let mainCount : UInt = 2
        var fieldIdx : UInt = 0
        
        for field in fields {
            if let nu = dataHolder.preferredNumber(withUnit: field){
                if nu.isValidValue() && nu.value != 0.0 {
                    if var comparisonNu = comparisonHolder?.preferredNumber(withUnit: field){
                        var showPositive : Bool = true
                        if comparisonNu.unit == nu.unit {
                            switch multiFieldConfig.comparisonMetric {
                            case .percent:
                                comparisonNu = GCNumberWithUnit(name: "percent", andValue:  (nu.value/comparisonNu.value - 1.0) * 100.0 )
                                showPositive = comparisonNu.value > 0
                            case .valueDifference:
                                comparisonNu = GCNumberWithUnit(unit: nu.unit, andValue:  nu.value-comparisonNu.value )
                                showPositive = nu.unit.betterIsMin() ? comparisonNu.value < 0 : comparisonNu.value > 0
                            default:
                                showPositive = nu.unit.betterIsMin() ? (nu.value < comparisonNu.value) : (nu.value > comparisonNu.value )
                            }
                        }
                        
                        if comparisonNu.value.isFinite {
                            let comparisonCellView = GCCellFieldValueView(numberWithUnit: comparisonNu,
                                                                          geometry: geometry,
                                                                          field: field,
                                                                          icon: .hide)
                            if multiFieldConfig.comparisonMetric != .value {
                                comparisonCellView.sign = RZNumberWithUnitGeometry.DisplaySign.always
                            }else {
                                comparisonCellView.sign = RZNumberWithUnitGeometry.DisplaySign.natural
                            }
                            comparisonCellView.displayField = .hide
                            comparisonCellView.iconInset = 4.0
                            comparisonCellView.fieldAttribute = GCViewConfig.attribute(rzAttribute.secondaryField)
                            comparisonCellView.numberAttribute = GCViewConfig.attribute(rzAttribute.secondaryValue)
                            comparisonCellView.unitAttribute = GCViewConfig.attribute(rzAttribute.secondaryUnit)
                            
                            if showPositive {
                                comparisonCellView.numberAttribute[ NSAttributedString.Key.foregroundColor] = UIColor.systemGreen
                            }else{
                                comparisonCellView.numberAttribute[ NSAttributedString.Key.foregroundColor] = UIColor.systemRed
                            }
                            
                            self.setupView(comparisonCellView, forRow: row, andColumn: 2)
                        }
                    }
                    
                    let cellView = GCCellFieldValueView(numberWithUnit: nu,
                                                        geometry: geometry,
                                                        field: field,
                                                        icon: .left)
                    cellView.sign = .natural
                    cellView.displayField = .hide
                    cellView.iconInset = 4.0
                    if fieldIdx < mainCount {
                        cellView.fieldAttribute = GCViewConfig.attribute(rzAttribute.field)
                        cellView.numberAttribute = GCViewConfig.attribute(rzAttribute.value)
                        cellView.unitAttribute = GCViewConfig.attribute(rzAttribute.unit)
                    }else{
                        cellView.fieldAttribute = GCViewConfig.attribute(rzAttribute.secondaryField)
                        cellView.numberAttribute = GCViewConfig.attribute(rzAttribute.secondaryValue)
                        cellView.unitAttribute = GCViewConfig.attribute(rzAttribute.secondaryUnit)
                    }
                    
                    
                    self.setupView(cellView, forRow: row, andColumn: 1)
                }else{
                    self.reset(forRow: row, andCol: 2)
                }
            }
            row += 1
            fieldIdx += 1
        }
        
    }

    
    @objc func setupAggregatedComparison(field:GCField,
                                         dataHolder : GCHistoryAggregatedDataHolder,
                                         comparisonHolder: GCHistoryAggregatedDataHolder?,
                                         index : Int,
                                         multiFieldConfig : GCStatsMultiFieldConfig,
                                         activityType : GCActivityType,
                                         geometry : RZNumberWithUnitGeometry,
                                         wide :Bool = false
    ){
        let fields = activityType.summaryFields()
        
        let colCount : UInt = wide ? 5 : 3
        let rowCount : UInt = wide ? 2 : UInt(fields.count)

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
        
        if let comparisonDate = comparisonHolder?.date {
            let comparisonDateFmt = multiFieldConfig.calendarConfig.formattedDate(comparisonDate)
            let comparisonDateAttributed = NSAttributedString(string: comparisonDateFmt, attributes: GCViewConfig.attribute(rzAttribute.secondaryField))
            
            var title = "ΔM-1"
            if multiFieldConfig.calendarConfig.calendarUnit == .weekOfYear {
                title = "ΔW-1"
            }else if multiFieldConfig.calendarConfig.calendarUnit == .year {
                title = "ΔY-1"
            }
            self.label(forRow: 1, andCol: 0)?.attributedText = NSAttributedString(string:title , attributes: GCViewConfig.attribute(rzAttribute.secondaryField))
            self.label(forRow: 2, andCol: 0)?.attributedText = comparisonDateAttributed
        }
        
        var row : UInt = 0
        let mainCount : UInt = 2
        var fieldIdx : UInt = 0
        
        let preferred = dataHolder.preferredAggregatedType(for: field)
        let aggregatedStats = [ preferred, .max, .cnt, .wvg, .min]
        
        for stat in aggregatedStats {
            if let nu = (stat == preferred) ? dataHolder.preferredNumber(withUnit: field) : dataHolder.number(withUnit: field, statType: stat){
                if nu.isValidValue() && nu.value != 0.0 {
                    if var comparisonNu = (stat == preferred) ? comparisonHolder?.preferredNumber(withUnit: field) : comparisonHolder?.number(withUnit: field, statType: stat){
                        var showPositive : Bool = true
                        if comparisonNu.unit == nu.unit {
                            switch multiFieldConfig.comparisonMetric {
                            case .percent:
                                comparisonNu = GCNumberWithUnit(name: "percent", andValue:  (nu.value/comparisonNu.value - 1.0) * 100.0 )
                                showPositive = comparisonNu.value > 0
                            case .valueDifference:
                                comparisonNu = GCNumberWithUnit(unit: nu.unit, andValue:  nu.value-comparisonNu.value )
                                showPositive = nu.unit.betterIsMin() ? comparisonNu.value < 0 : comparisonNu.value > 0
                            default:
                                showPositive = nu.unit.betterIsMin() ? (nu.value < comparisonNu.value) : (nu.value > comparisonNu.value )
                            }
                        }
                        
                        if comparisonNu.value.isFinite {
                            let comparisonCellView = GCCellFieldValueView(numberWithUnit: comparisonNu,
                                                                          geometry: geometry,
                                                                          field: field,
                                                                          icon: .hide)
                            if multiFieldConfig.comparisonMetric != .value {
                                comparisonCellView.sign = RZNumberWithUnitGeometry.DisplaySign.always
                            }else {
                                comparisonCellView.sign = RZNumberWithUnitGeometry.DisplaySign.natural
                            }
                            comparisonCellView.displayField = .hide
                            comparisonCellView.iconInset = 4.0
                            comparisonCellView.fieldAttribute = GCViewConfig.attribute(rzAttribute.secondaryField)
                            comparisonCellView.numberAttribute = GCViewConfig.attribute(rzAttribute.secondaryValue)
                            comparisonCellView.unitAttribute = GCViewConfig.attribute(rzAttribute.secondaryUnit)
                            
                            if showPositive {
                                comparisonCellView.numberAttribute[ NSAttributedString.Key.foregroundColor] = UIColor.systemGreen
                            }else{
                                comparisonCellView.numberAttribute[ NSAttributedString.Key.foregroundColor] = UIColor.systemRed
                            }
                            
                            self.setupView(comparisonCellView, forRow: row, andColumn: 2)
                        }
                    }
                    
                    let cellView = GCCellFieldValueView(numberWithUnit: nu,
                                                        geometry: geometry,
                                                        field: field,
                                                        primaryField: field,
                                                        icon: .hide)
                    cellView.sign = .natural
                    cellView.displayField = .right
                    //cellView.displayNumber = .right
                    cellView.iconInset = 4.0
                    cellView.overrideFieldName = dataHolder.describe(stat)
                    
                    if fieldIdx < mainCount {
                        cellView.fieldAttribute = GCViewConfig.attribute(rzAttribute.secondaryField)
                        cellView.numberAttribute = GCViewConfig.attribute(rzAttribute.value)
                        cellView.unitAttribute = GCViewConfig.attribute(rzAttribute.unit)
                    }else{
                        cellView.fieldAttribute = GCViewConfig.attribute(rzAttribute.secondaryField)
                        cellView.numberAttribute = GCViewConfig.attribute(rzAttribute.secondaryValue)
                        cellView.unitAttribute = GCViewConfig.attribute(rzAttribute.secondaryUnit)
                    }
                    
                    
                    self.setupView(cellView, forRow: row, andColumn: 1)
                }else{
                    self.reset(forRow: row, andCol: 2)
                }
            }
            row += 1
            fieldIdx += 1
        }
        
    }

    
    //MARK: - Detail Activity view
    
    func setupActivityDetailsColumn(fields : [GCField], activity : GCActivity, geometry : RZNumberWithUnitGeometry, column : UInt ){
        if let field = fields.first?.displayName() {
            let fieldFmt = NSAttributedString(string: field, attributes: GCViewConfig.attribute(rzAttribute.field) )
            self.label(forRow: 0, andCol: column)?.attributedText = fieldFmt
            if column != 0 {
                self.config(forRow: 0, andCol: column)?.horizontalAlign = .right
            }
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
                
                if( row != 0){
                    if field.displayName(withPrimary: primaryField) == field.displayName() {
                        cellView.displayField = .hide
                        self.label(forRow: row, andCol: column)?.attributedText = NSAttributedString(string: field.displayName(), attributes: fieldAttr)
                    }
                    if( column != 0){
                        self.config(forRow: row, andCol: column)?.horizontalAlign = gcHorizontalAlign.right
                    }
                }
                self.setupView(cellView, forRow: row, andColumn: column+1)
            }
            row += 1
            fieldAttr = GCViewConfig.attribute(rzAttribute.secondaryField)
            numberAttr = GCViewConfig.attribute(rzAttribute.secondaryValue)
            unitAttr = GCViewConfig.attribute(rzAttribute.secondaryUnit)
        }
    }
    
    @objc func setupActivityDetail(fields : [GCField],
                                   activity : GCActivity,
                                   geometry : RZNumberWithUnitGeometry,
                                   second : [GCField] = [] ){
        GCViewConfig.setupGradient(forDetails: self)
        
        let columns : UInt = second.count == 0 ? 2 : 4
        
        self.setup(forRows:UInt(max(fields.count,second.count)), andCols:columns)
        
        self.setupActivityDetailsColumn(fields: fields, activity: activity, geometry: geometry, column: 0)
        if second.count > 0 {
            self.setupActivityDetailsColumn(fields: second, activity: activity, geometry: geometry, column: 2)
        }
    }
    
    //MARK: - Fields Statistics
    
    @objc static func adjustFieldStatistics(summaryStats : GCHistoryFieldSummaryStats,
                                            histStats which: gcHistoryStats,
                                       geometry : RZNumberWithUnitGeometry ) {
        
        for (_,dataHolder) in summaryStats.fieldData {
            let info = dataHolder.relevantNumbers(histStats: which)
            if let main = info.main {
                geometry.adjust(for: main, numberAttribute: GCViewConfig.attribute(.value), unitAttribute: GCViewConfig.attribute(.unit))
                geometry.adjust(for: main, numberAttribute: GCViewConfig.attribute(.secondaryValue), unitAttribute: GCViewConfig.attribute(.secondaryUnit))
            }
        }
    }

    
    @objc func setupFieldStatistics(dataHolder : GCHistoryFieldSummaryDataHolder, histStats which: gcHistoryStats, geometry: RZNumberWithUnitGeometry){
        let field = dataHolder.field

        let mainFieldName = field.displayName()

        
        let info = dataHolder.relevantNumbers(histStats: which)
        let count = dataHolder.count(withUnit: which)

        let mainNumber : GCNumberWithUnit? = info.main
        let extra : GCNumberWithUnit? = info.extra
        let extraLabel : String? = info.extraLabel
        
        self.setup(forRows: 2, andCols: 2)
        self.label(forRow: 0, andCol: 0)?.attributedText = NSAttributedString(string: mainFieldName ?? "Error",
                                                                              attributes: GCViewConfig.attribute(rzAttribute.field))
        self.label(forRow: 1, andCol: 0)?.attributedText = NSAttributedString(string: String(format: NSLocalizedString("Cnt %@", comment: "Summary Field Stats"), count),
                                                                              attributes: GCViewConfig.attribute(rzAttribute.secondaryValue))

        //let minimumSize = ("Maxxx" as NSString).size(withAttributes: GCViewConfig.attribute(.field))
        if let mainNumber = mainNumber {
            let cellView = GCCellFieldValueView(numberWithUnit: mainNumber,
                                                geometry: geometry,
                                                field: nil,
                                                primaryField: nil,
                                                icon: .hide)
            cellView.numberAttribute = GCViewConfig.attribute(.value)
            cellView.unitAttribute = GCViewConfig.attribute(.unit)
            cellView.displayField = .right
            cellView.displayNumber = .right
            //cellView.fieldMinimumSize = minimumSize
            cellView.geometry.numberAlignment = .right
            cellView.geometry.unitAlignment = .trailingNumber
            cellView.geometry.timeAlignment = .withNumber
            self.setupView(cellView, forRow: 0, andColumn: 1)
        }
        if let extra = extra {
            let cellView = GCCellFieldValueView(numberWithUnit: extra,
                                                geometry: geometry,
                                                field: nil,
                                                primaryField: nil,
                                                icon: .hide)
            cellView.overrideFieldName = extraLabel
            cellView.fieldAttribute = GCViewConfig.attribute(.secondaryField)
            cellView.numberAttribute = GCViewConfig.attribute(.secondaryValue)
            cellView.unitAttribute = GCViewConfig.attribute(.secondaryUnit)
            cellView.displayField = .right
            cellView.displayNumber = .right
            //cellView.fieldMinimumSize = minimumSize
            cellView.geometry.numberAlignment = .right
            cellView.geometry.unitAlignment = .trailingNumber
            cellView.geometry.timeAlignment = .withNumber
            self.setupView(cellView, forRow: 1, andColumn: 1)
        }
    }
    
}

extension GCHistoryFieldSummaryDataHolder {
    func relevantNumbers(histStats which: gcHistoryStats) -> (main: GCNumberWithUnit?, extra : GCNumberWithUnit?, extraLabel: String?) {
        var rv : (main: GCNumberWithUnit?, extra : GCNumberWithUnit?, extraLabel: String?)
        if field.canSum {
            rv.main = self.sum(withUnit: which)
            rv.extra  = self.average(withUnit: which)
            rv.extraLabel = NSLocalizedString("Avg", comment: "Summary Field Stats")
        }else if field.isWeightedAverage {
            rv.main = self.weightedAverage(withUnit: which)
        }else {
            rv.main = self.average(withUnit: which)
            
            if field.isMax {
                rv.extra = self.max(withUnit: which)
                rv.extraLabel = NSLocalizedString("Max", comment: "Summary Field Stats")
            }else{
                rv.extra = self.average(withUnit: which)
                rv.extraLabel = NSLocalizedString("Avg", comment: "Summary Field Stats")
            }
        }
        return rv
    }
}
