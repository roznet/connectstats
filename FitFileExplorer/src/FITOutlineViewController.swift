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
    
    var outlineDataSource : FITOutlineDataSource? {
        didSet {
            self.outlineView.dataSource = self.outlineDataSource
            self.outlineView.delegate = self.outlineDataSource
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    
    
}
