//
//  FITSplitViewController.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 05/11/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import Cocoa

class FITSplitViewController: NSSplitViewController {

    var outlineDataSource : FITOutlineDataSource? {
        didSet {
            self.outlineViewController()?.outlineDataSource = self.outlineDataSource
        }
    }
    
    var fieldsListDataSource : FITFieldsListDataSource?
    
    var fitFile : RZFitFile? {
        get {
            if let doc = self.representedObject as? FITDocument {
                return doc.fitFile
            }else{
                return nil
            }
            
        }
        set {
            self.representedObject = newValue
        }
    }
    var dataListDataSource : FITDataListDataSource?
    
    var selectionContext : FITSelectionContext?
    
    override var representedObject: Any? {
        didSet {
            if let file = self.fitFile {
                self.outlineDataSource = FITOutlineDataSource(fitFile: file)
                self.selectionContext = FITSelectionContext(fitFile: file)
            }
        }
    }
    
    //MARK: - View Controller Delegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(outlineDataSourceSelectionChanged(notification:)),
                                               name: FITOutlineDataSource.kFITNotificationOutlineSelectionChanged,
                                               object: self.outlineDataSource)
        
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        NotificationCenter.default.removeObserver(self)
    }
    

    //MARK: - Selection Changes
    
    func settingsChanged(notification : Notification){
        if let ds = self.fieldsListDataSource {
            self.detailTableViewController()?.updateWith(dataSource: ds)
        }
        self.detailSelectionChanged(notification: notification)
    }
    
    /**
     Notification call back from detail table
     */
    @objc func detailSelectionChanged(notification : Notification){
        if let fitFile = self.fitFile,
            let messageType = self.outlineDataSource?.selectedMessageType ?? fitFile.messageTypes.first {
            if let mef = self.fieldsListDataSource?.selectedField,
                let idx = self.fieldsListDataSource?.selectedRow,
                let selectionContext = self.selectionContext{
                if idx >= 0 {
                    selectionContext.selectMessageField(field: mef, atIndex:idx)
                    self.graphViewController()?.updateWith(selectionContext: selectionContext)
                    self.mapViewController()?.updateWith(selectionContext: selectionContext)
                    self.dataListDataSource = FITDataListDataSource(file: fitFile, messageType: messageType, selectedRow: idx, context: selectionContext)
                    self.dataViewController()?.update(with: self.dataListDataSource!)
                }
            }
        }
    }
    /**
     Notification call back from the outline table
     */
    @objc func outlineDataSourceSelectionChanged(notification : Notification){
        if let fitFile = self.fitFile,
            let messageType = self.outlineDataSource?.selectedMessageType ?? fitFile.messageTypes.first {
            var changed :Bool = false
            if self.fieldsListDataSource == nil {
                self.fieldsListDataSource = FITFieldsListDataSource(file: fitFile, messageType: messageType, context: self.selectionContext!)
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(detailSelectionChanged(notification:)),
                                                       name: FITFieldsListDataSource.kFITNotificationDetailSelectionChanged,
                                                       object: self.fieldsListDataSource)
                
                changed = true
            }else if( self.fieldsListDataSource?.messageType != messageType){
                changed = true;
                self.fieldsListDataSource?.messageType = messageType
            }
            if changed {
                self.selectionContext?.selectedMessageType = messageType
                if let ds = self.fieldsListDataSource {
                    self.detailTableViewController()?.updateWith(dataSource: ds)
                }
            }
        }
    }
    
    private func updateDependendWithSelectionContext(){
        
    }
    //MARK: - Access View Controllers
    func outlineViewController() -> FITOutlineViewController?{
        if self.splitViewItems.count > 0 {
            return self.splitViewItems[0].viewController as? FITOutlineViewController
        }else{
            return nil
        }
    }
    
    func detailTableViewController() -> FITDetailTableViewController?{
        if self.splitViewItems.count > 1 {
            return self.splitViewItems[1].viewController as? FITDetailTableViewController
        }else{
            return nil
        }
    }

    func dataViewController() -> FITDataViewController?{
        if self.splitViewItems.count > 2 {
            if let tabView = self.splitViewItems[2].viewController as? NSTabViewController{
                if tabView.tabViewItems.count > 0{
                    if let dataView = tabView.tabViewItems[0].viewController as? FITDataViewController{
                        return dataView;
                    }
                }
            }
        }
        return nil;

    }
    func graphViewController() -> FITGraphViewController? {
        if self.splitViewItems.count > 2 {
            if let tabView = self.splitViewItems[2].viewController as? NSTabViewController{
                if tabView.tabViewItems.count > 1{
                    if let graphView = tabView.tabViewItems[1].viewController as? FITGraphViewController{
                        return graphView;
                    }
                }
            }
        }
        return nil;
    }
    func mapViewController() -> FITMapViewController? {
        if self.splitViewItems.count > 2 {
            if let tabView = self.splitViewItems[2].viewController as? NSTabViewController{
                if tabView.tabViewItems.count > 2{
                    if let mapView = tabView.tabViewItems[2].viewController as? FITMapViewController{
                        return mapView;
                    }
                }
            }
        }
        return nil;
    }

}
