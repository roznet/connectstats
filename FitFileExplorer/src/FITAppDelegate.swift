//
//  FITAppDelegate.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 04/11/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import Foundation
import Cocoa

class FITAppDelegate : NSObject, NSApplicationDelegate {
    
    // Trick to override default NSDocumentController as first instance of a
    // DocumentController will become the default. create it as variable in app delegate
    let documentController = FITDocumentController()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Force init of the shared global state
        _ = FITAppGlobal.shared
    }
    
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return false
    }
}
