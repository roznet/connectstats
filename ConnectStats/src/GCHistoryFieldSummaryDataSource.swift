//  MIT License
//
//  Created on 24/02/2022 for ConnectStats
//
//  Copyright (c) 2022 Brice Rosenzweig
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



import UIKit
import RZUtilsSwift

class GCHistoryFieldSummaryDataSource: NSObject, UITableViewDataSource {
    private let fieldSummaryStats : GCHistoryFieldSummaryStats
    private let fieldOrder : [GCFieldsForCategory]
    private let sectionOffset : Int
    private let allFields : [GCField]
    private let multiFieldConfig : GCStatsMultiFieldConfig
    private let graphs : [GCField:GCHistoryFieldDataSerie]
    
    typealias FieldSelectionCallback = (_ : GCField) -> Void
    
    var callback : FieldSelectionCallback? = nil
    
    let geometry = RZNumberWithUnitGeometry()
    
    init(fieldSummaryStats : GCHistoryFieldSummaryStats,
         multiFieldConfig : GCStatsMultiFieldConfig,
         sectionOffset : Int = 0,
         graphs : [GCField:GCHistoryFieldDataSerie] = [:]){
        self.fieldSummaryStats = fieldSummaryStats
        self.allFields = Array(fieldSummaryStats.fieldData.keys)
        self.multiFieldConfig = multiFieldConfig
        self.sectionOffset = sectionOffset
        self.fieldOrder = GCFields.categorizeAndOrder(self.allFields)
        self.graphs = graphs

        GCCellGrid.adjustFieldStatistics(summaryStats: self.fieldSummaryStats, histStats: multiFieldConfig.historyStats, geometry: self.geometry)
    }
    
    convenience init(activities : [GCActivity],
                     multiFieldConfig : GCStatsMultiFieldConfig,
                     sectionOffset : Int = 0) {
        let vals = GCHistoryFieldSummaryStats(activities: activities,
                                              activityTypeSelection: multiFieldConfig.activityTypeSelection,
                                              referenceDate: multiFieldConfig.calendarConfig.referenceDate,
                                              ignoreMode: .activityFocus)
        if GCAppGlobal.health().hasHealthData() {
            vals.add(GCAppGlobal.health().measures, referenceDate: multiFieldConfig.calendarConfig.referenceDate)
        }
        self.init(fieldSummaryStats: vals, multiFieldConfig: multiFieldConfig,sectionOffset: sectionOffset)
    }
    
    
    //MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return fieldOrder.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fieldsForSection(section: section).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : GCCellGrid = GCCellGrid(tableView)
        if let field = self.fieldsForSection(section: indexPath.section)[safe: indexPath.row]{
            
            let summaryDataHolder = self.fieldSummaryStats.data(for: field)
            cell.setupFieldStatistics(dataHolder: summaryDataHolder, histStats: multiFieldConfig.historyStats, geometry: self.geometry)
            
            if graphs.count > 0 {
                let iconSize = CGSize(width: tableView.frame.size.width > 400.0 ? 128.0 : 64.0, height: 60.0)
                if let fieldDataSerie = graphs[field],
                   let cache = self.multiFieldConfig.dataSource(for: fieldDataSerie) {
                    cache.maximizeGraph = true
                    let view = GCSimpleGraphView(frame: .zero)
                    view.displayConfig = cache
                    view.dataSource = cache
                    cell.setIconView(view, with: iconSize)
                }else{
                    let empty = UIView(frame: .zero)
                    empty.backgroundColor = UIColor.clear
                    cell.iconView = empty
                    cell.iconSize = iconSize
                }
            }else{
                cell.iconView = nil
            }
            
        }else{
            cell.setup(forRows: 1, andCols: 1)
            cell.label(forRow: 0, andCol: 0).text = NSLocalizedString("Empty", comment: "fieldSummaryCell")
        }
        
        return cell
    }
    
    
//MARK: - helpers
    
    func fieldsForSection(section : Int) -> [GCField] {
        if let fieldOrder = self.fieldOrder[safe: section] {
            return fieldOrder.fields
        }else{
            return []
        }
    }
    
    func categoryName(section : Int) -> String {
        if let fieldOrder = self.fieldOrder[safe: section] {
            return fieldOrder.category ?? ""
        }else{
            return ""
        }
    }
}
