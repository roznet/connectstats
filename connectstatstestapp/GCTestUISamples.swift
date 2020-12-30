//  MIT License
//
//  Created on 30/12/2020 for ConnectStatsTestApp
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

extension GCTestUISamples {
    
    typealias GeometryAlignment = (alignment : RZNumberWithUnitGeometry.Alignment,
                                number : RZNumberWithUnitGeometry.NumberAlignment,
                                unit : RZNumberWithUnitGeometry.UnitAlignment,
                                time : RZNumberWithUnitGeometry.TimeAlignment,
                                icon : GCCellFieldValueView.DisplayIcon )
    
    @objc func sampleNumberGeometry() -> [GCTestUISampleCellHolder] {
        var rv : [GCTestUISampleCellHolder] = []
        
        let samples : [GCNumberWithUnit] = [
            GCNumberWithUnit(name: "minperkm", andValue: 5.2),
            GCNumberWithUnit(name: "bpm", andValue: 160),
            GCNumberWithUnit(name: "kilometer", andValue: 7.25),
            GCNumberWithUnit(name: "second", andValue: 4000),
        ]
        
        let fields : [GCField] = [
            GCField(for: gcFieldFlag.weightedMeanSpeed, andActivityType: GC_TYPE_RUNNING),
            GCField(for: gcFieldFlag.weightedMeanHeartRate, andActivityType: GC_TYPE_RUNNING),
            GCField(for: gcFieldFlag.sumDistance, andActivityType: GC_TYPE_RUNNING),
            GCField(for: gcFieldFlag.sumDuration, andActivityType: GC_TYPE_RUNNING),
        ]
        
        var configIdx = 0
        
        let configs : [GeometryAlignment] = [
            (alignment: .left, number: .decimalSeparator, unit: .right, time: .withNumber, icon: .hide),
            (alignment: .left, number: .right, unit: .left, time: .center, icon: .left),
            (alignment: .left, number: .decimalSeparator, unit: .left, time: .withUnit, icon: .right),

            (alignment: .left, number: .decimalSeparator, unit: .trailingNumber, time: .center, icon: .left),
            (alignment: .left, number: .right, unit: .left, time: .center, icon: .right),
            (alignment: .left, number: .right, unit: .right, time: .center, icon: .left),
        ]
        
        let fieldAttr = GCViewConfig.attribute(rzAttribute.secondaryField)
        let numberAttr = GCViewConfig.attribute(rzAttribute.secondaryValue)
        let unitAttr = GCViewConfig.attribute(rzAttribute.secondaryUnit)
        
        for _ in 0...1 {
            if let cell = GCCellGrid(nil) {
                cell.setup(forRows: UInt(samples.count), andCols: 3)
                for col : UInt in 0...2 {
                    var row : UInt = 0
                    let geometry = RZNumberWithUnitGeometry()
                    let config = configs[configIdx]
                    configIdx += 1
                    geometry.alignment = config.alignment
                    geometry.numberAlignment = config.number
                    geometry.unitAlignment = config.unit
                    geometry.timeAlignment = config.time
                    let displayIcon = config.icon
                    for nu in samples {
                        geometry.adjust(for: nu, numberAttribute: numberAttr, unitAttribute: unitAttr)
                    }
                    for (field,nu) in zip(fields,samples) {
                        let cellView = GCCellFieldValueView(numberWithUnit: nu,
                                                            geometry: geometry,
                                                            field: field,
                                                            primaryField: nil,
                                                            icon: displayIcon)
                        cellView.fieldAttribute = fieldAttr
                        cellView.numberAttribute = numberAttr
                        cellView.unitAttribute = unitAttr
                        cellView.displayField = .hide
                        /*if col % 2 == 0 {
                         cellView.backgroundColor = GCViewConfig.defaultColor(gcSkinDefaultColor.backgroundOdd)
                         }else{
                         cellView.backgroundColor = GCViewConfig.defaultColor(gcSkinDefaultColor.backgroundEven)
                         }*/
                        cell.setupView(cellView, forRow: row, andColumn: col)
                        row += 1
                        
                    }
                }
                let sample = GCTestUISampleCellHolder(for: cell, height: GCViewConfig.sizeForNumber(ofRows: UInt(samples.count)), andIdentifier: "Sample Geometry")
                rv.append(sample)
            }
        }
        return rv
    }
}
