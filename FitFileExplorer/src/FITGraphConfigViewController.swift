//
//  FITSelectionContextViewController.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 03/12/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import Cocoa
import FitFileParser

class FITGraphConfigViewController: NSViewController {

    
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
    var overlaySelectionContext : FITSelectionContext?
    
    func setup(selectionContext : FITSelectionContext){
        self.selectionContext = selectionContext
        self.overlaySelectionContext = FITSelectionContext(fitFile: selectionContext.fitFile)
        self.overlaySelectionContext?.messageType = .lap
        self.overlaySelectionContext?.messageIndex = 0
        self.update()
    }
    
    func update(){
        guard let selectionContext = self.selectionContext,
              let overlaySelectionContext = self.overlaySelectionContext else {
            return
        }
        fieldForX.removeAllItems()
        fieldForY.removeAllItems()
        fieldForY2.removeAllItems()
        fieldOverlay.removeAllItems()
        
        var xFields = selectionContext.availableDateFields()
        xFields.append(contentsOf: selectionContext.availableNumberFields())
        fieldForX.addItems(withTitles: xFields)
        fieldForY.addItems(withTitles: selectionContext.availableNumberFields())
        fieldForY2.addItems(withTitles: selectionContext.availableNumberFields())
        fieldOverlay.addItems(withTitles: overlaySelectionContext.availableNumberFields())
        
        if let selectX = self.selectionContext?.selectedXField{
           fieldForX.selectItem(withTitle: selectX)
        }
        if let selectY = self.selectionContext?.selectedYField {
            fieldForY.selectItem(withTitle: selectY)
        }
        if let selectY2 = self.selectionContext?.selectedY2Field {
            fieldForY2.selectItem(withTitle: selectY2)
        }
        if let selectO = overlaySelectionContext.selectedField {
            fieldOverlay.selectItem(withTitle: selectO )
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
                let enableOverlay = overlaySelectionContext.enableY2
                enableMessageOverlay.state = enableOverlay ? .on : .off
                enableMessageOverlay.isEnabled = true
                messageOverlay.isEnabled = true
                overlayFieldLabel.isEnabled = true
                fieldOverlay.isEnabled = true
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
            }else if identifier == "popup_message_overlay" {
                if let messageType = FitFile.messageType(forDescription: value) {
                    overlaySelectionContext?.messageType = messageType
                    if messageType == .lap || messageType == .session {
                        overlaySelectionContext?.selectedXField = "start_time"
                    }else{
                        overlaySelectionContext?.selectedXField = "timestamp"
                    }
                    NotificationCenter.default.post(name: FITSelectionContext.kFITNotificationDisplayConfigChanged, object: self.selectionContext)
                }
            }else if identifier == "popup_field_overlay" {
                overlaySelectionContext?.selectedField = value
                NotificationCenter.default.post(name: FITSelectionContext.kFITNotificationDisplayConfigChanged, object: self.selectionContext)
            }
        }
    }
    @IBAction func toggleField(_ sender: NSButton) {
        if let identifier = sender.identifier?.rawValue,
            let selectionContext = self.selectionContext{
            if identifier == "button_enable_y2" {
                selectionContext.enableY2 = (sender.state == NSControl.StateValue.on)
            }else if identifier == "button_enable_overlay" {
                overlaySelectionContext?.enableY2 = (sender.state == NSControl.StateValue.on)
                NotificationCenter.default.post(name: FITSelectionContext.kFITNotificationDisplayConfigChanged, object: self.selectionContext)
            }
        }
    }
}
