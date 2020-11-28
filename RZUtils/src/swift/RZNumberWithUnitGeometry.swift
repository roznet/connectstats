//
//  GCNumberWithUnit+Geometry.swift
//  RZUtilsSwift
//
//  Created by Brice Rosenzweig on 20/11/2020.
//  Copyright © 2020 Brice Rosenzweig. All rights reserved.
//

import Foundation
import RZUtils

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

extension CGSize {
    mutating func max( with : CGSize ){
        if self.width < with.width {
            self.width = with.width
        }
        if self.height < with.height {
            self.height = with.height
        }
    }
}
public class RZNumberWithUnitGeometry {
    
    var unitSize : CGSize = CGSize.zero
    var numberSize : CGSize = CGSize.zero
    public var totalSize : CGSize = CGSize.zero
    
    var defaultNumberAttribute : [NSAttributedString.Key:Any] = [:]
    var defaultUnitAttribute : [NSAttributedString.Key:Any] = [:]
    
    var defaultSpacing : CGFloat = 0.0

    var count : UInt = 0
    
    public init() {
        
    }
    
    public func reset() {
        self.unitSize = CGSize.zero
        self.numberSize = CGSize.zero
        self.totalSize = CGSize.zero
        self.count = 0
    }
    
    public func adjust(for numberWithUnit: GCNumberWithUnit,
                       numberAttribute : [NSAttributedString.Key:Any]? = nil,
                       unitAttribute : [NSAttributedString.Key:Any]?){
        
        let fmtNoUnit = numberWithUnit.formatDoubleNoUnits()
        let fmt  = numberWithUnit.formatDouble()
        let fmtUnit = numberWithUnit.unit.abbr
        
        let numberSize = (fmtNoUnit as NSString).size(withAttributes: self.defaultNumberAttribute)
        self.numberSize.max(with: numberSize)

        if( fmt != fmtNoUnit ){
            let unitSize   = (fmtUnit as NSString).size(withAttributes: self.defaultUnitAttribute)
            self.unitSize.max(with: unitSize)
            self.totalSize.height += max(unitSize.height, numberSize.height)
        }else{
            self.totalSize.height += numberSize.height
        }
        self.totalSize.width = self.unitSize.width+self.numberSize.width+self.defaultSpacing
        self.count += 1
    }
    
    
}
