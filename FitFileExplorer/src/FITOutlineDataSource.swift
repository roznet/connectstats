//
//  FITOutlineDataSource.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 04/11/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import Cocoa

class FITOutlineDataSource: NSObject,NSOutlineViewDataSource,NSOutlineViewDelegate {
    
    static let kFITNotificationOutlineSelectionChanged = Notification.Name( "kFITNotificationOutlineSelectionChanged" )
    
    let selectionContext : FITSelectionContext
    
    var fitFile: RZFitFile {
        return self.selectionContext.fitFile
    }
    
    
    var selectedMessageType : RZFitMessageType {
        return self.selectionContext.messageType
    }
    
    init(selectionContext : FITSelectionContext) {
        self.selectionContext = selectionContext
        super.init()
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        return self.fitFile.messageTypes.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        let types = Array(self.fitFile.messageTypes)
        
        if index < types.count {
            return types[index]
        }
        return FIT_MESG_NUM_INVALID
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let cellView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("DataCell"), owner: self)
        if let cellView = cellView as? FITOutlineCellView {
            cellView.textField?.stringValue = ""
            cellView.detailTextField.stringValue = ""
            
            if let type = item as? RZFitMessageType,
                let text = self.fitFile.messageTypeDescription(messageType: type){
                
                cellView.textField?.stringValue = text
                if let count = self.fitFile.messagesByType[type]?.count {
                    cellView.detailTextField.stringValue = "(\(count) items)"
                }else{
                    cellView.detailTextField.stringValue = ""
                }
                
            }
            cellView.imageView = nil
            
        }
        return cellView
    }
    func outlineViewSelectionDidChange(_ notification: Notification) {
        if let obj = notification.object as? NSOutlineView {
            let selected = obj.selectedRow;
            let types = Array(self.fitFile.messageTypes)
            
            if selected < types.count {
                if( types[selected] != self.selectionContext.messageType){
                    self.selectionContext.messageType = types[selected];
                    NotificationCenter.default.post(name: FITOutlineDataSource.kFITNotificationOutlineSelectionChanged, object: self)
                }
            }
        }
        
    }
}
