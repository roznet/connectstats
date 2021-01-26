//
//  FITGraphViewController.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 12/11/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import Cocoa
import FitFileParser


class FITGraphViewController: NSViewController {

    @IBOutlet weak var graphCustomView: NSView!
    
    var selectionContextViewController : FITGraphConfigViewController?
    
    var graphView : GCSimpleGraphView?
    
    var selectionContext : FITSelectionContext?
    
    var overlaySelectionContext : FITSelectionContext?
    var overlayEnabled : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.graphView = GCSimpleGraphView(frame: self.graphCustomView.frame)
        self.graphCustomView.addSubview(self.graphView!)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        self.updateGraphDataSource()
        if let selectionContext = self.selectionContext {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(selectionContextChanged(notification:)),
                                                   name: FITSelectionContext.kFITNotificationFieldSelectionChanged,
                                                   object: selectionContext)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(messageTypeChanged(notification:)),
                                                   name: FITSelectionContext.kFITNotificationMessageTypeChanged,
                                                   object: selectionContext)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(selectionContextChanged(notification:)),
                                                   name: FITSelectionContext.kFITNotificationDisplayConfigChanged,
                                                   object: selectionContext)
        }
    }
    
    override func viewWillDisappear() {
        NotificationCenter.default.removeObserver(self)
        super.viewWillDisappear()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        let newFrame = NSMakeRect(0.0, 0.0, self.graphCustomView.frame.width, self.graphCustomView.frame.height)
        self.graphView?.frame = newFrame
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedGraphContext"{
            if let scv = segue.destinationController as? FITGraphConfigViewController{
                self.selectionContextViewController = scv
                self.selectionContextViewController?.graphViewController = self
            }
        }
    }
    
    @objc func messageTypeChanged(notification : Notification ){
        self.updateGraphDataSource()
    }
    
    @objc func selectionContextChanged(notification : Notification){
        self.updateGraphDataSource()
    }
    func updateGraphDataSource( ){
        guard let selectionContext = self.selectionContext else {
            return
        }
        
        if let svc = self.selectionContextViewController {
            svc.update()
        }
        if let ds = selectionContext.graphDataSource() {
            if let overlaySelectionContext = self.selectionContextViewController?.overlaySelectionContext {
                if overlaySelectionContext.enableY2,
                   let selectedField = overlaySelectionContext.selectedField,
                   let (dh,_) = overlaySelectionContext.graphDataHolder(field: selectedField,
                                                                    color: NSColor.systemBrown,
                                                                    fillColor: NSColor.systemBrown.withAlphaComponent(0.5) ) {
                    if dh.yUnit != ds.yUnit(0) {
                        dh.axisForSerie = 1
                    }else{
                        dh.axisForSerie = 0
                    }
                    ds.add(dh)
                }
            }
            
            self.graphView?.dataSource = ds
            self.graphView?.displayConfig = ds
            self.graphView?.needsDisplay = true
        }
    }
    
    func setup(selectionContext : FITSelectionContext){
        self.selectionContext = selectionContext
        if let svc = self.selectionContextViewController {
            svc.setup(selectionContext: selectionContext)
        }

    }
    
}
