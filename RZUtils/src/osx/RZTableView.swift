//
//  RZTableView.swift
//  RZUtils
//
//  Created by Brice Rosenzweig on 19/11/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import Cocoa

public protocol RZTableViewDelegate {
    func userClicked(_ tableView : RZTableView, row:Int, column:Int)
}

public class RZTableView: NSTableView {

    public var rzTableViewDelegate : RZTableViewDelegate?
    
    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    public override func mouseDown(with event: NSEvent) {
        let globalLocation:NSPoint  = event.locationInWindow
        
        let localLocation:NSPoint  = self.convert(globalLocation, from: nil)
        let clickedRow:Int = self.row(at: localLocation)
        let clickedColumn:Int = self.column(at: localLocation)
        
        super.mouseDown(with: event)
        if( clickedRow != -1 || clickedColumn != -1){
            self.rzTableViewDelegate?.userClicked(self, row: clickedRow, column: clickedColumn)
        }
    }
    
}
