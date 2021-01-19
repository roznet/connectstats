//
//  FITDataViewController.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 21/05/2017.
//  Copyright © 2017 Brice Rosenzweig. All rights reserved.
//

import Cocoa
import FitFileParser

class FITDataViewController: NSViewController {

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
     */

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var statsUsing: NSPopUpButton!
    @IBOutlet weak var statsFor: NSPopUpButton!
    
    var dataListDataSource:FITDataListDataSource? {
        didSet {
            self.tableView.dataSource = dataListDataSource
            self.tableView.delegate = dataListDataSource
        }
    }
    
    var selectionContext : FITSelectionContext? {
        self.dataListDataSource?.selectionContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewWillAppear() {
        if let selectionContext = self.dataListDataSource?.selectionContext {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(selectionContextChanged(notification:)),
                                                   name: FITSelectionContext.kFITNotificationMessageTypeChanged,
                                                   object: selectionContext)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(selectionContextChanged(notification:)),
                                                   name: FITSelectionContext.kFITNotificationFieldSelectionChanged,
                                                   object: selectionContext)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(selectionContextChanged(notification:)),
                                                   name: FITSelectionContext.kFITNotificationDisplayConfigChanged,
                                                   object: selectionContext)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(selectionContextChanged(notification:)),
                                                   name: FITWindowController.kNotificationToolBarSettingsChanged,
                                                   object: nil)
        }
        self.updatePopup()
        self.updateStatistics()
        super.viewWillAppear()
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        NotificationCenter.default.removeObserver(self)
    }
    
    func setup(selectionContext : FITSelectionContext){
        self.dataListDataSource = FITDataListDataSource(context: selectionContext)
        
    }
    
    func updatePopup() {
        if let ds = self.dataListDataSource{
            if let mt = ds.selectionContext.statsUsing,
                let title = ds.selectionContext.fitFile.messageTypeDescription(messageType: mt){
                self.statsUsing.selectItem(withTitle: title)
            }
            if let mt = ds.selectionContext.statsFor,
                let title = ds.selectionContext.fitFile.messageTypeDescription(messageType: mt){
                self.statsFor.selectItem(withTitle: title)
            }
        }
    }
    
    @objc func selectionContextChanged(notification: Notification){
        self.updatePopup()
        self.updateStatistics()
    }

    func updateStatistics() {
        if let ds = self.dataListDataSource {
            DispatchQueue.global(qos: .userInitiated).async {
                // update stats in background then relad on main
                ds.updateStatistics()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    @IBAction func updateStatsFor(_ sender: NSPopUpButton) {
        if
            let value = sender.selectedItem?.title,
            let mesgnum = FitFile.messageType(forDescription: value),
            let ds = self.dataListDataSource{
            ds.selectionContext.statsFor = mesgnum
            self.updateStatistics()
        }
    }
    @IBAction func updateStatsUsing(_ sender: NSPopUpButton) {
        if
            let value = sender.selectedItem?.title,
            let mesgnum = FitFile.messageType(forDescription: value),
            let dataSource = self.dataListDataSource{
            dataSource.selectionContext.statsUsing = mesgnum
            self.updateStatistics()
        }
    }
    
    
}
