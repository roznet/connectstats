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
@objc public class RZNumberWithUnitGeometry : NSObject {
    
    var unitSize : CGSize = CGSize.zero
    var numberSize : CGSize = CGSize.zero
    public var totalSize : CGSize = CGSize.zero
    
    var defaultNumberAttribute : [NSAttributedString.Key:Any] = [:]
    var defaultUnitAttribute : [NSAttributedString.Key:Any] = [:]
    
    var defaultSpacing : CGFloat = 0.0

    var count : UInt = 0
    
    @objc public override init() {
        super.init()
    }
    
    @objc public static func geometry() -> RZNumberWithUnitGeometry {
        return RZNumberWithUnitGeometry()
    }
    
    @objc public func reset() {
        self.unitSize = CGSize.zero
        self.numberSize = CGSize.zero
        self.totalSize = CGSize.zero
        self.count = 0
    }
    
    @objc public func adjust(for numberWithUnit: GCNumberWithUnit,
                       numberAttribute : [NSAttributedString.Key:Any]? = nil,
                       unitAttribute : [NSAttributedString.Key:Any]? = nil){
        
        let unitAttribute = unitAttribute ?? self.defaultUnitAttribute
        let numberAttribute = numberAttribute ?? self.defaultNumberAttribute

        let fmtNoUnit = numberWithUnit.formatDoubleNoUnits()
        let fmt  = numberWithUnit.formatDouble()
        let fmtUnit = numberWithUnit.unit.abbr
        
        let numberSize = (fmtNoUnit as NSString).size(withAttributes: numberAttribute)
        self.numberSize.max(with: numberSize)

        if( fmt != fmtNoUnit ){
            let unitSize   = (fmtUnit as NSString).size(withAttributes: unitAttribute)
            self.unitSize.max(with: unitSize)
            self.totalSize.height += max(unitSize.height, numberSize.height)
        }else{
            self.totalSize.height += numberSize.height
        }
        self.totalSize.width = self.unitSize.width+self.numberSize.width+self.spacing(numberAttribute: numberAttribute)
        self.count += 1
    }
    
    func spacing(numberAttribute : [NSAttributedString.Key:Any]? = nil) -> CGFloat {
        let oneSize = (" " as NSString).size(withAttributes: numberAttribute ?? self.defaultNumberAttribute )
        return max(oneSize.width, self.defaultSpacing)
    }
    
    public func drawInRect(_ rect : CGRect,
                           numberWithUnit : GCNumberWithUnit,
                           numberAttribute : [NSAttributedString.Key:Any]? = nil,
                           unitAttribute : [NSAttributedString.Key:Any]? = nil){
        
        let unitAttribute = unitAttribute ?? self.defaultUnitAttribute
        let numberAttribute = numberAttribute ?? self.defaultNumberAttribute
        
        var numberPoint = rect.origin
        var unitPoint = rect.origin
        
        let fmtNoUnit = numberWithUnit.formatDoubleNoUnits()
        let fmt = numberWithUnit.formatDouble()
        let fmtUnit = numberWithUnit.unit.abbr

        let currentNumberSize = (fmtNoUnit as NSString).size(withAttributes: numberAttribute)
        //let currentUnitSize = (fmtUnit as NSString).size(withAttributes: unitAttribute)
        
        //     |-----||------!
        //       23.2 km
        //        169 km
        //      15:05 min/km
        
        if( fmt != fmtNoUnit ){
            unitPoint.x += numberSize.width + self.spacing(numberAttribute: numberAttribute)
            numberPoint.x += (numberSize.width - currentNumberSize.width)
        }else{
            numberPoint.x += (totalSize.width - currentNumberSize.width - (unitSize.width/2.0));
        }
        (fmtNoUnit as NSString).draw(at: numberPoint, withAttributes: numberAttribute)
        if( fmt != fmtNoUnit ){
            (fmtUnit as NSString).draw(at: unitPoint, withAttributes: unitAttribute)
        }

    }
    
    
}
