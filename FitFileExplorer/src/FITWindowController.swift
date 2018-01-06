//
//  FITWindowController.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 29/11/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import Cocoa

class FITWindowController: NSWindowController {

    static let kNotificationToolBarSettingsChanged = Notification.Name("kNotificationToolBarSettingsChanged")
    let kToolBarItemSpeedUnitChoiceIdentifier = "SpeedUnitChoice"
    let kToolBarItemFieldDisplayChoiceIdentifier = "FieldDisplayChoice"
    
    @IBOutlet weak var toolbar: NSToolbar!
    
    @IBOutlet var speedUnitChoiceView: NSView!
    @IBOutlet weak var speedUnitChoicePopup: NSPopUpButton!
    @IBOutlet var fieldDisplayChoiceView: NSView!
    @IBOutlet weak var fieldDisplayChoice: NSPopUpButton!
    
    override func windowDidLoad() {
        super.windowDidLoad()
    
        
        self.toolbar.allowsUserCustomization = true
        self.toolbar.autosavesConfiguration = true
        
        self.toolbar.displayMode = .iconOnly
        
        let speedUnits = GCUnit.mps().compatibleUnits()
        self.speedUnitChoicePopup.removeAllItems()
        self.speedUnitChoicePopup.addItems(withTitles: speedUnits.map {
            $0.abbr
        })
        self.speedUnitChoicePopup.selectItem(withTitle: GCUnit.kph().abbr)
        var choices = GCFieldCache.availableLanguagesNames()
        choices?.append("Raw Fields")
        self.fieldDisplayChoice.removeAllItems()
        if let choices = choices {
            self.fieldDisplayChoice.addItems(withTitles: choices)
        }
        self.fieldDisplayChoice.selectItem(withTitle: "Raw Fields")
    }
    
    // MARK: - Tool bar button actions
    
    @IBAction func changeSpeedUnit(_ sender: NSPopUpButton) {
        let selected = GCUnit.mps().compatibleUnits().filter {
            $0.abbr == sender.selectedItem?.title
        }
        if selected.count > 0{
            self.splitViewController().selectionContext?.speedUnit = selected[0]
            self.splitViewController().settingsChanged(notification: Notification(name: FITWindowController.kNotificationToolBarSettingsChanged))
        }
    }
    @IBAction func changeFieldDisplay(_ sender: NSPopUpButton) {
        if let selectedTitle = sender.selectedItem?.title {
            if selectedTitle == "Raw Fields" {
                self.splitViewController().selectionContext?.prettyField = false
            }else{
                self.splitViewController().selectionContext?.prettyField = true
                if let idx = GCFieldCache.availableLanguagesNames().index(of: selectedTitle) {
                    let language = GCFieldCache.availableLanguagesCodes()[idx]
                    let cache = GCFieldCache(db: nil, andLanguage: language)
                    GCField.setFieldCache(cache)
                    GCFields.setFieldCache(cache)
                }
            }
            self.splitViewController().settingsChanged(notification: Notification(name: FITWindowController.kNotificationToolBarSettingsChanged))
        }
    }
    
    func splitViewController() -> FITSplitViewController {
        let contentView = self.contentViewController as! FITSplitViewController
        return contentView
    }
    
    // MARK: - NSToolbarDelegate
    
    /**
     Factory method to create NSToolbarItems.
     
     All NSToolbarItems have a unique identifer associated with them, used to tell your delegate/controller
     what toolbar items to initialize and return at various points.  Typically, for a given identifier,
     you need to generate a copy of your "master" toolbar item, and return.  The function
     creates an NSToolbarItem with a bunch of NSToolbarItem paramenters.
     
     It's easy to call this function repeatedly to generate lots of NSToolbarItems for your toolbar.
     
     The label, palettelabel, toolTip, action, and menu can all be nil, depending upon what you want
     the item to do.
     */
    func customToolbarItem(itemForItemIdentifier itemIdentifier: String, label: String, paletteLabel: String, toolTip: String, target: AnyObject, itemContent: AnyObject, action: Selector?, menu: NSMenu?) -> NSToolbarItem? {
        
        let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier( itemIdentifier))
        
        toolbarItem.label = label
        toolbarItem.paletteLabel = paletteLabel
        toolbarItem.toolTip = toolTip
        toolbarItem.target = target
        toolbarItem.action = action
        
        // Set the right attribute, depending on if we were given an image or a view.
        if (itemContent is NSImage) {
            let image: NSImage = itemContent as! NSImage
            toolbarItem.image = image
        }
        else if (itemContent is NSView) {
            let view: NSView = itemContent as! NSView
            toolbarItem.view = view
        }
        else {
            assertionFailure("Invalid itemContent: object")
        }
        
        /* If this NSToolbarItem is supposed to have a menu "form representation" associated with it
         (for text-only mode), we set it up here.  Actually, you have to hand an NSMenuItem
         (not a complete NSMenu) to the toolbar item, so we create a dummy NSMenuItem that has our real
         menu as a submenu.
         */
        // We actually need an NSMenuItem here, so we construct one.
        let menuItem: NSMenuItem = NSMenuItem()
        menuItem.submenu = menu
        menuItem.title = label
        toolbarItem.menuFormRepresentation = menuItem
        
        return toolbarItem
    }

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: String, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        var toolbarItem: NSToolbarItem = NSToolbarItem()
        
        /* We create a new NSToolbarItem, and then go through the process of setting up its
         attributes from the master toolbar item matching that identifier in our dictionary of items.
         */
        if (itemIdentifier == kToolBarItemSpeedUnitChoiceIdentifier) {
            // 1) Font style toolbar item.
            toolbarItem = customToolbarItem(itemForItemIdentifier: kToolBarItemSpeedUnitChoiceIdentifier, label: "Speed Unit", paletteLabel:"Speed Unit", toolTip: "Select your preferred speed unit", target: self, itemContent: self.speedUnitChoiceView, action: nil, menu: nil)!
        }else if(itemIdentifier == kToolBarItemFieldDisplayChoiceIdentifier){
            toolbarItem = customToolbarItem(itemForItemIdentifier: kToolBarItemFieldDisplayChoiceIdentifier, label: "Field Choice", paletteLabel:"Field Choice", toolTip: "Select your preferred Field Display", target: self, itemContent: self.fieldDisplayChoiceView, action: nil, menu: nil)!
            
        }
        
        
        return toolbarItem

    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [String] {
        return [ kToolBarItemSpeedUnitChoiceIdentifier, kToolBarItemFieldDisplayChoiceIdentifier ]
    }
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [String] {
        
        return [ kToolBarItemSpeedUnitChoiceIdentifier,
                 kToolBarItemFieldDisplayChoiceIdentifier,
                 NSToolbarItem.Identifier.space.rawValue,
                 NSToolbarItem.Identifier.flexibleSpace.rawValue,
                  ]
    }


}
