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
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let cache = GCFieldCache(db: nil, andLanguage: nil)
        GCField.setFieldCache(cache)
        GCFields.setFieldCache(cache)
    }
    
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return false
    }
}
