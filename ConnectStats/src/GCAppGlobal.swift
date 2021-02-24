//
//  AppGlobal.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 02/10/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import Foundation

public extension GCAppGlobal{
    static func dispatchQueue() -> DispatchQueue {
        return GCAppGlobal.worker();
    }
    
    static func handleAppRating() {
        
    }
}
