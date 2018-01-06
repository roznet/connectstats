//
//  RZSAttributedString.swift
//  RZUtilsSwift
//
//  Created by Brice Rosenzweig on 12/08/2017.
//  Copyright © 2017 Brice Rosenzweig. All rights reserved.
//

import Foundation

extension NSAttributedString {
    static public func convertObjcAttributesDict( attributes: [String:Any]?) -> [NSAttributedStringKey:Any]? {
        var rv : [NSAttributedStringKey:Any]?
        
        if let attributes = attributes {
            rv = Dictionary(uniqueKeysWithValues:
                attributes.lazy.map { (NSAttributedStringKey($0.key), $0.value) }
            )
        }
        return rv
    }
}
