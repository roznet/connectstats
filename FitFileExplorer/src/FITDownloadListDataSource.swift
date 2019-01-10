//  MIT License
//
//  Created on 18/11/2018 for FitFileExplorer
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
import RZUtils

class FITDownloadListDataSource: NSObject,NSTableViewDelegate,NSTableViewDataSource {

    func list() -> FITGarminActivityListWrapper {
        return FITGarminActivityListWrapper()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return Int(self.list().count)
    }
    
    func requiredTableColumnsIdentifiers() -> [String]{
        return [ "activityId", "activityType", "time", "downloaded" ]
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView =  tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("DownloadCellView"), owner: self)
        let to_display = self.list()[UInt(row)]
        if let cellView = cellView as? NSTableCellView, let column = tableColumn?.identifier.rawValue {
            cellView.textField?.stringValue = ""
            if column == "activityId" {
                cellView.textField?.stringValue = to_display.activityId
            }else if( column == "activityType" ){
                cellView.textField?.stringValue = to_display.activityType
            }else if( column == "time" ){
                cellView.textField?.stringValue = to_display.time.description
            }else if( column == "downloaded" ){
                cellView.textField?.stringValue = to_display.downloaded ? "yes" : ""
            }else{
                if let value = to_display[column] {
                    cellView.textField?.stringValue =  value.formatDouble()
                }
            }
        }
        return cellView
    }

}
