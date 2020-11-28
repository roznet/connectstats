//  MIT License
//
//  Created on 26/11/2020 for ConnectStats
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
import RZUtilsTouch

extension GCActivityDetailViewController {
    
    @objc func tableView(_ tableView: UITableView, fieldCellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        guard let cell = GCCellGrid(tableView) else { return UITableViewCell(frame: CGRect.zero)}
        
        GCViewConfig.setupGradient(forDetails: cell)
        
        if let organizedFields = self.organizedFields {
        
            if indexPath.row < organizedFields.groupedPrimaryFields.count {
                let fields = organizedFields.groupedPrimaryFields[ indexPath.row ]
                
                cell.setup(forRows:UInt(fields.count), andCols:2)
                if let field = fields.first?.displayName() {
                    let fieldFmt = NSAttributedString(string: field, attributes: GCViewConfig.attribute(rzAttribute.field) )
                    cell.label(forRow: 0, andCol: 0)?.attributedText = fieldFmt
                }
                
                var fieldAttr = GCViewConfig.attribute(rzAttribute.field) ?? [:]
                var numberAttr = GCViewConfig.attribute(rzAttribute.value) ?? [:]
                var unitAttr = GCViewConfig.attribute(rzAttribute.unit) ?? [:]
                let primaryField = fields.first
                var row : UInt = 0
                
                for field in fields {
                    if let numberWithUnit = self.activity.numberWithUnit(for: field) {
                        let cellView = GCCellFieldValueView(numberWithUnit: numberWithUnit,
                                                            geometry: self.organizedFields.geometry,
                                                            field: field,
                                                            primaryField: primaryField,
                                                            icon: false)
                        cellView.fieldAttribute = fieldAttr
                        cellView.numberAttribute = numberAttr
                        cellView.unitAttribute = unitAttr
                        cell.setupView(cellView, forRow: row, andColumn: 1)
                    }
                    row += 1
                    fieldAttr = GCViewConfig.attribute(rzAttribute.secondaryField) ?? [:]
                    numberAttr = GCViewConfig.attribute(rzAttribute.secondaryValue) ?? [:]
                    unitAttr = GCViewConfig.attribute(rzAttribute.secondaryUnit) ?? [:]
                }
                
            }
        
        }
        return cell
    }
}
