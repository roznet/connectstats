//
//  FITDataViewController.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 21/05/2017.
//  Copyright © 2017 Brice Rosenzweig. All rights reserved.
//

import Cocoa

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
    
    var fitDataSource:FITDataListDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func update(with source:FITDataListDataSource){
        self.fitDataSource = source
        source.updateStatistics()
        self.tableView.dataSource = source
        self.tableView.delegate = source
        self.tableView.reloadData()
        
    }
    
    @IBAction func updateStatsFor(_ sender: NSPopUpButton) {
        if
            let value = sender.selectedItem?.title,
            let dataSource = self.fitDataSource{
            //dataSource.selectionContext?.dependentField = value
            self.tableView.reloadData()
        }
    }
    @IBAction func updateStatsUsing(_ sender: NSPopUpButton) {
        if
            let value = sender.selectedItem?.title,
            let dataSource = self.fitDataSource{
            dataSource.selectionContext?.dependentMessage = value
            dataSource.updateStatistics()
            self.tableView.reloadData()
        }
    }
    
    
}
