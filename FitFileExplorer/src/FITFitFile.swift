//
//  FITFitFile.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 12/11/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import Foundation

extension FITFitFile :Sequence {
    public typealias Iterator = NSFastEnumerationIterator
    
    public func makeIterator() -> NSFastEnumerationIterator {
        return NSFastEnumerationIterator(self)
    }
}
