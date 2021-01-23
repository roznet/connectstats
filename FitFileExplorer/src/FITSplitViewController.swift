//
//  FITSplitViewController.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 05/11/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import Cocoa
import FitFileParser

class FITSplitViewController: NSSplitViewController {
    var selectionContext : FITSelectionContext?
    
    var fitFile : FitFile? {
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
    
    override var representedObject: Any? {
        didSet {
            if let file = (self.representedObject as? FITDocument)?.fitFile {
                let context = FITSelectionContext(fitFile: file)
                self.selectionContext = context
                self.outlineViewController()?.setup(selectionContext: context)
                self.detailTableViewController()?.setup(selectionContext: context)
                self.graphViewController()?.setup(selectionContext: context)
                self.mapViewController()?.setup(selectionContext: context)
                self.dataViewController()?.setup(selectionContext: context)
            }
        }
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
