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

    let fitFile : RZFitFile
    var selectionContext : FITSelectionContext?

    let selectedRow : Int
    var selectedField : RZFitFieldKey?
    
    var messageType:RZFitMessageType
    var messages:[RZFitMessage]
    
    var displayFields:[RZFitFieldKey]
    
    var statsMessageType:RZFitMessageType?
    var statsFields:[RZFitFieldKey:[RZFitFieldKey]]?
    var statistics:[RZFitFieldKey:FITFitValueStatistics]?
    
    var message : RZFitMessage {
        return self.messages[self.selectedRow]
    }
    
    
    init(file: RZFitFile, messageType : RZFitMessageType, selectedRow : Int, context : FITSelectionContext) {
        self.fitFile = file
        self.messages = self.fitFile.messages(forMessageType: messageType)
        self.selectionContext = context
        self.selectedRow = selectedRow
        self.messageType = messageType
        
        // Session style, where only one row.
        // Just select all fields that are related to selected field (max, avg, etc)
        let interp = FITFitFileInterpret(fitFile: file);
        let samplesKeys = Array(self.fitFile.sampleValues(messageType: messageType).keys)
        if( context.messages.count == 1){
            if let field = context.selectedYField {
                let mapped = interp.mapFields(from: [field], to:  samplesKeys)
        
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
            self.displayFields = samplesKeys
        }
        // record could be session to get value or record to do stats
        let messageDefaultMap : [RZFitMessageType:RZFitMessageType] = [FIT_MESG_NUM_RECORD  :FIT_MESG_NUM_RECORD,
                                                                       FIT_MESG_NUM_LAP     :FIT_MESG_NUM_RECORD,
                                                                       FIT_MESG_NUM_SESSION :FIT_MESG_NUM_RECORD ]
        
        self.statsMessageType = messageDefaultMap[messageType]
    }
    
    func updateStatistics(){
        if let context = self.selectionContext,
            let statsMessageType = context.dependentMessage,
            let statsFor = context.statsFor{
            let interp = FITFitFileInterpret(fitFile: self.fitFile);

            //self.relatedMessage = self.fitFile[statsMessageType];
            var interval : (from:Date,to:Date)?
            if let ts = context.selectedMessage?.time(field: "timestamp"){
                
                let mf = interp.messageForTimestamp(messageType: statsFor, timestamp: ts)

                if let start = mf?.time(field: "start_time"),
                    let end = mf?.time(field: "timestamp"){
                    interval = (from:start,to:end);
                }
            }
            self.statistics = interp.statsForMessage(messageType: statsMessageType, interval: interval)
            let possibleFields = Array(self.fitFile.sampleValues(messageType: statsFor).keys)
            self.statsFields = interp.mapFields(from: self.displayFields, to: possibleFields)
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
                    let idx = self.selectedRow < self.messages.count ? self.selectedRow : 0
                    let message = self.messages[idx]
                    if let item = message.interpretedField(key: identifier),
                        let selectionContext = self.selectionContext{
                        cellView.textField?.stringValue = selectionContext.display(fieldValue: item)
                    }
                }else{
                    let idx = self.selectedRow < self.messages.count ? self.selectedRow : 0
                    let message = self.messages[idx]
                    if let item = message.interpretedField(key: identifier),
                        let selectionContext = self.selectionContext,
                        let relatedFields = self.statsFields?[identifier],
                        let stats = self.statistics{
                        if relatedFields.count > 0 && item.numberWithUnit != nil{
                            if let stat = stats[relatedFields[0]]{
                                if let avg : GCNumberWithUnit = stat.preferredStatisticsForField(fieldKey: identifier){
                                    cellView.textField?.stringValue = selectionContext.display(numberWithUnit: avg)
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
