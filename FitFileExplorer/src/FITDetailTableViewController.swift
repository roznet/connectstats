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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.detailTableView.allowsColumnSelection = true;
        
    }
    
    func updateWith(dataSource : FITDetailListDataSource){
        let columns : [NSTableColumn] = self.detailTableView.tableColumns
        
        //self.detailTableView.dataSource = nil
        //self.detailTableView.delegate = nil

        var existing: [NSUserInterfaceItemIdentifier:NSTableColumn] = [:]
        
        for col in columns {
            existing[col.identifier] = col
            
        }
        
        let required = dataSource.requiredTableColumnsIdentifiers()

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
        
        self.detailTableView.dataSource = dataSource
        self.detailTableView.delegate = dataSource
        self.detailTableView.rzTableViewDelegate = dataSource
        self.detailTableView.reloadData()
    }
}
