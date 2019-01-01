//
//  FITFieldsListDataSource.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 05/11/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import Cocoa
import RZUtilsOSX

class FITDetailListDataSource: NSObject,NSTableViewDelegate,NSTableViewDataSource,RZTableViewDelegate {

    static let kFITNotificationDetailSelectionChanged = Notification.Name( "kFITNotificationDetailSelectionChanged" )
    
    let selectionContext : FITSelectionContext
    
    var fitFile : RZFitFile {
        return self.selectionContext.fitFile
    }
    
    var selectedColumn : Int = -1
    var selectedRow : Int = -1
    
    var selectedField : RZFitFieldKey?
    var messages:[RZFitMessage] {
        return self.selectionContext.messages
    }
    
    var setupMode : Bool = false
    
    var messageType :RZFitMessageType{
        get {
            return self.selectionContext.messageType
        }
        set {
            self.selectionContext.messageType = newValue
            self.samples = self.fitFile.sampleValues(messageType: self.messageType)
        }
    }
    
    var samples : [RZFitFieldKey:RZFitFieldValue]
    
    init(context : FITSelectionContext) {
        self.selectionContext = context
        self.samples = context.fitFile.sampleValues(messageType: context.messageType)
    }
    
    
    func requiredTableColumnsIdentifiers() -> [String] {
        if( messages.count == 1){
            return [ "Field", "Value"]
        }else{
            return Array(self.samples.keys);
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        if self.setupMode {
            return 0
        }
        if( self.messages.count == 1){
            if let first = self.messages.first {
                return first.interpretedFieldKeys().count
            }else{
                return 0
            }
        }else{
            return Int(messages.count)
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView =  tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("MessageCellView"), owner: self)
        if let cellView = cellView as? NSTableCellView {
            cellView.textField?.stringValue = ""
            if( messages.count == 1){
                if let first = self.messages.first {
                    if( row < first.interpretedFieldKeys().count){
                        let identifier = first.interpretedFieldKeys()[row]
                        if tableColumn?.identifier == NSUserInterfaceItemIdentifier("Field") {
                            let fieldDisplay = self.selectionContext.displayField(fieldName: identifier)
                            cellView.textField?.attributedStringValue = fieldDisplay
                            
                        }else{
                            if let item = first.interpretedField(key: identifier){
                                cellView.textField?.stringValue = self.selectionContext.display(fieldValue: item)
                            }
                        }
                    }
                }
            }else{
                if row < self.messages.count {
                    let message = self.messages[row]
                    if let identifier = tableColumn?.identifier,
                        let item = message.interpretedField(key:identifier.rawValue){
                        cellView.textField?.stringValue = selectionContext.display(fieldValue: item)
                    }
                }
            }
        }
        return cellView
    }
    
    func userClicked(_ tableView: RZTableView, row: Int, column: Int) {
    
        let changed : Bool = ( self.selectedColumn != column || self.selectedRow != row);
        
        if( changed ){
            self.selectedColumn = column
            self.selectedRow = row
            
            var chosenField : RZFitFieldKey?
            
            if messages.count == 1 {
                if let fields = self.messages.first?.interpretedFieldKeys() {
                    if self.selectedRow != -1 && self.selectedRow < fields.count {
                        chosenField = fields[self.selectedRow];
                    }
                }
            }else{
                if( self.selectedColumn != -1 && self.selectedColumn < tableView.tableColumns.count){
                    chosenField = tableView.tableColumns[self.selectedColumn].identifier.rawValue
                }
            }
            
            self.selectedField = chosenField
            
            NotificationCenter.default.post(name: FITDetailListDataSource.kFITNotificationDetailSelectionChanged, object: self)
        }

    }

    
}
