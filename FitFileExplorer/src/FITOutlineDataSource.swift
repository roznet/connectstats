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
    
    let fitFile: FITFitFile
    var selectedMessageType : String?
    
    init(fitFile:FITFitFile) {
        self.fitFile = fitFile
        super.init()
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        return self.fitFile.allMessageTypes().count
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let types = self.fitFile.allMessageTypes(), index < types.count {
            return types[index]
        }
        return ""
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let cellView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("DataCell"), owner: self)
        if let cellView = cellView as? FITOutlineCellView {
            if let text = item as? String {
                cellView.textField?.stringValue = text
                let count = self.fitFile.message(forType: text).count()
                if count > 0{
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
            if let types = self.fitFile.allMessageTypes() {
                self.selectedMessageType = types[selected];
                NotificationCenter.default.post(name: FITOutlineDataSource.kFITNotificationOutlineSelectionChanged, object: self)
            }
        }
        
    }
}
