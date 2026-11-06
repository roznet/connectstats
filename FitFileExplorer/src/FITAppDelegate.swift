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
    static let reviewPrompt = GCAppReviewPrompt(daysUntilPrompt: 5, usesUntilPrompt: 10)

    // Trick to override default NSDocumentController as first instance of a
    // DocumentController will become the default. create it as variable in app delegate
    let documentController = FITDocumentController()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        #if DEBUG
        if RZSystemInfo.isDebuggerAttached() {
            RZLogSetOutputToConsole(true);
        }
        #endif
        // Force init of the shared global state
        _ = FITAppGlobal.shared
        FITAppDelegate.reviewPrompt.recordUse()
    }
    
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return false
    }
}
