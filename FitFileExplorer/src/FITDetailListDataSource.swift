//
//  FITFieldsListDataSource.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 05/11/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import Cocoa
import RZUtilsMacOS
import FitFileParser
import RZUtilsSwift

class FITDetailListDataSource: NSObject,NSTableViewDelegate,NSTableViewDataSource,RZTableViewDelegate {
    
    let selectionContext : FITSelectionContext
    var orderedKeys : [FitFieldKey] {
        return self.selectionContext.orderedKeys
    }
    
    var setupMode : Bool = false
    
    // Whether messages are in rows or columns
    var messageInColumns : Bool = false

    // MARK: - Indirection Convenience from Selection Context
    
    var selectedField : FitFieldKey? {
        get {
            return self.selectionContext.selectedField
        }
    }

    var fitFile : FitFile {
        return self.selectionContext.fitFile
    }
    var messages : [FitMessage] {
        return self.selectionContext.messages
    }
    var messageType :FitMessageType{
        get {
            return self.selectionContext.messageType
        }
    }
    
    init(context : FITSelectionContext) {
        self.selectionContext = context
        super.init()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    
    func requiredTableColumnsIdentifiers() -> [String] {
        if( self.messageInColumns){
            if self.messages.count == 1 {
                return [ "Field", "Value"]
            }else{
                var rv = [ "Field" ]
                for i in 0..<self.messages.count {
                    rv.append("message[\(i)]")
                }
                return rv
            }
        }else{
            return self.orderedKeys
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if self.setupMode {
            return 0
        }
        if( self.messageInColumns){
            return self.selectionContext.orderedKeys.count
        }else{
            return Int(messages.count)
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView =  tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("MessageCellView"), owner: self)
        if let cellView = cellView as? NSTableCellView {
            cellView.textField?.stringValue = ""
            if( self.messageInColumns ){
                if let tableColumn = tableColumn{
                    let selectionContext = self.selectionContext
                    if tableColumn.identifier == NSUserInterfaceItemIdentifier("Field"),
                       let identifier = selectionContext.orderedKeys[safe: row] {
                        let fieldDisplay = selectionContext.displayField(fitMessageType: selectionContext.messageType, fieldName: identifier)
                        cellView.textField?.attributedStringValue = fieldDisplay
                    }else if let columnIndex = tableView.tableColumns.firstIndex(of: tableColumn),
                             let message = self.messages[safe: columnIndex-1],
                             let identifier = selectionContext.orderedKeys[safe: row],
                             let value = message.interpretedField(key: identifier) {
                        cellView.textField?.stringValue = selectionContext.display(fieldValue: value, field: identifier)
                    }
                }
            }else{
                if row < self.messages.count {
                    let message = self.messages[row]
                    if let identifier = tableColumn?.identifier.rawValue,
                        let item = message.interpretedField(key:identifier){
                        cellView.textField?.stringValue = selectionContext.display(fieldValue: item, field: identifier)
                    }
                }
            }
        }
        return cellView
    }
    
    func userClicked(_ tableView: RZTableView, row: Int, column: Int) {
        if self.messageInColumns {
            let selectedMessageIndex = column < 1 ? 1 : column - 1
            if let fields = self.messages[safe: selectedMessageIndex]?.interpretedFieldKeys() {
                if row != -1 && row < fields.count {
                    let chosenField = fields[row]
                    self.selectionContext.selectMessageField(field: chosenField, atIndex: selectedMessageIndex)
                }
            }
        }else{
            if( column != -1 && column < tableView.tableColumns.count){
                if let chosenField = tableView.tableColumns[safe: column]?.identifier.rawValue {
                    self.selectionContext.selectMessageField(field: chosenField, atIndex: row)
                }
            }
        }
    }
    
}
