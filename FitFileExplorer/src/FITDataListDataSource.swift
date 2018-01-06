//
//  FITDataListDataSource.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 25/05/2017.
//  Copyright © 2017 Brice Rosenzweig. All rights reserved.
//

import Cocoa
import RZUtilsOSX

/*
 - Select Record or Lap or Session Field
 - Session/1 message -> find related fields or display field of message
 - display as table with line for each field
 - for each field-> Value, Avg, Min, Max
 - Surrounding Session or Lap (option)
 - for each field, map into other section where timestamp in [start_time/timestamp]:
 ex: speed -> session speed, session max speed, etc
 - Containing: Lap or Record
 - find record/lap (from start_time -> timestamp)
 - average/max from record.
 
 - Select Field in session:
 - find matching fields from record/lap, compute between start_time/timestamp:
 - avg, min, max
 - if nothing found: just display field
 
 - Compute Stats using: record/Lap for session/Lap/all
 - session: using record/lap for session/all
 - lap: using record for lap/session/all
 - record: using record for lap/session/all
 
 Calculated Value:
 - stat(avg/max/min) from record/lap for session/lap [surround field]
    operate on all messages within surround field
 - value/max/min from session/lap
    operate on the message that surround message
 - deriv/cumsum for session/lap
    operate on all prev sinc surround message: prev/curr+state (not next to simplify?)
 */
class FITDataListDataSource: NSObject,NSTableViewDelegate,NSTableViewDataSource {

    let fitFile : FITFitFile
    
    let selectedRow : Int
    
    var selectedField : String?
    var selectedMessageField : FITFitMessageFields?
    
    var selectionContext : FITSelectionContext?
    var message:FITFitMessage
    
    var displayFields:[String]
    var relatedMessage:FITFitMessage?
    var relatedFields:[String:[String]]?
    
    var relatedStatistics:[String:FITFitValueStatistics]?
    
    init(file: FITFitFile, messageType : String, selectedRow : Int, context : FITSelectionContext) {
        self.fitFile = file
        self.message = self.fitFile[messageType];
        self.selectionContext = context
        self.selectedRow = selectedRow;
        
        // Session style, where only one row.
        // Just select all fields that are related to selected field (max, avg, etc)
        let interp = FITFitFileInterpret(fitFile: file);
        
        if( context.message.count() == 1){
            if let field:String = context.selectedYField {
                let mapped:[String:[String]] = interp.mapFields(from: [field], to: self.message.allNumberKeys())
                if let found = mapped[field] {
                    self.displayFields = found
                }else{
                    self.displayFields = [field]
                }
            }else{
                self.displayFields = [];
            }
            
        }else{
            // lap/record stype: display all the field for the line
            self.displayFields = self.message.allSortedFieldKeys()
        }
        
        // record could be session to get value or record to do stats
        let messageDefaultMap = [ "record": "record", "lap":"record", "session":"record" ]
        if let subMessage = messageDefaultMap[messageType] {
            self.relatedMessage = self.fitFile[subMessage];
            var interval :(from:Date,to:Date)?
            if let ts = context.selectedMessageFields?["timestamp"]?.dateValue,
                let start = context.selectedMessageFields?["start_time"]?.dateValue{
                interval = (from:start,to:ts);
            }
            self.relatedStatistics = interp.statsForMessage(message: subMessage, interval: interval)
            if let possibleFields = self.relatedMessage?.allAvailableFieldKeys(){
                self.relatedFields = interp.mapFields(from: self.displayFields, to: possibleFields)
            }
        }
    }
    
    func requiredTableColumnsIdentifiers() -> [String] {
        return [ "Field", "Value"]
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.displayFields.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView =  tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("DataCellView"), owner: self)
        if let cellView = cellView as? NSTableCellView {
            cellView.textField?.stringValue = ""
            if( row < self.displayFields.count){
                let identifier = self.displayFields[row]
                if tableColumn?.identifier.rawValue == "Field" {
                    if let fieldDisplay = self.selectionContext?.displayField(fieldName: identifier){
                        cellView.textField?.attributedStringValue = fieldDisplay
                    }
                }else if(tableColumn?.identifier.rawValue == "Value"){
                    let idx = UInt(self.selectedRow) < self.message.count() ? self.selectedRow : 0
                    if let field = self.message.field(for: UInt(idx)),
                        let item = field[identifier],
                        let selectionContext = self.selectionContext{
                        cellView.textField?.stringValue = selectionContext.display(fieldValue: item)
                    }
                }else{
                    let idx = UInt(self.selectedRow) < self.message.count() ? self.selectedRow : 0
                    if let field = self.message.field(for: UInt(idx)),
                        let item = field[identifier],
                        let selectionContext = self.selectionContext,
                        let relatedFields = self.relatedFields?[identifier],
                        let stats = self.relatedStatistics{
                        if relatedFields.count > 0 && item.numberWithUnit != nil{
                            if let stat = stats[relatedFields[0]]{
                                if stat.count > 0 {
                                    if let avg : GCNumberWithUnit = stat.sum{
                                        avg.value/=Double(stat.count);
                                        cellView.textField?.stringValue = selectionContext.display(numberWithUnit: avg)
                                        //print( "\(identifier) -> \(relatedFields[0]) = \(stat.count)" )
                                    }
                                }
                            }
                        }else{
                            cellView.textField?.stringValue = ""
                        }
                    }
                }
            }
        }
        return cellView
    }
    

}
