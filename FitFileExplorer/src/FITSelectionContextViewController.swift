//
//  FITSelectionContextViewController.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 03/12/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import Cocoa

class FITSelectionContextViewController: NSViewController {

    
    @IBOutlet weak var fieldForX: NSPopUpButton!
    @IBOutlet weak var fieldForY: NSPopUpButton!
    @IBOutlet weak var fieldForY2: NSPopUpButton!
    @IBOutlet weak var messageOverlay: NSPopUpButton!
    @IBOutlet weak var enableY2: NSButton!
    @IBOutlet weak var enableMessageOverlay: NSButton!
    @IBOutlet weak var fieldOverlay: NSPopUpButton!
    @IBOutlet weak var overlayFieldLabel: NSTextField!
    
    weak var graphViewController : FITGraphViewController?;
    
    var selectionContext : FITSelectionContext?
    
    func update(selectionContext: FITSelectionContext){
        self.selectionContext = selectionContext
        
        fieldForX.removeAllItems()
        fieldForY.removeAllItems()
        fieldForY2.removeAllItems()
        var xFields = selectionContext.availableDateFields()
        xFields.append(contentsOf: selectionContext.availableNumberFields())
        fieldForX.addItems(withTitles: xFields)
        fieldForY.addItems(withTitles: selectionContext.availableNumberFields())
        fieldForY2.addItems(withTitles: selectionContext.availableNumberFields())

        if let selectX = self.selectionContext?.selectedXField{
           fieldForX.selectItem(withTitle: selectX)
        }
        if let selectY = self.selectionContext?.selectedYField {
            fieldForY.selectItem(withTitle: selectY)
        }
        if let selectY2 = self.selectionContext?.selectedY2Field {
            fieldForY2.selectItem(withTitle: selectY2)
        }
        if let enableY2On = self.selectionContext?.enableY2 {
            enableY2.state = enableY2On ? .on : .off
            
            if enableY2On {
                enableMessageOverlay.isEnabled = false
                enableMessageOverlay.state = .off
                messageOverlay.isEnabled = false
                fieldOverlay.isEnabled = false
                overlayFieldLabel.isEnabled = false
            }else{
                enableMessageOverlay.isEnabled = true
                messageOverlay.isEnabled = true
                overlayFieldLabel.isEnabled = true
                fieldOverlay.isEnabled = true
                fieldOverlay.removeAllItems()
                fieldOverlay.addItems(withTitles: selectionContext.availableNumberFields())
            }
        }
    }
    
    @IBAction func updateField(_ sender: NSPopUpButton) {
        if let identifier = sender.identifier?.rawValue,
            let value = sender.selectedItem?.title,
            let selectionContext = self.selectionContext{
            if identifier == "popup_x_field" {
                selectionContext.selectedXField = value
            }else if identifier == "popup_y_field" {
                selectionContext.selectedYField = value
            }else if identifier == "popup_y2_field" {
                selectionContext.selectedY2Field = value;
            }
        }
    }
    @IBAction func toggleField(_ sender: NSButton) {
        if let identifier = sender.identifier?.rawValue,
            let selectionContext = self.selectionContext{
            if identifier == "button_enable_y2" {
                selectionContext.enableY2 = (sender.state == NSControl.StateValue.on)
            }
        }
    }
}
