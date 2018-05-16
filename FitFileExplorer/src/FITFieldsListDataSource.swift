//
//  FITFieldsListDataSource.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 05/11/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import Cocoa
import RZUtilsOSX

class FITFieldsListDataSource: NSObject,NSTableViewDelegate,NSTableViewDataSource,RZTableViewDelegate {

    static let kFITNotificationDetailSelectionChanged = Notification.Name( "kFITNotificationDetailSelectionChanged" )

    
    let fitFile : FITFitFile
    
    var selectedColumn : Int = -1
    var selectedRow : Int = -1
    
    var selectedField : String?
    var selectedMessageField : FITFitMessageFields?

    var selectionContext : FITSelectionContext?
    var message:FITFitMessage
    
    var messageType :String {
        didSet{
            self.message = self.fitFile[self.messageType];
            selectedRow = -1
            selectedColumn = -1
        }
    }
    
    init(file: FITFitFile, messageType : String, context : FITSelectionContext) {
        self.fitFile = file
        self.message = self.fitFile[messageType];
        self.messageType = messageType
        self.selectionContext = context
    }
    
    
    func requiredTableColumnsIdentifiers() -> [String] {
        if( message.count() == 1){
            
            return [ "Field", "Value"]
        }else{
            return self.message.allSortedFieldKeys();
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if( message.count() == 1){
            return self.message[0].allFieldNames().count
        }else{
            return Int(message.count())
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView =  tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("MessageCellView"), owner: self)
        if let cellView = cellView as? NSTableCellView {
            cellView.textField?.stringValue = ""
            if( message.count() == 1){
                if let fields = self.message[0] {
                    if( row < fields.allFieldNames().count){
                        let identifier = fields.allFieldNames()[row]
                        if tableColumn?.identifier == NSUserInterfaceItemIdentifier("Field") {
                            if let fieldDisplay = self.selectionContext?.displayField(fieldName: identifier){
                                cellView.textField?.attributedStringValue = fieldDisplay
                            }
                        }else{
                            if let item = fields[identifier],
                                let selectionContext = self.selectionContext{
                                cellView.textField?.stringValue = selectionContext.display(fieldValue: item)
                            }
                        }
                    }
                }
            }else{
                if let fields = self.message[UInt(row)], let identifier = tableColumn?.identifier, let item = fields[identifier.rawValue],
                    let selectionContext = self.selectionContext{
                    cellView.textField?.stringValue = selectionContext.display(fieldValue: item)
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
            
            var chosenField : String?
            var chosenMessage : FITFitMessageFields?
            
            if message.count() == 1 {
                let fields = self.message[0].allFieldNames()
                if self.selectedRow != -1 && self.selectedRow < fields.count {
                    chosenField = fields[self.selectedRow];
                }
                
            }else{
                if self.selectedRow != -1 && self.selectedRow < Int(self.message.count()) {
                    chosenMessage = self.message[ UInt(self.selectedRow) ]
                }
                if( self.selectedColumn != -1 && self.selectedColumn < tableView.tableColumns.count){
                    chosenField = tableView.tableColumns[self.selectedColumn].identifier.rawValue
                }
            }
            
            self.selectedField = chosenField
            self.selectedMessageField = chosenMessage
            
            NotificationCenter.default.post(name: FITFieldsListDataSource.kFITNotificationDetailSelectionChanged, object: self)
        }

    }

    
}
