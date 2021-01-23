//
//  FITDetailTableViewController.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 05/11/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import Cocoa
import RZUtilsMacOS
import RZUtilsSwift

class FITDetailTableViewController: NSViewController {

    @IBOutlet weak var detailTableView: RZTableView!
    @IBOutlet weak var messageTypeLabel: NSTextField!
    
    @IBOutlet weak var messageIndexField: NSTextField!
    @IBOutlet weak var totalMessagesLabel: NSTextField!
    
    @IBOutlet weak var selectedFieldLabel: NSTextField!
    @IBOutlet weak var selectedFieldUnits: NSPopUpButton!
    @IBOutlet weak var transportTable: NSButton!
    
    var detailListDataSource : FITDetailListDataSource? {
        return self.detailTableView.dataSource as? FITDetailListDataSource
    }
    
    var selectionContext : FITSelectionContext? {
        return self.detailListDataSource?.selectionContext
    }

    // MARK: - Selection and Choices
    

    func fieldUnitChoices() -> [String] {
        guard let context = self.selectionContext else {
            return []
        }
        
        if let selectedField = context.selectedField {
            if let _ = context.sampleNumberWithUnit(field: selectedField){
                return context.availableDisplayUnitsForField(field: selectedField).map { $0.display }
            }else if let _ = context.sampleTime(field: selectedField){
                return FITSelectionContext.DateTimeFormat.descriptions
            }
        }
        return []
    }
    
    func fieldUnitChoice() -> String? {
        guard let context = self.selectionContext else {
            return nil
        }
        
        if let selectedField = context.selectedField {
            if  let unit = context.displayUnit(field: selectedField) {
                return unit.display
            }else if let _ = context.sampleTime(field: selectedField){
                return context.dateTimeFormat.description
            }
        }
        return nil
    }
    
    func updateFieldUnitChoice(title : String){
        guard let context = self.selectionContext else {
            return
        }
        
        if let selectedField = context.selectedField {
            if let _ = context.sampleNumberWithUnit(field: selectedField){
                let units = context.availableDisplayUnitsForField(field: selectedField)
                let titles = units.map { $0.display }
                if let found = titles.firstIndex(of: title ) {
                    context.setDisplayUnitOverride(field: selectedField, unit: units[found])
                }
            }else if let _ = context.sampleTime(field: selectedField){
                if let _ = FITSelectionContext.DateTimeFormat.descriptions.firstIndex(of: title) {
                    context.dateTimeFormat = FITSelectionContext.DateTimeFormat(description: title)
                }
            }
        }
    }
    
    // MARK: - ViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.detailTableView.allowsColumnSelection = true;
        
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(detailSelectionChanged(notification:)),
                                               name: FITSelectionContext.kFITNotificationFieldSelectionChanged,
                                               object: self.selectionContext)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(detailSelectionChanged(notification:)),
                                               name: FITSelectionContext.kFITNotificationMessageSelectionChanged,
                                               object: self.selectionContext)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(messageTypeSelectionChanged(notification:)),
                                               name: FITSelectionContext.kFITNotificationMessageTypeChanged,
                                               object: self.selectionContext)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(configurationChange(notification:)),
                                               name: FITWindowController.kNotificationToolBarSettingsChanged,
                                               object: nil)
        self.disableAll()
        self.updateAfterMessageTypeChange()
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Callback Actions
    
    @IBAction func rowChanged(_ sender: Any) {
        if let row = Int(self.messageIndexField.stringValue) {
            self.detailTableView.scrollRowToVisible(row)
            self.detailTableView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
        }
    }

    @IBAction func transposeChanged(_ sender: Any) {
        if self.transportTable.state == .on {
            self.detailListDataSource?.messageInColumns = true
        }else{
            self.detailListDataSource?.messageInColumns = false
        }
        self.rebuildColumns()
        self.detailTableView.reloadData()
    }
    
    @IBAction func unitChanged(_ sender: Any) {
        //let idx = selectedFieldUnits.indexOfSelectedItem
        if let name = selectedFieldUnits.selectedItem?.title {
            self.updateFieldUnitChoice(title: name)
            self.detailTableView.reloadData()
        }
    }
    
    @IBAction func exportCSV(_ sender: Any) {
        if let dataSource = self.detailTableView.dataSource as? FITDetailListDataSource {
            let savePanel = NSSavePanel()

            savePanel.message = "Choose the location to save the csv file"
            savePanel.allowedFileTypes = [ "csv" ]
            let fitFile = dataSource.fitFile
            if let message = fitFile.messageTypeDescription(messageType: dataSource.messageType){
                var candidate = "newfile_\(message)"
                if let sourceURL = fitFile.sourceURL {
                    candidate = sourceURL.lastPathComponent.replacingOccurrences(of: ".fit", with: "_\(message)")
                }
                savePanel.nameFieldStringValue = candidate
                if savePanel.runModal() == NSApplication.ModalResponse.OK, let url = savePanel.url {
                    let csv = fitFile.csv(messageType: dataSource.messageType)
                    do {
                        try csv.joined(separator: "\n").write(to: url, atomically: true, encoding: String.Encoding.utf8)
                        
                    }catch{
                        RZSLog.error( "Failed to save \(url)")
                    }
                }
                
            }
        }
    }
    
    // MARK: - updates and sync
    
    @objc func messageTypeSelectionChanged( notification : Notification ){
        if let _ = notification.object as? FITSelectionContext {
            self.updateAfterMessageTypeChange()
        }
    }
    
    @objc func detailSelectionChanged( notification : Notification){
        if let _ = notification.object as? FITSelectionContext {
            self.updateAfterFieldSelectionChanged()
        }
    }
    
    
    @objc func configurationChange(notification: Notification){
        self.selectionContext?.clearDisplayUnitOverrides()
        self.updateAfterMessageTypeChange()
        self.detailTableView.reloadData()
    }
    
    func disableAll() {
        self.messageIndexField.stringValue = ""
        self.selectedFieldLabel.stringValue = "No Field Selected"
        self.messageTypeLabel.stringValue = "No Message Selected"
        self.selectedFieldUnits.removeAllItems()
        self.selectedFieldUnits.addItem(withTitle: "No Unit")
        self.selectedFieldUnits.isEnabled = false
    }
        
    func updateAfterFieldSelectionChanged(){
        guard let context = self.selectionContext else {
            self.disableAll()
            return
        }

        if context.messageIndex < 0 {
            self.messageIndexField.stringValue = ""
        }else{
            self.messageIndexField.stringValue = "\(context.messageIndex)"
        }

        if let selectedField = context.selectedField {
            self.selectedFieldLabel.stringValue = selectedField
            var enable = false
            if let sample = context.sampleMessage {
                if let _ = sample.interpretedField(key: selectedField)?.numberWithUnit {
                    enable = true
                    selectedFieldUnits.removeAllItems()
                    let choices = self.fieldUnitChoices()
                    if choices.count == 0{
                        enable = false
                        selectedFieldUnits.removeAllItems()
                        self.selectedFieldUnits.addItem(withTitle: "No Unit")
                    }else{
                        selectedFieldUnits.addItems(withTitles: choices)
                        if let  selectedUnit = self.fieldUnitChoice(),
                           let found = choices.firstIndex(of: selectedUnit){
                            selectedFieldUnits.selectItem(at: found)
                        }
                        if choices.count == 1 {
                            // no choices
                            enable = false
                        }
                    }
                }else if let _ = context.sampleTime(field: selectedField) {
                    enable = true
                    selectedFieldUnits.removeAllItems()
                    selectedFieldUnits.addItems(withTitles: FITSelectionContext.DateTimeFormat.descriptions)
                    if  let found = FITSelectionContext.DateTimeFormat.descriptions.firstIndex(of: context.dateTimeFormat.description){
                        selectedFieldUnits.selectItem(at: found)
                    }
                }else{
                    selectedFieldUnits.removeAllItems()
                    self.selectedFieldUnits.addItem(withTitle: "No Unit")
                }
            }
            selectedFieldUnits.isEnabled = enable
        }else{
            self.selectedFieldLabel.stringValue = "No Field Selected"
        }

        
        if context.messages.count > 0 {
            self.totalMessagesLabel.stringValue = " out of \(context.messages.count)"
        }else{
            self.totalMessagesLabel.stringValue = ""
        }
        
        self.messageTypeLabel.stringValue = context.messageTypeDescription
    }
    
    func rebuildColumns() {
        guard let detailListDataSource = self.detailListDataSource else {
            return
        }
        
        let columns : [NSTableColumn] = self.detailTableView.tableColumns
        var existing: [NSUserInterfaceItemIdentifier:NSTableColumn] = [:]
        
        for col in columns {
            existing[col.identifier] = col
        }
        
        let required = detailListDataSource.requiredTableColumnsIdentifiers()

        if required.count < columns.count{
            var toremove :[NSTableColumn] = []
            for item in required.count..<columns.count {
                toremove.append(columns[item])
            }
            for item in toremove {
                self.detailTableView.removeTableColumn(item)
            }
        }

        var idx : Int = 0
        for identifier in required {
            if idx < columns.count {
                let col = columns[idx];
                col.title = identifier
                col.identifier = NSUserInterfaceItemIdentifier(identifier)
            }else{
                let col = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(identifier))
                col.title = identifier
                self.detailTableView.addTableColumn(col)
            }
            idx += 1
        }
    }
    
    func updateAfterMessageTypeChange(){
        self.transportTable.isEnabled = false;
        self.transportTable.state = .off
        self.detailListDataSource?.messageInColumns = false
        
        if let selectionContext = self.selectionContext {
            if selectionContext.messages.count == 1 {
                self.transportTable.state = .on
                self.transportTable.isEnabled = true
                self.detailListDataSource?.messageInColumns = true
            }else if selectionContext.messages.count < 64 {
                self.transportTable.state = .off
                self.transportTable.isEnabled = true
            }
        }
        self.rebuildColumns()
        self.detailTableView.reloadData()
        
        self.updateAfterFieldSelectionChanged()
    }
    
    func setup(selectionContext : FITSelectionContext){
        let dataSource = FITDetailListDataSource(context: selectionContext)
        self.detailTableView.dataSource = dataSource
        self.detailTableView.delegate = dataSource
        self.detailTableView.rzTableViewDelegate = dataSource

    }
}
