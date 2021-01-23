//
//  FITOutlineViewController.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 05/11/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import Cocoa

class FITOutlineViewController: NSViewController {

    
    @IBOutlet weak var outlineView: NSOutlineView!
    
    var outlineDataSource : FITOutlineDataSource? = nil{
        didSet {
            self.outlineView.dataSource = outlineDataSource
            self.outlineView.delegate = outlineDataSource
        }
    }
    
    var selectionContext : FITSelectionContext? {
        return self.outlineDataSource?.selectionContext
    }
    
    func setup(selectionContext : FITSelectionContext){
        self.outlineDataSource = FITOutlineDataSource(selectionContext: selectionContext)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
    
        if let messageType = self.selectionContext?.messageType {
            if let idx = self.outlineDataSource?.orderedMessageTypes.firstIndex(of: messageType) {
                self.outlineView.selectRowIndexes(IndexSet(integer: idx), byExtendingSelection: false)
            }

        }
    }
    
}
